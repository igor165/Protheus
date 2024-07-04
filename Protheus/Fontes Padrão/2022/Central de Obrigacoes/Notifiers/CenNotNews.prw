#include 'totvs.ch'
#define TAMSX3      1
#define FILIAL      1
#define USR_NOTIFY  2
#define COD_NOTIFY  3
#define DTHR_NOTIFY 4
#define lLinux IsSrvUnix()
#IFDEF lLinux
    #define CRLF Chr(13) + Chr(10)
    #define _barra '/'
#ELSE
    #define CRLF Chr(10)
    #define _barra '\'
#ENDIF

Class CenNotNews from CenEveIns

    Data oJson
    Data nNews
    Data cCodigo
    Data cTitulo
    Data lAtivo
    Data cLevel
    Data cCodUser
    Data cAlias
    Data aCampos
    Data cDataValid

    Method New() Constructor
    Method Execute()
    Method getNews()
    Method setNotification()
    Method SetCodigo(cCodigo)
    Method SetAtivo(lAtivo)
    Method SetLevel(cLevel)
    Method SetValidade(cDataValid)
    Method existeCodigo()
    Method existeTitulo()
    Method existeMensagem()
    Method existeAtivo()
    Method existeLevel()
    Method existeLog()
    Method existeValidade()
    Method msgAntiga()
    Method gravaLog()
    Method openConnection()
    Method closeConnection()
EndClass

/*/{Protheus.doc}
    Classe que envia as notificações sobre novidades da Central
    @type  Class
    @author david.juan
    @since 20200928
    @see https://tdn.totvs.com/pages/viewpage.action?pageId=567741157
/*/
Method New() Class CenNotNews
    _Super:New()
    self:cTitulo    := "Central News"
    self:cMensagem  := ""
    self:lAtivo     := .F.
    self:cDataValid := "99999999"
    self:cAlias     := "BX7"
    self:aCampos    := {;
        self:cAlias + "_FILIAL",;
        self:cAlias + "_USRNOT",;
        self:cAlias + "_CODNOT",;
        self:cAlias + "_DTHNOT"}
    self:SetEventID("074")
    self:LvInfo()
    self:EnvAll()
    self:oJson      := JsonObject():New()
Return self

Method Execute() Class CenNotNews
    Local nLenNews := 0
    Local nNews := 0
    local cRet  := ""
    If PrjExtCmp(@cRet,self:aCampos)
        If self:openConnection()
            If self:getNews()
                nLenNews := Len(self:oJson["novidadescentral"])
                For nNews := 1 To nLenNews
                    self:nNews := nNews
                    self:setNotification()
                    If self:lAtivo .And. !self:existeLog() .And. !self:msgAntiga()
                        self:gravaLog()
                        self:Send()
                        ConOut("Notificacao enviada: " + CRLF +;
                            "Codigo: " + self:cCodigo + CRLF +;
                            "Mensagem: " + self:cMensagem + CRLF)
                    Else
                        ConOut("Notificacao INATIVA ou Ja Recebida: " + CRLF +;
                            "Codigo: " + self:cCodigo + CRLF +;
                            "Mensagem: " + self:cMensagem + CRLF)
                    EndIf
                Next nNews
            EndIf
            self:closeConnection()
        EndIf
    EndIf
    ConOut( cRet )
Return .T.

Method msgAntiga() Class CenNotNews
Return self:cDataValid < DToS(Date())

Method existeLog() Class CenNotNews
    Local cFil      := PadR(self:cFil,      TamSx3(self:aCampos[FILIAL])[TAMSX3])
    Local cCodigo   := PadR(self:cCodigo,   TamSx3(self:aCampos[COD_NOTIFY])[TAMSX3])
    Local cCodUser  := PadR(self:cCodUser,  TamSx3(self:aCampos[USR_NOTIFY])[TAMSX3])
Return MsSeek(cFil+cCodigo+cCodUser)

Method gravaLog() Class CenNotNews
    Reclock(self:cAlias,.T.)
    (self:cAlias)->&(self:aCampos[FILIAL])      := self:cFil
    (self:cAlias)->&(self:aCampos[COD_NOTIFY])  := self:cCodigo
    (self:cAlias)->&(self:aCampos[USR_NOTIFY])  := self:cCodUser
    (self:cAlias)->&(self:aCampos[DTHR_NOTIFY]) := DToS(Date()) + " " + Time()
    MsUnlock()
Return

Method openConnection() Class CenNotNews
    local lConnect := .F.
    IF  FWAliasInDic(self:cAlias, .F.) .And. ChkFile(self:cAlias)
        DBSelectArea(self:cAlias)
        (self:cAlias)->(DBSetOrder(1))
        lConnect := .T.
    EndIf
Return lConnect

Method closeConnection() Class CenNotNews
    DBUnlockAll()
    (self:cAlias)->(DBCloseArea())
Return

Method SetCodigo(cCodigo) Class CenNotNews
    self:cCodigo    := cCodigo
Return

Method SetAtivo(lAtivo) Class CenNotNews
    self:lAtivo     := lAtivo
Return

Method SetValidade(cDataValid) Class CenNotNews
    self:cDataValid     := cDataValid
Return

Method SetLevel(cLevel) Class CenNotNews
    Do Case
        Case lower(cLevel) == "warning"
            self:LvWarning()
        Case lower(cLevel) == "error"
            self:LvError()
        Case lower(cLevel) == "info"
            self:LvInfo()
    EndCase
Return

Method existeCodigo() Class CenNotNews
Return !Empty(self:oJson["novidadescentral"][self:nNews]["codigo"]  )

Method existeTitulo() Class CenNotNews
Return !Empty(self:oJson["novidadescentral"][self:nNews]["titulo"]  )

Method existeMensagem() Class CenNotNews
Return !Empty(self:oJson["novidadescentral"][self:nNews]["msg"]     )

Method existeAtivo() Class CenNotNews
Return !Empty(self:oJson["novidadescentral"][self:nNews]["ativo"]   )

Method existeLevel() Class CenNotNews
Return !Empty(self:oJson["novidadescentral"][self:nNews]["level"]   )

Method existeValidade() Class CenNotNews
Return !Empty(self:oJson["novidadescentral"][self:nNews]["datavalidade"] )

Method setNotification() Class CenNotNews
    self:lAtivo     := .F.
    self:LvInfo()
    self:cCodUser   := strZero( val(RetCodUsr()),6)
    If self:existeAtivo()
        self:SetAtivo(      self:oJson["novidadescentral"][self:nNews]["ativo"] )
    EndIf
    If self:existeCodigo()
        self:SetCodigo(     self:oJson["novidadescentral"][self:nNews]["codigo"])
    EndIf
    If self:existeTitulo()
        self:SetTitulo(     self:oJson["novidadescentral"][self:nNews]["titulo"])
    EndIf
    If self:existeMensagem()
        self:SetMensagem(   self:oJson["novidadescentral"][self:nNews]["msg"]   )
    EndIf
    If self:existeLevel()
        self:SetLevel(      self:oJson["novidadescentral"][self:nNews]["level"] )
    EndIf
    If self:existeValidade()
        self:SetValidade(   self:oJson["novidadescentral"][self:nNews]["datavalidade"] )
    EndIf
Return

Method getNews() Class CenNotNews
    Local cFolder   := _barra + "sigacen" + _barra
    Local cFileName := "CENNEWS.json"
    Local cUrl      := "https://cobprostorage.blob.core.windows.net"
    Local cRequest  := "/files/CONFIGURACAO/CENNEWS.json"
    Local cErrJsonLc:= ""
    Local oWzFiles  := PrjWzFiles():New(cFolder, cFileName)
    Local oJsonCloud:= JsonObject():New()
    Local lRet      := .T.

    cErrJsonLc := self:oJson:fromJson(oWzFiles:readFile())
    If oWzFiles:getRest(cUrl, cRequest)
        oJsonCloud:fromJson(oWzFiles:GetResult())
        If oJsonCloud["versao"] > self:oJson["versao"] .Or. !Empty(cErrJsonLc)
            If oWzFiles:saveFile(oWzFiles:GetResult())
                self:oJson:fromJson(oJsonCloud:toJson())
            ElseIf !Empty(oWzFiles:getErro())
                conout(oWzFiles:getErro())
                lRet    := .F.
            EndIf
        EndIf
    ElseIf !Empty(cErrJsonLc)
        conout(cErrJsonLc)
        lRet    := .F.
    EndIf
Return lRet