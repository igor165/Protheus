#include 'protheus.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRA200  บAutor  ณRicardo Tomasi      บ Data ณ  01/08/2004 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Inclusใo de Previsao de Aplicacao.                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AGRA200()
	Private aCores  	:= {{'NP1->NP1_STATUS == " "' ,'BR_VERDE'   },; //Verde    = Nใo Aplicada
							{'NP1->NP1_STATUS == "P"' ,'BR_AZUL'    },; //Azul     = Aplicada Parcialmente		                    
							{'NP1->NP1_STATUS == "F"' ,'BR_VERMELHO'}}  //Vermelho = Fechada
	Private aRotina 	:=  MenuDef()
	Private cCadastro 	:= "Aplica็๕es na Planta็ใo"	
	AjustaSX1()
	
	dbSelectArea('NP1')
	dbSetOrder(1)
	
	mBrowse(06, 01, 22, 75, 'NP1', Nil, Nil, Nil, Nil, Nil, aCores)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRA200A บAutor  ณRicardo Tomasi      บ Data ณ  01/08/2004 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtualiza็ใo da Aplica็ใo e Itens da Aplica็ใo.              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AGRA200A(cAlias, nReg, nOpcao)
	Do Case
		Case nOpcao == 4
			If NP1->NP1_STATUS == 'F'
				Help('',1,'AGRA200A',,"Esta Aplica็ใo esta fechada."+Chr(10)+Chr(13)+"Nใo ้ possivel fazer altera็๕es!",4,1)
			ElseIf NP1->NP1_STATUS == 'P'
				Help('',1,'AGRA200A',,"Esta Aplica็ใo ja sofreu retornos."+Chr(10)+Chr(13)+"Nใo ้ possivel fazer a altera็๕es!",4,1)
			Else
				AGRA200B(cAlias, nReg, nOpcao)
			EndIf
		Case nOpcao == 5
			If NP1->NP1_STATUS == 'F'
				Help('',1,'AGRA200A',,"Esta Aplica็ใo esta fechada."+Chr(10)+Chr(13)+"Nใo ้ possivel fazer a exclusใo!",4,1)
			ElseIf NP1->NP1_STATUS == 'P'
				Help('',1,'AGRA200A',,"Esta Aplica็ใo ja sofreu retornos."+Chr(10)+Chr(13)+"Nใo ้ possivel fazer a exclusใo!",4,1)
			Else
				AGRA200B(cAlias, nReg, nOpcao)
			EndIf
		OtherWise
			AGRA200B(cAlias, nReg, nOpcao)
	EndCase
	
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRA200B บAutor  ณRicardo Tomasi      บ Data ณ  01/08/2004 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtualiza็ใo da Aplica็ใo e Itens da Aplica็ใo.              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AGRA200B(cAlias, nReg, nOpcao)
	Local aSize      := MsAdvSize()
	Local aObjects   := {{100,100,.t.,.t.},{100,100,.t.,.t.},{100,015,.t.,.f.}}
	Local aInfo      := {aSize[1],aSize[2],aSize[3],aSize[4],3,3}
	Local aPosObj    := MsObjSize(aInfo,aObjects)
	Local nOpcA      := 0
	Local aCposMO    := {}
	Local aCposEQ    := {}
	Local aCposPD    := {}
	Local aTitulo    := {"Mใo de Obra","Equipamentos","Produtos"}
	Local aRefere    := {'Pasta1'     ,'Pasta2'      ,'Pasta3'  }
	Local nC         := 0
	Local nX         := 0
	Local nY         := 0
	Local nPos_ITEMMO:= 0
	Local nPos_ITEMEQ:= 0
	Local nPos_ITEMPD:= 0
	Local nPos_MOCOD := 0
	Local nPos_EQCOD := 0
	Local nPos_PDCOD := 0
	
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
	Private oDlg
	Private oEnch
	Private oGetMO
	Private oGetEQ
	Private oGetPD
	Private oFolder
	
	aCposMO := {'NP2_ITEM', 'NP2_MOCOD', 'NP2_MONOM', 'NP2_UM', 'NP2_QTDHAS', 'NP2_QTDAPL', 'NP2_QTDUNI', 'NP2_QTDTOT'}
	If ExistBlock('AGRA200MO')
		aCposMO := ExecBlock('AGRA200MO',.F.,.F.,aCposMO)
	EndIf
	
	aCposEQ := {'NP2_ITEM', 'NP2_EQCOD', 'NP2_EQNOM', 'NP2_UM', 'NP2_QTDHAS', 'NP2_QTDAPL', 'NP2_QTDUNI', 'NP2_QTDTOT'}
	If ExistBlock('AGRA200EQ')
		aCposEQ := ExecBlock('AGRA200EQ',.F.,.F.,aCposEQ)
	EndIf
	
	aCposPD := {'NP2_ITEM', 'NP2_PDCOD', 'NP2_PDNOM', 'NP2_UM', 'NP2_LOCAL', 'NP2_QTDHAS', 'NP2_QTDAPL', 'NP2_QTDUNI', 'NP2_QTDTOT'}
	If ExistBlock('AGRA200PD')
		aCposPD := ExecBlock('AGRA200PD',.F.,.F.,aCposPD)
	EndIf

	//______________________________________________________________________________________________|MO|
	For nX := 1 to Len(aCposMO)
		If X3USADO(aCposMO[nX]) .And. cNivel >= AGRRETNIV(aCposMO[nX])
			aAdd(aClAHMO,{ AllTrim(RetTitle(aCposMO[nX])),;
			 					  aCposMO[nX],;
			 					  X3Picture(aCposMO[nX]),;
			 					  TamSX3(aCposMO[nX])[1],;
			 					  TamSX3(aCposMO[nX])[2],;
			 					  X3Valid(aCposMO[nX]),;
			 					  GetSX3Cache(aCposMO[nX],"X3_USADO"),;
			 					  TamSX3(aCposMO[nX])[3],;
			 					  "NP2",;
			 					  AGRRETCTXT("NP2", aCposMO[nX]) })
		Endif
	Next nX
	
	If nOpcao == 3
		aAdd(aClACMO, Array(Len(aClAHMO)+1))
		For nX := 1 to Len(aClAHMO)
			aClACMO[1,nX] := CriaVar(aClAHMO[nX,2])
			If 'NP2_ITEM' == AllTrim(aClAHMO[nX,2])
				aClACMO[1,nX] := '01'
			EndIf
		Next
		aClACMO[1,Len(aClAHMO)+1] := .F.
	Else
		nC := 0
		dbSelectArea('NP2')
		dbSetOrder(1)
		If dbSeek(xFilial('NP2')+NP1->NP1_CODIGO+'MO')
			nC := 0
			While !Eof() .And. NP2->NP2_CODIGO == NP1->NP1_CODIGO .And. NP2->NP2_TIPO == 'MO'
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
				If 'NP2_ITEM' == AllTrim(aClAHMO[nX,2])
					aClACMO[1,nX] := '01'
				EndIf
			Next
			aClACMO[1,Len(aClAHMO)+1] := .F.
		EndIf
	EndIf
	//______________________________________________________________________________________________|EQ|
	For nX := 1 to Len(aCposEQ)
		If X3USADO(aCposEQ[nX]) .And. cNivel >= AGRRETNIV(aCposEQ[nX])
			aAdd(aClAHEQ,{ AllTrim(RetTitle(aCposEQ[nX])),;
			 					  aCposEQ[nX],;
			 					  X3Picture(aCposEQ[nX]),;
			 					  TamSX3(aCposEQ[nX])[1],;
			 					  TamSX3(aCposEQ[nX])[2],;
			 					  X3Valid(aCposEQ[nX]),;
			 					  GetSX3Cache(aCposEQ[nX],"X3_USADO"),;
			 					  TamSX3(aCposEQ[nX])[3],;
			 					  "NP2",;
			 					  AGRRETCTXT("NP2", aCposEQ[nX]) })
		Endif
	Next nX
	
	If nOpcao == 3
		aAdd(aClACEQ, Array(Len(aClAHEQ)+1))
		For nX := 1 to Len(aClAHEQ)
			aClACEQ[1,nX] := CriaVar(aClAHEQ[nX,2])
			If 'NP2_ITEM' == AllTrim(aClAHEQ[nX,2])
				aClACEQ[1,nX] := '01'
			EndIf
		Next
		aClACEQ[1,Len(aClAHEQ)+1] := .F.
	Else
		nC := 0
		dbSelectArea('NP2')
		dbSetOrder(1)
		If dbSeek(xFilial('NP2')+NP1->NP1_CODIGO+'EQ')
			nC := 0
			While !Eof() .And. NP2->NP2_CODIGO == NP1->NP1_CODIGO .And. NP2->NP2_TIPO == 'EQ'
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
				If 'NP2_ITEM' == AllTrim(aClAHEQ[nX,2])
					aClACEQ[1,nX] := '01'
				EndIf
			Next
			aClACEQ[1,Len(aClAHEQ)+1] := .F.
		EndIf
	EndIf
	//______________________________________________________________________________________________|PD|
	For nX := 1 to Len(aCposPD)
		If X3USADO(aCposPD[nX]) .And. cNivel >= AGRRETNIV(aCposPD[nX])
			aAdd(aClAHPD,{ AllTrim(RetTitle(aCposPD[nX])),;
			 					  aCposPD[nX],;
			 					  X3Picture(aCposPD[nX]),;
			 					  TamSX3(aCposPD[nX])[1],;
			 					  TamSX3(aCposPD[nX])[2],;
			 					  X3Valid(aCposPD[nX]),;
			 					  GetSX3Cache(aCposPD[nX],"X3_USADO"),;
			 					  TamSX3(aCposPD[nX])[3],;
			 					  "NP2",;
			 					  AGRRETCTXT("NP2", aCposPD[nX]) })
		Endif
	Next nX

	If nOpcao == 3
		aAdd(aClACPD, Array(Len(aClAHPD)+1))
		For nX := 1 to Len(aClAHPD)
			aClACPD[1,nX] := CriaVar(aClAHPD[nX,2])
			If 'NP2_ITEM' == AllTrim(aClAHPD[nX,2])
				aClACPD[1,nX] := '01'
			EndIf
		Next
		aClACPD[1,Len(aClAHPD)+1] := .F.
	Else
		nC := 0
		dbSelectArea('NP2')
		dbSetOrder(1)
		If dbSeek(xFilial('NP2')+NP1->NP1_CODIGO+'PD')
			nC := 0
			While !Eof() .And. NP2->NP2_CODIGO == NP1->NP1_CODIGO .And. NP2->NP2_TIPO == 'PD'
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
				If 'NP2_ITEM' == AllTrim(aClAHPD[nX,2])
					aClACPD[1,nX] := '01'
				EndIf
			Next
			aClACPD[1,Len(aClAHPD)+1] := .F.
		EndIf
	EndIf
	//______________________________________________________________________________________________
	
	RegToMemory('NP1',(nOpcao == 3))
	
	Define MSDialog oDlg Title cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd Pixel
	
		oEnch   := MsMGet():New('NP1',,nOpcao,,,,,aPosObj[1],,3,,,,oDlg,,.t.)
		oFolder := TFolder():New(aPosObj[2,1],aPosObj[2,2],aTitulo,aRefere,oDlg,,,,.t.,.f.,aPosObj[2,4],aPosObj[2,3]/2)
	
		aHeader := aClone(aClAHMO)
		aCols   := aClone(aClACMO)
		oGetMO  := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcao,,,'+NP2_ITEM',.t.,,Len(aHeader),,,'AGRA200E("MO")',,,,oFolder:aDialogs[1])
		oGetMO:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
		oGetMO:oBrowse:bGotFocus  := {|| AGRA200C('MO') }
		oGetMO:oBrowse:bLostFocus := {|| AGRA200D('MO') }
		oGetMO:oBrowse:Default()
		oGetMO:oBrowse:Refresh()
		
		aHeader := aClone(aClAHEQ)
		aCols   := aClone(aClACEQ)
		oGetEQ  := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcao,,,'+NP2_ITEM',.t.,,Len(aHeader),,,'AGRA200E("EQ")',,,,oFolder:aDialogs[2])
		oGetEQ:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
		oGetEQ:oBrowse:bGotFocus  := {|| AGRA200C('EQ') }
		oGetEQ:oBrowse:bLostFocus := {|| AGRA200D('EQ') }
		oGetEQ:oBrowse:Default()
		oGetEQ:oBrowse:Refresh()
		
		aHeader := aClone(aClAHPD)
		aCols   := aClone(aClACPD)
		oGetPD  := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcao,,,'+NP2_ITEM',.t.,,Len(aHeader),,,'AGRA200E("PD")',,,,oFolder:aDialogs[3])
		oGetPD:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
		oGetPD:oBrowse:bGotFocus  := {|| AGRA200C('PD') }
		oGetPD:oBrowse:bLostFocus := {|| AGRA200D('PD') }
		oGetPD:oBrowse:Default()
		oGetPD:oBrowse:Refresh()
	
	Activate MsDialog oDlg On Init EnchoiceBar(oDlg, {|| nOpcA := 1, If(AGRA200F(nOpcao), oDlg:End(), nOpcA := 0) } , {|| nOpcA := 0, oDlg:End() })
	
	If nOpcA == 1 .And. (nOpcao == 3 .Or. nOpcao == 4 .Or. nOpcao == 5)
		
		If nOpcao == 3 .or. nOpcao == 4
			//PONTO DE ENTRADA CHAMADO TUSHHJ
			If ExistBlock("AGRA200CO")
				If !EXECBLOCK("AGRA200CO",.F.,.F.,nOpcao)  
					Return()
				EndIf 
			EndIf
		EndIF
		/* EXEMPLO DO PE 
			#Include 'Protheus.ch'
	
			User Function AGRA200CO()
				Local nOpcao 	:= PARAMIXB		//OPCOES 3=Inclusใo, 4=Altera็ใo, 5=Exclusใo  
				Local lRetorno	:= .F.
				
				If nOpcao == 3
					ALERT("Ponto de Entrada INCLUIR - AGRA200CO")
					//PARA A OPวรO 3=INCLUSAO ESTA RETORNANDO VERDADEIRO .T.
					// ASSIM A INCLUSAO SERม FEITA 						  
					lRetorno := .T.		
				ElseIf nOpcao == 4
					ALERT("Ponto de Entrada ALTERAR - AGRA200CO")
					//PARA A OPวรO 4=ALTERACAO ESTA RETORNANDO FALSO .F.
					//ASSIM A ALTERACAO NรO SERม FEITA 				  	
					lRetorno := .F.		
				EndIf	 
			Return(lRetorno)
		*/
		Begin Transaction
	
		If nOpcao == 3 .or. nOpcao == 4
		
			If nOpcao == 3
				If __lSX8
					ConfirmSX8()
				EndIf
			EndIf
	
			dbSelectArea('NP1')
			dbSetOrder(1)
			dbSeek(xFilial('NP1')+M->NP1_CODIGO)
			If RecLock('NP1',(nOpcao==3))
				For nY := 1 To FCount()
					If "_FILIAL" $ FieldName(nY)
						&('NP1->NP1_FILIAL') := xFilial('NP1')
					Else
						&('NP1->'+FieldName(nY)) := &('M->'+FieldName(nY))
					EndIf
				Next nY
				MsUnLock()
			EndIf
	
			//________________________________________________________________________________________________|MO|
			If Len(aClACMO) > 0
				nPos_ITEMMO := aScan(aClAHMO,{|x| Alltrim(Upper(x[2])) == 'NP2_ITEM'  })
				nPos_MOCOD  := aScan(aClAHMO,{|x| Alltrim(Upper(x[2])) == 'NP2_MOCOD' })
				nPos_QTDTOT := aScan(aClAHMO,{|x| Alltrim(Upper(x[2])) == 'NP2_QTDTOT'})
				For nX := 1 To Len(aClACMO)
					If !Empty(aClACMO[nX,nPos_MOCOD])
						dbSelectArea('NP2')
						//dbSetOrder(2) //NP2_FILIAL+NP2_CODIGO+NP2_TIPO+NP2_MOCOD
						dbSetOrder(1) //NP2_FILIAL+NP2_CODIGO+NP2_TIPO+NP2_ITEM
						//If dbSeek(xFilial('NP2')+NP1->NP1_CODIGO+'MO'+aClACMO[nX,nPos_MOCOD])
						If dbSeek(xFilial('NP2')+NP1->NP1_CODIGO+'MO'+aClACMO[nX,nPos_ITEMMO])
							If aClACMO[nX,Len(aClAHMO)+1]
								If RecLock('NP2',.f.)
									dbDelete()
									msUnLock()
								EndIf
							Else
								If RecLock('NP2',.f.)
									For nY := 1 To Len(aClAHMO)
										&('NP2->'+aClAHMO[nY,2]) := aClACMO[nX,nY]
									Next nY
									msUnLock()
								EndIf
							EndIf
						Else
							If !(aClACMO[nX,Len(aClAHMO)+1])
								If RecLock('NP2',.t.)
									NP2->NP2_FILIAL := xFilial('NP2')
									NP2->NP2_CODIGO  := NP1->NP1_CODIGO
									NP2->NP2_TIPO   := 'MO'
									For nY := 1 To Len(aClAHMO)
										&('NP2->'+aClAHMO[nY,2]) := aClACMO[nX,nY]
									Next nY
									msUnLock()
								EndIf
							EndIf				
						EndIf
					EndIf
				Next nX
			EndIf
			//________________________________________________________________________________________________|EQ|
			If Len(aClACEQ) > 0
				nPos_ITEMEQ := aScan(aClAHEQ,{|x| Alltrim(Upper(x[2])) == 'NP2_ITEM' })
				nPos_EQCOD  := aScan(aClAHEQ,{|x| Alltrim(Upper(x[2])) == 'NP2_EQCOD' })
				nPos_QTDTOT := aScan(aClAHEQ,{|x| Alltrim(Upper(x[2])) == 'NP2_QTDTOT'})
				For nX := 1 To Len(aClACEQ)
					If !Empty(aClACEQ[nX,nPos_EQCOD])
						dbSelectArea('NP2')
						//dbSetOrder(3) //NP2_FILIAL+NP2_CODIGO+NP2_TIPO+NP2_EQCOD
						dbSetOrder(1) //NP2_FILIAL+NP2_CODIGO+NP2_TIPO+NP2_ITEM
						//If dbSeek(xFilial('NP2')+NP1->NP1_CODIGO+'EQ'+aClACEQ[nX,nPos_EQCOD])
						If dbSeek(xFilial('NP2')+NP1->NP1_CODIGO+'EQ'+aClACEQ[nX,nPos_ITEMEQ])
							If aClACEQ[nX,Len(aClAHEQ)+1]
								If RecLock('NP2',.f.)
									dbDelete()
									msUnLock()
								EndIf
							Else
								If RecLock('NP2',.f.)
									For nY := 1 To Len(aClAHEQ)
										&('NP2->'+aClAHEQ[nY,2]) := aClACEQ[nX,nY]
									Next nY
									msUnLock()
								EndIf
							EndIf
						Else
							If !(aClACEQ[nX,Len(aClAHEQ)+1])
								If RecLock('NP2',.t.)
									NP2->NP2_FILIAL := xFilial('NP2')
									NP2->NP2_CODIGO  := NP1->NP1_CODIGO
									NP2->NP2_TIPO   := 'EQ'
									For nY := 1 To Len(aClAHEQ)
										&('NP2->'+aClAHEQ[nY,2]) := aClACEQ[nX,nY]
									Next nY
									msUnLock()
								EndIf
							EndIf				
						EndIf
					EndIf
				Next nX
			EndIf
			//________________________________________________________________________________________________|PD|
			If Len(aClACPD) > 0
				nPos_ITEMPD := aScan(aClAHPD,{|x| Alltrim(Upper(x[2])) == 'NP2_ITEM' })
				nPos_PDCOD  := aScan(aClAHPD,{|x| Alltrim(Upper(x[2])) == 'NP2_PDCOD' })
				nPos_QTDTOT := aScan(aClAHPD,{|x| Alltrim(Upper(x[2])) == 'NP2_QTDTOT'})
				For nX := 1 To Len(aClACPD)
					If !Empty(aClACPD[nX,nPos_PDCOD])
						dbSelectArea('NP2')
						//dbSetOrder(4) //NP2_FILIAL+NP2_CODIGO+NP2_TIPO+NP2_PDCOD
						dbSetOrder(1) //NP2_FILIAL+NP2_CODIGO+NP2_TIPO+NP2_ITEM
						//If dbSeek(xFilial('NP2')+NP1->NP1_CODIGO+'PD'+aClACPD[nX,nPos_PDCOD])
						If dbSeek(xFilial('NP2')+NP1->NP1_CODIGO+'PD'+aClACPD[nX,nPos_ITEMPD])
							If aClACPD[nX,Len(aClAHPD)+1]
								If RecLock('NP2',.f.)
									dbDelete()
									msUnLock()
								EndIf
							Else
								If RecLock('NP2',.f.)
									For nY := 1 To Len(aClAHPD)
										&('NP2->'+aClAHPD[nY,2]) := aClACPD[nX,nY]
									Next nY
									msUnLock()
								EndIf
							EndIf
						Else
							If !(aClACPD[nX,Len(aClAHPD)+1])
								If RecLock('NP2',.t.)
									NP2->NP2_FILIAL := xFilial('NP2')
									NP2->NP2_CODIGO  := NP1->NP1_CODIGO
									NP2->NP2_TIPO   := 'PD'
									For nY := 1 To Len(aClAHPD)
										&('NP2->'+aClAHPD[nY,2]) := aClACPD[nX,nY]
									Next nY
									msUnLock()
								EndIf
							EndIf				
						EndIf
					EndIf
				Next nX
			EndIf
			//________________________________________________________________________________________________
	
		EndIf //Final do If se nOpcao for igual 3 ou igual 4
		
		If nOpcao == 5
	
			dbSelectArea('NP1')
			dbSetOrder(1)
			If dbSeek(xFilial('NP1')+M->NP1_CODIGO)
	
				dbSelectArea('NP2')
				dbSetOrder(1)
				If dbSeek(xFilial('NP2')+NP1->NP1_CODIGO)
					While NP2->NP2_FILIAL == NP1->NP1_FILIAL .And. NP2->NP2_CODIGO == NP1->NP1_CODIGO .And. !Eof()
						If RecLock('NP2',.f.)
							dbDelete()
							MsUnLock()
						EndIf
						dbSkip()
					EndDo
		        EndIf
	
				dbSelectArea('NP1')
				If RecLock('NP1',.f.)
					dbDelete()
					MsUnLock()
				EndIf
	
			EndIf	
		
		EndIf //Fim do nopcao == 5
	
		End Transaction
		
	Else
		If nOpcao == 3
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
ฑฑบPrograma  ณ AGRA200C บAutor  ณRicardo Tomasi      บ Data ณ  01/08/2004 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Quando o Getdados receber o foco aplica as variaveis ade-  บฑฑ
ฑฑบ          ณ quadas (aHeader e Acols).                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AGRA200C(cTipo)
	Local cGet := 'oGet' + cTipo
	
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
ฑฑบPrograma  ณ AGRA200D บAutor  ณRicardo Tomasi      บ Data ณ  01/08/2004 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Quando o Getdados perde o foco, salva as variaveis aHeader บฑฑ
ฑฑบ          ณ                                                    aCols   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AGRA200D(cTipo)
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
ฑฑบPrograma  ณ AGRA200E บAutor  ณRicardo Tomasi      บ Data ณ  01/08/2004 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida as linhas dos GetDados para cada tipo de insumo.    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AGRA200E(cTipo)
	Local aArea       := GetArea()
	Local lRetorno    := .t.
	Local nPos_MONOM  := aScan(aHeader,{|x| Alltrim(Upper(x[2])) == 'NP2_MONOM' })
	Local nPos_EQNOM  := aScan(aHeader,{|x| Alltrim(Upper(x[2])) == 'NP2_EQNOM' })
	Local nPos_PDNOM  := aScan(aHeader,{|x| Alltrim(Upper(x[2])) == 'NP2_PDNOM' })
	Local nPos_UM     := aScan(aHeader,{|x| Alltrim(Upper(x[2])) == 'NP2_UM'    })
	Local nPos_QTDHAS := aScan(aHeader,{|x| Alltrim(Upper(x[2])) == 'NP2_QTDHAS'})
	Local nPos_QTDAPL := aScan(aHeader,{|x| Alltrim(Upper(x[2])) == 'NP2_QTDAPL'})
	Local nPos_QTDUNI := aScan(aHeader,{|x| Alltrim(Upper(x[2])) == 'NP2_QTDUNI'})
	Local nPos_QTDTOT := aScan(aHeader,{|x| Alltrim(Upper(x[2])) == 'NP2_QTDTOT'})
	
	Do Case
		Case 'NP2_MOCOD' $ __READVAR
			//For nX := 1 to Len(aCols)
			//	If nX <> n .And. aCols[nX,nPos_MOCOD] == M->NP2_MOCOD
			//		lRetorno := .f.
			//		Help('',1,'AGRA200E',,"Este codigo jแ foi"+Chr(10)+Chr(13)+" utilizado nesta aplica็ใo!",4,1)
			//	EndIf
			//Next nX
			dbSelectArea('NNA')
			dbSetOrder(1)
			dbSeek(xFilial('NNA')+M->NP2_MOCOD)
			aCols[n,nPos_MONOM] := NNA->NNA_NOME
			aCols[n,nPos_UM]    := 'HR'
		Case 'NP2_EQCOD' $ __READVAR
			//For nX := 1 to Len(aCols)
			//	If nX <> n .And. aCols[nX,nPos_EQCOD] == M->NP2_EQCOD
			//		lRetorno := .f.
			//		Help('',1,'AGRA200E',,"Este codigo jแ foi"+Chr(10)+Chr(13)+" utilizado nesta aplica็ใo!",4,1)
			//	EndIf
			//Next nX
			dbSelectArea('NNB')
			dbSetOrder(1)
			dbSeek(xFilial('NNB')+M->NP2_EQCOD)
			aCols[n,nPos_EQNOM] := NNB->NNB_DESCRI
			aCols[n,nPos_UM]    := 'HR'
		Case 'NP2_PDCOD' $ __READVAR
			//For nX := 1 to Len(aCols)
			//	If nX <> n .And. aCols[nX,nPos_PDCOD] == M->NP2_PDCOD
			//		lRetorno := .f.
			//		Help('',1,'AGRA200E',,"Este codigo jแ foi"+Chr(10)+Chr(13)+" utilizado nesta aplica็ใo!",4,1)
			//	EndIf
			//Next nX
			dbSelectArea('SB1')
			dbSetOrder(1)
			dbSeek(xFilial('SB1')+M->NP2_PDCOD)
			aCols[n,nPos_PDNOM] := SB1->B1_DESC
			aCols[n,nPos_UM]    := SB1->B1_UM
		Case 'NP2_QTDHAS' $ __READVAR
			aCols[n,nPos_QTDTOT] := aCols[n,nPos_QTDAPL] * aCols[n,nPos_QTDUNI] * M->NP2_QTDHAS//M->NP1_AREA
		Case 'NP2_QTDAPL' $ __READVAR
			aCols[n,nPos_QTDTOT] := M->NP2_QTDAPL * aCols[n,nPos_QTDUNI]//M->NP1_AREA   
			If nPos_QTDHAS > 0
				aCols[n,nPos_QTDTOT] := aCols[n,nPos_QTDTOT] * aCols[n,nPos_QTDHAS]//M->NP1_AREA   
			EndIf
		Case 'NP2_QTDUNI' $ __READVAR
			aCols[n,nPos_QTDTOT] := aCols[n,nPos_QTDAPL] * M->NP2_QTDUNI //M->NP1_AREA   
			If nPos_QTDHAS > 0
				aCols[n,nPos_QTDTOT] := aCols[n,nPos_QTDTOT] * aCols[n,nPos_QTDHAS]//M->NP1_AREA   
			EndIf		
		Case 'NP2_QTDTOT' $ __READVAR
			aCols[n,nPos_QTDUNI] := M->NP2_QTDTOT / (aCols[n,nPos_QTDAPL] * aCols[n,nPos_QTDHAS])//M->NP1_AREA)
	EndCase
	
	RestArea(aArea)
Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRA200F บAutor  ณRicardo Tomasi      บ Data ณ  01/08/2004 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida se tudo OK para fechar a tela.                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AGRA200F(nOpc)
	Local lRetorno := .t.
	
	oEnch:SetFocus()
	
	If nOpc == 3 .Or. nOpc == 4
		lRetorno := Obrigatorio(aGets,aTela).And.AGRA200G()
	EndIf
Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRA200G บAutor  ณRicardo Tomasi      บ Data ณ  01/08/2004 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida codigo do talhao.                                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AGRA200G()
	Local aArea    := GetArea()                              
	Local lRetorno := .T.
	
	If Empty(M->NP1_TALHAO)
		lRetorno := .T.
	Else
		dbSelectArea('NN3')
		dbSetOrder(1)
		If dbSeek(xFilial('NN3')+M->NP1_SAFRA+M->NP1_FAZ+M->NP1_TALHAO)
			If NN3->NN3_FECHAD == 'S'
				Help('',1,'AGRA200GV1',,"Este talhใo ja esta fechado, e nใo pode ser movimentado.",4,1)
				lRetorno := .F.
			Else
				lRetorno := .T.
			EndIf
		Else
			Help('',1,'AGRA200GV2',,M->NP1_SAFRA,2,40)
			lRetorno := .F.
		EndIf
	EndIf
	
	RestArea(aArea)
Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRA200H บAutor  ณRicardo Tomasi      บ Data ณ  01/08/2004 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtualiza tamanho da area aplicada, atraves de gatilho.      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AGRA200H()
	Local aArea    := GetArea()                              
	Local nRetorno := 0
	
	If Empty(M->NP1_TALHAO)
		dbSelectArea('NN3')
		dbSetOrder(1)
		If dbSeek(xFilial('NN3')+M->NP1_SAFRA+M->NP1_FAZ)
			While !Eof() .And. NN3_SAFRA == M->NP1_SAFRA .And. NN3_FAZ == M->NP1_FAZ
					nRetorno := nRetorno + NN3->NN3_HECTAR
				dbSkip()
			EndDo
		EndIf
	Else
		dbSelectArea('NN3')
		dbSetOrder(1)
		If dbSeek(xFilial('NN3')+M->NP1_SAFRA+M->NP1_FAZ+M->NP1_TALHAO)
			nRetorno := NN3->NN3_HECTAR
		EndIf
	EndIf                              
		
	RestArea(aArea)
Return(nRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRA200I บAutor  ณRicardo Tomasi      บ Data ณ  01/08/2004 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida tamanho da area aplicada, nao permitindo que seja    บฑฑ
ฑฑบ          ณmaior que a area do talhao.                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AGRA200I()
	Local aArea    := GetArea()                              
	Local nAreaTot := 0
	Local lRetorno := .T.
	
	If Empty(M->NP1_TALHAO)
		nAreaTot := 99999999999
	Else
		dbSelectArea('NN3')
		dbSetOrder(1)
		If dbSeek(xFilial('NN3')+M->NP1_SAFRA+M->NP1_FAZ+M->NP1_TALHAO)
			nAreaTot := NN3->NN3_HECTAR
		EndIf
	EndIf                              
	
	If M->NP1_AREA > nAreaTot
		Help('',1,'AGRA200I',,"Area de aplica็ใo nใo pode ser"+Chr(10)+Chr(13)+"maior que a area total do talhao!",4,1)
		lRetorno := .F.
	Else
		lRetrono := .T.
	EndIf
		
	RestArea(aArea)
Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRA200L บAutor  ณ Ricardo Tomasi     บ Data ณ  13/07/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Legenda para Aplica็๕es Agrํcolas.                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AGRA200L()
	Local aLeg := {}
	
	aAdd(aLeg,{'BR_VERDE'   ,'Nใo Aplicada'         })
	aAdd(aLeg,{'BR_AZUL'    ,'Aplicada Parcialmente'})
	aAdd(aLeg,{'BR_VERMELHO','Fechada'              })
	
	BrwLegenda(cCadastro,"Legenda das Aplica็๕es", aLeg)
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
					{ 'Pesquisar' , 'AxPesqui', 0, 1},;
					{ 'Visualizar', 'AGRA200A', 0, 2},;
					{ 'Incluir'   , 'AGRA200A', 0, 3},;
					{ 'Alterar'   , 'AGRA200A', 0, 4},;
					{ 'Excluir'   , 'AGRA200A', 0, 5},;
					{ 'Legenda'   , 'AGRA200L', 0, 6} ;
					}
Return(aRotina)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณAjustaSX1 บAutorณAline Sebrian         บ Data ณ 15/10/2013  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบUso       ณ agra200                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function AjustaSX1()

	Local aHelpPor1 :={}
	Local aHelpEng1 :={}
	Local aHelpSpa1 :={}
	
	aAdd( aHelpPor1, "Talhใo nใo cadastrado ou nใo estแ   ")
	aAdd( aHelpPor1, "relacionado เ Safra ou Fazenda ") 
	
	aAdd( aHelpEng1, "Plot not registered or is not related ") 
	aAdd( aHelpEng1, "to Crop o Farm ")
	
	aAdd( aHelpSpa1, "Parcela no estแ registrado o no estแ   ")
	aAdd( aHelpSpa1, "relacionada con Cosecha o Hacienda  ")  
	                                                 
	PutHelp("PAGRA200GV2",aHelpPor1,aHelpEng1,aHelpSpa1,.T.)
	
	aHelpPor1 :={}
	aHelpEng1 :={}
	aHelpSpa1 :={}
	
	aAdd( aHelpPor1, "Cadastrar ou relacionar o Talhใo correto")
	
	aAdd( aHelpEng1, "Register or links the correct Plot") 
	
	aAdd( aHelpSpa1, "Regํstrese o enlaces la Parcela correcta ")
	                                               
	PutHelp("SAGRA200GV2",aHelpPor1,aHelpEng1,aHelpSpa1,.T.)		
	                                            
Return Nil