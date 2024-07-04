#INCLUDE "Average.ch"

/*
Funcao      : EICDI159
Parametros  : Nil
Retorno     : Nenhum
Objetivos   : Funcões responsáveis pelo WorkFlow da NF
Autor       : Guilherme Fernandes Pilan - GFP
Data/Hora   : 28/03/2011 17:11
Revisao     :
Obs.        :
*/
*------------------*
Function EICDI159() 
*------------------*
Return Nil
*----------------------------------*
Function EICWFNFVAR(oEasyWorkFlow)
*----------------------------------*
Local aOrd := SaveOrd({"SWN","SW6"}), i
Private aCposWF := {}  // GFP - 03/09/2013

cRet:= oEasyWorkFlow:RetChave()
SF1->(DbSetOrder(5))
SW6->(dbSetOrder(1))

If SW6->(dbSeek(cRet)) .And. SF1->(DbSeek(xFilial("SF1") + SW6->W6_HAWB))
   oEasyWorkFlow:AddVal("EMBNUM"  , SF1->F1_HAWB     )
   oEasyWorkFlow:AddVal("NFE"     , SF1->F1_DOC      )
   oEasyWorkFlow:AddVal("SERIE"   , Transform(SF1->F1_SERIE,AvSx3("F1_SERIE",AV_PICTURE))    )
   oEasyWorkFlow:AddVal("DATA"    , SF1->F1_EMISSAO  )
   oEasyWorkFlow:AddVal("DTATUAL" , dDatabase        )
      
   IF(EasyEntryPoint("EICDI159"),ExecBlock("EICDI159",.F.,.F.,"CPOS_WF"),)   // GFP - 03/09/2013
   
   If Len(aCposWF) > 0
      For i := 1 To Len(aCposWF)
         oEasyWorkFlow:AddVal(aCposWF[i][1]  , aCposWF[i][2] )
      Next i
   EndIf
EndIf

RestOrd(aOrd, .T.)
Return Nil

*-------------------------------*
Function EICWFNFENV(oEasyWorkFlow)
*-------------------------------*

RecLock("SWN",.F.)
SWN->WN_ID := oEasyWorkFlow:RetID()
MsUnlock()

Return Nil