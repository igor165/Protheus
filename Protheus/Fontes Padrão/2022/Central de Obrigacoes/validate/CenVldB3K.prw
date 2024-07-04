#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

Class CenVldB3K from CenValidator

    Method New() Constructor
    Method validate(oEntity)

EndClass

Method New() Class CenVldB3K
    _Super:New()
Return self

Method validate(oEntity) Class CenVldB3K
Return _Super:validate(oEntity)
