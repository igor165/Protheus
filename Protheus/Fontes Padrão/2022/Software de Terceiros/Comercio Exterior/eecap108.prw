#INCLUDE "AVERAGE.CH"
/*
Funcao      : EECAP108
Parametros  : Nil
Retorno     : Nenhum
Objetivos   : Funcões responsáveis pelo WorkFlow de liberação de crédito
Autor       : Guilherme Fernandes Pilan - GFP
Data/Hora   : 29/03/2011 16:51
Revisao     :
Obs.        :
*/
*------------------*
Function EECAP108() 
*------------------*
Return Nil
*----------------------------------*
Function EECWFCRVAR(oEasyWorkFlow)
*----------------------------------*
Local aOrd := SaveOrd("EE7")

cRet:= oEasyWorkFlow:RetChave()
EE7->(DbSetOrder(1))

If EE7->(DbSeek(cRet)) 
   If !Empty(EE7->EE7_DTAPCR)
      oEasyWorkFlow:AddVal("PEDNUM" , EE7->EE7_PEDIDO )
      oEasyWorkFlow:AddVal("CLIENTE", EE7->EE7_IMPODE )
      oEasyWorkFlow:AddVal("DTPROC" , EE7->EE7_DTPROC )
      oEasyWorkFlow:AddVal("DTSOLIC", EE7->EE7_DTSLCR )
      oEasyWorkFlow:AddVal("DTAPROV", EE7->EE7_DTAPCR )
      oEasyWorkFlow:AddVal("DATA"   , dDataBase       ) 
   EndIf  
EndIf

RestOrd(aOrd, .T.)
Return Nil

*-------------------------------*
Function EECWFCRENV(oEasyWorkFlow)
*-------------------------------*

RecLock("EE7",.F.)
EE7->EE7_ID_CR := oEasyWorkFlow:RetID()
MsUnlock()

Return Nil

*-------------------------------*
Function EECWFCRCOND()
*-------------------------------*
Local aChaves := {}

Begin Sequence
          
If !Empty(M->EE7_DTAPCR) .AND. M->EE7_DTAPCR <> EE7->EE7_DTAPCR
   aAdd(aChaves, xFilial("EE7")+M->EE7_PEDIDO)   
EndIf
   
End Sequence

Return aChaves