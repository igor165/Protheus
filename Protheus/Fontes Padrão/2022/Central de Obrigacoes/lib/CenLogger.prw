#INCLUDE "TOTVS.CH" 
#INCLUDE 'FWMVCDEF.CH'

#IFDEF lLinux
	#define CRLF Chr(13) + Chr(10)
#ELSE
	#define CRLF Chr(10)
#ENDIF

#DEFINE DATETIME "datetime"
#DEFINE LOGTYPE "logtype"
#DEFINE DEFNAMEFILE "Default_Log_Name"

#DEFINE KEY 1
#DEFINE VALUE 2

Class CenLogger
    Data cFileName
    Data cPath
    Data cLogType
    Data cMessage
    Data lLogLimit
    Data lAutoFlush
    Data lAssinc
    Data nLogLimit
    Data aLogs
    Data aFields
    Data oHMLog
    Data cDirMod
    Data cDate
    Data cExtension
    Data lDatabase
    Data cSeqReq

    Method New(cType,lAutoFlush) Constructor
    Method destroy()
    Method flush()
    Method cleaner()
    Method setMessage(cMessage)
    Method getMessage()
    Method formatHeader(cTime, cType)
    Method checkDir()
    Method frmSlash(cConteudo)
    Method addLine(cKey, cValue)
    Method addLog()
    Method count()
    Method logLimt()
    Method autoFlush()
    Method setLogLimit(nLogLimit)
    Method setAutoFlush(lAutoFlush)
    Method setDateTime()
    Method setValue(cCampo, cValue)
    Method formatType(cType)
    Method setLogType(cLogType)
    Method frmDesc(cDesc)
    Method getFileName()
    Method setFileName(cFileName)
    Method toSave()
    Method mudDir()
    Method getDirMod()    
    Method save()
    Method getFullPath()
    Method setDatabase()
    Method setAssinc()
EndClass

Method New(cType,lAutoFlush) Class CenLogger
    Default cType := "I"
    Default lAutoFlush := .T.
    self:oHMLog := THashMap():New()
    self:aLogs := {}
    self:aFields := {}
    self:lAssinc := .T.
    self:lAutoFlush := lAutoFlush
    self:cMessage := ""
    self:cDirMod := self:frmSlash( "\logpls\" )
    self:cDate := DtoS(Date())+"\"    
    self:cFileName := self:frmSlash(DEFNAMEFILE)
    self:cExtension := "log"
    self:oHMLog:set(LOGTYPE,self:formatType(cType))
    self:setLogLimit(10)
    self:setAutoFlush(.T.)
    self:checkDir()
    self:lDatabase := .T.
    self:cSeqReq    := ""
Return self

Method destroy() Class CenLogger
    self:flush()
    FreeObj(self:aFields)
    FreeObj(self:aLogs)
    FreeObj(self:oHMLog)
    self:aFields := nil
    self:aLogs := nil
    self:oHMLog := nil
Return

Method flush() Class CenLogger
    Local nI := 1
    Local nJ := 1
    Local aListValues := {}
    Local cTempTime := ""
    Local cTempType := ""
    Local cBody := ""
    Local aCenCltB5Q := {}
    Local oCenCltB5Q 

    For nI := 1 to Len(self:aLogs)
        oCenCltB5Q := CenCltB5Q():New()
        self:aLogs[nI]:get(DATETIME, @cTempTime)
        self:aLogs[nI]:get(LOGTYPE, @cTempType)
        self:aLogs[nI]:Del(DATETIME)
        self:aLogs[nI]:Del(LOGTYPE)

        self:aLogs[nI]:List(@aListValues)
        For nJ:= 1 to Len(aListValues)
            If aListValues[nJ][KEY] == "path"
                oCenCltB5Q:setValue("path",aListValues[nJ][VALUE]) /* B5Q_PATH */      
            EndIf
            If aListValues[nJ][KEY] = "entradaJson"
                oCenCltB5Q:setValue("entradaJson", aListValues[nJ][VALUE]) /* B5Q_JSONIN */      
            EndIf
            If aListValues[nJ][KEY] = "saidaJson"
                oCenCltB5Q:setValue("saidaJson", aListValues[nJ][VALUE]) /* B5Q_JSONOU */        
            EndIf
            If aListValues[nJ][KEY] = "verboRequisicao"
                oCenCltB5Q:setValue("verboRequisicao", aListValues[nJ][VALUE]) /* B5Q_VERBO */       
            EndIf
            cBody += self:frmDesc(aListValues[nJ][KEY])
            cBody += aListValues[nJ][VALUE] + CRLF
        Next
        aadd(aCenCltB5Q, oCenCltB5Q)
        self:setMessage(self:formatHeader(cTempTime,cTempType) + cBody)
        aListValues := {}
        oCenCltB5Q := nil
        cTempType := ""
        cHeader := ""
        cBody := ""
    Next
    self:toSave(aCenCltB5Q)
    self:cleaner()
Return

Method frmDesc(cDesc) Class CenLogger
Return StrTran(Alltrim(Upper(cDesc)), "_", " ") + ": "
 
Method cleaner() Class CenLogger
    FreeObj(self:aLogs)
    FreeObj(self:oHMLog)
    self:aLogs := nil
    self:aLogs := {}
    self:oHMLog := nil
    self:oHMLog := THashMap():New()
    self:cMessage := ""
    self:oHMLog:set(LOGTYPE,self:formatType("I"))
Return

Method setMessage(cMessage) Class CenLogger
    self:cMessage += cMessage
Return

Method getMessage() Class CenLogger
Return self:cMessage

Method formatHeader(cTime, cType) Class CenLogger
Return PADL("",20, "-") + " [" + cTime  + "] " + cType +" "+ PADL("",20, "-") + CRLF

Method checkDir() Class CenLogger
    //Se nao existe o diretorio de log's do modulo cria						 
    If !ExistDir(self:cDirMod+self:cDate)
    	If !ExistDir(self:cDirMod)
    		If MakeDir( self:cDirMod ) <> 0
    			self:cDirMod := ""
    		EndIf
    	EndIf
    	If !Empty(self:cDirMod)
    		self:cDirMod := self:frmSlash( self:cDirMod+self:cDate )
    		If MakeDir( self:cDirMod ) <> 0
    			self:cDirMod := ""
    		EndIf
    	EndIf
    else
    	self:cDirMod := self:frmSlash( self:cDirMod+self:cDate )
    endIf
Return

Method frmSlash(cConteudo) Class CenLogger
    If  !ISSRVUNIX()
    	cConteudo := StrTran(cConteudo,"/","\")
    Else
    	cConteudo := StrTran(cConteudo,"\","/")
    EndIf   
    cConteudo := lower(cConteudo)
Return cConteudo

Method addLine(cKey, cValue) Class CenLogger
    Default cKey := ""
    Default cValue := ""
    self:oHMLog:set(cKey, strtran(cValue,CRLF,""))
    self:setDateTime()
Return

Method addLog() Class CenLogger
    Local lMakeFlush := .F.
    
    aAdd(self:aLogs, self:oHMLog)
    self:oHMLog := THashMap():New()
    self:oHMLog:set(LOGTYPE,self:formatType("I"))
    lMakeFlush := self:lAutoFlush .AND. self:count() > self:nLogLimit
    
    If lMakeFlush
        self:flush()
    EndIf
Return .T.

Method count() Class CenLogger
Return len(self:aLogs)

Method logLimt() Class CenLogger
Return self:lLogLimit

Method autoFlush() Class CenLogger
Return self:lAutoFlush

Method setLogLimit(nLogLimit) Class CenLogger
    self:nLogLimit := nLogLimit
Return

Method setAutoFlush(lAutoFlush) Class CenLogger
    self:lAutoFlush := lAutoFlush
Return

Method setDateTime() Class CenLogger
    Local cDateTime := DTOS(Date()) + " " + Time()
    If !self:oHMLog:get(DATETIME)
        self:oHMLog:set(DATETIME, cDateTime)
    EndIf
Return

Method formatType(cType) Class CenLogger
    Local cTypeFomat := ""
    Default cType := "I"
    if cType == "E"
		cTypeFomat := "[ERRO]"
	ElseIf cType == "W"
		cTypeFomat := "[WARN]"
	Else
		cTypeFomat := "[INFO]"
	EndIf
Return cTypeFomat

Method setLogType(cLogType) Class CenLogger
    Default cLogType := ""
    self:setValue(LOGTYPE, self:formatType(cLogType))
Return 

Method getFileName() Class CenLogger
Return self:cFileName + "." + self:cExtension

Method setFileName(cFileName) Class CenLogger
    self:cFileName := cFileName
Return

Method setValue(cKey, cValue) Class CenLogger
    self:oHMLog:set(cKey, cValue)
Return 

Method getFullPath() Class CenLogger
return  self:getDirMod() + self:getFileName()

Method getDirMod() Class CenLogger
Return self:cDirMod

Method setDatabase(lDatabase) Class CenLogger
    self:lDatabase := lDatabase
Return 

Method setAssinc(lAssinc) Class CenLogger
    self:lAssinc := lAssinc
Return

Method save() Class CenLogger
    saveLogMsg(self:mudDir(), self:getDirMod(), self:getFileName(), self:getMessage())
Return

Method mudDir() Class CenLogger
return lMudDir := Iif(At(self:frmSlash("\"),self:frmSlash(self:getFileName()))>0,.F.,.T.)

Method toSave(aCenCltB5Q) Class CenLogger
    If self:lAssinc
        SmartJob("saveLogMsg", GetEnvServer(), .F., self:mudDir(), self:getDirMod(), self:getFileName(), self:getMessage())
    Else
        self:save()
    EndIf

    If self:lDatabase
        /*/ Method
        @author  vinicius.nicolau
        @since   20200302
        /*/
        // SmartJob ainda não implementado por conta do mesmo não aceitar Array e Objeto, deixando apenas a parte Sincrona do método.
        self:setAssinc(.F.)
        If self:lAssinc
            SmartJob("saveToDatabase", GetEnvServer(), .F., cEmpAnt, cFilAnt, aCenCltB5Q, self:getFileName(), self:cDate, self:lAssinc)
        Else
            saveToDatabase(cEmpAnt, cFilAnt, aCenCltB5Q, self:getFileName(), self:cDate, self:lAssinc)
        EndIf
    EndIf
Return

Function saveToDatabase(cEmp, cFil, aCenCltB5Q, cFileName, cDate, lAssinc)
    Local nI := 1
    Local lLogs := FWAliasInDic("B5Q", .F.) //verificar se aplicou o pacote de logs    
    Default aCenCltB5Q := {}
    Default cFileName := ""
    Default cDate := ""
    Default lAssinc := .F.
    Default cEmp := ""
    Default cFil := ""
    
    If lAssinc
		RpcSetType(3)
		RpcSetEnv(cEmp,cFil,,,'PLS')
	EndIf

    if lLogs
        For nI:= 1 to Len(aCenCltB5Q)
            aCenCltB5Q[nI]:setValue("errorDescription", cFileName) /*B5Q_DESCRI*/
            aCenCltB5Q[nI]:setValue("errorDate",STOD(cDate)) /*B5Q_DATA*/
            aCenCltB5Q[nI]:setValue("errorTime",Time()) /*B5Q_HORA*/
            aCenCltB5Q[nI]:setValue("idRequest", GetSX8Num("B5Q","B5Q_IDREQU")) /*B5Q_IDREQU*/

            If aCenCltB5Q[nI]:bscChaPrim()
                aCenCltB5Q[nI]:update()
            Else
                aCenCltB5Q[nI]:insert()
            EndIf
            aCenCltB5Q[nI]:destroy()
        Next
    endIf

    aCenCltB5Q := nil

Return

Function saveLogMsg(lMudDir, cDirMod,cFileName,cMessage)
    Local aBuffer := {}
    LOCAL nPos := 0
    LOCAL nHdlLog := 0
    LOCAL lBuffer := .F.
    LOCAL lQLinha := .T.

    //Nome do arquivo mais diretorio
    if lMudDir
    	cArqlog := cDirMod+cFileName
    EndIf
    
    nPos := aScan(aBuffer,{|x| allTrim(upper(x[1])) == allTrim(upper(cFileName))})
    if lBuffer
       if nPos > 0
          if len(aBuffer[nPos,2]) > 1000
             lBuffer := .F.
          EndIf
       EndIf
    EndIf

    if !lBuffer

        // if nPos > 0
        //     cDesLog := ""
        //     for nI := 1 to len(aBuffer[nPos,2])
        //         if lQLinha
	    //             cDesLog += aBuffer[nPos,2,nI]+ CRLF
	    //         Else
	    //             cDesLog += aBuffer[nPos,2,nI]
	    //         EndIf
   	    // 	    //verificar se a string esta maior que 1mb
   	    //  	    if len(cDesLog) > 1000000
	    // 	        if ! file(cArqLog)
	    // 	            if (nHdlLog := fCreate(cArqlog,0)) == -1
	    // 			    return
	    // 		    endIf
	    // 		    Else
	    // 			    if (nHdlLog := fOpen(cArqlog,2)) == -1
	    // 				   return
	    // 			    EndIf
	    // 		    EndIf
	    // 		    fSeek(nHdlLog,0,2)
        // 		    fWrite(nHdlLog,cDesLog)
	    // 		    fClose(nHdlLog)
   	    // 	  	    cDesLog := ''
   	    // 	    EndIf
        //     next
        //     cMessage := cDesLog + cMessage
        //     aBuffer[nPos,2]	:= {}
        // EndIf

        if !File(cArqLog)
            if (nHdlLog := fCreate(cArqlog,0)) == -1
	    	    return
	        EndIf
        Else
	        if (nHdlLog := fOpen(cArqlog,2)) == -1
	    	    return
	        EndIf
        EndIf

        fSeek(nHdlLog,0,2)

        if lQLinha
	        fWrite(nHdlLog, cMessage + chr(13) + chr(10))
        Else
	        fWrite(nHdlLog,cMessage)
        EndIf

        fClose(nHdlLog)
    Else
        if nPos > 0
            aadd(aBuffer[nPos,2],cMessage)
        Else
            aadd(aBuffer,{cFileName,{cMessage}})
        EndIf
    EndIf
Return