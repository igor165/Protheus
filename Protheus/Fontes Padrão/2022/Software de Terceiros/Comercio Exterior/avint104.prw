#INCLUDE "PROTHEUS.CH"  

/*
Programa        : AVINT104.PRW
Objetivo        : Classe generica pra integração de arquivos
Autor           : Rodrigo Mendes Dias/ Allan Oliveira Monteiro
Data/Hora       : 26/07/2010 
Obs.            :
*/

Function AvInt104()
Return Nil

Class AvImport

    Data aTipos
	Data cTipo
	Data aDados
	Data aHeader
	Data cSeparador
	Data cDecimalSimb
	Data cFile
	Data cTmpFile
	Data lDelTemp
	Data oXML
	
	Data cLOG
	
	//*** Construtor
	Method New() Constructor
	//***
	
	//*** Metodos de definição da importação
	Method SetType(cTipo)
	Method SetSeparador(cSeparador)
	Method SetDecSimb(cDecimalSimb)
	Method SetFile(cFile)
	Method AddField()
	//***
	
	//*** Metodos de retorno das informacoes importadas
	Method RetField(cCampo, nLinha)
	//***
    
    //*** Metodo de interface para seleção do arquivo
	Method ChooseFile()
	//***
    
	//*** Executa a importação
	Method Import()
	Method ImportP()
	//***
	
	//*** Metodos de framework interna (reservados)
	Method __SetValType(cCont, nPos)
	//***
	

End Class


//////////////////////////////////////////
//           Método Construtor          //
//////////////////////////////////////////

Method New() Class AvImport

   Self:aTipos			:= {}
   aAdd(Self:aTipos, {"CSV", "Arquivos de Texto" + "|*.csv |"})
   
   Self:cSeparador 		:= ";"
   Self:cDecimalSimb	:= ","
   Self:cTipo			:= ""
   Self:cFile           := ""
   Self:aDados			:= {}
   Self:aHeader			:= {}
   Self:lDelTemp		:= .T. //RMD - 26/05/15 - Possibilita manter o arquivo no servidor.
   Self:cLog            := ""  //RMD - 18/06/15 - Guarda as mensagens

Return Self



//////////////////////////////////////////
//           Método SetSeparador        //
//////////////////////////////////////////

Method SetSeparador(cSeparador) Class AvImport

   If ValType(cSeparador) == "C" .And. Len(cSeparador) > 0
      Self:cSeparador := cSeparador
   EndIf

Return Self:cSeparador 

Method SetDecSimb(cDecimalSimb) Class AvImport

   If ValType(cDecimalSimb) == "C" .And. Len(cDecimalSimb) > 0
      Self:cDecimalSimb := cDecimalSimb
   EndIf

Return Self:cDecimalSimb



//////////////////////////////////////////
//           Método AddField            //
//////////////////////////////////////////

Method AddField(cNome, cTipo, nTamanho, nDecimal) Class AvImport
Default cTipo    := "C"
Default nTamanho := 0
Default nDecimal := 0

   If ValType(cNome) == "C"
      aAdd(Self:aHeader, {cNome, cTipo, nTamanho, nDecimal})
   EndIf

Return Nil



//////////////////////////////////////////
//           Método __SetValType        //
//////////////////////////////////////////

Method __SetValType(cCont, nPos) Class AvImport
Local xRet, cTipo, nTamanho, nDecimal

Begin Sequence

   If Len(Self:aHeader) < nPos
      xRet := cCont
      Break
   EndIf
   
   cTipo	:= Self:aHeader[nPos][2]
   nTamanho	:= Self:aHeader[nPos][3]
   nDecimal	:= Self:aHeader[nPos][4]

   Do Case
      Case cTipo == "C"
         xRet := IncSpace(cCont, nTamanho, .F.)

      Case cTipo == "N"
         If Self:cDecimalSimb == ","
            cCont := StrTran(cCont, ".", "")
            cCont := StrTran(cCont, ",", ".")
         Else
            cCont := StrTran(cCont, ",", "")
         EndIf
         If nDecimal > 0
            SET DECIMALS TO nDecimal
            SET FIXED ON
         EndIf
         xRet := Val(cCont)

      Case cTipo == "D"
         xRet := StrTran(cCont, "/", "")
         xRet := SUBSTR(xRet,05,04)+SUBSTR(xRet,03,02)+SUBSTR(xRet,01,02)
         xRet := STOD(xRet)
         
   EndCase

End Sequence

Return xRet



//////////////////////////////////////////
//           Método SetType             //
//////////////////////////////////////////

Method SetType(cTipo) Class AvImport
Local nPos

   If ValType(cTipo) == "C" .And. (nPos:= aScan(Self:aTipos, {|x| x[1] == Upper(cTipo) })) > 0
      Self:cTipo := Upper(cTipo)
   EndIf

Return Self:cTipo 



//////////////////////////////////////////
//           Método Import              //
//////////////////////////////////////////

Method Import(lProgress) Class AvImport
Local xRet
Local bImport := {|| xRet := Self:ImportP(lProgress)}
Default lProgress := !IsBlind()//.T. - RMD - 13/08/15 - Testa se está sendo executado via JOB

If lProgress
   Private oProgress := EasyProgress():New()
   oProgress:SetProcess(bImport,"Lendo arquivo...")
   oProgress:Init()
Else
   Eval(bImport)
EndIf

Return xRet

Method ImportP(lProgress) Class AvImport
Local cLine, cTexto    // GFP - 06/02/2013
Local nPos, nPos2, nCampo   // GFP - 06/02/2013
Local lRet := .T.
Local lAux := .T.
Local lUTF8:= .F.
Local nPerc   := 0
Local nTotReg := 0
Local i := 0
Local cError := cWarning := ""

Begin Sequence
   
   If Empty(Self:cFile)
      MsgInfo("Nome do arquivo não informado.","Aviso")
      lRet := .F.
      Break
   EndIf

   If Right(AllTrim(Lower(Self:cFile)), 4) == ".xml"
      Self:oXML := XMLParserFile(Self:cFile, "_", @cError, @cWarning)
      If !Empty(cError+cWarning)
      	EasyHelp("Erro ao importar o arquivo:" + ENTER + cError + ENTER + cWarning)
      	lRet := .F.
      	Break
      EndIf
   Else
	   Self:aDados := {}
	   FT_FUSE(Self:cFile)
	   FT_FGOTOP()
	   
	   If lProgress
	      oProgress:SetRegua(FT_FLastRec())
	   EndIf
	   
	   If Left(FT_FReadLn(),3) ==  "ï»¿" //Le e Pula o BOM (Byte Order Mark) UTF-8
	      lUTF8 := .T.
	      FT_FGOTO(4)
	   EndIf
	   
	   lMemo := .F.
   EndIf
   Do While /*i <= nTotReg .OR.*/ !Empty(cLine := If(lUTF8,DecodeUTF8(FT_FReadLn()),StrTran(FT_FReadLn(),CHR(9),"")))// Não usar FT_FEOF() pois fica muito lento.
	      if(!lMemo,nCampo := 1,)
	      
		  cLine := If(lUTF8,DecodeUTF8(FT_FReadLn()),StrTran(FT_FReadLn(),CHR(9),""))
	      
	      If !Empty(cLine)
	         If !lMemo
	            aAdd(Self:aDados, {})
	         EndIf
	         
	         lLoop := .T.
	         While lLoop
	            
	            If lMemo
	               nPosPV    := 0
	               nPosASPAS := 1
	               While (nPosASPAS  := At('"', cLine, nPosASPAS)) == (nPosASPAS2 := At('""', cLine,nPosASPAS)) .AND. nPosASPAS > 0
	                  nPosASPAS+=2
	               EndDo
	            Else
	               nPosPV     := At(Self:cSeparador, cLine)
	               nPosASPAS  := At('"', cLine)
	               nPosASPAS2 := At('""', cLine)
	            EndIf
	         
	            If nPosASPAS > 0 .AND. (nPosASPAS < nPosPV .OR. nPosPV == 0) .AND. nPosASPAS <> nPosASPAS2
	               
	               If lMemo
	                  cTexto += Chr(10)+StrTran(SubStr(cLine,1,nPosASPAS-1),'""','"')
	                  lMemo  := .F.
	                  nPosPV := At(Self:cSeparador, cLine, nPosASPAS)
	               Else
	               
	                  cTexto := SubStr(cLine, 2, Len(cLine))
	                  nPos2 := 1
	                  While (nPos2 := At('"', cTexto, nPos2)) > 0 .AND. SubStr(cTexto,nPos2+1,1) == '"'
	                     nPos2+=2
	                  EndDo
	   
	                  If nPos2 == 0
	                     //Não encontrou a aspas que fecha
	                     lMemo := .T.
	                     cTexto := StrTran(cTexto,'""','"')
	                  Else
	                     cTexto := SubStr(cLine, 2, nPos2-1)
	                     cTexto := StrTran(cTexto,'""','"')
	                     nPosPV   := At(Self:cSeparador, cLine, nPos2)
	                  EndIf
	               EndIf
	            ElseIf nPosPV > 0
	               cTexto := Left(cLine, nPosPV - 1)
               If !lMemo .AND. nPosASPAS > 0 .AND. cTexto == '""' 
                  cTexto := ""
               Else                                
                  cTexto := StrTran(cTexto,'""','"')
               EndIf
            Else
               If !lMemo .AND. nPosASPAS > 0 .AND. cLine == '""' 
                  cLine := ""
               Else                                
                  cLine := StrTran(cLine,'""','"')
               EndIf
               
               If lMemo
                  cTexto += Chr(10)+cLine
               Else
                  cTexto := cLine
               EndIf
            EndIf
            
            if !lMemo
               aAdd(Self:aDados[Len(Self:aDados)], Self:__SetValType(cTexto, nCampo))
               ++nCampo
               cLine := SubStr(cLine, nPosPV + 1)
            EndIf
         
            lLoop := !lMemo .AND. nPosPV > 0
         EndDo

	  EndIf
	  
	  If lProgress
	     If !oProgress:IncRegua()
   	        Self:aDados := {}
   	        BREAK
	     EndIf
	  EndIf
      
	  FT_FSKIP()
	  i++
      
   EndDo

   FT_FUSE()//Fecha o arquivo
   
   If !Empty(Self:cTmpFile) .And. Self:lDelTemp//RMD - 26/05/15 - Possibilita manter o arquivo no servidor.
      FErase(Self:cTmpFile)
      Self:cTmpFile := ""
   EndIf

End Sequence

Return lRet


//////////////////////////////////////////
//           Método ChooseFile          //
//////////////////////////////////////////

Method ChooseFile(cTitle,cMask,cDefaultDir,nOptions,bValid,lCopySrv,cTmpDir,lDelTemp) Class AvImport
Local cFile := ""
Local nDefaultMask := 0, nPos
Local cGetFile := ""
Local cDrive
Local cNomeArq
Local cExt
Default cTitle := "Nome do Arquivo"
Default cMask  := "Todos os Arquivos" + "|*.*"
Default cDefaultDir := "C:\"
Default nOptions    := GETF_OVERWRITEPROMPT+GETF_LOCALHARD+GETF_NETWORKDRIVE
Default bValid      := {|| .T.}
Default lCopySrv    := .T.
Default cTmpDir := "\Comex\"
Default lDelTemp := .T.

   If (nPos := aScan(Self:aTipos, {|x| x[1] == Self:cTipo })) > 0
      cMask := Self:aTipos[nPos][2] + cMask
   EndIf

   Do While (cFile := cGetFile(cMask,cTitle,nDefaultMask,cDefaultDir,,nOptions),!Empty(cFile) .AND. !Eval(bValid,cFile))
   EndDo

   Self:cTmpFile := ""
   
   If !Empty(cFile)
      If lCopySrv .AND. File(cFile)
      	 
      	 Self:lDelTemp := lDelTemp//RMD - 26/05/15 - Possibilita manter o arquivo no servidor.
      	 
         SplitPath(cFile,@cDrive,,@cNomeArq,@cExt)
         
      EndIf
   
      Self:SetFile(cFile, cTmpDir)
   EndIf

Return cFile

Function INT104ValTipo(cArquivo,xTipo)
Local lRet := .T.
Local cArq := AllTrim(cArquivo)
Local cTip := ""

Begin Sequence
   
   If ValType(xTipo) == "A"
      aTipos := xTipo
   ElseIf ValType(xTipo) == "C"
      aTipos := {xTipo}
   Else
      aTipos := {}
   EndIf
   
   If !(lRet := aScan(aTipos,{|X| X := Upper(AllTrim(X)), cTip += X+",", X == Upper(SubStr(cArq,Len(cArq)-Len(X)+1))}) > 0)
      cTip := SubStr(cTip,1,Len(cTip)-1)
      If (nPos := Rat(",",cTip)) > 0
         cTip := SubStr(cTip,1,nPos-1)+" e "+SubStr(cTip,nPos+1)+"."
      EndIf
      If !Empty(cTip)
         EasyHelp("Tipo de arquivo não permitido. Arquivos permitidos são "+cTip)
      EndIf
   EndIf
   
End Sequence

Return lRet

//////////////////////////////////////////
//           Método SetFile             //
//////////////////////////////////////////

Method SetFile(cFile, cTmpDir) Class AvImport
Local cDrive
Local cNomeArq
Local cExt
Local lServerPath := .F.
Default cTmpDir := "\Comex\"

   If ValType(cFile) == "C" .And. !Empty(cFile)

      SplitPath(cFile,@cDrive,,@cNomeArq,@cExt)
      
      If Left(cFile, 1) == "\" //Para caminho relativo ou de rede
         lServerPath := .T.
      EndIf

      If !Empty(cDrive) .Or. lServerPath

         IF !lIsDir(cTmpDir)
            MakeDir(cTmpDir)
         Endif
            
         //RMD - 26/05/15 - Possibilita manter o arquivo no servidor.
         If !Self:lDelTemp .And. File(cTmpDir+cNomeArq+cExt)
            cLOG += "O arquivo informado já foi importado anteriormente."
            Return ""
         EndIf

         If lServerPath
            Self:cTmpFile := cTmpDir+cNomeArq+if(!Empty(cExt),cExt,"") 
            copy file (cFile) to (Self:cTmpFile)
         Else
	         If CpyT2S(cFile, cTmpDir, .T.)
	            Self:cTmpFile := cTmpDir+cNomeArq+if(!Empty(cExt),cExt,"") 
	         EndIf
         EndIf
            
         If File(Self:cTmpFile)
            cFile := Self:cTmpFile
         EndIf

         Self:cFile := cFile
      EndIf
      
   EndIf
   
Return Self:cFile


//////////////////////////////////////////
//           Método RetField            //
//////////////////////////////////////////

Method RetField(cCampo, nLinha) Class AvImport
Local xRet
Local nCol

   If (nCol := aScan(Self:aHeader, {|x| x[1] == cCampo })) > 0
      xRet := Self:aDados[nLinha][nCol]
   EndIf

Return xRet