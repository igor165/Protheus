#INCLUDE "Tmsa220.ch"
#INCLUDE "FIVEWIN.CH"
#INCLUDE "FOLDER.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ TMSA220  ³ Autor ³Patricia A. Salomao    ³ Data ³07.02.2002  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Tabela Frete para Carreteiros por Rota                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA220()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SigaTMS - Gestao de Transporte                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSA220()

Private cCadastro := STR0001 //"Tabela de Frete para Carreteiros por Rota"
Private aRotina   := MenuDef()


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
mBrowse(6,1,22,75,"DTS")

Return NIL
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA220Mnt  ³ Autor ³ Patricia A. Salomao ³ Data ³07.02.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Manutencao Tabela de Frete para Carreteiros                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA220Mnt(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function TMSA220Mnt(cAlias, nReg, nOpcx)

Local oEnchoice, nCntFor
Local nOpca		 := 0
Local aAreaAnt   := GetArea()
Local aObjects	 := {}
Local aPosObj 	 := {}
Local aPosGetD   := {}
Local aInfo	 	 := {}
Local aSize	 	 := {}
Local aButtons   := {}
Local aPages	 := {}
Local aTitles	 := {}
Local nIndex     := 0
Local aNoFields  := {}
Local nCont      := 0
Local aSomaButtons := {}

Private aHeader  := {}
Private aCols    := {}
Private aRecDTM  := {}
Private aRecDTT  := {}
Private aTela[0][0],aGets[0]
Private aSvFolder := {}
Private o1Get, o2Get, oDlg, oFolder
Private cDescTab  := ""

RegToMemory("DTS", nOpcx==3)

//-- Ponto de entrada para incluir botoes na enchoicebar
If	ExistBlock('TM220BUT')
	aSomaButtons:=ExecBlock('TM220BUT',.F.,.F.,{nOpcx})
	If	ValType(aSomaButtons) == 'A'
		For nCont:=1 To Len(aSomaButtons)
			AAdd(aButtons,aSomaButtons[nCont])
		Next
	EndIf
EndIf

aNoFields := {"DTT_TABCAR","DTT_ROTA","DTM_TABCAR","DTM_ROTA"}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ aSvFolder[ n, 1 ] = aHeader                                               ³
//³ aSvFolder[ n, 2 ] = aCols                                                 ³
//³ aSvFolder[ n, 3 ] = Nr da linha da GetDados da pasta atual, variavel n    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa aSvFolder e Carrega variaveis para pasta de Frete               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DTT->(dbSetOrder(1))
Aadd(aSvFolder,{{},{},1})
TMS220IniVar("DTT", xFilial("DTT")+M->DTS_TABCAR+M->DTS_ROTA,;
         'DTT_FILIAL+DTT_TABCAR+DTT_ROTA',1,1,aNoFields )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa aSvFolder e Carrega variaveis para pasta de Premio              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DTM->(dbSetOrder(1))
Aadd(aSvFolder,{{},{},1})
TMS220IniVar("DTM", xFilial("DTM")+M->DTS_TABCAR+M->DTS_ROTA,;
	     'DTM_FILIAL+DTM_TABCAR+DTM_ROTA',1,2,aNoFields )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Configura variaveis do Objeto Folder                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd(aTitles,'&'+STR0008) //"Frete"
Aadd(aTitles,'&'+STR0009) //"Premio"

Aadd(aPages,"HEADER")

aSize := MsAdvSize()

AAdd( aObjects, { 100, 40, .T., .T. } )
AAdd( aObjects, { 100, 100, .T., .T.,.T.} )

aInfo := {aSize[1],aSize[2],aSize[3],aSize[4],3,3}

aPosObj := MsObjSize( aInfo, aObjects,.T.)

Inclui := ((nOpcX==3).Or.(nOpcX==4)) //-- Impede que a Descricao apareca na inclusao de itens durante a alteracao

DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],00 TO aSize[6],aSize[5] OF oMainWnd PIXEL
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a Enchoice                                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oEnchoice:= MsMGet():New("DTS", nReg, nOpcx,,,,,aPosObj[1],,3,,,,,,.T. )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta o Objeto Folder                                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oFolder:=TFolder():New( aPosObj[2,1],aPosObj[2,2],aTitles,aPages,oDlg,,,,.T.,.T.,aPosObj[2,3],aPosObj[2,4])

	aPosGetD := { 5, 5, aPosObj[ 2, 4 ] - 18, aPosObj[ 2, 3 ] - 8 }

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Consistencia a cada mudanca de pasta do Objeto Folder                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oFolder:bSetOption:={|nAtu| TMSA220Muda(nAtu,oFolder:nOption)}

	For nCntFor := 1 To Len(oFolder:aDialogs)
		oFolder:aDialogs[nCntFor]:oFont := oDlg:oFont
	Next nCntFor

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Folder de Premio                                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aHeader	:={}
	aCols	:={}
	n		:= 1
	aHeader	:= aClone(aSvFolder[2,1])
	aCols	:= aClone(aSvFolder[2,2])
	aEval(aCols, {|x| IIF( Empty(x[GdFieldPos('DTM_ITEM')]), x[GdFieldPos('DTM_ITEM')]:= StrZero(1, Len(DTM->DTM_ITEM)), .T.) })
	aSvFolder[2,2] := aClone(aCols)
	o2Get:=MSGetDados():New( aPosGetD[1] ,aPosGetD[2],aPosGetD[3],aPosGetD[4],nOpcx,'TmsA220LOk','AllWaysTrue','+DTM_ITEM',.T.,,,,,,,,,oFolder:aDialogs[2])
	o2Get:oBrowse:Default()
	o2Get:oBrowse:lDisablePaint := .T.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Folder de Frete                                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aHeader 	:={}
	aCols		:={}
	n			:= 1
	aHeader 	:= aClone(aSvFolder[1,1])
	aCols		:= aClone(aSvFolder[1,2])
	aEval(aCols, {|x| IIF( Empty(x[GdFieldPos('DTT_ITEM')]), x[GdFieldPos('DTT_ITEM')]:= StrZero(1, Len(DTT->DTT_ITEM)), .T.) })
	aSvFolder[1,2] := aClone(aCols)
	o1Get:=MSGetDados():New( aPosGetD[1],aPosGetD[2],aPosGetD[3],aPosGetD[4],nOpcx,'TmsA220LOk','AllWaysTrue','+DTT_ITEM',.T.,,,,,,,,,oFolder:aDialogs[1])
	o1Get:oBrowse:Default()

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca:=1,Iif( TmsA220TOk(nOpcx),oDlg:End(),nOpca := 0)},{||oDlg:End()},, aButtons )

If	nOpca == 1 .And. nOpcx != 2
	Begin Transaction
		Processa({|| TMSA220Grava(nOpcx)},cCadastro)
	End Transaction
EndIf

SET KEY VK_F4 TO

RestArea(aAreaAnt)

Return NIL

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA220Grava  ³ Autor ³ Patricia A. Salomao  ³ Data ³07.02.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Grava a Tabela de Frete p/Carreteiros                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA220Grava(nOpcx)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Opcao Selecionada (Inclusao/Alteracao/Exclusao/...)            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³NIL                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±/*/
Function TMSA220Grava(nOpcx)

Local nI, nX, nY
Local aAreaDTS   := DTS->(GetArea())
Local lTMA220GRV := ExistBlock("TMA220GRV")

If nOpcx == 5

	DTS->(dbSetOrder(1))
	While DTS->(MsSeek(xFilial()+M->DTS_TABCAR+M->DTS_ROTA))
		RecLock("DTS",.F.)
		dbDelete()
		MsUnLock()
		DTS->(dbSkip())
	EndDo
	DTT->(dbSetOrder(1))
	While DTT->(MsSeek(xFilial()+M->DTS_TABCAR+M->DTS_ROTA))
		RecLock("DTT",.F.)
		dbDelete()
		MsUnLock()
		DTT->(dbSkip())
	EndDo
	DTM->(dbSetOrder(1))
	While DTM->(MsSeek(xFilial()+M->DTS_TABCAR+M->DTS_ROTA))
		RecLock("DTM",.F.)
		dbDelete()
		MsUnLock()
		DTM->(dbSkip())
	EndDo
EndIf

If nOpcx == 3  .Or. nOpcx == 4
	dbSelectArea("DTS")
	dbSetOrder(1)
	If MsSeek(xFilial()+M->DTS_TABCAR+M->DTS_ROTA)
		RecLock("DTS",.F.)
	Else
		RecLock("DTS",.T.)
	EndIf
	For nI := 1 TO FCount()
		If "FILIAL" $ Field(nI)
			FieldPut(nI,xFilial())
		Else
			FieldPut(nI,M->&(FieldName(nI)))
		EndIf
	Next
	MsUnLock()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Grava os Itens Informados no Folder de Frete                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aHeader := {}
	aCols   := {}
	aHeader := Aclone(aSvFolder[1,1])
	aCols   := Aclone(aSvFolder[1,2])
	DTT->(DbSetOrder(1))
	For nX := 1 to Len(aCols)
		If !GDDeleted( nX )
			dbSelectArea("DTT")
			If nX <= Len(aRecDTT)
				MsGoto(aRecDTT[nX])
				RecLock("DTT",.F.)
			Else
				RecLock("DTT",.T.)
			EndIf
			DTT->DTT_FILIAL := xFilial("DTT")
			DTT->DTT_TABCAR := M->DTS_TABCAR
			DTT->DTT_ROTA   := M->DTS_ROTA

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza os dados contidos na GetDados                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nY:= 1 to Len(aHeader)
				If aHeader[nY][10] # "V"
					DTT->(FieldPut(FieldPos(Trim(aHeader[nY][2])),aCols[nX][nY]))
				EndIf
			Next
			MsUnLock()
		Else
			If DTT->(MsSeek(xFilial()+M->DTS_TABCAR+M->DTS_ROTA+GdFieldGet('DTT_ITEM', nX)  ))
				RecLock( "DTT", .F. )
				DbDelete()
				MsUnLock()
			EndIf
		EndIf
	Next nX

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Grava os Dados informados no Folder de Premio                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aHeader := {}
	aCols   := {}
	aHeader := Aclone(aSvFolder[2,1])
	aCols	:= Aclone(aSvFolder[2,2])
	DTM->(DbSetOrder(1))
	For nX := 1 to Len(aCols)
		If !GDDeleted( nX ) .And. !Empty(GdFieldGet('DTM_PONTUA',nX))
			dbSelectArea("DTM")
			If nX <= Len(aRecDTM)
				MsGoto(aRecDTM[nX])
				RecLock("DTM",.F.)
			Else
				RecLock("DTM",.T.)
			EndIf
			DTM->DTM_FILIAL := xFilial("DTM")
			DTM->DTM_TABCAR := M->DTS_TABCAR
			DTM->DTM_ROTA   := M->DTS_ROTA
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza os dados contidos na GetDados                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nY:= 1 to Len(aHeader)
				If aHeader[nY][10] # "V"
					DTM->(FieldPut(FieldPos(Trim(aHeader[nY][2])),aCols[nX][nY]))
				EndIf
			Next
			MsUnLock()
		Else
			If DTM->(MsSeek(xFilial()+M->DTS_TABCAR+M->DTS_ROTA+GdFieldGet('DTM_ITEM', nX)))
				RecLock("DTM",.F.)
				DbDelete()
				MsUnLock()
			EndIf
		EndIf
	Next nX
EndIf

//-- Ponto de Entrada para a gravacao complementar.
If lTMA220GRV
	ExecBlock('TMA220GRV',.F.,.F.,{nOpcx})
EndIf

RestArea( aAreaDTS )

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA220LOk³ Autor ³ Alex Egydio          ³ Data ³09.04.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao da linha da getdados                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA220LOk()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TmsA220LOk()

Local aCampo	:= {}
Local lRet     := .T.
Local lTercRbq := DTT->(ColumnPos("DTT_FRORB3")) > 0

If !GDdeleted(n) .And. (lRet:=MaCheckCols(aHeader,aCols,n))
	If lTercRbq
		If	( GDFieldPos('DTT_TIPVEI') ) > 0
			//-- Valida getdados Frete
			If	( GDFieldPos('DTT_TIPVIA') ) > 0
					aCampo := { 'DTT_TIPVEI', 'DTT_FRORB1', 'DTT_FRORB2','DTT_VEIRAS', 'DTT_TIPVIA','DTT_FRORB3' }
			Else
					aCampo := { 'DTT_TIPVEI', 'DTT_FRORB1', 'DTT_FRORB2','DTT_VEIRAS', 'DTT_FRORB3' }
			EndIf
		ElseIf	( GDFieldPos('DTM_PONTUA') ) > 0
			//-- Valida getdados Premio
			aCampo := { 'DTM_PONTUA' }
		EndIf
	Else
		If	( GDFieldPos('DTT_TIPVEI') ) > 0
			//-- Valida getdados Frete
			If	( GDFieldPos('DTT_TIPVIA') ) > 0
					aCampo := { 'DTT_TIPVEI', 'DTT_FRORB1', 'DTT_FRORB2','DTT_VEIRAS', 'DTT_TIPVIA' }
			Else
					aCampo := { 'DTT_TIPVEI', 'DTT_FRORB1', 'DTT_FRORB2','DTT_VEIRAS' }
			EndIf
		ElseIf	( GDFieldPos('DTM_PONTUA') ) > 0
			//-- Valida getdados Premio
			aCampo := { 'DTM_PONTUA' }
		EndIf
	EndIf
	//-- Analisa se ha itens duplicados na GetDados.
	lRet := GDCheckKey( aCampo, 4 )
	If lRet .And. GdFieldPos('DTT_TIPVEI') > 0
		DUT->(dbSetOrder(1))
		DUT->(MsSeek(xFilial('DUT')+ GdFieldGet('DTT_TIPVEI',n) ))
		If lTercRbq
			If DUT->DUT_CATVEI $ '24' .And. ( (GdFieldGet('DTT_FRORB2',n) =='0') .And. (GdFieldGet('DTT_FRORB1',n) == "0") .And. (GdFieldGet('DTT_FRORB3',n) == "0"))
				Help('',1,'TMSA22003') //-- E obrigatorio informar 1o/2o/3o Reboque para os Veiculos de Categoria "Cavalo" / "Especial"
				lRet := .F.
			EndIf
		Else
			If DUT->DUT_CATVEI $ '24' .And. ( (GdFieldGet('DTT_FRORB2',n) =='0') .And. (GdFieldGet('DTT_FRORB1',n) == "0"))
				Help('',1,'TMSA22003') //-- E obrigatorio informar 1o/2o Reboque para os Veiculos de Categoria "Cavalo" / "Especial"
				lRet := .F.
			EndIf
		EndIf
	EndIf
	If lRet .And. GdFieldPos('DTT_INTERV') > 0
		If ( (GdFieldGet('DTT_INTERV',n) == 0)) .And. ( (GdFieldGet('DTT_TIPCAL',n) <> '1'))
			Help('',1,'TMSA22008') //-- A fração é obrigatoria para tipcal = 2 (Capac.Veiculo) / 3 (km) / 4 (Peso) / 5 (Peso Cubado)
			lRet := .F.
		EndIf
	EndIf

EndIf

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA220TOk   ³ Autor ³Patricia A. Salomao    ³ Data ³07.02.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Consistencia Geral.                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA220TOK(nOpcx)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Opcao Selecionada (Inclusao/Alteracao/Exclusao/...)            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³Logico                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA220                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA220TOK(nOpcx)

Local aHeaAnt	:= aClone( aHeader )
Local aColAnt	:= aClone( aCols )
Local aGetDad	:= { o1Get, o2Get }
Local lRet		:= .T.
Local nCntFor	:= 0
Local n1Cnt		:= 0
Local nSavN		:= n
Local lTM220TOK:= ExistBlock("TM220TOK")

//-- Analisa se os campos obrigatorios da Enchoice foram informados.
lRet := Obrigatorio(aGets,aTela)

If lRet
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza o Folder com os dados do aCols                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aSvFolder[oFolder:nOption][2] := Aclone(aCols)
EndIf

//-- Varre os folders
If lRet

	aHeader	:= aClone( aSvFolder[ 1, 1 ] )
	aCols	:= aClone( aSvFolder[ 1, 2 ] )

	//-- Analisa se todas os itens da GetDados estao deletados.
	If Ascan( aCols, { |x| x[ Len( x ) ] == .F. } ) == 0
		Help( ' ', 1, 'OBRIGAT2') //Um ou alguns campos obrigatorios nao foram preenchidos no Browse"
		lRet := .F.
	EndIf

	If lRet
		For n1Cnt := 1 To Len( aCols )
			//-- Analisa se os campos obrigatorios da GetDados foram informados.
			If	!GDDeleted( n1Cnt )
				If !(	lRet := aGetDad[ 1 ]:ChkObrigat( n1Cnt ) )
					Exit
				EndIf
				//-- Analisa o linha ok.
				n := n1Cnt
				If !(	lRet := TmsA220LOk() )
					Exit
				EndIf
			EndIf
		Next
	EndIf
EndIf

If	lRet
	//-- Executa ponto de entrada
	If	lTM220TOK
		lRet := ExecBlock('TM220TOK',.F.,.F.,{nOpcx})
		If ValType(lRet) <> "L"
			lRet:=.T.
		EndIf
	EndIf
EndIf

aHeader:= aClone( aHeaAnt )
aCols  := aClone( aColAnt )
n      := nSavN

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA220IniVar³ Autor ³Patricia A. Salomao ³ Data ³07.02.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Configura variaveis para as Pastas                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA220IniVar(ExpC1,ExpC2,ExpC3,ExpN1,ExpN2)               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do Arquivo                                   ³±±
±±³          ³ ExpC2 = Chave para posicionar o registro                   ³±±
±±³          ³ ExpC3 = Expressao do While                                 ³±±
±±³          ³ ExpN1 = Numero do Indice                                   ³±±
±±³          ³ ExpN2 = Numero da Pasta                                    ³±±
±±³          ³ ExpA1 = Campos que nao deverao aparecer no aCols           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TMS220IniVar(cAlias,cSeek,cWhile,nIndex,nFolder, aNoFields)

Local aAreaAnt	:= GetArea()
Local aHTmp		:= {}
Local aCTmp		:= {}
Local nCntFor	:= 0

aHTmp := APBuildHeader(cAlias, aNoFields)

DbSelectArea(cAlias)
DbSetOrder(nIndex)
MsSeek( cSeek )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta aCols                                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Do While !Eof() .And. &( cWhile ) == cSeek
	TMSA220Cols(cAlias,aHTmp,@aCTmp)
	If cAlias == "DTT"
		AADD(aRecDTT,DTT->(Recno()))
	EndIf
	If cAlias = "DTM"
		AADD(aRecDTM,DTM->(Recno()))
	EndIf
	dbSelectArea(cAlias)
	dbSkip()
EndDo
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Se aCols vazio inicializa com uma linha em branco                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If	Empty(aCTmp)
	Aadd(aCTmp,Array(Len(aHTmp)+1))
	For nCntFor := 1 To Len(aHTmp)
		aCTmp[1,nCntFor] := CriaVar(aHTmp[nCntFor,2])
	Next
	aCTmp[1,Len(aHTmp)+1] := .F.
EndIf

aSvFolder[nFolder][1] := aClone(aHTmp)
aSvFolder[nFolder][2] := aClone(aCTmp)
aSvFolder[nFolder][3] := Len(aCTmp)

RestArea(aAreaAnt)

Return NIL

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA220Head  ³ Autor ³Patricia A. Salomao ³ Data ³07.02.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta aHeader                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA220Head(ExpC1)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do Arquivo                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Array contendo o aHeader                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±/*/
Function TMSA220Head(cAlias, aNoFields)

Return APBuildHeader(cAlias, aNoFields)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA220Cols  ³ Autor ³Patricia A. Salomao ³ Data ³07.02.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta aCols                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA220Cols(ExpC1,ExpA1,ExpA2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do Arquivo                                   ³±±
±±³          ³ ExpA1 = Vetor aHeader                                      ³±±
±±³          ³ ExpA2 = Vetor aCols, passado por referencia                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±/*/
Function TMSA220Cols(cAlias,aHTmp,aCTmp)

Local nCntFor

DbSelectArea(cAlias)

Aadd(aCTmp,Array(Len(aHTmp)+1))
For nCntFor := 1 To Len(aHTmp)
	If	aHTmp[nCntFor,10] != "V"
		aCTmp[Len(aCTmp),nCntFor]:=FieldGet(FieldPos(aHTmp[nCntFor,2]))
	Else
		aCTmp[Len(aCTmp),nCntFor]:=CriaVar(aHTmp[nCntFor,2])
	EndIf
Next nCntFor

aCTmp[Len(aCTmp),Len(aHTmp)+1]:=.F.

Return NIL

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA220Mud³ Autor ³Patricia A. Salomao    ³ Data ³07.02.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Checa a mudanca de pasta no Objeto Folder                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA220Muda(ExpN1,ExpN2)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Numero do Folder que se deseja Ir.                 ³±±
±±³	         ³ ExpN2 = Numero do Folder Atual.                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function TMSA220Muda(nIndo,nEstou)

Local lRet:=.T.

If lRet

	If nEstou == 1				// Se estiver no folder de Servico
		//
		// Esconde a GetDados
		//
		o1Get:oBrowse:lDisablePaint := .T.

		//
		// Atualiza matriz atraves do aCols alterado
		//
		aSvFolder[1][1]:= Aclone(aHeader)
		aSvFolder[1][2]:= Aclone(aCols)
		aSvFolder[1][3]:= Len(aCols)

	ElseIf nEstou == 2		// Se estiver no folder de Notas Fiscais
		//
		// Esconde a GetDados
		//
		o2Get:oBrowse:lDisablePaint := .T.

		//
		// Atualiza matriz atraves do aCols alterado
		//
		aSvFolder[2][1]:= Aclone(aHeader)
		aSvFolder[2][2]:= Aclone(aCols)
		aSvFolder[2][3]:= Len(aCols)
	EndIf

	If	nIndo == 1			// Se estiver indo para o folder de Servico
		//
		// Mostra a GetDados
		//
		o1Get:oBrowse:nAt	:= 1
		o1Get:oBrowse:lDisablePaint := .F.
		//
		// Atualiza aHeader e aCols com dados
		//
		aHeader	:={}
		aCols		:={}
		aHeader 	:= Aclone(aSvFolder[1,1])
		aCols		:= Aclone(aSvFolder[1,2])
		n			:= Len(aCols)
		//
		// Refresh na tela
		//
		o1Get:oBrowse:Refresh(.T.)
		o1Get:ForceRefresh()
		oDlg:Refresh()

	ElseIf nIndo == 2
		//
		// Mostra a GetDados
		//
		o2Get:oBrowse:nAt	:= 1
		o2Get:oBrowse:lDisablePaint := .F.

		//
		// Atualiza aHeader e aCols
		//
		aHeader	:={}
		aCols	:={}
		aHeader := Aclone(aSvFolder[2,1])
		aCols	:= Aclone(aSvFolder[2,2])
		n		:= Len(aCols)
		//
		// Refresh
		//
		o2Get:oBrowse:Refresh(.T.)
		o2Get:ForceRefresh()
		oDlg:Refresh()
	EndIf

	oFolder:Refresh(.T.)
	nEstou := nIndo

EndIf

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA220Tab³ Autor ³Patricia A. Salomao    ³ Data ³07.02.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida o Codigo da Tabela Digitado.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA220TABCAR()                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function TMSA220TABCAR()

Local aArea := GetArea()
Local lRet  := .T.
DTS->(dbSetOrder(1) )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se todos os campos da chave estiverem preenchidos verificar se a Tabela   ³
//³ ja existe no arquivo DTS                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(M->DTS_TABCAR) .And. !Empty(M->DTS_ROTA)
	If DTS->(MsSeek(xFilial()+M->DTS_TABCAR+M->DTS_ROTA) )
		Help("",1,"TMSA22001") // Tabela de Carreteiro para Motoristas Ja Cadastrada ...
		lRet := .F.
	EndIf
EndIf

RestArea(aArea)

Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA220Cop  ³ Autor ³ Patricia A. Salomao ³ Data ³07.02.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Copia a Tabela de Carreteiro                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA220Cop()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±/*/
Function TMSA220Cop()

Local oBold
Local oDlg
Local cNewTab     := Space(Len(DTS->DTS_TABCAR))
Local cRotaDe     := Space(Len(DTS->DTS_ROTA))
Local cRotaAte    := "ZZZZZZ"
Local aAreaDTM    := DTM->(GetArea())
Local aAreaDTT    := DTT->(GetArea())
Local nRecDTS     := DTS->( Recno() )
Local nOpc        := 2
Local cKeyDTS     := DTS->DTS_TABCAR
Local cKeyDTM     := ''
Local cKeyDTT     := ''
Local cDescTab    := ''
Local cDescNewOri := ''
Local aCampos     := {}

Inclui := .T.

cDescTab    := Posicione("DUS",1,xFilial("DUS")+DTS->DTS_TABCAR,"DUS_DESCRI")
cDescNewOri := ''

DEFINE MSDIALOG oDlg TITLE STR0025 From 9,0 To 23,50 OF oMainWnd //"Copiar Tabela de Carreteiro"

	@ 010,010 SAY STR0026 SIZE 100,15 COLOR CLR_HBLUE PIXEL FONT oBold 	//"Da Tabela : "
	@ 025,010 SAY STR0027 SIZE 100,15 COLOR CLR_HBLUE PIXEL FONT oBold 	//"Rota De   : "
	@ 025,090 SAY STR0028 SIZE 100,15 COLOR CLR_HBLUE PIXEL FONT oBold 	//"Rota Ate  : "
	@ 055,010 SAY STR0029 SIZE 100,15 COLOR CLR_HBLUE PIXEL FONT oBold 	//"Para a Tabela"

	@ 010,040 SAY cKeyDTS + ' - ' + cDescTab  SIZE 200,15 PIXEL
	@ 025,040 MSGET cRotaDe  F3 "DA8"  PICTURE PesqPict("DTS","DTS_ROTA") SIZE 6,9  PIXEL
	@ 025,130 MSGET cRotaAte F3 "DA8"  PICTURE PesqPict("DTS","DTS_ROTA") SIZE 6,9  PIXEL
	@ 055,050 MSGET cNewTab  F3 "DUS"  PICTURE PesqPict("DTS","DTS_TABCAR") SIZE 6,9 WHEN ( DbGoTo( nRecDTS ), .T. ) ;
									VALID cNewTab <> DTS->DTS_TABCAR .And. TMSA220Cpo(cNewTab,@cDescNewOri) .And. !Empty(cNewTab) PIXEL
	@ 055,085 MSGET cDescNewOri When .F. SIZE 70,9  OF oDlg PIXEL

	DEFINE SBUTTON FROM 85,118	TYPE 1 ACTION (nOpc := 1,oDlg:End()) ENABLE OF oDlg
	DEFINE SBUTTON FROM 85,155	TYPE 2 ACTION (nOpc := 2,oDlg:End()) ENABLE OF oDlg

ACTIVATE MSDIALOG oDlg CENTERED

DTS->( DbGoto( nRecDTS ) )

IF nOpc == 1 .AND. Aviso( STR0010 , STR0030 +'"'+ AllTrim(DTS->DTS_TABCAR) +'"'+ CRLF + ; //"AVISO" ### "Copiar a Tabela de Carreteiro "
								STR0024 + '"'+AllTrim(cNewTab)+'"', { STR0020 ,  STR0023 },, STR0022 ) == 1 //"para a NOVA Tabela " ### "Confirma" ### "Abandona" ### "Confirmacao"
	cKeyDTS := xFilial("DTS")+ DTS->DTS_TABCAR
	CursorWait()
	dbSelectArea( "DTS" )
	dbSetOrder(1)
	MsSeek(cKeyDTS,.T.)
	Do While !DTS->(Eof()) .And. xFilial("DTS") + DTS->DTS_TABCAR + DTS->DTS_ROTA <= cKeyDTS+cRotaAte

		aArea :=DTS->(GetArea())

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se ja existe uma tabela com a nova Regiao Origem/Destino ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If  DTS->(MsSeek(xFilial('DTS')+cNewTab+DTS_ROTA))
			RestArea(aArea)
			DTS->(dbSkip())
			Loop
		EndIf

		RestArea(aArea)

		cKeyDTM := xFilial("DTM") + DTS->DTS_TABCAR + DTS->DTS_ROTA
		cKeyDTT := xFilial("DTT") + DTS->DTS_TABCAR + DTS->DTS_ROTA
		aCampos := {}
		Aadd( aCampos, { "DTS_TABCAR", cNewTab } )
		//-- Copia Cabecalho
		DTS->(TmsCopyReg(aCampos))

		DbSelectArea( "DTM" )
		DbSetOrder(1)
		MsSeek( cKeyDTM )
		aCampos := {}
		Aadd( aCampos, { "DTM_TABCAR", cNewTab } )
		Do While cKeyDTM == xFilial("DTM") + DTM_TABCAR + DTM_ROTA
			aAreaDTM := DTM->(GetArea())
			//-- Copia Dados do Frete
			DTM->(TmsCopyReg(aCampos))
			RestArea( aAreaDTM )
			DbSkip()
		EndDo

		dbSelectArea( "DTT" )
		DbSetOrder(1)
		MsSeek( cKeyDTT )
		aCampos := {}
		Aadd( aCampos, { "DTT_TABCAR", cNewTab } )
		Do While cKeyDTT == xFilial("DTT") + DTT_TABCAR + DTT_ROTA
			aAreaDTT := DTT->(GetArea())
			//-- Copia Dados do Premio
			DTT->(TmsCopyReg(aCampos))
			RestArea( aAreaDTT )
			DbSkip()
		EndDo

		RestArea(aArea)
		DTS->( dbSkip() )

	EndDo

EndIf
DTS->( DbGoto( nRecDTS ) )
CursorArrow()

Return NIL

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA220Cpo() ³ Autor ³Patricia A. Salomao ³ Data ³ 26/07/2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Inicializa alguns campos a partir da Regiao Origem informada ³±±
±±³          ³ na Copia da Tabela de Carreteiro                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA220Cpo(cNewTab,cDescNewOri)

Local lRet := .T.
Local aAreaDUS := DTS->(GetArea())

If lRet
	If DUS->(MsSeek(xFilial('DUS')+cNewTab))
		cDescNewOri := Posicione("DUS",1, xFilial("DUS")+ cNewTab, "DUS_DESCRI")
		lRet := .T.
	Else
		Help("",1,"REGNOIS") //Nao existe registro relacionado a este codigo.
		lRet := .F.
	EndIf
EndIf
RestArea(aAreaDUS)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA220Vld³ Autor ³ Patricia A. Salomao  ³ Data ³22.07.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacoes do sistema                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA220Vld()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA220                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TMSA220Vld()

Local cCampo := ReadVar()
Local lRet   := .T.
Local lTercRbq := DTT->(ColumnPos("DTT_FRORB3")) > 0

If cCampo == 'M->DTS_TABCAR'
	DUS->(dbSetOrder(1))
	If !DUS->(MsSeek(xFilial('DUS')+M->DTS_TABCAR))
		Help("",1,"TMSA22006") // Nao foi Cadastrado Vigencia para esta Tabela de Carreteiro ...
		Return( .F. )
	EndIF
ElseIf cCampo == 'M->DTT_TIPVEI'
	DUT->(dbSetOrder(1))
	DUT->(MsSeek(xFilial('DUT')+M->DTT_TIPVEI))
	If DUT->(Eof())
		Help('',1,'TMSA24011') //-- Nao foi encontrado Categoria de Veiculo para este Tipo de Veiculo
		Return( .F. )
	EndIf
	If DUT->DUT_CATVEI == '3'
		Help('',1,'TMSA24009') //-- Nao poderao ser Informados Veiculos com categoria igual a "3" (Carreta)
		Return( .F. )
	EndIf
	If DUT->DUT_CATVEI $ '1' //-- Comum
		GdFieldPut('DTT_FRORB1',"0",n)
		GdFieldPut('DTT_FRORB2',"0",n)
		If lTercRbq
			GdFieldPut('DTT_FRORB3',"0",n)
		EndIf
	ElseIf DUT->DUT_CATVEI $ '24' //-- Cavalo ou Especial
		GdFieldPut('DTT_FRORB1',"2",n)
		GdFieldPut('DTT_FRORB2',"2",n)
		If lTercRbq
			GdFieldPut('DTT_FRORB3',"2",n)
		EndIf
	EndIf
ElseIf cCampo == 'M->DTT_TIPCAL'
	If M->DTT_TIPCAL == '1' //-- Tipo do Calculo Por Valor
		GdFieldPut('DTT_INTERV',0, n)	 // Nao Informa Fracao
	ElseIf M->DTT_TIPCAL == '3' //-- Calculo do Frete Por Km
		DA8->(dbSetOrder(1))
		If DA8->(MsSeek(xFilial('DA8')+M->DTS_ROTA)) .And. DA8->DA8_SERTMS $ '1;3'
			Help('',1,'TMSA22007') // A Rota informada e' de Entrega/Coleta, portanto o Tipo do Calculo nao podera ser por "km" ...
			Return ( .F. )
		EndIf
	EndIf

EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA220Whe³ Autor ³ Patricia A. Salomao  ³ Data ³26.07.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacoes p/ edicao do campo (X3_WHEN)                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA220Whe()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA220                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TMSA220Whe()

Local cCampo   := ReadVar()
Local lRet     := .T.
Local lTercRbq := DTT->(ColumnPos("DTT_FRORB3")) > 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Somente permitir a digitacao da Frota 1o. 2o.Reboque e 3o.Reboque caso o   ³
//³veiculo seja de categoria 2=Cavalo ou 4=Especial.                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lTercRbq
	If cCampo $ 'M->DTT_FRORB1.M->DTT_FRORB2.M->DTT_FRORB3'
		DUT->(dbSetOrder(1))
	   	DUT->(MsSeek(xFilial('DUT')+GdFieldget('DTT_TIPVEI',n) ))
		lRet := (DUT->DUT_CATVEI=='2' .Or. DUT->DUT_CATVEI=='4')
	ElseIf cCampo $ 'M->DTT_INTERV' //So deixar o campo Fracao ativo se o Calculo for igual a "Capac.Veiculo" /"Km" / "Peso" / "Peso Cubado"
		 lRet := GdFieldget('DTT_TIPCAL',n) $ '2;3;4;5'
	EndIf
Else
	If cCampo $ 'M->DTT_FRORB1.M->DTT_FRORB2'
		DUT->(dbSetOrder(1))
	   	DUT->(MsSeek(xFilial('DUT')+GdFieldget('DTT_TIPVEI',n) ))
		lRet := (DUT->DUT_CATVEI=='2' .Or. DUT->DUT_CATVEI=='4')
	ElseIf cCampo $ 'M->DTT_INTERV' //So deixar o campo Fracao ativo se o Calculo for igual a "Capac.Veiculo" /"Km" / "Peso" / "Peso Cubado"
		 lRet := GdFieldget('DTT_TIPCAL',n) $ '2;3;4;5'
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA220Inc³ Autor ³ Patricia A. Salomao  ³ Data ³26.07.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Testa Inclusao Duplicada                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA220Inc()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSA220                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TMSA220Inc()

Local lRet := .T.
Local aArea:= DTS->(GetArea())

DTS->(dbSetOrder(1))

If DTS->(MsSeek(xFilial("DTS")+M->DTS_TABCAR+M->DTS_ROTA))
	Help("",1,"JAGRAVADO") //"Ja existe registro com esta informacao"
	lRet := .F.
EndIf

RestArea(aArea)
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Marco Bianchi         ³ Data ³01/09/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³    1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()

Private aRotina	:= {	{STR0002, "AxPesqui"  ,0,1,0,.F.},; //"Pesquisar"
						{STR0003 ,"TMSA220Mnt",0,2,0,NIL},; //"Visualizar"
						{STR0004 ,"TMSA220Mnt",0,3,0,NIL},; //"Incluir"
						{STR0005 ,"TMSA220Mnt",0,4,0,NIL},; //"Alterar"
						{STR0006 ,"TMSA220Mnt",0,5,0,NIL},; //"Excluir"
						{STR0007 ,"TMSA220Cop",0,6,0,NIL} } //"Copiar"

If ExistBlock("TMA220MNU")
	ExecBlock("TMA220MNU",.F.,.F.)
EndIf

Return(aRotina)
