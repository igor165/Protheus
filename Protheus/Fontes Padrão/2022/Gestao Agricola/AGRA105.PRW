#include 'AGRA105.CH'
#include 'protheus.ch'

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRA105  บ Autor ณ Ricardo Tomasi     บ Data ณ  09/08/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina para inclusใo de contratos financeiros.             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsga                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function AGRA105()
Private cCadastro := STR0001 //"Contrato Financeiro"
Private aRotina   := MenuDef()

dbSelectArea('NO7')
dbSetOrder(1)

mBrowse(06, 01, 22, 75, 'NO7')

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRA105A บ Autor ณ Ricardo Tomasi     บ Data ณ  21/07/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina auxilial para montagem da tela de cadastro.         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function AGRA105A(cAlias, nReg, nOpc)
Local aSize    := MsAdvSize()
Local aObjects := {{100,100,.t.,.t.},{100,100,.t.,.t.},{100,015,.t.,.f.}}
Local aInfo    := {aSize[1],aSize[2],aSize[3],aSize[4],3,3}
Local aPosObj  := MsObjSize(aInfo,aObjects)
Local nOpcX    := aRotina[nOpc,4]
Local nOpcA    := 0
Local nX       := 0
Local nC       := 0
Local aCampos  := Array(0)

Private aGets    := Array(0)
Private aTela    := Array(0,0)
Private aHeader  := Array(0)
Private aCols    := Array(0)
Private oDlg
Private o105Ench
Private o105GetD

If nOpcX==2
	aAdd(aCampos, 'NO8_STATUS')
EndIf
aAdd(aCampos, 'NO8_PREFIX'); aAdd(aCampos, 'NO8_NUMERO'); aAdd(aCampos, 'NO8_PARCEL')
aAdd(aCampos, 'NO8_TIPO'  ); aAdd(aCampos, 'NO8_DATVEN'); aAdd(aCampos, 'NO8_VALOR' )
aAdd(aCampos, 'NO8_NATURE'); aAdd(aCampos, 'NO8_HISTOR')

For nX := 1 To Len(aCampos)
	If X3USADO(aCampos[nX]) .And. cNivel >= AGRRETNIV(aCampos[nX])
		aAdd(aHeader,{AllTrim(RetTitle(aCampos[nX])), aCampos[nX], X3PICTURE(aCampos[nX]), TamSx3(aCampos[nX])[1], TamSx3(aCampos[nX])[2], X3VALID(aCampos[nX]), X3USADO(aCampos[nX]), TamSx3(aCampos[nX])[3], "NO8", AGRRETCTXT("NO8", aCampos[nX]) })
	EndIf
Next nX

If nOpcX==3
	aAdd(aCols, Array(Len(aHeader)+1))
	For nX := 1 to Len(aHeader)
		aCols[1,nX] := CriaVar(aHeader[nX,2])
	Next nX
	aCols[1,Len(aHeader)+1] := .f.

	RegToMemory('NO7',.T.)
	M->NO7_TIPO := 'PR'
Else
	dbSelectArea('NO8')
	dbSetOrder(1)
	dbSeek(xFilial('NO8')+NO7->NO7_NUMERO+NO7->NO7_ADTIVO+NO7->NO7_TIPO)
	While !Eof() .And. NO8->NO8_NUMCT+NO8->NO8_ADTCT+NO8->NO8_TIPCT == NO7->NO7_NUMERO+NO7->NO7_ADTIVO+NO7->NO7_TIPO
		nC++
		aAdd(aCols, Array(Len(aHeader)+1))
		For nX := 1 to Len(aHeader)
			aCols[nC,nX] := FieldGet(FieldPos(aHeader[nX,2]))
		Next nX
		aCols[nC,Len(aHeader)+1] := .f.
		dbSkip()
	EndDo
	RegToMemory('NO7',.F.)
EndIf

Define MSDialog oDlg Title cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd Pixel

	o105Ench := MsMGet():New('NO7',nReg,nOpcX,,,,,aPosObj[1],,3,,,,oDlg,,.t.)
	o105GetD := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcX,,'AGRA105E',,.f.,,Len(aHeader),,,,,,,oDlg)

Activate MsDialog oDlg On Init EnchoiceBar(oDlg, {|| nOpcA := 1, IIf(o105GetD:TudoOK().And.Obrigatorio(aGets,aTela), oDlg:End(), nOpca := 0) } , {|| nOpcA := 0, oDlg:End() })

If nOpcA==1
	If nOpcX == 3
		fInclui()
		//Ponto de Entrada apos inclusใo do Contrato Financeiro
		If ExistBlock('AGRA105IC')
			ExecBlock('AGRA105IC',.F.,.F.)
		EndIf
	EndIf
	If nOpcX == 5; fExclui(); EndIf
Else
	If nOpcX==3
		If __lSX8
			RollBackSX8()
		EndIf
	EndIf
EndIf

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRA105B บ Autor ณ Ricardo Tomasi     บ Data ณ  21/07/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina auxilial para montagem da tela de cadastro.         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function AGRA105B(cAlias, nReg, nOpc)
Local aSize    := MsAdvSize()
Local aObjects := {{100,100,.t.,.t.},{100,100,.t.,.t.},{100,015,.t.,.f.}}
Local aInfo    := {aSize[1],aSize[2],aSize[3],aSize[4],3,3}
Local aPosObj  := MsObjSize(aInfo,aObjects)
Local nOpcA    := 0
Local nX       := 0
Local aCampos  := {}

Private aGets    := Array(0)
Private aTela    := Array(0,0)
Private aHeader  := Array(0)
Private aCols    := Array(0)
Private oDlg
Private o105Ench
Private o105GetD

aAdd(aCampos, 'NO8_PREFIX'); aAdd(aCampos, 'NO8_NUMERO'); aAdd(aCampos, 'NO8_PARCEL')
aAdd(aCampos, 'NO8_TIPO'  ); aAdd(aCampos, 'NO8_DATVEN'); aAdd(aCampos, 'NO8_VALOR' )
aAdd(aCampos, 'NO8_NATURE'); aAdd(aCampos, 'NO8_HISTOR')

If NO7->NO7_TIPO == 'JR'
	ApMsgAlert( STR0010 )
	Return()
EndIf

If NO7->NO7_TIPO == 'PR'
	aAreaAtu := GetArea()
	If dbSeek(xFilial('NO7')+NO7->NO7_NUMERO+'1JR')
		ApMsgAlert( STR0011 )
		Return()
	Else
		RestArea(aAreaAtu)
	EndIf
EndIf

For nX := 1 To Len(aCampos)
	If X3USADO(aCampos[nX]) .And. cNivel >= AGRRETNIV(aCampos[nX])
		aAdd(aHeader,{AllTrim(RetTitle(aCampos[nX])), aCampos[nX], X3PICTURE(aCampos[nX]), TamSx3(aCampos[nX])[1], TamSx3(aCampos[nX])[2], X3VALID(aCampos[nX]), X3USADO(aCampos[nX]), TamSx3(aCampos[nX])[3], "NO8", AGRRETCTXT("NO8", aCampos[nX]) })
	EndIf
Next nX

aAdd(aCols, Array(Len(aHeader)+1))
For nX := 1 to Len(aHeader)
	aCols[1,nX] := CriaVar(aHeader[nX,2])
Next nX
aCols[1,Len(aHeader)+1] := .f.

RegToMemory('NO7',.T.)
M->NO7_NUMERO := NO7->NO7_NUMERO
M->NO7_TIPO   := 'JR'
M->NO7_NUMCMP := NO7->NO7_NUMCMP
M->NO7_CODFOR := NO7->NO7_CODFOR
M->NO7_LOJFOR := NO7->NO7_LOJFOR
M->NO7_DATEMI := NO7->NO7_DATEMI

Define MSDialog oDlg Title cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd Pixel

	o105Ench := MsMGet():New('NO7',,3,,,,,aPosObj[1],,3,,,,oDlg,,.t.)
	o105GetD := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],3,,'AGRA105E',,.f.,,Len(aHeader),,,,,,,oDlg)

Activate MsDialog oDlg On Init EnchoiceBar(oDlg, {|| nOpcA := 1, IIf(o105GetD:TudoOK().And.Obrigatorio(aGets,aTela), oDlg:End(), nOpca := 0) } , {|| nOpcA := 0, oDlg:End() })

If nOpcA == 1
	fInclui()
EndIf

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRA105C บ Autor ณ Ricardo Tomasi     บ Data ณ  21/07/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina auxilial para montagem da tela de cadastro.         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function AGRA105C(cAlias, nReg, nOpc)
Local aSize    := MsAdvSize()
Local aObjects := {{100,100,.t.,.t.},{100,100,.t.,.t.},{100,015,.t.,.f.}}
Local aInfo    := {aSize[1],aSize[2],aSize[3],aSize[4],3,3}
Local aPosObj  := MsObjSize(aInfo,aObjects)
Local nOpcA    := 0
Local nX       := 0
Local aCampos  := {}
Local nValor   := 0

Private aGets    := Array(0)
Private aTela    := Array(0,0)
Private aHeader  := Array(0)
Private aCols    := Array(0)
Private oDlg
Private o105Ench
Private o105GetD

aAdd(aCampos, 'NO8_PREFIX')
aAdd(aCampos, 'NO8_NUMERO')
aAdd(aCampos, 'NO8_PARCEL')
aAdd(aCampos, 'NO8_TIPO'  )
aAdd(aCampos, 'NO8_DATVEN')
aAdd(aCampos, 'NO8_VALOR' )
aAdd(aCampos, 'NO8_NATURE')
aAdd(aCampos, 'NO8_HISTOR')

aAreaAtu := GetArea()
If dbSeek(xFilial('NO7')+NO7->NO7_NUMERO+RetAsc(Val(NO7->NO7_ADTIVO)+1,1,.t.)+NO7->NO7_TIPO)
	ApMsgAlert( STR0012 )
	Return()
EndIf
RestArea(aAreaAtu)

For nX := 1 To Len(aCampos)
	If X3USADO(aCampos[nX]) .And. cNivel >= AGRRETNIV(aCampos[nX])
		aAdd(aHeader,{AllTrim(RetTitle(aCampos[nX])), aCampos[nX], X3PICTURE(aCampos[nX]), TamSx3(aCampos[nX])[1], TamSx3(aCampos[nX])[2], X3VALID(aCampos[nX]), X3USADO(aCampos[nX]), TamSx3(aCampos[nX])[3], "NO8", AGRRETCTXT("NO8", aCampos[nX]) })
	EndIf
Next nX

aAdd(aCols, Array(Len(aHeader)+1))
For nX := 1 to Len(aHeader)
	aCols[1,nX] := CriaVar(aHeader[nX,2])
Next nX
aCols[1,Len(aHeader)+1] := .f.

RegToMemory('NO7',.T.)
M->NO7_NUMERO := NO7->NO7_NUMERO
M->NO7_ADTIVO := RetAsc(Val(NO7->NO7_ADTIVO)+1,1,.t.)
M->NO7_TIPO   := NO7->NO7_TIPO
M->NO7_NUMCMP := NO7->NO7_NUMCMP
M->NO7_CODFOR := NO7->NO7_CODFOR
M->NO7_LOJFOR := NO7->NO7_LOJFOR
M->NO7_MOEDA  := NO7->NO7_MOEDA 
M->NO7_NATURE := NO7->NO7_NATURE
M->NO7_HISTOR := NO7->NO7_HISTOR
M->NO7_CONTAD := NO7->NO7_CONTAD
M->NO7_CCD    := NO7->NO7_CCD
M->NO7_ITEMD  := NO7->NO7_ITEMD
M->NO7_CLVLD  := NO7->NO7_CLVLD


dbSelectArea('NO8')
dbSetOrder(1)
dbSeek(xFilial('NO8')+NO7->NO7_NUMERO+NO7->NO7_ADTIVO+NO7->NO7_TIPO)
While !Eof() .And. NO8->NO8_NUMCT+NO8->NO8_ADTCT+NO8->NO8_TIPCT == NO7->NO7_NUMERO+NO7->NO7_ADTIVO+NO7->NO7_TIPO
	If NO8->NO8_STATUS == 'A'
		nValor += NO8->NO8_VALOR
	EndIf
	dbSkip()
EndDo

If nValor > 0
	M->NO7_VALOR := nValor
Else
	ApMsgAlert( STR0013 )
	Return()
EndIf

dbSelectArea('NO7')

Define MSDialog oDlg Title cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd Pixel

	o105Ench := MsMGet():New('NO7',,3,,,,,aPosObj[1],,3,,,,oDlg,,.t.)
	o105GetD := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],3,,'AGRA105E',,.f.,,Len(aHeader),,,,,,,oDlg)

Activate MsDialog oDlg On Init EnchoiceBar(oDlg, {|| nOpcA := 1, IIf(o105GetD:TudoOK().And.Obrigatorio(aGets,aTela), oDlg:End(), nOpca := 0) } , {|| nOpcA := 0, oDlg:End() })

If nOpcA == 1
	If fReneg()
		fInclui()
	EndIf
EndIf

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRA105D บ Autor ณ Ricardo Tomasi     บ Data ณ  21/07/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina auxilial para gera็ใo das linhas do GetDados.       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function AGRA105D()
Local lRetorno  := .t.
Local aParcela  := Array(0)
Local cParcela  := SuperGetMV("MV_1DUP",.F.,"A")
Local nTamParc  := TamSx3("NO8_PARCEL")[1]
Local nX        := 0
Local nTotal    := 0
Local nP_PREFIX := aScan(aHeader, { |x| Alltrim(x[2]) == 'NO8_PREFIX'})
Local nP_NUMERO := aScan(aHeader, { |x| Alltrim(x[2]) == 'NO8_NUMERO'})
Local nP_PARCEL := aScan(aHeader, { |x| Alltrim(x[2]) == 'NO8_PARCEL'})
Local nP_TIPO   := aScan(aHeader, { |x| AllTrim(x[2]) == 'NO8_TIPO'  })
Local nP_DATVEN := aScan(aHeader, { |x| Alltrim(x[2]) == 'NO8_DATVEN'})
Local nP_VALOR  := aScan(aHeader, { |x| Alltrim(x[2]) == 'NO8_VALOR' })
Local nP_NATURE := aScan(aHeader, { |x| Alltrim(x[2]) == 'NO8_NATURE'})
Local nP_HISTOR := aScan(aHeader, { |x| Alltrim(x[2]) == 'NO8_HISTOR'})
Local lAGRCTPR  := GetMV('MV_AGRCTPR',,'DP ')
Local lAGRCTJR  := GetMV('MV_AGRCTJR',,'JP ')

If Empty(M->NO7_CONPAG)
	If !Empty(M->NO7_NUMPAR) .And. !Empty(M->NO7_DATVEN) .And. !Empty(M->NO7_PERVEN)
		dDatVen := M->NO7_DATVEN
		nValPar := Round(M->NO7_VALOR / M->NO7_NUMPAR, 2)
		
		For nX := 1 To M->NO7_NUMPAR
			If nX > 1
				dDatVen += M->NO7_PERVEN
			EndIf
			aAdd(aParcela, {dDatVen, nValPar} )
		Next nX
	EndIf
Else
	aParcela := Condicao(M->NO7_VALOR,M->NO7_CONPAG,,M->NO7_DATEMI)
EndIf                                     

If nTamParc <> Len(cParcela)
	Help('',1,'A1031DUP')
	lRetorno:= .F.
EndIf  

If lRetorno .And. (nTamParc == 1 .And. Len(aParcela) > 35)
	Help('',1,'A103PARC')    
	lRetorno:= .F.
EndIf 

If lRetorno
	If Len(aParcela) > 0
		For nX := 1 To Len(aParcela)
			nTotal := nTotal + aParcela[nX,2]
		Next nX
		If nTotal <> M->NO7_VALOR
			If nTotal > M->NO7_VALOR
				aParcela[nX-1,2] := aParcela[nX-1,2] - (nTotal - M->NO7_VALOR)
			Else
				aParcela[nX-1,2] := aParcela[nX-1,2] + (M->NO7_VALOR - nTotal)
			EndIf
		EndIf
	EndIf
	
	If Len(aParcela) > 0
		aCols := Array(Len(aParcela),Len(aHeader)+1)
		For nX := 1 To Len(aCols)
			aCols[nX,nP_PREFIX] := 'CT'+M->NO7_ADTIVO
			aCols[nX,nP_NUMERO] := M->NO7_NUMERO
			aCols[nX,nP_PARCEL] := StrZero(nX,nTamParc)
			aCols[nX,nP_TIPO  ] := IIf(M->NO7_TIPO=='PR',lAGRCTPR,lAGRCTJR)
			aCols[nX,nP_DATVEN] := aParcela[nX,1]
			aCols[nX,nP_VALOR ] := aParcela[nX,2]
			aCols[nX,nP_NATURE] := M->NO7_NATURE
			aCols[nX,nP_HISTOR] := Substr(M->NO7_HISTOR,1,TamSX3('NO8_HISTOR')[1])
			aCols[nX,Len(aHeader)+1] := .f.
		Next nX
	EndIf
                       
EndIf

o105GetD:nMax:=Len(aCols)
o105GetD:oBrowse:Refresh()

Return(lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRA105E บ Autor ณ Ricardo Tomasi     บ Data ณ  21/07/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina auxilial para gera็ใo das linhas do GetDados.       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function AGRA105E()
Local lRetorno  := .t.
Local nX        := 0
Local nTotal    := 0
Local nP_VALOR  := aScan(aHeader, { |x| Alltrim(x[2]) == 'NO8_VALOR' })

For nX := 1 To Len(aCols)
	nTotal += aCols[nX,nP_VALOR]
Next nX

If nTotal <> M->NO7_VALOR
	ApMsgAlert( STR0009 )
	lRetorno := .f.
EndIf

Return(lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRA105F บ Autor ณ Ricardo Tomasi     บ Data ณ  21/07/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina auxilial para gera็ใo das linhas do GetDados.       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function AGRA105F()
Local lRetorno  := .t.
Local nX        := 0
Local nP_NATURE := aScan(aHeader, { |x| Alltrim(x[2]) == 'NO8_NATURE'})
Local nP_HISTOR := aScan(aHeader, { |x| Alltrim(x[2]) == 'NO8_HISTOR'})

For nX := 1 To Len(aCols)
	aCols[nX,nP_NATURE] := M->NO7_NATURE
	aCols[nX,nP_HISTOR] := Substr(M->NO7_HISTOR,1,TamSX3('NO8_HISTOR')[1])
Next nX

o105GetD:nMax:=Len(aCols)
o105GetD:oBrowse:Refresh()

Return(lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRA105G บ Autor ณ Ricardo Tomasi     บ Data ณ  21/07/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Ponto de Entrada na Baixa do Titulo a Pagar.               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function AGRA105G()
	dbSelectArea('NO8')
	dbSetOrder(2)
	If dbSeek(xFilial('NO8')+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO)
		If RecLock('NO8',.F.)
			If SE2->E2_SALDO > 0
				NO8->NO8_STATUS := 'C'
			Else
				NO8->NO8_STATUS := 'B'
			EndIf
			MsUnLock()
		EndIf
	EndIf
Return()


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRA105H บ Autor ณ Ricardo Tomasi     บ Data ณ  21/07/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Ponto de Entrada no Cancelamento da Baixa do Titulo a Pagarบฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑhฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function AGRA105H()
	dbSelectArea('NO8')
	dbSetOrder(2)
	If dbSeek(xFilial('NO8')+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO)
		If RecLock('NO8',.F.)
			NO8->NO8_STATUS := 'A'
			MsUnLock()
		EndIf
	EndIf
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRA105I บ Autor ณ Ricardo Tomasi     บ Data ณ  21/07/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Permite selecionar parcelas a serem alteradas.             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑhฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function AGRA105I()
Local aSize    := MsAdvSize()
Local aObjects := {{100,100,.t.,.t.},{100,100,.t.,.t.},{100,015,.t.,.f.}}
Local aInfo    := {aSize[1],aSize[2],aSize[3],aSize[4],3,3}
Local aPosObj  := MsObjSize(aInfo,aObjects)

Local nX       := 0
Local nOpcA    := 0
Local cFiltro  := ''
Local aCampos  := {}
Local aListar  := {}
Local lRetorno := .T.

Private oDlg
Private oMark
Private cMarca  := GetMark()

If ExistBlock('AGRA105RP')
	lRetorno := ExecBlock('AGRA105RP',.F.,.F.)
EndIf

If !(lRetorno)
	Return()
EndIf

aAdd(aCampos, 'NO8_MARCA' )
aAdd(aCampos, 'NO8_PREFIX')
aAdd(aCampos, 'NO8_NUMERO')
aAdd(aCampos, 'NO8_PARCEL')
aAdd(aCampos, 'NO8_TIPO'  )
aAdd(aCampos, 'NO8_VALOR' )
aAdd(aCampos, 'NO8_DATVEN')

For nX := 1 To Len(aCampos)
	If aCampos[nX] == 'NO8_MARCA'
		aAdd(aListar,{aCampos[nX],, ''})
	Else
		aAdd(aListar,{aCampos[nX],,AllTrim(RetTitle(aCampos[nX])),X3PICTURE(aCampos[nX])})
	Endif
Next nX

RegToMemory('NO7',.F.)

dbSelectArea('NO8')
dbSetOrder(2)
cFiltro := 'NO8->NO8_NUMCT+NO8->NO8_ADTCT+NO8->NO8_TIPCT==NO7->NO7_NUMERO+NO7->NO7_ADTIVO+NO7->NO7_TIPO'
dbSetFilter({|| &cFiltro }, cFiltro )
dbGotop()

Define MSDialog oDlg Title "Selecione o titulo para altera็ใo..." From aSize[7],0 to aSize[6],aSize[5] of oMainWnd Pixel

	oMark := MsSelect():New('NO8', 'NO8_MARCA', 'NO8_STATUS<>"A"', aListar,, cMarca, aPosObj[1])
	oMark:bMark := {|| AGRA105J(cMarca) }
	oMark:oBrowse:Align       := CONTROL_ALIGN_ALLCLIENT
	oMark:oBrowse:lColDrag    := .T.

Activate MsDialog oDlg On Init EnchoiceBar(oDlg, {|| nOpcA := 1, oDlg:End() } , {|| nOpcA := 0, oDlg:End() })

If nOpcA == 1

	dbGoTop()
	While !Eof()
		If NO8->NO8_MARCA == cMarca
			fAltDados()
			If RecLock('NO8',.F.)
				NO8->NO8_MARCA := Space(2)
				MsUnLock()
			EndIf
		EndIf
		dbSkip()
	EndDo

EndIf

dbSelectArea('NO8')
Set Filter To
dbSetOrder(1)

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRA105J บ Autor ณ Ricardo Tomasi     บ Data ณ  21/07/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Marca e Desmarca os registro selecionados.                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑhฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function AGRA105J(cMarca)
Local nReg := Recno()

	If NO8->NO8_MARCA ==  cMarca

		If NO8->NO8_STATUS <> 'A'
			RecLock( 'NO8', .f.)
			NO8->NO8_MARCA := Space(2)
			MsUnLock()
		EndIf

		dbSelectArea('NO8')
		dbGotop()
		While !Eof()
			If Recno() <> nReg
				RecLock( 'NO8', .f.)
				NO8->NO8_MARCA := Space(2)
				MsUnLock()
			EndIf
			dbSkip()
		EndDo
		dbGoto(nReg)

	EndIf

	oMark:oBrowse:Refresh()

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ fInclui  บ Autor ณ Ricardo Tomasi     บ Data ณ  21/07/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina para grava็ใo dos dados. Gera็ใo de titulos a Pagar.บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function fInclui()
Local nX         := 0
Local nY         := 0
Local aFina050   := Array(0)
Local nP_PREFIX  := aScan(aHeader, { |x| Alltrim(x[2]) == 'NO8_PREFIX'})
Local nP_NUMERO  := aScan(aHeader, { |x| Alltrim(x[2]) == 'NO8_NUMERO'})
Local nP_PARCEL  := aScan(aHeader, { |x| Alltrim(x[2]) == 'NO8_PARCEL'})
Local nP_TIPO    := aScan(aHeader, { |x| Alltrim(x[2]) == 'NO8_TIPO'  })
Local nP_DATVEN  := aScan(aHeader, { |x| Alltrim(x[2]) == 'NO8_DATVEN'})
Local nP_VALOR   := aScan(aHeader, { |x| Alltrim(x[2]) == 'NO8_VALOR' })
Local nP_NATURE  := aScan(aHeader, { |x| Alltrim(x[2]) == 'NO8_NATURE'})
Local nP_HISTOR  := aScan(aHeader, { |x| Alltrim(x[2]) == 'NO8_HISTOR'})
Local lAGRA105E2 := ExistBlock('AGRA105E2')

Private lMsErroAuto := .f.

For nX := 1 To Len(aCols)
	If !(aCols[nX,Len(aHeader)+1])

		aAdd(aFina050,  {"E2_PREFIXO" , aCols[nX,nP_PREFIX], Nil})
		aAdd(aFina050,  {"E2_NUM"     , aCols[nX,nP_NUMERO], Nil})
		aAdd(aFina050,  {"E2_PARCELA" , aCols[nX,nP_PARCEL], Nil})
		aAdd(aFina050,  {"E2_TIPO"    , aCols[nX,nP_TIPO  ], Nil})
		aAdd(aFina050,  {"E2_NATUREZ" , aCols[nX,nP_NATURE], Nil})
		aAdd(aFina050,  {"E2_PORTADO" , M->NO7_CODBCO      , Nil})
		aAdd(aFina050,  {"E2_FORNECE" , M->NO7_CODFOR      , Nil})
		aAdd(aFina050,  {"E2_LOJA"    , M->NO7_LOJFOR      , Nil})
		aAdd(aFina050,  {"E2_EMISSAO" , M->NO7_DATEMI      , Nil})
		aAdd(aFina050,  {"E2_VENCTO"  , aCols[nX,nP_DATVEN], Nil})
		aAdd(aFina050,  {"E2_VALOR"   , aCols[nX,nP_VALOR] , Nil})
		aAdd(aFina050,  {"E2_MOEDA"   , M->NO7_MOEDA       , Nil})
		aAdd(aFina050,  {"E2_VLCRUZ"  , xMoeda(aCols[nX,nP_VALOR],M->NO7_MOEDA,1,M->NO7_DATEMI,9) , Nil})
		aAdd(aFina050,  {"E2_DEBITO"  , M->NO7_CONTAD      , Nil})
		aAdd(aFina050,  {"E2_CCD"     , M->NO7_CCD         , Nil})
		aAdd(aFina050,  {"E2_ITEMD"   , M->NO7_ITEMD       , Nil})
		aAdd(aFina050,  {"E2_CLVLDB"  , M->NO7_CLVLD       , Nil})
		aAdd(aFina050,  {"E2_HIST"    , aCols[nX,nP_HISTOR], Nil})
		aAdd(aFina050,  {"E2_ORIGEM"  , 'AGRA105'          , Nil})

		MSExecAuto({|x,y,z| fina050(x,y,z)},aFina050,Nil,3)

//		If lMsErroAuto
//			DisarmTransaction()
//			Mostraerro()
//			Return()
//		Else
		If lAGRA105E2
			ExecBlock('AGRA105E2',.F.,.F.)
		EndIf
		aFina050 := Array(0)
//		EndIf

	EndIf
Next nX

Begin Transaction

dbSelectArea('NO7')
dbSetOrder(1)
dbSeek(xFilial('NO7')+M->NO7_NUMERO+M->NO7_ADTIVO+M->NO7_TIPO)
If RecLock('NO7',.t.)
	For nX := 1 To FCount()
		If "_FILIAL" $ FieldName(nX)
			&('NO7->NO7_FILIAL') := xFilial('NO7')
		Else
			&('NO7->'+FieldName(nX)) := &('M->'+FieldName(nX))
		EndIf
	Next nX
	MsUnLock()
EndIf

For nX := 1 To Len(aCols)
	If !(aCols[nX,Len(aHeader)+1])
		If RecLock('NO8',.t.)
			NO8->NO8_FILIAL := xFilial('NO8')
			NO8->NO8_NUMCT  := NO7->NO7_NUMERO
			NO8->NO8_ADTCT  := NO7->NO7_ADTIVO
			NO8->NO8_TIPCT  := NO7->NO7_TIPO
			NO8->NO8_STATUS := 'A'
			For nY := 1 To Len(aHeader)
				&('NO8->'+aHeader[nY,2]) := aCols[nX,nY]
			Next nY
			msUnLock()
		EndIf
	EndIf
Next nX

End Transaction

Return() 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ fReneg   บ Autor ณ Ricardo Tomasi     บ Data ณ  21/07/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina para grava็ใo dos dados. Exclusใo de titulos a pagarบฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function fReneg()
Local aFina050  := Array(0)
Private lMsErroAuto := .f.

dbSelectArea('NO8')
dbSetOrder(1)
If dbSeek(xFilial('NO8')+NO7->NO7_NUMERO+NO7->NO7_ADTIVO+NO7->NO7_TIPO)
	While !Eof() .And. NO8->NO8_NUMCT+NO8->NO8_ADTCT+NO8->NO8_TIPCT == NO7->NO7_NUMERO+NO7->NO7_ADTIVO+NO7->NO7_TIPO
		dbSelectArea('SE2')
		dbSetOrder(1) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
		If dbSeek(xFilial('SE2')+NO8->NO8_PREFIX+NO8->NO8_NUMERO+NO8->NO8_PARCEL+NO8->NO8_TIPO)
			If SE2->E2_SALDO == NO8->NO8_VALOR

				aAdd(aFina050,  {"E2_PREFIXO" , SE2->E2_PREFIXO, Nil})
				aAdd(aFina050,  {"E2_NUM"     , SE2->E2_NUM    , Nil})
				aAdd(aFina050,  {"E2_PARCELA" , SE2->E2_PARCELA, Nil})
				aAdd(aFina050,  {"E2_TIPO"    , SE2->E2_TIPO   , Nil})
				aAdd(aFina050,  {"E2_FORNECE" , SE2->E2_FORNECE, Nil})
				aAdd(aFina050,  {"E2_LOJA"    , SE2->E2_LOJA   , Nil})

				MSExecAuto({|x,y,z| fina050(x,y,z)},aFina050,Nil,5)

				aFina050 := Array(0)

				If RecLock('NO8',.f.)
					NO8->NO8_STATUS := 'R'
					MsUnLock()
				EndIf
			EndIf
		EndIf
		dbSelectArea('NO8')
		dbSkip()
	EndDo
EndIf

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ fExclui  บ Autor ณ Ricardo Tomasi     บ Data ณ  21/07/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina para grava็ใo dos dados. Gera็ใo de titulos a Pagar.บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function fExclui()
Local aFina050   := Array(0)
Local cNumAnt    := NO7->NO7_NUMERO
Local cAdtAnt    := RetAsc(Val(NO7->NO7_ADTIVO)-1,1,.T.)
Local cTipAnt    := NO7->NO7_TIPO
Local cNumAtu    := NO7->NO7_NUMERO
Local cAdtAtu    := NO7->NO7_ADTIVO
Local cTipAtu    := NO7->NO7_TIPO
Local cNumPrx    := NO7->NO7_NUMERO
Local cAdtPrx    := RetAsc(Val(NO7->NO7_ADTIVO)+1,1,.T.)
Local cTipPrx    := NO7->NO7_TIPO
Local lAGRA105E2 := ExistBlock('AGRA105E2')

Private lMsErroAuto := .f.

dbSelectArea('NO7')
dbSetOrder(1)
If dbSeek(xFilial('NO7')+cNumPrx+cAdtPrx+cTipPrx)
	ApMsgAlert("Este contrato jแ foi renegociado, e nใo pode ser excluido.")
	Return()
Else
    If cTipAtu == 'PR' .And. cAdtAtu == '1'
    	If dbSeek(xFilial('NO7')+cNumAtu+'1JR')
			ApMsgAlert("Este contrato tem um contrato de juros em anexo, e nใo pode ser excluido.")
			Return()
    	Else
			dbSelectArea('NO8')
			dbSetOrder(1)
			If dbSeek(xFilial('NO8')+cNumAtu+cAdtAtu+cTipAtu)
				While !Eof() .And. NO8->NO8_NUMCT+NO8->NO8_ADTCT+NO8->NO8_TIPCT == cNumAtu+cAdtAtu+cTipAtu
					dbSelectArea('SE2')
					dbSetOrder(1) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
					If dbSeek(xFilial('SE2')+NO8->NO8_PREFIX+NO8->NO8_NUMERO+NO8->NO8_PARCEL+NO8->NO8_TIPO)
						If SE2->E2_SALDO <> NO8->NO8_VALOR
							ApMsgAlert("Este contrato tem parcelas baixadas, e nใo pode ser excluido.")
							Return()
						EndIf
					EndIf
					dbSelectArea('NO8')
					dbSkip()
				EndDo
			EndIf
			Begin Transaction
			dbSelectArea('NO8')
			dbSetOrder(1)
			If dbSeek(xFilial('NO8')+cNumAtu+cAdtAtu+cTipAtu)
				While !Eof() .And. NO8->NO8_NUMCT+NO8->NO8_ADTCT+NO8->NO8_TIPCT == cNumAtu+cAdtAtu+cTipAtu
					dbSelectArea('SE2')
					dbSetOrder(1) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
					If dbSeek(xFilial('SE2')+NO8->NO8_PREFIX+NO8->NO8_NUMERO+NO8->NO8_PARCEL+NO8->NO8_TIPO)

						aAdd(aFina050,  {"E2_PREFIXO" , SE2->E2_PREFIXO, Nil})
						aAdd(aFina050,  {"E2_NUM"     , SE2->E2_NUM    , Nil})
						aAdd(aFina050,  {"E2_PARCELA" , SE2->E2_PARCELA, Nil})
						aAdd(aFina050,  {"E2_TIPO"    , SE2->E2_TIPO   , Nil})
						aAdd(aFina050,  {"E2_FORNECE" , SE2->E2_FORNECE, Nil})
						aAdd(aFina050,  {"E2_LOJA"    , SE2->E2_LOJA   , Nil})
		
						MSExecAuto({|x,y,z| fina050(x,y,z)},aFina050,Nil,5)

						aFina050 := Array(0)
		
						dbSelectArea('NO8')
						If RecLock('NO8',.f.)
							dbDelete()
							MsUnLock()
						EndIf
						
					EndIf
					dbSkip()
				EndDo
			EndIf
			dbSelectArea('NO7')
			dbSetOrder(1)
			If dbSeek(xFilial('NO7')+cNumAtu+cAdtAtu+cTipAtu)
				If RecLock('NO7',.f.)
					dbDelete()
					MsUnLock()
				EndIf
			EndIf
			End Transaction
    	EndIf
    Else
	    //Volta situa็ใo anterior independente do TIPO
		dbSelectArea('NO8')
		dbSetOrder(1)
		If dbSeek(xFilial('NO8')+cNumAtu+cAdtAtu+cTipAtu)
			While !Eof() .And. NO8->NO8_NUMCT+NO8->NO8_ADTCT+NO8->NO8_TIPCT == cNumAtu+cAdtAtu+cTipAtu
				dbSelectArea('SE2')
				dbSetOrder(1) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
				If dbSeek(xFilial('SE2')+NO8->NO8_PREFIX+NO8->NO8_NUMERO+NO8->NO8_PARCEL+NO8->NO8_TIPO)
					If SE2->E2_SALDO <> NO8->NO8_VALOR
						ApMsgAlert("Este contrato tem parcelas baixadas, e nใo pode ser excluido.")
						Return()
					EndIf
				EndIf
				dbSelectArea('NO8')
				dbSkip()
			EndDo
		EndIf
		//Exclui atual
		dbSelectArea('NO8')
		dbSetOrder(1)
		If dbSeek(xFilial('NO8')+cNumAtu+cAdtAtu+cTipAtu)
			While !Eof() .And. NO8->NO8_NUMCT+NO8->NO8_ADTCT+NO8->NO8_TIPCT == cNumAtu+cAdtAtu+cTipAtu
				dbSelectArea('SE2')
				dbSetOrder(1) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
				If dbSeek(xFilial('SE2')+NO8->NO8_PREFIX+NO8->NO8_NUMERO+NO8->NO8_PARCEL+NO8->NO8_TIPO)

					aAdd(aFina050,  {"E2_PREFIXO" , SE2->E2_PREFIXO, Nil})
					aAdd(aFina050,  {"E2_NUM"     , SE2->E2_NUM    , Nil})
					aAdd(aFina050,  {"E2_PARCELA" , SE2->E2_PARCELA, Nil})
					aAdd(aFina050,  {"E2_TIPO"    , SE2->E2_TIPO   , Nil})
					aAdd(aFina050,  {"E2_FORNECE" , SE2->E2_FORNECE, Nil})
					aAdd(aFina050,  {"E2_LOJA"    , SE2->E2_LOJA   , Nil})

					MSExecAuto({|x,y,z| fina050(x,y,z)},aFina050,Nil,5)

					aFina050 := Array(0)

					dbSelectArea('NO8')
					If RecLock('NO8',.f.)
						dbDelete()
						MsUnLock()
					EndIf
					
				EndIf
				dbSkip()
			EndDo
		EndIf
		dbSelectArea('NO7')
		dbSetOrder(1)
		If dbSeek(xFilial('NO7')+cNumAtu+cAdtAtu+cTipAtu)
			If RecLock('NO7',.f.)
				dbDelete()
				MsUnLock()
			EndIf
		EndIf
		//Volta a situa็ใo anterior
		If dbSeek(xFilial('NO7')+cNumAnt+cAdtAnt+cTipAnt)
			dbSelectArea('NO8')
			dbSetOrder(1)
			If dbSeek(xFilial('NO8')+cNumAnt+cAdtAnt+cTipAnt)
				While !Eof() .And. NO8->NO8_NUMCT+NO8->NO8_ADTCT+NO8->NO8_TIPCT == cNumAnt+cAdtAnt+cTipAnt

					aAdd(aFina050,  {"E2_PREFIXO" , NO8->NO8_PREFIX, Nil})
					aAdd(aFina050,  {"E2_NUM"     , NO8->NO8_NUMERO, Nil})
					aAdd(aFina050,  {"E2_PARCELA" , NO8->NO8_PARCEL, Nil})
					aAdd(aFina050,  {"E2_TIPO"    , NO8->NO8_TIPO  , Nil})
					aAdd(aFina050,  {"E2_NATUREZ" , NO8->NO8_NATURE, Nil})
					aAdd(aFina050,  {"E2_PORTADO" , NO7->NO7_CODBCO, Nil})
					aAdd(aFina050,  {"E2_FORNECE" , NO7->NO7_CODFOR, Nil})
					aAdd(aFina050,  {"E2_LOJA"    , NO7->NO7_LOJFOR, Nil})
					aAdd(aFina050,  {"E2_EMISSAO" , NO7->NO7_DATEMI, Nil})
					aAdd(aFina050,  {"E2_VENCTO"  , NO8->NO8_DATVEN, Nil})
					aAdd(aFina050,  {"E2_VALOR"   , NO8->NO8_VALOR , Nil})
					aAdd(aFina050,  {"E2_MOEDA"   , NO7->NO7_MOEDA , Nil})
					aAdd(aFina050,  {"E2_VLCRUZ"  , xMoeda(NO8->NO8_VALOR,NO7->NO7_MOEDA,1,NO7->NO7_DATEMI,9) , Nil})
					aAdd(aFina050,  {"E2_DEBITO"  , NO7->NO7_CONTAD, Nil})
					aAdd(aFina050,  {"E2_CCD"     , NO7->NO7_CCD   , Nil})
					aAdd(aFina050,  {"E2_ITEMD"   , NO7->NO7_ITEMD , Nil})
					aAdd(aFina050,  {"E2_CLVLDB"  , NO7->NO7_CLVLD , Nil})
					aAdd(aFina050,  {"E2_HIST"    , NO8->NO8_HISTOR, Nil})
					aAdd(aFina050,  {"E2_ORIGEM"  , 'AGRA105'      , Nil})
			
					MSExecAuto({|x,y,z| fina050(x,y,z)},aFina050,Nil,3)

					aFina050 := Array(0)
					If lAGRA105E2
						ExecBlock('AGRA105E2',.F.,.F.)
					EndIf

					If RecLock('NO8',.f.)
						NO8->NO8_STATUS := 'A'
						MsUnLock()
					EndIf

					dbSkip()
				EndDo
			EndIf
		EndIf
    EndIf
EndIf

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ fAltDadosบ Autor ณ Ricardo Tomasi     บ Data ณ  21/07/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina para altera็ใo da data de vencimento e valor do tit-บฑฑ
ฑฑบ          ณ no Contas a Pagar.                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function fAltDados()
Local oDlg
Local oGrp1
Local oSay1
Local oSay2
Local oSay3
Local oGet1
Local oGet2
Local oSBtn1
Local oSBtn2
Local nOpcA   := 0
Local aFina050:= {}
Local cTitulo := NO8->NO8_PREFIX+' - '+NO8->NO8_NUMERO+' - '+NO8->NO8_PARCEL+' - '+NO8->NO8_TIPO
Local cDatAnt := NO8->NO8_DATVEN
Local nValAnt := NO8->NO8_VALOR
Local cDatVen := NO8->NO8_DATVEN
Local nValor  := NO8->NO8_VALOR

Private lMsErroAuto := .f.

oDlg := MSDIALOG():Create()
oDlg:cName := 'oDlg'
oDlg:cCaption := "Altere os campos e confirme..."
oDlg:nLeft := 0
oDlg:nTop := 0
oDlg:nWidth := 370
oDlg:nHeight := 224
oDlg:lShowHint := .F.
oDlg:lCentered := .T.

oGrp1 := TGROUP():Create(oDlg)
oGrp1:cName := 'oGrp1'
oGrp1:cCaption := "Titulo"
oGrp1:nLeft := 10
oGrp1:nTop := 10
oGrp1:nWidth := 340
oGrp1:nHeight := 42
oGrp1:lShowHint := .F.
oGrp1:lReadOnly := .F.
oGrp1:Align := 0
oGrp1:lVisibleControl := .T.

oSay1 := TSAY():Create(oDlg)
oSay1:cName := 'oSay1'
oSay1:cCaption := cTitulo
oSay1:nLeft := 60
oSay1:nTop := 24
oSay1:nWidth := 280
oSay1:nHeight := 21
oSay1:lShowHint := .F.
oSay1:lReadOnly := .F.
oSay1:Align := 0
oSay1:lVisibleControl := .T.
oSay1:lWordWrap := .F.
oSay1:lTransparent := .F.

oSay2 := TSAY():Create(oDlg)
oSay2:cName := 'oSay2'
oSay2:cCaption := "Data do Vencimento"
oSay2:nLeft := 60
oSay2:nTop := 80
oSay2:nWidth := 100
oSay2:nHeight := 21
oSay2:lShowHint := .F.
oSay2:lReadOnly := .F.
oSay2:Align := 0
oSay2:lVisibleControl := .T.
oSay2:lWordWrap := .F.
oSay2:lTransparent := .F.

oSay3 := TSAY():Create(oDlg)
oSay3:cName := 'oSay3'
oSay3:cCaption := "Valor"
oSay3:nLeft := 60
oSay3:nTop := 110
oSay3:nWidth := 100
oSay3:nHeight := 21
oSay3:lShowHint := .F.
oSay3:lReadOnly := .F.
oSay3:Align := 0
oSay3:lVisibleControl := .T.
oSay3:lWordWrap := .F.
oSay3:lTransparent := .F.

oGet1 := TGET():Create(oDlg)
oGet1:cName := 'oGet1'
oGet1:nLeft := 160
oGet1:nTop := 80
oGet1:nWidth := 100
oGet1:nHeight := 21
oGet1:lShowHint := .F.
oGet1:lReadOnly := .F.
oGet1:Align := 0
oGet1:cVariable := 'cDatVen'
oGet1:bSetGet := {|u| If(PCount()>0,cDatVen:=u,cDatVen) }
oGet1:lVisibleControl := .T.
oGet1:lPassword := .F.
oGet1:lHasButton := .F.
oGet1:bValid := {|| cDatVen > NO7->NO7_DATEMI }

oGet2 := TGET():Create(oDlg)
oGet2:cName := 'oGet2'
oGet2:nLeft := 160
oGet2:nTop := 110
oGet2:nWidth := 100
oGet2:nHeight := 21
oGet2:lShowHint := .F.
oGet2:lReadOnly := .F.
oGet2:Align := 0
oGet2:cVariable := 'nValor'
oGet2:bSetGet := {|u| If(PCount()>0,nValor:=u,nValor) }
oGet2:lVisibleControl := .T.
oGet2:lPassword := .F.
oGet2:Picture := '@E 999,999,999.99'
oGet2:lHasButton := .F.
oGet2:bValid := {|| Positivo(nValor) }

oSBtn1 := SBUTTON():Create(oDlg)
oSBtn1:cName := 'oSBtn1'
oSBtn1:cCaption := "Confirmar"
oSBtn1:nLeft := 235
oSBtn1:nTop := 163
oSBtn1:nWidth := 52
oSBtn1:nHeight := 22
oSBtn1:lShowHint := .F.
oSBtn1:lReadOnly := .F.
oSBtn1:Align := 0
oSBtn1:lVisibleControl := .T.
oSBtn1:nType := 1
oSBtn1:bAction := {|| nOpcA := 1, oDlg:End() }

oSBtn2 := SBUTTON():Create(oDlg)
oSBtn2:cName := 'oSBtn2'
oSBtn2:cCaption := "Cancelar"
oSBtn2:nLeft := 294
oSBtn2:nTop := 163
oSBtn2:nWidth := 52
oSBtn2:nHeight := 22
oSBtn2:lShowHint := .F.
oSBtn2:lReadOnly := .F.
oSBtn2:Align := 0
oSBtn2:lVisibleControl := .T.
oSBtn2:nType := 2
oSBtn2:bAction := {|| nOpcA := 0, oDlg:End() }

oDlg:Activate()

If nOpcA == 1
	If nValor <> nValAnt
		dbSelectArea('SE2')
		dbSetOrder(1) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
		If dbSeek(xFilial('SE2')+NO8->NO8_PREFIX+NO8->NO8_NUMERO+NO8->NO8_PARCEL+NO8->NO8_TIPO)
			aAdd(aFina050,  {"E2_PREFIXO" , SE2->E2_PREFIXO, Nil})
			aAdd(aFina050,  {"E2_NUM"     , SE2->E2_NUM    , Nil})
			aAdd(aFina050,  {"E2_PARCELA" , SE2->E2_PARCELA, Nil})
			aAdd(aFina050,  {"E2_TIPO"    , SE2->E2_TIPO   , Nil})
			aAdd(aFina050,  {"E2_FORNECE" , SE2->E2_FORNECE, Nil})
			aAdd(aFina050,  {"E2_LOJA"    , SE2->E2_LOJA   , Nil})

			MSExecAuto({|x,y,z| fina050(x,y,z)},aFina050,Nil,5)

			aFina050 := Array(0)

			dbSelectArea('NO7')
			If RecLock('NO7',.f.)
				NO7->NO7_VALOR := (NO7->NO7_VALOR - nValAnt) + nValor
				MsUnLock()
			EndIf
			dbSelectArea('NO8')
			If RecLock('NO8',.f.)
				NO8->NO8_DATVEN := cDatVen
				NO8->NO8_VALOR  := nValor
				MsUnLock()
			EndIf

		EndIf

		aAdd(aFina050,  {"E2_PREFIXO" , NO8->NO8_PREFIX, Nil})
		aAdd(aFina050,  {"E2_NUM"     , NO8->NO8_NUMERO, Nil})
		aAdd(aFina050,  {"E2_PARCELA" , NO8->NO8_PARCEL, Nil})
		aAdd(aFina050,  {"E2_TIPO"    , NO8->NO8_TIPO  , Nil})
		aAdd(aFina050,  {"E2_NATUREZ" , NO8->NO8_NATURE, Nil})
		aAdd(aFina050,  {"E2_PORTADO" , NO7->NO7_CODBCO, Nil})
		aAdd(aFina050,  {"E2_FORNECE" , NO7->NO7_CODFOR, Nil})
		aAdd(aFina050,  {"E2_LOJA"    , NO7->NO7_LOJFOR, Nil})
		aAdd(aFina050,  {"E2_EMISSAO" , NO7->NO7_DATEMI, Nil})
		aAdd(aFina050,  {"E2_VENCTO"  , NO8->NO8_DATVEN, Nil})
		aAdd(aFina050,  {"E2_VALOR"   , NO8->NO8_VALOR , Nil})
		aAdd(aFina050,  {"E2_MOEDA"   , NO7->NO7_MOEDA , Nil})
		aAdd(aFina050,  {"E2_VLCRUZ"  , xMoeda(NO8->NO8_VALOR,NO7->NO7_MOEDA,1,NO7->NO7_DATEMI,9) , Nil})
		aAdd(aFina050,  {"E2_DEBITO"  , NO7->NO7_CONTAD, Nil})
		aAdd(aFina050,  {"E2_CCD"     , NO7->NO7_CCD   , Nil})
		aAdd(aFina050,  {"E2_ITEMD"   , NO7->NO7_ITEMD , Nil})
		aAdd(aFina050,  {"E2_CLVLDB"  , NO7->NO7_CLVLD , Nil})
		aAdd(aFina050,  {"E2_HIST"    , NO8->NO8_HISTOR, Nil})
		aAdd(aFina050,  {"E2_ORIGEM"  , 'AGRA105'      , Nil})

		MSExecAuto({|x,y,z| fina050(x,y,z)},aFina050,Nil,3)

		aFina050 := Array(0)
		If ExistBlock('AGRA105E2')
			ExecBlock('AGRA105E2',.F.,.F.)
		EndIf

	Else
		If cDatVen <> cDatAnt
			dbSelectArea('SE2')
			dbSetOrder(1) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
			If dbSeek(xFilial('SE2')+NO8->NO8_PREFIX+NO8->NO8_NUMERO+NO8->NO8_PARCEL+NO8->NO8_TIPO)
				If RecLock('SE2',.F.)
					SE2->E2_VENCTO  := cDatVen
					SE2->E2_VENCREA := cDatVen
					MsUnLock()
				EndIf
				dbSelectArea('NO8')
				If RecLock('NO8',.f.)
					NO8->NO8_DATVEN := cDatVen
					MsUnLock()
				EndIf
			EndIf
		EndIf
	EndIf

EndIf

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ MenuDef  บAutor  ณ Ricardo Tomasi     บ Data ณ  04/10/2006 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cria็ใo do menu.                                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MenuDef()

Local aRotina:= {;
				 { STR0002 ,"AxPesqui" ,0,1},; //"Pesquisar"
				 { STR0003 ,"AGRA105A" ,0,2},; //"Visualizar"
				 { STR0004 ,"AGRA105A" ,0,3},; //"Incluir"
				 { STR0005 ,"AGRA105B" ,0,4},; //"Juros"
				 { STR0006 ,"AGRA105C" ,0,4},; //"Renegociar"
				 { STR0007 ,"AGRA105I" ,0,4},; //"Reneg.Parc."
				 { STR0008 ,"AGRA105A" ,0,5} ; //"Excluir"
				 }

Return(aRotina)
