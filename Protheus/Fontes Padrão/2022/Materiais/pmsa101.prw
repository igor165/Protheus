#include "PMSA101.ch"
#include "protheus.ch"
#include "pmsicons.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PMSA101  ³ Autor ³ Michel Dantas         ³ Data ³ 31-07-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de manutecao de EDTs    do Orcamento de Projetos    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSA101(nCallOpcx,aGetCpos,cNivTrf,lRefresh)

Local nRecAF5

SaveInter()

PRIVATE cCadastro	:= STR0001 //"EDT do Orcamento"
PRIVATE aRotina := MenuDef()

Default lRefresh := .F.

If AMIIn(44) .And. !PMSBLKINT()
	If nCallOpcx == Nil
		mBrowse(6,1,22,75,"AF5")
	Else
		cNivTrf := Soma1(cNivTrf)
		nRecAF5 := PMS101Dlg("AF5",AF5->(RecNo()),nCallOpcx,,,aGetCpos,cNivTrf,@lRefresh)
	EndIf
EndIf
RestInter()
Return nRecAF5

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS101Dlg³ Autor ³ Edson Maricate         ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de Inclusao,Alteracao,Visualizacao e Exclusao       ³±±
±±³          ³ de EDTs    de Orcamentos de Projetos.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS101Dlg(cAlias,nReg,nOpcx,xreserv,yreserv,aGetCpos,cNivTrf,lRefresh)

Local oDlg

Local l101Inclui	:= .F.
Local l101Visual	:= .F.
Local l101Altera	:= .F.
Local l101Exclui	:= .F.
Local lContinua		:= .T.
Local nOpc		    := 0
Local aSize			:= {}
Local aObjects		:= {}
Local aInfo         := {}
Local aPosObj       := {}
Local aGetEnch
Local aPages	:= {}
Local aRecAF2	:= {}
Local aRecAJ2	:= {}
Local aRecAJ3	:= {}
Local aTitles	:= { 	STR0008}
Local aButtons	:= {}
//						STR0018,; //"Relac.Tarefa"
//						STR0019 }  //"Relac.EDT"
Local nPosCpo
Local cCpo
Local nRecAF5
Local oGet
Local ny := 0
Local nx := 0
Local ni := 0
    
Local lPms101msg

PRIVATE aSavN		:= {1,1,1}
PRIVATE aHeaderSV	:= {{},{},{}}
PRIVATE aColsSV		:= {{},{},{}}
PRIVATE oGD[3]
PRIVATE oFolder
PRIVATE aTELA[0][0],aGETS[0]
PRIVATE 	cSavScrVT,;
			cSavScrVP,;
			cSavScrHT,;
			cSavScrHP,;
			CurLen,;
			nPosAtu:=0,;
			nPosAnt:=9999,;
			nColAnt:=9999
			
DEFAULT cNivTrf := "001"

// define a funcao utilizada ( Incl.,Alt.,Visual.,Exclu.)
Do Case                              
	Case aRotina[nOpcx][4] == 2
		l101Visual := .T.
	Case aRotina[nOpcx][4] == 3
		l101Inclui	:= .T.
		Inclui := .T.
		Altera := .F.
	Case aRotina[nOpcx][4] == 4
		l101Altera	:= .T.
		Inclui := .F.
		Altera := .T.
	Case aRotina[nOpcx][4] == 5
		l101Exclui	:= .T.
		l101Visual	:= .T.
EndCase

If l101Inclui

	// verifica o evento de Inclusao na Fase atual
	If !PmsVldFase("AF1",AF5->AF5_ORCAME,"16")
		lContinua := .F.
	EndIf
EndIf

If l101Altera

	// verifica o evento de Alteracao na Fase atual
	If !PmsVldFase("AF1",AF5->AF5_ORCAME,"17")
		lContinua := .F.
	EndIf
EndIf

If l101Exclui

	// verifica o evento de Exclusao no Fase atual
	If !PmsVldFase("AF1",AF5->AF5_ORCAME,"13")
		lContinua := .F.
	EndIf
EndIf

If l101Exclui .And. ExistBlock("PMA101EX")
	lContinua := ExecBlock("PMA101EX",.F.,.F.)
EndIf

If lContinua
	
	RegToMemory("AF5",l101Inclui)
	
	If l101Inclui
		M->AF5_NIVEL  := cNivTrf
		M->AF5_FILIAL := xFilial("AF5")
		M->AF5_ORCAME := AF1->AF1_ORCAME
		M->AF5_VERSAO := AF1->AF1_VERSAO
	EndIf

	If aGetCpos <> Nil
		aGetEnch	:= {}
 		dbSelectArea("SX3")
		dbSetOrder(1)
		dbSeek("AF5")
		While !Eof() .and. SX3->X3_ARQUIVO == "AF5"
			IF X3USO(x3_usado) .AND. cNivel >= x3_nivel
				nPosCpo	:= aScan(aGetCpos,{|x| x[1]==Alltrim(X3_CAMPO)})
				If nPosCpo > 0
					If aGetCpos[nPosCpo][3]
						aAdd(aGetEnch,AllTrim(X3_CAMPO))
					EndIf
				Else
					aAdd(aGetEnch,AllTrim(X3_CAMPO))
				EndIf
			EndIf
			dbSkip()
		End
		For nx := 1 to Len(aGetCpos)
			cCpo	:= "M->"+Trim(aGetCpos[nx][1])
			&cCpo	:= aGetCpos[nx][2]
		Next nx
	EndIf

	If !l101Inclui

		If l101Altera.Or.l101Exclui
			If !SoftLock("AF5")
				lContinua := .F.
			Else
				nRecAF5 := AF5->(RecNo())
			Endif
		EndIf  
	EndIf

	// montagem do aHeader AF2
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek("AF2")
	While !EOF() .And. (x3_arquivo == "AF2")
		IF X3USO(x3_usado) .AND. cNivel >= x3_nivel
			AADD(aHeaderSV[1],{ TRIM(x3titulo()), x3_campo, x3_picture,;
				x3_tamanho, x3_decimal, x3_valid,;
				x3_usado, x3_tipo, x3_arquivo,x3_context } )
		Endif
		dbSelectArea("SX3")
		dbSkip()
	End
    	
	// montagem do aHeader AJ2
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek("AJ2")
	While !EOF() .And. (x3_arquivo == "AJ2")
		IF X3USO(x3_usado) .AND. cNivel >= x3_nivel
			AADD(aHeaderSV[2],{ TRIM(x3titulo()), x3_campo, x3_picture,;
				x3_tamanho, x3_decimal, x3_valid,;
				x3_usado, x3_tipo, x3_arquivo,x3_context } )
		Endif
		dbSelectArea("SX3")
		dbSkip()
	End

	// montagem do aHeader AJ3
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek("AJ3")
	While !EOF() .And. (x3_arquivo == "AJ3")
		IF X3USO(x3_usado) .AND. cNivel >= x3_nivel
			AADD(aHeaderSV[3],{ TRIM(x3titulo()), x3_campo, x3_picture,;
				x3_tamanho, x3_decimal, x3_valid,;
				x3_usado, x3_tipo, x3_arquivo,x3_context } )
		Endif
		dbSelectArea("SX3")
		dbSkip()
	End



	If !l101Inclui

		// faz a montagem do aColsAF2
		dbSelectArea("AF2")
		dbSetOrder(2)
		dbSeek(xFilial()+AF5->AF5_ORCAME+AF5->AF5_EDT)
		While !Eof() .And. AF2->AF2_FILIAL+AF2->AF2_ORCAME+AF2->AF2_EDTPAI ==;
					xFilial("AF2")+AF5->AF5_ORCAME+AF5->AF5_EDT .And. lContinua

			// trava o registro do AF2 - Alteracao,Exclusao
			If l101Altera.Or.l101Exclui
				If !SoftLock("AF2")
					lContinua := .F.
				Else
					aAdd(aRecAF2,RecNo())
				Endif
			EndIf
			aADD(aColsSV[1],Array(Len(aHeaderSV[1])+1))
			For ny := 1 to Len(aHeaderSV[1])
				If ( aHeaderSV[1][ny][10] != "V")
					aColsSV[1][Len(aColsSV[1])][ny] := FieldGet(FieldPos(aHeaderSV[1][ny][2]))
				Else
					aColsSV[1][Len(aColsSV[1])][ny] := CriaVar(aHeaderSV[1][ny][2])
				EndIf
				aColsSV[1][Len(aColsSV[1])][Len(aHeaderSV[1])+1] := .F.
			Next ny
			dbSelectArea("AF2")
			dbSkip()
		EndDo
	EndIf

	// faz a montagem de uma linha em branco no aColsAF2
	If Empty(aColsSV[1])
		aadd(aColsSV[1],Array(Len(aHeaderSV[1])+1))
		For ny := 1 to Len(aHeaderSV[1])
			If Trim(aHeaderSV[1][ny][2]) == "AF2_ITEM"
				aColsSV[1][1][ny] 	:= "01"
			Else
					aColsSV[1][1][ny] := CriaVar(aHeaderSV[1][ny][2])
			EndIf
			aColsSV[1][1][Len(aHeaderSV[1])+1] := .F.
		Next ny
	EndIf	

	If !l101Inclui

		// faz a montagem do aCols AJ2
		dbSelectArea("AJ2")
		dbSetOrder(1)
		dbSeek(xFilial()+AF5->AF5_ORCAME+AF5->AF5_EDT)
		While !Eof() .And. AJ2->AJ2_FILIAL+AJ2->AJ2_ORCAME+AJ2->AJ2_EDT ==;
					xFilial("AJ2")+AF5->AF5_ORCAME+AF5->AF5_EDT .And. lContinua
			AF2->(dbSetOrder(1))
			AF2->(dbSeek(xFilial()+AJ2->AJ2_ORCAME+AJ2->AJ2_PREDEC))

			// trava o registro do AJ2 - Alteracao,Exclusao
			If l101Altera.Or.l101Exclui
				If !SoftLock("AJ2")
					lContinua := .F.
				Else
					aAdd(aRecAJ2,RecNo())
				Endif
			EndIf
			aADD(aColsSV[2],Array(Len(aHeaderSV[2])+1))
			For ny := 1 to Len(aHeaderSV[2])
				If ( aHeaderSV[2][ny][10] != "V")
					aColsSV[2][Len(aColsSV[2])][ny] := FieldGet(FieldPos(aHeaderSV[2][ny][2]))
				Else
					Do Case
						Case AllTrim(aHeaderSV[2][ny][2]) == "AJ2_DESCRI"
							aColsSV[2][Len(aColsSV[2])][ny] := AF2->AF2_DESCRI
						OtherWise
							aColsSV[2][Len(aColsSV[2])][ny] := CriaVar(aHeaderSV[2][ny][2])
					EndCase
				EndIf
				aColsSV[2][Len(aColsSV[2])][Len(aHeaderSV[2])+1] := .F.
			Next ny
			dbSelectArea("AJ2")
			dbSkip()
		EndDo
	EndIf

	// faz a montagem de uma linha em branco no aCols AJ2
	If Empty(aColsSV[2])
		aadd(aColsSV[2],Array(Len(aHeaderSV[2])+1))
		For ny := 1 to Len(aHeaderSV[2])
			If Trim(aHeaderSV[2][ny][2]) == "AJ2_ITEM"
				aColsSV[2][1][ny] 	:= "01"
			Else
				aColsSV[2][1][ny] := CriaVar(aHeaderSV[2][ny][2])
			EndIf
			aColsSV[2][1][Len(aHeaderSV[2])+1] := .F.
		Next ny
	EndIf	

	If !l101Inclui

		// faz a montagem do aCols AJ3
		dbSelectArea("AJ3")
		dbSetOrder(1)
		dbSeek(xFilial()+AF5->AF5_ORCAME+AF5->AF5_EDT)
		While !Eof() .And. AJ3->AJ3_FILIAL+AJ3->AJ3_ORCAME+AJ3->AJ3_EDT ==;
					xFilial("AJ3")+AF5->AF5_ORCAME+AF5->AF5_EDT .And. lContinua
			AF5->(dbSetOrder(1))
			AF5->(dbSeek(xFilial()+AJ3->AJ3_ORCAME+AJ3->AJ3_PREDEC))

			// trava o registro do AJ2 - Alteracao,Exclusao
			If l101Altera.Or.l101Exclui
				If !SoftLock("AJ3")
					lContinua := .F.
				Else
					aAdd(aRecAJ3,RecNo())
				Endif
			EndIf
			aADD(aColsSV[3],Array(Len(aHeaderSV[3])+1))
			For ny := 1 to Len(aHeaderSV[3])
				If ( aHeaderSV[3][ny][10] != "V")
					aColsSV[3][Len(aColsSV[3])][ny] := FieldGet(FieldPos(aHeaderSV[3][ny][2]))
				Else
					Do Case
						Case AllTrim(aHeaderSV[3][ny][2]) == "AJ3_DESCRI"
							aColsSV[3][Len(aColsSV[3])][ny] := AF5->AF5_DESCRI
						OtherWise
							aColsSV[3][Len(aColsSV[3])][ny] := CriaVar(aHeaderSV[3][ny][2])
					EndCase
				EndIf
				aColsSV[3][Len(aColsSV[3])][Len(aHeaderSV[3])+1] := .F.
			Next ny
			dbSelectArea("AJ3")
			dbSkip()
		EndDo
	EndIf

	// faz a montagem de uma linha em branco no aCols AJ3
	If Empty(aColsSV[3])
		aadd(aColsSV[3],Array(Len(aHeaderSV[3])+1))
		For ny := 1 to Len(aHeaderSV[3])
			If Trim(aHeaderSV[3][ny][2]) == "AJ3_ITEM"
				aColsSV[3][1][ny] 	:= "01"
			Else
				aColsSV[3][1][ny] := CriaVar(aHeaderSV[3][ny][2])
			EndIf
			aColsSV[3][1][Len(aHeaderSV[3])+1] := .F.
		Next ny
	EndIf	
   
	If ExistBlock("PMS101MSG")
		lPms101msg := ExecBlock("PMS101MSG", .F., .F.)
		If ValType(lPms101msg) == "L"
			lContinua := lPms101msg
		EndIf
	EndIF
	
	If lContinua

		// faz o calculo automatico de dimensoes de objetos
		aSize := MsAdvSize(,.F.,400)
		aObjects := {} 
		
		AAdd( aObjects, { 100, 100 , .T., .F. } )
		AAdd( aObjects, { 100, 100 , .T., .T. } )
		
		aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 2, 2 }
		aPosObj := MsObjSize( aInfo, aObjects )
		
		DEFINE MSDIALOG oDlg TITLE cCadastro+" - "+aRotina[nOpcx,01] From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
    	
			oGet := MsMGet():New("AF5",AF5->(RecNo()),nOpcx,,,,,aPosObj[1],aGetEnch,3,,,,oDlg)

			oFolder := TFolder():New(aPosObj[2,1],aPosObj[2,2],aTitles,aPages,oDlg,,,, .T., .T.,aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1])
			oFolder:bSetOption:={|nFolder| A101SetOption(nFolder,oFolder:nOption,@aCols,@aHeader,@aColsSV,@aHeaderSV,@aSavN,@oGD) }
			For ni := 1 to Len(oFolder:aDialogs)
				DEFINE SBUTTON FROM 5000,5000 TYPE 5 ACTION Allwaystrue() ENABLE OF oFolder:aDialogs[ni]
			Next	
    	
			oFolder:aDialogs[1]:oFont := oDlg:oFont
			aHeader		:= aClone(aHeaderSV[1])
			aCols		:= aClone(aColsSV[1])
			oGD[1]		:= MsGetDados():New(2,2,aPosObj[2,3]-aPosObj[2,1]-16,aPosObj[2,4]-6,2,".T.",".T.",,.F.,,1,,300,,,,,oFolder:aDialogs[1])
			oGD[1]:oBrowse:bDrawSelect	:= {|| A203SVCols(@aHeaderSV,@aColsSV,@aSavN,1)}

//			oFolder:aDialogs[2]:oFont := oDlg:oFont
//			aHeader		:= aClone(aHeaderSV[2])
//			aCols		:= aClone(aColsSV[2])
//			oGD[2]		:= MsGetDados():New(2,2,aPosObj[2,3]-aPosObj[2,1]-16,aPosObj[2,4]-6,nOpcx,"A101GD2LinOk","A101GD2TudOK","+AJ2_ITEM",.T.,,1,,300,,,,,oFolder:aDialogs[2])
//			oGD[2]:oBrowse:lDisablePaint := .T.
//			oGD[2]:oBrowse:bDrawSelect	:= {|| A203SVCols(@aHeaderSV,@aColsSV,@aSavN,2)}
			
//			oFolder:aDialogs[3]:oFont := oDlg:oFont
//			aHeader		:= aClone(aHeaderSV[3])
//			aCols		:= aClone(aColsSV[3])
//			oGD[3]		:= MsGetDados():New(2,2,aPosObj[2,3]-aPosObj[2,1]-16,aPosObj[2,4]-6,nOpcx,"A101GD3LinOk","A101GD3TudOK","+AJ3_ITEM",.T.,,1,,300,,,,,oFolder:aDialogs[3])
//			oGD[3]:oBrowse:lDisablePaint := .T.
//			oGD[3]:oBrowse:bDrawSelect	:= {|| A203SVCols(@aHeaderSV,@aColsSV,@aSavN,3)}


			aHeader := aClone(aHeaderSV[1])
			aCols   := aClone(aColsSV[1])

			// verifica a existencia do ponto de entrada dos botoes de usuarios
			If ExistBlock("PMA101BU")
				aButtons := ExecBlock("PMA101BU",.F.,.F.,{aButtons})
			EndIf
	
			aButtons := AddToExcel(aButtons,{	{"ENCHOICE",cCadastro,aGets,aTela},;
															{"GETDADOS",aTitles[1],aHeaderSV[1],aColsSV[1]} } )


		ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||If(Obrigatorio(aGets,aTela);
																		,(nOpc:=1,oDlg:End()),Nil)},{||oDlg:End()},,aButtons)

		// Não aplicar refresh na visualizacao do orcamento (arvore/planilha)
		lRefresh := .F.
		
		If (nOpc == 1) .And. (l101Inclui .Or. l101Altera .Or. l101Exclui)
			// Aplicar refresh na visualizacao do orcamento (arvore/planilha)
			lRefresh := .T.

			// verifica se existe o ponto de entrada para a permissao ou bloqueio
			// da exclusao da EDT.
			If l101Exclui
				If ExistBlock("PMA101DEL")
					If !ExecBlock("PMA101DEL",.F.,.F.)
						RestArea(aAreaAF2)
						Return(nRecAF5)
					EndIf
				EndIf
			EndIf

			Begin Transaction
				PMS101Grava(l101Exclui,aHeaderSV,aColsSV,nRecAF5,aRecAJ2,aRecAJ3)
		    End Transaction
			If ExistBlock("PMA101SA")
				ExecBlock("PMA101SA", .T., .T., {(nOpc==1), nOpcx})
			EndIf    
		EndIf
	Endif	
Endif

// destrava Todos os Registros
MsUnLockAll()


Return nRecAF5

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A101SetOption³ Autor ³ Edson Maricate     ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao que controla a GetDados ativa na visualizacao do      ³±±
±±³          ³ Folder.                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA101                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A101SetOption(nFolder,nOldFolder,aCols,aHeader,aColsSV,aHeaderSV,aSavN,oGD)
           
If nOldFolder <= Len(aHeaderSV) .And. !Empty(aHeaderSV[nOldFolder])

	// salva o conteudo da GetDados se existir
	aColsSV[nOldFolder]		:= aClone(aCols)
	aHeaderSV[nOldFolder]	:= aClone(aHeader)
	aSavN[nOldFolder]		:= n
	oGD[nOldFolder]:oBrowse:lDisablePaint := .T.
EndIf

If nFolder!=Nil.And.nFolder <= Len(aHeaderSV) .And. !Empty(aHeaderSV[nFolder])

	// restaura o conteudo da GetDados se existir
	oGD[nFolder]:oBrowse:lDisablePaint := .F.
	aCols	:= aClone(aColsSV[nFolder])
	aHeader := aClone(aHeaderSV[nFolder])
	n		:= aSavN[nFolder]
	oGD[nFolder]:oBrowse:Refresh()
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A101GD2TudOk³ Autor ³ Edson Maricate      ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao TudOk da GetDados 2.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA101                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A101GD2TudOk()
Local nx := 0

Local nPosPred	:= aScan(aHeader,{|x|AllTrim(x[2])=="AJ2_PREDEC"})
Local nSavN	:= n
Local lRet	:= .T.

For nx := 1 to Len(aCols)
	n	:= nx
	If !Empty(aCols[n][nPosPred])
		If !A101GD2LinOk()
			lRet := .F.
			Exit
		EndIf
	EndIf
Next
	
n	:= nSavN

Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A101GD3TudOk³ Autor ³ Edson Maricate      ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao TudOk da GetDados 3.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA101                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A101GD3TudOk()
Local nx := 0

Local nPosPred	:= aScan(aHeader,{|x|AllTrim(x[2])=="AJ3_PREDEC"})
Local nSavN	:= n
Local lRet	:= .T.

For nx := 1 to Len(aCols)
	n	:= nx
	If !Empty(aCols[n][nPosPred])
		If !A101GD3LinOk()
			lRet := .F.
			Exit
		EndIf
	EndIf
Next
	
n	:= nSavN

Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A101GD4TudOk³ Autor ³ Edson Maricate      ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao TudOk da GetDados 4.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA101                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A101GD4TudOk()
Local nx := 0

Local nPosPredec	:= aScan(aHeader,{|x|AllTrim(x[2])=="AF7_PREDEC"})
Local nSavN	:= n
Local lRet	:= .T.

For nx := 1 to Len(aCols)
	n	:= nx
	If !Empty(aCols[n][nPosPredec])
		If !A101GD4LinOk()
			lRet := .F.
			Exit
		EndIf
	EndIf
Next
	
n	:= nSavN

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A101GD2LinOk³ Autor ³ Edson Maricate      ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao LinOk da GetDados 2.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA101                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A101GD2LinOk()

// verifica os campos obrigatorios do SX3
Local lRet := MaCheckCols(aHeader,aCols,n)


Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A101GD3LinOk³ Autor ³ Edson Maricate      ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao LinOk da GetDados 3.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA101                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A101GD3LinOk()

// verifica os campos obrigatorios do SX3
Local lRet := MaCheckCols(aHeader,aCols,n)


Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³A101GD4LinOk³ Autor ³ Edson Maricate      ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao LinOk da GetDados 4.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PMSA101                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A101GD4LinOk()

// verifica os campos obrigatorios do SX3
Local lRet := MaCheckCols(aHeader,aCols,n)


Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS101Grava³ Autor ³ Edson Maricate       ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Faz a gravacao do Orcamento.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA101                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS101Grava(lDeleta,aHeaderSV,aColsSV,nRecAF5,aRecAJ2,aRecAJ3)

Local bCampo 	:= {|n| FieldName(n) }
Local nCntFor   := 0
Local nCntFor2  := 0
Local lAltera	:= (nRecAF5!=Nil)
Local nPosPrd2	:= aScan(aHeaderSV[2],{|x|AllTrim(x[2])=="AJ2_PREDEC"})
Local nPosPrd3	:= aScan(aHeaderSV[3],{|x|AllTrim(x[2])=="AJ3_PREDEC"})
Local lAtuBDi	:= Type("M->AF5_BDITAR") <> "U" 
Local nX		:=	1
Local cChave    := ""
Local nOpcMemo  := 0

	If !lDeleta
	
		// grava arquivo AF5 (SubTarefas)
		If lAltera
			AF5->(dbGoto(nRecAF5))
			RecLock("AF5",.F.)
			lAtuBDI	:= lAtuBdi .And. (M->AF5_BDITAR <> AF5->AF5_BDITAR)
		Else
			RecLock("AF5",.T.)
		EndIf
		FOR nX := 1 TO FCount()
			FieldPut(nX ,M->&( EVAL(bCampo ,nX) ) )
		NEXT i
		AF5->AF5_FILIAL := xFilial("AF5")
		MsUnlock()
	
		If Type(M->AF5_CODMEM) <> Nil
			cChave := M->AF5_CODMEM
		EndIf
		If Empty(M->AF5_OBS) .And. lAltera
			nOpcMemo := 2 // Deleta Campo Memo
		Else
			nOpcMemo := 1 // Mantem funcionamento anterior
		EndIf
	
		MSMM(cChave ,TamSx3("AF5_OBS")[1] ,,M->AF5_OBS ,nOpcMemo ,,,"AF5" ,"AF5_CODMEM")
		nRecAF5 := Recno()
	
		// grava arquivo AJ2 (Predecessoras)
		dbSelectArea("AJ2")
		For nCntFor := 1 to Len(aColsSV[2])
			If !aColsSV[2][nCntFor][Len(aHeaderSV[2])+1]
				If !Empty(aColsSV[2][nCntFor][nPosPrd2])
					If nCntFor <= Len(aRecAJ2)
						dbGoto(aRecAJ2[nCntFor])
						RecLock("AJ2",.F.)
					Else
						RecLock("AJ2",.T.)
					EndIf
					For nCntFor2 := 1 To Len(aHeaderSV[2])
						If ( aHeaderSV[2][nCntFor2][10] != "V" )
							AJ2->(FieldPut(FieldPos(aHeaderSV[2][nCntFor2][2]),aColsSV[2][nCntFor][nCntFor2]))
						EndIf
					Next nCntFor2
					AJ2->AJ2_FILIAL	:= xFilial("AJ2")
					AJ2->AJ2_ORCAME	:= AF5->AF5_ORCAME
					AJ2->AJ2_EDT	:= AF5->AF5_EDT
					MsUnlock()
				EndIf
			Else
				If nCntFor <= Len(aRecAJ2)
					dbGoto(aRecAJ2[nCntFor])
					RecLock("AJ2",.F.,.T.)
					dbDelete()
					MsUnlock()
				EndIf
			EndIf
	
		Next nCntFor
	
		// grava arquivo AJ3 (Predecessoras)
		dbSelectArea("AJ3")
		For nCntFor := 1 to Len(aColsSV[3])
			If !aColsSV[3][nCntFor][Len(aHeaderSV[3])+1]
				If !Empty(aColsSV[3][nCntFor][nPosPrd3])
					If nCntFor <= Len(aRecAJ3)
						dbGoto(aRecAJ3[nCntFor])
						RecLock("AJ3",.F.)
					Else
						RecLock("AJ3",.T.)
					EndIf
					For nCntFor2 := 1 To Len(aHeaderSV[3])
						If ( aHeaderSV[3][nCntFor2][10] != "V" )
							AJ3->(FieldPut(FieldPos(aHeaderSV[3][nCntFor2][2]),aColsSV[3][nCntFor][nCntFor2]))
						EndIf
					Next nCntFor2
					AJ3->AJ3_FILIAL	:= xFilial("AJ3")
					AJ3->AJ3_ORCAME	:= AF5->AF5_ORCAME
					AJ3->AJ3_EDT   	:= AF5->AF5_EDT
					MsUnlock()
				EndIf
			Else
				If nCntFor <= Len(aRecAJ3)
					dbGoto(aRecAJ3[nCntFor])
					RecLock("AJ3",.F.,.T.)
					dbDelete()
					MsUnlock()
				EndIf
			EndIf
			If lAtuBDI
				aAreaAF5	:=AF5->(GetArea())
				aEdts		:=	{}
				AtuBdiTarefas(@aEDTS)                       
				RestArea(aAreaAF5)
				aSort(aEDTS,,,{|x,y| x[1]>y[1]})				
				DbSelectArea('AF2')
				DbSetOrder(2)
				For nX := 1 To Len(aEDTS)
					DbSeek(xFilial()+AF5->AF5_ORCAME+aEDTS[nX,2])			
					While !EOF() .And. xFilial()+AF5->AF5_ORCAME+aEDTS[nX,2] == AF2->(AF2_FILIAL+AF2_ORCAME+AF2_EDTPAI)
						If AF2->AF2_BDI == 0 
							RecLock('AF2')
							Replace AF2_VALBDI	With AF2->AF2_CUSTO * AF5->AF5_BDITAR/100
							MsUnLock()										
						Endif			
						PmsAvalAF2("AF2")
						DbSelectArea('AF2')
						DbSkip()          
					Enddo	
				Next nX
			Endif
	
		Next nCntFor
		
	Else
		MaExclAF5(,,nRecAF5)
	
	EndIf
	
Return 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMSA101Eof³ Autor ³ Edson Maricate        ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de Filtro utiliada na consulta SXB e no Browse das    ³±±
±±³          ³ EDTs    do Orcamento.                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SXB, PMSA101                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSA101Trf()
Local aArea		:= GetArea()
Local aAreaAF2	:= AF2->(GetArea())
Local nRecAF2	:= PMSA101(3,,M->AF2_NIVEL)
Local nPosSubTrf:= aScan(aHeader,{|x| AllTrim(x[2])=="AF5_SUBTRF"})
Local nPosDescri:= aScan(aHeader,{|x| AllTrim(x[2])=="AF5_DESCRI"})
Local nPosSubNiv:= aScan(aHeader,{|x| AllTrim(x[2])=="AF5_SUBNIV"})
Local nPosQuant := aScan(aHeader,{|x| AllTrim(x[2])=="AF5_QUANT"})

If nRecAF2 <> Nil
	AF2->(dbGoto(nRecAF2))
	aCols[n][nPosSubTrf]	:= AF2->AF2_TAREFA
	aCols[n][nPosDescri]	:= AF2->AF2_DESCRI
	aCols[n][nPosSubNiv]	:= AF2->AF2_NIVEL
	aCols[n][nPosQuant]		:= AF2->AF2_QUANT
EndIf


RestArea(aAreaAF2)
RestArea(aArea)
Return .F.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS101CMP³ Autor ³ Edson Maricate         ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao que importa o cadastro de composicoes para uma deter- ³±±
±±³          ³ minada EDT do Orcamento.                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA101                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS101CMP(nRecAF1,oTree,cArquivo)
Local oDlg
Local oDescri
Local n101Quant  := 0
Local cUM        := ''
Local cDescri    := ''
Local c101Compos := SPACE(Len(AE1->AE1_COMPOS))
Local oBold
Local oUM
Local oBmp
Local lOk        := .F.
Local cAlias     := ""
Local nRecAlias  := 0
Local cTarefa    := Space(TamSx3("AF2_TAREFA")[1])
Local oQuant     := Nil

If oTree != Nil

	// verifica os dados da EDT/Tarefa posicionada no tree
	cAlias:= SubStr(oTree:GetCargo(),1,3)
	nRecAlias:= Val(SubStr(oTree:GetCargo(),4,12))
Else
	cAlias := (cArquivo)->ALIAS
	nRecAlias := (cArquivo)->RECNO
EndIf


If cAlias == "AF5"
	dbSelectArea(cAlias)
	dbGoto(nRecAlias)

	DEFINE FONT oBold NAME "Arial" SIZE 0, -12 BOLD
	DEFINE MSDIALOG oDlg FROM 114,150 TO 450,600 TITLE cCadastro Of oMainWnd PIXEL

		@   0,  0 BITMAP oBmp RESNAME BMP_PROJETOAP oF oDlg SIZE 70,255 NOBORDER WHEN .F. PIXEL
		@  17, 43 TO 18 ,245 LABEL '' OF oDlg PIXEL
		@   6, 50 SAY STR0010 Of oDlg PIXEL SIZE 69, 08 FONT oBold //'Importar Composicao'
			
		@  30,  55 SAY STR0011 Of oDlg PIXEL SIZE 58, 08 //'Cod. Composicao'
		@  29, 105 MSGET c101Compos Picture PesqPict('AE1','AE1_COMPOS') F3 'AE1';
		           Valid Vazio(c101Compos) .Or. RefDlg(@c101Compos,@cDescri,@oDescri,@cUM,@oUM) .And.;
		           (oQuant:SetFocus(), .T.);
		           OF oDlg PIXEL SIZE 92, 08 HASBUTTON
			
		@  50,  55 SAY STR0012 Of oDlg PIXEL SIZE 43, 08 //'Descricao'
		@  49,105 GET oDescri VAR cDescri MEMO SIZE 106,33 PIXEL OF oDlg //READONLY
			
		@  95,  55 SAY STR0013 Of oDlg PIXEL SIZE 80, 08 //'Unid. de Medida'
		@  94, 105 MSGET oUM VAR cUM Picture PesqPict('AE1','AE1_UM') OF oDlg When .F. PIXEL SIZE 25, 08
			
		@  115,  55 SAY STR0014 Of oDlg PIXEL SIZE 45, 08 //'Quantidade'
		@  114, 105 MSGET oQuant Var n101Quant Picture PesqPict('AF2','AF2_QUANT') Valid Positivo(n101Quant) OF oDlg PIXEL SIZE 60, 08 HASBUTTON
		   
		If GetMv("MV_PMSTCOD") == "1"
	
			// codificacao manual
			@ 135,  55 Say STR0021 Of oDlg Pixel Size 45, 08
			@ 134, 105 MSGET cTarefa Picture PesqPict("AF2", "AF2_TAREFA") Valid !ExistOrcTrf((cAlias)->AF5_ORCAMENTO, cTarefa) Of oDlg Pixel Size 60, 08
    
			@ 155, 131 BUTTON STR0015 SIZE 35 ,11  FONT oDlg:oFont ACTION  (lOk:=.T.,oDlg:End()) OF oDlg PIXEL When !Empty(c101Compos) .And. !Empty(n101Quant) .And. !Empty(cTarefa)//'Confirma'
		Else
			@ 155, 131 BUTTON STR0015 SIZE 35 ,11  FONT oDlg:oFont ACTION  (lOk:=.T.,oDlg:End()) OF oDlg PIXEL When !Empty(c101Compos) .And. !Empty(n101Quant) //"Confirma"
		EndIf
		
		@ 155, 171 BUTTON STR0016 SIZE 35 ,11  FONT oDlg:oFont ACTION (oDlg:End())  OF oDlg PIXEL  //'Cancela'

	ACTIVATE MSDIALOG oDlg CENTERED

	If lOk 
		Begin Transaction

			If GetMv("MV_PMSTCOD") == "2"
				// codificacao automatica
				cTarefa := PmsNumAF5(AF5->AF5_ORCAME,AF5->AF5_NIVEL,AF5->AF5_EDT)
			EndIf

			// verifica a existencia do ponto de entrada PMA101CP
			If ExistBlock("PMA101CP")
				ExecBlock("PMA101CP",.F.,.F.,{ 'AF5',AF5->(RecNo()),AE1->(RecNo()),n101Quant })
			EndIf

			If GetMv("MV_PMSCUST") == "2" //1-custo total  2-custo unitario
				nRecAF2 := PMS101IMPOR(nRecAF1,AF5->AF5_NIVEL,c101Compos, 1,cTarefa,AF5->AF5_EDT,,,,, n101Quant,,cDescri)
			Else
				nRecAF2 := PMS101IMPOR(nRecAF1,AF5->AF5_NIVEL,c101Compos,n101Quant,cTarefa,AF5->AF5_EDT,,,,, n101Quant,,cDescri)
			EndIf

		End Transaction
	EndIf
EndIf

Return lOk

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS101CMP2³ Autor ³ Edson Maricate        ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao que associa a composicao para uma determinada tarefa  ³±±
±±³          ³ do Orcamento.                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA101                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS101CMP2(nRecAF1,oTree,cArquivo)
Local oDlg
Local oDescri
Local n101Quant  := 0
Local cUM        := ''
Local cDescri    := ''
Local c101Compos := SPACE(Len(AE1->AE1_COMPOS))
Local oBold
Local oUM
Local oBmp
Local lOk := .F.
Local cAlias	:= ""
Local nRecAlias	:= 0
Local oQuant     := Nil
Local lMantProd  := .F.

If oTree != Nil

 	// verifica os dados da EDT/Tarefa posicionada no tree
	cAlias:= SubStr(oTree:GetCargo(),1,3)
	nRecAlias:= Val(SubStr(oTree:GetCargo(),4,12))
Else
	cAlias    := (cArquivo)->ALIAS
	nRecAlias := (cArquivo)->RECNO
EndIf


If cAlias == "AF2"
	dbSelectArea(cAlias)
	dbGoto(nRecAlias)
	n101Quant := AF2->AF2_QUANT

	DEFINE FONT oBold NAME "Arial" SIZE 0, -12 BOLD
	DEFINE MSDIALOG oDlg FROM 114,150 TO 490,600 TITLE cCadastro Of oMainWnd PIXEL

		@   0,   0 BITMAP oBmp RESNAME BMP_PROJETOAP oF oDlg SIZE 70,255 NOBORDER WHEN .F. PIXEL
		@  17,  43 TO 18 ,245 LABEL '' OF oDlg PIXEL
		@   6,  50 SAY STR0020 Of oDlg PIXEL SIZE 69, 08 FONT oBold  //"Associar Composicao"
			
		@  30,  55 SAY STR0011 Of oDlg PIXEL SIZE 58, 08 //'Cod. Composicao'
		@  29, 105 MSGET c101Compos Picture PesqPict('AE1','AE1_COMPOS') F3 'AE1';
			             Valid Vazio(c101Compos) .Or. RefDlg(@c101Compos,@cDescri,@oDescri,@cUM,@oUM);
			             OF oDlg PIXEL SIZE 92, 08 HASBUTTON
			
		@  50,  55 SAY STR0012 Of oDlg PIXEL SIZE 43, 08 //'Descricao'
		@  49, 105 GET oDescri VAR cDescri MEMO SIZE 106 , 33 PIXEL OF oDlg //READONLY
			
		@  95,  55 SAY STR0013 Of oDlg PIXEL SIZE 80, 08 //'Unid. de Medida'
		@  94, 105 MSGET oUM VAR cUM Picture PesqPict('AE1','AE1_UM') OF oDlg When .F. PIXEL SIZE 25, 08
			
		@ 115,  55 SAY STR0014 Of oDlg PIXEL SIZE 45, 08 //'Quantidade'
		@ 114, 105 MSGET oQuant Var n101Quant Picture PesqPict('AF2','AF2_QUANT') Valid Positivo(n101Quant) OF oDlg PIXEL SIZE 60, 08 HASBUTTON
		
		TCheckBox():New(133,55,STR0022,{|u|if( pcount()==0,lMantProd,lMantProd := u)},oDlg,200,20,,,,,,,,.T.) //"Manter Produto/Recurso/Despesa da tarefa associada?"
			
		@ 165, 171 BUTTON STR0015 SIZE 35 ,11  FONT oDlg:oFont ACTION  (lOk:=.T.,oDlg:End()) OF oDlg PIXEL When !Empty(c101Compos) .And. !Empty(n101Quant) //'Confirma'
		@ 165, 131 BUTTON STR0016 SIZE 35 ,11  FONT oDlg:oFont ACTION (oDlg:End())  OF oDlg PIXEL  //'Cancela'
		
	ACTIVATE MSDIALOG oDlg CENTERED

	If lOk 
		Begin Transaction
			// verifica a existencia do ponto de entrada PMA101CP
			If ExistBlock("PMA101CP")
				ExecBlock("PMA101CP",.F.,.F.,{ 'AF2',AF2->(RecNo()),AE1->(RecNo()),n101Quant })
			EndIf

			If GetMv("MV_PMSCUST")=="2"  //1-custo total  2-custo unitario
				nRecAF2 := PMS101IMPOR(nRecAF1,AF5->AF5_NIVEL,c101Compos,1        ,PmsNumAF5(AF5->AF5_ORCAME,AF5->AF5_NIVEL,AF5->AF5_EDT),AF5->AF5_EDT,.T.,,,AF2->(RecNo()),n101Quant,,cDescri,,lMantProd)
			Else
				nRecAF2 := PMS101IMPOR(nRecAF1,AF5->AF5_NIVEL,c101Compos,n101Quant,PmsNumAF5(AF5->AF5_ORCAME,AF5->AF5_NIVEL,AF5->AF5_EDT),AF5->AF5_EDT,.T.,,,AF2->(RecNo()),n101Quant,,cDescri,,lMantProd)
			EndIf
		End Transaction
	EndIf
EndIf

Return lOk


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³RefDlg³ Autor ³ Edson Maricate            ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Executa a validacao e o refresh dos gets da janela            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMS101CMP                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function RefDlg(cCompos,cDescri,oDescri,cUM,oUM)
Local aArea		:= GetArea()
Local aAreaAE1	:= AE1->(GetArea())
Local lRet 		:= .T.

AE1->(dbSetOrder(1))
If AE1->(MsSeek(xFilial("AE1") + cCompos))
	Do Case
		// 1 - orçamento/projeto
		// 2 - orçamento
		Case AE1->AE1_USO == "1" .Or. AE1->AE1_USO == "2"
			cDescri := AE1->AE1_DESCRI
			cUM 	:= AE1->AE1_UM
			oDescri:Refresh()
			oUM:Refresh()

		// inativa		
		Case AE1->AE1_USO == "3"
			Aviso(STR0023 ,STR0024, {"OK"})
			lRet := .F.		

		Otherwise
			lRet := .F.
					
	EndCase
	
Else
	HELP("  ",1,"REGNOIS")
	lRet := .F.
	
EndIf

RestArea(aAreaAE1)
RestArea(aArea)
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS101IMPOR³ Autor ³ Edson Maricate       ³ Data ³ 09-02-2001              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao que importa/associa a composicao no Orcamento.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cItemAF3 : numero do item produto da tabela AF3                            ³±±
±±³          ³cItemAF4 : numero do item da despesa da tabela AF4                         ³±±
±±³          ³lMantProd : mantem os produtos da tarefa associada(utilizado se associacao)³±±
±±³          ³cItemRec : numero do item recurso da tabela AF3                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMS101CMP                                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS101IMPOR(nRecAF1,cNivelAtu,cCompos,nQuant,cTarefa,cEDTPAI,lCriaAF2,cItemAF3,cItemAF4,nRecAF2,nGravaQuant, cOrcame,cDescri,lSub,lMantProd,cItemRec)

Local aArea     := GetArea()
Local aAreaAE1  := AE1->(GetArea())
Local aAreaAE2  := AE2->(GetArea())
Local aAreaAF2  := AF2->(GetArea())
Local aAreaAE3  := AE3->(GetArea())
Local aAreaAE4  := AE4->(GetArea())
Local aAreaSB1  := SB1->(GetArea())
Local nRetAF2   := 0
Local nAuxAF2   := 0
Local cNivelTrf := cNivelAtu
Local bCampo    := {|n| FieldName(n) }
Local nx
Local lPadrao   := .T.
Local cAux      := ""

DEFAULT lCriaAF2 := .T.
DEFAULT cItemAF3 := "00"
DEFAULT cItemAF4 := "00"
DEFAULT cItemRec := "00"
DEFAULT cOrcame  := AF1->AF1_ORCAME
DEFAULT lSub 	  := .F.
DEFAULT lMantProd := .F.

dbSelectArea("AE1")
dbSetOrder(1)
If dbSeek(xFilial()+cCompos)
	If lCriaAF2
		If nRecAF2 == Nil              
			RegToMemory("AF2",.T.)		
			cNivelTrf := StrZero(Val(cNivelTrf) + 1, TamSX3("AF2_NIVEL")[1])
			RecLock("AF2",.T.)
			For nx := 1 TO FCount()
				FieldPut(nx,M->&(EVAL(bCampo,nx)))
			Next nx
			AF2->AF2_FILIAL := xFilial("AF2")
			AF2->AF2_ORCAME := AF1->AF1_ORCAME
			AF2->AF2_NIVEL  := cNivelTrf

			If GetMv("MV_PMSTCOD") == "1"

				// codificacao manual
				AF2->AF2_TAREFA := cTarefa			
			Else
				AF2->AF2_TAREFA := PmsNumAF2(AF1->AF1_ORCAME, cNivelAtu, cEDTPai)
			EndIf
			
			AF2->AF2_DESCRI:= IIf(cDescri==Nil .Or.Empty(cDescri),AE1->AE1_DESCRI,cDescri)
			AF2->AF2_UM     := AE1->AE1_UM
			AF2->AF2_QUANT  := nGravaQuant
			AF2->AF2_COMPOS := cCompos
			AF2->AF2_TPMEDI := "4"
			AF2->AF2_EDTPAI := cEDTPai
			AF2->AF2_GRPCOM := AE1->AE1_GRPCOM
			AF2->AF2_PRIORI := AE1->AE1_PRIORI
	
			If ExistTemplate("CCT101_0")
				ExecTemplate("CCT101_0",.F.,.F.,{cCompos,lSub})
			EndIf
			MsUnlock()
		Else

			AF2->(dbGoto(nRecAF2))
			RecLock("AF2",.F.)
			AF2->AF2_DESCRI := IIf(cDescri==Nil .Or.Empty(cDescri),AE1->AE1_DESCRI,cDescri)
			AF2->AF2_UM     := AE1->AE1_UM
			AF2->AF2_QUANT  := nGravaQuant
			AF2->AF2_COMPOS := cCompos
			AF2->AF2_GRPCOM := AE1->AE1_GRPCOM
			AF2->AF2_PRIORI := AE1->AE1_PRIORI
	
			If ExistTemplate("CCT101_0")
				ExecTemplate("CCT101_0",.F.,.F.,{cCompos,lSub})
			EndIf

			MsUnlock()
			
			AF3->(DbSetOrder(1))
			AF3->(DbSeek(xFilial()+AF2->AF2_ORCAME+AF2->AF2_TAREFA))
			While AF3->(!Eof()) .And. xFilial()+AF2->AF2_ORCAME+AF2->AF2_TAREFA == ;
								AF3->(AF3_FILIAL+AF3_ORCAME+AF3_TAREFA)
				If !lMantProd // mantem produto/recurso/despesa?
					RecLock("AF3",.F.,.T.)
					AF3->(DbDelete())
					AF3->(MsUnlock())
				Else
					//guarda o ultimo item do produto/recurso da tarefa
					If !Empty(AF3->AF3_RECURS)
						cItemRec := AF3->AF3_ITEM
					Else
						cItemAF3 := AF3->AF3_ITEM
					EndIf
				EndIf
				AF3->(DbSkip())
			EndDo
	
			AF4->(DbSetOrder(1))
			AF4->(DbSeek(xFilial()+AF2->AF2_ORCAME+AF2->AF2_TAREFA))
			While AF4->(!Eof()) .And. xFilial()+AF2->AF2_ORCAME+AF2->AF2_TAREFA == ;
								AF4->(AF4_FILIAL+AF4_ORCAME+AF4_TAREFA)
				If !lMantProd // mantem produto/recurso/despesa?
					RecLock("AF4",.F.,.T.)
					AF4->(DbDelete())
					AF4->(MsUnlock())
				Else
					//guarda o ultimo item da despesa da tarefa
					cItemAF4 := AF4->AF4_ITEM
				EndIf
				AF4->(DbSkip())
			EndDo
		EndIf

		RegToMemory("AF2",.F.)
		nRetAF2	:= AF2->(RecNo())
		
	EndIf

	FkCommit()
	
	dbSelectArea("AE2")
	dbSetOrder(1)
	dbSeek(xFilial()+cCompos)
	While !Eof() .And. xFilial()+cCompos == AE2->AE2_FILIAL+AE2->AE2_COMPOS
		//Ponto de entrada utilizado para gravar no Recurso da Tarefa valores do Orcamento do Boletim
		lPadrao := .T.
		If ExistBlock("PMA101E2")
			If !Empty(AE2->AE2_RECURS)
				cAux := Soma1(cItemRec)
			Else
				cAux := Soma1(cItemAF3)
			EndIf

			If ExecBlock("PMA101E2",.F.,.F.,{cAux})==.T.
				lPadrao := .F.
				If !Empty(AE2->AE2_RECURS)
					cItemRec := cAux
				Else
					cItemAF3 := cAux
				EndIf
			EndIf
		EndIf

		If lPadrao 
			RegToMemory("AF3",.T.)
			If SB1->(dbSeek(xFilial()+AE2->AE2_PRODUT)) .or. Empty(AE2->AE2_PRODUT)
				RecLock("AF3",.T.)
				For nx := 1 TO FCount()
					FieldPut(nx,M->&(EVAL(bCampo,nx)))
				Next nx
				AF3->AF3_FILIAL := xFilial("AF3")
				AF3->AF3_ORCAME := IF(lCriaAF2,AF2->AF2_ORCAME,cOrcame)
				AF3->AF3_TAREFA := IF(lCriaAF2,AF2->AF2_TAREFA,cTarefa)
				AF3->AF3_PRODUT := AE2->AE2_PRODUT
				AF3->AF3_QUANT  := PmsAF3Quant(AF3->AF3_ORCAME,AF3->AF3_TAREFA,AF3->AF3_PRODUT,nQuant,AE2->AE2_QUANT,,.T.)
				If !ExistTemplate("CCTAF3QUANT") .And. GetMV("MV_PMSCUST")=="2"
					AF3->AF3_QUANT := nQuant * AE2->AE2_QUANT
				EndIf
				AF3->AF3_MOEDA  := Val(RetFldProd(SB1->B1_COD,"B1_MCUSTD"))
				AF3->AF3_CUSTD  := RetFldProd(SB1->B1_COD,"B1_CUSTD")
				AF3->AF3_ACUMUL := "3"
				AF3->AF3_COMPOS := cCompos
				AF3->AF3_QTSEGU := AE2->AE2_QTSEGU
	
				If  !Empty(AE2->AE2_RECURS)
					If Empty(AE2->AE2_PRODUT)
						AF3->AF3_MOEDA	:= 1
					Endif                                                 
					
					AF3->AF3_RECURS	:= AE2->AE2_RECURS
					AE8->(dbSetOrder(1))
					AE8->(dbSeek(xFilial()+AE2->AE2_RECURS))
					If AE8->AE8_VALOR >0 .AND. ( AE8->AE8_PRODUT == AE2->AE2_PRODUT .OR. Empty(AE2->AE2_PRODUT) )
						AF3->AF3_CUSTD := AE8->AE8_VALOR
					EndIf
					cItemRec      := Soma1(cItemRec)
					AF3->AF3_ITEM := cItemRec
				Else
					cItemAF3      := Soma1(cItemAF3)
					AF3->AF3_ITEM := cItemAF3
				EndIf
				// Rever gravacao da 2a UM!!!
	
				If ExistTemplate("CCT101_1")
					ExecTemplate("CCT101_1",.F.,.F.,{cCompos,lSub})
				EndIf
			
				MsUnlock()
			Else
				Aviso(STR0026,STR0027+AE2->AE2_PRODUT+STR0028,{STR0015},2 )
			EndIf
		EndIf
		
		dbSelectArea("AE2")
		dbSkip()
	End

	dbSelectArea("AE3")
	dbSetOrder(1)
	dbSeek(xFilial()+cCompos)
	While !Eof() .And. xFilial()+cCompos == AE3->AE3_FILIAL+AE3->AE3_COMPOS

		//Ponto de entrada utilizado para gravar na Despesa da Tarefa valores do Orcamento do Boletim
		lPadrao := .T.
		If ExistBlock("PMA101E3")
			cAux := Soma1(cItemAF4)
			If ExecBlock("PMA101E3",.F.,.F.,{cAux})==.T.
				lPadrao  := .F.
				cItemAF4 := cAux
			EndIf
		EndIf

		If lPadrao
			cItemAF4 := Soma1(cItemAF4)
			RegToMemory("AF4",.T.)		
			RecLock("AF4",.T.)
			For nx := 1 TO FCount()
				FieldPut(nx,M->&(EVAL(bCampo,nx)))
			Next nx
			AF4->AF4_FILIAL := xFilial("AF4")
			AF4->AF4_ORCAME := AF2->AF2_ORCAME
			AF4->AF4_ITEM   := cItemAF4
			AF4->AF4_TAREFA := AF2->AF2_TAREFA
			AF4->AF4_DESCRI := AE3->AE3_DESCRI
			AF4->AF4_MOEDA  := AE3->AE3_MOEDA
			AF4->AF4_VALOR  := PmsAF4Valor(nQuant,AE3->AE3_VALOR,.T.)
			AF4->AF4_TIPOD  := AE3->AE3_TIPOD
			AF4->AF4_COMPOS := cCompos
	
			If ExistTemplate("CCT101_2")
				ExecTemplate("CCT101_2",.F.,.F.,{cCompos})
			EndIf
	
			MsUnlock()
		EndIf

    	dbSelectArea("AE3")
		dbSkip()
	End

 	// grava o custo da tarefa
	If ExistTemplate("PMAAF2CTrf")
		ExecTemplate("PMAAF2CTrf",.F.,.F.,{AF2->AF2_ORCAME,AF2->AF2_TAREFA})
	Else
		aRetCus	:= PmsAF2CusTrf(0,AF2->AF2_ORCAME, AF2->AF2_TAREFA)
		RecLock("AF2",.F.)
		Replace AF2->AF2_CUSTO  With aRetCus[1]
		Replace AF2->AF2_CUSTO2 With aRetCus[2]
		Replace AF2->AF2_CUSTO3 With aRetCus[3]
		Replace AF2->AF2_CUSTO4 With aRetCus[4]
		Replace AF2->AF2_CUSTO5 With aRetCus[5]
		AF2_VALBDI:= aRetCus[1]*IIf(AF2->AF2_BDI <> 0,AF2->AF2_BDI,PmsGetBDIPad('AF2',AF2->AF2_ORCAME,,AF2->AF2_EDTPAI))/100
		AF2_TOTAL := aRetCus[1]+AF2->AF2_VALBDI
		MsUnLock()										

	 EndIf
    
	PmsAvalAF2("AF2")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica a existencia do ponto de entrada PMA101IMP.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("PMA101IMP")
		ExecBlock("PMA101IMP",.F.,.F.,{cCompos,nQuant})
	EndIf
	
	If ExistTemplate("PMA101IMP")
		ExecTemplate("PMA101IMP",.F.,.F.,{cCompos})
	EndIf
	

	dbSelectArea("AE4")
	dbSetOrder(1)
	dbSeek(xFilial()+cCompos)
	While !Eof() .And. xFilial()+cCompos == AE4->AE4_FILIAL+AE4->AE4_COMPOS
		If lCriaAF2
			nAuxAF2 := PMS101IMPOR(nRecAF1,cNivelTrf,AE4->AE4_SUBCOM,AE4->AE4_QUANT*nQuant,AF2->AF2_TAREFA,cEDTPai,.F.,@cItemAF3,@cItemAF4,AF2->(Recno()),nGravaQuant,cOrcame,cDescri,.T.,,@cItemRec)
		Else
			nAuxAF2 := PMS101IMPOR(nRecAF1,cNivelTrf,AE4->AE4_SUBCOM,AE4->AE4_QUANT*nQuant,cTarefa,cEDTPai,.F.,@cItemAF3,@cItemAF4,AF2->(Recno()),nGravaQuant,cOrcame,cDescri,.T.,,@cItemRec)
		EndIf
		dbSelectArea("AE4")
		dbSkip()
	End

EndIf

RestArea(aAreaAF2)
RestArea(aAreaAE1)
RestArea(aAreaAE2)
RestArea(aAreaAE3)
RestArea(aAreaAE4)
RestArea(aAreaSB1)
RestArea(aArea)

Return nRetAF2

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS101PRED³ Autor ³ Edson Maricate        ³ Data ³ 18-05-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de validacao da Predecessora da tarefa.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA101                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS101PRED()


Local aArea		:= GetArea()
Local lRet		:= .T.
Local cPredec	:= &(ReadVar())

If !Empty(cPredec)
	lRet := ExistCpo("AF2",M->AF5_ORCAME+cPredec,1)
EndIf

RestArea(aArea)
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMS101PRDE³ Autor ³ Edson Maricate        ³ Data ³ 18-05-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de validacao da Predecessora da tarefa ( EDT )         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA101                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMS101PrdE()

Local aArea		:= GetArea()
Local lRet		:= .T.
Local cPredec	:= &(ReadVar())

If !Empty(cPredec)
	If cPredec!=M->AF5_EDTPAI
		lRet := ExistCpo("AF5",M->AF5_ORCAME+cPredec,1)
	Else
		lRet := .F.
	EndIf
EndIf

RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ExistOrcT ³ Autor ³ Adriano Ueda         ³ Data ³ 07-06-2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para verificar a existencia de determinada tarefa.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cProjeto : codigo do projeto                                 ³±±
±±³          ³ cTarefa  : codigo da tarefa                                  ³±±
±±³          ³ lMensagem: indica se exibira o help de ja gravado            ³±±
±±³          ³            (default: .T.)                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ExistOrcTrf(cOrcamento, cTarefa, lMensagem)
	Local aAreaAF2 := AF2->(GetArea())
	Default lMensagem := .T.
	
	dbSelectArea("AF2")
	AF2->(dbSetOrder(1))
	
	If AF2->(Msseek(xFilial("AF2") + cOrcamento + cTarefa))
		If lMensagem
			Help(" ", 1, "JAGRAVADO")
		EndIf
		
		lRet := .T.
	Else
		If !(FreeForUse("AF2", cOrcamento + cTarefa))
			MsgAlert(STR0025) //"Código Reservado!"
			lRet := .T.
		Else
			lRet := .F.	
		EndIf
	EndIf		
   FreeUsedCode(.T.)
	RestArea(aAreaAF2)
Return lRet


Static Function AtuBDITarefas(aEDTSPai)
Local aAreaAF5	:=	{}
Local cEdtAtu	:=	AF5->AF5_ORCAME+AF5->AF5_EDT
AAdd(aEDTSPAI,{AF5->AF5_NIVEL,AF5->AF5_EDT})
AF5->(dBsEToRDER(2))     
AF5->(DbSeek(xFilial()+cEdtAtu))
While !AF5->(Eof()) .And. xFilial('AF5')==AF5->AF5_FILIAL.And. cEdtAtu	==	AF5->AF5_ORCAME+AF5->AF5_EDTPAI
	If AF5->AF5_BDITAR == 0   
		aAreaAF5	:=	AF5->(GetArea())
		AtuBDITarefas(@aEDTSPai)
		RestArea(aAreaAF5)
	Endif	   
	AF5->(DbSkip())
Enddo						
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Ana Paula N. Silva     ³ Data ³30/11/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados     ³±±
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
Local aRotina 	:= {	{ STR0002, "AxPesqui"  , 0 , 1,,.F.},; //"Pesquisar"
							{ STR0003,"PMS101Dlg", 0 , 2},; //"Visualizar"
							{ STR0004,   "PMS101Dlg", 0 , 3},; //"Incluir"
							{ STR0005,   "PMS101Dlg", 0 , 4},; //"Alterar"
							{ STR0006,   "PMS101Dlg", 0 , 5},; //"Excluir"
							{ STR0007,"MSDOCUMENT",0,4 }} //"Conhecimento"
Return(aRotina)
