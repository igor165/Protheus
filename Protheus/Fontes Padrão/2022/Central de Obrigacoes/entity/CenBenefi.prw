#include "TOTVS.ch"

/*/{Protheus.doc}
    @type  Class
    @author lima.everton
    @since 10/08/2018
/*/
Class CenBenefi from AbstractEntity

    Data cCodOpe
    Data cCodCco
    Data cMatric
    Data cNomBen
    Data cSexo
    Data dDatNas
    Data dDatInc
    Data dDatBlo
    Data cUf
    Data cCodPro
    Data cMatAnt
    Data dDatRea
    Data cPisPas
    Data cNomMae
    Data cDn
    Data cCns
    Data cEndere
    Data cNr_end
    Data cComEnd
    Data cBairro
    Data cCodMun
    Data cMunIci
    Data cCepUsr
    Data cTipEnd
    Data cResExt
    Data cTipDep
    Data cCodTit
    Data cSusep
    Data cScpa
    Data cCobPar
    Data cCnpJco
    Data cCeiCon
    Data cCpf
    Data cCpfMae
    Data cCpfPre
    Data cIteExc
    Data cOpeSib
    Data cMotBlo
    Data cProAns
    Data cPlaOri
    Data cCriMae
    Data cCriNom
    Data cSitAns
    Data cCaepf
    Data cNomeCO
    Data lNotifyANS
    Data lChange

    Method New(oDao) Constructor
    Method getCodOpe()
    Method getCodCco()
    Method getMatric()
    Method getNomBen()
    Method getSexo()
    Method getDatNas()
    Method getDatInc()
    Method getDatBlo()
    Method getUf()
    Method getCodPro()
    Method getMatAnt()
    Method getDatRea()
    Method getPisPas()
    Method getNomMae()
    Method getDn()
    Method getCns()
    Method getEndere()
    Method getNr_end()
    Method getComEnd()
    Method getBairro()
    Method getCodMun()
    Method getMunIci()
    Method getCepUsr()
    Method getTipEnd()
    Method getResExt()
    Method getTipDep()
    Method getCodTit()
    Method getSusep()
    Method getScpa()
    Method getCobPar()
    Method getCnpJco()
    Method getCeiCon()
    Method getCpf()
    Method getCpfMae()
    Method getCpfPre()
    Method getIteExc()
    Method getNotifyANS()
    Method getOpeSib()
    Method getMotBlo()
    Method getPlaOri()
    Method getProAns()
    Method getCriMae()
    Method getCriNom()
    Method getSitAns()
    Method getCaepf()
    Method getNomeCO()
    Method getChange()

    Method setCodOpe(cCodOpe)
    Method setCodCco(cCodCco)
    Method setMatric(cMatric)
    Method setNomBen(cNomBen)
    Method setSexo(cSexo)
    Method setDatNas(dDatNas)
    Method setDatInc(dDatInc)
    Method setDatBlo(dDatBlo)
    Method setUf(cUf)
    Method setCodPro(cCodPro)
    Method setMatAnt(cMatAnt)
    Method setDatRea(dDatRea)
    Method setPisPas(cPisPas)
    Method setNomMae(cNomMae)
    Method setDn(cDn)
    Method setCns(cCns)
    Method setEndere(cEndere)
    Method setNr_end(cNr_end)
    Method setComEnd(cComEnd)
    Method setBairro(cBairro)
    Method setCodMun(cCodMun)
    Method setMunIci(cMunIci)
    Method setCepUsr(cCepUsr)
    Method setTipEnd(cTipEnd)
    Method setResExt(cResExt)
    Method setTipDep(cTipDep)
    Method setCodTit(cCodTit)
    Method setSusep(cSusep)
    Method setScpa(cScpa)
    Method setCobPar(cCobPar)
    Method setCnpJco(cCnpJco)
    Method setCeiCon(cCeiCon)
    Method setCpf(cCpf)
    Method setCpfMae(cCpfMae)
    Method setCpfPre(cCpfPre)
    Method setIteExc(cIteExc)
    Method setNotifyANS(lNotifyANS)
    Method setOpeSib(cOpeSib)
    Method setMotBlo(cMotBlo)
    Method setPlaOri(cPlaOri)
    Method setProAns(cProAns)
    Method setCriMae(cCriMae)
    Method setCriNom(cCriNom)
    Method setSitAns(cSitAns)
    Method setCAEPF(cCaepf)
    Method setNomeCO(cNomeCO)

    Method setNullType(cValue,cType)
    Method serialize(oJsonControl)
    Method ccoSerialize(oJsonControl)
    Method setDadEnv(aDadEnv)
    Method setChange(lChange)

EndClass

Method New(oDao) Class CenBenefi
    _Super:New(oDao)
    self:lNotifyANS := .F. //Inicia a classe com o atributo lNotifyANS como False
    self:lChange    := .F. //Inicia a classe com o atributo lChange como False
Return self

Method setDadEnv(aDadEnv) Class CenBenefi
    self:oDao:setDadEnv(aDadEnv)
Return

Method serialize(oJsonControl) Class CenBenefi

    Local oJson        := JsonObject():New()
    Local aExpandables := {}

    DEFAULT oJsonControl := AutJsonControl():New()

    if oJsonControl:notFiltered()
        aExpandables :=  oJsonControl:getExpandables(aExpandables)
        if Len(aExpandables) > 0
            oJson["_expandables"] := aExpandables
        EndIf
    Endif

    If Empty(self:oHashFields) .OR. !self:oHashFields:get("nLenFields") .OR. self:oHashFields:get("codeCco")
        oJsonControl:setProp(oJson,"codeCco", self:getCodCco())
    EndIf
    If Empty(self:oHashFields) .OR. !self:oHashFields:get("nLenFields") .OR. self:oHashFields:get("healthInsurerCode")
        oJsonControl:setProp(oJson,"healthInsurerCode", self:getCodOpe())
    EndIf
    If Empty(self:oHashFields) .OR. !self:oHashFields:get("nLenFields") .OR. self:oHashFields:get("subscriberId")
        oJsonControl:setProp(oJson,"subscriberId", self:getMatric())
    EndIf
    If Empty(self:oHashFields) .OR. !self:oHashFields:get("nLenFields") .OR. self:oHashFields:get("name")
        oJsonControl:setProp(oJson,"name", self:getNomBen())
    EndIf
    If Empty(self:oHashFields) .OR. !self:oHashFields:get("nLenFields") .OR. self:oHashFields:get("gender")
        oJsonControl:setProp(oJson,"gender", self:getSexo())
    EndIf
    If Empty(self:oHashFields) .OR. !self:oHashFields:get("nLenFields") .OR. self:oHashFields:get("birthdate")
        oJsonControl:setProp(oJson,"birthdate", self:dateToUtc(self:getDatNas(),"00:00:00", .T.), .T.)
    EndIf
    If Empty(self:oHashFields) .OR. !self:oHashFields:get("nLenFields") .OR. self:oHashFields:get("effectiveDate")
        oJsonControl:setProp(oJson,"effectiveDate", self:dateToUtc(self:getDatInc(),"00:00:00", .T.), .T.)
    EndIf
    If Empty(self:oHashFields) .OR. !self:oHashFields:get("nLenFields") .OR. self:oHashFields:get("blockDate")
        oJsonControl:setProp(oJson,"blockDate", self:dateToUtc(self:getDatBlo(),"00:00:00", .T.), .T.)
    EndIf
    If Empty(self:oHashFields) .OR. !self:oHashFields:get("nLenFields") .OR. self:oHashFields:get("stateAbbreviation")
        oJsonControl:setProp(oJson,"stateAbbreviation", self:getUf())
    EndIf
    If Empty(self:oHashFields) .OR. !self:oHashFields:get("nLenFields") .OR. self:oHashFields:get("healthInsuranceCode")
        oJsonControl:setProp(oJson,"healthInsuranceCode", self:getCodPro())
    EndIf
    If Empty(self:oHashFields) .OR. !self:oHashFields:get("nLenFields") .OR. self:oHashFields:get("oldSubscriberId")
        oJsonControl:setProp(oJson,"oldSubscriberId", self:getMatAnt())
    EndIf
    If Empty(self:oHashFields) .OR. !self:oHashFields:get("nLenFields") .OR. self:oHashFields:get("unblockDate")
        oJsonControl:setProp(oJson,"unblockDate", self:dateToUtc(self:getDatRea(),"00:00:00", .T.), .T.)
    EndIf
    If Empty(self:oHashFields) .OR. !self:oHashFields:get("nLenFields") .OR. self:oHashFields:get("pisPasep")
        oJsonControl:setProp(oJson,"pisPasep", self:getPisPas())
    EndIf
    If Empty(self:oHashFields) .OR. !self:oHashFields:get("nLenFields") .OR. self:oHashFields:get("mothersName")
        oJsonControl:setProp(oJson,"mothersName", self:getNomMae())
    EndIf
    If Empty(self:oHashFields) .OR. !self:oHashFields:get("nLenFields") .OR. self:oHashFields:get("declarationOfLiveBirth")
        oJsonControl:setProp(oJson,"declarationOfLiveBirth", self:getDn())
    EndIf
    If Empty(self:oHashFields) .OR. !self:oHashFields:get("nLenFields") .OR. self:oHashFields:get("nationalHealthCard")
        oJsonControl:setProp(oJson,"nationalHealthCard", self:getCns())
    EndIf
    If Empty(self:oHashFields) .OR. !self:oHashFields:get("nLenFields") .OR. self:oHashFields:get("address")
        oJsonControl:setProp(oJson,"address", self:getEndere())
    EndIf
    If Empty(self:oHashFields) .OR. !self:oHashFields:get("nLenFields") .OR. self:oHashFields:get("houseNumbering")
        oJsonControl:setProp(oJson,"houseNumbering", self:getNr_end())
    EndIf
    If Empty(self:oHashFields) .OR. !self:oHashFields:get("nLenFields") .OR. self:oHashFields:get("addressComplement")
        oJsonControl:setProp(oJson,"addressComplement", self:getComEnd())
    EndIf
    If Empty(self:oHashFields) .OR. !self:oHashFields:get("nLenFields") .OR. self:oHashFields:get("district")
        oJsonControl:setProp(oJson,"district", self:getBairro())
    EndIf
    If Empty(self:oHashFields) .OR. !self:oHashFields:get("nLenFields") .OR. self:oHashFields:get("cityCode")
        oJsonControl:setProp(oJson,"cityCode", self:getCodMun())
    EndIf
    If Empty(self:oHashFields) .OR. !self:oHashFields:get("nLenFields") .OR. self:oHashFields:get("cityCodeResidence")
        oJsonControl:setProp(oJson,"cityCodeResidence", self:getMunIci())
    EndIf
    If Empty(self:oHashFields) .OR. !self:oHashFields:get("nLenFields") .OR. self:oHashFields:get("ZIPCode")
        oJsonControl:setProp(oJson,"ZIPCode", self:getCepUsr())
    EndIf
    If Empty(self:oHashFields) .OR. !self:oHashFields:get("nLenFields") .OR. self:oHashFields:get("typeOfAddress")
        oJsonControl:setProp(oJson,"typeOfAddress", self:getTipEnd())
    EndIf
    If Empty(self:oHashFields) .OR. !self:oHashFields:get("nLenFields") .OR. self:oHashFields:get("residentAbroad")
        oJsonControl:setProp(oJson,"residentAbroad", self:getResExt())
    EndIf
    If Empty(self:oHashFields) .OR. !self:oHashFields:get("nLenFields") .OR. self:oHashFields:get("holderRelationship")
        oJsonControl:setProp(oJson,"holderRelationship", self:getTipDep())
    EndIf
    If Empty(self:oHashFields) .OR. !self:oHashFields:get("nLenFields") .OR. self:oHashFields:get("holderSubscriberId")
        oJsonControl:setProp(oJson,"holderSubscriberId", self:getCodTit())
    EndIf
    If Empty(self:oHashFields) .OR. !self:oHashFields:get("nLenFields") .OR. self:oHashFields:get("codeSusep")
        oJsonControl:setProp(oJson,"codeSusep", self:getSusep())
    EndIf
    If Empty(self:oHashFields) .OR. !self:oHashFields:get("nLenFields") .OR. self:oHashFields:get("codeSCPA")
        oJsonControl:setProp(oJson,"codeSCPA", self:getScpa())
    EndIf
    If Empty(self:oHashFields) .OR. !self:oHashFields:get("nLenFields") .OR. self:oHashFields:get("partialCoverage")
        oJsonControl:setProp(oJson,"partialCoverage", self:getCobPar())
    EndIf
    If Empty(self:oHashFields) .OR. !self:oHashFields:get("nLenFields") .OR. self:oHashFields:get("guarantorCNPJ")
        oJsonControl:setProp(oJson,"guarantorCNPJ", self:getCnpJco())
    EndIf
    If Empty(self:oHashFields) .OR. !self:oHashFields:get("nLenFields") .OR. self:oHashFields:get("guarantorCEI")
        oJsonControl:setProp(oJson,"guarantorCEI", self:getCeiCon())
    EndIf
    If Empty(self:oHashFields) .OR. !self:oHashFields:get("nLenFields") .OR. self:oHashFields:get("holderCPF")
        oJsonControl:setProp(oJson,"holderCPF", self:getCpf())
    EndIf
    If Empty(self:oHashFields) .OR. !self:oHashFields:get("nLenFields") .OR. self:oHashFields:get("motherCPF")
        oJsonControl:setProp(oJson,"motherCPF", self:getCpfMae())
    EndIf
    If Empty(self:oHashFields) .OR. !self:oHashFields:get("nLenFields") .OR. self:oHashFields:get("sponsorCPF")
        oJsonControl:setProp(oJson,"sponsorCPF", self:getCpfPre())
    EndIf
    If Empty(self:oHashFields) .OR. !self:oHashFields:get("nLenFields") .OR. self:oHashFields:get("excludedItems")
        oJsonControl:setProp(oJson,"excludedItems", self:getIteExc())
    EndIf
    If Empty(self:oHashFields) .OR. !self:oHashFields:get("nLenFields") .OR. self:oHashFields:get("notifyANS")
        oJsonControl:setProp(oJson,"notifyANS", self:getNotifyANS())
    EndIf
    If Empty(self:oHashFields) .OR. !self:oHashFields:get("nLenFields") .OR. self:oHashFields:get("skipRuleName")
        oJsonControl:setProp(oJson,"skipRuleName", self:getCriNom())
    EndIf
    If Empty(self:oHashFields) .OR. !self:oHashFields:get("nLenFields") .OR. self:oHashFields:get("skipRuleMothersName")
        oJsonControl:setProp(oJson,"skipRuleMothersName", self:getCriMae())
    EndIf
    If Empty(self:oHashFields) .OR. !self:oHashFields:get("nLenFields") .OR. self:oHashFields:get("blockingReason")
        oJsonControl:setProp(oJson,"blockingReason", self:getMotBlo())
    EndIf
    If Empty(self:oHashFields) .OR. !self:oHashFields:get("nLenFields") .OR. self:oHashFields:get("statusAns")
        oJsonControl:setProp(oJson,"statusAns", self:getSitAns())
    EndIf
    If Empty(self:oHashFields) .OR. !self:oHashFields:get("nLenFields") .OR. self:oHashFields:get("caepf")
        oJsonControl:setProp(oJson,"caepf", self:getCaepf())
    EndIf
    If Empty(self:oHashFields) .OR. !self:oHashFields:get("nLenFields") .OR. self:oHashFields:get("portabilityPlanCode")
        oJsonControl:setProp(oJson,"portabilityPlanCode", self:getPlaOri())
    EndIf
    If Empty(self:oHashFields) .OR. !self:oHashFields:get("nLenFields") .OR. self:oHashFields:get("guarantorName")
        oJsonControl:setProp(oJson,"guarantorName", self:getNomeCO())
    EndIf
    If Empty(self:oHashFields) .OR. !self:oHashFields:get("nLenFields") .OR. self:oHashFields:get("CheckChange")
        oJsonControl:setProp(oJson,"CheckChange", self:getChange())
    EndIf
    aExpandables := Nil

Return oJson

Method ccoSerialize(oJsonControl) Class CenBenefi

    Local oJson    := JsonObject():New()
    Local aExpandables  := {}

    DEFAULT oJsonControl := AutJsonControl():New()

    if oJsonControl:notFiltered()
        aExpandables :=  oJsonControl:getExpandables(aExpandables)
        if Len(aExpandables) > 0
            oJson["_expandables"] := aExpandables
        EndIf
    Endif

    If Empty(self:oHashFields) .OR. !self:oHashFields:get("nLenFields") .OR. self:oHashFields:get("codeCco")
        oJsonControl:setProp(oJson,"codeCco", self:getCodCco())
    Endif
    If Empty(self:oHashFields) .OR. !self:oHashFields:get("nLenFields") .OR. self:oHashFields:get("subscriberId")
        oJsonControl:setProp(oJson,"subscriberId", self:getMatric())
    Endif
    If Empty(self:oHashFields) .OR. !self:oHashFields:get("nLenFields") .OR. self:oHashFields:get("name")
        oJsonControl:setProp(oJson,"name", self:getNomBen())
    Endif

Return oJson

Method getCodOpe() Class CenBenefi
Return self:cCodOpe

Method getCodCco() Class CenBenefi
Return self:cCodCco

Method getMatric() Class CenBenefi
Return self:cMatric

Method getNomBen() Class CenBenefi
Return self:cNomBen

Method getSexo() Class CenBenefi
Return self:cSexo

Method getDatNas() Class CenBenefi
Return self:dDatNas

Method getDatInc() Class CenBenefi
Return self:dDatInc

Method getDatBlo() Class CenBenefi
Return self:dDatBlo

Method getUf() Class CenBenefi
Return self:cUf

Method getCodPro() Class CenBenefi
Return self:cCodPro

Method getMatAnt() Class CenBenefi
Return self:cMatAnt

Method getDatRea() Class CenBenefi
Return self:dDatRea

Method getPisPas() Class CenBenefi
Return self:cPisPas

Method getNomMae() Class CenBenefi
Return self:cNomMae

Method getDn() Class CenBenefi
Return self:cDn

Method getCns() Class CenBenefi
Return self:cCns

Method getEndere() Class CenBenefi
Return self:cEndere

Method getNr_end() Class CenBenefi
Return self:cNr_end

Method getComEnd() Class CenBenefi
Return self:cComEnd

Method getBairro() Class CenBenefi
Return self:cBairro

Method getCodMun() Class CenBenefi
Return self:cCodMun

Method getMunIci() Class CenBenefi
Return self:cMunIci

Method getCepUsr() Class CenBenefi
Return self:cCepUsr

Method getTipEnd() Class CenBenefi
Return self:cTipEnd

Method getResExt() Class CenBenefi
Return self:cResExt

Method getTipDep() Class CenBenefi
Return self:cTipDep

Method getCodTit() Class CenBenefi
Return self:cCodTit

Method getSusep() Class CenBenefi
Return self:cSusep

Method getScpa() Class CenBenefi
Return self:cScpa

Method getCobPar() Class CenBenefi
Return self:cCobPar

Method getCnpJco() Class CenBenefi
Return self:cCnpJco

Method getCeiCon() Class CenBenefi
Return self:cCeiCon

Method getCpf() Class CenBenefi
Return self:cCpf

Method getCpfMae() Class CenBenefi
Return self:cCpfMae

Method getCpfPre() Class CenBenefi
Return self:cCpfPre

Method getIteExc() Class CenBenefi
Return self:cIteExc

Method getNotifyANS() Class CenBenefi
Return self:lNotifyANS

Method getOpeSib() Class CenBenefi
Return self:cOpeSib

Method getPlaOri() Class CenBenefi
Return self:cPlaOri

Method getMotBlo() Class CenBenefi
Return self:cMotBlo

Method getProAns() Class CenBenefi
Return self:cProAns

Method getCriMae() Class CenBenefi
Return self:cCriMae

Method getCriNom() Class CenBenefi
Return self:cCriNom

Method getSitAns() Class CenBenefi
Return self:cSitAns

Method getCaepf() Class CenBenefi
Return self:cCaepf

Method getNomeCO() Class CenBenefi
Return self:cNomeCO

Method getChange() Class CenBenefi
Return self:lChange

Method setNullType(cValue,cType) Class CenBenefi

    If cValue == Nil
        If UPPER(cType) == "C"
            cValue := ""
        ElseIf cType == "D"
            cValue := STOD("")
        EndIf
    EndIf

Return cValue

Method setCodOpe(cCodOpe) Class CenBenefi
    self:cCodOpe := self:setNullType(cCodOpe,"c")
Return

Method setCodCco(cCodCco) Class CenBenefi
    self:cCodCco := self:setNullType(cCodCco,"c")
Return

Method setMatric(cMatric) Class CenBenefi
    self:cMatric := self:setNullType(cMatric,"c")
Return

Method setNomBen(cNomBen) Class CenBenefi
    self:cNomBen := self:setNullType(cNomBen,"c")
Return

Method setSexo(cSexo) Class CenBenefi
    self:cSexo := self:setNullType(cSexo,"c")
Return

Method setDatNas(dDatNas) Class CenBenefi
    self:dDatNas := self:setNullType(dDatNas,"d")
Return

Method setDatInc(dDatInc) Class CenBenefi
    self:dDatInc := self:setNullType(dDatInc,"d")
Return

Method setDatBlo(dDatBlo) Class CenBenefi
    self:dDatBlo := self:setNullType(dDatBlo,"d")
Return

Method setUf(cUf) Class CenBenefi
    self:cUf := self:setNullType(cUf,"c")
Return

Method setCodPro(cCodPro) Class CenBenefi
    self:cCodPro := self:setNullType(cCodPro,"c")
Return

Method setMatAnt(cMatAnt) Class CenBenefi
    self:cMatAnt := self:setNullType(cMatAnt,"c")
Return

Method setDatRea(dDatRea) Class CenBenefi
    self:dDatRea := self:setNullType(dDatRea,"d")
Return

Method setPisPas(cPisPas) Class CenBenefi
    self:cPisPas := self:setNullType(cPisPas,"c")
Return

Method setNomMae(cNomMae) Class CenBenefi
    self:cNomMae := self:setNullType(cNomMae,"c")
Return

Method setDn(cDn) Class CenBenefi
    self:cDn := self:setNullType(cDn,"c")
Return

Method setCns(cCns) Class CenBenefi
    self:cCns := self:setNullType(cCns,"c")
Return

Method setEndere(cEndere) Class CenBenefi
    self:cEndere := self:setNullType(cEndere,"c")
Return

Method setNr_end(cNr_end) Class CenBenefi
    self:cNr_end := self:setNullType(cNr_end,"c")
Return

Method setComEnd(cComEnd) Class CenBenefi
    self:cComEnd := self:setNullType(cComEnd,"c")
Return

Method setBairro(cBairro) Class CenBenefi
    self:cBairro := self:setNullType(cBairro,"c")
Return

Method setCodMun(cCodMun) Class CenBenefi
    self:cCodMun := self:setNullType(cCodMun,"c")
Return

Method setMunIci(cMunIci) Class CenBenefi
    self:cMunIci := self:setNullType(cMunIci,"c")
Return

Method setCepUsr(cCepUsr) Class CenBenefi
    self:cCepUsr := self:setNullType(cCepUsr,"c")
Return

Method setTipEnd(cTipEnd) Class CenBenefi
    self:cTipEnd := self:setNullType(cTipEnd,"c")
Return

Method setResExt(cResExt) Class CenBenefi
    self:cResExt := self:setNullType(cResExt,"c")
Return

Method setTipDep(cTipDep) Class CenBenefi
    self:cTipDep := self:setNullType(cTipDep,"c")
Return

Method setCodTit(cCodTit) Class CenBenefi
    self:cCodTit := self:setNullType(cCodTit,"c")
Return

Method setSusep(cSusep) Class CenBenefi
    self:cSusep := self:setNullType(cSusep,"c")
Return

Method setScpa(cScpa) Class CenBenefi
    self:cScpa := self:setNullType(cScpa,"c")
Return

Method setCobPar(cCobPar) Class CenBenefi
    self:cCobPar := self:setNullType(cCobPar,"c")
Return

Method setCnpJco(cCnpJco) Class CenBenefi
    self:cCnpJco := self:setNullType(cCnpJco,"c")
Return

Method setCeiCon(cCeiCon) Class CenBenefi
    self:cCeiCon := self:setNullType(cCeiCon,"c")
Return

Method setCpf(cCpf) Class CenBenefi
    self:cCpf := self:setNullType(cCpf,"c")
Return

Method setCpfMae(cCpfMae) Class CenBenefi
    self:cCpfMae := self:setNullType(cCpfMae,"c")
Return

Method setCpfPre(cCpfPre) Class CenBenefi
    self:cCpfPre := self:setNullType(cCpfPre,"c")
Return

Method setIteExc(cIteExc) Class CenBenefi
    self:cIteExc := self:setNullType(cIteExc,"c")
Return

Method setOpeSib(cOpeSib) Class CenBenefi
    self:cOpeSib := self:setNullType(cOpeSib,"c")
Return

Method setMotBlo(cMotBlo) Class CenBenefi
    self:cMotBlo := self:setNullType(cMotBlo,"c")
Return

Method setPlaOri(cPlaOri) Class CenBenefi
    self:cPlaOri := self:setNullType(cPlaOri,"c")
Return

Method setProAns(cProAns) Class CenBenefi
    self:cProAns := self:setNullType(cProAns,"c")
Return

Method setCriMae(cCriMae) Class CenBenefi
    self:cCriMae := self:setNullType(cCriMae,"c")
Return

Method setCriNom(cCriNom) Class CenBenefi
    self:cCriNom := self:setNullType(cCriNom,"c")
Return

Method setNomeCO(cNomeCO) Class CenBenefi
    self:cNomeCO := cNomeCO
Return

//Method setTitCco(cTitCco) Class CenBenefi
//    self:cTitCco := self:setNullType(cTitCco,"c")
//Return

Method setSitAns(cSitAns) Class CenBenefi
    self:cSitAns := self:setNullType(cSitAns,"c")
Return

Method setCAEPF(cCaepf) Class CenBenefi
    self:cCaepf := self:setNullType(cCaepf,"c")
Return

Method setNotifyANS(lNotifyANS) Class CenBenefi

    Local cVal := cValToChar(lNotifyANS)

    //Se for igual a "1" ou ".T." será Verdadeiro
    If cVal == ".T." .OR. cVal == "1" .OR. UPPER(cVal) = "TRUE"
        self:lNotifyANS := .T.
    EndIf

Return

Method SetChange(lChange) Class CenBenefi
    Local cVal := cValToChar(lChange)

    //Se for igual a "1" ou ".T." será Verdadeiro
    If cVal == ".T." .OR. cVal == "1" .OR. UPPER(cVal) = "TRUE"
        self:lChange := .T.
    Else
        self:lChange := .F.
    EndIf

Return
