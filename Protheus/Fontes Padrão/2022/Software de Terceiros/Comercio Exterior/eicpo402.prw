/*
Funcao      : EICPO402
Parametros  : Nil
Retorno     : Nenhum
Objetivos   : Funcões responsáveis pelo WorkFlow do PO
Autor       : Guilherme Fernandes Pilan - GFP
Data/Hora   : 21/03/2011 15:20
Revisao     :
Obs.        :
*/
*------------------*
Function EICPO402() 
*------------------*
Return Nil
*----------------------------------*
Function EICWFPOVAR(oEasyWorkFlow)
*----------------------------------*
Local aOrd := SaveOrd("SW2"), i
Local cDetail := ""
Private aCposWF := {}  // GFP - 03/09/2013

cRet:= oEasyWorkFlow:RetChave()
SW2->(DbSetOrder(1))
SW3->(DbSetOrder(1))

If SW2->(DbSeek(cRet)) 
   If SW3->(DbSeek(xFilial("SW2")+SW2->W2_PO_NUM))
      Do While SW3->(!Eof()) .AND. xFilial("SW3") == SW3->W3_FILIAL .AND. SW3->W3_PO_NUM == SW2->W2_PO_NUM
         If SW3->W3_FLUXO == "1"//Work->(dbSeek(SW3->(W3_CC+W3_SI_NUM+W3_COD_I+Str(W3_REG,AVSX3("W3_REG",3))))) .AND. Work->WKFLUXO_O <> Work->WKFLUXO
            cDetail += "Código Item: " + SW3->W3_COD_I + "<br>"
         EndIf
         SW3->(DbSkip())
      EndDo
      oEasyWorkFlow:AddVal("PONUM" , SW2->W2_PO_NUM)
      oEasyWorkFlow:AddVal("ITENS" , cDetail       )
      oEasyWorkFlow:AddVal("DATA"  , dDataBase     )  
   EndIf
   
   IF(EasyEntryPoint("EICPO402"),ExecBlock("EICPO402",.F.,.F.,"CPOS_WF"),)   // GFP - 03/09/2013
   
   If Len(aCposWF) > 0
      For i := 1 To Len(aCposWF)
         oEasyWorkFlow:AddVal(aCposWF[i][1]  , aCposWF[i][2] )
      Next i
   EndIf  
   
EndIf

RestOrd(aOrd, .T.)
Return Nil

*-------------------------------*
Function EICWFPOENV(oEasyWorkFlow)
*-------------------------------*

RecLock("SW2",.F.)
SW2->W2_ID_ANU := oEasyWorkFlow:RetID()
MsUnlock()

Return Nil

*-------------------------------*
Function EICWFPOCOND()
*-------------------------------*
Local aChaves := {}

Begin Sequence

   //If SW3->(DbSeek(xFilial("SW3")+SW2->W2_PO_NUM))
      Work->(dbGoTop())
      Do While Work->(!Eof())// .AND. xFilial("SW3") == SW3->W3_FILIAL .AND. SW3->W3_PO_NUM == SW2->W2_PO_NUM
         If Work->WKFLUXO == "1" .AND. Work->WKFLUXO <> Work->WKFLUXO_O// Verifica se item é anuente
            aAdd(aChaves,xFilial("SW2")+TPO_NUM) // SW2->W2_PO_NUM)
            BREAK
         EndIf
         WORK->(DbSkip())
      EndDo
   //EndIf
   
End Sequence

Return aChaves