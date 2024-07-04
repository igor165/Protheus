#INCLUDE "TOTVS.CH"
//#INCLUDE "autorizadorRest.CH"

/*/{Protheus.doc} AutRestObj
    Classe abstrata que controla o corpo dos endpoints dos servicos rest do autorizador
    @type  Class
    @author victor.silva
    @since 20180427
/*/
Class AutRestObj 
	
    Data cSvcName
    Data cResponse
    Data lSuccess
    Data nFault
    Data nStatus
    Data cFaultDesc
    Data cFaultDetail
    Data nMediaType
    Data oRest
    Data oReqBody
    Data oRespBody
    Data oRespControl
    Data oService
    Data oDao
    Data oBuscador
    Data oJson
    Data oCenLogger
    
    Method New(oRest) Constructor
    Method checkAuth()
    Method applyFields()
    Method applyPageSize()
    Method applyExpandables()
    Method setMediaType()
    Method pushFila()
    Method popLista()
    Method checkBody()
    Method checkAgreement()
    Method getSuccess()
    
    Method initRequest()
    Method endRequest()
    Method serializeFault()

    Method destroy()
    
EndClass

Method New(oRest, cSvcName) Class AutRestObj
    self:oRest        := oRest
    self:cSvcName     := cSvcName
    self:lSuccess     := .T.
    self:nStatus      := 200
    self:oReqBody     := JsonObject():New()
    self:oRespBody    := JsonObject():New()
    self:oRespControl := AutJsonControl():New()
    self:oCenLogger := CenLogger():New()
    // self:oCenLogger:setAssinc(.F.)
    self:oCenLogger:setFileName("arquivo_de_log")
Return self

/*/{Protheus.doc} checkAuth
Valida as informacoes de autenticacao do usuario com as informacoes do header da requisicao
@author  victor.silva
@since   20180518
/*/
Method checkAuth() Class AutRestObj
    // TODO - IMPLEMENTAR LEITURA DO HEADER COM A AUTENTICACAO DO USUARIO
    // self:oRest:getHeader()
    // VarInfo("REST",ClassMethArr(self:oRest,.T.))
Return self:lSuccess

Method applyFields() Class AutRestObj
    self:oRespControl:prepFields(self:oRest:fields)
Return

/*/{Protheus.doc} applyPageSize
Aplica o tamanho da pagina para paginas do tipo colecao
@author  victor.silva
@since   20180523
/*/
Method applyPageSize() Class AutRestObj
    
    self:oDao:setNumPage(self:oRest:page)
    self:oDao:setPageSize(self:oRest:pageSize)
    
    self:oRespBody["hasNext"] := .F.
    self:oRespBody["items"] := {}

Return self:lSuccess

/*/{Protheus.doc} applyExpandables
Expande os dados compostos do objeto
@author  victor.silva
@since   20180312
/*/
Method applyExpandables() Class AutRestObj
    if self:lSuccess
        self:oRespControl:prepExpand(self:oRest:expand)
    endif
Return

Method setMediaType(nMediaType) Class AutRestObj
    self:nMediaType := nMediaType
Return self:lSuccess

/*/{Protheus.doc} pushFila
Adiciona uma mensagem na fila de processamento
@author  victor.silva
@since   20180518
/*/
Method pushFila() Class AutRestObj

    Local oJObjContent := JsonObject():New()
    Local oJObjParams  := JsonObject():New()
    Local oJObjMsg     := JsonObject():New()
    Local cToken       := ""

    oJObjContent:fromJson(self:oRest:getContent())
    oJObjParams:fromJson(ArrToJson(self:oRest:aQueryString))

    oJObjMsg["message"] := oJObjContent
    oJObjMsg["params"]  := oJObjParams

    // TODO - SYSLOG RFC-5424
    if self:oService:pushFila(oJObjMsg:toJson(),@cToken)
        self:oRespBody['serviceResponse'] := !Empty(cToken)
        self:oRespBody['avrgTime'] := 1000
        self:oRespBody['tokenProcess'] := cToken
        self:cResponse := self:oRespBody:toJson()
        self:lSuccess   := .T.
    else
        self:nFault     := 500
        self:cFaultDesc := self:oService:getFault()
        self:lSuccess   := .F.
    endif

    FreeObj(oJObjContent)
    oJObjContent := Nil

    FreeObj(oJObjParams)
    oJObjParams := Nil

    FreeObj(oJObjMsg)
    oJObjMsg := Nil

Return self:lSuccess

/*/{Protheus.doc} popLista
Recupera uma resposta da Lista de mensagens processadas pelos microservices
a partir do token gerado no momento da inclusao na Fila
@author  victor.silva
@since   20180518
/*/
Method popLista(cToken) Class AutRestObj
    Local cMsg  := ""

    // TODO - SYSLOG RFC-5424
    if self:oService:popLista(cToken,@cMsg)
        self:cResponse  := cMsg
        self:nStatus    := self:oService:getStatus()
        self:lSuccess   := .T.
    else
        self:cFault := self:oService:getFault()[1]
        self:cFaultDesc := self:oService:getFault()[2]
        self:lSuccess   := .F.
    EndIf

Return self:lSuccess

/*/{Protheus.doc} checkBody
Realiza o parser do JSon enviado pelo client
@author  victor.silva
@since   20180518
/*/
Method checkBody() Class AutRestObj
    Local cParseError := ""

    // TODO - SYSLOG RFC-5424
    self:oReqBody := JsonObject():New()
    cParseError := self:oReqBody:fromJson(self:oRest:getContent())

    if empty(cParseError)
        self:lSuccess   := .T.
    else
        self:nFault     := 404
        self:cFaultDesc := cParseError
        self:lSuccess   := .F.
    endif

Return self:lSuccess

Method getSuccess() Class AutRestObj
Return .T.

/*/{Protheus.doc} endRequest
Inicializa a solicitacao
@author  victor.silva
@since   20180518
/*/
Method initRequest() Class AutRestObj
    // TODO - SYSLOG RFC-5424 
    self:oCenLogger:addLine("verboRequisicao", self:oRest:getMethod())
    self:oCenLogger:addLine("path", self:oRest:getPath())
    if self:oRest:getContent() <> nil
        self:oCenLogger:addLine("entradaJson", StrTran(StrTran(self:oRest:getContent(),char(13),""),char(10),""))
    endif
    self:oCenLogger:addLog()
Return

/*/{Protheus.doc} endRequest

Finaliza a solicitacao e coloca a resposta e status na requisicao
@author  victor.silva
@since   20180518
/*/
Method endRequest() Class AutRestObj
    Local cResponse := ""
    if self:lSuccess
        self:oRest:setStatus(self:nStatus,"")
        cResponse := EncodeUTF8(self:cResponse)
        self:oRest:setResponse(cResponse)
    else
        self:oRest:setStatus(self:nStatus,"")
        cResponse := EncodeUTF8(self:serializeFault())
        self:oRest:setResponse(cResponse)
        // TODO - AutSysLog: dinamizar o tenantId quando prepararmos a aplicação para trabalhar com tenant
        //AutSysLog(ProcName(), RESTAPI, INFORMATIONAL, 1, self:cMsgId, "[tenantId=1]", {"Finalizando requisição com erro: " + cResponse })
    endif
    
    If self:oRest:GetMethod() != "GET"
        self:oCenLogger:addLine("path", self:oRest:getPath())
        self:oCenLogger:addLine("saidaJson", cResponse)    
        self:oCenLogger:addLog()
        self:oCenLogger:flush()
    EndIf
Return

/*/{Protheus.doc} serializeFault
Serializa retorno de falha do WSREST
@author  victor.silva
@since   20180704
/*/
Method serializeFault() Class AutRestObj

    self:oJson := JsonObject():New()

    self:oJson["code"] := self:nFault
    self:oJson["message"] := self:cFaultDesc
    self:oJson["detailedMessage"] := self:cFaultDetail
    self:oJson["helpUrl"] := ""
    self:oJson["details"] := {}
    aAdd(self:oJson["details"], JsonObject():New())
    self:oJson["details"][1]["code"] := ""
    self:oJson["details"][1]["message"] := ""
    self:oJson["details"][1]["detailedMessage"] := ""
    self:oJson["details"][1]["helpUrl"] := ""

Return self:oJson:toJson()

/*/{Protheus.doc} destroy
Limpa os objetos auxiliares
@author  victor.silva
@since   20180518
/*/
Method destroy() Class AutRestObj
    
    if !empty(self:oService)
        self:oService:destroy()
        FreeObj(self:oService)
        self:oService := nil
    endif

    if self:oReqBody <> Nil
        FreeObj(self:oReqBody)
        self:oReqBody := Nil
    EndIf

    if self:oRespBody <> Nil
        FreeObj(self:oRespBody)
        self:oRespBody := Nil
    EndIf

    if self:oRespControl <> Nil
        FreeObj(self:oRespControl)
        self:oRespControl := Nil
    EndIf

    if self:oDao <> Nil
        FreeObj(self:oDao)
        self:oDao := Nil
    EndIf

    if self:oBuscador <> Nil
        self:oBuscador:destroy()
        FreeObj(self:oBuscador)
        self:oBuscador := Nil
    EndIf

    if self:oCenLogger <> Nil
        self:oCenLogger:destroy()
        FreeObj(self:oCenLogger)
        self:oCenLogger := Nil
    EndIf

    DelClassIntf()

Return

Method checkAgreement() class AutRestObj
Return .T.  