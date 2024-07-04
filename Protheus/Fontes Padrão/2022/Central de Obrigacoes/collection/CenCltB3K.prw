#include "TOTVS.CH"

#DEFINE N_TO_N   1 // Relaï¿½ï¿½o N para N
#DEFINE ONE_TO_N 2 // Relaï¿½ï¿½o 1 para N
#DEFINE N_TO_ONE 3 // Relaï¿½ï¿½o N para 1
#DEFINE ZERO_TO  4 // Relaï¿½ï¿½o 0 para 1 ou N
#DEFINE TO_ZERO  5 // Relaï¿½ï¿½o N ou 1 para 0

#DEFINE NO_BEHAVIOR 0 // Sem comportamento  
#DEFINE CASCADE 1     // Relacionamento em cascata

Class CenCltB3K from CenCollection
    Method New() Constructor
    Method initEntity()
    Method initRelation()
EndClass

Method New() Class CenCltB3K
    _Super:new()
    self:oMapper := CenMprB3K():New()
    self:oDao := CenDaoB3K():New(self:oMapper:getFields())
return self

Method initEntity() Class CenCltB3K
return CenB3K():New()

Method initRelation() Class CenCltB3K

    Local oRelation := CenRelation():New()

    oRelation:setCollection(CenCltCrit():New())
    oRelation:setName("obligationCentralCritics")
    oRelation:setType(ONE_TO_N)
    oRelation:setBehavior(CASCADE)
    oRelation:setKey({;
        {"B3K_CODOPE","B3F_CODOPE"},;
        {"B3K_MATRIC","B3F_IDEORI"};
    })
    self:setRelation(oRelation)

    oRelation := CenRelation():New()

    oRelation:setCollection(CenCltB3X():New())
    oRelation:setName("changesHistory")
    oRelation:setType(ONE_TO_N)
    oRelation:setBehavior(CASCADE)
    oRelation:setKey({;
        {"B3K_CODOPE","B3X_CODOPE"},;
        {"B3K_MATRIC","B3X_IDEORI"},;
        {"B3K_CODCCO","B3X_CODCCO"};
    })
    self:setRelation(oRelation)

    oRelation:destroy()

return self:listRelations()
