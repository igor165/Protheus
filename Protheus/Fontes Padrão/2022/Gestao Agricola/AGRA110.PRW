#include 'protheus.ch'
#include 'AGRA110.CH'
#include "fwmvcdef.ch"
#INCLUDE "TOTVS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRA110  บAutor  ณRicardo Tomasi      บ Data ณ  01/08/2004 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Inclusใo de Despesas Agregadas.                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AGRA110(cTip, cSer, cDoc, cCoF, cLoj, nOpc)
Private cCadastro := STR0001 //Despesas Agregadas
Private cTipoDA   := IIf(ValType(cTip)=='U','I',cTip)
Private cSerOri   := IIf(ValType(cSer)=='U','' ,cSer)
Private cNumOri   := IIf(ValType(cDoc)=='U','' ,cDoc)
Private cCliFor   := IIf(ValType(cCoF)=='U','' ,cCoF)
Private cLojaCF   := IIf(ValType(cLoj)=='U','' ,cLoj)
Private nOpcRot   := IIf(ValType(nOpc)=='U', 2 ,nOpc)
Private aRotina   := MenuDef()

dbSelectArea('NOA')
dbSetOrder(1)

If cTipoDA == 'I'
	mBrowse(06, 01, 22, 75, 'NOA')
Else
	If !Empty(cSerOri) .And. !Empty(cNumOri) .And. !Empty(cCliFor) .And. !Empty(cLojaCF)
		If nOpcRot == 3
			AGRA110A('NOA',0,nOpcRot)
		ElseIf nOpcRot == 5
			AGRA110E()
		EndIf
	EndIf
EndIf

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRA110A บAutor  ณ WR Intelig๊ncia    บ Data ณ  01/08/2004 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina para Visualiza็ใo, Inclusใo e Exclusใo de Despesas  บฑฑ
ฑฑบ          ณ Agregadas.                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AGRA110A(cAlias, nReg, nOpcao)
Local aSize      := MsAdvSize()
Local aObjects   := {{100,100,.t.,.t.},{100,100,.t.,.t.},{100,015,.t.,.f.}}
Local aInfo      := {aSize[1],aSize[2],aSize[3],aSize[4],3,3}
Local aPosObj    := MsObjSize(aInfo,aObjects)
Local nOpcA      := 0
Local aCampos   := {}
Local aTitulo    := { STR0007} //Servi็os Gerais
Local aRefere    := {'Pasta1'}
Local nC         := 0
Local nX         := 0
Local aStruct	 :=	NOA->(dbStruct())
Local oStruNOA   := FWFormStruct(1, 'NOA')
Local lVirtual   := .F.

Private aGets    := Array(0)
Private aTela    := Array(0,0)
Private aHeader  := Array(0)
Private aCols    := Array(0)
Private n        := 1
Private oDlg
Private oGetD
Private oFolder

aAdd(aCampos, 'NOA_CODFOR')
aAdd(aCampos, 'NOA_LOJFOR')
aAdd(aCampos, 'NOA_NOMFOR')
aAdd(aCampos, 'NOA_DATEMI')
aAdd(aCampos, 'NOA_DATVEN')
aAdd(aCampos, 'NOA_NATURE')
aAdd(aCampos, 'NOA_MOEDA' )
aAdd(aCampos, 'NOA_CODBCO')
aAdd(aCampos, 'NOA_HISTOR')
aAdd(aCampos, 'NOA_CODPRO')
aAdd(aCampos, 'NOA_DESPRO')
aAdd(aCampos, 'NOA_UM'    )
aAdd(aCampos, 'NOA_LOCAL' )
aAdd(aCampos, 'NOA_QTDPRO')
aAdd(aCampos, 'NOA_VLRUNI')
aAdd(aCampos, 'NOA_VLRTOT')
aAdd(aCampos, 'NOA_CLVL'  )
aAdd(aCampos, 'NOA_CC'    )
aAdd(aCampos, 'NOA_ITEMCT')

//Substitui a montagem do aHeader com a utiliza็ใo direta da tabela SX3
For nX := 1 To Len(aStruct)
	If aScan(aCampos, aStruct[nX, 1]) > 0

		lVirtual := oStruNOA:GetProperty(aStruct[nX, 1], MODEL_FIELD_VIRTUAL)
		
		aAdd(aHeader,{RetTitle(aStruct[nX, 1]), aStruct[nX, 1], PesqPict("NOA",aStruct[nX, 1]), aStruct[nX, 3], aStruct[nX, 4], x3Valid(aStruct[nX, 1]), x3Usado(aStruct[nX, 1]), aStruct[nX, 2], "NOA", IIF(!lVirtual, "R", "V")})	

	EndIf
Next nX

If nOpcao == 3
	aAdd(aCols, Array(Len(aHeader)+1))
	For nX := 1 to Len(aHeader)
		aCols[1,nX] := CriaVar(aHeader[nX,2])
	Next nX
	aCols[1,Len(aHeader)+1] := .f.
Else
	If cTipoDA == 'I'
		dbSelectArea('NOA')
		dbSetOrder(1)
		dbGoto(nReg)
		aAdd(aCols, Array(Len(aHeader)+1))
		For nX := 1 to Len(aHeader)
			aCols[1,nX] := FieldGet(FieldPos(aHeader[nX,2]))
		Next
		aCols[1,Len(aHeader)+1] := .f.
	Else
		dbSelectArea('NOA')
		dbSetOrder(2)
		If dbSeek(xFilial('NOA')+cTipoDA+cSerOri+cNumOri+cCliFor+cLojaCF)
			nC := 0
			While !Eof() .And. NOA->NOA_TIPDOC == cTipoDA .And.;
							   NOA->NOA_SERDOC == cSerOri .And.;
							   NOA->NOA_NUMDOC == cNumOri .And.;
							   NOA->NOA_CLIFOR == cCliFor .And.;
							   NOA->NOA_LOJACF == cLojaCF
				nC++
				aAdd(aCols, Array(Len(aHeader)+1))
				For nX := 1 to Len(aHeader)
					aCols[nC,nX] := FieldGet(FieldPos(aHeader[nX,2]))
				Next
				aCols[nC,Len(aHeader)+1] := .f.
				dbSkip()
			EndDo
		EndIf
	EndIf
EndIf
//______________________________________________________________________________________________

Define MSDialog oDlg Title STR0001 From aSize[7],0 to aSize[6],aSize[5] of oMainWnd Pixel

	oFolder := TFolder():New(1,0,aTitulo,aRefere,oDlg,,,,.f.,.f.,aPosObj[2,4],aPosObj[2,3])

	oGetD := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcao,'AGRA110B()','AGRA110B()',,.t.,,Len(aHeader),,,'AGRA110C()',,,,oFolder:aDialogs[1])
	oGetD:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oGetD:oBrowse:Default()
	oGetD:oBrowse:Refresh()
	
Activate MsDialog oDlg On Init EnchoiceBar(oDlg, {|| nOpcA := 1, IIf(oGetD:TudoOK(), oDlg:End(), nOpcA := 0) } , {|| nOpcA := 0, oDlg:End() })

If nOpcA == 1
	If nOpcao == 3
		AGRA110D()
	ElseIf nOpcao == 5
		AGRA110E()
	Else
		ApMsgAlert('')
	EndIf
EndIf

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRA110B บAutor  ณRicardo Tomasi      บ Data ณ  01/08/2004 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida a Linha e o Tudo OK do GetDados.                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AGRA110B()
Local lRetorno := .t.

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRA110C บAutor  ณRicardo Tomasi      บ Data ณ  01/08/2004 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida os campos expecificos dos GetDados.                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AGRA110C(cTipo)
Local aArea       := GetArea()
Local lRetorno    := .t.
Local nP_LOJFOR := aScan(aHeader,{|x| Alltrim(Upper(x[2])) == 'NOA_LOJFOR' })
Local nP_NOMFOR := aScan(aHeader,{|x| Alltrim(Upper(x[2])) == 'NOA_NOMFOR' })
Local nP_DESPRO := aScan(aHeader,{|x| Alltrim(Upper(x[2])) == 'NOA_DESPRO' })
Local nP_UM     := aScan(aHeader,{|x| Alltrim(Upper(x[2])) == 'NOA_UM'     })
Local nP_LOCAL  := aScan(aHeader,{|x| Alltrim(Upper(x[2])) == 'NOA_LOCAL'  })
Local nP_QTDPRO := aScan(aHeader,{|x| Alltrim(Upper(x[2])) == 'NOA_QTDPRO' })
Local nP_VLRUNI := aScan(aHeader,{|x| Alltrim(Upper(x[2])) == 'NOA_VLRUNI' })
Local nP_VLRTOT := aScan(aHeader,{|x| Alltrim(Upper(x[2])) == 'NOA_VLRTOT' })

Do Case
	Case 'NOA_CODFOR' $ __READVAR
		dbSelectArea('SA2')
		dbSetOrder(1)
		dbSeek(xFilial('SA2')+M->NOA_CODFOR)
		aCols[n,nP_LOJFOR] := SA2->A2_LOJA
		aCols[n,nP_NOMFOR] := SA2->A2_NOME
	Case 'NOA_CODPRO' $ __READVAR
		dbSelectArea('SB1')
		dbSetOrder(1)
		dbSeek(xFilial('SB1')+M->NOA_CODPRO)
		aCols[n,nP_DESPRO] := SB1->B1_DESC
		aCols[n,nP_UM]     := SB1->B1_UM
		aCols[n,nP_LOCAL]  := SB1->B1_LOCPAD
	Case 'NOA_QTDPRO' $ __READVAR
		aCols[n,nP_VLRTOT] := (M->NOA_QTDPRO * aCols[n,nP_VLRUNI])
	Case 'NOA_VLRUNI' $ __READVAR
		aCols[n,nP_VLRTOT] := (aCols[n,nP_QTDPRO] * M->NOA_VLRUNI)
	Case 'NOA_VLRTOT' $ __READVAR
		If M->NOA_VLRTOT <> (aCols[n,nP_QTDPRO] * aCols[n,nP_VLRUNI])
			lRetorno := .f.
		EndIf
EndCase

RestArea(aArea)
Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRA110D บAutor  ณ WR Intelig๊ncia    บ Data ณ  01/08/2004 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Grava Despesas Agregadas.                                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AGRA110D()
Local nX := 0
Local cCodigo := ''
Local cPedido := ''

Local nP_CODFOR := aScan(aHeader,{|x| Alltrim(Upper(x[2])) == 'NOA_CODFOR' })
Local nP_LOJFOR := aScan(aHeader,{|x| Alltrim(Upper(x[2])) == 'NOA_LOJFOR' })
Local nP_NOMFOR := aScan(aHeader,{|x| Alltrim(Upper(x[2])) == 'NOA_NOMFOR' })
Local nP_DATEMI := aScan(aHeader,{|x| Alltrim(Upper(x[2])) == 'NOA_DATEMI' })
Local nP_DATVEN := aScan(aHeader,{|x| Alltrim(Upper(x[2])) == 'NOA_DATVEN' })
Local nP_NATURE := aScan(aHeader,{|x| Alltrim(Upper(x[2])) == 'NOA_NATURE' })
Local nP_CODBCO := aScan(aHeader,{|x| Alltrim(Upper(x[2])) == 'NOA_CODBCO' })
Local nP_HISTOR := aScan(aHeader,{|x| Alltrim(Upper(x[2])) == 'NOA_HISTOR' })
Local nP_MOEDA  := aScan(aHeader,{|x| Alltrim(Upper(x[2])) == 'NOA_MOEDA'  })
Local nP_CODPRO := aScan(aHeader,{|x| Alltrim(Upper(x[2])) == 'NOA_CODPRO' })
Local nP_DESPRO := aScan(aHeader,{|x| Alltrim(Upper(x[2])) == 'NOA_DESPRO' })
Local nP_UM     := aScan(aHeader,{|x| Alltrim(Upper(x[2])) == 'NOA_UM'     })
Local nP_LOCAL  := aScan(aHeader,{|x| Alltrim(Upper(x[2])) == 'NOA_LOCAL'  })
Local nP_QTDPRO := aScan(aHeader,{|x| Alltrim(Upper(x[2])) == 'NOA_QTDPRO' })
Local nP_VLRUNI := aScan(aHeader,{|x| Alltrim(Upper(x[2])) == 'NOA_VLRUNI' })
Local nP_VLRTOT := aScan(aHeader,{|x| Alltrim(Upper(x[2])) == 'NOA_VLRTOT' })
Local nP_CC     := aScan(aHeader,{|x| Alltrim(Upper(x[2])) == 'NOA_CC'     })
Local nP_ITEMCT := aScan(aHeader,{|x| Alltrim(Upper(x[2])) == 'NOA_ITEMCT' })
Local nP_CLVL   := aScan(aHeader,{|x| Alltrim(Upper(x[2])) == 'NOA_CLVL'   })

Begin Transaction

For nX := 1 to Len(aCols)

	If !aCols[nX,Len(aHeader)+1]
	
		cCodigo := GetSXENum('NOA','NOA_CODIGO')
		cPedido := GetSXENum('SC7','C7_NUM')
	
		If Reclock('NOA',.t.)
			NOA->NOA_FILIAL := xFilial('NOA')
			NOA->NOA_CODIGO := cCodigo
			NOA->NOA_PREFIX := 'PC'
			NOA->NOA_NUMERO := cPedido
			NOA->NOA_PARCEL := '1'
			NOA->NOA_CODFOR := aCols[nX,nP_CODFOR]
			NOA->NOA_LOJFOR := aCols[nX,nP_LOJFOR]
			NOA->NOA_NOMFOR := aCols[nX,nP_NOMFOR]
			NOA->NOA_DATEMI := aCols[nX,nP_DATEMI]
			NOA->NOA_DATVEN := aCols[nX,nP_DATVEN]
			NOA->NOA_NATURE := aCols[nX,nP_NATURE]
			NOA->NOA_CODBCO := aCols[nX,nP_CODBCO]
			NOA->NOA_HISTOR := aCols[nX,nP_HISTOR]
			NOA->NOA_MOEDA  := aCols[nX,nP_MOEDA]
			NOA->NOA_PEDIDO := cPedido
			NOA->NOA_ITEMPC := '001'
			NOA->NOA_CODPRO := aCols[nX,nP_CODPRO]
			NOA->NOA_DESPRO := aCols[nX,nP_DESPRO]
			NOA->NOA_UM     := aCols[nX,nP_UM]
			NOA->NOA_LOCAL  := aCols[nX,nP_LOCAL]
			NOA->NOA_QTDPRO := aCols[nX,nP_QTDPRO]
			NOA->NOA_VLRUNI := aCols[nX,nP_VLRUNI]
			NOA->NOA_VLRTOT := aCols[nX,nP_VLRTOT]
			NOA->NOA_CC     := aCols[nX,nP_CC]
			NOA->NOA_ITEMCT := aCols[nX,nP_ITEMCT]
			NOA->NOA_CLVL   := aCols[nX,nP_CLVL]
			NOA->NOA_TIPDOC := cTipoDA
			NOA->NOA_SERDOC := cSerOri
			NOA->NOA_NUMDOC := cNumOri
			NOA->NOA_CLIFOR := cCliFor
			NOA->NOA_LOJACF := cLojaCF
			MsUnLock()
		EndIf
		
		If RecLock('SE2',.t.)
			SE2->E2_FILIAl  := xFilial('SE2')
			SE2->E2_PREFIXO := 'PC'
			SE2->E2_NUM     := cPedido
			SE2->E2_PARCELA := '1'
			SE2->E2_TIPO    := 'PR'
			SE2->E2_NATUREZ := aCols[nX,nP_NATURE]
			SE2->E2_FORNECE := aCols[nX,nP_CODFOR]
			SE2->E2_LOJA    := aCols[nX,nP_LOJFOR]
			SE2->E2_NOMFOR  := aCols[nX,nP_NOMFOR]
			SE2->E2_EMISSAO := aCols[nX,nP_DATEMI]
			SE2->E2_VENCTO  := aCols[nX,nP_DATVEN]
			SE2->E2_VENCREA := aCols[nX,nP_DATVEN]
			SE2->E2_MOEDA   := aCols[nX,nP_MOEDA]
			SE2->E2_VALOR   := aCols[nX,nP_VLRTOT]
			SE2->E2_VLCRUZ  := xMoeda(aCols[nX,nP_VLRTOT],aCols[nX,nP_MOEDA],1,aCols[nX,nP_DATEMI],9) //Converte valor para moeda 1 na data de emissใo.
			SE2->E2_SALDO   := aCols[nX,nP_VLRTOT]
			SE2->E2_PORTADO := aCols[nX,nP_CODBCO]
			SE2->E2_HIST    := aCols[nX,nP_HISTOR]
			SE2->E2_CLVLCR  := aCols[nX,nP_CLVL]
			SE2->E2_CCC     := aCols[nX,nP_CC]
			SE2->E2_ITEMC   := aCols[nX,nP_ITEMCT]
			MsUnLock()
		EndIf
		
		If RecLock("SC7",.t.)
			SC7->C7_FILIAL  := xFilial("SC7")
			SC7->C7_TIPO    := 1 //PEDIDO DE COMPRAS
			SC7->C7_ITEM    := '001'
			SC7->C7_PRODUTO := aCols[nX,nP_CODPRO]
			SC7->C7_UM      := aCols[nX,nP_UM]
			SC7->C7_QUANT   := aCols[nX,nP_QTDPRO]
			SC7->C7_PRECO   := aCols[nX,nP_VLRUNI]
			SC7->C7_TOTAL   := aCols[nX,nP_VLRTOT]
			SC7->C7_DATPRF  := aCols[nX,nP_DATEMI]
			SC7->C7_LOCAL   := aCols[nX,nP_LOCAL]
			SC7->C7_FORNECE := aCols[nX,nP_CODFOR]
			SC7->C7_COND    := '001'
			SC7->C7_LOJA    := aCols[nX,nP_LOJFOR]
			SC7->C7_EMISSAO := aCols[nX,nP_DATEMI]
			SC7->C7_NUM     := cPedido
			SC7->C7_FILENT  := xFilial("SC7")
			SC7->C7_DESCRI  := aCols[nX,nP_DESPRO]
			SC7->C7_TPFRETE := 'C'
			SC7->C7_FLUXO   := 'N'
			SC7->C7_CONAPRO := 'L'
			SC7->C7_USER    := '000000'
			SC7->C7_MOEDA   := aCols[nX,nP_MOEDA]
			SC7->C7_TXMOEDA := aCols[nX,nP_MOEDA]
			SC7->C7_PENDEN  := 'N'
//			SC7->C7_DATINIC := aCols[nX,nP_DATEMI]
//			SC7->C7_CLVL    := aCols[nX,nP_CLVL]
//			SC7->C7_CC	    := aCols[nX,nP_CC]
//			SC7->C7_ITEMCTA := aCols[nX,nP_ITEMCT]
			MsUnLock()
		EndIf
		
		ConfirmSX8()

	EndIf

Next nX

End Transaction

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRA110E บAutor  ณ WR Intelig๊ncia    บ Data ณ  01/08/2004 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Exclui Despesas Agregadas.                                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AGRA110E()
Local lExcSE2 := .f.
Local lExcSC7 := .f.
Local lExcNOA := .f.

	If cTipoDA == 'P'
		dbSelectArea('NOA')
		dbSetOrder(3) //NOA_FILIAL+NOA_PEDIDO+NOA_ITEMPC
		If dbSeek(xFilial('NOA')+cSerOri+cNumOri)
			If AllTrim(NOA->NOA_TIPDOC) $ 'ES'
				Begin Transaction
				//Excluir Contas a Pagar
				dbSelectArea('SE2')
				dbSetOrder(6) //E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
				If dbSeek(xFilial('SE2')+NOA->NOA_CODFOR+NOA->NOA_LOJFOR+NOA->NOA_PREFIX+NOA->NOA_NUMERO+NOA->NOA_PARCEL+'PR')
					If RecLock('SE2',.f.)
						dbDelete()
						MsUnLock()
						lExcSE2 := .t.
					EndIf
			    EndIf
			    //Excluir Despesas Agragadas
			    dbSelectArea('NOA')
		    	If RecLock('NOA',.f.)
		    		dbDelete()
		    		MsUnLock()
		    		lExcNOA := .t.
		    	EndIf
		    	If !lExcSE2 .Or. !lExcNOA
		    		DisarmTransaction()
		    	EndIf
		    	End Transaction
			EndIf
		EndIf
	EndIf

	If cTipoDA == 'I' .And. AllTrim(NOA->NOA_TIPDOC) == 'I'
		Begin Transaction
	    //Excluir Pedido de Compras
	    dbSelectArea('SC7')
	    dbSetOrder(1) //C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN
	    If dbSeek(xFilial('SC7')+NOA->NOA_PEDIDO+NOA->NOA_ITEMPC)
	    	If SC7->C7_QUJE == 0 .And. SC7->C7_ENCER <> 'E'
		    	If RecLock('SC7',.f.)
		    		dbDelete()
		    		MsUnLock()
		    		lExcSC7 := .t.
		    	EndIf
		    EndIf
	    EndIf
		//Excluir Contas a Pagar
		dbSelectArea('SE2')
		dbSetOrder(6) //E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
		If dbSeek(xFilial('SE2')+NOA->NOA_CODFOR+NOA->NOA_LOJFOR+NOA->NOA_PREFIX+NOA->NOA_NUMERO+NOA->NOA_PARCEL+'PR')
			If RecLock('SE2',.f.)
				dbDelete()
				MsUnLock()
				lExcSE2 := .t.
			EndIf
	    EndIf
	    //Excluir Despesas Agragadas
	    dbSelectArea('NOA')
    	If RecLock('NOA',.f.)
    		dbDelete()
    		MsUnLock()
    		lExcNOA := .t.
    	EndIf
    	
    	If !lExcSE2 .Or. !lExcSC7 .Or. !lExcNOA
			DisarmTransaction()
    	EndIf
    	End Transaction
	EndIf
	
	//--------------------------------------------------------------- Exclusใo de Documento NFE ou NFS
	If cTipoDA $ 'ES'
		dbSelectArea('NOA')
		dbSetOrder(2) //NOA_FILIAL+NOA_TIPDOC+NOA_SERDOC+NOA_NUMDOC+NOA_CLIFOR+NOA_LOJACF
		If dbSeek(xFilial('NOA')+cTipoDA+cSerOri+cNumOri+cCliFor+cLojaCF)
			While !Eof() .And. NOA_FILIAL+NOA_TIPDOC+NOA_SERDOC+NOA_NUMDOC+NOA_CLIFOR+NOA_LOJACF == xFilial('NOA')+cTipoDA+cSerOri+cNumOri+cCliFor+cLojaCF
				If AllTrim(NOA->NOA_TIPDOC) $ 'ES'
					Begin Transaction
				    //Excluir Pedido de Compras
				    dbSelectArea('SC7')
				    dbSetOrder(1) //C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN
				    If dbSeek(xFilial('SC7')+NOA->NOA_PEDIDO+NOA->NOA_ITEMPC)
		    	    	If SC7->C7_QUJE == 0 .And. SC7->C7_ENCER <> 'E'
					    	If RecLock('SC7',.f.)
					    		dbDelete()
					    		MsUnLock()
					    		lExcSC7 := .t.
					    	EndIf
				    	EndIf
				    EndIf
					//Excluir Contas a Pagar
					dbSelectArea('SE2')
					dbSetOrder(6) //E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
					If dbSeek(xFilial('SE2')+NOA->NOA_CODFOR+NOA->NOA_LOJFOR+NOA->NOA_PREFIX+NOA->NOA_NUMERO+NOA->NOA_PARCEL+'PR')
						If RecLock('SE2',.f.)
							dbDelete()
							MsUnLock()
							lExcSE2 := .t.
						EndIf
				    EndIf
				    //Excluir Despesas Agragadas
				    dbSelectArea('NOA')
			    	If RecLock('NOA',.f.)
			    		dbDelete()
			    		MsUnLock()
			    		lExcNOA := .t.
			    	EndIf
			    	If !lExcSE2 .Or. !lExcSC7 .Or. !lExcNOA
			    		DisarmTransaction()
			    	EndIf
			    	End Transaction
				EndIf
				dbSelectArea('NOA')
				dbSkip()
			EndDo
		EndIf
	EndIf

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRA110F บAutor  ณ WR Intelig๊ncia    บ Data ณ  01/08/2004 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Altera็ใo do Pedido de Compras ligado a um Titulo a Pagar  บฑฑ
ฑฑบ          ณ provisorio, o qual deve ter o valor alterado de acordo com บฑฑ
ฑฑบ          ณ o valor total dos itens do Pedido de Compras.              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AGRA110F(cPedido,cItem)
Local nP_PRODUTO := aScan(aHeader,{|x| Alltrim(Upper(x[2])) == 'C7_PRODUTO'})
Local nP_DESCRI  := aScan(aHeader,{|x| Alltrim(Upper(x[2])) == 'C7_DESCRI' })
Local nP_UM      := aScan(aHeader,{|x| Alltrim(Upper(x[2])) == 'C7_UM'     })
Local nP_LOCAL   := aScan(aHeader,{|x| Alltrim(Upper(x[2])) == 'C7_LOCAL'  })
Local nP_QUANT   := aScan(aHeader,{|x| Alltrim(Upper(x[2])) == 'C7_QUANT'  })
Local nP_PRECO   := aScan(aHeader,{|x| Alltrim(Upper(x[2])) == 'C7_PRECO'  })
Local nP_TOTAL   := aScan(aHeader,{|x| Alltrim(Upper(x[2])) == 'C7_TOTAL'  })
Local nP_CC      := aScan(aHeader,{|x| Alltrim(Upper(x[2])) == 'C7_CC'     })
Local nP_ITEMCTA := aScan(aHeader,{|x| Alltrim(Upper(x[2])) == 'C7_ITEMCTA'})
Local nP_CLVL    := aScan(aHeader,{|x| Alltrim(Upper(x[2])) == 'C7_CLVL'   })

dbSelectArea('SC7')
dbSetOrder(1) //C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN
If dbSeek(xFilial('SC7')+cPedido+cItem)
	dbSelectArea('NOA')
	dbSetOrder(3)//NOA_FILIAL+NOA_PEDIDO+NOA_ITEMPC
	If dbSeek(xFilial('NOA')+cPedido+cItem)
		Begin Transaction
		If Reclock('NOA',.f.)
			NOA->NOA_CODPRO := aCols[1,nP_PRODUTO]
			NOA->NOA_DESPRO := aCols[1,nP_DESCRI]
			NOA->NOA_UM     := aCols[1,nP_UM]
			NOA->NOA_LOCAL  := aCols[1,nP_LOCAL]
			NOA->NOA_QTDPRO := aCols[1,nP_QUANT]
			NOA->NOA_VLRUNI := aCols[1,nP_PRECO]
			NOA->NOA_VLRTOT := aCols[1,nP_TOTAL]
			NOA->NOA_CC     := aCols[1,nP_CC]
			NOA->NOA_ITEMCT := aCols[1,nP_ITEMCTA]
			NOA->NOA_CLVL   := aCols[1,nP_CLVL]
			MsUnLock()
		EndIf
		dbSelectArea('SE2')
		dbSetOrder(6) //E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
		If dbSeek(xFilial('SE2')+NOA->NOA_CODFOR+NOA->NOA_LOJFOR+NOA->NOA_PREFIX+NOA->NOA_NUMERO+NOA->NOA_PARCEL+'PR')
			If RecLock('SE2',.f.)
				SE2->E2_VALOR   := aCols[1,nP_TOTAL]
				SE2->E2_VLCRUZ  := xMoeda(aCols[1,nP_TOTAL],SE2->E2_MOEDA,1,SE2->E2_EMISSAO,9)
				SE2->E2_SALDO   := aCols[1,nP_TOTAL]
				MsUnLock()
			EndIf
	    EndIf
		End Transaction
	EndIf
EndIf

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRA110G บAutor  ณ WR Intelig๊ncia    บ Data ณ  01/08/2004 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Exclui Despesas Agregadas.                                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AGRA110G(cPedido, cItem)
Local lExcSE2 := .f.
Local lExcNOA := .f.

dbSelectArea('NOA')
dbSetOrder(3) //NOA_FILIAL+NOA_PEDIDO+NOA_ITEMPC
If dbSeek(xFilial('NOA')+cPedido+cItem)
	If AllTrim(NOA->NOA_TIPDOC) $ 'ES'
		Begin Transaction
		//Excluir Contas a Pagar
		dbSelectArea('SE2')
		dbSetOrder(6) //E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
		If dbSeek(xFilial('SE2')+NOA->NOA_CODFOR+NOA->NOA_LOJFOR+NOA->NOA_PREFIX+NOA->NOA_NUMERO+NOA->NOA_PARCEL+'PR')
			If RecLock('SE2',.f.)
				dbDelete()
				MsUnLock()
				lExcSE2 := .t.
			EndIf
	    EndIf
	    //Excluir Despesas Agragadas
	    dbSelectArea('NOA')
    	If RecLock('NOA',.f.)
    		dbDelete()
    		MsUnLock()
    		lExcNOA := .t.
    	EndIf
    	If !lExcSE2 .Or. !lExcNOA
    		DisarmTransaction()
    	EndIf
    	End Transaction
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

Local aRotina:= {}

aAdd( aRotina, { STR0002 ,"AxPesqui" ,0,1}) //Pesquisar
aAdd( aRotina, { STR0003 ,"AxVisual" ,0,2}) //Visualizar
aAdd( aRotina, { STR0004 ,"AGRA110A" ,0,3}) //Incluir
aAdd( aRotina, { STR0005 ,""         ,0,4}) //Alterar
aAdd( aRotina, { STR0006 ,"AGRA110A" ,0,5}) //Excluir

Return(aRotina)