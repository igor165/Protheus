#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

#DEFINE SIB_INCLUIR "1" // Incluir
#DEFINE SIB_RETIFIC "2" // Retificar
#DEFINE SIB_MUDCONT "3" // Mud.Contrat
#DEFINE SIB_CANCELA "4" // Cancelar
#DEFINE SIB_REATIVA "5" // Reativar

#DEFINE SINGLE "01"
#DEFINE ALL    "02"
#DEFINE INSERT "03"
#DEFINE DELETE "04"
#DEFINE UPDATE "05"
#DEFINE LOTE   "06"
#DEFINE BUSCA  "07"
#DEFINE CCOS   "CCOS"

Class RestCenArqSib from AutRestObj

    Data oJsonCenArqSib
 
    Method New(oRest,cSvcName) Constructor
    Method applyFilter(nType)
    Method buscar(nType)
    Method procCenArqSib(nType)
    Method ccosArqSib() 
    Method buildBodyCenArqSib(oObjec, nType) 
    Method applyOrder(cOrder)

EndClass

Method New(oRest, cSvcName) Class RestCenArqSib
    _Super:New(oRest,cSvcName)
    self:oDao           := DaoCenArqSib():New()
    self:oBuscador      := BscCenArqSib():New(self:oDao)
    self:oJsonCenArqSib := JsonObject():New()
    self:oCenLogger:setFileName("arquivo_log_sib")
Return self

Method applyFilter(nType) Class RestCenArqSib
    If self:lSuccess
        If nType == CCOS
            self:oDao:setArquiv(self:oRest:fileName)
            self:oDao:setNomben(self:oRest:name)
            self:oDao:setMatric(self:oRest:subscriberid)
            self:oDao:setCodcco(self:oRest:codecco)
        Else
            self:oDao:setCodOpe(self:oRest:healthInsurerCode)
            self:oDao:setAno( SubStr(allTrim(STRTRAN(self:oRest:yearMonthRefer, "-", "")), 1, 4) )
            self:oDao:setComp("0" + SubStr(allTrim(STRTRAN(self:oRest:yearMonthRefer, "-", "")), 5, 2) )
        EndIf
    EndiF
Return self:lSuccess

Method applyOrder(cOrder) Class RestCenArqSib
    If self:lSuccess
        self:oDao:setOrder(cOrder)
    Endif
Return self:lSuccess

Method buscar(nType) Class RestCenArqSib

    Local lExiste := nil 

    If self:lSuccess

        If nType == ALL
            lExiste := self:oBuscador:buscar()
        ElseIf nType == CCOS
            lExiste := self:oBuscador:bscCcos()
        Else
            lExiste := self:oBuscador:buscar()
        EndIf

        If !lExiste .AND. nType != INSERT .AND. nType != BUSCA .AND. nType != CCOS
            self:lSuccess     := .F. 
            self:nFault       := 404
            self:nStatus      := 404
            self:cFaultDesc   := "Operação não pode ser realizada."
            self:cFaultDetail := "Arquivo(s) não localizado(s)."
        ElseIf lExiste .AND. nType == INSERT
            self:lSuccess     := .F.
            self:nFault       := 400
            self:nStatus      := 400 
            self:cFaultDesc   := "Operação não pode ser realizada."
            self:cFaultDetail := "Arquivo já existe."
        EndIf

    Endif

Return lExiste

Method procCenArqSib(nType) Class RestCenArqSib

    Local nCenArqSib    := 1
    Local oMprCenArqSib := MprCenArqSib():New()
    Local oCenArqSib    := CenArqSib():New()
    Local oJsonControl  := AutJsonControl():new()

    If self:lSuccess   
        if self:oBuscador:found() 
            If nType == ALL
                while self:oBuscador:hasNext() .And. nCenArqSib <= Val(self:oDao:getPageSize())
                    oCenArqSib := self:oBuscador:getNext(oCenArqSib, oMprCenArqSib)
                    oCenArqSib:setHashFields(self:self:oRespControl:hmFields)
                    aAdd(self:oRespBody["items"], self:buildBodyCenArqSib(oCenArqSib, ""))
                    nCenArqSib++
                enddo
                self:oRespBody["hasNext"] := self:oBuscador:hasNext()
                self:cResponse := self:oRespBody:toJson()
            Else
                oCenArqSib := self:oBuscador:getNext(oCenArqSib, oMprCenArqSib)
                oCenArqSib:setHashFields(self:self:oRespControl:hmFields)
                self:oJsonCenArqSib := self:buildBodyCenArqSib(oCenArqSib, "")
                self:cResponse := self:oJsonCenArqSib:toJson()
            Endif
        Else
            If nType == ALL
                self:oRespBody["hasNext"] := self:oBuscador:hasNext()
                self:cResponse := self:oRespBody:toJson()
            Else
                self:cResponse := self:oJsonCenArqSib:toJson()
            EndIF
        Endif
    Endif

    FreeObj(oMprCenArqSib)
    oMprCenArqSib := nil

    FreeObj(oCenArqSib)
    oCenArqSib := nil

    FreeObj(oJsonControl)
    oJsonControl := nil


Return self:lSuccess

Method ccosArqSib() Class RestCenArqSib

    Local nCenArqSib    := 1
    Local oMprCenBenefi := MprCenBenefi():New()
    Local oCenBenefi    := CenBenefi():New()

    If self:lSuccess
        if self:oBuscador:found() 
            while self:oBuscador:hasNext() .And. nCenArqSib <= Val(self:oDao:getPageSize())
                oMprCenBenefi:mapFromDao(oCenBenefi, self:oDao)
                oCenBenefi:setHashFields(self:oRespControl:hmFields)
                self:oBuscador:goToNext()
                aAdd(self:oRespBody["items"], self:buildBodyCenArqSib(oCenBenefi, CCOS))
                nCenArqSib++
            enddo
            self:oRespBody["hasNext"] := self:oBuscador:hasNext()
            self:cResponse := self:oRespBody:toJson()
        Else
            self:oRespBody["hasNext"] := self:oBuscador:hasNext()
            self:cResponse := self:oRespBody:toJson()
        Endif        
    EndIf

    FreeObj(oMprCenBenefi)
    oMprCenBenefi := nil

    FreeObj(oCenBenefi)
    oCenBenefi := nil
    
Return self:lSuccess

Method buildBodyCenArqSib(oObjec, nType) Class RestCenArqSib
    If nType == CCOS
        Return oObjec:ccoSerialize(self:oRespControl)    
    Else
        Return oObjec:serialize(self:oRespControl)    
    Endif
Return
