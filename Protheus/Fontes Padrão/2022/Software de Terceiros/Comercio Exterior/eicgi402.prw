/*
Funcao      : EICGI402
Parametros  : Nil
Retorno     : Nenhum
Objetivos   : Funcões responsáveis pelo WorkFlow da PLI
Autor       : Guilherme Fernandes Pilan - GFP
Data/Hora   : 24/03/2011 10:06
Revisao     :
Obs.        :
*/
*------------------*
Function EICGI402() 
*------------------*
Return Nil
*----------------------------------*
Function EICWFLIVAR(oEasyWorkFlow)
*----------------------------------*
Local aOrd := SaveOrd("SW4"), i
Private aCposWF := {}  // GFP - 03/09/2013

cRet:= oEasyWorkFlow:RetChave()
SW4->(DbSetOrder(1))

If SW4->(DbSeek(cRet)) 
   oEasyWorkFlow:AddVal("LINUM", SW4->W4_PGI_NUM )
   oEasyWorkFlow:AddVal("DATA" , dDataBase       )

   IF(EasyEntryPoint("EICGI402"),ExecBlock("EICGI402",.F.,.F.,"CPOS_WF"),)   // GFP - 03/09/2013
   
   If Len(aCposWF) > 0
      For i := 1 To Len(aCposWF)
         oEasyWorkFlow:AddVal(aCposWF[i][1]  , aCposWF[i][2] )
      Next i
   EndIf  
EndIf

RestOrd(aOrd, .T.)
Return Nil

*-------------------------------*
Function EICWFLIENV(oEasyWorkFlow)
*-------------------------------*

RecLock("SW4",.F.)
SW4->W4_ID := oEasyWorkFlow:RetID()
MsUnlock()

Return Nil