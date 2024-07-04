#include "TOTVS.CH"
#include 'FWMVCDEF.CH'

#DEFINE NO_RELATION 0 // Sem Relação 
#DEFINE N_TO_N      1 // Relação N para N
#DEFINE ONE_TO_N    2 // Relação 1 para N
#DEFINE N_TO_ONE    3 // Relação N para 1
#DEFINE ZERO_TO     4 // Relação 0 para 1 ou N
#DEFINE TO_ZERO     5 // Relação N ou 1 para 0

#DEFINE NO_BEHAVIOR 0 // Sem comportamento  
#DEFINE CASCADE 1     // Relacionamento em cascata

/*/{Protheus.doc} 
    Relation
    Classe abstrata das Relações de uma entidade
    Esta classe deve orquestrar as relações entre entidades
    Isso envolve:
        - Colação de dados para buscar elementos dela e de seus relacionamentos
        - Fazer busca de Expandiveis pela API
        - Fazer alterações, inclusões e deleções por relacionamento

    @type  Class
    @author lima.everton
    @since 20191008
/*/

Class CenRelation
	   
    Data cName
    Data oCollection
    Data aFromTo
    Data nRelationType
    Data nBehavior
    Data nType
    Data aKey

    Method New() Constructor
    Method destroy()
    Method setName(cName)
    Method setCollection(oCollection)
    Method setFromTo(aFromTo)
    Method setRelationType(nRelationType)
    Method setType(nType)
    Method getType()
    Method setBehavior(nBehavior)
    Method getName()
    Method getCollection()
    Method getFromTo()
    Method getRelationType()
    Method getBehavior()
    Method setKey(aKey)
    Method getKey()

EndClass

Method New(oDao) Class CenRelation
    self:cName := ""
    self:oCollection := Nil
    self:aFromTo := {}
    self:nRelationType := NO_RELATION
return self

Method destroy() Class CenRelation
return

Method setName(cName) Class CenRelation
    self:cName := cName
return

Method setCollection(oCollection) Class CenRelation
    self:oCollection := oCollection
return

Method setFromTo(aFromTo) Class CenRelation
    self:aFromTo := aFromTo
return

Method setRelationType(nRelationType) Class CenRelation
    self:nRelationType := nRelationType
return

Method setBehavior(nBehavior) Class CenRelation
    self:nBehavior := nBehavior
return

Method setType(nType) Class CenRelation
    self:nType := nType
return

Method setKey(aKey) Class CenRelation
    self:aKey := aKey
return

Method getName() Class CenRelation
return self:cName

Method getCollection() Class CenRelation
return self:oCollection

Method getFromTo() Class CenRelation
return self:aFromTo

Method getRelationType() Class CenRelation
return self:nRelationType

Method getBehavior() Class CenRelation
return self:nBehavior

Method getType() Class CenRelation
return self:nType

Method getKey() Class CenRelation
return self:aKey

Method destroy() Class CenObri
	DelClassIntF()
return