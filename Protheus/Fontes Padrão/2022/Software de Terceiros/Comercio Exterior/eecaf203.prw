/*
Funcao      : EECAF203
Parametros  : Nil                                       
Retorno     : Nenhum
Objetivos   : Funcões responsáveis pelo WorkFlow de Cambio
Autor       : Guilherme Fernandes Pilan - GFP
Data/Hora   : 25/04/2011 17:08
Revisao     :
Obs.        :
*/
*------------------*
Function EECAF203() 
*------------------*
Return Nil
*----------------------------------*
Function EECWFLIVAR(oEasyWorkFlow)
*----------------------------------*
Local aOrd := SaveOrd("EEQ"), i
Private aCposWF := {}  // GFP - 03/09/2013

cRet:= oEasyWorkFlow:RetChave()
EEQ->(DbSetOrder(1))

If EEQ->(DbSeek(cRet)) 
   If !Empty(EEQ->EEQ_PGT)
      oEasyWorkFlow:AddVal("PROCESSO", EEQ->EEQ_PREEMB )
      oEasyWorkFlow:AddVal("DTVENC"  , EEQ->EEQ_VCT    )
      oEasyWorkFlow:AddVal("INVOICE" , EEQ->EEQ_NRINVO )
      oEasyWorkFlow:AddVal("DTPGT"   , EEQ->EEQ_PGT    )
      oEasyWorkFlow:AddVal("PARCELA" , EEQ->EEQ_PARC   )
      oEasyWorkFlow:AddVal("DATA"    , dDataBase       )
      
      IF(EasyEntryPoint("EECAF203"),ExecBlock("EECAF203",.F.,.F.,"CPOS_WF"),)   // GFP - 03/09/2013
   
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
Function EECWFLIENV(oEasyWorkFlow)
*-------------------------------*

RecLock("EEQ",.F.)
EEQ->EEQ_ID_LB := oEasyWorkFlow:RetID()
MsUnlock()

Return Nil

*-------------------------------*
Function EECWFLICOND()
*-------------------------------*
Local aChaves := {}

Begin Sequence

TMP->(DbGoTop())
Do While TMP->(!Eof()) .AND. EEQ->EEQ_FILIAL == TMP->EEQ_FILIAL .AND. EEQ->EEQ_PREEMB == TMP->EEQ_PREEMB
   If !Empty(TMP->EEQ_PGT) .AND. TMP->EEQ_PGT <> EEQ->EEQ_PGT
      aAdd(aChaves,xFilial("EEQ")+AvKey(TMP->EEQ_PREEMB,"EEQ_PREEMB")+AvKey(TMP->EEQ_PARC,"EEQ_PARC"))
      BREAK
   EndIf
   TMP->(DbSkip())
EndDo   

   
End Sequence

Return aChaves