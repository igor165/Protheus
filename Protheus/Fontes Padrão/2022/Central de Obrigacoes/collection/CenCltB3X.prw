#include "TOTVS.CH"

#DEFINE N_TO_N   1 // Relação N para N
#DEFINE ONE_TO_N 2 // Relação 1 para N
#DEFINE N_TO_ONE 3 // Relação N para 1
#DEFINE ZERO_TO  4 // Relação 0 para 1 ou N
#DEFINE TO_ZERO  5 // Relação N ou 1 para 0

#DEFINE NO_BEHAVIOR 0 // Sem comportamento  
#DEFINE CASCADE 1     // Relacionamento em cascata

Class CenCltB3X from CenCollection
	   
    Method New() Constructor
    Method initEntity()
    Method initRelation()
    Method bscMovCount(cDateIni, cDateFim, cCodeOpe)

EndClass

Method New() Class CenCltB3X
    _Super:new()
    self:oMapper := CenMprB3X():New()
    self:oDao := CenDaoB3X():New(self:oMapper:getFields())
return self

Method initEntity() Class CenCltB3X
return CenB3X():New()

Method initRelation() Class CenCltB3X
return self:listRelations()

Method bscMovCount(cDateIni, cDateFim, cCodeOpe) Class CenCltB3X
Return self:getDao():bscMovCount(cDateIni, cDateFim, cCodeOpe)
