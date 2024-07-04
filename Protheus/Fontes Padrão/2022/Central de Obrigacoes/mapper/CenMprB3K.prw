#include "TOTVS.CH"

Class CenMprB3K from CenMapper

    Method New() Constructor

EndClass

Method New() Class CenMprB3K
    _Super:new()

    aAdd(self:aFields,{"B3K_CODOPE" ,"healthInsurerCode"})
    aAdd(self:aFields,{"B3K_CODCCO" ,"codeCco"})
    aAdd(self:aFields,{"B3K_MATRIC" ,"subscriberId"})
    aAdd(self:aFields,{"B3K_NOMBEN" ,"name"})
    aAdd(self:aFields,{"B3K_SEXO"   ,"gender"})
    aAdd(self:aFields,{"B3K_DATNAS" ,"birthdate"})
    aAdd(self:aFields,{"B3K_DATINC" ,"effectiveDate"})
    aAdd(self:aFields,{"B3K_DATBLO" ,"blockDate"})
    aAdd(self:aFields,{"B3K_UF"     ,"stateAbbreviation"})
    aAdd(self:aFields,{"B3K_CODPRO" ,"healthInsuranceCode"})
    aAdd(self:aFields,{"B3K_DATREA" ,"unblockDate"})
    aAdd(self:aFields,{"B3K_PISPAS" ,"pisPasep"})
    aAdd(self:aFields,{"B3K_NOMMAE" ,"mothersName"})
    aAdd(self:aFields,{"B3K_DN"     ,"declarationOfLiveBirth"})
    aAdd(self:aFields,{"B3K_CNS"    ,"nationalHealthCard"})
    aAdd(self:aFields,{"B3K_ENDERE" ,"address"})
    aAdd(self:aFields,{"B3K_NR_END" ,"houseNumbering"})
    aAdd(self:aFields,{"B3K_COMEND" ,"addressComplement"})
    aAdd(self:aFields,{"B3K_BAIRRO" ,"district"})
    aAdd(self:aFields,{"B3K_CODMUN" ,"cityCode"})
    aAdd(self:aFields,{"B3K_MUNICI" ,"cityCodeResidence"})
    aAdd(self:aFields,{"B3K_CEPUSR" ,"ZIPCode"})
    aAdd(self:aFields,{"B3K_TIPEND" ,"typeOfAddress"})
    aAdd(self:aFields,{"B3K_RESEXT" ,"residentAbroad"})
    aAdd(self:aFields,{"B3K_TIPDEP" ,"holderRelationship"})
    aAdd(self:aFields,{"B3K_CODTIT" ,"holderSubscriberId"})
    aAdd(self:aFields,{"B3K_SUSEP"  ,"codeSusep"})
    aAdd(self:aFields,{"B3K_SCPA"   ,"codeSCPA"})
    aAdd(self:aFields,{"B3K_COBPAR" ,"partialCoverage"})
    aAdd(self:aFields,{"B3K_CNPJCO" ,"guarantorCNPJ"})
    aAdd(self:aFields,{"B3K_CEICON" ,"guarantorCEI"})
    aAdd(self:aFields,{"B3K_CPF"    ,"holderCPF"})
    aAdd(self:aFields,{"B3K_CPFMAE" ,"motherCPF"})
    aAdd(self:aFields,{"B3K_CPFPRE" ,"sponsorCPF"})
    aAdd(self:aFields,{"B3K_ITEEXC" ,"excludedItems"})
    aAdd(self:aFields,{"B3K_CRINOM" ,"skipRuleName"})
    aAdd(self:aFields,{"B3K_CRIMAE" ,"skipRuleMothersName"})
    aAdd(self:aFields,{"B3K_MOTBLO" ,"blockingReason"})
    aAdd(self:aFields,{"B3K_SITANS" ,"statusAns"})
    aAdd(self:aFields,{"B3K_CAEPF"  ,"caepf"})
    aAdd(self:aFields,{"B3K_PLAORI" ,"portabilityPlanCode"})
    if FieldPos("B3K_NOMECO") > 0
        aAdd(self:aFields,{"B3K_NOMECO" ,"guarantorName"})
    endIf
    aAdd(self:aExpand,{"obligationCentralCritics","changesHistory"})

Return self
