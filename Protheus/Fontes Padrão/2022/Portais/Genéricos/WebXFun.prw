#include "protheus.ch"

#define SpcConst "&nbsp;"

#DEFINE INICABEC    Chr(27)+Chr(01)+Chr(01)
#DEFINE FIMCABEC    Chr(27)+Chr(01)+Chr(02)
#DEFINE INIFIELD    Chr(27)+Chr(02)+Chr(01)
#DEFINE FIMFIELD    Chr(27)+Chr(02)+Chr(02)
#DEFINE INIRODA     Chr(27)+Chr(03)+Chr(01)
#DEFINE FIMRODA     Chr(27)+Chr(03)+Chr(02)
#DEFINE INIPARAM    Chr(27)+Chr(04)+Chr(01)
#DEFINE FIMPARAM    Chr(27)+Chr(04)+Chr(02)
#DEFINE INITHINLINE Chr(27)+Chr(05)+Chr(01)
#DEFINE FIMTHINLINE Chr(27)+Chr(05)+Chr(02)
#DEFINE INIFATLINE  Chr(27)+Chr(06)+Chr(01)
#DEFINE FIMFATLINE  Chr(27)+Chr(06)+Chr(02)
#DEFINE INICENTER   Chr(27)+Chr(07)+Chr(01)
#DEFINE FIMCENTER   Chr(27)+Chr(07)+Chr(02)
#DEFINE INIRIGHT    Chr(27)+Chr(09)+Chr(01)
#DEFINE FIMRIGHT    Chr(27)+Chr(09)+Chr(02)
#DEFINE INILEFT     Chr(27)+Chr(11)+Chr(01)
#DEFINE FIMLEFT     Chr(27)+Chr(11)+Chr(02)
#DEFINE INILOGO     Chr(27)+Chr(14)+Chr(01)
#DEFINE FIMLOGO     Chr(27)+Chr(14)+Chr(02)
#DEFINE INIBORDER   Chr(27)+Chr(16)+Chr(01)
#DEFINE FIMBORDER   Chr(27)+Chr(16)+Chr(02)
#DEFINE INILOGOESP  Chr(27)+Chr(17)+Chr(01)
#DEFINE FIMLOGOESP  Chr(27)+Chr(17)+Chr(02)

/***********************************************************************************************/
Function HTMLSpace(nCount)
Return(Replicate(SpcConst,nCount))

/***********************************************************************************************/
Function HTMLAllTrim(cString)
Return(If(Empty(AllTrim(cString)),SpcConst,AllTrim(cString)))

/***********************************************************************************************/
Function HTMLLTrim(cString)
Return(If(Empty(LTrim(cString)),SpcConst,LTrim(cString)))

/***********************************************************************************************/
Function HTMLRTrim(cString)
Return(If(Empty(RTrim(cString)),SpcConst,RTrim(cString)))

/***********************************************************************************************/
Function HTMLProcID(nProcID)
Local cRet 
Default nProcID := 0
cret := '<meta HTTP-EQUIV="Set-cookie" Content="ap5ProcId='+AllTrim(Str(nProcId,18,0))+'">'
cret += Chr(13)+chr(10)
cRet += '<meta HTTP-EQUIV="Expires" Content="-1">'
Return cRet

/***********************************************************************************************/
Function HTMLKillProc(nProcID)
Local cRet := HTMLProcID(nProcID)
cRet += "__killcurrentproccess__"
return cRet

/***********************************************************************************************/
Function HTMLGetValue(aParms,cParm)
Local cRet := ""
Local nPos

DEFAULT cParm := ""

If !Empty(aParms)
	cParm := Upper(AllTrim(cParm))
	nPos := Ascan(aParms,{|x| Upper(AllTrim(x[1])) == cParm})
	If nPos > 0
		cRet := aParms[nPos][2]
	EndIf
EndIf
Return cRet

/***********************************************************************************************/
Function APWTStart()
Local i
Local cInifile := GetADV97()
Local cNames
Local nAt
Local cJobName
Local cJobInfo
Local cJobEmp
Local cJobFil
Local nJobs

cNames := GetPvProfString("WorkThreads","WorkName","",cInIfile)

While !Empty(cNames)
	nAt := At(",",cNames)
	If nAt > 0
		cJobName := Subs(cNames,1,nAt-1)
		cNames := Subs(cNames,nAt+1)
	Else
		cJobName := cNames
		cNames := ""
	EndIf

	cJobName := AllTrim(cJobName)
	If FindFunction(cJobName)
		cJobInfo := AllTrim(GetPvProfString("WorkThreads",cJobName,"",cInIfile))

		//empresa
		nAt := At(",",cJobInfo)
		cJobEmp := Subs(cJobInfo,1,nAt-1)
		cJobInfo := Subs(cJobInfo,nAt+1)

		nAt := At(",",cJobInfo)
		cJobFil := Subs(cJobInfo,1,nAt-1)
		cJobInfo := Subs(cJobInfo,nAt+1)

		nJobs := Val(cJobInfo)

		If nJobs > 0
			For i := 1 To nJobs
				StartJob(cJobName,GetEnvServer(),.F.,cJobEmp,cJobFil)
			Next
		EndIf
	EndIf
End
Return

/***********************************************************************************************/
Function HTMLCabec(cPage,nSize,cLGRL,cLGSIGA)
Local i
Local nAt1
Local nAt2
Local nINICABEC
Local nFIMCABEC
Local nINIPARAM
Local nFIMPARAM
Local nINIRODA
Local nFIMRODA
Local cPart := ""
Local cCopy := ""
Local cCabec := ""
Local cField := ""
Local cRoda := ""

DEFAULT nSize := 132

/*If Empty(cLGRL)
	cLGRL := HTMLLGRL()
	If !Empty(cLGRL)
		cLGRL := "/"+cLGRL
	EndIf
EndIf

If Empty(cLGSIGA)
	cLGSIGA := HTMLLGSIGA()
	If !Empty(cLGSIGA)
		cLGSIGA := "/"+cLGSIGA
	EndIf
EndIf*/

nINICABEC := At(INICABEC,cPage)
nFIMCABEC := At(FIMCABEC,cPage)

If nSize > 0 .and. nINICABEC > 0 .and. nFIMCABEC > 0
	nSize := nSize+1
	cCopy := Subs(cPage,nINICABEC+3,nFIMCABEC-nINICABEC)
	cCopy := StrTran(cCopy,CRLF,"")
	
	cCabec += '<table border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" width="100%">'+CRLF
	cCabec += '<tr><td>'+CRLF
	cCabec += '<table border="0" cellspacing="0" cellpadding="0" width="100%" bgcolor="#FFFFFF">'+CRLF

	//primeira linha
	cCabec += '<tr><td colspan="3">'+CRLF
	cCabec += '<hr color="#000000" noshade size="2">'+CRLF
	cCabec += '</td></tr>'+CRLF
	
	//segunda linha - logotipo e folha
	nAt1 := At(INIFIELD,cCopy)
	nAt2 := At(FIMFIELD,cCopy)
	If !Empty(cLGRL)
		cField := '<img border="0" src="'+cLGRL+'">'+CRLF
	Else
		cField := AllTrim(Subs(cCopy,nAt1+3,nAt2-nAt1-3))
	EndIf
	
	nAt1 := At(INILOGOESP,cField)
	If nAt1 > 0
		cField := Subs(cField,1,nAt1-1)
	EndIf

	cCabec += '<tr><td><font face="Arial" size="2">'+CRLF
	cCabec += cField
	cCabec += '</font></td>'+CRLF
	cCabec += '<td></td>'+CRLF
	
	cCopy := Subs(cCopy,nAt2+3)
	nAt1 := At(INIFIELD,cCopy)
	nAt2 := At(FIMFIELD,cCopy)
	cField := AllTrim(Subs(cCopy,nAt1+3,nAt2-nAt1-3))

	cCabec += '<td align="right"><font face="Arial" size="2">'+CRLF
	cCabec += cField
	cCabec += '</font></td></tr>'+CRLF

	//terceira linha - nome, descricao e data de referencia
	cCopy := Subs(cCopy,nAt2+3)

	nAt1 := At(INIFIELD,cCopy)
	nAt2 := At(FIMFIELD,cCopy)
	cField := AllTrim(Subs(cCopy,nAt1+3,nAt2-nAt1-3))

	cCabec += '<tr><td><font face="Arial" size="2">'+CRLF
	cCabec += cField
	cCabec += '</font></td>'+CRLF

	cCopy := Subs(cCopy,nAt2+3)
	nAt1 := At(INIFIELD,cCopy)
	nAt2 := At(FIMFIELD,cCopy)
	cField := Subs(cCopy,nAt1+3,nAt2-nAt1-3)
	cField := StrTran(cField," ",SpcConst)

	cCabec += '<td align="center"><font face="Arial" size="2">'+CRLF
	cCabec += cField
	cCabec += '</font></td>'+CRLF

	cCopy := Subs(cCopy,nAt2+3)
	nAt1 := At(INIFIELD,cCopy)
	nAt2 := At(FIMFIELD,cCopy)
	cField := Subs(cCopy,nAt1+3,nAt2-nAt1-3)

	cCabec += '<td align="right"><font face="Arial" size="2">'+CRLF
	cCabec += cField
	cCabec += '</font></td></tr>'+CRLF

	//quarta linha - hora e emissao
	cCopy := Subs(cCopy,nAt2+3)

	nAt1 := At(INIFIELD,cCopy)
	nAt2 := At(FIMFIELD,cCopy)
	cField := AllTrim(Subs(cCopy,nAt1+3,nAt2-nAt1-3))

	cCabec += '<tr><td><font face="Arial" size="2">'+CRLF
	cCabec += cField
	cCabec += '</font></td>'+CRLF
	cCabec += '<td></td>'+CRLF

	cCopy := Subs(cCopy,nAt2+3)
	nAt1 := At(INIFIELD,cCopy)
	nAt2 := At(FIMFIELD,cCopy)
	cField := AllTrim(Subs(cCopy,nAt1+3,nAt2-nAt1-3))

	cCabec += '<td align="right"><font face="Arial" size="2">'+CRLF
	cCabec += cField
	cCabec += '</font></td></tr>'+CRLF

	//quinta linha
	cCopy := Subs(cCopy,nAt2+3)
	cCabec += '<tr><td colspan="3">'+CRLF
	cCabec += '<hr color="#000000" noshade size="2">'+CRLF
	cCabec += '</td></tr>'+CRLF

	//sexta e setima linha - cabec1 e cabec2
	cCopy := Subs(cCopy,At(FIMFATLINE,cCopy)+3)
	
	While INIFIELD $ cCOPY
		nAt1 := At(INIFIELD,cCopy)
		nAt2 := At(FIMFIELD,cCopy)
		cField := Subs(cCopy,nAt1+3,nAt2-nAt1-3)
		cField := StrTran(cField," ",SpcConst)
		cCopy := Subs(cCopy,nAt2+3)
				
		cCabec += '<tr><td colspan="3" nowrap><font face="Courier New" size="2">'+CRLF
		cCabec += cField
		cCabec += '</font></td></tr>'+CRLF
	End

	//oitava linha
	cCabec += '<tr><td colspan="3">'+CRLF
	cCabec += '<hr color="#000000" noshade size="1">'+CRLF
	cCabec += '</td></tr></table>'+CRLF
	cCabec += '</td></tr>'+CRLF

	//pergunte
	nINIPARAM := At(INIPARAM,cPage)
	nFIMPARAM := At(FIMPARAM,cPage)
	If nINIPARAM > 0 .and. nFIMPARAM > 0
		cCopy := Subs(cPage,nINIPARAM+3,nFIMPARAM-nINIPARAM)

		cCabec += '<tr><td>'+CRLF
		cCabec += '<table border="0" cellspacing="0" cellpadding="0" width="100%" bgcolor="#FFFFFF">'+CRLF
		cCabec += '<tr><td colspan="2"><br></td></tr>'+CRLF

		For i := 1 To MlCount(cCopy)
			cPart := MemoLine(cCopy,nSize,i)
			If INIFIELD $ cPart
				nAt1 := At(INIFIELD,cPart)
				nAt2 := At(FIMFIELD,cPart)
				cField := AllTrim(Subs(cPart,nAt1+3,nAt2-nAt1-3))
				cField := StrTran(cField," ",SpcConst)

				cCabec += '<tr><td width="40%"><font face="Arial" size="2">'+CRLF
				cCabec += cField+CRLF
				cCabec += '</font></td>'

				cPart := Subs(cPart,nAt2+3)
				nAt1 := At(INIFIELD,cPart)
				nAt2 := At(FIMFIELD,cPart)
				cField := AllTrim(Subs(cPart,nAt1+3,nAt2-nAt1-3))
				cField := StrTran(cField," ",SpcConst)

				cCabec += '<td><font face="Arial" size="2">'+CRLF
				cCabec += cField+CRLF
				cCabec += '</font></td></tr>'+CRLF
				cCabec += '<tr><td colspan="2"><br></td></tr>'+CRLF
			EndIf
		Next

		cCabec += '<tr><td colspan="2">'+CRLF
		cCabec += '<hr color="#000000" noshade size="2">'+CRLF
		cCabec += '</td></tr></table>'+CRLF
        cCabec += '</td></tr>'+CRLF

		cCopy := Subs(cCopy,nFIMPARAM+3)
	Else

		//rodape
		nINIRODA := At(INIRODA,cPage)
		nFIMRODA := At(FIMRODA,cPage)

		If nINIRODA > 0 .and. nFIMRODA > 0
			cCopy := Subs(cPage,nINIRODA+3,nFIMRODA-nINIRODA)
			cCopy := StrTran(cCopy,CRLF,"")
			
			cRoda += '<tr><td>'+CRLF
			cRoda += '<table border="0" cellspacing="0" cellpadding="0" width="100%" bgcolor="#FFFFFF">'+CRLF
			cRoda += '<tr><td colspan="3">'+CRLF
			cRoda += '<hr color="#000000" noshade size="2">'+CRLF
			cRoda += '</td></tr>'+CRLF

			nAt1 := At(INIFIELD,cCopy)
			nAt2 := At(FIMFIELD,cCopy)
			If !Empty(cLGSIGA)
				cField := '<img border="0" src="/'+cLGSIGA+'">'+CRLF
			Else
				cField := AllTrim(Subs(cCopy,nAt1+3,nAt2-nAt1-3))
				cField := StrTran(cField," ",SpcConst)
			EndIf

			cRoda += '<tr><td><font face="Arial" size="2">'+CRLF
			cRoda += cField+CRLF
			cRoda += '</font></td>'

			cCopy := Subs(cCopy,nAt2+3)
			nAt1 := At(INIFIELD,cCopy)
			nAt2 := At(FIMFIELD,cCopy)
			cField := Subs(cCopy,nAt1+3,nAt2-nAt1-3)
			cField := StrTran(cField," ",SpcConst)

			cRoda += '<td><font face="Arial" size="2">'+CRLF
			cRoda += cField+CRLF
			cRoda += '</font></td>'+CRLF

			cCopy := Subs(cCopy,nAt2+3)
			nAt1 := At(INIFIELD,cCopy)
			nAt2 := At(FIMFIELD,cCopy)
			cField := AllTrim(Subs(cCopy,nAt1+3,nAt2-nAt1-3))
			cField := StrTran(cField," ",SpcConst)

			cRoda += '<td align="right"><font face="Arial" size="2">'+CRLF
			cRoda += cField+CRLF
			cRoda += '</font></td></tr>'+CRLF

			cRoda += '<tr><td colspan="3">'+CRLF
			cRoda += '<hr color="#000000" noshade size="2">'+CRLF
			cRoda += '</td></tr></table>'+CRLF
	        cRoda += '</td></tr>'+CRLF

        	cCopy := Subs(cPage,1,nINIRODA-1)
		Else
			cCopy := cPage
		EndIf

		cCopy := Subs(cCopy,nFIMCABEC+3)
		cCopy := StrTran(cCopy," ",SpcConst)
		cCopy := HtmlFormat(cCopy,nSize,cLGRL)
		cCopy := StrTran(cCopy,CRLF,"<br>")
		cCopy := StrTran(cCopy,Chr(12),"")

		cCabec += '<tr><td nowrap><font face="Courier New" size="2">'+CRLF
		cCabec += cCopy+CRLF
		cCabec += '</font></td></tr>'+CRLF
		cCabec += cRoda
	EndIf

	cCabec += '</table>'
Else
	cCopy := cPage
	cCopy := StrTran(cCopy," ",SpcConst)
	cCopy := HtmlFormat(cCopy,nSize,cLGRL)
	cCopy := StrTran(cCopy,CRLF,"<br>")
	cCopy := StrTran(cCopy,Chr(12),"")
	cCopy := StrTran(cCopy,Chr(8),"")
	cCopy := StrTran(cCopy,INICABEC,"")
	cCopy := StrTran(cCopy,FIMCABEC,"")
	cCopy := StrTran(cCopy,INIFIELD,"")
	cCopy := StrTran(cCopy,FIMFIELD,"")
	cCopy := StrTran(cCopy,INIRODA,"")
	cCopy := StrTran(cCopy,FIMRODA,"")
	cCopy := StrTran(cCopy,INIPARAM,"")
	cCopy := StrTran(cCopy,FIMPARAM,"")
	
	nAt1 := At("LGRL",cCopy)
	nAt2 := At(".BMP",cCopy)
	If nAt1 > 0 .and. nAt2 > 0
		cCopy := Subs(cCopy,1,nAt1-1)+Subs(cCopy,nAt2+4)
	EndIf

	cCabec += '<table border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">'+CRLF
	cCabec += '<tr><td nowrap><font face="Courier New" size="2">'+CRLF
	cCabec += cCopy
	cCabec += '</font></td></tr></table>'
EndIf

Return cCabec

/***********************************************************************************************/
Static Function HtmlFormat(cMsg,nSize,cLGRL)
Local cPage := ""
Local cPart
Local nPos

nPos := At(Chr(13),cMsg)

While nPos > 0
	cPart := Subs(cMsg,1,nPos)
	cMsg := Subs(cMsg,nPos + 1)
	nPos := At(Chr(13),cMsg)

	//__PrtThinLine
	If INITHINLINE $ cPart
		cPage += '<hr color="#000000" noshade size="1">'
	
	//__PrtFatLine
	ElseIf INIFATLINE $ cPart
		cPage += '<hr color="#000000" noshade size="2">'

	//__PrtCenter
	ElseIf INICENTER $ cPart
		cPart := StrTran(cPart,INICENTER,"")
		cPart := StrTran(cPart,FIMCENTER,"")
		cPage += '<font face="Arial" size="2">' + cPart + '</font>'
		
		If Subs(cMsg,1,1) == Chr(10)
			cPage += CRLF
		EndIf

	//__PrtRight
	ElseIf INIRIGHT $ cPart
		cPart := StrTran(cPart,INIRIGHT,"")
		cPart := StrTran(cPart,FIMRIGHT,"")
		cPage += '<font face="Arial" size="2">'+cPart+'</font>'
		
		If Subs(cMsg,1,1) == Chr(10)
			cPage += CRLF
		EndIf

	//__PrtRight
	ElseIf INILEFT $ cPart
		cPart := StrTran(cPart,INILEFT,"")
		cPart := StrTran(cPart,FIMLEFT,"")
		cPage += '<font face="Arial" size="2">'+cPart+'</font>'
		
		If Subs(cMsg,1,1) == Chr(10)
			cPage += CRLF
		EndIf

	//__PrtLogo
	ElseIf INILOGO $ cPart
		cPage += '<img border="0" src="'+cLGRL+'">'	
	
	//__PrtBorder
	ElseIf INIBORDER $ cPart
		cPage += ""
	
	Else
		cPage += cPart + CRLF
	EndIf
End
Return cPage

/***********************************************************************************************/
Function HTMLLGRL()
Local cFileLogo := ""
Local cPath := HTMLMainDir(.T.)
Local cEmpHtm

If cPath <> "-1"
	cEmpHtm := HTMLGetSession("EMPFIL")

	If Empty(cEmpHtm) .and. Select("SM0") > 0
		cEmptHtm := SM0->M0_CODIGO+SM0->M0_CODFIL
	EndIf

	If !Empty(cEmpHtm)
		cFileLogo := "LGRL"+cEmpHtm+".GIF" // Empresa+Filial
		If !File(cPath+cFileLogo)
			cFileLogo := "LGRL"+Subs(cEmpHtm,1,2)+".GIF" // Empresa
			If !File(cPath+cFileLogo)
				cFileLogo := ""
			EndIf
		EndIf
	EndIf
EndIf
Return cFileLogo
