#INCLUDE "AVERAGE.CH"

/*
Funcao      : EICNU401
Parametros  : Nil
Retorno     : Nenhum
Objetivos   : Funcões responsáveis pelo WorkFlow de Solic. Numerario
Autor       : Guilherme Fernandes Pilan - GFP
Data/Hora   : 29/03/2011 14:27
Revisao     :
Obs.        :
*/
*------------------*
Function EICNU401() 
*------------------*
Return Nil
*----------------------------------*
Function EICWFNMVAR(oEasyWorkFlow)
*----------------------------------*
Local aOrd := SaveOrd("EIC"), i
Local cPictValor := AvSx3("EIC_VALOR",AV_PICTURE)

Private aCposWF := {}  // GFP - 03/09/2013

cRet:= oEasyWorkFlow:RetChave()
EIC->(DbSetOrder(1))

If EIC->(DbSeek(cRet)) 
   oEasyWorkFlow:AddVal("EMBNUM"  , EIC->EIC_HAWB    )
   oEasyWorkFlow:AddVal("DESPESA" , EIC->EIC_DESPES  )
   oEasyWorkFlow:AddVal("DATA"    , EIC->EIC_DT_EFE  )

   oEasyWorkFlow:AddVal("VALOR"   , AllTrim(TransForm(EIC->EIC_VALOR, cPictValor))   )
  

   oEasyWorkFlow:AddVal("AUT"     , EIC->EIC_USER    )
   oEasyWorkFlow:AddVal("DTATUAL" , dDataBase        )
   
   IF(EasyEntryPoint("EICNU401"),ExecBlock("EICNU401",.F.,.F.,"CPOS_WF"),)   // GFP - 03/09/2013
  
   If Len(aCposWF) > 0
      For i := 1 To Len(aCposWF)
         oEasyWorkFlow:AddVal(aCposWF[i][1]  , aCposWF[i][2] )
      Next i
   EndIf   
EndIf                                               

RestOrd(aOrd, .T.)
Return Nil

*-------------------------------*
Function EICWFNMENV(oEasyWorkFlow)
*-------------------------------*

RecLock("EIC",.F.)
EIC->EIC_ID := oEasyWorkFlow:RetID()
MsUnlock()

Return Nil