#include "AVERAGE.CH"
#include "AVINT103.CH"

/*
Programa   : AvInt103.prw
Objetivo   : Reunir as classes de integração do EasyLink (Boundary Manager)
Autor      : Rodrigo Mendes Diaz
Data/Hora  : 08/02/07
Obs        : 
*/

/*
Classe      : ELinkBdMan (Easy Link Boundary Manager)
Objetivos   : Enviar e receber via FTP arquivos de integração do EasyLink
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 01/08/07
Revisao     : 
Obs.        : 
*/

Function AvInt103()
Return Nil

*===============*
Class ELinkBdMan
*===============*

Data cType
Data cServer
Data nPort
Data cUser
Data cPass
Data cDirFtpIn
Data cDirFtpOut
Data cDirLocIn
Data cDirLocOut
Data cFileMode
Data aFilesFtp
Data aFilesLoc
Data aFilesDownload
Data aFilesUpload
Data cError
Data lInterface
Data lRemoveFiles
Data bDownload
Data bUpload

Method New(cType) Constructor
Method SetComType(cType)
Method Connect()
Method AuxConnect()
Method Disconnect()
Method UploadFiles()
Method DownloadFiles()
Method AuxUpldFiles()
Method AuxDownFiles()
Method SetFileMode(cMode)
Method ChangeStoreMode(cMode)
Method GoToFtpDir()
Method SetDirFtpIn(cDir)
Method SetDirFtpOut(cDir)
Method SetDirLocIn(cDir)
Method SetDirLocOut(cDir)
Method SetServer(cServer)
Method SetPort(nPort)
Method SetUser(cUser)
Method SetPass(cPass)
Method GetFtpFileList()
Method GetLocFileList()
Method DownloadList(xFile)
Method UploadList(xFile)
Method GetError()

End Class


/*
Método      : New(cType)
Classe      : ELinkBdMan
Parâmetros  : cType - Define o tipo de comunicação (Atualmente está disponível apenas a opção FTP)
Retorno     : Self - Instância da classe
Objetivos   : Gerar nova instância da classe
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 01/08/2007
Revisao     :
Obs.        :
*/
Method New(cType) Class ELinkBdMan
Default cType := ""

   ::cType        := cType
   ::cUser        := ""
   ::cPass        := ""
   ::cServer      := ""
   ::nPort        := 21
   ::cError       := ""
   ::lRemoveFiles := .F.
   ::lInterface   := .T.
   ::SetComType(cType)

Return Self

/*
Método      : SetComType(cType)
Classe      : ELinkBdMan
Parâmetros  : cType - Define o tipo de comunicação (Atualmente está disponível apenas a opção FTP)
Retorno     : Nenhum
Objetivos   : Definir o tipo de comunicação utilizado
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 01/08/2007
Revisao     :
Obs.        :
*/
Method SetComType(cType) Class ELinkBdMan
Default cType := ""

   If cType == "FTP"
      ::cDirFtpIn      := ""
      ::cDirFtpOut     := ""
      ::aFilesFtp      := {}
      ::aFilesLoc      := {}
      ::aFilesDownload := {}
      ::aFilesUpload   := {}
      ::cDirLocIn      := ""
      ::cDirLocOut     := ""
      ::cFileMode      := "COMPLETE"
   EndIf
   
Return Nil

/*
Método      : Connect()
Classe      : ELinkBdMan
Parâmetros  : Nenhum
Retorno     : lRet - Indica se a conexão foi concluída
Objetivos   : Fazer a conexão ao servidor FTP com base nos atributos de definição de servidor, porta, usuário e senha.
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 01/08/2007
Revisao     :
Obs.        :
*/
Method Connect() Class ELinkBdMan
Local lRet

   If ::lInterface
      Processa({|| lRet := ::AuxConnect() }, STR0001)//"Conectando ao servidor FTP"
   Else
      lRet := ::AuxConnect()
   EndIf

Return lRet


/*
Método      : AuxConnect()
Classe      : ELinkBdMan
Parâmetros  : Nenhum
Retorno     : lRet - Indica se a conexão foi concluída
Objetivos   : Auxiliar ao método Connect()
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 01/08/2007
Revisao     :
Obs.        :
*/
Method AuxConnect() Class ELinkBdMan
Local lRet

   lRet := FtpConnect(::cServer, ::nPort, ::cUser, ::cPass)
   If !lRet
      ::cError += STR0002 + ENTER//"Erro na conexão com o servidor FTP."
   EndIf

Return lRet

/*
Método      : Disconnect()
Classe      : ELinkBdMan
Parâmetros  : Nenhum
Retorno     : lRet - Indica se foi possível conexão foi concluída
Objetivos   : Faz a desconexão do servidor FTP
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 01/08/2007
Revisao     :
Obs.        :
*/
Method Disconnect() Class ELinkBdMan
Local lRet

   lRet := FtpDisconnect()

Return lRet

/*
Método      : UploadFiles()
Classe      : ELinkBdMan
Parâmetros  : Nenhum
Retorno     : lRet - Indica o resultado da operação
Objetivos   : Faz o upload (envio) dos arquivos locais ao servidor de FTP
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 01/08/2007
Revisao     :
Obs.        :
*/
Method UploadFiles() Class ELinkBdMan
Local lRet

Begin Sequence

   If !Empty(::cError)
      lRet := .F.
      Break
   EndIf

   If ::lInterface
      Processa({|lEnd| lRet := ::AuxUpldFiles(@lEnd) }, STR0003)//"Efetuando upload dos arquivos."
   Else
      lRet := ::AuxUpldFiles()
   EndIf

End Sequence

Return lRet

/*
Método      : AuxUpldFiles(lEnd)
Classe      : ELinkBdMan
Parâmetros  : lEnd - Termina e execução
Retorno     : lRet - Indica o resultado da operação
Objetivos   : Auxiliar ao método UploadFiles()
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 01/08/2007
Revisao     :
Obs.        :
*/

Method AuxUpldFiles(lEnd) Class ELinkBdMan
Local lRet := .T.
Local nTotal := Len(::aFilesUpload), nCount := 0

   If !(lRet := ::GoToFtpDir(::cDirFtpIn))
      ::cError += "O diretório de entrada de arquivos no servidor de FTP não foi encontrado." + ENTER
   EndIf
   ProcRegua(nTotal)
   While lRet .And. (Len(::aFilesUpload) > 0)
      ++nCount
      IncProc(StrTran(StrTran(STR0004, "XXX", AllTrim(Str(nCount))), "YYY", AllTrim(Str(nTotal))))//"Efetuando upload do arquivo XXX/YYY"
      If (lRet := FtpUpload(::cDirLocOut + ::aFilesUpload[1], ::aFilesUpload[1]))
         If ValType(::bUpload) == "B"
            Eval(::bUpload, ::aFilesUpload[1], Self)
         EndIf
         If ::lRemoveFiles
            If !(lRet := !(FErase(::cDirLocOut + ::aFilesUpload[1]) == -1))
               ::cError += StrTran(STR0005, "###", ::aFilesUpload[1])//"Erro ao excluir o arquivo '###' do diretório local de envio de arquivos"
               Exit
            EndIf
         EndIf
         aDel(::aFilesUpload, 1)
         aSize(::aFilesUpload, Len(::aFilesUpload) - 1)
      Else
         ::cError += StrTran(STR0006, "###", ::aFilesUpload[1]) + ENTER//"Erro ao enviar o arquivo '###' para o diretório de destino de arquivos no servidor de FTP"
      EndIf
      IncProc()
      If lEnd
         Exit
      EndIf
   EndDo
   ::GoToFtpDir("/")

Return lRet

/*
Método      : DownloadFiles()
Classe      : ELinkBdMan
Parâmetros  : Nenhum
Retorno     : lRet
Objetivos   : Fazer o download (recebimento) dos arquivos do servidor FTP no sistema local
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 01/08/2007
Revisao     :
Obs.        :
*/
Method DownloadFiles() Class ELinkBdMan
Local lRet

Begin Sequence
   
   If !Empty(::cError)
      lRet := .F.
      Break
   EndIf
   
   If ::lInterface
      Processa({|lEnd| lRet := ::AuxDownFiles(@lEnd) }, STR0007,, .T.)//"Efetuando download dos arquivos."
   Else
      lRet := ::AuxDownFiles()
   EndIf

End Sequence

Return lRet

/*
Método      : AuxDownFiles()
Classe      : ELinkBdMan
Parâmetros  : lEnd - Termina a execução
Retorno     : lRet - Indica o sucesso da operação
Objetivos   : Auxiliar ao método Download files
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 01/08/2007
Revisao     :
Obs.        :
*/
Method AuxDownFiles(lEnd) Class ELinkBdMan
Local lRet := .T.
Local nTotal := Len(::aFilesDownload), nCount := 0

   If !(lRet := ::GoToFtpDir(::cDirFtpOut))
      ::cError += "O diretório de saída de arquivos no servidor de FTP (" + ::cDirFtpOut + ") não foi encontrado." + ENTER
   EndIf
   ProcRegua(nTotal)
   While lRet .And. Len(::aFilesDownload) > 0
      ++nCount
      IncProc(StrTran(StrTran(STR0008, "XXX", AllTrim(Str(nCount))), "YYY", AllTrim(Str(nTotal))))//"Efetuando download do arquivo XXX/YYY"
      If (lRet := FtpDownload(::aFilesDownload[1], ::aFilesDownload[1]))
         If ValType(::bDownload) == "B"
            Eval(::bDownload, ::aFilesDownload[1], Self)
         EndIf
         AvCpyFile("\" + ::aFilesDownload[1], ::cDirLocIn + ::aFilesDownload[1], .F., .T.)
         If ::lRemoveFiles
            FtpDeleteFile(::aFilesDownload[1])
         EndIf
         aDel(::aFilesDownload, 1)
         aSize(::aFilesDownload, Len(::aFilesDownload) - 1)
      Else
         ::cError += StrTran(STR0009, "###", ::aFilesDownload[1]) + ENTER//"Erro ao receber o arquivo '###' do diretório de saída de arquivos no servidor de FTP"
      EndIf
      If lEnd
         Exit
      EndIf
   EndDo
   ::GoToFtpDir("/")

Return lRet

/*
Método      : SetFileMode(cMode)
Classe      : ELinkBdMan
Parâmetros  : cMode - Modo de exibição (Completo/Normal)
Retorno     : Self:cFileMode - Modo atual
Objetivos   : Definir o modo de exibição dos arquivos
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 01/08/2007
Revisao     : 
Obs.        :
*/
Method SetFileMode(cMode) Class ELinkBdMan
Default cMode := ""

   If cMode $ "NORMAL/COMPLETE"
      ::ChangeStoreMode(cMode)
      ::cFileMode := cMode
   EndIf

Return ::cFileMode

/*
Método      : ChangeStoreMode(cNewMode, cOldMode, aChange)
Classe      : ELinkBdMan
Parâmetros  : cNewMode, cOldMode, aChange
Retorno     : 
Objetivos   : 
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 01/08/2007
Revisao     :
Obs.        :
*/
Method ChangeStoreMode(cNewMode, cOldMode, aChange) Class ELinkBdMan
Local nInc
Private aTemp
Private aProps
Private oSelf := Self
Private cSelf := ""
Private bSetMode := {|x, y| nInd := x, aTemp := &(cSelf + aProps[nInd]), &(cSelf + aProps[nInd]) := {}, aEval(aTemp, y) },;
        bComp2Norm := {|x| aAdd(&(cSelf + aProps[nInd]), x[1]) },;
        bNorm2Comp := {|x| aAdd(&(cSelf + aProps[nInd]), {x,"","","",""}) }
Private aUpdate
Default cOldMode := ::cFileMode
Default cNewMode := ""

   If ValType(aChange) == "A"
      aUpdate := aChange
      aProps := {"aUpdate"}
   Else
      aProps := {"aFilesFtp", "aFilesLoc", "aFilesDownload", "aFilesUpload"}
      cSelf := "oSelf:"
   EndIf
        
   If cOldMode == "COMPLETE" .And. cNewMode == "NORMAL"
      For nInc := 1 To Len(aProps)
         Eval(bSetMode, nInc, bComp2Norm)
      Next
      
   ElseIf cOldMode == "NORMAL" .And. cNewMode == "COMPLETE"
      For nInc := 1 To Len(aProps)
         Eval(bSetMode, nInc, bNorm2Comp)
      Next
      
   EndIf

Return aUpdate

/*
Método      : GoToFtpDir(cDir)
Classe      : ELinkBdMan
Parâmetros  : cDir - Diretório a ser acessado
Retorno     : lRet
Objetivos   : Altera o diretório atual do servidor de FTP
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 01/08/2007
Revisao     :
Obs.        :
*/
Method GoToFtpDir(cDir) Class ELinkBdMan
Local lRet := .F.
Default cDir := ""
   
   If Len(cDir) <> 0
      lRet := FtpDirChange(cDir)
   EndIf

Return lRet

/*
Método      : SetDirFtpIn(cDir)
Classe      : ELinkBdMan
Parâmetros  : cDir - Nome do diretório
Retorno     : lRet
Objetivos   : Define o diretório de entrada de arquivos (enviados pela classe) no servidor de FTP
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 01/08/2007
Revisao     :
Obs.        :
*/
Method SetDirFtpIn(cDir) Class ELinkBdMan
Local lRet := .F.

   If ValType(cDir) == "C"
      ::cDirFtpIn := cDir
      lRet := .T.
   EndIf
   
Return lRet

/*
Método      : SetDirFtpOut(cDir)
Classe      : ELinkBdMan
Parâmetros  : cDir - Nome do diretório
Retorno     : lRet
Objetivos   : Alterar o diretório de saída de arquivos no servidor de FTP
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 01/08/2007
Revisao     :
Obs.        :
*/
Method SetDirFtpOut(cDir) Class ELinkBdMan
Local lRet := .F.

   If ValType(cDir) == "C"
      ::cDirFtpOut := cDir
      lRet := .T.
   EndIf

Return lRet

/*
Método      : SetDirLocIn(cDir)
Classe      : ELinkBdMan
Parâmetros  : cDir - Nome do diretório
Retorno     : lRet
Objetivos   : Definir o diretório local (no servidor Protheus) de recebimento de arquivos
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 01/08/2007
Revisao     :
Obs.        :
*/
Method SetDirLocIn(cDir) Class ELinkBdMan
Local lRet := .F.

   If ValType(cDir) == "C"
      ::cDirLocIn := cDir
      lRet := .T.
   EndIf
   
Return lRet

/*
Método      : SetDirLocOut(cDir)
Classe      : ELinkBdMan
Parâmetros  : cDir - Nome do diretório
Retorno     : lRet
Objetivos   : Definir o diretório local (no servidor Protheus) de envio de arquivos
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 01/08/2007
Revisao     :
Obs.        :
*/
Method SetDirLocOut(cDir) Class ELinkBdMan
Local lRet := .F.

   If ValType(cDir) == "C"
      ::cDirLocOut := cDir
      lRet := .T.
   EndIf
   
Return lRet

/*
Método      : SetServer(cServer)
Classe      : ELinkBdMan
Parâmetros  : cServer - Endereço do servidor
Retorno     : lRet
Objetivos   : Definir o endereço do servidor (remoto) de FTP que irá ser acessado
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 01/08/2007
Revisao     :
Obs.        :
*/
Method SetServer(cServer) Class ELinkBdMan
Local lRet := .F.

   If ValType(cServer) == "C"
      ::cServer := cServer
      lRet := .T.
   EndIf

Return lRet

/*
Método      : SetPort(nPort)
Classe      : ELinkBdMan
Parâmetros  : nPort - Número da porta
Retorno     : lRet
Objetivos   : Definir a porta de acesso ao servidor (remoto) de FTP
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 01/08/2007
Revisao     :
Obs.        :
*/
Method SetPort(nPort) Class ELinkBdMan
Local lRet := .F.

   If ValType(nPort) == "N"
      ::nPort := nPort
      lRet := .T.
   EndIf
   
Return lRet

/*
Método      : SetUser(cUser)
Classe      : ELinkBdMan
Parâmetros  : cUser - Nome do usuário
Retorno     : lRet
Objetivos   : Definir o usuário que será informado ao efetuar acesso no servidor de FTP
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 01/08/2007
Revisao     :
Obs.        :
*/
Method SetUser(cUser) Class ELinkBdMan
Local lRet := .F.

   If ValType(cUser) == "C"
      ::cUser := cUser
      lRet := .T.
   EndIf
   
Return lRet

/*
Método      : SetPass(cPass)
Classe      : ELinkBdMan
Parâmetros  : cPass - Senha do usuário
Retorno     : lRet
Objetivos   : Definir a senha de usuário que será informada ao efetuar acesso ao servidor de FTP
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 01/08/2007
Revisao     :
Obs.        :
*/
Method SetPass(cPass) Class ELinkBdMan
Local lRet := .F.

   If ValType(cPass) == "C"
      ::cPass := cPass
      lRet := .T.
   EndIf
   
Return .T.

/*
Método      : GetFtpFileList(cOpc)
Classe      : ELinkBdMan
Parâmetros  : cOpc - (DOWNLOAD/UPLOAD) - Define qual diretório será verificado
Retorno     : Self:aFilesFtp
Objetivos   : Retorna e armazena no atributo aFilesFtp a lista de arquivos de diretório de entrada (UPLOAD) ou de saída (DONWLOAD) do servidor FTP, conforme
              o tipo de arquivos definido
              Ex: Modo normal - Self:aFilesFtp = {"ARQUIVO1", "ARQUIVO2", ..., "ARQUIVOn"}
                  Modo completo - Self:aFilesFto = {{"ARQUIVO1", "ATRIBUTO", "ATRIBUTO", "ATRIBUTO", "ATRIBUTO"}, ...}
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 01/08/2007
Revisao     :
Obs.        :
*/
Method GetFtpFileList(cOpc) Class ELinkBdMan
Local cDir
Default cOpc := ""

   If cOpc == "DOWNLOAD"
      cDir := ::cDirFtpOut
   ElseIf cOpc == "UPLOAD"
      cDir := ::cDirFtpIn
   EndIf
   If ::GoToFtpDir(cDir)
      ::aFilesFtp := FtpDirectory("*.*")
      If ::cFileMode <> "COMPLETE"
         ::aFilesFtp := ::ChangeStoreMode(::cFileMode, "COMPLETE", ::aFilesFtp)
      EndIf
      ::GoToFtpDir("/")
   EndIf

Return ::aFilesFtp

/*
Método      : GetLocFileList()
Classe      : ELinkBdMan
Parâmetros  : cOpc - (DOWNLOAD/UPLOAD) - Define qual diretório será verificado
Retorno     : Self:aFilesLoc
Objetivos   : Retorna e armazena no atributo aFilesLoc a lista de arquivos de diretório de entrada (UPLOAD) ou de saída (DONWLOAD) locais, conforme
              o tipo de arquivos definido
              Ex: Modo normal - Self:aFilesLoc = {"ARQUIVO1", "ARQUIVO2", ..., "ARQUIVOn"}
                  Modo completo - Self:aFilesLoc = {{"ARQUIVO1", "ATRIBUTO", "ATRIBUTO", "ATRIBUTO", "ATRIBUTO"}, ...}
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 01/08/2007
Revisao     :
Obs.        :
*/
Method GetLocFileList(cOpc) Class ELinkBdMan
Local cDir := ""
Default cOpc := ""

   If cOpc == "DOWNLOAD"
      cDir := ::cDirLocIn
   ElseIf cOpc == "UPLOAD"
      cDir := ::cDirLocOut
   EndIf
   ::aFilesLoc := Directory(cDir + "*.*")
   If ::cFileMode <> "COMPLETE"
      ::aFilesLoc := ::ChangeStoreMode(::cFileMode, "COMPLETE", ::aFilesLoc)
   EndIf
   
Return ::aFilesLoc

/*
Método      : DownloadList(xFile)
Classe      : ELinkBdMan
Parâmetros  : xFile - Nome do arquivo a ser incluído na lista, ou array com vários arquivos, conforme modo definido
Retorno     : ::aFilesDownload - Lista de arquivos definidos para download (conforme modo de armazenamento)
Objetivos   : Inclui um arquivo (ou uma lista) na lista de arquivos marcados para download
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 01/08/2007
Revisao     :
Obs.        :
*/
Method DownloadList(xFile) Class ELinkBdMan
Default xFile := ""

Begin Sequence

   If ValType(xFile) == "A"
      If Len(xFile) > 0 .And. ValType(xFile[1]) == "A"
         If Len(xFile[1]) == 5
            xFile[1] := xFile[1][1]
         Else
            Break
         EndIf
      EndIf
      aEval(xFile, {|x| ::DownloadList(x)})
   ElseIf ValType(xFile) == "C" .And. Len(xFile) > 0
      aAdd(::aFilesDownload, xFile)
   EndIf
   
End Sequence

Return ::aFilesDownload

/*
Método      : UploadList(xFile)
Classe      : ELinkBdMan
Parâmetros  : xFile - Nome do arquivo a ser incluído na lista, ou array com vários arquivos, conforme modo definido
Retorno     : ::aFilesUpload - Lista de arquivos definidos para upload (conforme modo de armazenamento)
Objetivos   : Inclui um arquivo (ou uma lista) na lista de arquivos marcados para upload
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 01/08/2007
Revisao     :
Obs.        :
*/
Method UploadList(xFile) Class ELinkBdMan
Default xFile := ""

Begin Sequence

   If ValType(xFile) == "A"
      If Len(xFile) > 0 .And. ValType(xFile[1]) == "A"
         If Len(xFile[1]) == 5
            xFile[1] := xFile[1][1]
         Else
            Break
         EndIf
      EndIf
      aEval(xFile, {|x| ::UploadList(x)})
   ElseIf ValType(xFile) == "C" .And. Len(xFile) > 0
      aAdd(::aFilesUpload, xFile)
   EndIf
   
End Sequence

Return ::aFilesUpload

/*
Método      : GetError()
Classe      : ELinkBdMan
Parâmetros  : Nenhum
Retorno     : Self:cError - Log de erros
Objetivos   : Retornar o log de erros encontrados na execução da instância da classe
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 01/08/2007
Revisao     :
Obs.        :
*/
Method GetError() Class ELinkBdMan
Return ::cError
