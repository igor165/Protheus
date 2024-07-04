#include "TOTVS.CH" 

Class BscCenOpe From Buscador 
    Method New(oDaoBusca) Constructor 
    Method getNext() 
EndClass 

Method New(oDaoBusca) Class BscCenOpe
    _Super:New(oDaoBusca) 
Return self 

Method getNext() Class BscCenOpe
    Local oCenOpe := _Super:getNext(CenOpe():New(self:getDao()), MprCenOpe():New())
return oCenOpe