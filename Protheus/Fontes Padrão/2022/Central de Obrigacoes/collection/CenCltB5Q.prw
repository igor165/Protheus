#include "TOTVS.CH"

#DEFINE N_TO_N   1 // Relação N para N
#DEFINE ONE_TO_N 2 // Relação 1 para N
#DEFINE N_TO_ONE 3 // Relação N para 1
#DEFINE ZERO_TO  4 // Relação 0 para 1 ou N
#DEFINE TO_ZERO  5 // Relação N ou 1 para 0

#DEFINE NO_BEHAVIOR 0 // Sem comportamento  
#DEFINE CASCADE 1     // Relacionamento em cascata

Class CenCltB5Q from CenCollection
	   
    Method New() Constructor
    Method initEntity()
    Method initRelation()

EndClass

Method New() Class CenCltB5Q
    _Super:new()
    self:oMapper := CenMprB5Q():New()
    self:oDao := CenDaoB5Q():New(self:oMapper:getFields())
return self

Method initEntity() Class CenCltB5Q
return CenB5Q():New()