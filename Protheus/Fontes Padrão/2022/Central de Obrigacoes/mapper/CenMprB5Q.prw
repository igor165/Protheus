#include "TOTVS.CH"

Class CenMprB5Q from CenMapper

    Method New() Constructor

EndClass

Method New() Class CenMprB5Q
    _Super:new()

    aAdd(self:aFields,{"B5Q_DESCRI" ,"errorDescription"})
    aAdd(self:aFields,{"B5Q_DATA  " ,"errorDate"})
    aAdd(self:aFields,{"B5Q_HORA  " ,"errorTime"})
    aAdd(self:aFields,{"B5Q_IDREQU" ,"idRequest"})
    aAdd(self:aFields,{"B5Q_PATH  " ,"path"})
    aAdd(self:aFields,{"B5Q_JSONIN" ,"entradaJson"})
    aAdd(self:aFields,{"B5Q_JSONOU" ,"saidaJson"})
    aAdd(self:aFields,{"B5Q_VERBO " ,"verboRequisicao"})


Return self
