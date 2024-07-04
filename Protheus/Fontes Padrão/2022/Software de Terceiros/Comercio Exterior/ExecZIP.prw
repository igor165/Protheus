Function ExecZIP()
Local cDir     := "C:"
Local cArquivo := "LoteZip.vbs"

//WinExec(cDir+cArquivo)
WAITRUN(cArquivo + " " + cDir)

Return