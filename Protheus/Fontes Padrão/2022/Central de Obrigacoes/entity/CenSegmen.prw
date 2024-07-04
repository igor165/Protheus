#include "TOTVS.CH"
#include "protheus.ch"

#DEFINE SINGLE      "01"
#DEFINE ALL         "02"
#DEFINE INSERT      "03"
#DEFINE DELETE      "04"
#DEFINE UPDATE      "05"


Class CenSegmen

    Data cSegmen
    Data cDesOri
    Data cPerDes

    Method New(cSegmen) Constructor
    Method getSegmen()
    Method getDesOri()
    Method getPerDes()
    Method setSegmen(cSegmen)
    Method setDesOri(cDesOri)
    Method setPerDes(cPerDes)

EndClass

Method New(cSegmen) Class CenSegmen

    self:setSegmen(cSegmen)

    If Empty(cSegmen) .OR. cSegmen == "1"
        self:setDesOri("AMBULATORIAL")
    ElseIf cSegmen == "2"
        self:setDesOri("HOSPITALAR")
    ElseIf cSegmen == "3"
        self:setDesOri("HOSPITALAR E OBSTÉTRICA")
    ElseIf cSegmen == "4"
        self:setDesOri("ODONTOLÓGICO")
    Else
        self:setDesOri("AMBULATORIAL")
        self:setSegmen("1")
    EndIf

    self:setPerDes(0)

Return self

Method getSegmen() Class CenSegmen
Return self:cSegmen

Method getDesOri() Class CenSegmen
Return self:cDesOri

Method getPerDes() Class CenSegmen
Return self:cPerDes

Method setSegmen(cSegmen) Class CenSegmen
    self:cSegmen := cSegmen
Return

Method setDesOri(cDesOri) Class CenSegmen
    self:cDesOri := cDesOri
Return

Method setPerDes(cPerDes) Class CenSegmen
    self:cPerDes := cPerDes
Return


