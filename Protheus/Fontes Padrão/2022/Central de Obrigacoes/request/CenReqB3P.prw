#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

#DEFINE SINGLE "01"
#DEFINE ALL    "02"
#DEFINE INSERT "03"
#DEFINE DELETE "04"
#DEFINE UPDATE "05"
#DEFINE BUSCA  "07"

Class CenReqB3P from CenRequest

    Method New(oRest,cSvcName) Constructor
    Method destroy()
    Method applyFilter(nType)
    Method applyOrder(cOrder)
    Method buscar(nType)
    Method prepFilter()

EndClass

Method destroy()  Class CenReqB3P
Return _Super:destroy()

Method New(oRest, cSvcName) Class CenReqB3P
    _Super:New(oRest,cSvcName)
    self:oCollection := CenCltB3P():New()
    //self:oValidador := CenVldB3P():New()
    self:cPropLote   := "B3P"
Return self

Method applyFilter(nType) Class CenReqB3P

    If self:lSuccess
        If nType == ALL
            self:oCollection:setValue("aliasOrigin",self:oRest:aliasOrigin)
            self:oCollection:setValue("originAcknowledgement",self:oRest:originAcknowledgement)
            self:oCollection:setValue("errorDescription",self:oRest:errorDescription)
            self:oCollection:setValue("callStackError",self:oRest:callStackError)
            self:oCollection:setValue("errorDate",self:oRest:errorDate)
            self:oCollection:setValue("errorTime",self:oRest:errorTime)
            self:oCollection:setValue("idRequest",self:oRest:idRequest)
            self:oCollection:setValue("path",self:oRest:path)
            self:oCollection:setValue("entradaJson",self:oRest:entradaJson)
            self:oCollection:setValue("saidaJson",self:oRest:saidaJson)
            self:oCollection:setValue("verboRequisicao",self:oRest:verboRequisicao)

        EndIf
        If nType == SINGLE

        EndIf
    EndIf
Return self:lSuccess

Method applyOrder(cOrder) Class CenReqB3P
    If self:lSuccess
        self:oCollection:applyOrder(cOrder)
    EndIf
Return self:lSuccess

Method prepFilter(oJson) Class CenReqB3P

    Default oJson := self:jRequest

    self:oCollection:mapFromJson(oJson)

Return

Method buscar(nType) Class CenReqB3P

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


