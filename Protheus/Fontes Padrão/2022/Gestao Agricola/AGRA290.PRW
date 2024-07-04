#INCLUDE 'AGRA290.CH'
#include 'protheus.ch'
#include "fwmvcdef.ch"
#INCLUDE "TOTVS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRA290  บ Autor ณ Ricardo Tomasi     บ Data ณ  25/05/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina de Romaneio de Saida.                               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function AGRA290()

Private aCores    := {;
					 {'NPR->NPR_TIPO=="V".And.NPR->NPR_SALDO==NPR->NPR_PSREAL' ,'BR_VERDE'    },;
                     {'NPR->NPR_TIPO=="V".And.NPR->NPR_SALDO< NPR->NPR_PSREAL' ,'BR_VERMELHO' },;
                     {'NPR->NPR_TIPO=="T"'                                     ,'BR_AMARELO'  } ;
                     }
Private cCadastro := STR0001 //"Romaneio de Saida"
Private aRotina   := MenuDef()

dbSelectArea('NPR')
dbSetOrder(1)

mBrowse( 6, 1, 22, 75, 'NPR', Nil, Nil, Nil, Nil, Nil, aCores)

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRA290A บ Autor ณ Ricardo Tomasi     บ Data ณ  25/05/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina auxiliar para montar a tela de romaneio de saida.   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function AGRA290A(cAlias, nReg, nOpc)
Local aSize    := MsAdvSize()
Local aObjects := {{100,100,.t.,.t.},{100,100,.t.,.t.},{100,015,.t.,.f.}}
Local aInfo    := {aSize[1],aSize[2],aSize[3],aSize[4],3,3}
Local aPosObj  := MsObjSize(aInfo,aObjects)
Local nOpcX    := aRotina[nOpc,4]
Local nOpcA    := 0
Local nX       := 0
Local nC       := 0
Local aCampos  := {}
Local aStruct  := NPS->(dbStruct())
Local oStruNpS := FWFormStruct(1, 'NPS')
Local lVirtual := .F.

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
Private nMaxLin := 0

aAdd(aCampos, 'NPS_ITEM'  ); aAdd(aCampos, 'NPS_CODDES'); aAdd(aCampos, 'NPS_DESDES')
aAdd(aCampos, 'NPS_PERDES'); aAdd(aCampos, 'NPS_PESDES')

//Substitui a montagem do aHeader com a utiliza็ใo direta da tabela SX3
For nX := 1 To Len(aStruct)
	If aScan(aCampos, aStruct[nX, 1]) > 0

		lVirtual := oStruNpS:GetProperty(aStruct[nX, 1], MODEL_FIELD_VIRTUAL)
		
		aAdd(aHeader,{RetTitle(aStruct[nX, 1]), aStruct[nX, 1], PesqPict("NPS",aStruct[nX, 1]), aStruct[nX, 3], aStruct[nX, 4], x3Valid(aStruct[nX, 1]), x3Usado(aStruct[nX, 1]), aStruct[nX, 2], "NPS", IIF(!lVirtual, "R", "V")})	

	EndIf
Next nX

If nOpc <> 3
	dbSelectArea('NPS')
	dbSetOrder(1)
	dbSeek(xFilial('NPS')+NPR->NPR_CODIGO)
	While !Eof() .And. xFilial('NPS')+NPS->NPS_CODIGO == xFilial('NPR')+NPR->NPR_CODIGO
		nC++
		aAdd(aCols, Array(Len(aHeader)+1))
		For nX := 1 to Len(aHeader)
			aCols[nC,nX] := FieldGet(FieldPos(aHeader[nX,2]))
		Next
		aCols[nC,Len(aHeader)+1] := .f.
		dbSkip()
	EndDo
EndIf

RegToMemory(cAlias,(nOpc == 3))

Define MSDialog oDlg Title cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd Pixel

	oFnt1 := TFont():New( 'Courier New',11)
	oEnch := MsMGet():New(cAlias,nReg,nOpc,,,,,aPosObj[1],,3,,,,oDlg,,.t.)
	oGetD := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpc,,,,.f.,,Len(aHeader),,nMaxLin,'AGRA290E()',,,,oDlg)
	oSay1 := TSay():New(aPosObj[3,1]   ,aPosObj[3,2]    , {|| 'Produtor: '  +Posicione('SA1',1,xFilial('SA1')+M->NPR_CODCLI+M->NPR_LOJCLI,'A1_NOME') },oDlg,,oFnt1,,,,.t.,CLR_BLUE,,200,21)
	oSay2 := TSay():New(aPosObj[3,1]+15,aPosObj[3,2]    , {|| 'Endere็o: '  +Posicione('SA1',1,xFilial('SA1')+M->NPR_CODCLI+M->NPR_LOJCLI,'A1_END' ) },oDlg,,oFnt1,,,,.t.,CLR_BLUE,,200,21)
	oSay3 := TSay():New(aPosObj[3,1]   ,aPosObj[3,2]+210, {|| 'Armazem: '   +Posicione('NNR',1,xFilial('NNR')+M->NPR_ARM,'NNR_DESCRI'              ) },oDlg,,oFnt1,,,,.t.,CLR_BLUE,,200,21)
	oSay4 := TSay():New(aPosObj[3,1]+15,aPosObj[3,2]+210, {|| 'Quantidade: '+Transform(M->NPR_PSREAL, '@E 99,999,999,999'                          ) },oDlg,,oFnt1,,,,.t.,CLR_RED ,,200,21)
	
Activate MsDialog oDlg On Init EnchoiceBar(oDlg, {|| nOpcA := 1, IIf(AGRA290B(nOpcX), oDlg:End(), nOpcA := 0) } , {|| nOpcA := 0, oDlg:End() })

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
ฑฑบPrograma  ณ AGRA290B บ Autor ณ Ricardo Tomasi     บ Data ณ  25/05/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Valida็ใo do Enchoice.                                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function AGRA290B(nOpcX)
Local lRetorno := .t.

If nOpcX == 3 .Or. nOpcX == 4

	lRetorno := Obrigatorio(aGets,aTela) .And. oGetD:TudoOK()

	If .Not. GetMV('MV_AGRSNEG',,.t.)
		dbSelectArea('NPL')
		dbSetOrder(1)
		If dbSeek(xFilial('NPL')+M->NPR_CODCLI+M->NPR_LOJCLI+M->NPR_SAFRA+M->NPR_ARM)
			nSaldo := NPL->NPL_SALDO
		EndIf
		If nSaldo >= M->NPR_PSREAL
			lRetorno := .t.
		Else
			ApMsgAlert("O cliente nใo possui saldo suficiente neste armazem para realizar esta opera็ใo.","Saldo Insuficiente")
		EndIf
	EndIf

EndIf

Return(lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRA290C บ Autor ณ Ricardo Tomasi     บ Data ณ  25/05/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Atualiza GetDados para contemplar a tabela de classifica็ใoบฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function AGRA290C()
Local aAreaAt := GetArea()
Local nX := 0
Local nC := 0
Local nP_ITEM   := aScan(aHeader, { |x| Alltrim(x[2]) == 'NPS_ITEM'  })
Local nP_CODDES := aScan(aHeader, { |x| Alltrim(x[2]) == 'NPS_CODDES'})
Local nP_DESDES := aScan(aHeader, { |x| Alltrim(x[2]) == 'NPS_DESDES'})

aCols := Array(0)

dbSelectArea('NNI')
dbSetOrder(1)
dbSeek(xFilial('NNI')+M->NPR_CODTAB)

If M->NPR_DATA < NNI->NNI_DATINI .Or. M->NPR_DATA > NNI->NNI_DATFIM
	ApMsgAlert(STR0006,STR0007) //"Esta tabela esta fora da data de vig๊ncia!!!"###"Data de Vig๊ncia"
	Return(.f.)
EndIf

dbSelectArea('NNJ')
dbSetOrder(2)
If dbSeek(xFilial('NNJ')+NNI->NNI_CODIGO)

	While !Eof() .And. NNI->NNI_CODIGO == NNJ->NNJ_CODTAB
		If NNJ->NNJ_EXTDES=='N'
			nC++
			aAdd(aCols, Array(Len(aHeader)+1))
			For nX := 1 to Len(aHeader)
				aCols[nC,nX] := CriaVar(aHeader[nX,2])
			Next
			aCols[nC,nP_ITEM]   := NNJ->NNJ_SEQ
			aCols[nC,nP_CODDES] := NNJ->NNJ_CODDES
			aCols[nC,nP_DESDES] := NNJ->NNJ_DESDES
			aCols[nC,Len(aHeader)+1] := .f.
		EndIf
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
ฑฑบPrograma  ณ AGRA290D บ Autor ณ Ricardo Tomasi     บ Data ณ  25/05/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Valida็ใo Utilizada no Peso Bruto e no Peso Tara do Equip. บฑฑ
ฑฑบ          ณ Calcula o Peso Liquido Recalcula Descontos e Pesos.        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function AGRA290D()
Local aAreaAt := GetArea()

Do Case
	Case 'NPR_PSBRUT' $ __READVAR
		If M->NPR_PSTARA > M->NPR_PSBRUT
			ApMsgAlert(STR0008,STR0009) //"Peso Bruto nใo pode ser menor que o Peso Tara!"###"Peso Invalido"
			Return(.f.)
		EndIf
		M->NPR_PSSUBT := M->NPR_PSBRUT - M->NPR_PSTARA
	Case 'NPR_PSTARA' $ __READVAR
		If M->NPR_PSTARA > M->NPR_PSBRUT
			ApMsgAlert(STR0010,STR0009) //"Peso Tara nใo pode ser maior que o Peso Bruto!"###"Peso Invalido"
			Return(.f.)
		EndIf
		M->NPR_PSSUBT := M->NPR_PSBRUT - M->NPR_PSTARA
EndCase

oEnch:Refresh()
oGetD:oBrowse:Refresh()
RestArea(aAreaAt)
Return(.t.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRA290E บ Autor ณ Ricardo Tomasi     บ Data ณ  25/05/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Atualiza o campo peso do desconto aplicando a tabela de    บฑฑ
ฑฑบ          ณ classifica็ใo apontada e os percentuais inseridos.         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function AGRA290E()
Local aAreaAt   := GetArea()
Local nX        := 0
Local nPerDes   := 0
Local nPesLiq   := 0
Local nTotDes   := 0
Local nTotExt   := 0
Local nP_CODDES := aScan(aHeader, { |x| Alltrim(x[2]) == 'NPS_CODDES'})
Local nP_PERDES := aScan(aHeader, { |x| Alltrim(x[2]) == 'NPS_PERDES'})
Local nP_PESDES := aScan(aHeader, { |x| Alltrim(x[2]) == 'NPS_PESDES'})

For nX := 1 to Len(aCols)

	nPerDes := aCols[nX,nP_PERDES]

	If 'NPS_PERDES' $ __READVAR .And. n == nX 
		nPerDes := M->NPS_PERDES
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
	dbSeek(xFilial('NNI')+M->NPR_CODTAB)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPosiciona Itens da Tabela de Descontosณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	dbSelectArea('NNJ')
	dbSetOrder(1)
	dbSeek(xFilial('NNJ')+M->NPR_CODTAB+aCols[nX,nP_CODDES])
	If NNJ->NNJ_INCIDE == 'A'
		nPesLiq := M->NPR_PSSUBT
	Else
		nPesLiq := M->NPR_PSLIQU
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPosiciona Sub-Itens da Tabela de Descontosณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	dbSelectArea('NNK')
	dbSetOrder(1)
	dbSeek(xFilial('NNK')+M->NPR_CODTAB+aCols[nX,nP_CODDES])
	While !Eof() .And. NNK->NNK_CODTAB == M->NPR_CODTAB .And. NNK->NNK_CODDES == aCols[nX,nP_CODDES]
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

	M->NPR_PSDESC := nTotDes
	M->NPR_PSLIQU := M->NPR_PSSUBT - nTotDes
	M->NPR_PSEXTR := nTotExt
	M->NPR_PSREAL := M->NPR_PSLIQU - nTotExt

Next nX

oSay4:Refresh()
oEnch:Refresh()
oGetD:oBrowse:Refresh()
RestArea(aAreaAt)
Return(.t.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ fInclui  บ Autor ณ Ricardo Tomasi     บ Data ณ  25/05/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina auxiliar para inclusใo de romaneio de saida.        บฑฑ
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

Begin Transaction

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณGrava cabecalho e itens do romaneio de saida.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	dbSelectArea('NPR')
	dbSetOrder(1)
	dbSeek(xFilial('NPR')+M->NPR_CODIGO)
	If RecLock('NPR',.t.)
		For nY := 1 To FCount()
			&('NPR->'+FieldName(nY)) := &('M->'+FieldName(nY))
		Next nY
		NPR->NPR_FILIAL := xFilial('NPR')
		NPR->NPR_SALDO := M->NPR_PSREAL
		MsUnLock()
	EndIf
	For nX := 1 To Len(aCols)
		dbSelectArea('NPS')
		dbSetOrder(1)
		If RecLock('NPS',.t.)
			NPS->NPS_FILIAL := xFilial('NPS')
			NPS->NPS_CODIGO  := NPR->NPR_CODIGO
			For nY := 1 To Len(aHeader)
				&('NPS->'+aHeader[nY,2]) := aCols[nX,nY]
			Next nY
			msUnLock()
		EndIf
	Next nX

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

End Transaction

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ fExclui  บ Autor ณ Ricardo Tomasi     บ Data ณ  25/05/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina auxiliar para exclusใo de romaneio de saida.        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function fExclui()

If NPR->NPR_SALDO <> NPR->NPR_PSREAL
	ApMsgAlert("O romaneio ja sofreu baixa por Nota Fiscal.","Impossivel Excluir")
	Return()
EndIf

Begin Transaction

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
	If dbSeek(xFilial('NPR')+M->NPR_CODIGO)
		If RecLock('NPR',.f.)
			dbDelete()
			MsUnLock()
		EndIf
	EndIf

End Transaction

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRA290L บAutor  ณ Ricardo Tomasi     บ Data ณ  13/07/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Legenda para Romaneio de Saida.                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AGRA290L()
Local aLeg := {}

aAdd(aLeg,{'BR_VERDE'    ,'Venda Sem NFS' })
aAdd(aLeg,{'BR_VERMELHO' ,'Venda Com NFS' })
aAdd(aLeg,{'BR_AMARELO'  ,'Transfer๊ncia' })

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
				 { STR0002 ,"AxPesqui",0,1} ,; //"Pesquisar"
				 { STR0003 ,"AGRA290A",0,2} ,; //"Visualizar"
				 { STR0004 ,"AGRA290A",0,3} ,; //"Incluir"
				 { STR0005 ,"AGRA290A",0,5} ,; //"Excluir"
				 { "Imprimir" ,"AGRR290",0,5} ,; //"Imprimir"
				 { "Legenda" ,"AGRA290L",0,6}  ;
				 }

Return(aRotina)