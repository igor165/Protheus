#INCLUDE "Acdv130.ch" 
#include "protheus.ch"
#include "apvt100.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ ACDV130    ³ Autor ³ Desenv.    ACD      ³ Data ³ 17/06/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Movimentacao interna de produtos                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ ExpC1 = Caso queira padronizar programas de movimentacao in³±±
±±³          ³         terna deve passar o nome do programa               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso	     ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/   
Function ACDV130(cTitulo)

Local nLinha        := 0
local bKey16        := VTSetKey(16,{|| Imprime()},STR0021)   // CTRL+P //"Imprime"
Local nX            := 0
Local nTamLote      := TamSX3("B8_LOTECTL")[1]
Local nTamSLote     := TamSX3("B8_NUMLOTE")[1]
Local nTamTM        := TamSX3("F5_CODIGO")[1]
Local nTamLocal     := Tamsx3("B1_LOCPAD")[1]
Local nTamNumSr     := TamSX3("BF_NUMSERI")[1]
Local nTamLoclz     := TamSX3("BF_LOCALIZ")[1]
Local nTamCdEt2     := TamSX3("CB0_CODET2")[1]
Local cPrintEti     := ''
Local nTamPrtEti    := 0
Private cTM         := ""
Private cEti
Private aEtiqueta   := {}
Private aEtiqueta2  := {}
Private nQE
Private lMSErroAuto := .F.
Private nQtdEtiq    := 1
Private cArmazem    := Space(nTamLocal)
Private cEndereco
Private cLote       := Space(nTamLote)
Private cSLote      := Space(nTamSLote)
Private dValid      := CtoD('')
Private cNumSerie   := Space(nTamNumSr)
Private lForcaQtd   := GetMV("MV_CBFCQTD",,"2") == "1"
Private cProgImp    := "ACDV130"
Private nValor      := 0 
IF !Type("lVT100B") == "L"
	Private lVT100B := .F.
EndIf


Default cTitulo     := STR0001 //"Movimentacao"

While .T.
	VTClear()
	cLote     := Space(nTamLote)
	cSLote    := Space(nTamSLote)
	dValid    := CtoD('')
	cTM       := Space(nTamTM)
	nQtdEtiq  := 1
	nQE       := 1
	nLinha    := 0
	aEtiqueta := {}
	aEtiqueta2:= {}
	cArmazem  := Space(nTamLocal)
	cEti      := If(UsaCB0("01"),Space(nTamCdEt2), IIf( FindFunction( 'AcdGTamETQ' ), AcdGTamETQ(), Space(48) ) )
	cEndereco := If(UsaCB0("02"),Space(20),Space(nTamLoclz))
	cNumSerie := Space(nTamNumSr)
	nValor    := 0
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ponto de entrada para fixar o TM e nao ser mostrado em tela³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock('AI130TM')
		cTM := Execblock('AI130TM',.F.,.F.,cTitulo)
	EndIf
	@ 0,0 VTSay cTitulo
	If Empty(cTM)
		@ ++nLinha,0 VTSay STR0002 VTGet cTM  pict '@!' Valid AI130VLTM() F3 "SF5" when Empty(cTM)   //"Tipo"
		VTRead
		If VTLastKey() == 27
			Exit
		EndIf
	Else
		AI130VLTM()
	EndIf
	If UsaCB0("01")
		@ ++nLinha,0 VTSay STR0018 //"Etiqueta de Produto"
		@ ++nLinha,0 VTGet cEti pict '@!' Valid VldEtiq().and. VldEnd()
	Else
		@ ++nLinha,0 VTSay STR0018 //"Etiqueta de Produto"
		@ ++nLinha,0 VTGet cEti pict '@!' Valid VTLastkey() == 5 .Or. VldEtiq()
		VTRead
		If VTLastKey() == 27
			Exit
		EndIf
		If Val(cTM) > 500 .and. GetMv("MV_LOCALIZ")=="S" .And. RetFldProd(SB1->B1_COD,"B1_LOCALIZ")=="S" //Requisicao
			If CBChkSer(aEtiqueta[1])
				MtNumSer(nQtdEtiq,aEtiqueta)
			EndIf
			If VTLastKey() == 27
				Exit
			EndIf
			If Empty(cNumserie)
				nTamPrtEti := VTMaxCol()+2
				If Len(AllTrim(cEti)) > nTamPrtEti //Etiqueta maior que a tela do coletor
					cPrintEti := Left(cEti, nTamPrtEti-3)+'...'
				Else
					cPrintEti := Left(cEti, nTamPrtEti)
				EndIf
				nLinha := 1
				@ ++nLinha,0 VTSay STR0018 //"Etiqueta de Produto"
				@ ++nLinha,0 VTSay cPrintEti
				If lVT100B // GetMv("MV_RF4X20")
					While .T.
						VTInkey(0)
						If VTLastKey() == 13 .or. VTLastKey() == 24 .or. VTLastKey() == 27
							Exit
						EndIf
					EndDo
					
					If VTLastKey() == 27
						Exit
					EndIf
					
					nLinha := -1
					VTClear
				EndIf
				@ ++nLinha,0 VTSay STR0005 //"Quantidade"
				@ ++nLinha,0 VTGet nQtdEtiq pict CBPictQtde() valid !Empty(nQtdEtiq) .And. VldEtiq() when VTLastKey() == 5
				@ ++nLinha,0 VTSay STR0025 //"Endereco"
				@ ++nLinha,0 VTGet cArmazem pict '@!' Valid !Empty(cArmazem) when Empty(cArmazem)
				@ nLinha,3 VTSay "-" VTGet cEndereco pict "@!" valid VldEnd(cEti)
			EndIf	
		Else
			If lVT100B // GetMv("MV_RF4X20")
				nLinha := -1
				VTClear
			EndIf
			@ ++nLinha,0 VTSay STR0003 //"Armazem"
			@ nLinha,9 VTGet cArmazem pict '@!' Valid !Empty(cArmazem) when Empty(cArmazem)
			@ ++nLinha,0 VTSay STR0005 //"Quantidade"
			@ ++nLinha,0 VTGet nQtdEtiq pict CBPictQtde() valid !Empty(nQtdEtiq).And. VldEtiq()
		EndIf
	EndIf
	VTRead
	If VTLastKey() == 27
		Exit
	EndIf
	VTClear()
	If SF5->F5_VAL == "S"
		 nLinha := 0
		 @ ++nLinha,0 VTSay STR0028 // "Movimento Valorizado"
		 @ ++nLinha,0 VTSay STR0029 // "Valor"
		 @ ++nLinha,0 VTGet nValor pict PesqPict("SB2","B2_CM1") Valid A240Custo()
	EndIf        
	VTRead
	If VTLastKey() == 27
		Exit
	EndIf  
	If ! VtYesNo(STR0006,STR0007,.t.) //"Confirma a movimentacao?"###"Atencao"
		Loop
	EndIf
	VTMSG(STR0008)  //"Aguarde..."

	Begin Transaction
		If If(len(aEtiqueta2) > 1, AI130GRMD2(aEtiqueta2), AI130Grava())
			If UsaCB0("01")
			    aSort(aEtiqueta2,,, {|x,y| y[1] > x[1]}) //Ordena o array por produto
			    SD3->(DbSetOrder(2))
			    If(Len(aEtiqueta2) >= 1, SD3->(DbSeek(xFilial("SD3")+SD3->D3_DOC+aEtiqueta2[1][1])), .f.) 
				For nX:= 1 To Len(aEtiqueta2)      
					CB0->(DbSeek(xFilial("CB0")+cEti))
					AI130GrCB0(aEtiqueta2[nX])
					SD3->(DbSkip())
				Next
			EndIf
		Else
			DisarmTransaction()
			Break
		EndIf
	End Transaction
	If lMSErroAuto
		VTDispFile(NomeAutoLog(),.t.)
	EndIf
End
Vtsetkey(16,bkey16)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ AI130VLTM  ³ Autor ³ Desenv.    ACD      ³ Data ³ 17/06/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica integridade no tipo de movimento                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AI130VLTM()
If Empty(cTM)
	VTKeyBoard(chr(23))
	Return .f.
EndIf
If !VTExistCPO("SF5",cTM,,STR0009,.T.)  //"Tipo de movimento nao existe."
	Return .f.
EndIf
If !SF5->F5_TIPO $ "R|D"
	VTBeep(2)
	VTAlert(STR0010,STR0011,.T.,4000)  //"Tipo de movimento invalido para este processo"###"Aviso"
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
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VldEtiq()
Local aItensPallet	:= CBItPallet(cEti)
Local cTipID
Local lIsPallet 	:= .t.                                     
local nP			:= 0

If Empty(cEti)
	Return .f.
EndIf

aEtiqueta2 := {} // Reinicializa o vetor quando chamada a validacao novamente

If len(aItensPallet) == 0
	aItensPallet:={cEti}
	lIsPallet := .f.
EndIf

If lIsPallet .And. ExistBlock("AV130VPL") // Ponto de entrada para validar a etiqueta de pallet
	cEti := Execblock("AV130VPL",,,{cEti})
EndIf    

begin Sequence
For nP:= 1 to len(aItensPallet)
	cEti :=  aItensPallet[nP] 
	
	If ExistBlock("AV130AVL")
		cEti := Execblock("AV130AVL",,,{cEti})
	EndIf    
	
	If UsaCB0("01")
		aEtiqueta := CBRetEti(cEti,"01",,.t.)
		If Empty(aEtiqueta)
			VTBeep(2)
			VTAlert(STR0012,STR0011,.T.,4000) //"Etiqueta invalida"###"Aviso"
			VTKeyBoard(chr(20))
			Return .f.
		EndIf  

		If !lIsPallet .and. !Empty(CB0->CB0_PALLET)
			VTALERT(STR0019,STR0011,.T.,4000) //"Etiqueta invalida, Produto pertence a um Pallet"###"AVISO"
			VTKeyBoard(chr(20))
			Return .f.
		EndIf 

		If SF5->F5_TIPO == "D" .And. If(CB0->CB0_STATUS # "3",Empty(CB0->CB0_STATUS),.F.)
			VTBeep(2)
			VTAlert(STR0024,STR0011,.T.,4000) //"A etiqueta nao podera ser devolvida, verique o status da etiqueta!" ## "AVISO"
			VTKeyBoard(chr(20))
			Return .f.
		EndIf
	
		If SF5->F5_TIPO =="R" .And. CB0->CB0_STATUS $"123"  
			VTBeep(2)
			VTAlert(STR0012,STR0011,.T.,4000) //"Etiqueta invalida"###"Aviso"
			VTKeyBoard(chr(20))
			Return .f.
		EndIf
		If !ValidProd(cEti)
			Return .F.
		EndIf		
		If Empty(aEtiqueta[2])
			aEtiqueta[2] := 1
		EndIf
		nQtdEtiq := 1
		cArmazem := aEtiqueta[10]
		cEndereco:= aEtiqueta[9]
		cLote    := aEtiqueta[16]
		cSLote   := aEtiqueta[17]
		dValid   := aEtiqueta[18]
		cNumSerie:= CB0->CB0_NUMSER
	Else
		If ! CBLoad128(@cEti)
			VTKeyBoard(chr(20))
			Return .f.
		EndIf
		cTipId:=CBRetTipo(cEti)
		If ! cTipId $ "EAN8OU13-EAN14-EAN128"
			VTBEEP(2)
			VTALERT(STR0013,STR0011,.T.,4000) //"Etiqueta invalida."###"AVISO"
			VTKeyBoard(chr(20))
			Return .f.
		EndIf
		aEtiqueta := CBRetEtiEAN(cEti)
		If Empty(aEtiqueta) .or. Empty(aEtiqueta[2])
			VTBEEP(2)
			VTALERT(STR0013,STR0011,.T.,4000) //"Etiqueta invalida."###"AVISO"
			VTKeyBoard(chr(20))
			Return .f.
		EndIf
		If !ValidProd(cEti)
			Return .F.
		EndIf
		aEtiqueta[2] := aEtiqueta[2] *nQtdEtiq
	EndIf 
	
	If ! CBProdLib(cArmazem,aEtiqueta[1])
		VTKeyBoard(chr(20))
		Return .f.
	EndIf
	SB1->(DbSetOrder(1))
	SB1->(DbSeek(xFilial("SB1")+aEtiqueta[1]))
	
	dValid := dDataBase+SB1->B1_PRVALID
	nQE:= 1
	If ! CBProdUnit(aEtiqueta[1])
		aEtiqueta[2]:= 0
		nQE := CBQtdEmb(aEtiqueta[1])
		If Empty(nQE)
			VTKeyBoard(chr(20))
			Return .f.
		EndIf
	EndIf
	If ! Usacb0("01")
	
		// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		// ³ Carrega variavel caso o retorno da funcao CBRetEtiEAN traga     ³
		// ³ informacao do lote do produto.                                  ³
		// ³ Ex: utilizacao do ponto de entrada CBRETEAN retornando lote.    ³
		// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ValType(aEtiqueta[3]) == "C" .And. !Empty(aEtiqueta[3])
			cLote := aEtiqueta[3]
		EndIf
		
		// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		// ³ So chama tela para informacao de Lote caso a variavel cLote nao ³
		// ³ esteja vazia. Validacao incluida devido a funcao ser chamada    ³
		// ³ em mais de um GET no coletor.                                   ³
		// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty(cLote)
			If cTM <= "500" // devolucao
				If ! CBRastro(aEtiqueta[1],@cLote,nil,@dValid)
					VTKeyboard(chr(20))
					Return .f.
				EndIf
			Else
				If ! CBRastro(aEtiqueta[1],@cLote,@cSLote,nil)
					VTKeyboard(chr(20))
					Return .f.
				EndIf
			EndIf
		EndIf
	EndIf
	aadd(aEtiqueta2,aEtiqueta)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ponto de entrada para validacao da etiqueta de codigo de barras³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock('AI130VCB')
		Return(Execblock('AI130VCB',.F.,.F.,cEti))
	EndIf
Next
End Sequence
nQtdEtiq := Iif(Empty(nQtdEtiq),1,nQtdEtiq)
VTGetRefresh("nQtdEtiq")
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ VldEnd     ³ Autor ³ Desenv.    ACD      ³ Data ³ 01/01/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Efetua a Validacao do Endereço                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VldEnd()
Local aEndereco := {}

DbSelectArea("SBF")
DbSetOrder(1)

If !UsaCB0("01")
	If Empty(cEndereco)
		VTBeep(2)
		VTALERT(STR0013,STR0011,.T.,4000) //"Etiqueta invalida."###"AVISO"
		VTClearGet()
		VTClearGet("cArmazem")
		VTGetSetFocus("cArmazem")
		Return .f.
	EndIf
	
	If UsaCB0("02")
		aEndereco := CBRetEti(cEndereco,"02")
		If Empty(aEndereco)
			VTBEEP(2)
			VTALERT(STR0013,STR0011,.T.,4000) //"Etiqueta invalida."###"AVISO"
			VTKeyBoard(chr(20))
			Return .f.
		EndIf
		cEndereco := Padr(aEndereco[1],TamSX3("BF_LOCALIZ")[1])
	EndIf
	SBE->(DbSetOrder(1))
	If ! SBE->(DbSeek(xFilial()+cArmazem+cEndereco)) 
		VTBEEP(2)
		VTALERT(STR0015,STR0011,.T.,4000) //"Endereco nao encontrado"###"AVISO"
		VTClearGet()
		VTClearGet("cArmazem")
		VTGetSetFocus("cArmazem")
		Return .f.
	EndIf
	
	If !CBEndLib(cArmazem,cEndereco)
		VTBEEP(2)
		VTALERT(STR0016,STR0011,.T.,4000) //"Endereco bloqueado"###"AVISO"
		VTClearGet()
		VTClearGet("cArmazem")
		VTGetSetFocus("cArmazem")
		Return .f.
	EndIf
EndIf	
If Val(cTM) > 500 
	If RetFldProd(SB1->B1_COD,"B1_LOCALIZ")=="S"
		If ! SBF->(Dbseek(xFilial("SBF")+cArmazem+cEndereco+aEtiqueta[1]+cNumSerie+cLote+cSLote))
			VTBeep(2)
			VTALERT(STR0023,STR0011 ,.T.,4000)  //"Não existe saldos para o endereço informado"###"Aviso"
			VTClearGet()
			VTClearGet("cArmazem")
			VTGetSetFocus("cArmazem")
			Return .f.
		EndIf
		If aEtiqueta[2] > SaldoSBF(cArmazem,cEndereco,aEtiqueta[1],cNumSerie,cLote,cSLote)
			VTBeep(2)
			VTALERT(STR0014,STR0011 ,.T.,4000)  //"Quantidade excede o saldo disponivel"###"Aviso"
			VTClearGet()
			VTClearGet("cArmazem")
			VTGetSetFocus("cArmazem")
			Return .f.
		EndIf
	Else
		SB2->(DbSetOrder(1))
		If ! SB2->(DbSeek(xFilial()+aEtiqueta[1]+cArmazem))
			VTBeep(2)
			VTALERT(STR0020+cArmazem,STR0011 ,.T.,4000)  //"Aviso" //"Nao existe saldo disponivel para o Armazem "
			VTClearGet()
			VTClearGet("cArmazem")
			VTGetSetFocus("cArmazem")
			Return .f.
		EndIf
		If  If(! Empty(aEtiqueta[2]),aEtiqueta[2]*nQE,nQE) > SaldoSB2()
			VTBeep(2)
			VTALERT(STR0014,STR0011 ,.T.,4000)  //"Quantidade excede o saldo disponivel"###"Aviso"
			VTClearGet()
			VTClearGet("cArmazem")
			VTGetSetFocus("cArmazem")
			Return .f.
		EndIf
	EndIf
EndIf
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ AI130Grava ³ Autor ³ Desenv.    ACD      ³ Data ³ 17/07/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gera mivimentacao interna no SIGA                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso	     ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AI130Grava()
Local aAreaSF5 := SF5->(GetArea())
Local cDocumento:= CriaVar("D3_DOC",.T.) 
Local aMata    := {	{"D3_TM"		,cTM			, nil},;
					{"D3_COD"		,aEtiqueta[1]	, nil},;
					{"D3_QUANT"		,If(! Empty(aEtiqueta[2]),aEtiqueta[2]*nQE,nQE), nil},;
					{"D3_LOCAL"		,cArmazem 		, nil},;
					{"D3_LOCALIZ"	,cEndereco		, nil},;
					{"D3_DOC"		,IIf(Empty(cDocumento),NextNumero("SD3",2,"D3_DOC",.T.),cDocumento), nil},;
					{"D3_EMISSAO"	,dDataBase		, nil}}
					
Private nModulo := 4

If Rastro(aEtiqueta[1])
	aadd(aMata,{"D3_LOTECTL", cLote         , nil})
	aadd(aMata,{"D3_NUMLOTE", cSLote        , nil})
	aadd(aMata,{"D3_DTVALID", dValid        , nil})
EndIf
If ! Empty(cNumSerie)
	SB1->(DbSetOrder(1))
	SB1->(DbSeek(xFilial("SB1")+aEtiqueta[1]))
	If(ValType(SB1->B1_QTDSER)) == "C"
		If SB1->B1_QTDSER <> '1'
			aadd(aMata,{"D3_QTSEGUM",1, nil})
		EndIf
	Else
		If SB1->B1_QTDSER <> 1
			aadd(aMata,{"D3_QTSEGUM",1 , nil})
		EndIf	
	EndIf
	aadd(aMata, {"D3_NUMSERI", cNumserie, Nil})
EndIf

If SF5->F5_VAL == "S"
	aadd(aMata,{"D3_CUSTO1", nValor     , nil}) 
EndIf
lMSErroAuto := .F.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de entrada, atualiza array com campos especificos    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock('AI130GMI')
	aMata := Execblock('AI130GMI',.F.,.F.,aMATA)
EndIf
lMSHelpAuto := .T.
MSEXECAUTO({|x|MATA240(x)},aMata)
lMSHelpAuto := .F.
If lMSErroAuto
	VTBeep(2)
	VTAlert(STR0017,STR0011,.T.,6000)  //"Falha na gravacao da movimentacao, tente novamente."###"Aviso"
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de entrada depois que foi feita a gravacao           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock('AI130DGR')
	Execblock('AI130DGR',.F.,.F.)
EndIf
RestArea(aAreaSF5)
Return !lMsErroAuto
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ AI130GrCB0 ³ Autor ³ Desenv.    ACD      ³ Data ³ 16/08/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza CB0                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso	     ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AI130GrCB0(aEtiqueta)
Local lGrava 	:= .F.
Local aAreaCB0  := CB0->(GetArea())

If Empty(aEtiqueta[4]+aEtiqueta[5]+aEtiqueta[6]+aEtiqueta[7]+; //NOTA+SERIE+FORNEC+LOJA
	aEtiqueta[11]+aEtiqueta[12]) //OP+NUMSEQ
	If SF5->F5_TIPO == "D" .And. ! CBProdUnit(aEtiqueta[1])
		aEtiqueta[2] := nQE
		If !Localiza(aEtiqueta[1])
			aEtiqueta[11]:= SD3->D3_OP
			aEtiqueta[12]:= SD3->D3_NUMSEQ
			aEtiqueta[24]:= "SD3"
		EndIf	
	EndIf
	lGrava := .T.
EndIf

If SF5->F5_TIPO == "D" .And. (Localiza(aEtiqueta[1]) .Or. Rastro(aEtiqueta[1]))
	//-- Se devolucao limpa os campos.
	aEtiqueta[4]  := "" 			 //NOTA
	aEtiqueta[5]  := "" 			 //SERIE
	aEtiqueta[6]  := "" 			 //FORNEC
	aEtiqueta[7]  := "" 			 //LOJA
	aEtiqueta[25] := ""				 //ITEM NOTA FISCAL
	aEtiqueta[9]  := "" 			 //ENDERECO
	aEtiqueta[11] := SD3->D3_OP 	 //OP
	aEtiqueta[12] := SD3->D3_NUMSEQ //NUMERO DE SEQUENCIA
	aEtiqueta[21] := "" 			 //CODIGO DO PALLET
	aEtiqueta[24] := "SD3" 			 //ORIGEM
	lGrava := .T.
EndIf

If lGrava
	CBGrvEti("01",aEtiqueta,If(!UsaCB0("01"),aEtiqueta[len(aEtiqueta)],cEti))
EndIf

RecLock("CB0",.f.)
CB0->CB0_STATUS:= If(SF5->F5_TIPO=="R","1"," ")
CB0->CB0_NUMSEQ:= If(SF5->F5_TIPO=="R",SD3->D3_NUMSEQ," ")
CB0->(MsUnLock())
RestArea(aAreaCB0)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ ACD040Imp  ³ Autor ³ Anderson Rodrigues  ³ Data ³ 30/11/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chamada Programa de Impressao de Etiquetas de Produto      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Imprime()
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
±±³Fun‡„o	 ³ Validprod  ³ Autor ³ Aécio Ferreira Gomes³ Data ³ 26/09/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida se o produto existe no cadastro de produtos         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Validprod(cEti)

Local aAreaSB1 := SB1->(GetArea())

DbselectArea("SB1")
DbSetOrder(1)  

If Empty(cEti) 
	Return .F.	
EndIf          

If ! SB1->(DbSeek(xFilial()+aEtiqueta[1]))
	VTBEEP(2)
	VTALERT(STR0022,STR0011,.T.,4000) //"Produto invalido."###"AVISO"
	VTKeyBoard(chr(20))
	Return .F.
EndIf	

RestArea(aAreaSB1)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ MtNumSer   ³ Autor ³ Aecio Ferreira Gomes³ Data ³ 02/02/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta tela quando existir controle de numero de serie	  ³±±
±±³			 ³ para o produto		                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ 															  ³±±
±±³          ³          											      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso	     ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MtNumSer(nQtdEtiq,aEtiqueta)

Local aTela :={}
Local nLinha:=1
aSave:= VTSAVE()
VTClear()
If CBChkSer(aEtiqueta[1]) .And. ! CBNumSer(@cNumserie,Nil,aEtiqueta)
	Return .F.
EndIf
If !Empty(cNumserie)
	@ ++nLinha,0 VTSay STR0005 //"Quantidade"
	@ ++nLinha,0 VTGet nQtdEtiq pict CBPictQtde() valid !Empty(nQtdEtiq) when VTLastKey() == 5
	@ ++nLinha,0 VTSay STR0026 //"Numero de Serie:"
	@ ++nLinha,0 VTSay cNumserie
	@ ++nLinha,0 VTSay STR0025 //"Endereco"
	@ ++nLinha,0 VTGet cArmazem pict '@!' Valid !Empty(cArmazem) when Empty(cArmazem)
	@ nLinha,3 VTSay "-" VTGet cEndereco pict "@!" valid VldEnd(cEti)
EndIf
VTREAD
VtRestore(,,,,aSave)
Return  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ AI130GRMD2 ³ Autor ³ Aécio ferreira Gomes³ Data ³ 12/01/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gera mivimentacao interna MOD2 no Protheus                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ExpA1: Array com itens para gerar a movimentação            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso	     ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AI130GRMD2(aEtiqueta)
Local aAreaSF5  := SF5->(GetArea())
Local cDocumento:= CriaVar("D3_DOC",.T.) 
Local nX,nQE	:= 0
Local aItens    := {}
Local aCab      := {} 

Private nModulo := 4

IIf(Empty(cDocumento),NextNumero("SD3",2,"D3_DOC",.T.),cDocumento)

aCab := {	{"D3_DOC"		,cDocumento							,NIL},;
			{"D3_TM"    	,cTM	   							,NIL},;
            {"D3_EMISSAO"	,dDataBase	   						,Nil} } 

For nX:= 1 to Len(aEtiqueta)
	nQE := CBQtdEmb(aEtiqueta[nX][1])
	If UsaCB0("01")
		aAdd(aItens,{	{"D3_COD"		,aEtiqueta[nX][1]	,nil},;
						{"D3_QUANT"		,If(! Empty(aEtiqueta[nX][2]),aEtiqueta[nX][2]*nQE,nQE),nil},;
						{"D3_LOCAL"		,aEtiqueta[nX][10]	,nil},;
						{"D3_LOCALIZ"	,aEtiqueta[nX][9]	,nil},;
						{"D3_EMISSAO"	,dDataBase	    	,nil}})
						
		If Rastro(aEtiqueta[nX][1])
			aadd(aItens[nX],{"D3_LOTECTL",aEtiqueta[nX][16]        ,nil})
			aadd(aItens[nX],{"D3_NUMLOTE",aEtiqueta[nX][17]        ,nil})
			aadd(aItens[nX],{"D3_DTVALID",aEtiqueta[nX][18]        ,nil})
		EndIf          

		If ! Empty(aEtiqueta[nX][23])
			SB1->(DbSetOrder(1))
			SB1->(DbSeek(xFilial("SB1")+aEtiqueta[nX][1]))
			If SB1->B1_QTDSER <> 1
				aadd(aItens[nX],{"D3_QTSEGUM",1 , nil})
			EndIf
			aadd(aItens[nX],{"D3_NUMSERI", aEtiqueta[nX][23] , Nil})
		EndIf		
	Else
		aAdd(aItens,{	{"D3_COD"		,aEtiqueta[nX][1]	,nil},;
						{"D3_QUANT"		,If(! Empty(aEtiqueta[nX][2]),aEtiqueta[nX][2]*nQE,nQE),nil},;
						{"D3_LOCAL"		,cArmazem			,nil},;
						{"D3_LOCALIZ"	,cEndereco			,nil},;
						{"D3_EMISSAO"	,dDataBase	    	,nil}})
						
		If Rastro(aEtiqueta[nX][1])
			aAdd(aItens,{"D3_LOTECTL"	,aEtiqueta[nX][3]	,nil})
			aAdd(aItens,{"D3_NUMLOTE"	,cSLote				,nil})
			aAdd(aItens,{"D3_DTVALID"	,aEtiqueta[nX][4]	,nil})
		EndIf          

		If ! Empty(aEtiqueta[nX][5])
			SB1->(DbSetOrder(1))
			SB1->(DbSeek(xFilial("SB1")+aEtiqueta[1]))
			If SB1->B1_QTDSER <> 1
				aAdd(aItens,{"D3_QTSEGUM",1 , nil})
			EndIf
			aAdd(aItens, {"D3_NUMSERI", aEtiqueta[nX][5], Nil})
		EndIf
	EndIf
Next
lMSErroAuto := .F.
lMSHelpAuto := .T.
MSEXECAUTO({|x,y|MATA241(x,y)},aCab,aItens)
lMSHelpAuto := .F.
If lMSErroAuto
	VTBeep(2)
	VTAlert(STR0017,STR0011,.T.,6000)  //"Falha na gravacao da movimentacao, tente novamente."###"Aviso"
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de entrada depois que foi feita a gravacao           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock('AI130DGR')
	Execblock('AI130DGR',.F.,.F.)
EndIf
RestArea(aAreaSF5)
Return !lMsErroAuto
