#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

#DEFINE SINGLE "01"
#DEFINE ALL    "02"
#DEFINE INSERT "03"
#DEFINE DELETE "04"
#DEFINE UPDATE "05"
#DEFINE BUSCA  "07"

Class CenReqB3X from CenRequest

    Method New(oRest,cSvcName) Constructor
    Method destroy()
    Method applyFilter(nType)
    Method applyOrder(cOrder)
    Method buscar(nType)
    Method prepFilter()

EndClass

Method destroy()  Class CenReqB3X
Return _Super:destroy()

Method New(oRest, cSvcName) Class CenReqB3X
    _Super:New(oRest,cSvcName)
    self:oCollection := CenCltB3X():New()
    self:oValidador := CenVldB3X():New()
    self:cPropLote   := "B3X"
Return self

Method applyFilter(nType) Class CenReqB3X
    
    If self:lSuccess
        If nType == ALL
            self:oCollection:setValue("benefitedRecno",self:oRest:benefitedRecno)
            self:oCollection:setValue("changedField",self:oRest:changedField)
            self:oCollection:setValue("changeDate",self:oRest:changeDate)
            self:oCollection:setValue("fileName",self:oRest:fileName)
            self:oCollection:setValue("sibOperation",self:oRest:sibOperation)
            self:oCollection:setValue("criticized",self:oRest:criticized)
            self:oCollection:setValue("modificationTime",self:oRest:modificationTime)
            self:oCollection:setValue("originDescription",self:oRest:originDescription)
            self:oCollection:setValue("status",self:oRest:status)
            self:oCollection:setValue("previousValue",self:oRest:previousValue)
            self:oCollection:setValue("newValue",self:oRest:newValue)
            self:oCollection:setValue("operatorRecord",self:oRest:operatorRecord)
            self:oCollection:setValue("operationalControlCode",self:oRest:operationalControlCode)
            self:oCollection:setValue("validationStartDate",self:oRest:validationStartDate)
            self:oCollection:setValue("validationStartTime",self:oRest:validationStartTime)
            self:oCollection:setValue("validationEndDate",self:oRest:validationEndDate)
            self:oCollection:setValue("validationEndTime",self:oRest:validationEndTime)

        EndIf
        If nType == SINGLE 
            self:oCollection:setValue("fileName",self:oRest:fileName)
            self:oCollection:setValue("originDescription",self:oRest:originDescription)

        EndIf
    EndIf
Return self:lSuccess

Method applyOrder(cOrder) Class CenReqB3X
    If self:lSuccess
        self:oCollection:applyOrder(cOrder)
    EndIf
Return self:lSuccess

Method prepFilter(oJson) Class CenReqB3X

    Default oJson := self:jRequest
    self:oCollection:setValue("fileName", self:oRest:fileName)
    self:oCollection:setValue("originDescription", self:oRest:originDescription)
    
    self:oCollection:mapFromJson(oJson)

Return

Method buscar(nType) Class CenReqB3X

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


