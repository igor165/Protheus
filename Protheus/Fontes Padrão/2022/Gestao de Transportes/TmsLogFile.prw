#INCLUDE "TMSLOGFILE.CH"
#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TmsLogFile
Classe TMS para gerenciamento de arquivos de logs
@type class
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 07/04/2017
@example oTmsLog := TmsLogFile():New()                // Instancia a classe
@example oTmsLog:CreateDir("\temp")                   // Cria diretório \temp no servidor
@example oTmsLog:CreateFile("\temp\tmslog.log")       // Cria arquivo tmslog.log
@example oTmsLog:AddMsg("Registro 01 atualizado!", 1) // Adiciona mensagem (indica quebra de uma linha)
@example oTmsLog:AddMsg("Registro 02 atualizado!", 2) // Adiciona mensagem (indica quebra de duas linhas)
@example oTmsLog:WriteFile()                          // Escreve mensagens no arquivo de log
@example oTmsLog:AddMsg("Registro 03 atualizado!", 1) // Adiciona mensagem (indica quebra de uma linha)
@example oTmsLog:AddMsg("Registro 04 atualizado!", 1) // Adiciona mensagem (indica quebra de uma linha)
@example oTmsLog:WriteFile()                          // Escreve mensagens no arquivo de log
@example oTmsLog:CloseFile()                          // Fecha o arquivo
@example FreeObj(oTmsLog)                             // Limpa objeto de memória
/*/
//-------------------------------------------------------------------------------------------------
Class TmsLogFile

    //-- Propriedades da classe
    Data nDir    as Numeric
    Data cDir    as Character
    Data nFile   as Numeric
    Data cFile   as Character
    Data lConout as Logical
    Data aMsgs   as Array

    //-- Métodos públicos da classe
    Method New()
    Method CreateDir()
    Method CreateFile()
    Method AddMsg()
    Method WriteFile()
    Method CleanMsgs()
    Method CloseFile()

    //-- Métodos privados da classe
    Method _SetConout()

EndClass

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} New
Método construtor que instancia a classe
@type method
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 07/04/2017
@return Self Objeto da classe
/*/
//-------------------------------------------------------------------------------------------------
Method New() Class TmsLogFile

    ::nDir    := 0
    ::cDir    := ""
    ::nFile   := 0
    ::cFile   := ""
    ::lConout := .T.
    ::aMsgs   := {}

Return Self

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CreateDir
Cria um diretório
@type method
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 07/04/2017
@param [cDir], Caracter, Diretório
@return nDir Retorna zero (0), se o diretório for criado com sucesso senão retorna diferente de zero
/*/
//-------------------------------------------------------------------------------------------------
Method CreateDir(cDir) Class TmsLogFile

    Default cDir := ""

    ::nDir := 0
    ::cDir := cDir

    If ! Empty(cDir)
        If ! ExistDir(cDir)
            ::nDir := MakeDir(cDir, Nil, .F.)
            If ::nDir != 0
                ::_SetConout(STR0003, {cDir, cValToChar(FError())}, "CreateDir")
            EndIf
        Else
            ::_SetConout(STR0002, {cDir}, "CreateDir")
        EndIf
    Else
        ::_SetConout(STR0001, , "CreateDir")
    EndIf

Return ::nDir

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CreateFile
Cria um arquivo
@type method
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 07/04/2017
@param [cFile], Caracter, Arquivo
@param [lChangeCase], Lógico, Se verdadeiro (.T.), nomes de arquivos e pastas serão convertidos para letras minúsculas
@return nFile Retorna o handle do arquivo para ser usado nas demais funções de manutenção de arquivo.
/*/
//-------------------------------------------------------------------------------------------------
Method CreateFile(cFile, lChangeCase) Class TmsLogFile

    Default cFile       := ""
    Default lChangeCase := .F.

    ::nFile := 0

    If ! Empty(cFile)
        If ! File(cFile)
            ::nFile := FCreate(cFile, Nil, Nil, lChangeCase)
            If ::nFile < 0
                ::_SetConout(STR0006, {cFile, cValToChar(FError())}, "CreateFile")
            EndIf
        Else
            ::_SetConout(STR0005, {cFile}, "CreateFile")
        EndIf
    Else
        ::_SetConout(STR0004, , "CreateFile")
    EndIf

Return ::nFile

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AddMsg
Inclui mensagem para ser gravada no arquivo de log
@type method
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 07/04/2017
@param [cMsg], Caracter, Mensagem
@param [nChr10], Numérico, Número de quebras de linhas
@param [lWrite], Lógico, Indica se já deve gravar a mensagem no arquivo de log
@return nLin Retorna o número da linha que contém a mensagem incluída
/*/
//-------------------------------------------------------------------------------------------------
Method AddMsg(cMsg, nChr10, lWrite) Class TmsLogFile

    Local nLin  := 0
    Local nCont := 0

    Default cMsg   := ""
    Default nChr10 := 0
    Default lWrite := .F.

    AAdd(::aMsgs, cMsg + chr(13) + chr(10))
    nLin := Len(::aMsgs)

    For nCont := 1 To nChr10
        AAdd(::aMsgs, chr(13) + chr(10))
    Next nCont

    If lWrite
        ::WriteFile()
    EndIf

Return nLin

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WriteFile
Grava mensagens no arquivo de log
@type method
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 07/04/2017
@return lRet Indica se conseguiu ou não gravar
/*/
//-------------------------------------------------------------------------------------------------
Method WriteFile() Class TmsLogFile

    Local lRet  := .F.
    Local nCont := 0

    For nCont := 1 To Len(::aMsgs)
        FWrite(::nFile, ::aMsgs[nCont])
        If FError() # 0
            ::_SetConout(STR0007, {cValToChar(FError()), ::aMsgs[nCont]}, "WriteFile")
        Else
            lRet := .T.
        EndIf
    Next nCont

    If lRet
        ::aMsgs := {}
    EndIf

Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CleanMsgs
Limpa mensagens
@type method
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 07/04/2017
@return Nil Não há retorno
/*/
//-------------------------------------------------------------------------------------------------
Method CleanMsgs() Class TmsLogFile

    ::aMsgs := {}

Return Nil

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CloseFile
Fecha arquivo
@type method
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 07/04/2017
@return Nil Não há retorno
/*/
//-------------------------------------------------------------------------------------------------
Method CloseFile() Class TmsLogFile

    FClose(::nFile)

Return Nil

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} _SetConout
Gera uma mensagem no prompt
@type method
@protected
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 07/04/2017
@param [cMsg], Caracter, Mensagem
@param [aPar], Array, Parâmetros da mensagem
@param [cMet], Caracter, Método
@return lConout Retorna se gerou ou não o Conout
/*/
//-------------------------------------------------------------------------------------------------
Method _SetConout(cMsg, aPar, cMet) Class TmsLogFile

    Local nCont := 0

    Default cMsg := ""
    Default aPar := {}
    Default cMet := ""

    If ::lConout

        If ValType(cMsg) != "C"
            cMsg := ""
        EndIf

        If ValType(aPar) != "A"
            aPar := {}
        EndIf

        If ValType(cMet) != "C"
            cMet := ""
        EndIf

        For nCont := 1 To Len(aPar)
            If ValType(aPar[nCont]) != "C"
                aPar[nCont] := ""
            EndIf
            cMsg := StrTran(cMsg, "&" + cValToChar(nCont), aPar[nCont])
        Next nCont

        If ! Empty(cMet)
            cMsg := cMet + ": " + cMsg
        EndIf

        TmsLogMsg("INFO",AnsiToOEM(cMsg))
    EndIf

Return ::lConout