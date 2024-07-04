#INCLUDE "TMSA570.ch"
#Include 'Protheus.ch'

Static nPFilDoc   	:= 0
Static nPDoc      	:= 0
Static nPSerie    	:= 0
Static nPNF       	:= 0
Static nPSerNF		:= 0

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ TMSA570  ³ Autor ³Patricia A. Salomao    ³ Data ³ 21.08.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Comprovante de Entrega                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA570()                                                    ³±±
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
Function TMSA570()
Local lPainel := .F.

Private cCadastro	:= STR0001 //'Comprovante de Entrega'
Private aRotina   := MenuDef()

If Type("aPanAgeTMS") == "U"
	aPanAgeTMS := Array(6)
EndIf

lPainel := IsInCallStack("TMSAF76") .And. !Empty(aPanAgeTMS)

If !lPainel
	mBrowse( 6,1,22,75,'DU1')
Else
	If (at("(",aPanAgeTMS[6])>0)
		&(aPanAgeTMS[6])
	Else
		&(aPanAgeTMS[6] + "('" + aPanAgeTMS[1] + "'," + StrZero(aPanAgeTMS[2],10) + "," + StrZero(aPanAgeTMS[3],2) + ")")
	Endif
EndIf

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA570Mnt³ Autor ³ Patricia A. Salomao   ³ Data ³21.08.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Manutencao dos Comprovantes de Entrega                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA570Mnt(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TMSA570Mnt( cAlias, nReg, nOpcx)

//-- EnchoiceBar
Local aVisual	  := {}
Local aButtons	  := {}
Local aNoFields	  := {}
Local aYesFields  := {}
Local aObjects	  := {}
Local aInfo		  := {}
Local aSize       := {}
Local aPosObj	  := {}
Local bSeekFor    := { || .T. }
Local aAlter
Local aAltEnc
Local nOpca		  := 0
Local oEnchoice, oDlg
Local oCpyData    := Nil
Local lHasFldDt    := (DU1->(ColumnPos('DU1_DATENT')) > 0 .And. DU1->(ColumnPos('DU1_DATCNT')) > 0 .And. DU1->(ColumnPos('DU1_HORENT')) > 0 .And. DU1->(ColumnPos('DU1_HORCNT')) > 0)
Local nMax		  := 999

Private aTela[0][0], aGets[0]
Private aHeader	   := {}
Private aCols	   := {}
Private __nDelItem := 0
Private oGetD
Private lCpyData     := .F.

//-- Configura variaveis da Enchoice
RegToMemory( cAlias, nOpcx==3 )

cCadastro:= STR0001 //'Comprovante de Entrega'

Aadd( aVisual, 'DU1_LOTCET' )
Aadd( aVisual, 'DU1_DATLOT' )
Aadd( aVisual, 'DU1_CODCLI' )
Aadd( aVisual, 'DU1_LOJCLI' )
Aadd( aVisual, 'DU1_NOMCLI' )

aNoFields := aClone( aVisual )

If nOpcx == 3 // Inclusao
	Aadd(aNoFields, 'DU1_ESTORN')
EndIf

If nOpcx == 4 // Estorno
	aAlter := {'DU1_ESTORN'}
	aAltEnc:= {}
EndIf

//-- Configura variaveis da GetDados
TMSFillGetDados( nOpcx, 'DU1', 1, xFilial( 'DU1' ) + M->DU1_LOTCET, { ||  DU1->(DU1_FILIAL + DU1_LOTCET) },;
bSeekFor, aNoFields,	aYesFields )

//-- Dimensoes padroes
aSize := MsAdvSize()
AAdd( aObjects, { 100, 50, .T., .T. } )
AAdd( aObjects, { 100, 100, .T., .T. } )
aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aPosObj := MsObjSize( aInfo, aObjects,.T.)

DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],00 TO aSize[6],aSize[5] PIXEL

oEnchoice := MsMGet():New( cAlias, nReg, nOpcx,,,, aVisual, aPosObj[1], aAltEnc, 3,,,,,,.T. )

//        MsGetDados(nT , nL, nB, nR, nOpc, cLinhaOk, cTudoOk, cIniCpos, lDeleta, aAlter, nFreeze, lEmpty, nMax, cFieldOk, cSuperDel, aTeclas, cDelOk, oWnd)
oGetD := MSGetDados():New(aPosObj[ 2, 1 ], aPosObj[ 2, 2 ],aPosObj[ 2, 3 ], aPosObj[ 2, 4 ], nOpcx,'TMSA570LinOk','TmsA570TudOk', ,nOpcx==3, aAlter,,,nMax,,,,Iif(nOpcx ==3,"TMSA570Del()",Nil))

If nOpcx == 4
	oGetD:oBrowse:bAdd := { || .F. }	 // Nao Permite Incluir Linhas

//--Inclui funcao de mudanca de linha e repeticao de data/hora de entrega e dos canhotos
Else
     oGetD:oBrowse:bChange := {|| TMSA570Chg() }
EndIf

     //-- Repetir conteudo de Data e Hora de Entrega e Recebimento do Canhoto no proximo item da Gride
     If lHasFldDt
           @ aPosObj[2,1]-15,aPosObj[2,2]+20 CHECKBOX oCpyData VAR lCpyData PROMPT STR0007 SIZE 100,010 Pixel 
           oCpyData:lReadOnly := ( nOpcx == 4) //-- Desabilitado para a opcao de estorno
     EndIf

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||Iif( oGetD:TudoOk(), (nOpca := 1,oDlg:End()), (nOpca :=0, .F.))},{||nOpca:=0,oDlg:End()},, aButtons )

If nOpcA == 1 .And. nOpcx <> 2
	Begin Transaction
	Processa({|| TMSA570Grv(nOpcx)}, cCadastro)
	If __lSX8
		ConfirmSX8()
	EndIf
	End Transaction
Else
	If ( __lSX8 )
		RollBackSX8()
	EndIf
EndIf

//-- Limpa marcas dos agendamentos
If !IsInCallStack("TMSAF76")
	TMSALimAge(StrZero(ThreadId(),20))
EndIf

Return Nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA570Lin³ Autor ³ Patricia A. Salomao   ³ Data ³23.08.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacoes da linha da GetDados                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA570LinOk()                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TmsA570LinOk()

Local lRet		:= .T.
//-- Nao avalia linhas deletadas.
If !GDdeleted(n) .And. (lRet:=MaCheckCols(aHeader,aCols,n))
	//-- Analisa se ha itens duplicados na GetDados.
	lRet := GDCheckKey( { 'DU1_FILDOC', 'DU1_DOC', 'DU1_SERIE', 'DU1_NUMNFC', 'DU1_SERNFC'  }, 4 )
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA570Tud³ Autor ³ Patricia A. Salomao   ³ Data ³23.08.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao Geral da Tela                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA570TudOk()                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TmsA570TudOk()

Local lRet	:= .T.

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA570Whe³ Autor ³ Patricia A. Salomao   ³ Data ³23.08.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao dos Campos                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA570Whe()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TMSA570Whe()

Local cCampo    := ReadVar()
Local lRet      := .T.

If cCampo == 'M->DU1_FILDOC' .Or. cCampo == 'M->DU1_DOC' .Or. cCampo == 'M->DU1_SERIE' .Or. ;
	cCampo == 'M->DU1_NUMNFC' .Or. cCampo == 'M->DU1_SERNFC'
	If !Empty( GDFieldGet( 'DU1_NUMNFC', n ))
		Help("",1,"TMSA57003")   // Os Dados Nao Poderao ser Alterados ...
		lRet := .F.
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA570Grv³ Autor ³ Patricia A. Salomao   ³ Data ³22.08.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava os Dados                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA570Grv(ExpN1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Opcao Selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TMSA570Grv(nOpcx)

Local na
Local cFilDoc := ""
Local cDoc    := ""
Local cSerie  := ""
Local nX, nY, nZ

If nOpcx == 3  //Inclusao
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Grava os Dados da Nota Fiscal                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DU1->(DbSetOrder(1))
	For nX := 1 to Len(aCols)
		If !GdDeleted(nX)
			RecLock("DU1",.T.)
			For nZ := 1 TO FCount()
				If "FILIAL"$Field(nZ)
					FieldPut(nZ,xFilial('DU1'))
				Else
					If TYPE("M->"+FieldName(nZ)) <> "U"
						FieldPut(nZ,M->&(FieldName(nZ)))
					EndIf
				EndIf
			Next nZ
			For nY:= 1 to Len(aHeader)
				If aHeader[nY][10] # "V"
					DU1->(FieldPut(FieldPos(Trim(aHeader[nY][2])),aCols[nX][nY]))
				EndIf
			Next
			MsUnLock()
			
			cFilDoc  := GdFieldGet('DU1_FILDOC',nX)
			cDoc     := GdFieldGet('DU1_DOC'   ,nX)
			cSerie   := GdFieldGet('DU1_SERIE' ,nX)
			DT6->(dbSetOrder(1))
			If DT6->(MsSeek(xFilial('DT6')+cFilDoc+cDoc+cSerie)) .And.  Empty(DT6->DT6_LOTCET)
				RecLock('DT6', .F.)
				DT6->DT6_LOTCET := M->DU1_LOTCET
				MsUnLock()
			EndIf
			
		EndIf
	Next nX
	
ElseIf nOpcx == 4 // Estorno
	DU1->(dbSetOrder(2))
	For nA:=1 to Len(aCols)
		If GdFieldGet('DU1_ESTORN',nA) == '1'
			cFilDoc  := GdFieldGet('DU1_FILDOC',nA)
			cDoc     := GdFieldGet('DU1_DOC',nA)
			cSerie   := GdFieldGet('DU1_SERIE',nA)
			
			If DU1->(MsSeek(xFilial('DU1')+ cFilDoc + cDoc+ cSerie +;
				GdFieldGet('DU1_NUMNFC',nA)+GdFieldGet('DU1_SERNFC',nA) ))
				DT6->(dbSetOrder(1))
				If DT6->(MsSeek(xFilial('DT6')+ cFilDoc + cDoc + cSerie)) .And. !Empty(DT6->DT6_LOTCET)
					RecLock("DT6", .F.)
					DT6->DT6_LOTCET := CriaVar('DT6_LOTCET', .F.)
					DT6->(MsUnLock())
				EndIf
				RecLock("DU1", .F.)
				dbDelete()
				DU1->(MsUnLock())
			EndIf
		EndIf
	Next nA
	
EndIf

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA570Vld³ Autor ³ Patricia A. Salomao   ³ Data ³22.08.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida os Campos                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA570Vld()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TMSA570Vld()

Local aPerfil	:= {}
Local cCampo  := ReadVar()
Local lRet    := .T.
Local cFilDoc := ""
Local cDoc    := ""
Local cSerie  := "" 
Local cFilDCO := ""
Local cDocDCO := ""
Local cSerDCO := ""  
Local cDocTMS := ""

If cCampo $ 'M->DU1_CODCLI.M->DU1_LOJCLI'
	SA1->(dbSetOrder(1))
	If !SA1->(MsSeek(xFilial('SA1')+M->DU1_CODCLI+AllTrim(M->DU1_LOJCLI) ))
		Help('',1,'REGNOIS') //"Nao existe registro relacionado a este codigo"
		Return ( .F. )
	EndIf
	//-- Obtem o perfil do cliente ou cliente generico
	aPerfil := TmsPerfil(M->DU1_CODCLI,AllTrim(M->DU1_LOJCLI))
	If	Empty(aPerfil)
		Return(.F.)
	EndIf	

ElseIf cCampo $'M->DU1_FILDOC.M->DU1_DOC.M->DU1_SERIE'
	
	//-- Verifica se o Filial Documento + Documento + Serie ja foram Informados
	If cCampo == 'M->DU1_FILDOC'
		cFilDoc := M->DU1_FILDOC
		cDoc    := GDFieldGet( 'DU1_DOC'  , n )
		cSerie  := GDFieldGet( 'DU1_SERIE', n )
	ElseIf cCampo == 'M->DU1_DOC'
		cFilDoc := GDFieldGet( 'DU1_FILDOC', n )
		cDoc    := M->DU1_DOC
		cSerie  := GDFieldGet( 'DU1_SERIE' , n )
	ElseIf cCampo == 'M->DU1_SERIE'
		cFilDoc := GDFieldGet( 'DU1_FILDOC', n )
		cDoc    := GDFieldGet( 'DU1_DOC', n )
		cSerie  := M->DU1_SERIE
	EndIf
	
	If !Empty(cFilDoc) .And. !Empty(cDoc) .And. !Empty(cSerie)
		//-- Verifica se o agendamento está sendo utilizado por outro usuário no painel de agendamentos
		If !TMSAVerAge("1",cFilDoc,cDoc,cSerie,,,,,,,,,"2",.T.,.T.)
			Return .F.
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o Documento Informado foi Entregue                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SA1->(dbSetOrder(1))
		SA1->(MsSeek(xFilial('SA1')+M->DU1_CODCLI+AllTrim(M->DU1_LOJCLI) ))
		
		If Posicione("DT6",1,xFilial("DT6")+cFilDoc+cDoc+cSerie,"DT6_STATUS") != StrZero(7,Len(DT6->DT6_STATUS)) // Entregue
			Help("",1,"TMSA57006") // Documento ainda não foi entregue ...
			lRet := .F. 
		ElseIf !EmptY(Posicione("DT6",1,xFilial("DT6")+cFilDoc+cDoc+cSerie,"DT6_LOTCET")) 
			Help("",1,"TMSA57007") // Documento já possui lote de comprovante ...
			lRet := .F. 
		Else
			cFilDCO := Posicione("DT6",1,xFilial("DT6")+cFilDoc+cDoc+cSerie,"DT6_FILDCO") //-- buscar documento original
			cDocDCO := Posicione("DT6",1,xFilial("DT6")+cFilDoc+cDoc+cSerie,"DT6_DOCDCO")
			cSerDCO := Posicione("DT6",1,xFilial("DT6")+cFilDoc+cDoc+cSerie,"DT6_SERDCO")  
			cDocTMS := Posicione("DT6",1,xFilial("DT6")+cFilDoc+cDoc+cSerie,"DT6_DOCTMS")  
		EndIf  
					
		If lRet
			lRet := TMSA570Car(cFilDoc, cDoc, cSerie, cDocTMS,cFilDCO, cDocDCO, cSerDCO,) // Carrega o aCols com todas as Notas  relacionadas ao Documento 
		EndIf
	EndIf
	
ElseIf cCampo == 'M->DU1_ESTORN'
	If M->DU1_ESTORN == '1'
		DT6->(dbSetOrder(1))
		If DT6->(MsSeek(xFilial('DT6')+GDFieldGet('DU1_FILDOC', n)+GDFieldGet('DU1_DOC', n)+GDFieldGet('DU1_SERIE', n) ))
			If !Empty(DT6->DT6_NUM)
				Help("",1,"TMSA57005") // Este Item Nao podera ser Estornado, pois ja foi faturado ...
				lRet := .F.
			EndIf
		EndIf
	EndIf
	If lRet
		aEval(aCols, {|x| IIf( x[GdFieldPos('DU1_FILDOC')]+x[GdFieldPos('DU1_DOC')]+x[GdFieldPos('DU1_SERIE')]  == ;
		GdFieldGet('DU1_FILDOC',n)+ GdFieldGet('DU1_DOC',n) +GdFieldGet('DU1_SERIE',n), x[GdFieldPos("DU1_ESTORN")] := &(ReadVar()), .T.) })
	EndIf

//-- Valida a hora de entrega e do comprovantes de entrega
ElseIf cCampo $ 'M->DU1_HORENT.M->DU1_HORCNT'
       
       If !Empty(M->DU1_HORENT)
           lRet := AtVldHora(M->DU1_HORENT)
       EndIf
       If !Empty(M->DU1_HORCNT)
           lRet := AtVldHora(M->DU1_HORCNT)
       EndIf
     
//-- Valida a data de entrega e do comprovantes de entrega
ElseIf cCampo $ 'M->DU1_DATENT.M->DU1_DATCNT'


           If M->DU1_DATCNT > dDataBase .Or. M->DU1_DATENT > dDataBase
               Help("", 1, "TMSA57009", ,STR0008,1,4) //-- "O campo Data entrega ou Data Comprovante não pode ser maior que a data atual."
               lRet := .F.
           EndIf

EndIf

If !lRet
	//-- Limpa marcas dos agendamentos
	//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
	If !IsInCallStack("TMSAF76")
		TMSALimAge(StrZero(ThreadId(),20))
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA570Car³ Autor ³ Patricia A. Salomao   ³ Data ³22.08.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Preenche o aCols com todas as Notas Fiscais relacionadas ao³±±
±±³          ³ Documento.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA570Car(ExpC1, ExpC2, ExpC3)                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Filial do Documento                                ³±±
±±³          ³ ExpC2 - No. do Documento                                   ³±±
±±³          ³ ExpC3 - Serie do Documento                                 ³±±   
±±³          ³ ExpC4 - Tipo do Documento                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TMSA570Car(cFilDoc, cDoc, cSerie, cDocTMS, cFilDco, cDocDco, cSerDco)

Local lAAddACols := .F.  
Local lRet		 := .F.    
Local cSeek		:= ""    

Default cDocTMS  := ""
Default cFilDco  := ""
Default cDocDco  := ""
Default cSerDco  := ""

//-- Atualiza posicao dos campos na primeira passagem
If nPFilDoc == 0
	nPFilDoc := GDFieldPos('DU1_FILDOC')
	nPDoc    := GDFieldPos('DU1_DOC')
	nPSerie  := GDFieldPos('DU1_SERIE')
	nPNF     := GDFieldPos('DU1_NUMNFC')
	nPSerNF  := GDFieldPos('DU1_SERNFC')
EndIf

If !Empty(cFilDco+cDocDco+cSerDco)
	cSeek := xFilial('DTC')+cFilDco+cDocDco+cSerDco
Else
	cSeek := xFilial('DTC')+cFilDoc+cDoc+cSerie
EndIf

DTC->(dbSetOrder(3))

If FindFunction("TmsPsqDY4") .And. !TmsPsqDY4(cFilDoc,cDoc,cSerie)
	If DTC->(MsSeek(cSeek ))
		While !DTC->(Eof()) .And. DTC->(DTC_FILIAL+DTC_FILDOC+DTC_DOC+DTC_SERIE) == cSeek
			If DTC->DTC_CLIREM+DTC->DTC_LOJREM <> M->DU1_CODCLI+M->DU1_LOJCLI .And. DTC->DTC_CLIDEV+DTC->DTC_LOJDEV <> M->DU1_CODCLI+M->DU1_LOJCLI .And. ;
			   cDocTMS != "6"
				Help("",1,"TMSA57004") // Este Documento Nao Pertence ao Cliente Informado ...
				Return ( .F. )
			EndIf
		
			If Ascan( aCols, { |x| x[nPFilDoc] + x[nPDoc] + x[nPSerie] + x[nPNF] + x[nPSerNF] == ;
					cFilDoc + cDoc + cSerie + DTC->DTC_NUMNFC + DTC->DTC_SERNFC } ) == 0
				If lAAddACols
					n++
					TMSA570Cols() //Adiciona linha na GetDados
				Else
					lAAddACols := .T.
				EndIf
				
				GdFieldPut('DU1_FILDOC', cFilDoc			 , n)
				GdFieldPut('DU1_DOC',    cDoc    			 , n)
				GdFieldPut('DU1_SERIE',  cSerie  			 , n)
				GdFieldPut('DU1_NUMNFC', DTC->DTC_NUMNFC 	 , n)
				GdFieldPut('DU1_SERNFC', DTC->DTC_SERNFC 	 , n) 
				lRet := .T.
			EndIf
			DTC->(dbSkip())
		EndDo   
	Else   
		Help("",1,"TMSA57008") // Documento do cliente não encontrado ...
		Return ( .F. )	
	EndIf
Else
	DbSelectArea("DY4")
	DbSetOrder(1) //Filial + Fil.Docto. + No.Docto. + Serie Docto. + Doc.Cliente + Serie Dc.Cli + Produto
	If DY4->(MsSeek(cSeek ))
		While !DY4->(Eof()) .And. DY4->(DY4_FILIAL+DY4_FILDOC+DY4_DOC+DY4_SERIE) == cSeek
			If DY4->DY4_CLIREM+DY4->DY4_LOJREM <> M->DU1_CODCLI+M->DU1_LOJCLI  .And. cDocTMS != "6"
				Help("",1,"TMSA57004") // Este Documento Nao Pertence ao Cliente Informado ...
				Return ( .F. )
			EndIf
		
			If Ascan( aCols, { |x| x[nPFilDoc] + x[nPDoc] + x[nPSerie] + x[nPNF] + x[nPSerNF] == ;
					cFilDoc + cDoc + cSerie + DY4->DY4_NUMNFC + DY4->DY4_SERNFC } ) == 0
				If lAAddACols
					n++
					TMSA570Cols() //Adiciona linha na GetDados
				Else
					lAAddACols := .T.
				EndIf
				
				GdFieldPut('DU1_FILDOC', cFilDoc			 , n)
				GdFieldPut('DU1_DOC',    cDoc    			 , n)
				GdFieldPut('DU1_SERIE',  cSerie  			 , n)
				GdFieldPut('DU1_NUMNFC', DY4->DY4_NUMNFC 	 , n)
				GdFieldPut('DU1_SERNFC', DY4->DY4_SERNFC 	 , n) 
				lRet := .T.
			EndIf
			DY4->(dbSkip())
		EndDo   
	Else   
		Help("",1,"TMSA57008") // Documento do cliente não encontrado ...
		Return ( .F. )	
	EndIf	
Endif	

oGetD:oBrowse:nAt := n
oGetD:oBrowse:Refresh(.T.)

Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA570Cols  ³ Autor ³Patricia A. Salomao ³ Data ³23.02.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Insere uma Linha em Branco no aCols                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA570Cols(ExpC1,ExpA1,ExpA2)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±/*/
Function TMSA570Cols()
Local nCntFor

Aadd(aCols,Array(Len(aHeader)+1))
For nCntFor := 1 To Len(aHeader)
	aCols[Len(aCols),nCntFor] := CriaVar(aHeader[nCntFor,2])
Next
aCols[Len(aCols),Len(aHeader)+1] := .F.

Return NIL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA570Del³ Autor ³ Patricia A. Salomao   ³ Data ³22.08.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Deleta os outros elementos do Acols que tenham o Documento /³±±
±±³          ³Serie Iguais                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA570Del()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .F.                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TMSA570Del()

Local nLoop, nSeek

//Condicao para nao chamar o delOk duas vezes
If __nDelItem == 1
	__nDelItem := 0
	Return .F.
EndIf

__nDelItem := 1

Aeval( aCols, { |x|  IIF(  x[GdFieldPos('DU1_FILDOC')]+ x[GdFieldPos('DU1_DOC')]+x[GdFieldPos('DU1_SERIE')] == GdFieldGet('DU1_FILDOC',n) + GdFieldGet('DU1_DOC',n)+ GdFieldGet('DU1_SERIE',n) , x[Len(x)] := .T. , .T.) })

For nLoop := 1 to Len( aCols )
	nSeek := Ascan(aCols,{|x| x[Len(x)] })
	If nSeek > 0
		aCols:= ADel( aCols, nSeek )
		aCols:= ASize( aCols, Len( aCols ) - 1)
	EndIf
Next nLoop

If Empty(aCols)
	AAdd(aCols,Array(Len(aHeader)+1))
	Aeval( aHeader, { |e, nI | aCols[Len(aCols),nI] := CriaVar(aHeader[nI,2]) } )
	aCols[Len(aCols),Len(aHeader)+1] := .F.
EndIf
oGetD:oBrowse:Refresh(.T.)

Return .F.
          
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA570Imp³ Autor ³ Patricia A. Salomao   ³ Data ³28.06.2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Impressao do Comprovante de Entrega                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA570Imp()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .F.                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TMSA570Imp()

TMSR140(DU1->DU1_LOTCET)

Return .T.

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
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
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
     
Private aRotina := {	{STR0002 ,'AxPesqui'  	,0,1,0,.F.},; 		//"Pesquisar"
							{STR0003 ,'TMSA570Mnt'	,0,2,0,NIL},; 	//"Visualizar"
							{STR0004 ,'TMSA570Mnt'	,0,3,0,NIL},; 	//"Incluir"
							{STR0005 ,'TMSA570Mnt'	,0,4,0,NIL},; 	//"Estornar"
							{STR0006 ,'TMSA570IMP'	,0,5,0,NIL}} 	//"Imprimir"

If ExistBlock("TM570MNU")
	ExecBlock("TM570MNU",.F.,.F.)
EndIf

Return(aRotina)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA570Chg³ Autor ³ Tiago Santos        ³ Data ³16.08.2017  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Processa mudança de linhas da grid                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA570Chg()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function TMSA570Chg()
Local nI       := 1
Local nPos     := 1
Local dDatEnt  := CtoD("")
Local dDatCnt  := CtoD("")
Local cHorEnt  := ""
Local cHorCnt  := ""
Local lHasFldDt    := (DU1->(ColumnPos('DU1_DATENT')) > 0 .And. DU1->(ColumnPos('DU1_DATCNT')) > 0 .And. DU1->(ColumnPos('DU1_HORENT')) > 0 .And. DU1->(ColumnPos('DU1_HORCNT')) > 0)

       If lCpyData .And. lHasFldDt
            If n == Len(aCols) .And. Empty(GdFieldGet("DU1_DOC",n))
            
                 //-- Posiciona no ultimo item não deletado
                 For nI := n-1 To 1 Step -1
                     If !GdDeleted(nI)
                         nPos := nI
                         Exit
                     EndIf
                 Next nI
                
                 //-- Copia o conteudo dos campos data e hora da grid para a nova linha
                 dDatEnt  := GdFieldGet("DU1_DATENT", nPos)
                 dDatCnt  := GdFieldGet("DU1_DATCNT", nPos)
                 cHorEnt  := GdFieldGet("DU1_HORENT", nPos)
                 cHorCnt  := GdFieldGet("DU1_HORCNT", nPos)
                 
                 GDFieldPut("DU1_DATENT",dDatEnt,n)
                 GDFieldPut("DU1_DATCNT",dDatCnt,n)
                 GDFieldPut("DU1_HORENT",cHorEnt,n)
                 GDFieldPut("DU1_HORCNT",cHorCnt,n)

            EndIf
            oGetD:Refresh()
       EndIf

Return .T.