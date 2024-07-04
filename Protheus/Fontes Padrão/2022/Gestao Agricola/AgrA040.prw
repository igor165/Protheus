#include 'AGRA040.CH'
#include 'protheus.ch'

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRA040  บ Autor ณ Ricardo Tomasi     บ Data ณ  25/05/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Cadastro de Mensagens para as Notas Fiscais de Saida e ou  บฑฑ
ฑฑบ          ณ Documento de Entrada.                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function AGRA040()
Private cCadastro := STR0001 //"Cadastro de Historicos Padrao"
Private aRotina   := MenuDef()

dbSelectArea('NNL')
dbSetOrder(1)

mBrowse( 6, 1, 22, 75, 'NNL')

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRA040A บ Autor ณ Ricardo Tomasi     บ Data ณ  25/05/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ GetDados para cadastro de Historicos Padrใo.               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function AGRA040A(cAlias,nReg,nOpc)
Local aSize     := MsAdvSize()
Local aObjects  := {{100,100,.t.,.t.},{100,100,.t.,.t.},{100,015,.t.,.f.}}
Local aInfo     := {aSize[1],aSize[2],aSize[3],aSize[4],3,3}
Local aPosObj   := MsObjSize(aInfo,aObjects)
Local nOpcX     := aRotina[nOpc,4]
Local nOpcA     := 0
Local nX        := 0
Local nY        := 0
Local nC        := 0
Local aCampos   := Array(0)
Local cCodAnt   := IIf(nOpcX==3,GetSXENum('NNL','NNL_CODIGO'),NNL->NNL_CODIGO)

Private aGets   := Array(0)
Private aTela   := Array(0,0)
Private aHeader := Array(0)
Private aCols   := Array(0)
Private oDlg
Private oGetD

aAdd(aCampos, 'NNL_SEQ'); aAdd(aCampos, 'NNL_MENS')

If ExistBlock('AGRA040IT')
	aCampos := ExecBlock('AGRA040IT',.f.,.f.,aCampos)
EndIf

For nX := 1 To Len(aCampos)
	If X3USADO(aCampos[nX]) .And. cNivel >= AGRRETNIV(aCampos[nX])
		aAdd(aHeader,{AllTrim(RetTitle()), aCampos[nX], X3PICTURE(aCampos[nX]), TamSx3(aCampos[nX])[1], TamSx3(aCampos[nX])[2], X3VALID(aCampos[nX]), X3USADO(aCampos[nX]), TamSx3(aCampos[nX])[3], "NNL", AGRRETCTXT("NNL", aCampos[nX]) })
	Endif
Next nX

If nOpcX==3
	aAdd(aCols, Array(Len(aHeader)+1))
	For nX := 1 to Len(aHeader)
		aCols[1,nX] := CriaVar(aHeader[nX,2])
		If 'NNL_SEQ' $ aHeader[nX,2]
			aCols[1,nX] := Soma1(Replicate('0',aHeader[nX,4]))
		EndIf
	Next
	aCols[1,Len(aHeader)+1] := .f.
Else
	dbSelectArea('NNL')
	dbSetOrder(1)
	dbSeek(xFilial('NNL')+cCodAnt)
	While !Eof() .And. NNL->NNL_CODIGO == cCodAnt
		nC++
		aAdd(aCols, Array(Len(aHeader)+1))
		For nX := 1 to Len(aHeader)
			aCols[nC,nX] := FieldGet(FieldPos(aHeader[nX,2]))
		Next
		aCols[nC,Len(aHeader)+1] := .f.
		dbSkip()
	EndDo
EndIf

Define MSDialog oDlg Title STR0001 From aSize[7],0 to aSize[6],aSize[5] of oMainWnd Pixel

	oGetD := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcX,,,'+NNL_SEQ',.f.,,Len(aHeader),,,,,,,oDlg)
	oGetD:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

Activate MsDialog oDlg On Init EnchoiceBar(oDlg, {|| nOpcA:=1, If(AGRA040B(nOpcX), oDlg:End(), nOpcA:=0) } , {|| nOpcA:=0, oDlg:End() })

If nOpcA==1 .And. (nOpcX==3 .Or. nOpcX==4 .Or. nOpcX==5)
	Begin Transaction
	If nOpcX==4 .Or. nOpcX==5
		dbSelectArea('NNL')
		dbSetOrder(1)
		dbSeek(xFilial('NNL')+cCodAnt)
		While !Eof() .And. NNL->NNL_CODIGO == cCodAnt
			If RecLock('NNL',.f.)
				dbDelete()
				msUnLock()
			EndIf
			dbSkip()
		EndDo
	EndIf
	If nOpcX==4 .Or. nOpcX== 3
		For nX := 1 To Len(aCols)
			If .Not. aCols[nX,Len(aHeader)+1]
				If RecLock('NNL',.t.)
					For nY := 1 To Len(aHeader)
						&('NNL->'+aHeader[nY,2]) := aCols[nX,nY]
					Next nY
					NNL->NNL_FILIAL := xFilial('NNL')
					NNL->NNL_CODIGO := cCodAnt
					MsUnLock()
				EndIf
			EndIf
		Next nX
		If __lSX8 .And. nOpcX==3
			ConfirmSX8()
		EndIf
	EndIf
	End Transaction
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
ฑฑบPrograma  ณ AGRA040B บ Autor ณ Ricardo Tomasi     บ Data ณ  21/07/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina auxilial para validar a tela de cadastro.           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function AGRA040B(nOpcX)
Local lRetorno := .t.

If nOpcX==3 .Or. nOpcX==4
	lRetorno := Obrigatorio(aGets,aTela) .And. oGetD:TudoOK()
EndIf

Return(lRetorno)

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
				{ STR0002 ,'AxPesqui',0,1} ,; //"Pesquisar"
				{ STR0003 ,'AGRA040A',0,2} ,; //"Visualizar"
				{ STR0004 ,'AGRA040A',0,3} ,; //"Incluir"
				{ STR0005 ,'AGRA040A',0,4} ,; //"Alterar"
				{ STR0006 ,'AGRA040A',0,5}  ; //"Excluir"
				}

Return(aRotina)