#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"

#DEFINE ARQUIVO_LOG "rest_log.txt"
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

Class RestCenBenefi from AutRestObj

    Data oJsonCenBenefi
    Data oJsonSerialize
    Data oJsonLoteResponse
    Data lLoteItemExists
    Data oBeneValidate
 
    Method New(oRest,cSvcName) Constructor
    Method applyFilter(nType)
    Method applyOrder(cOrder)
    Method buscar(nType)
    Method procCenBenefi(nType)
    Method altBenefi()
    Method insCenBenefi()
    Method insLoteCenBenefi()
    Method delBenefi()
    Method cancelBenefi()  
    Method reactBenefi()
    Method changContrBene()
    Method checkAgreement()
    Method buildBodyCenBenefi(oCenBenefi)
    Method cleanVars()

EndClass

Method New(oRest, cSvcName) Class RestCenBenefi
    _Super:New(oRest,cSvcName)
    self:oDao           := DaoCenBenefi():New()
    self:oBuscador      := BscCenBenefi():New(self:oDao)
    self:oJsonCenBenefi := JsonObject():New() 
    self:oBeneValidate  := BeneValidate():New(self)
    self:oCenLogger:setFileName("arquivo_log_beneficiario")
Return self


Method cleanVars() Class RestCenBenefi
    
    if self:oJsonCenBenefi <> Nil
        FreeObj(self:oJsonCenBenefi)
        self:oJsonCenBenefi := Nil
    EndIf

    if self:oJsonSerialize <> Nil
        FreeObj(self:oJsonSerialize)
        self:oJsonSerialize := Nil
    EndIf

    if self:oJsonLoteResponse <> Nil
        FreeObj(self:oJsonLoteResponse)
        self:oJsonLoteResponse := Nil
    EndIf

    if self:oBeneValidate <> Nil
        FreeObj(self:oBeneValidate)
        self:oBeneValidate := Nil
    EndIf

Return 

Method applyFilter(nType) Class RestCenBenefi
    If self:lSuccess
        
        self:oDao:setCodOpe(self:oRest:healthInsurerCode)
        
        If nType == ALL
            self:oDao:setCodCco(self:oRest:codeCco)
            self:oDao:setMatric(self:oRest:subscriberId)
            self:oDao:setNomben(self:oRest:name)
            self:oDao:setSexo(self:oRest:gender)
            self:oDao:setDatnas(self:oRest:birthdate)
            self:oDao:setCodpro(self:oRest:healthInsuranceCode)
            self:oDao:setMatant(self:oRest:oldSubscriberId)
            self:oDao:setPispas(self:oRest:pisPasep)
            self:oDao:setNommae(self:oRest:mothersName)
            self:oDao:setCns(self:oRest:nationalHealthCard)
            self:oDao:setEndere(self:oRest:address)
            self:oDao:setNr_end(self:oRest:houseNumbering)
            self:oDao:setComend(self:oRest:addressComplement)
            self:oDao:setBairro(self:oRest:district)
            self:oDao:setCodmun(self:oRest:cityCode)
            self:oDao:setMunici(self:oRest:cityCodeResidence)
            self:oDao:setCepusr(self:oRest:ZIPCode)
            self:oDao:setResext(self:oRest:residentAbroad)
            self:oDao:setTipdep(self:oRest:holderRelationship)
            self:oDao:setCodtit(self:oRest:holderSubscriberId)
            self:oDao:setSusep(self:oRest:codeSusep)
            self:oDao:setScpa(self:oRest:codeSCPA)
            self:oDao:setCobpar(self:oRest:partialCoverage)
            self:oDao:setCnpjco(self:oRest:guarantorCNPJ)
            self:oDao:setCeicon(self:oRest:guarantorCEI)
            self:oDao:setNomeCO(self:oRest:guarantorName)
            self:oDao:setCpf(self:oRest:holderCPF)
            self:oDao:setCpfmae(self:oRest:motherCPF)
            self:oDao:setCpfpre(self:oRest:sponsorCPF)
            self:oDao:setCriNom(self:oRest:skipRuleName)
            self:oDao:setCriMae(self:oRest:skipRuleMothersName)
            self:oDao:setCaepf(self:oRest:caepf)
        EndIf
        If nType == SINGLE 
            self:oDao:setCodCco(self:oRest:codeCco)
            self:oDao:setMatric(self:oRest:subscriberId)
        EndiF
    Endif
Return self:lSuccess

Method applyOrder(cOrder) Class RestCenBenefi
    If self:lSuccess
        self:oDao:setOrder(cOrder)
    Endif
Return self:lSuccess

Method buscar(nType) Class RestCenBenefi

    Local lExiste := nil 

    If self:lSuccess

        If nType == ALL
            lExiste := self:oBuscador:buscar()
        ElseIf nType == LOTE
            lExiste := self:oBuscador:buscar()
            self:lLoteItemExists := lExiste
            If lExiste
                self:lSuccess := .F.
            EndIf
        Else
            lExiste := self:oBuscador:buscar()
        EndIf

        If !lExiste .AND. nType != INSERT .AND. nType != LOTE .AND. nType != BUSCA
            self:lSuccess     := .F.
            self:nStatus      := 404 
            self:nFault       := 404
            self:cFaultDesc   := "Operação não pode ser realizada."
            self:cFaultDetail := "Beneficiário de matrícula: " + self:oRest:subscriberId + " e CCO: " + self:oRest:codeCco +" não encontrado."
        ElseIf lExiste .AND. nType == INSERT
            self:lSuccess     := .F.
            self:nStatus      := 400
            self:nFault       := 400
            self:cFaultDesc   := "Operação não pode ser realizada."
            self:cFaultDetail := "Beneficiário de matrícula: " + self:oRest:subscriberId + " e CCO: " + self:oRest:codeCco +" já existe."
        EndIf
    Endif

Return lExiste

Method procCenBenefi(nType) Class RestCenBenefi

    Local nCenBenefi    := 1
    Local oMprCenBenefi := MprCenBenefi():New()
    Local oCenBenefi    := CenBenefi():New()

    If self:lSuccess    
        if self:oBuscador:found()
            If nType == ALL
                while self:oBuscador:hasNext() .And. nCenBenefi <= Val(self:oDao:getPageSize())
                    oCenBenefi := self:oBuscador:getNext(oCenBenefi, oMprCenBenefi)
                    oCenBenefi:setHashFields(self:oRespControl:hmFields)
                    aAdd(self:oRespBody["items"], self:buildBodyCenBenefi(oCenBenefi))
                    nCenBenefi++
                enddo
                self:oRespBody["hasNext"] := self:oBuscador:hasNext()
                self:cResponse := self:oRespBody:toJson()
            Else
                oCenBenefi := self:oBuscador:getNext(oCenBenefi, oMprCenBenefi)
                oCenBenefi:setHashFields(self:oRespControl:hmFields)            
                self:oJsonCenBenefi := self:buildBodyCenBenefi(oCenBenefi)
                self:cResponse := self:oJsonCenBenefi:toJson()
            Endif
        Else
            If nType == ALL
                self:oRespBody["hasNext"] := self:oBuscador:hasNext()
                self:cResponse := self:oRespBody:toJson()
            Else
                self:cResponse := self:oJsonCenBenefi:toJson()
            EndIF
        Endif
    Endif

    self:oDao:destroy()
    self:cleanVars()

    FreeObj(oMprCenBenefi)
    oMprCenBenefi := Nil
        
    oCenBenefi:destroy()
    FreeObj(oCenBenefi)
    oCenBenefi := Nil

Return self:lSuccess

Method altBenefi() Class RestCenBenefi

    Local cJson         := ""
    Local oCenBenefi    := CenBenefi():New(self:oDao)
    Local oMprCenBenefi := MprCenBenefi():new()

    cJson := DecodeUTF8(self:oRest:GetContent(), "cp1252")
    FWJsonDeserialize(cJson, @self:oJsonCenBenefi)
                
    If self:lSuccess
        
        oMprCenBenefi:mapFromJson(oCenBenefi, self:oJsonCenBenefi, UPDATE)

        oCenBenefi:setMatric(self:oRest:subscriberId)
        oCenBenefi:setCodCco(self:oRest:codeCco)
        oCenBenefi:setCodOpe(self:oRest:healthInsurerCode)

        oCenBenefi:setOpeSib(SIB_RETIFIC)
        self:applyFilter(SINGLE)

        FWJsonDeserialize(cJson, @self:oJsonCenBenefi)
        
        If self:oBeneValidate:valBene(oCenBenefi,self:oJsonCenBenefi) //Validate

            If self:buscar()
                //Mapeia novamente porque a matricula pode ser diferente entre o Body e o queryparam
                oMprCenBenefi:mapFromJson(oCenBenefi, self:oJsonCenBenefi, UPDATE)

                //Verifico se realmente é diferente
                If oCenBenefi:getMatric() != self:oRest:subscriberId .OR. oCenBenefi:getCodCco() != self:oRest:codeCco

                    //Caso seja preciso atualizar as chaves de busca 
                    self:oDao:setCodCco(oCenBenefi:getCodCco())
                    self:oDao:setMatric(oCenBenefi:getMatric())
                    self:oDao:setCodOpe(oCenBenefi:getCodOpe())
                    

                    //Verifico se ja existe um beneficiário para qual a matricula será atualizada
                    If !self:buscar(SINGLE)

                        //Volto a chave para receber o beneficiário que será manipulado
                        self:oDao:setMatric(self:oRest:subscriberId)
                        self:oDao:setCodCco(self:oRest:codeCco)
                        self:oDao:setCodOpe(self:oRest:healthInsurerCode)

                        self:lSuccess := .T.

                        If (self:oDao:commit(oCenBenefi, self, UPDATE))
                            self:oBuscador:oDaoBusca:setCodCco(oCenBenefi:getCodCco())
                            self:oBuscador:oDaoBusca:setMatric(oCenBenefi:getMatric())
                            self:oBuscador:buscar(SINGLE)
                            oCenBenefi := self:oBuscador:getNext(oCenBenefi, oMprCenBenefi)
                            self:nStatus   := 200
                            self:oRespBody := oCenBenefi:serialize(self:oRespControl)
                            self:cResponse := self:oRespBody:toJson()
                        Endif

                    Else
                        self:lSuccess     := .F.
                        self:nStatus      := 400
                        self:nFault       := 400
                        self:cFaultDesc   := "Operação não pode ser realizada."
                        self:cFaultDetail := "Beneficiário de matrícula: " + oCenBenefi:getMatric() + " e CCO: " + oCenBenefi:getCodCco() +" já existe."
                    Endif                

                Else
                    If (self:oDao:commit(oCenBenefi, self, UPDATE))
                        self:oBuscador:oDaoBusca:setCodCco(oCenBenefi:getCodCco())
                        self:oBuscador:oDaoBusca:setMatric(oCenBenefi:getMatric())
                        self:oBuscador:buscar(SINGLE)
                        oCenBenefi := self:oBuscador:getNext(oCenBenefi, oMprCenBenefi)
                        self:nStatus   := 200
                        self:oRespBody := oCenBenefi:serialize(self:oRespControl)
                        self:cResponse := self:oRespBody:toJson()
                    Endif
                EndIf
            Else
                self:lSuccess     := .F.
                self:nStatus      := 404
                self:nFault       := 404
                self:cFaultDesc   := "Operação não pode ser realizada."
                self:cFaultDetail := "Beneficiário de matrícula: " + self:oRest:subscriberId + " e CCO: " + self:oRest:codeCco +" não encontrado."
            EndIf
        Endif

    Endif

    self:oDao:destroy()
    self:cleanVars()    

    oCenBenefi:destroy()
    FreeObj(oCenBenefi)
    oCenBenefi := Nil

    FreeObj(oMprCenBenefi)
    oMprCenBenefi := Nil

Return self:lSuccess

Method insCenBenefi() Class RestCenBenefi

    Local cJson         := ""
    Local oCenBenefi    := CenBenefi():New()
    Local oMprCenBenefi := MprCenBenefi():new()
    
    cJson := DecodeUTF8(self:oRest:GetContent(), "cp1252")
    FWJsonDeserialize(cJson, @self:oJsonCenBenefi)
    
    if self:lSuccess

        oMprCenBenefi:mapFromJson(oCenBenefi, self:oJsonCenBenefi, INSERT)

        self:oRest:healthInsurerCode := oCenBenefi:getCodOpe()
        self:oRest:codeCco           := oCenBenefi:getCodCco()
        self:oRest:subscriberId      := oCenBenefi:getMatric()

        oCenBenefi:setOpeSib(SIB_INCLUIR)

        self:applyFilter(SINGLE)

        If self:oBeneValidate:valBene(oCenBenefi) //Validate
            if (self:oDao:commit(oCenBenefi, self, INSERT))
                self:nStatus := 201
                self:oRespBody := oCenBenefi:serialize(self:oRespControl)
                cJson := self:oRespBody:toJson()
                self:cResponse := cJson
            endif
        endif
    endif

    self:oDao:destroy()
    self:cleanVars()

    oCenBenefi:destroy()
    FreeObj(oCenBenefi)
    oCenBenefi := Nil

    FreeObj(oMprCenBenefi)
    oMprCenBenefi := Nil

Return self:lSuccess

Method insLoteCenBenefi() Class RestCenBenefi

    Local nMinLimit          := 1
    Local nMaxLimit          := 10000
    Local cJson              := ""
    Local nX                 := 1
    Local oCenBenefi         := Nil
    Local oMprCenBenefi      := MprCenBenefi():new()
    Local oJsonAlreadyExists := JsonObject():New()        
    Local oJsonErrors        := JsonObject():New()
    
    self:oRespBody         := nil
    self:oJsonLoteResponse := JsonObject():New()
    self:oJsonSerialize    := AutJsonControl():New()
    
    self:oJsonSerialize:newArray(self:oJsonLoteResponse, 'included')
    self:oJsonSerialize:newArray(self:oJsonLoteResponse, 'notIncluded')

    self:oJsonSerialize:newArray(oJsonAlreadyExists, 'beneficiaries')
    self:oJsonSerialize:setProp(oJsonAlreadyExists, 'codeError', 400)
    self:oJsonSerialize:setProp(oJsonAlreadyExists, 'errorMessage', 'Beneficiário(s) Já existe(m).')

    self:oJsonSerialize:newArray(oJsonErrors, 'beneficiaries')
    self:oJsonSerialize:setProp(oJsonErrors, 'codeError', 400)
    self:oJsonSerialize:setProp(oJsonErrors, 'errorMessage', 'Erro ao tentar inserir Beneficiário(s).')
           
    cJson := DecodeUTF8(self:oRest:GetContent(), "cp1252")
    FWJsonDeserialize(cJson, @self:oJsonCenBenefi)
    
    if self:lSuccess

        if ValType(self:oJsonCenBenefi) == "A"
           
            nCount := Len(self:oJsonCenBenefi)

            If nCount >= nMinLimit .AND. nCount <= nMaxLimit

                For nX := 1 to Len(self:oJsonCenBenefi)

                    oCenBenefi := CenBenefi():New()
                    oMprCenBenefi:mapFromJson(oCenBenefi, self:oJsonCenBenefi[nX], INSERT)

                    self:oRest:healthInsurerCode := oCenBenefi:getCodOpe()
                    self:oRest:codeCco           := oCenBenefi:getCodCco()
                    self:oRest:subscriberId      := oCenBenefi:getMatric()

                    oCenBenefi:setOpeSib(SIB_INCLUIR)
                    self:applyFilter(SINGLE)

                    if (self:oDao:commit(oCenBenefi, self, LOTE))
                        self:oJsonSerialize:oBjArray(self:oJsonLoteResponse, 'included', oCenBenefi:serialize(self:oRespControl))
                    Else
                        If self:lLoteItemExists
                            self:oJsonSerialize:oBjArray(oJsonAlreadyExists, 'beneficiaries', oCenBenefi:serialize(self:oRespControl))
                            self:lSuccess  := .T.
                            self:lLoteItemExists := .F.
                        Else
                            self:oJsonSerialize:oBjArray(oJsonErrors, 'beneficiaries', oCenBenefi:serialize(self:oRespControl))
                            self:lSuccess  := .T.
                            self:lLoteItemExists := .F.                        
                        EndIf
                    EndIf

                    oCenBenefi := Nil
                    self:oRespControl := Nil

                Next

                If len(oJsonAlreadyExists["beneficiaries"]) >= 1
                    aAdd(self:oJsonLoteResponse["notIncluded"], oJsonAlreadyExists)    
                EndIf
                If len(oJsonErrors["beneficiaries"]) >= 1
                    aAdd(self:oJsonLoteResponse["notIncluded"], oJsonErrors)
                EndIf
                
                self:lSuccess  := .T.
                self:nStatus   := 200
                self:cResponse := self:oJsonLoteResponse:toJson()

            Else 
                self:lSuccess     := .F.
                self:nStatus      := 400
                self:nFault       := 400
                self:cFaultDesc   := "Operação não pode ser realizada."
                self:cFaultDetail := "Operação em lote só é permitida de " + cValToChar(nMinLimit) + " a " + cValToChar(nMaxLimit) + " registros."
            EndIf
        Else
            self:lSuccess     := .F.
            self:nStatus      := 400
            self:nFault       := 400
            self:cFaultDesc   := "Operação não pode ser realizada."
            self:cFaultDetail := "Operação só pode ser realizada em lote, com um array de objetos válidos."
        EndIf
    EndIf

    self:oDao:destroy()
    self:cleanVars()    

    If oCenBenefi <> Nil
        oCenBenefi:destroy()
        FreeObj(oCenBenefi)
        oCenBenefi := Nil        
    EndIf
    
    FreeObj(oMprCenBenefi)
    oMprCenBenefi := Nil

    FreeObj(oJsonAlreadyExists)
    oJsonAlreadyExists := Nil

    FreeObj(oJsonErrors)
    oJsonErrors := Nil

Return self:lSuccess

Method delBenefi() Class RestCenBenefi

    Local oCenBenefi := CenBenefi():New()
           
    If self:lSuccess
        if (self:oDao:commit(oCenBenefi, self, DELETE))
            self:nStatus := 204
            self:cResponse := ""
        endif
    endif

    self:oDao:destroy()
    self:cleanVars()    

    oCenBenefi:Destroy()
    FreeObj(oCenBenefi)
    oCenBenefi := Nil

Return self:lSuccess

Method cancelBenefi()  Class RestCenBenefi

    Local cJson         := ""
    Local oCenBenefi    := CenBenefi():New()
    Local oMprCenBenefi := MprCenBenefi():new()
    
    cJson := DecodeUTF8(self:oRest:GetContent(), "cp1252")
    FWJsonDeserialize(cJson, @self:oJsonCenBenefi)
                
    If self:lSuccess

        oCenBenefi:setMatric(self:oRest:subscriberId) 
        oMprCenBenefi:mapFromJson(oCenBenefi, self:oJsonCenBenefi, SIB_CANCELA)

        self:oRest:healthInsurerCode := oCenBenefi:getCodOpe()
        self:oRest:codeCco := oCenBenefi:getCodCco()

        self:applyFilter(SINGLE)

        If (self:oDao:commitCancel(oCenBenefi, self))
            self:nStatus := 200
            self:cResponse := cJson
        Endif

    endif

    self:oDao:destroy()
    self:cleanVars()    

    oCenBenefi:destroy()
    FreeObj(oCenBenefi)
    oCenBenefi := Nil

    FreeObj(oMprCenBenefi)
    oMprCenBenefi := Nil

Return self:lSuccess

Method reactBenefi() Class RestCenBenefi

    Local cJson         := ""
    Local oCenBenefi    := CenBenefi():New()
    Local oMprCenBenefi := MprCenBenefi():new()
    
    cJson := DecodeUTF8(self:oRest:GetContent(), "cp1252")
    FWJsonDeserialize(cJson, @self:oJsonCenBenefi)

    If self:lSuccess

        oCenBenefi:setMatric(self:oRest:subscriberId)
        oMprCenBenefi:mapFromJson(oCenBenefi, self:oJsonCenBenefi, SIB_REATIVA)

        self:oRest:healthInsurerCode := oCenBenefi:getCodOpe()
        self:oRest:codeCco := oCenBenefi:getCodCco()
        self:applyFilter(SINGLE)

        If (self:oDao:commitReact(oCenBenefi, self))
            self:nStatus := 200
            self:cResponse := cJson
        endif
    
    EndIf

    self:oDao:destroy()
    self:cleanVars()    

    oCenBenefi:destroy()
    FreeObj(oCenBenefi)
    oCenBenefi := Nil

    FreeObj(oMprCenBenefi)
    oMprCenBenefi := Nil

Return self:lSuccess

Method changContrBene() Class RestCenBenefi

    Local cJson             := ""
    Local oInCenBenefi      := CenBenefi():New()
    Local oOutCenBenefi     := CenBenefi():New()
    Local oMprCenBenefi     := MprCenBenefi():new()
    
    cJson := DecodeUTF8(self:oRest:GetContent(), "cp1252")
    FWJsonDeserialize(cJson, @self:oJsonCenBenefi)
                
    If self:lSuccess

        oInCenBenefi:setMatric(self:oRest:subscriberId)
        oMprCenBenefi:mapFromJson(oInCenBenefi, self:oJsonCenBenefi, SIB_MUDCONT)

        self:oRest:healthInsurerCode := oInCenBenefi:getCodOpe()
        self:oRest:codeCco := oInCenBenefi:getCodCco()
        self:applyFilter(SINGLE)

        self:buscar(SINGLE)

        If self:lSuccess
            oOutCenBenefi := self:oBuscador:getNext(oInCenBenefi, oMprCenBenefi)
            oMprCenBenefi:mapFromJson(oOutCenBenefi, self:oJsonCenBenefi, SIB_MUDCONT)
            
            if self:oBeneValidate:valChangCon(oOutCenBenefi)

                If (self:oDao:commitChangContrac(oOutCenBenefi, self))
                    If self:lSuccess
                        self:nStatus := 200
                        self:cResponse := cJson
                    EndIf
                EndIf

            EndIf
        
        EndIf

    Endif

    self:oDao:destroy()
    self:cleanVars()

    oInCenBenefi:Destroy()
    FreeObj(oInCenBenefi)
    oInCenBenefi := Nil

    oOutCenBenefi:Destroy()
    FreeObj(oOutCenBenefi)
    oOutCenBenefi := Nil

    FreeObj(oMprCenBenefi)
    oMprCenBenefi := Nil

Return self:lSuccess

Method buildBodyCenBenefi(oCenBenefi, nType) Class RestCenBenefi
Return oCenBenefi:serialize(self:oRespControl)