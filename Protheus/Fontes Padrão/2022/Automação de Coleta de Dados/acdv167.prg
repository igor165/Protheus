#INCLUDE "ACDV167.CH" 
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APVT100.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ ACDV167  ³ Autor ³ ACD                   ³ Data ³ 01/03/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Embalagem                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/  

Function ACDV167()
Local aTela
Local nOpc
If ACDGet170()
	Return ACDV167X(0)
EndIf
IF !Type("lVT100B") == "L"
	Private lVT100B := .F.
EndIf
aTela := VtSave()
VTCLear()
If lVT100B // GetMv("MV_RF4X20")
	@ 0,0 VTSAY STR0006 //"Embalagem Selecione"
	nOpc:=VTaChoice(2,0,3,VTMaxCol(),{STR0003,STR0004,STR0005}) //"Ordem de Separacao"###"Pedido de Venda"###"Nota Fiscal"
ElseIf Vtmodelo()=="RF" .or. lVT100B // GetMv("MV_RF4X20")
	@ 0,0 VTSAY STR0001 //"Embalagem"
	@ 1,0 VTSay STR0002 //"Selecione:"
	nOpc:=VTaChoice(3,0,6,VTMaxCol(),{STR0003,STR0004,STR0005}) //"Ordem de Separacao"###"Pedido de Venda"###"Nota Fiscal"
ElseIf VtModelo()=="MT44"
	@ 0,0 VTSAY STR0001 //"Embalagem"
	@ 1,0 VTSay STR0002 //"Selecione:"
	nOpc:=VTaChoice(0,20,1,39,{STR0003,STR0004,STR0005}) //"Ordem de Separacao"###"Pedido de Venda"###"Nota Fiscal"
ElseIf VtModelo()=="MT16"
	@ 0,0 VTSAY STR0006 //"Embalagem Selecione"
	nOpc:=VTaChoice(1,0,1,19,{STR0003,STR0004,STR0005}) //"Ordem de Separacao"###"Pedido de Venda"###"Nota Fiscal"
EndIf

VtRestore(,,,,aTela)
If nOpc == 1 //-- por ordem de separacao
	ACDV167A()
ElseIf nOpc == 2 //-- por pedido de venda
	ACDV167B()
ElseIf nOpc == 3 //-- por Nota Fiscal
	ACDV167C()
EndIf
Return 1

Function ACDV167A()
ACDV167X(1)
Return
Function ACDV167B()
ACDV167X(2)
Return
Function ACDV167C()
ACDV167X(3)
Return

Static Function ACDV167X(nOpc)
Local ckey09  := VTDescKey(09)
Local ckey22  := VTDescKey(22)
Local ckey24  := VTDescKey(24)
Local bkey09  := VTSetKey(09)
Local bkey22  := VTSetKey(22)
Local bkey24  := VTSetKey(24)
Local nTamVol := TamSX3("CB9_VOLUME")[1]
Local lV167Embala	:= ExistBlock("V167EMBALA")
Private cCodOpe    := CBRetOpe()
Private cImp       := CBRLocImp("MV_IACD01")
Private cPictQtdExp:= PesqPict("CB8","CB8_QTDORI")
Private cVolume    := Space(nTamVol)
Private lForcaQtd  := GetMV("MV_CBFCQTD",,"2") =="1"

VTClearBuffer()

If Type('cOrdSep')=='U'
	Private cOrdSep := Space(TamSX3("CB8_ORDSEP")[1])
EndIf

If Empty(cCodOpe)
	VTAlert(STR0007,STR0008,.T.,4000,3) //"Operador nao cadastrado"###"Aviso"
	Return 10 //-- valor necessario para finalizar o acv170
EndIf

CB5->(DbSetOrder(1))
If !CB5->(DbSeek(xFilial("CB5")+cImp))  //-- cadastro de locais de impressao
	VtBeep(3)
	VtAlert(STR0009,STR0008,.t.) //"O conteudo informado no parametro MV_IACD01 deve existir na tabela CB5."###"Aviso"
	Return 10 //-- valor necessario para finalizar o acv170
EndIf

//-- Verifica se foi chamado pelo programa ACDV170 e se ja foi Embalado
If ACDGet170() .AND. CB7->CB7_STATUS >= "4"
	If !A170SLProc() .OR. !("02" $ CB7->CB7_TIPEXP)
		//-- Nao eh necessario  liberar o semaforo pois ainda nao criou nada
		Return 1
	EndIf
	//-- Ativa/Destativa a tecla avanca e retrocesa
	A170ATVKeys(.t.,.f.)	 //-- Ativa tecla avanca e desativa tecla retrocede
ElseIf ACDGet170() .AND. !("02" $ CB7->CB7_TIPEXP)
	Return 1
ElseIf ACDGet170()
	//-- Desativa a  tecla  avanca
	A170ATVKeys(.f.,.t.)
EndIf

VTClear()
	If	VtModelo()=="RF" .or. lVT100B // GetMv("MV_RF4X20")
	@ 0,0 VtSay STR0001 //"Embalagem"
EndIf
If ! CBSolCB7(nOpc,{|| VldCodSep()})
	Return 10
EndIf
//-- Ver se o codigo de separacao devera vir do programa anterior.
If Empty(cOrdSep)
	cOrdSep := CB7->CB7_ORDSEP
EndIf

If	(ACDGet170() .And. CB7->CB7_STATUS >= "4") .Or. CB7->CB7_STATUS == "4" .Or. ;
	("02" $ CBUltExp(CB7->CB7_TIPEXP) .And. CB7->CB7_STATUS == "9")
	VTAlert(STR0010,STR0008,.t.,4000) //"Processo de embalagem finalizado"###"Aviso"
	If	VTYesNo(STR0012,STR0013,.T.) //"Deseja estornar os produtos embalados ?"###"Atencao"
		VTSetKey(09,{|| Informa()},STR0014) //"Informacoes"
		Estorna()
		VTSetKey(09,bkey09,cKey09)
	EndIf
	Return FimProcEmb()
EndIf


InicProcEmb()
//-- Informa os volumes
While ! Volume()
	Return FimProcEmb()
EndDo

//-- Ativa teclas de atalho
VTSetKey(09,{|| Informa()},STR0014) //"Informacoes"
VTSetKey(24,{|| Estorna()},STR0015) //"Estorna"
VTSetKey(22,{|| Volume()}, STR0016) //"Volume"

While .T.
	If !Embalagem()
		Exit
	EndIf
	CB9->(DBSetOrder(2))
	If ! CB9->(DBSeek(xFilial("CB9")+cOrdSep+Space(nTamVol)))
		If lV167Embala
			ExecBlock("V167EMBALA",.F.,.F.)
		EndIf
		Exit
	EndIf
EndDo

//-- Restaura teclas
VTSetKey(09,bkey09,cKey09)
VTSetKey(22,bkey22,cKey22)
VTSetKey(24,bkey24,cKey24)
Return FimProcEmb()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³Embalagem ³ Autor ³ ACD                   ³ Data ³ 03/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Realiza o Processo de Embalagem                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAACD                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Embalagem()
Local cSubVolume := Space(10)
Local cEtiqProd
Local cProduto
Local nQtde
Local lRetAgain :=.f.
Private lEmbala :=.t.
IF !Type("lVT100B") == "L"
	Private lVT100B := .F.
EndIf
CB9->(DBSetOrder(2))
VTClear()
If lVT100B // GetMv("MV_RF4X20")
	@ 0,0 VTSay STR0022+cVolume //"Embalagem Volume:"
	If '01' $ CB7->CB7_TIPEXP  //-- trabalha com sub-volume
		cSubVolume := Space(10)
		@ 2,00 VtSay STR0018 //"Sub-volume a embalar"
		@ 3,00 VtGet cSubVolume Picture "@!" Valid VldSubVol(cSubVolume)
	Else
		nQtde := 1
		cProduto   := IIf( FindFunction( 'AcdGTamETQ' ), AcdGTamETQ(), Space(48) )
		If ! Usacb0("01")
			@ 1,0 VTSay STR0019 VtGet nQtde pict cPictQtdExp valid VldQtde(nQtde) when (lForcaQtd .or. VTLastkey() == 5) //"Qtde "
		EndIf
		@ 2,0 VTSay STR0023 //"Produto a embalar"
		@ 3,0 VTGet cProduto pict '@!' VALID VTLastkey() == 5 .or. VldProdEmb(cProduto,nQtde,NIL,NIL)
	EndIf
ElseIf VtModelo()=="RF"
	@ 0,0 VTSay STR0001 //"Embalagem"
	@ 1,0 VTSay STR0017+cVolume //"Volume :"
	If '01' $ CB7->CB7_TIPEXP  //-- trabalha com sub-volume
		cSubVolume := Space(10)
		@ 04,00 VtSay STR0018 //"Sub-volume a embalar"
		@ 05,00 VtGet cSubVolume Picture "@!" Valid VldSubVol(cSubVolume)
	Else
		nQtde := 1
		cProduto   := IIf( FindFunction( 'AcdGTamETQ' ), AcdGTamETQ(), Space(48) )
		If ! Usacb0("01")
			@ 3,0 VTSay STR0019 VtGet nQtde pict cPictQtdExp valid VldQtde(nQtde) when (lForcaQtd .or. VTLastkey() == 5) //"Qtde "
		EndIf
		@ 4,0 VTSay STR0020 //"Leia o produto"
		@ 5,0 VtSay STR0021 //"a embalar"
		@ 6,0 VTGet cProduto pict '@!' VALID VTLastkey() == 5 .or. VldProdEmb(cProduto,nQtde,NIL,NIL)
	EndIf
ElseIf VtModelo()=="MT44"
	If '01' $ CB7->CB7_TIPEXP  //-- trabalha com sub-volume
		cSubVolume := Space(10)
		@ 0,0 VTSay STR0022+cVolume //"Embalagem Volume:"
		@ 1,0 VtSay STR0018  VtGet cSubVolume Picture "@!" Valid VldSubVol(cSubVolume) //"Sub-volume a embalar"
	Else
		nQtde := 1
		cProduto   := IIf( FindFunction( 'AcdGTamETQ' ), AcdGTamETQ(), Space(48) )
		@ 0,0 VTSay STR0033+cVolume //"Vol:"
		If ! Usacb0("01")
			@ 0,18 VTSay STR0019 VtGet nQtde pict cPictQtdExp valid VldQtde(nQtde) when (lForcaQtd .or. VTLastkey() == 5) //"Qtde "
		EndIf
		@ 1,0 VTSay STR0023 VTGet cProduto pict '@!' VALID VTLastkey() == 5 .or. VldProdEmb(cProduto,nQtde,NIL,NIL) //"Produto a embalar"
	EndIf
ElseIf VtModelo()=="MT16"
	If '01' $ CB7->CB7_TIPEXP  //-- trabalha com sub-volume
		cSubVolume := Space(10)
		@ 0,0 VTSay STR0017+cVolume //"Volume :"
		@ 1,0 VtSay STR0024  VtGet cSubVolume Picture "@!" Valid VldSubVol(cSubVolume) //"Sub-volume"
	Else
		nQtde := 1
		cProduto   := IIf( FindFunction( 'AcdGTamETQ' ), AcdGTamETQ(), Space(48) )
		If Usacb0("01")
			@ 0,0 VTSay STR0025+cVolume //"Vol.:"
		Else
			@ 0,0 VTSay STR0019 VtGet nQtde pict cPictQtdExp valid VldQtde(nQtde) when (lForcaQtd .or. VTLastkey() == 5) //"Qtde "
		EndIf
		@ 1,0 VTSay STR0026 VTGet cProduto pict '@!' VALID VTLastkey() == 5 .or. VldProdEmb(cProduto,nQtde,NIL,NIL) //"Produto"
	EndIf
EndIf
VtRead
If VtLastKey() == 27
	Return .f.
EndIf
Return .T.


//-- incia processo de embalagem
Static Function InicProcEmb()
CBFlagSC5("2",cOrdSep)  //-- Em processo de embalagem
Reclock('CB7')
CB7->CB7_STATUS := "3"  // Embalando
CB7->CB7_STATPA := " "  // tira pausa
CB7->(MsUnLock())

If	ExistBlock("ACD167IN")
	ExecBlock("ACD167IN",.F.,.F.)
Endif

Return
//-- Estorna o processo de embalagem
Static Function Estorna()
Local ckey22    := VTDescKey(22)
Local bkey22    := VTSetKey(22)
Local cProduto  := IIf( FindFunction( 'AcdGTamETQ' ), AcdGTamETQ(), Space(48) )
Local cIdVol    := Space(10)
Local cVolume   := Space(10)
Local cSubVolume:= Space(10)
Local nQtde     := 0
Local aTela     := VTSave()
Local lVolta 	  := .F.
IF !Type("lVT100B") == "L"
	Private lVT100B := .F.
EndIf

//-- Desabilita tecla de atalho (Volume)
VTSetKey(22,Nil)

CB9->(DBSetOrder(1))
CB9->(DbSeek(xFilial("CB9")+cOrdSep))
While CB9->(! Eof() .and. CB9_FILIAL+CB9_ORDSEP == xFilial("CB9")+cOrdSep)

	If Empty(CB9->CB9_VOLUME)
		CB9->(DbSkip())
		Loop
	EndIf

	VTClear()
	If lVT100B // GetMv("MV_RF4X20")
		While .T.
			If lVolta
				VTClear
			EndIf
			
			@ 0,0 VtSay Padc(STR0027,VTMaxCol()) //"Estorno da leitura"
			@ 1,0 VTSay STR0028 //"Leia o volume"
			@ 2,0 VTGet cIdVol pict '@!' Valid VldVolEst(cIdVol,@cVolume)
			VTRead
			
			If !(vtLastKey() == 27)
				// Segunda tela------------------------------------------------
				VTClear()
				If '01' $ CB7->CB7_TIPEXP //-- trabalha com sub-volume
					cSubVolume := Space(10)
					@ 2,00 VtSay STR0029 //"Leia o sub-volume"
					@ 3,00 VtGet cSubVolume Picture "@!" Valid VldSubVol(cSubVolume,.t.,cVolume) when iif(vtRow() == 3 .and. vtLastKey() == 5,(VTKeyBoard(chr(27)),lVolta := .T.),.T.)
				Else
					nQtde := 1
					cProduto   := IIf( FindFunction( 'AcdGTamETQ' ), AcdGTamETQ(), Space(48) )
					If ! USACB0("01")
						@ 1,0 VTSay STR0019 VtGet nQtde pict cPictQtdExp valid VldQtde(nQtde) when lForcaQtd .and. iif(vtRow() == 1 .and. vtLastKey() == 5,(VTKeyBoard(chr(27)),lVolta := .T.),.T.) //"Qtde "
					EndIf
					@ 2,0 VTSay STR0020 //"Leia o produto"
					@ 3,0 VTGet cProduto pict '@!' VALID VTLastkey() == 5 .or. VldProdEmb(cProduto,@nQtde,.t.,cVolume) when iif(vtRow() == 3 .and. vtLastKey() == 5 .and. USACB0("01"),(VTKeyBoard(chr(27)),lVolta := .T.),.T.)
				EndIf
				VtRead
			EndIf
			
			if lVolta
				Loop
			endif
		EndDo
	ElseIf VtModelo()=="RF"
		@ 0,0 VtSay Padc(STR0027,VTMaxCol()) //"Estorno da leitura"
		@ 1,0 VTSay STR0028 //"Leia o volume"
		@ 2,0 VTGet cIdVol pict '@!' Valid VldVolEst(cIdVol,@cVolume)
		If '01' $ CB7->CB7_TIPEXP //-- trabalha com sub-volume
			cSubVolume := Space(10)
			@ 04,00 VtSay STR0029 //"Leia o sub-volume"
			@ 05,00 VtGet cSubVolume Picture "@!" Valid VldSubVol(cSubVolume,.t.,cVolume)
		Else
			nQtde := 1
			cProduto   := IIf( FindFunction( 'AcdGTamETQ' ), AcdGTamETQ(), Space(48) )
			If ! USACB0("01")
				@ 3,0 VTSay STR0019 VtGet nQtde pict cPictQtdExp valid VldQtde(nQtde) when (lForcaQtd .or. VTLastkey() == 5) //"Qtde "
			EndIf
			@ 4,0 VTSay STR0020 //"Leia o produto"
			@ 5,0 VTGet cProduto pict '@!' VALID VTLastkey() == 5 .or. VldProdEmb(cProduto,@nQtde,.t.,cVolume)
		EndIf
		VtRead
	ElseIf VtModelo()=="MT44"
		If '01' $ CB7->CB7_TIPEXP //-- trabalha com sub-volume
			cSubVolume := Space(10)
			@ 0,0 VTSay STR0030 VTGet cIdVol pict '@!' Valid VldVolEst(cIdVol,@cVolume) //"Estorno:Volume"
			@ 1,0 VtSay STR0031 VtGet cSubVolume Picture "@!" Valid VldSubVol(cSubVolume,.t.,cVolume) //"Sub-volume    "
		Else
			nQtde := 1
			cProduto   := IIf( FindFunction( 'AcdGTamETQ' ), AcdGTamETQ(), Space(48) )
			@ 0,0 VTSay STR0032 //"Estorno"
			@ 1,0 VTSay STR0033 VTGet cIdVol pict '@!' Valid VldVolEst(cIdVol,@cVolume) //"Vol:"
			If ! USACB0("01")
				@ 0,17 VTSay STR0019 VtGet nQtde pict cPictQtdExp valid VldQtde(nQtde) when (lForcaQtd .or. VTLastkey() == 5) //"Qtde "
			EndIf
			@ 1,17 VTSay STR0026 VTGet cProduto pict '@!' VALID VTLastkey() == 5 .or. VldProdEmb(cProduto,@nQtde,.t.,cVolume) //"Produto"
		EndIf
		VtRead
	ElseIf VtModelo()=="MT16"
		If '01' $ CB7->CB7_TIPEXP //-- trabalha com sub-volume
			cSubVolume := Space(10)
			@ 0,0 VTSay STR0016 VTGet cIdVol pict '@!' Valid VldVolEst(cIdVol,@cVolume) //"Volume"
			@ 1,0 VtSay "SubVol" VtGet cSubVolume Picture "@!" Valid VldSubVol(cSubVolume,.t.,cVolume)
		Else
			nQtde := 1
			cProduto   := IIf( FindFunction( 'AcdGTamETQ' ), AcdGTamETQ(), Space(48) )
			@ 0,0 VTSay STR0032 //"Estorno"
			@ 1,0 VTSay STR0016 VTGet cIdVol pict '@!' Valid VldVolEst(cIdVol,@cVolume) //"Volume"
			VtRead
			If VTLastkey() == 27
				Exit
			EndIf
			VtClear()
			If ! USACB0("01")
				@ 0,0 VTSay STR0019 VtGet nQtde pict cPictQtdExp valid VldQtde(nQtde) when (lForcaQtd .or. VTLastkey() == 5) //"Qtde "
			Else
				@ 0,0 VTSay STR0035+cVolume //"Volume "
			EndIf
			@ 1,0 VTSay STR0026 VTGet cProduto pict '@!' VALID VTLastkey() == 5 .or. VldProdEmb(cProduto,@nQtde,.t.,cVolume) //"Produto"
		EndIf
		VtRead
	EndIf
	If VTLastkey() == 27
		Exit
	EndIf
EndDo

VTRestore(,,,,aTela)
//-- Restaura Telca
VTSetKey(22,bKey22, cKey22)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ Volume   ³ Autor ³ ACD                   ³ Data ³ 01/03/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Geracao de novo Volume                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Volume()
Local aTela
Local cVolAnt
IF !Type("lVT100B") == "L"
	Private lVT100B := .F.
EndIf

cVolAnt := cVolume
aTela   := VTSave()
VTClear()
cVolume := Space(20)
If lVT100B // GetMv("MV_RF4X20")
	@ 0,0 VTSay STR0040 //"Leia o volume"
	@ 1,0 VtGet cVolume Pict "@!" Valid VldVolume()
	@ 2,0 VtSay STR0037 //"Tecle ENTER para"
	@ 3,0 VtSay STR0038 //"novo volume.    "
ElseIf VtModelo()=="RF"
	@ 0,0 VTSay STR0001 //"Embalagem"
	@ 1,0 VtSay STR0036 //"Leia o volume:"
	@ 2,0 VtGet cVolume Pict "@!" Valid VldVolume()
	@ 4,0 VtSay STR0037 //"Tecle ENTER para"
	@ 5,0 VtSay STR0038 //"novo volume.    "
Else
	If VtModelo()=="MT44"
		@ 0,0 VTSay STR0039 //"Leia o volume ou ENTER p/ novo volume"
	Else //-- mt16
		@ 0,0 VTSay STR0040 //"Leia o volume"
	EndIf
	@ 1,0 VtGet cVolume Pict "@!" Valid VldVolume()
EndIf
VTRead
VTRestore(,,,,aTela)
cVolume := Padr(cVolume,TamSX3("CB9_VOLUME")[1])
If VTLastkey() == 27
	cVolume := cVolAnt
	Return .f.
EndIf
//-- Atualiza Display na tela de embalagem
If VtModelo()=="RF" .or. lVT100B // GetMv("MV_RF4X20")
	@ 1,0 VTSay STR0017+cVolume //"Volume :"
ElseIf VtModelo()=="MT44"
	If '01' $ CB7->CB7_TIPEXP
		@ 0,0 VTSay STR0022+cVolume //"Embalagem Volume:"
	Else
		@ 0,0 VTSay STR0033+cVolume //"Vol:"
	EndIf
ElseIf VtModelo()=="MT16"
	If '01' $ CB7->CB7_TIPEXP
		@ 0,0 VTSay STR0017+cVolume //"Volume :"
	Else
		If Usacb0("01")
			@ 0,0 VTSay STR0033+cVolume //"Vol:"
		EndIf
	EndIf
EndIf
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ FimProcEmb ³ Autor ³ ACD                 ³ Data ³ 01/03/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Finalisa o processo de embalagem                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FimProcEmb()
Local  cMsg     := ''
Local  nSai     := 1
Local  lExitEmb := .F.
Local  lVolEmpty:= .F.

CB9->(DBSetOrder(2))
If CB9->(DBSeek(xFilial("CB9")+cOrdSep+Space(TamSX3("CB9_VOLUME")[1])))
	lVolEmpty := .T.
EndIf

CB9->(DBSeek(xFilial("CB9")+cOrdSep))
While CB9->(!Eof() .AND. CB9_FILIAL+CB9_ORDSEP==xFilial("CB9")+cOrdSep)
	If !Empty(CB9->CB9_VOLUME)
		lExitEmb := .T.
		Exit
	EndIf
	CB9->(DbSkip())
EndDo

Reclock('CB7')
If	lVolEmpty .And. !lExitEmb  //-- Nao existem produtos embalados
	nSai := 0
	CB7->CB7_STATUS := "2"  //-- retorna para processo de separacao
	cMsg := STR0041 //"Processo de embalagem nao iniciado"
ElseIf	!lVolEmpty
	nSai := 1
	If	CB7->CB7_STATUS < "4"
		If	("02" $ CBUltExp(CB7->CB7_TIPEXP))
			CB7->CB7_STATUS := "9"  // embalagem finalizada
			cMsg := STR0091 //"Processo de expedicao finalizado"
		Else
			CB7->CB7_STATUS := "4"  // embalagem finalizada
			cMsg := STR0010 //"Processo de embalagem finalizado"
		EndIf
	EndIf
Else
	nSai := 0
	CB7->CB7_STATUS := "3"  // embalagem em andamento
	cMsg := STR0042 //"Processo de embalagem nao finalizado"
EndIf
If	!("02" $ CBUltExp(CB7->CB7_TIPEXP))
	CB7->CB7_STATPA := "1"  // Pausa
EndIf
CB7->(MsUnLock())
VTAlert(cMsg,STR0008,.t.,4000,3) //"Aviso"

//Verifica se esta sendo chamado pelo ACDV170 e se existe um avanco
//ou retrocesso forcado pelo operador
If ACDGet170() .AND. A170AvOrRet()
	If CB7->CB7_STATUS == "3" //-- Nao efetua saltos com embalagem em andamento
		nSai := 0
	Else
		nSai := A170ChkRet()
	EndIf
ElseIf ACDGet170().AND. ((lVolEmpty .and. !lExitEmb) .OR. CB7->CB7_STATUS == "3") .AND. ;
		VTYesNo(STR0043,STR0013,.T.) //"Deseja abandonar o processo de embalagem ?"###"Atencao"
	nSai := 10
EndIf
If	ExistBlock("ACD167FI")
	ExecBlock("ACD167FI",.F.,.F.)
Endif
Return nSai

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ Informa    ³ Autor ³ ACD                 ³ Data ³ 01/03/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Mostra produtos que ja foram lidos/embalados               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Informa()
Local ckey22  := VTDescKey(22)
Local bkey22  := VTSetKey(22)
Local aCab,aSize
Local aSave   := VTSAVE()
Local aTemp   :={}
Local nTam

//-- Desabilita tecla de atalho (Volume)
VTSetKey(22,Nil)

VTClear()
If UsaCB0('01')
	aCab  := {STR0016,STR0026,STR0045,STR0046,STR0047,STR0048,STR0049,STR0050,STR0024,"Serie",STR0051} //"Volume"###"Produto"###"Qtde Separada"###"Qtde embalada"###"Armazem"###"Endereco"###"Lote"###"Sub-Lote"###"Sub-volume"###"Id Etiqueta"
Else
	aCab  := {STR0016,STR0026,STR0045,STR0046,STR0047,STR0048,STR0049,STR0050,STR0024,"Serie"} //"Volume"###"Produto"###"Qtde Separada"###"Qtde embalada"###"Armazem"###"Endereco"###"Lote"###"Sub-Lote"###"Sub-volume"
EndIf
nTam := len(aCab[3])
If nTam < len(Transform(0,cPictQtdExp))
	nTam := len(Transform(0,cPictQtdExp))
EndIf
If UsaCB0('01')
	aSize := {10,15,nTam,nTam,7,10,10,8,10,20,12}
Else
	aSize := {10,15,nTam,nTam,7,10,10,8,10,20}
EndIf

CB9->(DbSetOrder(6))
CB9->(DbSeek(xFilial("CB9")+cOrdSep))
While CB9->(! Eof() .and. CB9_FILIAL+CB9_ORDSEP == xFilial("CB9")+cOrdSep)
	If UsaCB0('01')
		aadd(aTemp,{CB9->CB9_VOLUME,CB9->CB9_PROD,Transform(CB9->CB9_QTESEP,cPictQtdExp),Transform(CB9->CB9_QTEEMB,cPictQtdExp),CB9->CB9_LOCAL,CB9->CB9_LCALIZ,CB9->CB9_LOTECT,CB9->CB9_NUMLOT,CB9->CB9_SUBVOL,CB9->CB9_NUMSER,CB9->CB9_CODETI})
	Else
		aadd(aTemp,{CB9->CB9_VOLUME,CB9->CB9_PROD,Transform(CB9->CB9_QTESEP,cPictQtdExp),Transform(CB9->CB9_QTEEMB,cPictQtdExp),CB9->CB9_LOCAL,CB9->CB9_LCALIZ,CB9->CB9_LOTECT,CB9->CB9_NUMLOT,CB9->CB9_SUBVOL,CB9->CB9_NUMSER})
	EndIf
	CB9->(DbSkip())
EndDo
VTaBrowse(,,,,aCab,aTemp,aSize)
VtRestore(,,,,aSave)
//-- Restaura Telca
VTSetKey(22,bKey22, cKey22)
Return

//////////////////////////////////////////////////////////////
// Funcoes de validacao
/////////////////////////////////////////////////////////////
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ VldVolEst³ Autor ³ ACD                   ³ Data ³ 01/03/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida o estorno do volume                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VldVolEst(cIDVolume,cVolume)
Local aRet:= {}

If	VtLastkey()== 05
	Return .t.
EndIf

If Empty(cIDVolume)
	Return .f.
EndIf

If UsaCB0("05")
	aRet:= CBRetEti(cIDVolume,"05")
	If Empty(aRet)
		VtAlert(STR0052,STR0008,.t.,4000,3) //"Etiqueta de volume invalida"###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .f.
	Else
		cVolume:= aRet[1]
	EndIf
Else
	cVolume:= cIDVolume
EndIf

CB6->(DBSetOrder(1))
If ! CB6->(DbSeek(xFilial("CB6")+cVolume))
	VtAlert(STR0053,STR0008,.t.,4000,3) //"Codigo de volume nao cadastrado"###"Aviso"
	VtKeyboard(Chr(20))  // zera o get
	Return .f.
EndIf

CB9->(DBSetOrder(2))
If ! CB9->(DbSeek(xFilial("CB9")+cOrdSep+cVolume))
	VtAlert(STR0054,STR0008,.t.,4000,3) //"Volume pertence a outra ordem de separacao"###"Aviso"
	VtKeyboard(Chr(20))  // zera o get
	Return .f.
EndIf
If	ExistBlock("ACD167VV")                
	lRet := ExecBlock("ACD167VV",.F.,.F.,{cOrdSep,cVolume})
	If ValType(lret) == "L" .and. !lRet
		VtKeyboard(Chr(20))  // zera o get
		Return .f.
	EndIf	
EndIf
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³VldSubVol ³ Autor ³ ACD                   ³ Data ³ 01/03/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Funcao auxiliar Chamada pelas Funcoes Estorna e Embalagem   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAACD                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VldSubVol(cSubVolume,lEstorna,cVolumeEst)
Local aRet := CBRetEti(cSubVolume,"05")
DEFAULT lEstorna:= .f.

If Empty(cSubVolume)
	Return .f.
EndIf
If Empty(aRet)
	VtAlert(STR0055,STR0008,.t.,4000,3) //"Etiqueta invalida"###"Aviso"
	VtKeyboard(Chr(20))  // zera o get
	return .f.
EndIf
cCodVol := aRet[1]
CB6->(DBSetOrder(1))
If ! CB6->(DbSeek(xFilial("CB6")+cCodVol))
	VtAlert(STR0056,STR0008,.t.,4000,3) //"Codigo de sub-volume nao cadastrado"###"Aviso"
	VtKeyboard(Chr(20))  // zera o get
	return .f.
EndIf
If CB7->CB7_ORIGEM == "1"
	If ! CB6->CB6_PEDIDO == CB7->CB7_PEDIDO
		VtAlert(STR0057+CB6->CB6_PEDIDO,STR0008,.t.,4000,3) //"Sub-volume pertence ao pedido "###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		return .f.
	EndIf
ElseIf CB7->CB7_ORIGEM == "2"
	If ! CB6->(CB6_NOTA+CB6_SERIE) == CB7->(CB7_NOTA+CB7_SERIE)
		VtAlert(STR0058+CB6->CB6_NOTA+'-'+SerieNfId("CB6",2,"CB6_SERIE"),STR0008,.t.,4000,3) //"Sub-volume pertence a nota "###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		return .f.
	EndIf
EndIF

CB9->(DbSetOrder(7))
If ! CB9->(DbSeek(xFilial("CB9")+cOrdSep+cCodVol))
	If lEstorna
		VtAlert(STR0059,STR0008,.t.,4000) //"Sub-volume nao pertence esta ordem de separacao"###"Aviso"
	Else
		VtAlert(STR0060,STR0008,.t.,4000) //"Sub-volume nao separado"###"Aviso"
	EndIf
	VtKeyboard(Chr(20))  // zera o get
	return .f.
EndIf
If ! lEstorna
	If ! Empty(CB9->CB9_VOLUME)
		VtAlert(STR0061,STR0008,.t.,4000) //"Sub-Volume ja embalado"###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		return .f.
	EndIf
	While CB9->(! EOF() .and. CB9_FILIAL+CB9_ORDSEP+CB9_SUBVOL == ;
			xFilial("CB9")+cOrdSep+cCodVol)
		RecLock("CB9")
		CB9->CB9_VOLUME := cVolume
		CB9->CB9_CODEMB := cCodOpe
		CB9->(MsUnLock())
		CB9->(DBSkip())
	End
Else
	If Empty(CB9->CB9_VOLUME)
		VtAlert(STR0062,STR0008,.t.,4000,3) //"Sub-Volume nao embalado"###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		return .f.
	EndIf
	If CB9->CB9_VOLUME # cVolumeEst
		VtAlert(STR0063+CB9->CB9_VOLUME,STR0008,.t.,4000,3) //"Sub-Volume pertence ao volume "###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		return .f.
	EndIf
	While CB9->(! EOF() .and. CB9_FILIAL+CB9_ORDSEP+CB9_SUBVOL == ;
			xFilial("CB9")+cOrdSep+cCodVol)
		RecLock("CB9")
		CB9->CB9_VOLUME := " "
		CB9->CB9_CODEMB := " "
		CB9->(MsUnLock())
		CB9->(DBSkip())
	End
EndIf
VtKeyboard(Chr(20))  // zera o get
Return ! lEstorna

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³  VldQtde ³ Autor ³ Anderson Rodrigues    ³ Data ³ 29/06/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Validacao da quantidade informada                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAACD                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VldQtde(nQtde,lSerie)
Default lSerie:= .f.

If	nQtde <= 0
	Return .f.
EndIf
If	lSerie .and. nQtde > 1
	VTAlert(STR0064,STR0008,.T.,2000) //"Quantidade invalida !!!"###"Aviso"
	VTAlert(STR0065,STR0008,.T.,4000) //"Quando se utiliza numero de serie a quantidade deve ser == 1"###"Aviso"
	Return .f.
EndIf
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³VldProdEmb³ Autor ³ ACD                   ³ Data ³ 01/03/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Funcao auxiliar chamada pela funcao Embalagem               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAACD                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VldProdEmb(cEProduto,nQtde,lEstorna,cVolumeEst)
Local cTipo
Local aEtiqueta,aRet
Local aPed := {}
Local cSequen := " "
Local cLote    := Space(TamSX3("B8_LOTECTL")[1])
Local cSLote   := Space(TamSX3("B8_NUMLOTE")[1])
Local cNumSer  := Space(TamSX3("BF_NUMSERI")[1])
Local nQE      :=0
Local nQEConf  :=0
Local nSaldoEmb
Local nRecno,nRecnoCB9
Local cProduto
Local nQtdeSep
Local lPrdIguais:= .F.
Local lRet		:= .T.
Local lFirst 	:= .T.
Local cC9Fil	:= Nil
Local cC9OrdSep	:= Nil
Local cC9Produt	:= Nil
Local cC9CodEti	:= Nil
Local cC9Volum	:= Nil
Local cCB9Alias	:= GetNextAlias()
Local lImg01	:= ExistBlock('IMG01')
Local lRemIEmb 	:= GetMV('MV_REMIEMB') == "S"
Local lChkEmb	:= GetMv("MV_CHKQEMB") == "1"

DEFAULT lEstorna := .f.

If Empty(cEProduto)
	Return .f.
EndIf

If !CBLoad128(@cEProduto)
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
EndIf
cTipo :=CbRetTipo(cEProduto)
If cTipo == "01"
	aEtiqueta:= CBRetEti( cEProduto, cTipo,,,cOrdSep )
	If Empty(aEtiqueta)
		VtAlert(STR0055,STR0008,.t.,4000,3) //"Etiqueta invalida"###"Aviso"
		//-- Permite intera??o diferente do vtalert
		If ExistBlock("V167VLD")
			ExecBlock("V167VLD",,,{cEProduto,cTipo})
		EndIf
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
	CB9->(DbSetorder(1))
	If ! CB9->(DbSeek(xFilial("CB9")+cOrdSep+Left(cEProduto,10)))
		VtAlert(STR0066,STR0008,.t.,4000,3) //"Produto nao separado"###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
	If ! lEstorna
		If ! Empty(CB9->CB9_VOLUME)
			VtAlert(STR0067+CB9->CB9_VOLUME,STR0008,.t.,4000,3) //"Produto embalado no volume "###"Aviso"
			VtKeyboard(Chr(20))  // zera o get
			Return .F.
		EndIf
	Else
		If Empty(CB9->CB9_VOLUME)
			VtAlert(STR0068,STR0008,.t.,4000) //"Produto nao embalado"###"Aviso"
			VtKeyboard(Chr(20))  // zera o get
			Return .F.
		EndIf
		If CB9->CB9_VOLUME # cVolumeEst
			VtAlert(STR0069+CB9->CB9_VOLUME,STR0008,.t.,4000,3) //"Produto embalado em outro volume "###"Aviso"
			VtKeyboard(Chr(20))  // zera o get
			Return .F.
		EndIf
	EndIf
	
	cProduto:= aEtiqueta[1]
	nQE     := aEtiqueta[2]
	cLote   := aEtiqueta[16]
	cSLote  := aEtiqueta[17]
	nBkpSld	:= nQE

	cC9Fil 		:= CB9->CB9_FILIAL
	cC9OrdSep	:= CB9->CB9_ORDSEP
	cC9Produt	:= CB9->CB9_PROD
	cC9CodEti	:= CB9->CB9_CODETI
	cC9Volum	:= CB9->CB9_VOLUME

	cQuery := " SELECT CB9.R_E_C_N_O_ CB9RECNO "
	cQuery += " FROM "+ RetSQLName( 'CB9' ) +" CB9 "
	cQuery += " WHERE CB9.CB9_FILIAL = '"+ cC9Fil +"' "
	cQuery += " 	AND CB9.CB9_VOLUME = '"+ cC9Volum  +"' "
	cQuery += " 	AND CB9.CB9_ORDSEP = '"+ cC9OrdSep +"' "
	cQuery += " 	AND CB9.CB9_PROD   = '"+ cC9Produt +"' "
	cQuery += " 	AND CB9.CB9_CODETI = '"+ cC9CodEti +"' "
	cQuery += " 	AND CB9.D_E_L_E_T_ = ' ' "		
	
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., __cRdd, TCGenQry( Nil, Nil, cQuery ), cCB9Alias, .T., .F. )

	SB1->( dbSetOrder( 1 ) )
	CB8->( dbSetOrder( 4 ) )
	
	dbSelectArea( cCB9Alias )
	While !( cCB9Alias )->( Eof() )
		CB9->( dbGoto( ( cCB9Alias )->CB9RECNO ) )
			nSaldoE := IIf( nQE > CB9->CB9_QTESEP, CB9->CB9_QTESEP, nQE )
			If !( lEstorna )
				nQEConf:= nSaldoE
				If ! CBProdUnit(aEtiqueta[1]) .and. lChkEmb
					nQEConf := CBQtdEmb(aEtiqueta[1])
				EndIf
				If empty(nQEConf) .or. nSaldoE # nQEConf
					VtAlert(STR0070,STR0008,.t.,4000,3) //"Quantidade invalida "###"Aviso"
					VtKeyboard(Chr(20))  // zera o get
					lRet := .F.
					Exit
				EndIf

				RecLock("CB9")
				CB9->CB9_VOLUME := cVolume
				CB9->CB9_QTEEMB += nSaldoE
				CB9->CB9_CODEMB := cCodOpe
				CB9->CB9_STATUS := "2"  // Embalado
				CB9->(MsUnlock())
				
				CB8->( dbSeek( FWxFilial("CB8")+CB9->(CB9_ORDSEP+CB9_ITESEP+CB9_PROD+CB9_LOCAL+CB9_LCALIZ+CB9_LOTSUG+CB9_SLOTSU+CB9_NUMSER ) )  )
				RecLock("CB8")
				CB8->CB8_SALDOE -= nSaldoE
				CB8->(MsUnlock())

				SB1->( dbSeek( FWxFilial("SB1")+cProduto ) )
				If ! CBProdUnit(aEtiqueta[1]) .and. lRemIEmb
					If CB5SetImp(cImp,.T.)
						VTAlert(STR0071,STR0008,.T.,2000) //"Imprimindo etiqueta de produto "###"Aviso"
						If lImg01
							ExecBlock("IMG01",,,{,,CB9->CB9_CODETI})
						EndIf
						MSCBCLOSEPRINTER()
					EndIf
				EndIf
			Else
				If lFirst
					If ! VtYesNo(STR0072,STR0008,.t.) //"Confirma o estorno?"###"Aviso"
						VtKeyboard(Chr(20))  // zera o get
						lRet := .F.
						Exit
					Else
						lFirst := .F.
					EndIf
				EndIf
				RecLock("CB9")
				CB9->CB9_VOLUME := ''
				CB9->CB9_QTEEMB -= nSaldoE
				CB9->CB9_CODEMB := ''
				CB9->CB9_STATUS := "1"  // Em Aberto
				CB9->(MsUnlock())
				
				CB8->( dbSeek( FWxFilial("CB8")+CB9->(CB9_ORDSEP+CB9_ITESEP+CB9_PROD+CB9_LOCAL+CB9_LCALIZ+CB9_LOTSUG+CB9_SLOTSU+CB9_NUMSER ) ) )
				RecLock("CB8")
				CB8->CB8_SALDOE += nSaldoE
				CB8->(MsUnlock())

			EndIf
			nQE := ( nQE - nSaldoE )

		( cCB9Alias )->( dbSkip() )	
	EndDo

	nQE := nBkpSld
	IIf( Select( cCB9Alias ) > 0, ( cCB9Alias )->( dbCloseArea() ), Nil )
	If !( lRet )
		Return lRet
	Else
		If lEstorna
			lEstorna := IsEstEmb( cC9Fil, cC9OrdSep, cC9Volum )
		EndIf
	EndIf

ElseIf cTipo $ "EAN8OU13-EAN14-EAN128"
	aRet := CBRetEtiEan(cEProduto)
	If	Empty(aRet)
		VtAlert(STR0055,STR0008,.t.,4000,3) //"Etiqueta invalida"###"Aviso"
		//-- Permite interação diferente do vtalert
		If ExistBlock("V167VLD")
			ExecBlock("V167VLD",,,{cEProduto,cTipo})
		EndIf
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
	cProduto := aRet[1]
	If	! CBProdUnit(cProduto)
		VtAlert(STR0055,STR0008,.t.,4000,3) //"Etiqueta invalida"###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
	If cTipo == "EAN14" // Se for EAN14, utiliza o operador logistico como quantidade 
		nQE := aRet[2]*nQtde
	ElseIf Empty(aRet[2])
		nQE  :=CBQtdEmb(cProduto)*nQtde
	Else
		nQE  :=CBQtdEmb(cProduto)*nQtde*aRet[2]	
	EndIf
	If	Empty(nQE)
		VtAlert(STR0073,STR0008,.t.,4000,3) //"Quantidade invalida"###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
	cLote  := aRet[3]
	If	! CBRastro(cProduto,@cLote,@cSLote)
		VTKeyBoard(chr(20))
		Return .f.
	EndIf
	cNumSer := aRet[5]
	If	Empty(cNumSer) .and. CBSeekNumSer(cOrdSep,cProduto)
		If	! VldQtde(nQtde,.T.)
			VtKeyboard(Chr(20))  // zera o get
			Return .F.
		EndIf
		If	! CBNumSer(@cNumSer)
			VTKeyBoard(chr(20))
			Return .f.
		EndIf
	EndIf
	
	If ExistBlock("ACD167VE")
		aRet := ExecBlock("ACD167VE",,,{aRet,lEstorna,nQtde})
		If Empty(aRet)
			Return .f.
		EndIf            
		cLote   := aRet[3]
		cNumSer := aRet[5]
	EndIf
	// Verifica produtos iguais ao realizar a embalagem em pedidos distintos 
	lPrdIguais := EmbProdIG(cProduto,nQtde,lEstorna,cVolumeEst,cLote,cSLote,cNumSer)

	If	! lEstorna
		CB9->(DbSetorder(8))
		If	! CB9->(DBSeek(xFilial("CB9")+cOrdSep+cProduto+cLote+cSLote+cNumSer+space(10)))
			VtAlert(STR0074,STR0008,.t.,4000,3)   //"Produto invalido, ou ja embalado"###"Aviso"
			VtKeyboard(Chr(20))  // zera o get
			Return .F.
		EndIf
		nSaldoEmb:=0
		While CB9->(! EOF() .AND. CB9_FILIAL+CB9_ORDSEP+CB9_PROD+CB9_LOTECT+CB9_NUMLOT+CB9_VOLUME ==;
				xFilial("CB9")+cOrdSep+cProduto+cLote+cSLote+space(10))
			nSaldoEmb += CB9->CB9_QTESEP
			CB9->(DbSkip())
		EndDo
		If	nQE > nSaldoEmb
			VtAlert(STR0075,STR0008,.t.,4000)   //"Quantidade informada maior que disponivel para embalar"###"Aviso"
			VtKeyboard(Chr(20))  // zera o get
			Return .F.
		EndIf
		//-- Atualiza Quantidade Embalagem
		nSaldoEmb := nQE
		CB9->(DbSetorder(8))
		While nSaldoEmb > 0 .And. CB9->(DBSeek(xFilial("CB9")+cOrdSep+cProduto+cLote+cSLote+cNumSer+space(10)))
			If	nSaldoEmb > CB9->CB9_QTESEP
				Begin Transaction
					RecLock("CB9")
					CB9->CB9_VOLUME := cVolume
					CB9->CB9_QTEEMB := CB9->CB9_QTESEP
					CB9->CB9_CODEMB := cCodOpe
					CB9->CB9_STATUS := "2"  // Embalado
					CB9->(MsUnlock())
					//-- Atualiza Itens Ordem da Separacao
					CB8->(DbSetOrder(4)) //-- CB8_FILIAL+CB8_ORDSEP+CB8_ITEM+CB8_PROD+CB8_LOCAL+CB8_LCALIZ+CB8_LOTECT+CB8_NUMLOT+CB8_NUMSER
					If CB8->(DbSeek(xFilial("CB8")+CB9->(CB9_ORDSEP+CB9_ITESEP+CB9_PROD+CB9_LOCAL+CB9_LCALIZ+CB9_LOTECT+CB9_NUMLOT+CB9_NUMSER)))
						RecLock("CB8")
						CB8->CB8_SALDOE -= CB9->CB9_QTESEP
						CB8->(MsUnlock())
					EndIf
				End Transaction
				nSaldoEmb-=CB9->CB9_QTESEP
			Elseif lPrdIguais .And. CB9->(DBSeek(xFilial("CB9")+cOrdSep+cProduto+cLote+cSLote+cNumSer+space(10))) .And.;
					 nSaldoEmb <= CB9->CB9_QTESEP					
					nRecno:= CB9->(CBCopyRec({{"CB9_VOLUME","X"}}))
					Begin Transaction
						RecLock("CB9")
						CB9->CB9_VOLUME := cVolume
						CB9->CB9_QTEEMB := nSaldoEmb
						CB9->CB9_QTESEP := nSaldoEmb
						CB9->CB9_CODEMB := cCodOpe
						CB9->CB9_STATUS := "2"  // Embalado
						CB9->(MsUnlock())
						
						//-- Atualiza Itens Ordem da Separacao
						If !Empty(CB9->CB9_PEDIDO)
							CB8->(DbSetOrder(2))
							CB8->(DbSeek(xFilial("CB8")+CB9->(CB9_PEDIDO+CB9_ITESEP+CB9_SEQUEN+CB9_PROD)))
						Else 
							CB8->(DbSetOrder(4)) //-- CB8_FILIAL+CB8_ORDSEP+CB8_ITEM+CB8_PROD+CB8_LOCAL+CB8_LCALIZ+CB8_LOTECT+CB8_NUMLOT+CB8_NUMSER
							IF CB8->(DbSeek(xFilial("CB8")+CB9->(CB9_ORDSEP+CB9_ITESEP+CB9_PROD+CB9_LOCAL+CB9_LCALIZ+CB9_LOTECT+CB9_NUMLOT+CB9_NUMSER)))
								While CB8->(! Eof() .and. (xFilial("CB8")+CB8_ORDSEP+CB8_ITEM+CB8_PROD+CB8_LOCAL+CB8_LCALIZ+CB8_LOTECT+CB8_NUMLOT+CB8_NUMSER) ==;
															CB9->(xFilial("CB8")+CB9_ORDSEP+CB9_ITESEP+CB9_PROD+CB9_LOCAL+CB9_LCALIZ+CB9_LOTSUG+CB9_SLOTSU+CB9_NUMSER))
										IF CB8->CB8_SALDOE >= nSaldoEmb
											Exit 
										EndIf
										CB8->(dBSkip())
								EndDo
							EndIF
						EndIf
						RecLock("CB8")
						CB8->CB8_SALDOE -= nSaldoEmb
						CB8->(MsUnlock())
						//--
						CB9->(DBGoto(nRecno))
						RecLock("CB9")
						CB9->CB9_VOLUME := Space(10)
						CB9->CB9_QTESEP -= nSaldoEmb
						If	Empty(CB9->CB9_QTESEP)
							CB9->(DBDelete())
						EndIf
						CB9->(MsUnlock())
					End Transaction
					nSaldoEmb := 0
			Else
				nRecnoCB9:= CB9->(Recno())
				CB9->(DbSetOrder(8))
				If	CB9->(DBSeek(CB9_FILIAL+CB9_ORDSEP+CB9_PROD+CB9_LOTECT+CB9_NUMLOT+CB9_NUMSER+cVolume+CB9_ITESEP+CB9_LOCAL+CB9_LCALIZ))
					Begin Transaction
						RecLock("CB9")
						CB9->CB9_QTEEMB += nSaldoEmb
						CB9->CB9_QTESEP += nSaldoEmb
						CB9->(MsUnlock())
						//-- Atualiza Itens Ordem da Separacao
						CB8->(DbSetOrder(4)) //-- CB8_FILIAL+CB8_ORDSEP+CB8_ITEM+CB8_PROD+CB8_LOCAL+CB8_LCALIZ+CB8_LOTECT+CB8_NUMLOT+CB8_NUMSER
						If CB8->(DbSeek(xFilial("CB8")+CB9->(CB9_ORDSEP+CB9_ITESEP+CB9_PROD+CB9_LOCAL+CB9_LCALIZ+CB9_LOTECT+CB9_NUMLOT+CB9_NUMSER)))
							RecLock("CB8")
							CB8->CB8_SALDOE -= nSaldoEmb
							CB8->(MsUnlock())
						EndIf
						//--
						CB9->(DbGoto(nRecnoCB9))
						RecLock("CB9")
						CB9->CB9_QTESEP -= nSaldoEmb
						If	Empty(CB9->CB9_QTESEP)
							CB9->(DBDelete())
						EndIf
						CB9->(MsUnlock())
					End Transaction
					nSaldoEmb := 0
				Else
					CB9->(DbGoto(nRecnoCB9))
					nRecno:= CB9->(CBCopyRec({{"CB9_VOLUME","X"}}))
					Begin Transaction
						RecLock("CB9")
						CB9->CB9_VOLUME := cVolume
						CB9->CB9_QTEEMB := nSaldoEmb
						CB9->CB9_QTESEP := nSaldoEmb
						CB9->CB9_CODEMB := cCodOpe
						CB9->CB9_STATUS := "2"  // Embalado
						CB9->(MsUnlock())
						//-- Atualiza Itens Ordem da Separacao
						CB8->(DbSetOrder(4)) //-- CB8_FILIAL+CB8_ORDSEP+CB8_ITEM+CB8_PROD+CB8_LOCAL+CB8_LCALIZ+CB8_LOTECT+CB8_NUMLOT+CB8_NUMSER
						If CB8->(DbSeek(xFilial("CB8")+CB9->(CB9_ORDSEP+CB9_ITESEP+CB9_PROD+CB9_LOCAL+CB9_LCALIZ+CB9_LOTECT+CB9_NUMLOT+CB9_NUMSER)))
							RecLock("CB8")
							CB8->CB8_SALDOE -= nSaldoEmb
							CB8->(MsUnlock())
						EndIf
						//--
						CB9->(DBGoto(nRecno))
						RecLock("CB9")
						CB9->CB9_VOLUME := Space(10)
						CB9->CB9_QTESEP -= nSaldoEmb
						If	Empty(CB9->CB9_QTESEP)
							CB9->(DBDelete())
						EndIf
						CB9->(MsUnlock())
					End Transaction
					nSaldoEmb := 0
				EndIf
			EndIf
		EndDo
	Else
		CB9->(DbSetorder(8))
		If ! CB9->(DBSeek(xFilial("CB9")+cOrdSep+cProduto+cLote+cSLote+cNumSer+cVolumeEst))
			VtAlert(STR0068,STR0008,.t.,4000) //"Produto nao embalado"###"Aviso"
			VtKeyboard(Chr(20))  // zera o get
			Return .F.
		EndIf
		nSaldoEmb:=0
		While CB9->(! EOF() .AND. CB9_FILIAL+CB9_ORDSEP+CB9_PROD+CB9_LOTECT+CB9_NUMLOT+CB9_VOLUME ==;
				xFilial("CB9")+cOrdSep+cProduto+cLote+cSLote+cVolumeEst)
			nSaldoEmb += CB9->CB9_QTEEMB
			CB9->(DbSkip())
		EndDo
		If nQE > nSaldoEmb
			VtAlert(STR0076,STR0008,.t.,4000,3) //"Quantidade informada maior que embalado no volume "###"Aviso"
			VtKeyboard(Chr(20))  // zera o get
			Return .F.
		EndIf
		If ! VtYesNo(STR0072,STR0008,.t.) //"Confirma o estorno?"###"Aviso"
			VtKeyboard(Chr(20))  // zera o get
			Return .F.
		EndIf
		//-- Estorna Quantidade Embalagem
		nSaldoEmb := nQE
		If lPrdIguais .And. !UsaCB0('01')
			CB9->(DbSetorder(8))
			If CB9->(DBSeek(xFilial("CB9")+cOrdSep+cProduto+cLote+cSLote+cNumSer+cVolumeEst))
				IF !Empty(CB9->CB9_PEDIDO)
					aPed := TelPedEmb(cOrdSep,cProduto,CB9->CB9_ITESEP,CB9->CB9_SEQUEN)
					CB9->(DbSetorder(8))
					If aPed <> Nil .And. Len(aPed) > 0 
						While nSaldoEmb>0 .And. CB9->(xFilial("CB9")+cOrdSep+cProduto+cLote+cSLote+cNumSer+cVolumeEst) ==;
												CB9->(xFilial("CB9")+CB9_ORDSEP+CB9_PROD+CB9_LOTECT+CB9_NUMLOT+CB9_NUMSER+CB9_VOLUME)
							If aPed[1][1] == CB9->CB9_PEDIDO .And. aPed[1][2] == CB9->CB9_ITESEP .And. 	aPed[1][3] == CB9->CB9_ORDSEP
								// grava a sequencia correta
									cSequen := CB9->CB9_SEQUEN
								If nSaldoEmb >= CB9->CB9_QTEEMB
									nRecnoCB9:= CB9->(Recno())
									nQtdeSep := CB9->CB9_QTESEP
									Begin Transaction
										CB9->(DbSetOrder(8))
			                     	If CB9->(DBSeek(CB9_FILIAL+CB9_ORDSEP+CB9_PROD+CB9_LOTECT+CB9_NUMLOT+CB9_NUMSER+Space(10)+CB9_ITESEP+CB9_LOCAL+CB9_LCALIZ))
											RecLock("CB9")
											CB9->CB9_QTESEP += nQtdeSep
											CB9->(MsUnlock())
											CB9->(DbGoto(nRecnoCB9))
											// Posicionar na ordem de separação para atualizar saldo
										   	CB8->(DbSetOrder(2))
											CB8->(DbSeek(xFilial("CB8")+aPed[1][1]+aPed[1][2]+cSequen+cProduto))
										   	RecLock("CB9")
											CB9->(DbDelete())
											CB9->(MsUnlock())	
										Else
											CB9->(DbGoto(nRecnoCB9))
											RecLock("CB9")
											CB9->CB9_VOLUME := ""
											CB9->CB9_QTEEMB := 0
											CB9->CB9_CODEMB := ""
											CB9->CB9_STATUS := "1"  // Em Aberto
											CB9->(MsUnlock())
											// Posicionar na ordem de separação para atualizar saldo
											CB8->(DbSetOrder(2))
											CB8->(DbSeek(xFilial("CB8")+aPed[1][1]+aPed[1][2]+cSequen+cProduto))
										EndIf
										RecLock("CB8")
										CB8->CB8_SALDOE += nQtdeSep
										CB8->(MsUnlock())
									End Transaction
									nSaldoEmb-=nQtdeSep
									CB9->(DbSkip())
								Else
										nRecnoCB9:= CB9->(Recno())
										nQtdeSep := CB9->CB9_QTESEP
										Begin Transaction
											CB9->(DbSetOrder(8))
											If	CB9->(DBSeek( CB9_FILIAL+CB9_ORDSEP+CB9_PROD+CB9_LOTECT+CB9_NUMLOT+CB9_NUMSER+Space(10)+CB9_ITESEP+CB9_LOCAL+CB9_LCALIZ))
												RecLock("CB9")
												CB9->CB9_QTESEP += nSaldoEmb
												CB9->(MsUnlock())
												//--
												CB9->(DbGoto(nRecnoCB9))
												RecLock("CB9")
												//CB9->CB9_VOLUME := ""
												CB9->CB9_QTEEMB -= nSaldoEmb
												CB9->CB9_QTESEP -= nSaldoEmb
												//CB9->CB9_CODEMB := ''
												//CB9->CB9_STATUS := "1"
												If	Empty(CB9->CB9_QTESEP)
													CB9->(DbDelete())
												EndIf
												CB9->(MsUnlock())
												//--
												CB8->(DbSetOrder(2))
												CB8->(DbSeek(xFilial("CB8")+aPed[1][1]+aPed[1][2]+cSequen+cProduto))
												RecLock("CB8")
												CB8->CB8_SALDOE += nSaldoEmb
												CB8->(MsUnlock())
											Else
												CB9->(DbGoto(nRecnoCB9))
												nRecno:= CB9->(CBCopyRec({{"CB9_VOLUME","X"}}))
												RecLock("CB9")
												CB9->CB9_VOLUME := ""
												CB9->CB9_QTEEMB := 0
												CB9->CB9_QTESEP := nSaldoEmb
												CB9->CB9_CODEMB := ''
												CB9->CB9_STATUS := "1"
												CB9->(MsUnlock())
												//--
												CB8->(DbSetOrder(2))
												CB8->(DbSeek(xFilial("CB8")+aPed[1][1]+aPed[1][2]+cSequen+cProduto))
												RecLock("CB8")
												CB8->CB8_SALDOE += nSaldoEmb
												CB8->(MsUnlock())
												CB9->(DBGoto(nRecno))
												RecLock("CB9")              
												CB9->CB9_VOLUME := cVolumeEst
												CB9->CB9_QTESEP -= nSaldoEmb
												CB9->CB9_QTEEMB -= nSaldoEmb
												If	Empty(CB9->CB9_QTESEP)
													CB9->(DBDelete())
												EndIf
												CB9->(MsUnlock())
											EndIf
										End Transaction
										nSaldoEmb := 0
									EndIf
							EndIf
							CB9->(DbSkip())
						EndDo
					EndIf
				EndIf
			EndIf
		Else
			CB9->(DbSetorder(8))
			While nSaldoEmb>0 .And. CB9->(DBSeek(xFilial("CB9")+cOrdSep+cProduto+cLote+cSLote+cNumSer+cVolumeEst))
				If	nSaldoEmb >= CB9->CB9_QTEEMB
					nRecnoCB9:= CB9->(Recno())
					nQtdeSep := CB9->CB9_QTESEP
					Begin Transaction
						CB9->(DbSetOrder(8))
						If	CB9->(DBSeek(CB9_FILIAL+CB9_ORDSEP+CB9_PROD+CB9_LOTECT+CB9_NUMLOT+CB9_NUMSER+Space(10)+CB9_ITESEP+CB9_LOCAL+CB9_LCALIZ))
							RecLock("CB9")
							CB9->CB9_QTESEP += nQtdeSep
							CB9->(MsUnlock())
							CB9->(DbGoto(nRecnoCB9))
							//--
							CB8->(DbSetOrder(4))
							CB8->(DbSeek(xFilial("CB8")+CB9->(CB9_ORDSEP+CB9_ITESEP+CB9_PROD+CB9_LOCAL+CB9_LCALIZ+CB9_LOTECT+CB9_NUMLOT+CB9_NUMSER)))
							RecLock("CB9")
							CB9->(DbDelete())
							CB9->(MsUnlock())
						Else
							CB9->(DbGoto(nRecnoCB9))
							RecLock("CB9")
							CB9->CB9_VOLUME := ""
							CB9->CB9_QTEEMB := 0
							CB9->CB9_CODEMB := ""
							CB9->CB9_STATUS := "1"  // Em Aberto
							CB9->(MsUnlock())
							CB8->(DbSetOrder(4))
							CB8->(DbSeek(xFilial("CB8")+CB9->(CB9_ORDSEP+CB9_ITESEP+CB9_PROD+CB9_LOCAL+CB9_LCALIZ+CB9_LOTECT+CB9_NUMLOT+CB9_NUMSER)))
						EndIf
						RecLock("CB8")
						CB8->CB8_SALDOE += nQtdeSep
						CB8->(MsUnlock())							
					End Transaction
					nSaldoEmb-=nQtdeSep
				Else
					nRecnoCB9:= CB9->(Recno())
					nQtdeSep := CB9->CB9_QTESEP
					Begin Transaction
						CB9->(DbSetOrder(8))
						If	CB9->(DBSeek( CB9_FILIAL+CB9_ORDSEP+CB9_PROD+CB9_LOTECT+CB9_NUMLOT+CB9_NUMSER+Space(10)+CB9_ITESEP+CB9_LOCAL+CB9_LCALIZ))
							RecLock("CB9")
							CB9->CB9_QTESEP += nSaldoEmb
							CB9->(MsUnlock())
							//--
							CB9->(DbGoto(nRecnoCB9))
							RecLock("CB9")
							//CB9->CB9_VOLUME := ""
							CB9->CB9_QTEEMB -= nSaldoEmb
							CB9->CB9_QTESEP -= nSaldoEmb
							//CB9->CB9_CODEMB := ''
							//CB9->CB9_STATUS := "1"
							If	Empty(CB9->CB9_QTESEP)
								CB9->(DbDelete())
							EndIf
							CB9->(MsUnlock())
							//--
							CB8->(DbSetOrder(4))
							If CB8->(DbSeek(xFilial("CB8")+CB9->(CB9_ORDSEP+CB9_ITESEP+CB9_PROD+CB9_LOCAL+CB9_LCALIZ+CB9_LOTECT+CB9_NUMLOT+CB9_NUMSER)))
								RecLock("CB8")
								CB8->CB8_SALDOE += nSaldoEmb
								CB8->(MsUnlock())
							EndIf
						Else
							CB9->(DbGoto(nRecnoCB9))
							nRecno:= CB9->(CBCopyRec({{"CB9_VOLUME","X"}}))
							RecLock("CB9")
							CB9->CB9_VOLUME := ""
							CB9->CB9_QTEEMB := 0
							CB9->CB9_QTESEP := nSaldoEmb
							CB9->CB9_CODEMB := ''
							CB9->CB9_STATUS := "1"
							CB9->(MsUnlock())
							//--
							CB8->(DbSetOrder(4))
							If CB8->(DbSeek(xFilial("CB8")+CB9->(CB9_ORDSEP+CB9_ITESEP+CB9_PROD+CB9_LOCAL+CB9_LCALIZ+CB9_LOTECT+CB9_NUMLOT+CB9_NUMSER)))
								RecLock("CB8")
								CB8->CB8_SALDOE += nSaldoEmb
								CB8->(MsUnlock())
							EndIf
							CB9->(DBGoto(nRecno))
							RecLock("CB9")              
							CB9->CB9_VOLUME := cVolumeEst
							CB9->CB9_QTESEP -= nSaldoEmb
							CB9->CB9_QTEEMB -= nSaldoEmb
							If	Empty(CB9->CB9_QTESEP)
								CB9->(DBDelete())
							EndIf
							CB9->(MsUnlock())
						EndIf
					End Transaction
					nSaldoEmb := 0
				EndIf
			EndDo
		EndIf
	EndIf
Else
	VtAlert(STR0055,STR0008,.t.,4000,3) //"Etiqueta invalida"###"Aviso"
	//-- Permite interação diferente do vtalert
	If ExistBlock("V167VLD")
		ExecBlock("V167VLD",,,{cEProduto,cTipo})
	EndIf
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
EndIf
VTClearGet("cProduto")
nQtde:=1
VTGetRefresh('nQtde')
if !UsaCB0("01") .And. lEstorna .And. lForcaQtd
	VTGEtSetFocus('nQtde')
EndIf
If !lForcaQtd
	VtKeyboard(Chr(20))  // zera o get
Endif
Return ! lEstorna

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ VldVolume³ Autor ³ Anderson Rodrigues    ³ Data ³ 25/11/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Validacao da Geracao do Volume                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static function VldVolume()
Local cCodEmb   := Space(3)
Local cVolImp   := Space(10)
Local lRet      := .t.
Local aRet      := {}
Local aTela     := {}
Private cCodVol := ""

If Empty(cVolume)
	aTela := VTSave()
	VtClear()
	If VtModelo()=="RF" .or. lVT100B // GetMv("MV_RF4X20")
	@ 1,0 VtSay STR0077  //"Digite o codigo do"
	@ 2,0 VtSay STR0078  //"tipo de embalagem"
	If ExistBlock("ACD170EB")
		cRet := ExecBlock("ACD170EB")
		If ValType(cRet)=="C"
			cCodEmb := cRet
		EndIf
	EndIf
	@ 3,0 VTGet cCodEmb pict "@!"  Valid VldEmb(cCodEmb) F3 'CB3'
	VTRead
	Else
		@ 0,0 VtSay STR0078  //"Tipo de embalagem"
		If ExistBlock("ACD170EB")
			cRet := ExecBlock("ACD170EB")
			If ValType(cRet)=="C"
				cCodEmb := cRet
			EndIf
		EndIf
		@ 1,0 VTGet cCodEmb pict "@!"  Valid VldEmb(cCodEmb) F3 'CB3'
		VTRead
	EndIf

	If VTLastkey() == 27
		VtRestore(,,,,aTela)
		VtKeyboard(Chr(20))  // zera o get
		Return .f.
	EndIf
	VtRestore(,,,,aTela)
	If ExistBlock('IMG05') .and. CB5SetImp(cImp,.t.)
		cCodVol := CB6->(GetSX8Num("CB6","CB6_VOLUME"))
		ConfirmSX8()
		VTAlert(STR0079,STR0008,.T.,2000) //"Imprimindo etiqueta de volume "###"Aviso"
		ExecBlock("IMG05",.f.,.f.,{cCodVol,CB7->CB7_PEDIDO,CB7->CB7_NOTA,CB7->CB7_SERIE})
		MSCBCLOSEPRINTER()

		CB6->(RecLock("CB6",.T.))
		CB6->CB6_FILIAL := xFilial("CB6")
		CB6->CB6_VOLUME := cCodVol
		CB6->CB6_PEDIDO := CB7->CB7_PEDIDO
		CB6->CB6_NOTA   := CB7->CB7_NOTA
		//CB6->CB6_SERIE  := CB7->CB7_SERIE
		SerieNfId("CB6",1,"CB6_SERIE",,,,CB7->CB7_SERIE)
		CB6->CB6_TIPVOL := CB3->CB3_CODEMB
		CB6->CB6_STATUS := "1"   // ABERTO
		CB6->(MsUnlock())

	EndIf
	Return .f.
Else

	If ExistBlock("ACD167VO")
		lRet:= ExecBlock("ACD167VO",.F.,.F.,{cVolume})
		If ! lRet
			Return .f.
		EndIf
	EndIf

	If UsaCB0("05")
		aRet:= CBRetEti(cVolume)
		If Empty(aRet)
			VtAlert(STR0055,STR0008,.t.,4000,3) //"Etiqueta invalida"###"Aviso"
			VtKeyboard(Chr(20))  // zera o get
			Return .f.
		EndIf
		cCodVol:= aRet[1]
	Else
		cCodVol:= cVolume
	EndIf
	CB6->(DBSetOrder(1))
	If ! CB6->(DbSeek(xFilial("CB6")+cCodVol))
		VtAlert(STR0053,STR0008,.t.,4000,3)    //"Codigo de volume nao cadastrado"###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .f.
	EndIf
	If CB7->CB7_ORIGEM == "1"
		If ! CB6->CB6_PEDIDO == CB7->CB7_PEDIDO
			VtAlert(STR0080+CB6->CB6_PEDIDO,STR0008,.t.,4000,3)    //"Volume pertence ao pedido "###"Aviso"
			VtKeyboard(Chr(20))  // zera o get
			Return .f.
		EndIf
	ElseIf CB7->CB7_ORIGEM == "2"
		If ! CB6->(CB6_NOTA+CB6_SERIE) == CB7->(CB7_NOTA+CB7_SERIE)
			VtAlert(STR0081+CB6->CB6_NOTA+'-'+SerieNfId("CB6",2,"CB6_SERIE"),STR0008,.t.,4000,3)    //"Volume pertence a nota "###"Aviso"
			VtKeyboard(Chr(20))  // zera o get
			Return .f.
		EndIf
	EndIf
EndIf
cVolume:= CB6->CB6_VOLUME
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ VldEmb   ³ Autor ³ ACD                   ³ Data ³ 03/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Validacao do Tipo de Embalagem                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VldEmb(cEmb)
Local lRet := .T.
If	Empty(cEmb)
	lRet := .F.
Else
	CB3->(DbSetOrder(1))
	If	! CB3->(DbSeek(xFilial("CB3")+cEmb))
		VtAlert(STR0082,STR0008,.t.,4000) //"Embalagem nao cadastrada"###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		lRet := .F.
	EndIf
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ VldCodSep³ Autor ³ ACD                   ³ Data ³ 17/03/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Validacao da Ordem de Separacao                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VldCodSep()
Local lRet

If Empty(cOrdSep)
	VtKeyBoard(chr(23))
	Return .f.
EndIf

CB7->(DbSetOrder(1))
If !CB7->(DbSeek(xFilial("CB7")+cOrdSep))
	VtAlert(STR0083,STR0008,.t.,4000,3) //"Ordem de separacao nao encontrada."###"Aviso"
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
EndIf

If !("02") $ CB7->CB7_TIPEXP
	VtAlert(STR0084,STR0008,.t.,4000,3) //"Ordem de separacao nao configurada para embalagem"###"Aviso"
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
EndIf

If CB7->CB7_STATUS == "0" .OR. CB7->CB7_STATUS == "1"
	VtAlert(STR0085,STR0008,.t.,4000,3) //"Ordem de separacao possui itens nao separados"###"Aviso"
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
EndIf


//0-Inicio;1-Separando;2-Sep.Final;3-Embalando;4-Emb.Final;5-Gera Nota;6-Imp.nota;7-Imp.Vol;8-Embarcado;9-Embarque Finalizado
If "03" $ CB7->CB7_TIPEXP .and. !Empty(CB7->(CB7_NOTA+CB7_SERIE))
	VtAlert(STR0086,STR0008,.t.,4000,3) //"Nota ja gerada para esta Ordem de separacao"###"Aviso"
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
EndIf

If !ACDGet170()
	If CB7->CB7_STATUS == "6"
		VtAlert(STR0087,STR0008,.t.,4000,3)   //"NF ja impressa para esta Ordem de separacao. Exclua primeiramente a NF."###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
	If CB7->CB7_STATUS == "7"
		VtAlert(STR0088,STR0008,.t.,4000,3) //"Etiquetas oficiais de volume ja foram impressas."###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
EndIf

If CB7->CB7_STATUS == "8"
	VtAlert(STR0089,STR0008,.t.,4000,3) //"Ordem de separacao em processo de embarque"###"Aviso"
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
EndIf

If CB7->CB7_STATUS == "9" .And. !("02" $ CBUltExp(CB7->CB7_TIPEXP))
	VtAlert(STR0090,STR0013,.T.) //"Ordem de separacao encerrada"###"Atencao"
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
EndIf

If	ExistBlock("ACD167OS")                
	lRet := ExecBlock("ACD167OS",.F.,.F.,{cOrdSep})
	If ValType(lret) == "L" .and. ! lRet
		Return .f.
	EndIf	
Endif

Return .t.

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} EmbProdIG
Verifica produtos iguais ao realizar a Embalagem

@param: Produto, Quantidade, Valida se é estorno,Volume

@author: André Maximo 
@since:  09/05/2016
/*/
// -------------------------------------------------------------------------------------

Static Function EmbProdIG(cProduto,nQtde,lEstorna,cVolumeEst,cLote,cSLote,cNumSer)

Local aArea    := GetArea()
Local aPedITem := {}
Local nITIguais:= 0
Local lITIguais:= .F.
Local lRet 	 := .F.
Local nY       := 0
Local nX       := 0 

Default cProduto := " "
Default nQtde    := " "
Default lEstorna := " "
Default cVolumeEst:= " "
Default cLote	   := " "
Default cSLote   := " "

CB8->(DbSetorder(1))
CB8->(DBSeek(xFilial("CB8")+cOrdSep))
While CB8->(! EOF() .AND. CB8_FILIAL+CB8_ORDSEP ==;
				xFilial("CB9")+cOrdSep)
		If CB8->CB8_PROD == cProduto
			nITIguais++
			Aadd(aPedITem, {CB8->CB8_ORDSEP,CB8->CB8_PROD,CB8->CB8_PEDIDO,CB8->CB8_ITEM})
		EndIf
		CB8->(DbSkip())
EndDo

If nITIguais > 1 
	For nX := 1 to Len(aPedITem)
		For nY := 1 to Len (aPedITem)
			If (aPedITem[nX][2] == aPedITem[nY][2]) .And. (nX <> nY) .And. (aPedITem[nX][3]<> aPedITem[nY][3])  .And. (aPedITem[nX][4]== aPedITem[nY][4])
			// Produtos iguais, pedidos diferentes e itens iguais 
				lITIguais := .T.
			EndIF			
		Next
	Next
	If lITIguais
		lRet := .T.
	EndIF
EndIF 

RestArea(aArea) 
Return lRet

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} TelPedEmb
Tela de Seleção de Produtos iguais 

@param: 
@author: André Maximo 
@since:  25/05/2016
/*/
// -------------------------------------------------------------------------------------

Static function TelPedEmb(cOrdSep,cProduto,cIten,cSequ)

Local aTela:= VtSave()
Local aFields := {"CB8_PEDIDO","CB8_ITEM","CB8_ORDSEP"}
Local aSize   := {6,2,7,12}
Local aHeader := {'PEDIDO','ITEM','ORD.SEP'} //"Produto"###"Pedido"###"Item"
Local aRet := {}
Local cPed := " "
local cITe := " "
local cORS := " "

Local cTop,cBottom
Local nRecno
IF !Type("lVT100B") == "L"
	Private lVT100B := .F.
EndIf

CB8->(dbSetOrder(1))
cCodOpe:=CB8->(xFilial("CB8")+cOrdSep+cIten+cSequ+cProduto)

If CB8->(dbSeek(cCodOpe))
	nRecno := CB8->(Recno())
	ctop	:= CB8->(xFilial("CB8")+cOrdSep+cIten+cSequ+cProduto)
	cBottom:= CB8->(xFilial("CB8")+cOrdSep+cIten+cSequ+cProduto)
	VtClear()
	If VTModelo()=="RF" .or. lVT100B // GetMv("MV_RF4X20")
		@ 0,0 VTSay STR0093
		@ 1,0 VTSay STR0026 +': '+cProduto 
		@ 2,0 VTSay STR0092
		nRecno := VTDBBrowse(3,0,VTMaxRow(),VTMaxCol(),"CB8",aHeader,aFields,aSize,,"'"+cTop+"'","'"+cBottom+"'")
	Else
		nRecno := VTDBBrowse(0,0,VTMaxRow(),VTMaxCol(),"CB8",aHeader,aFields,aSize,,"'"+cTop+"'","'"+cBottom+"'")
	EndIf
	If VtLastkey() == 27
		VTRestore(,,,,aTela)
		Return
	EndIf
	cPed:=CB8->CB8_PEDIDO
	cITe:=CB8->CB8_ITEM
	cORS:=CB8->CB8_ORDSEP
	Aadd(aRet, {cPed,cITe,cORS})
EndIf

VTRestore(,,,,aTela)

Return aRet

/*/{Protheus.doc} IsEstEmb
	Funcao Responsavel por Verificar a Quantidade de Itens da Ordem de Separacao que ainda não foram Estornados
	@type  Static Function
	@author Paulo V. Beraldo
	@since Jun/2020
	@version 1.00
	@param cC9Fil	, Caracter, Filial da Ordem de Separacao
	@param cC9OrdSep, Caracter, Codigo da Ordem de Separacao
	@param cC9Volum	, Caracter, Codigo do Volume 
	@return lRet	, Boolean , Indica se a Qtde de Itens Vinculados ao Volume é Maior que Zero
/*/
Static Function IsEstEmb( cC9Fil, cC9OrdSep, cC9Volum )
Local lRet		:= .F.
Local cQuery 	:= Nil
Local cTmpAlias	:= GetNextAlias()

cQuery := " SELECT COUNT( CB9.CB9_ORDSEP ) ORDSEP, "
cQuery += " 	( 	SELECT COUNT( XXX.CB9_VOLUME ) VOLUME "
cQuery += " 		FROM "+ RetSQLName( 'CB9' ) +" XXX "
cQuery += " 		WHERE XXX.D_E_L_E_T_ = ' ' "
cQuery += " 			AND XXX.CB9_FILIAL = CB9.CB9_FILIAL "
cQuery += " 			AND XXX.CB9_ORDSEP = CB9.CB9_ORDSEP "
cQuery += " 			AND XXX.CB9_VOLUME = '"+ cC9Volum +"' ) VOLUME "

cQuery += " FROM "+ RetSQLName( 'CB9' ) +" CB9 "
cQuery += " WHERE CB9.D_E_L_E_T_ = '  ' "
cQuery += " 	AND CB9.CB9_FILIAL = '"+ cC9Fil    +"' "
cQuery += " 	AND CB9.CB9_ORDSEP = '"+ cC9OrdSep +"' "

cQuery += " GROUP BY CB9.CB9_FILIAL, CB9.CB9_ORDSEP "
cQuery += " ORDER BY 1 "

dbUseArea( .T., __cRdd, TCGenQry( Nil, Nil, cQuery ), cTmpAlias, .T., .F. )
dbSelectArea( cTmpAlias )
If !( cTmpAlias )->( Eof() )
	lRet := ( ( cTmpAlias )->VOLUME > 0 )
EndIf

IIf( Select( cTmpAlias ) > 0, ( cTmpAlias )->( dbCloseArea() ), Nil )
Return lRet
