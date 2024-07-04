#INCLUDE "TOTVS.CH"
#DEFINE JOB_PROCES "1"
#DEFINE JOB_AGUARD "2"
#DEFINE JOB_CONCLU "3"

#DEFINE OBR_DMED  "4"
#DEFINE OBR_MONIT "5"

#DEFINE LOGTYPE "logtype"


/*/{Protheus.doc}
    Servico que retorna o processamento da identficacao do beneficiario
    @type  Class
    @author everton.mateus
    @since 31/01/2018
/*/
Class Service
    Data cFila
    Data cJob
    Data cCodOpe
    Data oFila
    Data oProc
    Data lJob
    Data nTry
    Data dData
    Data cHora
    Data cObs
    Data oCenLogger
    Data cCodObri
    Data cAnoComp
    Data cCodComp
    Data cTrirec

    Method New() CONSTRUCTOR
    Method destroy()
    Method setProcId(cProcId)
    Method setCodOpe(cCodOpe)
    Method run()
    Method beforeProc(cObr)
    Method temCompromisso()
    Method logMsg(cLevel, cMsg, cStatus,lDmed)
    Method procNextMsg()
    Method runProc(oObj)
    Method keepProc()
    Method AbreSemaforo()
    Method FechaSemaforo()
    Method CheckSemaforo()

EndClass

Method New() Class Service
    self:cFila := ""
    self:cJob := ""
    self:lJob := .T.
    self:oFila := nil
    self:oProc := nil
    self:nTry := 0
    self:dData := Date()
    self:cHora := Time()
    self:cCodOpe := ""
    self:cObs := ""
    self:oCenLogger := CenLogger():New()
    self:cCodObri := ""
    self:cAnoComp := ""
    self:cCodComp := ""
    self:cTrirec := ""
Return self

Method destroy() Class Service
    if self:oCenLogger <> nil
        self:oCenLogger:destroy()
        FreeObj(self:oCenLogger)
        self:oCenLogger := Nil
    EndIf
Return

Method setProcId(cProcId) Class Service
    self:oFila:setProcId(cProcId)
Return

Method setCodOpe(cCodOpe) Class Service
    self:cCodOpe := cCodOpe
Return

Method run(lTeste) Class Service
    Local cCodOpe := MV_PAR01
    Default lTeste := .F.
    If Self:AbreSemaforo()

        StartJob(self:cJob, GetEnvServer(), .F., cEmpAnt, cFilAnt, .T., cCodOpe )
        Self:FechaSemaforo()

    endIf
return

Method beforeProc(cObr) Class Service
    Local lRet  := .F.
    Default cObr:=OBR_MONIT

    lRet := self:temCompromisso(cObr)
    If lRet .AND. self:oFila <> nil
        self:oFila:setCodOpe(self:cCodOpe)
        lRet := self:oFila:checkQueue() .And. self:oFila:setupQueue()
    EndIf
return lRet

Method temCompromisso(cObr) Class Service
    Local oCltComp := CenCltComp():New()
    Local lRet := .T.
    Default cObr :=OBR_MONIT

    oCltComp:setValue("operatorRecord", self:cCodOpe)
    If cObr == "4"
        lRet := oCltComp:bscCmpDmAtiv()
    Else
        lRet := oCltComp:bscCmpMonAtiv()
    EndIf
    If lRet .AND. oCltComp:hasNext()
        oComp := oCltComp:getNext()
        self:cCodObri := oComp:getValue("B3D_CDOBRI")
        self:cAnoComp := oComp:getValue("B3D_ANO")
        self:cCodComp := oComp:getValue("B3D_CODIGO")
        self:cCodOpe  := oComp:getValue("B3D_CODOPE")
        oComp:destroy()
    Else
        If cObr == "4"
            self:logMsg("E","Não conseguiu encontrar um compromisso da DMED cadastrado.")
        Else
            self:logMsg("E","Não conseguiu encontrar um compromisso do Monitoramento TISS cadastrado.")
        EndIf
    EndIf

    oCltComp:destroy()
    FreeObj(oCltComp)
    oCltComp := nil
Return lRet

Method logMsg(cLevel, cMsg, cStatus,lDmed) Class Service
    Local cTipo := OBR_MONIT
    Local cNomJob := self:cJob
    Local cDescr := self:cObs
    Local cDatExe := DtoS(self:dData)
    Local cHorExe := self:cHora
    Local aJOBs := {}
    Local cTrirec := ''
    Default cMsg := self:cObs
    Default cStatus := JOB_PROCES
    Default lDmed   := .F.

    If lDmed .Or. "DMED" $ upper(cNomJob)
        cTipo := OBR_DMED
    EndIf

    self:oCenLogger:setLogType(LOGTYPE, cLevel)
    self:oCenLogger:addLine("mensagem", "Thread["+AllTrim(Str(ThreadId()))+"]" + cMsg)
    self:oCenLogger:addLog()
    self:oCenLogger:flush()

    conout("Thread["+AllTrim(Str(ThreadId()))+"]" + cMsg)
    CENMANTB3V(self:cCodOpe,self:cCodObri,self:cAnoComp,self:cCodComp,cTrirec,cTipo,cNomJob,cDescr,cMsg,cDatExe,cHorExe,cStatus,aJOBs)
Return

Method procNextMsg() Class Service
    self:logMsg("","vai buscar novo registro pra processar")
    If self:oFila:getMsg()
        self:logMsg("","achou um registro")
        oObj := self:oFila:getNext()
        If oObj != nil

            If !Empty(oObj:getValue("operatorRecord"))
                self:cCodOpe := oObj:getValue("operatorRecord")
            EndIf
            If !Empty(oObj:getValue("requirementCode"))
                self:cCodObri := oObj:getValue("requirementCode")
            EndIf
            If !Empty(oObj:getValue("referenceYear"))
                self:cAnoComp := oObj:getValue("referenceYear")
            EndIf
            If !Empty(oObj:getValue("commitmentCode"))
                self:cCodComp := oObj:getValue("commitmentCode")
            EndIf

            self:oProc:setOper(oObj:getValue("operatorRecord"))
            self:oProc:setObrig(oObj:getValue("requirementCode"))
            self:oProc:setAno(oObj:getValue("referenceYear"))
            self:oProc:setComp(oObj:getValue("commitmentCode"))
            self:runProc(oObj)
            self:oFila:setEndProc()
            self:logMsg("W","processou")
        EndIf
        self:nTry := 0
    Else
        self:logMsg("W","aguardando...")
        sleep(5000)
        self:nTry++
    EndIf
Return

Method runProc(oObj) Class Service
Return

Method keepProc() Class Service
Return self:nTry <= 0

Method AbreSemaforo() Class Service
Return LockByName(Self:cFila + ".lck", .T., .T.)

Method FechaSemaforo() Class Service
Return unLockByName(Self:cFila + ".lck", .T., .T.)

Method CheckSemaforo() Class Service
    Local lSuccess := self:AbreSemaforo()

    If lSuccess
        self:FechaSemaforo()
    endif

Return lSuccess