#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TBICONN.CH"

#DEFINE CRLF CHR(13)+CHR(10)

//-----------------------------------------------------------------
/*/{Protheus.doc} PlsRest
 Classe geral para comunicacoes via Rest
 
@author renan.almeida
@since 12/02/2019
@version 1.0
/*/
//-----------------------------------------------------------------
Class PlsRest

    Data aHeadParam as Array
    Data aQryParam as Array
    Data nMaxTry as Integer
    Data cCodOpe As String
    Data cEndPoint as String
    Data cJson as String
    Data cPath as String
    Data cRespJson as String
    Data lSucess as Boolean
    Data cError as String
    Data lGeraLog as Boolean
    Data cNameLog as String
    Data lAuto as Boolean
    Data lAutoSuc as Boolean
    Data cJsonResp as String
    Data cRespType as String
    Data cTextResp as String
    Data cCookieResp as String

    Method New()
    Method setHeadPar(cKey,cValue)
    Method setQryPar(cKey,cValue)
    Method setCodOpe(cCodOpe)
    Method setEndPoin(cEndPoint)
    Method setJson(cJson)
    Method SetJsonFormData(cKey, cValue)
    Method setPath(cPath)
    Method setSucess(lSucces)
    Method setResJson(cRespJson)
    Method setAuto(lAuto)
    Method setAutoSuc(lSuccess)
    Method setError(cError)
    Method setJsonRes(cJsonResp)
    Method comunPost()
    Method comunGet()
    Method resetAtrib()
    Method impLog(cMsg,lDateTime)
    Method setRespType(cType)
    Method setTextResp(cTextResp)
    Method setCookieResp(cCookieResp)
    Method setGeraLog(lGeraLog)
    Method setNameLog(cNameLog)
    Method getResJson()
    Method getSuccess()

EndClass


//-----------------------------------------------------------------
/*/{Protheus.doc} New
 Classe Construtora
 
@author renan.almeida
@since 12/02/2019
@version 1.0
/*/
//-----------------------------------------------------------------
Method New() Class PlsRest
    
    self:aHeadParam := {}
    self:aQryParam  := {}
    self:lSucess    := .F.
    self:nMaxTry    := 10
    self:cCodOpe    := ''
    self:cEndPoint  := ''
    self:cJson      := ''
    self:cPath      := ''
    self:cRespJson  := ''
    self:cError     := ''
    self:lGeraLog   := .F.
    self:cNameLog   := ''
    self:lAuto      := .F.
    self:lAutoSuc   := .T.
    self:cRespType  := 'json'
    self:cTextResp  := ''
    self:cCookieResp := ""

Return


//-----------------------------------------------------------------
/*/{Protheus.doc} Metodos Set
 Adiciona Paramentos do Header
 
@author renan.almeida
@since 12/02/2019
@version 1.0
/*/
//-----------------------------------------------------------------
Method setHeadPar(cKey,cValue) Class PlsRest
    aadd(self:aHeadParam,{cKey,cValue})
Return

Method setQryPar(cKey,cValue) Class PlsRest
    aadd(self:aQryParam,{cKey,cValue})
Return

Method setCodOpe(cCodOpe) Class PlsRest
    self:cCodOpe := cCodOpe
Return

Method setEndPoin(cEndPoint) Class PlsRest
    self:cEndPoint := cEndPoint
Return

Method setJson(cJson) Class PlsRest
    self:cJson := cJson
Return

Method SetJsonFormData(cKey, cValue, lEnd) Class PlsRest

    Local cParmsFormData := ""

    Default cKey := ""
    Default cValue := ""
    Default lEnd := .F.

    If !Empty(cKey) .And. !Empty(cValue)

        cParmsFormData += 'Content-Disposition: form-data; name="'+cKey+'"' + CRLF + CRLF
        cParmsFormData += cValue

        If !lEnd
            cParmsFormData += CRLF
        EndIf

        Self:cJson += cParmsFormData
    EndIf
Return

Method setPath(cPath) Class PlsRest
    self:cPath := cPath
Return

Method setError(cError) Class PlsRest
    self:cError := cError
Return

Method setSucess(lSucess) Class PlsRest
    self:lSucess := lSucess
Return

Method setResJson(cRespJson) Class PlsRest
    self:cRespJson := cRespJson
Return

Method setAuto(lAuto) Class PlsRest
    self:lAuto := lAuto
Return
    
Method setAutoSuc(lSuccess) Class PlsRest
    self:lAutoSuc := lSuccess
Return

Method setJsonRes(cJsonResp) Class PlsRest
    self:cJsonResp := cJsonResp
Return

Method setRespType(cType) Class PlsRest
    self:cRespType := cType
Return

Method setTextResp(cTextResp) Class PlsRest
    self:cTextResp := cTextResp
Return

Method setCookieResp(cCookieResp) Class PlsRest
    self:cCookieResp := cCookieResp
Return

Method setGeraLog(lGeraLog) Class PlsRest
    self:lGeraLog := lGeraLog
Return

Method setNameLog(cNameLog) Class PlsRest
    self:cNameLog := cNameLog
Return

Method getResJson() Class PlsRest
Return self:cRespJson

Method getSuccess() Class PlsRest
Return self:lSucess

//-----------------------------------------------------------------
/*/{Protheus.doc} comunPost
 Faz a comunicacao via Post
 
@author renan.almeida
@since 12/02/2019
@version 1.0
/*/
//-----------------------------------------------------------------
Method comunPost() Class PlsRest

    Local oRest      := nil
    Local oJsonResp  := nil
    Local cMsg       := ''
    Local nX         := 0
    Local nTry       := 0
    Local lOk        := .F.
    Local lSendAgain := .T.
    Local aHeader    := {}
    Local nPosCookie := 0

    //Monta Header
    for nX := 1 to len(self:aHeadParam)
        aAdd(aHeader,self:aHeadParam[nX,1]+": "+self:aHeadParam[nX,2])
    next

    //Monta Path e QueryParam
    for nX := 1 to len(self:aQryParam)
        self:cPath += iif(nX==1,'?','&')
        self:cPath += self:aQryParam[nX,1]+"="+self:aQryParam[nX,2]
    next

    while lSendAgain .and. nTry <= self:nMaxTry

        oRest := FWRest():New(self:cEndPoint)
        oRest:setPath(self:cPath)
        oRest:SetPostParams(self:cJson)

        //Log
        self:impLog('Realizando a comunicacao POST')
        self:impLog('URL: '+self:cEndPoint+self:cPath)
        self:impLog('JSON: '+self:cJson )

        //Realiza a comunicacao POST
        if !self:lAuto
            oRest:Post(aHeader)
        endIf

        //Comunicacao realizada com sucesso        
        if (self:lAuto .And. self:lAutoSuc) .Or. ;
            (empty(oRest:cInternalError) .and. (!empty(oRest:oResponseH:cStatusCode) .and. oRest:oResponseH:cStatusCode $ "200/201/202"))

            self:setResJson(iif(self:lAuto,self:cJsonResp,oRest:GetResult()))

            If Upper(self:cRespType) $ "TEXT"
                lOk := .T.
                lSendAgain := .F.
                self:setSucess(.T.)
                self:setTextResp(oRest:GetResult())
                self:impLog("Comunicacao realizada com sucesso.")
            Else
                oJsonResp := JsonParser():New()
                oJsonResp:setJson(self:cRespJson)
                hMap := oJsonResp:parseJson()
                hMap:get("success",@lOk)
                lSendAgain := .F.

                if lOk
                    self:setSucess(.T.)
                    self:impLog("Comunicacao realizada com sucesso.")
                    self:impLog("Json resposta: "+self:cRespJson)
                else
                    hMap:get("msgError",@cMsg)
                    self:setError("Erro na comunicacao: "+cMsg)
                    self:impLog(self:cError)
                endIf
            Endif 

            // Pega o Cookie da Resposta quando houver
            If lOk .And. Len(oRest:oResponseH:aHeaderFields) > 0
                nPosCookie := AScan(oRest:oResponseH:aHeaderFields, {|x| Upper(AllTrim(x[1])) == "SET-COOKIE"})
                If nPosCookie > 0
                    self:cCookieResp := oRest:oResponseH:aHeaderFields[nPosCookie][2]
                EndIf
            EndIf
            
        //Erro interno ou url incorreta
        elseIf (self:lAuto .And. !self:lAutoSuc) .Or. ;
            empty(oRest:cInternalError) .and. (valtype(oRest:oResponseH:cStatusCode) == "C" .and. oRest:oResponseH:cStatusCode $ "404/400")
            
            lSendAgain := .F.
            self:setResJson(iif(self:lAuto,self:cJsonResp,oRest:GetResult()))
            self:setError("Ocorreu um erro ao realizar a comunicacao. Json resposta: "+self:cRespJson)
            self:impLog(self:cError)
     
        //Nao obteve resposta, vou realizar a comunicacao novamente
        else
        
            lSendAgain := .T.
            nTry++
            self:impLog("COMUNICACAO FALHOU. Realizando nova tentativa (" + cValtoChar(nTry) + ")")
            sleep(500)   
          
        endIf    
        oRest := nil
        
    endDo

    if nTry > self:nMaxTry
        self:setError("Não foi possivel realizar a comunicacao.")
    endIf

Return


//-----------------------------------------------------------------
/*/{Protheus.doc} comunGet
 Faz a comunicacao via Get
 
@author renan.almeida
@since 12/02/2019
@version 1.0
/*/
//-----------------------------------------------------------------
Method comunGet() Class PlsRest

    Local oRest      := nil
    Local oJsonResp  := nil
    Local cMsg       := ''
    Local nX         := 0
    Local nTry       := 0
    Local lOk        := .F.
    Local lSendAgain := .T.
    Local aHeader    := {}
    Local nPosCookie := 0

    //Monta Header
    for nX := 1 to len(self:aHeadParam)
        aAdd(aHeader,self:aHeadParam[nX,1]+": "+self:aHeadParam[nX,2])
    next

    //Monta Path e QueryParam
    for nX := 1 to len(self:aQryParam)
        self:cPath += iif(nX==1,'?','&')
        self:cPath += self:aQryParam[nX,1]+"="+self:aQryParam[nX,2]
    next

    while lSendAgain .and. nTry <= self:nMaxTry

        oRest := FWRest():New(self:cEndPoint)
        oRest:setPath(self:cPath)

        //Log
        self:impLog('Realizando a comunicacao GET')
        self:impLog('URL: '+self:cEndPoint+self:cPath)

        //Realiza a comunicacao GET
        if !self:lAuto
            oRest:Get(aHeader)
        endIf

        //Comunicacao realizada com sucesso        
        if (self:lAuto .And. self:lAutoSuc) .Or. ;
            (empty(oRest:cInternalError) .and. (!empty(oRest:oResponseH:cStatusCode) .and. oRest:oResponseH:cStatusCode $ "200/201/202"))

            self:setResJson(iif(self:lAuto,self:cJsonResp,oRest:GetResult()))

            If Upper(self:cRespType) $ "TEXT"
                lOk := .T.
                lSendAgain := .F.
                self:setSucess(.T.)
                self:setTextResp(oRest:GetResult())
                self:impLog("Comunicacao realizada com sucesso.")
            Else
                oJsonResp := JsonParser():New()
                oJsonResp:setJson(self:cRespJson)
                hMap := oJsonResp:parseJson()
                hMap:get("success",@lOk)
                lSendAgain := .F.

                if lOk
                    self:setSucess(.T.)
                    self:impLog("Comunicacao realizada com sucesso.")
                    self:impLog("Json resposta: "+self:cRespJson)
                else
                    hMap:get("msgError",@cMsg)
                    self:setError("Erro na comunicacao: "+cMsg)
                    self:impLog(self:cError)
                endIf
            Endif 

            // Pega o Cookie da Resposta quando houver
            If lOk .And. Len(oRest:oResponseH:aHeaderFields) > 0
                nPosCookie := AScan(oRest:oResponseH:aHeaderFields, {|x| Upper(AllTrim(x[1])) == "SET-COOKIE"})
                If nPosCookie > 0
                    self:cCookieResp := oRest:oResponseH:aHeaderFields[nPosCookie][2]
                EndIf
            EndIf
            
        //Erro interno ou url incorreta
        elseIf (self:lAuto .And. !self:lAutoSuc) .Or. ;
            empty(oRest:cInternalError) .and. (valtype(oRest:oResponseH:cStatusCode) == "C" .and. oRest:oResponseH:cStatusCode $ "404/400")
            
            lSendAgain := .F.
            self:setResJson(iif(self:lAuto,self:cJsonResp,oRest:GetResult()))
            self:setError("Ocorreu um erro ao realizar a comunicacao. Json resposta: "+self:cRespJson)
            self:impLog(self:cError)

        //Nao obteve resposta, vou realizar a comunicacao novamente
        else
        
            lSendAgain := .T.
            nTry++
            self:impLog("COMUNICACAO FALHOU. Realizando nova tentativa (" + cValtoChar(nTry) + ")")
            sleep(500)   
          
        endIf    
        oRest := nil
        
    endDo

    if nTry > self:nMaxTry
        self:setError("Não foi possivel realizar a comunicacao.")
    endIf

Return

//-----------------------------------------------------------------
/*/{Protheus.doc} resetAtrib
 Reseta atributos da classe (exceto codigo da operadora)
 
@author renan.almeida
@since 12/02/2019
@version 1.0
/*/
//-----------------------------------------------------------------
Method resetAtrib() Class PlsRest

    self:aHeadParam := {}
    self:aQryParam  := {}
    self:nMaxTry    := 10
    self:lSucess    := .F.
    self:cEndPoint  := '' 
    self:cJson      := ''
    self:cPath      := ''
    self:cRespJson  := ''
    self:cError     := ''
    self:lGeraLog   := .F.
    self:cNameLog   := ''
    self:cRespType  := 'json'
    self:cTextResp  := ''
    self:cCookieResp := ""

Return

//-----------------------------------------------------------------
/*/{Protheus.doc} impLog
 Imprime log
 
@author renan.almeida
@since 12/02/2019 
@version 1.0
/*/
//-----------------------------------------------------------------
Method impLog(cMsg,lDateTime) Class PlsRest

    Local cDateTime := Substr(DTOS(Date()),7,2)+"/"+Substr(DTOS(Date()),5,2)+"/"+Substr(DTOS(Date()),1,4) + "-" + Time()
    Default cMsg    := ''
    Default lDateTime := .T.

    if self:lGeraLog .And. !empty(self:cNameLog)
        if lDateTime
            PlsPtuLog("["+cDateTime+"] " + cMsg, self:cNameLog)
        else
            PlsPtuLog(cMsg, self:cNameLog)
        endIf    
    endIf

Return
