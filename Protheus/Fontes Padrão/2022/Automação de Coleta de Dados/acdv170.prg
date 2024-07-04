#INCLUDE "acdv170.ch" 
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'APVT100.CH'

// variaveis usadas para POSICAO de campos nos arrays aItens e aItensCB9
STATIC _POSRECNO   :=1
STATIC _POSITEM    :=2
STATIC _POSCODPRO  :=3
STATIC _POSARMAZEM :=4
STATIC _POSENDERECO:=5
STATIC _POSSLDSEP  :=6
STATIC _POSQTDSEP  :=7
STATIC _POSLOTECTL :=8
STATIC _POSNUMLOTE :=9
STATIC _POSNUMSERIE:=10
STATIC _POSSUBVOL  :=11
STATIC _POSIDETI   :=12
STATIC _POSCFLOTE  :=13
STATIC _POSLOTESUG :=14
STATIC _POSSLOTESUG:=15
STATIC _lPulaItem  := .F.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ ACDV172    ³ Autor ³ Desenv.    ACD      ³ Data ³ 17/06/01 	 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Movimentacao interna de produtos                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ ExpC1 = Caso queira padronizar programas de movimentacao in³±±
±±³          ³         terna deve passar o nome do programa               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso	     ³ SIGAACD                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ACDV172()
Local aTela
Local nOpc

aTela := VtSave()
VTCLear()
@ 0,0 VTSAY STR0164 //"Separacao"
@ 1,0 VTSay STR0181 //'Selecione:'
nOpc:=VTaChoice(3,0,4,VTMaxCol(),{STR0165,STR0166,STR0167})  //"Ordem de Separacao"###"Pedido de Venda"###"Ordem de Producao"
VtRestore(,,,,aTela)
If nOpc == 1 // por Ordem de Separacao
	ACDV170()
ElseIf nOpc == 2 // por pedido de venda
	ACDV171()
ElseIf nOpc == 3 // por Ordem de Producao
	ACDV171B()
EndIf
Return NIL
                
Function ACDV170()
	ACDV170x(1)
Return NIL

Function ACDV171()
	ACDV170x(2)
Return NIL

Function ACDV171B()
	ACDV170x(3)
Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ ACDV170X ³ Autor ³ ACD                   ³ Data ³ 03/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Funcao Principal da rotina de Expedicao                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ACDV170X(nOpc)
Local bKey09
Local bKey01
Local bKey24
Local bKey22
Local cOP            := Space(13)
Local lContinua      := .T.
Private cPedido      := Space(6)
Private cCodOpe      := CBRetOpe()
Private cOrdSep      := Space(6)
Private aItens       := {}
Private bKey16       := VtSetKey(16,{|| nil})
Private bKey02       // Retrocede
Private bKey04       // Avanca
Private cTipoExp
Private cOriExp
Private cImp         := CBRLocImp("MV_IACD01")
Private cNota
Private lMSErroAuto  := .F.
Private lMSHelpAuto  := .t.
Private lEstEmbalagem:= .f.
Private lRetrocede   := .f.
Private lAvanca      := .f.
Private lRetSepara   := .f.
Private lDesfazTudo  := .f.
Private lExcluiNF    := .f.
Private cUltTipoExp
Private lProcSep     := .t.
Private lProcEmbFim  := .t.
Private lProcGeraNF  := .t.
Private lProcEmbarque:= .t.
Private lProcReqOP   := .t.
Private lEstLeitura  := .f.
Private cDivItemPv   := GetMV("MV_DIVERPV")
Private cPictQtdExp  := PesqPict("CB8","CB8_QTDORI")
Private lForcaQtd    := GetMV("MV_CBFCQTD",,"2") =="1"

If Empty(cCodOpe)
	VTAlert(STR0001,STR0002,.T.,4000) //"Operador nao cadastrado"###"Aviso"
	lContinua := .F.
EndIf
CB5->(DbSetOrder(1))
If !CB5->(DbSeek(xFilial("CB5")+cImp)) // cadastro de locais de impressao
	VtBeep(3)
	VtAlert(STR0003,STR0002,.t.) //"O conteudo informado no parametro MV_IACD01 deve existir na tabela CB5."###"Aviso"
	lContinua := .F.
EndIf

If lContinua
	bkey09 := VTSetKey(09)
	bkey01 := VTSetKey(01)
	bKey24 := VTSetKey(24)
	bKey22 := VTSetKey(22)
	bKey02 := VTSetKey(02)
	bKey04 := VTSetKey(04)

	While .t.
		If !lRetrocede
			vtsetkey(01,bkey01)
			vtsetkey(09,bkey09)
			vtsetkey(24,bkey24)
			vtsetkey(22,bkey22)
			vtsetkey(02,bkey02)
			vtsetkey(04,bkey04)

			VTClear()
			@ 0,0 VtSay STR0164 //"Separacao"
			If nOpc == 1  // por codigo de pre-separacao
				cOrdSep := Space(6)
				@ 1,0 VTSay STR0182 //'Informe o codigo:'
				@ 2,0 VTGet cOrdSep PICT "@!" F3 "CB7"  Valid VldCodSep()
			Elseif nOpc == 2 // por pedido
				cPedido := Space(6)
				@ 2,0 VTSay STR0183 //'Informe o Pedido'
				@ 3,0 VTSay STR0184 VTGet cPedido PICT "@!" F3 "CBL" Valid VldNumPed(@cPedido)  // asv pendencia //'de venda: '
			Else
				cOP:= Space(13)
				@ 2,0 VTSay STR0185 //'Informe a Ordem'
				@ 3,0 VTSay STR0198  //'de Producao:'
				@ 4,0 VTGet cOP PICT "@!" F3 "SC2" Valid VldOP(@cOP)
			EndIf
			VTRead
			If VTLastKey() == 27
				Exit
			EndIf

			cUltTipoExp:= Alltrim(CB7->CB7_TIPEXP)
			cUltTipoExp:= StrTran(cUltTipoExp,"08*","")
			cUltTipoExp:= StrTran(cUltTipoExp,"10*","")
			cUltTipoExp:= StrTran(cUltTipoExp,"11*","")
			cUltTipoExp:= Ordena(cUltTipoExp)  // Ordena a String
			cUltTipoExp:= Right(cUltTipoExp,3)

			VTSetKey(09,{|| Informa()})
			VTSetKey(01,{|| Ajuda()})
			VTSetKey(24,{|| Estorna()})
			VTSetKey(22,{|| Volume()})
			VTSetKey(02,{|| Retrocede()})
			VTSetKey(04,{|| Avanca()})
		Else
			lRetrocede := .f.
		EndIf

		// analisar a pergunta (CB7->CB7_TIPOEXP)
		//00-Separcao,01-Separacao/Embalagem,02-Embalagem,03-Gera Nota,04-Imp.Nota,05-Imp.Volume,06-embarque,07-Requisita
		If lProcSep
			seta()
			If !Separa()
				EstItemPv()
				If lRetrocede
					lRetrocede:=.f.
					Grv_Pausa(1) //1 - Retrocedendo e perguntando nova Ordem Separacao...
					Loop
				Else
					If !lAvanca
						Exit
					Else
						lAvanca:=.f.
					EndIf
				EndIf
			EndIf
			EstItemPv()
		EndIf
		If lProcEmbFim
			seta()
			If "02" $ cTipoExp
				If ! Embalagem()
					If lRetrocede
						Loop
					Else
						Exit
					EndIf
				EndIf
			EndIf
		EndIf
		If lProcReqOP
			seta()
			If "07" $ cTipoExp
				If ! RequisitOP()
					If VldSaida(5)
						Exit
					EndIf
					Grv_Pausa(1) //1 - Retrocedendo e perguntando nova Ordem Separacao...
					Loop
				EndIf
			EndIf
		EndIf
		If lProcGeraNF
			seta()
			If "03" $ cTipoExp
				If ! GeraNota()
					If lRetrocede
						If "01" $ CB7->CB7_TIPEXP .OR. "02" $ CB7->CB7_TIPEXP
							lEstEmbalagem:= .T.
						Else
							lRetSepara:= .T.
						EndIf
						Loop
					EndIf
					If VldSaida(6)
						Exit
					EndIf
				EndIf
				If lRetrocede .and. (lEstEmbalagem .or. lRetSepara .or. lExcluiNF)
					Loop
				EndIf
			EndIf
		EndIf
		If "04" $ cTipoExp
			If ! ImpNota()
				Exit
			EndIf
			If lRetrocede
				Loop
			EndIf
		EndIf
		If "05" $ cTipoExp
			If ! ImpVolume()
				Exit
			EndIf
		EndIf
		If lProcEmbarque
			seta()
			If "06" $ cTipoExp
				If ! Embarque()
					If lRetrocede
						Loop
					Else
						Exit
					EndIf
				EndIf
			EndIf
		EndIf
		FimProcesso()
	End

	Grv_Pausa(2) //2 - Saindo da Ordem Separacao...

	vtsetkey(01,bkey01)
	vtsetkey(09,bkey09)
	vtsetkey(24,bkey24)
	vtsetkey(22,bkey22)
	vtsetkey(02,bkey02)
	vtsetkey(04,bkey04)
EndIf
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ Separa   ³ Autor ³ ACD                   ³ Data ³ 03/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Realiza o Processo de Separacao dos Produtos               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static function Separa()
Local nX
Local cEndereco      := Space(15)
Local cEtiqEnd       := Space(20)
Local cEtiqProd      := Space(TamSx3("CB0_CODET2")[1])
Local cEtiqCaixa     := Space(TamSx3("CB0_CODET2")[1])
Local cEtiqAvulsa    := Space(TamSx3("CB0_CODET2")[1])
Local cProduto       := IIf( FindFunction( 'AcdGTamETQ' ), AcdGTamETQ(), Space(48) )
Local cNumSerie      := Space(20)
Local nQtde          := 0
Local cDescProd      := ""
Local cRetPE         := ""
Local cCodEti
Local lSeparou       := .f.
Local lFaltaSeparar  := .f.
Local lMV_CFENDIG    := GetMV('MV_CFENDIG') =="1"
Local lACD170SEP     := ExistBlock("ACD170SEP")
Local lACD170DES     := ExistBlock("ACD170DES")
Private nQtdLida     := 0
Private cVolume      := Space(10)
Private cVolPrv      := Space(10)
Private lSepara      := .t.
Private cLoteNew     := Space(10)
Private cSLoteNew    := Space(6)
Private cArmazem     := Space(Tamsx3("B1_LOCPAD")[1])
Private lSaiEstorno  := .f.

If "01" $ cTipoExp .and. !("00" $ cTipoExp) .and. !("02" $ cTipoExp) .and. lExcluiNF
	Return .t.
EndIf

If "00" $ cUltTipoExp .and. CB7->CB7_STATUS == "9"
	lEstLeitura:=.t.
	CB9->(DBSetOrder(1))
	CB9->(DbSeek(xFilial("CB9")+cOrdSep))
	While CB9->(! Eof() .and. CB9_FILIAL+CB9_ORDSEP == xFilial("CB9")+cOrdSep)
		If ! Empty(CB9->CB9_QTESEP)
			If !VTYesNo(STR0146,STR0027,.T.) //'Estorna leitura ?'###'Atencao'
				AtvRet(.f.)
				AtvAva(.f.)
				Return .f.
			Else
				Estorna()
				CB9->(DbSeek(xFilial("CB9")+cOrdSep))
				Loop
			EndIf
		EndIf
		CB9->(DbSkip())
	End
EndIf

CBFlagSC5("1",cOrdSep)  //Em separacao
_lPulaItem:= .f.
While .T.
	If ("01" $ cTipoExp) .and. (CB7->CB7_STATUS =='0' .or. CB7->CB7_STATUS =='1' .or. lRetrocede)
		While ! Volume()
			If VldSaida(1)
				Return .f.
			EndIf
		End
	EndIf
	If lRetSepara  //Caso ja tenha sido feita a separacao...e retorna a separacao
		For nX:= 1 to len(aItens)
			If aItens[nX] == nil
				Loop
			EndIf
			lSaiEstorno := .f.
			//Begin Sequence
			nQtdLida  := 0
			cArmazem  := aItens[nX,_POSARMAZEM]
			cEndereco := aItens[nX,_POSENDERECO]
			VTClear()
			If	GetNewPar("MV_OSEP2UN","0") $ "0 "
				@ 0,0 VTSay Padr(STR0011+Alltrim(Str(aItens[nX,_POSSLDSEP],TamSx3("CB8_QTDORI")[1],TamSx3("CB8_QTDORI")[2]))+If(aItens[nX,_POSSLDSEP]==1,STR0012,STR0013),20) //'Separe '###' item '###' itens '
			Else
				SB1->(DbSetOrder(1))
				SB1->(DbSeek(xFilial("SB1")+aItens[nX,_POSCODPRO]))
				nQtdCX:= CBQEmb()
				If ExistBlock('CBRQEESP')
					nQtdCX:=ExecBlock('CBRQEESP',,,SB1->B1_COD)
				EndIf

				If aItens[nX,_POSSLDSEP]/nQtdCX < 1
					@ 0,0 VTSay Padr(STR0011+Alltrim(Str(aItens[nX,_POSSLDSEP],TamSx3("CB8_QTDORI")[1],TamSx3("CB8_QTDORI")[2]))+If(aItens[nX,_POSSLDSEP]==1,STR0012,STR0013),20) //'Separe '###' item '###' itens '
				Else
					@ 0,0 VTSay Padr(STR0011+Alltrim(Str(aItens[nX,_POSSLDSEP]/nQtdCX,TamSx3("CB8_QTDORI")[1],TamSx3("CB8_QTDORI")[2]))+If(aItens[nX,_POSSLDSEP]/nQtdCX==1,STR0168,STR0169),20) //'Separe ' //" Volume"###" Volumes"
				EndIf
			EndIf
			cDescProd := Posicione("SB1",1,xFilial('SB1')+aItens[nX,_POSCODPRO],"B1_DESC")
			If	lACD170DES
				cRetPE    := ExecBlock("ACD170DES", .F., .F., {aItens[nX,_POSCODPRO]})
				cDescProd := If(ValType(cRetPe)=="C",cRetPE,cDescProd)
			EndIf
			@ 1,0 VTSay aItens[nX,_POSCODPRO]
			@ 2,0 VTSay PADR(cDescProd,VTMaxCol())
			If Rastro(aItens[nX,_POSCODPRO],"L")
				@ 3,0 VTSay STR0014 //'Lote       '
				@ 4,0 VTSay aItens[nX,_POSLOTECTL]
			ElseIf Rastro(aItens[nX,_POSCODPRO],"S")
				@ 3,0 VTSay STR0015 //'Lote       SubLote'
				@ 4,0 VTSay aItens[nX,_POSLOTECTL]+' '+aItens[nX,_POSNUMLOTE]
			EndIf
			
			If ! CBProdUnit(aItens[nX,_POSCODPRO])  // granel
				cEtiqCaixa := Space(TamSx3("CB0_CODET2")[1])
				@ 6,0 VTSay STR0016 //"Leia a caixa"
				@ 7,0 VtGet cEtiqCaixa pict '@!' Valid VldCaixa(cEtiqCaixa,nX) .and. AtvP(.f.) When AtvP(.t.)
				VtRead
				If VTLastkey() == 27
					lRetSepara :=.f.
					If lSaiEstorno
						nX := 0
						Loop
					Endif
					If ! VldSaida(4)
						nX--
						Loop
					EndIf
					If lRetrocede
						If "00*" $ cTipoExp
							Return .f.
						Else
							cArmazem  := Space(Tamsx3("B1_LOCPAD")[1])
							cEndereco := Space(15)
							Exit
						EndIf
					EndIf
					Return .f.
				EndIf
				cEtiqAvulsa:= Space(TamSx3("CB0_CODET2")[1])
				@ 6,0 VTClear to 7,19
				@ 6,0 VTSay STR0017 //"Leia a etiq. avulsa"
				@ 7,0 VtGet cEtiqAvulsa pict '@!' Valid VldEtiqAvulsa(cEtiqAvulsa,nX).and. AtvP(.f.) When AtvP(.t.)
				VtRead
				If VTLastkey() == 27
					lRetSepara :=.f.
					If lSaiEstorno
						nX := 0
						Loop
					Endif
					If ! VldSaida(4)
						nX--
						Loop
					EndIf
					If lRetrocede
						If "00*" $ cTipoExp
							Return .f.
						Else
							cArmazem  := Space(Tamsx3("B1_LOCPAD")[1])
							cEndereco := Space(15)
							Exit
						EndIf
					EndIf
					Return .f.
				EndIf
			Else
				If UsaCB0("01")
					cEtiqProd  := Space(TamSx3("CB0_CODET2")[1])
					@ 6,0 VTSay STR0018 //'Leia a etiqueta'
					@ 7,0 VTGet cEtiqProd pict '@!' Valid VldEti(@cEtiqProd,nX) .and. AtvP(.f.) When AtvP(.t.)
					VTRead
					If VTLastkey() == 27
						lRetSepara :=.f.
						If lSaiEstorno
							nX := 0
							Loop
						Endif
						If ! VldSaida(4)
							nX--
							Loop
						EndIf
						If lRetrocede
							If "00*" $ cTipoExp
								Return .f.
							Else
								cArmazem  := Space(Tamsx3("B1_LOCPAD")[1])
								cEndereco := Space(15)
								Exit
							EndIf
						EndIf
						Return .f.
					EndIf
				Else
					nQtde := 1
					cProduto   := IIf( FindFunction( 'AcdGTamETQ' ), AcdGTamETQ(), Space(48) )
					@ 5,0 VTSay STR0019 VtGet nQtde pict cPictQtdExp valid VldQtde(nQtde) when (lForcaQtd .or. VTLastkey() == 5) //'Qtde '
					@ 6,0 VTSay STR0020 //'Leia o produto'
					@ 7,0 VTGet cProduto pict '@!' VALID VTLastkey() == 5 .or. VldProd(cProduto,nX,nQtde).and. AtvP(.f.) When AtvP(.t.)
					VTRead
					If VTLastkey() == 27
						lRetSepara :=.f.
						If lSaiEstorno
							nX := 0
							Loop
						EndIf
						If ! VldSaida(4)
							nX--
							Loop
						EndIf
						If lRetrocede
							If "00*" $ cTipoExp
								Return .f.
							Else
								cArmazem  := Space(Tamsx3("B1_LOCPAD")[1])
								cEndereco := Space(15)
								Exit
							EndIf
						EndIf
						Return .f.
					EndIf
				EndIf
			EndIf
			lSeparou  := .t.
			If ! CBProdUnit(aItens[nX,_POSCODPRO])  .or. UsaCB0("01")
				cCodEti := CB0->CB0_CODETI
			Else
				cCodEti := NIL
			End

			If ! Grava(nX,,cVolume,cCodEti)
				nX--
				Loop
			EndIf
			
			lFaltaSeparar:=.f.
			CB8->(DBSetOrder(1))
			CB8->(DbSeek(xFilial("CB8")+cOrdSep))
			While CB8->(! Eof() .and. CB8_FILIAL+CB8_ORDSEP == xFilial("CB8")+cOrdSep)
				If CB8->CB8_SALDOS > 0
					lFaltaSeparar:=.t.
				EndIf
				CB8->(DbSkip())
			End

			If lFaltaSeparar
				Reclock('CB7')
				CB7->CB7_STATUS := "1"  // inicio separacao
				CB7->(MsUnLock())
				lFaltaSeparar:=.f.
			EndIf

			If lMV_CFENDIG
				If Len(aItens) > nX  .and. aItens[nX,_POSCODPRO] # aItens[nX+1,_POSCODPRO]
					cArmazem   := Space(Tamsx3("B1_LOCPAD")[1])
					cEndereco  := Space(15)
				EndIf
			EndIf
			cEtiqEnd   := Space(TamSx3("CB0_CODET2")[1])
			cEtiqProd  := Space(TamSx3("CB0_CODET2")[1])
			cEtiqCaixa := Space(TamSx3("CB0_CODET2")[1])
			cEtiqAvulsa:= Space(TamSx3("CB0_CODET2")[1])
			cProduto   := IIf( FindFunction( 'AcdGTamETQ' ), AcdGTamETQ(), Space(48) )
			nQtde      := 0
			/*
			Recover
			nX:= 0
			End Sequence
			*/
		Next
		lRetSepara:=.f.
		If lSeparou
			Reclock('CB7')
			CB7->CB7_STATUS := "2"  // separacao finalizada
			CB7->CB7_DTFIMS := dDataBase
			CB7->CB7_HRFIMS := StrTran(Time(),":","")
			CB7->(MsUnLock())
		EndIf
	Else
		For nX:= 1 to len(aItens)
			//Begin Sequence
			lSaiEstorno:= .f.
			If aItens[nX] == nil
				Loop
			EndIf
			nQtdLida := 0
			If Empty(aItens[nX,_POSSLDSEP])
				Loop
			EndIf
			If ! aItens[nX,_POSARMAZEM]+aItens[nX,_POSENDERECO] == cArmazem+cEndereco .and. Empty(CB7->CB7_PRESEP)
				VTClear()
				cArmazem   := Space(Tamsx3("B1_LOCPAD")[1])
				cEndereco  := Space(15)
				cEtiqEnd   := Space(20)
				@ 1,0 VTSay STR0008 //'Va para o endereco'
				@ 2,0 VTSay aItens[nX,_POSARMAZEM]+'-'+aItens[nX,_POSENDERECO]
				If ! GETMV("MV_CONFEND") =="1"
					@ 6,0 VTPause STR0009 //'Enter para continuar'
				Else
					@ 4,0 VTSay STR0010 //'Leia o endereco'
					If UsaCB0('02')
						@ 5,0 VTGet cEtiqEnd pict '@!' valid VldEnd(,,cEtiqEnd,nX)
					Else
						@ 5,0 VTGet cArmazem pict '@!' valid ! Empty(cArmazem)
						@ 5,3 VTSay "-" VTGet cEndereco pict '@!' valid VtLastKey()==5 .or. VldEnd(cArmazem,cEndereco,,nX)
					EndIf
					VTRead
					If VTLastkey() == 27
						If lSaiEstorno
							nX := 0
							Loop
						EndIf
						If ! VldSaida(2)
							nX--
							Loop
						EndIf
						If lRetrocede
							If "00*" $ cTipoExp
								Return .f.
							Else
								cArmazem  := Space(Tamsx3("B1_LOCPAD")[1])
								cEndereco := Space(15)
								Exit
							EndIf
						EndIf
						Return .f.
					EndIf
				EndIf
				cArmazem := aItens[nX,_POSARMAZEM]
				cEndereco:= aItens[nX,_POSENDERECO]
			ElseIf ! Empty(CB7->CB7_PRESEP)
				cArmazem := aItens[nX,_POSARMAZEM]
				cEndereco:= aItens[nX,_POSENDERECO]
			EndIf
			VTClear()
			If GetNewPar("MV_OSEP2UN","0") $ "0 "
				@ 0,0 VTSay Padr(STR0011+Alltrim(Str(aItens[nX,_POSSLDSEP],TamSx3("CB8_QTDORI")[1],TamSx3("CB8_QTDORI")[2]))+If(aItens[nX,_POSSLDSEP]==1,STR0012,STR0013),20) //'Separe '###' item '###' itens '
			Else
				SB1->(DbSetOrder(1))
				SB1->(DbSeek(xFilial("SB1")+aItens[nX,_POSCODPRO]))
				nQtdCX:= CBQEmb()
				If ExistBlock('CBRQEESP')
					nQtdCX:=ExecBlock('CBRQEESP',,,SB1->B1_COD)
				EndIf

				If aItens[nX,_POSSLDSEP]/nQtdCX < 1
					@ 0,0 VTSay Padr(STR0011+Alltrim(Str(aItens[nX,_POSSLDSEP],TamSx3("CB8_QTDORI")[1],TamSx3("CB8_QTDORI")[2]))+If(aItens[nX,_POSSLDSEP]==1,STR0012,STR0013),20) //'Separe '###' item '###' itens '
				Else
					@ 0,0 VTSay Padr(STR0011+Alltrim(Str(aItens[nX,_POSSLDSEP]/nQtdCX,TamSx3("CB8_QTDORI")[1],TamSx3("CB8_QTDORI")[2]))+If(aItens[nX,_POSSLDSEP]/nQtdCX==1,STR0168,STR0169),20) //'Separe ' //" Volume"###" Volumes"
				EndIf
			EndIf
			cDescProd := Posicione("SB1",1,xFilial('SB1')+aItens[nX,_POSCODPRO],"B1_DESC")
			If	lACD170DES
				cRetPE    := ExecBlock("ACD170DES", .F., .F., {aItens[nX,_POSCODPRO]})
				cDescProd := If(ValType(cRetPe)=="C",cRetPE,cDescProd)
			EndIf
			@ 1,0 VTSay aItens[nX,_POSCODPRO]
			@ 2,0 VTSay PADR(cDescProd,VTMaxCol())
			If Rastro(aItens[nX,_POSCODPRO],"L")
				@ 3,0 VTSay STR0014 //'Lote       '
				@ 4,0 VTSay aItens[nX,_POSLOTECTL]
			ElseIf Rastro(aItens[nX,_POSCODPRO],"S")
				@ 3,0 VTSay STR0015 //'Lote       SubLote'
				@ 4,0 VTSay aItens[nX,_POSLOTECTL]+' '+aItens[nX,_POSNUMLOTE]
			EndIf
			If ! CBProdUnit(aItens[nX,_POSCODPRO])  // granel
				cEtiqCaixa := Space(TamSx3("CB0_CODET2")[1])
				@ 6,0 VTSay STR0016 //"Leia a caixa"
				@ 7,0 VtGet cEtiqCaixa pict '@!' Valid VldCaixa(cEtiqCaixa,nX) .and. AtvP(.f.) When AtvP(.t.)
				VtRead
				AtvP(.f.)
				If VTLastkey() == 27
					If lSaiEstorno
						nX := 0
						Loop
					Endif
					If ! VldSaida(2)
						nX--
						Loop
					EndIf
					If lRetrocede
						If "00*" $ cTipoExp
							Return .f.
						Else
							cArmazem  := Space(Tamsx3("B1_LOCPAD")[1])
							cEndereco := Space(15)
							Exit
						EndIf
					EndIf
					Return .f.
				EndIf
				If PulaItem(nX)
					nX--
					Loop
				EndIf
				cEtiqAvulsa:= Space(TamSx3("CB0_CODET2")[1])
				@ 6,0 VTClear to 7,19
				@ 6,0 VTSay STR0017 //"Leia a etiq. avulsa"
				@ 7,0 VtGet cEtiqAvulsa pict '@!' Valid VldEtiqAvulsa(cEtiqAvulsa,nX).and. AtvP(.f.) When AtvP(.t.)
				VtRead
				AtvP(.f.)
				If VTLastkey() == 27
					If lSaiEstorno
						nX := 0
						Loop
					Endif
					If ! VldSaida(2)
						nX--
						Loop
					EndIf
					If lRetrocede
						If "00*" $ cTipoExp
							Return .f.
						Else
							cArmazem  := Space(Tamsx3("B1_LOCPAD")[1])
							cEndereco := Space(15)
							Exit
						EndIf
					EndIf
					Return .f.
				EndIf
			Else
				If UsaCB0("01")
					cEtiqProd  := Space(TamSx3("CB0_CODET2")[1])
					If ! Empty(aItens[nX,_POSNUMSERIE])
						@ 5,0 VTSay STR0170 //"Numero de Serie "
						@ 6,0 VTSay aItens[nX,_POSNUMSERIE]
						@ 7,0 VTPause STR0009 //'Enter para continuar'
						VTClear()
						@ 0,0 VTSay STR0018 //'Leia a etiqueta'
						@ 2,0 VTGet cEtiqProd pict '@!' Valid VldEti(cEtiqProd,nX) .and. AtvP(.f.) When AtvP(.t.)
					Else
						@ 6,0 VTSay STR0018 //'Leia a etiqueta'
						@ 7,0 VTGet cEtiqProd pict '@!' Valid VldEti(cEtiqProd,nX) .and. AtvP(.f.) When AtvP(.t.)
					EndIf
					VTRead
					AtvP(.f.)
					If VTLastkey() == 27
						If lSaiEstorno
							nX := 0
							Loop
						Endif
						If ! VldSaida(2)
							nX--
							Loop
						EndIf
						If lRetrocede
							If "00*" $ cTipoExp
								Return .f.
							Else
								cArmazem  := Space(Tamsx3("B1_LOCPAD")[1])
								cEndereco := Space(15)
								Exit
							EndIf
						EndIf
						Return .f.
					EndIf
				Else
					nQtde := 1
					cProduto   := IIf( FindFunction( 'AcdGTamETQ' ), AcdGTamETQ(), Space(48) )
					If ! Empty(aItens[nX,_POSNUMSERIE])
						@ 5,0 VTSay STR0170 //"Numero de Serie "
						@ 6,0 VTSay aItens[nX,_POSNUMSERIE]
						@ 7,0 VTPause STR0009 //'Enter para continuar'
						VTClear()
						@ 0,0 VTSay STR0019 VtGet nQtde pict cPictQtdExp valid VldQtde(nQtde,.T.) when (lForcaQtd .or. VTLastkey() == 5) //'Qtde '
						@ 2,0 VTSay STR0020 //'Leia o produto'
						@ 3,0 VTGet cProduto pict '@!' VALID VTLastkey() == 5 .or. VldProd(cProduto,nX,nQtde).and. AtvP(.f.) When AtvP(.t.)
					Else
						@ 5,0 VTSay STR0019 VtGet nQtde pict cPictQtdExp valid VldQtde(nQtde) when (lForcaQtd .or. VTLastkey() == 5) //'Qtde '
						@ 6,0 VTSay STR0020 //'Leia o produto'
						@ 7,0 VTGet cProduto pict '@!' VALID VTLastkey() == 5 .or. VldProd(cProduto,nX,nQtde).and. AtvP(.f.) When AtvP(.t.)
					EndIf
					VTRead
					AtvP(.f.)
					If VTLastkey() == 27
						If lSaiEstorno
							nX := 0
							Loop
						Endif
						If ! VldSaida(2)
							nX--
							Loop
						EndIf
						If lRetrocede
							If "00*" $ cTipoExp
								Return .f.
							Else
								cArmazem  := Space(Tamsx3("B1_LOCPAD")[1])
								cEndereco := Space(15)
								Exit
							EndIf
						EndIf
						Return .f.
					EndIf
				EndIf
			EndIf
			lSeparou:= .t.
			If PulaItem(nX)
				nX--
				Loop
			EndIf
			If ! CBProdUnit(aItens[nX,_POSCODPRO])  .or. UsaCB0("01")
				cCodEti := CB0->CB0_CODETI
			Else
				cCodEti := NIL
			EndIf

			Reclock('CB7')
			CB7->CB7_STATUS := "1"  // inicio separacao
			CB7->(MsUnLock())

			If ! Grava(nX,,cVolume,cCodEti)
				nX--
				Loop
			EndIf

			If ! Empty(aItens[nX,_POSSLDSEP])
				nX--
			Else
				If lMV_CFENDIG
					If Len(aItens) > nX  .and. aItens[nX+1]#NIL .and.  aItens[nX,_POSCODPRO] # aItens[nX+1,_POSCODPRO]
						cArmazem   := Space(Tamsx3("B1_LOCPAD")[1])
						cEndereco  := Space(15)
					EndIf
				EndIf
				cEtiqEnd   := Space(TamSx3("CB0_CODET2")[1])
				cEtiqProd  := Space(TamSx3("CB0_CODET2")[1])
				cEtiqCaixa := Space(TamSx3("CB0_CODET2")[1])
				cEtiqAvulsa:= Space(TamSx3("CB0_CODET2")[1])
				cProduto   := IIf( FindFunction( 'AcdGTamETQ' ), AcdGTamETQ(), Space(48) )
				nQtde      := 0
			EndIf
			/*
			Recover
			nX:= 0
			End Sequence
			*/
		Next
		If lSeparou
			Reclock('CB7')
			CB7->CB7_STATUS := "2"  // separacao finalizada
			CB7->CB7_DTFIMS := dDataBase
			CB7->CB7_HRFIMS := StrTran(Time(),":","")
			CB7->(MsUnLock())
		EndIf
	EndIf

	If lRetrocede
		AtvRet(.f.)
		Loop
	EndIf

	lSeparou:=.t.
	CB8->(DBSetOrder(1))
	CB8->(DbSeek(xFilial("CB8")+cOrdSep))
	While CB8->(! Eof() .and. CB8_FILIAL+CB8_ORDSEP == xFilial("CB8")+cOrdSep)
		If !Empty(CB8->CB8_SALDOS)
			lSeparou:=.f.
		EndIf
		CB8->(DbSkip())
	End
	If lACD170SEP
		ExecBlock("ACD170SEP",,,{CB7->CB7_ORDSEP})
	EndIf

	If "02" $ cTipoExp .and. lSeparou .and. CB7->CB7_STATUS < '3' .and. ! VTYesNo(STR0021,STR0007,.t.) //'Deseja embalar agora?'###'Aviso'
		AtvRet(.f.)
		AtvAva(.f.)
		Return .f.
	EndIf
	Exit
Enddo
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ VldEnd   ³ Autor ³ ACD                   ³ Data ³ 03/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Funcao auxiliar chamada pela funcao Separa                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function VldEnd(cArmazem,cEndereco,cEtiqEnd,nX)
Local aRet
Local lRet := .T.
VtClearBuffer()
If Empty(cEtiqEnd) .and. UsaCB0('02')
	VtBeep(3)
	VtAlert(STR0022,STR0002,.t.,4000) //"Etiqueta invalida"###"Aviso"
	VtKeyboard(Chr(20))  // zera o get
	lRet := .F.
EndIf
If lRet .And. cArmazem == NIL // se cArmazem == NIL entao e' etiqueta de endereco com CB0
	aRet := CBRetEti(cEtiqEnd,'02')
	If len(aRet) == 0
		VtBeep(3)
		VtAlert(STR0022,STR0002,.t.,4000) //"Etiqueta invalida"###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		lRet := .F.
	EndIf
	cArmazem  := aRet[2]
	cEndereco := aRet[1]
EndIf
If lRet .And. !(cArmazem+cEndereco == aItens[nX,_POSARMAZEM]+aItens[nX,_POSENDERECO] )
	VtBeep(3)
	VtAlert(STR0023,STR0002,.t.,4000) //"Endereco incorreto"###"Aviso"
	VTClearGet("cArmazem")
	VTClearGet("cEndereco")
	VTGetSetFocus("cArmazem")
	VtKeyboard(Chr(20))  // zera o get
	lRet := .F.
EndIf
If lRet .And. !CBEndLib(cArmazem,cEndereco) // verifica se o endereco esta liberado ou bloqueado
	VtBeep(3)
	VtAlert(STR0024,STR0002,.t.,4000) //"Endereco Bloqueado."###"Aviso"
	VTClearGet("cArmazem")
	VTClearGet("cEndereco")
	VTGetSetFocus("cArmazem")
	VtKeyboard(Chr(20))  // zera o get
	lRet := .F.
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ VldCodSep³ Autor ³ ACD                   ³ Data ³ 03/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Validacao da Ordem de Separacao                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function VldCodSep()
Local nPos
Local lRetPE := .T.
Local lACD166VL := ExistBlock("ACD166VL")

aItens := {}

If Empty(cOrdSep)
	VtKeyBoard(chr(23))
	Return .f.
EndIf

CB7->(DbSetOrder(1))
CB7->(DbSeek(xFilial("CB7")+cOrdSep))
If CB7->(Eof())
	VtBeep(3)
	VtAlert(STR0025,STR0002,.t.,4000) //"Ordem de separacao nao encontrada."###"Aviso"
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
EndIf
If "09*"  $ CB7->CB7_TIPEXP
	VtBeep(3)
	VtAlert(STR0171,STR0002,.t.,4000)  //"O Codigo informado trata-se de uma Ordem de Pre-Separacao, verifique !!!"###"Aviso"
	VtKeyboard(Chr(20))  // zera o get
	Return .f.
Endif
If "03" $ CB7->CB7_TIPEXP .AND. GETMV('MV_PDEVLOC') # 1 //Se gera nota verificar o parametro MV_PDEVLOC
	VtBeep(3)
	VtAlert(STR0172,STR0173,.t.,4000)  //"O MV_PDEVLOC deve estar com conteudo ---> 1 <---"###"Parametro Invalido"
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
EndIf
If CB7->CB7_STATUS == "9"
	// --- Ponto de entrada para desativar pergunta nao deixando o operador modificar O.S.
	If lACD166VL
		lRetPe := ExecBlock("ACD166VL")
		lRetPe := If(ValType(lRetPe)=="L",lRetPe,.T.)
	EndIf
	If !lRetPe .Or. ! VTYesNo(STR0026,STR0027,.T.) //'Ordem encerrada, deseja modifica-la?'###'Atencao'
		VtKeyboard(Chr(20))  // zera o get
		AtvRet(.f.)
		AtvAva(.f.)
		Return .F.
	EndIf
	lDesfazTudo:=.t.
	//cUltTipoExp:=Subs(Alltrim(CB7->CB7_TIPEXP),Len(Alltrim(CB7->CB7_TIPEXP))-2,Len(Alltrim(CB7->CB7_TIPEXP)))
	// analisar a pergunta '00-Separcao,01-Separacao/Embalagem,02-Embalagem,03-Gera Nota,04-Imp.Nota,05-Imp.Volume,06-embarque'
	If cUltTipoExp == "00*"
		CBFlagSC5("1",cOrdSep)  //Em separacao
		lProcSep     := .t.
		lProcEmbFim  := .f.
		lProcGeraNF  := .f.
		lProcEmbarque:= .f.
		lProcReqOP   := .f.
	ElseIf cUltTipoExp == "01*"
		CBFlagSC5("1",cOrdSep)  //Em separacao
		lProcSep     := .f.
		lProcEmbFim  := .t.
		lProcGeraNF  := .f.
		lProcEmbarque:= .f.
		lProcReqOP   := .f.
	ElseIf cUltTipoExp == "02*"
		CBFlagSC5("2",cOrdSep)  //Em processo de embalagem
		lProcSep     := .f.
		lProcEmbFim  := .t.
		lProcGeraNF  := .f.
		lProcEmbarque:= .f.
		lProcReqOP   := .f.
//		lEstEmbalagem:=.t.
	ElseIf cUltTipoExp == "03*"
		CBFlagSC5("2",cOrdSep)  //Em processo de embalagem
		lProcSep     := .f.
		lProcEmbFim  := .f.
		lProcGeraNF  := .t.
		lProcEmbarque:= .f.
		lProcReqOP   := .f.
		lExcluiNF    := .t.
	ElseIf cUltTipoExp == "04*"
		CBFlagSC5("2",cOrdSep)  //Em processo de embalagem
		If '03' $ CB7->CB7_TIPEXP
			lProcSep     := .f.
			lProcEmbFim  := .f.
			lProcGeraNF  := .t.
			lProcEmbarque:= .f.
			lProcReqOP   := .f.
		ElseIf '01' $ CB7->CB7_TIPEXP .or. '02' $ CB7->CB7_TIPEXP
			lProcSep     := .f.
			lProcEmbFim  := .t.
			lProcGeraNF  := .f.
			lProcEmbarque:= .f.
			lProcReqOP   := .f.
		ElseIf '00' $ CB7->CB7_TIPEXP
			lProcSep     := .t.
			lProcEmbFim  := .f.
			lProcGeraNF  := .f.
			lProcEmbarque:= .f.
			lProcReqOP   := .f.
		EndIf
	ElseIf cUltTipoExp == "05*"
		CBFlagSC5("2",cOrdSep)  //Em processo de embalagem
		If '03' $ CB7->CB7_TIPEXP
			lProcSep     := .f.
			lProcEmbFim  := .f.
			lProcGeraNF  := .t.
			lProcEmbarque:= .f.
			lProcReqOP   := .f.
		ElseIf '01' $ CB7->CB7_TIPEXP .or. '02' $ CB7->CB7_TIPEXP
			lProcSep     := .f.
			lProcEmbFim  := .t.
			lProcGeraNF  := .f.
			lProcEmbarque:= .f.
			lProcReqOP   := .f.
		ElseIf '00' $ CB7->CB7_TIPEXP
			lProcSep     := .t.
			lProcEmbFim  := .f.
			lProcGeraNF  := .f.
			lProcEmbarque:= .f.
			lProcReqOP   := .f.
		EndIf
	ElseIf cUltTipoExp == "06*"
		CBFlagSC5("3",cOrdSep)  //Em processo de embarque
		lProcSep     := .f.
		lProcEmbFim  := .f.
		lProcGeraNF  := .f.
		lProcEmbarque:= .t.
		lProcReqOP   := .f.
	ElseIf cUltTipoExp == "07*"
		lProcSep     := .f.
		lProcEmbFim  := .f.
		lProcGeraNF  := .f.
		lProcEmbarque:= .f.
		lProcReqOP   := .t.
	EndIf
Else
	If CB7->CB7_STATUS # "0" .AND. CB7->CB7_STATPA == "1" .AND. CB7->CB7_CODOPE # cCodOpe  // SE ESTIVER EM SEPARACAO E PAUSADO SE DEVE VERIFICAR SE O OPERADOR E' O MESMO
		VtBeep(3)
		If !VTYesNo(STR0174+CB7->CB7_CODOPE+STR0175,STR0027,.T.) //"Ordem Separacao iniciada pelo operador "###". Deseja continuar ?"
			VtKeyboard(Chr(20))  // zera o get
			Return .F.
		EndIf
	ElseIf CB7->CB7_STATUS # "0" .AND. CB7->CB7_STATPA == " "  //Ordem Separacao ja esta em andamento...
		VtBeep(3)
		VtAlert(STR0176,STR0002,.t.,4000) //"Ordem de Separacao ja esta em andamento por outro operador!"
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
EndIf
DbSelectArea("CB8")
DbSetOrder(3)
DbSeek(xFilial("CB8")+cOrdSep)
While ! CB8->(Eof()) .and. CB8->CB8_FILIAL == xFilial("CB8") .and. CB8->CB8_ORDSEP == cOrdSep
	SB1->(DbSetOrder(1))
	SB1->(DbSeek(xFilial("SB1")+CB8->CB8_PROD))
	SB5->(DbSetOrder(1))
	SB5->(DbSeek(xFilial("SB5")+CB8->CB8_PROD))
	nPos := Ascan(aItens,{|x| x[3]+x[4]+x[5]+x[8]+x[9]+x[10]+X[13] == CB8->(CB8_PROD+CB8_LOCAL+CB8->CB8_LCALIZ+CB8_LOTECT+CB8_NUMLOT+CB8_NUMSER+CB8_CFLOTE)})

	If  nPos == 0
		aadd(aItens,{{CB8->(Recno())},;
						CB8->CB8_ITEM,;
						CB8->CB8_PROD,;
						CB8->CB8_LOCAL,;
						CB8->CB8_LCALIZ,;
						CB8->CB8_SALDOS,;
						CB8->CB8_QTDORI,;
						CB8->CB8_LOTECT,;
						CB8->CB8_NUMLOT,;
						CB8->CB8_NUMSER,;
						NIL,;
						NIL,;
						CB8->CB8_CFLOTE })
	Else
		If Ascan(aItens[nPos,1],{|x| x == CB8->(Recno())}) == 0
			aadd(aItens[nPos,1],CB8->(Recno()))
		EndIf
		aItens[nPos,6]+=CB8->CB8_SALDOS
		aItens[nPos,7]+=CB8->CB8_QTDORI
	EndIf
	CB8->(DbSkip())
EndDo
aItens := aSort(aItens,,,{|x,y| x[4]+x[5]+x[8]+x[9]+x[10] < y[4]+y[5]+y[8]+y[9]+y[10]})

//CB7_STATUS:
//0-Nao Iniciada;01-Em Separacao;02-Separacao Finalizada;3-Em processo embalagem;4-Embalagem Finalizada;5-Gera Nota;6-Imprime nota;7-Imprime Volume;8-Em processo embarque;9-Embarcado/Finalizado
If CB7->CB7_STATUS == "0" .or. Empty(CB7->CB7_STATUS)
	CBFlagSC5("1",cOrdSep)  //Em separacao
	RecLock("CB7")
	CB7->CB7_STATUS := "1"  // em separacao
	CB7->CB7_DTINIS := dDataBase
	CB7->CB7_HRINIS := StrTran(Time(),":","")
	CB7->(MsUnlock())
ElseIf CB7->CB7_STATUS == "1"
	CBFlagSC5("1",cOrdSep)  //Em separacao
ElseIf CB7->CB7_STATUS >= "2" .and. CB7->CB7_STATUS <= "7"
	CBFlagSC5("2",cOrdSep)  //Em processo de embalagem
ElseIf CB7->CB7_STATUS == "8"
	CBFlagSC5("3",cOrdSep)  //Em processo de embarque
EndIf

RecLock("CB7")
If !Empty(CB7->CB7_STATPA)  // se estiver pausado tira o STATUS  de pausa
	CB7->CB7_STATPA := " "
EndIf
CB7->CB7_CODOPE := cCodOpe
CB7->(MsUnlock())
cTipoExp:= CB7->CB7_TIPEXP
cOriExp := CB7->CB7_ORIGEM
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ VldCaixa ³ Autor ³ ACD                   ³ Data ³ 03/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Funcao auxiliar chamada pela Funcao Separa                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function VldCaixa(cEtiqAvulsa,nX)
Local cCodPro
Local aRet

If _lPulaItem .or. lSaiEstorno
	Return .t.
EndIf
If Empty(cEtiqAvulsa)
	Return .f.
EndIf
If UsaCB0("01")
	aRet := CBRetEti(cEtiqAvulsa,"01")
	If len(aRet) == 0
		VtBeep(3)
		VtAlert(STR0022,STR0002,.t.,4000) //"Etiqueta invalida"###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
	cCodPro := aRet[1]
	If ! Empty(aRet[2])
		VtBeep(3)
		VtAlert(STR0022,STR0002,.t.,4000) //"Etiqueta invalida"###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
Else
	If !CBLoad128(@cEtiqAvulsa)
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
	If ! CbRetTipo(cEtiqAvulsa) $ "EAN8OU13-EAN14-EAN128"
		VtBeep(3)
		VtAlert(STR0022,STR0002,.t.,4000) //"Etiqueta invalida"###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
	aRet     := CBRetEtiEan(cEtiqAvulsa)
	If len(aRet) == 0
		VtBeep(3)
		VtAlert(STR0022,STR0002,.t.,4000) //"Etiqueta invalida"###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
	cCodPro := aRet[1]
EndIf

If ! CBProdLib(cArmazem,cCodPro)
	VTKeyBoard(chr(20))
	Return .f.
EndIF
If !(aItens[nX,_POSCODPRO] == cCodPro)
	VtBeep(3)
	VtAlert(STR0030,STR0002,.t.,4000) //"Etiqueta de produto diferente"###"Aviso"
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
EndIf
Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ VldEtiqAvulsa³ Autor ³ ACD               ³ Data ³ 03/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Funcao auxiliar chamada pela funcao Separa                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function VldEtiqAvulsa(cEtiqAvulsa,nX)
Local nQE
Local cLote    := Space(10)
Local cSLote   := Space(6)

Local aEtiqueta:={}
If _lPulaItem .or. lSaiEstorno
	Return .t.
EndIf
If Empty(cEtiqAvulsa)
	Return .f.
EndIf
If Len(CBRetEti(cEtiqAvulsa)) > 0
	VtBeep(3)
	VtAlert(STR0022,STR0002,.t.,4000) //"Etiqueta invalida"###"Aviso"
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
EndIf
CBGrvEti("01",{aItens[nX,_POSCODPRO],0,cCodOpe},Padr(cEtiqAvulsa,10))
nQE  :=CBQtdEmb(aItens[nX,_POSCODPRO])
If Empty(nQE)
	VtBeep(3)
	VtAlert(STR0031,STR0002,.t.,4000) //"Quantidade invalida"###"Aviso"
	VtKeyboard(Chr(20))  // zera o get
	RecLock('CB0',.f.)
	CB0->(DbDelete())
	CB0->(MSUnlock())
	Return .F.
EndIf
If nQE > aItens[nX,_POSSLDSEP]
	VtBeep(3)
	VtAlert(STR0032,STR0002,.t.,4000) //"Quantidade maior que solicitado"###"Aviso"
	VtKeyboard(Chr(20))  // zera o get
	RecLock('CB0',.f.)
	CB0->(DbDelete())
	CB0->(MSUnlock())
	Return .f.
EndIf
CBGrvEti("01",{NIL,nQE,NIL},Padr(cEtiqAvulsa,10))
If CBRastro(aItens[nX,_POSCODPRO],@cLote,@cSLote)
	If aItens[nX,_POSCFLOTE] == "1"
		If ! cLote+cSLote == aItens[nX,_POSLOTECTL]+aItens[nX,_POSNUMLOTE]
			VtBeep(3)
			VtAlert(STR0033,STR0002,.t.,4000) //"Lote invalido"###"Aviso"
			VtKeyboard(Chr(20))  // zera o get
			Return .F.
		EndIf
	EndIf
	If  GetMv('MV_ESTNEG') =='N'
		nSaldo := SaldoSBF(aItens[nX,_POSARMAZEM],aItens[nX,_POSENDERECO],aItens[nX,_POSCODPRO],,cLote,cSLote,.T.)
		If nQE > nSaldo
			VtBeep(3)
			VtAlert(STR0034,STR0002,.t.,4000) //"Saldo em estoque insuficiente"###"Aviso"
			VtKeyboard(Chr(20))  // zera o get
			Return .F.
		EndIf
	Else
		If ! CBExistLot(aItens[nX,_POSCODPRO],aItens[nX,_POSARMAZEM],aItens[nX,_POSENDERECO],cLote,cSLote)
			VtBeep(3)
			VtAlert(STR0035,STR0002,.t.,4000) //"Lote nao existe"###"Aviso"
			VtKeyboard(Chr(20))  // zera o get
			Return .F.
		EndIf
	EndIf

	aEtiqueta:= CBRetEti(Padr(cEtiqAvulsa,10),"01")
	aEtiqueta[16]:=cLote
	aEtiqueta[17]:=cSLote
	CBGrvEti("01",aEtiqueta,Padr(cEtiqAvulsa,10))
Else
	VTKeyBoard(chr(20))
	Return .f.
EndIf
cLoteNew:= cLote
cSLoteNew:=cSLote
nQtdLida := nQE
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ VldEti   ³ Autor ³ ACD                   ³ Data ³ 03/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Funcao auxiliar chamada pela funcao Separa - Tem como      ³±±
±±³			 ³ objetivo validar a etiqueta do Produto com Codigo Interno  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function VldEti(cEtiqProd,nX)
Local cLote := Space(10)
Local cSLote:= Space(6)
Local cNewEtiq
Local aEtiqueta:={}
Local aNewEtiq :={}
If _lPulaItem .or. lSaiEstorno
	Return .t.
EndIf
If Empty(cEtiqProd)
	Return .f.
EndIf

aEtiqueta:= CBRetEti(cEtiqProd,"01")
If Empty(aEtiqueta)
	VtBeep(3)
	VtAlert(STR0022,STR0002,.t.,4000) //"Etiqueta invalida"###"Aviso"
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
EndIf
If ! aItens[nX,_POSARMAZEM]+ aItens[nX,_POSENDERECO] == aEtiqueta[10]+aEtiqueta[9]
	VtBeep(3)
	VtAlert(STR0036,STR0002,.t.,4000) //"Endereco diferente"###"Aviso"
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
EndIf

If !  aItens[nX,_POSCODPRO] == aEtiqueta[1]
	VtBeep(3)
	VtAlert(STR0037,STR0002,.t.,4000) //"Produto diferente"###"Aviso"
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
EndIf
If ! CBProdLib(aEtiqueta[10],aEtiqueta[1])
	VTKeyBoard(chr(20))
	Return .f.
EndIF

cLote  := aEtiqueta[16]
cSLote := aEtiqueta[17]
If aItens[nX,_POSCFLOTE] =="1"
	If ! cLote+cSLote == aItens[nX,_POSLOTECTL]+aItens[nX,_POSNUMLOTE]
		VtBeep(3)
		VtAlert(STR0033,STR0002,.t.,4000) //"Lote invalido"###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
EndIf

If CB0->CB0_NUMSER # aItens[nX,_POSNUMSERIE]
	VtBeep(3)
	VtAlert(STR0177,STR0002,.t.,3000) //"Etiqueta Invalida !!!"###"Aviso"
	VtAlert(STR0178+aItens[nX,_POSNUMSERIE]   ,STR0002,.t.,4000) //"Informe a etiqueta com o Numero de Serie "###"Aviso"
	VtKeyboard(Chr(20))  // zera o get
	Return .f.
Endif

If ExistBlock('ACD170VE')
	aEtiqueta:=ExecBlock('ACD170VE',,,aEtiqueta)
	If Empty(aEtiqueta)
		Return .f.
	EndIf
EndIf
If CBQtdVar(aEtiqueta[1]) .and. aEtiqueta[2] > aItens[nX,_POSSLDSEP]
	cNewEtiq:= GeraNewEti(aItens[nX,_POSSLDSEP])
	aNewEtiq:= CBRetEti(cNewEtiq,"01")
ElseIf aEtiqueta[2] > aItens[nX,_POSSLDSEP]
	VtBeep(3)
	VtAlert(STR0038,STR0002,.t.,4000) //"Quantidade maior que necessario"###"Aviso"
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
EndIf
If Empty(aNewEtiq)
	nQtdLida := aEtiqueta[2]
	cLoteNew := cLote
	cSLoteNew:= cSLote
Else
	cEtiqProd:= CB0->CB0_CODETI
	nQtdLida := aNewEtiq[2]
	cLoteNew := aNewEtiq[16]
	cSLoteNew:= aNewEtiq[17]
Endif

DbSelectArea("CB9")
DbSetOrder(3)
If DbSeek(xFilial("CB9")+aEtiqueta[1]+cEtiqProd)
	VtAlert(STR0200,STR0002,.T.,4000,3)//"Etiqueta ja separada","AVISO"
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
EndIf

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ VldProd  ³ Autor ³ ACD                   ³ Data ³ 03/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Funcao auxiliar chamada pela funcao Separa - Tem como      ³±±
±±³			 ³ objetivo validar o Produto com utilizacao de Codigo Natural³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function VldProd(cProduto,nX,nQtde)
Local aRet   := {}
Local nSaldo := 0
Local cLote  := Space(10)
Local cSLote := Space(6)
Local cNumSer:= Space(20)

If _lPulaItem .or. lSaiEstorno
	Return .t.
EndIf

If Empty(cProduto)
	Return .f.
EndIf

If !CBLoad128(@cProduto)
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
EndIf
If ! CBRetTipo(cProduto) $ "EAN8OU13-EAN14-EAN128"
	VtBeep(3)
	VtAlert(STR0022,STR0002,.t.,4000) //"Etiqueta invalida"###"Aviso"
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
EndIf
aRet     := CBRetEtiEan(cProduto)
If len(aRet) == 0
	VtBeep(3)
	VtAlert(STR0022,STR0002,.t.,4000) //"Etiqueta invalida"###"Aviso"
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
EndIf

If !  aItens[nX,_POSCODPRO] == aRet[1]
	VtBeep(3)
	VtAlert(STR0037,STR0002,.t.,4000) //"Produto diferente"###"Aviso"
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
EndIf

cLote := aRet[3]
If ! CBProdLib(cArmazem,aRet[1])
	VTKeyBoard(chr(20))
	Return .f.
EndIF
cNumSer:= aRet[5]	 // Numero de Serie
If ! CBRastro(aItens[nX,_POSCODPRO],@cLote,@cSLote)
	VTKeyBoard(chr(20))
	Return .f.
EndIf

If aItens[nX,_POSCFLOTE] == "1"
	If ! cLote+cSLote == aItens[nX,_POSLOTECTL]+aItens[nX,_POSNUMLOTE]
		VtBeep(3)
		VtAlert(STR0033,STR0002,.t.,4000) //"Lote invalido"###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
EndIf

If CBSeekNumSer(cOrdSep,aItens[nX,_POSCODPRO])
	If ! VldQtde(nQtde,.T.)
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	Endif
	If ! CBNumSer(@cNumSer,aItens[nX,_POSNUMSERIE])
		VTKeyBoard(chr(20))
		Return .f.
	EndIf
EndIf
If aRet[2]*nQtde > aItens[nX,_POSSLDSEP]
	VtBeep(3)
	VtAlert(STR0038,STR0002,.t.,4000) //"Quantidade maior que necessario"###"Aviso"
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
EndIf
If CB7->CB7_ORIGEM # "2"
	If GetMv('MV_ESTNEG') =='N'
		nSaldo := SaldoSBF(aItens[nX,_POSARMAZEM],aItens[nX,_POSENDERECO],aItens[nX,_POSCODPRO],,cLote,cSLote,.T.)
		If aRet[2]*nQtde > nSaldo
			VtBeep(3)
			VtAlert(STR0034,STR0002,.t.,4000) //"Saldo em estoque insuficiente"###"Aviso"
			VtKeyboard(Chr(20))  // zera o get
			Return .F.
		EndIf
	Else
		If ! CBExistLot(aItens[nX,_POSCODPRO],aItens[nX,_POSARMAZEM],aItens[nX,_POSENDERECO],cLote,cSLote)
			VtBeep(3)
			VtAlert(STR0035,STR0002,.t.,4000) //"Lote nao existe"###"Aviso"
			VtKeyboard(Chr(20))  // zera o get
			Return .F.
		EndIf
	EndIf
EndIf
nQtdLida := aRet[2]*nQtde
cLoteNew:= cLote
cSLoteNew:=cSLote
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ VldSaida ³ Autor ³ ACD                   ³ Data ³ 03/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Valida as saidas das rotinas                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function VldSaida(nLocal)
Local nRegs:=0
Local lFaltaSeparar:=.f., lFaltaEmbalar:=.f., lEmbalou:=.f., cTipoEstorno

If (lAvanca .or. lRetrocede) .and. nLocal <> 5 .and. nLocal <> 6 .and. nLocal <> 8
	If nLocal == 1
		AtvRet(.f.)
		AtvAva(.f.)
		Return .f.
	ElseIf nLocal == 2
		CB8->(DBSetOrder(1))
		CB8->(DbSeek(xFilial("CB8")+cOrdSep))
		While CB8->(! Eof() .and. CB8_FILIAL+CB8_ORDSEP == xFilial("CB8")+cOrdSep)
			If CB8->CB8_SALDOS <= CB8->CB8_QTDORI
				lFaltaSeparar:=.t.
			EndIf
			CB8->(DbSkip())
		End
		If lRetrocede
			AtvAva(.f.)
			If lFaltaSeparar
				Return .t.
			Else
				Return .f.
			EndIf
		ElseIf lAvanca
			AtvRet(.f.)
			AtvAva(.f.)
			If lFaltaSeparar
				Return .f.
			Else
				Return .t.
			EndIf
		EndIf
	ElseIf nLocal == 3  //Get volume oficial
		If "00" $ cTipoExp .or. "01" $ cTipoExp
			CB9->(DBSetOrder(1))
			CB9->(DbSeek(xFilial("CB9")+cOrdSep))
			While CB9->(! Eof() .and. CB9_FILIAL+CB9_ORDSEP == xFilial("CB9")+cOrdSep)
				If "00" $ cTipoExp
					If Empty(CB9->CB9_VOLUME)
						lFaltaEmbalar:=.t.
					Else
						lEmbalou:=.t.
					EndIf
				ElseIf "01" $ cTipoExp
					If "02" $ cTipoExp
						If Empty(CB9->CB9_VOLUME)
							lFaltaEmbalar:=.t.
						Else
							lEmbalou:=.t.
						EndIf
					ElseIf ! "02" $ cTipoExp
						If Empty(CB9->CB9_SUBVOL)
							lFaltaEmbalar:=.t.
						Else
							lEmbalou:=.t.
						EndIf
					EndIf
				EndIf
				CB9->(DbSkip())
			End
			If lAvanca  //Verificar se todos os itens foram embalados oficialmente...possuem volume e sub-volume...
				AtvRet(.f.)
				If lFaltaEmbalar
					AtvAva(.f.)
					Return .f.
				Else
					Return .t.
				EndIf
			ElseIf lRetrocede
				If lEmbalou
					CB9->(DBSetOrder(1))
					CB9->(DbSeek(xFilial("CB9")+cOrdSep))
					While CB9->(! Eof() .and. CB9_FILIAL+CB9_ORDSEP == xFilial("CB9")+cOrdSep)
						If ! Empty(CB9->CB9_VOLUME)
							If !VTYesNo(STR0147,STR0027,.T.)			 //'Estorna volumes ?'###'Atencao'
								AtvRet(.f.)
								AtvAva(.f.)
								Return .f.
							Else
								Estorna()
								CB9->(DbSeek(xFilial("CB9")+cOrdSep))
								Loop
							EndIf
						EndIf
						CB9->(DbSkip())
					End
					//desfaz separacao?.......rotina abaixo...
				Else
					lRetSepara:=.t.
					Return .t.
				EndIf
			EndIf
		EndIf
	ElseIf nLocal == 4  //Get separacao again...
		CB8->(DBSetOrder(1))
		CB8->(DbSeek(xFilial("CB8")+cOrdSep))
		While CB8->(! Eof() .and. CB8_FILIAL+CB8_ORDSEP == xFilial("CB8")+cOrdSep)
			If CB8->CB8_SALDOS > 0
				lFaltaSeparar:=.t.
			EndIf
			CB8->(DbSkip())
		End
		If lRetrocede
			AtvAva(.f.)
			If lFaltaSeparar
				Return .t.
			Else
				AtvRet(.f.)
				Return .f.
			EndIf
		ElseIf lAvanca
			AtvRet(.f.)
			If lFaltaSeparar
				AtvAva(.f.)
				Return .f.
			Else
				Return .t.
			EndIf
		EndIf
	ElseIf nLocal == 7  //Em processo de embarque
		If lAvanca
			AtvRet(.f.)
			AtvAva(.f.)
			Return .f.
		ElseIf lRetrocede
			CB9->(DBSetOrder(1))
			CB9->(DbSeek(xFilial("CB9")+cOrdSep))
			While CB9->(! Eof() .and. CB9_FILIAL+CB9_ORDSEP == xFilial("CB9")+cOrdSep)
				If ! Empty(CB9->CB9_QTEEBQ)
					If "00" $ cTipoExp .and. !("01" $ cTipoExp) .and. !("02" $ cTipoExp)
						cTipoEstorno:=STR0148 //"itens"
					Else
						cTipoEstorno:=STR0149 //"volumes"
					EndIf
					If !VTYesNo(STR0150+cTipoEstorno+STR0151,STR0027,.T.)			 //'Estorna '###' embarcados?'###'Atencao'
						AtvRet(.f.)
						AtvAva(.f.)
						Return .f.
					Else
						Estorna()
						CB9->(DbSeek(xFilial("CB9")+cOrdSep))
						Loop
					EndIf
				EndIf
				CB9->(DbSkip())
			End
			If ("00" $ cTipoExp .and. !("02" $ cTipoExp)) .or. ("01" $ cTipoExp .and. !("02" $ cTipoExp))
				lRetSepara:=.t.
			ElseIf "02" $ cTipoExp
				lEstEmbalagem:=.t.
			EndIf
			Return .t.
		EndIf
	EndIf
EndIf

If nLocal == 6
	AtvRet(.f.)
	AtvAva(.f.)
	Return .t.
EndIf

If ! VTYesNo(STR0039,STR0027,.T.) //'Confirma a saida?'###'Atencao'
	AtvRet(.f.)
	AtvAva(.f.)
	Return .f.
Else
	If nLocal == 1 .or. nLocal == 3 .or. nLocal == 5 .or. nLocal == 6 .or. nLocal == 7 .or. nLocal == 8
		Return .t.
	EndIf
EndIf

nRegs:=0
CB9->(DBSetOrder(1))
CB9->(DbSeek(xFilial("CB9")+cOrdSep))
While CB9->(! Eof() .and. CB9_FILIAL+CB9_ORDSEP == xFilial("CB9")+cOrdSep)
	++nRegs
	CB9->(DbSkip())
End

//0-Nao Iniciada;01-Em Separacao;02-Separacao Finalizada;3-Em processo embalagem;4-Embalagem Finalizada;5-Gera Nota;6-Imprime nota;7-Imprime Volume;8-Em processo embarque;9-Embarcado/Finalizado
If nRegs>0 .and. 	VTYesNo(STR0040,STR0027,.T.) //'Desfaz o que foi separado?'###'Atencao'
	AtvRet(.f.)
	AtvAva(.f.)
	If DesFaz()
		RecLock("CB7")
		CB7->CB7_STATUS := "0"
		//CB7->CB7_CODOPE := ""
		CB7->CB7_DTINIS := ctod('')
		CB7->CB7_HRINIS := ""
		CB7->CB7_STATPA := "1"  // EM PAUSA
		CB7->(MsUnlock())
		Return .t.
	EndIf
EndIf
If !lRetrocede .and. !lAvanca
	RecLock("CB7")
	CB7->CB7_STATPA := "1"  // EM PAUSA
	CB7->(MsUnlock())
EndIf
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ Grava    ³ Autor ³ ACD                   ³ Data ³ 03/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Realiza a Gravacao do CB9 e ajusta os saldos do CB8        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Grava(nX,lEstorno,cVolume,cCodCB0)
Local nY
Local nSaldoCB8
Default lEstorno := .f.
DefauLt cCodCB0 := Space(10)

For nY:= 1 to len(aItens[nX,_POSRECNO])

	CB8->(DbGoto(aItens[nX,_POSRECNO,nY]))
	nSaldoCB8:= CB8->CB8_SALDOS
	If ! lEstorno .AND. empty(nSaldoCB8)
		Loop
	EndIf
	If "02" $ cTipoExp
		CB9->(DbSetOrder(6))
	Else
		CB9->(DbSetOrder(10))
	EndIf

	CB9->(DbSeek(xFilial("CB9")+CB8->(CB8_ORDSEP+CB8_ITEM+CB8_PROD+CB8_LOCAL+CB8_LCALIZ+cLoteNew+cSLoteNew+CB8_NUMSER+CB8_LOTECT+CB8_NUMLOT)+cVolume+cCodCB0+CB8->CB8_PEDIDO))

	If ! lEstorno
		If ! CB9->(Eof())
			If UsaCB0("01")
				VtBeep(3)
				VtAlert(STR0041,STR0002,.t.,4000) //"Codigo ja Lido"###"Aviso"
				Return .F.
			EndIf
			RecLock("CB9",.F.)
		Else
			RecLock("CB9",.T.)
			CB9->CB9_FILIAL := xFilial("CB9")
			CB9->CB9_ORDSEP := CB7->CB7_ORDSEP
			CB9->CB9_CODETI := cCodCB0
			CB9->CB9_PROD   := CB8->CB8_PROD
			CB9->CB9_CODSEP := CB7->CB7_CODOPE
			CB9->CB9_ITESEP := CB8->CB8_ITEM
			CB9->CB9_SEQUEN := CB8->CB8_SEQUEN
			CB9->CB9_LOCAL  := CB8->CB8_LOCAL
			CB9->CB9_LCALIZ := CB8->CB8_LCALIZ
			CB9->CB9_LOTECT := cLoteNew
			CB9->CB9_NUMLOT := cSLoteNew
			CB9->CB9_NUMSER := CB8->CB8_NUMSER
			CB9->CB9_LOTSUG := CB8->CB8_LOTECT
			CB9->CB9_SLOTSU := CB8->CB8_NUMLOT
			CB9->CB9_PEDIDO := CB8->CB8_PEDIDO

			If '01' $ cTipoExp .or. ! Empty(cVolume)
				If Empty(cVolume)
					cVolume:=cVolPrv
				EndIf
				If ! '02' $ cTipoExp
					CB9->CB9_VOLUME := cVolume
				Else
					CB9->CB9_SUBVOL := cVolume
				EndIf
			EndIf
		EndIf
		CB9->CB9_QTESEP += If(nQtdLida > nSaldoCB8,nSaldoCB8,nQtdLida)
		If '01' $ cTipoExp
			CB9->CB9_QTEEMB += If(nQtdLida > nSaldoCB8,nSaldoCB8,nQtdLida)
			If ! "02" $ cTipoExp
				CB9->CB9_CODEMB := cCodOpe
			EndIf
			CB9->CB9_STATUS := "2"  // embalado
		Else
			CB9->CB9_STATUS := "1"  // EM ABERTO
		EndIf
		CB9->(MsUnlock())
		RecLock("CB8")
		CB8->CB8_SALDOS -=  If(nQtdLida > nSaldoCB8,nSaldoCB8,nQtdLida)
		If '01' $ cTipoExp
			CB8->CB8_SALDOE -=  If(nQtdLida > nSaldoCB8,nSaldoCB8,nQtdLida)
		EndIf
		CB8->(MsUnlock())
		aItens[nX,_POSSLDSEP] -= If(nQtdLida > nSaldoCB8,nSaldoCB8,nQtdLida)
		nQtdLida -= If(nQtdLida > nSaldoCB8,nSaldoCB8,nQtdLida)
		If nQtdLida == 0
			Exit
		Endif
	Else
		If CB9->(Eof())
			Loop
		EndIf
		If "01" $ cTipoExp .or. ! Empty(cVolPrv)
			If ! "02" $ cTipoExp
				cVolPrv:=CB9->CB9_VOLUME
			Else
				cVolPrv:=CB9->CB9_SUBVOL
			EndIf
		Else
			cVolPrv:=CB9->CB9_VOLUME
		EndIf

		RecLock("CB9",.F.)
		CB9->CB9_QTESEP -= nQtdLida
		If Empty(CB9->CB9_QTESEP)
			CB9->(DbDelete())
		EndIf
		CB9->(MsUnlock())
		RecLock("CB8")
		CB8->CB8_SALDOS += nQtdLida
		If '01' $ cTipoExp
			CB8->CB8_SALDOE += nQtdLida
		EndIf
		CB8->(MsUnlock())
		aItens[nX,_POSSLDSEP] += nQtdLida
		RecLock("CB7",.F.)
		CB7->CB7_STATUS := '1'
		CB7->(MsUnlock())
	EndIf
Next
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PulaItem ³ Autor ³ ACD                   ³ Data ³ 03/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Pula a Leitura do Item atual                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function PulaItem(nX)
Local aRec, aSvTela,cOcoSep
Local i, j
Private aItensAux := {}
If lSaiEstorno
	lSaiEstorno := .f.
	Return .t.
EndIf
If ! _lPulaItem
	Return .f.
EndIf
_lPulaItem := .f.
aRec := aClone(aItens[nX])
aSvTela := VtSave()
CB8->(DbGoto(aItens[nX,_POSRECNO,1]))
aadd(aItensAux,{aItens[nX,_POSITEM]+aItens[nX,_POSCODPRO]+aItens[nX,_POSARMAZEM]+aItens[nX,_POSENDERECO]+aItens[nX,_POSLOTECTL]+aItens[nX,_POSNUMLOTE],{aItens[nX,_POSRECNO,1]}})  //Adiciona recno do CB8 atual...
cOcoSep := CB8->CB8_OCOSEP
CB4->(DbSetOrder(1))
CB4->(DbSeek(xFilial("CB4")+cOcoSep))
VTClear
@ 2,0 VTSay STR0042 //'Informe o codigo'
@ 3,0 VTSay STR0043 //'da divergencia:'
@ 4,0 VtGet cOcoSep pict '@!' Valid VldOcoSep(cOcoSep,nX) F3 "CB4"
VtRead()
VtRestore(,,,,aSvTela)
If VtLastKey() == 27
	Return .t.
EndIf

For i:=1 to len(aItensAux)  //Processa e grava ocorrencia quando mesmo: item+prd+arm+end+lote+sublote
	For j:=1 to len(aItensAux[i,2])
		CB8->(DbGoto(aItensAux[i,2,j]))
		RecLock("CB8")
		CB8->CB8_OCOSEP := cOcoSep
		CB8->(MsUnlock())
	Next
	//O laco abaixo estah sendo usado pois ao usarmos Ascan quando existe um elemento deletado retorna erro...
	For j:=1 to len(aItens)
		If aItens[j] == nil
			Loop
		EndIf
		If aItens[j][2]+aItens[j][3]+aItens[j][4]+aItens[j][5]+aItens[j][8]+aItens[j][9] == aItensAux[i,1]
			aItens := Adel(aItens,j)
			If cOcoSep # cDivItemPv
				aItens[len(aItens)]:= aClone(aRec)
			EndIf
		EndIf
	Next
Next

If CB7->CB7_DIVERG # "1"   // marca divergencia na ORDEM DE SEPARACAO para que esta seja arrumada
	CB7->(RecLock("CB7"))
	CB7->CB7_DIVERG := "1"  // sim
	CB7->(MsUnlock())
EndIf
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ VldOcoSep³ Autor ³ ACD                   ³ Data ³ 03/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Expedicao                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function VldOcoSep(cOcoSep,nX)
Local  i, nPos, nPos2
Local  cProduto   := aItens[nX][3]
Local  aItensSort := {}
Local  aItensAux2 := {}
Local  lItemUnico := .t.
Local  lSeparados := .f.
If Empty(cOcoSep)
	VtKeyBoard(chr(23))
EndIf
CB4->(DBSetOrder(1))
If ! CB4->(DbSeek(xFilial("CB4")+cOcoSep))
	VtBeep(3)
	VtAlert(STR0044,STR0002,.t.,4000) //"Ocorrencia nao cadastrada"###"Aviso"
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
EndIf
If AllTrim(cOcoSep) == cDivItemPv
	If CB7->CB7_ORIGEM # '1'
		VtBeep(3)
		VtAlert(STR0179,STR0002,.t.,4000) //"Aviso" //"Ocorrencia invalida!"
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
	aEval(aItens,{|x| If(x<>nil,aadd(aItensSort,x),)})
	aSort(aItensSort,,,{|x,y| x[3] < y[3]})
	aEval(aItensSort,{|x| If(x[3]<>cProduto,lItemUnico := .f.,)})
	nPos := Ascan(aItensSort,{|x| x[3] == cProduto})
	For i:=nPos to len(aItensSort)
		If aItensSort[i][3] # cProduto
			Exit
		EndIf
		If aItensSort[i][_POSSLDSEP] # aItensSort[i][_POSQTDSEP]
			lSeparados := .t.
			Exit
		Else
			nPos2 := Ascan(aItensAux2,{|x| x[1] == aItensSort[i][2]+aItensSort[i][3]+aItensSort[i][4]+aItensSort[i][5]+aItensSort[i][8]+aItensSort[i][9]})
			If nPos2 == 0
				aadd(aItensAux2,{aItensSort[i][2]+aItensSort[i][3]+aItensSort[i][4]+aItensSort[i][5]+aItensSort[i][8]+aItensSort[i][9],{}})
				nPos2 := Ascan(aItensAux2,{|x| x[1] == aItensSort[i][2]+aItensSort[i][3]+aItensSort[i][4]+aItensSort[i][5]+aItensSort[i][8]+aItensSort[i][9]})
				aEval(aItensSort[i][1],{|x|aadd(aItensAux2[nPos2][2],x)})
			EndIf
		EndIf
	Next
	If lItemUnico //Unico item
		VtBeep(3)
		VtAlert(STR0179,STR0002,.t.,4000) //"Aviso" //"Ocorrencia invalida!"
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
	If lSeparados
		VtBeep(3)
		VtAlert(STR0180,STR0002,.t.,4000) //"Aviso" //"Esta ocorrencia exige o estorno dos itens lidos deste produto!"
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
	If !Empty(aItensAux2)
		aItensAux := {}
		aEval(aItensAux2,{|x| aadd(aItensAux,x)})
	EndIf
EndIf
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ AtvP     ³ Autor ³ ACD                   ³ Data ³ 03/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Funcao para ativar a variavel _lPulaItem ao tecla Ctrl+P   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function AtvP(lAtiva)
If lAtiva
	VtSetKey(16,{|| _lPulaItem:= .t.,VtKeyboard(CHR(13)) })  // CTRL+P
Else
	VtSetKey(16, bKey16)
EndIf
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ AtvRet   ³ Autor ³ ACD                   ³ Data ³ 03/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Funcao para ativar a variavel lRetrocede                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function AtvRet(lAtiva)
If lAtiva
	lRetrocede:=.t.
Else
	lRetrocede:=.f.
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ AtvAva   ³ Autor ³ ACD                   ³ Data ³ 03/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Funcao para ativar a variavel lAvanca                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function AtvAva(lAtiva)
If lAtiva
	lAvanca:=.t.
Else
	lAvanca:=.f.
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ Ajuda 	  ³ Autor ³ Eduardo Motta       ³ Data ³ 28/11/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Mostra tela de ajuda ao usuario                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Ajuda()
If Type("cVolume") #"C"
	cVolume:= Space(20)
EndIf
VTALERT(STR0045+chr(13)+chr(10)+; //"CTRL+A Ajuda"
STR0046+chr(13)+chr(10)+; //"CTRL+I Informacao"
STR0152+chr(13)+chr(10)+; //"CTRL+B Retrocede"
STR0153+chr(13)+chr(10)+; //"CTRL+D Avanca"
IIf(Type("lDesfaz")#"L",STR0047+chr(13)+chr(10),"")+; //"CTRL+X Estorna"
IIF(('01' $ cTipoExp  .or. ! Empty(cVolume)) .and. Type("lDesfaz")#"L" ,STR0048+chr(13)+chr(10),"")+; //"CTRL+V Volume"
IIF(Type("lSepara")=="L" .and. Type("lDesfaz")#"L" ,STR0049,""),STR0050) //"CTRL+P Pula"###"Ajuda"
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ Informa    ³ Autor ³ Eduardo Motta       ³ Data ³ 28/11/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Mostra produtos que ja foram lidos                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Informa()
Local aCab,aSize,aSave := VTSAVE()
Local nPos
Local aTemp:={}
Local nTam
Local cChave,cChaveM
VTClear()

If Type("lSepara") # "L" .AND. Type("lEmbala") # "L" .AND. Type("lEmbarque") # "L"
	VtRestore(,,,,aSave)
	Return
Endif

If Type("lEmbarque")=="L" .and. ("02" $ cTipoExp .or. "01" $ cTipoExp)
	aCab  := {STR0051,STR0052,STR0053,STR0054,STR0055} //"Volume"###"Pedido"###"Nota"###"Serie"###"Tipo"
	aSize := { 10,6,6,5,4}
	If CB7->CB7_ORIGEM == "1"
		CB6->(DbSetOrder(2))
		cChave:=xFilial('CB6')+cPedido
		cChaveM:= 'CB6_FILIAL+CB6_PEDIDO'
	Else
		CB6->(DbSetOrder(5))
		cChave:=xFilial('CB6')+CB7->(CB7_NOTA+CB7_SERIE)
		cChaveM:= 'CB6_FILIAL+CB6_NOTA+CB6_SERIE'
	EndIf
	CB9->(DbSetOrder(2))
	CB6->(DbSeek(cChave))
	While CB6->(! Eof() .and. cChave == &cChaveM)
		If CB6->CB6_STATUS == "5" .and. CB9->(DbSeek(xFilial("CB6")+CB7->CB7_ORDSEP+CB6->CB6_VOLUME))
			CB6->(aadd(aTemp,{CB6_VOLUME,CB6_PEDIDO,CB6_NOTA,CB6_SERIE,CB6_TIPVOL}))
		EndIf
		CB6->(DbSkip())
	End
	nPos := 0
Else
	If Type("lSepara")=="L"
		If UsaCB0('01')
			aCab  := {STR0056,STR0057,STR0058,STR0059,STR0060,STR0061,STR0062,STR0051,STR0065} //"Produto"###"Quantidade"###"Armazem"###"Endereco"###"Lote"###"Sub-Lote"###"Sub-volume"###"Volume"###"Id Etiqueta"
		Else
			aCab  := {STR0056,STR0057,STR0058,STR0059,STR0060,STR0061,STR0062,STR0051} //"Produto"###"Quantidade"###"Armazem"###"Endereco"###"Lote"###"Sub-Lote"###"Sub-volume"###"Volume"
		EndIf
		nTam := len(aCab[2])
		If nTam < len(Transform(0,cPictQtdExp))
			nTam := len(Transform(0,cPictQtdExp))
		EndIf
		If UsaCB0('01')
			aSize := {15,nTam,7,10,10,8,10,10,12}
		Else
			aSize := {15,nTam,7,10,10,8,10,10}
		Endif
	ElseIf Type("lEmbala")=="L"
		If UsaCB0('01')
			aCab  := {STR0051,STR0056,STR0063,STR0064,STR0058,STR0059,STR0060,STR0061,STR0062,STR0065} //"Volume"###"Produto"###"Qtde Separada"###"Qtde embalada"###"Armazem"###"Endereco"###"Lote"###"Sub-Lote"###"Sub-volume"###"Id Etiqueta"
		Else
			aCab  := {STR0051,STR0056,STR0063,STR0064,STR0058,STR0059,STR0060,STR0061,STR0062} //"Volume"###"Produto"###"Qtde Separada"###"Qtde embalada"###"Armazem"###"Endereco"###"Lote"###"Sub-Lote"###"Sub-volume"
		Endif
		nTam := len(aCab[3])
		If nTam < len(Transform(0,cPictQtdExp))
			nTam := len(Transform(0,cPictQtdExp))
		EndIf
		If UsaCB0('01')
			aSize := {10,15,nTam,nTam,7,10,10,8,10,12}
		Else
			aSize := {10,15,nTam,nTam,7,10,10,8,10}
		EndIf
	ElseIf Type("lEmbarque")=="L"
		If UsaCB0('01')
			aCab  := {STR0056,STR0057,STR0058,STR0059,STR0060,STR0061,STR0062,STR0051,STR0065} //"Produto"###"Quantidade"###"Armazem"###"Endereco"###"Lote"###"Sub-Lote"###"Sub-volume"###"Volume""###"Id Etiqueta"
		Else
			aCab  := {STR0056,STR0057,STR0058,STR0059,STR0060,STR0061,STR0062,STR0051} //"Produto"###"Quantidade"###"Armazem"###"Endereco"###"Lote"###"Sub-Lote"###"Sub-volume"###"Volume"
		EndIf
		nTam := len(aCab[2])
		If nTam < len(Transform(0,cPictQtdExp))
			nTam := len(Transform(0,cPictQtdExp))
		EndIf
		If UsaCB0('01')
			aSize := {15,nTam,7,10,10,8,10,10,12}
		Else
			aSize := {15,nTam,7,10,10,8,10,10}
		EndIf
	EndIf
	CB9->(DbSetOrder(6))
	CB9->(DbSeek(xFilial("CB9")+cOrdSep))
	While CB9->(! Eof() .and. CB9_FILIAL+CB9_ORDSEP == xFilial("CB9")+cOrdSep)
		If Type("lSepara")=="L"
			If UsaCB0('01')
				aadd(aTemp,{CB9->CB9_PROD,Transform(CB9->CB9_QTESEP,cPictQtdExp),CB9->CB9_LOCAL,CB9->CB9_LCALIZ,CB9->CB9_LOTECT,CB9->CB9_NUMLOT,CB9->CB9_SUBVOL,CB9->CB9_VOLUME,CB9->CB9_CODETI})
			Else
				aadd(aTemp,{CB9->CB9_PROD,Transform(CB9->CB9_QTESEP,cPictQtdExp),CB9->CB9_LOCAL,CB9->CB9_LCALIZ,CB9->CB9_LOTECT,CB9->CB9_NUMLOT,CB9->CB9_SUBVOL,CB9->CB9_VOLUME})
			EndIf
		ElseIf Type("lEmbala")=="L"
			If UsaCB0('01')
				aadd(aTemp,{CB9->CB9_VOLUME,CB9->CB9_PROD,Transform(CB9->CB9_QTESEP,cPictQtdExp),Transform(CB9->CB9_QTEEMB,cPictQtdExp),CB9->CB9_LOCAL,CB9->CB9_LCALIZ,CB9->CB9_LOTECT,CB9->CB9_NUMLOT,CB9->CB9_SUBVOL,CB9->CB9_CODETI})
			Else
				aadd(aTemp,{CB9->CB9_VOLUME,CB9->CB9_PROD,Transform(CB9->CB9_QTESEP,cPictQtdExp),Transform(CB9->CB9_QTEEMB,cPictQtdExp),CB9->CB9_LOCAL,CB9->CB9_LCALIZ,CB9->CB9_LOTECT,CB9->CB9_NUMLOT,CB9->CB9_SUBVOL})
			Endif
		ElseIf Type("lEmbarque")=="L"
			If CB9->CB9_QTEEBQ > 0
				If UsaCB0('01')
					aadd(aTemp,{CB9->CB9_PROD,Transform(CB9->CB9_QTEEBQ,cPictQtdExp),CB9->CB9_LOCAL,CB9->CB9_LCALIZ,CB9->CB9_LOTECT,CB9->CB9_NUMLOT,CB9->CB9_SUBVOL,CB9->CB9_VOLUME,CB9->CB9_CODETI})
				Else
					aadd(aTemp,{CB9->CB9_PROD,Transform(CB9->CB9_QTEEBQ,cPictQtdExp),CB9->CB9_LOCAL,CB9->CB9_LCALIZ,CB9->CB9_LOTECT,CB9->CB9_NUMLOT,CB9->CB9_SUBVOL,CB9->CB9_VOLUME})
				EndIf
			EndIf
		EndIf
		CB9->(DbSkip())
	Enddo
	If '01' $ cTipoExp .or. Type("lEmbala")=="L"
		nPos := 1
		@ 0,0 VtSay Left(STR0066+cVolume,20) //'Volume '
	Else
		nPos := 0
	EndIf
EndIf
VTaBrowse(nPos,0,7,19,aCab,aTemp,aSize)
VtRestore(,,,,aSave)
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ Estorna  ³ Autor ³ ACD                   ³ Data ³ 03/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Expedicao                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Estorna()
Local aTela
Local cEtiqEnd   := Space(20)
Local cArmazem   := Space(02)
Local cEndereco  := Space(15)
Local cProduto   := IIf( FindFunction( 'AcdGTamETQ' ), AcdGTamETQ(), Space(48) )
Local cVolume    := Space(10)
Local cIdVol     := Space(10)
Local cSubVolume := Space(10)
Local nQtde      := 1
Private cLoteNew := Space(10)
Private cSLoteNew:= Space(6)

If Type("lSepara") =="L"
	aTela := VTSave()
	VTClear()
	@ 0,0 VtSay Padc(STR0067,VTMaxCol()) //"Estorno da leitura"
	@ 1,0 VTSay STR0010 //'Leia o endereco'
	If UsaCB0('02')
		@ 2,0 VTGet cEtiqEnd pict '@!' valid VldEndEst(,,cEtiqEnd)
	Else
		@ 2,0 VTGet cArmazem pict '@!' valid ! Empty(cArmazem)
		@ 2,3 VTSay "-" VTGet cEndereco pict '@!' valid VtLastKey()==5 .or. VldEndEst(@cArmazem,@cEndereco)
	EndIf
	If '01' $ cTipoExp
		@ 3,0 VTSay STR0068 //'Leia o volume'
		@ 4,0 VTGet cIdVol pict '@!' Valid VldVolEst(cIdVol,@cVolume)
	EndIf
	cProduto   := IIf( FindFunction( 'AcdGTamETQ' ), AcdGTamETQ(), Space(48) )
	If ! UsaCB0('01')
		@ 5,0 VTSay STR0019 VtGet nQtde pict cPictQtdExp valid VldQtde(nQtde) when (lForcaQtd .or. VTLastkey() == 5) //'Qtde '
	EndIf
	@ 6,0 VTSay STR0020 //'Leia o produto'
	@ 7,0 VTGet cProduto pict '@!' VALID VTLastkey() == 5 .or. VldProdEst(cProduto,@nQtde,cArmazem,cEndereco,cVolume)
	VTRead
	VTRestore(,,,,aTela)
	If lSaiEstorno
		VtKeyBoard(chr(27))
	Endif
ElseIf Type('lEmbala') =='L'
	aTela := VTSave()
	VTClear()
	@ 0,0 VtSay Padc(STR0067,VTMaxCol()) //"Estorno da leitura"
	@ 1,0 VTSay STR0068 //'Leia o volume'
	@ 2,0 VTGet cIdVol pict '@!' Valid VldVolEst(cIdVol,@cVolume)
	If '01' $ cTipoExp // trabalha com sub-volume
		cSubVolume := Space(10)
		@ 04,00 VtSay STR0069 //"Leia o sub-volume"
		@ 05,00 VtGet cSubVolume Picture "@!" Valid VldSubVol(cSubVolume,.t.,cVolume)
	Else
		nQtde := 1
		cProduto   := IIf( FindFunction( 'AcdGTamETQ' ), AcdGTamETQ(), Space(48) )
		If ! Usacb0("01")
			@ 3,0 VTSay STR0019 VtGet nQtde pict cPictQtdExp valid VldQtde(nQtde) when (lForcaQtd .or. VTLastkey() == 5) //'Qtde '
		EndIf
		@ 4,0 VTSay STR0020 //'Leia o produto'
		@ 5,0 VTGet cProduto pict '@!' VALID VTLastkey() == 5 .or. VldProdEmb(cProduto,@nQtde,.t.,cVolume)
	EndIf
	VtRead
	VTRestore(,,,,aTela)
ElseIf Type('lEmbarque') =='L'
	aTela := VTSave()
	VTClear()
	@ 0,0 VtSay Padc(STR0070,VTMaxCol()) //"Estorno do embarque"
	If '01' $ cTipoExp .or. '02' $ cTipoExp
		cVolume := Space(10)
		@ 03,00 VtSay STR0071 //"Leia o volume"
		@ 04,00 VtGet cVolume Picture "@!" Valid VldEbqVol(cVolume,.t.)
	Else
		nQtde := 1
		cProduto   := IIf( FindFunction( 'AcdGTamETQ' ), AcdGTamETQ(), Space(48) )
		If ! Usacb0("01")
			@ 3,0 VTSay STR0019 VtGet nQtde pict cPictQtdExp valid VldQtde(nQtde) when (lForcaQtd .or. VTLastkey() == 5) //'Qtde '
		EndIf
		@ 4,0 VTSay STR0020 //'Leia o produto'
		@ 5,0 VTGet cProduto pict '@!' VALID VTLastkey() == 5 .or. VldProdEbq(cProduto,@nQtde,.t.)
	EndIf
	VtRead
	VTRestore(,,,,aTela)
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ VldEndEst³ Autor ³ ACD                   ³ Data ³ 03/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Funcao auxiliar chamada pela funcao Estorna                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function VldEndEst(cArmazem,cEndereco,cEtiqEnd)
Local aRet
Local nPos
VtClearBuffer()
If cArmazem == NIL // se cArmazem == NIL entao e' etiqueta de endereco com CB0
	aRet := CBRetEti(cEtiqEnd,'02')
	If len(aRet) == 0
		VtBeep(3)
		VtAlert(STR0022,STR0002,.t.,4000) //"Etiqueta invalida"###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
	cArmazem  := aRet[2]
	cEndereco := aRet[1]
EndIf
nPos := Ascan(aItens,{|x| cArmazem+cEndereco == x[_POSARMAZEM]+x[_POSENDERECO]})
If Empty(nPos)
	VtBeep(3)
	VtAlert(STR0023,STR0002,.t.,4000) //"Endereco incorreto"###"Aviso"
	VTClearGet("cArmazem")
	VTClearGet("cEndereco")
	VTGetSetFocus("cArmazem")
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
EndIf
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³VldProdEst³ Autor ³ ACD                   ³ Data ³ 03/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Funcao auxiliar chamada pela funcao Estorna - Tem como      ³±±
±±³			 ³objetivo validar o Produto com utilizacao de Codigo Natural ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAACD                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static function VldProdEst(cEProduto,nQtde,cArmazem,cEndereco,cVolume)
Local cTipo
Local aEtiqueta,aRet
Local cLote   := Space(10)
Local cSLote  := Space(6)
Local cNumSer := Space(20)
Local nQE:=0
Local nPos
Local cProduto
Local nTQtde := 0
Local nQtdSaldo  :=0
Private nQtdLida :=0

If Empty(cEProduto)
	Return .f.
EndIf
If !CBLoad128(@cEProduto)
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
EndIf
cTipo := CBRetTipo(cEProduto)
If cTipo == "01"
	aEtiqueta:= CBRetEti(cEProduto,"01")
	If Empty(aEtiqueta)
		VtBeep(3)
		VtAlert(STR0022,STR0002,.t.,4000) //"Etiqueta invalida"###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
	CB9->(DbSetorder(1))
	If ! CB9->(DbSeek(xFilial("CB9")+cOrdSep+Left(cEProduto,10)))
		VtBeep(3)
		VtAlert(STR0072,STR0002,.t.,4000) //"Produto nao separado"###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
	IF ! VtYesNo(STR0073,STR0002,.t.) //"Confirma o estorno?"###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		AtvRet(.f.)
		AtvAva(.f.)
		Return .F.
	EndIf
	lSaiEstorno:= .t.
	cProduto:= aEtiqueta[1]
	nQE     := aEtiqueta[2]
	cLote   := aEtiqueta[16]
	cSLote  := aEtiqueta[17]
	nQtdLida := nQE
	nPos := ascan(aItens,{|x| x[_POSITEM]+X[_POSARMAZEM]+X[_POSENDERECO]+X[_POSLOTECTL]+X[_POSNUMLOTE]+X[_POSNUMSERIE] == ;
	CB9->(CB9_ITESEP+CB9_LOCAL+CB9_LCALIZ+CB9_LOTSUG+CB9_SLOTSUG+CB9_NUMSER)})
	
	cLoteNew := cLote
	cSLoteNew:= cSLote
	Grava(nPos,.T.,cVolume,CB9->CB9_CODETI)
ElseIf cTipo $ "EAN8OU13-EAN14-EAN128"
	aRet     := CBRetEtiEan(cEProduto)
	If len(aRet) == 0
		VtBeep(3)
		VtAlert(STR0022,STR0002,.t.,4000) //"Etiqueta invalida"###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
	cProduto := aRet[1]
	nQE  :=CBQtdEmb(cProduto)*nQtde
	If Empty(nQE)
		VtBeep(3)
		VtAlert(STR0031,STR0002,.t.,4000) //"Quantidade invalida"###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
	cLote := aRet[3]
	If ! CBRastro(cProduto,@cLote,@cSLote)
		VTKeyBoard(chr(20))
		Return .f.
	EndIf
	cNumSer:= aRet[5]	 // Numero de Serie
	If Empty(cNumSer) .and. CBSeekNumSer(cOrdSep,cProduto,nQtde)
		If ! VldQtde(nQtde,.T.)
			VtKeyboard(Chr(20))  // zera o get
			Return .F.
		Endif
		If ! CBNumSer(@cNumSer)
			VTKeyBoard(chr(20))
			Return .f.
		EndIf
	Endif
	CB9->(DBSetOrder(9))
	CB9->(DbSeek(xFilial("CB9")+cOrdSep+cProduto+cArmazem+cEndereco+cLote+cSLote+cNumSer))
	nPos := 0
	While CB9->(! Eof() .and. xFilial("CB9")+cOrdSep+cProduto+cArmazem+cEndereco+cLote+cSLote+cNumSer ==;
		CB9_FILIAL+CB9_ORDSEP+CB9_PROD+CB9_LOCAL+CB9_LCALIZ+CB9_LOTECT+CB9_NUMLOT+CB9_NUMSER)
		nPos := 	Ascan(aItens,{|X| CB9->(CB9_PROD+CB9_LOCAL+CB9_LCALIZ+CB9_LOTSUG+CB9_SLOTSU+CB9_NUMSER) ==;
		x[_POSCODPRO]+x[_POSARMAZEM]+x[_POSENDERECO]+x[_POSLOTECTL]+x[_POSNUMLOTE]+x[_POSNUMSERIE] .and.;
		x[_POSSLDSEP]< X[_POSQTDSEP]})
		If ! Empty(nPos)
			Exit
		EndIf
		CB9->(DbSkip())
	EndDo
	cLoteNew := cLote
	cSLoteNew:= cSLote
	If Empty(nPos)
		VtBeep(3)
		VtAlert(STR0074,STR0002,.t.,4000) //"Item nao encontrado"###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
	nTQtde := 0
	CB9->(DbSetorder(6))
	If ! CB9->(DBSeek(xFilial("CB9")+cOrdSep+aItens[nPos,_POSITEM]+cProduto+cArmazem+cEndereco+cLoteNew+cSLoteNew+aItens[nPos,_POSNUMSERIE]+aItens[nPos,_POSLOTECTL]+aItens[nPos,_POSNUMLOTE]+cVolume+space(10)))
		VtBeep(3)
		VtAlert(STR0075,STR0002,.t.,4000) //"Volume ou etiqueta invalida"###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
	If nQE > CB9->CB9_QTESEP
		VtBeep(3)
		VtAlert(STR0076,STR0002,.t.,4000) //"Quantidade informada maior do que separada"###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
	IF ! VtYesNo(STR0073,STR0002,.t.) //"Confirma o estorno?"###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		AtvRet(.f.)
		AtvAva(.f.)
		Return .F.
	EndIf
	lSaiEstorno:= .t.
	nQtdLida := nQE
	Grava(nPos,.T.,cVolume)
	nQtde:= 1
	VTGetRefresh('nQtde')
Else
	VtBeep(3)
	VtAlert(STR0022,STR0002,.t.,4000) //"Etiqueta invalida"###"Aviso"
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
EndIf
VtKeyboard(Chr(20))  // zera o get
Return .F.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ Volume   ³ Autor ³ ACD                   ³ Data ³ 03/01/02 ³±±
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
Local lImp:=.t.
cVolAnt := cVolume
aTela   := VTSave()
VTClear()
cVolume := Space(20)
@ 0,0 VTSay STR0077 //"Embalagem:"
@ 1,0 VtSay STR0078 //"Leia o volume ou"
@ 2,0 VtSay STR0079 //"registre a etiqueta"
@ 3,0 VtGet cVolume Pict "@!" Valid VldVolume(lImp)
If lImp
	@ 4,0 VtSay STR0080 //"Tecle ENTER para"
	@ 5,0 VtSay STR0081 //"novo volume.    "
EndIf
VTRead
VTRestore(,,,,aTela)
cVolume := Padr(cVolume,10)
If VTLastkey() == 27
	cVolume := cVolAnt
	Return .f.
EndIf
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³VldVolume ³ Autor ³ ACD                   ³ Data ³ 03/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Validacao do Volume             		              		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAACD                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static function VldVolume(lImp)
Local cCodEmb := Space(3)
Local cVolImp := Space(10)
Local aRet    := {}
Local aTela   := {}

If Empty(cVolume)
	If ! lImp
		Return .f.
	EndIf
	aTela := VTSave()
	VtClear()
	@ 1,0 VtSay STR0083 //"Digite o codigo do"
	@ 2,0 VtSay STR0084 //"tipo de embalagem"

	If ExistBlock("ACD170EB")
		cCodEmb := ExecBlock("ACD170EB")
	EndIf
	@ 3,0 VTGet cCodEmb pict "@!"  Valid VldEmb(cCodEmb) F3 'CB3'
	VTRead

	If VTLastkey() == 27
		VtRestore(,,,,aTela)
		VtKeyboard(Chr(20))  // zera o get
		Return .f.
	EndIf

	cCodVol := CB6->(GetSX8Num("CB6","CB6_VOLUME"))
	CB6->(RecLock("CB6",.T.))
	CB6->CB6_FILIAL := xFilial("CB6")
	CB6->CB6_VOLUME := cCodVol
	CB6->CB6_PEDIDO := cPedido
	CB6->CB6_NOTA   := CB7->CB7_NOTA
	CB6->CB6_SERIE  := CB7->CB7_SERIE
	CB6->CB6_TIPVOL := CB3->CB3_CODEMB
	CB6->CB6_STATUS := "1"   // ABERTO
	CB6->(MsUnlock())
	CB6->(ConfirmSX8())
	If CB5SetImp(cImp,.t.)
		VTAlert(STR0085,STR0007,.T.,2000) //'Imprimindo etiqueta de volume '###'Aviso'
		If ExistBlock('IMG05')
			ExecBlock("IMG05",,,{cCodVol,cPedido,CB7->CB7_NOTA,CB7->CB7_SERIE})
		EndIf
		MSCBCLOSEPRINTER()
	EndIf
	While .t.
		cVolImp := Space(10)
		@ 5,0 VtSay STR0071 //"Leia o Volume"
		@ 6,0 VTGet cVolImp pict "@!"  Valid ! Empty(cVolImp)
		VTRead
		If VTLastkey() == 27
			VtRestore(,,,,aTela)
			VtKeyboard(Chr(20))  // zera o get
			Return .f.
		EndIf
		If UsaCB0("05")
			If cVolImp # CB0->CB0_CODETI
				VTAlert(STR0086,STR0002,.t.,3000) //"Volume nao confere"###"Aviso"
			Else
				Exit
			EndIf
		Else
			If cVolImp # cCodVol
				VTAlert(STR0086,STR0002,.t.,3000) //"Volume nao confere"###"Aviso"
			Else
				Exit
			EndIf
		Endif
	EndDo
	VtRestore(,,,,aTela)
Else
	If UsaCB0("05")
		aRet:= CBRetEti(cVolume)
		If Empty(aRet)
			VtBeep(3)
			VtAlert(STR0022,STR0002,.t.,4000) //"Etiqueta invalida"###"Aviso"
			VtKeyboard(Chr(20))  // zera o get
			Return .f.
		EndIf
		cCodVol:= aRet[1]
	Else
		cCodVol:= cVolume
	Endif
	CB6->(DBSetOrder(1))
	If ! CB6->(DbSeek(xFilial("CB6")+cCodVol))
		VtBeep(3)
		VtAlert(STR0087,STR0002,.t.,4000) //"Codigo de volume nao cadastrado"###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .f.
	EndIf
	If CB7->CB7_ORIGEM == "1"
		If ! CB6->CB6_PEDIDO == cPedido
			VtBeep(3)
			VtAlert(STR0088+CB6->CB6_PEDIDO,STR0002,.t.,4000) //"Volume pertence ao pedido "###"Aviso"
			VtKeyboard(Chr(20))  // zera o get
			Return .f.
		EndIf
	ElseIf CB7->CB7_ORIGEM == "2"
		If ! CB6->(CB6_NOTA+CB6_SERIE) == CB7->(CB7_NOTA+CB7_SERIE)
			VtBeep(3)
			VtAlert(STR0089+CB6->(CB6_NOTA+'-'+CB6_SERIE),STR0002,.t.,4000) //"Volume pertence a nota "###"Aviso"
			VtKeyboard(Chr(20))  // zera o get
			Return .f.
		EndIf
	EndIF
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
If Empty(cEmb)
	Return .f.
EndIf
CB3->(DbSetOrder(1))
If ! CB3->(DbSeek(xFilial("CB3")+cEmb))
	VtBeep(3)
	VtAlert(STR0090,STR0002,.t.,4000) //"Embalagem nao cadastrada"###"Aviso"
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
EndIf
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ VldVolEst³ Autor ³ ACD                   ³ Data ³ 03/01/02 ³±±
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

If VtLastkey()== 05
	Return .t.
EndIf

If Empty(cIDVolume)
	Return .f.
EndIf

If UsaCB0("05")
	aRet:= CBRetEti(cIDVolume,"05")
	If Empty(aRet)
		VtBeep(3)
		VtAlert(STR0082,STR0002,.t.,4000) //"Etiqueta de volume invalida"###"Aviso"
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
	VtBeep(3)
	VtAlert(STR0087,STR0002,.t.,4000) //"Codigo de volume nao cadastrado"###"Aviso"
	VtKeyboard(Chr(20))  // zera o get
	Return .f.
EndIf

If Type('lEmbala')=='L'
	CB9->(DBSetOrder(2))
	If ! CB9->(DbSeek(xFilial("CB9")+cOrdSep+cVolume))
		VtBeep(3)
		VtAlert(STR0091,STR0002,.t.,4000) //"Volume pertence a outra ordem de separacao"###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .f.
	EndIf
	@ 2,0 VTSay cVolume
Else
	@ 4,0 VTSay cVolume
EndIf
Return .t.

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
Private cVolume := Space(10)

VtClear()
CB9->(DBSetOrder(2))
If	("03" $ cTipoExp .and. CB7->CB7_STATUS == "5" .AND. Empty(CB7->CB7_NOTA)) .or. ;
	("02" $ cUltTipoExp .and. CB7->CB7_STATUS == "9")
	lRetAgain:=.t.
ElseIf lExcluiNF
	Return .t.
Else
	If ! CB9->(DBSeek(xFilial("CB9")+cOrdSep+Space(10))) .and. ! lEstEmbalagem
		Return .t.
	EndIf
EndIf

If lEstEmbalagem .or. lRetAgain  //Estorna os volumes...
	CB9->(DBSetOrder(1))
	CB9->(DbSeek(xFilial("CB9")+cOrdSep))
	While CB9->(! Eof() .and. CB9_FILIAL+CB9_ORDSEP == xFilial("CB9")+cOrdSep)
		If ! Empty(CB9->CB9_VOLUME)
			If !VTYesNo(STR0147,STR0027,.T.)	  //'Estorna volumes ?'###'Atencao'
				AtvRet(.f.)
				AtvAva(.f.)
				Return .f.
			Else
				Estorna()
				If lAvanca
					Return .t.
				Endif
				CB9->(DbSeek(xFilial("CB9")+cOrdSep))
				Loop
			EndIf
		EndIf
		CB9->(DbSkip())
	End
EndIf

CBFlagSC5("2",cOrdSep)  //Em processo de embalagem
Reclock('CB7')
CB7->CB7_STATUS := "3"  // embalando
CB7->(MsUnLock())
While ! Volume()
	If VldSaida(3)
		If lAvanca
			AtvAva(.f.)
			Return .t.
		EndIf
		Return .f.  //retrocede
	EndIf
End

While .T.
	VTClear
	@ 0,0 VTSay STR0092 //"Embalagem"
	@ 1,0 VTSay STR0093+cVolume //"Volume :"
	If '01' $ cTipoExp  // trabalha com sub-volume
		cSubVolume := Space(10)
		@ 04,00 VtSay STR0094 //"Sub-volume a embalar"
		@ 05,00 VtGet cSubVolume Picture "@!" Valid VldSubVol(cSubVolume)
	Else
		nQtde := 1
		cProduto   := IIf( FindFunction( 'AcdGTamETQ' ), AcdGTamETQ(), Space(48) )
		If ! Usacb0("01")
			@ 3,0 VTSay STR0019 VtGet nQtde pict cPictQtdExp valid VldQtde(nQtde) when (lForcaQtd .or. VTLastkey() == 5) //'Qtde '
		EndIf
		@ 4,0 VTSay STR0020 //'Leia o produto'
		@ 5,0 VtSay STR0095 //'a embalar'
		@ 6,0 VTGet cProduto pict '@!' VALID VTLastkey() == 5 .or. VldProdEmb(cProduto,nQtde,NIL,NIL)
	EndIf
	VtRead
	If VtLastKey() == 27
		If VldSaida(3)
			If lAvanca
				AtvAva(.f.)
				Return .t.
			EndIf
			Return .f.
		EndIf
		Loop
	EndIf

	CB9->(DBSetOrder(2))
	If ! CB9->(DBSeek(xFilial("CB9")+cOrdSep+Space(10)))
		Exit
	EndIf
EndDo
Reclock('CB7')
CB7->CB7_STATUS := "4"  // embalagem finalizada
CB7->(MsUnLock())
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³VldSubVol ³ Autor ³ ACD                   ³ Data ³ 03/01/02 ³±±
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
	VtBeep(3)
	VtAlert(STR0022,STR0002,.t.,4000) //"Etiqueta invalida"###"Aviso"
	VtKeyboard(Chr(20))  // zera o get
	return .f.
EndIf
cCodVol := aRet[1]
CB6->(DBSetOrder(1))
If ! CB6->(DbSeek(xFilial("CB6")+cCodVol))
	VtBeep(3)
	VtAlert(STR0096,STR0002,.t.,4000) //"Codigo de sub-volume nao cadastrado"###"Aviso"
	VtKeyboard(Chr(20))  // zera o get
	return .f.
EndIf
If CB7->CB7_ORIGEM == "1"
	If ! CB6->CB6_PEDIDO == cPedido
		VtBeep(3)
		VtAlert(STR0097+CB6->CB6_PEDIDO,STR0002,.t.,4000) //"Sub-volume pertence ao pedido "###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		return .f.
	EndIf
ElseIf CB7->CB7_ORIGEM == "2"
	If ! CB6->(CB6_NOTA+CB6_SERIE) == CB7->(CB7_NOTA+CB7_SERIE)
		VtBeep(3)
		VtAlert(STR0098+CB6->(CB6_NOTA+'-'+CB6_SERIE),STR0002,.t.,4000) //"Sub-volume pertence a nota "###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		return .f.
	EndIf
EndIF

CB9->(DbSetOrder(7))
If ! CB9->(DbSeek(xFilial("CB9")+cOrdSep+cCodVol))
	VtBeep(3)
	If lEstorna
		VtAlert(STR0099,STR0002,.t.,4000) //"Sub-volume nao pertence esta ordem de separacao"###"Aviso"
	Else
		VtAlert(STR0100,STR0002,.t.,4000) //"Sub-volume nao separado"###"Aviso"
	EndIf
	VtKeyboard(Chr(20))  // zera o get
	return .f.
EndIf
If ! lEstorna
	If ! Empty(CB9->CB9_VOLUME)
		VtBeep(3)
		VtAlert(STR0101,STR0002,.t.,4000) //"Sub-Volume ja embalado"###"Aviso"
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
		VtBeep(3)
		VtAlert(STR0102,STR0002,.t.,4000) //"Sub-Volume nao embalado"###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		return .f.
	EndIf
	If CB9->CB9_VOLUME # cVolumeEst
		VtBeep(3)
		VtAlert(STR0103+CB9->CB9_VOLUME,STR0002,.t.,4000) //"Sub-Volume pertence ao volume "###"Aviso"
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
±±³Fun‡ao    ³VldProdEmb³ Autor ³ ACD                   ³ Data ³ 03/01/02 ³±±
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
Local cLote    := Space(10)
Local cSLote   := Space(6)
Local cNumSer  := Space(20)
Local nQE:=0
Local nQEConf:=0
Local nSaldoEmb
Local nRecno,nRecnoCB9
Local cProduto
Local nQtdeSep
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
	aEtiqueta:= CBRetEti(cEProduto,"01")
	If Empty(aEtiqueta)
		VtBeep(3)
		VtAlert(STR0022,STR0002,.t.,4000) //"Etiqueta invalida"###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
	CB9->(DbSetorder(1))
	If ! CB9->(DbSeek(xFilial("CB9")+cOrdSep+Left(cEProduto,10)))
		VtBeep(3)
		VtAlert(STR0072,STR0002,.t.,4000) //"Produto nao separado"###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
	If ! lEstorna
		If ! Empty(CB9->CB9_VOLUME)
			VtBeep(3)
			VtAlert(STR0104+CB9->CB9_VOLUME,STR0002,.t.,4000) //"Produto embalado no volume "###"Aviso"
			VtKeyboard(Chr(20))  // zera o get
			Return .F.
		EndIf
	Else
		If Empty(CB9->CB9_VOLUME)
			VtBeep(3)
			VtAlert(STR0105,STR0002,.t.,4000) //"Produto nao embalado"###"Aviso"
			VtKeyboard(Chr(20))  // zera o get
			Return .F.
		EndIf
		If CB9->CB9_VOLUME # cVolumeEst
			VtBeep(3)
			VtAlert(STR0106+CB9->CB9_VOLUME,STR0002,.t.,4000) //"Produto embalado em outro volume "###"Aviso"
			VtKeyboard(Chr(20))  // zera o get
			Return .F.
		EndIf
	EndIf
	cProduto:= aEtiqueta[1]
	nQE     := aEtiqueta[2]
	cLote   := aEtiqueta[16]
	cSLote  := aEtiqueta[17]
	If ! lEstorna
		nQEConf:= nQE
		If ! CBProdUnit(aEtiqueta[1]) .and. GetMv("MV_CHKQEMB") =="1"
			nQEConf := CBQtdEmb(aEtiqueta[1])
		EndIf
		If empty(nQEConf) .or. nQE # nQEConf
			VtBeep(3)
			VtAlert(STR0107,STR0002,.t.,4000) //"Quantidade invalida "###"Aviso"
			VtKeyboard(Chr(20))  // zera o get
			Return .f.
		EndIf
		
		RecLock("CB9")
		CB9->CB9_VOLUME := cVolume
		CB9->CB9_QTEEMB += nQE
		CB9->CB9_CODEMB := cCodOpe
		CB9->CB9_STATUS := "2"  // embalado
		CB9->(MsUnlock())
		CB8->(DbSetOrder(4))
		CB8->(DbSeek(xFilial("CB9")+CB9->(CB9_ORDSEP+CB9_ITESEP+CB9_PROD+CB9_LOCAL+CB9_LCALIZ+CB9_LOTSUG+CB9_SLOTSU+CB9_NUMSER)))
		RecLock("CB8")
		CB8->CB8_SALDOE -= nQE
		CB8->(MsUnlock())
		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1")+cProduto))
		If ! CBProdUnit(aEtiqueta[1]) .and. GetMV('MV_REMIEMB') == "S"
			If CB5SetImp(cImp,.T.)
				VTAlert(STR0108,STR0007,.T.,2000) //'Imprimindo etiqueta de produto '###'Aviso'
				If ExistBlock('IMG01')
					ExecBlock("IMG01",,,{,,CB9->CB9_CODETI})
				EndIf
				MSCBCLOSEPRINTER()
			EndIf
		EndIf
	Else
		IF ! VtYesNo(STR0073,STR0002,.t.) //"Confirma o estorno?"###"Aviso"
			VtKeyboard(Chr(20))  // zera o get
			AtvRet(.f.)
			AtvAva(.f.)
			Return .F.
		EndIf
		RecLock("CB9")
		CB9->CB9_VOLUME := ''
		CB9->CB9_QTEEMB -= nQE
		CB9->CB9_CODEMB := ''
		CB9->CB9_STATUS := "1"  // embalado
		CB9->(MsUnlock())
		CB8->(DbSetOrder(4))
		CB8->(DbSeek(xFilial("CB8")+CB9->(CB9_ORDSEP+CB9_ITESEP+CB9_PROD+CB9_LOCAL+CB9_LCALIZ+CB9_LOTSUG+CB9_SLOTSU+CB9_NUMSER)))
		RecLock("CB8")
		CB8->CB8_SALDOE += nQE
		CB8->(MsUnlock())
	EndIf
ElseIf cTipo $ "EAN8OU13-EAN14-EAN128"
	aRet     := CBRetEtiEan(cEProduto)
	If len(aRet) == 0
		VtBeep(3)
		VtAlert(STR0022,STR0002,.t.,4000) //"Etiqueta invalida"###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
	cProduto := aRet[1]
	If ! CBProdUnit(cProduto)
		VtBeep(3)
		VtAlert(STR0022,STR0002,.t.,4000) //"Etiqueta invalida"###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
	nQE  :=CBQtdEmb(cProduto)*nQtde
	If Empty(nQE)
		VtBeep(3)
		VtAlert(STR0031,STR0002,.t.,4000) //"Quantidade invalida"###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
	cLote  := aRet[3]
	If ! CBRastro(cProduto,@cLote,@cSLote)
		VTKeyBoard(chr(20))
		Return .f.
	EndIf
	cNumSer:= aRet[5]
	If Empty(cNumSer) .and. CBSeekNumSer(cOrdSep,cProduto)
		If ! VldQtde(nQtde,.T.)
			VtKeyboard(Chr(20))  // zera o get
			Return .F.
		Endif
		If ! CBNumSer(@cNumSer)
			VTKeyBoard(chr(20))
			Return .f.
		EndIf
	EndIf
	If ! lEstorna
		CB9->(DbSetorder(8))
		If ! CB9->(DBSeek(xFilial("CB9")+cOrdSep+cProduto+cLote+cSLote+cNumSer+space(10)))
			VtBeep(3)
			VtAlert(STR0109,STR0002,.t.,4000) //"Produto invalido"###"Aviso"
			VtKeyboard(Chr(20))  // zera o get
			Return .F.
		EndIf
		nSaldoEmb:=0
		While CB9->(! EOF() .AND. CB9_FILIAL+CB9_ORDSEP+CB9_PROD+CB9_LOTECT+CB9_NUMLOT+CB9_VOLUME ==;
			xFilial("CB9")+cOrdSep+cProduto+cLote+cSLote+space(10))
			nSaldoEmb += CB9->CB9_QTESEP
			CB9->(DbSkip())
		END
		If nQE > nSaldoEmb
			VtBeep(3)
			VtAlert(STR0110,STR0002,.t.,4000) //"Quantidade informada maior que disponivel para embalar"###"Aviso"
			VtKeyboard(Chr(20))  // zera o get
			Return .F.
		EndIf
		nSaldoEmb := nQE
		CB9->(DbSetorder(8))
		While CB9->(DBSeek(xFilial("CB9")+cOrdSep+cProduto+cLote+cSLote+cNumSer+space(10)))
			If nSaldoEmb > CB9->CB9_QTESEP
				RecLock("CB9")
				CB9->CB9_VOLUME := cVolume
				CB9->CB9_QTEEMB :=CB9->CB9_QTESEP
				CB9->CB9_CODEMB := cCodOpe
				CB9->CB9_STATUS := "2"  // embalado
				CB9->(MsUnlock())
				CB8->(DbSetOrder(4))
				CB8->(DbSeek(xFilial("CB8")+CB9->(CB9_ORDSEP+CB9_ITESEP+CB9_PROD+CB9_LOCAL+CB9_LCALIZ+CB9_LOTSUG+CB9_SLOTSU+CB9_NUMSER)))
				RecLock("CB8")
				CB8->CB8_SALDOE -= CB9->CB9_QTESEP
				CB8->(MsUnlock())
				nSaldoEmb-=CB9->CB9_QTESEP
			Else
				nRecnoCB9:= CB9->(Recno())
				CB9->(DbSetOrder(8))
				If CB9->(DBSeek( CB9_FILIAL+CB9_ORDSEP+CB9_PROD+CB9_LOTECT+CB9_NUMLOT+CB9_NUMSER+cVolume+CB9_ITESEP+CB9_LOCAL+CB9_LCALIZ))
					RecLock("CB9")
					CB9->CB9_QTEEMB += nSaldoEmb
					CB9->CB9_QTESEP += nSaldoEmb
					CB9->(MsUnlock())
					CB8->(DbSetOrder(4))
					CB8->(DbSeek(xFilial("CB8")+CB9->(CB9_ORDSEP+CB9_ITESEP+CB9_PROD+CB9_LOCAL+CB9_LCALIZ+CB9_LOTSUG+CB9_SLOTSU+CB9_NUMSER)))
					RecLock("CB8")
					CB8->CB8_SALDOE -= nSaldoEmb
					CB8->(MsUnlock())
					CB9->(DbGoto(nRecnoCB9))
					RecLock("CB9")
					CB9->CB9_QTESEP -= nSaldoEmb
					If Empty(CB9->CB9_QTESEP)
						CB9->(DBDelete())
					EndIf
					CB9->(MsUnlock())
					nSaldoEmb := 0
				Else
					CB9->(DbGoto(nRecnoCB9))    
					nRecno:= CB9->(CBCopyRec({{"CB9_VOLUME","X"}}))
					RecLock("CB9")
					CB9->CB9_VOLUME := cVolume
					CB9->CB9_QTEEMB := nSaldoEmb
					CB9->CB9_QTESEP := nSaldoEmb
					CB9->CB9_CODEMB := cCodOpe
					CB9->CB9_STATUS := "2"  // embalado
					CB9->(MsUnlock())
					CB8->(DbSetOrder(4))
					CB8->(DbSeek(xFilial("CB8")+CB9->(CB9_ORDSEP+CB9_ITESEP+CB9_PROD+CB9_LOCAL+CB9_LCALIZ+CB9_LOTSUG+CB9_SLOTSU+CB9_NUMSER)))
					RecLock("CB8")
					CB8->CB8_SALDOE -= nSaldoEmb
					CB8->(MsUnlock())
					CB9->(DBGoto(nRecno))
					RecLock("CB9")  
					CB9->CB9_VOLUME := Space(10)
					CB9->CB9_QTESEP -= nSaldoEmb
					If Empty(CB9->CB9_QTESEP)
						CB9->(DBDelete())
					EndIf
					CB9->(MsUnlock())
					nSaldoEmb := 0
				EndIf
			EndIf
			If Empty(nSaldoEmb)
				exit
			EndIf
		Enddo
	Else
		CB9->(DbSetorder(8))
		If ! CB9->(DBSeek(xFilial("CB9")+cOrdSep+cProduto+cLote+cSLote+cNumSer+cVolumeEst))
			VtBeep(3)
			VtAlert(STR0105,STR0002,.t.,4000) //"Produto nao embalado"###"Aviso"
			VtKeyboard(Chr(20))  // zera o get
			Return .F.
		EndIf
		nSaldoEmb:=0
		While CB9->(! EOF() .AND. CB9_FILIAL+CB9_ORDSEP+CB9_PROD+CB9_LOTECT+CB9_NUMLOT+CB9_VOLUME ==;
			xFilial("CB9")+cOrdSep+cProduto+cLote+cSLote+cVolumeEst)
			nSaldoEmb += CB9->CB9_QTEEMB
			CB9->(DbSkip())
		Enddo
		If nQE > nSaldoEmb
			VtBeep(3)
			VtAlert(STR0111,STR0002,.t.,4000) //"Quantidade informada maior que embalado no volume "###"Aviso"
			VtKeyboard(Chr(20))  // zera o get
			Return .F.
		EndIf
		IF ! VtYesNo(STR0073,STR0002,.t.) //"Confirma o estorno?"###"Aviso"
			VtKeyboard(Chr(20))  // zera o get
			AtvRet(.f.)
			AtvAva(.f.)
			Return .F.
		EndIf

		nSaldoEmb := nQE
		CB9->(DbSetorder(8))
		While CB9->(DBSeek(xFilial("CB9")+cOrdSep+cProduto+cLote+cSLote+cNumSer+cVolumeEst))
			If nSaldoEmb >= CB9->CB9_QTEEMB
				nRecnoCB9:= CB9->(Recno())
				nQtdeSep := CB9->CB9_QTESEP
				CB9->(DbSetOrder(8))
				If CB9->(DBSeek( CB9_FILIAL+CB9_ORDSEP+CB9_PROD+CB9_LOTECT+CB9_NUMLOT+CB9_NUMSER+Space(10)+CB9_ITESEP+CB9_LOCAL+CB9_LCALIZ))
					RecLock("CB9")
					CB9->CB9_QTESEP += nQtdeSep
					CB9->(MsUnlock())
					CB9->(DbGoto(nRecnoCB9))
					CB8->(DbSetOrder(4))
					CB8->(DbSeek(xFilial("CB8")+CB9->(CB9_ORDSEP+CB9_ITESEP+CB9_PROD+CB9_LOCAL+CB9_LCALIZ+CB9_LOTSUG+CB9_SLOTSU+CB9_NUMSER)))
					RecLock("CB9")
					CB9->(DbDelete())
					CB9->(MsUnlock())
				Else
					CB9->(DbGoto(nRecnoCB9))
					RecLock("CB9")
					CB9->CB9_VOLUME := ""
					CB9->CB9_QTEEMB := 0
					CB9->CB9_CODEMB := ""
					CB9->CB9_STATUS := "1"  // embalado
					CB9->(MsUnlock())
					CB8->(DbSetOrder(4))
					CB8->(DbSeek(xFilial("CB8")+CB9->(CB9_ORDSEP+CB9_ITESEP+CB9_PROD+CB9_LOCAL+CB9_LCALIZ+CB9_LOTSUG+CB9_SLOTSU+CB9_NUMSER)))
				EndIf
				RecLock("CB8")
				CB8->CB8_SALDOE += nQtdeSep
				CB8->(MsUnlock())
				nSaldoEmb-=nQtdeSep
			Else
				nRecnoCB9:= CB9->(Recno())
				nQtdeSep := CB9->CB9_QTESEP
				CB9->(DbSetOrder(8))
				If CB9->(DBSeek( CB9_FILIAL+CB9_ORDSEP+CB9_PROD+CB9_LOTECT+CB9_NUMLOT+CB9_NUMSER+Space(10)+CB9_ITESEP+CB9_LOCAL+CB9_LCALIZ))
					RecLock("CB9")
					CB9->CB9_QTESEP += nSaldoEmb
					CB9->(MsUnlock())
					
					CB9->(DbGoto(nRecnoCB9))
					RecLock("CB9")
					//CB9->CB9_VOLUME := ""
					CB9->CB9_QTEEMB -= nSaldoEmb
					CB9->CB9_QTESEP -= nSaldoEmb
					//CB9->CB9_CODEMB := ''
					//CB9->CB9_STATUS := "1"
					If Empty(CB9->CB9_QTESEP)
						CB9->(DbDelete())
					EndIF
					CB9->(MsUnlock())
					CB8->(DbSetOrder(4))
					CB8->(DbSeek(xFilial("CB8")+CB9->(CB9_ORDSEP+CB9_ITESEP+CB9_PROD+CB9_LOCAL+CB9_LCALIZ+CB9_LOTSUG+CB9_SLOTSU+CB9_NUMSER)))
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
					CB8->(DbSetOrder(4))
					CB8->(DbSeek(xFilial("CB8")+CB9->(CB9_ORDSEP+CB9_ITESEP+CB9_PROD+CB9_LOCAL+CB9_LCALIZ+CB9_LOTSUG+CB9_SLOTSU+CB9_NUMSER)))
					RecLock("CB8")
					CB8->CB8_SALDOE += nSaldoEmb
					CB8->(MsUnlock())
					CB9->(DBGoto(nRecno))
					RecLock("CB9")
					CB9->CB9_VOLUME := cVolumeEst
					CB9->CB9_QTESEP -= nSaldoEmb
					CB9->CB9_QTEEMB -= nSaldoEmb
					If Empty(CB9->CB9_QTESEP)
						CB9->(DBDelete())
					EndIf
					CB9->(MsUnlock())
				EndIf
				nSaldoEmb := 0
			EndIf
			If Empty(nSaldoEmb)
				exit
			EndIf
		END
	EndIF
Else
	VtBeep(3)
	VtAlert(STR0022,STR0002,.t.,4000) //"Etiqueta invalida"###"Aviso"
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
EndIf
nQtde:=1
VTGetRefresh('nQtde')
VtKeyboard(Chr(20))  // zera o get
Return ! lEstorna

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ Desfaz   ³ Autor ³ ACD                   ³ Data ³ 03/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Desfaz a Separacao dos Produtos                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Desfaz()
Local nX
Local cArmazem    := Space(02)
Local cEndereco   := Space(15)
Local cEtiqEnd    := Space(20)
Local nPos
Local cDescProd   := ""
Local cRetPE      := ""
Local lMV_CFENDIG := GetMV('MV_CFENDIG') =="1"
Local lACD170DES  := ExistBlock("ACD170DES")
Private lDesfaz   := .t.
Private aItensCB9 := {}
Private nQtdLida  := 0
Private cVolume   := Space(10)
Private cLoteNew  := Space(10)
Private cSLoteNew := Space(6)

CB9->(DbSetOrder(6))
CB9->(DbSeek(xFilial("CB9")+cOrdSep))
While ! CB9->(Eof()) .and. CB9->(CB9_FILIAL+CB9_ORDSEP) == xFilial('CB9')+cOrdSep
	aadd(aItensCB9,{CB9->(Recno()),;
	CB9->CB9_ITESEP,;
	CB9->CB9_PROD,;
	CB9->CB9_LOCAL,;
	CB9->CB9_LCALIZ,;
	CB9->CB9_QTESEP,;
	CB9->CB9_QTESEP,;
	CB9->CB9_LOTECT,;
	CB9->CB9_NUMLOT,;
	CB9->CB9_NUMSER,;
	CB9->CB9_SUBVOL,;
	CB9->CB9_CODETI,;
	NIL,;
	CB9->CB9_LOTSUG,;
	CB9->CB9_SLOTSU,;
	CB9->CB9_STATUS})
	CB9->(DbSkip())
EndDo

For nX := 1 to Len(aItensCB9)
//	Begin Sequence
	lSaiEstorno:= .f.
	nQtdLida := 0
	If Empty(aItensCB9[nX,_POSSLDSEP])
		Loop
	EndIf
	CB9->(DbGoto(aItensCB9[nX,_POSRECNO]))
	lSeparou:= .t.
	If ! aItensCB9[nX,_POSARMAZEM]+aItensCB9[nX,_POSENDERECO] == cArmazem+cEndereco
		VTClear()
		cArmazem   := Space(Tamsx3("B1_LOCPAD")[1])
		cEndereco  := Space(15)
		cEtiqEnd   := Space(20)
		@ 1,0 VTSay STR0008 //'Va para o endereco'
		@ 2,0 VTSay aItensCB9[nX,_POSARMAZEM]+'-'+aItensCB9[nX,_POSENDERECO]
		If ! GETMV("MV_CONFEND") =="1"
			@ 6,0 VTPause STR0009 //'Enter para continuar'
		Else
			@ 4,0 VTSay STR0010 //'Leia o endereco'
			If UsaCB0('02')
				@ 5,0 VTGet cEtiqEnd pict '@!' valid VldEndDf(,,cEtiqEnd,nX)
			Else
				@ 5,0 VTGet cArmazem pict '@!' valid ! Empty(cArmazem)
				@ 5,3 VTSay "-" VTGet cEndereco pict '@!' valid VtLastKey()==5 .or. VldEndDf(cArmazem,cEndereco,,nX)
			EndIf
			VTRead
			AtvRet(.f.)
			AtvAva(.f.)
			If VTLastkey() == 27
				Return .F.
			EndIf
		EndIf
		cArmazem := aItensCB9[nX,_POSARMAZEM]
		cEndereco:= aItensCB9[nX,_POSENDERECO]
	EndIf
	VTClear()

	If GetNewPar("MV_OSEP2UN","0") $ "0 "
		@ 0,0 VTSay Padr(STR0112+Alltrim(Str(aItensCB9[nX,_POSSLDSEP],TamSx3("CB8_QTDORI")[1],TamSx3("CB8_QTDORI")[2]))+If(aItensCB9[nX,_POSSLDSEP]==1,STR0012,STR0013),20) //'Devolva '###' item '###' itens '
	Else
		SB1->(DbSetOrder(1))
		SB1->(DbSeek(xFilial("SB1")+aItensCB9[nX,_POSCODPRO]))
		nQtdCX:= CBQEmb()
		If ExistBlock('CBRQEESP')
			nQtdCX:=ExecBlock('CBRQEESP',,,SB1->B1_COD)
		EndIf
		If aItensCB9[nX,_POSSLDSEP]/nQtdCX < 1
			@ 0,0 VTSay Padr(STR0112+Alltrim(Str(aItensCB9[nX,_POSSLDSEP],TamSx3("CB8_QTDORI")[1],TamSx3("CB8_QTDORI")[2]))+If(aItensCB9[nX,_POSSLDSEP]==1,STR0012,STR0013),20) //'Devolva '###' item '###' itens '
		Else
			@ 0,0 VTSay Padr(STR0112+Alltrim(Str(aItensCB9[nX,_POSSLDSEP]/nQtdCX,TamSx3("CB8_QTDORI")[1],TamSx3("CB8_QTDORI")[2]))+If(aItensCB9[nX,_POSSLDSEP]/nQtdCX==1,STR0168,STR0169),20) //'Devolva ' //" Volume"###" Volumes"
		EndIf
	EndIf
	cDescProd := Posicione("SB1",1,xFilial('SB1')+aItensCB9[nX,_POSCODPRO],"B1_DESC")
	If	lACD170DES
		cRetPE    := ExecBlock("ACD170DES", .F., .F., {aItens[nX,_POSCODPRO]})
		cDescProd := If(ValType(cRetPe)=="C",cRetPE,cDescProd)
	EndIf
	@ 1,0 VTSay aItensCB9[nX,_POSCODPRO]
	@ 2,0 VTSay PADR(cDescProd,VTMaxCol())
	If Rastro(aItensCB9[nX,_POSCODPRO],"L")
		@ 3,0 VTSay STR0014 //'Lote       '
		@ 4,0 VTSay aItensCB9[nX,_POSLOTECTL]
	ElseIf Rastro(aItensCB9[nX,_POSCODPRO],"S")
		@ 3,0 VTSay STR0015 //'Lote       SubLote'
		@ 4,0 VTSay aItensCB9[nX,_POSLOTECTL]+' '+aItensCB9[nX,_POSNUMLOTE]
	EndIf

	If ! CBProdUnit(aItensCB9[nX,_POSCODPRO])  // granel
		cEtiqCaixa := Space(TamSx3("CB0_CODET2")[1])
		@ 6,0 VTSay STR0016 //"Leia a caixa"
		@ 7,0 VtGet cEtiqCaixa pict '@!' Valid VldCaixaDf(cEtiqCaixa,nX)
		VtRead
		AtvRet(.f.)
		AtvAva(.f.)
		If VTLastkey() == 27
			Return .F.
		EndIf
		cEtiqAvulsa:= Space(TamSx3("CB0_CODET2")[1])
		@ 5,0 VTClear to 7,19
		@ 5,0 VTSay STR0017 //"Leia a etiq. avulsa"
		@ 6,0 VTSay STR0113+aItensCB9[nX,_POSIDETI] //"com ID "
		@ 7,0 VtGet cEtiqAvulsa pict '@!' Valid VldEtAvDf(cEtiqAvulsa,nX)
		VtRead
		AtvRet(.f.)
		AtvAva(.f.)
		If VTLastkey() == 27
			Return .F.
		EndIf
	Else
		If UsaCB0("01")
			cEtiqProd  := Space(TamSx3("CB0_CODET2")[1])
			@ 5,0 VTSay STR0018 //'Leia a etiqueta'
			@ 6,0 VTSay STR0113+aItensCB9[nX,_POSIDETI] //"com ID "
			@ 7,0 VTGet cEtiqProd pict '@!' Valid VldEtiDf(cEtiqProd,nX)
			VTRead
			AtvRet(.f.)
			AtvAva(.f.)
			If VTLastkey() == 27
				If ! VldSaida(8)
					nX--
					Loop
				EndIf
				Return .F.
			EndIf
		Else
			nQtde := 1
			cProduto:= IIf( FindFunction( 'AcdGTamETQ' ), AcdGTamETQ(), Space(48) )
			If ! Empty(aItensCB9[nX,_POSNUMSERIE])
				@ 5,0 VTSay STR0170 //"Numero de Serie "
				@ 6,0 VTSay aItensCB9[nX,_POSNUMSERIE]
				@ 7,0 VTPause STR0009 //'Enter para continuar'
				VTClear()
				@ 0,0 VTSay STR0019 VtGet nQtde pict cPictQtdExp valid VldQtde(nQtde,.T.) when (lForcaQtd .or. VTLastkey() == 5) //'Qtde '
				@ 1,0 VTSay STR0020 //'Leia o produto'
				@ 2,0 VTGet cProduto pict '@!' VALID VTLastkey() == 5 .or. VldProdDf(cProduto,nX,nQtde)
			Else
				@ 5,0 VTSay STR0019 VtGet nQtde pict cPictQtdExp valid VldQtde(nQtde) when (lForcaQtd .or. VTLastkey() == 5) //'Qtde '
				@ 6,0 VTSay STR0020 //'Leia o produto'
				@ 7,0 VTGet cProduto pict '@!' VALID VTLastkey() == 5 .or. VldProdDf(cProduto,nX,nQtde)
			EndIf
			VTRead
			AtvRet(.f.)
			AtvAva(.f.)
			If VTLastkey() == 27
				If ! VldSaida(8)
					nX--
					Loop
				EndIf
				Return .F.
			EndIf
		EndIf
	EndIf
	If ! CBProdUnit(aItensCB9[nX,_POSCODPRO])  .or. UsaCB0("01")
		cCodEti := CB9->CB9_CODETI
	Else
		cCodEti := NIL
	End

	nPos := ascan(aItens,{|x| x[_POSCODPRO]+X[_POSARMAZEM]+X[_POSENDERECO]+X[_POSLOTECTL]+X[_POSNUMLOTE]+X[_POSNUMSERIE] == ;
	CB9->(CB9_PROD+CB9_LOCAL+CB9_LCALIZ+CB9_LOTSUG+CB9_SLOTSU+CB9_NUMSER)})
	cLoteNew:= CB9->CB9_LOTECT
	cSLoteNew:=CB9->CB9_NUMLOT

	If "01" $ cTipoExp .and. !("02" $ cTipoExp)
		cVolume:=CB9->CB9_VOLUME
	ElseIf "01" $ cTipoExp .and. "02" $ cTipoExp
		cVolume:=CB9->CB9_SUBVOL
	ElseIf "02" $ cTipoExp
		cVolume:=CB9->CB9_VOLUME
	EndIf
	If ! Grava(nPos,.T.,cVolume,cCodEti)
		nX--
		Loop
	EndIf
	aItensCB9[nX,_POSSLDSEP] -= nQtdLida

	If ! Empty(aItensCB9[nX,_POSSLDSEP])
		nX--
	Else
		If lMV_CFENDIG
			If Len(aItensCB9) > nX  .and. aItensCB9[nX,_POSCODPRO] # aItensCB9[nX+1,_POSCODPRO]
				cArmazem   := Space(Tamsx3("B1_LOCPAD")[1])
				cEndereco  := Space(15)
			EndIf
		EndIf
		cEtiqEnd   := Space(TamSx3("CB0_CODET2")[1])
		cEtiqProd  := Space(TamSx3("CB0_CODET2")[1])
		cEtiqCaixa := Space(TamSx3("CB0_CODET2")[1])
		cEtiqAvulsa:= Space(TamSx3("CB0_CODET2")[1])
		cProduto   := IIf( FindFunction( 'AcdGTamETQ' ), AcdGTamETQ(), Space(48) )
		nQtde      := 0
	EndIf
/*
	Recover
	nX:= 0
	End Sequence
*/
Next
Return .t.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ VldEndDf ³ Autor ³ ACD                   ³ Data ³ 03/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Funcao auxiliar chamada pela funcao Desfaz                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function VldEndDf(cArmazem,cEndereco,cEtiqEnd,nX)
Local aRet
VtClearBuffer()
If cArmazem == NIL // se cArmazem == NIL entao e' etiqueta de endereco com CB0
	aRet := CBRetEti(cEtiqEnd,'02')
	If len(aRet) == 0
		VtBeep(3)
		VtAlert(STR0022,STR0002,.t.,4000) //"Etiqueta invalida"###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
	cArmazem  := aRet[2]
	cEndereco := aRet[1]
EndIf
If !(cArmazem+cEndereco == aItensCB9[nX,_POSARMAZEM]+aItensCB9[nX,_POSENDERECO] )
	VtBeep(3)
	VtAlert(STR0023,STR0002,.t.,4000) //"Endereco incorreto"###"Aviso"
	VTClearGet("cArmazem")
	VTClearGet("cEndereco")
	VTGetSetFocus("cArmazem")
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
EndIf
If !CBEndLib(cArmazem,cEndereco) // verifica se o endereco esta liberado ou bloqueado
	VtBeep(3)
	VtAlert(STR0024,STR0002,.t.,4000) //"Endereco Bloqueado."###"Aviso"
	VTClearGet("cArmazem")
	VTClearGet("cEndereco")
	VTGetSetFocus("cArmazem")
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
EndIf
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³VldCaixaDf³ Autor ³ ACD                   ³ Data ³ 03/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Funcao auxiliar chamada pela funcao Desfaz                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function VldCaixaDf(cEtiqAvulsa,nX)
Local cCodPro
Local aRet
If Empty(cEtiqAvulsa)
	Return .f.
EndIf
If UsaCB0("01")
	aRet := CBRetEti(cEtiqAvulsa,"01")
	If len(aRet) == 0
		VtBeep(3)
		VtAlert(STR0022,STR0002,.t.,4000) //"Etiqueta invalida"###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
	cCodPro := aRet[1]
	If ! Empty(aRet[2])
		VtBeep(3)
		VtAlert(STR0022,STR0002,.t.,4000) //"Etiqueta invalida"###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
Else
	If !CBLoad128(@cEtiqAvulsa)
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
	If ! CbRetTipo(cEtiqAvulsa) $ "EAN8OU13-EAN14-EAN128"
		VtBeep(3)
		VtAlert(STR0022,STR0002,.t.,4000) //"Etiqueta invalida"###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
	aRet     := CBRetEtiEan(cEtiqAvulsa)
	If len(aRet) == 0
		VtBeep(3)
		VtAlert(STR0022,STR0002,.t.,4000) //"Etiqueta invalida"###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
	cCodPro := aRet[1]
EndIf
If !(aItensCB9[nX,_POSCODPRO] == cCodPro)
	VtBeep(3)
	VtAlert(STR0030,STR0002,.t.,4000) //"Etiqueta de produto diferente" //"Aviso"
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
EndIf
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ VldEtAvDf³ Autor ³ ACD                   ³ Data ³ 03/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Funcao auxiliar chamada pela funcao Desfaz                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function VldEtAvDf(cEtiqAvulsa,nX)
Local aEtiqueta:={}
If Empty(cEtiqAvulsa)
	Return .f.
EndIf
aEtiqueta := CBRetEti(cEtiqAvulsa,"01")
If Len(aEtiqueta) == 0
	VtBeep(3)
	VtAlert(STR0022,STR0002,.t.,4000) //"Etiqueta invalida"###"Aviso"
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
EndIf
nQtdLida := aEtiqueta[2]
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ VldEtiDf ³ Autor ³ ACD                   ³ Data ³ 03/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Funcao auxiliar chamada pela funcao Desfaz                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function VldEtiDf(cEtiqProd,nX)
Local aEtiqueta:={}
Private nQtdDev:=0
If Empty(cEtiqProd)
	Return .f.
EndIf

aEtiqueta:= CBRetEti(cEtiqProd,"01")
If Empty(aEtiqueta)
	VtBeep(3)
	VtAlert(STR0022,STR0002,.t.,4000) //"Etiqueta invalida"###"Aviso"
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
EndIf
If !  aItensCB9[nX,_POSIDETI] == CB0->CB0_CODETI
	VtBeep(3)
	VtAlert(STR0037,STR0002,.t.,4000) //"Produto diferente"###"Aviso"
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
EndIf
nQtdDev:= aItensCB9[nX,_POSSLDSEP]
If aEtiqueta[2] > nQtdDev
	VtBeep(3)
	VtAlert(STR0186,STR0002,.t.,4000) //"Quantidade excede o saldo a ser devolvido"###"Aviso"
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
Endif
If ExistBlock('ACD170VD')
	aEtiqueta:=ExecBlock('ACD170VD',,,aEtiqueta)
	If Empty(aEtiqueta)
		Return .f.
	EndIf
EndIf
nQtdLida := aEtiqueta[2]
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³VldProdDf ³ Autor ³ ACD                   ³ Data ³ 03/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Funcao auxiliar chamada pela funcao Desfaz - Tem como       ³±±
±±³			 ³objetivo validar as etiquetas de Produtos com Codigo Natural³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function VldProdDf(cProduto,nX,nQtde)
Local aRet   := {}
Local cLote  := Space(10)
Local cSLote := Space(6)
Local cNumSer:= Space(20)

If Empty(cProduto)
	Return .f.
EndIf
If !CBLoad128(@cProduto)
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
EndIf
If ! CbRetTipo(cProduto) $ "EAN8OU13-EAN14-EAN128"
	VtBeep(3)
	VtAlert(STR0022,STR0002,.t.,4000) //"Aviso" //"Etiqueta invalida"
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
EndIf
aRet     := CBRetEtiEan(cProduto)
If len(aRet) == 0
	VtBeep(3)
	VtAlert(STR0022,STR0002,.t.,4000) //"Etiqueta invalida"###"Aviso"
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
EndIf
cLote := aRet[3]
If ! CBRastro(aItensCB9[nX,_POSCODPRO],@cLote,@cSLote)
	VTKeyBoard(chr(20))
	Return .f.
EndIf
If ! cLote+cSLote == aItensCB9[nX,_POSLOTECTL]+aItensCB9[nX,_POSNUMLOTE]
	VtBeep(3)
	VtAlert(STR0033,STR0002,.t.,4000) //"Lote invalido"###"Aviso"
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
EndIf
cNumSer:= aRet[5]
If Empty(cNumSer) .and. CBSeekNumSer(cOrdSep,aItensCB9[nX,_POSCODPRO])
	If ! VldQtde(nQtde,.T.)
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
	If ! CBNumSer(@cNumSer,aItensCB9[nX,_POSNUMSERIE])
		VTKeyBoard(chr(20))
		Return .f.
	EndIf
EndIf
If aRet[2]*nQtde > aItensCB9[nX,_POSSLDSEP]
	VtBeep(3)
	VtAlert(STR0038,STR0002,.t.,4000) //"Quantidade maior que necessario"###"Aviso"
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
EndIf
nQtdLida := aRet[2]*nQtde
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ ImpNota  ³ Autor ³ ACD                   ³ Data ³ 03/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Funcao que confirma como impressa a Nota Fiscal de Saida   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ImpNota()

Local lPontoEntrada :=ExistBlock(GetMV("MV_CBIXBNF"))

If CB7->CB7_NFEMIT =="1" .or. ! lPontoEntrada
	Return .t.
EndIf
VTClear()
If ! VTYesNo(STR0114,STR0002,.t.) //"Confirma a impressao da nota"###"Aviso"
	If lRetrocede
		lExcluiNF := .t.
		Return .t.
	EndIF
	AtvAva(.f.)
	Return .f.
EndIf
ExecBlock(Alltrim(GETMV("MV_CBIXBNF")))
CB7->(RecLock('CB7'))
CB7->CB7_NFEMIT :="1"
If "04" $ cUltTipoExp
	CB7->CB7_STATUS := "9"  // finalizou...
	CBLogExp(cOrdSep)
	VTAlert(STR0006,STR0007,.t.,4000) //'Processo de expedicao finalizado'###'Aviso'
Else
	CB7->CB7_STATUS := "6"  // imprimiu nota fiscal
EndIf
CB7->(MsUnlock())

Return .t.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ ImpVolume³ Autor ³ ACD                   ³ Data ³ 03/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Gera Novas etiquetas de Volume e/ou SubVolumes             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ImpVolume()
Local aArea := sGetArea()
Local nX:= 0
Local aVolume:={}
Local lPontoEntrada :=ExistBlock('IMG05OFI')

If CB7->CB7_VOLEMI =="1" .or. ! lPontoEntrada
	Return .t.
EndIf
If ! VTYesNo(STR0115,STR0002,.t.) //"Confirma a impressao de etiquetas oficiais de volume"###"Aviso"
	AtvRet(.f.)
	AtvAva(.f.)
	Return .f.
EndIf
VTMsg(STR0116) //'Imprimindo ...'
aArea := sGetArea(aArea,"CB6")
CB5SetImp(cImp,.T.)
CB9->(DbSetOrder(1))
CB9->(DBSeek(xFilial("CB9")+CB7->CB7_ORDSEP))
While CB9->(!Eof() .and. xFilial("CB9")+CB7->CB7_ORDSEP == CB9_FILIAL+CB9_ORDSEP)
	If ascan(aVolume,CB9->CB9_VOLUME) ==0
		aadd(aVolume,CB9->CB9_VOLUME)
	EndIf
	CB9->(DbSkip())
EndDo
For nX := 1 to len(aVolume)
	CB6->(DBSetOrder(1))
	CB6->(DBSeek(xFilial("CB6")+aVolume[nX]))
	ExecBlock("IMG05OFI",,,{len(aVolume),nX})
Next
MSCBCLOSEPRINTER()
sRestArea(aArea)
CB7->(RecLock('CB7'))
CB7->CB7_VOLEMI :="1"
If "05" $ cUltTipoExp
	CB7->CB7_STATUS := "9"  // finalizou...
	CBLogExp(cOrdSep)
	VTAlert(STR0006,STR0007,.t.,4000) //'Processo de expedicao finalizado'###'Aviso'
Else
	CB7->CB7_STATUS := "7"  // imprimiu volume
EndIf
CB7->(MsUnlock())

Return .t.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ Embarque ³ Autor ³ ACD                   ³ Data ³ 03/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Processo de Embarque                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Embarque()
Local cEtiqProd
Local cProduto
Local nQtde
Local cTranspConf := Space(10)
Local nLinha
Local cF3Tra:=NIL
Local cDesTra
Private cVolume := Space(10)
Private lEmbarque := .t.

VtClear
CBFlagSC5("3",cOrdSep)  //Embarcado
RecLock("CB7")
CB7->CB7_STATUS := "8"    //Em processo de embarque
CB7->(MsUnlock())
If ! Empty(CB7->CB7_TRANSP)
	@ 0,0 VTSay STR0117 //"Va para doca "
	@ 1,0 VTSay STR0118 //"referente a  "
	@ 2,0 VTSay STR0119 //"transportadora:"
	@ 3,0 VTSay CB7->CB7_TRANSP
	@ 5,0 VTSay STR0120 //"Confirme a "
	@ 6,0 VTSay STR0121 //"transportadora"
	nLinha:= 7
Else
	@ 0,0 VTSay STR0122 //"Leia o codigo da"
	@ 1,0 VTSay STR0119 //"transportadora:"
	@ 2,0 VTSay STR0123 //"para embarcar"
	nLinha := 3
EndIf
while .t.
	If UsaCB0('06')
		cTranspConf := Space(10)
		cF3Tra :=NIL
	Else
		cTranspConf := Space(6)
		cF3Tra := 'SA4'
	EndIf
	@ nLinha,0 VTGet cTranspConf  pict "@!" Valid VldConfTransp(cTranspConf) F3 cF3Tra
	VTRead
	If VtLastKey() == 27
		If ! VldSaida(7)
			Loop
		EndIf
		If lRetrocede
			If "03" $ cTipoExp
				lExcluiNF := .t.
			EndIf
		EndIf
		Return .f.
	EndIf
	Exit
End
cDesTra := Posicione("SA4",1,xFilial("SA4")+CB7->CB7_TRANSP,"A4_NOME")
While .T.
	VTClear
	@ 0,0 VTSay STR0121 //"Transportadora"
	@ 1,0 VTSay CB7->CB7_TRANSP
	@ 2,0 VtSay SubStr(cDesTra,1,20)
	If '01' $ cTipoExp .or. '02' $ cTipoExp // trabalha com sub-volume
		cVolume := Space(10)
		@ 06,00 VtSay STR0071 //"Leia o volume"
		@ 07,00 VtGet cVolume Picture "@!" Valid VldEbqVol(cVolume)
	Else
		nQtde := 1
		cProduto   := IIf( FindFunction( 'AcdGTamETQ' ), AcdGTamETQ(), Space(48) )
		If ! Usacb0("01")
			@ 4,0 VTSay STR0019 VtGet nQtde pict cPictQtdExp valid VldQtde(nQtde,.T.) when (lForcaQtd .or. VTLastkey() == 5) //'Qtde '
		EndIf
		@ 5,0 VTSay STR0020 //'Leia o produto'
		@ 6,0 VtSay STR0124 //'a embarcar'
		@ 7,0 VTGet cProduto pict '@!' VALID VTLastkey() == 5 .or. VldProdEbq(cProduto,nQtde,Nil)
	EndIf
	VtRead
	If VtLastKey() == 27
		If ! VldSaida(7)
			Loop
		EndIf
		If lRetrocede
			If "03" $ cTipoExp
				lExcluiNF := .t.
			EndIf
		EndIf
		Return .f.
	EndIf
	CB9->(DbSetOrder(5))
	If ! CB9->(DbSeek(xFilial("CB9")+CB7->CB7_ORDSEP+"1")) .and. ! CB9->(DbSeek(xFilial("CB9")+CB7->CB7_ORDSEP+"2"))
		Exit
	EndIF
EndDo
RecLock("CB7")
CB7->CB7_STATUS := "9"    //embarcado/finalizado
CBLogExp(cOrdSep)
CB7->(MsUnlock())
VTAlert(STR0006,STR0007,.t.,4000) //'Processo de expedicao finalizado'###'Aviso'
Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³VldConfTransp³ Autor ³ ACD                ³ Data ³ 03/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Validacao da Transportadora Informada                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAACD                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function VldConfTransp(cTranspConf)
Local aRet
If Empty(cTranspConf)
	VtKeyBoard(chr(23))
EndIf
If UsaCB0("06")  // se usar CB0 para dispositivo
	aRet := CBRetEti(cTranspConf,"06")
	If len(aRet) == 0
		VtBeep(3)
		VtAlert(STR0022,STR0002,.t.,4000) //"Etiqueta invalida"###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
Else
	aRet := {PadR(cTranspConf,6)}
EndIf
If !Empty(CB7->CB7_TRANSP) .and. CB7->CB7_TRANSP <> aRet[1]
	VtBeep(3)
	VtAlert(STR0125,STR0002,.T.,4000) //"Transportadora invalida"###"Aviso"
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
EndIf
SA4->(DbSetOrder(1))
If !SA4->(DbSeek(xFilial("SA4")+aRet[1]))
	VtBeep(3)
	VtAlert(STR0126,STR0002,.T.,4000) //"Transportadora nao encontrada"###"Aviso"
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
EndIf
RecLock("CB7")
CB7->CB7_TRANSP := aRet[1]
CB7->(MsUnlock())
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ VldEbqVol³ Autor ³ ACD                   ³ Data ³ 03/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Validacao do Volume no embarque e no estorno do embarque   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function VldEbqVol(cVolume,lEstorna)
Local aRet:= {}
Default lEstorna := .F.

If Empty(cVolume)
	Return .f.
EndIf

If UsaCB0("05")
	aRet:= CBRetEti(cVolume,"05")
	If Empty(aRet)
		VtBeep(3)
		VtAlert(STR0082,STR0002,.t.,4000) //"Etiqueta de volume invalida"###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .f.
	Else
		cCodVol:= aRet[1]
	EndIf
Else
	cCodVol:= cVolume
EndIf

CB6->(DbSetOrder(1))
If ! CB6->(DbSeek(xFilial("CB6")+cCodVol))
	VtBeep(3)
	VtAlert(STR0127+cCodVol,STR0002,.t.,4000) //"Codigo de volume nao cadastrado "###"Aviso"
	VtKeyboard(Chr(20))  // zera o get
	return .f.
EndIf
If lEstorna
	If CB6->CB6_STATUS # "5"
		VtBeep(3)
		VtAlert(STR0128,STR0002,.t.,4000) //"Volume nao embarcado"###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		return .f.
	EndIf
EndIf
CB9->(DbSetOrder(4))
If !CB9->(DbSeek(xFilial("CB9")+cCodVol))
	VtBeep(3)
	VtAlert(STR0129,STR0002,.t.,4000) //"Volume nao encontrado"###"Aviso"
	VtKeyboard(Chr(20))  // zera o get
	return .f.
EndIf
If CB9->CB9_ORDSEP # CB7->CB7_ORDSEP
	VtBeep(3)
	VtAlert(STR0130+CB9->CB9_ORDSEP,STR0002,.t.,4000) //"Volume pertence a outra ordem de separacao "###"Aviso"
	VtKeyboard(Chr(20))  // zera o get
	return .f.
EndIf
If lEstorna
	IF ! VtYesNo(STR0073,STR0002,.t.) //"Confirma o estorno?"###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		AtvRet(.f.)
		AtvAva(.f.)
		Return .F.
	EndIf
Else
	IF CB9->CB9_STATUS =="3"
		VtBeep(3)
		VtAlert(STR0131,STR0002,.t.,4000) //"Volume ja lido"###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		return .f.
	EndIf
EndIf
RecLock("CB7")
CB7->CB7_STATUS := "9"    //Embarque finalizado...
CB7->(MsUnlock())
CB9->(DbSetOrder(2))
CB9->(DbSeek(xFilial("CB9")+CB7->CB7_ORDSEP+cCodVol))
While CB9->(! EOF() .and. CB9_FILIAL+CB9_ORDSEP+CB9_VOLUME == ;
	xFilial("CB9")+cOrdSep+cCodVol)
	RecLock("CB9")
	If lEstorna
		CB9->CB9_QTEEBQ := 0.00
		CB9->CB9_STATUS := "2"  // EMBALAGEM FINALIZADA
	Else
		CB9->CB9_QTEEBQ := CB9->CB9_QTESEP
		CB9->CB9_STATUS := "3"  // EMBARCADO
	EndIf
	CB9->(MsUnLock())
	CB9->(DBSkip())
End
RecLock("CB6")
If lEstorna
	CB6->CB6_STATUS := "1"   // VOLUME EM ABERTO
	CB6->CB6_CODEB1 := ""
	CB6->CB6_CODEB2 := ""
Else
	CB6->CB6_STATUS := "5"   // EMBARQUE
	CB6->CB6_CODEB1 := cCodOpe
	CB6->CB6_CODEB2 := cCodOpe
EndIf
CB6->(MsUnlock())
VtKeyboard(Chr(20))  // zera o get
Return ! lEstorna

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³VldProdEbq³ Autor ³ ACD                   ³ Data ³ 03/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Validacao do Produto no embarque e no estorno do embarque   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAACD                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function VldProdEbq(cEProduto,nQtde,lEstorna)
Local cTipo
Local aEtiqueta,aRet
Local cLote    := Space(10)
Local cSLote   := Space(6)
Local cNumSer  := Space(20)
Local nQE:=0
Local nQEConf:=0
Local nSaldoEmb
Local cProduto
Local nQtdBaixa:=0
Default lEstorna := .F.

If !CBLoad128(@cEProduto)
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
EndIf
cTipo := CBRetTipo(cEProduto)
If cTipo == "01"
	aEtiqueta:= CBRetEti(cEProduto,"01")
	If Empty(aEtiqueta)
		VtBeep(3)
		VtAlert(STR0022,STR0002,.t.,4000) //"Etiqueta invalida"###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
	CB9->(DbSetorder(1))
	If ! CB9->(DbSeek(xFilial("CB9")+cOrdSep+Left(cEProduto,10)))
		VtBeep(3)
		VtAlert(STR0072,STR0002,.t.,4000) //"Produto nao separado"###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
	cProduto:= aEtiqueta[1]
	nQE     := aEtiqueta[2]
	cLote   := aEtiqueta[16]
	cSLote  := aEtiqueta[17]
	nQEConf := nQE
	If ! CBProdUnit(aEtiqueta[1]) .and. GetMv("MV_CHKQEMB") =="1"
		nQEConf := CBQtdEmb(aEtiqueta[1])
	EndIf
	If Empty(nQEConf) .or. nQE # nQEConf
		VtBeep(3)
		VtAlert(STR0107,STR0002,.t.,4000) //"Quantidade invalida "###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .f.
	EndIf
	If lEstorna
		If CB9->CB9_STATUS == "1"  // STATUS=1 (EM ABERTO)
			VtBeep(3)
			VtAlert(STR0132,STR0002,.t.,4000) //"Produto nao embarcado"###"Aviso"
			VtKeyboard(Chr(20))  // zera o get
			Return .f.
		EndIf
		If ! VtYesNo(STR0073,STR0002,.t.) //"Confirma o estorno?"###"Aviso"
			VtKeyboard(Chr(20))  // zera o get
			AtvRet(.f.)
			AtvAva(.f.)
			Return .F.
		EndIf
	Else
		If CB9->CB9_STATUS # "1"  // STATUS=1 (EM ABERTO)
			VtBeep(3)
			VtAlert(STR0133,STR0002,.t.,4000) //"Produto ja embarcado"###"Aviso"
			VtKeyboard(Chr(20))  // zera o get
			Return .f.
		EndIf
	EndIf
	If lEstorna
		RecLock("CB9")
		CB9->CB9_QTEEBQ := 0.00
		CB9->CB9_STATUS := "1"  // em aberto
		CB9->(MsUnlock())
	Else
		RecLock("CB9")
		CB9->CB9_QTEEBQ += nQE
		CB9->CB9_STATUS := "3"  // embarcado
		CB9->(MsUnlock())
	EndIf
ElseIf cTipo $ "EAN8OU13-EAN14-EAN128"
	aRet     := CBRetEtiEan(cEProduto)
	If len(aRet) == 0
		VtBeep(3)
		VtAlert(STR0022,STR0002,.t.,4000) //"Etiqueta invalida"###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
	cProduto := aRet[1]
	If ! CBProdUnit(cProduto)
		VtBeep(3)
		VtAlert(STR0022,STR0002,.t.,4000) //"Etiqueta invalida"###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
	nQE  :=CBQtdEmb(cProduto)*nQtde
	If Empty(nQE)
		VtBeep(3)
		VtAlert(STR0031,STR0002,.t.,4000) //"Quantidade invalida"###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
	cLote := aRet[3]
	If ! CBRastro(aRet[1],@cLote,@cSLote)
		VTKeyBoard(chr(20))
		Return .f.
	EndIf
	cNumSer:= aRet[5]
	If Empty(cNumSer) .and. CBSeekNumSer(cOrdSep,cProduto)
		If ! VldQtde(nQtde,.T.)
			VtKeyboard(Chr(20))  // zera o get
			Return .F.
		Endif
		If ! CBNumSer(@cNumSer)
			VTKeyBoard(chr(20))
			Return .f.
		EndIf
	EndIf
	CB9->(DbSetorder(8))
	If ! CB9->(DBSeek(xFilial("CB9")+cOrdSep+cProduto+cLote+cSLote+cNumSer+space(10)))
		VtBeep(3)
		VtAlert(STR0109,STR0002,.t.,4000) //"Produto invalido"###"Aviso"
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
	nSaldoEmb:=0
	While CB9->(! EOF() .AND. CB9_FILIAL+CB9_ORDSEP+CB9_PROD+CB9_LOTECT+CB9_NUMLOT+CB9_VOLUME ==;
		xFilial("CB9")+cOrdSep+cProduto+cLote+cSLote+space(10))
		If lEstorna
			nSaldoEmb += CB9->CB9_QTEEBQ
		Else
			nSaldoEmb += CB9->CB9_QTESEP-CB9->CB9_QTEEBQ
		EndIf
		CB9->(DbSkip())
	Enddo
	If nQE > nSaldoEmb
		VtBeep(3)
		If lEstorna
			VtAlert(STR0134,STR0002,.t.,4000) //"Quantidade informada maior que a quantidade embarcada"###"Aviso"
		Else
			VtAlert(STR0135,STR0002,.t.,4000) //"Quantidade informada maior que disponivel para o embarque"###"Aviso"
		EndIf
		VtKeyboard(Chr(20))  // zera o get
		Return .F.
	EndIf
	If lEstorna
		If ! VtYesNo(STR0073,STR0002,.t.) //"Confirma o estorno?"###"Aviso"
			VtKeyboard(Chr(20))  // zera o get
			AtvRet(.f.)
			AtvAva(.f.)
			Return .F.
		EndIf
	EndIf
	nSaldoEmb := nQE
	nQtdBaixa :=0
	CB9->(DbSetorder(8))
	CB9->(DBSeek(xFilial("CB9")+cOrdSep+cProduto+cLote+cSLote+cNumSer+space(10)))
	While CB9->(! EOF() .AND. CB9_FILIAL+CB9_ORDSEP+CB9_PROD+CB9_LOTECT+CB9_NUMLOT+CB9_VOLUME ==;
		xFilial("CB9")+cOrdSep+cProduto+cLote+cSLote+space(10)) .and. ! Empty(nSaldoEmb)
		If lEstorna
			If Empty(CB9->CB9_QTEEBQ)
				CB9->(DBSkip())
				Loop
			EndIf
		Else
			If CB9->CB9_STATUS == '3'
				CB9->(DBSkip())
				Loop
			EndIf
		EndIf
		nQtdBaixa := nSaldoEmb
		If lEstorna
			If nSaldoEmb >= CB9->CB9_QTEEBQ
				nQtdBaixa := CB9->CB9_QTEEBQ
			EndIf
		Else
			If nSaldoEmb >= (CB9->CB9_QTESEP-CB9->CB9_QTEEBQ)
				nQtdBaixa := (CB9->CB9_QTESEP-CB9->CB9_QTEEBQ)
			EndIf
		EndIf
		RecLock("CB9")
		If lEstorna
			CB9->CB9_QTEEBQ -=nQtdBaixa
			CB9->CB9_STATUS := "1"  // em aberto
		Else
			CB9->CB9_QTEEBQ +=nQtdBaixa
			If CB9->CB9_QTEEBQ == CB9->CB9_QTESEP
				CB9->CB9_STATUS := "3"  // embarcado
			EndIf
		EndIf
		CB9->(MsUnlock())
		nSaldoEmb -=nQtdBaixa
		CB9->(DbSkip())
	Enddo
Else
	VtBeep(3)
	VtAlert(STR0022,STR0002,.t.,4000) //"Etiqueta invalida"###"Aviso"
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
EndIf
nQtde:=1
VTGetRefresh('nQtde')
VtKeyboard(Chr(20))  // zera o get
Return ! lEstorna

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ GeraNota ³ Autor ³ ACD                   ³ Data ³ 03/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Executa a Preparacao da Nota Fiscal de Saida               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function GeraNota()
Local aPvlNfs := {}
Local cSerie  := GetMV("MV_ACDSERI")
Local lExcNF  := GetMV("MV_CBEXCNF")=='1'
Local nTamSX1 := Len(SX1->X1_GRUPO)
Local aRegSD2
Local aRegSE1
Local aRegSE2
Local lSai       := .f.
Local lCtbOnLine := .f.
Private nModulo    := 4


If SX1->(DbSeek(PADR("MT460A",nTamSX1)+"03"))
	lCtbOnLine := (SX1->X1_PRESEL==1)
EndIf

If CB7->CB7_STATUS < '5' .or. lDesfazTudo .or. lExcluiNF

	If ! EMPTY(CB7->(CB7_NOTA+CB7_SERIE))
		If !lExcNF
			VTBeep(3)
			VTAlert(STR0187,STR0002,.t.,6000) //"Aviso" //"Conforme informado no parametro MV_CBEXCNF a nota deve ser excluida pelo Protheus"
			AtvRet(.f.)
			AtvAva(.f.)
			Return .f.
		EndIf
		If ! VTYesNo(STR0136,STR0002,.t.) //"Deseja excluir a nota?"###"Aviso"
			If lAvanca
				Return .t.
			EndIf
			AtvRet(.f.)
			AtvAva(.f.)
			Return .f.
		EndIf
		Begin transaction
		VTClear()
		VTMsg(STR0137) //'Excluindo nota...'
		If ExistBlock("ACD170FIM")  //Ponto de Entrada antes da Tratativa da Nota Fiscal (2 = exclusao)
			ExecBlock("ACD170FIM",,,{2,CB7->CB7_NOTA,CB7->CB7_SERIE})
		EndIf
		SF2->(DbSetOrder(1))
		If ! SF2->(DbSeek(xFilial("SF2")+CB7->(CB7_NOTA+CB7_SERIE)))
			VTAlert(STR0188+CB7->(CB7_NOTA+"-"+CB7_SERIE)+STR0189,STR0002,.t.,6000,3) //"Aviso" //"Nota "###" nao encontrada "
			BREAK
		EndIf
		If ! MaCanDelF2("SF2",SF2->(RecNo()),@aRegSD2,@aRegSE1,@aRegSE2)
			VTAlert(STR0138,STR0002,.t.,6000,3) //"Falha na exclusao da nota"###"Aviso"
			BREAK
		EndIf
		SF2->(MaDelNFS(aRegSD2,aRegSE1,aRegSE2,.F.,.F.,.F.,.T.))
		Libera(nil,.t.) // no programa acdv168 o Anderson nao colocou esta linha - by Erike
		AtuCB0(cNota,cSerie,.t.)
		End transaction
		If lDesfazTudo .or. lExcluiNF
			//lExcluiNF     := .f.
			lEstEmbalagem := .t.
			lRetrocede    := .t.
			If "00" $ cTipoExp .and. !("02" $ cTipoExp)
				lRetSepara:=.t.
			EndIf
		EndIf
	Else
		If ! VTYesNo(STR0139,STR0002,.t.) //"Confirma a geracao da nota?"###"Aviso"
			If lDesfazTudo .or. lExcluiNF
				lExcluiNF     := .f.
				lEstEmbalagem := .t.
				lRetrocede    := .t.
				lRetSepara    := .t.
			Else
				RecLock("CB7")
				CB7->CB7_STATPA := "1"  // EM PAUSA
				CB7->(MsUnlock())
			EndIf
			If lRetrocede
				Return .f.
			Endif
			If ! VTYesNo(STR0190,STR0002,.t.) //"Confirma saida?"###"Aviso"
				AtvRet(.t.)
			Else
				AtvRet(.f.)
			EndIf
			AtvAva(.f.)
			Return .t.
		EndIf

		Begin transaction

		VTClear()
		VTMsg(STR0140) //'Gerando nota...'
		Libera(aPvlNfs)
		If Empty(aPvlNfs)
			VTAlert(STR0141,STR0007,.t.,2000) //'Problema com empenho'###'Aviso'
			MsUnLockAll()
			lSai:= .t.
			BREAK
		EndIf
		cNota := MaPvlNfs(aPvlNfs,cSerie, .F.     , .F.     ,lCtbOnLine   , .T.     , .F.     , 0     , 0          , .T.   , .F.) 
		//cNota := MaPvlNfs(aPvlNfs,cSerie,lMostraCtb,lAglutCtb,lCtbOnLine,lCtbCusto,lReajusta,nCalAcrs,nArredPrcLis,lAtuSA7,lECF,cembexp)	
		AtuCB0(cNota,cSerie)

		End transaction
		dbUnLockAll()

		If lMsErroAuto
			VTDispFile(NomeAutoLog(),.t.)
		EndIf
		If lSai .OR. lMsErroAuto
			Return .f.
		Endif
		If !lMsErroAuto .and. ExistBlock("ACD170FIM")  //Ponto de Entrada apos a Tratativa da Nota Fiscal (1 = geracao)
			ExecBlock("ACD170FIM",,,{1,cNota,cSerie})
		EndIf
	EndIf
	MsUnLockAll()
	Reclock('CB7')
	If lExcluiNF .or. lDesfazTudo
		lExcluiNF  :=.f.
		lDesfazTudo:=.f.
		If "01" $ CB7->CB7_TIPEXP .OR. "02" $ CB7->CB7_TIPEXP
			CB7->CB7_STATUS := "4"  // Embalagem finalizada
		Else
			CB7->CB7_STATUS := "2"  // Separacao finalizada
		Endif
	Else
		If "03" $ cUltTipoExp
			CB7->CB7_STATUS := "9"  // FINALIZADO
			CBLogExp(cOrdSep)
			VTAlert(STR0006,STR0007,.t.,4000) //'Processo de expedicao finalizado'###'Aviso'
		Else
			CB7->CB7_STATUS := "5"  // gerado nota fiscal
		EndIf
	EndIf
	CB7->(MsUnLock())
EndIf
Return .t.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ AtuCB0   ³ Autor ³ ACD                   ³ Data ³ 03/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Atualiza CB0 e outros dados apos a geracao da nota fiscal  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function AtuCB0(cNota,cSerie,lEstorna)
Local aVolume := {}
Local aRetCB0 := {}
Default lEstorna := .f.
CB7->(DbSetOrder(1))
CB7->(DbSeek(xFilial("CB7")+cOrdSep))

CB6->(DBSetOrder(1))
// soma a quantidade de volumes da ordem de separacao
CB9->(DbSetOrder(1))
CB9->(DBSeek(xFilial("CB9")+CB7->CB7_ORDSEP))
While CB9->(!Eof() .and. xFilial("CB9")+CB7->CB7_ORDSEP == CB9_FILIAL+CB9_ORDSEP)
	If ascan(aVolume,CB9->CB9_VOLUME) ==0
		aadd(aVolume,CB9->CB9_VOLUME)
		If CB6->(DbSeek(xFilial("CB6")+CB9->CB9_VOLUME))
			RecLock('CB6')
			If !lEstorna
				CB6->CB6_NOTA := cNota
				CB6->CB6_SERIE:= cSerie
			Else
				CB6->CB6_NOTA := ''
				CB6->CB6_SERIE:= ''
			EndIf
			CB6->(MsUnlock())
		EndIf
	EndIf
	aRetCB0 := CBRetEti(CB9->CB9_CODETI,'01')
	If Len(aRetCB0) > 0
		If ! lEstorna
			aRetCB0[13] := cNota
			aRetCB0[14] := cSerie
		Else
			aRetCB0[13] := ''
			aRetCB0[14] := ''
		EndIf
		CBGrvEti("01",aRetCB0,CB9->CB9_CODETI)
	EndIf
	If lEstorna // Se for exclusao da nota sempre estorna o embarque se tiver
		RecLock('CB9',.f.)
		CB9->CB9_QTEEBQ := 0.00
		CB9->CB9_STATUS := "2"  // EMBALAGEM FINALIZADA
		CB9->(MsUnlock())
	EndIf
	CB9->(DbSkip())
EndDo
If !lEstorna
	SF2->(DbSetOrder(1))
	SF2->(DbSeek(xFilial("SF2")+cNota+cSerie))
	RecLock("SF2",.F.)
	SF2->F2_VOLUME1 := Len(aVolume)   // grava quantidade de volumes na nota
	SF2->(MsUnlock())

	SD2->(DbSetOrder(3))
	If SD2->(DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
		RecLock("SD2",.F.)
		While SD2->(! Eof()) .and. SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA ==;
									SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA
			RecLock("SD2",.F.)
			SD2->D2_ORDSEP:= cOrdSep   // grava ordem de separacao
			SD2->(MsUnlock())
			SD2->(DbSkip())
		EndDo
		SD2->(MsUnlock())
	Endif
	RecLock('CB7')
	CB7->CB7_NOTA := cNota
	CB7->CB7_SERIE:= cSerie
	CB7->CB7_VOLEMI:= " "
	CB7->CB7_NFEMIT:= " "
	CB7->(MsUnlock())
Else
	RecLock('CB7')
	CB7->CB7_NOTA   := ""
	CB7->CB7_SERIE  := ""
	CB7->CB7_VOLEMI := " "
	CB7->CB7_NFEMIT := " "
	CB7->(MsUnlock())
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ Libera   ³ Autor ³ ACD                   ³ Data ³ 03/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Faz a liberacao do Pedido de Venda para a geracao da NF    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Libera(aPvlNfs,lEstorno,aItensDiverg)
Local cOrdSep   := CB7->CB7_ORDSEP
Local nX,nI
Local nQtdLib   := 0
Local nPosItemDiv
Local lContinua := .f.
Local lRefazSC9 := .f.
Local aPedidos  :={}
Local aEmp      :={}

Default lEstorno	 := .F.
Default aItensDiverg := {}

CB8->(DbSetOrder(1))
CB8->(DbSeek(xFilial("CB8")+cOrdSep))
Do While  CB8->(! Eof() .AND. CB8_FILIAL+CB8_ORDSEP==xFilial('CB8')+cOrdSep)
	If aScan(aPedidos, {|x| x[1]+x[2] == CB8->CB8_PEDIDO+CB8->CB8_ITEM}) == 0 
		aAdd(aPedidos,{CB8->CB8_PEDIDO,CB8->CB8_ITEM, CB8->CB8_SEQUEN, CB8->(Recno())})
	EndIf
	CB8->(DbSkip())
EndDo

aPvlNfs  :={}
For nX:= 1 to len(aPedidos)
	
	CB8->(dbGoto(aPedidos[nX, 4]))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Libera quantidade embarcada³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SC5->(dbSetOrder(1)) //-- C5_FILIAL+C5_NUM
	SC5->(DbSeek(xFilial("SC5")+aPedidos[nx,1]))
	SC6->(DbSetOrder(1)) //-- C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
	SC6->(DbSeek(xFilial("SC6")+aPedidos[nx,1]+aPedidos[nx,2]))
	SC9->(DbSetOrder(1)) //-- C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
	If !SC9->(DbSeek(xFilial("SC9")+aPedidos[nx,1]+aPedidos[nx,2], .F.))
		If lEstorno
			Do While SC6->(!Eof() .and. C6_FILIAL+C6_NUM+C6_ITEM==xFilial("SC6")+aPedidos[nX,1]+aPedidos[nx,2])
				aEmp := CarregaEmpenho(lEstorno)
				nQtdLib := SC6->C6_QTDVEN
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ LIBERA (Pode fazer a liberacao novamente caso com novos lotes³
				//³         caso possua)                                         ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				MaLibDoFat(SC6->(Recno()),nQtdLib,.T.,.T.,.F.,.F.,	.F.,.F.,	NIL,{||SC9->C9_ORDSEP := cOrdSep},aEmp,.T.)
				SC6->(DbSkip())
			EndDo
		EndIf
		Loop
	EndIf
	
	Do While SC6->(!Eof() .and. C6_FILIAL+C6_NUM+C6_ITEM==xFilial("SC6")+aPedidos[nx,1]+aPedidos[nx,2])
		
		If !Empty(aItensDiverg)
			nPosItemDiv := Ascan(aItensDiverg,{|x| x[1]+x[2]+x[3]== SC6->(C6_NUM+C6_ITEM+C6_PRODUTO)})
			If nPosItemDiv == 0
				SC6->(DbSkip())
				Loop
			EndIf
		EndIf
		If lEstorno
			nQtdLib := SC6->C6_QTDVEN
		Else
			nQtdLib := SC6->C6_QTDEMP
		EndIf

		lContinua:= .F.
		Do While SC9->(! Eof() .and. C9_FILIAL+C9_PEDIDO+C9_ITEM==xFilial("SC9")+SC6->(C6_NUM+C6_ITEM))
			If Empty(SC9->C9_NFISCAL) .And. ;
				Empty(SC9->C9_BLEST)   .And. ;
				Empty(SC9->C9_BLCRED)  .And. ;
				(SC9->C9_BLWMS$'05,06,07,  ') .And. ;
				(SC9->C9_AGREG==CB7->CB7_AGREG) .And. ;
				(SC9->C9_ORDSEP==CB7->CB7_ORDSEP)			
				lContinua := .T.
				Exit
			EndIf
			SC9->(DbSkip())
		EndDo
		
		If !lContinua
			SC6->(DbSkip())
			Loop
		EndIf

		//Esta validacao sera verdadeira se o produto tiver rastro e nao houver verficacao no momento da leitura
		//sendo assim sendo necessario estonar o SDC e gera outro conforme os itens lidos pelo coletor.
		//ou se o item do pedido estiver marcado com divergencia da leitura o mesmo devera ser estornado e sera
		//necessario liberar novamente sem o vinculo da ordem de separacao.
		If (!RASTRO(SC6->C6_PRODUTO) .AND. CB8->CB8_CFLOTE <> "1" ) .or. ! Empty(aItensDiverg)    
			aEmp 			:= CarregaEmpenho(lEstorno) // Nao eh estorno    
			SC9->(DbSeek(xFilial("SC9")+SC6->(C6_NUM+C6_ITEM), .F.))
			SC9->(a460Estorna())	 //estorna o que estava liberado no sdc e sc9
			If !Empty(aItensDiverg)
				// NAO LIBERA CREDITO NEM ESTOQUE...ITEM COM DIVERGENCIA APONTADA (MV_DIVERPV)
				MaLibDoFat(SC6->(Recno()),0,.F.,.F.,.F.,.F.,	.F.,.F.,	NIL,{||SC9->C9_ORDSEP := Space(TamSx3("C9_ORDSEP")[1])},aEmp,.T.)
			Else
				// LIBERA NOVAMENTE COM OS NOVOS LOTES
				MaLibDoFat(SC6->(Recno()),nQtdLib,.T.,.T.,.F.,.F.,	.F.,.F.,	NIL,{||SC9->C9_ORDSEP := cOrdSep},aEmp,.T.)
			EndIf
		EndIf

		SC9->(DbSetOrder(1))
		SC9->(DbSeek(xFilial("SC9")+SC6->(C6_NUM+C6_ITEM)))               //FILIAL+NUMERO+ITEM
		Do While SC9->(! Eof() .and. C9_FILIAL+C9_PEDIDO+C9_ITEM==xFilial("SC9")+SC6->(C6_NUM+C6_ITEM))
			If !Empty(SC9->C9_NFISCAL) .Or. ;
				!Empty(SC9->C9_BLEST)   .Or. ;
				!Empty(SC9->C9_BLCRED)  .Or. ;
				!(SC9->C9_BLWMS$'05,06,07,  ') .Or. ;
				(SC9->C9_AGREG#CB7->CB7_AGREG) .Or. ;
				(SC9->C9_ORDSEP#CB7->CB7_ORDSEP)			
				SC9->(DbSkip())
				Loop
			EndIf
			SE4->(DbSetOrder(1))
			SE4->(DbSeek(xFilial("SE4")+SC5->C5_CONDPAG))
			SB1->(DbSetOrder(1))
			SB1->(DbSeek(xFilial("SB1")+SC6->C6_PRODUTO))              //FILIAL+PRODUTO
			SB2->(DbSetOrder(1))
			SB2->(DbSeek(xFilial("SB2")+SC6->(C6_PRODUTO+C6_LOCAL)))  //FILIAL+PRODUTO+LOCAL
			SF4->(DbSetOrder(1))
			SF4->(DbSeek(xFilial("SF4")+SC6->C6_TES) )                 //FILIAL+CODIGO
			SC9->(aadd(aPvlNfs,{C9_PEDIDO,;
			C9_ITEM,;
			C9_SEQUEN,;
			C9_QTDLIB,;
			C9_PRCVEN,;
			C9_PRODUTO,;
			(SF4->F4_ISS=="S"),;
			SC9->(RecNo()),;
			SC5->(RecNo()),;
			SC6->(RecNo()),;
			SE4->(RecNo()),;
			SB1->(RecNo()),;
			SB2->(RecNo()),;
			SF4->(RecNo())}))
			SC9->(DbSkip())
		EndDo
		SC6->(DbSkip())
	Enddo
Next
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ CarregaEmpenho  ³ Autor ³ ACD            ³ Data ³ 03/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Reajusta o empenho dos produtos separados caso necessario  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CarregaEmpenho(lEstorno)
Local aEmp:={}
Local aEtiqueta:={}
CB9->(DBSetOrder(11))
CB9->(DbSeek(xFilial("CB9")+CB7->CB7_ORDSEP+SC6->C6_ITEM+SC6->C6_NUM))
While CB9->(! Eof() .and. CB9_FILIAL+CB9_ORDSEP+CB9_ITESEP+CB9_PEDIDO == xFilial("CB9")+CB7->CB7_ORDSEP+SC6->C6_ITEM+SC6->C6_NUM)
	If lEstorno
		nPos :=ascan(aEmp,{|x| x[1]+x[2]+x[3]+x[11] == CB9->(CB9_LOTSUG+CB9_SLOTSU+CB9_LCALIZ+CB9_LOCAL)})
	Else
		nPos :=ascan(aEmp,{|x| x[1]+x[2]+x[3]+x[11] == CB9->(CB9_LOTECT+CB9_NUMLOT+CB9_LCALIZ+CB9_LOCAL)})
	EndIf
	If nPos ==0
		If lEstorno
			CB9->(aadd(aEmp,{CB9_LOTSUG,CB9_SLOTSU,CB9_LCALIZ,CB9_NUMSER,CB9_QTESEP,ConvUM(CB9_PROD,CB9_QTESEP,0,2),,,,,CB9_LOCAL,0}))
		Else
			CB9->(aadd(aEmp,{CB9_LOTECT,CB9_NUMLOT,CB9_LCALIZ,CB9_NUMSER,CB9_QTESEP,ConvUM(CB9_PROD,CB9_QTESEP,0,2),,,,,CB9_LOCAL,0}))
		EndIf
	Else
		aEmp[nPos,5] +=CB9->CB9_QTESEP
	EndIF

	If ! Empty(CB9->CB9_CODETI)
		aEtiqueta := CBRetEti(CB9->CB9_CODETI,"01")
		If ! Empty(aEtiqueta)
			aEtiqueta[13]:= CB7->CB7_NOTA
			aEtiqueta[14]:= CB7->CB7_SERIE
			CBGrvEti("01",aEtiqueta,CB9->CB9_CODETI)
		EndIf
	EndIf
	CB9->(DBSkip())
EndDo
Return aEmp

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ RequisitOP ³ Autor ³ ACD                 ³ Data ³ 03/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Executa rotina automatica de requisicao - MATA240          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function RequisitOP()
Local aMata
Local dValid,cTM
Local	nModuloOld  := nModulo
Local cItem       := ""
Local lEstorno    := .f.
Local aCab        :={}
Local aItens      :={}
Private nModulo   := 4

If CB7->CB7_REQOP == "1"
	lEstorno := .t.
EndIF

lMsErroAuto:= .f.

If ! lEstorno
	If ! VTYesNo(STR0142,STR0002,.t.) //"Confirma a requisicao dos itens?"###"Aviso"
		AtvRet(.f.)
		AtvAva(.f.)
		Return .f.
	EndIf
Else
	If ! VTYesNo(STR0143,STR0002,.t.) //"Confirma o estorno da requisicao dos itens?"###"Aviso"
		AtvRet(.f.)
		AtvAva(.f.)
		Return .f.
	EndIf
	//cTM := GETMV("MV_CBDEVD3")
EndIf
Begin Transaction
cTM := GETMV("MV_CBREQD3")
VTMSG(STR0144) //'Processando'
CB9->(DBSetOrder(1))
CB9->(DbSeek(xFilial("CB9")+CB7->CB7_ORDSEP))
SB1->(DbSetOrder(1))
While CB9->(! Eof() .and. xFilial("CB9")+CB7->CB7_ORDSEP == CB9_FILIAL+CB9_ORDSEP)
	
	CB8->(DbSetOrder(4))
	CB8->(DbSeek(xFilial("CB8")+CB9->(CB9_ORDSEP+CB9_ITESEP+CB9_PROD+CB9_LOCAL+CB9_LCALIZ+CB9_LOTSUG+CB9_SLOTSU+CB9_NUMSER)))
	SB1->(DbSeek(xFilial("SB1")+CB9->CB9_PROD))
	dValid := dDataBase+SB1->B1_PRVALID
	aMata := { {"D3_TM"     ,cTM						,nil},;
	{"D3_COD"    ,CB9->CB9_PROD 		,nil},;
	{"D3_QUANT"  ,CB9->CB9_QTESEP		,nil},;
	{"D3_LOCAL"  ,CB9->CB9_LOCAL 		,nil},;
	{"D3_LOCALIZ",CB9->CB9_LCALIZ		,nil},;
	{"D3_LOTECTL",CB9->CB9_LOTECT		,nil},;
	{"D3_NUMLOTE",CB9->CB9_NUMLOT    	,nil},;
	{"D3_OP"     ,CB8->CB8_OP         ,nil},;
	{"D3_EMISSAO",dDataBase				,nil}}
	If Rastro(CB9->CB9_PROD)
		aadd(aMata,{"D3_LOTECTL",CB9->CB9_LOTECT		,nil})
		aadd(aMata,{"D3_NUMLOTE",CB9->CB9_NUMLOT    	,nil})
		aadd(aMata,{"D3_DTVALID",dValid             	,nil})
	EndIf
	lMSErroAuto := .F.
	lMSHelpAuto := .T.
	MSExecAuto({|x,y|MATA240(x,y)},aMata,If(!lEstorno,3,5))
	lMSHelpAuto := .F.
	If lMSErroAuto
		VTBeep(2)
		VTAlert(STR0145+cTM,STR0002,.T.,6000)   //"Falha na gravacao movimentacao TM "###"Aviso"
		Break
	EndIf
	CB9->(DbSkip())
End
CB7->(RecLock('CB7'))
If lEstorno
	CB7->CB7_REQOP := "0"
Else
	CB7->CB7_REQOP := "1"
EndIF
If "07" $ cUltTipoExp
	CB7->CB7_STATUS := "9"  // FINALIZADO
	CBLogExp(cOrdSep)
	VTAlert(STR0006,STR0007,.t.,4000) //'Processo de expedicao finalizado'###'Aviso'
EndIf
CB7->(MsUnlock())
End Transaction
If lMsErroAuto
	VTDispFile(NomeAutoLog(),.t.)
	Return .f.
EndIF
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ Retrocede ³ Autor ³ ACD                  ³ Data ³ 03/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Habilita os processos de retrocesso das Ordesn de Separacao³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Retrocede()
lRetrocede:=.t.  //Habilita retrocesso...
Return VtKeyboard(Chr(27))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ Avanca  ³ Autor ³ ACD                    ³ Data ³ 03/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Habilita os processos de avanco das Ordens de Separacao    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Avanca()
lAvanca:=.t.  //Habilita avanco...
Return VtKeyboard(Chr(27))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ FimProcesso³ Autor ³ ACD                 ³ Data ³ 03/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Flaga a Ordem de separacao como encerrada e exibe aviso    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function FimProcesso()

If "" $ cUltTipoExp
	CB7->CB7_STATUS := "9"  // FINALIZADO
	CB7->(MsUnlock())
	VTAlert(STR0006,STR0007,.t.,4000) //'Processo de expedicao finalizado'###'Aviso'
EndIf

If	(CB7->CB7_STATUS == "2" .and. (cUltTipoExp == "00*" .or. cUltTipoExp == "01*")) .or. ;
	(CB7->CB7_STATUS == "4" .and. cUltTipoExp == "02*") .or. ;
	(CB7->CB7_STATUS == "8" .and. cUltTipoExp == "02*")
	RecLock("CB7",.F.)
	CB7->CB7_STATUS := "9"  // FINALIZADO
	CBLogExp(cOrdSep)
	CB7->(MsUnlock())
	VTAlert(STR0006,STR0007,.t.,4000) //'Processo de expedicao finalizado'###'Aviso'
EndIf
If cOriExp == "3"
	SC2->(DbSetOrder(1))
	If SC2->(DbSeek(xFilial("SC2")+CB7->CB7_OP))
		RecLock("SC2",.F.)
		SC2->C2_ORDSEP:= " " // Limpa Ordem de Separacao p/ que possa ser possivel a separacao parcial das mesmas.
		SC2->(MsUnlock())
	Endif
Endif
EstItemPv()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ Seta    ³ Autor ³ ACD                   ³ Data ³ 03/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Seta as variaveis de controles                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Seta()
If CB7->CB7_STATUS == "9"
	lProcSep     := .t.
	lProcEmbFim  := .t.
	lProcGeraNF  := .t.
	lProcEmbarque:= .t.
	lProcReqOP   := .t.
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ Grv_Pausa³ Autor ³ ACD                  ³ Data ³ 03/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Grava Status de Pausa se necessario                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Grv_Pausa(nTipoParada)

If nTipoParada == 1 //Quando retrocede e pergunta novamente a Ordem de Separacao...
	If !lRetrocede
		RecLock("CB7")
		CB7->CB7_STATPA := "1"  // Em pausa
		CB7->(MsUnlock())
	EndIf
Else //Caso saindo da Ordem de Separacao verifica o status...
	If !Empty(cOrdSep) .and. !(CB7->CB7_STATUS $ '09') .and. (CB7->CB7_ORDSEP == cOrdSep)
		RecLock("CB7")
		CB7->CB7_STATPA := "1"  // Em pausa
		CB7->(MsUnlock())
	EndIf
	EstItemPv()
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ EstItemPv ³ Autor ³ ACD                 ³ Data ³ 03/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Estorna itens do Pedido de Vendas                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function EstItemPv()
Local  aSvAlias     := GetArea()
Local  aSvCB8       := CB8->(GetArea())
Local  aSvSC6       := SC6->(GetArea())
Local  aItensDiverg := {}
Local  nPos, i

If CB7->CB7_ORIGEM # "1" .or. CB7->CB7_DIVERG # "1"
	Return
EndIf

CB8->(DbSetOrder(1))
CB8->(DbSeek(xFilial("CB8")+CB7->CB7_ORDSEP))
While CB8->(!Eof() .and. CB8_ORDSEP == CB7->CB7_ORDSEP)
	If AllTrim(CB8->CB8_OCOSEP) # cDivItemPv
		CB8->(DbSkip())
		Loop
	EndIf
	nPos := Ascan(aItensDiverg,{|x| x[1]+x[2]+x[3]+x[6]+x[7]== CB8->(CB8_PEDIDO+CB8_ITEM+CB8_PROD+CB8_LOCAL+CB8_LCALIZ)})
	If nPos == 0
		aadd(aItensDiverg,{CB8->CB8_PEDIDO,CB8->CB8_ITEM,CB8->CB8_PROD,If(CB8->(CB8_QTDORI-CB8_SALDOS)==0,CB8->CB8_QTDORI,CB8->(CB8_QTDORI-CB8_SALDOS)),CB8->(Recno()),CB8->CB8_LOCAL,CB8->CB8_LCALIZ})
	EndIf
	CB8->(DbSkip())
EndDo
If Empty(aItensDiverg)
	RestArea(aSvSC6)
	RestArea(aSvCB8)
	RestArea(aSvAlias)
	Return
EndIf

Libera(nil,.t.,aItensDiverg)  //Estorna a liberacao de credito/estoque dos itens divergentes ja liberados

//Alteracao dos Itens da Ordem de Separacao:
For i:=1 to len(aItensDiverg)
	CB8->(DbGoto(aItensDiverg[i][5]))
	RecLock('CB8')
	CB8->(DbDelete())
	CB8->(MsUnlock())
Next

//Alteracao do CB7:
RecLock('CB7')
CB7->CB7_DIVERG := ""
CB7->(MsUnlock())

RestArea(aSvSC6)
RestArea(aSvCB8)
RestArea(aSvAlias)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ GeraNewEti ³ Autor ³ Anderson Rodrigues  ³ Data ³ 15/11/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gera Nova etiqueta para produtos de quantidade variavel    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SigaACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function GeraNewEti(nQtd)
Local cEtiqueta:= CBProxCod("MV_CODCB0")
Local nRecno
Local nRecnoCB0 := CB0->(Recno())

IF ! CB5SetImp(CBRLocImp("MV_IACD01"),IsTelNet())
	VTBeep(3)
	VTAlert(STR0199,STR0007,.t.,3000)  //'Local de impressao nao configurado, MV_IACD01'###'Aviso'
	Return
EndIf

VTMsg(STR0191)  //"Imprimindo..."

CB0->(DbGoto(nRecnoCB0))
nRecno:= CB0->(CBCopyRec())
CB0->(DbGoto(nRecno))
Reclock("CB0",.f.)
CB0->CB0_QTDE   := nQtd
CB0->CB0_CODETI := cEtiqueta
CB0->CB0_ORIGEM := "CB7"
CB0->(MSUnlock())

SB1->(DbSetOrder(1))
SB1->(DbSeek(xFilial("SB1")+CB0->CB0_CODPRO))
If ExistBlock('IMG01')
	ExecBlock("IMG01",,,{,,CB0->CB0_CODETI,1})
EndIf
If ExistBlock('IMG00')
	ExecBlock("IMG00",,,{"ACDV170",cOrdSep})
EndIf
MSCBCLOSEPRINTER()
CB0->(DbGoto(nRecnoCB0))
Reclock("CB0",.f.)
CB0->CB0_QTDE := CB0->CB0_QTDE - nQtd
CB0->(MSUnlock())
Return(cEtiqueta)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³VldNumPed ³ Autor ³ ACD                   ³ Data ³ 14/08/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ valida se tem numero de pedido                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function VldNumPed(cPedido)
Local aOrdSep:={}
Local aCab
Local aSize
Local nPos
Local aTela

If Empty(cPedido)
	VTKeyBoard(chr(23))
	Return .f.
Endif

CB8->(DbSetOrder(2))
CB8->(DbSeek(xFilial("CB8")+cPedido))

While CB8->(! Eof() .and. (CB8_FILIAL+CB8_PEDIDO == xFilial("CB8")+cPedido))
	If CB8->CB8_TIPSEP == "1" // Trata-se de uma Pre-Separacao
		CB8->(DbSkip())
		Loop
	EndIf
	If Ascan(aOrdSep,{|x| x[1] == CB8->CB8_ORDSEP}) == 0
		CB8->(aadd(aOrdSep,{CB8_ORDSEP,CB8_LOCAL,CB8_PEDIDO,CB7->CB7_CODOPE}))
	EndIf
	CB8->(DbSkip())
Enddo

CB7->(DbSetOrder(1))
If Empty(aOrdSep)
	VtAlert(STR0192,STR0002,.t.,4000,3)  //"Ordem de separacao nao encontrada"###"Aviso"
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
EndIf
If Len(aOrdSep) == 1
	cOrdSep:= aOrdSep[1,1]
	Return VldCodSep()
EndIf
aTela := VTSave()
VtClear
acab :={STR0193,STR0194,STR0052,STR0195} //"Ord.Sep"###"Arm"###"Pedido"###"Operador"
aSize:= {7,3,7,4,8,6}
nPos := 1
npos := VTaBrowse(,,,,aCab,aOrdSep,aSize,,nPos)
VtRestore(,,,,aTela)
If VtLastkey() == 27
	VtKeyboard(Chr(20))  // zera o get
	Return .f.
EndIf
cOrdSep:=aOrdSep[nPos,1]
cPedido:=aOrdSep[nPos,3]
VtKeyboard(Chr(13))  // zera o get
Return VldCodSep()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³VldOP     ³ Autor ³ Anderson Rodrigues    ³ Data ³ 10/08/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Valida a Ordem de Producao Informada                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function VldOP(cOP)

If Empty(cOP)
	VTKeyBoard(chr(23))
	Return .f.
EndIf

CB7->(DbSetOrder(5))
If CB7->(DbSeek(xFilial("CB7")+Padr(cOP,Len(CB7->CB7_OP))))
	cOrdSep:= CB7->CB7_ORDSEP
	VtKeyboard(Chr(13))  // zera o get
Else
	VtAlert(STR0025,STR0002,.t.,4000,3) //"Ordem de separacao nao encontrada."###"Aviso"
	VtKeyboard(Chr(20))  // zera o get
	Return .F.
Endif
Return VldCodSep()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³  Ordena  ³ Autor ³ Anderson Rodrigues    ³ Data ³ 02/03/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Ordena a String que contem a configuracao da expedicao     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAACD                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Ordena(cString)
Local cRetorno:= ""
Local nX      := 0
Local aTipExp := {}

For nX:= 1 to Len(cString) Step 3
	aadd(aTipExp,{Substr(cString,nX,3)})
Next

aTipExp := aSort(aTipExp,,,{|x,y| x[1] < y[1]})

For nX:= 1 to Len(aTipExp)
	cRetorno+= aTipExp[nX,1]
Next

Return(cRetorno)

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

If nQtde <= 0
	Return .f.
Endif
If lSerie .and. nQtde > 1
	VTAlert(STR0196,STR0002,.T.,2000) //"Quantidade invalida !!!"###"Aviso"
	VTAlert(STR0197,STR0002,.T.,4000) //"Quando se utiliza numero de serie a quantidade deve ser == 1"###"Aviso"
	Return .f.
Endif
Return .t.
