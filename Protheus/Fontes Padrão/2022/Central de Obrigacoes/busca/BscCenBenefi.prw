#include "TOTVS.CH" 

Class BscCenBenefi From Buscador 
    Method New(oDaoBusca) Constructor 
    Method getNext() 
EndClass 

Method New(oDaoBusca) Class BscCenBenefi
    _Super:New(oDaoBusca) 
Return self 

Method getNext() Class BscCenBenefi
    Local oCenBenefi := _Super:getNext(CenBenefi():New(self:getDao()), MprCenBenefi():New())
return oCenBenefi