#include "TOTVS.CH"
#include "protheus.ch"

#DEFINE SINGLE "01"
#DEFINE ALL    "02"
#DEFINE INSERT "03"
#DEFINE DELETE "04"
#DEFINE UPDATE "05"

#DEFINE SIB_INCLUIR "1" // Incluir
#DEFINE SIB_RETIFIC "2" // Retificar
#DEFINE SIB_MUDCONT "3" // Mud.Contrat
#DEFINE SIB_CANCELA "4" // Cancelar
#DEFINE SIB_REATIVA "5" // Reativar

Class MprCenBenefi

    Data aDadEnv

    Method New() Constructor
    Method mapFromDao(oCenBenefi, oDaoCenBenefi)
    Method mapFromJson(oCenBenefi, oJson, nType)
    Method mapCco(cCodCco)

EndClass

Method New() Class MprCenBenefi
    self:aDadEnv := {}
Return self

Method mapFromDao(oCenBenefi, oDaoCenBenefi) Class MprCenBenefi

    oCenBenefi:setCodOpe(AllTrim((oDaoCenBenefi:cAliasTemp)->B3K_CODOPE))
    oCenBenefi:setCodCco(AllTrim((oDaoCenBenefi:cAliasTemp)->B3K_CODCCO))
    oCenBenefi:setMatric(AllTrim((oDaoCenBenefi:cAliasTemp)->B3K_MATRIC))
    oCenBenefi:setNomBen(AllTrim((oDaoCenBenefi:cAliasTemp)->B3K_NOMBEN))
    oCenBenefi:setSexo(AllTrim((oDaoCenBenefi:cAliasTemp)->B3K_SEXO))
    oCenBenefi:setDatNas(STOD(AllTrim((oDaoCenBenefi:cAliasTemp)->B3K_DATNAS)))
    oCenBenefi:setDatInc(STOD(AllTrim((oDaoCenBenefi:cAliasTemp)->B3K_DATINC)))
    oCenBenefi:setDatBlo(STOD(AllTrim((oDaoCenBenefi:cAliasTemp)->B3K_DATBLO)))
    oCenBenefi:setUf(AllTrim((oDaoCenBenefi:cAliasTemp)->B3K_UF))
    oCenBenefi:setCodPro(AllTrim((oDaoCenBenefi:cAliasTemp)->B3K_CODPRO))
    oCenBenefi:setMatAnt(AllTrim((oDaoCenBenefi:cAliasTemp)->B3K_MATANT))
    oCenBenefi:setDatRea(STOD(AllTrim((oDaoCenBenefi:cAliasTemp)->B3K_DATREA)))
    oCenBenefi:setPisPas(AllTrim((oDaoCenBenefi:cAliasTemp)->B3K_PISPAS))
    oCenBenefi:setNomMae(AllTrim((oDaoCenBenefi:cAliasTemp)->B3K_NOMMAE))
    oCenBenefi:setDn(AllTrim((oDaoCenBenefi:cAliasTemp)->B3K_DN))
    oCenBenefi:setCns(AllTrim((oDaoCenBenefi:cAliasTemp)->B3K_CNS))
    oCenBenefi:setEndere(AllTrim((oDaoCenBenefi:cAliasTemp)->B3K_ENDERE))
    oCenBenefi:setNr_end(AllTrim((oDaoCenBenefi:cAliasTemp)->B3K_NR_END))
    oCenBenefi:setComEnd(AllTrim((oDaoCenBenefi:cAliasTemp)->B3K_COMEND))
    oCenBenefi:setBairro(AllTrim((oDaoCenBenefi:cAliasTemp)->B3K_BAIRRO))
    oCenBenefi:setCodMun(AllTrim((oDaoCenBenefi:cAliasTemp)->B3K_CODMUN))
    oCenBenefi:setMunIci(AllTrim((oDaoCenBenefi:cAliasTemp)->B3K_MUNICI))
    oCenBenefi:setCepUsr(AllTrim((oDaoCenBenefi:cAliasTemp)->B3K_CEPUSR))
    oCenBenefi:setTipEnd(AllTrim((oDaoCenBenefi:cAliasTemp)->B3K_TIPEND))
    oCenBenefi:setResExt(AllTrim((oDaoCenBenefi:cAliasTemp)->B3K_RESEXT))
    oCenBenefi:setTipDep(AllTrim((oDaoCenBenefi:cAliasTemp)->B3K_TIPDEP))
    oCenBenefi:setCodTit(AllTrim((oDaoCenBenefi:cAliasTemp)->B3K_CODTIT))
    oCenBenefi:setSusep(AllTrim((oDaoCenBenefi:cAliasTemp)->B3K_SUSEP))
    oCenBenefi:setScpa(AllTrim((oDaoCenBenefi:cAliasTemp)->B3K_SCPA))
    oCenBenefi:setCobPar(AllTrim((oDaoCenBenefi:cAliasTemp)->B3K_COBPAR))
    oCenBenefi:setCnpJco(AllTrim((oDaoCenBenefi:cAliasTemp)->B3K_CNPJCO))
    oCenBenefi:setCeiCon(AllTrim((oDaoCenBenefi:cAliasTemp)->B3K_CEICON))
    oCenBenefi:setCpf(AllTrim((oDaoCenBenefi:cAliasTemp)->B3K_CPF))
    oCenBenefi:setCpfMae(AllTrim((oDaoCenBenefi:cAliasTemp)->B3K_CPFMAE))
    oCenBenefi:setCpfPre(AllTrim((oDaoCenBenefi:cAliasTemp)->B3K_CPFPRE))
    oCenBenefi:setIteExc(AllTrim((oDaoCenBenefi:cAliasTemp)->B3K_ITEEXC))
    oCenBenefi:setMotBlo(AllTrim((oDaoCenBenefi:cAliasTemp)->B3K_MOTBLO))
    oCenBenefi:setSitAns(AllTrim((oDaoCenBenefi:cAliasTemp)->B3K_SITANS))
    oCenBenefi:setPlaOri(AllTrim((oDaoCenBenefi:cAliasTemp)->B3K_PLAORI))

    If B3K->(FieldPos("B3K_CRINOM")) > 0
        oCenBenefi:setCriNom(AllTrim((oDaoCenBenefi:cAliasTemp)->B3K_CRINOM))
    EndIf
    If B3K->(FieldPos("B3K_CRIMAE")) > 0
        oCenBenefi:setCriMae(AllTrim((oDaoCenBenefi:cAliasTemp)->B3K_CRIMAE))
    EndIf
    If B3K->(FieldPos("B3K_CAEPF")) > 0
        oCenBenefi:setCAEPF(AllTrim((oDaoCenBenefi:cAliasTemp)->B3K_CAEPF))
    EndIf
    If B3K->(FieldPos("B3K_NOMECO")) > 0
        oCenBenefi:setNomeCO(AllTrim((oDaoCenBenefi:cAliasTemp)->B3K_NOMECO))
    EndIf

Return

Method mapFromJson(oCenBenefi, oJson, nType) Class MprCenBenefi

    If nType == UPDATE

        If AttIsMemberOf( oJson, "codeCco", .T.)
            oCenBenefi:setCodCCO(oJson["codeCco"])
            oCenBenefi:setCodCCO(self:mapCco(oCenBenefi:getCodCCO()))
        EndIf
        If AttIsMemberOf( oJson, "healthInsurerCode", .T.)
            oCenBenefi:setCodOpe(oJson["healthInsurerCode"])
            aAdd(self:aDadEnv,{"B3K_CODOPE",oJson["healthInsurerCode"]})
        EndIf
        If AttIsMemberOf( oJson, "subscriberId", .T.)
            oCenBenefi:setMatric(oJson["subscriberId"])
            aAdd(self:aDadEnv,{"B3K_MATRIC",oJson["subscriberId"]})
        EndIf
        If AttIsMemberOf( oJson, "name", .T.)
            oCenBenefi:setNomBen(oJson["name"])
            aAdd(self:aDadEnv,{"B3K_NOMBEN",oJson["name"]})
        EndIf
        If AttIsMemberOf( oJson, "gender", .T.)
            oCenBenefi:setSexo(oJson["gender"])
            aAdd(self:aDadEnv,{"B3K_SEXO",oJson["gender"]})
        EndIf
        If AttIsMemberOf( oJson, "birthdate", .T.)
            oCenBenefi:setDatNas(oCenBenefi:utcToDate(oJson["birthdate"]))
            aAdd(self:aDadEnv,{"B3K_DATNAS",oCenBenefi:utcToDate(oJson["birthdate"])})
        EndIf
        If AttIsMemberOf( oJson, "effectiveDate", .T.)
            oCenBenefi:setDatInc(oCenBenefi:utcToDate(oJson["effectiveDate"]))
            aAdd(self:aDadEnv,{"B3K_DATINC",oCenBenefi:utcToDate(oJson["effectiveDate"])})
        EndIf
        If AttIsMemberOf( oJson, "blockDate", .T.)
            oCenBenefi:setDatBlo(oCenBenefi:utcToDate(oJson["blockDate"]))
        EndIf
        If AttIsMemberOf( oJson, "stateAbbreviation", .T.)
            oCenBenefi:setUf(oJson["stateAbbreviation"])
        EndIf
        If AttIsMemberOf( oJson, "healthInsuranceCode", .T.)
            oCenBenefi:setCodPro(oJson["healthInsuranceCode"])
        EndIf
        If AttIsMemberOf( oJson, "oldSubscriberId", .T.)
            oCenBenefi:setMatAnt(oJson["oldSubscriberId"])
        EndIf
        If AttIsMemberOf( oJson, "unblockDate", .T.)
            oCenBenefi:setDatRea(oCenBenefi:utcToDate(oJson["unblockDate"]))
        EndIf
        If AttIsMemberOf( oJson, "pisPasep", .T.)
            oCenBenefi:setPisPas(oJson["pisPasep"])
            aAdd(self:aDadEnv,{"B3K_PISPAS",oJson["pisPasep"]})
        EndIf
        If AttIsMemberOf( oJson, "mothersName", .T.)
            oCenBenefi:setNomMae(oJson["mothersName"])
            aAdd(self:aDadEnv,{"B3K_NOMMAE",oJson["mothersName"]})
        EndIf
        If AttIsMemberOf( oJson, "declarationOfLiveBirth", .T.)
            oCenBenefi:setDn(oJson["declarationOfLiveBirth"])
            aAdd(self:aDadEnv,{"B3K_DN",oJson["declarationOfLiveBirth"]})
        EndIf
        If AttIsMemberOf( oJson, "nationalHealthCard", .T.)
            oCenBenefi:setCns(oJson["nationalHealthCard"])
            aAdd(self:aDadEnv,{"B3K_CNS",oJson["nationalHealthCard"]})
        EndIf
        If AttIsMemberOf( oJson, "address", .T.)
            oCenBenefi:setEndere(oJson["address"])
            aAdd(self:aDadEnv,{"B3K_ENDERE",oJson["address"]})
        EndIf
        If AttIsMemberOf( oJson, "houseNumbering", .T.)
            oCenBenefi:setNr_end(oJson["houseNumbering"])
            aAdd(self:aDadEnv,{"B3K_NR_END",oJson["houseNumbering"]})
        EndIf
        If AttIsMemberOf( oJson, "addressComplement", .T.)
            oCenBenefi:setComEnd(oJson["addressComplement"])
            aAdd(self:aDadEnv,{"B3K_COMEND",oJson["addressComplement"]})
        EndIf
        If AttIsMemberOf( oJson, "district", .T.)
            oCenBenefi:setBairro(oJson["district"])
            aAdd(self:aDadEnv,{"B3K_BAIRRO",oJson["district"]})
        EndIf
        If AttIsMemberOf( oJson, "cityCode", .T.)
            oCenBenefi:setCodMun(oJson["cityCode"])
            aAdd(self:aDadEnv,{"B3K_CODMUN",oJson["cityCode"]})
        EndIf
        If AttIsMemberOf( oJson, "cityCodeResidence", .T.)
            oCenBenefi:setMunIci(oJson["cityCodeResidence"])
            aAdd(self:aDadEnv,{"B3K_MUNICI",oJson["cityCodeResidence"]})
        EndIf
        If AttIsMemberOf( oJson, "ZIPCode", .T.)
            oCenBenefi:setCepUsr(oJson["ZIPCode"])
            aAdd(self:aDadEnv,{"B3K_CEPUSR",oJson["ZIPCode"]})
        EndIf
        If AttIsMemberOf( oJson, "typeOfAddress", .T.)
            oCenBenefi:setTipEnd(oJson["typeOfAddress"])
            aAdd(self:aDadEnv,{"B3K_TIPEND",oJson["typeOfAddress"]})
        EndIf
        If AttIsMemberOf( oJson, "residentAbroad", .T.)
            oCenBenefi:setResExt(oJson["residentAbroad"])
            aAdd(self:aDadEnv,{"B3K_RESEXT",oJson["residentAbroad"]})
        EndIf
        If AttIsMemberOf( oJson, "holderRelationship", .T.)
            oCenBenefi:setTipDep(oJson["holderRelationship"])
            aAdd(self:aDadEnv,{"B3K_TIPDEP",oJson["holderRelationship"]})
        EndIf
        If AttIsMemberOf( oJson, "holderSubscriberId", .T.)
            oCenBenefi:setCodTit(oJson["holderSubscriberId"])
            aAdd(self:aDadEnv,{"B3K_CODTIT",oJson["holderSubscriberId"]})
        EndIf
        If AttIsMemberOf( oJson, "codeSusep", .T.)
            oCenBenefi:setSusep(oJson["codeSusep"])
        EndIf
        If AttIsMemberOf( oJson, "codeSCPA", .T.)
            oCenBenefi:setScpa(oJson["codeSCPA"])
        EndIf
        If AttIsMemberOf( oJson, "partialCoverage", .T.)
            oCenBenefi:setCobPar(oJson["partialCoverage"])
            aAdd(self:aDadEnv,{"B3K_COBPAR",oJson["partialCoverage"]})
        EndIf
        If AttIsMemberOf( oJson, "guarantorCNPJ", .T.)
            oCenBenefi:setCnpJco(oJson["guarantorCNPJ"])
            aAdd(self:aDadEnv,{"B3K_CNPJCO",oJson["guarantorCNPJ"]})
        EndIf
        If AttIsMemberOf( oJson, "guarantorCEI", .T.)
            oCenBenefi:setCeiCon(oJson["guarantorCEI"])
            aAdd(self:aDadEnv,{"B3K_CEICON",oJson["guarantorCEI"]})
        EndIf
        If AttIsMemberOf( oJson, "holderCPF", .T.)
            oCenBenefi:setCpf(oJson["holderCPF"])
            aAdd(self:aDadEnv,{"B3K_CPF",oJson["holderCPF"]})
        EndIf
        If AttIsMemberOf( oJson, "motherCPF", .T.)
            oCenBenefi:setCpfMae(oJson["motherCPF"])
            aAdd(self:aDadEnv,{"B3K_CPFMAE",oJson["motherCPF"]})
        EndIf
        If AttIsMemberOf( oJson, "sponsorCPF", .T.)
            oCenBenefi:setCpfPre(oJson["sponsorCPF"])
            aAdd(self:aDadEnv,{"B3K_CPFPRE",oJson["sponsorCPF"]})
        EndIf
        If AttIsMemberOf( oJson, "excludedItems", .T.)
            oCenBenefi:setIteExc(oJson["excludedItems"])
            aAdd(self:aDadEnv,{"B3K_ITEEXC",oJson["excludedItems"]})
        EndIf
        If AttIsMemberOf( oJson, "skipRuleName", .T.)
            oCenBenefi:setCriNom(oJson["skipRuleName"])
        EndIf
        If AttIsMemberOf( oJson, "skipRuleMothersName", .T.)
            oCenBenefi:setCriMae(oJson["skipRuleMothersName"])
        EndIf
        If AttIsMemberOf( oJson, "blockingReason", .T.)
            oCenBenefi:setMotBlo(oJson["blockingReason"])
        EndIf
        If AttIsMemberOf( oJson, "statusAns", .T.)
            oCenBenefi:setSitAns(oJson["statusAns"])
        EndIf
        If AttIsMemberOf( oJson, "notifyANS", .T.)
            oCenBenefi:setNotifyANS(oJson["notifyANS"])
        EndIf
        If AttIsMemberOf( oJson, "caepf", .T.)
            oCenBenefi:setCAEPF(oJson["caepf"])
            aAdd(self:aDadEnv,{"B3K_CAEPF",oJson["caepf"]})
        EndIf
        If AttIsMemberOf( oJson, "portabilityPlanCode", .T.)
            oCenBenefi:setPlaOri(oJson["portabilityPlanCode"])
            aAdd(self:aDadEnv,{"B3K_PLAORI",oJson["portabilityPlanCode"]})
        EndIf
        If AttIsMemberOf( oJson, "guarantorName", .T.)
            oCenBenefi:setNomeCO(oJson["guarantorName"])
        EndIf
        If AttIsMemberOf( oJson, "checkchange", .T.)
            oCenBenefi:setChange(oJson["checkchange"])
        EndIf
        oCenBenefi:setDadEnv(self:aDadEnv)

    EndIf

    If nType == INSERT

        oCenBenefi:setCodCCO(oJson["codeCco"])
        oCenBenefi:setCodCCO(self:mapCco(oCenBenefi:getCodCCO()))

        oCenBenefi:setMatric(oJson["subscriberId"])
        oCenBenefi:setCodOpe(oJson["healthInsurerCode"])

        If AttIsMemberOf( oJson, "name", .T.)
            oCenBenefi:setNomBen(oJson["name"])
        EndIf
        If AttIsMemberOf( oJson, "gender", .T.)
            oCenBenefi:setSexo(oJson["gender"])
        EndIf
        If AttIsMemberOf( oJson, "birthdate", .T.)
            oCenBenefi:setDatNas(oCenBenefi:utcToDate(oJson["birthdate"]))
        EndIf
        If AttIsMemberOf( oJson, "effectiveDate", .T.)
            oCenBenefi:setDatInc(oCenBenefi:utcToDate(oJson["effectiveDate"]))
        EndIf
        If AttIsMemberOf( oJson, "blockDate", .T.)
            oCenBenefi:setDatBlo(oCenBenefi:utcToDate(oJson["blockDate"]))
        EndIf
        If AttIsMemberOf( oJson, "stateAbbreviation", .T.)
            oCenBenefi:setUf(oJson["stateAbbreviation"])
        EndIf
        If AttIsMemberOf( oJson, "healthInsuranceCode", .T.)
            oCenBenefi:setCodPro(oJson["healthInsuranceCode"])
        EndIf
        If AttIsMemberOf( oJson, "oldSubscriberId", .T.)
            oCenBenefi:setMatAnt(oJson["oldSubscriberId"])
        EndIf
        If AttIsMemberOf( oJson, "unblockDate", .T.)
            oCenBenefi:setDatRea(oCenBenefi:utcToDate(oJson["unblockDate"]))
        EndIf
        If AttIsMemberOf( oJson, "pisPasep", .T.)
            oCenBenefi:setPisPas(oJson["pisPasep"])
        EndIf
        If AttIsMemberOf( oJson, "mothersName", .T.)
            oCenBenefi:setNomMae(oJson["mothersName"])
        EndIf
        If AttIsMemberOf( oJson, "declarationOfLiveBirth", .T.)
            oCenBenefi:setDn(oJson["declarationOfLiveBirth"])
        EndIf
        If AttIsMemberOf( oJson, "nationalHealthCard", .T.)
            oCenBenefi:setCns(oJson["nationalHealthCard"])
        EndIf
        If AttIsMemberOf( oJson, "address", .T.)
            oCenBenefi:setEndere(oJson["address"])
        EndIf
        If AttIsMemberOf( oJson, "houseNumbering", .T.)
            oCenBenefi:setNr_end(oJson["houseNumbering"])
        EndIf
        If AttIsMemberOf( oJson, "addressComplement", .T.)
            oCenBenefi:setComEnd(oJson["addressComplement"])
        EndIf
        If AttIsMemberOf( oJson, "district", .T.)
            oCenBenefi:setBairro(oJson["district"])
        EndIf
        If AttIsMemberOf( oJson, "cityCode", .T.)
            oCenBenefi:setCodMun(oJson["cityCode"])
        EndIf
        If AttIsMemberOf( oJson, "cityCodeResidence", .T.)
            oCenBenefi:setMunIci(oJson["cityCodeResidence"])
        EndIf
        If AttIsMemberOf( oJson, "ZIPCode", .T.)
            oCenBenefi:setCepUsr(oJson["ZIPCode"])
        EndIf
        If AttIsMemberOf( oJson, "typeOfAddress", .T.)
            oCenBenefi:setTipEnd(oJson["typeOfAddress"])
        EndIf
        If AttIsMemberOf( oJson, "residentAbroad", .T.)
            oCenBenefi:setResExt(oJson["residentAbroad"])
        EndIf
        If AttIsMemberOf( oJson, "holderRelationship", .T.)
            oCenBenefi:setTipDep(oJson["holderRelationship"])
        EndIf
        If AttIsMemberOf( oJson, "holderSubscriberId", .T.)
            oCenBenefi:setCodTit(oJson["holderSubscriberId"])
        EndIf
        If AttIsMemberOf( oJson, "codeSusep", .T.)
            oCenBenefi:setSusep(oJson["codeSusep"])
        EndIf
        If AttIsMemberOf( oJson, "codeSCPA", .T.)
            oCenBenefi:setScpa(oJson["codeSCPA"])
        EndIf
        If AttIsMemberOf( oJson, "partialCoverage", .T.)
            oCenBenefi:setCobPar(oJson["partialCoverage"])
        EndIf
        If AttIsMemberOf( oJson, "guarantorCNPJ", .T.)
            oCenBenefi:setCnpJco(oJson["guarantorCNPJ"])
        EndIf
        If AttIsMemberOf( oJson, "guarantorCEI", .T.)
            oCenBenefi:setCeiCon(oJson["guarantorCEI"])
        EndIf
        If AttIsMemberOf( oJson, "holderCPF", .T.)
            oCenBenefi:setCpf(oJson["holderCPF"])
        EndIf
        If AttIsMemberOf( oJson, "motherCPF", .T.)
            oCenBenefi:setCpfMae(oJson["motherCPF"])
        EndIf
        If AttIsMemberOf( oJson, "sponsorCPF", .T.)
            oCenBenefi:setCpfPre(oJson["sponsorCPF"])
        EndIf
        If AttIsMemberOf( oJson, "excludedItems", .T.)
            oCenBenefi:setIteExc(oJson["excludedItems"])
        EndIf
        If AttIsMemberOf( oJson, "blockingReason", .T.)
            oCenBenefi:setMotBlo(oJson["blockingReason"])
        EndIf
        If AttIsMemberOf( oJson, "skipRuleName", .T.)
            oCenBenefi:setCriNom(oJson["skipRuleName"])
        EndIf
        If AttIsMemberOf( oJson, "skipRuleMothersName", .T.)
            oCenBenefi:setCriMae(oJson["skipRuleMothersName"])
        EndIf
        If AttIsMemberOf( oJson, "statusAns", .T.)
            oCenBenefi:setSitAns(oJson["statusAns"])
        EndIf
        If AttIsMemberOf( oJson, "notifyANS", .T.)
            oCenBenefi:setNotifyANS(oJson["notifyANS"])
        EndIf
        If AttIsMemberOf( oJson, "caepf", .T.)
            oCenBenefi:setCAEPF(oJson["caepf"])
        EndIf
        If AttIsMemberOf( oJson, "portabilityPlanCode", .T.)
            oCenBenefi:setPlaOri(oJson["portabilityPlanCode"])
        EndIf
        If AttIsMemberOf( oJson, "guarantorName", .T.)
            oCenBenefi:setNomeCO(oJson["guarantorName"])
        EndIf

    EndIf

    If nType == SIB_CANCELA
        oCenBenefi:setCodOpe(oJson["healthInsurerCode"])
        oCenBenefi:setCodCCO(oJson["codeCco"])
        oCenBenefi:setDatBlo(oCenBenefi:utcToDate(oJson["blockingDate"]))
        oCenBenefi:setMotBlo(oJson["blockingReason"])
    EndIf

    If nType == SIB_REATIVA
        oCenBenefi:setCodOpe(oJson["healthInsurerCode"])
        oCenBenefi:setCodCCO(oJson["codeCco"])
        oCenBenefi:setDatRea(oCenBenefi:utcToDate(oJson["unblockDate"]))
    EndIf

    If nType == SIB_MUDCONT

        oCenBenefi:setCodOpe(oJson["healthInsurerCode"])
        oCenBenefi:setCodCCO(oJson["codeCco"])
        oCenBenefi:setPlaOri(oJson["portabilityPlanCode"])
        oCenBenefi:setCnpJco(oJson["guarantorCNPJ"])
        oCenBenefi:setIteExc(oJson["excludedItems"])
        oCenBenefi:setCobPar(oJson["partialCoverage"])
        oCenBenefi:setTipDep(oJson["holderRelationship"])
        oCenBenefi:setCodPro(oJson["healthInsuranceCode"])
        oCenBenefi:setDatInc(oCenBenefi:utcToDate(oJson["effectiveDate"]))

        If AttIsMemberOf( oJson, "holderSubscriberId",.T.)
            oCenBenefi:setCodTit(oJson["holderSubscriberId"])
        EndIf
        If AttIsMemberOf( oJson, "guarantorCEI",.T.)
            oCenBenefi:setCeiCon(oJson["guarantorCEI"])
        EndIf
        If AttIsMemberOf( oJson, "caepf",.T.)
            oCenBenefi:setCAEPF(oJson["caepf"])
        EndIf
        If AttIsMemberOf( oJson, "codeSCPA", .T.)
            oCenBenefi:setScpa(oJson["codeSCPA"])
        EndIf
        If AttIsMemberOf( oJson, "codeSusep", .T.)
            oCenBenefi:setSusep(oJson["codeSusep"])
        EndIf

    EndIf

Return

Method mapCco(cCodCco) Class MprCenBenefi

    Default cCodCco := ""

    If !Empty(cCodCco)
        cCodCco := PADL(AllTrim(cCodCco),12, "0")
    EndIf

Return cCodCco