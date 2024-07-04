#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

#DEFINE SINGLE "01"
#DEFINE ALL    "02"
#DEFINE INSERT "03"
#DEFINE DELETE "04"
#DEFINE UPDATE "05"
#DEFINE BUSCA  "07"

Class CenReqB3K from CenRequest

    Method New(oRest,cSvcName) Constructor
    Method destroy()
    Method readPathPar(cPathKey)
    Method applyFilter(nType)
    Method applyOrder(cOrder)
    Method buscar(nType)
    Method prepFilter()

EndClass

Method destroy()  Class CenReqB3K
Return _Super:destroy()

Method New(oRest, cSvcName) Class CenReqB3K
    _Super:New(oRest,cSvcName)
    self:oCollection := CenCltB3K():New()
    self:oValidador := CenVldB3K():New()
    self:cPropLote   := "B3K"
Return self

Method readPathPar(cPathKey) Class CenReqB3K
    Local aPathKey := {}
    Default cPathKey := ""
    aPathKey := StrTokArr2(cPathKey,"|",.F.)
    If Len(aPathKey) > 1
        self:oRest:subscriberId := IIf(len(aPathKey) >= 1, aPathKey[1],nil)
    Else
        self:oRest:subscriberId := IIf(len(aPathKey) >= 1, aPathKey[1],nil)
    EndIf
Return aPathKey

Method applyFilter(nType) Class CenReqB3K
	self:readPathPar(self:oRest:uniqueKey)
    If self:lSuccess
        If nType == ALL
            self:oCollection:setValue("healthInsurerCode",self:oRest:healthInsurerCode)
            self:oCollection:setValue("codeCco",self:oRest:codeCco)
            self:oCollection:setValue("subscriberId",self:oRest:subscriberId)
            self:oCollection:setValue("name",self:oRest:name)
            self:oCollection:setValue("gender",self:oRest:gender)
            self:oCollection:setValue("birthdate",self:oRest:birthdate)
            self:oCollection:setValue("effectiveDate",self:oRest:effectiveDate)
            self:oCollection:setValue("blockDate",self:oRest:blockDate)
            self:oCollection:setValue("stateAbbreviation",self:oRest:stateAbbreviation)
            self:oCollection:setValue("healthInsuranceCode",self:oRest:healthInsuranceCode)
            self:oCollection:setValue("unblockDate",self:oRest:unblockDate)
            self:oCollection:setValue("pisPasep",self:oRest:pisPasep)
            self:oCollection:setValue("mothersName",self:oRest:mothersName)
            self:oCollection:setValue("declarationOfLiveBirth",self:oRest:declarationOfLiveBirth)
            self:oCollection:setValue("nationalHealthCard",self:oRest:nationalHealthCard)
            self:oCollection:setValue("address",self:oRest:address)
            self:oCollection:setValue("houseNumbering",self:oRest:houseNumbering)
            self:oCollection:setValue("addressComplement",self:oRest:addressComplement)
            self:oCollection:setValue("district",self:oRest:district)
            self:oCollection:setValue("cityCode",self:oRest:cityCode)
            self:oCollection:setValue("cityCodeResidence",self:oRest:cityCodeResidence)
            self:oCollection:setValue("ZIPCode",self:oRest:ZIPCode)
            self:oCollection:setValue("typeOfAddress",self:oRest:typeOfAddress)
            self:oCollection:setValue("residentAbroad",self:oRest:residentAbroad)
            self:oCollection:setValue("holderRelationship",self:oRest:holderRelationship)
            self:oCollection:setValue("holderSubscriberId",self:oRest:holderSubscriberId)
            self:oCollection:setValue("codeSusep",self:oRest:codeSusep)
            self:oCollection:setValue("codeSCPA",self:oRest:codeSCPA)
            self:oCollection:setValue("partialCoverage",self:oRest:partialCoverage)
            self:oCollection:setValue("guarantorCNPJ",self:oRest:guarantorCNPJ)
            self:oCollection:setValue("guarantorCEI",self:oRest:guarantorCEI)
            self:oCollection:setValue("holderCPF",self:oRest:holderCPF)
            self:oCollection:setValue("motherCPF",self:oRest:motherCPF)
            self:oCollection:setValue("sponsorCPF",self:oRest:sponsorCPF)
            self:oCollection:setValue("excludedItems",self:oRest:excludedItems)
            self:oCollection:setValue("skipRuleName",self:oRest:skipRuleName)
            self:oCollection:setValue("skipRuleMothersName",self:oRest:skipRuleMothersName)
            self:oCollection:setValue("blockingReason",self:oRest:blockingReason)
            self:oCollection:setValue("statusAns",self:oRest:statusAns)
            self:oCollection:setValue("caepf",self:oRest:caepf)
            self:oCollection:setValue("portabilityPlanCode",self:oRest:portabilityPlanCode)
            self:oCollection:setValue("guarantorName",self:oRest:guarantorName)
        EndIf
        If nType == SINGLE 
            self:oCollection:setValue("subscriberId",self:oRest:subscriberId)
            self:oCollection:setValue("healthInsurerCode",self:oRest:healthInsurerCode)
            self:oCollection:setValue("codeCco",self:oRest:codeCco)
        EndIf
    EndIf
Return self:lSuccess

Method applyOrder(cOrder) Class CenReqB3K
    If self:lSuccess
        self:oCollection:applyOrder(cOrder)
    EndIf
Return self:lSuccess

Method prepFilter(oJson) Class CenReqB3K
    Default oJson := self:jRequest
    self:readPathPar(self:oRest:uniqueKey)
    self:oCollection:setValue("healthInsurerCode", self:oRest:healthInsurerCode)
    self:oCollection:setValue("codeCco", self:oRest:codeCco)
    self:oCollection:setValue("subscriberId", self:oRest:subscriberId)
    
    self:oCollection:mapFromJson(oJson)
Return

Method buscar(nType) Class CenReqB3K

    Local lExiste := .F.
    If self:lSuccess
        If nType == BUSCA
            self:oCollection:buscar()
        Else
            lExiste := self:oCollection:bscChaPrim()
            If nType == INSERT
                self:lSuccess := !lExiste
            Else
                self:lSuccess := lExiste
            EndIf
        EndIf
    EndIf

Return self:lSuccess


