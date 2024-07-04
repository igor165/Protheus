#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

#DEFINE SINGLE "01"
#DEFINE ALL    "02"
#DEFINE INSERT "03"
#DEFINE DELETE "04"
#DEFINE UPDATE "05"
#DEFINE LOTE   "06"
#DEFINE BUSCA  "07"

Class RestCenProd from AutRestObj

    Data oJsonCenProd
    Data oProdValidate

    Method New(oRest,cSvcName) Constructor
    Method applyFilter(nType) 
    Method applyOrder(cOrder) 
    Method buscar(nType)
    Method procCenProd(nType)
    Method buildBodyCenProd(oCenProd)
    Method procAltCenProd()
    Method procInsCenProd()
    Method procDelCenProd()

EndClass

Method New(oRest, cSvcName) Class RestCenProd
    _Super:New(oRest,cSvcName)
    self:oDao          := DaoCenProd():New()
    self:oBuscador     := BscCenProd():New(self:oDao)
    self:oJsonCenProd  := JsonObject():New() 
    self:oProdValidate := ProdValidate():New(self)
    self:oCenLogger:setFileName("arquivo_log_produto")
Return self

Method applyFilter(nType) Class RestCenProd
    If self:lSuccess
        self:oDao:setCodOpe(self:oRest:healthInsurerCode)
        If nType == ALL
            self:oDao:setCodigo(self:oRest:code)
            self:oDao:setDescri(self:oRest:description)
            self:oDao:setForcon(self:oRest:wayofhiring)
            self:oDao:setSegmen(self:oRest:marketsegmentation)
            self:oDao:setAbrang(self:oRest:coveragearea)
        EndIf
        If nType == SINGLE
            self:oDao:setCodigo(self:oRest:healthInsuranceCode)
        EndIf
    Endif
Return self:lSuccess

Method applyOrder(cOrder) Class RestCenProd
    If self:lSuccess
        self:oDao:setOrder(cOrder)
    Endif
Return self:lSuccess

Method buscar(nType) Class RestCenProd

    Local lExiste := nil 

    If self:lSuccess

        If nType == ALL
            lExiste := self:oBuscador:buscar()
        Else 
            lExiste := self:oBuscador:buscar()
        EndIf

        If !lExiste .AND. nType != INSERT .AND. nType != BUSCA
            self:lSuccess     := .F. 
            self:nFault       := 404
            self:nStatus      := 404
            self:cFaultDesc   := "Operação não pode ser realizada."
            self:cFaultDetail := "Produto(s) não localizado(s)."
        ElseIf lExiste .AND. nType == INSERT
            self:lSuccess     := .F.
            self:nFault       := 400
            self:nStatus      := 400
            self:cFaultDesc   := "Operação não pode ser realizada."
            self:cFaultDetail := "Produto já existe."
        EndIf

    Endif

Return lExiste

Method procCenProd(nType) Class RestCenProd

    Local nCenProd     := 1
    Local oMprCenProd  := MprCenProd():New()
    Local oCenProd     := CenProd():New()

    If self:lSuccess
        if self:oBuscador:found()
            If nType == ALL
                while self:oBuscador:hasNext() .And. nCenProd <= Val(self:oDao:getPageSize())
                    oCenProd := self:oBuscador:getNext(oCenProd, oMprCenProd)
                    oCenProd:setHashFields(self:oRespControl:hmFields)
                    aAdd(self:oRespBody['items'], self:buildBodyCenProd(oCenProd))
                    nCenProd++
                enddo
                self:oRespBody["hasNext"] := self:oBuscador:hasNext()
                self:cResponse := self:oRespBody:toJson()
            Else
                oCenProd := self:oBuscador:getNext(oCenProd, oMprCenProd)
                oCenProd:setHashFields(self:oRespControl:hmFields)
                self:oJsonCenProd := self:buildBodyCenProd(oCenProd)
                self:cResponse := self:oJsonCenProd:toJson()
            Endif
        Else
            If nType == ALL
                self:oRespBody["hasNext"] := self:oBuscador:hasNext()
                self:cResponse := self:oRespBody:toJson()
            Else
                self:cResponse := self:oJsonCenProd:toJson()
            EndIF
        Endif        
    Endif

    self:oDao:destroy()
    
    FreeObj(oMprCenProd)
    oMprCenProd := Nil

    FreeObj(oCenProd)
    oCenProd := Nil

Return self:lSuccess

Method procAltCenProd() Class RestCenProd
    
    Local cJson       := ''
    Local oCenProd    := CenProd():New()
    Local oMprCenProd := MprCenProd():new()
    
    cJson := DecodeUTF8(self:oRest:GetContent(), "cp1252")
    FWJsonDeserialize(cJson, @self:oJsonCenProd)
                
    If self:lSuccess
        
            oCenProd:setCodigo(self:oRest:healthInsuranceCode) 
            oMprCenProd:mapFromJson(oCenProd, @self:oJsonCenProd, UPDATE)
            self:oRest:healthInsurerCode := oCenProd:getCodOpe()

            self:applyFilter(SINGLE)
        
            If self:oProdValidate:valProd(oCenProd) //Validate
                If (self:oDao:commit(oCenProd, self, UPDATE))
                    self:nStatus := 200
                    self:oRespBody := oCenProd:serialize(self:oRespControl)
                    self:cResponse := self:oRespBody:toJson()
                Endif
            EndIf //Fim Validate
    Endif

    self:oDao:destroy()

    FreeObj(oMprCenProd)
    oMprCenProd := Nil

    FreeObj(oCenProd)
    oCenProd := Nil
 
Return self:lSuccess

Method procInsCenProd() Class RestCenProd

    Local cJson         := ""
    Local oCenSegmen    := Nil
    Local oDaoCenSegmen := DaoCenSegmen():New()
    Local oCenAbrang    := Nil
    Local oDaoCenAbrang := DaoCenAbrang():New()    
    Local oCenProd      := CenProd():New()
    Local oMprCenProd   := MprCenProd():New()
    
    cJson := DecodeUTF8(self:oRest:GetContent(), "cp1252")
    FWJsonDeserialize(cJson, @self:oJsonCenProd)

    if self:lSuccess
        
        oMprCenProd:mapFromJson(oCenProd, @self:oJsonCenProd, INSERT)
        self:oRest:healthInsurerCode   := oCenProd:getCodOpe()
        self:oRest:healthInsuranceCode := oCenProd:getCodigo()
        
        self:applyFilter(SINGLE)

        oCenSegmen := CenSegmen():New(oCenProd:getSegmen())
        oDaoCenSegmen:setSegmen(oCenSegmen:getSegmen())

        oCenAbrang := CenAbrang():New(oCenProd:getAbrang())
        oDaoCenAbrang:setCodOri(oCenProd:getAbrang())
        
        If self:oProdValidate:valProd(oCenProd) //Validate
            If (oDaoCenSegmen:commit(oCenSegmen, self, INSERT))
                If (oDaoCenAbrang:commit(oCenAbrang, self, INSERT))
                    If (self:oDao:commit(oCenProd, self, INSERT))
                        self:nStatus := 201
                        self:oRespBody := oCenProd:serialize(self:oRespControl)
                        cJson := self:oRespBody:toJson()
                        self:cResponse := "["+ cJson +"]"
                    EndIf
                Else
                    //Erro ao cadastrar Abrangência
                    self:lSuccess     := .F. 
                    self:nFault       := 400
                    self:nStatus      := 400
                    self:cFaultDesc   := "Operação não pode ser realizada."
                    self:cFaultDetail := "Erro ao cadastrar abrangência."                
                EndIf
            Else
                //Erro ao cadastrar o seguimento
                self:lSuccess     := .F. 
                self:nFault       := 400
                self:nStatus      := 400
                self:cFaultDesc   := "Operação não pode ser realizada."
                self:cFaultDetail := "Erro ao cadastrar segumento."                            
            Endif
        EndIf //Fim Validate
    Endif

    self:oDao:destroy()

    FreeObj(oCenSegmen)
    oCenSegmen := Nil

    FreeObj(oDaoCenSegmen)
    oDaoCenSegmen := Nil

    FreeObj(oCenAbrang)
    oCenAbrang := Nil

    FreeObj(oDaoCenAbrang)
    oDaoCenAbrang := Nil

    FreeObj(oCenProd)
    oCenProd := Nil

    FreeObj(oMprCenProd)
    oMprCenProd := Nil

Return self:lSuccess


Method procDelCenProd() Class RestCenProd

    Local oCenProd    := CenProd():New()
    Local oMprCenProd := MprCenProd():new()

    if self:lSuccess

        self:applyFilter(SINGLE)
        
        If (self:oDao:commit(oCenProd, self, DELETE))
            self:nStatus := 204
            self:cResponse := ""
        Endif
    endif

    self:oDao:destroy()

    FreeObj(oCenProd)
    oCenProd := Nil

    FreeObj(oMprCenProd)
    oMprCenProd := Nil

Return self:lSuccess

Method buildBodyCenProd(oCenProd, nType) Class RestCenProd
Return oCenProd:serialize(self:oRespControl)