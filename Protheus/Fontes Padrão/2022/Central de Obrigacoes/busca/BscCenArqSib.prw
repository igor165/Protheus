#include "TOTVS.CH" 

Class BscCenArqSib From Buscador 
    Method New(oDaoBusca) Constructor 
    Method getNext() 
EndClass 

Method New(oDaoBusca) Class BscCenArqSib
    _Super:New(oDaoBusca) 
    
Return self   

Method getNext() Class BscCenArqSib
    Local oCenArqSib := _Super:getNext(CenArqSib():New(self:getDao()), MprCenArqSib():New())
return oCenArqSib