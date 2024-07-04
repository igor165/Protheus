#INCLUDE "AGRA100.ch"
#include 'protheus.ch'

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRA100  บ Autor ณ Ricardo Tomasi     บ Data ณ  09/08/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina para inclusใo de Compromisso Futuro.                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsga                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function AGRA100()

	Private aCores  :=  {;
	                     {'(NO1->NO1_FECHAD=="N".Or.NO1->NO1_FECHAD==" ").And.(NO1->NO1_FCHFIN=="N".Or.NO1->NO1_FCHFIN==" ").And.(NO1->NO1_FCHFAT=="N".Or.NO1->NO1_FCHFAT==" ")' ,'BR_VERDE'   },;
	                     {'(NO1->NO1_FECHAD=="N".Or.NO1->NO1_FECHAD==" ").And.(NO1->NO1_FCHFIN=="S".Or.NO1->NO1_FCHFIN=="S").And.(NO1->NO1_FCHFAT=="N".Or.NO1->NO1_FCHFAT==" ")' ,'BR_AZUL'    },;
	                     {'(NO1->NO1_FECHAD=="N".Or.NO1->NO1_FECHAD==" ").And.(NO1->NO1_FCHFIN=="N".Or.NO1->NO1_FCHFIN==" ").And.(NO1->NO1_FCHFAT=="S".Or.NO1->NO1_FCHFAT=="S")' ,'BR_AMARELO' },;
	                     {'(NO1->NO1_FECHAD=="N".Or.NO1->NO1_FECHAD==" ").And.(NO1->NO1_FCHFIN=="S".Or.NO1->NO1_FCHFIN=="S").And.(NO1->NO1_FCHFAT=="S".Or.NO1->NO1_FCHFAT=="S")' ,'BR_VERMELHO'},;
	                     {'(NO1->NO1_FECHAD=="S".Or.NO1->NO1_FECHAD=="S").And.(NO1->NO1_FCHFIN=="S".Or.NO1->NO1_FCHFIN=="S").And.(NO1->NO1_FCHFAT=="S".Or.NO1->NO1_FCHFAT=="S")' ,'BR_PRETO'   } ;
	                    }

	Private cCadastro := STR0001 //"Compromisso Futuro"
	Private aRotina   := MenuDef(1)

	dbSelectArea('NO1')
	dbSetOrder(1)

	mBrowse(06, 01, 22, 75, 'NO1', Nil, Nil, Nil, Nil, Nil, aCores)

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRA100A บ Autor ณ Ricardo Tomasi     บ Data ณ  21/07/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Tela de visualiza็ใo do compromisso futuro. Traz informaco-บฑฑ
ฑฑบ          ณ es sobre Fixa็๕es - Financeiro - Faturamento               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function AGRA100A(cAlias, nReg, nOpc)
	Local aSize    := MsAdvSize(.T.)
	Local aObjects := {{100,100,.t.,.t.},{100,100,.t.,.t.},{100,030,.t.,.t.}}
	Local aInfo    := {aSize[1],aSize[2],aSize[3],aSize[4],5,5}
	Local aPosObj  := MsObjSize(aInfo,aObjects,.T.)
	Local nOpcA    := 0
	Local nX       := 0
	Local nC       := 0
	Local aTitulo  := {"Fixa็๕es","Financeiro","Faturamento"}
	Local aRefere  := {'Pasta1'  ,'Pasta2'    ,'Pasta3'     }
	Local aCampos  := Array(0)
	Local cArqSD2  := ''
	Local nIndSD2  := 0
	Local aStruct  := {}

	Private aGets    := Array(0)
	Private aTela    := Array(0,0)
	Private aHeadFX  := Array(0)
	Private aColsFX  := Array(0)
	Private aHeadFN  := Array(0)
	Private aColsFN  := Array(0)
	Private aHeadFT  := Array(0)
	Private aColsFT  := Array(0)

	Private cRoda11  := ''
	Private cRoda12  := ''
	Private cRoda21  := ''
	Private cRoda22  := ''

	Private nQtdAFix := 0
	Private nQtdFixa := 0
	Private nValAFix := 0
	Private nValFixa := 0

	Private nTotRece := 0
	Private nTotARec := 0
	Private nTotAdts := 0
	Private nTotJuro := 0

	Private nTotEntr := 0
	Private nTotAEnt := 0

	Private oDlg
	Private oEnch
	Private oSay1
	Private oSay2
	Private oSay3
	Private oSay4
	Private oGetDFX
	Private oGetDFN
	Private oGatDFT

	//_______________________________________________________________________FX
	aStruct := NO2->(DBSTRUCT()) //http://tdn.totvs.com/x/tYVsAQ

	For nX := 1 To Len(aStruct)
		If X3USADO(aStruct[nX,1]) .AND. cNivel >= AGRRETNIV(aStruct[nX,1])
			aAdd(aHeadFX,{AllTrim(RetTitle(aStruct[nX,1])), aStruct[nX,1], X3PICTURE(aStruct[nX,1]), aStruct[nX,3], aStruct[nX,4], X3VALID(aStruct[nX,1]), X3USADO(aStruct[nX,1]), aStruct[nX,2], "NO2", AGRRETCTXT("NO2", aStruct[nX,1]) })
		EndIf
	Next nX

	dbSelectArea('NO2')
	dbSetOrder(1)
	dbSeek(xFilial('NO2')+NO1->NO1_NUMERO)
	nC := 0
	While .Not. Eof() .And. NO2->NO2_FILIAL==cFilial .And. NO2->NO2_NUMCP==NO1->NO1_NUMERO
		nC++
		aAdd(aColsFX, Array(Len(aHeadFX)+1))
		For nX := 1 to Len(aHeadFX)
			aColsFX[nC,nX] := FieldGet(FieldPos(aHeadFX[nX,2]))
		Next
		aColsFX[nC,Len(aHeadFX)+1] := .f.

		If Empty(NO2->NO2_DATPRC).Or.Empty(NO2->NO2_DATPRM).Or.Empty(NO2->NO2_DATDES).Or.Empty(NO2->NO2_DATARO)
			nQtdAFix += NO2->NO2_QUANT
			nValAFix += NO2->NO2_TOTAL
		Else
			nQtdFixa += NO2->NO2_QUANT
			nValFixa += NO2->NO2_TOTAL
		EndIf

		dbSkip()
	EndDo

	//_______________________________________________________________________FN
	aStruct := NO3->(DBSTRUCT()) //http://tdn.totvs.com/x/tYVsAQ

	For nX := 1 To Len(aStruct)
		If X3USADO(aStruct[nX,1]) .AND. cNivel >= AGRRETNIV(aStruct[nX,1])
			aAdd(aHeadFN,{AllTrim(RetTitle(aStruct[nX,1])), aStruct[nX,1], X3PICTURE(aStruct[nX,1]), aStruct[nX,3], aStruct[nX,4], X3VALID(aStruct[nX,1]), X3USADO(aStruct[nX,1]), aStruct[nX,2], "NO3", AGRRETCTXT("NO3", aStruct[nX,1]) })
		EndIf
	Next nX

	dbSelectArea('NO3')
	dbSetOrder(2)
	dbSeek(xFilial('NO3')+NO1->NO1_NUMERO)
	nC := 0
	While .Not. Eof() .And. NO3->NO3_FILIAL==cFilial .And. NO3->NO3_NUMCP==NO1->NO1_NUMERO
		nC++
		aAdd(aColsFN, Array(Len(aHeadFN)+1))
		For nX := 1 to Len(aHeadFN)
			aColsFN[nC,nX] := FieldGet(FieldPos(aHeadFN[nX,2]))
		Next
		aColsFN[nC,Len(aHeadFN)+1] := .f.

		If 'PR' $ NO3->NO3_TIPO
			nTotARec += NO3->NO3_VALOR
		Else
			nTotARec -= NO3->NO3_VALOR
		EndIf
		If 'RA' $ NO3->NO3_TIPO
			nTotRece += NO3->NO3_VALOR
			nTotAdts += NO3->NO3_VALOR
		EndIf
		If 'JR' $ NO3->NO3_TIPO
			nTotJuro += NO3->NO3_VALOR
		EndIf

		dbSelectArea('SE1')
		dbSetOrder(2) //E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
		If NO1->NO1_FCHFIN=='S'
			If dbSeek(xFilial('SE1')+NO1->NO1_CODCLI+NO1->NO1_LOJCLI+NO3->NO3_PREFIX+NO3->NO3_NUM+' '+'DP ')
				nTotRece := SE1->E1_VALOR-SE1->E1_SALDO
				nTotARec := SE1->E1_SALDO
			EndIf
		EndIf

		dbSelectArea('NO3')
		dbSkip()
	EndDo

	//_______________________________________________________________________FT
	aAdd(aCampos, 'D2_SERIE'  ); aAdd(aCampos, 'D2_DOC'  ); aAdd(aCampos, 'D2_ITEM'  )
	aAdd(aCampos, 'D2_EMISSAO'); aAdd(aCampos, 'D2_QUANT'); aAdd(aCampos, 'D2_UM'    )
	aAdd(aCampos, 'D2_PRCVEN' ); aAdd(aCampos, 'D2_TOTAL'); aAdd(aCampos, 'D2_CODROM')

	For nX := 1 To Len(aCampos)
		If X3USADO(aCampos[nX])
			aAdd(aHeadFT,{AllTrim(RetTitle(aCampos[nX])), aCampos[nX], X3PICTURE(aCampos[nX]), TamSx3(aCampos[nX])[1], TamSx3(aCampos[nX])[2], X3VALID(aCampos[nX]), X3USADO(aCampos[nX]), TamSx3(aCampos[nX])[3], "SD2", AGRRETCTXT("SD2", aCampos[nX]) })
		EndIf
	Next nX

	dbSelectArea('SD2')
	cArqSD2 := CriaTrab(Nil,.f.)
	IndRegua('SD2', cArqSD2, 'D2_FILIAL+D2_SERIE+D2_DOC+D2_ITEM',, 'D2_FILIAL=="'+cFilial+'" .And. D2_NUMCP=="'+NO1->NO1_NUMERO+'"', STR0009)
	nIndSD2 := RetIndex('SD2')+1
	#IFNDEF TOP
	dbSetIndex(cIndSD2+OrdBagExT())
	#ENDIF
	dbSetOrder(nIndSD2)
	dbGotop()
	nC := 0
	nTotAEnt := NO1->NO1_QTDPRO
	While .Not. Eof()
		nC++
		aAdd(aColsFT, Array(Len(aHeadFT)+1))
		For nX := 1 to Len(aHeadFT)
			aColsFT[nC,nX] := FieldGet(FieldPos(aHeadFT[nX,2]))
		Next
		aColsFT[nC,Len(aHeadFT)+1] := .f.

		nTotEntr += AGRX001(SD2->D2_UM,NO1->NO1_UM1PRO,SD2->D2_QUANT)
		nTotAEnt -= AGRX001(SD2->D2_UM,NO1->NO1_UM1PRO,SD2->D2_QUANT)

		dbSkip()
	EndDo

	RegToMemory('NO1',.F.)

	Define MSDialog oDlg Title cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd Pixel

	oEnch   := MsMGet():New('NO1',nReg,2,,,,,aPosObj[1],,3,,,,oDlg,,.t.)
	oFolder := TFolder():New(aPosObj[2,1],aPosObj[2,2],aTitulo,aRefere,oDlg,,,,.t.,.f.,aPosObj[2,4],aPosObj[2,3]/2)
	oFolder:bSetGet := {|| fAtualVl(oFolder:nOption) }
	oFolder:bChange := {|| fAtualVl(oFolder:nOption) }

	oGetDFX := MsNewGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],0,,,,,,9999,,,,oFolder:aDialogs[1],aHeadFX,aColsFX)
	oGetDFX:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	oGetDFN := MsNewGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],0,,,,,,9999,,,,oFolder:aDialogs[2],aHeadFN,aColsFN)
	oGetDFN:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	oGetDFT := MsNewGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],0,,,,,,9999,,,,oFolder:aDialogs[3],aHeadFT,aColsFT)
	oGetDFT:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	oFont := TFont():New( 'Courier New', 10)
	oSay1 := TSay():New(aPosObj[3,1]+15,aPosObj[3,2]    , {|| cRoda11 },oDlg,,oFont,,,,.t.,CLR_BLUE,,200,21)
	oSay2 := TSay():New(aPosObj[3,1]+30,aPosObj[3,2]    , {|| cRoda21 },oDlg,,oFont,,,,.t.,CLR_BLUE,,200,21)
	oSay3 := TSay():New(aPosObj[3,1]+15,aPosObj[3,2]+210, {|| cRoda12 },oDlg,,oFont,,,,.t.,CLR_BLUE,,200,21)
	oSay4 := TSay():New(aPosObj[3,1]+30,aPosObj[3,2]+210, {|| cRoda22 },oDlg,,oFont,,,,.t.,CLR_BLUE,,200,21)

	Activate MsDialog oDlg On Init EnchoiceBar(oDlg, {|| nOpcA := 1, oDlg:End() } , {|| nOpcA := 0, oDlg:End() })

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRA100B บ Autor ณ Ricardo Tomasi     บ Data ณ  21/07/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina auxilial para montagem da tela de cadastro.         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function AGRA100B(cAlias, nReg, nOpc)
	Local aSize    := MsAdvSize()
	Local aObjects := {{100,100,.t.,.t.},{100,100,.t.,.t.},{100,015,.t.,.f.}}
	Local aInfo    := {aSize[1],aSize[2],aSize[3],aSize[4],3,3}
	Local aPosObj  := MsObjSize(aInfo,aObjects)
	Local nOpcX    := aRotina[nOpc,4]
	Local nOpcA    := 0

	Private aGets  := Array(0)
	Private aTela  := Array(0,0)
	Private oDlg
	Private oEnch

	RegToMemory('NO1',(nOpcX==3))

	Define MSDialog oDlg Title cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd Pixel

	oEnch := MsMGet():New('NO1',nReg,nOpcX,,,,,aPosObj[1],,3,,,,oDlg,,.t.)
	oEnch:oBox:Align := CONTROL_ALIGN_ALLCLIENT

	Activate MsDialog oDlg On Init EnchoiceBar(oDlg, {|| nOpcA:=1, IIf(Obrigatorio(aGets,aTela), oDlg:End(), nOpcA:=0) } , {|| nOpcA:=0, oDlg:End() })

	If nOpcA==1
		If nOpcX==3; fInclui(); EndIf
		If nOpcX==5; fExclui(); EndIf
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
ฑฑบPrograma  ณ AGRA100C บ Autor ณ Ricardo Tomasi     บ Data ณ  21/07/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina auxilial para montagem da tela de cadastro.         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function AGRA100C(cAlias, nReg, nOpc)
	Local aSize    := MsAdvSize()
	Local aObjects := {{100,100,.t.,.t.},{100,100,.t.,.t.},{100,040,.t.,.f.}}
	Local aInfo    := {aSize[1],aSize[2],aSize[3],aSize[4],9,9}
	Local aPosObj  := MsObjSize(aInfo,aObjects)
	Local nOpcX    := aRotina[nOpc,4]
	Local nOpcA    := 0
	Local nX       := 0
	Local nC       := 0
	Local aStruct  := {}
	Local aHeadFX  := {}

	Private aGets    := Array(0)
	Private aTela    := Array(0,0)
	Private aHeader  := Array(0)
	Private aCols    := Array(0)
	Private oDlg
	Private oEnch
	Private oGetD
	Private oSay1
	Private oSay2
	Private oSay3
	Private oSay4
	Private nTotPrev := 0
	Private nQtdAFix := 0
	Private nQtdFixa := 0

	If NO1->NO1_FCHFIN=='S'
		nOpc  := 2
		nOpcX := 2
	EndIf

	//_______________________________________________________________________FX
	aStruct := NO2->(DBSTRUCT()) //http://tdn.totvs.com/x/tYVsAQ

	For nX := 1 To Len(aStruct)
		If X3USADO(aStruct[nX,1]) .AND. cNivel >= AGRRETNIV(aStruct[nX,1])
			aAdd(aHeadFX,{AllTrim(RetTitle(aStruct[nX,1])), aStruct[nX,1], X3PICTURE(aStruct[nX,1]), aStruct[nX,3], aStruct[nX,4], X3VALID(aStruct[nX,1]), X3USADO(aStruct[nX,1]), aStruct[nX,2], "NO2", AGRRETCTXT("NO2", aStruct[nX,1]) })
		EndIf
	Next nX

	dbSelectArea('NO2')
	dbSetOrder(1)
	dbSeek(xFilial('NO2')+NO1->NO1_NUMERO)
	While .Not. Eof() .And. NO2->NO2_FILIAL==cFilial .And. NO2->NO2_NUMCP==NO1->NO1_NUMERO
		nC++
		aAdd(aCols, Array(Len(aHeader)+1))
		For nX := 1 to Len(aHeader)
			aCols[nC,nX] := FieldGet(FieldPos(aHeader[nX,2]))
		Next
		aCols[nC,Len(aHeader)+1] := .f.

		nTotPrev += NO2->NO2_TOTAL
		If Empty(NO2->NO2_DATPRC).Or.Empty(NO2->NO2_DATPRM).Or.Empty(NO2->NO2_DATDES).Or.Empty(NO2->NO2_DATARO)
			nQtdAFix += NO2->NO2_QUANT
		Else
			nQtdFixa += NO2->NO2_QUANT
		EndIf

		dbSkip()
	EndDo
	If nC == 0
		aAdd(aCols, Array(Len(aHeader)+1))
		For nX := 1 to Len(aHeader)
			aCols[1,nX] := CriaVar(aHeader[nX,2])
			If 'NO2_SEQ' $ aHeader[nX,2]
				aCOLS[1][nX] := Soma1(Replicate('0',aHeader[nX,4]))
			EndIf
		Next
		aCols[1,Len(aHeader)+1] := .f.
	EndIf

	RegToMemory('NO1',.F.)

	Define MSDialog oDlg Title cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd Pixel

	oEnch := MsMGet():New('NO1',nReg,2,,,,,aPosObj[1],,3,,,,oDlg,,.t.)
	oGetD := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcX,,'AGRA100H','+NO2_SEQ',.t.,,Len(aHeader),,,'AGRA100G',,,,oDlg)
	oGetD:oBrowse:SetFocus()

	oFont := TFont():New( 'Courier New', 10)
	oSay1 := TSay():New(aPosObj[3,1]+15,aPosObj[3,2]    , {|| 'Quantidade A Fixar: '+Transform(nQtdAFix,'@E 999,999,999.99')},oDlg,,oFont,,,,.t.,CLR_BLUE,,200,21)
	oSay2 := TSay():New(aPosObj[3,1]+30,aPosObj[3,2]    , {|| 'Quantidade Fixada:  '+Transform(nQtdFixa,'@E 999,999,999.99')},oDlg,,oFont,,,,.t.,CLR_BLUE,,200,21)
	oSay3 := TSay():New(aPosObj[3,1]+15,aPosObj[3,2]+250, {|| 'Valor : '+GetMV('MV_SIMB'+AllTrim(Str(NO1->NO1_MOEDA)))+' '+Transform(nTotPrev,'@E 999,999,999.99')},oDlg,,oFont,,,,.t.,CLR_RED,,200,21)
	oSay4 := TSay():New(aPosObj[3,1]+30,aPosObj[3,2]+250, {|| '' },oDlg,,oFont,,,,.t.,CLR_BLUE,,200,21)

	Activate MsDialog oDlg On Init EnchoiceBar(oDlg, {|| nOpcA := 1, IIf(Obrigatorio(aGets,aTela) .And. oGetD:TudoOK(), oDlg:End(), nOpcA := 0) } , {|| nOpcA := 0, oDlg:End() })

	If nOpcA==1
		fFixacao()
		fAtualPR()
	EndIf

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRA100D บ Autor ณ Ricardo Tomasi     บ Data ณ  21/07/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina auxilial para montagem da tela de cadastro.         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function AGRA100D(cAlias, nReg, nOpc)

	Private aRotina   := MenuDef(2)


	dbSelectArea('NO3')
	dbSetOrder(2)

	FilBrowse('NO3',{},'NO3_FILIAL==xFilial("NO3").And.NO3_NUMCP==NO1->NO1_NUMERO')

	mBrowse(06, 01, 22, 75, 'NO3')

	dbClearFilter()

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRA100G บ Autor ณ Ricardo Tomasi     บ Data ณ  21/07/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina auxilial para gera็ใo das linhas do GetDados.       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function AGRA100G()
	Local lRetorno  := .t.
	Local nX        := 0

	Local nP_QUANT  := aScan(aHeader, { |x| Alltrim(x[2]) == 'NO2_QUANT'  })
	Local nP_MOEDA  := aScan(aHeader, { |x| Alltrim(x[2]) == 'NO2_MOEDA'  })
	Local nP_UM     := aScan(aHeader, { |x| Alltrim(x[2]) == 'NO2_UM'     })
	Local nP_TXMOED := aScan(aHeader, { |x| Alltrim(x[2]) == 'NO2_TXMOED' })
	Local nP_VLRPRC := aScan(aHeader, { |x| Alltrim(x[2]) == 'NO2_VLRPRC' })
	Local nP_DATPRC := aScan(aHeader, { |x| Alltrim(x[2]) == 'NO2_DATPRC' })
	Local nP_PREMIO := aScan(aHeader, { |x| Alltrim(x[2]) == 'NO2_PREMIO' })
	Local nP_DATPRM := aScan(aHeader, { |x| Alltrim(x[2]) == 'NO2_DATPRM' })
	Local nP_DESPSA := aScan(aHeader, { |x| Alltrim(x[2]) == 'NO2_DESPSA' })
	Local nP_DATDES := aScan(aHeader, { |x| Alltrim(x[2]) == 'NO2_DATDES' })
	Local nP_AROLAG := aScan(aHeader, { |x| Alltrim(x[2]) == 'NO2_AROLAG' })
	Local nP_DATARO := aScan(aHeader, { |x| Alltrim(x[2]) == 'NO2_DATARO' })
	Local nP_TOTAL  := aScan(aHeader, { |x| Alltrim(x[2]) == 'NO2_TOTAL'  })
	Local nP_TOTALX := aScan(aHeader, { |x| Alltrim(x[2]) == 'NO2_TOTALX' })

	Local nQuant    := aCols[n,nP_QUANT ]
	Local nMoeda    := aCols[n,nP_MOEDA ]
	Local cUM       := aCols[n,nP_UM    ]
	Local nTxMoed   := aCols[n,nP_TXMOED]
	Local nVlrPrc   := aCols[n,nP_VLRPRC]
	Local nPremio   := aCols[n,nP_PREMIO]
	Local nDespsa   := aCols[n,nP_DESPSA]
	Local nArolag   := aCols[n,nP_AROLAG]

	Do Case
		Case 'NO2_QUANT'  $ __READVAR
		nQuant := &__READVAR
		aCols[n,nP_QUANT] := nQuant
		Case 'NO2_UM'     $ __READVAR
		cUM    := &__READVAR
		aCols[n,nP_UM] := cUM
		Case 'NO2_MOEDA'  $ __READVAR
		nMoeda := &__READVAR
		aCols[n,nP_MOEDA] := nMoeda
		If nMoeda==M->NO1_MOEDA
			aCols[n,nP_TXMOED] := 1
		Else
			aCols[n,nP_TXMOED] := RecMoeda(dDataBase,nMoeda)
		EndIf
		Case 'NO2_TXMOED' $ __READVAR
		nTxMoed := &__READVAR
		If nMoeda==M->NO1_MOEDA
			nTxMoed := 1
			&__READVAR := nTxMoed
		EndIf
		aCols[n,nP_TXMOED] := nTxMoed
		Case 'NO2_VLRPRC' $ __READVAR
		nVlrPrc := &__READVAR
		aCols[n,nP_VLRPRC] := nVlrPrc
		Case 'NO2_PREMIO' $ __READVAR
		nPremio := &__READVAR
		aCols[n,nP_PREMIO] := nPremio
		Case 'NO2_DESPSA' $ __READVAR
		nDespsa := &__READVAR
		aCols[n,nP_DESPSA] := nDespsa
		Case 'NO2_AROLAG' $ __READVAR
		nArolag := &__READVAR
		aCols[n,nP_AROLAG] := nArolag
	EndCase

	aCols[n,nP_TOTAL] := (AGRX001(M->NO1_UM1PRO,cUM,nQuant)*(nVlrPrc+nPremio-nDespsa+nArolag))
	aCols[n,nP_TOTALX] := (AGRX001(M->NO1_UM1PRO,cUM,nQuant)*(nTxMoed*(nVlrPrc+nPremio-nDespsa+nArolag)))

	nTotPrev := 0
	nQtdAFix := 0
	nQtdFixa := 0
	For nX := 1 To Len(aCols)
		nTotPrev += aCols[nX,nP_TOTAL]
		If Empty(aCols[nX,nP_DATPRC]).Or.Empty(aCols[nX,nP_DATPRM]).Or.Empty(aCols[nX,nP_DATDES]).Or.Empty(aCols[nX,nP_DATARO])
			nQtdAFix += aCols[nX,nP_QUANT]
		Else
			nQtdFixa += aCols[nX,nP_QUANT]
		EndIf
	Next nX

	oSay1:Refresh()
	oSay2:Refresh()
	oSay3:Refresh()
	oSay4:Refresh()

Return(lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRA100H บ Autor ณ Ricardo Tomasi     บ Data ณ  21/07/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina auxilial para gera็ใo das linhas do GetDados.       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function AGRA100H()
	Local lRetorno  := .t.
	Local nX        := 0
	Local nTotal    := 0
	Local nP_QUANT  := aScan(aHeader, { |x| Alltrim(x[2]) == 'NO2_QUANT' })

	For nX := 1 To Len(aCols)
		If !(aCols[nX,Len(aHeader)+1])
			nTotal += aCols[nX,nP_QUANT]
		EndIf
	Next nX

	If nTotal <> M->NO1_QTDPRO
		ApMsgAlert( STR0008 ) //"A soma das quantidades deve ser igual a quantidade total do compromisso."
		lRetorno := .f.
	EndIf

Return(lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRA100I บ Autor ณ Ricardo Tomasi     บ Data ณ  21/07/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function AGRA100I()
	Local aAreaAnt  := GetArea()



	RestArea(aAreaAnt)
Return(lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRA100J บ Autor ณ Ricardo Tomasi     บ Data ณ  21/07/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina para inclusใo de Recebimentos Antecipados.          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function AGRA100J(cAlias, nReg, nOpc)
	Local aSize    := MsAdvSize()
	Local aObjects := {{100,100,.t.,.t.},{100,100,.t.,.t.}}
	Local aInfo    := {aSize[1],aSize[2],aSize[3],aSize[4],5,5}
	Local aPosObj  := MsObjSize(aInfo,aObjects)
	Local nOpcX    := aRotina[nOpc,4]
	Local nOpcA    := 0
	Local nY       := 0
	Local cParcela := '0'
	Local aFina040 := Array(0)
	Local aAreaNO3 := Array(0)

	Private aGets  := Array(0)
	Private aTela  := Array(0,0)
	Private oDlg
	Private oEnch
	Private lMsErroAuto := .f.

	If NO1->NO1_FCHFIN == 'S'
		Return()
	EndIf

	If nOpcX==5
		If NO3->NO3_TIPO <> 'RA '
			ApMsgAlert('Este titulo nใo se refere a um Recebimento Antecipado.','Tipo do Titulo')
			Return()
		Else
			aAreaNO3 := GetArea()
			If dbSeek(xFilial('NO3')+NO3->NO3_NUMCP+'04'+'JR-'+NO3->NO3_PARCEL)
				ApMsgAlert('Jแ existe parcela de juros para este Adiantamento.','Impossivel Excluir')
				Return()
			Else
				RestArea(aAreaNO3)
			EndIf
		EndIf
	EndIf

	If nOpcX==3
		aAreaNO3 := GetArea()
		dbSelectArea('NO3')
		dbSeek(xFilial('NO3')+NO1->NO1_NUMERO)
		While .Not. Eof() .And. xFilial('NO3')==cFilial .And. NO3->NO3_NUMCP==NO1->NO1_NUMERO
			If NO3->NO3_TIPO $ 'RA '
				cParcela := NO3->NO3_PARCEL
			EndIf
			dbSkip()
		EndDo
		cParcela := Soma1(cParcela,1)
		RestArea(aAreaNO3)
	EndIf

	RegToMemory('NO3', (nOpcX==3))

	If nOpcX==3
		M->NO3_PREFIX := 'CP '
		M->NO3_NUM    := NO1->NO1_NUMERO
		M->NO3_PARCEL := cParcela
		M->NO3_TIPO   := 'RA '
		M->NO3_DATVEN := NO1->NO1_DATVEN
	EndIf

	Define MSDialog oDlg Title cCadastro From aSize[7],0 TO aSize[6],aSize[5] of oMainWnd Pixel

	oEnch := MsMGet():New('NO3',nReg,nOpc,,,,,aPosObj[1],,3,,,,oDlg,,.t.)
	oEnch:oBox:Align := CONTROL_ALIGN_ALLCLIENT

	Activate MsDialog oDlg On Init EnchoiceBar(oDlg, {|| nOpcA:=1, IIf(AGRA100M(nOpcX), oDlg:End(), nOpcA:=0) } , {|| nOpcA:=0, oDlg:End() }) Centered

	If nOpcA==1

		If nOpcX==3
			If RecLock('NO3',.t.)
				For nY := 1 To FCount()
					&(FieldName(nY)) := &('M->'+FieldName(nY))
				Next nY
				NO3->NO3_FILIAL := xFilial('NO3')
				NO3->NO3_NUMCP  := NO1->NO1_NUMERO
				NO3->NO3_SEQ    := '04'
				msUnLock()
			EndIf
			If __lSX8
				ConfirmSX8()
			EndIf

			aAdd(aFina040,  {'E1_PREFIXO' , NO3->NO3_PREFIX, Nil})
			aAdd(aFina040,  {'E1_NUM'     , NO3->NO3_NUM   , Nil})
			aAdd(aFina040,  {'E1_PARCELA' , NO3->NO3_PARCEL, Nil})
			aAdd(aFina040,  {'E1_TIPO'    , NO3->NO3_TIPO  , Nil})

			aAdd(aFina040,  {'CBCOAUTO'   , NO3->NO3_CODBCO, Nil})
			aAdd(aFina040,  {'CAGEAUTO'   , NO3->NO3_CODAGE, Nil})
			aAdd(aFina040,  {'CCTAAUTO'   , NO3->NO3_CODCTA, Nil})

			aAdd(aFina040,  {'E1_NATUREZ' , NO3->NO3_NATURE, Nil})
			aAdd(aFina040,  {'E1_CLIENTE' , NO1->NO1_CODCLI, Nil})
			aAdd(aFina040,  {'E1_LOJA'    , NO1->NO1_LOJCLI, Nil})
			aAdd(aFina040,  {'E1_EMISSAO' , NO3->NO3_DATEMI, Nil})
			aAdd(aFina040,  {'E1_VENCTO'  , NO3->NO3_DATVEN, Nil})
			aAdd(aFina040,  {'E1_VALOR'   , NO3->NO3_VALOR , Nil})
			aAdd(aFina040,  {'E1_MOEDA'   , NO3->NO3_MOEDA , Nil})
			aAdd(aFina040,  {'E1_VLCRUZ'  , NO3->NO3_VLCRUZ, Nil})
			aAdd(aFina040,  {'E1_CREDIT'  , NO1->NO1_CONTAC, Nil})
			aAdd(aFina040,  {'E1_CCC'     , NO1->NO1_CCC   , Nil})
			aAdd(aFina040,  {'E1_ITEMC'   , NO1->NO1_ITEMC , Nil})
			aAdd(aFina040,  {'E1_CLVLCR'  , NO1->NO1_CLVLC , Nil})
			aAdd(aFina040,  {'E1_HIST'    , NO3->NO3_HISTOR, Nil})
			aAdd(aFina040,  {'E1_ORIGEM'  , 'AGRA100'      , Nil})

			MSExecAuto({|x,y| fina040(x,y)},aFina040,3)

			If lMsErroAuto
				MostraErro()
			EndIf

			RecLock('SE1',.F.)
			SE1->E1_PORTADO := NO3->NO3_CODBCO
			SE1->E1_AGEDEP  := NO3->NO3_CODAGE
			SE1->E1_CONTA   := NO3->NO3_CODCTA
			MsUnLock()

			RecLock('SE5',.F.)
			SE5->E5_BANCO   := NO3->NO3_CODBCO
			SE5->E5_AGENCIA := NO3->NO3_CODAGE
			SE5->E5_CONTA   := NO3->NO3_CODCTA
			MsUnLock()

			If ExistBlock('AGRA100RA')
				ExecBlock('AGRA100RA',.F.,.F.)
			EndIf

			aFina040 := Array(0)
		EndIf

		If nOpcX==5
			dbSelectArea('SE1')
			dbSetOrder(2) //E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
			If dbSeek(xFilial('SE1')+NO1->NO1_CODCLI+NO1->NO1_LOJCLI+M->NO3_PREFIX+M->NO3_NUM+M->NO3_PARCEL+M->NO3_TIPO)
				aAdd(aFina040,  {"E1_PREFIXO" , M->NO3_PREFIX  , Nil})
				aAdd(aFina040,  {"E1_NUM"     , M->NO3_NUM     , Nil})
				aAdd(aFina040,  {"E1_PARCELA" , M->NO3_PARCEL  , Nil})
				aAdd(aFina040,  {"E1_TIPO"    , M->NO3_TIPO    , Nil})
				aAdd(aFina040,  {"E1_CLIENTE" , NO1->NO1_CODCLI, Nil})
				aAdd(aFina040,  {"E1_LOJA"    , NO1->NO1_LOJCLI, Nil})

				MSExecAuto({|x,y| fina040(x,y)},aFina040,5)

				If lMsErroAuto
					MostraErro()
				EndIf
				aFina040 := Array(0)
			EndIf
			dbSelectArea('NO3')
			If RecLock('NO3',.f.)
				dbDelete()
				MsUnLock()
			EndIf
		EndIf

		fAtualPR()

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
ฑฑบPrograma  ณ AGRA100K บ Autor ณ Ricardo Tomasi     บ Data ณ  21/07/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina para inclusใo de titulos de Juros sobre RA.         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function AGRA100K(cAlias, nReg, nOpc)
	Local aSize    := MsAdvSize()
	Local aObjects := {{100,100,.t.,.t.},{100,100,.t.,.t.}}
	Local aInfo    := {aSize[1],aSize[2],aSize[3],aSize[4],5,5}
	Local aPosObj  := MsObjSize(aInfo,aObjects)
	Local nOpcX    := aRotina[nOpc,4]
	Local nOpcA    := 0
	Local nY       := 0
	Local aAreaNO3 := GetArea()

	Private aGets  := Array(0)
	Private aTela  := Array(0,0)
	Private oDlg
	Private oEnch
	Private lMsErroAuto := .f.

	If NO1->NO1_FCHFIN == 'S'
		Return()
	EndIf

	Do Case
		Case nOpcX==3
		If NO3->NO3_TIPO == 'RA '
			If dbSeek(xFilial('NO3')+NO3->NO3_NUMCP+'04'+'JR-'+NO3->NO3_PARCEL)
				ApMsgAlert('Jแ existe parcela de juros para este Adiantamento.','Parcela de Juros')
				Return()
			Else
				RestArea(aAreaNO3)
			EndIf
			//Else
			//	Return()
		EndIf
		Case nOpcX==4
		If NO3->NO3_TIPO<>'JR-'
			ApMsgAlert('Este titulo nใo se refere a um Juros sobre Adiantamento.','Tipo do Titulo')
			Return()
		EndIf
		Case nOpcX==5
		If NO3->NO3_TIPO<>'JR-'
			ApMsgAlert('Este titulo nใo se refere a um Juros sobre Adiantamento.','Tipo do Titulo')
			Return()
		EndIf
	EndCase

	RegToMemory('NO3', (nOpcX==3))

	If nOpcX==3         
		If Empty(NO3->NO3_PREFIX) .Or. Empty(NO3->NO3_NUM)  
			ApMsgAlert('Nใo existe parcela de juros para este Compromisso.','Fixa็ใo do Compromisso')
			Return()
		Else
			M->NO3_PREFIX := NO3->NO3_PREFIX
			M->NO3_NUM    := NO3->NO3_NUM
			M->NO3_PARCEL := NO3->NO3_PARCEL
			M->NO3_TIPO   := 'JR-'
			M->NO3_DATVEN := NO3->NO3_DATVEN  
		EndIf
	EndIf

	Define MSDialog oDlg Title cCadastro From 0,0 to 480,640 of oMainWnd Pixel

	oEnch := MsMGet():New('NO3',nReg,nOpc,,,,,aPosObj[1],,3,,,,oDlg,,.t.)
	oEnch:oBox:Align := CONTROL_ALIGN_ALLCLIENT

	Activate MsDialog oDlg On Init EnchoiceBar(oDlg, {|| nOpcA:=1, IIf(Obrigatorio(aGets,aTela), oDlg:End(), nOpcA:=0) } , {|| nOpcA:=0, oDlg:End() }) Centered

	If nOpcA==1
		If nOpcX==3
			If RecLock('NO3',.t.)
				For nY := 1 To FCount()
					&(FieldName(nY)) := &('M->'+FieldName(nY))
				Next nY
				NO3->NO3_FILIAL := xFilial('NO3')
				NO3->NO3_NUMCP  := NO1->NO1_NUMERO
				NO3->NO3_SEQ    := '04'
				msUnLock()
			EndIf
			If __lSX8
				ConfirmSX8()
			EndIf
		EndIf
		If nOpcX==4
			If RecLock('NO3',.f.)
				For nY := 1 To FCount()
					&(FieldName(nY)) := &('M->'+FieldName(nY))
				Next nY
				msUnLock()
			EndIf
		EndIf
		If nOpcX==5
			If RecLock('NO3',.f.)
				dbDelete()
				MsUnLock()
			EndIf
		EndIf
		fAtualPR()
	Else
		If nOpcX==3
			If __lSX8
				RollBackSX8()
			EndIf
		EndIf
	EndIf

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRA100L บAutor  ณ Ricardo Tomasi     บ Data ณ  12/07/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Programa para converter valores em moedas diferentes.      บฑฑ
ฑฑบ          ณ Baseado na taxa do dia ou em taxa pre-fixada.              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AGRA100L()

	If Empty(M->NO3_TXMOED)
		M->NO3_VLCRUZ := xMoeda(M->NO3_VALOR, M->NO3_MOEDA, 1, M->NO3_DATEMI)
	Else
		M->NO3_VLCRUZ := M->NO3_VALOR * M->NO3_TXMOED
	EndIf

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRA100M บAutor  ณ Ricardo Tomasi     บ Data ณ  12/07/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida as telas de inclusใo de Recebimentos Antecipados e  บฑฑ
ฑฑบ          ณ Juros sobre Adiantamentos.                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AGRA100M(nOpcX)
	Local lRetorno := .t.

	lRetorno := Obrigatorio(aGets,aTela)

	If .Not. SA6->(dbSeek(xFilial('SA6')+M->NO3_CODBCO+M->NO3_CODAGE+M->NO3_CODCTA))
		ApMsgAlert('Para Recebimentos Antecipados, sใo obrigat๓rias as informa็๕es de: Banco, Agencia e Conta.','Banco+Agencia+Conta')
		lRetorno := .f.
	EndIf
	If .Not. SED->(dbSeek(xFilial('SED')+M->NO3_NATURE))
		ApMsgAlert('Para Recebimentos Antecipados, ้ obrigat๓ria a informa็ใo de: Natureza.','Natureza')
		lRetorno := .f.
	EndIf

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRA100N บAutor  ณ Ricardo Tomasi     บ Data ณ  12/07/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fechamento financeiro do compromisso. Gera titulo real no  บฑฑ
ฑฑบ          ณ financeiro.                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AGRA100N()
	Local nValDP   := 0
	Local aFina040 := Array(0)

	Private lMsErroAuto := .f.

	If NO1->NO1_FCHFIN == 'S'
		Return()
	EndIf

	dbSelectArea('NO2')
	dbSetOrder(1)
	dbGotop()
	While .Not. Eof() .And. xFilial('NO2')==cFilial .And. NO2->NO2_NUMCP==NO1->NO1_NUMERO
		If Empty(NO2->NO2_DATPRC).Or.Empty(NO2->NO2_DATPRM).Or.Empty(NO2->NO2_DATDES).Or.Empty(NO2->NO2_DATARO)
			Return()
		EndIf
		dbSkip()
	EndDo

	dbSelectArea('NO3')
	dbGotop()
	While .Not. Eof() .And. xFilial('NO3')==cFilial .And. NO3->NO3_NUMCP==NO1->NO1_NUMERO
		If NO3->NO3_TIPO $ 'PR '
			nValDP += NO3->NO3_VALOR
		EndIf
		If NO3->NO3_TIPO $ 'FU-#FE-#JR-'
			nValDP -= NO3->NO3_VALOR
		EndIf
		dbSkip()
	EndDo

	//Exclui titulo provisorio se existir.
	dbSelectArea('SE1')
	dbSetOrder(2) //E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	If dbSeek(xFilial('SE1')+NO1->NO1_CODCLI+NO1->NO1_LOJCLI+'CP '+NO1->NO1_NUMERO+' '+'PR ')
		aAdd(aFina040,  {"E1_PREFIXO" , 'CP '          , Nil})
		aAdd(aFina040,  {"E1_NUM"     , NO1->NO1_NUMERO, Nil})
		aAdd(aFina040,  {"E1_PARCELA" , ' '            , Nil})
		aAdd(aFina040,  {"E1_TIPO"    , 'PR '          , Nil})
		aAdd(aFina040,  {"E1_CLIENTE" , NO1->NO1_CODCLI, Nil})
		aAdd(aFina040,  {"E1_LOJA"    , NO1->NO1_LOJCLI, Nil})

		MSExecAuto({|x,y| fina040(x,y)},aFina040,5)

		If lMsErroAuto
			MostraErro()
		EndIf
		aFina040 := Array(0)
	EndIf

	//Gera titulo no financeiro
	aAdd(aFina040,  {"E1_PREFIXO" , 'CP '          , Nil})
	aAdd(aFina040,  {"E1_NUM"     , NO1->NO1_NUMERO, Nil})
	aAdd(aFina040,  {"E1_PARCELA" , ' '            , Nil})
	aAdd(aFina040,  {"E1_TIPO"    , 'DP '          , Nil})
	aAdd(aFina040,  {"E1_NATUREZ" , NO1->NO1_NATURE, Nil})
	aAdd(aFina040,  {"E1_CLIENTE" , NO1->NO1_CODCLI, Nil})
	aAdd(aFina040,  {"E1_LOJA"    , NO1->NO1_LOJCLI, Nil})
	aAdd(aFina040,  {"E1_EMISSAO" , NO1->NO1_DATEMI, Nil})
	aAdd(aFina040,  {"E1_VENCTO"  , NO1->NO1_DATVEN, Nil})
	aAdd(aFina040,  {"E1_VALOR"   , nValDP         , Nil})
	aAdd(aFina040,  {"E1_MOEDA"   , NO1->NO1_MOEDA , Nil})
	aAdd(aFina040,  {"E1_VLCRUZ"  , xMoeda(nValDP, NO1->NO1_MOEDA, 1, NO1->NO1_DATEMI), Nil})
	aAdd(aFina040,  {"E1_CREDIT"  , NO1->NO1_CONTAC, Nil})
	aAdd(aFina040,  {"E1_CCC"     , NO1->NO1_CCC   , Nil})
	aAdd(aFina040,  {"E1_ITEMC"   , NO1->NO1_ITEMC , Nil})
	aAdd(aFina040,  {"E1_CLVLCR"  , NO1->NO1_CLVLC , Nil})
	aAdd(aFina040,  {"E1_HIST"    , Substr(NO1->NO1_HISTOR,1,25), Nil})
	aAdd(aFina040,  {"E1_ORIGEM"  , 'AGRA100'      , Nil})

	MSExecAuto({|x,y| fina040(x,y)},aFina040,3)

	If lMsErroAuto
		MostraErro()
	EndIf

	If ExistBlock('AGRA100DP')
		ExecBlock('AGRA100DP',.F.,.F.)
	EndIf

	aFina040 := Array(0)

	dbSelectArea('NO1')
	If RecLock('NO1',.F.)
		NO1->NO1_FCHFIN := 'S'
		If NO1->NO1_FCHFAT == 'S'
			NO1->NO1_FECHAD := 'S'
		EndIf
		MsUnLock()
	EndIf

	ApMsgAlert("Compromisso fechado com sucesso.","Fechamento")

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRA100P บAutor  ณ Ricardo Tomasi     บ Data ณ  12/07/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Re-Abertura do financeiro no compromisso.                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AGRA100P()
	Local aFina040 := Array(0)

	Private lMsErroAuto := .f.

	If NO1->NO1_FCHFIN == 'N'
		Return()
	EndIf

	dbSelectArea('SE1')
	dbSetOrder(2) //E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	If dbSeek(xFilial('SE1')+NO1->NO1_CODCLI+NO1->NO1_LOJCLI+'CP '+NO1->NO1_NUMERO+' '+'DP ')
		aAdd(aFina040,  {"E1_PREFIXO" , 'CP '          , Nil})
		aAdd(aFina040,  {"E1_NUM"     , NO1->NO1_NUMERO, Nil})
		aAdd(aFina040,  {"E1_PARCELA" , ' '            , Nil})
		aAdd(aFina040,  {"E1_TIPO"    , 'DP '          , Nil})
		aAdd(aFina040,  {"E1_CLIENTE" , NO1->NO1_CODCLI, Nil})
		aAdd(aFina040,  {"E1_LOJA"    , NO1->NO1_LOJCLI, Nil})

		MSExecAuto({|x,y| fina040(x,y)},aFina040,5)

		If lMsErroAuto
			MostraErro()
		EndIf
		aFina040 := Array(0)
	EndIf

	dbSelectArea('NO1')
	If RecLock('NO1',.F.)
		NO1->NO1_FCHFIN := 'N'
		NO1->NO1_FECHAD := 'N'
		MsUnLock()
	EndIf

	fAtualPR()

	ApMsgAlert("Compromisso re-aberto com sucesso.","Re-Abertura")

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRA100Q บAutor  ณ Ricardo Tomasi     บ Data ณ  13/07/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Legenda para Aplica็๕es Agrํcolas.                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AGRA100Q()
	Local aLeg := {}

	aAdd(aLeg,{'BR_VERDE'   ,'Aberto'})
	aAdd(aLeg,{'BR_AZUL'    ,'Fechado Financeiro'})
	aAdd(aLeg,{'BR_AMARELO' ,'Fechado Faturamento'})
	aAdd(aLeg,{'BR_VERMELHO','Fechada Financeiro e Faturamento'})
	aAdd(aLeg,{'BR_PRETO'   ,'Fechado'})

	BrwLegenda(cCadastro,"Legenda dos Compromissos", aLeg)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRA100R บAutor  ณ Ricardo Tomasi     บ Data ณ  12/07/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Re-Abertura do financeiro no compromisso.                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AGRA100R()

	If (NO1->NO1_FCHFIN=='N'.Or.NO1->NO1_FCHFIN==' ').Or.(NO1->NO1_FCHFAT=='N'.Or.NO1->NO1_FCHFAT==' ')
		ApMsgAlert("Este compromisso nใo podera ser fechado, pois o financeiro e ou faturamento ainda podem estar abertos.","Fechar Compromisso")
		Return()
	EndIf

	dbSelectArea('NO1')
	If RecLock('NO1',.F.)
		NO1->NO1_FECHAD := 'S'
		MsUnLock()
	EndIf

	ApMsgAlert("Compromisso Fechado com sucesso.","Fecha Compromisso")

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
	Local nY := 0

	Begin Transaction
		dbSelectArea('NO1')
		dbSetOrder(1)
		dbSeek(xFilial('NO1')+M->NO1_NUMERO)
		If RecLock('NO1',.t.)
			For nY := 1 To FCount()
				&('NO1->'+FieldName(nY)) := &('M->'+FieldName(nY))
			Next nY
			NO1->NO1_FILIAL := xFilial('NO1')
			NO1->NO1_SALDO  := NO1->NO1_QTDPRO
			NO1->(MsUnLock())
		EndIf
		If __lSX8
			ConfirmSX8()
		EndIf
	End Transaction

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ fFixacao บ Autor ณ Ricardo Tomasi     บ Data ณ  21/07/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina para grava็ใo dos dados. Gera็ใo de titulos a Pagar.บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function fFixacao()
	Local nX        := 0
	Local nY        := 0
	Local nP_SEQ    := aScan(aHeader, { |x| Alltrim(x[2]) == 'NO2_SEQ' })

	Begin Transaction

		dbSelectArea('NO2')
		dbSetOrder(1)
		For nX := 1 To Len(aCols)
			If !(aCols[nX,Len(aHeader)+1])
				If dbSeek(xFilial('NO2')+NO1->NO1_NUMERO+aCols[nX,nP_SEQ])
					If RecLock('NO2',.f.)
						For nY := 1 To Len(aHeader)
							&('NO2->'+aHeader[nY,2]) := aCols[nX,nY]
						Next nY
						NO2->(MsUnLock())
					EndIf
				Else
					If RecLock('NO2',.t.)
						For nY := 1 To Len(aHeader)
							&('NO2->'+aHeader[nY,2]) := aCols[nX,nY]
						Next nY
						NO2->NO2_FILIAL := xFilial('NO2')
						NO2->NO2_NUMCP  := NO1->NO1_NUMERO
						NO2->(MsUnLock())
					EndIf
				EndIf
			Else
				If dbSeek(xFilial('NO2')+NO1->NO1_NUMERO+aCols[nX,nP_SEQ])
					If RecLock('NO2',.f.)
						dbDelete()
						NO2->(MsUnLock())
					EndIf
				EndIf
			EndIf
		Next nX

	End Transaction

Return()

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

	Local 	aFina040 	:= {}   
	Local 	lExclui		:= .T.
	Private lMsErroAuto := .f.

	Begin Transaction

		If NO1->NO1_FECHAD=='S' .OR. NO1->NO1_FCHFIN == 'S' .Or. NO1->NO1_FCHFAT == 'S'
			ApMsgAlert("Nใo foi possivel excluir este Compromisso.","Nใo Aberto")
			DisarmTransaction()
			Break
		EndIf

		dbSelectArea('NO3')
		dbSetOrder(1)
		If dbSeek(xFilial('NO3')+NO1->NO1_NUMERO)
			While .Not. Eof() .And. NO3->NO3_FILIAL == cFilial .And. NO3->NO3_NUMCP == NO1->NO1_NUMERO   
				DbSelectArea('SE1')
				SE1->(DbSetOrder(2))
				If SE1->(MsSeek(xFilial('SE1')+NO1->NO1_CODCLI+NO1->NO1_LOJCLI+NO3->NO3_PREFIX+NO3->NO3_NUMCP+;
				Padr(Iif(Alltrim(NO3->NO3_TIPO) == 'PR',"",NO3->NO3_PARCEL),TamSx3("E1_PARCELA")[1])+NO3->NO3_TIPO))   

					aAdd(aFina040,  {"E1_PREFIXO" , SE1->E1_PREFIXO, Nil})
					aAdd(aFina040,  {"E1_NUM"     , SE1->E1_NUM		, Nil})
					aAdd(aFina040,  {"E1_PARCELA" , SE1->E1_PARCELA, Nil})
					aAdd(aFina040,  {"E1_TIPO"    , SE1->E1_TIPO   , Nil})
					aAdd(aFina040,  {"E1_CLIENTE" , SE1->E1_CLIENTE, Nil})
					aAdd(aFina040,  {"E1_LOJA"    , SE1->E1_LOJA 	, Nil})

					MSExecAuto({|x,y| fina040(x,y)},aFina040,5)

					If lMsErroAuto
						MostraErro()
						lExclui := .F.
					EndIf
					aFina040 := Array(0)
					SE1->(DbSkip())  
				EndIf
				If lExclui .And. RecLock('NO3',.f.)
					dbDelete()
					NO3->(MsUnLock())
				EndIf    
				DbSelectArea('NO3')
				dbSkip()
			EndDo
		EndIf
		dbSelectArea('NO2')
		dbSetOrder(1)
		If lExclui .And. dbSeek(xFilial('NO2')+NO1->NO1_NUMERO)
			While .Not. Eof() .And. NO2->NO2_FILIAL==cFilial .And. NO2->NO2_NUMCP == NO1->NO1_NUMERO
				If RecLock('NO2',.f.)
					dbDelete()
					NO2->(MsUnLock())
				EndIf
				dbSkip()
			EndDo
		EndIf
		dbSelectArea('NO1')
		dbSetOrder(1)
		If lExclui .And. dbSeek(xFilial('NO1')+M->NO1_NUMERO)
			If RecLock('NO1',.f.)
				dbDelete()
				NO1->(MsUnLock())
			EndIf
		EndIf
	End Transaction

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ fAtualPR บ Autor ณ Ricardo Tomasi     บ Data ณ  21/07/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina para atualiza็ใo/cria็ใo do titulo tipo provisorio  บฑฑ
ฑฑบ          ณ gerado para valor total do contrato menos os adiantamentos.บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ          ADMIN
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function fAtualPR()
	Local nValNO2  := 0
	Local nValNO3  := 0
	Local nValSE1  := 0
	Local nValPR   := 0
	Local lGeraPR  := .t.
	Local nValFU   := 0
	Local nIndFU   := Val(Substr(GetMV('MV_CONTSOC'),IIf(SM0->M0_PRODRUR=='F',1,IIf(SM0->M0_PRODRUR=='L',5,9)),3))
	Local lGeraFU  := .t.
	Local nValFE   := 0
	Local nIndFE   := GetMV('MV_FETHAB')
	Local lGeraFE  := .t.
	Local nValFIN  := 0
	Local aFina040 := Array(0)           
	Local cParcela := '1'

	Private lMsErroAuto := .F.


	dbSelectArea('SE1')
	dbSetOrder(2) //E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	If dbSeek(xFilial('SE1')+NO1->NO1_CODCLI+NO1->NO1_LOJCLI+'CP '+NO1->NO1_NUMERO)
		nValFIN := SE1->E1_VALOR
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCalcula valor total das fixa็๕es.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	dbSelectArea('NO2')
	dbSetOrder(1) //NO2_FILIAL+NO2_NUMCP+NO2_SEQ
	If dbSeek(xFilial('NO2')+NO1->NO1_NUMERO)
		While .Not. Eof() .And. NO2->NO2_FILIAL==cFilial .And. NO2->NO2_NUMCP==NO1->NO1_NUMERO
			nValNO2 += NO2->NO2_TOTAL
			dbSkip()
		EndDo
		nValPR  += nValNO2
		nValSE1 += nValNO2
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCalcula os Impostos Federais e Estaduais no caso de Mato Grosso.ณ
	//ณ                                                                ณ
	//ณFunRural - Contribui็ใo Social Rural (Federal)                  ณ
	//ณFethab - Fundo Estadual para Transporte e Habita็ใo (Estadual)  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	dbSelectArea('SB1')
	dbSetOrder(1)
	If dbSeek(xFilial('SB1')+NO1->NO1_CODPRO)
		If SB1->B1_CONTSOC == 'S'
			nValFU += (nValNO2 * nIndFU) / 100
		EndIf
		nValSE1 -= nValFU
		If GetMV('MV_ESTADO') $ 'MT'
			If SB1->B1_FETHAB == 'S'
				nValFE += (AGRX001(NO1->NO1_UM1PRO,'TL',NO1->NO1_QTDPRO) * nIndFE)
				nValFE := xMoeda(nValFE, 1, NO1->NO1_MOEDA, dDataBase)
			EndIf
		EndIf
		nValSE1 -= nValFE
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCalcula valores de abatimento para gera็ใo do tituloณ
	//ณcom valor liquido a receber.                        ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	dbSelectArea('NO3')
	dbSetOrder(2)
	If dbSeek(xFilial('NO3')+NO1->NO1_NUMERO)
		While .Not. Eof() .And. NO3->NO3_FILIAL==cFilial .And. NO3->NO3_NUMCP==NO1->NO1_NUMERO
			Do Case
				Case NO3->NO3_TIPO $ 'PR '
				If nValPR==NO3->NO3_VALOR
					lGeraPR := .f.
				Else
					RecLock('NO3',.F.)
					dbDelete()
					MsUnLock()
				EndIf
				Case NO3->NO3_TIPO $ 'FU-'
				If nValFU==NO3->NO3_VALOR
					lGeraFU := .f.
				Else
					RecLock('NO3',.F.)
					dbDelete()
					MsUnLock()
				EndIf
				Case NO3->NO3_TIPO $ 'FE-'
				If nValFE==NO3->NO3_VALOR
					lGeraFE := .f.
				Else
					RecLock('NO3',.F.)
					dbDelete()
					MsUnLock()
				EndIf
				Case NO3->NO3_TIPO $ 'RA #JR-'
				nValNO3 += NO3->NO3_VALOR
			EndCase
			dbSkip()
		EndDo
		nValSE1 -= nValNO3
	EndIf

	If nValSE1 <> nValFIN
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ6ฟ
		//ณLocaliza e apaga titulo Provisorio no financeiro. ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ6ู
		dbSelectArea('SE1')
		dbSetOrder(2) //E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM
		If dbSeek(xFilial('SE1')+NO1->NO1_CODCLI+NO1->NO1_LOJCLI+'CP '+NO1->NO1_NUMERO)
			AAdd( aFina040, { "E1_NUM"    , NO1->NO1_NUMERO, NIL } )
			AAdd( aFina040, { "E1_PREFIXO", 'CP '			, NIL } )
			AAdd( aFina040, { "E1_NATUREZ", NO1->NO1_NATURE, NIL } )
			AAdd( aFina040, { "E1_TIPO"   , 'PR '			, NIL } )
			AAdd( aFina040, { "E1_CLIENTE", NO1->NO1_CODCLI, NIL } )
			AAdd( aFina040, { "E1_LOJA"   , NO1->NO1_LOJCLI, NIL } )

			MSExecAuto({|x,y| fina040(x,y)},aFina040,5)

			If lMsErroAuto
				MostraErro()
			EndIf
			aFina040 := Array(0)
		EndIf
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ6ฟ
		//ณGera titulo Provisorio no financeiro.             ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ6ู
		If nValSE1 > 0
			aAdd(aFina040,  {"E1_PREFIXO" , 'CP '          , Nil})
			aAdd(aFina040,  {"E1_NUM"     , NO1->NO1_NUMERO, Nil})
			aAdd(aFina040,  {"E1_PARCELA" , ' '            , Nil})
			aAdd(aFina040,  {"E1_TIPO"    , 'PR '          , Nil})
			aAdd(aFina040,  {"E1_NATUREZ" , NO1->NO1_NATURE, Nil})
			aAdd(aFina040,  {"E1_CLIENTE" , NO1->NO1_CODCLI, Nil})
			aAdd(aFina040,  {"E1_LOJA"    , NO1->NO1_LOJCLI, Nil})
			aAdd(aFina040,  {"E1_EMISSAO" , NO1->NO1_DATEMI, Nil})
			aAdd(aFina040,  {"E1_VENCTO"  , NO1->NO1_DATVEN, Nil})
			aAdd(aFina040,  {"E1_VALOR"   , nValSE1        , Nil})
			aAdd(aFina040,  {"E1_MOEDA"   , NO1->NO1_MOEDA , Nil})
			aAdd(aFina040,  {"E1_VLCRUZ"  , xMoeda(nValSE1, NO1->NO1_MOEDA, 1, dDataBase), Nil})
			aAdd(aFina040,  {"E1_CREDIT"  , NO1->NO1_CONTAC, Nil})
			aAdd(aFina040,  {"E1_CCC"     , NO1->NO1_CCC   , Nil})
			aAdd(aFina040,  {"E1_ITEMC"   , NO1->NO1_ITEMC , Nil})
			aAdd(aFina040,  {"E1_CLVLCR"  , NO1->NO1_CLVLC , Nil})
			aAdd(aFina040,  {"E1_HIST"    , Substr(NO1->NO1_HISTOR,1,25), Nil})
			aAdd(aFina040,  {"E1_ORIGEM"  , 'AGRA100'      , Nil})
			MSExecAuto({|x,y| fina040(x,y)},aFina040,3)
			If lMsErroAuto
				MostraErro()
			EndIf
			If ExistBlock('AGRA100PR')
				ExecBlock('AGRA100PR',.F.,.F.)
			EndIf
			aFina040 := Array(0)
		EndIf
	EndIf

	If lGeraPR
		RecLock('NO3',.T.)
		NO3->NO3_FILIAL := xFilial('NO3')
		NO3->NO3_NUMCP  := NO1->NO1_NUMERO
		NO3->NO3_SEQ    := '01'
		NO3->NO3_PREFIX := 'CP '
		NO3->NO3_NUM    := NO1->NO1_NUMERO
		NO3->NO3_PARCEL := cParcela
		NO3->NO3_TIPO   := 'PR '
		NO3->NO3_NATURE := NO1->NO1_NATURE
		NO3->NO3_DATEMI := NO1->NO1_DATEMI
		NO3->NO3_DATVEN := NO1->NO1_DATVEN
		NO3->NO3_VALOR  := nValPR
		NO3->NO3_MOEDA  := NO1->NO1_MOEDA
		NO3->NO3_VLCRUZ := xMoeda(nValPR, NO1->NO1_MOEDA, 1, dDataBase)
		NO3->NO3_TXMOED := RecMoeda(dDataBase, NO1->NO1_MOEDA)
		MsUnLock()
	EndIf

	If nValFU > 0 .And. lGeraFU
		RecLock('NO3',.T.)
		NO3->NO3_FILIAL := xFilial('NO3')
		NO3->NO3_NUMCP  := NO1->NO1_NUMERO
		NO3->NO3_SEQ    := '02'
		NO3->NO3_PREFIX := 'CP '
		NO3->NO3_NUM    := NO1->NO1_NUMERO
		NO3->NO3_PARCEL := cParcela
		NO3->NO3_TIPO   := 'FU-'
		NO3->NO3_NATURE := NO1->NO1_NATURE
		NO3->NO3_DATEMI := NO1->NO1_DATEMI
		NO3->NO3_DATVEN := NO1->NO1_DATVEN
		NO3->NO3_VALOR  := nValFU
		NO3->NO3_MOEDA  := NO1->NO1_MOEDA
		NO3->NO3_VLCRUZ := xMoeda(nValFU, NO1->NO1_MOEDA, 1, dDataBase)
		NO3->NO3_TXMOED := RecMoeda(dDataBase, NO1->NO1_MOEDA)
		MsUnLock()
	EndIf

	If nValFE > 0 .And. lGeraFE
		RecLock('NO3',.T.)
		NO3->NO3_FILIAL := xFilial('NO3')
		NO3->NO3_NUMCP  := NO1->NO1_NUMERO
		NO3->NO3_SEQ    := '03'
		NO3->NO3_PREFIX := 'CP '
		NO3->NO3_NUM    := NO1->NO1_NUMERO
		NO3->NO3_PARCEL := cParcela
		NO3->NO3_TIPO   := 'FE-'
		NO3->NO3_NATURE := NO1->NO1_NATURE
		NO3->NO3_DATEMI := NO1->NO1_DATEMI
		NO3->NO3_DATVEN := NO1->NO1_DATVEN
		NO3->NO3_VALOR  := nValFE
		NO3->NO3_MOEDA  := NO1->NO1_MOEDA
		NO3->NO3_VLCRUZ := xMoeda(nValFE, NO1->NO1_MOEDA, 1, dDataBase)
		NO3->NO3_TXMOED := RecMoeda(dDataBase, NO1->NO1_MOEDA)
		MsUnLock()
	EndIf

Return()

Static Function fAtualVl(nPasta)

	Do Case
		Case nPasta==1
		cRoda11 := 'Quantidade Fixada:  ' + PadL(Transform(nQtdFixa, '@E 999,999,999.99'),15)
		cRoda12 := 'Valor Fixado:       ' + PadL(Transform(nValFixa, '@E 999,999,999.99'),15)
		cRoda21 := 'Quantidade A Fixar: ' + PadL(Transform(nQtdAFix, '@E 999,999,999.99'),15)
		cRoda22 := 'Valor Nใo Fixado:   ' + PadL(Transform(nValAFix, '@E 999,999,999.99'),15)
		Case nPasta==2
		cRoda11 := 'Total Recebido:     ' + PadL(Transform(nTotRece, '@E 999,999,999.99'),15)
		cRoda12 := 'Total de Adtos:     ' + PadL(Transform(nTotAdts, '@E 999,999,999.99'),15)
		cRoda21 := 'Total A Receber:    ' + PadL(Transform(nTotARec, '@E 999,999,999.99'),15)
		cRoda22 := 'Total de Juros:     ' + PadL(Transform(nTotJuro, '@E 999,999,999.99'),15)
		Case nPasta==3
		cRoda11 := 'Total Entregue:     ' + PadL(Transform(nTotEntr, '@E 999,999,999.99'),15)
		cRoda12 := 'Total A Entregar:   ' + PadL(Transform(nTotAEnt, '@E 999,999,999.99'),15)
		cRoda21 := ''
		cRoda22 := ''
		OtherWise
		cRoda11 := ''
		cRoda12 := ''
		cRoda21 := ''
		cRoda22 := ''
	EndCase

	oSay1:Refresh()
	oSay2:Refresh()
	oSay3:Refresh()
	oSay4:Refresh()

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
Static Function MenuDef(nMnu)

	Local aRotina := {}

	If nMnu == 1
		aRotina:= {;
		{ STR0002   ,"AxPesqui" ,0,1},; //"Pesquisar"
		{ STR0003   ,"AGRA100A" ,0,2},; //"Visualizar"
		{ STR0004   ,"AGRA100B" ,0,3},; //"Incluir"
		{ STR0005   ,"AGRA100C" ,0,4},; //"Fixa็ใo"
		{ STR0006   ,"AGRA100D" ,0,4},; //"Financeiro"
		{ STR0007   ,"AGRA100B" ,0,5},; //"Excluir"
		{ "Incluir Adto" ,'AGRA100J' ,0,3},;
		{ "Excluir Adto" ,'AGRA100J' ,0,5},;
		{ "Incluir Juro" ,'AGRA100K' ,0,3},;
		{ "Alterar Juro" ,'AGRA100K' ,0,4},;
		{ "Excluir Juro" ,'AGRA100K' ,0,5},;
		{ "Fecham. Fin."   ,'AGRA100N' ,0,4},;
		{ "Re-Abertura"  ,'AGRA100P' ,0,4},;
		{ "Fechar"  ,"AGRA100R" ,0,4},; //"Excluir"
		{ "Legenda" ,"AGRA100Q" ,0,6} ;
		}
	Else
		aRotina:= {;
		{ "Pesquisar"    ,'AxPesqui' ,0,1},;
		{ "Visualizar"   ,'AxVisual' ,0,2} ;
		}
	EndIf

Return(aRotina)
