#include 'totvs.ch'

Static _barra := iif(IsSrvUnix(),"/","\")

/*/{Protheus.doc} CenGeraTxt
    Classe genérica responsável pela criação de arquivos .txt;
    inicialmente criada para atender a legislação DMed - CenArqDMed
    @type  Class
    @author david.juan
    @since 20201019
/*/

Class CenGeraTxt From Service
    Data oHashTxt       As Object

    Data nLine          As Number
    Data cFolder        As String
    Data cFileName      As String
    Data cSeparator     As String
    Data cError         As String
    Data cCodOpe        As String
    Data cCodObr        As String
    Data cCodComp       As String
    Data cAnoCalendar   As String
    Data cTipo          As String
    Data cObrigacao     As String
    Data cCnpjOpe       As String
    Data cRazSocOpe     As String
    Data cAnoRef        As String

    Method New() Constructor
    Method destroy()
    Method setLine(aCampos, xKey)
    Method setSeparator(cSeparator)
    Method existsFile()
    Method saveFile()
    Method setFolder(cFolder)
    Method setFileName(cFileName)
    Method getErro()
    Method setErro(cError)
    Method checkFolder(cFolder)
    Method saveInServer(cServFolder)
    Method downFromServer(cServFolder)

    Method setCodOpe(cCodOpe)
    Method setCodObr(cCodObr)
    Method setCodComp(cCodComp)
    Method setAnoCalendar(nAnoCalendar)
    Method setTipo(cTipo)
    Method setCnpjOpe(cCnpjOpe)
    Method setRazSocOpe(cRazSocOpe)
    Method setAnoRef(nAnoRef)

EndClass

Method New() Class CenGeraTxt
    self:oHashTxt       := tHashMap():New()
    self:nLine          := 0
    self:cError         := ""
    self:cCodOpe        := ""
    self:cCodObr        := ""
    self:cCodComp       := ""
    self:cAnoCalendar   := ""
    self:cTipo          := ""
    self:cObrigacao     := ""
    self:cCnpjOpe       := ""
    self:cRazSocOpe     := ""
    self:cAnoRef        := ""
    self:setSeparator()
    self:setFolder()
    self:setFileName()
Return Self

Method setFolder(cFolder) Class CenGeraTxt
    Default cFolder		:= ""
    self:cFolder    	:= PrjWzLinux(cFolder)
    self:checkFolder()
Return

Method setFileName(cFileName) Class CenGeraTxt
    Default cFileName	:= ""
    self:cFileName  	:= cFileName
Return

Method setSeparator(cSeparator) Class CenGeraTxt
    Default cSeparator  := "|"
    Self:cSeparator := cSeparator
Return

Method setLine(aCampos) Class CenGeraTxt
    Local lRet := .F.
    Default aCampos := {}
    If !Empty(aCampos)
        self:nLine++
        lRet := self:oHashTxt:set(self:nLine, aCampos)
    EndIf
Return lRet

Method existsFile() Class CenGeraTxt
Return File(self:cFolder + self:cFileName)

Method saveFile() Class CenGeraTxt
    Local nHandle := -1
    Local lSuccess := .T.
    Local aLine   := {}
    Local nLine   := 1

    If self:existsFile()
        FErase(self:cFolder + self:cFileName)
    EndIf

    nHandle := FCreate(self:cFolder + self:cFileName,NIL,NIL,.F.)
    If nHandle >= 0
        For nLine := 1 To Self:nLine
            self:oHashTxt:get(nLine, @aLine)
            FWrite(nHandle, CenArr2Str(aLine, self:cSeparator) + self:cSeparator + CRLF)
            aLine := {}
        Next nLine
    EndIf
    If (!File(self:cFolder + self:cFileName))
        lSuccess := .F.
        self:setErro("Erro ao criar arquivo - FERROR " + str(FError(),4) )
    EndIf
    FClose(nHandle)
Return lSuccess

Method getErro() Class CenGeraTxt
Return self:cError

Method setErro(cError) Class CenGeraTxt
    self:cError += cError + CRLF
Return

Method checkFolder(cFolder) Class CenGeraTxt
    Local cBarra 	:= _barra
    Local aFolder 	:= {}
    Local nFolder	:= 0
    Local nLenFolder	:= 0
    Default cFolder := self:cFolder

    If !(ExistDir(cFolder))
        aFolder := StrTokArr(cFolder,cBarra)
        cFolder := cBarra
        nLenFolder := Len(aFolder)
        For nFolder := 1 To nLenFolder
            cFolder += aFolder[nFolder] + cBarra
            MakeDir(cFolder)
        Next nFolder
    EndIf
Return

Method saveInServer(cServFolder) Class CenGeraTxt
    Default cServFolder := _barra + self:cObrigacao + _barra
    self:setFolder(cServFolder)
Return self:saveFile()

Method downFromServer(cServFolder) Class CenGeraTxt
    Default cServFolder := _barra + self:cObrigacao + _barra
Return IIf(isBlind(), .F. ,CpyS2T( cServFolder + self:cFileName , self:cFolder, .F. ))

Method setCodOpe(cCodOpe) Class CenGeraTxt
    self:cCodOpe := AllTrim(cCodOpe)
Return

Method setCodObr(cCodObr) Class CenGeraTxt
    self:cCodObr := cCodObr
Return

Method setCodComp(cCodComp) Class CenGeraTxt
    self:cCodComp := cCodComp
Return

Method setAnoCalendar(nAnoCalendar) Class CenGeraTxt
    If ValType(nAnoCalendar) == "N"
        self:cAnoCalendar := cValToChar(nAnoCalendar)
    Else
        self:cAnoCalendar := nAnoCalendar
    EndIf
Return

Method setTipo(cTipo) Class CenGeraTxt
    Default cTipo := ""
    self:cTipo := cTipo
    Do Case
        Case self:cTipo == "1"
            self:cObrigacao := "sip"
        Case self:cTipo == "2"
            self:cObrigacao := "sib"
        Case self:cTipo == "3"
            self:cObrigacao := "diops"
        Case self:cTipo == "4"
            self:cObrigacao := "dmed"
        Case self:cTipo == "5"
            self:cObrigacao := "monitoramento"
    EndCase
Return

Method setCnpjOpe(cCnpjOpe) Class CenGeraTxt
    self:cCnpjOpe   := cCnpjOpe
Return

Method setRazSocOpe(cRazSocOpe) Class CenGeraTxt
    self:cRazSocOpe := AllTrim(cRazSocOpe)
Return

Method setAnoRef(nAnoRef) Class CenGeraTxt
    If ValType(nAnoRef) == "N"
        self:cAnoRef := cValToChar(nAnoRef)
    Else
        self:cAnoRef := nAnoRef
    EndIf
Return

Method destroy() Class CenGeraTxt
    if self:oHashTxt != nil
        FreeObj(self:oHashTxt)
        self:oHashTxt:= nil
    EndIf
Return

Function CenArr2Str(aArray,cSep)
    Local cRet      := ""
    Local nCount    := 0
    Default cSep    := "|"

    FOR nCount := 1 TO Len(aArray)
        Do Case
            Case VALTYPE(aArray[nCount]) == "C"
                cRet += If(nCount > 1,cSep,"") + aArray[nCount]
            Case VALTYPE(aArray[nCount]) == "D"
                cRet += If(nCount > 1,cSep,"") + dtoc(aArray[nCount])
            Case VALTYPE(aArray[nCount]) == "N"
                cRet += If(nCount > 1,cSep,"") + str(aArray[nCount],12,2)
            Case VALTYPE(aArray[nCount]) == "L"
                cRet += If(nCount > 1,cSep,"") + If(aArray[nCount],"T","F")
        EndCase
    Next
Return cRet