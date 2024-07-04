#INCLUDE "TOTVS.CH"
#INCLUDE "PLSMGER.CH"
#INCLUDE "Fileio.ch"
#INCLUDE "MsOle.ch"
#INCLUDE "PLMensCont.CH"
#DEFINE TOKEN_AUTO 'PLS123456789'
#DEFINE CRYPTKEY 'B8T127CO13' 


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLMensCont
    Classe abstrata para mensageria PLS x HAT
    @type  Class
    @author renan.almeida
    @since 20190320

    Type: 1 - Auditor
          2 - Prestador

    Status: 1 - Pend. Auditor
            2 - Pend. Prestador
            3 - Finalizado
/*/
//------------------------------------------------------------------------------------------
Class PLMensCont From PLSRest

    Data cRoomKey as String
    Data cRoomId as String
    Data cGetMsg as String
    Data oMessages as Object
    Data oAttach as Object
    Data cCodeError as String
    Data cCreatTime as String
    Data cStatus as String
    Data cUpFolder as String    
    Data cEndPoint as String
    //Atributos para conexao via client oAuth2
    Data cURLRac as String
    Data cUserName as String
    Data cPassword as String
    Data cClientId as String
    Data cClientSec as String
    Data cToken as String
    Data nTimeExp as Integer
    Data nMinuteExp as Integer
    Data cMsgEndRoom as String
    Data lAnalyzed as Boolean
    //Atributos para conexao via MasterToken
    Data cAuthToken as String
    Data cIdTenant as String
    Data cTenantName as String
    Data lTokConfig as Boolean
    //Atributos automacao
    Data cJsonTokenAuto as String
    Data cFilUpAuto as String

    Public Method New()

    //Get Set
    Method setRoomKey(cRoomKey)
    Method setRoomId(cRoomId)
    Method setStatus(cStatus)
    Method setCreaTim(cCreatTime)
    Method setStatB53(cChave,cStatus)
    Method getRoomKey()
    Method getRoomId()
    Method getMessages()
    Method getCodeErr()
    Method getCreaTim()
    Method getStatus()
    Method getMsgEnd()
    Method getFileName(cFile)
    Method getDataMask(cData)
    Method getAnalyzed()

    //Metodos Gerais
    Method prGetRoom()
    Method prPostRoom()
    Method prGetMsg()
    Method prPostMsg(cMessage,nStatus)
    Method prGetAttach()
    Method prPostAttach(cFileName,cId)
    Method setAttach(cIdMsg)
    Method getAttach(cIdMsg)
    Method getRoomSch(nPage)
    Method strTranMsg(cStr)
    Method uploadFile()
    Method downFile(aAnexList,nAtFile,lAllFiles)
    Method destroy()
    Method procSchedule()
    Method prepHeader()
    Method cryptKey(cKey)
    Method decryptKey(cKey)
    Method vldDadAces()
    Method ajustChar(cURI)

    //Metodos Automacao
    Method setJsnTkAut()
    Method setFilUpAut(cFilUpAuto)

    Method reset()

EndClass


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} New
    Metodo construtor da classe PLMensCont
    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method New() Class PLMensCont

    _Super:new()

    self:nMaxTry      := 1
    self:oMessages    := JsonObject():New()
    self:oAttach      := HMNew()
    self:cRoomKey     := ""
    self:cRoomId      := ""
    self:cGetMsg      := ""
    self:cCodeError   := ""
    self:cStatus      := ""
    self:lGeraLog     := .T.
    self:cNameLog     := "plsmensag.log"
    self:cCreatTime   := ""
    self:cUpFolder    := "\mensageriapls"
    self:cToken       := ""
    self:nMinuteExp   := 18 //Dois minutos antes da expiracao
    self:nTimeExp     := 0
    self:lAnalyzed    := iif(B53->B53_SITUAC == "1",.T.,.F.)

    if PLSALIASEXI("B7G")
        B7G->(DbSetOrder(1)) //B7G_FILIAL+B7G_CODOPE
        if B7G->(DbSeek(xFilial("B7G")+PlsIntPad()))
            self:cEndPoint     := Alltrim(B7G->B7G_MSURLM)
            self:cURLRac       := Alltrim(B7G->B7G_MSURLR)
            self:cEndPoint     += iif(Substr(self:cEndPoint,len(self:cEndPoint),1) == "/","","/")
            self:cURLRac       += iif(Substr(self:cURLRac,len(self:cURLRac),1) == "/","","/")

            self:cUserName     := self:ajustChar(Alltrim(B7G->B7G_MSUSER))
            self:cPassword     := self:ajustChar(self:decryptKey(Alltrim(B7G->B7G_MSPASS)))
            self:cClientId     := self:ajustChar(Alltrim(B7G->B7G_MSCLID))
            self:cClientSec    := self:ajustChar(Alltrim(B7G->B7G_MSCSEC))
            self:cMsgEndRoom   := iif(Empty(B7G->B7G_MSMSGF),STR0001,B7G->B7G_MSMSGF) //"Sala encerrada com o termino da analise de auditoria."
        endIf
    endIf

    //Atributos automacao
    self:cJsonTokenAuto := ''
    self:cFilUpAuto := ''
    
    //Dados MasterToken
    self:cAuthToken  := GetNewPar("MV_PHATTOK", "" )
    self:cIdTenant   := GetNewPar("MV_PHATIDT", "" )
    self:cTenantName := GetNewPar("MV_PHATNMT", "" )
    self:lTokConfig  := !empty(self:cAuthToken) .And. !empty(self:cIdTenant) .And. !empty(self:cTenantName)
     
Return self

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} Metodos Get/Set

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method setRoomKey(cRoomKey) Class PLMensCont
    self:cRoomKey := cRoomKey
Return

Method setRoomId(cRoomId) Class PLMensCont
    self:cRoomId := cRoomId
Return

Method setStatus(cStatus) Class PLMensCont
    self:cStatus := cStatus
Return

Method setCreaTim(cCreatTime) Class PLMensCont
    self:cCreatTime := cCreatTime
Return

//Metodos automacao
Method setJsnTkAut(cJsonTokenAuto) Class PLMensCont
    self:cJsonTokenAuto := cJsonTokenAuto
Return    

Method setFilUpAut(cFilUpAuto) Class PLMensCont
    self:cFilUpAuto := cFilUpAuto
Return

//Metodos Get
Method getRoomKey() Class PLMensCont
Return self:cRoomKey

Method getRoomId() Class PLMensCont
Return self:cRoomId

Method getStatus() Class PLMensCont
Return self:cStatus

Method getMessages() Class PLMensCont
Return self:oMessages

Method getCodeErr() Class PLMensCont
Return self:cCodeError

Method getCreaTim() Class PLMensCont
Return self:cCreatTime

Method getMsgEnd() Class PLMensCont
Return self:cMsgEndRoom

Method getAnalyzed() Class PLMensCont
Return self:lAnalyzed

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} getRoom
    Busca dados da sala

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method prGetRoom() Class PLMensCont

    Local oResponse := nil
    Local lRet      := .F.

    if self:prepHeader()
        self:setQryPar('roomKey' ,self:cRoomKey)
        self:setPath('api/healthcare/hatChat/v1/room')
        self:comunGet()
        if !empty(self:cRespJson)
            lRet := .T.
            oResponse := JsonObject():New()
            oResponse:fromJSON(self:cRespJson)
            if self:lSucess
                self:setRoomId(oResponse['items',1,'id'])
                self:setCreaTim(oResponse['items',1,'creationTime'])
                self:setStatus(oResponse['items',1,'status'])
            else
                self:cCodeError := oResponse['code']
            endIf
        endIf
    endIf

Return lRet


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} prPostRoom
    Cria uma sala

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method prPostRoom() Class PLMensCont

    Local oRoom := JsonObject():new()
    Local oResponse := nil
    Local lRet      := .F.

    oRoom['roomKey'] := self:cRoomKey
    oRoom['status']  := 1 //Padrao e criacao de sala pendente para o Auditor
    
    if self:prepHeader()
        self:setJson(FWJsonSerialize(oRoom,.F.,.F.))
        self:setPath('api/healthcare/hatChat/v1/room')
        self:comunPost()

        if self:lSucess .And. !empty(self:cRespJson)
            lRet := .T.
            oResponse := JsonObject():New()
            oResponse:fromJSON(self:cRespJson)
            if self:lSucess
                self:setRoomId(oResponse['id'])
                self:setCreaTim(oResponse['creationTime'])
                self:setStatus(oResponse['status'])
            else
                self:cCodeError := oResponse['code']
            endIf
        endIf
    endif

Return lRet


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} getMessage
    Busca dados das mensagens

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method prGetMsg() Class PLMensCont

    Local oResponse := nil
    Local lRet := .F.
    
    if self:prepHeader()
        self:setQryPar('roomId' ,self:cRoomId)
        self:setPath('api/healthcare/hatChat/v1/message')
        self:comunGet()
        if !empty(self:cRespJson)
            lRet := .T.
            if self:lSucess
                self:oMessages:fromJSON(self:cRespJson)
            else
                oResponse := JsonObject():New()
                oResponse:fromJSON(self:cRespJson)
                self:cCodeError := oResponse['code']
            endIf
        endIf
    endif

Return lRet


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} prPostMsg
    Realiza o post de message

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method prPostMsg(cMessage,nStatus) Class PLMensCont

    Local oMessage  := JsonObject():new()
    Local oResponse := nil

    oMessage['message'] := self:strTranMsg(cMessage)
    oMessage['type']    := 1 //Auditor
    oMessage['roomId']  := self:cRoomId
    oMessage['status']  := nStatus
    
    if self:prepHeader()
        self:setJson(FWJsonSerialize(oMessage,.F.,.F.))
        self:setPath('api/healthcare/hatChat/v1/message')
        self:comunPost()
        if !empty(self:cRespJson) .And. self:lSucess
            oResponse := JsonObject():New()
            oResponse:fromJSON(self:cRespJson)
            self:setStatus(oResponse['status']) //Atualiza o status da sala
        endIf
    endIf

Return self:lSucess


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} prPostMsg
    Realiza o post de message

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method prPostAttach(cFileName,cId) Class PLMensCont

    Local nHandle   := 0
    Local cString   := ''
    Local aSizes    := {}
    Local cPath     := self:cUpFolder+"\"+cId+"\"+upper(cFileName)
    Local lRet      := .F.
    Local cBlob     := ''

    if aDir(cPath ,{}, aSizes) > 0
    
        nHandle := fOpen(cPath,FO_READWRITE + FO_SHARED )
        cString := ""
        fRead( nHandle, cString, aSizes[1] ) //Carrega na variável cString, a string ASCII do arquivo.

        cBlob := Encode64(cString) //Converte o arquivo para BASE64
        fClose(nHandle)
             
        if self:prepHeader()
            self:setHeadPar('fileName',cFileName)
            self:setJson(cBlob)
            self:setPath('api/healthcare/hatChat/v1/message/'+cId+'/attachments64')
            self:comunPost()
            if !empty(self:cRespJson) .And. self:lSucess
                if self:prepHeader()
                    self:prGetAttach(cId) //Atualiza os anexos
                    lRet := .T.
                endIf
            endIf
        endIf
    endif

    cBlob   := nil
    cString := nil
    aSizes  := {}
    self:reset() //Limpar todos os atributos

Return lRet


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} prGetAttach
    Busca dados de anexos

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method prGetAttach(cIdMsg) Class PLMensCont

    if self:prepHeader()
        self:setPath('api/healthcare/hatChat/v1/message/'+cIdMsg+"/attachments")
        self:comunGet()
        if self:lSucess
            self:setAttach(cIdMsg)
        endIf
    endIf

Return self:lSucess


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} setAttach
    Adiciona os anexos no Hashmap

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method setAttach(cIdMsg) Class PLMensCont

    Local oResponse    := JsonObject():New()
    Local aAttachments := {}

    oResponse:fromJSON(self:cRespJson)
    if len(oResponse['files']) > 0
        aAttachments := {oResponse['path'],oResponse['sasToken'],oResponse['files']}
        HMSet(self:oAttach,cIdMsg,aAttachments)
    endIf

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} getAttach
    Procura no hashmap e retorna array com os anexos

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method getAttach(cIdMsg) Class PLMensCont

    Local aRet := {}
    Local oVal := nil

    if HMGet(self:oAttach,cIdMsg,oVal)
        aRet := oVal
    endif

Return aRet


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} reset
    Reseta atributos de comunicacao

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method reset() Class PLMensCont

    self:cCodeError := ""
    self:aHeadParam := {}
    self:aQryParam  := {}
    self:lSucess    := .F.
    self:cRespJson  := ''
    self:cError     := ''
    self:setJson('')

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} destroy
    Reseta atributos do objeto

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method destroy() Class PLMensCont

	self:oAttach:clean()
	FreeObj(self:self:oAttach)
	self:oAttach := nil
    
Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} getRoomSch
    Processa get de room na rotina de schedule

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method getRoomSch(nPage) Class PLMensCont

    Local lRet := .F.

    if self:prepHeader()
        self:setQryPar('status','1')
        self:setQryPar('pageSize','2')
        self:setQryPar('page',cValtoChar(nPage))
        self:setPath('api/healthcare/hatChat/v1/room')
        self:comunGet()
        if !empty(self:cRespJson)
            lRet := .T.
        endIf
    endIf

Return lRet


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} strTranMsg
    Processa get de room na rotina de schedule

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method strTranMsg(cStr) Class PLMensCont

	cStr := StrTran(cStr, "ç", "c")
    cStr := StrTran(cStr, "Ç", "C")
	cStr := StrTran(cStr, "á", "a")
	cStr := StrTran(cStr, "ã", "a")
	cStr := StrTran(cStr, "à", "a")
	cStr := StrTran(cStr, "â", "a")
    cStr := StrTran(cStr, "Á", "A")
	cStr := StrTran(cStr, "À", "A")
	cStr := StrTran(cStr, "Â", "A")
	cStr := StrTran(cStr, "Ã", "A")
	cStr := StrTran(cStr, "é", "e")
	cStr := StrTran(cStr, "è", "e")
	cStr := StrTran(cStr, "ê", "e")
    cStr := StrTran(cStr, "É", "E")
	cStr := StrTran(cStr, "È", "E")
	cStr := StrTran(cStr, "Ê", "E")
	cStr := StrTran(cStr, "í", "i")
	cStr := StrTran(cStr, "ì", "i")
    cStr := StrTran(cStr, "Í", "I")
	cStr := StrTran(cStr, "Ì", "I")
	cStr := StrTran(cStr, "ó", "o")
	cStr := StrTran(cStr, "ò", "o")
	cStr := StrTran(cStr, "õ", "o")
	cStr := StrTran(cStr, "ô", "o")
    cStr := StrTran(cStr, "Ó", "O")
	cStr := StrTran(cStr, "Ò", "O")
	cStr := StrTran(cStr, "Õ", "O")
	cStr := StrTran(cStr, "Ô", "O")
	cStr := StrTran(cStr, "ú", "u")
	cStr := StrTran(cStr, "ù", "u")
	cStr := StrTran(cStr, "Ú", "U")
	
Return cStr

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} Upload de arquivos

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method uploadFile(cId) Class PLMensCont

    Local cFile  := ''
    Local cMask  := 'Todos aquivos *.*|*.*|Arquivos pdf|*.pdf|Arquivos txt|*.txt|Arquivos doc|*.doc|Arquivos imagem png|*.png|Arquivos jpg|*.jpg|Arquivos zip|*.zip'
	Local lComun := .F.
    Local cRet   := ''
    Local lCopy  := .F.
    Local oFile  := nil

	if !ExistDir(self:cUpFolder)
		if MakeDir(self:cUpFolder) != 0
			cRet := STR0002+self:cUpFolder+STR0003 //"Não foi possível criar o diretório " ## " no servidor, contate o admnistrador do sistema."
		endIf
	endIf

	if Empty(cRet) .And. !ExistDir(self:cUpFolder+"\"+cId)
		if MakeDir(self:cUpFolder+"\"+cId) != 0
			cRet := STR0002+self:cUpFolder+"\"+cId+STR0003 //"Não foi possível criar o diretório " ## " no servidor, contate o admnistrador do sistema."
		endIf 
	endIf

	if Empty(cRet)
		
        cFile := iif(self:lAuto, self:cUpFolder+"\"+self:cFilUpAuto, cGetFile( cMask, STR0004, 0, "\", .F., GETF_LOCALHARD, .F.)) //"Escolha o arquivo"
		if !empty(cFile)
            
            //Verifica o limite de 10mb
            oFile := FWFileReader():New(cFile)
            if oFile:Open() .And. oFile:getFileSize() < 10000000 
                
                if self:lAuto
                    __CopyFile(cFile,self:cUpFolder+"\"+cId+"\"+self:cFilUpAuto)
                    lCopy := .T.
                else
                    lCopy := CpyT2S( cFile, self:cUpFolder+"\"+cId, .F. ) //Copia anexo para o servidor			
                endIf

                if lCopy

                    cFileName := self:getFileName(cFile)				
                    if self:lAuto
                        lComun := self:prPostAttach(cFileName,cId)
                    else
                        MsAguarde( {|| lComun := self:prPostAttach(cFileName,cId) }, STR0005 , STR0006, .F.) //"Mensageria" ## "Anexando o arquivo, aguarde..."
                    endIf
                    cRet := iif(lComun,STR0007+cFileName+STR0008,STR0009+cFileName+".") //"Arquivo " ## " anexado com sucesso." ## "Não foi possível anexar o arquivo "
                    
                    //Remove arquivos e folder
                    FErase(self:cUpFolder+"\"+cId+"\"+cFileName)
                    DirRemove(self:cUpFolder+"\"+cId)
                else
                    cRet := STR0010+cFile+STR0011 // "Não foi possível copiar o arquivo " ## " para o servidor, contate o admnistrador do sistema."
                endIf
            else
                cRet := STR0012 //"O tamanho do arquivo excedeu o limite permitido de 10mb."
            endIf
		endIf
	endIf

Return cRet


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} Download de arquivos

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method downFile(aAnexList,nAtFile,lAllFiles) Class PLMensCont

	Local cEnvServ   := GetEnvServer()
	Local cDirRaiz 	 := Upper(GetPvProfString(cEnvServ, "RootPath", "C:\MP811\Protheus_Data", GetADV97()))
	Local cFile		 := GetNewPar("MV_RELT",'\SPOOL\')
	Local cDirFinal  := cDirRaiz + cFile
	Local cDirDown   := ""
	Local cUserPwd   := ""
    Local aInfo      := {}
	Local nTotFiles  := 0
    Local nX         := 0
	Local cLocalFile := ""
	Local cURL       := ""
	Local cFilesDown := ""
	Local cRet       := ""
    Local lOk        := .F.
    
    //Baixa todos os arquivos
	cDirDown := cGetFile("TOTVS",STR0013,,"",.T.,GETF_OVERWRITEPROMPT + GETF_NETWORKDRIVE + GETF_LOCALHARD + GETF_RETDIRECTORY, .F.) //"Selecione o diretório"
    
    if !ExistDir(cDirFinal+cLocalFile)    
        cRet := "A estrutura de pastas '"+cDirFinal+cLocalFile+"' nao foi encontrada no servidor, contate o administrador."
    elseIf !Empty(cDirDown)
        nTotFiles := iif(lAllFiles,len(aAnexList),1)
        for nX := 1 to nTotFiles
            if !lAllFiles
                nX := nAtFile
            endIf
            cLocalFile := aAnexList[nX,1]
            cURL       := aAnexList[nX,2]+aAnexList[nX,3] // URL + Filename + SAS Token
            if !Empty(cLocalFile) .And. !Empty(cURL)
                nRet := WDClient("GET", cDirFinal+cLocalFile, STRTRAN(cURL," ","%20"), "", cUserPwd, @aInfo)
                if nRet == 0
                    FErase(cDirDown+cLocalFile)
                    lOk := CpyS2T( cFile + cLocalFile , cDirDown )
                    if lOk
                        if lAllFiles
                            cFilesDown += cLocalFile  + Chr(10)
                        else
                             ShellExecute("Open", cDirDown+cLocalFile, "", "", 1) 
                        endIf
                    endIf
                endif
            endIf
        next
        if lAllFiles
            cRet := iif(lOk,STR0014 + Chr(10) + cFilesDown,STR0015) //"Download do(s) arquivo(s) realizado com sucesso. Arquivos: " ## "Falha ao copiar arquivo(s)."
        endIf
    endIf
    
Return cRet


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} getFileName
    Retorna o nome do arquivo

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method getFileName(cFile) Class PLMensCont

	Local cRet := ''
	Local lAt  := .T.
	Local nAt  := 1
	Local nSubStrFil := 0

	while lAt
		nAt := At("\",cFile,nAt)
		if nAt > 0
			nSubStrFil := nAt
			nAt++
		else
			cRet := Substr(cFile,nSubStrFil+1,len(cFile))
			lAt := .F.
		endIf
	endDo

Return cRet


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} getDataMask
    Mascara de data para apresentacao

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method getDataMask(cData) Class PLMensCont
Return Substr(cData,9,2)+"/"+Substr(cData,6,2)+"/"+Substr(cData,1,4)


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} setStatB53
    Mascara de data para apresentacao

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method setStatB53(cChave,cStatus) Class PLMensCont

	Local cSql := ''

	cSql := " UPDATE " +RetSqlName("B53") + " SET B53_MSGSTA = '"+cStatus+"' "
	cSql += " WHERE B53_FILIAL = '"+xFilial("B53")+"' "
	cSql += " AND B53_NUMGUI = '"+cChave+"' "
	cSql += " AND D_E_L_E_T_ = ' ' "
	TcSqlExec(cSql)

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} setStatB53
    Mascara de data para apresentacao

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method procSchedule() Class PLMensCont

	Local lHasNext  := .T.
	Local nX        := 0
    Local nY        := 0
	Local oResponse := nil
	
    while lHasNext
		nX ++
        if self:getRoomSch(nX) .And. self:lSucess
		
            oResponse := JsonObject():New()
            oResponse:fromJSON(self:cRespJson)
                
            for nY := 1 to len(oResponse['items'])
				self:impLog("Atualizando B53_MSGSTA - Guia: "+oResponse['items',nY,'roomKey'])
				self:setStatB53(oResponse['items',nY,'roomKey'],'1')
            next
            lHasNext := oResponse['hasNext']
        else
            lHasNext := .F. //Nao conseguiu comunicar, finaliza
        endIf
	endDo

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} prepHeader
    Busca token de acesso

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
method prepHeader() class PLMensCont

    Local aHeader       := {}
    Local cBody         := ""
    Local cResult       := ""
    Local oResponse     := nil
    Local oRestClient   := nil
    Local lResult       := .T.
    
    self:reset()
    
    //Verifica se ja existe token ou esta expirado
    if !self:lTokConfig .And. (empty(self:cToken) .Or. Seconds() > self:nTimeExp)

        self:cToken := '' //Reinicializa o token
        aAdd(aHeader,'Content-Type: application/x-www-form-urlencoded')

        cBody += "grant_type=password&"
        cBody += "username=" + self:cUserName + "&"
        cBody += "password=" + self:cPassword + "&"
        cBody += "client_id=" + self:cClientId + "&"
        cBody += "client_secret=" + self:cClientSec + "&"
        cBody += "scope=authorization_api openid profile email"

        oRestClient := FWRest():New(self:cURLRac)
        oRestClient:setPath("connect/token")
        oRestClient:setPostParams(cBody)

        lResult := iif(self:lAuto,.T.,oRestClient:Post(aHeader))

        if lResult
            cResult := iif(self:lAuto,self:cJsonTokenAuto,oRestClient:getResult())
            oResponse := JsonObject():New()
            oResponse:fromJson(cResult)

            self:cToken := oResponse["token_type"] + " " + oResponse["access_token"]
            self:nTimeExp := NoRound(Seconds(), 0) + (self:nMinuteExp * 60)
        endIf
    endIf

    if self:lTokConfig
        lResult := .T.
        self:setHeadPar("authorization",self:cAuthToken)
        self:setHeadPar("idTenant",self:cIdTenant)
        self:setHeadPar("tenantName",self:cTenantName)
    else
        if lResult .And. !empty(self:cToken)
            self:setHeadPar('Authorization',self:cToken)
        endIf
    endIf

return lResult


//-----------------------------------------------------------------
/*/{Protheus.doc} cryptKey
 Encripta uma chave usando o RC4Crypt
 
@author renan.almeida
@since 12/02/2019
@version 1.0
/*/
//-----------------------------------------------------------------
Method cryptKey(cKey) Class PLMensCont
Return (rc4crypt( cKey ,CRYPTKEY, .T.))


//-----------------------------------------------------------------
/*/{Protheus.doc} decryptKey
 Decripta uma chave usando o RC4Crypt
 
@author renan.almeida
@since 12/02/2019
@version 1.0
/*/
//-----------------------------------------------------------------
Method decryptKey(cKey) Class PLMensCont
    local cToken := ""

    if !empty(cKey)
        cToken := rc4crypt(cKey, CRYPTKEY, .F., .T.)
    endif

Return cToken


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} vldDadAces
    Valida se todos atributos de acesso foram preenchidos

    @type  Class
    @author renan.almeida
    @since 20190320
/*/
//------------------------------------------------------------------------------------------
Method vldDadAces() Class PLMensCont

    Local lRet := .T.
    Local cMsg := ""

    if empty(self:cEndPoint)
        lRet := .F.
        cMsg := "Campo 'URL Mensag.' (B7G_MSURLM) não foi configurado na 'Rotina Config. API Terceiros' (aba Mensageria), contate o administrador do sistema"
    endIf
    
    if lRet .And. empty(self:cMsgEndRoom)
        lRet := .F.
        cMsg := "Campo 'Msg.Fin.Sala' (B7G_MSMSGF) não foi configurado na 'Rotina Config. API Terceiros' (aba Mensageria), contate o administrador do sistema"
    endIf

    if lRet .And. !self:lTokConfig
        if empty(self:cUserName) .Or. empty(self:cPassword) .Or. empty(self:cClientId) .Or. empty(self:cClientSec)
            lRet := .F.
            cMsg := "É necessário configurar o MasterToken ou dados de acesso na rotina 'Config. API Terceiros' (aba Mensageria), contate o administrador do sistema"
        endIf
    endIf

Return {lRet,cMsg}


//-----------------------------------------------------------------
/*/{Protheus.doc} ajustChar
 Converte caracteres especiais do QueryParam
 
@author renan.almeida
@since 12/02/2019
@version 1.0
/*/
//-----------------------------------------------------------------
Method ajustChar(cURI) Class PLMensCont

    local cURIEncoded := ""
    local nAtChar := 1
    local oHashMap := HashMap():new()

    oHashMap:set(" ","%20")
    oHashMap:set("!","%21")
    oHashMap:set('"',"%22")
    oHashMap:set("#","%23")
    oHashMap:set("$","%24")
    oHashMap:set("%","%25")
    oHashMap:set("&","%26")
    oHashMap:set("'","%27")
    oHashMap:set("(","%28")
    oHashMap:set(")","%29")
    oHashMap:set("*","%2A")
    oHashMap:set("+","%2B")
    oHashMap:set(",","%2C")
    oHashMap:set("-","%2D")
    oHashMap:set(".","%2E")
    oHashMap:set("/","%2F")
    oHashMap:set(":","%3A")
    oHashMap:set(";","%3B")
    oHashMap:set("<","%3C")
    oHashMap:set("=","%3D")
    oHashMap:set(">","%3E")
    oHashMap:set("?","%3F")
    oHashMap:set("@","%40")
    oHashMap:set("[","%5B")
    oHashMap:set("\","%5C")
    oHashMap:set("]","%5D")
    oHashMap:set("^","%5E")
    oHashMap:set("_","%5F")
    oHashMap:set("`","%60")
    oHashMap:set("{","%7B")
    oHashMap:set("|","%7C")
    oHashMap:set("}","%7D")
    oHashMap:set("~","%7E")

    for nAtChar := 1 to len(cURI)
        cChar := oHashMap:get(SubStr(cURI,nAtChar,1))
        if empty(cChar)
            cURIEncoded += SubStr(cURI,nAtChar,1)
        else
            cURIEncoded += cChar
        endif
    next

Return cURIEncoded