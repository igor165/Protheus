#include "TOTVS.CH" 

Class BscCenProd From Buscador 
    Method New(oDaoBusca) Constructor 
    Method getNext() 
EndClass 

Method New(oDaoBusca) Class BscCenProd
    _Super:New(oDaoBusca) 
Return self 

Method getNext() Class BscCenProd
    Local oCenProd := _Super:getNext(CenProd():New(self:getDao()), MprCenProd():New())
return oCenProd