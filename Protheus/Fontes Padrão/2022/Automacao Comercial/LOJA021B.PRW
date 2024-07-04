#Include "PROTHEUS.CH"
#Include "LOJA021A.CH"

#DEFINE CONFIRMA  1
#DEFINE ABANDONA  2

#DEFINE VALMERC  	1	// Valor total do mercadoria
#DEFINE VALDESC 	2	// Valor total do desconto
#DEFINE FRETE   	3  // Valor total do Frete
#DEFINE VALDESP 	4  // Valor total da despesa
#DEFINE SEGURO		7	// Valor total do seguro
#DEFINE VALTROCA	5	// Valor da Troca
#DEFINE QTDEITEM	6	// Quantidade de Itens
#DEFINE SEGURO		7	// Valor total do seguro
#DEFINE VALBRUTO	8	// Valor Bruto da NF
#DEFINE PERCDESC   10   // Percentual de Desconto

#DEFINE IMPOSTOS 	9	// Array contendo Os Valores de Impostos Exibidos no ListBox

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//| Posicao do array aDevol   |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#DEFINE _DESCMOEDA 1	// Descricao da moeda
#DEFINE _SALDO     	2	// Saldo a devolver
#DEFINE _VALORDEV  3	// Valor efetivamente devolvido
#DEFINE _SOMADEV   	4	// Somatorio da devolucao convertido
#DEFINE _VLRORIG   	5	// Valor original da devolucao(backup)
#DEFINE _MOEDA   	6	// Moeda

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//|Dados do array aInfCliente |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#DEFINE _NOMECLI     1
#DEFINE _TELCLI      2
#DEFINE _PRICOMCLI   3
#DEFINE _ULTCOMCLI   4
#DEFINE _ENDCLI      5
#DEFINE _ESTCLI      6
#DEFINE _CGCCLI      7
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ LOJA021B	³ Autor ³ Lucas			        ³ Data ³ 27/10/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ programa com funcoes auxiliares do LOJA021A.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGALOJA 												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ DATA     ³ BOPS ³Prograd.³ALTERACAO                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ 27.11.01 ³XXXXXX³Lucas   ³Inicio...									  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ LJ021ACols    ³ Autor ³ Lucas	        ³ Data ³ 27.11.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Inicia o aCols para as Notas de Devolucao, baseando-se em  ³±±
±±³			 ³ SL1 e SL2.												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ LJ021ACols()										          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 := LJ021ACols()									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ LOJA021	 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LJ021ACols(lVisual)
LOCAL aArea := GetArea()
LOCAL nI, nC, nX, nCnt := 0
LOCAL nPosCF := Ascan(aHeader,{|x| AllTrim(x[2]) == "L2_CF"})
LOCAL nPosQuant := Ascan(aHeader,{|x| AllTrim(x[2]) == "L2_QUANT"})
LOCAL nPosVUnit := Ascan(aHeader,{|x| AllTrim(x[2]) == "L2_VRUNIT"})
LOCAL nPosVlItem := Ascan(aHeader,{|x| AllTrim(x[2]) == "L2_VLRITEM"})
LOCAL nPosItem   := 0
LOCAL nSaidas    := 0
LOCAL aProdutos  := {}
LOCAL cCampo     := ""
LOCAL lTemItem   := .F.
LOCAL lLj021Prod := ExistBlock("LJ021PROD")
LOCAL lCondItem  := .T.

DbSelectArea("SL2")
DbSetOrder(1)
MsSeek( xFilial("SL2")+SL1->L1_NUM )

While !Eof() .AND. L2_FILIAL==xFilial("SL2") .AND. L2_NUM == SL1->L1_NUM
	
	If lLj021Prod
		lCondItem  := ExecBlock("LJ021PROD",.F.,.F.)
	EndIf
	
	If (L2_VENDIDO <> "S" .OR. L2_STATUS == "D") .AND. !lVisual
		dbSkip( )
		Loop
	EndIf
	
	If (SL2->L2_VLRITEM < 0 .AND. !nModulo == 72) .AND. !lVisual .AND. lCondItem
		dbSkip( )
		Loop
	EndIf
	
	lTemItem  := .T.
	nPosItem := Ascan(aProdutos,{ |x| x[1] == L2_ITEM })
	nSaidas += L2_QUANT
	If nPosItem == 0
		AADD(aProdutos,{L2_ITEM,L2_PRODUTO,L2_QUANT})
	Else
		aProdutos[nPosItem][3] += L2_QUANT
	EndIf
	DbSelectArea("SL2")
	DbSkip()
End

If !lTemItem .AND. !lVisual
	//"Nao existe itens a devolver ou Nota Fiscal ja devolvida..."
	//"Atencao!"
	MsgStop(IIf(cPaisLoc<>"SAL",OemToAnsi(STR0052),OemToAnsi(STR0177)),OemToAnsi(STR0009))
	RestArea( aArea )
	Return( nCnt )
EndIf

nUsado	 := 0
nDescont := 0
nMerc 	 := 0
aCols    := {}

DbSelectArea("SX3")
DbSetOrder(1)

MsSeek( "SL2" )
While !Eof() .AND. x3_arquivo == "SL2"
	If (x3Uso(x3_usado) .AND. cNivel >= x3_nivel .AND. alltrim(x3_campo)<>"L2_NUM") .OR. Alltrim(X3_campo) == "L2_ITEM"
		nUsado++
	EndIf
	DbSkip()
End

For nI := 1 To Len(aProdutos)
	
	If aProdutos[nI][3] > 0
		
		nCnt++
		
		AADD(aCols,Array(nUsado+1))
		Aadd(aQuantOrig,aProdutos[nI][3])
		
		DbSelectArea("SL2")
		DbSetOrder(1)
		MsSeek( xFilial("SL2")+SL1->L1_NUM+aProdutos[nI][1] )
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Considerar todos os impostos que incidem no Total da Nota ³
		//³ baseando se na Roteiro Amarracao Tes X Impostos.          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nMerc += SL2->L2_VLRITEM
		cTesImp := SL2->L2_TES
		aImposto := DefImposto( SL2->L2_TES )
		For nC := 1 To Len(aImposto)
			cCampo := "SL2->L2_"+aImposto[nC][2]
			If aImposto[nC][3] == "1"  //Determina se imposto incide ou nao na nota
				nMerc += &cCampo
			EndIf
		Next nC
		
		nUsado:=0
		
		DbSelectArea("SX3")
		MsSeek( "SL2" )
		While !Eof() .AND. X3_ARQUIVO == "SL2"
			If (x3Uso(X3_USADO) .AND. cNivel >= X3_NIVEL .AND. Trim(X3_CAMPO)<>"L2_NUM") .OR. Trim(X3_CAMPO) == "L2_ITEM"
				nUsado++
				If SX3->X3_CONTEXT<>"V"
					aCOLS[nCnt][nUsado] :=&(" SL2->"+X3_CAMPO)
				Else
					aCOLS[nCnt][nUsado] := CriaVar(X3_CAMPO)
				EndIf
				If Upper(AllTrim(X3_CAMPO)) == "L2_VALDESC"
					aCOLS[nCnt][nUsado] := SL2->L2_VALDESC //SL2->L2_DESCPRO
				EndIf
				If Upper(AllTrim(X3_CAMPO)) == "L2_DESC"
					If SL2->L2_DESC > 0
						aCOLS[nCnt][nUsado] := SL2->L2_DESC
					Else
						aCOLS[nCnt][nUsado] := ((SL2->L2_DESCPRO + SL2->L2_VALDESC)/SL2->L2_QUANT/SL2->L2_PRCTAB)*100
					EndIf
				EndIf
			EndIf
			If AllTrim(X3_CAMPO) == "L2_TES" .OR. Trim(X3_CAMPO) == "L2_CF"
				SF4->(DbSetOrder(1))
				SF4->(MsSeek(xFilial("SF4")+SL2->L2_TES))
				If !Empty(SF4->F4_TESDV)
					aCOLS[nCnt][nPosTES] := SF4->F4_TESDV
				Else
					aCOLS[nCnt][nPosTES] := GetMV("MV_TESTROC")
				EndIf
				
				If ExistBlock("LJ021TES")
					aCOLS[nCnt][nPosTES] := ExecBlock("LJ021TES",.F.,.F.)
				EndIf
				
				SF4->(DbSetOrder(1))
				If SF4->(MsSeek(xFilial("SF4")+aCols[nCnt][nPosTES]))
					aCOLS[nCnt][nPosCF] := SF4->F4_CF
				EndIf
			EndIf
			If AllTrim(X3_CAMPO) == "L2_QUANT"
				aCOLS[nCnt][nPosQuant] := aProdutos[nI][3]
			EndIf
			DbSelectArea("SX3")
			DbSkip()
		End
		aCols[nCnt][nUsado+1] := .F.
	EndIf
Next nI
//Ponto de entrada para alterar o Tes no momento da troca.

If ExistBlock('LJ020TES')
	ExecBlock('LJ020TES',.F.,.F.)
EndIf

For nC := 1 To Len(aCols)
	If !aCols[nC][Len(aCols[nC])]
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Quando na Venda foi aplicado desconto por Total, mostrar  ³
		//³ os itens com valor original.                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SL1->L1_DESCNF > 0 .AND. (aCols[nC][nPosDesc]+aCols[nC][nPosValDesc]) > 0
			aCols[nC][nPosVlrItem] := aCols[nC][nPosVlrItem] + aCols[nC][nPosDescPro]
			aCols[nC][nPosVUnit] := (aCols[nC][nPosVlrItem] / aCols[nC][nPosQuant])
		Else
			aCOLS[nC][nPosDesc]    :=  0.00
			aCOLS[nC][nPosValDesc] := 0.00
		EndIf
		aCols[nC][nPosVlItem] := aCols[nC][nPosVUnit] * aCols[nC][nPosQuant]
	EndIf
Next nC
DbSelectArea("SX3")
DbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Considerar todos os impostos que incidem no Total da Nota ³
//³ baseando se na Roteiro Amarracao Tes X Impostos.          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aImps  := {}
For nX := 1 to Len(aCols)
	If !aCols[nX][Len(aCols[nX])]
		Lj021CalcIV(nX)
	Else
		AAdd(aImps,{0,0,0,0,0,{}})
	EndIf
Next nX

LJ021GetIp()
LJ021Header("1")

RestArea( aArea )
Return( nCnt )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ LJ021LinOk    ³ Autor ³ Lucas        	³ Data ³ 27.11.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida os campos digitados na linha do aCols...            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ LJ021LinOk()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 := LJ021LinOk()									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ LOJA021	 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LJ021LinOk(o)
LOCAL lRet	:= .T.

If aCols[n][nPosQuant] = 0
	aCols[n][nPosQuant] := 1
EndIf
// Executa o PE "LJ021LOK" que valida cada linha informada na troca ...
// Todas as opcoes menos Devolucao Total...
If lTroca .OR. lParcial .OR. (lDevoluca .AND. !lTotal)
	If ExistBlock("LJ021LOK")
		lRet := ExecBlock("LJ021LOK",.F.,.F.)
	EndIf
EndIf

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ LJ021TudOk    ³ Autor ³ Lucas			³ Data ³ 27.11.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida os campos digitados nas linhas do aCols...          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ LJ021TudOk()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 := LJ021TudOk()									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ LOJA021	 												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ DATA     ³ BOPS ³Prograd.³ALTERACAO                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ 27.11.01 ³086812³Geronimo³Implementada inicializacao e validacao da   ³±±
±±³          ³      ³        ³variavel cNumNFDev (numero NF de Credito)   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LJ021TudOk()
LOCAL lRet := .F.
LOCAL nX := 1
LOCAL nOpcao    := 1
LOCAL cNextNum  := Space(TamSX3("F1_DOC")[1])
LOCAL cChaveSX5 := ""
LOCAL lSeqEspecie  := SuperGetMV("MV_SEQESPE",,.F.)
Local lLj021TOk := ExistBlock("LJ021TOK")
Local cFilSx5	:= If(FindFunction("LjFilSX5"),LjFilSX5(),xFilial("SX5"))  // Retorna Filial SX5

For nX := 1 to Len(aCols)
	If !aCols[nX][Len(aCols[nX])]
		lRet := .T.
	EndIf
Next nX

If !lRet
	MsgStop(STR0138,STR0009)  //"Nao e possivel realizar a operacao porque todos os itens foram excluidos."###"Atencao!"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida se numeracao da NCC esta autorizada por resolucao   ³
//³(SAT)-Loc. Guatemala                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .AND. cFormProp == "S" .AND. cPaisLoc == "GUA"
	If lNFManual
		nOpcao := Aviso(STR0009,STR0193,{STR0191,STR0192}) //"Aten‡„o"###"Sera gravada uma Nota de Credito MANUAL. Confirma a operacao?"###"Confirma"###"Cancela"
		If nOpcao == 2
			lRet  := .F.
		EndIf
	Else
		If !Empty(cSerieDev)
			cChaveSX5     := IIf(lSeqEspecie,xFilial("SX5")+"AC"+"NCC"+cSerieDev,cFilSx5+"01"+cSerieDev)
			dbSelectArea("SX5")
			If MsSeek(cChaveSX5)
				cNextNum  := AllTrim(X5Descri())
				If !ValNumSAT(cSerieDev,cNextNum,"2",lNFManual)
					lRet  := .F.
					//"Atenção"###"Nao ha resolucao cadastrada para a proxima numeracao de Nota de Credito."
					//"O proximo numero de Nota de Credito e: "###"Entre em contato com a SAT." ###"OK"
					Aviso(STR0009,STR0180+chr(13)+STR0181+cNextNum+"/"+cSerieDev+"."+chr(13)+;
					STR0182,{STR0150})
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

// Verifica se o total nao esta negativo...
If aValores[VALBRUTO] <= 0
	MsgAlert(STR0194) //"O Total geral dos itens informados para a Troca/Devolucao nao pode ser menor que 0(Zero)"
	lRet := .F.
EndIf

// Executa o PE "LJ021TOK" que valida a confirmacao do Troca/Devolucao...
If lRet .AND. lLj021TOk
	lRet := ExecBlock("LJ021TOK",.F.,.F.)
EndIf

If lRet .AND. cFormProp == "S"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se Numero e Serie da nota Devolvida ja existe no SF1.           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(cNumNFDev) .OR. Empty(cSerieDev)
		MsgStop(STR0195,STR0009)	//"Não foi informado a serie ou o numero da nota de credito."
		lRet := .F.
	Else
		cCodCli		:= cCliente		//Compatibilização com nome de variavel utilizada na funcao LJ021VALNF
		cLojaTrc	:= cLoja		//Compatibilização com nome de variavel utilizada na funcao LJ021VALNF
		lRet := LJ021VALNF()
	Endif
Endif

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ LJ021Del 	    ³ Autor ³ Lucas			³ Data ³ 27.11.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Disparar eventos quando itens do acols forem deletados...  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ LJ021Del()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 := LJ021Del()										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ LOJA021	 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LJ021Del()
LOCAL lRet := .T.
LOCAL nI := 0

If lTotal
	MsgStop(STR0070,STR0009) //Devolucao Total! Não é permitido apagar registros...###Atenção!
	aCols[n][Len(aCols[n])] := .F.
	lRet := .F.
EndIf

If lRet
	aImpVarSF1 := {}
	aImpVarSD1[6] := {}
	aImpsAux   := {}
	aImps      := {}
	LJ021Header("1")
	LJ021Refresh()
	
	For nI := 1 To Len(aCols)
		If !aCols[nI][Len(aCols[nI])]
			aCols[nI][nPosVlrItem] := aCols[nI][nPosVUnit] * aCols[nI][nPosQuant]
			If !Empty(aCols[nI][nPosTES])
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Calcular os impostos variaveis...						  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				LJ021CalcIV(nI)
			EndIf
			LJ021Header("1")
			LJ021Refresh()
		Else
			AAdd(aImps,{0,0,0,0,0,{}})
		EndIf
	Next nI
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Manter o array aImps mesmo quando a linha do aCols for excluida...	   ³
	//³ Será usado na User Function LJ021Imp.                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aImps) > Len(aCols)
		For nI := 1 To Len(aCols)
			AADD(aImpsAux,aImps[nI])
		Next nI
		aImps := {}
		aImps := AClone(aImpsAux)
	EndIf
EndIf

// Executa PE para que o usario possa validar a delecao de uma linha...

If lRet .AND. ExistBlock("LJ021DEL")
	lRet := ExecBlock("LJ021DEL",.F.,.F.)
EndIf

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³LJ021Total³ Autor ³ Fernando				³ Data ³ 12.12.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Soma as Mercadorias Trocadas. 			    			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ LOJA021													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LJ021Total()
Local nI, nC
Local cCampo  := ""
Local nPosImps  := 0

aValores[VALMERC]   := 0
aValores[VALTROCA]  := 0
aValores[VALBRUTO]  := 0
For nI:=1 To Len(aCols)
	If !aCols[nI][Len(aCols[nI])]
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Considerar todos os impostos que incidem no Total da Nota ³
		//³ baseando se na Roteiro Amarracao Tes X Impostos.          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aValores[VALMERC]   +=aCols[nI][nPosVlrItem]
		aValores[VALTROCA]  +=aCols[nI][nPosVlrItem]
		aValores[VALBRUTO]  +=aCols[nI][nPosVlrItem]
		cTesImp := aCols[nI][nPosTes]
		aImposto := DefImposto( cTesImp )
		For nC := 1 To Len(aImposto)
			cCampo := "L2_"+aImposto[nC][2]
			nPosImps  := Ascan(aHeader,{|x| Trim(x[2]) == cCampo})
			If aImposto[nC][3] == "1"  .AND. nPosImps > 0 //Determina se imposto incide ou nao na nota
				aValores[VALTROCA]  += aCols[nI][nPosImps]
				aValores[VALBRUTO]  += aCols[nI][nPosImps]
			EndIf
		Next nC
	EndIf
Next
oObj1:Refresh()
oObj5:Refresh()
oObj8:Refresh()
Return( .T. )

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³LJ021VALNF³ Autor ³ Wagner Xavier 		³ Data ³		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida nota informada									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ LojA021													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LJ021VALNF()
Local xAlias
Local lRet:=.T.
Local nRec

xAlias := Alias( )
dbSelectArea("SL1")
nRec := RecNo( )
dbSetOrder(2)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a nota ja existe no SF1  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet
	dbSelectArea("SF1")
	dbSetOrder(1)
	If (MsSeek(xFilial()+cNumNFDev+cSerieDev+cCodCli+cLojaTrc))
		Help(" ",1,"LJ010NOTA")
		lRet := .F.
	EndIf
EndIf

dbSelectArea("SL1")
dbGoTo( nRec )
dbSetOrder( 1 )
dbSelectArea(xAlias)
Return lRet


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³A021Fim() ³ Autor ³ Adriano Sacomani 	  ³ Data ³			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Encerra a Tela de Troca e volta para o Browse			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ LojA021													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function A021Fim(oDlg1)
dbSelectArea("SL1")
dbSetOrder(2)
oDlg1:End()
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ LJ021VldDev   ³ Autor ³ Lucas			³ Data ³ 27.11.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Inicia o aCols para as Notas de Devolucao, baseando-se em  ³±±
±±³			 ³ SL1 e SL2.								    			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ LJ021VldDev()											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ LJ021VldDev(nRecno)    						              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ LOJA021	 												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ DATA     ³ BOPS ³Prograd.³ALTERACAO                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ 10.05.05 ³001286³Magh    ³Nas trocas e Devolucoes, se cliente Padrao  ³±±
±±³          |/200500(FNC)   |forcar devolucao em dinheiro e nao em NCC   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß



*/
Function LJ021VldDev(nRecno,cNumAnt,cSerAnt,nVlrTr)

LOCAL oButton2
LOCAL oDlgDev
LOCAL oValorDev

LOCAL lDinheiro  := .T.
LOCAL lConfNcc   := .F.
LOCAL lDifTotal  := .F.
LOCAL lRet       := .F.
LOCAL lRetorno   := .F.

LOCAL nOpcDev    := 2
LOCAL nMoedaBco  := 1
LOCAL nDecs1	 := MsDecimais(1)
LOCAL nI
LOCAL nDecs 	 := 2
LOCAL nVlrTranMd1:= Round(xMoeda(nVlrTran,nMoedaTr,1,dDatabase,nDecs1+1,nTxMoedaTr),nDecs1)
Local nTam       := TamSx3("L1_VLRTOT")[1]
LOCAL nValorDev  := 0

LOCAL cAdmCC     := CriaVar("AE_DESC")
Local cTitulo    := ""
Local cDescMoeda := ""

LOCAL aArea      := GetArea()
Local aCabGrid   := {STR0145,STR0146,STR0147} //"Moeda"###"Saldo"###"Valor da Devolucao"
Local aTamGrid   := {}
Local aDevolBck  := Array(9)

Private cFormaDev := IIf(Empty(SL1->L1_FORMPG),GetMv("MV_SIMB1"),Trim(SL1->L1_FORMPG))

Default nVlrTr := 0

DbSelectArea("SX3")
DbSetOrder(2)
DbSetOrder(1)
For nI := 1 To MoedFin()
	If RecMoeda(dDataBase,nI) > 0
		If !Empty(GetMv("MV_MOEDA"+Alltrim(Str(nI))))
			AAdd(aDevol,{GetMv("MV_MOEDA"+Alltrim(STR(nI))),0,0,0,0,nI})
		Endif
	Endif
Next nI

If !lTrocaOut
	cSerie := cSerie + Space(TamSX3("L1_SERIE")[1]-Len(cSerie))
	
	DbSelectArea("SL1")
	DbSetOrder(2)
	MsSeek(xFilial("SL1")+cSerie+cNumNota)
	
	aTitulos := {}
	DbSelectArea("SE1")
	DbSetOrder(1)
	If lTroca
		nValorDev := Round(xMoeda(nVlrTr,nMoedaTr,1,,nDecs1+1,nTxMoedaTr),nDecs1)
	Else
		If MsSeek(xFilial("SE1")+SL1->L1_SERIE+SL1->L1_DOC)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se j  foi pago ao menos 1 parcela		  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			While !Eof() .AND. SE1->E1_FILIAL == xFilial("SE1") .AND.;
				SE1->E1_PREFIXO == SL1->L1_SERIE  .AND.;
				SE1->E1_NUM == SL1->L1_DOC
				
				SA1->(DbSetOrder(1))
				SA1->(MsSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA))
				
				DbSelectArea("SE5")
				DbSetOrder(2)
				If MsSeek(xFilial("SE5") +"LJ"+ SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO) .OR.;
					MsSeek(xFilial("SE5") + "VL" + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO) .OR.;
					MsSeek(xFilial("SE5") + "CP" + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO)
					
					SA6->(DbSetOrder(1))
					If SA6->(MsSeek(xFilial("SA6")+SE5->E5_BANCO+SE5->E5_AGENCIA+SE5->E5_CONTA))
						nMoedaBco  := Max(SA6->A6_MOEDA,1)
					EndIf
					aDevol[nMoedaBco][_SALDO] += SE5->E5_VALOR
					nValorDev += Round(xMoeda(SE5->E5_VALOR,nMoedaBco,1,dDatabase,nDecs1+1,IIf(nMoedaBco==SL1->L1_MOEDA,SL1->L1_TXMOEDA,0)),nDecs1)
					AADD(aTitulos,{SE1->E1_TIPO,SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_CLIENTE,SE1->E1_LOJA,SA1->A1_NOME,SE1->E1_MOEDA,SE1->E1_VALOR,SE1->E1_VLCRUZ})
				Else
					AADD(aTitulos,{SE1->E1_TIPO,SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_CLIENTE,SE1->E1_LOJA,SA1->A1_NOME,SE1->E1_MOEDA,SE1->E1_VALOR,SE1->E1_VLCRUZ})
					If SE1->E1_SALDO > 0
						If SE1->E1_PORTADOR <> xNumCaixa()       //Devolucao em dinheiro nos casos em que os titulos jah foram transferidos para um novo Caixa
							nDecs  := MsDecimais(SE1->E1_MOEDA)
							//Valor que nao serah devolvido porque ja esta em poder de outro Caixa
							nValorDev   += Round(xMoeda(SE1->E1_SALDO,SE1->E1_MOEDA,1,dDatabase,nDecs+1,IIf(SE1->E1_MOEDA==SL1->L1_MOEDA,SL1->L1_TXMOEDA,0)),nDecs)
							aDevol[1][_SALDO]  += Round(xMoeda(SE1->E1_SALDO,SE1->E1_MOEDA,1,dDatabase,nDecs+1,IIf(SE1->E1_MOEDA==SL1->L1_MOEDA,SL1->L1_TXMOEDA,0)),nDecs)
						Else
							//Se tiver algum titulo em aberto em poder do Caixa corrente que nao seja Cartao de Credito/Debito
							//deve excluir o mesmo e devolver em dinheiro ou gerar NCC para o valor que ja foi baixado(depende do MV_DEVNCC)
							lExcluiTit  := .T.
						EndIf
					EndIf
				EndIf
				DbSelectArea("SE1")
				DbSkip()
			End
		Else
			AADD(aTitulos,{Space(TamSX3("E1_TIPO")[1]),Space(TamSX3("E1_PREFIXO")[1]),;
			Space(TamSX3("E1_NUM")[1]),Space(TamSX3("E1_PARCELA")[1]),Space(TamSX3("E1_CLIENTE")[1]),;
			Space(TamSX3("E1_LOJA")[1]),Space(TamSX3("A1_NOME")[1]),Space(TamSX3("E1_MOEDA")[1]),0,0})
		EndIf
		
		//Para os casos em que jah foi feita uma(ou mais) devolucao(oes) parcial(ais) para esta venda
		//deve considerar o valor restante a devolver e nao o total baixado(nValorDev).
		If lTotal .AND. nValorDev > nVlrTranMd1
			If nValorDev - nVlrTranMd1 > (1/10**(MsDecimais(1)))  //Prever diferenca de arredondamento
				lDifTotal := .T.
			EndIf
		EndIf
		//Se for dev. parcial ou dif. de arredondamento,mostrar o total devolvido parcialmente na moeda 1
		If lParcial .OR. lDifTotal
			aDevol[1][_SALDO]   := nVlrTranMd1
			nValorDev       := aDevol[1][_SALDO]
			For nI := 2 to Len(aDevol)  //Zerar nas outras moedas
				If aDevol[nI][_SALDO] > 0
					aDevol[nI][_SALDO]  := 0
				EndIf
			Next nI
		EndIf
		
		SAE->(DbSetOrder(1))
		For nI := 1 To Len(aTitulos)
			If Alltrim(aTitulos[nI][1]) $ "CC|CD"
				If SAE->(MsSeek(xFilial("SAE")+Subs(aTitulos[nI][5],1,3)))
					aTitulos[nI][7] := SAE->AE_DESC
					cAdmCC := SAE->AE_DESC
				EndIf
			EndIf
		Next nI
	Endif
Else
	nValorDev := Round(xMoeda(nVlrTr,nMoedaTr,1,,nDecs1+1,nTxMoedaTr),nDecs1)
EndIf

If lParcial .OR. IIf(cPaisLoc == "POR",lTotal,.F.)
	nValorDev           := nVlrTr
	lExcluiTit          := .F.
EndIf

If ExistBlock("LJ021PGT")
	lRetorno := ExecBlock("LJ021PGT",.F.,.F.,{nValorDev})
EndIf

If nValorDev > 0 .AND. !lRetorno
	If cPaisLoc <> "ARG"  .OR. ( cPaisLoc == "ARG" .AND. cDevNCC <> "5" ) 
		If cDevNCC == "1" .OR. ((GetMv("MV_CLIPAD") + GetMv("MV_LOJAPAD")) == cCliente+cLoja) //ou se e Cliente Padrao
			//Nao gera NCC
			lConfNcc := .F.
		ElseIf cDevNCC == "2"  //Gera NCC
			lConfNcc := .T.
		ElseIf cDevNCC == "3"  //Pergunta se gera NCC
			lConfNcc := MsgYesNo(OemToAnsi(STR0115)+chr(13)+OemToAnsi(STR0175),;
			OemToAnsi(STR0116))  //"Se o cliente tem credito, deseja Gerar NCC(Nota de Credito ao Cliente) para o Financeiro?"###"Caso contrario, sera gerada devolucao em dinheiro."###"Gera NCC"
		ElseIf cDevNCC == "4"  //Sempre Gera NCC
			lConfNcc := .T.
		ElseIf cDevNCC == "5"  //Localizado para Argentina (Nao Gera NCC - Gera Abatimento)
			lConfNcc := .T.
		EndIf
		For nI := 1 to Len(aDevol)
			aDevol[nI][_VLRORIG] := aDevol[nI][_SALDO]
		Next nI
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se houver devolucao e nao for gerar NCC, mostrar a tela para ³
		//³ que indique os valores da devolucao por moeda                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lConfNcc
			AFill(aDevolBck,0)
			If SL1->L1_FORMPG $ "FI;CO;VA;CH;CC;CD"
				cFormaDev  := SL1->L1_FORMPG
			Else
				cFormaDev  := GetMv("MV_SIMB"+AllTrim(Str(nMoedaTr)))
			EndIf
			cFormaDev   := Padr(cFormaDev,3)
			lDinheiro   := IsMoney(cFormaDev)
			cDescMoeda  := GetMV("MV_MOEDA"+AllTrim(Str(nMoedaTr)))
			LjCalcDevIni(nValorDev)
			// Devolu‡„o (Forma de pagamento)
			DEFINE MSDIALOG oDlgDev TITLE Oemtoansi(STR0148);
			From 10,30 To 30,82 OF GetWndDefault()
			
			@ 0,1 TO 22,200 OF oDlgDev PIXEL
			
			@ 8.5,  3 Say STR0113 of oDlgDev PIXEL SIZE 25,8  // Forma:
			@ 8.5, 22 Say STR0087 of oDlgDev PIXEL SIZE 25,8  // DINHEIRO
			@ 8.5, 55 Say STR0059 of oDlgDev PIXEL SIZE 50,8 // Valor a devolver
			
			@ 6, 100 MSGET oValorDev VAR nValorDev PICTURE PesqPict("SL1","L1_VLRTOT");
			SIZE 55,6 OF oDlgDev  PIXEL  RIGHT WHEN .F.
			
			@ 8.5, 160 Say cDescMoeda of oDlgDev PIXEL SIZE 50,8
			
			cTitulo := aCabGrid[1]
			AAdd(aTamGrid,Iif(nTam > Len(Trim(cTitulo)),nTam*3,Len(Trim(cTitulo))*3))
			
			cTitulo := aCabGrid[2]
			AAdd(aTamGrid,Iif(nTam > Len(Trim(cTitulo)),nTam*4.1,Len(Trim(cTitulo))*4.1))
			
			cTitulo := aCabGrid[3]
			AAdd(aTamGrid,Iif(nTam > Len(Trim(cTitulo)),nTam*4.1,Len(Trim(cTitulo))*4.1))
			
			oLBBaixa := TwBrowse():New(025,001,000,000,,aCabGrid,aTamGrid,oDlgDev,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
			
			oLBBaixa:lHScroll := .T.
			oLBBaixa:lVScroll := .T.
			oLBBaixa:nHeight  := 200
			oLBBaixa:nWidth   := 400
			
			oLBBaixa:SetArray(aDevol)
			oLBBaixa:bLine      := {|| {aDevol[oLBBaixa:nAT][_DESCMOEDA],Transform(aDevol[oLBBaixa:nAT][_SALDO],PesqPict("SL1","L1_VLRTOT",18,oLBBaixa:nAT)) ,Transform(aDevol[oLBBaixa:nAT][_VALORDEV],PesqPict("SL1","L1_VLRTOT",18,oLBBaixa:nAT)) }}
			oLBBaixa:bLDblClick := {|| LjDblDev(nValorDev,@aDevolBck,lDinheiro)}
			
			DEFINE SBUTTON oButton FROM 130,140 TYPE 1 ACTION (IIf(Lj021VldPgto(nValorDev),;
			(nOpcDev := 1,oDlgDev:End()),NIL)) ENABLE OF oDlgDev
			
			DEFINE SBUTTON oButton2 FROM 130,170 TYPE 2 ACTION (nOpcDev := 2,oDlgDev:End());
			ENABLE OF oDlgDev
			
			//Se eh troca, naum pode cancelar a operacao porque os dados da nova venda jah foram gravados
			If lTroca
				oButton2:Disable()
			Endif
			
			ACTIVATE MSDIALOG oDlgDev VALID Lj021Valid(nOpcDev) CENTERED
			
			If nOpcDev <> 1
				RestArea( aArea )
				Aviso(STR0009,STR0173,{OemToAnsi(STR0150)})  //"Atencao"###"Transacion no efectuada!"###"OK"
				Return( .F. )
			EndIf
		EndIf
	EndIf
Else
	//Nao houve baixa de titulos da venda devolvida/trocada ou os titulos se encontram com outro Caixa
	//Desta forma, deve excluir os titulos
	lExcluiTit  := .T.
EndIf

lRet  := LJ021Grava(nRecno,lConfNcc,nValorDev,cNumAnt,cSerAnt)

Return (lRet)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Lj021CalcI³ Autor ³ Fernando Machima      ³ Data ³ 12/03/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calcula e grava impostos variaveis (Localizacoes)          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ ExpL1 := Lj010CalcIV(nPos,cCod)      					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Venda Balcao  											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Lj021CalcIV(nLineACols)
LOCAL aArea     := GetArea()
LOCAL nI, nC, nCA := 0
LOCAL nRndFat   := MsDecimais(nMoedaTr)
LOCAL cCampo    := ""
LOCAL lPrim     := .F.
LOCAL nValItemAcu := 0
LOCAL nLin        := 0
LOCAL nDescProp   := 0

nLineACols := If( nLineACols==NIL,0,nLineACols)
nLin  := If( nLineACols > 0,nLineACols, n )
lPrim := nLin == 1

If lPrim
	aImps := {}
	aImpVarSF1 := {}
EndIf
nDescProp    := aCols[nLin][nPosDescPro]

DbSelectArea("SL1")
aImpVarSD1[1] := aCOLS[nLin][nPosQuant]
If SL1->L1_DESCNF > 0
	aImpVarSD1[2] := aCOLS[nLin][nPosPrcTab] - nDescProp
	aImpVarSD1[3] := aCOLS[nLin][nPosVlrItem] - nDescProp
Else
	aImpVarSD1[2] := aCOLS[nLin][nPosVUnit]
	aImpVarSD1[3] := aCOLS[nLin][nPosVlrItem]
EndIf
aImpVarSD1[4] := 0.00
aImpVarSD1[5] := 0.00
aImpVarSD1[6] := {}
nPosCols := 1
nPosRow  := 1

SA1->(DbSetOrder(1))
SA1->( MsSeek(xFilial("SA1")+cCliente+cLoja) )

SF4->(DbSetOrder(1))
SF4->( MsSeek(xFilial("SF4")+aCOLS[nLin][nPosTES]) )

nValItemAcu := 0.00
For nI := 1 To Len(aCols)
	If nI <= nLin
		nValItemAcu += aCOLS[nI][nPosVlrItem]
	EndIf
Next nI

CalcTesxIp( "E", nValItemAcu,aCOLS[nLin][nPosPrcTab],aCOLS[nLin][nPosProd],nPosCols,nPosRow,"BALCAO" )

For nCA := 1 To Len( aImpVarSD1[6] )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gravar os Impostos gerados atrav‚s do Roteiro de c lculo da ³
	//³ Amarra‡Æo Tes X Impostos...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Subs(aImpVarSD1[6,nCA,7],3,7) == "_BASIMP"
		cCampo := "L2"+Subs(aImpVarSD1[6,nCA,7],3,8)
		nPosCpo := Ascan(aHeader,{|x| AllTrim(x[2]) == cCampo })
		aCOLS[nLin][nPosCpo] := Round(aImpVarSD1[6,nCA,3],nRndFat)
	EndIf
	
	If Subs(aImpVarSD1[6,nCA,6],3,7) == "_VALIMP"
		cCampo := "L2"+Subs(aImpVarSD1[6,nCA,6],3,8)
		nPosCpo := Ascan(aHeader,{|x| AllTrim(x[2]) == cCampo })
		aCOLS[nLin][nPosCpo] := Round(aImpVarSD1[6,nCA,4],nRndFat)
	EndIf
Next nCA

For nC := 1 To Len( aImpVarSD1[6] )
	If (nE := aScan( aImpVarSF1,{|x| x[1] == aImpVarSD1[6,nC,8] } )) == 0
		AAdd( aImpVarSF1, { aImpVarSD1[6,nC,8], 0.00, aImpVarSD1[6,nC,2], aImpVarSD1[6,nC,1] } )
		nE := Len( aImpVarSF1 )
	EndIf
	aImpVarSF1[ nE,2 ] += aImpVarSD1[6,nC,4]
	
	If (nE := aScan( aImpVarSF1,{|x| x[1] == aImpVarSD1[6,nC,9] } )) == 0
		AAdd( aImpVarSF1, { aImpVarSD1[6,nC,9], 0.00, aImpVarSD1[6,nC,2], aImpVarSD1[6,nC,1] } )
		nE := Len( aImpVarSF1 )
	EndIf
	aImpVarSF1[ nE,2 ] += aImpVarSD1[6,nC,3]
Next nC
AAdd(aImps,AClone(aImpVarSD1))

RestArea( aArea )
Return(.T.)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Lj021QtdIt³ Autor ³ Lucas			        ³ Data ³ 12/03/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retornar o numero de itens ativos do aCols ...             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ ExpN1 := Lj021QtdItem()			      					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Venda Balcao  											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Lj021QtdItem()
Local nI := 1
Local nItens := 0
Local nPosProd   := Ascan(aHeader,{|x|Subs(x[2],1,10)=="L2_PRODUTO"})

For nI := 1 To Len(aCols)
	If !aCols[nI][Len(aCols[nI])] .AND. !Empty(aCols[nI][nPosProd])
		nItens++
	EndIf
Next nI
Return( nItens )

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ Lj021VldForma ³ Autor ³ Lucas	        ³ Data ³ 21/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validar Forma de Devolucao conforme as regras locais...    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ ExpL1 := Lj021VldForma(ExpC1,ExpN1)      	              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ ExpC1 := Forma de Pagamento              	              ³±±
±±³       	 ³ ExpN1 := Valor total da Devolução        	              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpL1 := Retorno Lógico .T. ou .F.       	              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ LOJA021 - Devolucao de Vendas				              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function LJ021VldForma(oCombo,aFormaDev,cFormaDev,nValorDev,lCCredito)
LOCAL aArea := GetArea()
LOCAL cSimbMoeda := GETMV("MV_SIMB1")
LOCAL cMoeda := ""
LOCAL lRet := .T.
LOCAL nI := 0

SA6->(DbSetOrder(1))

For nI := 1 to Len(aTitulos)
	
	cSeekCxFin := xNumCaixa() + If(aTitulos[nI][08]==1,".",aTitulos[nI][1])
	SA6->(MsSeek(xFilial("SA6")+cSeekCxFin))
	
	If Alltrim(aTitulos[nI][1]) $ "CC|CD"
		// Tratamento Futuro
	ElseIf Subs(aTitulos[nI][1],1,2) $ "CH³VL³PG"
		
		If lParcial .AND. Subs(aTitulos[nI][1],1,2) $ "CH³VL³PG"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ No permitir devoluciones parciales com Cheques...         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			MsgStop(OemToAnsi(STR0073),OemToAnsi(STR0009))
			lRet := .F.
		ElseIf lTotal .AND. Subs(aTitulos[nI][1],1,2) $ "CH³VL³PG"
			DbSelectArea("SE1")
			DbSetOrder(1)
			If MsSeek(xFilial("SE1") + SL1->L1_SERIE + SL1->L1_DOC)
				While !Eof() .AND. SE1->E1_FILIAL  == xFilial("SE1") .AND.;
					SE1->E1_PREFIXO == SL1->L1_SERIE  .AND.;
					SE1->E1_NUM == SL1->L1_DOC
					If Alltrim(SE1->E1_STATUS) == "A"
						DbSelectArea("SEF")
						DbSetOrder(3)
						If MsSeek(xFilial("SEF") + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO)
							If SE1->E1_PORTADOR <> xNumCaixa()
								cMoeda  := Str(Max(SE1->E1_MOEDA,1),1)
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Quando Portador do Cheque diferente do Caixa Corrente, ‚  ³
								//³ provav‚l que os Cheques foram transferidos.  Neste caso   ³
								//³ deve-se sugerir ao Usuario que fa‡a Devolu‡ao em Dinheiro ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								// "Cheques ja foram transferidos, devolver en dinheiro..."
								// "Atencao!"
								lChoice := MsgYesNo(OemToAnsi(STR0061),OemToAnsi(STR0009))
								nChoice := If(lChoice,1,2)
								If nChoice == 2
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³ Usuario cancelou a operacao...                    ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									// "Devolucao cancelada pelo Usuario..."
									MsgStop(OemToAnsi(STR0062),OemToAnsi(STR0009))
									lRet := .F.
								Else
									//Verifica o saldo em Caixa
									If IIf(GetMv("MV_LJVLDEV"),LjVSaldo(SE1->E1_VALOR,GetMV("MV_SIMB"+cMoeda)),.T.)
										cSimbMoeda  := GetMV("MV_SIMB"+cMoeda)
										cFormaDev := cSimbMoeda
										nPosCbox := Ascan(aFormaDev,cFormaDev)
										If nPosCbox > 0
											oCombo:nAT:=nPosCbox
											oCombo:Refresh()
											aTitulos[nI][1] := cFormaDev
										EndIf
									Else
										lRet  := .F.
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
					DbSelectArea("SE1")
					DbSkip()
				End
			EndIf
		EndIf
	ElseIf IsMoney(aTitulos[nI][1])
		cMoeda  := Str(aTitulos[nI][8],1)
		//Verifica se tem dinheiro em Caixa para efetuar a devolucao
		lRet    := IIf(GetMv("MV_LJVLDEV"),LjVSaldo(aTitulos[nI][09],GetMV("MV_SIMB"+cMoeda)),.T.)
		If ExistBlock("LJ021DEV")
			lRet := ExecBlock("LJ021DEV",.F.,.F.)
		EndIf
	EndIf
Next nI
RestArea(aArea)
If ! lRet
	MsgStop(OemToAnsi(STR0084),OemToAnsi(STR0009))  //"Devolucao cancelada pelo sistema!"###"Atencao!"
EndIf
Return( lRet )

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ Lj021DescPro  ³ Autor ³ Lucas	            ³ Data ³ 21/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calcular o desconto proporcional para o Item...            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ ExpN1 := Lj021DescPro(ExpN2)             	              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ ExpN2 := Número do Item			        	              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpN1 := Valor do Desconto Calculado       	              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ LOJA021 - Devolucao de Vendas				              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function LJ021DescPro(nItem)
LOCAL nJ := 0
LOCAL nTotalNF := 0
LOCAL nPerc := SL1->L1_DESCNF
LOCAL nDescTotal := 0

For nJ := 1 to Len(aCols)
	If ! aCols[nJ][Len(aCols[nJ])]
		nTotalNF += aCols[nJ][nPosVlrItem]
	EndIf
Next nJ
nDescTotal := nTotalNF * (nPerc/100)
aCols[nItem][nPosDescPro] := aCols[nItem][nPosVlrItem] * (nDescTotal/nTotalNF)
Return( aCols[nItem][nPosDescPro] )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Programa  ³ Lj021GrvImpº Autor ³      Nava       º Data ³  31/05/01   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao ³ Grava os impostos variaveis (Localizacoes)                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe   ³ Lj021GrvImp( cTes, nLine, cAlias, cOperator )             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametro ³ cTes 		- Numero da Tes                               ³±±
±±³           ³ nLine		- Numero da Linha do Acols                    ³±±
±±³           ³ cAlias		- Nome do Alias que irah ser gravado          ³±±
±±³           ³ cOperator 	- '+' -> Acrescenta ao valor existente        ³±±
±±³           ³                 - '-' -> Diminui do valor existente       ³±±
±±³           ³         	- '=' -> Substitui o valor existente          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno   ³ NIL                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ SigaLoja - Localizacoes                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj021GrvImp( cTes, nLine, cAlias, cOperator )

LOCAL nI
LOCAL nPosL2Base :=0
LOCAL nPosL2Valor:=0
LOCAL cCampoBase
LOCAL cCampoValor
LOCAL nPosBase
LOCAL nPosValor
LOCAL cBase
LOCAL cValor
Local nDecs     := MsDecimais(nMoedaTr)

FOR nI := 1 TO Len( aPosImps )
	If Substr(aPosImps[nI][1],4,6) = "BASIMP"
		cBase := Substr( aPosImps[nI][1], 3 ,8 )
		nPosL2Base	:= Ascan( aCampos, "L2" + cBase  )
	ElseIf Substr(aPosImps[nI][1],4,6) = "VALIMP"
		cValor := Substr( aPosImps[nI][1],3 ,8 )
		nPosL2Valor	:= Ascan( aCampos, "L2" + cValor )
	Endif
	
	IF nPosL2Base > 0 .AND. nPosL2Valor > 0
		cCampoBase	:= Subst(cAlias, 2 ) + cBase
		cCampoValor	:= Subst(cAlias, 2 ) + cValor
		IF ( nPosBase := ( cAlias )->( FieldPos( cCampoBase ) ) ) > 0 .AND. ( nPosValor := ( cAlias )->( FieldPos( cCampoValor ) ) ) > 0
			If (aCols[nLine][nPosL2Base] > 0) .AND. (aCols[nLine][nPosL2Valor] > 0)
				DO CASE
					CASE cOperator == '='
						( cAlias )->( FieldPut( nPosBase,	aCols[nLine][nPosL2Base] ) )
						( cAlias )->( FieldPut( nPosValor,Round(aCols[nLine][nPosL2Valor],nDecs) ) )
					CASE cOperator == '+'
						( cAlias )->( FieldPut( nPosBase, FieldGet( nPosBase )  + aCols[nLine][nPosL2Base] ) )
						( cAlias )->( FieldPut( nPosValor,FieldGet( nPosValor ) + Round(aCols[nLine][nPosL2Valor],nDecs) ) )
					CASE cOperator == '-'
						( cAlias )->( FieldPut( nPosBase, FieldGet( nPosBase )  - aCols[nLine][nPosL2Base] ) )
						( cAlias )->( FieldPut( nPosValor,FieldGet( nPosValor ) - Round(aCols[nLine][nPosL2Valor],nDecs) ) )
				ENDCASE
				nPosL2Base :=0
				nPosL2Valor:=0
			ENDIF
		ENDIF
	ENDIF
NEXT nI

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Programa  ³Lj021CalcMoeº Autor ³      Nava       º Data ³  01/06/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Descricao ³ Calcula soma das moedas no valor da moeda 1               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Sintaxe   ³ Lj021CalcMoed(nValorDev)                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Parametro ³ nValorDev  - Valor Total da Devolucao na Moeda 1          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Retorno   ³ .T. se o Valor Total = Soma dos Valores Parciais          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Uso       ³ SigaLoja - Localizacoes                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj021CalcMoed(nValorDev)

LOCAL nSoma     := 0
LOCAL lReturn 	:= .T.
LOCAL nDecs1	:= MsDecimais(1)
LOCAL nY
LOCAL cMoeda1   := GetMV("MV_MOEDA1")


For nY := 1 to Len(aDevol)
	nSoma  += Round(xMoeda(aDevol[nY][_VALORDEV],nY,1,dDatabase,nDecs1+1),nDecs1)
Next nY

nSoma := Round(xMoeda(nValorDev,nMoedaTr,1,dDatabase,nDecs1+1),nDecs1) - nSoma

If nSoma >= (1/10**nDecs1)
	IF MsgNoYes( OemToAnsi( '$ ' + Transform( nSoma, PesqPict("SL1","L1_VLRLIQ",15,nMoedaTr) ) + CRLF + STR0121 + cMoeda1 + STR0132) ) //"A diferen‡a acima ser  acertada na Moeda "###". Deseja Continuar ? "
		aDevol[1][_VALORDEV] += nSoma
	ELSE
		lReturn := .F.
	ENDIF
ELSEIF nSoma < 0
	MsgAlert( OemToAnsi( '$ ' + Transform( nSoma, PesqPict("SL1","L1_VLRLIQ",15,nMoedaTr) ) + CRLF + STR0120 ), OemToAnsi( STR0009 ) )  //"Devolucao MAIOR que o valor original ! Favor corrigir valores !!"   "Aten‡„o"
	lReturn := .F.
ENDIF

RETURN lReturn

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ Lj021VerSaldo ³ Autor ³ Fernando Machima ³ Data ³ 21/08/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verificar se existe saldo na moeda desejada para devolucao ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ ExpL1 := Lj021VerSaldo(ExpA1)             	              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ ExpN2 := Array com os valores a devolver em n moedas       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpL1 := Permite ou nao fetuar a devolucao                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ LOJA021 - Devolucao de Vendas				              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Lj021VerSaldo()
LOCAL lRet      := .T.
LOCAL nI

For nI := 1 to Len(aDevol)
	If aDevol[nI][_VALORDEV] > 0
		If !LjVSaldo(aDevol[nI][_VALORDEV],GetMv("MV_SIMB"+Str(nI,1)))
			lRet  := .F.
			Exit
		End
	EndIf
Next nI

Return (lRet)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ Lj021VldPgto  ³ Autor ³ Fernando Machima ³ Data ³ 23/08/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chamada das 2 rotinas de validacao para efetuar a devolucao³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ ExpL1 := Lj021VldPgto(ExpA1,ExpN1)        	              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³ ExpA1 := Array com os valores a devolver em n moedas       ³±±
±±³          ³ ExpN1 := valor total a ser devolvido na moeda 1            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpL1 := Permite ou nao efetuar a devolucao                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ LOJA021 - Devolucao de Vendas				              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Lj021VldPgto(nValorDev)
LOCAL lRet    := .T.

//Verifica o saldo do Caixa na forma de pagto. Dinheiro
lRet  := Iif(GetMv("MV_LJVLDEV",.F.),Lj021VerSaldo(),.T.)
If lRet
	//Verifica se o total digitado pelo usuario corresponde ao total da devolucao
	lRet := Lj021CalcMoed(nValorDev)
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LjCalcDevI³ Autor ³ Fernando Machima      ³ Data ³ 22/01/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Calcula os valores iniciais da devolucao nas moedas cadas- ³±±
±±³          ³ tradas                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LOJA021                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LjCalcDevIni(nValorDev)

Local nY
Local nDecs  := 2
Local lMoedaUnica  := Len(aDevol) == 1  //Ha apenas uma moeda ativa

For nY := 1 to Len(aDevol)
	nDecs  := MsDecimais(nY)
	aDevol[nY][_SALDO] := Round(xMoeda(nValorDev,nMoedaTr,nY,dDatabase,nDecs+1),nDecs)
	aDevol[nY][_VLRORIG] := aDevol[nY][_SALDO]
	If lMoedaUnica
		aDevol[nY][_VALORDEV] := aDevol[nY][_SALDO]
		aDevol[nY][_SALDO]    := 0
	EndIf
Next nY

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LjDblDev  ³ Autor ³ Fernando Machima      ³ Data ³ 22/01/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Permite a edicao dos valores da devolucao atraves do duplo ³±±
±±³          ³ clique                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LOJA021                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LjDblDev(nValorDev,aDevolBck)

Local nPosOri := oLBBaixa:ColPos

oLBBaixa:ColPos := 3
lEditCell(aDevol,oLBBaixa,PesqPict("SL1","L1_VLRTOT",TamSx3("L1_VLRTOT")[1],oLBBaixa:nAT),3)
oLBBaixa:ColPos := nPosOri
LjRecalcDev(nValorDev,oLBBaixa:nAT,@aDevolBck)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LjRecalcDe³ Autor ³ Fernando Machima      ³ Data ³ 22/01/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Recalcula os valores da devolucao nas moedas cadastradas   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LOJA021                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LjRecalcDev(nValorDev,nLinha,aDevolBck)

Local nY
Local nDif      := 0
Local nVlrDigit := 0
Local nDecs     := 2
Local nDecs1    := MsDecimais(1)
Local lZeraTudo := .F.
Local nSoma     := 0

nDif  := aDevol[nLinha][_VALORDEV] - aDevolBck[nLinha]
aDevol[nLinha][_SOMADEV] += nDif
nVlrDigit := aDevol[nLinha][_SOMADEV]
lZeraTudo  := aDevol[nLinha][_SOMADEV] == aDevol[nLinha][_VLRORIG]
For nY:= 1 To Len(aDevol)
	nDecs := MsDecimais(nY)
	aDevol[nY][_SOMADEV] := Round(xMoeda(nVlrDigit,nLinha,nY,dDataBase,nDecs+1),nDecs) // Converte o somatorio da devolucao digitado pelo usuario da moeda escolhida para a moeda correspondente
	If !lZeraTudo .AND. aDevol[nY][_VLRORIG] - aDevol[nY][_SOMADEV] < 0  // Valor digitado e maior que o valor original
		If aDevol[nY][_SOMADEV] - aDevol[nY][_VLRORIG] >= 1/(10**nDecs)
			// 1/(10**nDecs) -> Tolerancia de arredondamento
			// Se a diferenca entre o digitado e o saldo for maior que a tolerancia 1/(10**nDecs)
			// entao exibe mensagem que valor digitado e maior
			Aviso(STR0009,STR0149,{OemToAnsi(STR0150)})  //"Atencao"###"O valor digitado e maior que o saldo da devolucao."###"OK"
			If nLinha > nY
				aDevol[nY][_SOMADEV] -= Round(xMoeda(nDif,nLinha,nY,dDataBase,nDecs+1),nDecs)
			EndIf
			aDevol[nLinha][_SOMADEV] -= nDif
			aDevol[nLinha][_VALORDEV]:= aDevolBck[nLinha] // Volta o valor que estava no grid (backup)
			Return
		Endif
	Else
		aDevol[nY][_SALDO] := aDevol[nY][_VLRORIG] - aDevol[nY][_SOMADEV]   // Recalcula o saldo ( Valor original - Somatorio do valor informado )
		If aDevol[nY][_SALDO] > 0
			If aDevol[nY][_SALDO] < 1/(10**nDecs)
				lZeraTudo := .T.
			Endif
		Endif
	Endif
	aDevolBck[nY]:= aDevol[nY][_VALORDEV] // Guarda o valor da devolucao digitado pelo usuario
Next nY

If !lZeraTudo
	For nY:= 1 To Len(aDevol)
		nDecs  := MsDecimais(nY)                // Se o saldo de qualquer moeda estiver
		If aDevol[nY][_SALDO] < 1/(10**nDecs)       // menor a tolerancia de decimais,
			lZeraTudo := .T.                   // entao atribui .T. para lZeraTudo
			Exit
		Endif
	Next nY
EndIf

If lZeraTudo
	For nY :=1 To Len(aDevol)
		nSoma  += Round(xMoeda(aDevol[nY][_VALORDEV],nY,1,dDatabase,nDecs1+1),nDecs1)
	Next nY
	nSoma := Round(xMoeda(nValorDev,nMoedaTr,1,dDatabase,nDecs1+1),nDecs1) - nSoma
	If Abs(nSoma) >= (1/10**nDecs1)
		aDevol[1][_VALORDEV]  += nSoma
	EndIf
	For nY :=1 To Len(aDevol)   // Vai zerar a coluna de saldos do grid
		aDevol[nY][_SALDO]  := 0
	Next nY
Endif

oLBBaixa:Refresh()

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Lj021Formul  ³ Autor ³ Fernando Machima   ³ Data ³ 28.01.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Checar se o formulario da nota de credito eh proprio       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Loja021                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Lj021Formul()

Local aArea     := GetArea()
Local cNextNum  := Space(TamSX3("F1_DOC")[1])
Local cChaveSX5 := ""
Local lSeqEspecie  := SuperGetMV("MV_SEQESPE",,.F.)
Local cFilSx5	   := If(FindFunction("LjFilSX5"),LjFilSX5(),xFilial("SX5"))  // Retorna Filial SX5

If LojaOk(STR0153)  //Formul rio pr¢prio para a Nota de Credito?
	cFormProp := "S"
Else
	cFormProp := "N"
Endif
IIf(cFormProp == "N", (cSerieDev:=Space(TamSx3("F1_SERIE")[1]),.T.), Lj021Nota(.F.))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Valida se numeracao da NCC esta autorizada por resolucao   ³
//³(SAT)-Loc. Guatemala                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cFormProp == "S" .AND. cPaisLoc == "GUA"
	If !Empty(cSerieDev)
		cChaveSX5     := IIf(lSeqEspecie,xFilial("SX5")+"AC"+"NCC"+cSerieDev,cFilSx5+"01"+cSerieDev)
		dbSelectArea("SX5")
		If MsSeek(cChaveSX5)
			cNextNum  := AllTrim(X5Descri())
			If !ValNumSAT(cSerieDev,cNextNum,"2",lNFManual)
				//"Atenção"###"Nao ha resolucao cadastrada para a proxima numeracao de Nota de Credito."
				//"O proximo numero de Nota de Credito e: "###"Entre em contato com a SAT." ###"OK"
				Aviso(STR0009,STR0180+chr(13)+STR0181+cNextNum+"/"+cSerieDev+"."+chr(13)+;
				STR0182,{STR0150})
			EndIf
		EndIf
	EndIf
EndIf

RestArea(aArea)

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Lj021NotaExt ³ Autor ³ Fernando Machima   ³ Data ³ 28.01.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Quando nao eh formulario proprio, o usuario deve digitar   ³±±
±±³          ³ serie/numero da Nota de Credito                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Loja021                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Lj021NotaExt()

Local lRet     := .T.
Local oDlg
Local oBtnDev
Local oSerieDev
Local oSucNC
Local oNumNC
Local cSucNC  := Space(4)
Local cNumNC  := Space(8)

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0154) From 10,30 To 16,63 OF oMainWnd  //"Numeracao da Nota de Credito"
@ 2,1.5 TO 27,128 LABEL OemToAnsi(STR0155) OF oDlg PIXEL  //"Numero/Serie"
@ 9, 5 Say OemToAnsi(STR0105) OF oDlg PIXEL  //"Numero"
If cPaisLoc == "ARG"
	@ 9.5, 25 MSGET oSucNC    VAR cSucNC     Picture "9999"     Valid Lj020ZeraGet(@cSucNC) SIZE 15,8 OF oDlg  PIXEL  RIGHT
	@ 9.5, 42 MSGET oNumNC    VAR cNumNC     Picture "99999999" Valid Lj020ZeraGet(@cNumNC) .AND. Lj020ActVar(@cNumNFDev,cSucNC,cNumNC) SIZE 30,8 OF oDlg  PIXEL  RIGHT
Else
	@ 9.5, 25 MSGET oNumNFDev VAR cNumNFDev  Picture REPLICATE("9",TamSx3("F1_DOC")[1]) Valid Lj020ZeraGet(@cNumNFDev) SIZE 50,8 OF oDlg  PIXEL  RIGHT
EndIf
@ 9.5, 75 Say  OemToAnsi(STR0018)  OF oDlg PIXEL  //"Serie"
@ 9.5, 92 MSGET oSerieDev VAR cSerieDev Picture "@!" SIZE 8,8 OF oDlg  PIXEL RIGHT

DEFINE SBUTTON oBtnDev FROM 28,60 TYPE 1 ACTION (IIf(!Empty(cNumNFDev),;
(cSerieDev:=PADR(AllTrim(cSerieDev),3),lRet:=.T., oDlg:End()),NIL)) ENABLE OF oDlg
DEFINE SBUTTON oBtnDev FROM 28,90 TYPE 2 ACTION (lRet:=.F., oDlg:End()) ENABLE OF oDlg
ACTIVATE MSDIALOG oDlg CENTERED

Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³lj021Impri³ Autor ³ Fernando Machima      ³ Data ³ 30/01/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Pergunta se imprime  a nota de credito                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Loja021                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function lj021Imprime()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pergunta se imprime a nota de credito ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lNFManual .AND. (!GetMV("MV_PERGNOT") .OR. LojaOk(OemToAnsi(STR0156)))//Imprime Nota de Credito?
	Lojr110(cNumNFDev,cSerieDev)
EndIf

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj021VldDo³ Autor ³ Fernando Machima      ³ Data ³ 30/01/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida o numero da nota de credito selecionado pelo usuario³±±
±±³          ³ para documentos formulario proprio = Nao                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Loja021                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj021VldDoc(cTipContNF)

Local lVldNumDoc    := .T.

If MsSeek(xFilial("SF3")+cSerieDev+cNumNFDev,.F.)
	While !Eof() .AND. cSerieDev+cNumNFDev == F3_SERIE+F3_NFISCAL .AND. lVldNumDoc
		//Controle de validacao de numeracao da NF considerando o parametro MV_CONTNF.
		//Se a numeracao e a mesma, nao considerar a especie do documento
		//Se a numeracao dos formularios e independente, que seja da mesma especie.
		If F3_TIPO == "D" .AND. cCliente+cLoja == F3_CLIEFOR+F3_LOJA .AND. Alltrim(F3_ESPECIE) $ "NCC|NDE"
			lVldNumDoc  := !Empty(F3_DTCANC)
		EndIf
		DbSkip()
	End
EndIf

Return (lVldNumDoc)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Lj021Troca³ Autor ³Fernando Machima       ³ Data ³30/01/03  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Permite trocar o numero da nota de credito                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Loja021                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj021TrcNum(nItem,aSerNF)
Local oDlgLojaNf
Local oBtn
Local cNumero	:= aSerNf[nItem,2]

DEFINE MSDIALOG oDlgLojaNf TITLE OemToAnsi(STR0151) From 13,50 To 18,65 ;  //"Nota de Credito"
STYLE nOr( DS_MODALFRAME, WS_DLGFRAME ) OF GetWndDefault()

@ 4,2 SAY OemToAnsi(STR0105)  Font oDlgLojaNf:oFont PIXEL //"Numero"

@ 11,2 MSGET cNumero Picture "@!" Font oDlgLojaNf:oFont Valid oDlgLojaNf:End();
SIZE 47,6 PIXEL

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Botao invisivel para sair da tela ao digitar numero ³
//| Sair                                                |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 2000, 2000 BUTTON oBtn Prompt STR0080 SIZE 44, 11 ACTION oDlgLojaNf:End() OF oDlgLojaNf PIXEL

ACTIVATE MSDIALOG oDlgLojaNf

aSerNf[nItem,2] := cNumero

Return aSerNf

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ Lj021DevOut   ³ Autor ³ Fernando Machima ³ Data ³ 31.01.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Programa de Devolucao de Mercadoria de outra loja          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Lj021DevOut(cAlias,nRecno,nOpcx)  						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGALOJA 								    			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ DATA     ³ BOPS ³Prograd.³ALTERACAO                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ 23.02.06 ³092248³Norbert ³Troca do uso do evento bEditCol pelo evento ³±±
±±³          ³      ³        ³cFieldOk. O evento bEditCol passou a ser cha³±±
±±³          ³      ³        ³mado uma unica vez.                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj021DevOut(cAlias,nRecno,nOpcx)

LOCAL aArea     := GetArea()
LOCAL aPages	:= {"HEADER"}
LOCAL aTitles	:= {OemToAnsi(STR0010),; //"Totais"
OemToAnsi(STR0011),; //"Inf. do Cliente"
OemToAnsi(STR0012),; //"Impostos"
OemToAnsi(STR0111) } //""Dados Financeiros"
LOCAL aSizeAut
LOCAL aObjects		:= {}
LOCAL aInfo 		:= {}
LOCAL aPosGet		:= {}
LOCAL aPosObj		:= {}
LOCAL aImposto      := {}
LOCAL aEditCpos     := {}

LOCAL nI
LOCAL nUsado	   := 0
LOCAL nX           := 0
LOCAL nY           := 0
LOCAL nPosValImp   := 0
LOCAL nVlrTot      := 0
LOCAL nDescLoj     := 0
LOCAL nPosImps     := 0
LOCAL nCntItens    := 0

LOCAL cNumAnt   := Space(TamSx3("L1_DOC")[1])
LOCAL cSerAnt   := Space(3)
LOCAL cCampo    := ""
LOCAL cNomClie  := ""
LOCAL cTesImp   := ""

LOCAL lRet	   := .F.

LOCAL oBmp, oCliente, oLoja, oNomClie, oMoeda, oTxMoeda
LOCAL oNumNota, oSerie
LOCAL oDtEmissao
LOCAL oDlg

LOCAL xRet

PRIVATE aObj := Array(21)
PRIVATE oObj1,oObj2,oObj3,oObj4,oObj5,oObj6,oObj7,oObj8,oObj9

DEFAULT l021Auto := .F.
If !l021Auto
	aSizeAut := MsAdvSize(,.F.,400)
EndIf

PRIVATE aInfCliente	  := {"","",CTOD(""),CTOD(""),"","",""}
PRIVATE aValores	  := {0,0,0,0,0,0,0,0,{{'','',0,0,0}},0}
PRIVATE aMoeda        := {}
PRIVATE aPosicoes[0]
PRIVATE aHeader[0]
PRIVATE aCampos[0]
PRIVATE aFieldImpostos:={}, aHeadImpostos:= {}, aColsImpostos:={}, aColsLbx2:={}
PRIVATE aColsFinanc   := {}
PRIVATE aQuantOrig    := {}
PRIVATE aPosImps      := {}

PRIVATE nCredito    := 0
PRIVATE nDesconto	:= 0
PRIVATE nMerc		:= 0
PRIVATE nLinGetdados:= 15
PRIVATE nFolder     := 1
PRIVATE nOpcA       := 2
PRIVATE nTabela     := Int(Val(GetMv("MV_TABPAD")))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis PRIVATE inicializadas                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE oDlg1
PRIVATE oGet

PRIVATE cNumNFDev   := CriaVar("L1_DOC") //Numero da Nota de Credito a ser gerada
PRIVATE cSerieDev   := AllTrim(GetMV("MV_LJNFTRO"))
PRIVATE cNumNota    := Space(TamSx3("F2_DOC")[1])  //Numero da NF a ser gerado caso seja troca e nao devolucao
PRIVATE cSerie 	    := Space(TamSx3("F2_SERIE")[1])  //Serie da NF a ser gerada caso seja troca e nao devolucao
Private cNumPdv	    := Space(TamSx3("L1_PDV")[1])
Private cCliente    := PADR(GetMv("MV_CLIPAD"),TamSX3("A1_COD")[1])
Private cLoja	    := GetMv("MV_LOJAPAD")
PRIVATE cEspecie    := "NCC"
PRIVATE cCliAnt     := ""
PRIVATE cLojAnt     := ""
PRIVATE cDescCli	:= ""
PRIVATE cx3Valid    := ""		// usado na MSGETDADOS
PRIVATE cTipo       := "N"
PRIVATE cFormProp   := "S"
PRIVATE cMotivo     := Space(6)
PRIVATE cDevNCC     := GetMV("MV_DEVNCC")

PRIVATE dDtEmissao  := dDatabase

PRIVATE lComprou	:=.T.

//LjReadvar("lLjTroca",.T.)
lLjTroca := .T.

DbSelectArea("SL1")
DbSetOrder(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o caixa esta aberto, senao nao deixa fazer a troca ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ! LjCxAberto()
	Return(.F.)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada para validacao inicial                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If ExistBlock("LJ021INI")
	xRet  := ExecBlock("LJ021INI",.F.,.F.)
	If ValType(xRet) == "L" .AND. !xRet
		Return (.F.)
	EndIf
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria aHeader com os campos da troca                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nUsado := 0

dbSelectArea("Sx2")
MsSeek("SL2")

dbSelectArea("Sx3")
dbSetOrder(1)
MsSeek( "SL2" )

While !Eof() .AND. (x3_arquivo == "SL2")
	IF (X3USO(X3_USADO) .AND. cNivel >= x3_nivel .AND. Alltrim(x3_campo)<>"L2_NUM";
		.AND. X3_CONTEXT <> "V") .OR. Alltrim(X3_campo) == "L2_ITEM"
		nUsado++
		&('M->'+AllTrim(x3_campo)):=(" SL2->"+x3_campo)
		cx3Valid:=x3_Valid
		If Alltrim(X3_Campo) == "L2_PRODUTO"
			cX3Valid := "Lj021ValProd()"
		ElseIf  Alltrim(X3_Campo) = "L2_QUANT"
			cX3Valid := "LJ021Qtde() .AND. Lj021TESDev('Q')"
		ElseIf AllTrim(X3_CAMPO) = "L2_TES"
			cX3Valid := "Lj021TESDev('T')"
		Endif
		Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal, cX3Valid,;
		x3_usado, x3_tipo, x3_arquivo } )
		Aadd( aCampos, x3_campo )
		
		//Armazena as posicoes dos campos de impostos(bas e e valor) para posterior gravacao na fatura de compras
		If (Substr(X3_CAMPO,4,6) == "BASIMP" .OR. Substr(X3_CAMPO,4,6) == "VALIMP";
			.OR. Substr(X3_CAMPO,4,6) == "ALQIMP")
			Aadd(aPosImps,{X3_CAMPO,nUsado})
		EndIf
		//Monta array com os campos que poderao ser editados na GetDados...
		nPosImps  := Ascan(aPosImps,{|x| AllTrim(x[1]) == AllTrim(SX3->X3_CAMPO)})
		If nPosImps == 0 .AND. AllTrim(X3_CAMPO) <> "L2_ITEM"
			AAdd(aEditCpos,SX3->X3_CAMPO)
		EndIF
	EndIf
	DbSkip()
End

PRIVATE aCOLS[1][nUsado+1], aQtde := {}
PRIVATE aFirst[1][nUsado+1]

Aadd(aColsFinanc,{"","","","",Ctod("  /  /    "),0,1})
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega as Posicoes dos Campos no aHeader	  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LJ021Pos()
LJ010Pos()

nUsado:=0
dbSelectArea("SX3")
DbSetOrder(1)

MsSeek( "SL2" )
While !Eof() .AND. X3_ARQUIVO == "SL2"
	If (x3Uso(X3_USADO) .AND. cNivel >= X3_NIVEL .AND.	Alltrim(X3_CAMPO)<>"L2_NUM";
		.AND. X3_CONTEXT <> "V") .OR. Alltrim(X3_CAMPO) == "L2_ITEM"
		nUsado++
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta Array de 1 elemento vazio. Se inclus„o. 		           ³
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		If x3_tipo == "C"
			If Alltrim(X3_CAMPO)=="L2_ITEM"
				aCols[1][nUsado] := "01"
			Else
				aCOLS[1][nUsado] := SPACE(x3_tamanho)
			EndIf
		ElseIf x3_tipo == "N"
			aCOLS[1][nUsado] := 0
		ElseIf x3_tipo == "D"
			aCOLS[1][nUsado] := dDataBase
		Else
			aCOLS[1][nUsado] := .F.
		EndIf
	EndIf
	dbSkip()
End
aCOLS[1][nUsado+1] := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega array com as moedas ativs para o Combo.      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX	:=	1 To MoedFin()
	If(!(Empty(GetMV("MV_MOEDA"+Alltrim(STR(nX))))))
		AAdd(aMoeda,GetMV("MV_MOEDA"+Alltrim(STR(nX))))
	Else
		Exit
	Endif
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Quando for feita manutencao em alguma VALIDACAO dos GETs,      ³
//³ atualize as funcoes que se encontram no array aValidGet        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !l021Auto
	aObjects := {}
	AAdd( aObjects, { 0,    41, .T., .F. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )
	AAdd( aObjects, { 0,    75, .T., .F. } )
	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects )
	aPosGet := MsObjGetPos(aSizeAut[3]-aSizeAut[1],305,;
	{{10,40,95,140,200,234,268},;
	{10,40,111,140,223,268,60},;
	{5,70,160,205,295},;
	{6,34,200,215},;
	{6,34,80,113,160,175},;
	{6,34,245,268,260},;
	{10,50,150,190},;
	{273,130,190},;
	{8,45,80,103,139,173,200,235,270},;
	{133,190,144,190,289,293},;
	{142,293,140},;
	{9,47,188,148,9,146} } )
	
	LJ021GetIp()
	LJ021Header("1")
	LJ021Refresh("1")
	Lj021VldCli(cCliente,cLoja,@cNomClie)
	
	DEFINE MSDIALOG oDlg FROM aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] TITLE cCadastro OF oMainWnd PIXEL
	
	If File("Bombe.bmp")
		@	0.4,25 BITMAP oBmp FILE "BombE.bmp" OF oDlg NOBORDER SIZE 20,20
		oBmp:lStretch:=.T.
	EndIf
	
	@ 19,005 SAY OemToAnsi(STR0016)   OF oDlg PIXEL              // Cliente
	@ 32,005 SAY OemToAnsi(STR0151)   OF oDlg PIXEL              // "Nota de Credito"
	@ 32,080 SAY OemToAnsi(STR0018)   OF oDlg PIXEL              // Serie
	@ 32,150 SAY OemToAnsi(STR0159)   OF oDlg PIXEL              // Dt. Emissao
	@ 45,005 SAY OemToAnsi(STR0139)   OF oDlg PIXEL              // Moeda
	@ 45,080 SAY OemToAnsi(STR0140)   OF oDlg PIXEL              // Taxa Moeda
	
	
	@ 18,032 MSGET oCliente  VAR cCliente  SIZE  38, 8	 OF oDlg PIXEL F3 "SA1" Picture "@!"  VALID Lj021VldCli(cCliente,cLoja,@cNomClie)
	@ 18,072 MSGET oLoja 	 VAR cLoja	   SIZE   8, 8   OF oDlg PIXEL Picture "@!" ;
	VALID Lj021VldCli(cCliente,cLoja,@cNomClie) .AND. IIf(cFormProp == "N", (cSerieDev:=Space(TamSx3("F1_SERIE")[1]),.T.), Lj021Nota(.F.))
	@ 18,090 MSGET oNomClie  VAR cNomClie  SIZE  170, 8  OF oDlg PIXEL WHEN .F.
	
	@ 31,045 MSGET oNumNota   VAR cNumNFDev  SIZE  55, 8  OF oDlg PIXEL Picture PesqPict("SL1","L1_DOC") VALID Lj020ZeraGet(@cNumNFDev)
	@ 31,102 MSGET oSerie     VAR cSerieDev  SIZE  10, 8  OF oDlg PIXEL Picture "@!"
	@ 31,182 MSGET oDtEmissao VAR dDtEmissao SIZE  45, 8  OF oDlg PIXEL Picture "@!"
	
	@ 44,032 MSGET oMoeda     VAR nMoedaTr   SIZE  35, 8  OF oDlg PIXEL ON CHANGE (nDecimais:=MsDecimais(nMoedaTr))
	@ 44,116 MSGET oTxMoeda   VAR nTxMoedaTr SIZE  40, 8  OF oDlg PIXEL Picture PesqPict("SL1","L1_TXMOEDA")
	
	oGet:= MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcx,"LJ021LinOk","LJ021TudOk",'+L2_ITEM',.T.,aEditCpos,,,300,,,,"LJ021Del",oDlg)
	oGet:oBrowse:bDelete := {|| aCols[n,Len(Acols[n])]:=!aCols[n,Len(Acols[n])],oGet:LinhaOk(),oGet:oBrowse:Refresh(.F.),LJ021LinOk()}
	oGet:oBrowse:bDrawSelect := {|| aImps := RoteiroCalc(nVlrTot,nDescLoj,"D") }  //Calculo de impostos variaveis
	oGet:cFieldOk := "LJ021GetIp(),Lj021ValProd(),.T."
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define a area do rodape da rotina                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oFolder := TFolder():New(aPosObj[3,1],aPosObj[3,2],aTitles,aPages,oDlg,,,, .T., .F.,aPosObj[3,4]-aPosObj[3,2],aPosObj[3,3]-aPosObj[3,1],)
	For nX := 1 to Len(oFolder:aDialogs)
		DEFINE SBUTTON FROM 5000,5000 TYPE 5 ACTION Allwaystrue() ENABLE OF oFolder:aDialogs[nX]
	Next nX
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Folder dos totais da rotina                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oFolder:aDialogs[1]:oFont := oDlg:oFont
	@ 006,aPosGet[3,1] SAY OemToAnsi(STR0022) OF oFolder:aDialogs[1] PIXEL SIZE 055,009 // "Valor da Mercadoria"
	@ 005,aPosGet[3,2] MSGET oObj1 VAR aValores[VALMERC] PICTURE PesqPict('SL1','L1_VLRTOT',14,nMoedaTr) OF oFolder:aDialogs[1] PIXEL WHEN .F. SIZE 080,009
	
	@ 006,aPosGet[3,3] SAY OemToAnsi(STR0023) OF oFolder:aDialogs[1] PIXEL SIZE 049,009 // "Descontos"
	@ 005,aPosGet[3,4] MSGET oObj2 VAR aValores[PERCDESC]  PICTURE PesqPict('SL1','L1_DESCONT',14,nMoedaTr) OF oFolder:aDialogs[1] PIXEL ;
	WHEN .F. SIZE 080,009
	
	@ 020,aPosGet[3,1] SAY OemToAnsi(STR0024) OF oFolder:aDialogs[1] PIXEL SIZE 050,009  // "Frete"
	@ 019,aPosGet[3,2] MSGET oObj3 VAR aValores[FRETE]  PICTURE PesqPict('SL1','L1_FRETE',14,nMoedaTr) OF oFolder:aDialogs[1] PIXEL WHEN .F.  SIZE 080,009
	
	@ 020,aPosGet[3,3] SAY OemToAnsi(STR0025) OF oFolder:aDialogs[1] PIXEL SIZE 050,009  // "Despesas"
	@ 019,aPosGet[3,4] MSGET oObj4 VAR aValores[VALDESP]  PICTURE PesqPict('SL1','L1_DESPESA',14,nMoedaTr) OF oFolder:aDialogs[1] PIXEL WHEN .F.  SIZE 080,009
	
	@ 034,aPosGet[3,1] SAY OemToAnsi(STR0027) OF oFolder:aDialogs[1] PIXEL SIZE 050,009  	 // "Troca"
	@ 033,aPosGet[3,2] MSGET oObj5  VAR aValores[VALTROCA]  PICTURE PesqPict('SL1','L1_VLRTOT',14,nMoedaTr)	WHEN .F. OF oFolder:aDialogs[1] PIXEL SIZE 080,009
	
	@ 034,aPosGet[3,3] SAY OemToAnsi(STR0075) OF oFolder:aDialogs[1] PIXEL SIZE 050,009	//"Valor Desconto"
	@ 033,aPosGet[3,4] MSGET oObj6 VAR aValores[VALDESC]  PICTURE PesqPict('SL1','L1_DESCNF',14,nMoedaTr)	WHEN .F. OF oFolder:aDialogs[1] PIXEL SIZE 080,009
	
	@ 051,aPosGet[3,1] SAY OemToAnsi(STR0028) OF oFolder:aDialogs[1] PIXEL SIZE 050,009	//"Total de Itens"
	@ 049,aPosGet[3,2] MSGET oObj7   VAR aValores[QTDEITEM]  PICTURE "99999"	WHEN .F. OF oFolder:aDialogs[1] PIXEL SIZE 080,009
	
	@ 051,aPosGet[3,3] SAY OemToAnsi(STR0029) OF oFolder:aDialogs[1] PIXEL SIZE 058,009 		//"Total Nota Fiscal"
	@ 049,aPosGet[3,4] MSGET oObj8   VAR aValores[VALBRUTO]  PICTURE PesqPict('SL1','L1_VALBRUT',14,nMoedaTr) OF oFolder:aDialogs[1] PIXEL WHEN .F. SIZE 080,009
	
	@ 043,003 TO 46 ,aPosGet[3,5] LABEL '' OF oFolder:aDialogs[1] PIXEL
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Folder com as informacoes do cliente                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oFolder:aDialogs[2]:oFont := oDlg:oFont
	@ 006,aPosGet[4,1] SAY OemToAnsi(STR0030) OF oFolder:aDialogs[2] PIXEL SIZE 037,009 // "Nome"
	@ 005,aPosGet[4,2] MSGET aObj[09] VAR aInfCliente[_NOMECLI] PICTURE PesqPict('SA1','A1_NOME');
	WHEN .F. OF oFolder:aDialogs[2] PIXEL SIZE 159,009
	@ 006,aPosGet[4,3] SAY OemToAnsi(STR0031) OF oFolder:aDialogs[2] PIXEL SIZE 023,009 // "Tel."
	@ 005,aPosGet[4,4] MSGET aObj[10] VAR aInfCliente[_TELCLI] PICTURE PesqPict('SA1','A1_TEL');
	WHEN .F. OF oFolder:aDialogs[2] PIXEL SIZE 074,009
	@ 043,aPosGet[5,1] SAY OemToAnsi(STR0032) OF oFolder:aDialogs[2] PIXEL SIZE 032,009 // "1a Compra"
	@ 042,aPosGet[5,2] MSGET aObj[13] VAR aInfCliente[_PRICOMCLI] PICTURE PesqPict('SA1','A1_PRICOM') ;
	WHEN .F. OF oFolder:aDialogs[2] PIXEL SIZE 040,009
	@ 043,aPosGet[5,3] SAY OemToAnsi(STR0033) OF oFolder:aDialogs[2] PIXEL SIZE 036,009 // "Ult. Compra"
	@ 042,aPosGet[5,4] MSGET aObj[14] VAR aInfCliente[_ULTCOMCLI] PICTURE PesqPict('SA1','A1_ULTCOM');
	WHEN .F. OF oFolder:aDialogs[2] PIXEL SIZE 040,009
	@ 43 ,aPosGet[5,5] SAY RTrim(RetTitle("A1_CGC")) Of oFolder:aDialogs[2] PIXEL SIZE 21 ,9 // "CNPJ"
	@ 42 ,aPosGet[5,6] MSGET aObj[15] VAR aInfCliente[_CGCCLI] Picture PesqPict('SA1','A1_CGC');
	WHEN .F. OF oFolder:aDialogs[2] PIXEL SIZE 76 ,9
	@ 024,aPosGet[6,1] SAY OemToAnsi(STR0034) OF oFolder:aDialogs[2] PIXEL SIZE 049,009 // "Endereco"
	@ 023,aPosGet[6,2] MSGET aObj[11] VAR aInfCliente[_ENDCLI]  PICTURE PesqPict('SA1','A1_END');
	WHEN .F. OF oFolder:aDialogs[2] PIXEL SIZE 205,009
	@ 024,aPosGet[6,3] SAY OemToAnsi(STR0035) OF oFolder:aDialogs[2] PIXEL SIZE 032,009 // "Estado"
	@ 023,aPosGet[6,4] MSGET aObj[12] VAR aInfCliente[_ESTCLI]  PICTURE PesqPict('SA1','A1_EST');
	WHEN .F. OF oFolder:aDialogs[2] PIXEL SIZE 021,009
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Folder do resumo de impostos                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oFolder:aDialogs[3]:oFont := oDlg:oFont
	aObj[16] := Lj021Impostos(oFolder:aDialogs[3])
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Folder dos dados financeiros                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oFolder:aDialogs[4]:oFont := oDlg:oFont
	aObj[17]  := Lj021Financ(oFolder:aDialogs[4])
	
	ACTIVATE MSDIALOG oDlg ON INIT (LJ021Bar(oDlg),Lj021Formul(),oNumNota:refresh(), oSerie:refresh() ) CENTER
	
EndIf

If nOpcA <> 1
	RestArea(aArea)
	Return(.F.)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ A gravacao do motivo da devolucao eh Obrigatoriedade³
//³ fiscal - Loc. Guatemala                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cPaisLoc == "GUA"
	If !Lj021MotDev()
		RestArea(aArea)
		Return .F.
	EndIf
EndIf

If LJ021Opcoes()  //Mostra tela de opcoes(Trocar/Devolver/Abandonar)
	If lDevoluca
		nVlrTran   := aValores[VALBRUTO]  //Valor a ser devolvido
		nCntItens := 0
		For nI := 1 To Len(aCols)
			If ! aCols[nI][Len(aCols[1])]
				nCntItens ++
			EndIf
		Next nI
		If nCntItens > 0
			lRet  := LJ021VldDev(nRecno,Space(TamSX3("F2_DOC")[2]),Space(TamSX3("F2_SERIE")[2]),nVlrTran)
		EndIf
	ElseIf lTrocaOut
		For nI:=1 to Len(aCols)
			If !aCols[nI][Len(aCols[nI])]
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Considerar todos os impostos que incidem no Total da Nota ³
				//³ baseando se na Roteiro Amarracao Tes X Impostos.          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nCredito += aCols[nI][nPosVlrItem]
				cTesImp := aCols[nI][nPosTes]
				aImposto := DefImposto( cTesImp )
				For nY := 1 To Len(aImposto)
					cCampo := "L2_"+aImposto[nY][2]
					If aImposto[nY][3] == "1"  //Determina se imposto incide ou nao na nota
						nPosValImp := Ascan(aHeader,{|x| x[2] == cCampo})
						nCredito   +=  aCols[nI][nPosValImp]
					EndIf
				Next nY
			EndIf
		Next nI
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ A ocorrencia 25 (ACS), verifica se o usu rio poder  ou n„o 	  ³
		//³ efetuar um Atendimento. (Para Criar um orcamento novo de troca³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !ChkPsw( 25 )
			RestArea( aArea )
			Return( .F. )
		EndIf
		
		nVlrTran  := aValores[VALBRUTO]  //Valor a ser trocado
		
		If lj010ate("SL1",,3,,cCliente,cLoja)
			nVlrTran-=SL1->L1_VLRTOT
			LJ021Pos()
			lRet := LJ021VldDev(nRecno,cNumAnt,cSerAnt,nVlrTran)
		Else
			Help(" ",1,"NAOTROCADO")
		EndIf
	EndIf
Else
	RestArea(aArea)
	Return(.F.)
EndIf

lTroca     := .F.
lParcial   := .F.
lTotal     := .F.
lDevoluca  := .F.
lTrocaOut  := .F.

RestArea( aArea )

aRotina[3][4] := 4

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³Lj021ValPr³ Autor ³ Fernando Machima      ³ Data ³ 31/01/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Gatilhos do Campo Produto (L2_PRODUTO)                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ LOJA021                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Lj021ValProd()

Local aAreaAtu   := GetArea()
Local lRet	     := .F.
Local nPosDesc   := Ascan(aHeader,{|x|Subs(x[2],1,9)=="L2_DESCRI"})
Local nPosTes    := Ascan(aHeader,{|x|Subs(x[2],1,6)=="L2_TES"})
Local nPosCFO    := Ascan(aHeader,{|x|Subs(x[2],1,5)=="L2_CF"})
Local nPosProd   := Ascan(aHeader,{|x|Subs(x[2],1,10)=="L2_PRODUTO"})
Local cCodProd   := If(ReadVar()=="M->L2_PRODUTO",&(ReadVar()),aCols[n][nPosProd])
Local cTes       := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Funcao utilizada para verificar a ultima versao dos fontes      ³
//³ SIGACUS.PRW, SIGACUSA.PRX e SIGACUSB.PRX, aplicados no rpo do   |
//| cliente, assim verificando a necessidade de uma atualizacao     |
//| nestes fontes. NAO REMOVER !!!							        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF !(FindFunction("SIGACUS_V") .AND. SIGACUS_V() >= 20050512)
	Final("Atualizar SIGACUS.PRW !!!")
Endif
IF !(FindFunction("SIGACUSA_V") .AND. SIGACUSA_V() >= 20050512)
	Final("Atualizar SIGACUSA.PRX !!!")
Endif
IF !(FindFunction("SIGACUSB_V") .AND. SIGACUSB_V() >= 20050512)
	Final("Atualizar SIGACUSB.PRX !!!")
Endif

SB1->(dbSetOrder(1))
If SB1->(MsSeek(xFilial("SB1")+cCodProd))
	//Indica que existe o produto cadastrado no arquivo SB1...
	lRet := .T.
	
	If nPosDesc > 0
		aCols[n][nPosDesc] := SB1->B1_DESC
	EndIf
	
	If aCols[n][nPosTES] >= "501"  //So atualiza se TES for de saida. Condicao para
		SF4->(dbSetOrder(1))        //permitir que TES seja modificado
		If SF4->(MsSeek(xFiliaL("SF4")+If(!Empty(RetFldProd(SB1->B1_COD,"B1_TS")),RetFldProd(SB1->B1_COD,"B1_TS"),GetMV("MV_TESSAI")))) .AND. (nPosTes > 0)
			If !Empty(SF4->F4_TESDV)
				cTes := SF4->F4_TESDV
			Else
				cTes := GetMV("MV_TESTROC")
			EndIf
			SF4->(MsSeek(xFiliaL("SF4")+cTes))
			aCols[n][nPosTes] := SF4->F4_CODIGO
			M->L2_TES := aCols[n][nPosTes]
		EndIf
		
		If (nPosCFO > 0) .AND. (nPosTes > 0)
			aCols[n][nPosCFO] := SF4->F4_CF
			M->L2_CFO := SF4->F4_CF
		EndIf
	EndIf
	
	//Restaura a areA original...
	RestArea(aAreaAtu)
	
	//Atualiza os dados...
	Lj021Refresh()
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³Lj021VldCl³ Autor ³ Fernando Machima      ³ Data ³ 03/02/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Validar dados(codigo+loja) do cliente e buscar nome        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ LOJA021                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Lj021VldCli(cCliente,cLoja,cNomClie)

Local lRet      := .F.

SA1->(DbSetOrder(1))
If SA1->(MsSeek(xFilial("SA1")+PADR(cCliente,TamSX3("A1_COD")[1])+cLoja))
	cNomClie := SA1->A1_NOME
	lRet  := .T.
Else
	Aviso(STR0009,STR0160,{OemtoAnsi(STR0150)})  //"Atencao###"Cliente nao cadastrado!"###"OK"
EndIf

If lRet
	aInfCliente[_NOMECLI]   := SA1->A1_NOME
	aInfCliente[_TELCLI]    := SA1->A1_TEL
	aInfCliente[_PRICOMCLI] := SA1->A1_PRICOM
	aInfCliente[_ULTCOMCLI] := SA1->A1_ULTCOM
	aInfCliente[_ENDCLI]    := SA1->A1_END
	aInfCliente[_ESTCLI]    := SA1->A1_EST
	aInfCliente[_CGCCLI]    := SA1->A1_CGC
EndIf

Return (lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³Lj021Opcoe³ Autor ³ Fernando Machima      ³ Data ³ 04/02/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Mostrar as opcoes de devolucao ou troca                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ LOJA021                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Lj021Opcoes()

Local oDlgChoice
Local oBtnTroc
Local oBtnDevol
Local oBtnCancel
LOCAL lRet  := .T.

// Escolha a Opera‡„o
DEFINE MSDIALOG oDlgChoice TITLE Oemtoansi(STR0161);
From 10,30 To 17,68 OF GetWndDefault()

@ 0,1 TO 35,148 OF oDlgChoice PIXEL

// Trocar...
@ 1,3 BUTTON oBtnTroc PROMPT OemToAnsi(STR0162) SIZE 40,18;
ACTION (lTroca := .T.,lTrocaOut := .T.,lDevoluca := .F.,lRet := .T.,oDlgChoice:End()) OF oDlgChoice

// Devolver...
@ 1,14 BUTTON oBtnDevol PROMPT OemToAnsi(STR0163) SIZE 40,18;
ACTION (lTroca := .T.,lTrocaOut := .T.,lDevoluca := .T.,lRet := .T.,oDlgChoice:End()) OF oDlgChoice

// Abandonar...
@ 1,25 BUTTON oBtnCancel PROMPT OemToAnsi(STR0164) SIZE 40,18;
ACTION (lTroca := .F.,lTrocaOut := .F.,lDevoluca := .F.,lRet := .F.,oDlgChoice:End()) OF oDlgChoice

ACTIVATE MSDIALOG oDlgChoice CENTERED

Return (lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³Lj021Valid³ Autor ³ Fernando Machima      ³ Data ³ 04/02/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Mostrar as opcoes de devolucao ou troca                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ LOJA021                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Lj021Valid(nOpcDev)

LOCAL lRet  := .F.

lRet  := nOpcDev == 1

If !lRet
	Aviso(STR0009,STR0174,{OemToAnsi(STR0150)})   //"Para confirmar o anular la transacion use los botones abajo."
EndIf

Return(lRet)
