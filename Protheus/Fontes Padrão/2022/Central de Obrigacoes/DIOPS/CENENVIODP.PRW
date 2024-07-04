#include 'PROTHEUS.CH'
#INCLUDE "TOTVS.CH"
#INCLUDE "Fwlibversion.ch"
//Métricas - FwMetrics
STATIC lLibSupFw		:= FWLibVersion() >= "20200727"
STATIC lVrsAppSw		:= GetSrvVersion() >= "19.3.0.6"
STATIC lHabMetric		:= iif( GetNewPar('MV_PHBMETR', '1') == "0", .f., .t.)
Static _barra := iif(IsSrvUnix(),"/","\")

/*/{Protheus.doc}
Executa .Jar externo via linha de comando.
@type function
@author vinicius.nicolau
@since 27/05/2020
@version 1.0
/*/
Function ComandDp(cPath, cJarName, aParms, cLib)
    LOCAL cComando      := ""
    LOCAL cResposta     := ""
    LOCAL nX            := 0
    LOCAL nI            := 0
    LOCAL lOk           := .T.

    DEFAULT cPath       := ""
    DEFAULT cJarName    := ""
    DEFAULT aParms      := {}
    DEFAULT cLib        := ""

    cComando := "java -jar "

    If ExistDir(cPath)
        cComando += '"' + cPath
    Else
        cResposta := "Caminho não existe!" + Chr(13) + Chr(10) + cPath //"Erro: Caminho não existe!"
        lOk := .F.
    EndIf

    If lOk .And. File(cPath+_barra+cJarName)
        cComando += _barra + cJarName + '"'
    Else
        cResposta := "Arquivo .jar não encontrado!" + Chr(13) + Chr(10) + cPath+_barra+cJarName //"Erro: Arquivo .jar não encontrado!"
        lOk := .F.
    EndIf

    If lOk .And. ValType(cLib) == "C" .And. !Empty(cLib) .And. !File(cPath+_barra+cLib)
        cResposta := "Arquivo de biblioteca do .jar não encontrado!" + Chr(13) + Chr(10) + cPath+_barra+cLib //"Erro: Arquivo de biblioteca do .jar não encontrado!"
        lOk := .F.
    EndIf

    If lOk
        If ValType(aParms) == "A"
            For nX := 1 To Len(aParms)
                cComando += ' "' + aParms[nX] + '"'
            Next
        EndIf
        cResposta := WinExec(cComando)
        ProcRegua(5)
        While(nI <= 5)
            IncProc()
            Sleep(1000)
            nI++
        endDo
    EndIf

    If ValType(cResposta) == "N"
        cResposta := CValToChar(cResposta)
    EndIf

Return(cResposta)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} EnviaDiops
Função principal para envio do arquivo diops financeiro

@author    vinicius.nicolau
@version   1.0
@since     24/05/21
/*/
Function EnviaDiops()

    LOCAL cRoot         := GetPvProfString(GetEnvServer(), "RootPath", "", GetADV97())
    LOCAL cSystem       := GetPvProfString(GetEnvServer(), "StartPath", "", GetADV97())

    LOCAL cCaminho      := cRoot + cSystem + "diops"
    LOCAL cNome		    := "diopsenvio.jar"
    LOCAL aParametro    := {}
    LOCAL cLib		    := _barra+"lib"+_barra+"diopsfinanceiroclient.jar"
    Local oFileRead	    := Nil
    Local cFile         := ""

    LOCAL cRecibo       := cCaminho + _barra+"recibos"
    LOCAL cLog          := cCaminho + _barra+"logs"
    Local cRegANS       := B3D->B3D_CODOPE

    LOCAL cRet          := ""
    LOCAL cPass         := ""
    LOCAL cLogTratado   := ""

    MakeDir(cCaminho)
    MakeDir(cLog)
    MakeDir(cRecibo)

    cRet :=	cGetFile("Arquivo xml | *.xml","Selecione o arquivo XML",,"",.T.,GETF_LOCALFLOPPY+GETF_LOCALHARD+GETF_NETWORKDRIVE+GETF_RETDIRECTORY+128)

    if !Empty(cRet)
        cPass := AllTrim(CenDpSenha())

        If Empty(cPass)
            Alert("Senha não pode ser enviada em branco.")
        Else
            AAdd(aParametro,cRet)
            Aadd(aParametro,cRegANS)
            AAdd(aParametro,cPass)
            AAdd(aParametro,cLog)

            SplitPath(cRet,,, @cLogTratado,)
            cLogTratado := cLog + _barra + cLogTratado + ".txt"
            Processa( { || cRet := ComandDp(cCaminho,cNome,aParametro,cLib) },"Enviando XML para ANS","Processando...",.T.)

            if lHabMetric .and. lLibSupFw .and. lVrsAppSw
                FWMetrics():addMetrics("Envio Automático Financeiro", {{"totvs-saude-planos-protheus_obrigacoes-utilizadas_total", 1 }} )
            endif

            If file(cLogTratado)
                oFileRead := FWFILEREADER():New(cLogTratado)
                if oFileRead:Open()
                    while (oFileRead:hasLine())
                        cFile += oFileRead:GetLine()
                    EndDo
                    oFileRead:Close()
                EndIf
            EndIf

            If ("Erro" $ cFile) .OR. ("401" $ cFile) .OR. ("error" $ cFile) .OR. ("incorreto" $ cFile)
                Alert(cFile)
            Else
                MsgInfo(cFile,"Retorno ANS")
                If B3D->(FieldPos("B3D_PROTOC")) > 0
                    RecLock("B3D",.F.)
                    B3D->B3D_PROTOC := cFile
                    MsUnLock()
                EndIf
            EndIf
        EndIf
    EndIf

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc}
Funcao criada para que o usuario possa informar a senha da ANS a ser enviada criptografada no XML

@author vinicius.nicolau
@since 29/05/2021
/*/
Function CenDpSenha()
    Local oDlgSenha	:= Nil
    Local cSenha	:= Space(15)

    DEFINE DIALOG oDlgSenha Of GetWndDefault() TITLE "Informe a senha ANS" FROM 12, 30 TO 18,55
    @ .5,1 SAY "Senha: "
    @ .5,3.5 MSGET cSenha SIZE 035,006 OF oDlgSenha PASSWORD
    DEFINE SBUTTON FROM 32,65 TYPE 1 ACTION oDlgSenha:End() ENABLE OF oDlgSenha
    ACTIVATE MSDIALOG oDlgSenha CENTERED

Return PadR( cSenha, 15 )