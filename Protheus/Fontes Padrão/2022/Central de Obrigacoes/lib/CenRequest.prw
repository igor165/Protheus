#INCLUDE "TOTVS.CH"

#DEFINE NIVEL 1
#DEFINE SUBNIVEL 2
#DEFINE RELNAME 1

#DEFINE SINGLE "01"
#DEFINE ALL    "02"
#DEFINE INSERT "03"
#DEFINE DELETE "04"
#DEFINE UPDATE "05"
#DEFINE BUSCA  "07"

#DEFINE NO_BEHAVIOR 0 // Sem comportamento
#DEFINE CASCADE 1     // Relacionamento em cascata

/*/{Protheus.doc} CenRequest
    Classe abstrata que controla o corpo dos endpoints dos servicos rest do autorizador
    @type  Class
    @author victor.silva
    @since 20180427
/*/
Class CenRequest

    Data oRest
    Data cSvcName
    Data cResponse
    Data cPropLote
    Data cFaultDesc
    Data cFaultDetail
    Data aExpand
    Data lSuccess
    Data nStatus
    Data nFault
    Data oReqBody
    Data oRespBody
    Data oRespControl
    Data oCollection
    Data jRequest
    Data oValidador

    Method New(oRest, cSvcName) Constructor

    Method destroy()
    Method checkAuth()
    Method applySearch(cSearch)
    Method applyFields()
    Method applyPageSize()
    Method checkBody()
    Method getSuccess()
    Method initRequest()
    Method endRequest()
    Method serializeFault()
    Method checkAgreement()
    Method procGet(nType)
    Method procDelete()
    Method procPost(cJson,oCmd)
    Method procLotePost(oCmd)
    Method procPut(oCmd)
    Method buildBody(oEntity)
    Method applyExpand()
    Method expand(oJson)
    Method prePstIns(oCltPai)
    Method posPstIns(oCltPai)
    Method preRlt2Ins(oCltPai, oCltFilho)
    Method posRlt2Ins(oCltPai, oCltFilho)
    Method preRlt3Ins(oCltPai, oCltFilho)
    Method posRlt3Ins(oCltPai, oCltFilho)

EndClass

Method New(oRest, cSvcName) Class CenRequest
    self:oRest        := oRest
    self:cSvcName     := cSvcName
    self:lSuccess     := .T.
    self:nStatus      := 200
    self:oReqBody     := JsonObject():New()
    self:oRespBody    := JsonObject():New()
    self:jRequest     := JsonObject():New()
    self:oRespControl := CenJsonControl():New()
    self:nFault       := 0
    self:cFaultDesc   := ''
    self:cResponse    := ''
    self:cFaultDetail := ''
    self:aExpand      := {}
Return self

Method destroy() Class CenRequest

    FreeObj(self:oReqBody)
    self:oReqBody := nil

    FreeObj(self:oRespBody)
    self:oRespBody := nil

    FreeObj(self:oRespControl)
    self:oRespControl := nil

    FreeObj(self:oCollection)
    self:oCollection := nil

    FreeObj(self:jRequest)
    self:jRequest := nil

    FreeObj(self:oValidador)
    self:oValidador := nil

Return

/*/{Protheus.doc} checkAuth
Valida as informacoes de autenticacao do usuario com as informacoes do header da requisicao
@author  victor.silva
@since   20180518
/*/
Method checkAuth() Class CenRequest
    // TODO - IMPLEMENTAR LEITURA DO HEADER COM A AUTENTICACAO DO USUARIO
    // self:oRest:getHeader()
    // VarInfo("REST",ClassMethArr(self:oRest,.T.))
Return self:lSuccess

Method applyFields() Class CenRequest
    self:oRespControl:prepFields(self:oRest:fields)
Return

/*/{Protheus.doc} applySearch
Seta a busca generica solicitada na URL
@author  david.juan
@since   20201112
/*/
Method applySearch() Class CenRequest
    If self:lSuccess
        If !empty(self:oRest:search)
            If self:oCollection:applySearch(self:oRest:search)
                self:lSuccess := .T.
            Else
                self:nFault := 400
                self:cFaultDesc := "A pesquisa não retornou resultado(s)."
                self:cFaultDetail := "search="+self:oRest:search
                self:lSuccess := .F.
            EndIf
        EndIf
    EndIf
Return self:lSuccess

/*/{Protheus.doc} checkAuth
Seta os os expandables solicitados na URL
@author  lima.everton
@since   20191025
/*/
Method applyExpand() Class CenRequest
    If self:lSuccess
        If !empty(self:oRest:expand)
            self:aExpand := StrTokArr2(self:oRest:expand, ",")
            If self:oCollection:applyExpand(self:aExpand)
                self:lSuccess := .T.
            Else
                self:nFault := 400
                self:cFaultDesc := "Não foi possivel aplicar o(s) expandable(s)."
                self:cFaultDetail := "expand="+self:oRest:expand
                self:lSuccess := .F.
            EndIf
        EndIf
    EndIf
Return self:lSuccess

/*/{Protheus.doc} applyPageSize
Aplica o tamanho da pagina para paginas do tipo colecao
@author  victor.silva
@since   20180523
/*/
Method applyPageSize() Class CenRequest

    Default self:oRest:page := "1"
    Default self:oRest:pageSize := "20"

    self:oCollection:applyPageSize(self:oRest:page,self:oRest:pageSize)
    self:oRespBody["hasNext"] := .F.
    self:oRespBody["items"] := {}

Return self:lSuccess

/*/{Protheus.doc} checkBody
Realiza o parser do JSon enviado pelo client
@author  victor.silva
@since   20180518
/*/
Method checkBody() Class CenRequest
    Local cParseError := ""

    // TODO - SYSLOG RFC-5424
    cParseError := self:jRequest:fromJson(DecodeUTF8(self:oRest:GetContent(), "cp1252"))

    If empty(cParseError)
        self:lSuccess  := .T.
    else
        self:nFault     := 400
        self:cFaultDesc   := "Não foi possível fazer o parse da mensagem."
        self:cFaultDetail := cParseError
        self:lSuccess   := .F.
    EndIf

Return self:lSuccess

Method getSuccess() Class CenRequest
Return .T.

/*/{Protheus.doc} endRequest
Inicializa a solicitacao
@author  victor.silva
@since   20180518
/*/
Method initRequest() Class CenRequest
    // TODO - SYSLOG RFC-5424
Return

/*/{Protheus.doc} endRequest
Finaliza a solicitacao e coloca a resposta e status na requisicao
@author  victor.silva
@since   20180518
/*/
Method endRequest() Class CenRequest
    Local cResponse := ""
    If self:lSuccess
        self:oRest:setStatus(self:nStatus)
        cResponse := EncodeUTF8(self:cResponse)
        self:oRest:setResponse(cResponse)
    else
        self:oRest:setStatus(self:nStatus)
        cResponse := EncodeUTF8(self:serializeFault())
        self:oRest:setResponse(cResponse)
        // TODO - AutSysLog: dinamizar o tenantId quando prepararmos a aplicação para trabalhar com tenant
        //AutSysLog(ProcName(), RESTAPI, INFORMATIONAL, 1, self:cMsgId, "[tenantId=1]", {"Finalizando requisição com erro: " + cResponse })
    EndIf
Return

/*/{Protheus.doc} serializeFault
Serializa retorno de falha do WSREST
@author  victor.silva
@since   20180704
/*/
Method serializeFault() Class CenRequest

    Local oJson := JsonObject():New()

    oJson["code"] := self:nFault
    oJson["message"] := self:cFaultDesc
    oJson["detailedMessage"] := self:cFaultDetail
    oJson["helpUrl"] := ""
    oJson["details"] := {}
    aAdd(oJson["details"], JsonObject():New())
    oJson["details"][1]["code"] := ""
    oJson["details"][1]["message"] := ""
    oJson["details"][1]["detailedMessage"] := ""
    oJson["details"][1]["helpUrl"] := ""

Return oJson:toJson()

/*/{Protheus.doc} serializeFault
Percorre a lista de filhos
@author  lima.everton
@since   2019102019
/*/
Method expand(oJson) Class CenRequest

    Local nExp := 1
    Local aExpand := {}
    Local oCltExp := Nil
    Local oCltSub := Nil
    Local oEntity := Nil
    Default oJson := JsonObject():New()

    For nExp:= 1 to Len(self:aExpand)
        If !Empty(self:aExpand[nExp])
            aExpand := StrTokArr2(self:aExpand[nExp],".")

            oJson[aExpand[NIVEL]] := {}
            oCltExp := self:oCollection:getRelation(aExpand[NIVEL])
            oCltExp:buscar()
            If oCltExp:found()
                While oCltExp:hasNext()

                    oEntity := oCltExp:getNext()
                    aAdd(oJson[aExpand[NIVEL]], self:buildBody(oEntity))

                    If Len(aExpand) > 1 //Expande o subnivel
                        oJson[aExpand[NIVEL]][Len(oJson[aExpand[NIVEL]])][aExpand[SUBNIVEL]] := {}
                        oCltSub := oCltExp:getRelation(aExpand[SUBNIVEL])
                        oCltSub:buscar()
                        If oCltSub:found()
                            While oCltSub:hasNext()
                                oEntity := oCltSub:getNext()
                                aAdd(oJson[aExpand[NIVEL]][Len(oJson[aExpand[NIVEL]])][aExpand[SUBNIVEL]], self:buildBody(oEntity))
                            EndDo
                        EndIf
                    EndIf
                EndDo
            EndIf
        EndIf
    Next

    FreeObj(oEntity)
    oEntity := Nil

Return oJson

Method checkAgreement() class CenRequest
Return .T.

Method procGet(nType) Class CenRequest

    Local nRegistro := 1
    Local oEntity := nil
    Local oJson := nil

    If self:lSuccess
        If self:oCollection:found()
            If nType == ALL
                While self:oCollection:hasNext() .And. nRegistro <= Val(self:oCollection:getPageSize())
                    oEntity := self:oCollection:getNext()
                    oEntity:setHashFields(self:oRespControl:hmFields)
                    oJson := self:expand(self:buildBody(oEntity))
                    aAdd(self:oRespBody['items'], oJson)
                    nRegistro++
                EndDo
                self:oRespBody["hasNext"] := self:oCollection:hasNext()
                self:cResponse := self:oRespBody:toJson()
            Else
                oEntity := self:oCollection:getNext(oEntity)
                oEntity:setHashFields(self:oRespControl:hmFields)
                oJson := self:expand(self:buildBody(oEntity))
                self:jRequest := oJson
                self:cResponse := self:jRequest:toJson()
            EndIf
            oEntity:destroy()
        Else
            If nType == ALL
                self:oRespBody["hasNext"] := self:oCollection:hasNext()
            Else
                self:oRespBody := JsonObject():New()
            EndIf
            self:cResponse := self:oRespBody:toJson()
        EndIf

    EndIf

    FreeObj(oEntity)
    oEntity := Nil

Return self:lSuccess

Method prePstIns(oCltPai) Class CenRequest
Return

Method posPstIns(oCltPai) Class CenRequest
Return

Method preRlt2Ins(oCltPai, oCltFilho) Class CenRequest
Return

Method posRlt2Ins(oCltPai, oCltFilho) Class CenRequest
Return

Method preRlt3Ins(oCltPai, oCltFilho) Class CenRequest
Return

Method posRlt3Ins(oCltPai, oCltFilho) Class CenRequest
Return

Method procPost() Class CenRequest

    Local nI := 1
    Local nJ := 1
    Local nX := 0
    Local nY := 0
    Local nQtdExpand := 0
    Local oEntity := nil
    Local oCltRel := nil
    Local cJsonResp := ""
    Local aRelList := {}

    aRelList := self:oCollection:initRelation()

    If self:lSuccess
        self:prepFilter(self:jRequest)
        self:buscar(INSERT)
        If self:lSuccess
            If self:oValidador:validate(self:oCollection)
                self:prePstIns(self:oCollection)
                If self:oCollection:insert()
                    self:posPstIns(self:oCollection)

                    For nI:= 1 to Len(aRelList)
                        oCltRel := self:oCollection:getRelation(aRelList[nI][RELNAME])
                        If self:jRequest[aRelList[nI][RELNAME]] <> nil
                            For nJ:= 1 to Len(self:jRequest[aRelList[nI][RELNAME]])
                                oCltRel:mapFromJson(self:jRequest[aRelList[nI][RELNAME]][nJ])
                                self:preRlt2Ins(self:oCollection,oCltRel)
                                oCltRel:insert()
                                self:posRlt2Ins(self:oCollection,oCltRel)

                                //Busca do subnivel 2
                                aRelList2 := aRelList[nI][SUBNIVEL]:oCollection:initRelation()
                                For nX := 1 to len(aRelList2)
                                    oCltRel2  := aRelList[nI][SUBNIVEL]:oCollection:getRelation(aRelList2[nX][RELNAME])
                                    If valtype(self:jRequest[aRelList[nI,RELNAME],nJ][aRelList2[nX,RELNAME]]) == "A"
                                        For nY := 1 to len(self:jRequest[aRelList[nI,RELNAME],nJ][aRelList2[nX,RELNAME]])
                                            oCltRel2:mapFromJson(self:jRequest[aRelList[nI][RELNAME]][nJ][aRelList2[nX][RELNAME]][nY])
                                            self:preRlt3Ins(oCltRel,oCltRel2)
                                            oCltRel2:insert()
                                            self:posRlt3Ins(oCltRel,oCltRel2)
                                        Next
                                    EndIf
                                Next
                            Next
                        EndIf
                    Next

                    self:nStatus := 201
                    If self:buscar(SINGLE)
                        nJ := 1
                        nQtdExpand := len(self:oCollection:oMapper:aExpand)
                        self:aExpand := Array(1,nQtdExpand)
                        For nJ := 1 to nQtdExpand
                            self:aExpand[nJ] := self:oCollection:oMapper:aExpand[nJ][RELNAME]
                        Next
                        oEntity := self:oCollection:getNext()
                        self:oRespBody := oEntity:serialize(self:oRespControl)
                        If nQtdExpand > 0
                            self:oRespBody := self:expand(self:oRespBody)
                        EndIf
                        cJsonResp := self:oRespBody:toJson()
                    EndIf
                    self:cResponse := cJsonResp
                Else
                    self:lSuccess     := .F.
                    self:nFault       := 400
                    self:nStatus      := 400
                    self:cFaultDesc   := "Operação não pode ser realizada."
                    self:cFaultDetail := "Erro ao realizar insert."
                EndIf
            Else
                self:lSuccess     := .F.
                self:nFault       := 400
                self:nStatus      := 400
                self:cFaultDesc   := "Operação não pode ser realizada."
                self:cFaultDetail := self:oValidador:getErrMsg()
            EndIf
        Else
            self:nFault       := 400
            self:nStatus      := 400
            self:cFaultDesc   := "Operação não pode ser realizada."
			If Empty(self:cFaultDetail)
                    self:cFaultDetail := "Registro já existe no banco."
                EndIf
            EndIf
        Endif

    FreeObj(oEntity)
    oEntity := Nil

Return self:lSuccess

Method procLotePost(oCmd) Class CenRequest

    Local nMinLimit     := 1
    Local nMaxLimit     := 100
    Local nRegistro     := 1
    Local nCount        := 0
    Local oEntity       := 0
    Local jAlreadyExists:= JsonObject():New()
    Local jErrors       := JsonObject():New()
    Local jSerialize    := AutJsonControl():New()
    Local jLoteResponse := JsonObject():New()
    Default oCmd := CenCmdPostClt():New(self:oCollection)

    self:oRespBody      := nil

    jSerialize:newArray(jLoteResponse, 'included')
    jSerialize:newArray(jLoteResponse, 'notIncluded')

    jSerialize:newArray(jAlreadyExists, self:cPropLote)
    jSerialize:setProp(jAlreadyExists, 'codeError', 400)
    jSerialize:setProp(jAlreadyExists, 'errorMessage', 'Beneficiário(s) Já existe(m).')

    jSerialize:newArray(jErrors, self:cPropLote)
    jSerialize:setProp(jErrors, 'codeError', 400)
    jSerialize:setProp(jErrors, 'errorMessage', 'Erro ao tentar inserir Beneficiário(s).')

    If self:lSuccess
        If ValType(self:jRequest) == "A"
            nCount := Len(self:jRequest)
            If nCount >= nMinLimit .AND. nCount <= nMaxLimit
                For nRegistro := 1 to nCount
                    self:prepFilter(self:jRequest[nRegistro])
                    self:applyFilter(SINGLE)
                    self:buscar(INSERT)
                    If self:lSuccess
                        If oCmd:execute()
                            If self:buscar(BUSCA)
                                oEntity := self:oCollection:getNext()
                                jSerialize:addObjtoProp(jLoteResponse, 'included', oEntity:serialize(self:oRespControl))
                                oEntity:destroy()
                            EndIf
                        Else
                            jSerialize:addObjtoProp(jErrors, self:cPropLote, self:jRequest[nRegistro])
                        EndIf
                    Else
                        jSerialize:addObjtoProp(jAlreadyExists, self:cPropLote, self:jRequest[nRegistro])
                    EndIf
                    self:oRespControl := Nil
                Next

                If len(jAlreadyExists["beneficiaries"]) >= 1
                    aAdd(jLoteResponse["notIncluded"], jAlreadyExists)
                EndIf
                If len(jErrors["beneficiaries"]) >= 1
                    aAdd(jLoteResponse["notIncluded"], jErrors)
                EndIf

                self:lSuccess  := .T.
                self:nStatus   := 200
                self:cResponse := jLoteResponse:toJson()

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
            self:cFaultDetail := "Operação só pode ser realizada em lote, informe um array de objetos válidos."
        EndIf
    EndIf

    FreeObj(oEntity)
    FreeObj(jLoteResponse)
    FreeObj(jSerialize)
    FreeObj(jAlreadyExists)
    FreeObj(jErrors)
    oEntity := Nil
    jLoteResponse := Nil
    jSerialize := Nil
    jAlreadyExists := Nil
    jErrors := Nil

Return self:lSuccess

Method procPut(oCmd) Class CenRequest

    Local nI := 1
    Local nJ := 1
    Local oEntity := nil
    Local aRelList := {}
    Local cJsonResp := ""
    Default oCmd := CenCmdPutClt():New(self:oCollection)

    aRelList := self:oCollection:initRelation()

    If self:lSuccess
        self:prepFilter()
        self:applyFilter(SINGLE)
        self:buscar(SINGLE)
        If self:lSuccess
            If self:oValidador:validate(self:oCollection)
                self:oCollection:mapDaoJson(self:jRequest)
                If oCmd:execute()
                    For nI:= 1 to Len(aRelList)
                        oCltRel := self:oCollection:getRelation(aRelList[nI][RELNAME])
                        If self:jRequest[aRelList[nI][RELNAME]] <> nil
                            For nJ:= 1 to Len(self:jRequest[aRelList[nI][RELNAME]])
                                oCltRel:mapFromJson(self:jRequest[aRelList[nI][RELNAME]][nJ])
                                If oCltRel:bscChaPrim()
                                    oCmd := CenCmdPutClt():New(oCltRel)
                                    oCmd:execute()
                                EndIf
                            Next
                        EndIf
                    Next
                    self:nStatus := 200
                    self:applyFilter(SINGLE)
                    If self:buscar(SINGLE)
                        nJ := 1
                        nQtdExpand := len(self:oCollection:oMapper:aExpand)
                        self:aExpand := Array(1,nQtdExpand)
                        For nJ := 1 to nQtdExpand
                            self:aExpand[nJ] := self:oCollection:oMapper:aExpand[nJ][RELNAME]
                        Next
                        oEntity := self:oCollection:getNext()
                        self:oRespBody := oEntity:serialize(self:oRespControl)
                        self:oRespBody := self:expand(self:oRespBody)
                        cJsonResp := self:oRespBody:toJson()
                    EndIf
                    self:cResponse := cJsonResp
                Else
                    self:lSuccess     := .F.
                    self:nFault       := 400
                    self:nStatus      := 400
                    self:cFaultDesc   := "Operação não pode ser realizada."
                    self:cFaultDetail := "Erro ao realizar update."
                EndIf
            EndIf
        Else
            self:nFault       := 404
            self:nStatus      := 404
            self:cFaultDesc   := "Operação não pode ser realizada."
            self:cFaultDetail := "Registro não encontrado."
        EndIf
    EndIf

    FreeObj(oEntity)
    oEntity := Nil

Return self:lSuccess

Method procDelete() Class CenRequest

    Local nI := 0
    Local aRelList := {}

    aRelList := self:oCollection:initRelation()

    If self:lSuccess
        self:oCollection:setKeyRelation()
        For nI := 1 to Len(aRelList)
            if aRelList[nI][COLLECTION]:getBehavior() == CASCADE
                self:oCollection:getRelation(aRelList[nI][RELNAME]):delRelation()
            EndIf
        Next
        If (self:oCollection:delete())
            self:nStatus := 204
            self:cResponse := ""
        Else
            self:nFault       := 400
            self:nStatus      := 400
            self:cFaultDesc   := "Operação não pode ser realizada."
            self:cFaultDetail := "Registro não existe no banco."
        EndIf
    Else
        self:nFault       := 404
        self:nStatus      := 404
        self:cFaultDesc   := "Operação não pode ser realizada."
        self:cFaultDetail := "Registro não existe no banco."
    EndIf

Return self:lSuccess

Method buildBody(oEntity) Class CenRequest
Return oEntity:serialize(self:oRespControl)