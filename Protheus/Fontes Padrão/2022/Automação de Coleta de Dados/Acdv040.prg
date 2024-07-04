#INCLUDE "Acdv040.ch" 
#INCLUDE "protheus.ch"
#INCLUDE "apvt100.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ ACDV040    ³ Autor ³ Desenv.    ACD      ³ Data ³ 08/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Requisicao de materias por OP / Centro de Custo            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ ExpC1 = Caso queira padronizar programas de movimentacao   ³±±
±±³          ³         interna deve passar o nome do programa             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/           
Function ACDV040()
Local nOpc
Local cOperador := CBRetOpe()

If Empty(cOperador)
	VTBeep(2)
	VTAlert(STR0026,STR0013,.T.,3000) //"Operador nao cadastrado"###"Aviso"
Else
	@ 0,0 VTSAY Padr(STR0027,VTMaxCol()) //"Requisicao/Devolucao"
	@ 1,0 VTSay STR0028 //"Selecione:"
	nOpc:=VTaChoice(3,0,5,VTMaxCol(),{STR0029,STR0030}) //"Ordem de Producao"###"Centro de Custo"
	If nOpc == 1 // por Ordem de Producao
		ACDV041()
	ElseIf nOpc == 2 // por Centro de Custo
		ACDV042()
	EndIf
EndIf
Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ ACDV041    ³ Autor ³ Desenv.    ACD      ³ Data ³ 08/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Requisicao de materias por OP / Centro de Custo            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ ExpC1 = Caso queira padronizar programas de movimentacao   ³±±
±±³          ³         interna deve passar o nome do programa             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/    
Function ACDV041()
ACDV040X(1)
Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ ACDV042    ³ Autor ³ Desenv.    ACD      ³ Data ³ 08/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Requisicao de materias por OP / Centro de Custo            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ ExpC1 = Caso queira padronizar programas de movimentacao   ³±±
±±³          ³         interna deve passar o nome do programa             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/    
Function ACDV042()
ACDV040X(2)
Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ ACDV040X   ³ Autor ³ Desenv.    ACD      ³ Data ³ 08/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Requisicao de materias por OP / Centro de Custo            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ ExpC1 = Caso queira padronizar programas de movimentacao   ³±±
±±³          ³         interna deve passar o nome do programa             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/    
Static Function ACDV040X(nOpc)
Local nLinha   := 0
Local lSai     := .f.
Local lImprimiu:= .f.
Local lErroEAN13 := .F.
Local lAbortou   := .F.
Local lACD040TM	 := ExistBlock("ACD040TM")
Local lLocaliz	:= GetMv("MV_LOCALIZ")=="S"
Local lImg00		:= ExistBlock('IMG00')
Local 	lACD040GR	:= ExistBlock('ACD040GR')
Local nX       := 0
Local nQtdAnt  := 0
Local aTela
Local nColArm
local cPicEnd
Local cCodProd := ""
Local cIMETREQ	:= GetMV("MV_IMETREQ")
Local 	cEndProc	:= GetMV("MV_ENDPROC")
Local bkey09
Local bKey16
Local bKey24
Local nTamTM    := TamSX3("F5_CODIGO")[1]
Local nTamLote  := TamSX3("B8_LOTECTL")[1]
Local nTamSLote := TamSX3("B8_NUMLOTE")[1]
Local nTamSeri  := TamSX3("BF_NUMSERI")[1]
Local nTamEnd   := TamSX3("BF_LOCALIZ")[1]
Local nTamTRT   := TamSX3("D4_TRT")[1]
Local nTamOP    := TamSX3("D3_OP")[1]
Local nTamOPCP	 := Tamsx3("CBH_OP")[1]
Private cTM  := " "
Private cOP  := " "
Private cEti
Private cArmProc   := GetMvNNR('MV_LOCPROC','99')
Private lForcaQtd  := SuperGetMV("MV_ACDQTD",.F.,.F.)
Private cOperador  := CBRetOpe()
Private cArmazem
Private cEndereco
Private cEtiEnd
Private cCC
Private cLote      := Space(nTamLote)
Private cSLote     := Space(nTamSLote)
Private cNumSeri   := Space(nTamSeri)
Private cTRT       := Space(nTamTRT)
Private cOPCB0     := Space(nTamOP)
Private nQtdEtiq   := 1
Private nPosEnd    := 0
Private nQtdPar    := 0
Private dValid     := ctod('')
Private aEtiqueta  := {}
Private aHisEti    := {}
Private aHistOP    := {}
Private lPENSerDv  := ExistBlock("SD3NSDV")
Private lNumSerDev := .F.
Private lMSErroAuto:= .F.
IF !Type("lVT100B") == "L"
	Private lVT100B := .F.
EndIf

If lForcaQtd
	nQtdEtiq := 0
EndIf

bkey09 := VTSetKey(09,{|| ACD040Hist()},STR0031) //"Informacoes"
bKey16 := VTSetKey(16,{|| ACD040Imp()},STR0032)  // CTRL+P //"Imprime"
bKey24 := VTSetKey(24,{|| Estorna()},STR0033)    // CTRL+X //"Estorno"

If Empty(cOperador)
	VTBeep(2)
	VTAlert(STR0026,STR0013,.T.,3000) //"Operador nao cadastrado"###"Aviso"
	Return .F.
EndIf

If Empty(cArmProc)
	VTBeep(2)
	VTAlert(STR0034,STR0013,.T.,3000) //"Informe o local padrao para os materiais em processo - MV_LOCPROC"###"Aviso"
	Return .F.
EndIf

VtClearBuffer()

While .T.
	VTClear()
	cTM       := Space(nTamTM)
	aHisEti   := {}
	aHistOP   := {}
	aTela     := {}
	cLote     := Space(nTamLote)
	cSLote    := Space(nTamSLote)
	dValid    := ctod('')
	cTRT      := Space(nTamTRT)
	If lForcaQtd
		nQtdEtiq  := 0
	Else
		nQtdEtiq  := 1
	EndIf
	nLinha    := 0
	aEtiqueta := {}
	cArmazem  := Space(Tamsx3("B1_LOCPAD")[1])
	nColArm	  := If(Len(cArmazem) < 4,3,6)
	cPicEnd	  := If(Len(cArmazem) < 4,"@!","@!S11")
	cEti      := If(UsaCB0("01"),Space(20), IIf( FindFunction( 'AcdGTamETQ' ), AcdGTamETQ(), Space(48) ) )
	cEtiEnd   := Space(20)
	cEndereco := Space(nTamEnd)
	cOP	      := Space(nTamOPCP)
	cCC       := Space(Len(SD3->D3_CC))
	cNumSeri  := Space(nTamSeri)
	cOPCB0    := Space(nTamOP)
	nQtdPar   := 0
	lSai      := .f.
	If lACD040TM
		cTm := ExecBlock("ACD040TM")
		cTm := If(ValType(cTm)=="C",cTm,space(nTamTM))
		If !Empty(cTm)
			@ ++nLinha,0 VTSay STR0002+Space(01)+cTm
			If ! VldTM(@nLinha,@cOP,nOpc)
				Exit
			EndIf
		EndIf
	EndIf

	If Empty(cTM)
		@ nLinha,0 VTSay Padr(STR0027,VTMaxCol()) //"Requisicao/Devolucao"
		@ ++nLinha,0 VTSay STR0002  VTGet cTM  pict '@!' Valid VldTM(@nLinha,@cOP,nOpc) F3 "SF5" When Empty(cTM)
		VTRead
		If VTLastKey() == 27
			Exit
		EndIf
	EndIf
	cOPCB0 := cOp
	If !UsaCB0("01")
		If lLocaliz
			If VTMaxRow() < 8
				VtClear()
				nLinha:=-1
			EndIf
			@ ++nLinha,0 VTSay STR0004 //"Endereco"
			If ! UsaCB0("02")
				@ ++nLinha,0 VTGet cArmazem pict '@!' Valid !Empty(cArmazem)
				@ nLinha,nColArm VTSay "-" VTGet cEndereco pict cPicEnd valid Iif(!Empty(cEndereco),VldEnd(),IIf(lForcaQtd,VldEnd(.T.),.T.))
			Else
				@ ++nLinha,0 VTGet cEtiEnd pict '@!' Valid VldEnd()
				nPosEnd := nLinha
			EndIf
		Else
			@ ++nLinha,0 VTSay STR0005 //"Armazem"
			@ nLinha,9 VTGet cArmazem pict '@!' Valid (!Empty(cArmazem) .And. IIF(!lForcaQtd,.T.,VldEnd(.T.)))
		EndIf
	EndIf
	If VTLastKey() == 27
		Return
	EndIf
	nLinAnt:= nLinha
	while .t.
		If UsaCB0("01")
			If SF5->F5_TIPO == "D"
				nLinha:= nLinha+1
			EndIf
			@ nLinha,0 VTSay Padr(STR0006,VTMaxCol()) //"Produto"
			@ ++nLinha,0 VTGet cEti pict '@!' Valid VldEtiq(@cOP,nLinha)
		Else
			If lVT100B
				@ ++nLinha,0 VTSay STR0007 VTGet nQtdEtiq pict CBPictQtde() valid nQtdEtiq > 0 when VTLastKey() == 5
				@ ++nLinha,0 VTSay STR0006 VTGet cEti pict '@!' Valid VTLastkey() == 5 .or. VldEtiq(@cOP,nLinha)
			else
				@ ++nLinha,0 VTSay STR0007 //"Quantidade"
				@ ++nLinha,0 VTGet nQtdEtiq pict CBPictQtde() valid nQtdEtiq > 0 when VTLastKey() == 5
				@ ++nLinha,0 VTSay STR0006 //"Produto"
				@ ++nLinha,0 VTGet cEti pict '@!' Valid VTLastkey() == 5 .or. VldEtiq(@cOP,nLinha)
			endif
		EndIf
		VTRead
		If ! VtLastkey() == 27
			Exit
		EndIf
		If Empty(aHisEti)
			If VTYesNo(STR0035,STR0036,.t.) //'Aborta a operacao ?'###'Pergunta'
				VtClearGet("cEti")
				lSai:= .t.
				Exit
			Else
				nLinha:= nLinAnt
				Loop
			EndIf
		EndIf
		If ! VtYesNo(STR0037+If(SF5->F5_TIPO=="R",STR0038,STR0039),STR0009,.t.,3000) //"Confirma a "###"requisicao?"###"devolucao?"###"Atencao"
			If VTYesNo(STR0035,STR0036,.t.) //'Aborta a operacao ?'###'Pergunta'
				VtClearGet("cEti")
				lSai:= .t.
				Exit
			Else
				nLinha:= nLinAnt
				Loop
			EndIf
		EndIf
		Exit
	EndDo
	If lSai
		Exit
	EndIf
	If Empty(aHisEti)
		Loop
	EndIf
	VTMSG(STR0010) //"Aguarde..."
	If ! Empty(aHistOP)
		aHisEti:= aSort(aHisEti,,,{|x,y| x[8]+x[2] < y[8]+y[2]})
	EndIf
	Begin Transaction
		For nX:= 1 to len(aHisEti)
			cEti := aHisEti[nX,1]
			If UsaCB0("01")
				aEtiqueta := CBRetEti(cEti,"01",,.T.)
			Else
				SB1->(DbSetOrder(1))
				If SB1->(MsSeek(xFilial("SB1")+cEti))
					cEti := SB1->B1_CODBAR
					cCodProd := SB1->B1_COD
					If Empty(cEti)
						cEti := cCodProd
					EndIf
				EndIf
				aEtiqueta := CBRetEtiEAN(cEti)
				If Empty(aEtiqueta)
					VTBeep(2)
					// "Utilizacao incorreta do codigo EAN13. Produto: " ### "FALHA"
					VTAlert(STR0087+cCodProd,STR0088,.t.,4000)
					// "SIM: abortar toda a operacao. NAO: abortar apenas esse produto","Abortar operacao?"
					If VtYesNo(STR0089,STR0035,.t.,3000)
						VTKeyBoard(chr(20))
						DisarmTransaction()
						lErroEAN13 := .T.
						lAbortou   := .T.
						Exit
					Else
						lErroEAN13 := .T.
						Loop
					EndIf
				Else
					lErroEAN13 := .F.
				EndIf
			EndIf
			aEtiqueta[1]:= aHisEti[nX,2]
			nQtdPar     := aHisEti[nX,3]
			cLote       := aHisEti[nX,4]
			cSLote      := aHisEti[nX,5]
			cArmazem    := aHisEti[nX,6]
			cEndereco   := aHisEti[nX,7]
			cOP         := aHisEti[nX,8]
			cCC         := aHisEti[nX,9]
			cDoc        := aHisEti[nX,10]
			cNumSeri    := aHisEti[nX,11]
			cTRT        := aHisEti[nX,12]
			If ! Grava(cOP)
				DisarmTransaction()
				Break
			EndIf
			If UsaCB0("01")
				nQtdAnt := aEtiqueta[2]
				GravaCB0(cOP)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Obrigatoriamente o SD3 deve estar posicionado para  garan-³
				//³tir que seja informado o codigo do documento correto aten-³
				//³dendo o bops 00000087412                                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cDoc    := SD3->D3_DOC
			EndIf
			CBLog(If(SF5->F5_TIPO=="R","06","10"),{aEtiqueta[1],nQtdPar,cLote,cSLote,cArmazem,cEndereco,cOP,cCC,cTM,cEti})
			If (cIMETREQ $ "13" .or. SF5->F5_TIPO=="D") .and. nQtdPar < nQtdAnt
				lImprimiu:= Imprime(nX)
				If ! Empty(aHistOP) .AND. cIMETREQ == "1"
					If nX < len(aHisEti) .and. aHisEti[nX,8]#aHisEti[nX+1,8] .and. SF5->F5_TIPO=="R"
						If lImg00
							ExecBlock("IMG00",,,{"ACDV040",cTM,If(SF5->F5_TIPO=="R",aHisEti[nX,8],"")})
						EndIf
					EndIf
				EndIf
				If SF5->F5_TIPO # "R"
					Loop
				EndIf
				If ! CBArmProc(CB0->CB0_CODPRO,cTM) // Verifica se o produto e do armazem de processo (MV_LOCPROC)
					Loop
				EndIf
				If ! Empty(cEndProc) .AND. CB0->CB0_LOCAL == cArmProc
					If ! DistriProc(CB0->CB0_CODPRO,CB0->CB0_NUMSEQ,CB0->CB0_QTDE,CB0->CB0_LOTE,CB0->CB0_SLOTE,CB0->CB0_NUMSER)				
						DisarmTransaction()
						Break
					EndIf
					If UsaCB0("01")
						CBGrvEti("01",{NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,cEndProc,Nil,,Nil},CB0->CB0_CODETI)
						CBLog("01",{CB0->CB0_CODPRO,CB0->CB0_QTDE,CB0->CB0_LOTE,CB0->CB0_SLOTE,CB0->CB0_LOCAL,cEndProc,CB0->CB0_NUMSEQ,cDoc,CB0->CB0_CODETI})
					Else
						CBLog("01",{CB0->CB0_CODPRO,CB0->CB0_QTDE,CB0->CB0_LOTE,CB0->CB0_SLOTE,CB0->CB0_LOCAL,cEndProc,CB0->CB0_NUMSEQ,cDoc,""})
					EndIf
				Endif
			Else
				If ! CBArmProc(CB0->CB0_CODPRO,cTM) // Verifica se o produto e do armazem de processo (MV_LOCPROC)
					Loop
				EndIf
				If Empty(cEndProc) .OR. CB0->CB0_LOCAL # cArmProc
					Loop
				EndIf
				If ! DistriProc(aEtiqueta[1],SD3->D3_NUMSEQ,nQtdPar,cLote,cSLote,cNumSeri)
					DisarmTransaction()
					Break
				EndIf
				If UsaCB0("01")
					CBGrvEti("01",{NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,cEndProc,Nil,,Nil},CB0->CB0_CODETI)
				EndIf
			EndIf
		Next
		If !lErroEAN13 .And. lACD040GR
			Execblock('ACD040GR',.F.,.F.)
		EndIf
	End Transaction
	If lAbortou
		VTAlert(STR0090,STR0013,.t.,4000) // "Operacao abortada"###"Aviso"
	EndIf
	If lMSErroAuto
		VTDispFile(NomeAutoLog(),.t.)
	Else
		If lImprimiu //Imprime folha de rosto, pois imprimiu as etiquetas Img01
			If ! Empty(aHistOP)
				If lImg00
					ExecBlock("IMG00",,,{"ACDV040",cTM,If(SF5->F5_TIPO=="R",aHisEti[Len(aHisEti),8],"")})
				EndIf
			Else
				If lImg00
					ExecBlock("IMG00",,,{"ACDV040",cTM,""})
				EndIf
			EndIf
			MSCBCLOSEPRINTER()
		EndIf
	EndIf
Enddo

Vtsetkey(09,bkey09)
Vtsetkey(16,bkey16)
Vtsetkey(24,bkey24)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ VldTm      ³ Autor ³ Desenv.    ACD      ³ Data ³ 17/06/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica integridade no tipo de movimento                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VldTM(nLinha,cOP,nOpc)
Local aTela
Local cC2Pict	:= X3Picture("C2_NUM")

If Empty(cTM)
	VTKeyBoard(chr(23))
	Return .f.
EndIf
If !VTExistCPO("SF5",cTM,,STR0011,.T.)   //"Tipo de movimento nao existe."
	VtClearGet("cTM")
	Return .f.
EndIf
If ! SF5->F5_TIPO $"RD"
	VTBeep(2)
	VTAlert(STR0040 ,STR0013,.t.,4000) //"Tipo de Movimento invalido"###"Aviso"
	VTKeyBoard(chr(20))
	Return .f.
EndIf
If SF5->F5_TIPO=="R"
	@ nLinha-1,0 VTSay Padr(STR0001,VTMaxCol()) //"Requisicao"
Else
	@ nLinha-1,0 VTSay Padr(STR0041,VTMaxCol()) //"Devolucao"
EndIf
VtClearBuffer()
If SF5->F5_TIPO # "R"
	Return .t.
EndIf
aTela:= VtSave()
nLinha++
While .t.
	If nOpc == 1
		@ nLinha,0 VTSaY STR0003 VTGet cOP  Pict cC2Pict Valid VtLastKey()==5 .or. VldOP(cOP) F3 "SC2"   //"O.P."
		VTREAD
	Else
		@ nLinha,0 VTSaY "C.C." VTGet cCC  Pict "@!" Valid VtLastKey()==5 .or. VldCC() F3 "CTT" When Empty(cCC)  // "Centro de Custo"
		VTREAD
	EndIf
	If VtLastkey() == 27 .and. nOpc == 1
		aHistOP:= {}
		VtRestore(,,,,aTela)
		nLinha:=nLinha-1
		Return .f.
	ElseIf VtLastkey() == 27 .and. nOpc # 1
		VtRestore(,,,,aTela)
		nLinha:=nLinha-1
		Return .f.
	EndIf
	Exit
Enddo
VtClearBuffer()
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ VldOP      ³ Autor ³ Desenv.    ACD      ³ Data ³ 17/06/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica integridade da Ordem de Producao                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VldOP(cOP)
Local nPos
If Empty(cOp) .and. len(aHistOp) > 0
	Return .t.
ElseIf Empty(cOp) .and. len(aHistOp) <= 0
	VTKeyBoard(chr(23))
	Return .f.
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se Existe e posiciona o registro             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SC2->(DbSetOrder(1))
If ! SC2->(DbSeek(xFilial("SC2")+cOP))
	VTBeep(2)
	VTAlert(STR0042,STR0013,.T.,3000) //"OP nao cadastrada"###"Aviso"
	VTKeyBoard(chr(20))
	Return .F.
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se OP ja foi encerrada                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(SC2->C2_DATRF)
	VTBeep(2)
	VTAlert(STR0043,STR0013,.T.,3000) //"OP ja Encerrada"###"Aviso"
	VTKeyBoard(chr(20))
	Return .F.
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se OP e do tipo Firme                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SC2->C2_TPOP # "F"
	VTBeep(2)
	VTAlert(STR0044,STR0013,.T.,3000)  //"Nao e permitida movimentacao com OPs Previstas"###"Aviso"
	VTKeyBoard(chr(20))
	Return .F.
EndIf
nPos:= Ascan(aHistOP,{|x| x == cOP})
If nPos == 0
	aadd(aHistOP,cOP)
Else
	VTBeep(2)
	VTAlert(STR0045,STR0013 ,.t.,4000) //"OP ja informada"###"Aviso"
	VtClearGet(STR0046) //"cOP"
	Return .f.
EndIf
If GetMV("MV_MULTOPS") # "1"
	Return .t.
EndIf
VtClearGet("cOP")
Return .f.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ VldCC      ³ Autor ³ Desenv.    ACD      ³ Data ³ 19/11/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica integridade do Centro de custo                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function VldCC()

If Empty(cCC)
	VTKeyBoard(chr(23))
	Return .f.
EndIf
If !VTExistCPO("CTT",cCC,,STR0047,.T.) //"Centro de custo nao cadastrado"
	VTKeyBoard(chr(23))
	Return .f.
EndIf
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ VldEtiq    ³ Autor ³ Desenv.    ACD      ³ Data ³ 17/06/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica integridade na etiqueta de codigo de barras       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function VldEtiq(cOP,nLinAtual)
Local nTamLocal := TamSX3("B2_LOCAL")[1]
Local cTipID
Local cErros    := ""
Local cLocOri   := Space(nTamLocal)
Local cArmSD4   := Space(nTamLocal)
Local nQuant    := 0
Local nResto    := 0
Local nX,nY,nW
Local nQE,nQtdTotOP
Local nTamcOp	 := Tamsx3("CBH_OP")[1]
Local aCab      := {}
Local aSize     := {}
Local lConfSD4  := GetMV("MV_CBCFSD4") == "1" // --> Confere se o produto a ser requistado pertence ao Empenho
Local lConfSG1  := GetMV("MV_CBCFSG1") == "1" // --> Confere se o produto a ser requistado pertence a Estrutura
Local lAtuEmp   := (SF5->F5_ATUEMP # "N")
Local lBaixaEmp := .F.
Local lBxEmpB8  := .F.
Local aSave     := VTSAVE()
Local nTotQtde  := 0
Local nSaldo    := 0
Local cQuery    := ""
Local lQuery    := .F.
Local cAliasSD4 := "SD4"
Local lRet      := .T.
Local aTam      := {}
Local cB5Pict	:= X3Picture("C2_NUM")
Local nTamOPrd	:= TamSx3( 'D4_OP' )[ 1 ]
Local cPrdFan	:= ""
Local nRecSG1   := 0

PRIVATE l241    := .F. //Utilizada na funcao A240AvalEm (mata240.prx)
IF !Type("lVT100B") == "L"
	Private lVT100B := .F.
EndIf
Default nLinAtual := 6
If Empty(cEti)
	Return .f.
EndIf
If VtLastKey() == 27
	Return .t.
EndIf
If UsaCB0("01")
	aEtiqueta := CBRetEti(cEti,"01",,.T.)
	If Empty(aEtiqueta)
		VTBeep(2)
		VTAlert(STR0016,STR0013,.t.,4000) //"Etiqueta invalida"###"Aviso"
		VTKeyBoard(chr(20))
		Return .f.
	EndIf
	If Ascan(aHisEti,{|x| x[1]== CB0->CB0_CODETI}) > 0
		VTBeep(2)
		VTAlert(STR0024,STR0013,.t.,4000) //"Aviso" //"Etiqueta ja lida"
		VTKeyBoard(chr(20))
		Return .f.
	EndIf
	If Empty(aEtiqueta[2])
		aEtiqueta[2] := 1
	EndIf
	nQtdPar:= If(GetMV("MV_SGQTDRE") # "1",0,aEtiqueta[2])
	If SF5->F5_TIPO == "D"
		If aEtiqueta[10] == aEtiqueta[20]
			VTBeep(2)
			VTAlert(STR0016,STR0013,.t.,4000) //"Etiqueta invalida"###"Aviso"
			VTKeyBoard(chr(20))
			Return .f.
		EndIf
		If CBArmProc(aEtiqueta[1],cTm) .and. Empty(aEtiqueta[9])
			VTBeep(2)
			VTAlert(STR0048,STR0013,.t.,4000) //"Etiqueta nao enderecada no armazem de processos"###"Aviso"
			VTKeyBoard(chr(20))
			Return .f.
		EndIf
		If CBArmProc(aEtiqueta[1],cTm) .and. aEtiqueta[10] # cArmProc
			VTBeep(2)
			VTAlert(STR0049,STR0013,.t.,4000) //"Etiqueta nao pertence ao armazem de processos"###"Aviso"
			VTKeyBoard(chr(20))
			Return .f.
		EndIf
		If aEtiqueta[10]==cArmProc .and. Empty(aEtiqueta[20])
			VTBeep(2)
			VTAlert(STR0016,STR0013,.t.,4000) //"Etiqueta invalida"###"Aviso"
			VTKeyBoard(chr(20))
			Return .f.
		EndIf
		If Empty(aEtiqueta[19]+aEtiqueta[22])
			If VTYesNo(STR0050,STR0036,.t.) //'Pergunta' //'Informa OP ?'
				cOP := Space(nTamcOp)				
				If lVT100B
					//VTClear(0,0,3,19)
					@ 0,0 VTSay Padr(STR0051,VTMaxCol()) //"O.P"
					@ 1,0 VTGet cOP pict cB5Pict valid ValidOP(cOP) F3 "CB6"
					@ 2,0 VtSay STR0007 //"Quantidade"
					@ 3,0 VtGet nQtdPar pict CBPictQtde() valid VldQuant(SF5->F5_TIPO,.f.,cOP)
				else
					@ 2,0 VTSay Padr(STR0051,VTMaxCol()) //"O.P"
					@ 3,0 VTGet cOP pict cB5Pict valid ValidOP(cOP) F3 "CB6"
					@ 4,0 VtSay STR0007 //"Quantidade"
					@ 5,0 VtGet nQtdPar pict CBPictQtde() valid VldQuant(SF5->F5_TIPO,.f.,cOP)
				endif
				VtRead
				If VtLastKey() == 27
					VTKeyBoard(chr(20))
					VtRestore(,,,,aSave)
					Return .f.
				EndIf
				aEtiqueta[22] := cOP
				VtRestore(,,,,aSave)
			Else
				cCC := Space(Len(SD3->D3_CC))
				If lVT100B
					//VTClear(0,0,3,19)
					@ 0,0 VTSay Padr(STR0052,VTMaxCol()) //"C.C"
					@ 1,0 VTSay Space(20)
					@ 1,0 VTGet cCC pict "@!" valid ValidCC(cCC) F3 "CTT"
					@ 2,0 VtSay STR0007 //"Quantidade"
					@ 3,0 VtGet nQtdPar pict CBPictQtde() valid VldQuant(SF5->F5_TIPO,.t.)
				else
					@ 2,0 VTSay Padr(STR0052,VTMaxCol()) //"C.C"
					@ 3,0 VTSay Space(20)
					@ 3,0 VTGet cCC pict "@!" valid ValidCC(cCC) F3 "CTT"
					@ 4,0 VtSay STR0007 //"Quantidade"
					@ 5,0 VtGet nQtdPar pict CBPictQtde() valid VldQuant(SF5->F5_TIPO,.t.)
				endif
				VtRead
				If VtLastKey() == 27
					VTKeyBoard(chr(20))
					VtRestore(,,,,aSave)
					Return .f.
				EndIf
				aEtiqueta[19] := cCC
				VtRestore(,,,,aSave)
			EndIf
			CBGrvEti("01",aEtiqueta,cEti)
		Else
			VTClear
			@ 2,0 VtSay STR0007 //"Quantidade"
			If !Empty(aEtiqueta[22])
				@ 3,0 VtGet nQtdPar pict CBPictQtde() valid VldQuant(SF5->F5_TIPO,.f.,aEtiqueta[22])
			Else
				@ 3,0 VtGet nQtdPar pict CBPictQtde() valid VldQuant(SF5->F5_TIPO,.t.)
			EndIf
			VTREAD
			If VTLastKey() == 27
				VtRestore(,,,,aSave)
				VtClearGet("cEti")
				Return .f.
			EndIf
		EndIf
	Else
		If ! Empty(aEtiqueta[19]+aEtiqueta[22])
			VTBeep(2)
			VTAlert(STR0016,STR0013,.t.,4000) //"Etiqueta invalida"###"Aviso"
			VTKeyBoard(chr(20))
			Return .f.
		EndIf
	EndIf
	nQtdEtiq := 1
	cArmazem := aEtiqueta[10]
	cEndereco:= aEtiqueta[9]
	cLote    := aEtiqueta[16]
	cSLote   := aEtiqueta[17]
	dValid   := aEtiqueta[18]
	cNumSeri := aEtiqueta[23]
	cOP      := aEtiqueta[22]
	If Empty(aEtiqueta[2]) .and. SF5->F5_TIPO # "D"
		VTBeep(2)
		VTAlert(STR0017,STR0013,.t.,4000) //"Etiqueta ja requisitada"###"Aviso"
		VTKeyBoard(chr(20))
		Return .f.
	EndIf
Else
	If ! CBLoad128(@cEti)
		VTKeyBoard(chr(20))
		Return .f.
	EndIf
	cTipId:=CBRetTipo(cEti)
	If ! cTipId $ "EAN8OU13-EAN14-EAN128"
		VTBEEP(2)
		VTALERT(STR0018,STR0013,.t.,4000) //"Etiqueta invalida."###"AVISO"
		VTKeyBoard(chr(20))
		Return .f.
	EndIf
	aEtiqueta := CBRetEtiEAN(cEti)
	If Empty(aEtiqueta) .or. Empty(aEtiqueta[2])
		VTBEEP(2)
		VTALERT(STR0018,STR0013,.t.,4000) //"Etiqueta invalida."###"AVISO"
		VTKeyBoard(chr(20))
		Return .f.
	EndIf       
	If Localiza(aEtiqueta[1]) .And. Empty(cEndereco) 
		VTBEEP(2)
		VTALERT(STR0086,STR0013,.T.,4000)
		VTKeyBoard(chr(20))
		Return .F.
	EndIf
	If SF5->F5_TIPO == "D"
		If VTYesNo(STR0050,STR0036,.t.) //'Informa OP ?'###'Pergunta'
			cOP:= Space(nTamcOp)
			If lVT100B
				VTClear(0,0,3,19)
				@ 0,0 VTSay Padr(STR0051,VTMaxCol()) //"O.P"
				@ 1,0 VTGet cOP pict cB5Pict valid ValidOP(cOP) F3 "CB6"
			else
				@ 4,0 VTSay Padr(STR0051,VTMaxCol()) //"O.P"
				@ 5,0 VTGet cOP pict cB5Pict valid ValidOP(cOP) F3 "CB6"
			endif
			VtRead
			If VtLastKey() == 27
				VTKeyBoard(chr(20))
				VtRestore(,,,,aSave)
				Return .f.
			EndIf
			VtRestore(,,,,aSave)
		Else
			cCC:= Space(Len(SD3->D3_CC))
			If lVT100B
				VTClear(0,0,3,19)
				@ 0,0 VTSay Padr(STR0052,VTMaxCol()) //"C.C"
				@ 1,0 VTGet cCC pict "@!" valid ValidCC(cCC) F3 "CTT"
			else
				@ 4,0 VTSay Padr(STR0052,VTMaxCol()) //"C.C"
				@ 5,0 VTGet cCC pict "@!" valid ValidCC(cCC) F3 "CTT"
			endif
			VtRead
			If VtLastKey() == 27
				VTKeyBoard(chr(20))
				VtRestore(,,,,aSave)
				Return .f.
			EndIf
			VtRestore(,,,,aSave)
		EndIf
	EndIf
EndIf
cErros := ''
If SF5->F5_TIPO # "D" .and. lConfSG1
	For nX := 1 to len(aHistOP)
		SC2->(DbSetOrder(1))
		SC2->(DbSeek(xFilial("SC2")+aHistOP[nX]))
		SG1->(DbSetOrder(2))
		If ! SG1->(DbSeek(xFilial("SG1")+aEtiqueta[1]+SC2->C2_PRODUTO))
			SG1->(DbSetOrder(1))
			SG1->(DbSeek(xFilial("SG1")+SC2->C2_PRODUTO))
			while SG1->(!EOF()) .and. SG1->(G1_FILIAL + G1_COD) == xFilial("SG1")+SC2->C2_PRODUTO
				nRecSG1 := SG1->(RECNO())
				dbSelectArea("SB1")
				MsSeek(xFilial('SB1')+SG1->G1_COMP)
				If RetFldProd(SG1->G1_COMP,"B1_FANTASM") == "S" 
					cPrdFan := SG1->G1_COMP
					SG1->(DbSetOrder(2))
					SG1->(Dbgotop())
					If !SG1->(DbSeek(xFilial("SG1")+aEtiqueta[1]+cPrdFan))
						cPrdFan:=""
					EndIf
				EndIF
				SG1->(Dbgoto(nRecSG1))
				SG1->(DbSkip())
			End Do
			If cPrdFan == ""
				cErros+=Alltrim(aHistOP[nX])+' '
			EndIF
		EndIf
	Next
ElseIf SF5->F5_TIPO == "D" .and. lConfSG1
	SC2->(DbSetOrder(1))
	SC2->(DbSeek(xFilial("SC2")+cOP))
	SG1->(DbSetOrder(2))
	If ! SG1->(DbSeek(xFilial("SG1")+aEtiqueta[1]+SC2->C2_PRODUTO))
		cErros+=Alltrim(cOP)+' '
	EndIf
EndIf
If !Empty(cErros)
	VTBeep(2)
	VTAlert(STR0053+chr(13)+chr(10)+cErros ,STR0054,.f.) //"Produto nao pertence a estrutura da(s) OP(s) abaixo"###"Inconsistencia"
	If CBArmProc(aEtiqueta[1],cTm)
		VTClearGet("cEti")
		Return .f.
	EndIf
	If ! VTYesNo(STR0055,STR0025,.t.) //"Produto nao pertence a estrutura da(s) OP(s)"###"Confirma"
		VTKeyBoard(chr(20))
		Return .f.
	EndIf
EndIf
cErros:= ''
nSaldo:= 0
SD4->(DbSetOrder(2))
If lAtuEmp .and. SF5->F5_TIPO # "D" .and. lConfSD4
	For nX := 1 to len(aHistOP)
	
		lQuery		:= .T.
		cAliasSD4	:= "SD4SQL"
		cQuery	:= "SELECT SUM(SD4.D4_QUANT) QTD FROM "
		cQuery	+= RetSqlName("SD4")+" SD4 "
		cQuery	+= "WHERE "
		cQuery	+= "SD4.D4_FILIAL = '"+xFilial("SD4")+"' And "
		cQuery	+= "SD4.D4_OP  = '"+Padr(aHistOP[nX], nTamOPrd )+"' And "
		cQuery	+= "SD4.D4_COD = '"+aEtiqueta[1]+"' And "
		cQuery	+= "SD4.D_E_L_E_T_ = ' ' "
		cQuery	:= ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD4,.T.,.T.)
		aTam := TamSx3("D4_QUANT")
		TCSetField( cAliasSD4, "QTD", "N",aTam[1] , aTam[2] )

		If lQuery
			nSaldo := (cAliasSD4)->QTD
			(cAliasSD4)->(DbCloseArea())
		Else
			SD4->(DbSeek(xFilial("SD4")+Padr(aHistOP[nX], nTamOPrd )+aEtiqueta[1]))
			While SD4->(! EOF() .And. D4_FILIAL+D4_OP+D4_COD == xFilial("SD4")+Padr(aHistOP[nX], nTamOPrd )+aEtiqueta[1])
				nSaldo += SD4->D4_QUANT
				SD4->(dbSkip())
			EndDo
		EndIf

		If (QtdComp(nSaldo)<QtdComp(nQtdEtiq))
			cErros+=Alltrim(aHistOP[nX])+' '
		EndIf
	Next
ElseIf lAtuEmp .and. SF5->F5_TIPO == "D" .and. lConfSD4
	If !SD4->(DbSeek(xFilial("SD4")+Padr( cOP, nTamOPrd )+aEtiqueta[1])) .Or. ( QtdComp(SD4->D4_QTDEORI) < QtdComp(nQtdEtiq) )
		cErros+=Alltrim(cOP)+' '
	EndIf
EndIf
If !Empty(cErros)
	VTBeep(2)
	VTAlert(STR0056+chr(13)+chr(10)+cErros ,STR0054,.f.) //"Produto nao empenhado para a(s) OP(s) abaixo"###"Inconsistencia"
	If ! VTYesNo(STR0056,STR0025,.t.) //"Produto nao pertence a estrutura da(s) OP(s)"###"Confirma"
		VTKeyBoard(chr(20))
		Return .f.
	EndIf
EndIf    
If !CBEndLib(cArmazem,cEndereco)
	VTBEEP(2)
	VTALERT(STR0022,STR0013,.T.,4000) //"Endereco bloqueado"###"AVISO"
	VTKeyBoard(chr(20))
	Return .f.
EndIf
If ! CBProdLib(cArmazem,aEtiqueta[1])
	VTKeyBoard(chr(20))
	Return .f.
EndIf

dValid := dDataBase+SB1->B1_PRVALID
nQE:= 1
If UsaCB0("01")
	If ! CBProdUnit(aEtiqueta[1])
		nQE := CBQtdEmb(aEtiqueta[1])
		If Empty(nQE)
			VTKeyBoard(chr(20))
			Return .f.
		EndIf
		nQtdPar:= nQtdEtiq*nQE
	ElseIf SF5->F5_TIPO # "D" .And. QtdComp(aEtiqueta[2]) > QtdComp(0)
		aSave := VTSAVE()
		VTClear
		If lVT100B
			@ 3,0 VtSay STR0007 VtGet nQtdPar pict CBPictQtde()  valid VldQuant(SF5->F5_TIPO,.f.,cOP)
		else
			@ 3,0 VtSay STR0007  //"Quantidade"
			@ 4,0 VtGet nQtdPar pict CBPictQtde()  valid VldQuant(SF5->F5_TIPO,.f.,cOP)
		endif
		VTREAD
		VtRestore(,,,,aSave)
		If VTLastKey() == 27
			VTKeyBoard(chr(20))
			Return .f.
		EndIf
	EndIf
Else
	//nQtdPar := nQtdPar*nQtdEtiq
	nQtdPar := aEtiqueta[2]*nQtdEtiq
	cLote   := aEtiqueta[3]
	If ! CBRastro(aEtiqueta[1],@cLote,@cSLote,nil)
		VTKeyboard(chr(20))
		Return .f.
	EndIf
	// Verifica se o produto usa  Numero de Serie e Valida o Numero de Serie informado
	If CBChkSer(aEtiqueta[1]) .And. CBNumSer(@cNumseri,NIL,aEtiqueta) 
		aEtiqueta[5] := cNumseri//Numero de Serie
	EndIf	
EndIf
If UsaCb0("01")
	cArmSD4  := If(CBArmProc(aEtiqueta[1],cTM),cArmProc,aEtiqueta[10])
Else
	cArmSD4  := If(CBArmProc(aEtiqueta[1],cTM),cArmProc,cArmazem)
EndIf
nTotQtde := nQtdPar + QtdLida(aEtiqueta[1],cArmazem,cEndereco,cLote,cSLote,cNumSeri)

If (GetMV("MV_ESTNEG") == "N" .Or. Localiza(aEtiqueta[1]) .Or. Rastro(aEtiqueta[1])) .And. SubStr(aEtiqueta[1],1,3) != "MOD" .and. !Empty(nTotQtde)
	If cTM > "500"
		dbSelectArea("SB2")
		dbSeek(xFilial("SB2")+aEtiqueta[1]+cArmazem)

		lBaixaEmp := SF5->F5_ATUEMP == "S"
		If !A240AvalEm(@lBaixaEmp,aEtiqueta[1],cArmazem,nTotQtde,cLote,cSLote,cEndereco,cNumSeri,If(!Empty(aHistOP),aHistOP[Len(aHistOP)],Space(nTamcOp)),Space(TamSX3("D3_TRT")[1]),.T.,.F.,@lBxEmpB8,,"","")
			Return .F.
		EndIf

		If QtdComp(SaldoMov(NIL,!lBaixaEmp,NIL,NIL,If(lBaixaEmp,nTotQtde,NIL),NIL)) < QtdComp(nTotQtde)
			VtAlert(STR0020,STR0013,.T.,3000) // Quantidade excede o saldo disponive
			VTKeyBoard(chr(20))
			Return .F.
		EndIf
		If (!Empty(cEndereco) .Or. !Empty(cNumSeri)) .And. Localiza(aEtiqueta[1]) .And. QtdComp(SaldoSBF(cArmazem,cEndereco,aEtiqueta[1],cNumSeri,cLote,cSLote,lBxEmpB8)) < QtdComp(nTotQtde)
			VtAlert(STR0091,STR0013,.T.,3000) // O   produto  não  tem  saldo  Enderecadosuficiente ou o Endereço selecionado não tem saldo suficiente.
			VTKeyBoard(chr(20))
			Return .F.
		EndIf
	EndIf
EndIf

If UsaCB0("01")
	If ExistBlock("ACDV040VPR")
		lRet := ExecBlock("ACDV040VPR",.F.,.F.,{CB0->CB0_CODPRO,CB0->CB0_OPREQ,aHistOP})
		lRet := If(ValType(lRet)=="L",lRet,.T.)
		If !lRet
			VTKeyBoard(chr(20))
			Return .F.
		EndIf
	EndIf
EndIf

If !lForcaQtd
	nQtdEtiq := 1
	VTGetRefresh("nQtdEtiq")
EndIf
If !Empty(aHistOP)
	nQtdTotOP:=0
	For nX:= 1 to Len(aHistOP)
		nQtdTotOP:= nQtdTotOP+CBTotOP(aHistOP[nX],aEtiqueta[1])
	Next
EndIf

If !Empty(aEtiqueta) .And. CB040TRT(IIf(!Empty(cOp),cOp,cOPCB0),aEtiqueta[1],cArmazem)
	cTrt := Space(TamSX3("D4_TRT")[1])
	@ ++nLinAtual,0 VTSay "TRT: " VTGet cTRT pict '@!' Valid VTLastkey() == 13
	VtRead
EndIf

If UsaCB0("01") //Usa codigo interno
	If SF5->F5_TIPO # "D"	.and. !Empty(aHistOP)
		For nY:= 1 to Len(aHistOP)
			aadd(aHisEti,{CB0->CB0_CODETI,aEtiqueta[1],CBRatReq(aHistOP[nY],aEtiqueta[1],nQtdPar,nQtdTotOP),cLote,cSLote,cArmazem,cEndereco,aHistOP[nY],NIL,NextDoc(),cNumSeri,cTRT,CB0->CB0_NFENT,CB0->CB0_SERIEE,CB0->CB0_FORNEC,CB0->CB0_LOJAFO,CB0->CB0_PEDCOM})
		Next
		If GetMV("MV_MULTOPS") == "1"
			For nW:= 1 to Len(aHisEti)
				If aHisEti[nW,2]==aEtiqueta[1]
					nQuant+= aHisEti[nW,3]
				EndIf
			Next
			nResto:= nQtdPar-nQuant
			If nResto # 0
				For nW:= 1 to Len(aHisEti)
					If aHisEti[nW,2] == aEtiqueta[1]
						aHisEti[nW,3] += nResto
						Exit
					EndIf
				Next
			EndIf
		EndIf
	ElseIf SF5->F5_TIPO # "D"	.and. Empty(aHistOP)
		aadd(aHisEti,{CB0->CB0_CODETI,aEtiqueta[1],nQtdPar,cLote,cSLote,cArmazem,cEndereco,NIL,cCC,NextDoc(),CB0->CB0_NUMSER,cTRT,CB0->CB0_NFENT,CB0->CB0_SERIEE,CB0->CB0_FORNEC,CB0->CB0_LOJAFO,CB0->CB0_PEDCOM})
	ElseIf SF5->F5_TIPO == "D"
		If !Empty(aEtiqueta[19]+aEtiqueta[22])
			aadd(aHisEti,CB0->({CB0_CODETI,CB0_CODPRO,nQtdPar,CB0_LOTE,CB0_SLOTE,If(CB0_LOCAL==cArmProc,CB0_LOCORI,CB0_LOCAL),CB0_LOCALI,CB0_OPREQ,CB0_CC,NextDoc(),CB0->CB0_NUMSER,cTRT,CB0->CB0_NFENT,CB0->CB0_SERIEE,CB0->CB0_FORNEC,CB0->CB0_LOJAFO,CB0->CB0_PEDCOM}))
		Else
			aadd(aHisEti,CB0->({CB0_CODETI,CB0_CODPRO,nQtdPar,CB0_LOTE,CB0_SLOTE,If(CB0_LOCAL==cArmProc,CB0_LOCORI,CB0_LOCAL),CB0_LOCALI,cOP,cCC,NextDoc(),CB0->CB0_NUMSER,cTRT,CB0->CB0_NFENT,CB0->CB0_SERIEE,CB0->CB0_FORNEC,CB0->CB0_LOJAFO,CB0->CB0_PEDCOM}))
		EndIf
	EndIf
Else // Codigo Natural
	If Empty(aHistOP)
		nPos := Ascan(aHisEti,{|x| x[2]+x[4]+x[5]+x[6]+x[7]== aEtiqueta[1]+cLote+cSLote+cArmazem+cEndereco})
		If nPos ==0
			aadd(aHisEti,{aEtiqueta[1],aEtiqueta[1],nQtdPar,cLote,cSLote,cArmazem,cEndereco,,cCC,NextDoc(),aEtiqueta[5],cTRT})
		Else
			aHisEti[nPos,3]+=nQtdPar
		EndIf
	Else
		For nY:= 1 to Len(aHistOP)
			nPos := Ascan(aHisEti,{|x| x[2]+x[4]+x[5]+x[6]+x[7]== aEtiqueta[1]+cLote+cSLote+cArmazem+cEndereco})
			If nPos ==0
				aadd(aHisEti,{aEtiqueta[1],aEtiqueta[1],CBRatReq(aHistOP[nY],aEtiqueta[1],nQtdPar,nQtdTotOP),cLote,cSLote,cArmazem,cEndereco,aHistOP[nY],Nil,NextDoc(),aEtiqueta[5],cTRT,CB0->CB0_NFENT,CB0->CB0_SERIEE,CB0->CB0_FORNEC,CB0->CB0_LOJAFO})
			Else
				aHisEti[nPos,3]+=CBRatReq(aHistOP[nY],aEtiqueta[1],nQtdPar,nQtdTotOP)
			EndIf
		Next
		For nW:= 1 to Len(aHisEti)
			If aHisEti[nW,2]==aEtiqueta[1]
				nQuant:= nQuant+aHisEti[nW,3]
			EndIf
		Next
	EndIf
EndIf

// Se MV_ACDQTD ativo, restaura tela direto no campo de quantidade
If lForcaQtd
	nQtdEtiq := 0
	cEti     := IIf( FindFunction( 'AcdGTamETQ' ), AcdGTamETQ(), Space(48) )
	If ValType(aSave[1][6]) == "C" .And. ValType(aSave[1][4]) == "C"
		aSave[1][6] := cEti
		aSave[1][4] := Transform(nQtdEtiq, CBPictQtde())
	EndIf
	VTGetRefresh("nQtdEtiq")
	VTGetRefresh("cEti")
	VTGetSetFocus("nQtdEtiq")
	Return .f.
EndIf

VTKeyboard(chr(20))
VtRestore(,,,,aSave)
Return .f.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ ValidOP    ³ Autor ³ Desenv.    ACD      ³ Data ³ 28/11/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica integridade da O.P                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ValidOP(cOP)
Local nPos
If Empty(cOP)
	VTKeyBoard(chr(23))
	Return .f.
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se Existe e posiciona o registro             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SC2->(DbSetOrder(1))
If ! SC2->(DbSeek(xFilial("SC2")+cOP))
	VTBeep(2)
	VTAlert(STR0042,STR0013,.T.,3000)  //"OP nao cadastrada"###"Aviso"
	VTKeyBoard(chr(20))
	Return .F.
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se OP ja foi encerrada                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(SC2->C2_DATRF)
	VTBeep(2)
	VTAlert(STR0043,STR0013,.T.,3000)  //"OP ja Encerrada"###"Aviso"
	VTKeyBoard(chr(20))
	Return .F.
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se OP e do tipo Firme                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SC2->C2_TPOP # "F"
	VTBeep(2)
	VTAlert(STR0044,STR0013,.T.,3000)  //"Nao e permitida movimentacao com OPs Previstas"###"Aviso"
	VTKeyBoard(chr(20))
	Return .F.
EndIf
nPos:= Ascan(aHistOP,{|x| x == cOP})
If nPos == 0
	aadd(aHistOP,cOP)
Else
	VTBeep(2)
	VTAlert(STR0045,STR0013 ,.t.,4000) //"OP ja informada"###"Aviso"
	VtClearGet(STR0046) //"cOP"
	Return .f.
EndIf
If GetMV("MV_MULTOPS") # "1"
	Return .t.
EndIf
VtClearGet("cOP")
If VtLastKey() == 27
	Return .f.
EndIf
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ VldQuant   ³ Autor ³ Desenv.    ACD      ³ Data ³ 28/11/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao da quantidade informada                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³Parametros³ nQtdInf -> Quantidade digitada                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function VldQuant(cTipoTm,lCC,cOP)
LocaL   lRet  := .f.

If Empty(nQtdPar)
	Return(lRet)
EndIf
If nQtdPar > aEtiqueta[2] .And. cTipoTm # "D"
	VTBeep(2)
	VTALERT(STR0058,STR0013,.T.,4000) //"Quantidade maior do que a quantidade da etiqueta"###"Aviso"
	nQtdpar:= 0
	Return(lRet)
EndIf

If !(CBQtdVar(aEtiqueta[1])) .And. !(nQtdPar = aEtiqueta[2])
	VTBeep(2)
	VTALERT(STR0092,STR0013,.T.,4000) //""Quantidade menor do que a quantidade da etiqueta""###"Aviso"
	nQtdpar:= aEtiqueta[2]
	Return(lRet)
EndIf

If ExistBlock("ACD040QE")
	lRet := ExecBlock("ACD040QE") // Validacao da quantidade requisitada
	lRet := If(ValType(lRet)=="L",lRet,.t.)
Else                             // Retorna .t. / .f.
	lRet:= .t.
EndIf
If cTipoTm # "D" .or. lCC
	Return(lRet)
EndIf
If CBArmProc(aEtiqueta[1],cTm)
	If ! VldOPDev(aEtiqueta[1],nQtdPar,cOP)
		lRet:= .f.
	EndIf
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ ValidCC    ³ Autor ³ Desenv.    ACD      ³ Data ³ 28/11/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica integridade do Centro de custo                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ValidCC(cCC)
If Empty(cCC)
	VTKeyBoard(chr(23))
	Return .f.
EndIf
If !VTExistCPO("CTT",cCC,,STR0047,.T.) //"Centro de custo nao cadastrado"
	VtClearGet("cCC")
	Return .f.
EndIf
If VtLastKey() == 27
	Return .f.
EndIf
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ VldEnd     ³ Autor ³ Desenv.    ACD      ³ Data ³ 17/06/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica integridade do endereco                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function VldEnd(lQtd)
Local aEndereco := {}
Default lQtd    := .F.

If lQtd
	VTGetSetFocus("nQtdEtiq")
	Return .f.
EndIf

If Empty(cEndereco+cEtiEnd)
	VTBeep(2)
	VTALERT(STR0018,STR0013,.T.,4000) //"Etiqueta invalida."###"AVISO"
	VTClearGet()
	VTClearGet("cArmazem")
	VTGetSetFocus("cArmazem")
	Return .f.
EndIf

If UsaCB0("02")
	aEndereco := CBRetEti(cEtiEnd,"02")
	If Empty(aEndereco)
		VTBEEP(2)
		VTALERT(STR0018,STR0013,.T.,4000) //"Etiqueta invalida."###"AVISO"
		VTKeyBoard(chr(20))
		Return .f.
	EndIf
	cArmazem  := aEndereco[2]
	cEndereco := Padr(aEndereco[1],TamSX3("BF_LOCALIZ")[1])
	@ nPosEnd,0 VtSay cArmazem+'-'+cEndereco
EndIf
SBE->(DbSetOrder(1))
If ! SBE->(DbSeek(xFilial("SBE")+cArmazem+cEndereco))
	VTBEEP(2)
	VTALERT(STR0021,STR0013,.T.,4000) //"Endereco nao encontrado"###"AVISO"
	VTClearGet()
	VTClearGet("cArmazem")
	VTGetSetFocus("cArmazem")
	Return .f.
EndIf

If !CBEndLib(cArmazem,cEndereco)
	VTBEEP(2)
	VTALERT(STR0022,STR0013,.T.,4000) //"Endereco bloqueado"###"AVISO"
	VTClearGet()
	VTClearGet("cArmazem")
	VTGetSetFocus("cArmazem")
	Return .f.
EndIf

If lForcaQtd
	VTGetSetFocus("nQtdEtiq")
	Return .f.
EndIf

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Grava      ³ Autor ³ Desenv.    ACD      ³ Data ³ 17/07/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gera requisicao de materiais                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Sigaacd                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Grava(cOP)
Local aMata   :={}
Local aMataPE :={}
Local cRecSF5 :=SF5->(Recno())

aadd(aMata,{"D3_TM"     ,cTM          ,nil})
aadd(aMata,{"D3_COD"    ,aEtiqueta[1] ,nil})
aadd(aMata,{"D3_QUANT"  ,nQtdPar      ,nil})
aadd(aMata,{"D3_LOCAL"  ,cArmazem 		,nil})
aadd(aMata,{"D3_DOC"    ,cDoc    		,nil})
aadd(aMata,{"D3_LOCALIZ",cEndereco		,nil})
If SF5->F5_TIPO # "D"
	If !Empty(aHistOP)
		If ! CBArmProc(aEtiqueta[1],cTM)
			aadd(aMata,{"D3_OP"	,cOP			,nil})
		EndIf
	Else
		aadd(aMata,{"D3_CC"	,cCC				,nil})
	EndIf
Else
	If !Empty(cOP)
		If ! CBArmProc(aEtiqueta[1],cTM)
			aadd(aMata,{"D3_OP"	,cOP			,nil})
		EndIf
	Else
		aadd(aMata,{"D3_CC"	,cCC			,nil})
	EndIf
EndIf
aadd(aMata,{"D3_EMISSAO",dDataBase		,nil})
Private nModulo := 4
lMSErroAuto := .F.
If Rastro(aEtiqueta[1])
	aadd(aMata,{"D3_LOTECTL",cLote         ,nil})
	aadd(aMata,{"D3_NUMLOTE",cSLote        ,nil})
	aadd(aMata,{"D3_DTVALID",dValid        ,nil})
EndIf
If ! Empty(cNumSeri)
	SB1->(DbSetOrder(1))
	SB1->(DbSeek(xFilial("SB1")+aEtiqueta[1]))
	//Dependendo da Versao do Protheus o campo B1_QTDSER é C ou N
	If(ValType(SB1->B1_QTDSER)) == "C"
	 	SB1->B1_QTDSER # "1"
	 	aadd(aMata,{"D3_QTSEGUM",1, nil})
	 Elseif (ValType(SB1->B1_QTDSER)) == "N"
	 	SB1->B1_QTDSER # 1
	 	aadd(aMata,{"D3_QTSEGUM",1, nil})
	EndIf
	aadd(aMata,{"D3_NUMSERI",cNumseri,nil})
EndIf
If !Empty(cTRT)
	aadd(aMata,{"D3_TRT",cTRT,nil})
EndIf

If ExistBlock('AI040GRD')
	aMataPE := Execblock('AI040GRD',.F.,.F.,aMata)
	aMata   := If(ValType(aMataPE)=="A",aMataPE,aMata)
EndIf
lMSHelpAuto := .T.
MSEXECAUTO({|x|MATA240(x)},aMata)
lMSHelpAuto := .F.
If lMSErroAuto
	VTBeep(2)
	VTAlert(STR0023,STR0013,.t.,4000) //"Falha na gravacao da movimentacao, tente novamente."###"Aviso"
	Return .f.
EndIf

DbSelectArea("SF5")
DbGoTo(cRecSF5)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de entrada depois que foi feita a gravacao           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If CBArmProc(aEtiqueta[1],cTM)
	SD4->(DbSetOrder(2))
	If SD4->(DbSeek(xFilial("SD4")+Padr(cOP,Len(D4_OP))+aEtiqueta[1]+cArmProc))
		Reclock("SD4",.f.)
		If SF5->F5_TIPO # "D"
			SD4->D4_EMPROC:= SD4->D4_EMPROC+nQtdPar
			SD4->D4_CBTM  := cTM
		Else
			SD4->D4_EMPROC:= SD4->D4_EMPROC-nQtdPar
			SD4->D4_CBTM  := cTM
		EndIf
		SD4->(MsUnlock())
	EndIf
EndIf
If ExistBlock('AI130DGR')
	Execblock('AI130DGR',.F.,.F.)
EndIf
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Imprime    ³ Autor ³ Desenv.    ACD      ³ Data ³ 19/11/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Imprime etiquetas dos Produtos requisitados                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Imprime(nX)
Local cOrigem:= "SD3"
Local i

If lPENSerDv
	lNumSerDev := ExecBlock("SD3NSDV",.f.,.f.)
	lNumSerDev := If(ValType(lNumSerDev)=="L",lNumSerDev,.F.)
EndIf
If GetMV("MV_IMETREQ") == "1"
	If ! CB5SetImp(CBRLocImp("MV_IACD04"),IsTelNet())
		VTBeep(3)
		VTAlert(STR0059,STR0060,.t.,3000) //'Local de impressao nao configurado, MV_IACD04'###'Aviso'
		Return .f.
	EndIf
	VTMsg(STR0084) //"Imprimindo..."
EndIf
If ! CBImpEti(aHisEti[nX,2])
	Return .f.
EndIf
SB1->(DbSetOrder(1))
SB1->(DbSeek(xFilial("SB1")+aHisEti[nX,2]))
If CBProdUnit(aHisEti[nX,2])
	If CBQtdVar(aHisEti[nX,2])
		nEtiq  := 1
		nQuant := aHisEti[nX,3]
	Else
		If ! Empty(aHisEti[nX,11])
			If SB1->B1_QTDSER # 1
				nQuant := aHisEti[nX,3]
				nEtiq  := 1
			Else
				nQuant := CBQEmbI()
				nEtiq  := aHisEti[nX,3]/nQuant
			EndIf
		Else
			nQuant := CBQEmbI()
			nEtiq  := aHisEti[nX,3]/nQuant
		EndIf
	EndIf
Else
	nEtiq  := 1
	nQuant := aHisEti[nX,3]
EndIf
If GetMV("MV_IMETREQ") == "1"  //Imprime etiquetas...
	If ExistBlock('IMG01')
		If SF5->F5_TIPO=="R"
			ExecBlock('IMG01',,,({nQuant,NIL,NIL,nEtiq,aHisEti[nX,12],aHisEti[nX,13],aHisEti[nX,14],aHisEti[nX,15],If(CBArmProc(aHisEti[nX,2],cTM),cArmProc,aHisEti[nX,6]),NIL,SD3->D3_NUMSEQ,aHisEti[nX,4],aHisEti[nX,5],NIL,aHisEti[nX,9],aHisEti[nX,6],aHisEti[nX,8],cNumSeri,cOrigem,If(CBArmProc(aHisEti[nX,2],cTM)," ",aHisEti[nX,7]),aHisEti[nX,16]}))
		Else
			ExecBlock('IMG01',,,({nQuant,NIL,NIL,nEtiq,aHisEti[nX,12],aHisEti[nX,13],aHisEti[nX,14],aHisEti[nX,15],aHisEti[nX,6],NIL,SD3->D3_NUMSEQ,aHisEti[nX,4],aHisEti[nX,5],NIL,aHisEti[nX,9],NIL,NIL,If(lNumSerDev,cNumSeri," "),cOrigem,If(lNumSerDev .AND. !Empty(cNumSeri),aHisEti[nX,7]," "),aHisEti[nX,16]}))
		EndIf
	EndIf
	Return .t.
Else		//Somente cria etiquetas no CB0...
	For i:=1 to nEtiq
		If SF5->F5_TIPO=="R"
			CBGrvEti('01',{aHisEti[nX,2],nQuant,NIL,aHisEti[nX,12],aHisEti[nX,13],aHisEti[nX,14],aHisEti[nX,15],aHisEti[nX,16],If(CBArmProc(aHisEti[nX,2],cTM)," ",aHisEti[nX,7]),If(CBArmProc(aHisEti[nX,2],cTM),cArmProc,aHisEti[nX,6]),NIL,SD3->D3_NUMSEQ,NIL,NIL,NIL,aHisEti[nX,4],aHisEti[nX,5],NIL,aHisEti[nX,9],aHisEti[nX,6],NIL,aHisEti[nX,8],cNumSeri,cOrigem})
		Else
			CBGrvEti('01',{aHisEti[nX,2],nQuant,NIL,aHisEti[nX,12],aHisEti[nX,13],aHisEti[nX,14],aHisEti[nX,15],aHisEti[nX,16],If(lNumSerDev .AND. !Empty(cNumSeri),aHisEti[nX,7]," "),aHisEti[nX,6],NIL,SD3->D3_NUMSEQ,NIL,NIL,NIL,aHisEti[nX,4],aHisEti[nX,5],NIL,aHisEti[nX,9],NIL,NIL,NIL,If(lNumSerDev,cNumSeri," "),cOrigem})
		EndIf
	Next
EndIf
Return .f.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ GravaCB0   ³ Autor ³ Desenv.    ACD      ³ Data ³ 16/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza CB0                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Sigaacd                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GravaCB0(cOP)
Local nQtdOri := aEtiqueta[2]

If lPENSerDv
	lNumSerDev := ExecBlock("SD3NSDV",.f.,.f.)
	lNumSerDev := If(ValType(lNumSerDev)=="L",lNumSerDev,.F.)
EndIf
If CBProdUnit(aEtiqueta[1]).OR. CBQTDVAR(aEtiqueta[1])
	If nQtdPar < aEtiqueta[2]
		If SF5->F5_TIPO=="R"
			aEtiqueta[2] -= nQtdPar
		EndIf
		aEtiqueta[12]:= SD3->D3_NUMSEQ
	Else
		If SF5->F5_TIPO=="R"
			aEtiqueta[9] := cEndereco
			aEtiqueta[20]:= If(CBArmProc(aEtiqueta[1],cTM),aEtiqueta[10]," ")
			aEtiqueta[10]:= If(CBArmProc(aEtiqueta[1],cTM),cArmProc,cArmazem)
			aEtiqueta[19]:= cCC
			aEtiqueta[22]:= If(nQtdPar == nQtdOri,cOP," ")
		Else
			aEtiqueta[9] := If(lNumSerDev .AND. !Empty(aEtiqueta[23]),aEtiqueta[9]," ")
			aEtiqueta[10]:= If(CBArmProc(aEtiqueta[1],cTM),aEtiqueta[20],aEtiqueta[10])
			aEtiqueta[20]:= " "
			aEtiqueta[19]:= " "
			aEtiqueta[22]:= If(nQtdPar == nQtdOri," ",cOP)
			aEtiqueta[23]:= If(lNumSerDev,aEtiqueta[23]," ")
		EndIf
		aEtiqueta[12]:= SD3->D3_NUMSEQ
		aEtiqueta[24]:= If(nQtdPar == nQtdOri,"SD3"," ")
	EndIf
	CBGrvEti("01",aEtiqueta,cEti)
	If nQtdOri == nQtdPar
		RecLock("CB0",.f.)
		CB0->CB0_STATUS:= If(SF5->F5_TIPO=="R","1"," ")
		CB0->(MsUnLock())
	EndIf
EndIf
If ExistBlock('ACD040CB0')
	Execblock('ACD040CB0',.F.,.F.,{nQtdOri})
EndIf
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Estorna    ³ Autor ³ Anderson Rodrigues  ³ Data ³ 25/11/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza o estorno da(s) OP(s) informada(s) ou do(s)        ³±±
±±³          ³ produto(s) informado(s)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Estorna()
Local aTela
Local cOP := Space(Tamsx3("CBH_OP")[1])
Local cEtiProd
aTela := VTSave()
VTClear()

If Upper(Alltrim(VtReadVar())) == 'CCC'
	VTBeep(2)
	VTAlert(STR0061 ,STR0013,.t.,4000) //"Opcao de estorno nao disponivel"###"Aviso"
	VTKeyBoard(chr(20))
	VTRestore(,,,,aTela)
	Return .f.
EndIf

If Upper(Alltrim(VtReadVar())) == 'COP'
	@ 00,00 VtSay STR0062 //"Estorno da O.P"
	@ 02,00 VtGet cOP pict "@!" Valid VldEstorno(cOP) F3 "CB6"
Else
	cEtiProd := Space(20)
	@ 00,00 VtSay STR0063 //"Estorno do Produto"
	@ 02,00 VtGet cEtiProd pict "@!" Valid VldEstorno(cEtiProd)
EndIf
VtRead
VtRestore(,,,,aTela)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ ACD040Hist ³ Autor ³ Anderson Rodrigues  ³ Data ³ 25/11/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Mostra as OP's e/ou produto(s) lid(a)s (o)(s)              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ACD040Hist()
Local aSave := VTSAVE()
Local aCab  := {}
Local aProds:= {}
Local cEtiq,cProd
Local nPos,nQtde,nX

VtClear()
@ 0,0  VTSay STR0064 //"Selecione a"
@ 1,0  VTSay STR0065 //"consulta :"
nPos:= VTAchoice(3,0,7,VtmaxCol(),{STR0051,STR0006}) //"O.P"###"Produto"
VtClearBuffer()
If nPos ==0
	Return
EndIf
If nPos == 1
	If Empty(aHistOP)
		VTBeep(2)
		VTALERT(STR0066,STR0013,.T.,3000) //"Nao existe O.P(s) informada(s)"###"AVISO"
		VtRestore(,,,,aSave)
		Return .f.
	EndIf
	VtClear()
	@ 0,0 VTSay STR0067 //"OP(s) Lida(s):"
	VTaChoice(1,0,7,19,aHistOP)
	If VtLastKey() == 27
		VtRestore(,,,,aSave)
	EndIf
ElseIf nPos == 2
	If Empty(aHisEti)
		VTBeep(2)
		VTALERT(STR0068,STR0013,.T.,3000) //"Nao existe Produto(s) informado(s)"###"AVISO"
		VtRestore(,,,,aSave)
		Return .f.
	EndIf
	cEtiq:= aHisEti[1,1]
	cProd:= aHisEti[1,2]
	nQtde:= 0
	For nX:= 1 to Len(aHisEti)
		If aHisEti[nX,1] == cEtiq .and. aHisEti[nX,2]== cProd
			nQtde+= aHisEti[nX,3]
		Else
			aadd(aProds,{cEtiq,cProd,Str(nQtde,8,2)})
			cEtiq:= aHisEti[nX,1]
			cProd:= aHisEti[nX,2]
			nQtde:= aHisEti[nX,3]
		EndIf
	Next
	aadd(aProds,{cEtiq,cProd,Str(nQtde,8,2)})
	VTClear()
	@ 0,0 VTSay STR0069 //"Produto(s) Lido(s):"
	aCab  := {STR0070,STR0006,STR0007} //"Etiqueta"###"Produto"###"Quantidade"
	aSize := {10,15,10}
	VTaBrowse(2,0,7,19,aCab,aProds,aSize)
	If VtLastKey() == 27
		VtRestore(,,,,aSave)
	EndIf
EndIf
VtRestore(,,,,aSave)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ ACD040Imp  ³ Autor ³ Anderson Rodrigues  ³ Data ³ 30/11/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chamada Programa de Impressao de Etiquetas de Produto      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ACD040Imp()
Local aTela  := {}

If SF5->F5_TIPO#"D"
	Return
EndIf

aTela:= VtSave()
VTClear()
ACDI10PR()
VtRestore(,,,,aTela)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ VldEstorno ³ Autor ³ Anderson Rodrigues  ³ Data ³ 25/11/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida o estorno da Leitura das OP's ou dos produtos       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function VldEstorno(cConteudo)
Local nPos
If Empty(cConteudo)
	Return .f.
EndIf
If Upper(Alltrim(VtReadVar())) == 'COP'
	nPos := Ascan(aHistOP, {|x| AllTrim(x) == AllTrim(cConteudo)})
	If nPos == 0
		VTBeep(2)
		VTALERT(STR0071,STR0013,.T.,3000) //"O.P nao encontrada"###"AVISO"
		VtKeyboard(Chr(20))
		Return .f.
	EndIf
	If ! VTYesNo(STR0072,STR0009,.t.) //"Confirma o estorno da OP ?"###"ATENCAO"
		VtKeyboard(Chr(20))
		Return .f.
	EndIf
	aDel(aHistOP,nPos)
	aSize(aHistOP,Len(aHistOP)-1)
	VtKeyboard(Chr(20))
Else
	nPos:= Ascan(aHisEti, {|x| AllTrim(x[1]) == AllTrim(cConteudo)})
	If nPos == 0
		VTBeep(2)
		VTALERT(STR0073,STR0013,.T.,3000) //"Produto nao encontrado"###"AVISO"
		VtKeyboard(Chr(20))
		Return .f.
	EndIf
	If ! VTYesNo(STR0074,STR0009,.t.) //"Confirma o estorno do Produto ?"###"ATENCAO"
		VtKeyboard(Chr(20))
		Return .f.
	EndIf
	While .t.
		nPos:= Ascan(aHisEti,{|x| AllTrim(x[1]) == AllTrim(cConteudo)})
		If nPos == 0
			Exit
		EndIf
		aDel(aHisEti,nPos)
		aSize(aHisEti,Len(aHisEti)-1)
		VtKeyboard(Chr(20))
	Enddo
EndIf
Return .f.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ NextDoc    ³ Autor ³ Anderson Rodrigues  ³ Data ³ 06/12/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna o Numero do Proximo documento para a tabela SD3    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static function NextDoc()
Local aSvAlias   := GetArea()
Local aSvAliasD3 := SD3->(GetArea())
Local cDoc:= Space(Len(SD3->D3_DOC))

If ExistBlock('ACD040DOC')
	cDoc := Execblock('ACD040DOC',.F.,.F.)
	cDoc := If(ValType(cDoc)=="C",cDoc,Space(Len(SD3->D3_DOC)))
EndIf
If !Empty(cDoc)
	RestArea(aSvAliasD3)
	RestArea(aSvAlias)
	Return cDoc
EndIf
SD3->(DbSetOrder(2))
While .t.
	cDoc :=  NextNumero("SD3",2,"D3_DOC",.T.)
	cDoc :=  A261RetINV(cDoc)
	If ! dbSeek(xFilial("SD3")+cDoc)
		While ascan(aHisEti,{|x| x[10] ==cDoc}) > 0
			cDoc := Soma1(cDoc,Len(SD3->D3_DOC))
		Enddo
		Exit
	EndIf
Enddo
RestArea(aSvAliasD3)
RestArea(aSvAlias)
Return cDoc

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³DistriProc  ³ Autor ³ Desenv. ACD         ³ Data ³ 17/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava a distribuicao para o Armazem de processos           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DistriProc(cCodPro,cNumSeq,nQtde,cLote,cSLote,cNumSeri)
Local cItem    := ""
Local cArmazem := cArmProc
Local cEndProc := GetMV("MV_ENDPROC")
Local aCab     := {}
Local aItens   := {}
Local aSave    := VTSAVE()
Private lMSErroAuto := .F.

SBE->(DbSetOrder(1))
If ! SBE->(DbSeek(xFilial("SBE")+cArmazem+cEndProc))
	VTBEEP(2)
	VTALERT(STR0075,STR0009,.T.,4000) //"O endereco informado no parametro MV_ENDPROC nao existe no armazem de processos"###"Atencao"
	VTALERT(STR0076,STR0009,.T.,4000) //"Processo abortado !!!"###"Atencao"
	Return .f.
EndIf

VTMSG(STR0010) //"Aguarde..."
cItem := Item(cCodPro,cArmazem,cNumSeq)
aCAB  := {{"DA_PRODUTO",cCodPro , nil},;
{"DA_LOCAL"  ,cArmazem, nil},;
{"DA_NUMSEQ" ,cNumSeq , nil},;
{"DA_DOC"    ,cDoc    , nil}}

aITENS := {{{"DB_ITEM"   ,cItem    , nil},;
{"DB_LOCALIZ",cEndProc  , nil},;
{"DB_QUANT"  ,nQtde     , nil},;
{"DB_DATA"   ,dDATABASE , nil},;
{"DB_LOTECTL",cLote     ,nil},;
{"DB_NUMLOTE",cSLote    ,nil}}}
If ! Empty(cNumSeri)
	SB1->(DbSetOrder(1))
	SB1->(DbSeek(xFilial("SB1")+cCodPro))
	If SB1->B1_QTDSER # 1
		aadd(aItens[1],{"DB_QTSEGUM",1, nil})
	EndIf
	aadd(aItens[1],{"DB_NUMSERI",cNumSeri,nil})
EndIf
nModuloOld  := nModulo
nModulo     := 4
lMSHelpAuto := .T.
lMSErroAuto := .F.
SX3->(DbSetOrder(1))
msExecAuto({|x,y|mata265(x,y)},aCab,aItens)
nModulo := nModuloOld
lMSHelpAuto := .F.
If lMSErroAuto
	VTBEEP(2)
	VTALERT(STR0077,STR0078,.T.,3000) //"Falha no processo de distribuicao."###"ERRO"
	VTDispFile(NomeAutoLog(),.t.)
	Return .f.
EndIf
VTCLEAR
VtRestore(,,,,aSave)
If ExistBlock('ACD040DPR')
	Execblock('ACD040DPR',.F.,.F.)
EndIf
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Item       ³ Autor ³ Desenv.    ACD      ³ Data ³ 24/12/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna a numeracao do proximo item da tabela SDB          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Item(cProduto,cLocal,cNumSeq)
Local cItem     := ""
SDB->(dbSetOrder(1))
If SDB->(dbSeek(xFilial("SDB")+cProduto+cLocal+cNumSeq))
	While SDB->(!EOF() .and. xFilial("SDB")+cProduto+cLocal+cNumSeq ==;
		DB_FILIAL+DB_PRODUTO+DB_LOCAL+DB_NUMSEQ)
		cItem := SDB->DB_ITEM
		SDB->(dbSkip())
	Enddo
	cItem := Strzero(val(cItem)+1,Len(SDB->DB_ITEM))
Else
	cItem := Strzero(1,Len(SDB->DB_ITEM))
EndIf
Return cItem

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ VldOPDev   ³ Autor ³ Anderson Rodrigues  ³ Data ³ 20/02/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida a devolucao por OP para produtos c/ aprop. indireta ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function VldOPDev(cProduto,nQuant,cOP)

SC2->(DbSetOrder(1))
If ! SC2->(DbSeek(xFilial("SC2")+cOP))
	VTBeep(2)
	VTAlert(STR0042,STR0013,.T.,3000) //"OP nao cadastrada"###"Aviso"
	VTKeyBoard(chr(20))
	Return .F.
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se OP ja foi encerrada                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(SC2->C2_DATRF)
	VTBeep(2)
	VTAlert(STR0079,STR0013,.T.,3000) //"Nao e permitido a devolucao para uma OP ja encerrada"###"Aviso"
	VTKeyBoard(chr(20))
	Return .f.
EndIf
If SC2->C2_TPOP # "F"
	VTBeep(2)
	VTAlert(STR0044,STR0013,.T.,3000)  //"Nao e permitida movimentacao com OPs Previstas"###"Aviso"
	VTKeyBoard(chr(20))
	Return .F.
EndIf
SD4->(DbSetOrder(1))
If ! SD4->(DbSeek(xFilial("SD4")+cProduto+cOP))
	VTBeep(2)
	VTAlert(STR0080+cOP,STR0013,.T.,3000) //"Nao foi encontrado empenho para este produto na OP "###"Aviso"
	VTKeyBoard(chr(20))
	Return .f.
EndIf
If GetMv("MV_VLDEVAI")=="1"
	Return .t.
ElseIf GetMv("MV_VLDEVAI")=="2"
	If nQuant > SD4->D4_EMPROC
		VTBeep(2)
		VTAlert(STR0081,STR0013,.T.) //"Nao e permitida a devolucao por OP onde a quantidade e maior do que a requisitada"###"Aviso"
		Return .f.
	EndIf
ElseIf GetMv("MV_VLDEVAI")=="3"
	If nQuant > SD4->D4_EMPROC
		VTAlert(STR0082,STR0013,.T.) //"A quantidade da devolucao e maior do que o saldo requisitado deste produto para esta OP"###"Aviso"
		If VTYesNo(STR0083,STR0013,.T.) //"Ao devolver esta quantidade o saldo da OP podera ficar negativo"###"Aviso"
			Return .t.
		Else
			Return .f.
		EndIf
	EndIf
EndIf
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ QtdLida    ³ Autor ³ Henrique Gomes Oikawa ³ Data ³ 16/03/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna a quantidade lida do produto ateh o momento          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaACD                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function QtdLida(cProduto,cArmazem,cEndereco,cLote,cSLote,cNumSeri)
Local  nQtde := 0
aEval(aHisEti,{|x| If(x[2]+x[6]+x[7]+x[4]+x[5]+x[11]==cProduto+cArmazem+cEndereco+cLote+cSLote+cNumSeri,nQtde+=x[3],nil)})
Return nQtde

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CB040TRT  ³ Autor ³ Isaias Florencio      ³ Data ³27/11/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao utilizada para retornar se o produto possui         ³±±
±±³          ³ controle de sequencia na estrutura da OP (Campo TRT)       ³±±
±±³          ³ Se possuir TRT, retorna .T.                                ³±±
±±³          ³ Se nao possuir TRT, retorna .F.                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ACDV040                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CB040TRT(cOrdProd,cCodProd,cLocal)
Local lRet := .F.
Local aAreaAnt := GetArea()
Local aAreaSD4 := SD4->(GetArea())
Local cAliasTmp	:= CriaTrab(Nil,.F.)
Local cQuery     	:= ''
cQuery := "SELECT SD4.D4_TRT FROM "+ RetSqlName("SD4")+" SD4 WHERE "
cQuery += "SD4.D4_FILIAL	= '" + xFilial('SD4') + "' AND "
cQuery += "SD4.D4_OP		= '" + cOrdProd + "' AND SD4.D4_COD =  '"+ cCodProd +"' AND "
cQuery += "SD4.D4_LOCAL	= '" + cLocal   + "' AND SD4.D4_TRT <> '"+ Space(TamSX3("D4_TRT")[1]) +"' AND "
cQuery += "SD4.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)

If (cAliasTmp)->(!Eof())
	lRet := .T.
EndIf

(cAliasTmp)->(DbCloseArea())

RestArea(aAreaSD4)
RestArea(aAreaAnt)
Return lRet
