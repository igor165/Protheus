#include "TOTVS.CH"

/*/{Protheus.doc} 
    Classe concreta da Entidade CenB3K - Beneficiaries
    @type  Class
    @author FrameworkApi 1.0
    @since 20190211
/*/
Class CenB3K from CenEntity

    Method New()
  
    Method serialize(oJsonControl)
    Method destroy()

EndClass

Method New() Class CenB3K
	_Super:New()
Return self

Method serialize(oJsonControl) Class CenB3K

	Local oJson := JsonObject():New()
	Default oJsonControl := CenJsonControl():New()

    oJson["_expandables"] := {"obligationCentralCritics","changesHistory"}

    oJsonControl:setProp(oJson,"healthInsurerCode",self:getValue("healthInsurerCode")) 
    oJsonControl:setProp(oJson,"codeCco",self:getValue("codeCco")) 
    oJsonControl:setProp(oJson,"subscriberId",self:getValue("subscriberId")) 
    oJsonControl:setProp(oJson,"name",self:getValue("name")) 
    oJsonControl:setProp(oJson,"gender",self:getValue("gender")) 
    oJsonControl:setProp(oJson,"birthdate",self:getValue("birthdate")) 
    oJsonControl:setProp(oJson,"effectiveDate",self:getValue("effectiveDate")) 
    oJsonControl:setProp(oJson,"blockDate",self:getValue("blockDate")) 
    oJsonControl:setProp(oJson,"stateAbbreviation",self:getValue("stateAbbreviation")) 
    oJsonControl:setProp(oJson,"healthInsuranceCode",self:getValue("healthInsuranceCode")) 
    oJsonControl:setProp(oJson,"unblockDate",self:getValue("unblockDate")) 
    oJsonControl:setProp(oJson,"pisPasep",self:getValue("pisPasep")) 
    oJsonControl:setProp(oJson,"mothersName",self:getValue("mothersName")) 
    oJsonControl:setProp(oJson,"declarationOfLiveBirth",self:getValue("declarationOfLiveBirth")) 
    oJsonControl:setProp(oJson,"nationalHealthCard",self:getValue("nationalHealthCard")) 
    oJsonControl:setProp(oJson,"address",self:getValue("address")) 
    oJsonControl:setProp(oJson,"houseNumbering",self:getValue("houseNumbering")) 
    oJsonControl:setProp(oJson,"addressComplement",self:getValue("addressComplement")) 
    oJsonControl:setProp(oJson,"district",self:getValue("district")) 
    oJsonControl:setProp(oJson,"cityCode",self:getValue("cityCode")) 
    oJsonControl:setProp(oJson,"cityCodeResidence",self:getValue("cityCodeResidence")) 
    oJsonControl:setProp(oJson,"ZIPCode",self:getValue("ZIPCode")) 
    oJsonControl:setProp(oJson,"typeOfAddress",self:getValue("typeOfAddress")) 
    oJsonControl:setProp(oJson,"residentAbroad",self:getValue("residentAbroad")) 
    oJsonControl:setProp(oJson,"holderRelationship",self:getValue("holderRelationship")) 
    oJsonControl:setProp(oJson,"holderSubscriberId",self:getValue("holderSubscriberId")) 
    oJsonControl:setProp(oJson,"codeSusep",self:getValue("codeSusep")) 
    oJsonControl:setProp(oJson,"codeSCPA",self:getValue("codeSCPA")) 
    oJsonControl:setProp(oJson,"partialCoverage",self:getValue("partialCoverage")) 
    oJsonControl:setProp(oJson,"guarantorCNPJ",self:getValue("guarantorCNPJ")) 
    oJsonControl:setProp(oJson,"guarantorCEI",self:getValue("guarantorCEI")) 
    oJsonControl:setProp(oJson,"holderCPF",self:getValue("holderCPF")) 
    oJsonControl:setProp(oJson,"motherCPF",self:getValue("motherCPF")) 
    oJsonControl:setProp(oJson,"sponsorCPF",self:getValue("sponsorCPF")) 
    oJsonControl:setProp(oJson,"excludedItems",self:getValue("excludedItems")) 
    oJsonControl:setProp(oJson,"skipRuleName",self:getValue("skipRuleName")) 
    oJsonControl:setProp(oJson,"skipRuleMothersName",self:getValue("skipRuleMothersName")) 
    oJsonControl:setProp(oJson,"blockingReason",self:getValue("blockingReason")) 
    oJsonControl:setProp(oJson,"statusAns",self:getValue("statusAns")) 
    oJsonControl:setProp(oJson,"caepf",self:getValue("caepf")) 
    oJsonControl:setProp(oJson,"portabilityPlanCode",self:getValue("portabilityPlanCode")) 
    oJsonControl:setProp(oJson,"guarantorName",self:getValue("guarantorName")) 

Return oJson

Method destroy() Class CenB3K
	_Super:destroy()
	DelClassIntF()
return