#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

Class BeneValidate from ApiValidate

    Method New() Constructor
    Method valBene(oCenBenefi)
    Method valChangCon(oCenBenefi,oJson)
    Method valCco(cCodCco)

EndClass

Method New(oRest) Class BeneValidate
    _Super:New(oRest)
Return self

Method valBene(oCenBenefi,oJson) Class BeneValidate

    Default oJson := Nil

    self:valOpe(oCenBenefi:getCodOpe())

    if self:lIsValid
        self:valSitAns(oCenBenefi:getSitAns())
    endIf
    if self:lIsValid .AND. !Empty(oJson)
        If AttIsMemberOf( oJson, "subscriberId", .T.)
            self:valMatric(oJson["subscriberId"])
        EndIf
    endIf

Return self:lIsValid

Method valChangCon(oCenBenefi) Class BeneValidate

    self:valOpe(oCenBenefi:getCodOpe())

    if self:lIsValid
       self:valCco(oCenBenefi:getCodCco())
    endIf
    
    if self:lIsValid
        self:valExisProd(oCenBenefi:getCodPro(), oCenBenefi:getCodOpe())
    endIf
    //if self:lIsValid
    //    self:valBlock(oCenBenefi)
    //endIf
    if self:lIsValid
        self:valTipDep(oCenBenefi:getTipDep())
    endIf
    
Return self:lIsValid 

Method valCco(cCodCco) Class BeneValidate
    _Super:valCco(cCodCco)
    If !self:lIsValid
        self:oRest:cFaultDetail := 'Código do CCO não informado.'
    EndIf
Return