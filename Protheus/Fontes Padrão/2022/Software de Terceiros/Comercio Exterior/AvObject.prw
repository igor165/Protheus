#include "Average.ch" 

Function AvObject()
Return Nil

Class AvObject From LongNameClass
   
   Data aParent
   Data cClassName
   Data aError
   Data nErrSize
   Data aWarning
   Data lError
   
   Method New()
   Method setClassName()
   Method ClassName()
   Method Clone()
   Method ValidaParam()
   Method Error()
   Method Warning()
   Method GetStrErrors()
   Method ResetError()
   Method ShowErrors()
   Method HasErrors()
   Method SaveLog(cFileName, cHeader) //RMD - 08/03/16 - Método para gravação de arquivo de log com o mesmo conteúdo exibido no método ShowErrors
   
End Class

Method New() Class AvObject
::setClassName("AvObject")
::aError     := {}
::aWarning   := {}
::aParent    := {}
::nErrSize   := 0
::lError     := .F.
Return Self

Method setClassName(cClass) Class AvObject
If !Empty(::cClassName)
   aAdd(::aParent,::cClassName)
EndIf
::cClassName := cClass
Return

Method ClassName() Class AvObject
Return ::cClassName

Method Clone() Class AvObject
Return AvOClone(Self,::cClassName)

Method ValidaParam(xValue,cTipo,xDefault) Class AvObject
Local lRet := .T.
Default xValue := xDefault

If ValType(xValue) <> cTipo
   lRet := .F.
   ::Error("Parametro incorreto")
EndIf

Return lRet

Method Error(cError,lWarning,lUnique) Class AvObject
//Local i, aLinhas := {}, cLin
Local aArray, i
Default lWarning := .F.
Default lUnique  := .T.

If ValType(cError) $ "A/C"
   If ValType(cError) == "C"
      cError := {cError}
   EndIf
   
   If lWarning
      aArray   := ::aWarning
   Else
      If Len(cError) > 0
	     ::lError := .T.
	  EndIf
      aArray   := ::aError
   End If
   
   //aEval(cError,{|x| if(ValType(x)=="C",aAdd(aArray,x),aAdd(aArray,"Erro indeterminado: "))})
   For i := 1 To Len(cError)
      
      if ValType(cError[i]) == "C" .And. (!lUnique .OR. ASCAN(aArray,{|X| X == cError[i]}) == 0 )
         aAdd(aArray,cError[i])
         ::nErrSize += Len(cError[i])
      EndIf
   Next i
   //cError := ""
/*ElseIf !Empty(cError)
   
   If !lWarning
      aAdd(::aError,cError)
	  ::lError := .T.
   Else
      aAdd(::aWarning,cError)
   End If
   /*
   i := 0
   Do While i < Len(cError)
      nPos:= At(Chr(13)+Chr(10),cError,i+1)
      If nPos == 0
         nPos := Len(cError)
      EndIf
      
      cLin := StrTran(StrTran(AllTrim(SubStr(cError,i,nPos-i)),Chr(13),""),Chr(10),"")
      
      If Len(aLinhas) == 0
         cLin := If(left(AllTrim(cLin),2) <> "- ","- ","")+AllTrim(cLin)
      Else
         cLin := If(left(AllTrim(cLin),2) <> "  ","  ","")+AllTrim(cLin)
      EndIf
      aAdd(aLinhas,cLin) 
      i := nPos
   EndDo
   
   i := 1
   Do While i <= Len(aLinhas)
      If Len(aLinhas[i]) > 65
         aAdd(aLinhas,NIL)
         aIns(aLinhas,i+1)
         aLinhas[i+1] := If(Left(SubStr(aLinhas[i],66),2)<>"  ","  ","")+SubStr(aLinhas[i],66)
         aLinhas[i]   := SubStr(aLinhas[i],1,65)
      EndIf
      i++
   EndDo
   
   cError := aLinhas[1]+Chr(13)+Chr(10)
   For i := 2 To Len(aLinhas)
      cError += aLinhas[i]+Chr(13)+Chr(10)
   Next i    
   
   If !lWarning
      ::cError += cError
   Else
      ::cWarning += cError
   EndIf
   */
EndIf

Return nil

Method Warning(cError) Class AvObject

If ASCAN(Self:aWarning,cError) == 0
   ::Error(cError,.T.)
EndIf

Return nil

Method ResetError() Class AvObject
::aError   := {}
::aWarning := {}
::lError   := .F.
::nErrSize := 0
Return nil

Method ShowErrors(lWarning,lErro) Class AvObject
Local cMsg := ""
Local cArq, nHdl
Default lWarning := .T. 
Default lErro := .T.  // GFP - 03/02/2014

If IsInCallStack("EASYLINKATU")  // Atualização na inicialização de módulos
   Return NIL
EndIf

If ::nErrSize >= 1024*1024 //Caso a string tenha mais que 1MB, gravar em arquivo e chamar o notepad.
   ::cTexto += If(!lErro,"Update finalizado","")  // GFP - 03/02/2014
   Do While (cArq := GetTempPath(.T.)+CriaTrab(,.F.)+".TXT",File(cArq))
   EndDo
   
   nHdl := EasyCreateFile(cArq)
EndIf

If Len(::aError) > 0
   If !Empty(nHdl)
      FWrite(nHdl,"Ocorreram erros: "+ENTER)
   Else
      cMsg += "Ocorreram erros: "+ENTER
   EndIf
   cMsg += ::GetStrErrors(,nHdl)+ENTER
EndIf

If lWarning .AND. Len(::aWarning) > 0
   If !Empty(nHdl)
      If lErro   // GFP - 03/02/2014
         FWrite(nHdl,"Avisos: "+ENTER)
      EndIf
   ElseIf !lErro   // GFP - 03/02/2014
      ::cTexto += ::GetStrErrors(::aWarning,nHdl,lErro)
   Else
      cMsg += "Avisos: "+ENTER
   EndIf
   cMsg += ::GetStrErrors(::aWarning,nHdl,lErro)   // GFP - 03/02/2014
EndIf

If !Empty(cMsg)
   If Empty(nHdl)
      If lErro   // GFP - 03/02/2014
         EECView(cMsg,"Mensagens","Mensagens",,, .T. /*lQuebraLinha*/, .T. /*lSoExibeMsg*/)//31/07/2017 - adequação para exibir apenas o botão fechar
      EndIf
   Else
      FClose(nHdl)
      ShellExecute("open", cArq,"","", 1)
   EndIf
EndIf

Return nil

Function AvOClone(oObj,cClass,oObjDest,lByValue)
Local aData
Local i, j
Local cClassName
Local cMsg
Private oNew  := oObjDest

Default lByValue := .F.

If cClass == NIL
   /*If Type("oObj:ClassName()") == "C"
      cClass := oObj:ClassName()
   ElseIf Type("oObj:cClassName") == "C"
      cClass := oObj:cClassName
   Else
      cMsg := "Erro no uso da função AvOClone."
      cMsg += "Função não pode determinar a classe do objeto."
      cMsg += "Procedure: "+ProcName(1)+" linha "+LTrim(Str(ProcLine(1)))
      
      Help("",1,"AVG0001030",,cMsg,1,1) //MsgStop(cMsg,"Aviso")
   EndIf*/
   cClass := GetClassName(oObj)
EndIf

Default oNew  := &(cClass+"():New()")

aData := ClassDataArray(oObj)
If ValType(oObj:aParent) == "A" 
   aDataNames := {}
   For i:= 1 To Len(oObj:aParent)
      oNewPai := &(oObj:aParent[i]+"():New()")
      aDataPai := ClassDataArray(oNewPai)
      For j:=1 To Len(aDataPai)
         If aScan(aDataNames,{|X| X == aDataPai[j][1]}) == 0 .AND. aScan(aData,{|X| X[1] == aDataPai[j][1]}) == 0
            aAdd(aDataNames,aDataPai[j][1])
         Endif
      Next j
   Next i
   
   For i := 1 To Len(aDataNames)
      Private oObjOri := oObj
      aAdd(aData,{aDataNames[i],&("oObjOri:"+aDataNames[i]),0})
   Next i
   
EndIf

For i := 1 To Len(aData)
   If ValType(aData[i][2]) == "A"
      If lByValue
         &("oNew:"+aData[i][1]) := aClone(aData[i][2])
      Else
         &("oNew:"+aData[i][1]) := aData[i][2]
      EndIf
   ElseIf ValType(aData[i][2]) == "O"
      
      If lByValue
         Private oCont := aData[i][2]
         
         cClassName := GetClassName(oCont)
         AvOClone(aData[i][2],cClassName,"oNew:"+aData[i][1])
      Else
         &("oNew:"+aData[i][1]) := aData[i][2]
      EndIf
      
   Else
      &("oNew:"+aData[i][1]) := aData[i][2]
   EndIf
   
Next i

Return oNew

Method GetStrErrors(aError,nHdl,lErro)  Class AvObject
Local i
Local cErrors := ""
Default aError := ::aError
Default lErro := .T.   // GFP - 03/02/2014

For i := 1 To Len(aError)
   If !Empty(nHdl)
      FWrite(nHdl,If(!lErro,"","- ") + aError[i] + If(!lErro,"",ENTER))   // GFP - 03/02/2014
   Else
      cErrors += If(!lErro,"","- ") + aError[i] + If(!lErro,"",ENTER)   // GFP - 03/02/2014
   EndIf
Next i

Return If(!Empty(nHdl),"Arquivo gravado",cErrors)   // GFP - 03/02/2014



Method HasErrors() Class AvObject
Return Self:lError

/*
Método   : SaveLog
Autor    : Rodrigo Mendes Diaz
Data     : 08/03/16
Objetivo : Gravar arquivo com log de execução, incluindo erros e avisos.
*/
Method SaveLog(lWarning, lErro, cFileName, cHeader) Class AvObject
Local nHdl
Default lWarning := .T.
Default lErro := .T.
Default cHeader := ""

	If !File(cFileName) .And. (nHdl := EasyCreateFile(cFileName)) > 0
	
		If !Empty(cHeader)
			FWrite(nHdl,cHeader + ENTER)
		EndIf
	
		If lErro .And. Len(::aError) > 0
	      FWrite(nHdl,"Ocorreram erros: " + ENTER)
	      Self:GetStrErrors(,nHdl)
	 	EndIf
	 	
		If lWarning .AND. Len(::aWarning) > 0
			FWrite(nHdl,"Avisos: "+ENTER)
			Self:GetStrErrors(::aWarning,nHdl,lErro)
		EndIf
		
		FClose(nHdl)

	EndIf

Return Nil