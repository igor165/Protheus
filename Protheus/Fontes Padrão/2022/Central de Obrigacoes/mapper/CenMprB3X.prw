#include "TOTVS.CH"

Class CenMprB3X from CenMapper

    Method New() Constructor

EndClass

Method New() Class CenMprB3X
    _Super:new()
    aAdd(self:aFields,{"B3X_BENEF " ,"benefitedRecno"})
    aAdd(self:aFields,{"B3X_CAMPO " ,"changedField"})
    aAdd(self:aFields,{"B3X_DATA  " ,"changeDate"})
    aAdd(self:aFields,{"B3X_ARQUIV" ,"fileName"})
    aAdd(self:aFields,{"B3X_OPERA " ,"sibOperation"})
    aAdd(self:aFields,{"B3X_CRITIC" ,"criticized"})
    aAdd(self:aFields,{"B3X_IDEORI" ,"originIdentKey"})
    aAdd(self:aFields,{"B3X_HORA  " ,"modificationTime"})
    aAdd(self:aFields,{"B3X_DESORI" ,"originDescription"})
    aAdd(self:aFields,{"B3X_STATUS" ,"status"})
    aAdd(self:aFields,{"B3X_VLRANT" ,"previousValue"})
    aAdd(self:aFields,{"B3X_VLRNOV" ,"newValue"})
    aAdd(self:aFields,{"B3X_CODOPE" ,"operatorRecord"})
    aAdd(self:aFields,{"B3X_CODCCO" ,"operationalControlCode"})
    aAdd(self:aFields,{"B3X_DTINVL" ,"validationStartDate"})
    aAdd(self:aFields,{"B3X_HRINVL" ,"validationStartTime"})
    aAdd(self:aFields,{"B3X_DTTEVL" ,"validationEndDate"})
    aAdd(self:aFields,{"B3X_HRTEVL" ,"validationEndTime"})
Return self
