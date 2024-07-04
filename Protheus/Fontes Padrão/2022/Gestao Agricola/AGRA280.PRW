#include 'protheus.ch'
#INCLUDE 'AGRA280.CH'


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRA280  บ Autor ณ Ricardo Tomasi     บ Data ณ  25/05/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina de Romaneio de Entrada.                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function AGRA280()

Private aCores    := {;
					 {'NPO->NPO_TIPO=="P".And.!Empty(NPO->NPO_CODAPO)' ,'BR_VERDE'   },;
                     {'NPO->NPO_TIPO=="P".And. Empty(NPO->NPO_CODAPO)' ,'BR_AZUL'    },;
                     {'NPO->NPO_TIPO=="T".And. Empty(NPO->NPO_CODAPO)' ,'BR_AMARELO' } ;
                     }
Private cCadastro := STR0001 //"Romaneio de Entrada"
Private aRotina   := MenuDef()

dbSelectArea('NPO')
dbSetOrder(1)

mBrowse( 6, 1, 22, 75, 'NPO', Nil, Nil, Nil, Nil, Nil, aCores)

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRA280A บ Autor ณ Ricardo Tomasi     บ Data ณ  25/05/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Romaneio de Entrega.                                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function AGRA280A(cAlias, nReg, nOpc)
Local aSize    := MsAdvSize()
Local aObjects := {{100,100,.t.,.t.},{100,100,.t.,.t.},{100,015,.t.,.f.}}
Local aInfo    := {aSize[1],aSize[2],aSize[3],aSize[4],3,3}
Local aPosObj  := MsObjSize(aInfo,aObjects)
Local nOpcX    := aRotina[nOpc,4]
Local nOpcA    := 0
Local nX       := 0
Local nC       := 0
Local aCampos  := {}

Private aGets   := Array(0)
Private aTela   := Array(0,0)
Private aHeader := Array(0)
Private aCols   := Array(0)
Private oDlg
Private oEnch
Private oGetD
Private oSay1
Private oSay2
Private oSay3
Private oSay4
Private oFnt1
Private nMaxLin  := 0

aAdd(aCampos, 'NPP_ITEM'  )
aAdd(aCampos, 'NPP_CODDES')
aAdd(aCampos, 'NPP_DESDES')
aAdd(aCampos, 'NPP_PERDES')
aAdd(aCampos, 'NPP_PESDES')

For nX := 1 To Len(aCampos)
	If X3USADO(aCampos[nX]) .And. cNivel >= AGRRETNIV(aCampos[nX])
		aAdd(aHeader,{AllTrim(RetTitle(aCampos[nX])), aCampos[nX], X3PICTURE(aCampos[nX]), TamSx3(aCampos[nX])[1], TamSx3(aCampos[nX])[2], X3VALID(aCampos[nX]), X3USADO(aCampos[nX]), TamSx3(aCampos[nX])[3], "NPP", AGRRETCTXT("NPP", aCampos[nX]) })
	Endif
Next nX

If nOpc <> 3
	dbSelectArea('NPP')
	dbSetOrder(1)
	dbSeek(xFilial('NPP')+NPO->NPO_CODIGO)
	While !Eof() .And. xFilial('NPP')+NPP->NPP_CODIGO == xFilial('NPO')+NPO->NPO_CODIGO
		nC++
		aAdd(aCols, Array(Len(aHeader)+1))
		For nX := 1 to Len(aHeader)
			aCols[nC,nX] := FieldGet(FieldPos(aHeader[nX,2]))
		Next
		aCols[nC,Len(aHeader)+1] := .f.
		dbSkip()
	EndDo
EndIf

If nOpc == 5
	dbSelectArea('NN1')
	dbSetOrder(1)
	dbSeek(xFilial('NN1')+NPO->NPO_SAFRA)
	If NN1->NN1_FECHAD = 'S'
		Alert('Safra fechada para este tipo de movimenta็ใo!')
		Return()
	EndIf
EndIf
	

RegToMemory(cAlias,(nOpc == 3))

Define MSDialog oDlg Title cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd Pixel

	oFnt1 := TFont():New( 'Courier New',11)
	oEnch := MsMGet():New(cAlias,nReg,nOpc,,,,,aPosObj[1],,3,,,,oDlg,,.t.)
	oGetD := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpc,,,,.f.,,Len(aHeader),,nMaxLin,'AGRA280E()',,,,oDlg)
	oSay1 := TSay():New(aPosObj[3,1]   ,aPosObj[3,2]    , {|| 'Produtor: '  +Posicione('SA1',1,xFilial('SA1')+M->NPO_CODCLI+M->NPO_LOJCLI,'A1_NOME') },oDlg,,oFnt1,,,,.t.,CLR_BLUE,,200,21)
	oSay2 := TSay():New(aPosObj[3,1]+15,aPosObj[3,2]    , {|| 'Endere็o: '  +Posicione('SA1',1,xFilial('SA1')+M->NPO_CODCLI+M->NPO_LOJCLI,'A1_END' ) },oDlg,,oFnt1,,,,.t.,CLR_BLUE,,200,21)
	oSay3 := TSay():New(aPosObj[3,1]   ,aPosObj[3,2]+210, {|| 'Armazem: '   +Posicione('NNR',1,xFilial('NNR')+M->NPO_ARM,'NNR_DESCRI'              ) },oDlg,,oFnt1,,,,.t.,CLR_BLUE,,200,21)
	oSay4 := TSay():New(aPosObj[3,1]+15,aPosObj[3,2]+210, {|| 'Quantidade: '+Transform(M->NPO_PSREAL, '@E 99,999,999,999'                          ) },oDlg,,oFnt1,,,,.t.,CLR_RED ,,200,21)

Activate MsDialog oDlg On Init EnchoiceBar(oDlg, {|| nOpcA := 1, IIf(AGRA280B(nOpcX), oDlg:End(), nOpcA := 0) } , {|| nOpcA := 0, oDlg:End() })

If nOpcA == 1
	If nOpcX==3
		fInclui()
		If __lSX8
			ConfirmSX8()
		EndIf
	EndIf
	If nOpcX==5
		fExclui()
	EndIf
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
ฑฑบPrograma  ณ AGRA280B บ Autor ณ Ricardo Tomasi     บ Data ณ  25/05/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Valida็ใo do Enchoice.                                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function AGRA280B(nOpcX)
Local lRetorno := .t.

If nOpcX == 3 .Or. nOpcX == 4
	lRetorno := Obrigatorio(aGets,aTela) .And. oGetD:TudoOK()
EndIf

Return(lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRA280C บ Autor ณ Ricardo Tomasi     บ Data ณ  25/05/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Atualiza GetDados para contemplar a tabela de classifica็ใoบฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function AGRA280C()
Local aAreaAt := GetArea()
Local nX := 0
Local nC := 0
Local nP_ITEM   := aScan(aHeader, { |x| Alltrim(x[2]) == 'NPP_ITEM'  })
Local nP_CODDES := aScan(aHeader, { |x| Alltrim(x[2]) == 'NPP_CODDES'})
Local nP_DESDES := aScan(aHeader, { |x| Alltrim(x[2]) == 'NPP_DESDES'})

aCols := Array(0)

dbSelectArea('NNI')
dbSetOrder(1)
dbSeek(xFilial('NNI')+M->NPO_CODTAB)

If M->NPO_DATA < NNI->NNI_DATINI .Or. M->NPO_DATA > NNI->NNI_DATFIM
	ApMsgAlert(STR0006,STR0007) //"Esta tabela esta fora da data de vig๊ncia!!!"###"Data de Vig๊ncia"
	Return(.f.)
EndIf

dbSelectArea('NNJ')
dbSetOrder(2)
If dbSeek(xFilial('NNJ')+NNI->NNI_CODIGO)

	While !Eof() .And. NNI->NNI_CODIGO == NNJ->NNJ_CODTAB

		nC++
		aAdd(aCols, Array(Len(aHeader)+1))
		For nX := 1 to Len(aHeader)
			aCols[nC,nX] := CriaVar(aHeader[nX,2])
		Next
		aCols[nC,nP_ITEM]   := NNJ->NNJ_SEQ
		aCols[nC,nP_CODDES] := NNJ->NNJ_CODDES
		aCols[nC,nP_DESDES] := NNJ->NNJ_DESDES
		aCols[nC,Len(aHeader)+1] := .f.

		dbSkip()
	EndDo

	nMaxLin := nC

EndIf

oGetD:oBrowse:Refresh()
RestArea(aAreaAt)
Return(.t.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRA280D บ Autor ณ Ricardo Tomasi     บ Data ณ  25/05/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Valida็ใo Utilizada no Peso Bruto e no Peso Tara do Equip. บฑฑ
ฑฑบ          ณ Calcula o Peso Liquido Recalcula Descontos e Pesos.        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function AGRA280D()
Local aAreaAt := GetArea()

Do Case
	Case 'NPO_PSBRUT' $ __READVAR
		If M->NPO_PSTARA > M->NPO_PSBRUT
			ApMsgAlert(STR0008,STR0009) //"Peso Bruto nใo pode ser menor que o Peso Tara!"###"Peso Invalido"
			Return(.f.)
		EndIf
		M->NPO_PSSUBT := M->NPO_PSBRUT - M->NPO_PSTARA
	Case 'NPO_PSTARA' $ __READVAR
		If M->NPO_PSTARA > M->NPO_PSBRUT
			ApMsgAlert(STR0010,STR0009) //"Peso Tara nใo pode ser maior que o Peso Bruto!"###"Peso Invalido"
			Return(.f.)
		EndIf
		M->NPO_PSSUBT := M->NPO_PSBRUT - M->NPO_PSTARA
EndCase

oEnch:Refresh()
oGetD:oBrowse:Refresh()
RestArea(aAreaAt)
Return(.t.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRA280E บ Autor ณ Ricardo Tomasi     บ Data ณ  25/05/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Atualiza o campo peso do desconto aplicando a tabela de    บฑฑ
ฑฑบ          ณ classifica็ใo apontada e os percentuais inseridos.         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function AGRA280E()
Local aAreaAt   := GetArea()
Local nX        := 0
Local nPerDes   := 0
Local nPesLiq   := 0
Local nTotDes   := 0
Local nTotExt   := 0
Local nTotCmp   := 0
Local nP_CODDES := aScan(aHeader, { |x| Alltrim(x[2]) == 'NPP_CODDES'})
Local nP_PERDES := aScan(aHeader, { |x| Alltrim(x[2]) == 'NPP_PERDES'})
Local nP_PESDES := aScan(aHeader, { |x| Alltrim(x[2]) == 'NPP_PESDES'})

For nX := 1 to Len(aCols)

	nPerDes := aCols[nX,nP_PERDES]

	If 'NPP_PERDES' $ __READVAR .And. n == nX 
		nPerDes := M->NPP_PERDES
	EndIf

	If nPerDes < 0 .Or. nPerDes > 100
		ApMsgAlert(STR0011,STR0012) //"O Percentual de Desconto deve estar entre 0(Zero) e 100(Cem) porcento."###"Percentual Invalido"
		Return(.f.)
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPosiciona Cabecalho da Tabela de Descontosณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	dbSelectArea('NNI')
	dbSetOrder(1)
	dbSeek(xFilial('NNI')+M->NPO_CODTAB)
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPosiciona Itens da Tabela de Descontosณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	dbSelectArea('NNJ')
	dbSetOrder(1)
	dbSeek(xFilial('NNJ')+NNI->NNI_CODIGO+aCols[nX,nP_CODDES])
	If NNJ->NNJ_INCIDE == 'A'
		nPesLiq := M->NPO_PSSUBT
	Else
		nPesLiq := M->NPO_PSLIQU
	EndIf	

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPosiciona Sub-Itens da Tabela de Descontosณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	dbSelectArea('NNK')
	dbSetOrder(1)
	dbSeek(xFilial('NNK')+M->NPO_CODTAB+aCols[nX,nP_CODDES])
	While !Eof() .And. NNK->NNK_CODTAB == M->NPO_CODTAB .And. NNK->NNK_CODDES == aCols[nX,nP_CODDES]
		If NNK->NNK_PERPRO == 'S'
			If nPerDes > NNK->NNK_PERFIM
				aCols[nX,nP_PESDES] := Round((nPesLiq * ((nPerDes)-(NNK->NNK_PERFIM))) / 100,0)
			Else
				aCols[nX,nP_PESDES] := 0
			EndIf
		Else
			If nPerDes >= NNK->NNK_PERINI .And. nPerDes <= NNK->NNK_PERFIM
				aCols[nX,nP_PESDES] := Round((nPesLiq * NNK->NNK_PERDES) / 100,0)
			EndIf
		EndIf
		If nPerDes == 0
			aCols[nX,nP_PESDES] := 0
		EndIf
		dbSkip()
	EndDo

	If NNJ->NNJ_EXTDES == 'S'
		nTotExt := nTotExt + aCols[nX,nP_PESDES]
	Else
		nTotDes := nTotDes + aCols[nX,nP_PESDES]
	EndIf

	If NNJ->NNJ_INCCMP == 'S'
		nTotCmp += aCols[nX,nP_PESDES]
	EndIf

	M->NPO_PSDESC := nTotDes
	M->NPO_PSLIQU := M->NPO_PSSUBT - nTotDes
	M->NPO_PSEXTR := nTotExt
	M->NPO_PSREAL := M->NPO_PSLIQU - nTotExt
	M->NPO_PSCMPL := (M->NPO_PSSUBT-nTotCmp)-M->NPO_PSESTI

Next nX

M->NPO_PSDESC := nTotDes
M->NPO_PSLIQU := M->NPO_PSSUBT - nTotDes
M->NPO_PSEXTR := nTotExt
M->NPO_PSREAL := M->NPO_PSLIQU - nTotExt
M->NPO_PSCMPL := (M->NPO_PSSUBT-nTotCmp)-M->NPO_PSESTI

oSay4:Refresh()
oEnch:Refresh()
oGetD:oBrowse:Refresh()
RestArea(aAreaAt)
Return(.t.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRA280F บ Autor ณ Ricardo Tomasi     บ Data ณ  25/05/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Valida็ใo do numero do Apontamento de Produ็ใo.            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function AGRA280F()
Local aAreaAt   := GetArea()
Local lRetorno  := .t.

If !Empty(M->NPO_CODAPO)
	dbSelectArea('NPA')
	dbSetOrder(1)
	If dbSeek(xFilial('NPA')+M->NPO_CODAPO)
		If NPA->NPA_QTDREA == 0
			M->NPO_SAFRA  := NPA->NPA_SAFRA
			M->NPO_FAZ    := NPA->NPA_FAZ
			M->NPO_TALHAO := NPA->NPA_TALHAO
			M->NPO_ARM    := NPA->NPA_LOCAL
			M->NPO_CODCLI := IIf(Empty(NPA->NPA_CODCLI), Substr(GetMV('MV_AGRXCLI'),1,6), NPA->NPA_CODCLI)
			M->NPO_LOJCLI := IIf(Empty(NPA->NPA_LOJCLI), Substr(GetMV('MV_AGRXCLI'),7,2), NPA->NPA_LOJCLI)
			M->NPO_CODTRA := NPA->NPA_CODTRA
			M->NPO_CODEQU := NPA->NPA_CODEQU
			M->NPO_CODMOT := NPA->NPA_CODMOT
			M->NPO_CODPRO := NPA->NPA_CODPRO
			M->NPO_UM     := NPA->NPA_UM
			M->NPO_PSESTI := NPA->NPA_QTDEST
			oEnch:oBox:Refresh()
		Else
			lRetorno := .f.
		EndIf
	Else
		lRetorno := .f.
	EndIf
EndIf

RestArea(aAreaAt)
Return(lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ fInclui  บ Autor ณ Ricardo Tomasi     บ Data ณ  25/05/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina auxiliar para inclusใo de romaneio de entrada.      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function fInclui(nOpc)
Local nX := 0
Local nY := 0
Local cNovoCod := ''
Local aDescExt := Array(0)
Local cMVAGRXCLI  := GetMV('MV_AGRXCLI',,'000001')

Private lMsHelpAuto := .t.
Private lMsErroAuto := .f.

Begin Transaction

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณGrava cabecalho e itens do romaneio de entrada.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	dbSelectArea('NPO')
	dbSetOrder(1)
	dbSeek(xFilial('NPO')+M->NPO_CODIGO)
	If RecLock('NPO',.t.)
		For nY := 1 To FCount()
			&('NPO->'+FieldName(nY)) := &('M->'+FieldName(nY))
		Next nY
		NPO->NPO_FILIAL := xFilial('NPO')
		msUnLock()
	EndIf
	For nX := 1 To Len(aCols)
		dbSelectArea('NPP')
		dbSetOrder(1)
		If RecLock('NPP',.t.)
			NPP->NPP_FILIAL := xFilial('NPP')
			NPP->NPP_CODIGO  := NPO->NPO_CODIGO
			For nY := 1 To Len(aHeader)
				&('NPP->'+aHeader[nY,2]) := aCols[nX,nY]
			Next nY
			msUnLock()
		EndIf
		dbSelectArea('NNJ')
		dbSetOrder(1)
		dbSeek(xFilial('NNJ')+NPO->NPO_CODTAB+NPP->NPP_CODDES)
		If NNJ->NNJ_EXTDES == 'S'
			aAdd(aDescExt, {NNJ->NNJ_CODDES, NNJ->NNJ_DESDES, NPP->NPP_PESDES} )
		EndIf
	Next nX

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณGrava dados na tabela de estoque por clientexarmazemxsafraณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	dbSelectArea('NPL')
	dbSetOrder(1)
	If dbSeek(xFilial('NPL')+NPO->NPO_CODCLI+NPO->NPO_LOJCLI+NPO->NPO_SAFRA+NPO->NPO_ARM)
		If RecLock('NPL',.f.)
			NPL->NPL_ENBRUT := NPL->NPL_ENBRUT + NPO->NPO_PSSUBT
			NPL->NPL_ENDESC := NPL->NPL_ENDESC + NPO->NPO_PSDESC
			NPL->NPL_ENEXTR := NPL->NPL_ENEXTR + NPO->NPO_PSEXTR
			NPL->NPL_ENLIQU := NPL->NPL_ENLIQU + NPO->NPO_PSREAL
			NPL->NPL_SALDO  := NPL->NPL_SALDO  + NPO->NPO_PSREAL
			msUnLock()
		EndIf
	Else
		If RecLock('NPL',.t.)
			NPL->NPL_FILIAL := xFilial('NPL')
			NPL->NPL_CODCLI := NPO->NPO_CODCLI
			NPL->NPL_LOJCLI := NPO->NPO_LOJCLI
			NPL->NPL_NOMCLI := Posicione('SA1',1,xFilial('SA1')+NPO->NPO_CODCLI+NPO->NPO_LOJCLI,'A1_NOME')
			NPL->NPL_SAFRA  := NPO->NPO_SAFRA
			NPL->NPL_ARM    := NPO->NPO_ARM
			NPL->NPL_ENBRUT := NPO->NPO_PSSUBT
			NPL->NPL_ENDESC := NPO->NPO_PSDESC
			NPL->NPL_ENEXTR := NPO->NPO_PSEXTR
			NPL->NPL_ENLIQU := NPO->NPO_PSREAL
			NPL->NPL_SALDO  := NPO->NPO_PSREAL
			msUnLock()
		EndIf
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณGrava dados no Apontamento de Produ็ใoณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	dbSelectArea('NPA')
	dbSetOrder(1)
	If .Not. Empty(NPO->NPO_CODAPO) .And. dbSeek(xFilial('NPA')+NPO->NPO_CODAPO)
		If RecLock('NPA',.f.)
			NPA->NPA_QTDREA := NPO->NPO_PSLIQU
			NPA->NPA_FECHAD := 'S'
			NPA->NPA_LOCAL := NPO->NPO_ARM
			msUnLock()
		EndIf

		dbSelectArea('NPB')
		dbSeek(xFilial('NPB')+NPA->NPA_CODIGO)
		While .Not. Eof() .And. xFilial('NPA')+NPA->NPA_CODIGO == xFilial('NPB')+NPB->NPB_CODIGO
			If RecLock('NPB',.f.)
				NPB->NPB_PSREAL := (NPB->NPB_PERVAR * NPO->NPO_PSLIQU) / 100
				MsUnLock()
			EndIf
			dbSkip()
		EndDo

		/*
		cTMUtil := Substr(GetMV('MV_AGRTM',,'001/101/501'),1,3)
		SF5->(dbSeek(xFilial('SF5')+cTMUtil))
		If GetMV('MV_AGRXEST',,.f.)

			dbSelectArea('SC2')
			dbSetOrder(1)
			If dbSeek(xFilial('SC2')+NPA->NPA_CODIGO+'AG001')
				If SC2->C2_QUJE = 0

					nZ++
					aAdd(aMata250, {})
					aAdd(aMata250[nZ], {'D3_TM'     ,cTMUtil                 ,Nil})
					aAdd(aMata250[nZ], {'D3_COD'    ,NPA->NPA_CODPRO         ,Nil})
					aAdd(aMata250[nZ], {'D3_UM'     ,NPA->NPA_UM             ,Nil})
					aAdd(aMata250[nZ], {'D3_QUANT'  ,NPO->NPO_PSLIQU         ,Nil})
					aAdd(aMata250[nZ], {'D3_LOCAL'  ,NPA->NPA_LOCAL          ,Nil})
					aAdd(aMata250[nZ], {'D3_EMISSAO',NPA->NPA_DATA           ,Nil})
					aAdd(aMata250[nZ], {'D3_TIPO'   ,SB1->B1_TIPO            ,Nil})
					aAdd(aMata250[nZ], {'D3_OP'     ,NPA->NPA_CODIGO+'AG001' ,Nil})
					aAdd(aMata250[nZ], {'D3_DOC'    ,NPA->NPA_CODIGO         ,Nil})
					aAdd(aMata250[nZ], {'D3_PARCTOT','T'                     ,Nil})
					aAdd(aMata250[nZ], {'D3_USUARIO',Substr(cUsuario,7,15)   ,Nil})
					aAdd(aMata250[nZ], {'D3_PERDA'  ,ABS(NPA->NPA_QTDEST-NPO->NPO_PSLIQU),Nil})
					If SF5->F5_VAL=='S'
						aAdd(aMata250[nZ], {'D3_CUSTO1', NPA->NPA_VLRTOT, Nil})
					EndIf
		
					MSExecAuto({|x,y| mata250(x,y)},aMata250[1],3)
					If lMsErroAuto
						DisarmTransaction()
						Mostraerro()
						Return()
					EndIf
				EndIf
			EndIf
		EndIf
		*/

		If NPA->NPA_NFSOPE == 'V'
			dbSelectArea('NPR')
			dbSetOrder(1)
			If RecLock('NPR',.t.)
				NPR->NPR_FILIAL := xFilial('NPR')
				NPR->NPR_CODIGO := GetSXENum('NPR','NPR_CODIGO')
				NPR->NPR_TIPO   := 'V'
				NPR->NPR_DATA   := NPO->NPO_DATA
				NPR->NPR_SAFRA  := NPO->NPO_SAFRA
				NPR->NPR_ARM    := NPO->NPO_ARM
				NPR->NPR_CODCLI := NPO->NPO_CODCLI
				NPR->NPR_LOJCLI := NPO->NPO_LOJCLI
				NPR->NPR_CODTRA := NPO->NPO_CODTRA
				NPR->NPR_CODEQU := NPO->NPO_CODEQU
				NPR->NPR_CODMOT := NPO->NPO_CODMOT
				NPR->NPR_CODPRO := NPO->NPO_CODPRO
				NPR->NPR_UM     := NPO->NPO_UM
				NPR->NPR_TICKET := NPO->NPO_TICKET
				NPR->NPR_LAUDO  := NPO->NPO_LAUDO
				NPR->NPR_CODTAB := NPO->NPO_CODTAB
				NPR->NPR_PSBRUT := NPO->NPO_PSBRUT
				NPR->NPR_PSTARA := NPO->NPO_PSTARA
				NPR->NPR_PSSUBT := NPO->NPO_PSSUBT
				NPR->NPR_PSDESC := NPO->NPO_PSDESC
				NPR->NPR_PSLIQU := NPO->NPO_PSLIQU
				NPR->NPR_PSEXTR := NPO->NPO_PSEXTR
				NPR->NPR_PSREAL := NPO->NPO_PSREAL
				NPR->NPR_SALDO  := NPO->NPO_PSREAL
				NPR->NPR_OBS    := NPO->NPO_OBS
				msUnLock()
				ConfirmSX8()
			EndIf
			dbSelectArea('NPO')
			If RecLock('NPO',.f.)
				NPO->NPO_ROMSAI := NPR->NPR_CODIGO
				msUnLock()
			EndIf
			dbSelectArea('NPP')
			dbSetOrder(1)
			If dbSeek(xFilial('NPP')+NPO->NPO_CODIGO)
				While NPP->NPP_CODIGO == NPO->NPO_CODIGO
					dbSelectArea('NPS')
					dbSetOrder(1)
					If RecLock('NPS',.t.)
						NPS->NPS_FILIAL := xFilial('NPS')
						NPS->NPS_CODIGO := NPR->NPR_CODIGO
						NPS->NPS_ITEM   := NPP->NPP_ITEM
						NPS->NPS_CODDES := NPP->NPP_CODDES
						NPS->NPS_DESDES := NPP->NPP_DESDES
						NPS->NPS_PERDES := NPP->NPP_PERDES
						NPS->NPS_PESDES := NPP->NPP_PESDES
						msUnLock()
					EndIf
					dbSelectArea('NPP')
					dbSkip()
				EndDo
			EndIf

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณGrava dados na tabela de estoque por clientexarmazemxsafra.ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			dbSelectArea('NPL')
			dbSetOrder(1)
			If dbSeek(xFilial('NPL')+NPR->NPR_CODCLI+NPR->NPR_LOJCLI+NPR->NPR_SAFRA+NPR->NPR_ARM)
				If RecLock('NPL',.f.)
					NPL->NPL_SDBRUT := NPL->NPL_SDBRUT + NPR->NPR_PSSUBT
					NPL->NPL_SDDESC := NPL->NPL_SDDESC + NPR->NPR_PSDESC
					NPL->NPL_SDEXTR := NPL->NPL_SDEXTR + NPR->NPR_PSEXTR
					NPL->NPL_SDLIQU := NPL->NPL_SDLIQU + NPR->NPR_PSREAL
					NPL->NPL_SALDO  := NPL->NPL_SALDO  - NPR->NPR_PSREAL
					msUnLock()
				EndIf
			Else
				If RecLock('NPL',.t.)
					NPL->NPL_FILIAL := xFilial('NPL')
					NPL->NPL_CODCLI := NPR->NPR_CODCLI
					NPL->NPL_LOJCLI := NPR->NPR_LOJCLI
					NPL->NPL_NOMCLI := Posicione('SA1',1,xFilial('SA1')+NPR->NPR_CODCLI+NPR->NPR_LOJCLI,'A1_NOME')
					NPL->NPL_SAFRA  := NPR->NPR_SAFRA
					NPL->NPL_ARM    := NPR->NPR_ARM
					NPL->NPL_SDBRUT := NPR->NPR_PSSUBT
					NPL->NPL_SDDESC := NPR->NPR_PSDESC
					NPL->NPL_SDEXTR := NPR->NPR_PSEXTR
					NPL->NPL_SDLIQU := NPR->NPR_PSREAL
					NPL->NPL_SALDO  := NPR->NPR_PSREAL
					msUnLock()
				EndIf
			EndIf
		EndIf
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณGrava dados de Acertos de Fretes      ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	/*
	dbSelectArea('NT1')
	dbSetOrder(1)
	If dbSeek(xFilial('NT1')+NPA->NPA_SAFRA+NPA->NPA_FAZ+NPA->NPA_LOCAL+NPA->NPA_CODEQU)
		//Verifica a existencia de um PC
		If .Not. Empty(NT1->NT1_PCNUM) //Ja existe um pedido cadastrado...
			dbSelectArea('SC7')
			dbSetOrder(1)
			If dbSeek(xFilial('SC7')+NT1->NT1_PCNUM)
				//Carrega linha para memoria
				//Grava linha alterando o item
				RegToMemory('SC7', .F.)
				M->C7_ITEM    := Soma1(SC7->C7_ITEM,3)
				M->C7_QUANT   := AGRX001( NPA->NPA_UM, NT1->NT1_UM, NPO->NPO_PSLIQU)
				M->C7_PRECO   := NT1->NT1_VALOR
				M->C7_TOTAL   := M->C7_QUANT*M->C7_PRECO
				If RecLock('SC7',.t.)
					For nY := 1 To FCount()
						&('SC7->'+FieldName(nY)) := &('M->'+FieldName(nY))
					Next nY
					SC7->C7_FILIAL := xFilial('SC7')
					MsUnLock()
				EndIf
			EndIf
		Else //Ainda nใo existe um pedido de vendas
			If .Not. Empty(NT1->NT1_PCPDR) //Existe referencial de um modelo de PC
				dbSelectArea('NQ1')
				dbSetOrder(1)
				If dbSeek(xFilial('NQ1')+NT1->NT1_PCPDR)
					SB1->(dbSeek(xFilial('SB1')+NQ1->NQ1_CODPRO))
					dbSelectArea('SC7')
					RegToMemory('SC7',.T.)
					M->C7_TIPO    := 1 //PEDIDO DE COMPRAS
					M->C7_ITEM    := '001'
					M->C7_PRODUTO := NQ1->NQ1_CODPRO
					M->C7_UM      := NT1->NT1_UM
					M->C7_GRUPOPR := SB1->B1_GRUPO
					M->C7_QUANT   := AGRX001( NPA->NPA_UM, NT1->NT1_UM, NPO->NPO_PSLIQU)
					M->C7_PRECO   := NT1->NT1_VALOR
					M->C7_TOTAL   := M->C7_QUANT*M->C7_PRECO
					M->C7_DATPRF  := dDataBase
					M->C7_LOCAL   := SB1->B1_LOCPAD
					M->C7_FORNECE := NQ1->NQ1_CODFOR
					M->C7_LOJA    := NQ1->NQ1_LOJFOR
					M->C7_COND    := NQ1->NQ1_CONDPG
					M->C7_EMISSAO := dDataBase
					M->C7_NUM     := GetSXENum('SC7','C7_NUM')
					M->C7_FILENT  := xFilial("SC7")
					M->C7_DESCRI  := SB1->B1_DESC
					M->C7_TES     := NQ1->NQ1_TES
					M->C7_TPFRETE := 'C'
					M->C7_FLUXO   := 'N'
					M->C7_CONAPRO := 'L'
					M->C7_USER    := '000000'
					M->C7_MOEDA   := NQ1->NQ1_MOEDA
					M->C7_TXMOEDA := NQ1->NQ1_TAXA
					M->C7_PENDEN  := 'N'
					M->C7_DATINIC := dDataBase
					M->C7_CONTA   := NQ1->NQ1_CONTA
					M->C7_CLVL    := NQ1->NQ1_CLVL
					M->C7_CC	  := NQ1->NQ1_CC
					M->C7_ITEMCTA := NQ1->NQ1_ITEMCT
					If RecLock('SC7',.t.)
						For nY := 1 To FCount()
							&('SC7->'+FieldName(nY)) := &('M->'+FieldName(nY))
						Next nY
						SC7->C7_FILIAL := xFilial('SC7')
						MsUnLock()
					EndIf
					If __lSX8
						ConfirmSX8()
					EndIf
					dbSelectArea('NT1')
					If RecLock('NT1',.f.)
						NT1->NT1_PCNUM := M->C7_NUM
						MsUnLock()
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
	*/

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ“ฺฟ
	//ณGrava dados das transferencia caso haja descontos extras.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ“ฺู

	If Len(aDescExt) > 0
		For nX := 1 To Len(aDescExt)
			If aDescExt[nX,3] > 0
				dbSelectArea('NPI')
				dbSetOrder(1)
				cNovoCod := GetSXENum('NPI','NPI_CODIGO')
				If RecLock('NPI',.t.)
					NPI->NPI_FILIAL := xFilial('NPI')
					NPI->NPI_CODIGO := cNovoCod
					NPI->NPI_DATA   := M->NPO_DATA
					NPI->NPI_SAFRA  := M->NPO_SAFRA
					NPI->NPI_ARM    := M->NPO_ARM
					NPI->NPI_CDCLIO := M->NPO_CODCLI
					NPI->NPI_LJCLIO := M->NPO_LOJCLI
					NPI->NPI_DSCLIO := Posicione('SA1',1,xFilial('SA1')+M->NPO_CODCLI+M->NPO_LOJCLI,'A1_NOME')
					NPI->NPI_CDCLID := Substr(cMVAGRXCLI,1,6)
					NPI->NPI_LJCLID := Substr(cMVAGRXCLI,7,2)
					NPI->NPI_DSCLID := Posicione('SA1',1,xFilial('SA1')+Substr(cMVAGRXCLI,1,8),'A1_NOME')
					NPI->NPI_CODPRO := M->NPO_CODPRO
					NPI->NPI_UM     := M->NPO_UM
					NPI->NPI_CODROM := M->NPO_CODIGO
					NPI->NPI_CODDES := aDescExt[nX,1]
					NPI->NPI_QUANT  := aDescExt[nX,3]
					NPI->NPI_OBS    := "Transferencia romaneio " + M->NPO_CODIGO + " desconto de " + aDescExt[nX,2] + "."
					NPI->NPI_TIPO   := 'I'
					msUnLock()
				EndIf
			EndIf

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณGrava dados na tabela de estoque por clientexarmazemxsafraณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			dbSelectArea('NPL')
			dbSetOrder(1)
			If dbSeek(xFilial('NPL')+NPI->NPI_CDCLID+NPI->NPI_LJCLID+NPI->NPI_SAFRA+NPI->NPI_ARM)
				If RecLock('NPL',.f.)
					NPL->NPL_ENTRFS := NPL->NPL_ENTRFS + NPI->NPI_QUANT
					NPL->NPL_SALDO  := NPL->NPL_SALDO  + NPI->NPI_QUANT
					msUnLock()
				EndIf
			Else
				If RecLock('NPL',.t.)
					NPL->NPL_FILIAL := xFilial('NPL')
					NPL->NPL_CODCLI := NPI->NPI_CDCLID
					NPL->NPL_LOJCLI := NPI->NPI_LJCLID
					NPL->NPL_NOMCLI := NPI->NPI_DSCLID
					NPL->NPL_SAFRA  := NPI->NPI_SAFRA
					NPL->NPL_ARM    := NPI->NPI_ARM
					NPL->NPL_ENTRFS := NPI->NPI_QUANT
					NPL->NPL_SALDO  := NPI->NPI_QUANT
				EndIf
			EndIf
		Next nX	
	EndIf
End Transaction

//ponto de entrada para tratamento do frete...
If ExistBlock('AGRA280IN')
	ExecBlock('AGRA280IN',.F.,.F.)
EndIf

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ fExclui  บ Autor ณ Ricardo Tomasi     บ Data ณ  25/05/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina auxiliar para exclusใo de romaneio de entrada.      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function fExclui()
Local lRomSai := .f.

If .Not. Empty(AllTrim(NPO->NPO_ROMSAI))
	dbSelectArea('NPR')
	dbSetOrder(1)
	If dbSeek(xFilial('NPR')+NPO->NPO_ROMSAI)
		lRomSai := .t.
		If NPR->NPR_SALDO <> NPR->NPR_PSREAL
			ApMsgAlert("O romaneio ja sofreu baixa por Nota Fiscal.","Impossivel Excluir")
			Return()
		EndIf
	EndIf
EndIf

Begin Transaction

	If lRomSai
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณGrava dados na tabela de estoque por clientexarmazemxsafra.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		dbSelectArea('NPL')
		dbSetOrder(1)
		If dbSeek(xFilial('NPL')+NPR->NPR_CODCLI+NPR->NPR_LOJCLI+NPR->NPR_SAFRA+NPR->NPR_ARM)
			If RecLock('NPL',.f.)
				NPL->NPL_SDBRUT := NPL->NPL_SDBRUT - NPR->NPR_PSSUBT
				NPL->NPL_SDDESC := NPL->NPL_SDDESC - NPR->NPR_PSDESC
				NPL->NPL_SDEXTR := NPL->NPL_SDEXTR - NPR->NPR_PSEXTR
				NPL->NPL_SDLIQU := NPL->NPL_SDLIQU - NPR->NPR_PSREAL
				NPL->NPL_SALDO  := NPL->NPL_SALDO  - NPR->NPR_PSREAL
				msUnLock()
			EndIf
		EndIf
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณGrava dados na tabela de estoque por clientexarmazemxsafra.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	dbSelectArea('NPL')
	dbSetOrder(1)
	If dbSeek(xFilial('NPL')+NPO->NPO_CODCLI+NPO->NPO_LOJCLI+NPO->NPO_SAFRA+NPO->NPO_ARM)
		If RecLock('NPL',.f.)
			NPL->NPL_ENBRUT := NPL->NPL_ENBRUT - NPO->NPO_PSSUBT
			NPL->NPL_ENDESC := NPL->NPL_ENDESC - NPO->NPO_PSDESC
			NPL->NPL_ENEXTR := NPL->NPL_ENEXTR - NPO->NPO_PSEXTR
			NPL->NPL_ENLIQU := NPL->NPL_ENLIQU - NPO->NPO_PSREAL
			NPL->NPL_SALDO  := NPL->NPL_SALDO  - NPO->NPO_PSREAL
			msUnLock()
		EndIf
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณExclui transferencias por desconto extra.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	dbSelectArea('NPI')
	dbSetOrder(2)
	If dbSeek(xFilial('NPI')+NPO->NPO_CODIGO)
		While .Not. Eof() .And. NPI->NPI_CODROM==NPO->NPO_CODIGO
			dbSelectArea('NPL')
			dbSetOrder(1)
			If dbSeek(xFilial('NPL')+NPI->NPI_CDCLID+NPI->NPI_LJCLID+NPI->NPI_SAFRA+NPI->NPI_ARM)
				If RecLock('NPL',.f.)
					NPL->NPL_ENTRFS := NPL->NPL_ENTRFS - NPI->NPI_QUANT
					NPL->NPL_SALDO  := NPL->NPL_SALDO  - NPI->NPI_QUANT
					msUnLock()
				EndIf
			EndIf
			dbSelectArea('NPI')
			If RecLock('NPI',.f.)
				dbDelete()
				msUnLock()
			EndIf
			dbSkip()
		EndDo
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณReabre o Apontamento de Produ็ใo se existir.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If .Not. Empty(NPO->NPO_CODAPO)
		dbSelectArea('NPA')
		dbSetOrder(1)
		dbSeek(xFilial('NPA')+NPO->NPO_CODAPO)
		If RecLock('NPA',.f.)
			NPA->NPA_QTDREA := 0
			NPA->NPA_FECHAD := 'N'
			MsUnLock()
		EndIf
		dbSelectArea('NPB')
		dbSetOrder(1)
		dbSeek(xFilial('NPB')+NPA->NPA_CODIGO)
		While .Not. Eof() .And. xFilial('NPA')+NPA->NPA_CODIGO == xFilial('NPB')+NPB->NPB_CODIGO
			If RecLock('NPB',.f.)
				NPB->NPB_PSREAL
				MsUnLock()
			EndIf
			dbSkip()
		EndDo
	EndIf

	If lRomSai

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณExclui itens do romaneio de saida.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		dbSelectArea('NPS')
		dbSetOrder(1)
		If dbSeek(xFilial('NPS')+NPR->NPR_CODIGO)
			While .Not. Eof() .And. NPS->NPS_CODIGO==NPR->NPR_CODIGO
				If RecLock('NPS',.f.)
					dbDelete()
					msUnLock()
				EndIf
				dbSkip()
			EndDo
		EndIf
	
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณExclui cabecalho de romaneio de saida.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		dbSelectArea('NPR')
		dbSetOrder(1)
		If dbSeek(xFilial('NPR')+NPR->NPR_CODIGO)
			If RecLock('NPR',.f.)
				dbDelete()
				MsUnLock()
			EndIf
		EndIf

	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณExclui itens do romaneio de entrada.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	dbSelectArea('NPP')
	dbSetOrder(1)
	If dbSeek(xFilial('NPP')+NPO->NPO_CODIGO)
		While .Not. Eof() .And. NPP->NPP_CODIGO==NPO->NPO_CODIGO
			If RecLock('NPP',.f.)
				dbDelete()
				msUnLock()
			EndIf
			dbSkip()
		EndDo
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณExclui cabecalho de romaneio de entrada.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	dbSelectArea('NPO')
	dbSetOrder(1)
	If dbSeek(xFilial('NPO')+M->NPO_CODIGO)
		If RecLock('NPO',.f.)
			dbDelete()
			MsUnLock()
		EndIf
	EndIf

End Transaction

//ponto de entrada para tratamento do frete...
If ExistBlock('AGRA280EX')
	ExecBlock('AGRA280EX',.F.,.F.)
EndIf

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRA280L บAutor  ณ Ricardo Tomasi     บ Data ณ  13/07/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Legenda para Romaneio de Entrada.                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AGRA280L()
Local aLeg := {}

aAdd(aLeg,{'BR_VERDE'   ,'Produ็ใo Pr๓pria'   })
aAdd(aLeg,{'BR_AZUL'    ,'Produ็ใo de Terceiro' })
aAdd(aLeg,{'BR_AMARELO' ,'Transfer๊ncia'      })

BrwLegenda(cCadastro,"Legenda dos Romaneios", aLeg)

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
				 { STR0002 ,'AxPesqui',0,1} ,; //"Pesquisar"
				 { STR0003 ,'AGRA280A',0,2} ,; //"Visualizar"
				 { STR0004 ,'AGRA280A',0,3} ,; //"Incluir"
				 { STR0005 ,'AGRA280A',0,5} ,; //"Excluir"
				 { "Imprimir" ,'AGRR280' ,0,6} ,;
				 { "Legenda", 'AGRA280L' ,0,6} ;
				 }

Return(aRotina)