#INCLUDE "TFA02.ch"
#include "eADVPL.ch"

/************************** Tela Inicial (dados do tecnico) *******************************/
Function Senha()

Local oDlgSenha, oBtnSenha
Local cSenha := space(07)
Local oSay, oGet,oSayFile,oMeterFiles
Local lValid := .f.
Local nMeterFiles := 0
Local nTimes      := 3
Local nTry        := 1

dbSelectArea("AA1")

DEFINE DIALOG oDlgSenha TITLE STR0001 //"Senha do Tecnico"
       
#ifdef __PALM__
	@ 21,45 SAY "TFA for PalmOS" BOLD LARGE of oDlgSenha
	@ 36,12 SAY "Technical Force Automation" BOLD of oDlgSenha
	@ 94,78 GET oGet VAR cSenha PASSWORD of oDlgSenha	
#else
	@ 21,42 SAY "TFA for PocketPC" BOLD of oDlgSenha    
	@ 36,24 SAY "Technical Force Automation" of oDlgSenha
	cSenha := space(15)
	@ 94,78 GET oGet VAR cSenha PASSWORD of oDlgSenha	
#endif

@ 58,35 SAY oSay PROMPT STR0002 BOLD Of oDlgSenha //"Técnico: "
@ 58,78 SAY oSay PROMPT AA1->AA1_NOMTEC of oDlgSenha
@ 76,37 SAY oSay PROMPT STR0003 BOLD of oDlgSenha //"Código: "
@ 76,78 SAY oSay PROMPT AA1->AA1_CODTEC of oDlgSenha
@ 146,06 SAY oSay PROMPT "Microsiga Intelligence" BOLD of oDlgSenha
@ 96,20 SAY oSayFile PROMPT "" OF oDlgSenha
@ 108,20 METER oMeterFiles SIZE 120, 5 FROM 0 TO 100 OF oDlgSenha
@ 118,54 BUTTON oBtnSenha CAPTION STR0004 ACTION VldSenha(cSenha, nTry, nTimes, oSayFile, oMeterFiles, nMeterFiles) SIZE 65,15 Of oDlgSenha //"Entrar"
@ 94,38 SAY oSay PROMPT STR0005 BOLD of oDlgSenha //"Senha: "

HideControl(oSayFile)
HideControl(oMeterFiles)
SetFocus(oGet)

ACTIVATE DIALOG oDlgSenha

Return AllTrim(cSenha) == AllTrim(AA1->AA1_SENHA)

/*
Function CargaDatas(oData,aDatas)
	//Carrega a lista de datas de atendimento
	dbselectarea("DTA")
	dbsetorder(1)
	dbgotop()
	aSize(aDatas,0)
	While !Eof()
		//carrega o array de datas no formato dd/mm/yyyy
		aAdd(aDatas, Substr(DTA->DT_INI,7,2) + "/" + Substr(DTA->DT_INI,5,2) + "/" + Substr(DTA->DT_INI,1,4))
		dbskip()
	Enddo

	SetArray(oData, aDatas)
Return nil
*/

Function Desenvolv()
	MsgAlert("Em desenvolvimento!","Aviso")
Return nil


//Function SFConsPadrao(cAlias,cVar,oObj,nIndice, aRet)  
Function SFConsPadrao(cAlias,cVar,oObj,aCamp,aInd, aRet)
Local oDlg, oBrwCP, oBtnUp, oBtnDown, oBtnLeft, oBtnRight
Local oBtnOK, oBtnCanc, oBtnPesq,oInd,oPesq
Local cPesq:=""
Local aArray :={},aOrdem:={}, aCombo:= {}
Local nOrdem:=1, nTop:=0,nInd:=1, nX:=1
Local oCol

DEFINE DIALOG oDlg TITLE STR0006 //"Consulta Padrão:"
@ 15,01 BROWSE oBrwCP SIZE 135,100 NO SCROLL of oDlg
SET BROWSE oBrwCP ARRAY aArray                                    

For nI:=1 to Len(aCamp)
	ADD COLUMN oCol TO oBrwCP ARRAY ELEMENT nI HEADER aCamp[nI,1] WIDTH aCamp[nI,3]
Next                                                                    

For nX:=1 to Len(aInd)
	Aadd(aCombo,aInd[nX,1])
Next

@ 34,140 BUTTON oBtnUp CAPTION UP_ARROW SYMBOL SIZE 12,12 ACTION CPUp(cAlias,aArray,oBrwCP,@nTop,aCamp,aInd,nInd) of oDlg
@ 48,140 BUTTON oBtnRight CAPTION RIGHT_ARROW SYMBOL SIZE 12,12 ACTION GridRight(oBrwCP) of oDlg
@ 62,140 BUTTON oBtnLeft CAPTION LEFT_ARROW SYMBOL SIZE 12,12 ACTION GridLeft(oBrwCP) of oDlg
@ 76,140 BUTTON oBtnDown CAPTION DOWN_ARROW SYMBOL SIZE 12,12 ACTION CPDown(cAlias,aArray,oBrwCP,@nTop,aCamp,aInd,nInd) of oDlg
@ 120,05 SAY STR0007 of oDlg //"Pesquisar por:"
@ 120,70 COMBOBOX oInd VAR nInd ITEMS aCombo SIZE 60,50 of oDlg   
@ 132,05 GET oPesq VAR cPesq SIZE 150,15 of oDlg
@ 146,05 BUTTON oBtnOK CAPTION STR0008 SIZE 45,12 ACTION CPRet(oBrwCP,aArray,@cVar,oObj, aCamp, aRet) of oDlg //"OK"
@ 146,55 BUTTON oBtnCanc CAPTION STR0009 SIZE 45,12 ACTION CloseDialog() of oDlg //"Cancelar"
@ 146,105 BUTTON oBtnPesq CAPTION STR0010 SIZE 45,12 ACTION CPPesq(cAlias,@cPesq,aArray,oBrwCP,@nTop,aCamp,aInd,nInd) of oDlg //"Pesquisar"

CPLoad(cAlias,aArray,oBrwCP,@nTop,aCamp,aInd,nInd)

ACTIVATE DIALOG oDlg

Return Nil

Function CPRet(oBrwCP,aArray,cVar,oObj, aCamp, aRet)
Local nArray:=0
Local ni := 0
if Len(aArray) ==0 
	cVar:= ""
Else       
	nArray:= GridRow(oBrwCP)
	cVar:= aArray[nArray,1]
	If aRet != Nil
		aRet := Array(Len(aCamp))
		For ni := 1 To Len(aRet)
			aRet[ni,1] := aArray[nArray, ni]
		Next
	EndIf
Endif
SetText(oObj,cVar)
CloseDialog()
Return Nil     

Function CPDown(cAlias,aArray,oBrwCP,nTop,aCamp,aInd,nInd)
Local nOrdem:=aInd[nInd,2]
dbSelectArea(cAlias)                   
dbSetOrder(nOrdem)
dbGoTo(nTop)
dbSkip(GridRows(oBrwCP))
if !Eof()
   nTop := Recno()
Else
   return nil
endif     
Return CPLoad(cAlias,aArray,oBrwCP,nTop,aCamp,aInd,nInd)

Function CPUp(cAlias,aArray,oBrwCP,nTop,aCamp,aInd,nInd)
Local nOrdem:=aInd[nInd,2]
dbSelectArea(cAlias)
dbSetOrder(nOrdem)
dbGoTo(nTop)
dbSkip(-GridRows(oBrwCP))
if !Bof()
   nTop := Recno()
else
	dbGoTop()
    nTop := Recno()
endif
Return CPLoad(cAlias,aArray,oBrwCP,nTop,aCamp,aInd,nInd)

Function CPLoad(cAlias,aArray,oBrwCP,nTop,aCamp,aInd,nInd)
Local nOrdem:=aInd[nInd,2]
Local nCargMax:=1,nJ:=1,nZ:=1             
Local aLocal:= {}              

dbSelectArea(cAlias)
dbSetOrder(nOrdem)
if nTop ==0
	dbGoTop()
	if !Eof()
	    nTop := Recno()
	Endif
Else
	dbGoTo(nTop)
Endif

aSize(aArray,0)       
nCargMax:=GridRows(oBrwCP)
For nI:=1 to nCargMax
	if !Eof()
		AADD(aArray,Array(Len(aCamp)))
		For nZ := 1 to Len(aCamp)
			aArray[Len(aArray),nZ] := FieldGet(aCamp[nZ,2])
		Next
		dbSkip()
	Else
		nI:=nCargMax +1
	Endif
Next
aSize(aLocal,0)
SetArray(oBrwCP,aArray)

Return Nil

Function CPPesq(cAlias,cPesq,aArray,oBrwCP,nTop,aCamp,aInd,nInd)
Local nCargMax := GridRows(oBrwCP)
Local aPesq:={}     
Local nJ:=1, nZ:=1             
Local nOrdem:=aInd[nInd,2]
cPesq:=AllTrim(cPesq)
dbSelectArea(cAlias)
dbSetOrder(nOrdem)
if dbSeek(cPesq)
	aSize(aArray,0)                   
	nTop:=RecNo()

	For nI:=1 to nCargMax
		if !Eof()
			aSize(aPesq,0)
			For nJ:=1 to Len(aCamp)
				Aadd(aPesq,FieldGet(aCamp[nJ,2]))				
			Next
			AADD(aArray,Array(Len(aPesq)))
			For nZ := 1 to Len(aPesq)
			  aArray[Len(aArray),nZ] := aPesq[nZ,1]
			Next
			dbSelectArea(cAlias)
			dbSkip()
		else
			nI:=nCargMax +1
		endif          
	Next
Else
	MsgAlert(STR0011 + cPesq + STR0012 + aInd[nInd,1] + STR0013) //"Pesquisa "###" por "###" não encontrada"
Endif
aSize(aPesq,0)
SetArray(oBrwCP,aArray)

Return Nil