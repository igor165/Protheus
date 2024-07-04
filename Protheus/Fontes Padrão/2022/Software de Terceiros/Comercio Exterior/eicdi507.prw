/*
Funcao      : EICDI507
Parametros  : Nil
Retorno     : Nenhum
Objetivos   : Funcões responsáveis pelo WorkFlow do Encerramento do Processo de Importação
Autor       : Guilherme Fernandes Pilan - GFP
Data/Hora   : 28/03/2011 09:50
Revisao     :
Obs.        :
*/
*------------------*
Function EICDI507() 
*------------------*
Return Nil
*----------------------------------*
Function EICWFDSVAR(oEasyWorkFlow)
*----------------------------------*
Local aOrd := SaveOrd("SW6"), i
Private aCposWF := {}  // GFP - 03/09/2013

cRet:= oEasyWorkFlow:RetChave()
SW6->(DbSetOrder(1))

If SW6->(DbSeek(cRet))
   If !Empty(SW6->W6_DT_ENCE) 
      oEasyWorkFlow:AddVal("EMBNUM"   , SW6->W6_HAWB    )
      oEasyWorkFlow:AddVal("DTENCER"  , SW6->W6_DT_ENCE )
      oEasyWorkFlow:AddVal("DATA"     , dDataBase       )
   EndIf
   
   IF(EasyEntryPoint("EICDI507"),ExecBlock("EICDI507",.F.,.F.,"CPOS_WF"),)   // GFP - 03/09/2013
   
   If Len(aCposWF) > 0
      For i := 1 To Len(aCposWF)
         oEasyWorkFlow:AddVal(aCposWF[i][1]  , aCposWF[i][2] )
      Next i
   EndIf
   
EndIf                                              

RestOrd(aOrd, .T.)
Return Nil

*-------------------------------*
Function EICWFDSENV(oEasyWorkFlow)
*-------------------------------*

RecLock("SW6",.F.)
SW6->W6_ID_ENCE := oEasyWorkFlow:RetID()
MsUnlock()

Return Nil 

*-------------------------------*
Function EICWFDSCOND()
*-------------------------------*
Local aChaves := {}

Begin Sequence

SW6->(DbSetOrder(1))
If SW6->(DbSeek(xFilial("SW6")+M->W6_HAWB))   
   If !Empty(M->W6_DT_ENCE) .AND. M->W6_DT_ENCE <> SW6->W6_DT_ENCE  
      aAdd(aChaves,xFilial("SW6")+M->W6_HAWB)
   EndIf
EndIf   
   
End Sequence

Return aChaves