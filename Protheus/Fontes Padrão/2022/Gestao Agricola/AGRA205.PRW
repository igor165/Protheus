#include 'protheus.ch'
#include 'agra205.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRA205  บAutor  ณRicardo Tomasi      บ Data ณ  01/08/2004 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Inclusใo de Retorno de Aplica็๕es.                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function AGRA205()

	Private aCores  := {{'NP1->NP1_STATUS == " "' ,'BR_VERDE'   },; //Verde    = Nใo Aplicada
	                    {'NP1->NP1_STATUS == "P"' ,'BR_AZUL'    },; //Azul     = Aplicada Parcialmente
	                    {'NP1->NP1_STATUS == "F"' ,'BR_VERMELHO'}}  //Vermelho = Fechada

	Private aRotina :=  MenuDef()

	Private cCadastro := STR0001

	dbSelectArea('NP1')
	dbSetOrder(1)

	mBrowse(06, 01, 22, 75, 'NP1', Nil, Nil, Nil, Nil, Nil, aCores)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRA205A บAutor  ณRicardo Tomasi      บ Data ณ  01/08/2004 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtualiza็ใo da Aplica็ใo e Itens da Aplica็ใo.              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AGRA205A(cAlias, nReg, nOpc)
	Local aSize      := MsAdvSize()
	Local aArea      := GetArea()
	Local aObjects   := {{100,100,.t.,.t.},{100,100,.t.,.t.},{100,015,.t.,.f.}}
	Local aInfo      := {aSize[1],aSize[2],aSize[3],aSize[4],3,3}
	Local aPosObj    := MsObjSize(aInfo,aObjects)
	Local nOpcao     := aRotina[nOpc,4]
	Local nOpcA      := 0
	Local aCposMO    := {}
	Local aCposEQ    := {}
	Local aCposPD    := {}
	Local aTitulo    := {STR0012,STR0013,STR0014}
	Local aRefere    := {'Pasta1'     ,'Pasta2'      ,'Pasta3'  }
	Local nC         := 0
	Local nX         := 0
	Local aButtons   := Array(0)

	Private aGets    := Array(0)
	Private aTela    := Array(0,0)
	Private aHeader  := Array(0)
	Private aCols    := Array(0)
	Private aClAHMO  := Array(0)
	Private aClACMO  := Array(0)
	Private aClAHEQ  := Array(0)
	Private aClACEQ  := Array(0)
	Private aClAHPD  := Array(0)
	Private aClACPD  := Array(0)
	Private nNMO     := 0
	Private nNEQ     := 0                                    
	Private nNPD     := 0
	Private nOri     := 0
	Private cParame  := GetMV("MV_AGRQTI",,"EQ002MO002PD004")
	Private nPermMO  := Val(Subst(cParame,At("MO",cParame)+2,3))
	Private nPermEQ  := Val(Subst(cParame,At("EQ",cParame)+2,3))
	Private nPermPD  := Val(Subst(cParame,At("PD",cParame)+2,3))
	Private cGetAtv  := 'MO'
	Private oDlg
	Private oEnch
	Private oGetMO
	Private oGetEQ
	Private oGetPD
	Private oFolder

	If NP1->NP1_STATUS == 'F'
		Help('',1,'AGRA205A',,STR0015+Chr(10)+Chr(13)+STR0016,4,1)
		Return()
	EndIf    

	If !Empty(NP2->(FieldPos("NP2_MARCA"))) 
		aAdd(aButtons, { 'BMPPARAM', {|| IIf(oFolder:aDialogs[1]:lVisibleControl,fSelItens('MO'),.f.) }, STR0017, STR0018})
		aAdd(aButtons, { 'BMPPARAM', {|| IIf(oFolder:aDialogs[2]:lVisibleControl,fSelItens('EQ'),.f.) }, STR0019, STR0020})
		aAdd(aButtons, { 'BMPPARAM', {|| IIf(oFolder:aDialogs[3]:lVisibleControl,fSelItens('PD'),.f.) }, STR0021, STR0022})
	EndIf

	nPermMO := IIf(nPermMO < 0 .Or. nPermMO == Nil, 1, nPermMO)
	nPermEQ := IIf(nPermEQ < 0 .Or. nPermEQ == Nil, 1, nPermEQ)
	nPermPD := IIf(nPermPD < 0 .Or. nPermPD == Nil, 1, nPermPD)

	aCposMO := {'NP6_ITEM', 'NP6_MOCOD', 'NP6_MONOM', 'NP6_UM', 'NP6_QTDHAS', 'NP6_QTDUNI', 'NP6_QTDTOT'}
	If ExistBlock('AGRA205MO')
		aCposMO := ExecBlock('AGRA205MO',.F.,.F.,aCposMO)
	EndIf

	aCposEQ := {'NP6_ITEM', 'NP6_EQCOD', 'NP6_EQNOM', 'NP6_UM', 'NP6_QTDHAS', 'NP6_QTDUNI', 'NP6_QTDTOT'}
	If ExistBlock('AGRA205EQ')
		aCposEQ := ExecBlock('AGRA205EQ',.F.,.F.,aCposEQ)
	EndIf

	aCposPD := {'NP6_ITEM', 'NP6_PDCOD', 'NP6_PDNOM', 'NP6_UM', 'NP6_LOCAL', 'NP6_QTDHAS', 'NP6_VAZAO', 'NP6_QTDUNI', 'NP6_QTDTOT', 'NP6_CONTA', 'NP6_CC', 'NP6_CLVL', 'NP6_ITEMCT'}
	If ExistBlock('AGRA205PD')
		aCposPD := ExecBlock('AGRA205PD',.F.,.F.,aCposPD)
	EndIf  

	dbSelectArea('NP5')
	dbSetOrder(3)
	dbSeek(xFilial("NP5")+NP1->NP1_CODIGO)

	//______________________________________________________________________________________________
 	For nX := 1 To Len(aCposMO)
		If X3USADO(aCposMO[nX]) .And. cNivel >= AGRRETNIV(aCposMO[nX])
			aAdd(aClAHMO,{AllTrim(RetTitle(aCposMO[nX])), aCposMO[nX], X3PICTURE(aCposMO[nX]), TamSx3(aCposMO[nX])[1], TamSx3(aCposMO[nX])[1], X3VALID(aCposMO[nX]), X3USADO(aCposMO[nX]), TamSx3(aCposMO[nX])[3], "NP6", AGRRETCTXT("NP6", aCposMO[nX]) })
		Endif
	Next nX

	If nOpcao != 2
		If nPermMO > 0
			aAdd(aClACMO, Array(Len(aClAHMO)+1))
			For nX := 1 to Len(aClAHMO)
				aClACMO[1,nX] := CriaVar(aClAHMO[nX,2])
				If 'NP6_ITEM' == AllTrim(aClAHMO[nX,2])
					aClACMO[1,nX] := '01'
				EndIf
			Next
			aClACMO[1,Len(aClAHMO)+1] := .F.
		EndIf    
	Else
		nC := 0
		dbSelectArea('NP6')
		dbSetOrder(1)
		If dbSeek(xFilial('NP6')+NP5->NP5_CODIGO+'MO')
			nC := 0
			While !Eof() .And. NP6->NP6_CODIGO == NP5->NP5_CODIGO .And. NP6->NP6_TIPO == 'MO'
				nC++
				aAdd(aClACMO, Array(Len(aClAHMO)+1))
				For nX := 1 to Len(aClAHMO)
					aClACMO[nC,nX] := FieldGet(FieldPos(aClAHMO[nX,2]))
				Next
				aClACMO[nC,Len(aClAHMO)+1] := .F.
				dbSkip()
			EndDo
		EndIf
		If nC == 0
			aAdd(aClACMO, Array(Len(aClAHMO)+1))
			For nX := 1 to Len(aClAHMO)
				aClACMO[1,nX] := CriaVar(aClAHMO[nX,2])
				If 'NP6_ITEM' == AllTrim(aClAHMO[nX,2])
					aClACMO[1,nX] := '01'
				EndIf
			Next
			aClACMO[1,Len(aClAHMO)+1] := .F.
		EndIf	  
	EndIf   

	//______________________________________________________________________________________________
	For nX := 1 To Len(aCposEQ)
		If X3USADO(aCposEQ[nX]) .And. cNivel >= AGRRETNIV(aCposEQ[nX])
			aAdd(aClAHEQ,{AllTrim(RetTitle(aCposEQ[nX])), aCposEQ[nX], X3PICTURE(aCposEQ[nX]), TamSx3(aCposEQ[nX])[1], TamSx3(aCposEQ[nX])[1], X3VALID(aCposEQ[nX]), X3USADO(aCposEQ[nX]), TamSx3(aCposEQ[nX])[3], "NP6", AGRRETCTXT("NP6", aCposEQ[nX]) })
		Endif
	Next nX  

	If  nOpcao != 2
		If nPermEQ > 0
			aAdd(aClACEQ, Array(Len(aClAHEQ)+1))
			For nX := 1 to Len(aClAHEQ)
				aClACEQ[1,nX] := CriaVar(aClAHEQ[nX,2])
				If 'NP6_ITEM' == AllTrim(aClAHEQ[nX,2])
					aClACEQ[1,nX] := '01'
				EndIf
			Next
			aClACEQ[1,Len(aClAHEQ)+1] := .F.
		EndIf  
	Else
		nC := 0
		dbSelectArea('NP6')
		dbSetOrder(1)
		If dbSeek(xFilial('NP6')+NP5->NP5_CODIGO+'EQ')
			nC := 0
			While !Eof() .And. NP6->NP6_CODIGO == NP5->NP5_CODIGO .And. NP6->NP6_TIPO == 'EQ'
				nC++
				aAdd(aClACEQ, Array(Len(aClAHEQ)+1))
				For nX := 1 to Len(aClAHEQ)
					aClACEQ[nC,nX] := FieldGet(FieldPos(aClAHEQ[nX,2]))
				Next
				aClACEQ[nC,Len(aClAHEQ)+1] := .F.
				dbSkip()
			EndDo
		EndIf
		If nC == 0
			aAdd(aClACEQ, Array(Len(aClAHEQ)+1))
			For nX := 1 to Len(aClAHEQ)
				aClACEQ[1,nX] := CriaVar(aClAHEQ[nX,2])
				If 'NP6_ITEM' == AllTrim(aClAHEQ[nX,2])
					aClACEQ[1,nX] := '01'
				EndIf
			Next
			aClACEQ[1,Len(aClAHEQ)+1] := .F.
		EndIf	  
	EndIf      

	//______________________________________________________________________________________________

	For nX := 1 To Len(aCposPD)
		If X3USADO(aCposPD[nX]) .And. cNivel >= AGRRETNIV(aCposPD[nX])
			aAdd(aClAHPD,{AllTrim(RetTitle(aCposPD[nX])), aCposPD[nX], X3PICTURE(aCposPD[nX]), TamSx3(aCposPD[nX])[1], TamSx3(aCposPD[nX])[1], X3VALID(aCposPD[nX]), X3USADO(aCposPD[nX]), TamSx3(aCposPD[nX])[3], "NP6", AGRRETCTXT("NP6", aCposPD[nX]) })
		Endif
	Next nX   

	If nOpcao != 2
		If nPermPD > 0
			aAdd(aClACPD, Array(Len(aClAHPD)+1))
			For nX := 1 to Len(aClAHPD)
				aClACPD[1,nX] := CriaVar(aClAHPD[nX,2])
				If 'NP6_ITEM' == AllTrim(aClAHPD[nX,2])
					aClACPD[1,nX] := '01'
				EndIf
			Next
			aClACPD[1,Len(aClAHPD)+1] := .F.
		EndIf
	Else
		nC := 0
		dbSelectArea('NP6')
		dbSetOrder(1)
		If dbSeek(xFilial('NP6')+NP5->NP5_CODIGO+'PD')
			nC := 0
			While !Eof() .And. NP6->NP6_CODIGO == NP5->NP5_CODIGO .And. NP6->NP6_TIPO == 'PD'
				nC++
				aAdd(aClACPD, Array(Len(aClAHPD)+1))
				For nX := 1 to Len(aClAHPD)
					aClACPD[nC,nX] := FieldGet(FieldPos(aClAHPD[nX,2]))
				Next
				aClACPD[nC,Len(aClAHPD)+1] := .F.
				dbSkip()
			EndDo
		EndIf
		If nC == 0
			aAdd(aClACPD, Array(Len(aClAHPD)+1))
			For nX := 1 to Len(aClAHPD)
				aClACPD[1,nX] := CriaVar(aClAHPD[nX,2])
				If 'NP6_ITEM' == AllTrim(aClAHPD[nX,2])
					aClACPD[1,nX] := '01'
				EndIf
			Next
			aClACPD[1,Len(aClAHPD)+1] := .F.
		EndIf	  
	EndIf      

	//______________________________________________________________________________________________

	RegToMemory('NP5',(nOpcao != 2))

	M->NP5_SAFRA  := NP1->NP1_SAFRA
	M->NP5_SAFDES := NP1->NP1_SAFDES
	M->NP5_FAZ    := NP1->NP1_FAZ
	M->NP5_FAZNOM := NP1->NP1_FAZNOM
	M->NP5_TALHAO := NP1->NP1_TALHAO
	M->NP5_CODSRV := NP1->NP1_CODSRV
	M->NP5_DESSRV := NP1->NP1_DESSRV
	M->NP5_CODPRE := NP1->NP1_CODIGO

	Define MSDialog oDlg Title cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd Pixel

	oEnch   := MsMGet():New('NP5',,nOpcao,,,,,aPosObj[1],,3,,,,oDlg,,.t.)
	oFolder := TFolder():New(aPosObj[2,1],aPosObj[2,2],aTitulo,aRefere,oDlg,,,,.t.,.f.,aPosObj[2,4],aPosObj[2,3]/2)

	aHeader := aClone(aClAHMO)
	aCols   := aClone(aClACMO)
	oGetMO  := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcao,,,'+NP6_ITEM',.t.,,Len(aClACMO),,nPermMO,'AGRA205E("MO")',,,,oFolder:aDialogs[1])
	oGetMO:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT 


	aHeader := aClone(aClAHEQ)
	aCols   := aClone(aClACEQ)
	oGetEQ  := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcao,,,'+NP6_ITEM',.t.,,Len(aClACEQ),,nPermEQ,'AGRA205E("EQ")',,,,oFolder:aDialogs[2])
	oGetEQ:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

	aHeader := aClone(aClAHPD)
	aCols   := aClone(aClACPD)
	oGetPD  := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcao,,,'+NP6_ITEM',.t.,,Len(aClACPD),,nPermPD,'AGRA205E("PD")',,,,oFolder:aDialogs[3])
	oGetPD:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT 


	oFolder:bSetOption:={|nAtu| A205Fld(nAtu,oFolder:nOption,oFolder,{oGetMO,oGetEQ,oGetPD})}

	Activate MsDialog oDlg On Init  (A205Refre(oFolder:nOption,{oGetMO,oGetEQ,oGetPD}), EnchoiceBar(oDlg, {|| nOpcA := 1, If(AGRA205H(nOpcao), oDlg:End(), nOpcA := 0) } , {|| nOpcA := 0, oDlg:End() },,aButtons))

	If nOpcA==1 .And. !nOpcao == 2
		fGravaRet()
		If __lSX8
			ConfirmSX8()
		EndIf
	Else
		If __lSX8
			RollBackSX8()
		EndIf
	EndIf

	RestArea(aArea)
Return()                     


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRA205C บAutor  ณRicardo Tomasi      บ Data ณ  01/08/2004 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Quando o Getdados receber o foco aplica as variaveis ade-  บฑฑ
ฑฑบ          ณ quadas (aHeader e Acols).                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AGRA205C(cTipo)
	Local cGet := 'oGet' + cTipo

	If !Obrigatorio(aGets,aTela)
		oEnch:SetFocus()
		Return()
	EndIf

	Do Case
		Case cTipo == 'MO'
		aHeader := aClone(aClAHMO)
		aCols   := aClone(aClACMO)
		n       := IIf(nNMO==0,1,nNMO)
		Case cTipo == 'EQ'
		aHeader := aClone(aClAHEQ)
		aCols   := aClone(aClACEQ)
		n       := IIf(nNEQ==0,1,nNEQ)
		Case cTipo == 'PD'
		aHeader := aClone(aClAHPD)
		aCols   := aClone(aClACPD)
		n       := IIf(nNPD==0,1,nNPD)
	EndCase

	&cGet:oBrowse:Refresh()
	oFolder:Refresh()
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRA205D บAutor  ณRicardo Tomasi      บ Data ณ  01/08/2004 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Quando o Getdados perde o foco, salva as variaveis aHeader บฑฑ
ฑฑบ          ณ                                                    aCols   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AGRA205D(cTipo)

	Do Case
		Case cTipo == 'MO'
		aClAHMO := aClone(aHeader)
		aClACMO := aClone(aCols)
		nNMO    := n
		Case cTipo == 'EQ'
		aClAHEQ := aClone(aHeader)
		aClACEQ := aClone(aCols)
		nNEQ    := n
		Case cTipo == 'PD'
		aClAHPD := aClone(aHeader)
		aClACPD := aClone(aCols)
		nNPD    := n
	EndCase

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRA205E บAutor  ณRicardo Tomasi      บ Data ณ  01/08/2004 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida os campos expecificos dos GetDados.                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AGRA205E(cTipo)
	Local aArea       := GetArea()
	Local lRetorno    := .t.
	Local nPos_MONOM  := aScan(aHeader,{|x| Alltrim(Upper(x[2])) == 'NP6_MONOM' })
	Local nPos_EQNOM  := aScan(aHeader,{|x| Alltrim(Upper(x[2])) == 'NP6_EQNOM' })
	Local nPos_PDNOM  := aScan(aHeader,{|x| Alltrim(Upper(x[2])) == 'NP6_PDNOM' })
	Local nPos_UM     := aScan(aHeader,{|x| Alltrim(Upper(x[2])) == 'NP6_UM'    })
	Local nPos_QTDHAS := aScan(aHeader,{|x| Alltrim(Upper(x[2])) == 'NP6_QTDHAS'})
	Local nPos_QTDUNI := aScan(aHeader,{|x| Alltrim(Upper(x[2])) == 'NP6_QTDUNI'})
	Local nPos_QTDTOT := aScan(aHeader,{|x| Alltrim(Upper(x[2])) == 'NP6_QTDTOT'})

	Do Case
		Case 'NP6_MOCOD' $ __READVAR
		//For nX := 1 to Len(aCols)
		//	If nX <> n .And. aCols[nX,nPos_MOCOD] == M->NP6_MOCOD
		//		lRetorno := .f.
		//		Help('',1,'AGRA205E',,"Este codigo jแ foi"+Chr(10)+Chr(13)+" utilizado nesta aplica็ใo!",4,1)
		//	EndIf
		//Next nX
		dbSelectArea('NNA')
		dbSetOrder(1)
		dbSeek(xFilial('NNA')+M->NP6_MOCOD)
		aCols[n,nPos_MONOM] := NNA->NNA_NOME
		aCols[n,nPos_UM]    := 'HR'
		Case 'NP6_EQCOD' $ __READVAR
		//For nX := 1 to Len(aCols)
		//	If nX <> n .And. aCols[nX,nPos_EQCOD] == M->NP6_EQCOD
		//		lRetorno := .f.
		//		Help('',1,'AGRA205E',,"Este codigo jแ foi"+Chr(10)+Chr(13)+" utilizado nesta aplica็ใo!",4,1)
		//	EndIf
		//Next nX
		dbSelectArea('NNB')
		dbSetOrder(1)
		dbSeek(xFilial('NNB')+M->NP6_EQCOD)
		aCols[n,nPos_EQNOM] := NNB->NNB_DESCRI
		aCols[n,nPos_UM]    := 'HR'
		Case 'NP6_PDCOD' $ __READVAR
		//For nX := 1 to Len(aCols)
		//	If nX <> n .And. aCols[nX,nPos_PDCOD] == M->NP6_PDCOD
		//		lRetorno := .f.
		//		Help('',1,'AGRA205E',,"Este codigo jแ foi"+Chr(10)+Chr(13)+" utilizado nesta aplica็ใo!",4,1)
		//	EndIf
		//Next nX
		dbSelectArea('SB1')
		dbSetOrder(1)
		dbSeek(xFilial('SB1')+M->NP6_PDCOD)
		aCols[n,nPos_PDNOM] := SB1->B1_DESC
		aCols[n,nPos_UM]    := SB1->B1_UM
		Case 'NP6_QTDHAS' $ __READVAR
		aCols[n,nPos_QTDUNI] := aCols[n,nPos_QTDTOT] / M->NP6_QTDHAS//M->NP5_AREA
		aCols[n,nPos_QTDTOT] := aCols[n,nPos_QTDUNI] * M->NP6_QTDHAS//M->NP5_AREA
		Case 'NP6_QTDUNI' $ __READVAR
		aCols[n,nPos_QTDTOT] := M->NP6_QTDUNI * aCols[n,nPos_QTDHAS] //M->NP5_AREA
		Case 'NP6_QTDTOT' $ __READVAR
		aCols[n,nPos_QTDUNI] := M->NP6_QTDTOT / aCols[n,nPos_QTDHAS] //M->NP5_AREA
	EndCase

	RestArea(aArea)
Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRA205F บAutor  ณRicardo Tomasi      บ Data ณ  01/08/2004 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Grava fechamento da aplica็ใo.                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AGRA205F(cAlias,nReg,nOpcao)

	If NP1->NP1_STATUS == 'F'
		Help('',1,'AGRA205F',,STR0015+Chr(10)+Chr(13)+STR0023,4,1)
		Return()
	EndIf

	If ApMsgYesNo(STR0024, STR0025)
		If RecLock('NP1',.f.)
			NP1->NP1_STATUS := 'F'
			MsUnLock()
		EndIf
	EndIf

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRA205G บAutor  ณRicardo Tomasi      บ Data ณ  01/08/2004 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAplica o estorno do fechamnto na aplica็ใo.                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AGRA205G(cAlias, nReg, nOpcao)
	Local aSize    := MsAdvSize()
	Local aObjects := {{100,100,.t.,.t.},{100,100,.t.,.t.},{100,015,.t.,.f.}}
	Local aInfo    := {aSize[1],aSize[2],aSize[3],aSize[4],3,3}
	Local aPosObj  := MsObjSize(aInfo,aObjects)
	Local nX       := 0
	Local nOpcA    := 0
	Local nIndex   := 0
	Local aCampos  := Array(0)
	Local aListar  := Array(0)
	Local aMata240 := Array(0,0)
	Local cIndNP5  := ''
	Local cIndChv  := ''
	Local lAGRXEST :=GetMV('MV_AGRXEST',,.f.)

	Local lRetorno   := .T.    
	Local lAGRA205GE := .F.
	Private oDlg
	Private oMark
	Private cMarca  := GetMark()
	Private lMsErroAuto := .f.

	If Empty(NP1->NP1_STATUS)
		Help('',1,'AGRA205G',,STR0026,4,1)
		Return()
	EndIf

	aAdd(aCampos, 'NP5_MARCA' ); aAdd(aCampos, 'NP5_CODIGO'); aAdd(aCampos, 'NP5_DATA'  ); aAdd(aCampos, 'NP5_SAFRA' )
	aAdd(aCampos, 'NP5_FAZ'   ); aAdd(aCampos, 'NP5_TALHAO'); aAdd(aCampos, 'NP5_AREA'  ); aAdd(aCampos, 'NP5_DESSRV')

	For nX := 1 To Len(aCampos)
		If 'NP5_MARCA' $ aCampos[nX]
			aAdd(aListar,{'NP5_MARCA', ,'', '@!'})
		Else
			If X3USADO(aCampos[nX]) .And. cNivel >= AGRRETNIV(aCampos[nX])
				aAdd(aListar,{ aCampos[nX], , AllTrim(RetTitle(aCampos[nX])), X3PICTURE(aCampos[nX]) })
			Endif
		EndIf
	Next nX

	dbSelectArea('NP5')
	dbSetOrder(3)

	cIndNP5 := CriaTrab(Nil,.F.)
	cIndChv := IndexKey()
	IndRegua('NP5', cIndNP5, cIndChv, , 'NP5_CODPRE == "'+NP1->NP1_CODIGO+'"', STR0027)  //"Selecionando Registros..."
	nIndex := RetIndex('NP5')
	dbSelectArea('NP5')
	#IFNDEF TOP
	dbSetIndex(cIndNP5+OrdBagExt())
	#ENDIF
	dbSetOrder(nIndex+1)

	Define MSDialog oDlg Title STR0028 From aSize[7],0 to aSize[6]/1.5,aSize[5]/1.1 of oMainWnd Pixel

	oMark := MsSelect():New('NP5', 'NP5_MARCA', , aListar,, cMarca, aPosObj[1])
	oMark:oBrowse:Align       := CONTROL_ALIGN_ALLCLIENT
	oMark:oBrowse:lColDrag    := .T.

	Activate MsDialog oDlg On Init EnchoiceBar(oDlg, {|| nOpcA := 1, oDlg:End() } , {|| nOpcA := 0, oDlg:End() }) Centered

	If nOpcA == 1
		If ExistBlock('AGRA205GE')
			lAGRA205GE := ExecBlock('AGRA205GE',.F.,.F.)     
			If ValType(lAGRA205GE) == "L"
				lRetorno := lAGRA205GE
			EndIf
		EndIf

		If !(lRetorno)
			Return()
		EndIf

		dbSelectArea('NP5')
		dbGotop()
		While !Eof()

			If NP5->NP5_MARCA == cMarca

				Begin Transaction


					UpdRetItem("MO", NP5->NP5_CODIGO, NP5->NP5_CODPRE)

					UpdRetItem("EQ", NP5->NP5_CODIGO, NP5->NP5_CODPRE)

					aMata240 = UpdRetItem("PD", NP5->NP5_CODIGO, NP5->NP5_CODPRE, aMata240) /*Retornar os dados para */

					If lAGRXEST .And. Len(aMata240) > 0
						For nX := 1 to Len(aMata240)
							MSExecAuto({|x,y| mata240(x,y)},aMata240[nX],3)
						Next nX
					EndIf

					If lMsErroAuto
						//Alterada a l๓gica do programa para que a transa็ใo nใo tenha nenhuma interrup็ใo de interface - SONARQUBE
						DisarmTransaction()
						Break
					Else
						aMata240 := Array(0,0)
					EndIf

					If RecLock('NP5',.f.)
						dbDelete()
						MsUnLock()
					EndIf

				End Transaction

				//Alterada a l๓gica do programa para que a transa็ใo nใo tenha nenhuma interrup็ใo de interface - SONARQUBE
				If lMsErroAuto
					Mostraerro()
					Return()
				EndIf

			EndIf

			dbSelectArea('NP5')
			dbSkip()
		EndDo

		dbSelectArea('NP5')
		dbSetOrder(3)
		If dbSeek(xFilial('NP5')+NP1->NP1_CODIGO)
			If RecLock('NP1',.f.)
				NP1->NP1_STATUS := 'P'
				MsUnLock()
			EndIf
		Else
			If RecLock('NP1',.f.)
				NP1->NP1_STATUS := ' '
				MsUnLock()
			EndIf
		EndIf

	EndIf

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRA205H บAutor  ณRicardo Tomasi      บ Data ณ  01/08/2004 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida se tudo OK para fechar a tela.                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AGRA205H(nOpc)
	Local lRetorno := .t.   
	Local nX := 0     
	Local nPos_MOCOD  := aScan(aClAHMO,{|x| Alltrim(Upper(x[2])) == 'NP6_MOCOD' })
	Local nPos_EQCOD  := aScan(aClAHEQ,{|x| Alltrim(Upper(x[2])) == 'NP6_EQCOD' })
	Local nPos_PDCOD  := aScan(aClAHPD,{|x| Alltrim(Upper(x[2])) == 'NP6_PDCOD' })  
	Local nPos_MOQTDT := aScan(aClAHMO,{|x| Alltrim(Upper(x[2])) == 'NP6_QTDTOT'})
	Local nPos_EQQTDT := aScan(aClAHEQ,{|x| Alltrim(Upper(x[2])) == 'NP6_QTDTOT'})
	Local nPos_PDQTDT := aScan(aClAHPD,{|x| Alltrim(Upper(x[2])) == 'NP6_QTDTOT'})

	oEnch:SetFocus()  
	A205RefrIt()

	If nOpc == 3 .Or. nOpc == 4
		lRetorno := Obrigatorio(aGets,aTela)

		if lRetorno
			dbSelectArea('NP5')
			dbSetOrder(3)
			If dbSeek(xFilial('NP5')+M->NP5_CODIGO)
				lRetorno := .F.   
				Help( , , "AJUDA", , "O c๓digo de retorno informado jแ existe no sistema !", 1, 0 )                                     
			endif
		endif

		If lRetorno .And. Len(aClACMO) > 0   
			For nX := 1 to Len(aClACMO)
				If !(aClACMO[nX,Len(aClAHMO)+1]) 
					If aClACMO[nX,nPos_MOQTDT]== 0 .And. !(Empty(aClACMO[nX,nPos_MOCOD]))
						lRetorno := .F.                                         
						Help(,,1,'AGRA205H1')
						Exit
					EndIf
				EndIf	
			Next nX
		EndIf  

		If lRetorno .And. Len(aClACEQ) > 0   
			For nX := 1 to Len(aClACEQ)
				If !(aClACEQ[nX,Len(aClAHEQ)+1])
					If aClACEQ[nX,nPos_EQQTDT]== 0 .And. !(Empty(aClACEQ[nX,nPos_EQCOD]))
						lRetorno := .F.    
						Help(,,1,'AGRA205H2')		 
						Exit
					EndIf
				EndIf
			Next nX
		EndIf    

		If lRetorno .And. Len(aClACPD) > 0   
			For nX := 1 to Len(aClACPD)
				If !(aClACPD[nX,Len(aClAHPD)+1]) 
					If aClACPD[nX,nPos_PDQTDT] == 0 .And. !(Empty(aClACPD[nX,nPos_PDCOD]))
						lRetorno := .F.   
						Help(,,1,'AGRA205H3')			
						Exit
					EndIf
				EndIf
			Next nX 
		Endif      

	EndIf  
	oFolder:Refresh()

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ fSelItensบAutor  ณRicardo Tomasi      บ Data ณ  01/08/2004 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Grava retorno das aplica็๕es.                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fSelItens(cTipo)
	Local aArea      := GetArea()
	Local aSize      := MsAdvSize()
	Local aObjects   := {{100,100,.t.,.t.},{100,100,.t.,.t.},{100,015,.t.,.f.}}
	Local aInfo      := {aSize[1],aSize[2],aSize[3],aSize[4],3,3}
	Local aPosObj    := MsObjSize(aInfo,aObjects)
	Local nX         := 0
	Local nY         := 0
	Local nOpcA      := 0
	Local nIndex     := 0
	Local aCampos    := Array(0)
	Local aListar    := Array(0)
	Local cN         := ''
	Local cIndNP2    := ''
	Local cIndChv    := ''
	Local lExiste    := .f.
	Local lGravado   := .f.
	Local lLinBlk    := .f.      
	Local lRetorno   := .T.
	Local nPos_MOITE := 0
	Local nPos_MOCOD := 0
	Local nPos_MONOM := 0
	Local nPos_MOUM  := 0
	Local nPos_MOQUN := 0
	Local nPos_MOQTT := 0

	Local nPos_EQITE := 0
	Local nPos_EQCOD := 0
	Local nPos_EQNOM := 0
	Local nPos_EQUM  := 0
	Local nPos_EQQUN := 0
	Local nPos_EQQTT := 0

	Local nPos_QDHAS := 0

	Local nPos_PDITE := 0
	Local nPos_PDCOD := 0
	Local nPos_PDNOM := 0
	Local nPos_PDUM  := 0
	Local nPos_PDLOC := 0

	Private oDlg
	Private oMark
	Private cMarca  := GetMark()

	Do Case
		Case cTipo == 'MO'
		aCampos := { 'NP2_MARCA', 'NP2_ITEM', 'NP2_MOCOD', 'NP2_MONOM', 'NP2_UM', 'NP2_QTDTOT', 'NP2_QTDRET'}
		Case cTipo == 'EQ'
		aCampos := { 'NP2_MARCA', 'NP2_ITEM', 'NP2_EQCOD', 'NP2_EQNOM', 'NP2_UM', 'NP2_QTDTOT', 'NP2_QTDRET'}
		Case cTipo == 'PD'
		aCampos := { 'NP2_MARCA', 'NP2_ITEM', 'NP2_PDCOD', 'NP2_PDNOM', 'NP2_UM', 'NP2_LOCAL', 'NP2_QTDTOT', 'NP2_QTDRET'}
	EndCase

	For nX := 1 To Len(aCampos)
		If 'NP2_MARCA' $ aCampos[nX]
			aAdd(aListar,{'NP2_MARCA', ,'', '@!'})
		Else
			aAdd(aListar,{ aCampos[nX], , AllTrim(RetTitle(aCampos[nX])), X3PICTURE(aCampos[nX]) })
		EndIf
	Next nX

	dbSelectArea('NP2')
	dbSetOrder(1)

	cIndNP2 := CriaTrab(Nil,.F.)
	cIndChv := IndexKey()
	IndRegua('NP2', cIndNP2, cIndChv, , 'NP2_CODIGO == "'+NP1->NP1_CODIGO+'" .And. NP2_TIPO == "'+cTipo+'"', STR0027)  //"Selecionando Registros..."
	nIndex := RetIndex('NP2')
	dbSelectArea('NP2')
	#IFNDEF TOP
	dbSetIndex(cIndNP2+OrdBagExt())
	#ENDIF
	dbSetOrder(nIndex+1)

	Define MSDialog oDlg Title STR0029 From aSize[7],0 to aSize[6]/1.5,aSize[5]/1.1 of oMainWnd Pixel

	oMark := MsSelect():New('NP2', 'NP2_MARCA', , aListar,, cMarca, aPosObj[1])
	oMark:oBrowse:Align       := CONTROL_ALIGN_ALLCLIENT
	oMark:oBrowse:lColDrag    := .T.

	Activate MsDialog oDlg On Init EnchoiceBar(oDlg, {|| nOpcA := 1, oDlg:End() } , {|| nOpcA := 0, oDlg:End() }) Centered

	If nOpcA == 1     
		nPos_MOITE := aScan(aClAHMO,{|x| Alltrim(Upper(x[2])) == 'NP6_ITEM'  })
		nPos_MOCOD := aScan(aClAHMO,{|x| Alltrim(Upper(x[2])) == 'NP6_MOCOD' })
		nPos_MONOM := aScan(aClAHMO,{|x| Alltrim(Upper(x[2])) == 'NP6_MONOM' })
		nPos_MOUM  := aScan(aClAHMO,{|x| Alltrim(Upper(x[2])) == 'NP6_UM'    })
		nPos_MOQUN := aScan(aClAHMO,{|x| Alltrim(Upper(x[2])) == 'NP6_QTDUNI'})
		nPos_MOQTT := aScan(aClAHMO,{|x| Alltrim(Upper(x[2])) == 'NP6_QTDTOT'})

		nPos_EQITE := aScan(aClAHEQ,{|x| Alltrim(Upper(x[2])) == 'NP6_ITEM'  })
		nPos_EQCOD := aScan(aClAHEQ,{|x| Alltrim(Upper(x[2])) == 'NP6_EQCOD' })
		nPos_EQNOM := aScan(aClAHEQ,{|x| Alltrim(Upper(x[2])) == 'NP6_EQNOM' })
		nPos_EQUM  := aScan(aClAHEQ,{|x| Alltrim(Upper(x[2])) == 'NP6_UM'    })
		nPos_EQQUN := aScan(aClAHMO,{|x| Alltrim(Upper(x[2])) == 'NP6_QTDUNI'})
		nPos_EQQTT := aScan(aClAHMO,{|x| Alltrim(Upper(x[2])) == 'NP6_QTDTOT'})

		nPos_QDHAS := aScan(aClAHMO,{|x| Alltrim(Upper(x[2])) == 'NP6_QTDHAS'})

		nPos_PDITE := aScan(aClAHPD,{|x| Alltrim(Upper(x[2])) == 'NP6_ITEM'  })
		nPos_PDCOD := aScan(aClAHPD,{|x| Alltrim(Upper(x[2])) == 'NP6_PDCOD' })
		nPos_PDNOM := aScan(aClAHPD,{|x| Alltrim(Upper(x[2])) == 'NP6_PDNOM' })
		nPos_PDUM  := aScan(aClAHPD,{|x| Alltrim(Upper(x[2])) == 'NP6_UM'    })
		nPos_PDLOC := aScan(aClAHPD,{|x| Alltrim(Upper(x[2])) == 'NP6_LOCAL' })

		lRetorno := Obrigatorio(aGets,aTela)     

		If !lRetorno 
			Return
		EndIf

		If cTipo == 'MO'	
			dbSelectArea('NP2')
			dbGotop()
			While !Eof()
				If NP2->NP2_MARCA == cMarca
					For nX := 1 to Len(aCols) 
						If !aCols[nX,len(aCols[nX])]
							If aCols[nX,nPos_MOCOD] == NP2->NP2_MOCOD
								lExiste := .t.
							EndIf   				
						EndIf
						cN := aCols[nX,nPos_MOITE]
					Next nX                             

					If !(lExiste)
						If Empty(aCols[1,nPos_MOCOD]) .And. !aCols[1,len(aCols[1])]
							aCols[1,nPos_MOCOD] := NP2->NP2_MOCOD
							aCols[1,nPos_MONOM] := NP2->NP2_MONOM
							aCols[1,nPos_MOUM ] := NP2->NP2_UM
						Else
							aAdd(aCols, Array(Len(aHeader)+1))
							aCols[nX,nPos_MOITE] := Soma1(cN,1)
							aCols[nX,nPos_MOCOD] := NP2->NP2_MOCOD
							aCols[nX,nPos_MONOM] := NP2->NP2_MONOM
							aCols[nX,nPos_MOUM ] := NP2->NP2_UM
							aCols[nX,nPos_MOQUN] := 0
							aCols[nX,nPos_MOQTT] := 0
							aCols[nX,nPos_QDHAS] := 0					
							aCols[nX,Len(aHeader)+1] := .F.
						EndIf
					EndIf
					lExiste := .f.
				EndIf
				dbSkip()
			EndDo
			oGetMO:oBrowse:Refresh()
		EndIf

		If cTipo == 'EQ'	
			dbSelectArea('NP2')
			dbGotop()
			While !Eof()
				If NP2->NP2_MARCA == cMarca
					For nX := 1 to Len(aCols)
						If !aCols[nX,len(aCols[nX])]
							If aCols[nX,nPos_EQCOD] == NP2->NP2_EQCOD
								lExiste := .t.
							EndIf											
						EndIf                           
						cN := aCols[nX,nPos_EQITE]
					Next nX  

					If !(lExiste)
						If Empty(aCols[1,nPos_EQCOD])
							aCols[1,nPos_EQCOD] := NP2->NP2_EQCOD
							aCols[1,nPos_EQNOM] := NP2->NP2_EQNOM
							aCols[1,nPos_EQUM ] := NP2->NP2_UM
						Else
							aAdd(aCols, Array(Len(aHeader)+1))
							aCols[nX,nPos_EQITE] := Soma1(cN,1)
							aCols[nX,nPos_EQCOD] := NP2->NP2_EQCOD
							aCols[nX,nPos_EQNOM] := NP2->NP2_EQNOM
							aCols[nX,nPos_EQUM ] := NP2->NP2_UM
							aCols[nX,nPos_EQQUN] := 0
							aCols[nX,nPos_EQQTT] := 0
							aCols[nX,nPos_QDHAS] := 0					
							aCols[nX,Len(aHeader)+1] := .F.
						EndIf
					EndIf
					lExiste := .f.
				EndIf
				dbSkip()
			EndDo
			oGetEQ:oBrowse:Refresh()
		EndIf

		If cTipo == 'PD'
			dbSelectArea('NP2')
			dbGotop()
			While !Eof()

				If NP2->NP2_MARCA == cMarca

					dbSelectArea('SB1')
					dbSetOrder(1)
					If dbSeek(xFilial('SB1')+NP2->NP2_PDCOD)

						For nX := 1 to Len(aCols) 
							If !aCols[nX,len(aCols[nX])]
								If aCols[nX,nPos_PDCOD] == NP2->NP2_PDCOD
									lExiste := .t.
								EndIf							
							EndIf                     

							cN := aCols[nX,nPos_PDITE]
						Next nX

						If .Not. lExiste .And. nPermPD > Len(aCols)

							For nX := 1 to Len(aCols)  
								If !aCols[nX,len(aCols[nX])]
									If Empty(aCols[nX,nPos_PDCOD])
										aCols[nX,nPos_PDCOD] := NP2->NP2_PDCOD
										aCols[nX,nPos_PDNOM] := NP2->NP2_PDNOM
										aCols[nX,nPos_PDUM ] := NP2->NP2_UM
										aCols[nX,nPos_PDLOC] := NP2->NP2_LOCAL
										lGravado := .t.
										lLinBlk  := .t.
									EndIf   
								EndIf
							Next nX

							If .Not. lGravado

								aAdd(aCols, Array(Len(aHeader)+1))
								For nY := 1 to Len(aHeader)   
									If !aCols[nX,len(aCols[nX])]
										aCols[nX,nY] := CriaVar(aHeader[nY,2])
										If 'NP6_ITEM' == AllTrim(aHeader[nY,2])
											aCols[nX,nY] := Soma1(cN,1)
										EndIf     
									EndIf
								Next

								aCols[nX,nPos_PDCOD] := NP2->NP2_PDCOD
								aCols[nX,nPos_PDNOM] := NP2->NP2_PDNOM
								aCols[nX,nPos_PDUM ] := NP2->NP2_UM
								aCols[nX,nPos_PDLOC] := NP2->NP2_LOCAL
								aCols[nX,Len(aHeader)+1] := .F.

							EndIf

						EndIf //Se existir e for permitido a quantidade de itens

						lExiste  := .f.
						lGravado := .f.

					EndIf

				EndIf //Se esta marcado

				dbSelectArea('NP2')
				dbSkip()
			EndDo

			If lLinBlk .And. .f.
				cN := Soma1(cN,1)
				aAdd(aCols, Array(Len(aHeader)+1))
				nX := Len(aCols)
				For nY := 1 to Len(aHeader)    
					If !aCols[nX,len(aCols[nX])]
						aCols[nX,nY] := CriaVar(aHeader[nY,2])
						If 'NP6_ITEM' == AllTrim(aHeader[nY,2])
							aCols[nX,nY] := Soma1(cN,1)
						EndIf
					EndIf
				Next      
			EndIf

			oGetPD:oBrowse:Refresh()
		EndIf

	EndIf

	RestArea(aArea)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ fGravaRetบAutor  ณRicardo Tomasi      บ Data ณ  01/08/2004 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Grava retorno das aplica็๕es.                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fGravaRet()    
	Local aArea       := GetArea()
	Local nX          := 0
	Local nY          := 0
	Local nZ          := 0
	Local nPos_MOCOD  := 0
	Local nPos_EQCOD  := 0
	Local nPos_PDCOD  := 0
	Local nPos_QTDTOT := 0
	Local aMata240    := Array(0,0)
	Local cNovoItem   := ''    
	Local cQuery      := ""
	Local cAliasMONP2   := ""
	Local cAliasEQNP2   := ""
	Local cAliasPDNP2   := ""
	Local cTMUtil       := Subst(GetMV('MV_AGRTM',,'001/101/501'),9,3)

	Private lMsErroAuto := .f.    

	A205RefrIt()   

	Begin Transaction

		dbSelectArea('NP5')
		dbSetOrder(1)
		dbSeek(xFilial('NP5')+M->NP5_CODIGO)
		If RecLock('NP5',.t.)
			For nY := 1 To FCount()
				If "_FILIAL" $ FieldName(nY)
					&('NP5->NP5_FILIAL') := xFilial('NP5')
				Else
					&('NP5->'+FieldName(nY)) := &('M->'+FieldName(nY))
				EndIf
			Next nY

			NP5->(dbCommit())
			NP5->(MsUnLock())
		EndIf

		//________________________________________________________________________________|MO|
		dbSelectArea('NP6')
		dbSetOrder(2)
		If Len(aClACMO) > 0
			nPos_MOCOD  := aScan(aClAHMO,{|x| Alltrim(Upper(x[2])) == 'NP6_MOCOD' })
			nPos_QTDTOT := aScan(aClAHMO,{|x| Alltrim(Upper(x[2])) == 'NP6_QTDTOT'})
			For nX := 1 to Len(aClACMO)
				If !(aClACMO[nX,Len(aClAHMO)+1]) .And. aClACMO[nX,nPos_QTDTOT] > 0
					If RecLock('NP6',.t.)
						For nY := 1 To Len(aClAHMO)
							&('NP6->'+aClAHMO[nY,2]) := aClACMO[nX,nY]
						Next nY
						NP6->NP6_FILIAL := xFilial('NP6')
						NP6->NP6_CODIGO  := NP5->NP5_CODIGO
						NP6->NP6_TIPO   := 'MO'
						NP6->NP6_CUSTO  := fCalCusto('MO',aClACMO[nX,nPos_MOCOD]) * aClACMO[nX,nPos_QTDTOT]

						NP6->(dbCommit())
						NP6->(MsUnLock())
					EndIf

					dbSelectArea('NP2')
					dbSetOrder(2)     

					cQuery := "SELECT NP2.R_E_C_N_O_ AS MO_RECNO "
					cQuery += "  FROM "+RetSQLName("NP2")+" NP2 "
					cQuery += " WHERE NP2.NP2_FILIAL = '"+xFilial("NP2")+"'"
					cQuery += "   AND NP2.NP2_CODIGO = '"+NP5->NP5_CODPRE+"'"
					cQuery += "   AND NP2.NP2_TIPO   = 'MO'"
					cQuery += "   AND NP2.NP2_MOCOD  = '"+aClACMO[nX,nPos_MOCOD]+"'"
					cQuery += "   AND NP2.D_E_L_E_T_ = ' ' "

					cQuery   := ChangeQuery(cQuery)
					cAliasMONP2:= GetNextAlias()	
					dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasMONP2, .F., .T. )


					If !(cAliasMONP2)->(Eof())//NP2->(dbSeek(xFilial('NP2')+NP5->NP5_CODPRE+'MO'+aClACMO[nX,nPos_MOCOD]))
						NP2->( dbGoTo( (cAliasMONP2)->MO_RECNO ) )
						If RecLock('NP2',.F.)  					
							NP2->NP2_QTDRET := NP2->NP2_QTDRET + aClACMO[nX,nPos_QTDTOT]

							NP2->(dbCommit())
							NP2->(MsUnLock())
						EndIf
					Else //Produto nใo existe na previsใo.
						cNovoItem := fBuscaIt(NP5->NP5_CODPRE)
						If RecLock('NP2',.T.)
							NP2->NP2_FILIAL := xFilial('NP2')
							NP2->NP2_CODIGO := NP5->NP5_CODPRE
							NP2->NP2_ITEM   := cNovoItem
							NP2->NP2_TIPO   := 'MO'
							NP2->NP2_MOCOD  := NP6->NP6_MOCOD
							NP2->NP2_MONOM  := NP6->NP6_MONOM
							NP2->NP2_UM     := NP6->NP6_UM
							NP2->NP2_LOCAL  := NP6->NP6_LOCAL
							NP2->NP2_QTDRET := NP2->NP2_QTDRET + NP6->NP6_QTDTOT

							NP2->(dbCommit())
							NP2->(MsUnLock())
						EndIf
					EndIf    

					(cAliasMONP2)->(dbCloseArea())

					dbSelectArea('NP6')

				EndIf
			Next nX
		EndIf

		//________________________________________________________________________________|EQ|
		dbSelectArea('NP6')
		dbSetOrder(3)
		If Len(aClACEQ) > 0
			nPos_EQCOD  := aScan(aClAHEQ,{|x| Alltrim(Upper(x[2])) == 'NP6_EQCOD' })
			nPos_QTDTOT := aScan(aClAHEQ,{|x| Alltrim(Upper(x[2])) == 'NP6_QTDTOT'})
			For nX := 1 to Len(aClACEQ)
				If !(aClACEQ[nX,Len(aClAHEQ)+1]) .And. aClACEQ[nX,nPos_QTDTOT] > 0
					If RecLock('NP6',.t.)
						For nY := 1 To Len(aClAHEQ)
							&('NP6->'+aClAHEQ[nY,2]) := aClACEQ[nX,nY]
						Next nY
						NP6->NP6_FILIAL := xFilial('NP6')
						NP6->NP6_CODIGO  := NP5->NP5_CODIGO
						NP6->NP6_TIPO   := 'EQ'
						NP6->NP6_CUSTO  := fCalCusto('EQ',aClACEQ[nX,nPos_EQCOD]) * aClACEQ[nX,nPos_QTDTOT]
						MsUnLock()
					EndIf


					dbSelectArea('NP2')
					dbSetOrder(3)     

					cQuery := "SELECT NP2.R_E_C_N_O_ AS EQ_RECNO "
					cQuery += "  FROM "+RetSQLName("NP2")+" NP2 "
					cQuery += " WHERE NP2.NP2_FILIAL = '"+xFilial("NP2")+"'"
					cQuery += "   AND NP2.NP2_CODIGO = '"+NP5->NP5_CODPRE+"'"
					cQuery += "   AND NP2.NP2_TIPO   = 'EQ'"
					cQuery += "   AND NP2.NP2_EQCOD  = '"+aClACEQ[nX,nPos_EQCOD]+"'"
					cQuery += "   AND NP2.D_E_L_E_T_ = ' ' "

					cQuery   := ChangeQuery(cQuery)
					cAliasEQNP2:= GetNextAlias()	
					dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasEQNP2, .F., .T. )


					If !(cAliasEQNP2)->(Eof())
						NP2->( dbGoTo( (cAliasEQNP2)->EQ_RECNO ) )
						If RecLock('NP2',.F.)
							NP2->NP2_QTDRET := NP2->NP2_QTDRET + aClACEQ[nX,nPos_QTDTOT]
							MsUnLock()
						EndIf
					Else //Produto nใo existe na previsใo.
						cNovoItem := fBuscaIt(NP5->NP5_CODPRE)
						If RecLock('NP2',.T.)
							NP2->NP2_FILIAL := xFilial('NP2')
							NP2->NP2_CODIGO := NP5->NP5_CODPRE
							NP2->NP2_ITEM   := cNovoItem
							NP2->NP2_TIPO   := 'EQ'
							NP2->NP2_EQCOD  := NP6->NP6_EQCOD
							NP2->NP2_EQNOM  := NP6->NP6_EQNOM
							NP2->NP2_UM     := NP6->NP6_UM
							NP2->NP2_LOCAL  := NP6->NP6_LOCAL
							NP2->NP2_QTDRET := NP2->NP2_QTDRET + NP6->NP6_QTDTOT
							msUnLock()
						EndIf
					EndIf                        

					(cAliasEQNP2)->(dbCloseArea())
					dbSelectArea('NP6')

				EndIf
			Next nX
		EndIf

		//________________________________________________________________________________|PD|
		dbSelectArea('NP6')
		dbSetOrder(4)
		If Len(aClACPD) > 0
			nPos_PDCOD  := aScan(aClAHPD,{|x| Alltrim(Upper(x[2])) == 'NP6_PDCOD' })
			nPos_QTDTOT := aScan(aClAHPD,{|x| Alltrim(Upper(x[2])) == 'NP6_QTDTOT'})
			For nX := 1 to Len(aClACPD)
				If !(aClACPD[nX,Len(aClAHPD)+1]) .And. aClACPD[nX,nPos_QTDTOT] > 0
					If RecLock('NP6',.t.)
						lGravo := .t.
						For nY := 1 To Len(aClAHPD)
							&('NP6->'+aClAHPD[nY,2]) := aClACPD[nX,nY]
						Next nY
						NP6->NP6_FILIAL := xFilial('NP6')
						NP6->NP6_CODIGO  := NP5->NP5_CODIGO
						NP6->NP6_TIPO   := 'PD'
						NP6->NP6_CUSTO  := fCalCusto('PD',aClACPD[nX,nPos_PDCOD]) * aClACPD[nX,nPos_QTDTOT]
						MsUnLock()
						SF5->(dbSeek(xFilial('SF5')+cTMUtil))
						nZ++
						aAdd(aMata240, {})
						aAdd(aMata240[nZ], {'D3_TM'     ,cTMUtil        ,Nil})
						aAdd(aMata240[nZ], {'D3_COD'    ,NP6->NP6_PDCOD ,Nil})
						aAdd(aMata240[nZ], {'D3_UM'     ,NP6->NP6_UM    ,Nil})
						aAdd(aMata240[nZ], {'D3_QUANT'  ,NP6->NP6_QTDTOT,Nil})
						aAdd(aMata240[nZ], {'D3_LOCAL'  ,NP6->NP6_LOCAL ,Nil})
						aAdd(aMata240[nZ], {'D3_EMISSAO',NP5->NP5_DATA  ,Nil})
						aAdd(aMata240[nZ], {'D3_DOC'    ,NP6->NP6_CODIGO,Nil})
						aAdd(aMata240[nZ], {'D3_CONTA'  ,NP6->NP6_CONTA ,Nil})
						aAdd(aMata240[nZ], {'D3_CC'     ,fRetCC(NP5->NP5_SAFRA,NP5->NP5_FAZ,NP5->NP5_TALHAO),Nil})
						aAdd(aMata240[nZ], {'D3_CLVL'   ,NP6->NP6_CLVL  ,Nil})
						aAdd(aMata240[nZ], {'D3_ITEMCTA',NP6->NP6_ITEMCT,Nil})
						If SF5->F5_VAL=='S'
							aAdd(aMata240[nZ], {'D3_CUSTO1',NP6->NP6_CUSTO,Nil})
						EndIf
					EndIf

					dbSelectArea('NP2')
					dbSetOrder(4)        

					cQuery := "SELECT NP2.R_E_C_N_O_ AS PD_RECNO "
					cQuery += "  FROM "+RetSQLName("NP2")+" NP2 "
					cQuery += " WHERE NP2.NP2_FILIAL = '"+xFilial("NP2")+"'"
					cQuery += "   AND NP2.NP2_CODIGO = '"+NP5->NP5_CODPRE+"'"
					cQuery += "   AND NP2.NP2_TIPO   = 'PD'"
					cQuery += "   AND NP2.NP2_PDCOD  = '"+aClACPD[nX,nPos_PDCOD]+"'"
					cQuery += "   AND NP2.D_E_L_E_T_ = ' ' "

					cQuery   := ChangeQuery(cQuery)
					cAliasPDNP2:= GetNextAlias()	
					dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasPDNP2, .F., .T. )


					If !(cAliasPDNP2)->(Eof()) //dbSeek(xFilial('NP2')+NP5->NP5_CODPRE+'PD'+aClACPD[nX,nPos_PDCOD])
						NP2->( dbGoTo( (cAliasPDNP2)->PD_RECNO ) )

						If RecLock('NP2',.F.)
							NP2->NP2_QTDRET := NP2->NP2_QTDRET + aClACPD[nX,nPos_QTDTOT]
							MsUnLock()
						EndIf
					Else //Produto nใo existe na previsใo.
						cNovoItem := fBuscaIt(NP5->NP5_CODPRE)
						If RecLock('NP2',.T.)
							NP2->NP2_FILIAL := xFilial('NP2')
							NP2->NP2_CODIGO := NP5->NP5_CODPRE
							NP2->NP2_ITEM   := cNovoItem
							NP2->NP2_TIPO   := 'PD'
							NP2->NP2_PDCOD  := NP6->NP6_PDCOD
							NP2->NP2_PDNOM  := NP6->NP6_PDNOM
							NP2->NP2_UM     := NP6->NP6_UM
							NP2->NP2_LOCAL  := NP6->NP6_LOCAL
							NP2->NP2_QTDRET := NP2->NP2_QTDRET + NP6->NP6_QTDTOT
							msUnLock()
						EndIf
					EndIf  
					(cAliasPDNP2)->(dbCloseArea())
					dbSelectArea('NP6')

				EndIf
			Next nX
		EndIf

		If GetMV('MV_AGRXEST',,.f.) .And. Len(aMata240) > 0
			For nX := 1 to Len(aMata240)
				MSExecAuto({|x,y| mata240(x,y)},aMata240[nX],3)
			Next nX
		EndIf

		If lMsErroAuto
			//Alterada a l๓gica do programa para que a transa็ใo nใo tenha nenhuma interrup็ใo de interface - SONARQUBE
			DisarmTransaction()
			Break
		Else
			aMata240 := Array(0,0)
		EndIf

		If RecLock('NP1',.f.)
			NP1->NP1_STATUS := 'P'
			MsUnLock()
		EndIf

	End Transaction

	//Alterada a l๓gica do programa para que a transa็ใo nใo tenha nenhuma interrup็ใo de interface - SONARQUBE
	If lMsErroAuto
		Mostraerro()
		Return()
	EndIf

	If ExistBlock('AGRA205RA')
		ExecBlock('AGRA205RA',.F.,.F.)
	EndIf

	RestArea(aArea)		
Return()

/*fun็ใo para atualizar os intens do estorno*/
static Function UpdRetItem(cType, CodigoNP6, CodigoPre, aMata240)
	Local cTMUtil     := Subst(GetMV('MV_AGRTM',,'001/101/501'),5,3)
	Private cAliasNP6 := GetNextAlias()
	Private cAliasNP2 := GetNextAlias()
	Private cFiltroTP := ""

	nZ := 0

	BeginSql Alias cAliasNP6
	SELECT NP6_MOCOD, NP6_EQCOD, NP6_PDCOD, NP6.R_E_C_N_O_ AS NP_RECNO, NP6_QTDTOT, 
	NP6_UM, NP6_LOCAL, NP6_CODIGO, NP6_CONTA, NP6_CLVL, NP6_ITEMCT, NP6_CUSTO
	FROM %Table:NP6% NP6
	WHERE NP6.%notDel%
	AND NP6_FILIAL = %Exp:xFilial('NP6')%
	AND NP6_CODIGO = %Exp:CodigoNP6%
	AND NP6_TIPO   = %Exp:cType%  
	EndSQL

	DbSelectArea( cAliasNP6 )
	(cAliasNP6)->(DbGoTop())

	While  .Not. (cAliasNP6)->( Eof( ) )

		if cType = "MO"
			cFiltroTP := "% NP2_MOCOD = '"+(cAliasNP6)->NP6_MOCOD+"' %"
		elseif cType = "EQ"
			cFiltroTP := "% NP2_EQCOD = '"+(cAliasNP6)->NP6_EQCOD+"' %"
		else
			cFiltroTP := "% NP2_PDCOD = '"+(cAliasNP6)->NP6_PDCOD+"' %"
		endif

		/*produto*/

		if cType = "PD"            

			cCCusto := fRetCC(NP5->NP5_SAFRA,NP5->NP5_FAZ,NP5->NP5_TALHAO)
			SF5->(dbSeek(xFilial('SF5')+cTMUtil))
			nZ++
			aAdd(aMata240, {})
			aAdd(aMata240[nZ], {'D3_TM'     ,cTMUtil        ,Nil})
			aAdd(aMata240[nZ], {'D3_COD'    ,(cAliasNP6)->NP6_PDCOD ,Nil})
			aAdd(aMata240[nZ], {'D3_UM'     ,(cAliasNP6)->NP6_UM    ,Nil})
			aAdd(aMata240[nZ], {'D3_QUANT'  ,(cAliasNP6)->NP6_QTDTOT,Nil})
			aAdd(aMata240[nZ], {'D3_LOCAL'  ,(cAliasNP6)->NP6_LOCAL ,Nil})
			aAdd(aMata240[nZ], {'D3_EMISSAO',dDataBase      ,Nil})
			aAdd(aMata240[nZ], {'D3_DOC'    ,(cAliasNP6)->NP6_CODIGO,Nil})
			aAdd(aMata240[nZ], {'D3_CONTA'  ,(cAliasNP6)->NP6_CONTA ,Nil})
			aAdd(aMata240[nZ], {'D3_CC'     ,cCCusto        ,Nil})
			aAdd(aMata240[nZ], {'D3_CLVL'   ,(cAliasNP6)->NP6_CLVL  ,Nil})
			aAdd(aMata240[nZ], {'D3_ITEMCTA',(cAliasNP6)->NP6_ITEMCT,Nil})
			If SF5->F5_VAL=='S'
				aAdd(aMata240[nZ], {'D3_CUSTO1',(cAliasNP6)->NP6_CUSTO,Nil})
			EndIf
		endif

		BeginSql Alias cAliasNP2
		SELECT NP2.R_E_C_N_O_ AS PD_RECNO
		FROM %Table:NP2% NP2
		WHERE NP2.%notDel%
		AND NP2_FILIAL = %Exp:xFilial('NP2')%
		AND NP2_CODIGO = %Exp:CodigoPre%
		AND NP2_TIPO   = %Exp:cType%  
		AND %Exp:cFiltroTP% 
		EndSQL

		DbSelectArea( cAliasNP2 )
		(cAliasNP2)->(DbGoTop())

		While  .Not. (cAliasNP2)->( Eof( ) )
			NP2->( dbGoTo( (cAliasNP2)->PD_RECNO ) )

			If RecLock('NP2',.F.)
				NP2->NP2_QTDRET := NP2->NP2_QTDRET - (cAliasNP6)->NP6_QTDTOT
				MsUnLock()
			EndIf
			If NP2->NP2_QTDRET==0 .And. NP2->NP2_QTDTOT==0
				If RecLock('NP2',.F.)
					dbDelete()
					msUnLock()
				EndIf
			EndIf 

			(cAliasNP2)->( dbSkip() )
		end
		(cAliasNP2)->(dbCloseArea())

		NP6->( dbGoTo( (cAliasNP6)->NP_RECNO ) )

		If RecLock('NP6',.f.)
			dbDelete()
			msUnLock()
		EndIf

		(cAliasNP6)->( dbSkip() )
	end
	(cAliasNP6)->(dbCloseArea())

return(aMata240) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ fCalCustoบAutor  ณ Ricardo Tomasi     บ Data ณ  07/07/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Calcula custo para os insumos da aplica็ใo.                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fCalCusto(cTipo, cCodigo)
	Local aArea := GetArea()
	Local nCusto := 0

	If cTipo == 'PD'
		dbSelectArea('SB2')
		dbSetOrder(1)
		If dbSeek(xFilial('SB2')+cCodigo)
			nCusto := SB2->B2_CM1
		EndIf
	EndIf

	If cTipo == 'MO'
		dbSelectArea('NNA')
		dbSetOrder(1)
		If dbSeek(xFilial('NNA')+cCodigo)
			nCusto := NNA->NNA_CUSREA
		EndIf
	EndIf

	If cTipo == 'EQ'
		dbSelectArea('NNB')
		dbSetOrder(1)
		If dbSeek(xFilial('NNB')+cCodigo)
			nCusto := NNB->NNB_CUSREA
		EndIf
	EndIf

	RestArea(aArea)
Return(nCusto)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfRetCC    บAutor  ณRicardo Tomasi      บ Data ณ  01/08/2004 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para retornar o centro de custo do talhao.           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fRetCC(cSafra,cFazenda,cTalhao)
	Local aArea    := GetArea()
	Local cRetorno := ''

	dbSelectArea('NN3')
	dbSetOrder(1)
	If dbSeek(xFilial('NN3')+cSafra+cFazenda+cTalhao)
		cRetorno := NN3->NN3_CC
	EndIf

	RestArea(aArea)
Return(cRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ fBuscaIt บAutor  ณRicardo Tomasi      บ Data ณ  01/08/2004 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para retornar o proximo item em aplica็๕es previstas.บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fBuscaIt(cCodPre)
	Local aArea    := GetArea()
	Local cRetorno := ''

	dbSelectArea('NP2')
	dbSetOrder(1)
	If dbSeek(xFilial('NP2')+cCodPre)
		While !Eof() .And. NP2->NP2_CODIGO == cCodPre
			cRetorno := NP2->NP2_ITEM
			dbSkip()
		EndDo
		cRetorno := Soma1(cRetorno,1)
	EndIf

	RestArea(aArea)
Return(cRetorno)

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
	{ STR0002   ,'AxPesqui' ,0,1},;
	{ STR0003   ,'AGRA205A' ,0,2},;
	{ STR0008   ,'AGRA205A' ,0,4},;
	{ STR0009   ,'AGRA205F' ,0,4},;
	{ STR0010   ,'AGRA205G' ,0,4},;
	{ STR0011   ,'AGRA200L' ,0,6} ;
	}

Return(aRotina)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณ A205Fld  ณ Autor ณ Aline S Damasceno     ณ Data ณ23.11.2012ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Funcao de Tratamento dos Folders                           ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณExpN1: Folder de Destino                                    ณฑฑ
ฑฑณ          ณExpN2: Folder Atual                                         ณฑฑ
ฑฑณ          ณExpO3: Objeto do Folder                                     ณฑฑ
ฑฑณ          ณExpA4: Array com as getdados.                               ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function A205Fld(nFldDst,nFldAtu,oFolder,aGetDad)
	Local lRetorno:= .F.

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณEfetua a Validacao da GetDados                        ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If ( aGetDad[nFldAtu]:TudoOk() )
		lRetorno := .T.
		aGetDad[nFldAtu]:oBrowse:lDisablePaint := .T.
		Do Case   
			Case ( nFldAtu == 1 )       		
			aClACMO := aClone(aCols)  
			Case ( nFldAtu == 2 )       		
			aClACEQ := aClone(aCols)			
			Case ( nFldAtu == 3 )       		
			aClACPD := aClone(aCols)
		EndCase  

		Do Case
			Case ( nFldDst == 1 )
			aHeader := aClone(aClAHMO)
			aCols   := aClone(aClACMO)
			Case ( nFldDst == 2 )
			aHeader := aClone(aClAHEQ)
			aCols   := aClone(aClACEQ)
			Case ( nFldDst == 3 )
			aHeader := aClone(aClAHPD)
			aCols   := aClone(aClACPD)
		EndCase       
		nOri := aGetDad[nFldAtu]:oBrowse:nAt
		n := Max(aGetDad[nFldDst]:oBrowse:nAt,1)

		aGetDad[nFldDst]:oBrowse:lDisablePaint := .F.
		aGetDad[nFldDst]:oBrowse:Refresh(.T.)
	EndIf    

Return(lRetorno)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณ A205Refreณ Autor ณAline S Damasceno      ณ Data ณ26.11.2012ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Efetua o refresh nas GetDados                              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ A205Refre( ExpN1,ExpA1 )                                   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ .T.                                                        ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ ExpN1 -> Folder Selecionado                                ณฑฑ
ฑฑณ          ณ ExpA1 -> Array contendo objetos GetDados                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function A205Refre(nFldAtu,aGetDad )

	Do Case
		Case nFldAtu == 1
		aCols     := aClone(aClACMO)
		aHeader   := aClone(aClAHMO)
		aGetDad[nFldAtu]:oBrowse:lDisablePaint := .F.
		aGetDad[nFldAtu]:oBrowse:Refresh(.T.)   

		Case nFldAtu == 2
		aCols     := aClone(aClACEQ)
		aHeader   := aClone(aClAHEQ)
		aGetDad[nFldAtu]:oBrowse:lDisablePaint := .F.
		aGetDad[nFldAtu]:oBrowse:Refresh(.T.) 

		Case nFldAtu == 3
		aCols     := aClone(aClACPD)
		aHeader   := aClone(aClAHPD)
		aGetDad[nFldAtu]:oBrowse:lDisablePaint := .F.
		aGetDad[nFldAtu]:oBrowse:Refresh(.T.) 
	EndCase		  	


Return( .T. )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณA205RefrItณ Autor ณAline S Damasceno      ณ Data ณ24/04/2013ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Atualiza os aCols da Mao-de-Obra, Equip, Produto           ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ A205RefrIt(  )			                                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ .T.                                                        ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A205RefrIt()   
	Local nPos_MOCOD  := aScan(aHeader,{|x| Alltrim(Upper(x[2])) == 'NP6_MOCOD' })
	Local nPos_EQCOD  := aScan(aHeader,{|x| Alltrim(Upper(x[2])) == 'NP6_EQCOD' })
	Local nPos_PDCOD  := aScan(aHeader,{|x| Alltrim(Upper(x[2])) == 'NP6_PDCOD' })

	Do Case
		Case nPos_MOCOD > 0
		aClACMO	:= aClone(aCols)
		aClAHMO	:= aClone(aHeader)
		Case nPos_EQCOD > 0
		aClACEQ := aClone(aCols)
		aClAHEQ := aClone(aHeader)
		Case nPos_PDCOD > 0
		aClACPD	 := aClone(aCols)
		aClAHPD	 := aClone(aHeader)
	EndCase		  	

Return( .T. )
