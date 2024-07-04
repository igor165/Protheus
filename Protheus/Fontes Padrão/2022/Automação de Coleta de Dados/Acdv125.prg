#INCLUDE "Acdv125.ch" 
#INCLUDE "protheus.ch"
#INCLUDE "apvt100.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ ACDV125    ³ Autor ³ Sandro / Anderson   ³ Data ³ 22/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Recebimento de Mercadoria Mod 2- Por Pedido de Compra      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/     
Template function ACDV125(uPar1,uPar2,uPar3,uPar4,uPar5,uPar6,uPar7,uPar8,uPar9,uPar10)
Return ACDV125(uPar1,uPar2,uPar3,uPar4,uPar5,uPar6,uPar7,uPar8,uPar9,uPar10)

Function ACDV125()
Local bkey09
Local bkey24
Local lVolta := .f.
Local nTamDoc   := TamSx3("F1_DOC")[1]
Local nTamSerie := SerieNfId("SF1",6,"F1_SERIE")
Local nTamForn  := TamSx3("F1_FORNECE")[1]
Local nTamLoja  := TamSx3("F1_LOJA")[1]

Private cNota   := Space(nTamDoc)
Private cSerie  := Space(SerieNfId("SF1",6,"F1_SERIE"))
Private cForn   := Space(nTamForn)
Private cLoja   := Space(nTamLoja)
Private cCodOpe := CBRetOpe()
Private aCab    := {}
Private aHisEti := {}
private dEmissao:= Ctod("")
Private cPictQtd:= "999999999.99"
Private cPictPreco:="999999999.9999"
Private cPictTotal:="99999999999.99"
Private lInfPeso  := GetMV("MV_CBPESO") == "1"
Private lPreNota  := .f.
Private lACD125SE := ExistBlock("ACD125SE")  //Interromper processo de recebimento

IF !Type("lVT100B") == "L"
	Private lVT100B := .F.
EndIf



If	Empty(cCodOpe)
	VTAlert(STR0001,STR0002,.T.,4000) //"Operador nao cadastrado"###"Aviso"
	Return .F.
EndIf

If	dDataBase <= GetMV("MV_DATAFIS")
	VTAlert(STR0003,STR0002,.T.,4000) //"Data menor ou igual a data limite informada no parametro MV_DATAFIS "###"Aviso"
	Return .F.
EndIf

bkey09 := VTSetKey(09,{|| Informa()},STR0004) //"Informacoes"
bKey24 := VTSetKey(24,{|| Estorna()},STR0005)   // CTRL+X //"Estorno"

While .t.
	VTClear()
		If lVT100B // GetMv("MV_RF4X20")
			@ 0,0 VtSay STR0006 //"Recebimento"
			@ 1,0 VtSay STR0007 VtGet cNota 	Pict "@!" when iif(lVolta,(VTKeyBoard(chr(13)),lVolta := .F.,.T.),.T.) Valid ! Empty(cNota)  //"Nota      "
			@ 2,0 VtSay STR0008 VtGet cSerie 	Pict "@!" Valid  ! Empty(cSerie) .and. VldNota(cNota,@cSerie)//"Serie     "
			VTRead
	
			If !(vtLastKey() == 27)
				// Segunda tela------------------------------------------------
				VTClear()
				@ 0,0 VtSay STR0009 VtGet cForn 	Pict "@!" when iif(vtRow() == 0 .and. vtLastKey() == 5,(VTKeyBoard(chr(27)),lVolta := .T.),.T.) Valid ! Empty(cForn) F3 "FOR" //"Fornecedor"
				@ 1,0 VtSay STR0010 VtGet cLoja  	Pict "@!" Valid ! Empty(cLoja) .and. VldNota(cNota,cSerie,cForn,cLoja) //"Loja      "
				@ 2,0 VtSay AllTrim(STR0011)+"  " VtGet dEmissao Pict "@d" Valid ! Empty(dEmissao).and. VldData(dEmissao) //"Emissao   "
				VtRead
			endif
			
			If lVolta
				Loop
			Endif
		Else
			lVolta := .f.
			@ 0,0 VtSay STR0006 //"Recebimento"
			@ 1,0 VtSay STR0007 VtGet cNota 	Pict "@!" Valid ! Empty(cNota)  //"Nota      "
			@ 2,0 VtSay STR0008 VtGet cSerie 	Pict "@!" Valid  ! Empty(cSerie) .and. VldNota(cNota,@cSerie)//"Serie     "
			@ 3,0 VtSay STR0009 VtGet cForn 	Pict "@!" Valid ! Empty(cForn) F3 "FOR" //"Fornecedor"
			@ 4,0 VtSay STR0010 VtGet cLoja  	Pict "@!" Valid ! Empty(cLoja) .and. VldNota(cNota,cSerie,cForn,cLoja) //"Loja      "
			@ 5,0 VtSay STR0011 VtGet dEmissao Pict "@d" Valid ! Empty(dEmissao).and. VldData(dEmissao) //"Emissao   "
			VTRead
		EndIf
	If	VtLastkey() == 27
		Exit
	EndIf
	// Colher dados ref. ao total da nota, total icms
	If	VTYesNo(STR0012,STR0013,.t.) //"Selecionar Pedido"###"Pergunta"
		While .t.
			If	! SelPedido()
				lVolta := .t.
				Exit
			EndIf
			If	EntraValor()
				If	VTYesNo(STR0014,STR0015,.t.) //'Imprime as etiquetas dos itens selecionados'###'Atencao'
					ImpEti()
				EndIf
				Exit
			EndIf
		End
		If	lVolta
			loop
		EndIf
	EndIf
	If ! ConfereProd()
		cNota   := Space(nTamDoc)
		cSerie  := Space(nTamSerie)
		cForn   := Space(nTamForn)
		cLoja   := Space(nTamLoja)
		dEmissao:= Ctod("")
		aCab    := {}
		aHisEti := {}
		Loop
	EndIf
	If	Empty(Len(aHisEti))
		Loop
	EndIf
	Begin Transaction
		AjusteImp()  // ajuste dos impostos e codicao de pagamento
		If !Empty(SuperGetMV("MV_ACDCB0",.F.,"")) 
			AtuCB0()
		EndIf
		If ! Empty(GetMV("MV_CBCQEND"))
			DistriCQ(cNota,cSerie,cForn,cLoja)
		EndIf
	End Transaction
	cNota   := Space(nTamDoc)
	cSerie  := Space(nTamSerie)
	cForn   := Space(nTamForn)
	cLoja   := Space(nTamLoja)
	dEmissao:= Ctod("")
	aCab    := {}
	aHisEti := {}
EndDo
Vtsetkey(09,bkey09)
Vtsetkey(24,bkey24)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ VldNota    ³ Autor ³ Anderson Rodrigues  ³ Data ³ 22/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida a Nota informada                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VldNota(cNota,cSerie,cFornec,cLoja,lSerie)


Default cNota	:= ""
Default cSerie	:= ""
Default cFornec	:= ""
Default cLoja	:= "" 
Default lSerie 	:= .F.


If	Empty(Alltrim(cNota+cSerie+cFornec+cLoja))
	Return .F.
EndIf

If lSerie
	CBMULTDOC("SF1",cNota,@cSerie)
EndIf

If	VTReadVar() == "cForn"  .or. VTReadVar() == "cLoja"
	If	Empty(cForn)
		VTKeyBoard(chr(23))
		Return .f.
	EndIf
	SA2->(DbSetOrder(1))
	If ! SA2->(DbSeek(xFilial('SA2')+cFornec+cLoja))
		VTBeep(3)
		VTAlert(STR0016,STR0017,.t.,4000) //'Fornecedor nao cadastrado'###'Aviso'
		VTKeyBoard(chr(20))
		Return .f.
	EndIf
EndIf

If	VTReadVar() == "cLoja"
	SF1->(DbSetOrder(1))
	If	SF1->(DbSeek(xFilial('SF1')+cNota+cSerie+cFornec+cLoja))
		VtBeep(3)
		VtAlert(STR0018,STR0017,.t.,3000) //'Nota ja cadastrada'###'Aviso'
		VtkeyBoard(chr(20))
		Return .f.
	EndIf
EndIf
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ VldData    ³ Autor ³ Anderson Rodrigues  ³ Data ³ 22/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida a Data de Emissao da Nota                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VldData(dData)

If	dData > dDataBase
	VTBeep(3)
	VTAlert(STR0019,STR0017,.t.,3000) //'Data de Emissao Invalida'###'Aviso'
	Return .f.
EndIf
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ SelPedido  ³ Autor ³ Sandro              ³ Data ³ 22/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta Browse para selecao dos Pedidos de Compra            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function SelPedido()
Local nSldPed := 0
Local aTitulo :={"OK",STR0020,STR0021} //"Pedido"###"Emissao"
Local aTitItem:={"Ok",STR0022,STR0023,STR0024,STR0025,STR0026,STR0027,STR0028,STR0029} //"Item"###"Produto"###"Descricao"###"Qtde Pedida"###"Qtde Recebida"###"Preco"###"TES"###"Total Item"
Local aSize   :={2,6,10}
Local aSizItem:={2,4,15,20,15,15,15,3,15}
Local aTela   := VTSave()
Local nX      :=0
Private aItens:={}
SC7->(DBSetOrder(3))
SC7->(DbSeek(xFilial("SC7")+cForn+cLoja))
While  SC7->(!Eof() .and. C7_FILIAL+C7_FORNECE+C7_LOJA == xFilial("SC7")+cForn+cLoja)
	nSldPed := SC7->(C7_QUANT-C7_QUJE-C7_QTDACLA)
	If ( Empty(SC7->C7_RESIDUO) .And. nSldPed > 0 .And. If(GetMV("MV_RESTNFE")=="S",SC7->C7_CONAPRO != "B",.T.).And. SC7->C7_TPOP != "P" )
		If Ascan(aCab,{|x| x[2] == SC7->C7_NUM }) == 0
			SC7->(aadd(aCab,{" ", C7_NUM,DTOC(C7_EMISSAO),{}}))
		EndIf
	EndIf
	SC7->(DbSkip())
EndDo
If	Empty(aCab)
	VtBeep(3)
	VtAlert(STR0030,STR0017,.t.,3000) //'Nao existe pedido para este fonecedor'###'Aviso'
	Return .f.
EndIf
VtClearBuffer()
VtClear()
VtaBrowse(0,0,7,20,aTitulo,aCab,aSize,'A125AUX1')
VtRestore(,,,,aTela)
For nX := 1 to Len(aCab)
	If	Empty(aCab[nX,1])
		Loop
	EndIF
	aItens := aClone(aCab[nX,4])
	SC7->(DBSetOrder(3))
	SC7->(DbSeek(xFilial("SC7")+cForn+cLoja+aCab[nX,2]))
	While  SC7->(!Eof() .and. C7_FILIAL+C7_FORNECE+C7_LOJA+C7_NUM == xFilial("SC7")+cForn+cLoja+aCab[nX,2])
		nSldPed := SC7->(C7_QUANT-C7_QUJE-C7_QTDACLA)
		If ( Empty(SC7->C7_RESIDUO) .And. nSldPed > 0 .And. If(GetMV("MV_RESTNFE")=="S",SC7->C7_CONAPRO != "B",.T.).And. SC7->C7_TPOP != "P" )
			If Ascan(aitens,{|x|x[2] == SC7->C7_ITEM}) ==0
				SB1->(DBSetOrder(1))
				SB1->(DbSeek(xFilial("SB1")+SC7->C7_PRODUTO))
				SC7->(aadd(aItens,{" ",;
									C7_ITEM,;
									C7_PRODUTO,;
									Left(SB1->B1_DESC,19),;
									Transform(C7_QUANT-C7_QUJE-C7_QTDACLA,cPictQtd),;
									Transform(0,cPictQtd),;
									Transform(C7_PRECO,cPictPreco),;
									C7_TES,;
									Transform((C7_QUANT-C7_QUJE-C7_QTDACLA)*C7_PRECO,cPictTotal),;
									SC7->C7_NUM+SC7->C7_ITEM } ) )
			EndIf
		EndIf
		SC7->(DbSkip())
	EndDo
	VtClearBuffer()
	VtClear()
	@ 0,0 VTSay STR0031+aCab[nX,2] //"Pedido "
	VTaBrowse(1,0,7,20,aTitItem,aItens,aSizItem,'A125AUX2')
	VtRestore(,,,,aTela)
	aCab[nX,4] := aClone(aItens)
Next
If	lACD125SE
	If !Execblock("ACD125SE",.F.,.F.)
		Return .f.
	Endif
Endif
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ A125AUX1   ³ Autor ³ Sandro              ³ Data ³ 22/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao auxiliar chamada pela Funcao SelPedido()            ³±±
±±³          ³ Marca os Pedidos de Compras Selecionados                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A125AUX1(modo,nElem,nElemW)
If modo == 1
ElseIf Modo == 2
Else
	If	VTLastkey() == 27
		return 0
	ElseIf VTLastkey() == 13
		If	aCab[nElem,1] ==" "
			aCab[nElem,1] :="X"
		Else
			aCab[nElem,1] :=" "
		EndIf
		VTaBrwRefresh()
		return 2
	EndIf
EndIf
Return 2

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ A125AUX2   ³ Autor ³ Sandro              ³ Data ³ 22/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao auxiliar chamada pela Funcao SelPedido()            ³±±
±±³          ³ Marca os itens selecionados do Pedido de Compra            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A125AUX2(modo,nElem,nElemW)
Local aTela
Local nQtde := 0
If modo == 1
Elseif Modo == 2
Else
	If VTLastkey() == 27
		return 0
	ElseIf VTLastkey() == 13
		If aItens[nElem,1] ==" "
			VtClearBuffer()
			aTela := VTSave()
			VtClear
			@ 0,0 VTSay STR0032 //"Produto "
			@ 1,0 VTSay aItens[nElem,3]
			@ 2,0 VTSay STR0033 //"Qtde. Pedida"
			@ 3,0 VTSay Val(aItens[nElem,5]) pict cPictQtd
			@ 4,0 VTSay STR0034 //"Preco Unitario"
			@ 5,0 VTSay Val(aItens[nElem,7]) pict cPictPreco
			@ 6,0 VTSay STR0035 //"Qtde. Recebida"
			@ 7,0 VtGet nQtde Pict cPictQtd Valid  VldQtde(nQtde,nElem)
			VtRead
			If	VtLastKey() # 27
				aItens[nElem,6] := Transform(nQtde,cPictQtd)
				aItens[nElem,9] := nQtde*Val(aItens[nElem,7])
				aItens[nElem,1] :="X"
			EndIf
			VTRestore(,,,,aTela)
		Else
			aItens[nElem,1] :=" "
		EndIf
		VTaBrwRefresh()
		Return 2
	Endif
EndIf
Return 2

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ VldQtde    ³ Autor ³ Flavio Luiz Vicco   ³ Data ³ 08/08/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida a Quantidade                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³BOPS      ³ 0000084702 - Implementado ponto de entrada de Validacao    ³±±
±±³          ³              para a quantidade informada                   ³±±
±±³Parametros³ Array = {Produto, Qtde.Pedida, Qtd.digitada}               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VldQtde(nVldQtde,nElem)
local lRet:=.t.
If	Empty(nVldQtde)
	Return .f.
EndIf
If	ExistBlock("ACD125QT")
	lRet := Execblock("ACD125QT",.F.,.F.,{aItens[nElem,3],Val(aItens[nElem,5]),nVldQtde})
	If ValType(lRet) <> "L"
		lRet:=.T.
	EndIf
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ EntraValor ³ Autor ³ Sandro              ³ Data ³ 22/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Mostra o valor total das Mercadorias, se o valor for       ³±±
±±³          ³ confirmado a Funcao retorna .t.                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function EntraValor()
Local nTMercA:=0
Local nX := 0
Local nY := 0
For nX := 1 to len(aCab)
	If	Empty(aCab[nX,1])
		Loop
	EndIf
	For nY:= 1 to len(aCab[nX,4])
		If	Empty(aCab[nX,4,nY,1])
			Loop
		EndIf
		nTMercA += aCab[nX,4,nY,9]
	Next
Next

If ! VTYesNo(STR0036+Transform(nTMercA,cPictTotal),STR0037) //"Total Mercadorias:"###"Confirma o valor"
	Return .f.
EndIf
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ ImpEti     ³ Autor ³ Anderson Rodrigues  ³ Data ³ 22/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Impressao das Etiquetas                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ImpEti()
Local nX:=0
Local nY:=0
Private cPedido

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Funcao utilizada para verificar a ultima versao dos fontes      ³
//³ SIGACUS.PRW, SIGACUSA.PRX e SIGACUSB.PRX, aplicados no rpo do   |
//| cliente, assim verificando a necessidade de uma atualizacao     |
//| nestes fontes. NAO REMOVER !!!							        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !(FindFunction("SIGACUS_V") .and. SIGACUS_V() >= 20050512)
	Final("Atualizar SIGACUS.PRW !!!")
EndIf
If !(FindFunction("SIGACUSA_V") .and. SIGACUSA_V() >= 20050512)
	Final("Atualizar SIGACUSA.PRX !!!")
EndIf
If !(FindFunction("SIGACUSB_V") .and. SIGACUSB_V() >= 20050512)
	Final("Atualizar SIGACUSB.PRX !!!")
EndIf

VTMsg(STR0038) //"Imprimindo..."

If ! CB5SetImp(CBRLocImp("MV_IACD02"),IsTelNet())
	VTBeep(3)
	VTAlert(STR0039,STR0017,.t.,3000) //'Local de impressao nao configurado, MV_IACD02'###'Aviso'
	Return
EndIf
For nX := 1 to len(aCab)
	If	Empty(aCab[nX])
		Loop
	EndIf
	For nY:= 1 to len(aCab[nX,4])
		If	Empty(aCab[nX,4,nY,1])
			Loop
		EndIf
		SB1->(DbSetOrder(1))
		SB1->(DbSeek(xFilial("SB1")+aCab[nX,4,nY,3]))
		If CBProdUnit(aCab[nX,4,nY,3])
			If CBQtdVar(aCab[nX,4,nY,3])
				nQtde := 1
				nQE   := Val(aCab[nX,4,nY,6])
			Else
				nQE   := CBQEmbI()
				nQtde := Val(aCab[nX,4,nY,6])/nQE
			EndIf
		Else
			nQtde := 1
			nQE   := Val(aCab[nX,4,nY,6])
		EndIf
		If ! CBImpEti(aCab[nX,4,nY,3])
			Loop
		EndIf
		If ExistBlock('IMG01')
			cPedido    := aCab[nX,2]+aCab[nX,4,nY,2]
			ExecBlock("IMG01",,,{nQE,NIL,NIL,nQtde,NIL,NIL,cForn,cLoja,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,NIL,cPedido})
		EndIf
	Next
Next
If	ExistBlock('IMG00')
	ExecBlock("IMG00",,,{"ACDV125",Left(cPedido,6),cForn,cLoja})
EndIf
MSCBCLOSEPRINTER()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ ConfereProd³ Autor ³ Sandro              ³ Data ³ 22/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Conferencia das Etiquetas Impressas                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ConfereProd()
Local cEtiqueta
Local nAnalise :=0
While .t.
	cEtiqueta := Space(20)
	VtClear
	@ 0,0 VTSay STR0040 //'Conferencia'
	@ 1,0 VTSay STR0041 //'Leitura da Etiqueta'
	@ 2,0 VTGet cEtiqueta Pict "@!" Valid VldEtiConf(cEtiqueta)
	VTRead
	If	VtLastkey() == 27
		If	VTYesNo(STR0042,STR0043,.t.) //'Finaliza a conferencia'###'Pergunta'
			nAnalise :=Analise()  //0- sair erro, 1- volta a leitura, 2- sai ok
			If	nAnalise == 0
				Return .f.
			ElseIf nAnalise == 1
				Loop
			EndIF
			Exit
		EndIf
	EndIf
End
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ VldEtiConf ³ Autor ³ Sandro              ³ Data ³ 22/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao das Etiquetas lidas na Conferencia               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VldEtiConf(cEtiqueta)
Local aEtiqueta
Local nQE :=0
Local nPeso  := 0
Local nPos:=0
Local nPos2:=0
Local cPedido
Local aItens
Local aSave  := {}
Local nInd	 := 0
Local nXnd	 := 0
Local nPosPrd:= 0

If	Empty(cEtiqueta)
	Return .f.
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se está utilizando código natural ou Ean³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(SuperGetMV("MV_ACDCB0",.F.,"")) 
	aEtiqueta := CBRetEti(cEtiqueta,"01") 
	cPedido := CB0->CB0_PEDCOM
Else	
 	aEtiqueta := CBRetEtiEan(cEtiqueta)
	If Len( aEtiqueta ) > 0
		For nInd := 1 To Len( aCab )
			For nXnd := 1 To Len( aCab[ nInd ][ 04 ] )
				nPosPrd := Ascan( aCab[ nInd ][ 04 ], { | x | AllTrim( x[ 03 ] ) == AllTrim( aEtiqueta[ 01 ] ) } )
				If nPosPrd > 0
					cPedido := aCab[ nInd ][ 04 ][ nPosPrd ][ 10 ]
					Exit
				EndIf
			Next nXnd
		Next nInd
	EndIf
	 
Endif  
If	Empty(aEtiqueta)
	VTBEEP(2)
	VTALERT(STR0044,STR0002,.T.,4000) //"Etiqueta invalida."###"Aviso"
	VTKeyBoard(chr(20))
	Return .f.
EndIf

If	ascan(aHisEti,{|x|x[1] == cEtiqueta}) > 0
	VTBEEP(2)
	VTALERT(STR0045,STR0002,.T.,4000) //"Produto ja foi lido."###"Aviso"
	VTKeyBoard(chr(20))
	Return .f.
EndIf
If !Empty(SuperGetMV("MV_ACDCB0",.F.,"")) 
	If	Alltrim(aEtiqueta[6])+Alltrim(aEtiqueta[7]) # Alltrim(cForn)+Alltrim(cLoja)
		VTBEEP(2)
		VTALERT(STR0046,STR0002,.T.,4000) //"Fornecedor invalido."###"AVISO"
		VTKeyBoard(chr(20))
		Return .f.
	EndIf
	If	! Empty(aEtiqueta[9])
		VTBEEP(2)
		VTALERT(STR0047,STR0002,.T.,4000) //"Produto ja foi enderecado."###"AVISO"
		VTKeyBoard(chr(20))
		Return .f.
	EndIf
	If	! Empty(aEtiqueta[4]+aEtiqueta[5])
		VTBEEP(2)
		VTALERT(STR0048,STR0002,.T.,4000) //"Produto ja conferido"###"Aviso"
		VTKeyBoard(chr(20))
		Return .f.
	EndIf   
	If	Empty(CB0->CB0_PEDCOM)
		VTBEEP(2)
  		VTALERT(STR0049,STR0002,.T.,4000) //"Nao existe identificacao de pedido nesta etiqueta"###"Aviso"
		VTKeyBoard(chr(20))
		Return .f.
	EndIf
Endif    

SC7->(DbSetOrder(1))
If	! SC7->(DbSeek(xFilial("SC7")+cPedido))
	VTBEEP(2)
	VTALERT(STR0050,STR0002,.T.,4000) //"Pedido nao encontrado"###"Aviso"
	VTKeyBoard(chr(20))
	Return .f.
EndIf
SB1->(DbSetOrder(1))
SB1->(DbSeek(xFilial("SB1")+aEtiqueta[1]))
If ! CBProdUnit(aEtiqueta[1])
	While .t.
		nQE := CBQtdEmb(aEtiqueta[1],0)
		If	Empty(nQE)
			VTKeyBoard(chr(20))
			Return .f.
		EndIf
		aEtiqueta[2] := nQE
		nPos := ascan(aCab,{|x| x[2] == Left(cPedido,6)})
		If	nPos > 0
			aItens := aCab[nPos,4]
			nPos2:= Ascan(aitens,{|x|x[2] == Substr(cPedido,7,Len(SC7->C7_ITEM))})
			If nPos2 > 0
				If Transform(nQE,cPictQtd) # aitens[nPos2,6]
					VTBEEP(2)
					VTALERT(STR0051,STR0002,.T.,4000) //"Quantidade incosistente"###"Aviso"
					Loop
				EndIf
			EndIf
		EndIf
		Exit
	EndDo
Else
	If CBQtdVar(SB1->B1_COD)
		While .t.
			aSave:= VTSAVE()
			VTClear
			@ 1,0 VTSay STR0052 //"Embalagem Variada"
			@ 3,0 VtSay STR0053 //"Quantidade"
			@ 4,0 VtGet nQE pict cPictQtd valid nQE > 0
			VTREAD
			VtRestore(,,,,aSave)
			If VTLastKey() == 27
				VTAlert(STR0054,STR0002,.t.,3000) //"Quantidade Invalida"###"Aviso"
				VTKeyBoard(chr(20))
				Return .f.
			EndIf
			aEtiqueta[2] := nQE
			nPos := ascan(aCab,{|x| x[2] == Left(cPedido,6)})
			If nPos > 0
				aItens := aCab[nPos,4]
				nPos2:= Ascan(aitens,{|x|x[2] == Subst(cPedido,7,Len(SC7->C7_ITEM))})
				If nPos2 > 0
					If Transform(nQE,cPictQtd) # aitens[nPos2,6]
						VTBEEP(2)
						VTALERT(STR0051,STR0002,.T.,4000) //"Quantidade incosistente"###"Aviso"
						Loop
					EndIf
				EndIf
			EndIf
			exit
		Enddo
	EndIf
EndIf
If	ExistBlock("ACD125VLD")
	Execblock("ACD125VLD",.F.,.F.,{cEtiqueta})
EndIf
If lInfPeso .AND. !(SB1->B1_TIPO $ "BN-MO-PC")
	aSave   := VTSAVE()
	VTClear()
	nPeso := SB1->B1_PESO
	@ 1,0 VTSay STR0055 //"Dados adicionais"
	@ 3,0 VtSay STR0056 //"Peso Unitario"
	@ 4,0 VtGet nPeso pict PesqPict("SD1","D1_PESO") Valid ! Empty(nPeso)
	VTREAD
	VtRestore(,,,,aSave)
	If	VtLastkey() # 27
		RecLock("SB1",.F.)
		SB1->B1_PESO := nPeso
		SB1->(MsUnLock())
	EndIf
EndIf
If	lInfPeso
	aadd(aHisEti,{cEtiqueta,aEtiqueta[2],SC7->C7_PRECO,cPedido,nPeso,"",SC7->C7_LOCAL})
Else
	aadd(aHisEti,{cEtiqueta,aEtiqueta[2],SC7->C7_PRECO,cPedido,,"",SC7->C7_LOCAL})
EndIf
VtKeyBoard(chr(20))
Return .f.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ Analise    ³ Autor ³ Sandro              ³ Data ³ 22/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Analisa a Finalizacao da Conferencia                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Analise()
Local nX
Local nTotal:=0
For nX:= 1 to len(aHisEti)
	nTotal += aHisEti[nx,2]*aHisEti[nx,3]
Next
If	VTYesNo(STR0036+Transform(nTotal,cPictTotal),STR0037) //"Total Mercadorias:"###"Confirma o valor"
	Return 2
EndIf
If	VTYesNo(STR0057,STR0013,.t.) //"Aborta a operacao"###"Pergunta"
	Return 0
EndIf
Return 1

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ GeraNota   ³ Autor ³ Sandro              ³ Data ³ 22/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gera Nota Fiscal de Entrada (MATA103)/Factura (MATA101N)   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function GeraNota(cCond,aDupl)
Local nX
Local nPos:=0
Local aCab:={}
Local aItens:={}
Local cPedido:= ""
Local cItem  :=""
Local aTemp  :={}
Local aAutoImp := {	{"NF_FRETE" ,nTFre},;
							{"NF_VALIPI",nTIPI},;
							{"NF_VALICM",nTICM}}
Private lForcaPreNota:=.f.
Private lMsErroAuto  :=.f.
Private lMsHelpAuto  :=.t.
lPreNota := .f.

SC7->(DbSetOrder(1))
aCab := {	{"F1_TIPO",		'N',   		NIL},;
			{"F1_FORMUL",	'N',   		NIL},;
			{"F1_DOC",		cNota, 		NIL},;
			{"F1_SERIE",	cSerie,		NIL},;
			{"F1_EMISSAO",	dEmissao,	NIL},;
			{"F1_FORNECE",	cForn,		NIL},;
			{"F1_LOJA",		cLoja,		NIL},;
			{"F1_COND",		cCond,		NIL},;
			{"F1_ESPECIE",	'NF',		NIL} }

lForcaPreNota:= .f.
For nX := 1 to Len(aHisEti2)
	SC7->(DbSetOrder(1))
	If	! SC7->(DbSeek(xFilial("SC7")+aHisEti2[nX,4]))
		lForcaPreNota:= .t.
	EndIf
	If	Empty(SC7->C7_TES)
		lForcaPreNota:= .t.
	EndIf
	cPedido := Left(aHisEti2[nX,4],TamSX3("C7_NUM")[1])
	cItem   := Subst(aHisEti2[nX,4],7,TamSX3("C7_ITEM")[1])
	aTemp   := {}
	aadd(aTemp,{"D1_COD",		SC7->C7_PRODUTO,	NIL})
	aadd(aTemp,{"D1_PEDIDO",	cPedido,			NIL})
	aadd(aTemp,{"D1_ITEMPC",	cItem,				NIL})
	aadd(aTemp,{"D1_LOCAL",		SC7->C7_LOCAL,		NIL})
	aadd(aTemp,{"D1_UM",		SC7->C7_UM,			NIL})
	aadd(aTemp,{"D1_QUANT",		aHisEti2[nX,2],		NIL})
	aadd(aTemp,{"D1_VUNIT",		SC7->C7_PRECO,		NIL})
	aadd(aTemp,{"D1_TOTAL",		aHisEti2[nX,2]*SC7->C7_PRECO,NIL})
	If	Rastro(SC7->C7_PRODUTO,"L")
		aadd(aTemp,{"D1_LOTECTL",aHisEti2[nX,6],NIL})
	EndIf
	aadd(aTemp,{"D1_TES",		SC7->C7_TES,		NIL})
	SB1->(DbSetOrder(1))
	SB1->(DbSeek(xFilial("SB1")+SC7->C7_PRODUTO))
	If	lInfPeso .AND. !(SB1->B1_TIPO $ "BN-MO-PC")
		aadd(aTemp,{"D1_PESO",aHisEti2[nX,5]*aHisEti2[nX,2],NIL})
	EndIf
	
	//Adiciona D1_ITEM caso não seja Brasil
	If cPaisLoc <> "BRA"
		If nX == 1
			Aadd(aCab,{"F1_TXMOEDA",SC7->C7_TXMOEDA,NIL})
		EndIf
		Aadd(aTemp,{"D1_ITEM",StrZero(nX,Len(SD1->D1_ITEM)),NIL})
	EndIf
	
	aadd(aItens,aClone(aTemp))
Next
If	ExistBlock("ACD125VNF")
	Execblock("ACD125VNF",.F.,.F.,{aDupl})
EndIf
If	lForcaPreNota
	VTAlert(STR0058,STR0002,.t.,3000) //"Inconsistencia no pedido"###"Aviso"
	GeraPreNota(cCond)
	Return
EndIf
VTMsg(STR0059) //'Aguarde...'
lMsErroAuto := .f.

If cPaisLoc == "BRA"
	MSExecAuto({|v,w,x,y,z| MATA103(v,w,x,y,z)},aCab,aItens,3,NIL,aAutoImp)  //inclusao
Else
	Aadd(aCab,{"F1_TIPODOC","10",NIL}) //Nota Normal
	MSExecAuto({|v,w,x| MATA101N(v,w,x)},aCab,aItens,3)  //inclusao
EndIf

If lMsErroAuto 
	VTAlert(STR0060,STR0002,.t.,3000) //"Inconsistencia na geracao da nota"###"Aviso"
	VTDispFile(NomeAutoLog(),.t.)
	If cPaisLoc == "BRA"
		GeraPreNota(cCond)
	EndIf
	Return
EndIf
SF1->(DbSetOrder(1))
SF1->(DbSeek(xFilial('SF1')+cNota+cSerie+cForn+cLoja))
VTClear()
RecLock("SF1")
SF1->F1_STATCON := "1"
SF1->(MsUnLock())
If	ExistBlock("ACD125103")
	Execblock("ACD125103")
Endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ GeraPreNota³ Autor ³ Sandro              ³ Data ³ 22/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ GeraPreNota de Entrada (MATA140)                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function GeraPreNota(cCond)
Local nX
Local nPos:=0
Local aCab:={}
Local aItens:={}
Local lForcaPreNota:=.f.
Local cPedido:= ""
Local cItem  := ""
Local aTemp  :={}
Private lMsErroAuto := .f.
Private lMsHelpAuto := .t.
lPreNota := .t.
SC7->(DbSetOrder(1))
SC7->(DbSeek(xFilial("SC7")+aHisEti[1,4]))
aCab := {	{"F1_TIPO",		'N',		NIL},;
			{"F1_FORMUL",	'N',		NIL},;
			{"F1_DOC",		cNota,		NIL},;
			{"F1_SERIE",	cSerie,		NIL},;
			{"F1_EMISSAO",	dEmissao,	NIL},;
			{"F1_FORNECE",	cForn,		NIL},;
			{"F1_LOJA",		cLoja,		NIL},;
			{"F1_FRETE",	nTFre,		NIL},;
			{"F1_COND",		cCond,		NIL},;
			{"F1_ESPECIE",	'NF',		NIL} }

lForcaPreNota := .f.
For nX := 1 to Len(aHisEti2)
	SC7->(DbSetOrder(1))
	If	! SC7->(DbSeek(xFilial("SC7")+aHisEti2[nX,4]))
		lForcaPreNota:= .t.
	EndIf
	If	Empty(SC7->C7_TES)
		lForcaPreNota:= .t.
	EndIf
	cPedido := Left(aHisEti2[nX,4],TamSX3("C7_NUM")[1])
	cItem   := Subst(aHisEti2[nX,4],7,Len(SC7->C7_ITEM))
	aTemp   := {}
	aadd(aTemp,{"D1_COD",		SC7->C7_PRODUTO,	NIL})
	aadd(aTemp,{"D1_PEDIDO",	cPedido,			NIL})
	aadd(aTemp,{"D1_ITEMPC",	cItem,				NIL})
	aadd(aTemp,{"D1_LOCAL",		SC7->C7_LOCAL,		NIL})
	aadd(aTemp,{"D1_UM",		SC7->C7_UM,			NIL})
	aadd(aTemp,{"D1_QUANT",		aHisEti2[nX,2],		NIL})
	aadd(aTemp,{"D1_VUNIT",		SC7->C7_PRECO, 		NIL})
	aadd(aTemp,{"D1_TOTAL",		aHisEti2[nX,2]*SC7->C7_PRECO,NIL})
	If	Rastro(SC7->C7_PRODUTO,"L")
		aadd(aTemp,{"D1_LOTECTL",aHisEti2[nX,6],NIL})
	EndIf
	SB1->(DbSetOrder(1))
	SB1->(DbSeek(xFilial("SC7")+SC7->C7_PRODUTO))
	If	lInfPeso .AND. !(SB1->B1_TIPO $ "BN-MO-PC")
		aadd(aTemp,{"D1_PESO"  ,aHisEti2[nX,5]*aHisEti2[nX,2],NIL})
	EndIf
	aadd(aItens,aClone(aTemp))
Next
VTMsg(STR0061) //'Aguarde..'
lMsErroAuto := .f.

If cPaisLoc <> "BRA"
	Aadd(aCab,{"F1_TIPODOC","10",NIL}) //Nota Normal
EndIf

MSExecAuto({|x,y,z| MATA140(x,y,z)},aCab,aItens,3)  //inclusao
If	lMsErroAuto
	VTAlert(STR0062,STR0002,.t.,3000) //"Problemas com o conteudo da rotina automatica da Pre-Nota"###"Aviso"
	VTDispFile(NomeAutoLog(),.t.)
	DisarmTransaction()
	Break
EndIf
SF1->(DbSetOrder(1))
SF1->(DbSeek(xFilial('SF1')+cNota+cSerie+cForn+cLoja))
VTAlert(STR0063,STR0017,.t.,4000) //'Pre nota gerada, favor classificar'###'Aviso'
If	ExistBlock("ACD125140")
	Execblock("ACD125140")
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ ATUCB0     ³ Autor ³ Sandro              ³ Data ³ 22/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza a Tabela de Etiquetas (CB0)                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AtuCB0()
Local nX
Local aEtiqueta:={}

For nX:= 1 to Len(aHisEti)
	aEtiqueta := CBRetEti(aHisEti[nx,1],"01")
	aEtiqueta[02]:= aHisEti[nx,2]
	aEtiqueta[10]:= aHisEti[nx,7]
	aEtiqueta[04]:= SF1->F1_DOC
	aEtiqueta[05]:= SF1->F1_SERIE
	aEtiqueta[06]:= SF1->F1_FORNECE
	aEtiqueta[07]:= SF1->F1_LOJA
	If	Rastro(aEtiqueta[01],"L")
		aEtiqueta[16]:= aHisEti[nx,6]
	Endif
	CBGrvEti("01",aEtiqueta,aHisEti[nx,1])
	If	lPreNota
		CB0->(CbLog("05",{CB0_CODPRO,CB0_QTDE,CB0_LOTE,CB0_NFENT,CB0_SERIEE,CB0_FORNEC,CB0_LOJAFO,CB0_LOCAL,CB0_CODETI,STR0064})) //"Pre-Nota"
	Else
		CB0->(CbLog("05",{CB0_CODPRO,CB0_QTDE,CB0_LOTE,CB0_NFENT,CB0_SERIEE,CB0_FORNEC,CB0_LOJAFO,CB0_LOCAL,CB0_CODETI,STR0065})) //"Nota"
	EndIf
Next
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ Informa    ³ Autor ³ Sandro              ³ Data ³ 22/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Mostra Browse contendo as Etiquetas ja lidas               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Informa()
Local aCab,aSize,aSave := VTSAVE()
Local aTemp:={}

VTClear()
If lInfPeso
	aCab  := {STR0066,STR0053,STR0027,STR0020,STR0067} //"Etiqueta"###"Quantidade"###"Preco"###"Pedido"###"Peso"
	aSize := {10,16,16,10,10}
Else
	aCab  := {STR0066,STR0053,STR0027,STR0020} //"Etiqueta"###"Quantidade"###"Preco"###"Pedido"
	aSize := {10,16,16,10}
Endif
aTemp := aClone(aHisEti)
VTaBrowse(0,0,7,19,aCab,aTemp,aSize)
VtRestore(,,,,aSave)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³MostraTitulo³ Autor ³ Anderson Rodrigues  ³ Data ³ 22/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Mostra Browse para conferencia dos titulos Gerados         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function MostraTitulo(aDupl)
Local aTela := VTSAVE()
Local aCab  := {}
Local aSize := {}
Local aItens:= {}
Local nX
VTClear()
aCab  := {STR0068,STR0069} //"Vencto"###"Valor"
aSize := {08,15}
If  Len(aDupl) > 0
	For nX:= 1 to Len(aDupl)
		aadd(aItens,{aDupl[nX,1],aDupl[nX,2]})
	Next
	If !Empty(aItens)
		@ 7,0 VtSay STR0070 //"Total de Parcelas"
		@ 7,18 VtSay Strzero(Len(aItens),2)
		VTaBrowse(0,0,6,20,aCab,aItens,aSize)
		VtRestore(,,,,aTela)
	Endif 
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ VERIFICQ   ³ Autor ³ Anderson Rodrigues  ³ Data ³ 22/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica todos os Produtos da Nota que foram enviados para ³±±
±±³          ³ CQ e Retorna Array contendo estes Produtos                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VERIFCQ(cNotaEnt,cSerieEnt,cFornece,cLojafor)
Local cCQ     := GetMvNNR('MV_CQ','98')
Local aRetSD1 := {}

SD1->(DBSetOrder(1))
If ! SD1->(DBSeek(xFilial("SD1")+cNotaEnt+cSerieEnt+cFornece+cLojafor))
	Return aRetSD1
Endif
While ! SD1->(EOF()) .and. SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE;
	+SD1->D1_LOJA == xFilial("SD1")+cNotaEnt+cSerieEnt+cFornece+cLojafor
	If	SD1->D1_LOCAL # cCQ
		SD1->( DBSkip() )
		Loop
	Endif
	SD1->(aadd(aRetSD1,{D1_COD,D1_LOCAL,D1_NUMSEQ,D1_QUANT,D1_LOTECTL,D1_NUMLOTE}))
	SD1->( DBSkip() )
Enddo
aRetSD1:=aSort(aRetSD1)
Return aRetSD1

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ DistriCQ   ³ Autor ³ Sandro              ³ Data ³ 22/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza a Distribuicao automatica dos Produtos que foram   ³±±
±±³          ³ enviados para o Armazem de CQ                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function DistriCQ(cNota,cSerie,cForn,cLoja,lEstorno)
Local cItem
Local aCab  :={}
Local aItens:={}
Local cEndCQ:= GetMV("MV_CBCQEND")
Local aSD1CQ := VerifCQ(cNota,cSerie,cForn,cLoja)
Local nY
DEFAULT lEstorno:= .f.

If	Empty(aSD1CQ)
	Return
EndIf

CB0->(DbSetOrder(6))
For nY:= 1 to Len(aSD1CQ)
	If	IsTelNet()
		VTmsg(STR0071) //"Enviando p/ CQ..."
	Endif	
	If	!CB0->(DbSeek(xFilial('CB0')+ cNota+cSerie+cForn+cLoja+aSD1CQ[nY,1]))
		CONOUT(STR0072) //"Problemas na distribuicao do CQ no recebimento Mod 2 - ACDV125"
		Loop
	EndIf
	cItem := Item(aSD1CQ[nY,1],aSD1CQ[nY,2],aSD1CQ[nY,3],aSD1CQ[nY,4],lEstorno)
	aCAB  :={	{"DA_PRODUTO",aSD1CQ[nY,1], nil},;
					{"DA_LOCAL"  ,aSD1CQ[nY,2], nil},;
					{"DA_NUMSEQ" ,aSD1CQ[nY,3], nil},;
					{"DA_DOC"    ,cNota        , nil}}
	
	aITENS:={{	{"DB_ITEM"  ,cItem         , nil},;
					{"DB_LOCALIZ",cEndCQ    , nil},;
					{"DB_QUANT"  ,aSD1CQ[nY,4]   , nil},;
					{"DB_DATA"   ,dDATABASE     , nil},;
					{"DB_LOTECTL",aSD1CQ[nY,5] ,nil},;
					{"DB_NUMLOTE",aSD1CQ[nY,6] ,nil}}}
	If lEstorno
   	aadd(aItens[1],{"DB_ESTORNO"   ,"S"      , nil})
   EndIf
	//esta variavel devera ser retirada mais tarde
	nModuloOld  := nModulo
	nModulo     := 4
	lMSHelpAuto := .T.
	lMSErroAuto := .F.
	SX3->(DbSetOrder(1))
	msExecAuto({|x,y,z|mata265(x,y,z)},aCab,aItens,If (lEstorno,4,3))// 6=estorno 3=distribuicao	
	nModulo := nModuloOld
	lMSHelpAuto := .F.
	If	lMSErroAuto
		DisarmTransaction()
		If	IsTelNet()
			VTBEEP(2)
			VTALERT(STR0073,STR0074,.T.,4000) //"Falha no processo de distribuicao."###"ERRO"
			VTDispFile(NomeAutoLog(),.t.)
		Else
			MostraErro()
		EndIf
		Break
	Else
		If ! lEstorno
			If CB0->(DbSeek(xFilial("CB0")+ cNota+cSerie+cForn+cLoja+aSD1CQ[nY,1]))
				While ! CB0->(EOF()) .and. CB0->CB0_FILIAL+CB0->CB0_NFENT+CB0->CB0_SERIEE+CB0->CB0_FORNEC;
				+ CB0->CB0_LOJAFO+CB0->CB0_CODPRO == xFilial("CB0")+cNota+cSerie+cForn+cLoja+aSD1CQ[nY,1]
					RecLock("CB0",.f.)
					CB0->CB0_LOCAL :=aSD1CQ[nY,2]
					CB0->CB0_LOCALI:=cEndCQ
					CB0->CB0_NUMSEQ:=aSD1CQ[nY,3]
					CB0->(CBLog("01",{CB0_CODPRO,CB0_QTDE,CB0_LOTE,CB0_SLOTE,CB0_LOCAL,CB0_LOCALI,CB0_NUMSEQ,"",CB0_CODETI,""}))
					CB0->(MsUnlock())
					CB0->(DbSkip())
				Enddo
			Endif
		Else
			If CB0->(DbSeek(xFilial("CB0")+ cNota+cSerie+cForn+cLoja+aSD1CQ[nY,1]))
				While ! CB0->(EOF()) .and. CB0->CB0_FILIAL+CB0->CB0_NFENT+CB0->CB0_SERIEE+CB0->CB0_FORNEC;
				+ CB0->CB0_LOJAFO+CB0->CB0_CODPRO == xFilial("CB0")+cNota+cSerie+cForn+cLoja+aSD1CQ[nY,1]
					SC7->(DbSetorder(1))
					SC7->(DbSeek(xFilial("SC7")+CB0->CB0_PEDCOM))
					RecLock("CB0",.f.)
					CB0->CB0_LOCAL :=SC7->C7_LOCAL
					CB0->CB0_LOCALI:=""
					CB0->CB0_NUMSEQ:=""
					CB0->(CBLog("01",{CB0_CODPRO,CB0_QTDE,CB0_LOTE,CB0_SLOTE,CB0_LOCAL,CB0_LOCALI,CB0_NUMSEQ,"",CB0_CODETI,STR0005})) //"Estorno"
					CB0->(MsUnlock())
					CB0->(DbSkip())	
				Enddo
			Endif
		EndIf
	EndIf
Next
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ Item       ³ Autor ³ Sandro              ³ Data ³ 22/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorno o numero do Proximo item da tabela SDB             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Item(cProduto,cLocal,cNumSeq,nQtde,lEstorno)
Local cItem     := ""
DEFAULT lEstorno:= .f.
SDB->(dbSetOrder(1))
If	SDB->(dbSeek(xFilial("SDB")+cProduto+cLocal+cNumSeq))
	While SDB->(!EOF() .and. xFilial("SDB")+cProduto+cLocal+cNumSeq ==;
		DB_FILIAL+DB_PRODUTO+DB_LOCAL+DB_NUMSEQ)
		If lEstorno .and. StrZero(SDB->DB_QUANT,15,4) == StrZero(nQtde,15,4) .AND. Empty(SDB->DB_ESTORNO)
			cItem := SDB->DB_ITEM
			Return cItem
		EndIf
		cItem := SDB->DB_ITEM
		SDB->(dbSkip())
	End
	cItem := strzero(val(cItem)+1,3)
Else
	cItem := "001"
EndIf
Return cItem

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ AjusteImp  ³ Autor ³ Sandro              ³ Data ³ 22/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Mostra todos os Impostos calculados para a Nota e Permite  ³±±
±±³          ³ o ajuste dos mesmos                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AjusteImp()
Local aDupl     := {}
Local nPos
Local cLote
Local nX
Local nValMerc
Local nAcerto
Local nFrete := 0
Local lFrete:= .f.
Local aTela:= VtSave()
Local cCond
Local nTIPIAux :=0
Local nTICMAux :=0
Local nTFreAux :=0
Local nTotalAux:=0
Local lCBPAJIM := GetMV("MV_CBPAJIM") == "1"/// --> Permite o ajuste dos impostos
Private nTIPIAtu:=0
Private nTICMAtu:=0
Private nTFreAtu:=0
Private nTIPI   := 0
Private nTICM   := 0
Private nTFre   := 0
Private nTotal  := 0
Private aHisEti2:= {}
IF !Type("lVT100B") == "L"
	Private lVT100B := .F.
EndIf

If	VTYesNo(STR0075,STR0002,.t.) //"Informa Frete"###"Aviso"
	VtClear()
	@ 00,00 VtSay STR0076 //"Valor do Frete"
	@ 01,00 VTGet nFrete Pict PesqPict("SF1","F1_FRETE") Valid  nFrete > 0
	VTRead
	If	VTLastkey()# 27
		lFrete:= .t.
	EndIf
EndIf
VTMsg(STR0077) //'Calculando....'
For nX:= 1 to Len(aHisEti)
	nPos := aScan(aHisEti2,{|x| x[4] == aHisEti[nX,4]})
	If nPos ==0
		cLote := 'AUTO'+NextLote(,'S')
		aadd(aHisEti2,{aHisEti[nX,1],aHisEti[nX,2],aHisEti[nX,3],aHisEti[nX,4],aHisEti[nX,5],cLote})
		aHisEti[nX,6]:= cLote
	Else
		aHisEti2[nPos,2]+= aHisEti[nX,2]
		aHisEti[nX,6]  := aHisEti2[nPos,6]
	EndIf
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa a funcao fiscal                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

MaFisSave()
MaFisEnd()
MaFisIni(	cForn,;		// 1-Codigo Cliente/Fornecedor
			cLoja,;		// 2-Loja do Cliente/Fornecedor
			"F",;		// 3-C:Cliente , F:Fornecedor
			"N",;		// 4-Tipo da NF
			NIL,;		// 5-Tipo do Cliente/Fornecedor
			MaFisRelImp("MT100",{"SF1","SD1"}),;
			Nil,;
			.f.,;
			Nil)

SC7->(DbSetOrder(1))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Agrega os itens para a funcao fiscal         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 To Len(aHisEti2)
	SC7->(DbSeek(xFilial("SC7")+aHisEti2[nX,4]))
	cCond := SC7->C7_COND
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Calcula o preco de lista                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nValMerc  := aHisEti2[nX,2]*aHisEti2[nX,3]
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Agrega os itens para a funcao fiscal         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MaFisAdd(	SC7->C7_PRODUTO,;	// 1-Codigo do Produto ( Obrigatorio )
				SC7->C7_TES,;		// 2-Codigo do TES ( Opcional )
				aHisEti2[nX,2],;	// 3-Quantidade ( Obrigatorio )
				aHisEti2[nX,3],;	// 4-Preco Unitario ( Obrigatorio )
				0,;					// 5-Valor do Desconto ( Opcional )
				"",;				// 6-Numero da NF Original ( Devolucao/Benef )
				"",;				// 7-Serie da NF Original ( Devolucao/Benef )
				0,;					// 8-RecNo da NF Original no arq SD1/SD2
				0,;					// 9-Valor do Frete do Item ( Opcional )
				0,;					// 10-Valor da Despesa do item ( Opcional )
				0,;					// 11-Valor do Seguro do item ( Opcional )
				0,;					// 12-Valor do Frete Autonomo ( Opcional )
				nValMerc,;			// 13-Valor da Mercadoria ( Obrigatorio )
				0)					// 14-Valor da Embalagem ( Opiconal )
	MaFisAlt("IT_ALIQIPI",SC7->C7_IPI,nX)
	MaFisAlt("IT_ALIQICM",SC7->C7_PICM,nX)
Next nX
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Indica os valores do cabecalho               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If	lFrete
	MaFisAlt("NF_FRETE",nFrete)
	MaFisWrite(1)
EndIf

nTIPIAux:=MaFisRet(,"NF_VALIPI")
nTICMAux:=MaFisRet(,"NF_VALICM")
nTFreAux:=MaFisRet(,"NF_FRETE")
nTotalAux:=MaFisRet(,"NF_TOTAL")

If	lCBPAJIM
	VTClear()
	While .t.
		if !lVolta
			nTIPI := nTIPIAux
			nTICM := nTICMAux
			nTFre := nTFreAux
			nTotal:= nTotalAux
			nTIPIAtu:= nTIPI
			nTICMAtu:= nTICM
			nTFreAtu:= nTFre
		Endif
		If lVT100B // GetMv("MV_RF4X20")
			@ 0,0 VTSay Padr(STR0078,14,".")  //"Valor do IPI"
			@ 1,0 VTGet nTIPI  Pict "@e 99999999999.99" Valid VldArred("IPI") .and. AltRodape() when iif(lVolta,(VTKeyBoard(chr(13)),lVolta := .F.,.T.),.T.)
			@ 2,0 VTSay Padr(STR0079,14,".")  //"Valor do ICM"
			@ 3,0 VTGet nTICM  Pict "@e 99999999999.99" Valid VldArred("ICM") .and. AltRodape()
			VTRead()
			
			if !(vtLastKey() == 27)
			// Segunda tela------------------------------------------------
				VTClear()
				@ 0,0 VTSay Padr(STR0076,14,".")  //"Valor do Frete"
				@ 1,0 VTGet nTFre  Pict "@e 99999999999.99"  Valid VTLastkey() ==4 .or. AltRodape(.t.) when iif(vtRow() == 1 .and. vtLastKey() == 5,(VTKeyBoard(chr(27)),lVolta := .T.),.T.)
				@ 2,0 VTSay Padr(STR0080,14,".")  //"Valor da Nota"
				@ 3,0 VTGet nTotal Pict "@e 99999999999.99"
				VtRead
			endif
		
			if lVolta
				Loop
			endif
		Else
			@ 0,0 VTSay Padr(STR0078,14,".")  //"Valor do IPI"
			@ 1,0 VTGet nTIPI  Pict "@e 99999999999.99" Valid VldArred("IPI") .and. AltRodape()
			@ 2,0 VTSay Padr(STR0079,14,".")  //"Valor do ICM"
			@ 3,0 VTGet nTICM  Pict "@e 99999999999.99" Valid VldArred("ICM") .and. AltRodape()
			@ 4,0 VTSay Padr(STR0076,14,".")  //"Valor do Frete"
			@ 5,0 VTGet nTFre  Pict "@e 99999999999.99"  Valid VTLastkey() ==4 .or. AltRodape(.t.)
			@ 6,0 VTSay Padr(STR0080,14,".")  //"Valor da Nota"
			@ 7,0 VTGet nTotal Pict "@e 99999999999.99"
			VTRead()
		EndIf
		If	VTLastkey() == 27
			Loop
		EndIf
		Exit
	Enddo
Else
	nTIPI := nTIPIAux
	nTICM := nTICMAux
	nTFre := nTFreAux
	nTotal:= nTotalAux
	nTIPIAtu:= nTIPI
	nTICMAtu:= nTICM
	nTFreAtu:= nTFre
Endif
If lCBPAJIM
	If VTYesNo(STR0081,STR0082,.t.)  //"Confirma os Valores"###"Atencao"
		VtMsg(STR0083) //"Calculando..."
		CalcParcelas(aDupl,cCond)
		MostraTitulo(aDupl)
		If VTYesNo(STR0084,STR0082)		 //"Confirma os Titulos"###"Atencao"
			MaFisEnd()
			MaFisRestore()
			GeraNota(cCond,aDupl)
		Else
			MaFisEnd()
			MaFisRestore()
			GeraPreNota(cCond)
		EndIf
	Else
		MaFisEnd()
		MaFisRestore()
		GerapreNota(cCond)
	EndIf
Else
	VtMsg(STR0083) //"Calculando..."
	CalcParcelas(aDupl,cCond)
	MostraTitulo(aDupl)
	If	VTYesNo(STR0084,STR0082)		 //"Confirma os Titulos"###"Atencao"
		MaFisEnd()
		MaFisRestore()
		GeraNota(cCond,aDupl)
	Else
		MaFisEnd()
		MaFisRestore()
		GeraPreNota(cCond)
	EndIf
EndIf
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ VldArred   ³ Autor ³ Sandro              ³ Data ³ 22/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida o Ajuste realizado no valor dos Impostos            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function VldArred(cTipo)
Local nVlPerAj:= GetMV("MV_CBVLPAJ")

If	cTipo =="IPI"
	If Abs(nTIPI-nTIPIAtu) <= nVlPerAj
		Return .t.
	Else
		nTIPI :=nTIPIAtu
		VtBeep(3)
		VTAlert(STR0085,STR0002,.t.,5000) //"Ultrapassado o valor de ajuste permitido conforme informado no parametro MV_CBVLPAJ"###"Aviso"
		VTGetRefresh("nTIPI")
		Return .f.
	EndIf
ElseIf cTipo =="ICM"
	If Abs(nTICM-nTICMAtu) <= nVlPerAj
		Return .t.
	Else
		nTICM:=nTICMAtu
		VtBeep(3)
		VTAlert(STR0085,STR0002,.t.,5000) //"Ultrapassado o valor de ajuste permitido conforme informado no parametro MV_CBVLPAJ"###"Aviso"
		VTGetRefresh("nTICM")
		Return .f.
	EndIf
EndIf
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ AltRodaPe  ³ Autor ³ Sandro              ³ Data ³ 22/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza o valor dos Impostos apos o ajuste dos mesmos     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AltRodaPe(lAtu)
DEFAULT lAtu:= .f.
MaFisAlt("NF_VALIPI",nTIPI)
MaFisAlt("NF_VALICM",nTICM)
MaFisAlt("NF_FRETE",nTFre)
MaFisWrite(1)
nTIPI := MaFisRet(,"NF_VALIPI")
nTICM := MaFisRet(,"NF_VALICM")
nTFre := MaFisRet(,"NF_FRETE")
nTotal:= MaFisRet(,"NF_TOTAL")
If	lAtu .and. nTFreAtu # nTFre
	nTFreAtu:= nTFre
	nTIPIAtu:= nTIPI
	nTICMAtu:= nTICM
EndIf
VTGetRefresh("nTIPI")
VTGetRefresh("nTICM")
VTGetRefresh("nTFre")
VTGetRefresh("nTotal")
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³CalcParcelas³ Autor ³ Sandro              ³ Data ³ 22/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calcula as Duplicatas de acordo com a condicao de Pagto    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso	     ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CalcParcelas(aDupl,cCond)
Local nAcerto
Local nX
nAcerto:= 0
SE4->(DbSetOrder(1))
MsSeek(xFilial("SE4")+cCond)
aDupl := Condicao(MaFisRet(,"NF_BASEDUP"),cCond,MaFisRet(,"NF_VALIPI"),dEmissao,MaFisRet(,"NF_VALSOL"))
If  Len(aDupl) > 0	
	For nX := 1 To Len(aDupl)
		nAcerto += aDupl[nX][2]
	Next nX
	aDupl[Len(aDupl)][2] += MaFisRet(,"NF_BASEDUP") - nAcerto
	For nX := 1 To Len(aDupl)
		aDupl[nX][2] := Transform(aDupl[nX][2],"@e 99999999999.99")
	Next nX 
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ Estorna    ³ Autor ³ Sandro              ³ Data ³ 22/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza o estorno da Leitura das etiquetas                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Estorna()
Local aTela
Local cEtiqueta
aTela := VTSave()
VTClear()
cEtiqueta := Space(20)
@ 00,00 VtSay Padc(STR0086,VTMaxCol())   //"Estorno da Leitura"
@ 02,00 VtSay STR0087 //"Etiqueta:"
@ 03,00 VtGet cEtiqueta pict "@!" Valid VldEstorno(cEtiqueta)
VtRead
vtRestore(,,,,aTela)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ VldEstorno ³ Autor ³ Sandro              ³ Data ³ 22/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida o estorno da Leitura das Etiquetas                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VldEstorno(cEtiqueta)
Local nPos,cKey,nQtd,cProd,nPosID
Local aEtiqueta,nSaldo,nQtdeBx
Local cLote  := Space(TamSX3("B8_LOTECTL")[1])
Local cSLote := Space(TamSX3("B8_NUMLOTE")[1])
If	Empty(cEtiqueta)
	Return .f.
EndIf
nPos := Ascan(aHisEti, {|x| AllTrim(x[1]) == AllTrim(cEtiqueta)})
If nPos == 0
	VTBeep(2)
	VTALERT(STR0088,STR0002,.T.,4000)   //"Etiqueta nao encontrada"###"AVISO"
	VtKeyboard(Chr(20))  // zera o get
	Return .f.
EndIf
If ! VTYesNo(STR0089,STR0082,.t.)   //"Confirma o estorno desta Etiqueta?"###"ATENCAO"
	VtKeyboard(Chr(20))  // zera o get
	Return .f.
EndIf
//Estorno do aHisEti
aDel(aHisEti,nPos)
aSize(aHisEti,Len(aHisEti)-1)
VtKeyboard(Chr(20))  // zera o get
Return .f.
