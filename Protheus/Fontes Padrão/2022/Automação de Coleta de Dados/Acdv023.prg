#INCLUDE "Acdv023.ch"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'APVT100.CH'

Static n023SldOP := 0

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ ACDV023    ³ Autor ³ Anderson Rodrigues  ³ Data ³ 27/01/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Apontamento Producao PCP Mod1 - Este programa tem por       ³±±
±±³          ³objetivo realizar os apontamentos de Producao/Perda e Hrs   ³±±
±±³          ³improdutivas baseados nas operac alocadas pela Carga Maquina³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAACD                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Function ACDV023()
Local bKey05
Local bKey09
Local cOP      := Space(Len(CBH->CBH_OP))
Local cOperacao:= Space(Len(CBH->CBH_OPERAC))
Local cTransac := Space(Len(CBH->CBH_TRANSA))
Local cRetPe   := ""
Local lContinua:= .T.
Local lVolta := .F.
Local lCB023IOPE   := ExistBlock("CB023IOPE")
Private cOperador  := Space(Len(CB1->CB1_CODOPE))
Private cTM        := GetMV("MV_TMPAD")
Private cProduto   := Space(Len(SC2->C2_PRODUTO))
Private cLocPad    := Space(Len(SC2->C2_LOCAL))
Private cRoteiro   := Space(Len(SH8->H8_ROTEIRO))
Private cUltOper   := Space(Len(CBH->CBH_OPERAC))
Private cPriOper   := Space(Len(CBH->CBH_OPERAC))
Private cTipIni    := "1"
Private cUltApont  := " "
Private cApontAnt  := " "
Private nQTD       := 0
Private nSldOPer   := 0
Private nQtdOP     := 0
Private aOperadores:= {}
Private lConjunto  := .f.
Private lFimIni    := .f.
Private lAutAskUlt := .f.
Private lVldOper   := .f.
Private lRastro    := GetMV("MV_RASTRO")  == "S" // Verifica se utiliza controle de Lote
Private lSGQTDOP   := GetMV("MV_SGQTDOP") == "1" // Sugere quantidade no inicio e no apontamento da producao
Private lInfQeIni  := GetMV("MV_INFQEIN") == "1" // Verifica se deve informar a quantidade no inicio da Operacao
Private lCBAtuemp  := GetMV("MV_CBATUD4") == "1" // Verifica se ajusta o empenho no inicio da producao
Private lVldQtdOP  := GetMV("MV_CBVQEOP") == "1" // Valida no inicio da operacao a quantidade informada com o saldo a produzir da mesma
Private lVldQtdIni := GetMV("MV_CBVLAPI") == "1" // Valida a quantidade do apontamento com a quantidade informada no inicio da Producao
Private lCfUltOper := GetMV("MV_VLDOPER") == "S" // Verifica se tem controle de operacoes
Private lOperador  := GetMV("MV_SOLOPEA",,"2") == "1" // Solicita o codigo do operador no apontamento 1-sim 2-nao (default)
Private lMod1      := .t.
Private lMsHelpAuto:= .f.
Private lMSErroAuto:= .f.
Private lPerdInf   := .F.
IF !Type("lVT100B") == "L"
	Private lVT100B := .F.
EndIf

// -- Verifica se data do Protheus esta diferente da data do sistema.
DLDataAtu()

If IsTelnet()
	cOperador := CBRETOPE()
	If lCB023IOPE
		cRetPe := ExecBlock("CB023IOPE",.F.,.F.,{cOperador})
		If ValType(cRetPe)=="C"
			cOperador := cRetPe
			If ! CBVldOpe(cOperador)
				lContinua := .f.
			EndIf
		EndIf
	EndIf
	If lContinua .And. Empty(cOperador)
		CBAlert(STR0001,STR0002,.T.,3000,2) //"Operador nao cadastrado"###"Aviso"
		lContinua := .f.
	EndIf
	If lContinua .And. (VtModelo() == "RF" .or. lVT100B )
		bKey05 := VTSetKey(05,{|| CB023Encer()},STR0088)   // "Encerrar"
		bKey09 := VTSetKey(09,{|| CB023Hist(cOP)},STR0080) //"Informacoes"
	Endif
Endif

If lContinua .And. Empty(cTM)
	CBAlert(STR0003,STR0002,.T.,3000,2) //"Informe o tipo de movimentacao padrao - MV_TMPAD"###"Aviso"
	lContinua := .f.
EndIf

If lContinua .And. !lRastro .and. lCBAtuemp
	CBAlert(STR0004,STR0002,.T.,4000,2) //"O parametro MV_CBATUD4 so deve ser ativado quando o sistema controlar rastreabilidade"###"Aviso"
	lContinua := .f.
EndIf

If lContinua .And. (lVldQtdOP .or. lVldQtdIni .or. lCBAtuemp) .and. !lInfQeIni
	CBAlert(STR0005,STR0002,.T.,3000,2) //"O parametro MV_INFQEIN deve ser ativado"###"Aviso"
	lContinua := .f.
EndIf

While lContinua
	If lVT100B
		While .T.
			VtClear()
			@ 0,00 VtSay STR0006 //"Producao PCP MOD1"
			If lOperador
				cOperador  := Space(Len(CB1->CB1_CODOPE))
				@ 1,00 VtSay STR0084 VtGet cOperador Valid CBVldOpe(cOperador) //"Operador:"
			EndIf
			@ 2,00 VtSay STR0007 //"OP: "
			@ 2,04 VtGet cOP pict '@!'  Valid CB023OP(cOP) F3 "SH8" When Empty(cOP)
			VTRead

			If VTLastKey() != 27
				lVolta := .F.
				VTClear(1,0,3,19)
				@ 1,00 VtSay STR0008 //"Operacao: "
				@ 1,10 VtGet cOperacao pict '@!' Valid CB023OPERAC(cOP,cOperacao) ;
					when iif(vtRow() == 1 .and. vtLastKey() == 5,(VTKeyBoard(chr(27)),lVolta := .T.),.T.)
				@ 2,00 VtSay STR0009 //"Transacao:"
				@ 2,11 VtGet cTransac pict '@!'  Valid CB023VTran(cOP,cOperacao,cOperador,cTransac) F3 "CBI"
				VtRead
			EndIf

			If lVolta
				Loop
			EndIf

			Exit
		EndDo
	ElseIf IsTelnet() .and. VtModelo() == "RF"
		VtClear()
		@ 0,00 VtSay STR0006 //"Producao PCP MOD1"
		If lOperador
			cOperador  := Space(Len(CB1->CB1_CODOPE))
			@ 1,00 VtSay STR0084 VtGet cOperador Valid CBVldOpe(cOperador) //"Operador:"
		EndIf
		@ 2,00 VtSay STR0007 //"OP: "
		@ 2,04 VtGet cOP pict '@!'  Valid CB023OP(cOP) F3 "SH8" When Empty(cOP)
		@ 4,00 VtSay STR0008 //"Operacao: "
		@ 4,10 VtGet cOperacao pict '@!' Valid CB023OPERAC(cOP,cOperacao)
		@ 7,00 VtSay STR0009 //"Transacao:"
		@ 7,11 VtGet cTransac pict '@!'  Valid CB023VTran(cOP,cOperacao,cOperador,cTransac) F3 "CBI"
		VtRead
		If VtLastKey() == 27
			Exit
		EndIf
	Else
		TerIsQuit()
		If TerProtocolo() == "GRADUAL"
			cOperador:= CB023IOPE() // Solcita o operador para Microterminal com porta paralela
			If TerEsc()
				Loop
			EndIf
		EndIf
		TerCls()
		If VtModelo() == "MT44"
			@ 0,00 TerSay STR0006 //"Producao PCP MOD1"
			@ 1,00 TerSay STR0007 //"OP: "
			@ 1,05 TerGetRead cOP pict "XXXXXXXXXXXXX"  Valid CB023OP(cOP)
			If TerEsc()
				If IsTelnet()
					Exit
				EndIf
				Loop
			EndIf
			@ 0,20 TerSay STR0008 //"Operacao: "
			@ 0,32 TerGetRead cOperacao pict 'XX' Valid CB023OPERAC(cOP,cOperacao)
			TerCls()
			If TerEsc()
				Loop
			EndIf
			@ 0,00 TerSay STR0009 //"Transacao:"
			@ 0,12 TerGetRead cTransac pict 'XX'  Valid CB023VTran(cOP,cOperacao,cOperador,cTransac)
		Else
			@ 0,00 TerSay STR0006 //"Producao PCP MOD1"
			@ 1,00 TerSay STR0007 //"OP: "
			@ 1,05 TerGetRead cOP pict 'XXXXXXXXXXXXX' Valid CB023OP(cOP)
			TerCls()
			If TerEsc()
				If IsTelnet()
					Exit // quando for executa pelo sigaacdt a rotina devera' retornar ao menu
				EndIf
				Loop
			EndIf
			@ 0,00 TerSay STR0008 //"Operacao: "
			@ 0,12 TerGetRead cOperacao pict 'XX' Valid CB023OPERAC(cOP,cOperacao)
			TerCls()
			If TerEsc()
				Loop
			EndIf
			@ 0,00 TerSay STR0009 //"Transacao:"
			@ 0,12 TerGetRead cTransac pict 'XX'  Valid CB023VTran(cOP,cOperacao,cOperador,cTransac)
		Endif
		If TerEsc()
			Loop
		EndIf
	EndIf
	cOP       := Space(Len(CBH->CBH_OP))
	cOperacao := Space(Len(CBH->CBH_OPERAC))
	cTransac  := Space(Len(CBH->CBH_TRANSA))
	cUltOper  := Space(Len(CBH->CBH_OPERAC))
	cPriOper  := Space(Len(CBH->CBH_OPERAC))
	cProduto  := Space(Len(SC2->C2_PRODUTO))
	nQTD      := 0
EndDo
If lContinua
	If IsTelnet() .and. VtModelo() == "RF"
		vtsetkey(05,bKey05)
		vtsetkey(09,bKey09)
	Else
		TerIsQuit()
	EndIf
EndIf
SH8->(DbCloseArea())
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³  CB023OP   ³ Autor ³ Anderson Rodrigues  ³ Data ³ 28/01/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida OP informada pelo usuario                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CB023OP(cOP)
Local lACD023OP := (ExistBlock("ACD023OP"))
IF !Type("lVT100B") == "L"
	Private lVT100B := .F.
EndIf

If Empty(cOP)
	If TerProtocolo() # "PROTHEUS"
		If IsTelnet() .and. (VtModelo() == "RF" .or. lVT100B )
			VTKeyBoard(chr(23))
		Else
			//TerConPad("??") // Pendencia
		EndIf
	EndIf
	Return .f.
EndIf

If TerProtocolo() # "PROTHEUS"
	If IsTelnet() .and. (VtModelo() == "RF" .or. lVT100B)
		VtClearBuffer()
	Else
		TercBuffer()
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se Existe e posiciona o registro             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SC2->(DbSetOrder(1))
If ! SC2->(DbSeek(xFilial("SC2")+cOP))
	CBAlert(STR0010,STR0002,.T.,3000,2,.t.) //"OP nao cadastrada"###"Aviso"
	If TerProtocolo() # "PROTHEUS"
		If IsTelnet() .and. (VtModelo() == "RF" .or. lVT100B)
			VTKeyBoard(chr(20))
		EndIf
	EndIf
	Return .f.
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se OP e do tipo Firme                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If	SC2->C2_TPOP # "F"
	CBAlert(STR0012,STR0002,.T.,3000,2,.t.) //"Nao e permitida movimentacao com OPs Previstas"###"Aviso"
	If	TerProtocolo() # "PROTHEUS"
		If	IsTelnet() .and. (VtModelo() == "RF" .or. lVT100B)
			VTKeyBoard(chr(20))
		EndIf
	EndIf
	Return .f.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se OP ja foi encerrada                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ElseIf !Empty(SC2->C2_DATRF)
	CBAlert(STR0011,STR0002,.T.,3000,2,.t.) //"OP ja Encerrada"###"Aviso"
	If	TerProtocolo() # "PROTHEUS"
		If	IsTelnet() .And. (VtModelo() == "RF" .or. lVT100B)
			VTKeyBoard(chr(20))
		EndIf
	EndIf
	Return .f.
EndIf
cProduto := SC2->C2_PRODUTO
cLocPad  := SC2->C2_LOCAL
nQtdOP   := SC2->C2_QUANT
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se O total produzido para a operacao superou o  ³
//³ total da OP                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lMod1
	SH8->(DbSetOrder(1))
	If ! SH8->(DbSeek(xFilial("SH8")+cOP))
		CBAlert(STR0013,STR0002,.T.,3000,2,.t.) //"OP nao alocada pela ultima Carga Maquina"###"Aviso"
		If TerProtocolo() # "PROTHEUS"
			If IsTelnet() .and. (VtModelo() == "RF" .or. lVT100B)
				VTKeyBoard(chr(20))
			EndIf
		EndIf
		Return .f.
	EndIf
	cRoteiro := SH8->H8_ROTEIRO
Else
	If ! Empty(SC2->C2_ROTEIRO)
		cRoteiro := SC2->C2_ROTEIRO
	Else
		SB1->(DbSetorder(1))
		If SB1->(DbSeek(xFilial('SB1')+cProduto)) .And. !Empty(SB1->B1_OPERPAD)
			cRoteiro := SB1->B1_OPERPAD
		Else
			cRoteiro := StrZero(1, Len(SG2->G2_CODIGO))
		EndIf
	EndIf
EndIf

CBH->(DbSetOrder(2))

lVldOper:= CB023VOPER(cProduto) // Verifica se valida a sequencia de operacoes

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada generico utilizado apos todas as    ³
//³ Validacoes padrao da O.P                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lACD023OP
	If ! ExecBlock("ACD023OP",.F.,.F.)
		cProduto := " "
		cRoteiro := " "
		If TerProtocolo() # "PROTHEUS"
			If IsTelnet() .And. VtModelo() == "RF"
				VTKeyBoard(chr(20))
			EndIf
		EndIf
		Return .f.
	EndIf
EndIf
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³CB023OPERAC ³ Autor ³ Anderson Rodrigues  ³ Data ³ 04/04/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida o get da Operacao                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAACD                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CB023OPERAC(cOP,cOperacao)
Local nRecSG2:= 0
Local cApontMax:=""
Local aOperac:= CB023ArrOp(cProduto,cRoteiro,cOP)
Local nMaxOper 	:= 0
Local l023VOPER := ExistBlock("ACD023VOPER")

IF !Type("lVT100B") == "L"
	Private lVT100B := .F.
EndIf

If Empty(cOperacao)
	If l023VOPER
      cOperacao := ExecBlock("ACD023VOPER",.F.,.F.,{cOP,cRoteiro,cOperacao,cProduto})
      cOperacao := If(ValType(cOperacao)=="C",cOperacao,"")
		If Empty(cOperacao)
		Return .f.
		Endif
	Else
		Return .f.
	Endif
Endif

If TerProtocolo() # "PROTHEUS"
	If lVT100B
		@ 3,00 VtSay Space(20)
	ElseIf IsTelnet() .and. VtModelo() == "RF"
	@ 5,00 VtSay Space(20)
	Else
	If  VtModelo() == "MT44"
		@ 1,20 TerSay Space(20)
	Else
		@ 1,00 TerSay Space(20)
	EndIf
EndIf
EndIf

SG2->(DbSetOrder(1))
If ! SG2->(DbSeek(xFilial("SG2")+cProduto+cRoteiro+cOperacao))
	CBAlert(STR0014,STR0002,.T.,3000,2,.t.) //"Operacao nao encontrada no roteiro "###"Aviso"
	If TerProtocolo() # "PROTHEUS"
		If IsTelnet() .and. VtModelo() == "RF"
			VTKeyBoard(chr(20))
		EndIf
	EndIf
	Return .f.
EndIf

If lMod1
	SH8->(DbSetOrder(1))
	If ! SH8->(DbSeek(xFilial('SH8')+Padr(cOP,Len(SH8->H8_OP))+cOperacao))
		CBAlert(STR0015,STR0002,.T.,3000,2,.t.) //"Operacao nao alocada na ultima Carga Maquina"###"Aviso"
		If TerProtocolo() # "PROTHEUS"
				If IsTelnet() .and. (VtModelo() == "RF" .or. lVT100B )
				VTKeyBoard(chr(20))
			EndIf
		EndIf
		Return .f.
	EndIf
EndIf

nRecSG2  := SG2->(RECNO())
cUltOper := CB023UG2(cProduto,cRoteiro) // Retorna o codigo da ultima operacao do roteiro existente no SG2
cPriOper := CB023PG2(cProduto,cRoteiro) // Retorna o codigo da primeira operacao do roteiro existente no SG2
cUltApont:= CB023UH6(cOP) // Ultima Operacao apontada no SH6
cApontAnt:= CB023AH6(cOP,cOperacao) // Retorna a operacao anterior a atual apontada no SH6
nMaxOper := aScan(aOperac,{|aX| aX==If(!Empty(cUltApont),cUltApont,cPriOper)})+If(!Empty(cUltApont).And.!(cUltOper==cPriOper),1,0)
cApontMax:= aOperac[If(nMaxOper>Len(aOperac),Len(aOperac),nMaxOper)] //retorna a operação maxima que pode ser apontada

If lVldOper .and. cOperacao>cApontMax
	If cOperacao>cApontMax
		CBAlert(STR0017,STR0002,.T.,3000,2,.t.) //"Sequencia de operacao incorreta"###"Aviso"
	EndIf
	If TerProtocolo() # "PROTHEUS"
		If IsTelnet() .and. (VtModelo() == "RF" .or. lVT100B)
			VTKeyBoard(chr(20))
		EndIf
	EndIf
	Return .f.
EndIf

nSldOPer  := CB023Sld(cOP,cProduto,cOperacao) // Retorna o Saldo disponivel considerando a quantidade ja apontada nas operacoes anteriores
n023SldOP := CB023SldOP(cOP,cProduto,cOperacao) // Retorna o saldo restante da OP em relação à Operação

If	CB023PTot(cOP,cProduto,cOperacao,cOperador,.f.)
	CBAlert(STR0016,STR0002,.T.,3000,2,.t.) //"Capacidade da operacao desta OP ja esta totalizada"###"Aviso"
	If	TerProtocolo() # "PROTHEUS"
		If	IsTelnet() .and. (VtModelo() == "RF" .or. lVT100B)
			VTKeyBoard(chr(20))
		EndIf
	EndIf
	Return .f.
EndIf

If TerProtocolo() # "PROTHEUS"
		If IsTelnet() .and. (VtModelo() == "RF" .or. lVT100B )
		VtClearGet("cTransac")
		VtClearBuffer()
	Else
		TerCBuffer()
	EndIf
EndIf

SG2->(DbGoto(nRecSG2))

If TerProtocolo() # "PROTHEUS"
		If lVT100B
			@ 3,00 VtSay Left(SG2->G2_DESCRI,20)
		ElseIf IsTelnet() .and. VtModelo() == "RF"
		@ 5,00 VtSay Left(SG2->G2_DESCRI,20)
	Else
		If  VtModelo() == "MT44"
			@ 1,20 TerSay Left(SG2->G2_DESCRI,20)
		Else
			@ 1,00 TerSay Left(SG2->G2_DESCRI,20)
		EndIf
		TerInkey(0)
		TerCBuffer()
	EndIf
EndIf

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ ChkOperadores ³ Autor ³ Anderson Rodrigues  ³ Data ³ 13/02/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Alimenta o Array aOperadores com os operadores ativos         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ChkOperadores(cOP,cOperacao,cOperador)
Local aTamQtd   := TamSx3("CBH_QTD")
Local cSeek		:= xFilial("CBH")+cOP+cTipIni+cOperacao

CBH->(DbSetOrder(3))
CBH->(DbSeek(cSeek))

While ! CBH->(EOF()) .and. CBH->(CBH_FILIAL+CBH_OP+CBH_TIPO+CBH_OPERAC) == cSeek
	If !Empty(DTOS(CBH->CBH_DTFIM)+CBH->CBH_HRFIM)
	CBH->(DbSkip())
		Loop
	EndIf
	If Alltrim(CBH->CBH_OPERAD) == Alltrim(cOperador)
		aadd(aOperadores,{"X",CBH->CBH_OPERAD,Str(0,aTamQtd[1],aTamQtd[2]),CBH->CBH_DTINI,CBH->CBH_HRINI})
	Else
		aadd(aOperadores,{" ",CBH->CBH_OPERAD,Str(0,aTamQtd[1],aTamQtd[2]),CBH->CBH_DTINI,CBH->CBH_HRINI})
	EndIf
	CBH->(DbSkip())
EndDo
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ CB023Hist  ³ Autor ³ Anderson Rodrigues  ³ Data ³ 04/04/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consulta dos Status de Monitoramento da OP                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CB023Hist(cOP)
Local nX
Local aCab   := {STR0020,STR0021,STR0022,STR0023,STR0024} //"O.P"###"Transacao"###"Descricao"###"Operacao"###"Quantidade"
Local aSize  := {11,09,30,08,12}
Local aStatOP:= {}
Local aSave  := {}
IF !Type("lVT100B") == "L"
	Private lVT100B := .F.
EndIf

	If IsTelnet() .and. (VtModelo() == "RF" .or. lVT100B)
	aSave:= VtSave()
Else
	aSave:= TerSave()
EndIf

If Empty(cOP)
	CBAlert(STR0025,STR0002,.T.,3000,2,.t.) //"Informe a OP !!!"###"Aviso"
	Return .f.
EndIf
aStatOP:= aSort(CBRetMonit(cOP),,,{|x,y| x[1]+x[2]+x[4] < y[1]+y[2]+y[4]})
If Empty(aStatOP)
	Conout(STR0026) //"Erro na tabela CBH"
EndIf
For nX := 1 to Len(aStatOP)
	aSize(aStatOP[nX],5)
Next
If lVT100B
	VtClear()
	VTaBrowse(0,0,3,19,aCab,aStatOP,aSize)
	VtRestore(,,,,aSave)
ElseIf IsTelnet() .and. VtModelo() == "RF"
	VtClear()
	VTaBrowse(0,0,7,19,aCab,aStatOP,aSize)
	VtRestore(,,,,aSave)
Else
	TerCls()
	TeraBrowse(0,0,1,19,aCab,aStatOP,aSize)
	TerRestore(,,,,aSave)
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ CB023VTran ³ Autor ³ Anderson Rodrigues  ³ Data ³ 28/01/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida o get da Transacao do Apontamento da Prod PCP MOD 1 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CB023VTran(cOP,cOperacao,cOperador,cTransac)
Local cTipAtu  := Space(Len(CBH->CBH_TIPO))
Local cDataHora:= (Dtos(dDataBase)+Left(Time(),5))
Local lAchou   := .f.
Local aTela    := {}
Local lACD023TR

IF !Type("lVT100B") == "L"
	Private lVT100B := .F.
EndIf
// -- Verifica se data do Protheus esta diferente da data do sistema.
DLDataAtu()

If TerProtocolo() # "PROTHEUS"
	If IsTelnet() .and. (VtModelo() == "RF" .or. lVT100B)
		aTela:= VtSave()
	Else
		aTela:= TerSave()
	EndIf
EndIf

If Empty(cTransac)
	If TerProtocolo() # "PROTHEUS"
		If IsTelnet() .and. (VtModelo() == "RF" .or. lVT100B)
			VTKeyBoard(chr(23))
		Else
			//TerConPad("??") // Pendencia
		EndIf
	EndIf
	Return .f.
EndIf

aOperadores:= {}
lConjunto  := .f.
lFimIni    := .f.
lAutAskUlt := .f.

CBI->(DbSetOrder(1))
If ! CBI->(DbSeek(xFilial("CBI")+cTransac))
	CBAlert(STR0027,STR0002,.T.,3000,2,.t.) //"Transacao de Monitoramento nao cadastrada"###"Aviso"
	Return .f.
EndIf

If ExistBlock("ACD023TR")
	lACD023TR := ExecBlock('ACD023TR',.F.,.F.,{cOp,cOperacao,cOperador,cTransac})  //Retorno .F. para nao validar a transacao informada
	If ValType(lACD023TR)!= "L"
		lACD023TR := .T.
	EndIf
	If !lACD023TR
		Return .f.
	Endif
EndIf

// Os tipos sao: 1- inicio
//               2- pausa c/
//               3- pausa s/
//               4- producao
//               5- perda

cTipAtu := CBI->CBI_TIPO
CBH->(DbSetOrder(3))
If cTipAtu == "1" //Inicio
	If CBH->(DbSeek(xFilial("CBH")+cOP+cTipIni+cOperacao+cOperador)) .and. (Empty(CBH->CBH_DTFIM) .OR. Empty(CBH->CBH_HRFIM))
		CBAlert(STR0028+cOperador,STR0002,.T.,3000,2,.t.) //"O.P+Operacao ja iniciada pelo Operador "###"Aviso"
		Return .f.
	EndIf
	CB1->(DbSetOrder(1))
	If CB1->(DbSeek(xFilial("CB1")+cOperador)) .and. CB1->CB1_ACAPSM # "1" .and. ! Empty(CB1->CB1_OP+CB1->CB1_OPERAC)
		CBAlert(STR0029,STR0002,.T.,4000,4)  //"Operador sem permissao para executar apontamentos simultaneos"###"Aviso"
		CBAlert(STR0030+CB1->CB1_OPERAC+STR0031+CB1->CB1_OP+STR0032,STR0002,.T.,4000,4,.t.)  //"A operacao "###" da O.P. "###" esta em aberto"###"Aviso"
		Return .f.
	EndIf
	If lVldQtdOP .and. ! CB023Seq(cOperacao,.T.) // --> se a sequencia estiver incorreta e porque nao tem saldo para produzir na operacao
		Return .f.
	EndIf
	If TerProtocolo() # "PROTHEUS"
		If ! GrvInicio(cOP,cOperacao,cOperador,cTransac,cTipAtu)
			If IsTelnet() .and. (VtModelo() == "RF" .or. lVT100B)
				VTKeyBoard(chr(20))
			Else
				TerRestore(,,,,aTela)
			EndIf
			Return .f.
		EndIf
		Return .t.
	EndIf
Else
	If ! CBH->(DbSeek(xFilial("CBH")+cOP+cTipIni+cOperacao+cOperador))
		CBAlert(STR0033+cOperador,STR0002,.T.,3000,2,.t.) //"O.P+Operacao nao iniciada pelo Operador "###"Aviso"
		Return .f.
	Endif
	While CBH->(!EOF()) .and. CBH->(CBH_FILIAL+CBH_OP+CBH_TIPO+CBH_OPERAC+CBH_OPERAD) == xFilial("CBH")+cOP+cTipIni+cOperacao+cOperador
		If ! Empty(DTOS(CBH->CBH_DTFIM)+CBH->CBH_HRFIM)
			CBH->(DbSkip())
			Loop
		Else
			lAchou:= .t.
			Exit
		EndIf
	Enddo
	If !lAchou
		CBAlert(STR0034+cOperador,STR0002,.T.,3000,2,.t.) //"O.P+Operacao nao possui inicio em aberto para o operador "###"Aviso"
		Return .f.
	EndIf
	If TerProtocolo() # "PROTHEUS"
		If ! CB023DTHR(cOP,cOperacao,cOperador,cDataHora) // --> Verifica se a Data e Hora atuais sao validas para permitir a transacao.
			CBAlert(STR0035+cOperador,STR0002,.T.,3000,2,.t.) //"Database + hora atual invalidas para o operador "###"Aviso"
			Return .f.
		EndIf
	EndIf
	If cTipAtu $ "23" // 2 ou 3 pausa
		If ! GrvPausa(cOP,cOperacao,cOperador,cTransac,cTipAtu)
			If TerProtocolo() # "PROTHEUS"
				If IsTelnet() .and. VtModelo() == "RF"
					VTKeyBoard(chr(20))
				EndIf
			EndIf
			Return .f.
		EndIf
	ElseIf cTipAtu $ "45" //--> Producao ou Perda
		If CBI->CBI_TPAPON == "2" // Operacao em conjunto
			lConjunto:= .t.
		EndIf
		If CBI->CBI_FIMINI == "1" // Indica que finaliza o inicio da operacao no ato do apontamento da mesma independente de ter atingido o saldo ou nao
			lFimIni:= .t.
		EndIf
		If !lMod1 .and. CBI->CBI_CFULOP == "1" // No caso de ser PCP MOD2 e nao validar a sequencia de operacoes a transacao confirma o apontamento como ultima operacao
			lAutAskUlt:= .t.
		EndIf
		ChkOperadores(cOP,cOperacao,cOperador)
		If lConjunto .and. Len(aOperadores) < 2
			CBAlert(STR0036,STR0002,.T.,5000,2,.t.) //"Para utilizar o apontamento em conjunto devem ter no minimo dois operadores trabalhando na operacao"###"Aviso"
			aOperadores:= {}
			Return .f.
		EndIf
		If ! GrvPrPd(cOP,cOperacao,cOperador,cTransac,cTipAtu)
			If TerProtocolo() # "PROTHEUS"
				If IsTelnet() .and. VtModelo() == "RF"
					VTKeyBoard(chr(20))
				EndIf
			EndIf
			Return .f.
		EndIf
	EndIf
EndIf
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ CB023GRV   ³ Autor ³ Anderson Rodrigues  ³ Data ³ 04/04/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza gravacao dos arquivos para apontar a Producao      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CB023GRV(cOP,cOperacao,cTransac,cProduto,cRecurso,cOperador,cTipAtu,nQtd,cLote,dValid,dDtIni,cHrIni,dDtFim,cHrFim,lEstorna,aCpsUsu,cParTot,dDtApon)
Local cOP2      := Padr(cOP,Len(SH6->H6_OP))
Local cSeqRotAlt:= Space(Len(SH6->H6_SEQ))
Local cCalend   := ""
Local cH6PT     := ""
Local nTempoPar,nTempoTra
Local nMinutos,nTempo1,nTempo2,cTempo2
Local nOpcao,nOrdem
Local nSldSH6   := CB023SH6(cOP,cProduto,cOperacao)
Local aDadosSH6 := {}
Local aMata680  := {}
Local cMsgErro	:= ""
Local nPosRotOr := 0
Local lEncontrou:= .F.
Local cAliasTmp := ""
Local cQuery    := ""
Default cHrIni  := ""
Default cHrFim  := Left(Time(),5)
Default dDtIni  := CTOD("  /  /    ")
Default dDtFim  := dDataBase
Default lEstorna:= .f.
Default aCpsUsu	:= {}
Default cParTot	:= ""
Default dDtApon := dDataBase

If ! lEstorna
	aDadosSH6:= CB023Dados(cOP,cProduto,cOperacao,cOperador) // --> Retorna array contendo as informacoes do ultimo apontamento no SH6
	If !(Empty(cParTot))
		cH6PT := cParTot
	Else
		If (nSldSH6+nQtd) >= nQtdOP
			cH6PT:= "T"
		Else
			cH6PT:= "P"
		EndIf
	EndIf

	If  TerProtocolo() # "PROTHEUS" // So entra aqui se a rotina de origem nao for Monitoramento (ACDA080)
		If !Empty(aDadosSH6)
			dDtIni:= aDadosSH6[1,4]
			cHrIni:= aDadosSH6[1,5]
		EndIf

		CBH->(DbSetOrder(3))
		If ! CBH->(DbSeek(xFilial("CBH")+cOP+cTipIni+cOperacao+cOperador))
			If Empty(DTOS(dDtIni)+cHrIni)
				CBAlert(STR0037,STR0002,.T.,3000,2) //"OP inconsistente"###"Aviso"
				DisarmTransaction()
				Break
			EndIf
		ElseIf (DTOS(CBH->CBH_DTINI)+CBH->CBH_HRINI) > (DTOS(dDtIni)+cHrIni)
			dDtIni:= CBH->CBH_DTINI
			cHrIni:= CBH->CBH_HRINI
		EndIf
		If dDtIni == dDtFim .and. cHrIni == cHrFim
			cHrFim:= Left(cHrFim,3)+StrZero(Val(Right(cHrFim,2))+1,2)
			If Right(cHrFim,2) == "60"
				cHrFim:= StrZero(Val(Left(cHrFim,2))+1,2)+":00"
				If Left(cHrFim,2)== "24"
					cHrFim:= "00:00"
					dDtFim++
				EndIf
			EndIf
		EndIf
	EndIf
	cCalend := GetMV("MV_CBCALEN") // Parametro onde e informado o calendario padrao que deve ser utilizado
	If Empty(cCalend)
		cCalend := Posicione("SH1",1,xFilial("SH1")+cRecurso,"H1_CALEND")
	EndIf
	nTempoPar := CB023Pausa(cOP,cOperacao,cRecurso,cOperador,dDtIni,cHrIni,dDtFim,cHrFim,lEstorna)
	nTempoTra := IF(SuperGetMV("MV_USACALE",.F.,.T.),PmsHrsItvl(dDtIni,cHrIni,dDtFim,cHrFim,cCalend,"",cRecurso,.T.),A680Tempo(dDtIni,cHrIni,dDtFim,cHrFim))
	nTempo1   := nTempoTra - nTempoPar
	nTempo2   := Int(nTempo1)
	nMinutos  := (nTempo1-nTempo2)*60
	If nMinutos == 60
		nTempo2++
		nMinutos:= 0
	EndIf
	cTempo2:= StrZero(nTempo2,3)+":"+StrZero(nMinutos,2)
	If TerProtocolo() == "VT100" .and. VtModelo() == "RF"
		VtClear()
		VtSay(2,0,STR0039) //"Aguarde..."
	Else
		TerCls()
		TerSay(1,0,STR0039) //"Aguarde..."
	EndIf
EndIf

If lEstorna
	nOrdem:= CBOrdemSix("SH6","ACDSH601") // Retorna a Ordem do Indice para o NickName
EndIf

aadd(aMata680,{"H6_OP", cOP2             ,NIL})
aadd(aMata680,{"H6_PRODUTO", cProduto    ,NIL})
aadd(aMata680,{"H6_OPERAC" , cOperacao   ,NIL})
If lEstorna
	aadd(aMata680,{"H6_SEQ",cSeqRotAlt   ,NIL})
Else
	aadd(aMata680,{"H6_RECURSO",cRecurso ,NIL})
EndIf
aadd(aMata680,{"H6_DATAINI", dDtIni      ,NIL})
aadd(aMata680,{"H6_HORAINI", cHrIni      ,NIL})
aadd(aMata680,{"H6_DATAFIN", dDtFim      ,NIL})
aadd(aMata680,{"H6_HORAFIN", cHrFim      ,NIL})
aadd(aMata680,{"H6_OPERADO", cOperador   ,NIL})
If lEstorna // Passa os campos abaixo somente em caso de inclusao
	aadd(aMata680,{"INDEX",nOrdem         ,NIL}) // Ordem do indice para exclusao
Else
	aadd(aMata680,{"H6_TEMPO"  , cTempo2  ,NIL})
	aadd(aMata680,{"H6_DTAPONT", dDtApon   ,NIL})
	If cTipAtu == "4"
		aadd(aMata680,{"H6_QTDPROD", nQtd ,NIL})
	ElseIf cTipAtu == "5"
		aadd(aMata680,{"H6_QTDPERD" ,nQtd ,NIL})
	Endif
	aadd(aMata680,{"H6_PT"    ,cH6PT      ,NIL})
	aadd(aMata680,{"H6_CBFLAG","1"        ,NIL}) // Flag que indica que foi gerado pelo ACD
EndIf

aadd(aMata680,{"H6_LOCAL",cLocPad     ,NIL})

If Rastro(SC2->C2_PRODUTO)
	aadd(aMata680,{"H6_LOTECTL",cLote      ,Nil})
	aadd(aMata680,{"H6_DTVALID",dValid     ,Nil})
EndIf
lMsHelpAuto := .T.
lMSErroAuto := .F.
nModuloOld  := nModulo
nModulo     := 4
nOpcao      := If(lEstorna,5,3) // Estorno / Inclusao
MsExecAuto({|x,y|MATA680(x,y)},aMata680,nOpcao)
nModulo     := nModuloOld

lMsHelpAuto:=.F.
If lMSErroAuto
	DisarmTransaction()
	//APT PENDENTE
	nPosRotOr := aScan(aMata680,{|x| x[1] == "PENDENTE"}) //Verifica Tag no Apontamento
	IF nPosRotOr > 0 .and. aMata680[nPosRotOr][2] = "2"

		If IsTelNet()
			VTAlert(STR0094, STR0095,.t.,4000,4) //"O parametro MV_APTPEND está configurado,2 - Grava Apontamento se tiver erros,favor refazer o Apontamento pela Rotina de Apontamentos Pendentes PCP138" //"Houveram erros no Apontamento"
		Else
			HELP(' ',1,"ACDA080" ,,STR0095,2,0,,,,,, {STR0094})
		EndIf

		IF FindFunction("ErrosApt")
			cMsgErro	:= ErrosApt()
		EndIF
		IF FindFunction("a250GrvPnd")
			a250GrvPnd(aMata680,"MATA680", cMsgErro)
		EndIf
	EndIf

	Break
EndIf

cQuery := "SELECT count(R_E_C_N_O_) SH6COUNT "
cQuery += "FROM "+RetSqlName("SH6")+" SH6 "
cQuery += "WHERE SH6.H6_FILIAL='"+xFilial("SH6")+"'"
cQuery += " AND SH6.H6_OP='"+cOP+"'"
cQuery += " AND SH6.H6_PRODUTO='"+cProduto+"'"
cQuery += " AND SH6.H6_OPERAC='"+cOperacao+"'"
cQuery += " AND SH6.H6_DATAINI='"+Dtos(dDtIni)+"'"
cQuery += " AND SH6.H6_HORAINI='"+cHrIni+"'"
cQuery += " AND SH6.H6_DATAFIN='"+Dtos(dDtFim)+"'"
cQuery += " AND SH6.H6_HORAFIN='"+cHrFim+"'"
cQuery += " AND SH6.H6_OPERADO='"+cOperador+"'"
cQuery += " AND SH6.D_E_L_E_T_=' ' "
cQuery := ChangeQuery(cQuery)

cAliasTmp := GetNextAlias()

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp)

If (cAliasTmp)->SH6COUNT > 0
	lEncontrou := .T.
EndIf

(cAliasTmp)->(DBCloseArea())

If (!lEstorna .and. !lEncontrou) .OR. (lEstorna .and. lEncontrou)
	DisarmTransaction()
	Break
EndIf

If !lEstorna
	CB023CBH(cOP,cOperacao,cOperador,cTransac,Nil,dDtIni,cHrIni,dDtFim,cHrFim,cTipAtu,"ACDV023",0,nQtd,cRecurso,aCpsUsu,SH6->H6_LOTECTL,SH6->H6_NUMLOTE,SH6->H6_DTVALID,SH6->H6_DTAPONT)
	CB023FIM(cOP,cProduto,cOperacao,cOperador,nQtd,dDtFim,cHrFim)
ElseIf lEstorna
	CB023Pausa(cOP,cOperacao,cRecurso,cOperador,dDtIni,cHrIni,dDtFim,cHrFim,lEstorna)
EndIf

CB023HrImp(cOP,cOperacao,cRecurso,cOperador,dDtIni,cHrIni,dDtFim,cHrFim,lEstorna)

If !lEstorna
	If ExistBlock("ACD023GR") // Executado apos a gravacao do apontamento da producao
		ExecBlock("ACD023GR",.F.,.F.,{cOp,cOperacao,cRecurso,cOperador,nQtd})
	EndIf
EndIf

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ CB023CBH ³ Autor ³ Anderson Rodrigues  ³ Data ³ 28/01/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza gravacao do monitoramento da producao (CBH)      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function CB023CBH(cOP,cOperacao,cOperador,cTransac,nRecno,dDtIni,cHrIni,dDtFim,cHrFim,cTipAtu,cRotina,nQePrev,nQeApont,cRecurso,aCpsUsu,cLote,cNumLote,dValid,dDtApon)
Local aDadosSH6 := {}
Local nX		:= 0
Local lPfmv	:=ExistBlock("AC023FMV")
Default dDtFim  := CTOD(" ")
Default cHrFim  := " "
Default cRecurso:= " "
Default nRecno  := 0
Default nQePrev := 0
Default nQeApont:= 0
Default aCpsUsu := {}
Default dValid  := ctod('')
Default cLote   := Space(TamSX3("B8_LOTECTL")[1])
Default cNumLote:= Space(TamSX3("B8_NUMLOTE")[1])
Default dDtApon := dDataBase
If cTipAtu == "1" // Inicio de Transacao
	aDadosSH6:= CB023Dados(cOP,cProduto,cOperacao,cOperador) // --> Retorna array contendo as informacoes do ultimo apontamento no SH6
Endif

If ! Empty(aDadosSH6)
	If (DTOS(aDadosSH6[1,4])+aDadosSH6[1,5]) > (DTOS(dDtIni)+cHrIni)
		dDtIni:= aDadosSH6[1,4]
		cHrIni:= aDadosSH6[1,5]
	EndIf
EndIf

If Empty(nRecno) // Inclusao de todas as transacoes, ou seja, Inicio, Pausa e Apontamentos
	RecLock("CBH",.T.)
	CBH->CBH_FILIAL := xFilial("CBH")
	CBH->CBH_OPERAD := cOperador
	CBH->CBH_OP     := cOP
	CBH->CBH_TRANSA := cTransac
	CBH->CBH_TIPO   := cTipAtu
	CBH->CBH_QEPREV := nQePrev
	CBH->CBH_QTD    := nQeApont
	CBH->CBH_DTINI  := dDtIni
	CBH->CBH_DTINV  := Inverte(dDtIni)
	CBH->CBH_HRINI  := cHrIni
	CBH->CBH_HRINV  := Inverte(cHrIni)
	CBH->CBH_DTFIM  := dDtFim
	CBH->CBH_HRFIM  := cHrFim
	If CBH->(ColumnPos("CBH_DTAPON")) > 0 // Proteção para release 12.1.23
		CBH->CBH_DTAPON := dDtApon
	EndIF
	CBH->CBH_OPERAC := cOperacao
	CBH->CBH_HRIMAP := " "
	CBH->CBH_LOTCTL := cLote
	CBH->CBH_NUMLOT := cNumLote
	CBH->CBH_DVALID := dValid
	If ! Empty(cRecurso)
		CBH->CBH_RECUR:= cRecurso
	EndIf
	If lMod1
		CBH->CBH_OBS:= STR0040+DTOS(dDataBase)+" "+cRotina //"Incluido em "
	Else
		cRotina :="ACDV025"
		CBH->CBH_OBS:= STR0040+DTOS(dDataBase)+" "+cRotina //"Incluido em "
	EndIf
	For nX := 1 to Len(aCpsUsu)
		&("CBH->"+aCpsUsu[nX]) := &("M->"+aCpsUsu[nX])
	Next nX
	CBH->(MsUnlock())
Else // Finalizacao das Pausas ou Finalizacao do inicio
	CBH->(DbGoTo(nRecno))
	If CBH->CBH_DTINI == dDtFim .and. CBH->CBH_HRINI == cHrFim
		cHrFim:= Left(cHrFim,3)+StrZero(Val(Right(cHrFim,2))+1,2)
		If Right(cHrFim,2) == "60"
			cHrFim:= StrZero(Val(Left(cHrFim,2))+1,2)+":00"
			If Left(cHrFim,2)== "24"
				cHrFim:= "00:00"
				dDtFim++
			EndIf
		EndIf
	EndIf
	RecLock("CBH",.F.)
	CBH->CBH_DTFIM  := dDtFim
	CBH->CBH_HRFIM  := cHrFim
	CBH->CBH_QTD    += nQeApont
	For nX := 1 to Len(aCpsUsu)
		&("CBH->"+aCpsUsu[nX]) := &("M->"+aCpsUsu[nX])
	Next nX
	CBH->(MsUnlock())
EndIf
CB023CB1(cOP,cOperacao,cOperador,cTipAtu,cTransac,dDtFim)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada utilizado para executar uma rotina apos     ³
//³ a gravacao das movimentacoes na tabela CBH                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lPfmv
	ExecBlock("AC023FMV",.F.,.F.)
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ CB023Pausa ³ Autor ³ Anderson Rodrigues  ³ Data ³ 28/01/04  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se existe Horas com Pausa tipo 2 e 3 calcula as    ³±±
±±³          ³ mesmas e retorna o total                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function CB023Pausa(cOP,cOperacao,cRecurso,cOperador,dDtIni,cHrIni,dDtFim,cHrFim,lEstorna)
Local nHrsPausa := 0
Local nTotPausa := 0
Local nX        := 0
Local aRecnos   := {}
Local cCalend		:= GetMV("MV_CBCALEN") // Parametro onde e informado o calendario padrao que deve ser utilizado
Local lUsaCale	:=	SuperGetMV("MV_USACALE",.F.,.T.)
Local cSeek 	:= xFilial("CBH")+cOP+cOperacao+cOperador
Default lEstorna:= .f.

CBH->(DBSetOrder(5))
CBH->(DBGoTop())
If ! CBH->(DBSeek(cSeek))
	Return(nTotPausa)
EndIf

While ! CBH->(EOF()) .and. CBH->(CBH_FILIAL+CBH_OP+CBH_OPERAC+CBH_OPERAD) == cSeek
	If CBH->CBH_TIPO $ "145" // Se nao for Pausa desconsidera
		CBH->(DbSkip())
		Loop
	EndIf
	If Empty(CBH->CBH_OPERAC)
		If !lEstorna
			CBAlert(STR0041+CBH->(Recno()),STR0002,.T.,3000,2,Nil) //"Operacao nao informada para o registro "###"Aviso"
		EndIf
		Return
	EndIf
	If (DTOS(CBH->CBH_DTINI)+CBH->CBH_HRINI < DTOS(dDtIni)+cHrIni)
		CBH->(DBSkip()) // indica que esta fora do range de pausas
		Loop
	EndIf
	If (DTOS(CBH->CBH_DTFIM)+CBH->CBH_HRFIM > DTOS(dDtFim)+cHrFim)
		CBH->(DBSkip()) // indica que esta fora do range de pausas
		Loop
	EndIf
	If lEstorna
		If Empty(CBH->CBH_HRIMAP)
			CBH->( DBSkip() )
			Loop
		EndIf
	Else
		If ! Empty(CBH->CBH_HRIMAP)
			CBH->( DBSkip() )
			Loop
		Endif
		If Empty(CBH->CBH_DTFIM)
			CBH->( DBSkip() )
			Loop
		EndIf
	EndIf
	If Empty(cCalend)
		cCalend:= Posicione("SH1",1,xFilial("SH1")+cRecurso,"H1_CALEND")
	EndIf
	nHrsPausa:= IF(lUsaCale,CBH->(PmsHrsItvl(CBH_DTINI,CBH_HRINI,CBH_DTFIM,CBH_HRFIM,cCalend,"",cRecurso,.T.)),CBH->(A680Tempo(CBH_DTINI,CBH_HRINI,CBH_DTFIM,CBH_HRFIM)))
	nTotPausa += nHrsPausa
	If CBH->CBH_TIPO == "3" // aqui deve guardar para flegar somente o tipo 3, pois o Tipo 2 deve ser flegado somente no apontamento de horas improdutivas
		aadd(aRecnos,CBH->(Recno()))
	EndIf
	CBH->(DBSkip())
EndDo
If !Empty(aRecnos)
	For nX := 1 to Len(aRecnos)
		CBH->(DbGoTo(aRecnos[nX]))
		RecLock("CBH",.F.)
		If lEstorna
			CBH->CBH_HRIMAP := " "
		Else
			CBH->CBH_HRIMAP := "1"
		EndIf
		CBH->(MsUnlock())
	Next
EndIf
Return(nTotPausa)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ CB023HrImp ³ Autor ³ Anderson Rodrigues  ³ Data ³ 28/01/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se existe Horas improdutivas para serem gravadas  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function CB023HrImp(cOP,cOperacao,cRecurso,cOperador,dDataDe,cHoraDe,dDataAte,cHoraAte,lEstorna)
Local lHrImp,lInicio
Local dDtini,dData1,dData2
Local cHrini,cHora1,cHora2
Local nHrsImp,nTotHrImp1,cTotHrImp2
Local cTransac
Local cTipo
Local nRecCBH,nX,nMinutos
Local aRecnos  := {}
Local cCalend   := GetMV("MV_CBCALEN") // Parametro onde e informado o calendario padrao que deve ser utilizado
Local lUsaCale	:= SuperGetMV("MV_USACALE",.F.,.T.)
Local cSeek
Default lEstorna:= .f.

cTipo 	:= "2" // -> Totaliza todas as pausas do tipo 2 para realizar o apontamento das horas improdutivas.
nTotHrImp1 := 0

cSeek	:= xFilial("CBH")+cOP+cTipo+cOperacao

CBH->(DBSetOrder(3))
If ! CBH->(DBSeek(cSeek+cOperador))
	Return
EndIf

While ! CBH->(EOF()) .and. CBH->(CBH_FILIAL+CBH_OP+CBH_TIPO+CBH_OPERAC+CBH_OPERAD) == cSeek + cOperador
	lHrImp  := .f.
	lInicio := .t.
	cTransac:= CBH->CBH_TRANSA
	While ! CBH->(EOF()) .and. CBH->(CBH_FILIAL+CBH_OP+CBH_TIPO+CBH_OPERAC+CBH_TRANSA) == cSeek + cTransac
		If lEstorna
			If Empty(CBH->CBH_OPERAC)
				MsgAlert(STR0041+CBH->(Recno())) //"Operacao nao informada para o registro "
				Return
			EndIf
		Else
			If Empty(CBH->CBH_OPERAC)
				CBAlert(STR0041+CBH->(Recno()),STR0002,.T.,3000,2,Nil) //"Operacao nao informada para o registro "###"Aviso"
				Return
			EndIf
		EndIf
		If (DTOS(CBH->CBH_DTINI)+CBH->CBH_HRINI < DTOS(dDataDe)+cHoraDe)
			CBH->(DBSkip()) // indica que esta fora do range para o apontamento das horas improdutivas
			Loop
		Endif
		If (DTOS(CBH->CBH_DTFIM)+CBH->CBH_HRFIM > DTOS(dDataAte)+cHoraAte)
			CBH->(DBSkip()) // indica que esta fora do range para o apontamento das horas improdutivas
			Loop
		EndIf
		If lEstorna
			If Empty(CBH->CBH_HRIMAP)
				CBH->( DBSkip() )
				Loop
			EndIf
		Else
			If ! Empty(CBH->CBH_HRIMAP)
				CBH->(DBSkip())
				Loop
			EndIf
			If Empty(CBH->CBH_DTFIM)
				CBH->(DBSkip())
				Loop
			EndIf
		EndIf
		If lInicio
			lInicio:= .f.
			lHrImp := .t.
			dDtini := CBH->CBH_DTINI
			cHrini := CBH->CBH_HRINI
		EndIf
		dDtini    := If(CBH->CBH_DTINI < dDtini,CBH->CBH_DTINI,dDtini)
		cHrini    := If(CBH->CBH_HRINI < cHrini,CBH->CBH_HRINI,cHrini)
		dData1    := CBH->CBH_DTINI
		cHora1    := CBH->CBH_HRINI
		dData2    := CBH->CBH_DTFIM
		cHora2    := CBH->CBH_HRFIM
		If Empty(cCalend)
			cCalend:= Posicione("SH1",1,xFilial("SH1")+cRecurso,"H1_CALEND")
		EndIf
		nHrsImp   := IF(lUsaCale,PmsHrsItvl(dData1,cHora1,dData2,cHora2,cCalend,"",cRecurso,.T.),A680Tempo(dData1,cHora1,dData2,cHora2))
		nTotHrImp1:= nTotHrImp1 + nHrsImp
		aadd(aRecnos,CBH->(Recno()))
		CBH->(DBSkip())
		nRecCBH   := CBH->(Recno())
	EndDo
	If lHrImp
	   If !Empty(nTotHrImp1)
			nMinutos  := (nTotHrImp1-Int(nTotHrImp1))*60
			cTotHrImp2:= StrZero(Int(nTotHrImp1),3)+":"+StrZero(nMinutos,2)
			GravaHrImp(cOP,cOperacao,cRecurso,dDtini,cHrini,dData2,cHora2,cTotHrImp2,cTransac,cOperador,lEstorna)
		EndIf
		dData1  := CTOD(" ")
		cHora1  := " "
		dData2  := CTOD(" ")
		cHora2  := " "
		DbGoTo(nRecCBH)
	Else
		CBH->(DBSkip())
	Endif
Enddo
If !Empty(aRecnos)
	For nX := 1 to Len(aRecnos)
		CBH->(DbGoTo(aRecnos[nX]))
		RecLock("CBH",.F.)
		If lEstorna
			CBH->CBH_HRIMAP := " "
		Else
			CBH->CBH_HRIMAP := "1"
		EndIf
		CBH->(MsUnlock())
	Next
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ CB023PTot  ³ Autor ³ Anderson Rodrigues    ³ Data ³ 28/01/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se a Producao para a Operacao ja foi totalizada     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAACD                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CB023PTot(cOP,cProduto,cOperacao,cOperad2,lAponta)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ MV_GANHOPR - Parametro utilizado para verificar se NAO permite o conceito   ³
//|              de "Ganho de Producao" na inclusao do apontamento de Producao. |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lGanhoProd:= SuperGetMV("MV_GANHOPR",.F.,.T.)
Local lPergGanho:= SuperGetMv("MV_CBPERGA",.F.,.T.)
Local nPos      := 0
Default lAponta := .t.

If lFimIni .And. lAponta
	CBH->(DbSetOrder(3))
	If ! CBH->(DbSeek(xFilial("CBH")+cOP+cTipIni+cOperacao+cOperad2)) .or. ! Empty(DTOS(CBH->CBH_DTFIM)+CBH->CBH_HRFIM)
		Return .f.
	Else
		If cOperador == cOperad2
			Return .t.
		EndIf
		nSldOPer:= CB023Sld(cOP,cProduto,cOperacao) // Retorna o Saldo disponivel considerando a quantidade ja apontada nas operacoes anteriores
		If nSldOPer <= 0
			Return .t.
		Else
			Return .f.
		EndIf
	EndIf
EndIf

If lAponta // Se ja apontou atualiza o saldo disponivel
	nSldOPer:= CB023Sld(cOP,cProduto,cOperacao) // Retorna o Saldo disponivel considerando a quantidade ja apontada nas operacoes anteriores
Endif

If nSldOPer <= 0 .And. CB023UH6(cOP,"H6_PT") $ " T"
	If	lGanhoProd
		If	lAponta
			Return .f.
		ElseIf lPergGanho
			CBAlert(STR0016,STR0002,.T.,3000,2,.t.) //"Capacidade da operacao desta OP ja esta totalizada"###"Aviso"
			If VTYesNo(STR0090,STR0002,.T.) // "Continua apontamento da producao?" ### "Aviso"
				Return .f.
			EndIf
		EndIf
	EndIf
	Return .t.
EndIf

If C023OPRTOT(cOP,cProduto,cOperacao)
	Return .T.
EndIf

If lInfQeIni .And. lAponta
	CBH->(DbSetOrder(3))
	If ! CBH->(DbSeek(xFilial("CBH")+cOP+cTipIni+cOperacao+cOperad2)) .or. ! Empty(DTOS(CBH->CBH_DTFIM)+CBH->CBH_HRFIM)
		Return .f.
	ElseIf (CBH->CBH_QTD > 0 .and. CBH->CBH_QTD >= CBH->CBH_QEPREV)
		Return .t.
	ElseIf lConjunto
		nPos:= Ascan(aOperadores,{|x| x[2] == cOperad2})
		If nPos > 0 .and. ! Empty(aOperadores[nPos,1]) .and. (CBH->CBH_QTD == 0 .and. CBH->CBH_QEPREV == 0)
			Return .t.
		EndIf
	ElseIf (CBH->CBH_QTD == 0 .and. CBH->CBH_QEPREV == 0 .and. CBH->CBH_OPERAD == cOperador) // aqui verifica o operador que esta logado
		Return .t.
	EndIf
EndIf
Return .f.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ C023OPRTOT   ³ Autor ³ SQUAD Entradas    ³ Data ³ 25/09/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se a Operação da OP já foi totalizada na SH6      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function C023OPRTOT(cOP,cProduto,cOperacao)

	Local lProdTotal := .F.

	SH6->(DbSetOrder(1))
	If SH6->(dbSeek(xFilial("SH6") + cOP + cProduto + cOperacao))
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verificar se ja existe Producao TOTAL para a OP.              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		While !SH6->(Eof()) .And. SH6->H6_FILIAL + SH6->H6_OP + SH6->H6_OPERAC == xFilial("SH6") + cOP + cOperacao
			If SH6->H6_PT == "T"
				lProdTotal := .T.
			EndIf
			SH6->(dbSKip())
		End
	EndIf

Return lProdTotal

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ CB023UG2   ³ Autor ³ Anderson Rodrigues  ³ Data ³ 28/01/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna a ultima operacao do roteiro de operacoes - SG2    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function CB023UG2(cProduto,cRoteiro)
Local cOperac:= " "
Local cSeek 	:= xFilial("SG2")+cProduto+cRoteiro

SG2->(DbSetOrder(1))
If SG2->(DbSeek(cSeek))
	While ! SG2->(Eof()) .and. SG2->(G2_FILIAL+G2_PRODUTO+G2_CODIGO) == cSeek
		cOperac := SG2->G2_OPERAC
		SG2->(DbSkip())
	Enddo
EndIf
Return cOperac

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ CB023UH6   ³ Autor ³ Anderson Rodrigues  ³ Data ³ 11/02/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna a ultima operacao apontada no SH6                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function CB023UH6(cOP,cCampo)
Local cUltOperSH6:= " "

Default cCampo := "H6_OPERAC"

SH6->(DbSetOrder(1))
If ! SH6->(DbSeek(xFilial("SH6")+PadR(cOP,Len(SH6->H6_OP))))
	Return(cUltOperSH6)
EndIf
While ! SH6->(EOF()) .and. SH6->H6_OP == cOP
	cUltOperSH6:= &("SH6->"+cCampo)
	SH6->(DbSkip())
Enddo
Return(cUltOperSH6)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ CB023AH6   ³ Autor ³ Anderson Rodrigues  ³ Data ³ 11/02/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorno  o codigo da operacao do apontamento anterior ao   ³±±
±±³          ³ atual informado no get                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CB023AH6(cOP,cOperacao)
Local cOpeAnt:= ""

SH6->(DbSetOrder(1))
If ! SH6->(DbSeek(xFilial("SH6")+cOP+cProduto+cOperacao)) .or. cOperacao == "01"
	If cUltApont == "01" .and. cOperacao # "02"
		Return(cOpeAnt)
	Else
		Return(cUltApont) // Se nao existir a operacao atual retorna a ultima apontada
	EndIf
EndIf
While ! SH6->(BOF()) .and. SH6->H6_OP == cOP
	If SH6->H6_OPERAC == cOperacao
		SH6->(DbSkip(-1))
	Else
		cOpeAnt:= SH6->H6_OPERAC
		Exit
	EndIf
Enddo
Return(cOpeAnt)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ CB023Sld   ³ Autor ³ Anderson Rodrigues  ³ Data ³ 28/01/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna o saldo para validacao da qtd do apontamento       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CB023Sld(cOP,cProduto,cOperacao)
Local cOper2SH6
Local nQtd1SH6   := 0
Local nQtd2SH6   := 0
Local nRecSH6    := 0
Local nSaldo     := 0
Local nRecSH6Atu := SH6->(Recno())
Local nSldOperAnt := 0
Local cSeek		:= xFilial("SH6")+cOP+cProduto
Local cQuery	:= ''

Local lPerdInf := SuperGetMV("MV_PERDINF",.F.,.F.)

SH6->(DbSetOrder(1))

If ! SH6->(DbSeek(cSeek+cOperacao))
	If Empty(cApontAnt) .or. ! SH6->(DbSeek(cSeek+cApontAnt))
		nSaldo:= (nQtdOP - nSaldo) // Saldo disponivel considerando a quantidade ja apontada
		SH6->(DbGoTo(nRecSH6Atu))
		Return(nSaldo)
	EndIf
	While ! SH6->(EOF()) .and. SH6->(H6_FILIAL+H6_OP+H6_PRODUTO+H6_OPERAC) == cSeek+cApontAnt
		nSaldo+= SH6->H6_QTDPROD + SH6->H6_QTMAIOR + Iif(!lPerdInf, SH6->H6_QTDPERD, 0)
		SH6->(DbSkip())
	Enddo
	SH6->(DbGoTo(nRecSH6Atu))
	Return(nSaldo)
EndIf
//calcula saldo da operacao anterior
cQuery := ""
cQuery += "SELECT SUM(H6_QTDPROD) AS QTDPROD, "
cQuery += "       SUM(H6_QTMAIOR) AS QTMAIOR "
If !lPerdInf
	cQuery += " , SUM(H6_QTDPERD) AS QTDPERD "
EndIf
cQuery += "FROM " + RetSQLName("SH6") + " SH6 "
cQuery += "WHERE H6_FILIAL = '" + xFilial("SH6") + "' "
cQuery += "AND H6_OP = '"       + cOP + "' "
cQuery += "AND H6_PRODUTO = '"  + cProduto + "' "
cQuery += "AND H6_OPERAC = '"   + cApontAnt + "' "
cQuery += "AND D_E_L_E_T_ = ' ' "

cTmp := GetNextAlias()

cQuery := ChangeQuery(cQuery)
dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cTmp, .T., .F. )
nSldOperAnt := (cTmp)->QTDPROD
nSldOperAnt += (cTmp)->QTMAIOR
If !lPerdInf
	nSldOperAnt += (cTmp)->QTDPERD
EndIf
(cTmp)->(dbCloseArea())

cQuery := ""
cQuery += "SELECT SUM(H6_QTDPROD) AS QTDPROD, "
cQuery += "       SUM(H6_QTMAIOR) AS QTMAIOR "
If !lPerdInf
	cQuery += " , SUM(H6_QTDPERD) AS QTDPERD "
EndIf
cQuery += "FROM " + RetSQLName("SH6") + " SH6 "
cQuery += "WHERE H6_FILIAL = '" + xFilial("SH6") + "' "
cQuery += "AND H6_OP = '"       + cOP + "' "
cQuery += "AND H6_PRODUTO = '"  + cProduto + "' "
cQuery += "AND H6_OPERAC = '"   + cOperacao + "' "
cQuery += "AND D_E_L_E_T_ = ' ' "

cTmp := GetNextAlias()

cQuery := ChangeQuery( cQuery )
dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cTmp, .T., .F. )
nQtd1SH6 := (cTmp)->QTDPROD
nQtd1SH6 += (cTmp)->QTMAIOR
If !lPerdInf
	nQtd1SH6 += (cTmp)->QTDPERD
EndIf
(cTmp)->(dbCloseArea())

If nQtd1SH6 >= If(Empty(cApontAnt) .Or. cOperacao == cPriOper ,nQtdOP,nSldOperAnt)
	nSaldo := 0
	SH6->(DbGoTo(nRecSH6Atu))
	Return(nSaldo)
EndIf

nSaldo:= (nQtdOP-nQtd1SH6) // Neste caso o Saldo disponivel e o total da OP

If SH6->(DbSeek(cSeek+cOperacao))
	nRecSH6 := SH6->(Recno())
	SH6->(DbSkip(-1))
	If SH6->(H6_FILIAL+H6_OP+H6_PRODUTO) == cSeek .And. SH6->(Recno()) <> nRecSH6
		cOper2SH6:= SH6->H6_OPERAC
		cQuery := ""
		cQuery += "SELECT SUM(H6_QTDPROD) AS QTDPROD "
		cQuery += "FROM " + RetSQLName("SH6") + " SH6 "
		cQuery += "WHERE H6_FILIAL = '" + xFilial("SH6") + "' "
		cQuery += "AND H6_OP = '"       + cOP + "' "
		cQuery += "AND H6_PRODUTO = '"  + cProduto + "' "
		cQuery += "AND H6_OPERAC = '"   + cOper2SH6 + "' "
		cQuery += "AND D_E_L_E_T_ = ' ' "
		cTmp := GetNextAlias()

		cQuery := ChangeQuery( cQuery )
		dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cTmp, .T., .F. )
		nQtd2SH6 := (cTmp)->QTDPROD
		(cTmp)->(dbCloseArea())
		nSaldo:= (nQtd2SH6-nQtd1SH6)
	Endif
Endif
If nSaldo < 0
	nSaldo:= 0
Endif
SH6->(DbGoTo(nRecSH6Atu))
Return(nSaldo)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ CB023SldOP ³ Autor ³ SQUAD Entradas      ³ Data ³ 30/09/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna o saldo restante de uma OP para uma Operação       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CB023SldOP(cOP,cProduto,cOperacao)

	Local cQuery	:= ""
	Local cAlias    := ""

	Local nQtd1SH6  := 0

	Local lPerdInf  := SuperGetMV("MV_PERDINF",.F.,.F.)

	cQuery += "SELECT SUM(H6_QTDPROD) AS QTDPROD, "
	cQuery += "       SUM(H6_QTMAIOR) AS QTMAIOR "
	If !lPerdInf
		cQuery += " , SUM(H6_QTDPERD) AS QTDPERD "
	EndIf
	cQuery += "FROM " + RetSQLName("SH6") + " SH6 "
	cQuery += "WHERE H6_FILIAL = '" + xFilial("SH6") + "' "
	cQuery += "AND H6_OP = '"       + cOP + "' "
	cQuery += "AND H6_PRODUTO = '"  + cProduto + "' "
	cQuery += "AND H6_OPERAC = '"   + cOperacao + "' "
	cQuery += "AND D_E_L_E_T_ = ' ' "
	cAlias := GetNextAlias()

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cAlias, .T., .F. )
	nQtd1SH6 := (cAlias)->QTDPROD
	nQtd1SH6 += (cAlias)->QTMAIOR
	If !lPerdInf
		nQtd1SH6 += (cAlias)->QTDPERD
	EndIf
	(cAlias)->(dbCloseArea())

Return (nQtdOP-nQtd1SH6)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ CB023SH6   ³ Autor ³ Anderson Rodrigues  ³ Data ³ 10/02/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna quantidade que ja foi apontada para a operacao     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CB023SH6(cOP,cProduto,cOperacao)
Local nQtdSH6:= 0
Local cSeek

SH6->(DbSetOrder(1))

cSeek := xFilial("SH6")+cOP+cProduto+cOperacao

If ! SH6->(DbSeek(cSeek))
	Return(nQtdSH6)
EndIf

While ! SH6->(EOF()) .and. SH6->(H6_FILIAL+H6_OP+H6_PRODUTO+H6_OPERAC) == cSeek
	nQtdSH6 := nQtdSH6+(SH6->H6_QTDPROD+SH6->H6_QTDPERD)
	SH6->(DbSkip())
Enddo
Return(nQtdSH6)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³  CB023AUX  ³ Autor ³ Anderson Rodrigues  ³ Data ³ 12/02/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao auxiliar chamada pela Funcao GrvConjunto()          ³±±
±±³          ³ Marcacao dos operadores que devem ter apontamento feito    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CB023AUX(modo,nElem,nElemW)

If modo == 1
Elseif Modo == 2
Else
	If VTLastkey() == 27
		Return 0
	ElseIf VTLastkey() == 13
		If aOperadores[nElem,1] == " "
			CBH->(DbSetOrder(3))
			CBH->(DbSeek(xFilial("CBH")+cOP+"2"+cOperacao+aOperadores[nElem,2],.t.))
			While ! CBH->(EOF()) .and. CBH->(CBH_FILIAL+CBH_OP) == xFilial("CBH")+cOP
			   If CBH->CBH_OPERAD # aOperadores[nElem,2]
					CBH->(DbSkip())
					Loop
				EndIf
				If CBH->CBH_OPERAC == cOperacao .and. CBH->CBH_TIPO $ "23" .and. Empty(CBH->CBH_DTFIM)
					CBAlert(STR0042,STR0002,.T.,3000,2) //"Operacao em pausa para o operador, Verifique !!!"###"Aviso"
					Return 2
				EndIf
				CBH->(DbSkip())
			Enddo
			aOperadores[nElem,1] :="X" // Se passou pela validacao pode selecionar
		Else
			If aOperadores[nElem,2] # cOperador
				aOperadores[nElem,1] := " "
			EndIf
		EndIf
		If IsTelnet() .and. VtModelo() == "RF"
			VTaBrwRefresh()
    	Else
			TeraBrwRefresh()
		EndIf
		Return 2
	EndIf
EndIf
Return 2

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ CB023Rec   ³ Autor ³ Anderson Rodrigues  ³ Data ³ 28/01/04   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida se o Recurso informado existe no roteiro de operacoes ³±±
±±³          ³	Obs: Funcao utilizada no RF, Microterminal e Protheus       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CB023Rec(cOP,cOperacao,cRecurso,cTipo)
Local nACD023QE:= 0
Local aTela    := {}
Local lRet     := .t.
Local l023RC := ExistBlock("ACD023RC")

IF !Type("lVT100B") == "L"
	Private lVT100B := .F.
EndIf

If Empty(cRecurso)
	If TerProtocolo() # "PROTHEUS"
		If IsTelnet() .and. (VtModelo() == "RF" .or. lVT100B)
			VTKeyBoard(chr(23))
		Else
			//TerConPad("??") // Pendencia
		EndIf
	EndIf
	Return .f.
EndIf

If TerProtocolo() # "PROTHEUS"
	If IsTelnet() .and. (VtModelo() == "RF" .or. lVT100B)
		aTela:= VtSave()
	Else
		aTela:= TerSave()
	EndIf
EndIf

SH1->(DbSetOrder(1))
If ! SH1->(DbSeek(xFilial("SH1")+cRecurso))
	CBAlert(STR0043,STR0002,.T.,3000,2,.t.) //"Recurso nao cadastrado"###"Aviso"
	Return .f.
EndIf

If l023RC
	lACD023RC := ExecBlock('ACD023RC',.F.,.F.,{cOp,cOperacao,cOperador,cRecurso,lRet})  //Retorno .F. para nao validar o recurso informado
	If ValType(lACD023RC)== "L"
		lRet := lACD023RC
	EndIf
EndIf

If ! lRet
	CBAlert(STR0044,STR0002,.T.,3000,2,.t.) //"Recurso Invalido"###"Aviso"
	Return .f.
EndIf

If cTipo $ "23" // Tratamento para Pausas
	If TerProtocolo() == "PROTHEUS"
		Return .t.
	Else
		If CBYesNo(STR0045+chr(13)+cRecurso+" - "+Left(SH1->H1_DESCRI,20),STR0046,.T.) //"Confirma o recurso"#"ATENCAO"
			Return .t.
		EndIf
		If IsTelnet() .and. (VtModelo() == "RF" .or. lVT100B)
			VtRestore(,,,,aTela)
		Else
			TerRestore(,,,,aTela)
		EndIf
		Return .f.
	EndIf
EndIf

If !lSGQTDOP
	Return .t.
Endif

If ExistBlock("ACD023QE") // Ponto de Entrada para inicializacao da quantidade a ser apontada
	If TerProtocolo() # "PROTHEUS"
		nACD023QE:= ExecBlock("ACD023QE",.F.,.F.,{cOp,cOperacao,cRecurso,cOperador,nQtd})
		nQtd:= nACD023QE
	Else
		nACD023QE:= ExecBlock("ACD023QE",.F.,.F.,{M->CBH_OP,M->CBH_OPERAC,M->CBH_RECUR,M->CBH_OPERAD,M->CBH_QTD})
		M->CBH_QTD:= nACD023QE
	EndIf
Else // Se nao existir o Ponto de Entrada para iniciar a quantidade a mesma e iniciada com o saldo da operacao
	If TerProtocolo() # "PROTHEUS"
		nQtd:= nSldOper
	Else
		M->CBH_QTD:= nSldOper
	EndIf
EndIf
If TerProtocolo() # "PROTHEUS"
	If IsTelnet() .and. VtModelo() == "RF"
		VtRestore(,,,,aTela)
		VtClearBuffer()
	Else
		TerRestore(,,,,aTela)
		TerCBuffer()
	EndIf
EndIf
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ CBVldSeq   ³ Autor ³ Anderson Rodrigues  ³ Data ³ 28/01/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida a sequencia das operacoes de acordo com o roteiro   ³±±
±±³          ³	informado na O.P                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function CB023Seq(cOperacao,lInicio)
Default lInicio := .f.
If Empty(cUltApont)
	If cOperacao # cPriOper .and. ! lInicio
		CBAlert(STR0017,STR0002,.T.,3000,2,.t.) //"Sequencia de operacao incorreta"###"Aviso"
		Return .f.
	Else
		Return .t.
	EndIf
EndIf
If cUltApont # cUltOper
	SG2->(DbSetOrder(1))
	If SG2->(DbSeek(xFilial("SG2")+cProduto+cRoteiro+cUltApont))
		SG2->(DbSkip())
		If SG2->G2_FILIAL+SG2->G2_PRODUTO+SG2->G2_CODIGO # xFilial("SG2")+cProduto+cRoteiro
			CBAlert(STR0047,STR0002,.T.,3000,2,.t.) //"Operacao invalida para esta OP"###"Aviso"
			Return .f.
		EndIf
		If cOperacao > SG2->G2_OPERAC
			CBAlert(STR0017,STR0002,.T.,3000,2,.t.) //"Sequencia de operacao incorreta"###"Aviso"
			Return .f.
		EndIf
	EndIf
EndIf
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ CB023Qtd   ³ Autor ³ Anderson Rodrigues  ³ Data ³ 28/01/04   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida as quantidades requisitadas x quantidade a ser apontada³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CB023Qtd(cOP,cOperacao,cOperador,nQTD,lInicio)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ MV_GANHOPR - Parametro utilizado para verificar se NAO permite o conceito   ³
//|              de "Ganho de Producao" na inclusao do apontamento de Producao. |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lGanhoProd:= SuperGetMV("MV_GANHOPR",.F.,.T.)
Local lACD023VQ := ExistBlock("ACD023VQ")
Local lRetBkp
Local lRet      := .T.
Default lInicio := .F.

If lInicio .and. ! lVldQtdOP // Nao valida a quantidade a ser produzida com a quantidade da OP no inicio da OP+Operacao
	lRet := .T.
Else
	If	lGanhoProd
		lRet := .T.
	ElseIf lInicio // --> Indica que a transacao e do tipo 1 --> Inicio da OP+Operacao
		If ! VldQtdOP(cOP,cOperacao,nQtd) // Valida a quantidade a ser iniciada com a OP e o Saldo da Producao
			lRet := .F.
		EndIf
	ElseIf lVldQtdIni // --> Validacao quando a transacao for do tipo 4 ou 5 --> Apontamento de Producao e/ou Perda
		If ! VldQeComIni(cOP,cOperacao,cOperador,nQtd,lInicio)
			lRet := .F.
		EndIf
	ElseIf lVldOper
		If ! VldQeComOP(cOP,cOperacao,cOperador,nQtd,lInicio)
			lRet := .F.
		EndIf
	EndIf
	If lRet .And. (nQtd >= nSldOPer) .and. (Len(aOperadores) > 1) .and. ! lConjunto
		CBAlert(STR0048,STR0002,.T.,Nil,2,Nil) //"Existem outros operadores em andamento nesta operacao, a quantidade informada finaliza o saldo da operacao"###"Aviso"
		lRet := .F.
	Endif
	If lRet .And. CBH->(ColumnPos( "CBH_PARTOT" )) > 0
		M->CBH_PARTOT := If(QtdComp(nQtd) < QtdComp(n023SldOP), "P", "T")
	EndIf
EndIf

If lRet .And. lACD023VQ
	lRetBkp := lRet
	lRet := ExecBlock('ACD023VQ',.F.,.F.,{cOP,cOperacao,cOperador,nQTD,lInicio})  //Retorno .F. para nao validar a quantidade informada
	If ValType(lRet)!= "L"
		lRet := lRetBkp
	EndIf
Endif
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ VldQtdOP   ³ Autor ³ Anderson Rodrigues  ³ Data ³ 10/02/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida a quantidade a ser iniciada com o saldo da Operacao ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VldQtdOP(cOP,cOperacao,nQtd)
Local nSldCBH := 0
Local nSaldo  := 0

If nQtd > nSldOPer
	If TerProtocolo() == "PROTHEUS"
		MsgAlert(STR0049+". "+STR0050+Str(nSldOper,16,2))
	Else
		CBAlert(STR0049,STR0002,.T.,4000,2,Nil) //"Quantidade maior do que o saldo disponivel para o inicio da operacao"###"Aviso"
		CBAlert(STR0050+Str(nSldOPer,16,2),STR0002,.t.,4000,Nil,Nil) //"O saldo disponivel e  ---> "###"Aviso"
	EndIf
	Return .f.
EndIf

nSldCBH:= CBSldCBH(cOP,cOperacao) // Retorna a quantidade de producao iniciada para a operacao anterior a atual

If nSldCBH > 0 .and. nQtd > nSldCBH
	nSaldo:= (nSldCBH	- nQtd)
	If nSaldo < 0
		nSaldo:= 0
	EndIf
	If nSaldo == 0 .and. nQtd == 0
		Return .t.
	EndIf
	If TerProtocolo() == "PROTHEUS"
		MsgAlert(STR0051+". "+STR0050+Str(nSaldo,16,2))
	Else
		CBAlert(STR0051,STR0002,.T.,4000,2,Nil) //"Quantidade a ser iniciada e maior do que a quantidade do inicio da Operacao anterior"###"Aviso"
		CBAlert(STR0050+Str(nSaldo,16,2),STR0002,.t.,4000,Nil,Nil) //"O saldo disponivel e  ---> "###"Aviso"
	EndIf
	Return .f.
EndIf

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ VldQeComIni³ Autor ³ Anderson Rodrigues  ³ Data ³ 10/02/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida a quantidade do apontamento com a quantidade 		  ³±±
±±³			 ³ informada no inicio da Producao                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function VldQeComIni(cOP,cOperacao,cOperador,nQtd,lInicio)
Local nQtdPrev:= 0

CBH->(DBSetOrder(3))
If CBH->(DbSeek(xFilial("CBH")+cOP+cTipIni+cOperacao+cOperador))
	nQtdPrev:= (CBH->CBH_QEPREV-CBH->CBH_QTD)
	If (Empty(DTOS(CBH->CBH_DTFIM)+(CBH->CBH_HRFIM))) .and. (nQtd > nQtdPrev) // Quantidade Prevista
		If TerProtocolo() == "PROTHEUS"
			MsgAlert(STR0052+". "+STR0050+Str(nQtdPrev,16,2))
		Else
			CBAlert(STR0052,STR0002,.T.,4000,2,Nil) //"Quantidade maior do que o saldo previsto no inicio da operacao"###"Aviso"
			CBAlert(STR0050+Str(nQtdPrev,16,2),STR0002,.t.,4000,Nil,Nil) //"O saldo disponivel e  ---> "###"Aviso"
		EndIf
		Return .f.
	EndIf
EndIf
If lVldOper
	If ! VldQeComOP(cOP,cOperacao,cOperador,nQtd,lInicio)
		Return .f.
	EndIf
EndIf
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ VldQeComOP ³ Autor ³ Anderson Rodrigues  ³ Data ³ 10/02/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida a quantidade do apontamento com a quantidade da OP  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function VldQeComOP(cOP,cOperacao,cOperador,nQtd,lInicio)
Local nX      := 0
Local nPos    := 0
Local nQtdSH6 := 0
Local nTotSH6 := 0
Local nQtdNec := 0
Local nQtdPend:= 0
Local nQtdRe  := 0
Local nTotRe  := 0
Local aSave   := {}
Local aProds  := {}
Local aErros  := {}
Local aAreaAnt:= GetArea()
Local cProd   := SB1->B1_COD
If TerProtocolo() # "PROTHEUS"
	If IsTelnet() .and. (VtModelo() == "RF" .or. lVT100B)
		aSave:= VtSave()
	Else
		aSave:= TerSave()
	EndIf
EndIf

If !("ACDV025" $ FunName())
	If lVldOper .and. nQtd > nSldOPer // Validar somente no apontamento PCP MOD1
		If TerProtocolo() == "PROTHEUS"
			MsgAlert(STR0054+". "+STR0050+Str(nSldOPer,16,2))
		Else
			CBAlert(STR0054,STR0002,.T.,3000,2,Nil) //"Quantidade excede o saldo disponivel da OP"###"Aviso"
			CBAlert(STR0050+Str(nSldOPer,16,2),STR0002,.t.,4000,Nil,Nil) //"O saldo disponivel e  ---> "###"Aviso"
		EndIf
		Return .f.
	EndIf
ElseIf cOperacao > "01"
	If !Empty(cApontAnt)
		If cOperacao == cApontAnt .and. nSldOPer == 0
			If lVldOper
				If TerProtocolo() == "PROTHEUS"
					MsgAlert(STR0053+". "+STR0050+Str(nSldOPer,16,2))
				Else
					CBAlert(STR0053,STR0002,.T.,4000,2,Nil) //"Quantidade maior do que o saldo disponivel para o apontamento da operacao"###"Aviso"
					CBAlert(STR0050+Str(nSldOPer,16,2),STR0002,.t.,4000,Nil,Nil)             //"O saldo disponivel e  ---> "###"Aviso"
				EndIf
				Return .f.
			EndIf
		ElseIf cOperacao > cApontAnt
			If lVldOper .and. (nQtd > nSldOPer)
				If TerProtocolo() == "PROTHEUS"
					MsgAlert(STR0053+". "+STR0050+Str(nSldOPer,11,2))
				Else
					CBAlert(STR0053,STR0002,.T.,4000,2,Nil) //"Quantidade maior do que o saldo disponivel para o apontamento da operacao"###"Aviso"
				   	CBAlert(STR0050+Str(nSldOPer,16,2),STR0002,.t.,4000,Nil,Nil)//"O saldo disponivel e  ---> "###"Aviso"
				EndIf
				Return .f.
			EndIf
		EndIf
	EndIf
EndIf

aAreaAnt   := GetArea()
dbSelectArea("SB5")
SB5->(DbSetOrder(1))
If SB5->(DbSeek(xFilial("SB5")+cProd))
	If SB5->B5_VLDREQ == "3" // Nao valida em Hipotese alguma
		Return.T.
	EndIf

	If Empty(GetMV("MV_VLDREQ")).and. Empty(SB5->B5_VLDREQ)
		Return.T.
	EndIf

	If Empty(SB5->B5_VLDREQ)
		If GetMV("MV_VLDREQ") == "1" .and. cOperacao # "01"
			Return.T.
		EndIf
	Else
		If SB5->B5_VLDREQ == "1" .and. cOperacao # "01"
			Return.T.
		EndIf
	EndIf

	If Empty(SB5->B5_VLDREQ)
		If GetMV("MV_VLDREQ") == "2" .and. cUltOper # cOperacao
			Return.T.
		Endif
	Else
		If SB5->B5_VLDREQ == "2" .and. cUltOper # cOperacao
			Return.T.
		EndIf
	EndIf
Else
	Return.T.
EndIf
RestArea(aAreaAnt)

SD4->(DbSetOrder(2))
SB1->(DbSetOrder(1))

If ! SD4->(DbSeek(xFilial("SD4")+cOP))
	Return .t.
EndIf

While ! SD4->(EOF()) .and. SD4->(D4_FILIAL+D4_OP) == xFilial("SD4")+cOP
	If SB1->(DbSeek(xFilial("SB1")+SD4->D4_COD))
	If Alltrim(SB1->B1_TIPO) == "MO"
		SD4->(DbSkip())
			Loop
		EndIf
	EndIf
	nPos:= Ascan(aProds,{|x| x[1] == SD4->D4_COD})
	If nPos > 0
		aProds[nPos,2]+= SD4->D4_QTDEORI
		aProds[nPos,3]+= SD4->D4_EMPROC
	Else
		aadd(aProds,{SD4->D4_COD,SD4->D4_QTDEORI,SD4->D4_EMPROC})
	EndIf
	SD4->(DbSkip())
Enddo

nTotSH6:= 0
SH6->(DbSetOrder(1))
If SH6->(DbSeek(xFilial("SH6")+Padr(cOP,Len(H6_OP))+cProduto+cOperacao))
	While ! SH6->(EOF()) .and. SH6->(H6_FILIAL+H6_OP+H6_PRODUTO+H6_OPERAC) == xFilial("SH6")+cOP+cProduto+cOperacao
		nQtdSH6:= (SH6->H6_QTDPROD+SH6->H6_QTDPERD)
		nTotSH6+= nQtdSH6
		SH6->(DbSkip())
	Enddo
EndIf

For nX:= 1 to Len(aProds)
	nQtdNec:= (aProds[nX,2]/nQtdOP)  // --> Descobre a quantidade necessaria por unidade a ser produzida
	If CBArmProc(aProds[nX,1],cTM)
		nQtdNec:= (nQtd*nQtdNec)      // --> Descobre a quantidade necessaria para o total ser produzido
		If nQtdNec > aProds[nX,3]
			nQtdPend:= (nQtdNec-aProds[nX,3])
			aadd(aErros,{aProds[nX,1],Str(nQtdPend,6,2)})
		EndIf
	Else
		nQtdNec:= ((nQtd+nTotSH6)*nQtdNec) // --> Descobre a quantidade necessaria para o total ser produzido
		nTotRe:= 0
		SD3->(DbSetOrder(1))
		If SD3->(DbSeek(xFilial("SD3")+Padr(cOP,Len(SD3->(D3_OP)))+aProds[nX,1]))
			While ! SD3->(EOF()) .and. SD3->(D3_FILIAL+D3_OP+D3_COD) == xFilial("SD3")+cOP+aProds[nX,1]
				If SD3->D3_CF == "RE0"
					nQtdRe:= SD3->D3_QUANT
					nTotRe+= nQtdRe
				EndIf
				SD3->(DbSkip())
			Enddo
		Else
			nTotRe:= 0
		EndIf
		If nQtdNec > nTotRe
			nQtdPend:= (nQtdNec-nTotRe)
			aadd(aErros,{aProds[nX,1],Str(nQtdPend,6,2)})
		EndIf
	EndIf
Next
If Empty(aErros)
	Return .t.
EndIf
ShowErros(aErros,aSave)
Return .f.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ GravaHrImp ³ Autor ³ Anderson Rodrigues  ³ Data ³ 27/08/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza gravacao das Horas Improdutivas - Mata682          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function GravaHrImp(cOP,cOperacao,cRecurso,dData1,cHora1,dData2,cHora2,cTotHrImp2,cTransac,cOperador,lEstorna)
Local aMata682:= {}
Local nOpcao,nOrdem

IF !Type("lVT100B") == "L"
	Private lVT100B := .F.
EndIf

Default lEstorna:= .f.

If lEstorna
	nOrdem := 4 // H6_FILIAL+H6_TIPO+H6_RECURSO+DTOS(H6_DTAPONT)+DTOS(H6_DATAINI)+H6_HORAINI+DTOS(H6_DATAFIN)+H6_HORAFIN

Elseif TerProtocolo() == "VT100" .and. (VtModelo() == "RF" .or. lVT100B)
	VtClear()
	VtSay(2,0,STR0039) //"Aguarde..."
Else
	TerCls()
	TerSay(1,0,STR0039) //"Aguarde..."
EndIf

aadd(aMata682,{"H6_RECURSO" ,cRecurso   ,NIL})
aadd(aMata682,{"H6_DATAINI" ,dData1     ,NIL})
aadd(aMata682,{"H6_HORAINI" ,cHora1     ,NIL})
aadd(aMata682,{"H6_DATAFIN" ,dData2     ,NIL})
aadd(aMata682,{"H6_HORAFIN" ,cHora2     ,NIL})
aadd(aMata682,{"H6_TEMPO"   ,cTotHrImp2 ,NIL})
aadd(aMata682,{"H6_DTAPONT" ,dDataBase  ,NIL})
aadd(aMata682,{"H6_MOTIVO"  ,cTransac   ,NIL})
aadd(aMata682,{"H6_OPERADO" ,cOperador  ,NIL})
aadd(aMata682,{"H6_CBFLAG"  ,"1"        ,NIL}) // Flag que indica que foi gerado pelo ACD
If lEstorna
	aadd(aMata682,{"H6_TIPO" ,"I" ,NIL})

	aadd(aMata682,{"INDEX" ,nOrdem ,NIL}) // Ordem do indice para exclusao
Endif

aadd(aMata682,{"H6_LOCAL" ,cLocPad ,NIL})

lMsHelpAuto := .T.
lMSErroAuto := .F.
nModuloOld  := nModulo
nModulo     := 4
nOpcao      := If(lEstorna,5,3) // Estorno / Inclusao
MsExecAuto({|x,y|MATA682(x,y)},aMata682,nOpcao)
nModulo     := nModuloOld
lMsHelpAuto:=.F.
If lMSErroAuto
	DisarmTransaction()
	Break
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ CB023Dados ³ Autor ³ Anderson Rodrigues  ³ Data ³ 28/01/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna array contendo as informacoes do ultimo apontamento³±±
±±³          ³ realizado no SH6 para a chave informada nos parametros     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function CB023Dados(cOP,cProduto,cOperacao,cOperador)
Local cDataHora := ""
Local nRecOperad:= 0
Local aDados    := {}
Local nRecSH6   := SH6->(Recno())

SH6->(DbSetOrder(1))
If ! SH6->(DbSeek(xFilial("SH6")+cOP+cProduto+cOperacao))
	SH6->(DbGoto(nRecSH6))
	Return aClone(aDados)
EndIf
While ! SH6->(EOF()) .and. SH6->H6_OP==cOP .and. SH6->H6_PRODUTO==cProduto .and. SH6->H6_OPERAC==cOperacao
	If Alltrim(SH6->H6_OPERADO) == Alltrim(cOperador)
		If cDataHora < Dtos(SH6->H6_DATAFIN)+SH6->H6_HORAFIN
			cDataHora  := DTOS(SH6->H6_DATAFIN)+SH6->H6_HORAFIN
			nRecOperad := SH6->(Recno())
		EndIf
	EndIf
	SH6->(DbSkip())
Enddo
If nRecOperad == 0
	SH6->(DbGoto(nRecSH6))
	Return aClone(aDados)
EndIF
SH6->(DbGoto(nRecOperad))
aadd(aDados,{SH6->H6_RECURSO,SH6->H6_DATAINI,SH6->H6_HORAINI,SH6->H6_DATAFIN,SH6->H6_HORAFIN,SH6->H6_QTDPROD,SH6->H6_QTDPERD,SH6->H6_TEMPO,SH6->H6_OPERADO})
SH6->(DbGoto(nRecSH6))
Return aClone(aDados)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ CB023Apont ³ Autor ³ Anderson Rodrigues  ³ Data ³ 28/01/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna as quantidades de apontamentos iniciados que estao ³±±
±±³          ³ em aberto para a Operacao atual                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function CB023Apont(cOP,cOperacao)	// --> O parametro lFim determina se ira considerar os inicios ja encerrados e
Local nQtdIni := 0							//     as quantidades ja apontadas para cada inicio em aberto
Local nTotIni := 0

CBH->(DbSetOrder(3))

If ! CBH->(DbSeek(xFilial("CBH")+cOP+cTipIni+cOperacao))
	Return(nTotIni)
EndIf

While ! CBH->(EOF()) .and. CBH->(CBH_FILIAL+CBH_OP+CBH_TIPO+CBH_OPERAC) == xFilial("CBH")+cOP+cTipIni+cOperacao
	If ! Empty(DTOS(CBH->CBH_DTFIM)+CBH->CBH_HRFIM)
		CBH->(DbSkip())
		Loop
	EndIf
	nQtdIni+= (CBH->CBH_QEPREV - CBH->CBH_QTD)
	If	nQtdIni < 0  // deve ser feita esta verificacao, pois no caso de nao validar a qtd apontada com a iniciada a
		nQtdIni := 0 // qtd apontada pode ser maior e neste caso o nQtdIni ficara negativo
	EndIf
	nTotIni += nQtdIni
	CBH->(DbSkip())
Enddo
Return(nTotIni)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ CBSldCBH   ³ Autor ³ Anderson Rodrigues  ³ Data ³ 28/01/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna a quantidade de producao iniciada e que esta em    ³±±
±±³          ³ aberto para a operacao atual                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function CBSldCBH(cOP,cOperacao)
Local nSldPar:= 0
Local nSldTot:= 0

CBH->(DbSetOrder(3)) // Filial+OP+Tipo+Operacao
If ! CBH->(DbSeek(xFilial("CBH")+cOP+cTipIni+cOperacao))
	Return(nSldTot)
EndIf
While ! CBH->(EOF()) .and. CBH->(CBH_FILIAL+CBH_OP+CBH_TIPO+CBH_OPERAC) == xFilial("CBH")+cOP+cTipIni+cOperacao
	nSldPar:= (CBH->CBH_QEPREV - CBH->CBH_QTD)
	If nSldPar < 0
		nSldPar:= 0
	EndIf
	nSldTot+= nSldPar
	CBH->(DbSkip())
Enddo
Return(nSldTot)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ GrvPausa   ³ Autor ³ Anderson Rodrigues  ³ Data ³ 03/02/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gravacao das Paradas                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function GrvPausa(cOP,cOperacao,cOperador,cTransac,cTipAtu)
Local cRecurso:= Space(Len(CBH->CBH_RECUR))
Local aTela   := {}
IF !Type("lVT100B") == "L"
	Private lVT100B := .F.
EndIf
// analisando a pausa em aberto
CBH->(DbSetOrder(3))
CBH->(DbSeek(xFilial("CBH")+cOP+"2",.t.))
While ! CBH->(EOF()) .and. CBH->(CBH_FILIAL+CBH_OP) == xFilial("CBH")+cOP .and. CBH->CBH_TIPO $ "23"
	If ! Empty(CBH->CBH_DTFIM)  //pausa nao esta ativa, nao me enteressa
		CBH->(DbSkip())
		Loop
	EndIf
	If cOperador # CBH->CBH_OPERAD
		CBH->(DbSkip())
		Loop
	EndIf
	If cOperacao # CBH->CBH_OPERAC
		CBH->(DbSkip())
		Loop
	EndIf
	If TerProtocolo() # "PROTHEUS" // Se for RF e Microterminal so reclama se a transacao for diferente
		If CBH->CBH_TRANSA # cTransac
			CBAlert(STR0058+CBH->CBH_TRANSA,STR0002,.T.,4000,2) //"Operacao ja encontra-se pausada pela transacao "###"Aviso"
			Return .f.
		EndIf
	Else // se for Protheus nao permite nova pausa se qualquer outra estiver em aberto, pois a mesma deve ser finaliada atraves da opcao de alteracao do Monitoramento
		CBAlert(STR0058+CBH->CBH_TRANSA,STR0002,.T.,4000,2) //"Operacao ja encontra-se pausada pela transacao "###"Aviso"
		Return .f.
	EndIf
	CBH->(DbSkip())
Enddo

If TerProtocolo() # "PROTHEUS"
	If IsTelnet() .and. (VtModelo() == "RF" .or. lVT100B)
		aTela := VtSave()
	Else
		aTela := TerSave()
	EndIf
EndIf

CBH->(DbSetOrder(1))
If ! CBH->(DbSeek(xFilial("CBH")+cOP+cTransac+cTipAtu+cOperacao+cOperador)) .OR. !Empty(DTOS(CBH->CBH_DTFIM)+CBH->CBH_HRFIM)
	If TerProtocolo() # "PROTHEUS"
		If IsTelnet() .and. (VtModelo() == "RF" .or. lVT100B)
			VtClear()
			@ 0,00 VtSay STR0059 //"Inicio da Pausa"
		Else
		TerCls()
			@ 0,00 TerSay STR0059 //"Inicio da Pausa"
		EndIf
	EndIf
Else
	CB1->(DbSetOrder(1))
	If CB1->(DbSeek(xFilial("CB1")+cOperador)) .and. CB1->CB1_ACAPSM # "1" .and. ! Empty(CB1->CB1_OP+CB1->CB1_OPERAC)
		If (cOP+cOperacao) # (CB1->CB1_OP+CB1->CB1_OPERAC)
			CBAlert(STR0029,STR0002,.T.,4000,4)  //"Operador sem permissao para executar apontamentos simultaneos"###"Aviso"
			CBAlert(STR0030+CB1->CB1_OPERAC+STR0031+CB1->CB1_OP+STR0032,STR0002,.T.,4000,4,.t.)  //"A operacao "###" da O.P. "###" esta em aberto"###"Aviso"
			Return .f.
		EndIf
	EndIf
	If TerProtocolo() # "PROTHEUS"
		If IsTelnet() .and. (VtModelo() == "RF" .or. lVT100B)
			VtClear()
			@ 0,00 VtSay STR0060 //"Termino da Pausa"
		Else
			TerCls()
			@ 0,00 TerSay STR0060 //"Termino da Pausa"
		EndIf
	EndIf
EndIf

If TerProtocolo() == "PROTHEUS"
	Return .t. // Se for Protheus nao faz o bloco abaixo
EndIf

SH8->(DbSetOrder(1))
If lMod1 .And. SH8->(DbSeeK(xFilial("SH8")+padr(cOP,TAMSX3("H8_OP")[1])+cOperacao))
	cRecurso := SH8->H8_RECURSO
EndIf

If IsTelnet() .and. (VtModelo() == "RF" .or. lVT100B)
	@ 2,00 VtSay STR0061 //"Recurso: "
	@ 2,10 VtGet cRecurso  pict '@!' Valid CB023Rec(cOP,cOperacao,cRecurso,cTipAtu) F3 "SH1"
	VtRead
	VtRestore(,,,,aTela)
	If VtLastKey() == 27
		Return .f.
	EndIf
Else
	@ 1,00 TerSay STR0061 //"Recurso: "
	@ 1,10 TerGetRead cRecurso  pict 'XXXXXX' Valid CB023Rec(cOP,cOperacao,cRecurso,cTipAtu)
	TerRestore(,,,,aTela)
	If TerEsc()
		Return .f.
	Endif
EndIf

CBH->(DbSetOrder(1))
If ! CBH->(DbSeek(xFilial("CBH")+cOP+cTransac+cTipAtu+cOperacao+cOperador))
	CB023CBH(cOP,cOperacao,cOperador,cTransac,Nil,dDataBase,Left(Time(),5),Nil,Nil,cTipAtu,"ACDV023",Nil,Nil,cRecurso)
ElseIf ! EMPTY(CBH->CBH_DTINI) .and. EMPTY(CBH->CBH_DTFIM) .and. (CBH->CBH_TRANSA == cTransac) .and. (CBH->CBH_OPERAC == cOperacao) .and. (CBH->CBH_OPERAD == cOperador)
	CB023CBH(cOP,cOperacao,cOperador,cTransac,CBH->(Recno()),CBH->CBH_DTINI,CBH->CBH_HRINI,dDataBase,Left(Time(),5),cTipAtu,"ACDV023",Nil,Nil,cRecurso)
Else
	CB023CBH(cOP,cOperacao,cOperador,cTransac,Nil,dDataBase,Left(Time(),5),Nil,Nil,cTipAtu,"ACDV023",Nil,Nil,cRecurso)
EndIf

//--- Ponto de entrada: Apos a gravacao do monitoramento da producao (CBH)
If ExistBlock("ACD023GP")
	ExecBlock("ACD023GP",.F.,.F.,{cOP,cOperacao,cOperador,cTransac})
EndIf

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ GrvPRPD    ³ Autor ³ Anderson Rodrigues  ³ Data ³ 03/02/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Analisa se faz apontamento de perda ou de producao         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function GrvPrPd(cOP,cOperacao,cOperador,cTransac,cTipAtu)

If lVldOper
	If ! CB023Seq(cOperacao)
		Return .f.
	EndIf
EndIf

CBH->(DbSetOrder(3))
CBH->(DbSeek(xFilial("CBH")+cOP+"2"+cOperacao+cOperador,.t.))
While ! CBH->(EOF()) .and. CBH->(CBH_FILIAL+CBH_OP) == xFilial("CBH")+cOP
	If CBH->CBH_OPERAD # cOperador
		CBH->(DbSkip())
		Loop
	EndIf
	If CBH->CBH_OPERAC == cOperacao .and. CBH->CBH_TIPO $ "23" .and. Empty(CBH->CBH_DTFIM)
		CBAlert(STR0062,STR0002,.T.,3000,2) //"Operacao em pausa"###"Aviso"
		If TerProtocolo() # "PROTHEUS"
			If IsTelnet() .and. (VtModelo() == "RF" .or. lVT100B)
				VTKeyBoard(chr(20))
			EndIf
		EndIf
		Return .f.
	EndIf
	CBH->(DbSkip())
Enddo

If TerProtocolo() == "PROTHEUS"
	Return .t. // Se for Protheus nao executa o bloco abaixo
EndIf

If cTipAtu == "4"
	If ! GrvProd(cOP,cOperacao,cOperador,cTransac,cTipAtu)
		VTKeyBoard(chr(20))
		Return .f.
	EndIf
Else
	If ! GrvPerda(cOP,cOperacao,cOperador,cTransac,cTipAtu)
		VTKeyBoard(chr(20))
		Return .f.
	EndIf
EndIf
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ GrvProd    ³ Autor ³ Anderson Rodrigues  ³ Data ³ 03/02/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gravacao do apontamento da Producao                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GrvProd(cOP,cOperacao,cOperador,cTransac,cTipAtu)
Local aTela   := {}
Local cRecurso:= Space(Len(CBH->CBH_RECUR))
Local cPictQtd:= PesqPict("CBH","CBH_QTD")
Local cLote    := Space(TamSX3("CBH_LOTCTL")[1])
Local cAquivo  := " "
Local dValid   := ctod('')
Local lVolta  := .f.
Local lACD023PR	:=	ExistBlock("ACD023PR")        // Validacao antes da confirmacao do apontamento da producao
Local lTabTmpWMS := IntWMS() .And. FindFunction("WMSCTPRGCV") .AND. FindFunction("WMSDTPRGCV")
Local lRet := .F.
Local lConfirm	:= .T.
Local lProdOp := .T.
Local lGanhoProd := SuperGetMV("MV_GANHOPR",.F.,.T.)
Local lPergGanho := SuperGetMv("MV_CBPERGA",.F.,.T.)
Local dDtApon := dDataBase
Local cPictApon := ""
Local cParTot := ""
Local lCbhApon := .F.
Local nDtApt := SuperGetMV("MV_DTAPT", .F., 2)
Local nSldSH6   := CB023SH6(cOP,cProduto,cOperacao)
Local nSaldoOP  := 0

If nDtApt == 1
	dDtApon := Date()
EndIF

If CBH->(ColumnPos("CBH_DTAPON")) > 0
	cPictApon := PesqPict("CBH", "CBH_DTAPON")
	lCbhApon := .T.
Endif

IF !Type("lVT100B") == "L"
	Private lVT100B := .F.
EndIf


If IsTelnet() .and. (VtModelo() == "RF" .or. lVT100B)
	aTela:= VtSave()
Else
	aTela:= TerSave()
EndIf
nQtd:= 0
SH8->(DbSetOrder(1))
While .t.
	If IsTelnet() .and. (VtModelo() == "RF" .or. lVT100B)
		VtClear()
		VtClearBuffer()
		If lMod1 .And. SH8->(DbSeeK(xFilial("SH8")+padr(cOP,TAMSX3("H8_OP")[1])+cOperacao))
			cRecurso := SH8->H8_RECURSO
		EndIf
		@ 0,00 VtSay STR0063 //"Apontamento Producao"
		@ 2,00 VtSay STR0061 //"Recurso: "
		@ 2,10 VtGet cRecurso  pict 'XXXXXX' Valid CB023Rec(cOP,cOperacao,cRecurso,cTipAtu,nQtd) F3 "SH1" //When Empty(cRecurso)
		VtRead
		If VtLastKey() == 27
			Exit
		EndIf
	Else
		TerIsQuit()
		TerCls()
		TerCBuffer()
		If lMod1 .And. SH8->(DbSeeK(xFilial("SH8")+padr(cOP,TAMSX3("H8_OP")[1])+cOperacao))
			cRecurso := SH8->H8_RECURSO
		EndIf
		@ 0,00 TerSay STR0063 //"Apontamento Producao"
		@ 1,00 TerSay STR0061 //"Recurso: "
		@ 1,10 TerGetRead cRecurso  pict 'XXXXXX' Valid CB023Rec(cOP,cOperacao,cRecurso,cTipAtu,nQtd)  //When Empty(cRecurso)
		If TerEsc()
			Exit
		EndIf
	EndIf
	If !Empty(cRecurso)
		If IsTelnet() .and. VtModelo() == "RF"
			VtClearBuffer()
			@ 3,00 VtSay STR0064 //"Quantidade: "
			@ 4,00 VtGet nQTD Pict cPictQtd Valid CB023Qtd(cOP,cOperacao,cOperador,nQTD)

			If lCbhApon
				@ 5,00 VtSay STR0091 //"Apont.: "
				@ 5,08 VtGet dDtApon Pict cPictApon Valid ValidDtApt(dDtApon)
			EndIf

			VtRead
		Else
			TerCls()
			TerCBuffer()
			@ 0,00 TerSay STR0064 //"Quantidade: "
			@ 1,00 TerGetRead nQTD Pict cPictQtd Valid CB023Qtd(cOP,cOperacao,cOperador,nQTD)
			If lCbhApon
				@ 0,00 VtSay STR0091 //"Apont.: "
				@ 1,00 VtGet dDtApon Pict cPictApon Valid ValidDtApt(dDtApon)
			EndIf
		EndIf
	EndIf
	If IsTelnet() .and. VtModelo() == "RF"
		If VtLastKey() == 27
			Exit
		EndIf
	Else
		If TerEsc()
			Exit
		EndIf
	EndIf
	Geralote(@cLote,@dValid,@lVolta)
	If lVolta
		nQTD := 0
		VtClearGet("nQTD")
		lVolta := .f.
		Loop
	EndIf
	If lACD023PR        // Validacao antes da confirmacao do apontamento da producao
		If ! ExecBlock("ACD023PR",.F.,.F.,{cOp,cOperacao,cRecurso,cOperador,nQtd,cTransac,cLote})
			Loop
		EndIf
	EndIf
	If lGanhoProd
		If (nSldSH6+nQtd) >= nQtdOP
			If !lPergGanho .Or. CBYesNo(STR0096,STR0002,.T.) //"Apontamento Total(S) ou Parcial(N)?"
				cParTot := "T"
				If !lPergGanho .Or. CBYesNo(STR0097,STR0002,.T.) //"Confirma o Apontamento Total de Producao da OP?"
					lConfirm := .T.
				Else
					lConfirm := .F.
				EndIf
			Else
				cParTot := "P"
				If CBYesNo(STR0098,STR0002,.T.) //"Confirma o Apontamento Parcial de Producao da OP?"
					lConfirm := .T.
				Else
					lConfirm := .F.
				EndIf
			Endif
			lRet := .T.
		EndIf
	Else
		If (nSldSH6+nQtd) > nQtdOP
			If nQtdOP > nSldSH6
				nSaldoOP := nQtdOP - nSldSH6
			Else
				nSaldoOP := 0
			EndIf
			If TerProtocolo() == "PROTHEUS"
				MsgAlert(STR0054 + ". " + STR0050 + Str(nSaldoOP,16,2))	// Quantidade excede o saldo disponivel da OP # Aviso
				lConfirm := .F.
			Else
				CBAlert(STR0054, STR0002, .T., 3000, 2, Nil)	// Quantidade excede o saldo disponivel da OP # Aviso
				CBAlert(STR0050 + Str(nSaldoOP,16,2), STR0002, .T., 4000, Nil, Nil)	// O saldo disponivel e # Aviso
				lConfirm := .F.
			EndIf
		EndIf
	EndIf
 	If lConfirm
 		If !lRet
 			If CBYesNo(STR0065,STR0046,.T.) //"Confirma o Apontamento de Producao da OP?"###"ATENCAO"
 				lProdOp := .T.
 			Else
 				lProdOp := .F.
 			EndIf
	 	EndIf
 		If lProdOp
			// Cria a temporária utilizada na execução da regra de convocação WMS
			If lTabTmpWMS
				WMSCTPRGCV()
			EndIf
			Begin transaction
			If lConjunto
				If ! GrvConjunto(cOP,cOperacao,cOperador,cTransac,cRecurso,cTipAtu,nQtd,cLote,dValid)
					lVolta := .t.
				EndIf
			Else
				If lMod1
					If ! CB023GRV(cOP,cOperacao,cTransac,cProduto,cRecurso,cOperador,cTipAtu,nQtd,cLote,dValid,,,,,,,cParTot,dDtApon)
						lVolta := .t.
					Endif
				Else
					If ! CB025GRV(cOP,cOperacao,cTransac,cProduto,cRecurso,cOperador,cTipAtu,nQtd,cLote,dValid,,,,,,cParTot,dDtApon)
						lVolta := .t.
					EndIf
				EndIf
			EndIf
			End Transaction
			// Deleta a temporária utilizada na execução da regra de convocação WMS
			If lTabTmpWMS
				WMSDTPRGCV()
			EndIf
			If lVolta
				nQTD := 0
				VtClearGet("nQTD")
				lVolta := .f.
				Loop
			EndIf
			If lMSErroAuto
				cAquivo:= NomeAutoLog()
				VTDispFile(cAquivo,.t.)
			EndIf
		Else
			cParTot := ""
			nQTD := 0
			lConfirm := .T.
			lRet := .F.
			lProdOp := .T.
			VtClearGet("nQTD")
			Loop
		EndIf
	Else
		cParTot := ""
		nQTD := 0
		lConfirm := .T.
		lRet := .F.
		lProdOp := .T.
		VtClearGet("nQTD")
		Loop
	EndIf
	Exit
Enddo
If IsTelnet() .and. VtModelo() == "RF"
	If VtLastKey() == 27
		VtRestore(,,,,aTela)
		Return .f.
	EndIf
Else
	If TerEsc()
		TerRestore(,,,,aTela)
		Return .f.
	EndIf
EndIf
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ GrvPerda   ³ Autor ³ Anderson Rodrigues  ³ Data ³ 03/02/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gravacao do apontamento de Perda                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function GrvPerda(cOP,cOperacao,cOperador,cTransac,cTipAtu)
Local aTela   := {}
Local cRecurso:= Space(Len(CBH->CBH_RECUR))
Local cPictQtd:= PesqPict("CBH","CBH_QTD")
Local cLote    := Space(10)
Local dValid   := ctod('')
Local lACD023PR := ExistBlock("ACD023PR")        // Validacao antes da confirmacao do apontamento da producao
Local lVolta  := .f.
Local lTabTmpWMS := IntWMS() .And. FindFunction("WMSCTPRGCV") .AND. FindFunction("WMSDTPRGCV")
Local dDtApon := dDataBase
Local cPictApon := ""
Local lCbhApon := .F.
Local nDtApt := SuperGetMV("MV_DTAPT", .F., 2)

If nDtApt == 1
	dDtApon := Date()
EndIF

If CBH->(ColumnPos("CBH_DTAPON")) > 0
	cPictApon := PesqPict("CBH", "CBH_DTAPON")
	lCbhApon := .T.
Endif

IF !Type("lVT100B") == "L"
	Private lVT100B := .F.
EndIf

If IsTelnet() .and. (VtModelo() == "RF" .or. lVT100B)
	aTela:= VtSave()
Else
	aTela:= TerSave()
EndIf
nQtd     := 0
SH8->(DbSetOrder(1))
While .t.
	If IsTelnet() .and. (VtModelo() == "RF" .or. lVT100B)
		VtClear()
		VtClearBuffer()
		If lMod1 .And. SH8->(DbSeeK(xFilial("SH8")+padr(cOP,TAMSX3("H8_OP")[1])+cOperacao))
			cRecurso := SH8->H8_RECURSO
		EndIf
		@ 0,00 VtSay STR0066 //"Apontamento Perda"
		@ 2,00 VtSay STR0061 //"Recurso: "
		@ 2,10 VtGet cRecurso  pict '@!' Valid CB023Rec(cOP,cOperacao,cRecurso,cTipAtu,nQtd) F3 "SH1" //When Empty(cRecurso)
		VtRead
		If VtLastKey() == 27
			Exit
		EndIf
	Else
	   TerIsQuit()
	   TerCls()
	   TerCBuffer()
		If lMod1 .And. SH8->(DbSeeK(xFilial("SH8")+padr(cOP,TAMSX3("H8_OP")[1])+cOperacao))
			cRecurso := SH8->H8_RECURSO
		EndIf
		@ 0,00 TerSay STR0066 //"Apontamento Producao"
		@ 1,00 TerSay STR0061 //"Recurso: "
		@ 1,10 TerGetRead cRecurso  pict 'XXXXXX' Valid CB023Rec(cOP,cOperacao,cRecurso,cTipAtu,nQtd) //When Empty(cRecurso)
		If TerEsc()
			Exit
		EndIf
	EndIf
	If !Empty(cRecurso)
		If IsTelnet() .and. VtModelo() == "RF"
			VtClearBuffer()
			@ 3,00 VtSay STR0064 //"Quantidade: "
			@ 4,00 VtGet nQTD Pict cPictQtd Valid CB023Qtd(cOP,cOperacao,cOperador,nQTD)

			If lCbhApon
				@ 5,00 VtSay STR0091 //"Apont.: "
				@ 5,08 VtGet dDtApon Pict cPictApon Valid ValidDtApt(dDtApon)
			EndIf

			VtRead()
		Else
			TerCls()
			TerCBuffer()
			@ 0,00 TerSay STR0064 //"Quantidade: "
			@ 1,00 TerGetRead nQTD Pict cPictQtd Valid CB023Qtd(cOP,cOperacao,cOperador,nQTD)
			If lCbhApon
				@ 0,00 VtSay STR0091 //"Apont.: "
				@ 1,00 VtGet dDtApon Pict cPictApon Valid ValidDtApt(dDtApon)
			EndIf
		EndIf
	EndIf
	If IsTelnet() .and. VtModelo() == "RF"
		If VtLastKey() == 27
			Exit
		EndIf
	Else
		If TerEsc()
			Exit
		EndIf
	EndIf
	Geralote(@cLote,@dValid,@lVolta)
	If lVolta
		nQTD := 0
		VtClearGet("nQTD")
		lVolta := .f.
		Loop
	EndIf
	If lACD023PR        // Validacao antes da confirmacao do apontamento da producao
		If ! ExecBlock("ACD023PR",.F.,.F.,{cOp,cOperacao,cRecurso,cOperador,nQtd,cTransac,cLote})
			Loop
		EndIf
	EndIf
	If CBYesNo(STR0067,STR0046,.T.) //"Confirma o Apontamento de Perda da OP?"###"ATENCAO"
		// Cria a temporária utilizada na execução da regra de convocação WMS
		If lTabTmpWMS
			WMSCTPRGCV()
		EndIf
		Begin transaction
		If lConjunto
			If ! GrvConjunto(cOP,cOperacao,cOperador,cTransac,cRecurso,cTipAtu,nQtd,cLote,dValid)
				lVolta := .t.
			EndIf
		Else
			If lMod1
				If ! CB023GRV(cOP,cOperacao,cTransac,cProduto,cRecurso,cOperador,cTipAtu,nQtd,cLote,dValid,,,,,,,,dDtApon)
					lVolta := .t.
				EndIf
			Else
				If ! CB025GRV(cOP,cOperacao,cTransac,cProduto,cRecurso,cOperador,cTipAtu,nQtd,cLote,dValid,,,,,,,dDtApon)
					lVolta := .t.
				EndIf
			EndIf
		EndIf
		End Transaction
		// Deleta a temporária utilizada na execução da regra de convocação WMS
		If lTabTmpWMS
			WMSDTPRGCV()
		EndIf
		If lVolta
			lVolta := .f.
			Loop
		EndIf
		If lMSErroAuto
			VTDispFile(NomeAutoLog(),.t.)
		EndIf
	Else
		Loop
	Endif
	Exit
Enddo
If IsTelnet() .and. VtModelo() == "RF"
	If VtLastKey() == 27
		VtRestore(,,,,aTela)
		Return .f.
	EndIf
Else
	If TerEsc()
		TerRestore(,,,,aTela)
		Return .f.
	EndIf
EndIf
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ GrvConjunto³ Autor ³ Anderson Rodrigues  ³ Data ³ 04/04/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Analisa os operadores em aberto para fazer o apontamento   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function GrvConjunto(xOP,xOperacao,xOperador,cTransac,cRecurso,cTipAtu,nQtd,cLote,dValid)
Local aCab     := {"Ok",STR0068,STR0024} //"Operador"###"Quantidade"
Local aTamQtd  := TamSx3("CBH_QTD")
Local aSize    := {2,8,aTamQtd[1]}
Local nX       := 0
Local nPos     := 0
Local nMarcados:= 0

Private cOP       := xOP
Private cOperacao := xOperacao
Private cOperador := xOperador
IF !Type("lVT100B") == "L"
	Private lVT100B := .F.
EndIf

nPos:= Ascan(aOperadores,{|x| x[2] == cOperador})
If nPos > 0
	aOperadores[nPos,3]:= Str(nQtd,aTamQtd[1],aTamQtd[2])
Endif

aOperadores:= aSort(aOperadores,,,{|x,y| x[3] < y[3]})

While .t.
	nMarcados:= 0
	If lVT100B
		VtClearBuffer()
		VtClear()
		VtaBrowse(0,0,3,19,aCab,aOperadores,aSize,'CB023AUX')
	ElseIf IsTelnet() .and. VtModelo() == "RF"
		VtClearBuffer()
		VtClear()
		VtaBrowse(0,0,7,19,aCab,aOperadores,aSize,'CB023AUX')
	Else
		TerIsQuit()
		TerCBuffer()
		TerCls()
		TeraBrowse(0,0,1,19,aCab,aOperadores,aSize,'CB023AUX')
	EndIf
	For nX:= 1 to Len(aOperadores)
		If Empty(aOperadores[nX,1])
			Loop
		EndIf
		nMarcados++
	Next

	If nMarcados < 2
		CBAlert(STR0069,STR0002,.T.,5000,2) //"Para utilizar o apontamento em conjunto devem ser selecionados no minimo dois operadores"###"Aviso"
		If CBYesNo(STR0070,STR0046,.T.) //"Continua ?"###"ATENCAO"
			Loop
		Else
			Return .f.
		EndIf
	EndIf

	If (nQTD >= nSldOPer) .and. nMarcados < Len(aOperadores) // Nao selecionou todos os operadores
		CBAlert(STR0071,STR0002,.T.,nil,2) //"A quantidade informada finaliza o saldo da operacao, neste caso e necessario selecionar todos os operadores"###"Aviso"
		If CBYesNo(STR0070,STR0046,.T.) //"Continua ?"###"ATENCAO"
			Loop
		Else
			Return .f.
		EndIf
	EndIf

	If CBYesNo(STR0072,STR0046,.T.) //"Confirma os itens selecionados"###"ATENCAO"
		For nX:= 1 to Len(aOperadores)
			If Empty(aOperadores[nX,1])
				Loop
			EndIf
			If lMod1
				If ! CB023GRV(cOP,cOperacao,cTransac,cProduto,cRecurso,aOperadores[nX,2],cTipAtu,Val(aOperadores[nX,3]),cLote,dValid)
					Return .f.
				EndIf
			Else
				If ! CB025GRV(cOP,cOperacao,cTransac,cProduto,cRecurso,aOperadores[nX,2],cTipAtu,Val(aOperadores[nX,3]),cLote,dValid)
					Return .f.
				EndIf
			EndIf
		Next
		Exit
	Else
		Return .f.
	EndIf
Enddo
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ GrvInicio  ³ Autor ³ Anderson Rodrigues  ³ Data ³ 03/02/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gravacao do Inicio                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function GrvInicio(cOP,cOperacao,cOperador,cTransac,cTipAtu)
Local nQuant    := 0
Local nEmAberto := CB023Apont(cOP,cOperacao) // Retorna a quantidade total de inicio em aberto para esta operacao
Local cPictQtd  := PesqPict("CBH","CBH_QTD")
Local lRet	    := .t.
Local aTela     := {}
IF !Type("lVT100B") == "L"
	Private lVT100B := .F.
EndIf

If IsTelnet() .and. (VtModelo() == "RF" .or. lVT100B)
	aTela:= VtSave()
Else
	aTela:= TerSave()
EndIf

nSldOPer -= nEmAberto // Atualiza o Saldo da operacao considerando as quantidades de inicio que estao em aberto

If nSldOPer < 0  // --> Se apos a atualizacao o Saldo ficar negativo deixar como zero.
	nSldOPer:= 0
EndIf

If !lInfQeIni
	If CBYesNo(STR0073,STR0046,.T.) //"Confirma o Inicio da Producao da OP?"###"ATENCAO"
		CB023CBH(cOP,cOperacao,cOperador,cTransac,Nil,dDataBase,Left(Time(),5),Nil,Nil,cTipAtu,"ACDV023",nQuant)
		Return .t.
	Else
		If Istelnet() .and. (VtModelo() == "RF" .or. lVT100B)
			VTKeyBoard(chr(20))
		EndIf
		Return .f.
	EndIf
EndIf

If lSGQTDOP
	nQuant:= nSldOPer
EndIf

While .t.
	If lVT100B
		VtClear()
		VtClearBuffer()
		@ 0,00 VtSay STR0074 //"Inicio da Operacao:"
		@ 2,00 VtSay STR0064 //"Quantidade: "
		@ 3,00 VtGet nQuant Pict cPictQtd Valid CB023Qtd(cOP,cOperacao,cOperador,nQuant,.T.)
		VtRead
		If VtLastKey() == 27
			nSldOPer+= nEmAberto
			lRet:= .f.
			Exit
		EndIf
	ElseIf IsTelnet() .and. VtModelo() == "RF"
		VtClear()
		VtClearBuffer()
		@ 1,00 VtSay STR0074 //"Inicio da Operacao:"
		@ 3,00 VtSay STR0064 //"Quantidade: "
		@ 4,00 VtGet nQuant Pict cPictQtd Valid CB023Qtd(cOP,cOperacao,cOperador,nQuant,.T.)
		VtRead
		If VtLastKey() == 27
			nSldOPer+= nEmAberto
			lRet:= .f.
			Exit
		EndIf
	Else
		TerIsQuit()
		TerCls()
		TerCBuffer()
		@ 0,00 TerSay STR0074 //"Inicio da Operacao:"
		If VtModelo() == "MT44"
			@ 1,00 TerSay STR0064 //"Quantidade: "
			@ 1,13 TerGetRead nQuant Pict cPictQtd Valid CB023Qtd(cOP,cOperacao,cOperador,nQuant,.T.)
		Else
			@ 1,00 TerSay STR0081 //"Tecle Enter"
			TerCls()
			@ 0,00 TerSay STR0064 //"Quantidade: "
			@ 1,00 TerGetRead nQuant Pict cPictQtd Valid CB023Qtd(cOP,cOperacao,cOperador,nQuant,.T.)
		EndIf
		If TerEsc()
			nSldOPer+= nEmAberto
			lRet:= .f.
			Exit
		EndIf
	EndIf
	If CBYesNo(STR0073,STR0046,.T.) //"Confirma o Inicio da Producao da OP?"###"ATENCAO"
		Begin transaction
		If lCBAtuemp .and. (nQuant > 0) .and. cOperacao == "01"
			CB023EMP(cOP,cOperacao,nQuant)
		EndIf
		CB023CBH(cOP,cOperacao,cOperador,cTransac,Nil,dDataBase,Left(Time(),5),Nil,Nil,cTipAtu,"ACDV023",nQuant)
		End Transaction
		If lMSErroAuto
			lRet:= .f.
			If IsTelnet() .and. VtModelo() == "RF"
				VtDispFile(NomeAutoLog(),.t.)
			Else
				TerDispFile(NomeAutoLog(),.t.)
			EndIf
		EndIf
	Else
		Loop
	EndIf
	Exit
Enddo
If IsTelnet() .and. VtModelo() == "RF"
	VtRestore(,,,,aTela)
Else
	TerRestore(,,,,aTela)
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ CB023EMP   ³ Autor ³ Anderson Rodrigues  ³ Data ³ 28/01/04  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza os empenhos com os lotes de acordo com o FEFO      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function CB023EMP(cOP,cOperacao,nQTD)
Local cCodProd := ""
Local cLocal   := ""
Local cTRT     := ""
Local nQtdeOri := 0
Local nQtdSegUm:= 0
Local nTotEmp  := 0
Local nQtdLote := 0
Local nX       := 0
Local nY       := 0
Local aDadosD4 := {}
Local aLotes   := {}
Local aMata380 := {}
IF !Type("lVT100B") == "L"
	Private lVT100B := .F.
EndIf

If cOperacao # "01"
	Return
EndIf

SD4->(DbSetOrder(2))
If ! SD4->(DbSeek(xFilial("SD4")+cOP))
	Return
EndIf

While ! SD4->(EOF()) .and. SD4->(D4_FILIAL+D4_OP) == xFilial("SD4")+cOP
	If ! SB1->(DbSeek(xFilial("SB1")+SD4->D4_COD))
		SD4->(DbSkip())
		Loop
	EndIf
	If	Alltrim(SB1->B1_TIPO) == "MO"
		SD4->(DbSkip())
		Loop
	EndIf
	If !Rastro(SD4->D4_COD) // Verifica se controla Lote
		SD4->(DbSkip())
		Loop
	EndIf
	If	! Empty(SD4->D4_LOTECTL+SD4->D4_NUMLOTE)
		SD4->(DbSkip())
		Loop
	EndIf
	aadd(aDadosD4,{SD4->(RECNO())})
	SD4->(DbSkip())
EndDo

For nX:= 1 to Len(aDadosD4)
	SD4->(DbGoTo(aDadosD4[nX,1]))
	cCodProd := SD4->D4_COD
	cLocal   := SD4->D4_LOCAL
	cTRT     := SD4->D4_TRT
	nTotEmp  := RetTotEmp(cOP,cCodProd) // Retorna a quantidade Total que foi empenhada para a OP
	SD4->(DbGoTo(aDadosD4[nX,1]))
	nQtdeOri := (nTotEmp/nQtdOP)    // --> Descobre a quantidade empenhada para cada unidade a ser produzida
	nQtdeOri := (nQTD*nQtdeOri)     // --> Descobre a quantidade total a ser empenhada para a quantidade informada no inicio da operacao
	nQtdSegUm:= ConvUm(cCodProd,nQtdeOri,0,2) // Retorna a quantidade original na 2 Unidade de Medida
	aLotes   := SldPorLote(cCodProd,cLocal,nQtdeOri,nQtdSegUm,NIL,NIL,NIL,NIL,NIL,.T.)
	If Empty(aLotes)
		CBAlert(STR0075+cCodProd+STR0076,STR0002,.T.,3000) //"Nao existe Lote disponivel do produto "###" para empenho"###"Aviso"
		DisarmTransaction()
		Break
	Else
		For nY:= 1 to Len(aLotes)
			nQtdLote+= aLotes[nY,05]
		Next
		If nQtdLote < nQtdeOri
			CBAlert(STR0077+cCodProd+STR0078,STR0002,.T.,3000) //"O Saldo por Lote disponivel para o produto "###" e insuficiente para o empenho"###"Aviso"
			DisarmTransaction()
			Break
		EndIf
	EndIf
	If TerProtocolo() # "PROTHEUS"
		If lVT100B
			VtClear()
			VtSay(1,0,STR0039) //"Aguarde..."
			VtSay(3,0,STR0079) //"Empenhando Lotes..."
		ElseIf IsTelnet() .and. VtModelo() == "RF"
			VtClear()
			VtSay(2,0,STR0039) //"Aguarde..."
			VtSay(4,0,STR0079) //"Empenhando Lotes..."
		Else
			TerCls()
			TerSay(0,0,STR0039) //"Aguarde..."
			TerSay(1,0,STR0079) //"Empenhando Lotes..."
		EndIf
	Else
		ConOut(STR0039)
		ConOut(STR0079)
	EndIf
	For nY:= 1 to Len(aLotes)
		aMata380:= {}
		aadd(aMata380,{"D4_COD"    ,cCodProd     ,NIL}) // Produto
		aadd(aMata380,{"D4_LOCAL"  ,cLocal       ,NIL}) // Armazem
		aadd(aMata380,{"D4_OP"     ,cOP          ,NIL}) // OP
		aadd(aMata380,{"D4_DATA"   ,dDataBase    ,NIL}) // Data do empenho
		aadd(aMata380,{"D4_QTDEORI",aLotes[nY,05],NIL}) // Quantidade do Empenho
		aadd(aMata380,{"D4_QUANT"  ,aLotes[nY,05],NIL}) // Saldo do Empenho
		aadd(aMata380,{"D4_TRT"    ,cTRT         ,NIL}) // Sequencia da estrutura
		aadd(aMata380,{"D4_LOTECTL",aLotes[nY,01],NIL}) // Lote
		aadd(aMata380,{"D4_NUMLOTE",aLotes[nY,02],NIL}) // SubLote
		aadd(aMata380,{"D4_DTVALID",aLotes[nY,07],NIL}) // Data de Validade do Lote
		aadd(aMata380,{"D4_QTSEGUM",aLotes[nY,06],NIL}) // Saldo do Empenho na 2UM
		aadd(aMata380,{"D4_POTENCI",aLotes[nY,12],NIL}) // Potencia
		lMsHelpAuto := .T.
		lMSErroAuto := .F.
		nModuloOld  := nModulo
		nModulo     := 4
		msExecAuto({|x,y|MATA380(x,y)},aMata380,3)
		nModulo     := nModuloOld
		lMsHelpAuto:=.F.
		If lMSErroAuto
			DisarmTransaction()
			Break
		EndIf
	Next
	SD4->(DbGoTo(aDadosD4[nX,1]))
	RecLock("SD4",.F.)
	SD4->D4_QTDEORI -= nQtdeOri
	SD4->D4_QUANT   -= nQtdeOri
	If SD4->D4_QTDEORI <= 0 .OR. SD4->D4_QUANT <= 0
		SD4->(DbDelete())
	EndIf
	SD4->(MsUnlock())
Next
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ RetTotEmp  ³ Autor ³ Anderson Rodrigues  ³ Data ³ 10/02/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna quantidade que ja foi empenhada para a OP          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function RetTotEmp(cOP,cProduto)
Local nTotEmp:= 0

SD4->(DbSetOrder(2))
If ! SD4->(DbSeek(xFilial("SD4")+cOP+cProduto))
	Return(nTotEmp)
EndIf

While ! SD4->(EOF()) .and. SD4->(D4_FILIAL+D4_OP+D4_COD) == xFilial("SD4")+cOP+cProduto
	nTotEmp+= SD4->D4_QTDEORI
	SD4->(DbSkip())
EndDo

Return(nTotEmp)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³  CB023FIM  ³ Autor ³ Anderson Rodrigues  ³ Data ³ 29/04/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Analisa e finaliza os inicios da producao                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function CB023FIM(cOP,cProduto,cOperacao,cOperador,nQtd,dDtFim,cHrFim)
Local nRecCBH
Local cSeek

// ---> Aqui ira finalizar somente os operadores que fizeram parte do apontamento

CBH->(DbSetOrder(3))
If CBH->(DbSeek(xFilial("CBH")+cOP+cTipIni+cOperacao+cOperador))
	RecLock("CBH",.F.)
	If CB023PTot(cOP,cProduto,cOperacao,cOperador)
		CBH->CBH_DTFIM:= dDtFim
		CBH->CBH_HRFIM:= cHrFim
		CBH->CBH_QTD  += nQtd
	Else
		CBH->CBH_QTD  += nQtd
	EndIf
	CBH->(MsUnlock())
	CB023CB1(cOP,cOperacao,cOperador,CBH->CBH_TIPO,CBH->CBH_TRANSA,dDtFim)
EndIf

// ---> Aqui analisa os demais operadores que nao fizeram parte do apontamento, pois mesmo assim devem ter
// seus inicios finalizados caso a operacao tenha sido finalizada

CBH->(DbSetOrder(3))

cSeek 		:= xFilial("CBH")+cOP+cTipIni+cOperacao


CBH->(DbSeek(cSeek))
While ! CBH->(EOF()) .and. CBH->(CBH_FILIAL+CBH_OP+CBH_TIPO+CBH_OPERAC) == cSeek
	nRecCBH:= CBH->(RECNO())
	If CB023PTot(cOP,cProduto,cOperacao,CBH->CBH_OPERAD)
		CBH->(DbGoto(nRecCBH))
		If CBH->(DbSeek(cSeek+CBH->CBH_OPERAD))
			RecLock("CBH",.F.)
			CBH->CBH_DTFIM  := dDtFim
			CBH->CBH_HRFIM  := cHrFim
			CBH->(MsUnlock())
			CB023CB1(cOP,cOperacao,CBH->CBH_OPERAD,CBH->CBH_TIPO,CBH->CBH_TRANSA,dDtFim)
		EndIf
	EndIf
	CBH->(DbGoto(nRecCBH))
	CBH->(DbSkip())
Enddo
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ CB023CB1   ³ Autor ³ Anderson Rodrigues  ³ Data ³ 19/02/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza os Dados no cadastro do operador                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CB023CB1(cOP,cOperacao,cOperador,cTipAtu,cTransac,dDtFim,lLimpa)
Default lLimpa:= .f.

CB1->(DbSetOrder(1))
If ! CB1->(DbSeek(xFilial("CB1")+cOperador))
	Return
EndIf

RecLock('CB1',.f.)

If lLimpa
	CB1->CB1_OP    := Space(13)
	CB1->CB1_OPERAC:= Space(02)
ElseIf cTipAtu == "1"  // inicio
	If Empty(dDtFim)
		CB1->CB1_OP    := cOP
		CB1->CB1_OPERAC:= cOperacao
	Else
		If (CB1->CB1_OP+CB1->CB1_OPERAC) == (cOP+cOperacao) // so tira pausa
			CB1->CB1_OP    := Space(13)                                                      // se OP e operacao for
			CB1->CB1_OPERAC:= Space(02)                                                      // igual
		EndIf
	EndIf
ElseIf cTipAtu $"23" // pausa
	CBI->(DbSetOrder(1))
	If ! CBI->(DbSeek(xFilial("CBI")+cTransac))
		Return
	EndIf
	If ! Empty(dDtFim) .or.  CBI->CBI_BLQASM == "1" // Pausa nao permite o inicio de outra tarefa pelo operador
		CB1->CB1_OP    := cOP
		CB1->CB1_OPERAC:= cOperacao
	Else
		CB1->CB1_OP    := Space(13)
		CB1->CB1_OPERAC:= Space(02)
	EndIf
EndIf
CB1->(MsUnLock())
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ CB023DTHR  ³ Autor ³ Anderson Rodrigues  ³ Data ³ 06/03/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Analisa se a DataBase e Hora atual sao validas             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CB023DTHR(cOP,cOperacao,cOperador,cDataHora)
Local lRet:= .t.

CBH->(DbSetOrder(5))
If ! CBH->(DbSeek(xFilial("CBH")+cOP+cOperacao))
	lRet:= .f.
EndIf

While lRet .And. !CBH->(EOF()) .And. CBH->(CBH_FILIAL+CBH_OP+CBH_OPERAC) == xFilial("CBH")+cOP+cOperacao
	If CBH->CBH_OPERAD # cOperador
		CBH->(DbSkip())
		Loop
	EndIf
	If CBH->CBH_TIPO == "1" .and. !Empty(DTOS(CBH->CBH_DTFIM)+CBH->CBH_HRFIM)
		CBH->(DbSkip())
		Loop
	EndIf
	If CBH->CBH_TIPO == "1" .and. Empty(DTOS(CBH->CBH_DTFIM)+CBH->CBH_HRFIM)
		If  cDataHora < (DTOS(CBH->CBH_DTINI)+CBH->CBH_HRINI)
			lRet:= .f.
			Exit
		EndIf
	EndIf
	If CBH->CBH_TIPO $ "23" .and. Empty(DTOS(CBH->CBH_DTFIM)+CBH->CBH_HRFIM)
		If cDataHora < (DTOS(CBH->CBH_DTINI)+CBH->CBH_HRINI)
			lRet:= .f.
			Exit
		EndIf
	EndIf
	If CBH->CBH_TIPO $ "23" .and. !Empty(DTOS(CBH->CBH_DTFIM)+CBH->CBH_HRFIM)
		If cDataHora < (DTOS(CBH->CBH_DTFIM)+CBH->CBH_HRFIM)
			lRet:= .f.
			Exit
		EndIf
	EndIf
	If CBH->CBH_TIPO $ "45" .and. cDataHora < (DTOS(CBH->CBH_DTFIM)+CBH->CBH_HRFIM)
		lRet:= .f.
		Exit
	EndIf
	CBH->(DbSkip())
Enddo
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ CB023Seq   ³ Autor ³ Anderson Rodrigues  ³ Data ³ 22/04/04   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se valida a sequencia de operacoes                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAACD                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CB023VOPER(cProduto)
Local lRet		:= .f.
Local cVldOpe 	:= GetMV("MV_VLDOPER")

If lMod1
	lRet:= .t. // Para a Producao PCP MOD1 e obrigatoria a validacao da sequencia de operacoes
ElseIf cVldOpe == "S" // Valida a sequencia de Operacoes no apontamento da producao PCP MOD2
	lRet:= .t.
Else
	SB5->(DbSetOrder(1)) // Este bloco so e verificado se for Producao PCP MOD2 e o parametro MV_VLDOPER for N.
	If SB5->(DbSeek(xFilial("SB5")+cProduto))
		If SB5->B5_VLDOPER == "1"
			lRet:= .t.
		ElseIf SB5->B5_VLDOPER == "2"
			lRet:= .f.
		EndIf
	EndIf
EndIf
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa ³ CB023IOPE º Autor ³ Anderson Rodrigues º Data ³ 13/04/04  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Informacao do Operador quando utilizar a rotina em        º±±
±±º          ³	Microterminal com Porta Paralela                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAACD                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CB023IOPE()
Local cCodOpe   := Space(06)
Local cRetPe    := ""
Local lCB023IOPE:= ExistBlock("CB023IOPE") // Ponto de entrada para personalizar a informacao do operador para Microterminal com porta paralela

While .t.
	If lCB023IOPE
		cRetPe := ExecBlock("CB023IOPE",.F.,.F.,{cCodOpe})
		If ValType(cRetPe)=="C"
			cCodOpe := cRetPe
			If ! CBVldOpe(cCodOpe)
				Loop
			EndIf
		EndIf
	Else
		TerIsQuit()
		TerCls()
		TerCBuffer()
		@ 00,00 TerSay STR0082 //"Operador: "
		@ 01,00 TerGetRead cCodOpe pict "XXXXXX" Valid CBVldOpe(cCodOpe)
		If TerEsc()
			TerAlert(STR0083,STR0002,3000,2) //"Operador nao informado"###"Aviso"
			TerCls()
			Loop
		EndIf
	EndIf
	Exit
Enddo
Return(cCodOpe)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ShowErros   ³ Autor ³ Anderson Rodrigues  ³ Data ³ 29/04/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Mostra as inconsistencias encontradas pela funcao VldQeComOP³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ShowErros(aErros,aSave)
Local nX   := 0
Local aCab := {}
Local aSize:= {}

CBAlert(STR0055,STR0002,.T.,3000,2,Nil) //"Erro no apontamento da producao"###"Aviso"
CBAlert(STR0056,STR0002,.T.,3000,2,Nil) //"Favor requisitar os produtos a seguir"###"Aviso"

//-- Se ja existir o arquivo de log de uma operacao anterior, o mesmo devera ser apagado.
If NomeAutoLog()<> NIL .And. File( NomeAutoLog() )
	FErase( NomeAutoLog() )
EndIf

If TerProtocolo() == "PROTHEUS"
	autogrlog(Padr(OemToAnsi(STR0057),Tamsx3("B1_COD")[1])+" "+PadL(OemToAnsi(STR0024),20)) //"Produto"###"Quantidade"
	For nX:= 1 to Len(aErros)
		autogrlog(" ")
		autogrlog(PadL(aErros[nX,1],Tamsx3("B1_COD")[1])+" "+PadL(aErros[nX,2],20))
	Next
	MostraErro()
ElseIf TerProtocolo() == "VT100"
	aCab  := {STR0057,STR0024} //"Produto"###"Quantidade"
	aSize := {15,15}
	VtClear()
	VTaBrowse(0,0,IIf(lVT100B,3,7),19,aCab,aErros,aSize)
	VtRestore(,,,,aSave)
ElseIf TerProtocolo() == "GRADUAL"
	aCab  := {STR0057,STR0024} //"Produto"###"Quantidade"
	aSize := {15,15}
	TerCls()
	TeraBrowse(0,0,1,19,aCab,aErros,aSize)
	TerRestore(,,,,aSave)
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ CB023PG2   ³ Autor ³ André Anjos		    ³ Data ³ 16/01/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna a primeira operacao do roteiro de operacoes - SG2  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CB023PG2(cProduto,cRoteiro)
Local cOperac:= " "

SG2->(DbSetOrder(1))
If SG2->(DbSeek(xFilial("SG2")+cProduto+cRoteiro))
	cOperac := SG2->G2_OPERAC
EndIf
Return cOperac

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³CB023Operac ³ Autor ³ André Anjos			³ Data ³ 16/01/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna array com operacoes para a op apontada			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CB023ArrOp(cProduto,cRoteiro,cOP)
Local aOP := {}

If FunName() == "ACDV023"
	//monta sequencia de operacoes pelo SH8 - Carga Maq.
	dbSelectArea('SH8')
	dbSetOrder(1)
	dbSeek(xFilial('SH8')+cOP)
	While !EOF() .And. (SH8->(H8_FILIAL+H8_OP) == xFilial("SH8")+cOP)
		If aScan(aOP,{|aX| aX==SH8->H8_OPER}) == 0
			aAdd(aOP,SH8->H8_OPER)
		EndIf
		dbSkip()
	End
Else
	//monta sequencia de operacoes pelo SG2 - Roteiro
	dbSelectArea('SG2')
	dbSetOrder(1)
	dbSeek(xFilial('SG2')+cProduto+cRoteiro)
	While !EOF() .And. (SG2->(G2_FILIAL+G2_PRODUTO+G2_CODIGO) == xFilial("SG2")+cProduto+cRoteiro)
		aAdd(aOP,SG2->G2_OPERAC)
		dbSkip()
	End
EndIf

Return aOP
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³GeraLote    ³ Autor ³ Aécio Ferreira Gomes³ Data ³ 28/11/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Responsável pela chamada da função CBRASTRO()que verifica  ³±±
±±³          ³ se o produto controla lote e possibilita a digitação dos   ³±±
±±³          ³ Gets lote e data de valida. 								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD (RF)                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function GeraLote(cLote,dValid,lVolta)

Local cMVFormLot := SuperGetMV("MV_FORMLOT",.F.,"")

cProduto := SC2->C2_PRODUTO
SB1->(DbSetOrder(1))
SB1->(DbSeek(xFilial("SB1")+cProduto))
IF !Type("lVT100B") == "L"
	Private lVT100B := .F.
EndIf

// Gera No.Lote ao apontar a ultima operacao na finalizacao da transacao
If (CBI->CBI_TIPO == "4" .And. SG2->G2_OPERAC == cUltOper) .Or. CBI->CBI_CFULOP == "1"
	If Empty(SB1->B1_FORMLOT)
		If !Empty(cMVFormLot)
			cLote := Formula(cMVFormLot)
		EndIf
	Else
		cLote := Formula(SB1->B1_FORMLOT)
	EndIf
	dValid   := dDataBase+SB1->B1_PRVALID

	If ! CBRastro(cProduto,@cLote,,@dValid,,.T.,@lVolta)
		If IsTelnet() .and. (VtModelo() == "RF" .or. lVT100B)
			VTKeyBoard(chr(20))
		EndIf
		Return .f.
	EndIf

EndIf
Return
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³CB023Encer    ³ Autor ³ Aecio Ferreira Gomes³ Data ³ 11/10/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Responsavel pelo Encerramento das Ops.						³±±
±±³          ³ 						                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 										                        ³±±
±±³          ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ ACDV023                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function CB023Encer()

Local cOP      := Space(Len(SH6->H6_OP))
Local aMata680 := {}
IF !Type("lVT100B") == "L"
	Private lVT100B := .F.
EndIf

While .T.

	If IsTelnet() .and. (VtModelo() == "RF" .or. lVT100B)
		VTCLEAR()
		@ 0,0 vtSay STR0085 //"Encerramento da OP"
		@ 1,0 VTSAY STR0007 //"OP: "
		@ 2,0 VtGet cOP pict '@!'  Valid CB023OP(cOP) F3 "SH8" When Empty(cOP)
		VTREAD
		If vtLastKey() == 27
			Exit
		EndIf
	EndIf
	DbSelectArea("SH6")
	DbSetOrder(1)

	DBSetFilter( {|| cOP == SH6->H6_OP .AND. SH6->H6_PRODUTO == SC2->C2_PRODUTO }, " cOP == SH6->H6_OP .AND. SH6->H6_PRODUTO == SC2->C2_PRODUTO" ) //Verifica se o registro existe na tabela SH6
	DbGoTop()
	If !EOF() .And.  cOP == SH6->H6_OP .AND. SH6->H6_PRODUTO == SC2->C2_PRODUTO  // Se existir o registro nao encerra a OP.
		If ! VTYesNo(STR0086,STR0002,.T.)  //"Deseja encerrar a OP?"###"Aviso"
			cOP := Space(Len(SH6->H6_OP))
			VTGEtSetFocus('cOP')
			Loop
		EndIf
		aadd(aMata680,{"H6_OP"      , SH6->H6_OP       ,NIL})
		aadd(aMata680,{"H6_PRODUTO" , SH6->H6_PRODUTO  ,NIL})
		aadd(aMata680,{"H6_SEQ"     , SH6->H6_SEQ      ,NIL})

		lMsHelpAuto := .T.
		lMSErroAuto := .F.
		nModuloOld  := nModulo
		nModulo     := 4

		MsExecAuto({|x,Y|MATA680(aMata680,7)})// "Encerra ordem de producao"

		nModulo     := nModuloOld
		lMsHelpAuto :=.F.

    Else
		VTAlert(STR0087,STR0002,.T.,3000)// "Nao existem apontamentos para a ordem de producao no arquivo de movimentos da producao","Aviso"
	EndIf
	DBClearFilter()

	cOP := Space(Len(SH6->H6_OP))
	VTGEtSetFocus('cOP')
End

If lMSErroAuto
	VTDispFile(NomeAutoLog(),.t.)
Endif

Return !lMSErroAuto

//-------------------------------------------------------------------
/*/{Protheus.doc} A023RetSld
Retorna o saldo disponível para gatilhar o campo CBH_PARTOT
@author jose.eulalio
@since 10/07/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function A023RetSld(cOP,cOperacao)
Local cSeek		:= ""
Local cSeq		:= ""
Local cDesdobr	:= ""
Local nProd		:= 0
Local nQtMaior	:= 0
Local aAreaSH6	:= SH6->(GetArea())
Local lPerdInf	:= SuperGetMV("MV_PERDINF",.F.,.F.)
Local cQuery	:= ''

SH6->(DbSetOrder(1))
cSeek := xFilial("SH6") + cOP + SC2->C2_PRODUTO + cOperacao
If SH6->(DbSeek(cSeek))
	cSeq		:= SH6->H6_SEQ
	cDesdobr	:= SH6->H6_DESDOBR
	nQtMaior	:= SH6->H6_QTMAIOR
	cQuery := ""
	cQuery += "SELECT SUM(H6_QTDPROD "
	If !lPerdInf
		cQuery += "+ H6_QTDPERD "
	EndIf
	cQuery += " + H6_QTMAIOR) AS QTD FROM " + RetSQLName( 'SH6' ) + " SH6 WHERE "
	cQuery += " H6_FILIAL = '"+xFilial("SH6")+"' AND H6_OP = '"+cOP+"' AND "
	cQuery += " H6_OPERAC = '"+cOperacao+"' AND H6_DESDOBR = '"+cDesdobr+"' AND H6_SEQ = '"+cSeq+"' AND	D_E_L_E_T_ = ' '"
	cTmp := GetNextAlias()

	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cTmp, .T., .F. )
	nProd:= (cTmp)->QTD
	(cTmp)->(dbCloseArea())

	If nProd >= SC2->C2_QUANT
		nProd := 0
	EndIf
Else
	nProd := SC2->C2_QUANT
EndIf

RestArea(aAreaSH6)
Return nProd

/*/{Protheus.doc} ValidDtApt
	Verifica se a Data de Apontamento informada é válida
	@author SQUAD Entradas
	@since 02/04/2019
	@version 1.0
	@param dData, date, a data a ser validada
	@return lRet, logical, se .T. então a data informada é válida
/*/
Function ValidDtApt(dData)

Local lRet := .T.

If lRet .And. Empty(dData)
	CBAlert(STR0092, STR0002,.T.,3000,2,.t.) // "A Data de Apontamento e obrigatoria."
	If TerProtocolo() # "PROTHEUS"
		If IsTelnet() .and. (VtModelo() == "RF" .or. lVT100B)
			VTKeyBoard(DToS(dData))
		EndIf
	EndIf
	lRet := .F.
EndIf

If lRet .And. dData < dDataBase
	CBAlert(STR0093, STR0002,.T.,3000,2,.t.) // "A Data de Apontamento nao pode ser inferior a Data Base."
	If TerProtocolo() # "PROTHEUS"
		If IsTelnet() .and. (VtModelo() == "RF" .or. lVT100B)
			VTKeyBoard(DToS(dData))
		EndIf
	EndIf
	lRet := .F.
EndIf

Return lRet
