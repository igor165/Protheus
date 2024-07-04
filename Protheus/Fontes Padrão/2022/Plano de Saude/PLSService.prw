#INCLUDE "TOTVS.CH"
#DEFINE JOB_PROCES "1"
#DEFINE JOB_AGUARD "2"
#DEFINE JOB_CONCLU "3"

#DEFINE LOGTYPE "logtype"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSService
Classe de servico de comunicacao da integracao PLS > HAT

@author  Renan Sakai
@version P12
@since    24.02.21
/*/
//-------------------------------------------------------------------
Class PLSService

    Data oFila
    Data oProc 
    Data cCodOpe As String
    Data lJob As Boolean
    Data nTry As Integer
    Data cLogFile As String
    Data cAlias As String
    Data lLogServ As Boolean

    Method New() CONSTRUCTOR
    Method setProcId(cProcId)
    Method setCodOpe(cCodOpe)
    Method beforeProc()
    Method procNextMsg()
    Method runProc(oObj)
    Method keepProc()
    Method logMsg(cMsg)
    Method getTimeLog()

EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} New
Construtor

@author  Renan Sakai
@version P12
@since    24.02.21
/*/
//-------------------------------------------------------------------
Method New() Class PLSService

    self:lJob     := .T.
    self:oFila    := nil
    self:oProc    := nil
    self:nTry     := 0
    self:cCodOpe  := ""
    self:cLogFile := ""
    self:cAlias   := ""
    self:lLogServ := GetNewPar("MV_PSVCLOG","0") == "1"

Return self

//-------------------------------------------------------------------
/*/{Protheus.doc} setProcId

@author  Renan Sakai
@version P12
@since    24.02.21
/*/
//-------------------------------------------------------------------
Method setProcId(cProcId) Class PLSService
    self:oFila:setProcId(cProcId)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} setCodOpe

@author  Renan Sakai
@version P12
@since    24.02.21
/*/
//-------------------------------------------------------------------
Method setCodOpe(cCodOpe) Class PLSService
    self:cCodOpe := cCodOpe
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} beforeProc

@author  Renan Sakai
@version P12
@since    24.02.21
/*/
//-------------------------------------------------------------------
Method beforeProc() Class PLSService

    Local lRet  := .F.

    if self:oFila <> nil
        self:oFila:setCodOpe(self:cCodOpe)
        lRet := self:oFila:checkQueue() .And. self:oFila:setupQueue()
    endIf

return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} procNextMsg

@author  Renan Sakai
@version P12
@since    24.02.21
/*/
//-------------------------------------------------------------------
Method procNextMsg() Class PLSService

    self:logMsg("Procurando registro "+self:cAlias+" para processar")
    
    if self:oFila:getMsg()
    
        self:logMsg("--> Iniciando processamento registro "+self:cAlias)
        oObj := self:oFila:getNext()
        If oObj != nil
            self:runProc(oObj)
            self:oFila:setEndProc()
            self:logMsg("--> Finalizando processamento registro "+self:cAlias)
        EndIf
        self:nTry := 0
    else
        self:logMsg("Registro "+self:cAlias+" nao encontrado para processamento, aguardando 5 segundos")
        sleep(5000)
        self:nTry++
    endIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} runProc

@author  Renan Sakai
@version P12
@since    24.02.21
/*/
//-------------------------------------------------------------------
Method runProc(oObj) Class PLSService
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} keepProc

@author  Renan Sakai
@version P12
@since    24.02.21
/*/
//-------------------------------------------------------------------
Method keepProc() Class PLSService
Return self:nTry <= 0


//-------------------------------------------------------------------
/*/{Protheus.doc} logMsg

@author  Renan Sakai
@version P12
@since    24.02.21
/*/
//-------------------------------------------------------------------
Method logMsg(cMsg) Class PLSService

    Local cCharCSV  := ";"
	Default cMsg    := ""
	
	if self:lLogServ
        PlsPtuLog(AllTrim(Str(ThreadID())) +cCharCSV+;
                  self:getTimeLog()+cCharCSV+;
                  cMsg, ;
                  self:cLogFile)
    endIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} getTimeLog
Loga os 

@author  Renan Sakai
@version P12
@since    26.10.18
/*/
//-------------------------------------------------------------------
Method getTimeLog() Class PLSService

    Local nHH, nMM , nSS, nMS := seconds()

    nHH := int(nMS/3600)
    nMS -= (nHH*3600)
    nMM := int(nMS/60)
    nMS -= (nMM*60)
    nSS := int(nMS)
    nMS := (nMs - nSS)*1000

Return strzero(nHH,2)+":"+strzero(nMM,2)+":"+strzero(nSS,2)+"."+strzero(nMS,3)