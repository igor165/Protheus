#include "TOTVS.CH"
#include "protheus.ch"

#DEFINE SINGLE  "01"
#DEFINE ALL     "02"
#DEFINE INSERT  "03"
#DEFINE DELETE  "04"
#DEFINE UPDATE  "05"


Class CenAbrang

    Data cCodOri
    Data cDesOri
    Data cPerDes

    Method New() Constructor
    Method getCodOri()
    Method getDesOri()
    Method getPerDes()

    Method setCodOri(cCodOri)
    Method setDesOri(cDesOri)
    Method setPerDes(cPerDes)

EndClass

Method New(cCodOri) Class CenAbrang

    self:setCodOri(cCodOri)

    If Empty(cCodOri) .OR. cCodOri == "01"
        self:setDesOri("NACIONAL")
    ElseIf cCodOri == "02"
        self:setDesOri("ESTADUAL")
    ElseIf cCodOri == "03"
        self:setDesOri("REGIONAL GRUPO DE ESTADOS")
    ElseIf cCodOri == "04"
        self:setDesOri("MUNICIPAL")
    ElseIf cCodOri == "05"
        self:setDesOri("REGIONAL GRUPO DE MUNICIPIOS")
    Else
        self:setDesOri("NACIONAL")
        self:setCodOri("01")
    EndIf

    self:getPerDes(0)

Return self

Method getCodOri() Class CenAbrang
Return self:cCodOri

Method getDesOri() Class CenAbrang
Return self:cDesOri

Method getPerDes() Class CenAbrang
Return self:cPerDes

Method setCodOri(cCodOri) Class CenAbrang
    self:cCodOri := cCodOri
Return

Method setDesOri(cDesOri) Class CenAbrang
    self:cDesOri := cDesOri
Return

Method setPerDes(cPerDes) Class CenAbrang
    self:cPerDes := cPerDes
Return
