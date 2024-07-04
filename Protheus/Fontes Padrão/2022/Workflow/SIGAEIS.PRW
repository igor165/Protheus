/*Esta Função transfere os arquivos(parâmetro Files, com mascara), compactando-os para o arquivo
 NameFileDest, copiando-o para o diretório PathDest */
Function AP52EIS(Files,NameFileDest,PathDest)
	Local i
	Local cDestFile := ""
  //Pego o Diretório dos arquivos a serem compactados        
  For i:=Len(Files) TO 1 step -1 
    if Subs(Files,i,1) == '\' 
      Exit
    endif
  end
  cDestFile := Subs(Files,1,i-1)
  CpyS2T( Files, PathDest, .T. )
/*
  // Compacta os Arquivos no Server.
  // A Sintaxe do wzzip é 'wzzip.exe destino arquivos'
  WAITRUN("c:\progra~1\winzip\wzzip "+cDestFile+"\"+NameFileDest+" "+Files)

  //Copio o arquivo para a Estação
  Ori  := cDestFile+"\"+NameFileDest+".zip"
  Dest := PathDest+"\"+NameFileDest+".ZIP"
  Copy File &Ori To &Dest
  
  //descompacta os arquivos na estação
  // A Sintaxe do wzunzip é 'wzunzip.exe zipfile destino'
  WAITRUN("c:\progra~1\winzip\wzunzip "+PathDest+"\"+NameFileDest+".ZIP "+PathDest)  
  //Copia os Files  */
return  

Function EISInSrv(cExec,cDir)
  WaitRunSrv(cExec,.T.,cDir)
Return .T.
