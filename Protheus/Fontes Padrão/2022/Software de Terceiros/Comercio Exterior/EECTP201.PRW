#include "TOPCONN.CH"
/*
Funcao      : EECTP201
Parametros  : Nil
Retorno     : Nenhum
Objetivos   : Funcões responsáveis pelo WorkFlow da Aprovação de Preço
Autor       : Flavio Danilo Ricardo - FDR
Data/Hora   : 18/03/2011 14:30
Revisao     :
Obs.        :
*/
*------------------*
Function EECTP201() 
*------------------*
Return Nil
*----------------------------------*
Function EECWFAPVAR(oEasyWorkFlow)
*----------------------------------*
Local aOrd := SaveOrd("EX6")
Public cRet := ""

cRet:= oEasyWorkFlow:cChave    // GFP - 13/08/2012
EX6->(DbSetOrder(1))

If EX6->(DbSeek(cRet))
   oEasyWorkFlow:AddVal("CODITEM", EX6->EX6_COD_I)   // GFP - 13/08/2012
   oEasyWorkFlow:AddVal("PRECO",   EX6->EX6_PRECO)
   oEasyWorkFlow:AddVal("DATA",   dDataBase)  
EndIf

RestOrd(aOrd, .T.)
Return Nil

*-------------------------------*
Function EECWFAPENV(oEasyWorkFlow)
*-------------------------------*

RecLock("EX6",.F.)
EX6->EX6_ID    := oEasyWorkFlow:RetID() //contém o ID do processo de workflow, não usado no exemplo, pode ser usado para achar um pedido pelo id do workflow.
EX6->EX6_DTINI := dDataBase //armazena data atual como data de inicio (pois o email foi enviado)
MsUnlock()

Return Nil

*-------------------------------*
Function EECWFAPRET(oProc)
*-------------------------------*
oWorkFlow := EasyWorkFlow():New("PRECO")

oWorkFlow:LoadChave(oProc:FPROCESSID)

oWorkFlow:LoadVars()

dbSelectArea("EX6")

EX6->(DbSetOrder(1))
//Pega o código do pedido, através do método RetByName, para achar o pedido correto no cadastro.
If EX6->(DbSeek(oWorkFlow:RetChave())) 

   RecLock("EX6",.F.)              
   
   //Grava a data da aprovação de preço
   EX6->EX6_DTAPRO := dDataBase   

   MsUnlock()
EndIf
Return .T.

*-------------------------------*
Function EECWFAPCOND()
*-------------------------------*
Local aChaves := {}

Begin Sequence

   If Empty(WorkApro->WK_DTINI)
      aAdd(aChaves,xFilial("EX6")+WorkApro->WK_COD_I)   
   EndIf
   
End Sequence

Return aChaves