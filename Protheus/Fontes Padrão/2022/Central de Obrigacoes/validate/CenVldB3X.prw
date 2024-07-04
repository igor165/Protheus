#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

Class CenVldB3X from CenValidator

    Method New() Constructor
    Method validate(oEntity)

EndClass

Method New() Class CenVldB3X
    _Super:New()
Return self

Method validate(oEntity) Class CenVldB3X
Return _Super:validate(oEntity)
