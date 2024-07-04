#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

Class ProdValidate from ApiValidate

    Method New() Constructor
    Method valProd(oCenProd)

EndClass

Method New(oRest) Class ProdValidate
    _Super:New(oRest)
Return self

Method valProd(oCenProd) Class ProdValidate
  
    self:valOpe(oCenProd:getCodOpe())     
    
    if self:lIsValid
        self:valSegmen(oCenProd:getSegmen())
    EndIf
    
    if self:lIsValid
        self:valAbrang(oCenProd:getAbrang())
    EndIf

    if self:lIsValid
        self:valForCon(oCenProd:getForCon())
    EndIf

Return self:lIsValid
