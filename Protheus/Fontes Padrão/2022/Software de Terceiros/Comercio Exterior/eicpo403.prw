#include "Average.ch"
/*
Funcao      : EICPO403
Parametros  : Nil
Retorno     : Nenhum
Objetivos   : Funcões responsáveis pelo WorkFlow do PO
Autor       : Guilherme Fernandes Pilan - GFP
Data/Hora   : 17/05/2011 18:57
Revisao     :
Obs.        :
*/
*------------------*
Function EICPO403() 
*------------------*
Return Nil
*----------------------------------*
Function EICWFPUVAR(oEasyWorkFlow)
*----------------------------------*
Local aOrd := SaveOrd("SW2"), i
Local cDetail := Space(0)
Private aCposWF := {}  // GFP - 03/09/2013

cRet:= oEasyWorkFlow:RetChave()
SW2->(DbSetOrder(1))
SW3->(DbSetOrder(1))

If SW2->(DbSeek(cRet))
   If SW3->(DbSeek(xFilial("SW2")+SW2->W2_PO_NUM))
      Do While SW3->(!Eof()) .AND. xFilial("SW3") == SW3->W3_FILIAL .AND. SW3->W3_PO_NUM == SW2->W2_PO_NUM
         If !Empty(SW3->W3_DT_EMB) .AND. SW3->W3_SEQ == 0
            cDetail += "Código Item: " + AllTrim(SW3->W3_COD_I) + "<br>"
            cDetail += "Previsão de Embarque: " + AllTrim(DtoC(SW3->W3_DT_EMB)) + "<br><br>"
         EndIf
         SW3->(DbSkip())
      EndDo  
      oEasyWorkFlow:AddVal("PONUM"    , SW2->W2_PO_NUM)
      oEasyWorkFlow:AddVal("ITENS"    , cDetail       )
      oEasyWorkFlow:AddVal("DATA"     , dDataBase     )
      
         
      IF(EasyEntryPoint("EICPO403"),ExecBlock("EICPO403",.F.,.F.,"CPOS_WF"),)   // GFP - 03/09/2013
   
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
Function EICWFPUENV(oEasyWorkFlow)
*-------------------------------*

RecLock("SW2",.F.)
SW2->W2_ID_PRV := oEasyWorkFlow:RetID()
MsUnlock()

Return Nil

*-------------------------------*
Function EICWFPUCOND()
*-------------------------------*
Local aChaves := {}

Begin Sequence

      SW3->(dbSetOrder(8))  //W3_FILIAL+W3_PO_NUM+W3_POSICAO
      Work->(dbGoTop())
      Do While Work->(!Eof())
         If !SW3->(DbSeek(xFilial("SW3")+TPO_NUM+WORK->WKPOSICAO)) .OR. Work->WKDT_EMB <> Work->WKDTEMB_S
            aAdd(aChaves,xFilial("SW2")+TPO_NUM) //SW2->W2_PO_NUM
            BREAK
         EndIf
         WORK->(DbSkip())
      EndDo
   
End Sequence

Return aChaves