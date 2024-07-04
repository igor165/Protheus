#include "protheus.ch"
#include "HSFTRFUN.CH"

Function HSESPREO()
	HS_FTRREO(oMainWnd, STR0001, "SX5", 1, "X5_TABELA == 'ZE'", "X5_CHAVE", "HSVldReord(oGDReord)",, "X5_DESCSPA/X5_DESCENG", .F., {"X5_DESCRI"}) //"Prioridade por especialidade"
Return(Nil)

Function HSA08REsp()
HS_FTRREO(oMainWnd, STR0002, "GFR", 1, "GFR_FILIAL == '" + xFilial("GFR") + "'", "GFR_PRIORI",, "GFR_CDESPE/GFR_DSESPE") //"Prioridade por especialidade"
Return(Nil)

Function HSA08RPrc()
HS_FTRREO(oMainWnd, STR0003 + " [" + AllTrim(GFR->GFR_CDESPE + "-" + GFR->GFR_DSESPE) + "]", "GA7", 1, "GA7_CODESP == '" + GFR->GFR_CDESPE + "'", "GA7_PRIORI",, "GA7_CODPRO/GA7_DESC  ") //"Prioridade por procedimentos da especialidade"
Return(Nil)


/*User Function HSA08Rot()
Local aRotReord := {{OemtoAnsi("Especialidade"), "U_HSA08REsp()", 0, 4, 0, Nil}, ;
{OemtoAnsi("Procedimentos"), 'U_HSA08RPrc()', 0, 4, 0, Nil}}
aAdd(ParamIxb[1], {"Prioridade",	aRotReord, 8, 2})

Return(ParamIxb) */

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSFTRREO  ºAutor  ³José Orfeu          º Data ³  26/04/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Permite a reordenação dos registros informados por parametroº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function HS_FTRREO(oTela, cTitulo, cAlias, nOrd, cCondSql, cCpoCtrl, cVldReord, cLstCpo, cCpoNao, lLstCpo, aCposIni, lEditOrd, cVldEdit)

Local aSize := {}, aObjects := {}, aInfo := {}, aPObjs := {}
Local oDlgCfg := Nil, nOpcDlg := 0
Local aHeader := {}, aCols := {}, nUsado := 0
Local aGrvItens := {}
Local nForIni := 0, nForGrv := 0, nLenCReord := Len((cAlias)->(FieldGet(FieldPos(cCpoCtrl)))), nPosCReord := 0
local nI := 0

Private nSobe := 1, nDesce := 2, nOrdem := 3, oGDReord := Nil

Default oTela    := oMainWnd
Default nOrd     := 1
Default cCpoNao  := ""
Default aCposIni := {}
Default lLstCpo  := .T.
 Default lEditOrd := .F.
 Default cVldEdit := ""      

For nForIni := 1 To Len(aCposIni)
	cCpoNao := PadR(aCposIni[nForIni], 10) + IIf(Empty(cCpoNao), "", "/") + cCpoNao
Next

cCpoNao := PadR(cCpoCtrl, 10) + IIf(Empty(cCpoNao), "", "/") + cCpoNao

aSize(aCposIni, Len(aCposIni) + 1)

aIns(aCposIni, 1)

aCposIni[1] := cCpoCtrl

HS_BDados(cAlias, @aHeader, @aCols, @nUsado, nOrd,, cCondSql,,, cLstCpo,, cCpoNao,,,, lLstCpo,,,,,, aCposIni)

aSize(aHeader, Len(aHeader) + 3)

aIns(aHeader, 1)
aIns(aHeader, 2)
aIns(aHeader, 3)

aHeader[1] := {          "-", "cSobe" , "@BMP",          1, 0,".F.",""    , "C", "", "V" ,"" , "","","V"}
aHeader[2] := {          "+", "cDesce", "@BMP",          1, 0,".F.",""    , "C", "", "V" ,"" , "","","V"}
 aHeader[3] := {STR0004, "cOrdem", "@!"  , nLenCReord, 0,cVldEdit,""    , "C", "", "A" ,"" , "","",IIf(lEditOrd, "A","V")} //"Ordem Atual"

nPosCReord := aScan(aHeader, {| aPosCpo | aPosCpo[2] == PadR(cCpoCtrl, 10)})

aHeader[nPosCReord][1] := STR0005 //"Ordem Anterior"

aEVal(aCols, {| aCSize, nLinha | aSize(aCSize, Len(aCols[nLinha]) + 3)})

aEVal(aCols, {| aCIns, nLinha | (aIns(aCIns, 1), aCIns[1] := "metas_cima_16" ), ;
(aIns(aCIns, 2), aCIns[2] := "metas_baixo_16"), ;
(aIns(aCIns, 3), aCIns[3] := IIf(Empty(aCIns[nPosCReord]), StrZero(nLinha*10, nLenCReord), aCIns[nPosCReord])), ;
(aCIns[nPosCReord] := IIf(Empty(aCIns[nPosCReord]), aCIns[3], aCIns[nPosCReord]))})

nUsado += 3

 aSort(aCols,,,{|x,y| x[nOrdem] < y[nOrdem]})
aSize 			:= MsAdvSize(.F.)
aObjects := {}

aAdd( aObjects, { 100, 100, .T., .T.} )

aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPObjs := MsObjSize( aInfo, aObjects, .T. )

DEFINE MSDIALOG oDlgCfg TITLE OemToAnsi(cTitulo) From aSize[7],0 TO aSize[6], aSize[5]	PIXEL of oTela

oGDReord := MsNewGetDados():New(aPObjs[1, 1] + 20, aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4], GD_UPDATE,,,,,, 99999,,,,oDlgCfg, aHeader, aCols)
  oGDReord:oBrowse:BlDblClick := {|| FS_DblClk(cVldReord, nLenCReord)}
oGDReord:oBrowse:Align := CONTROL_ALIGN_BOTTOM

ACTIVATE MSDIALOG oDlgCfg ON INIT EnchoiceBar (oDlgCfg,	{|| nOpcDlg := 1, oDlgCfg:End()},;
{|| nOpcDlg := 0, oDlgCfg:End()})

If nOpcDlg == 1
	HS_FTRMORD(oGDReord, nLenCReord)
	DbSelectArea(cAlias)
	DbSetOrder(nOrd)
	
	aGrvItens := {}
	
	For nForGrv := 1 To Len(oGDReord:aCols)
		If DbSeek(FS_MntChave(cAlias, IndexKey(nOrd), oGDReord:aCols[nForGrv], oGDReord:aHeader)) .And. ;
			FieldGet(FieldPos(cCpoCtrl)) <> oGDReord:aCols[nForGrv][nOrdem]
			If !(cCpoCtrl $ IndexKey(nOrd))
				RecLock(cAlias, .F.)
				FieldPut(FieldPos(cCpoCtrl), oGDReord:aCols[nForGrv][nOrdem])
				MsUnLock()
			Else
				aAdd(aGrvItens, {(cAlias)->(RecNo()), oGDReord:aCols[nForGrv][nOrdem]})
			EndIf
		EndIf
	Next
	
	For nForGrv := 1 To Len(aGrvItens)
		DbGoTo(aGrvItens[nForGrv][1])
		RecLock(cAlias, .F.)
		FieldPut(FieldPos(cCpoCtrl), aGrvItens[nForGrv][2])
		MsUnLock()
	Next                      
	if SuperGetMV("MV_REOPLT", NIL, .F.) .and. isInCallStack("HSPAHM57") .and. !empty(aItensAlte)
	    if !empty(aItensAlte)
			for nI := 1 to len(aItensAlte)
				DbSelectArea("GTJ")
				DbSetOrder(1)
				If DbSeek(xFilial("GTJ") + aItensAlte[nI,1] + aItensAlte[nI,2])
					RecLock("GTJ", .F.)
					GTJ->GTJ_USRFOR := aItensAlte[nI,3]
					GTJ->GTJ_MTVAGE := aItensAlte[nI,4]
					GTJ->GTJ_DATFOR := dDatabase
					GTJ->GTJ_HORFOR := time()
					MsUnLock()
				endif
			next nI	     
		endif
	endif
EndIf

Return(Nil)

Static Function FS_DblClk(cFunVld)

Local nCol     := oGDReord:oBrowse:nColPos
Local nLin     := oGDReord:oBrowse:nAt
Local aCols    := aClone(oGDReord:aCols)
Local cNovaOrd := ""

If nCol == nSobe
	If nLin > 1
		
		If Empty(cFunVld) .Or. &(cFunVld)
			
			cNovaOrd := oGDReord:aCols[nLin - 1, nOrdem]
			oGDReord:aCols[nLin - 1, nOrdem] := oGDReord:aCols[nLin, nOrdem]
			oGDReord:aCols[nLin, nOrdem] := cNovaOrd
			oGDReord:oBrowse:nAt--
			
		EndIf
		
	EndIf
ElseIf nCol == nDesce
	If nLin < Len(oGDReord:aCols)
		
		If Empty(cFunVld) .Or. &(cFunVld)
			
			cNovaOrd := oGDReord:aCols[nLin + 1, nOrdem]
			oGDReord:aCols[nLin + 1, nOrdem] := oGDReord:aCols[nLin, nOrdem]
			oGDReord:aCols[nLin, nOrdem] := cNovaOrd
			oGDReord:oBrowse:nAt++
			
		End
		
	EndIf
ElseIf nCol == 3
	oGDReord:EDITCELL(oGDReord:OBROWSE, oGDReord:oBrowse:nAt, oGDReord:oBrowse:nColPos)	
EndIf

aSort(oGDReord:aCols,,,{|x,y| x[nOrdem] < y[nOrdem]})

oGDReord:oBrowse:Refresh()
Return(.T.)

Static Function FS_MntChave(cAlias, cChave, aValores, aPosCpos)
Local cChvRet := "", cCpoChv := "", nPosChv := 0

cChave := StrTran(cChave, " ", "")

While !Empty(cChave)
	cCpoChv := SubStr(cChave, 1, IIf((nPosChv := At("+", cChave)) > 0, nPosChv-1, Len(cChave)))
	cChave  := IIf(nPosChv > 0, SubStr(cChave, nPosChv+1), "")
	
	If "_FILIAL" $ cCpoChv
		cChvRet += xFilial(cAlias)
		
	Else
		cChvRet += aValores[aScan(aPosCpos, {| aCampos | aCampos[2] == PadR(AllTrim(cCpoChv), 10)})]		
	EndIf
End
Return(cChvRet)
/*
Static Function HSVldReord(oGet)
Local lRet := .T.

MsgStop(oGet:oBrowse:nColPos)
            
Return(lRet)*/
Function HS_FTRMORD(oGDReord, nLenCReord)
Local nCont := 10
Local nAux  := 0
Local nF    := 0

For nF := 1 To Len(oGDReord:aCols)
 
	If nCont == Val(oGDReord:aCols[nF, nOrdem])  .AND. nAux <> Val(oGDReord:aCols[nF, nOrdem])
		nAux := Val(oGDReord:aCols[nF, nOrdem])
		nCont += 10 		
	ElseIf nCont > Val(oGDReord:aCols[nF, nOrdem])
		nAux := Val(oGDReord:aCols[nF, nOrdem])			
	ElseIf nCont < Val(oGDReord:aCols[nF, nOrdem])  .AND. nAux < Val(oGDReord:aCols[nF, nOrdem]) 
		nAux := Val(oGDReord:aCols[nF, nOrdem]) 
		oGDReord:aCols[nF, nOrdem] := StrZero(nCont, nLenCReord)
		nCont += 10
	ElseIf nCont < Val(oGDReord:aCols[nF, nOrdem])  .AND. nAux  == Val(oGDReord:aCols[nF, nOrdem])
		oGDReord:aCols[nF, nOrdem] := StrZero(nCont - 10, nLenCReord)	 								
	ElseIf nCont == Val(oGDReord:aCols[nF, nOrdem])  .AND. nAux  == Val(oGDReord:aCols[nF, nOrdem])	
		oGDReord:aCols[nF, nOrdem] := StrZero(nCont - 10, nLenCReord)	 	
	EndIf

Next nF

//oGDReord:oBrowse:Refresh()
Return(.T.)


