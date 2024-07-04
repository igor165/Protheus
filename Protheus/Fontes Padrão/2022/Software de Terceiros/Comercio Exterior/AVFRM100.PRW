#Include "Average.Ch"
 
//Definição dos campos de Status (XXX_STATUS) das tabelas do IMonitor
#Define ITRECEBIDOS   "A"
#Define ITENVIADOS    "B"
#Define ITNAOENVIADOS "C"
#Define ITPROCESSADOS "D"

#Define DIR_INBOUND		"comex\easylink\inttra\inbound\"
#Define DIR_OUTBOUND	"comex\easylink\inttra\outbound\"
#Define DIR_SENT        "comex\easylink\inttra\outbound\sent\"

/*
Programa   : AvFrm100.prw
Objetivo   : Reunir as classes de integração com o sistema Inttra
Autor      : Rodrigo Mendes Diaz
Data/Hora  : 08/02/07
Obs        : 
*/

/*
Classe      : AvILink (Integração FTP Inttra)
Classe Pai  : ELinkBdMan
Objetivos   : Enviar e receber via FTP arquivos de integração entre o Protheus e o Inttra
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 01/08/07
Revisao     : 
Obs.        : 
*/
Class AvILink From ELinkBdMan

Data cStatus
Data cError

Method New() Constructor
Method InttraDefs()
Method InttraSend()
Method InttraReceive()
Method FileAlias(cFile)
Method SetFileName(cOpc)
Method SendUpdate(cFile)
Method RecUpdate(cFile)

End Class

/*
Método      : New(lInterface)
Classe      : AvILink
Parâmetros  : lInterface - Indica se a função pode exibir mensagens ao usuário (.F. quando executada via Schedule)
Retorno     : Self - Nova instância da classe
Objetivos   : Gerar nova instância da classe de integração
Data/Hora   : 01/08/2007
Revisao     :
Obs.        :
*/
Method New(lInterface) Class AvILink
Default lInterface := Type("oMainWnd") == "O"

   ::cStatus := ""
   ::cError  := ""
   ::SetComType("FTP")
   ::SetFileMode("NORMAL")
   ::InttraDefs()
   ::lRemoveFiles := .T.
   ::bDownload := {|cFile, Self| Self:RecUpdate(cFile)  }
   ::bUpload   := {|cFile, Self| Self:SendUpdate(cFile) }
   ::lInterface := lInterface
   
Return Self

/*
Método      : InttraDefs
Classe      : AvILink
Parâmetros  : Nenhum
Retorno     : lRet
Objetivos   : Definir os parâmetros da classe conforme os dados de acesso ao Inttra, além dos diretórios padrão.
Data/Hora   : 01/08/2007
Revisao     :
Obs.        :
*/
Method InttraDefs() Class AvILink
Local lRet := .T.
Local cServer    := EasyGParam("MV_AVG0147",,"")
Local cUser      := EasyGParam("MV_AVG0148",,"")
Local cPass      := EasyGParam("MV_AVG0149",,"")
Local cDirLocIn  := DIR_INBOUND
Local cDirLocOut := DIR_OUTBOUND

Begin Sequence
   
   If !(lRet := ::SetServer(cServer)) .Or.;
      !(lRet := ::SetUser(cUser)) .Or.;
      !(lRet := ::SetPass(cPass)) .Or.;
      !(lRet := ::SetDirLocIn(cDirLocIn)) .Or.;
      !(lRet := ::SetDirLocOut(cDirLocOut)) .Or.;
      !(lRet := ::SetPort(21))
      Break
   EndIf

End Sequence
   
Return lRet

/*
Método      : InttraSend
Classe      : AvILink
Parâmetros  : Nenhum
Retorno     : lRet
Objetivos   : Enviar os arquivos de integração gerados ao servidor do Sistema Inttra.
Data/Hora   : 01/08/2007
Revisao     :
Obs.        :
*/
Method InttraSend() Class AvILink
Local aOrd := SaveOrd("EYM")
Local lRet := .F.
Local cDirFtpIn  := "inbound"

Begin Sequence

   If Empty(::GetError()) .And. ::SetDirFtpIn(cDirFtpIn)
      ::GetLocFileList("UPLOAD")
      ::SetFileName("UPLOAD")
      ::UploadList(::aFilesLoc)
      lRet := ::UploadFiles()
   EndIf

End Sequence

RestOrd(aOrd, .T.)
Return lRet

/*
Método      : SendUpdate(cFile)
Classe      : AvILink
Parâmetros  : cFile - Nome do arquivo enviado
Retorno     : .t.
Objetivos   : Executada a cada envio (com sucesso) de arquivo ao Inttra, atualiza as tabelas do IMonitor
Data/Hora   : 01/08/2007
Revisao     :
Obs.        :
*/
Method SendUpdate(cFile) Class AvILink

   cAlias := ::FileAlias(cFile)
   If !Empty(cAlias) .And. (cAlias)->(DbSetOrder(1), DbSeek(xFilial() + AvKey(Lower(cFile), cAlias + "_FILE" )))
      Copy_File(DIR_OUTBOUND, cFile, DIR_SENT)
      (cAlias)->(RecLock(cAlias, .F.))
      (cAlias)->&(cAlias + "_STATUS") := ITENVIADOS
      (cAlias)->&(cAlias + "_DTENV")  := dDatabase
      (cAlias)->&(cAlias + "_HRENV")  := Time()
      (cAlias)->(MsUnlock())
      Frm101SetStatus((cAlias)->&(cAlias + "_PROC"))
   EndIf

Return .T.

Static Function Copy_File(cOrigem, cFile, cDest)

   If !lIsDir(cDest)
      CriaDir(cDest)
   EndIf
   
   AvCpyFile(cOrigem + cFile, cDest + cFile, .T., .F.)

Return Nil

Static Function CriaDir(cDirNew)
Local cDiretorio := "\", nInc
Local aFolders := SplitDir(cDirNew)

   For nInc := 1 To Len(aFolders)
      If !lIsDir(cDiretorio + aFolders[nInc])
         MakeDir(cDiretorio + aFolders[nInc])
      EndIf
      cDiretorio += aFolders[nInc]
   Next

Return lIsDir(cDirNew)

Static Function SplitDir(cDir)
Local aSplit := {}
Local nPos

   While (nPos := At("\", cDir)) > 0
      aAdd(aSplit, Left(cDir, nPos))
      cDir := SubStr(cDir, nPos + 1)
   EndDo

Return aSplit


/*
Método      : RecUpdate(cFile)
Classe      : AvILink
Parâmetros  : cFile - Nome do arquivo enviado
Retorno     : .t.
Objetivos   : Executada a cada recebimento (com sucesso) de arquivo do Inttra, atualiza as tabelas do IMonitor
Data/Hora   : 01/08/2007
Revisao     :
Obs.        :
*/
Method RecUpdate(cFile) Class AvILink

   cAlias := ::FileAlias(cFile)
   If !Empty(cAlias) .And. !(cAlias)->(DbSetOrder(1), DbSeek(xFilial() + AvKey(cFile, cAlias + "_FILE" )))
      (cAlias)->(RecLock(cAlias, .T.))
      (cAlias)->&(cAlias + "_FILIAL") := xFilial(cAlias)
      (cAlias)->&(cAlias + "_STATUS") := ITRECEBIDOS
      (cAlias)->&(cAlias + "_FILE")   := AvKey(cFile, cAlias + "_FILE" )
      (cAlias)->&(cAlias + "_DTREC")  := dDatabase
      (cAlias)->&(cAlias + "_HRREC")  := Time()
      (cAlias)->&(cAlias + "_USER")   := If(Type("cUser") <> "C", SubStr(cUsuario, 7, 15), cUser)
      (cAlias)->(MsUnlock())
   EndIf

Return .T.

/*
Método      : FileAlias(cFile)
Classe      : AvILink
Parâmetros  : cFile - Nome do arquivo
Retorno     : .t.
Objetivos   : Define a tabela do IMonitor correspondente ao arquivo a partir do seu nome.
Data/Hora   : 01/08/2007
Revisao     :
Obs.        :
*/
Method FileAlias(cFile) Class AvILink
Local cAlias

   If ("IFTMBC" $ Upper(cFile)) .Or. ("IFTMBF" $ Upper(cFile))
      //Booking
      cAlias := "EYM"
   ElseIf ("APERAK" $ Upper(cFile)) .Or. ("IFTMIN" $ Upper(cFile))
      //SI
      cAlias := "EYN"
   ElseIf ".ZIP" $ Upper(cFile)
      // B/L
      cAlias := "EYP"
   ElseIf "IFTSTA" $ Upper(cFile)
      //Track&Trace
      cAlias := "EYO"
   Else
      cAlias := ""
   EndIf

Return cAlias

/*
Método      : InttraReceive
Classe      : AvILink
Parâmetros  : Nenhum
Retorno     : lRet
Objetivos   : Receber os arquivos de integração gerados pelo servidor do Sistema Inttra.
Data/Hora   : 01/08/2007
Revisao     :
Obs.        :
*/
Method InttraReceive() Class AvILink
Local lRet := .F.
Local nInc
Local aDirFtpOut := {"/outbound", "/outbound/webbl"}

Begin Sequence

   For nInc := 1 To Len(aDirFtpOut)
      If Empty(::GetError()) .And. ::SetDirFtpOut(aDirFtpOut[nInc])
         ::GetFtpFileList("DOWNLOAD")
         ::SetFileName("DOWNLOAD")
         ::DownloadList(::aFilesFTP)
         lRet := ::DownloadFiles()
      EndIf
   Next

End Sequence

Return lRet

/*
Método      : SetFileName
Classe      : AvILink
Parâmetros  : Nenhum
Retorno     : Nenhum
Objetivos   : Acertar os nomes dos arquivos do servidor FTP (retornados todos em maiúsculo pelo Protheus), devido ao servidor de FTP do Inttra ser Unix (case-sensitive)
Data/Hora   : 01/08/2007
Revisao     :
Obs.        :
*/
Method SetFileName(cOpc) Class AvILink
Local nInc
Local bChange := {|x| StrTran(x, ".XML", ".xml") }
Default cOpc := ""

   If cOpc == "DOWNLOAD"
      For nInc := 1 To Len(::aFilesFtp)
         ::aFilesFtp[nInc] := Left(::aFilesFtp[nInc], Len(AllTrim(::aFilesFtp[nInc])) - 4) + Lower(SubStr(::aFilesFtp[nInc], Len(AllTrim(::aFilesFtp[nInc])) - 3, 4))
      Next
   ElseIf cOpc == "UPLOAD"
      For nInc := 1 To Len(::aFilesLoc)
         ::aFilesLoc[nInc] := Left(::aFilesLoc[nInc], Len(AllTrim(::aFilesLoc[nInc])) - 4) + Lower(SubStr(::aFilesLoc[nInc], Len(AllTrim(::aFilesLoc[nInc])) - 3, 4))
      Next
   EndIf

Return

/*
Função      : Frm100ILink
Parâmetros  : Nenhum
Retorno     : cRet - Log de erros da execução
Objetivos   : Instanciar a classe AvILink e executar os métodos de envio e recebimento de arquivos
Data/Hora   : 01/08/2007
Revisao     :
Obs.        :
*/
Function Frm100ILink()
Local lRet
Local cRet := ""
Local oILink := AvILink():New()

   oILink:Connect()
   If (lRet := oILink:InttraSend())
      (lRet := oILink:InttraReceive())
   EndIf
   oILink:Disconnect()

   If !lRet
      cRet := oILink:GetError() + ENTER
   EndIf

Return cRet
