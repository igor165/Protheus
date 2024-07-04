#INCLUDE 'FIVEWIN.CH'
#INCLUDE 'APVT100.CH'
#INCLUDE 'OFIA180.CH'

/*/{Protheus.doc} OFIA180
Coletor/Leitor VT100 - Atualiza Endereco do Item

@author Andre Luis Almeida
@since 01/10/2019
@version undefined

@type function
/*/
Function OFIA180()
Local lVAI_ATUEND := ( VAI->(FieldPos("VAI_ATUEND")) <> 0 ) // Permissao para Atualizar o Endereco
Private nCodSB1 := TamSx3("B1_CODBAR")[1]
Private cCodSB1 := space(nCodSB1)
Private nTamCol := VTMaxCol()
Private nTamLin := VTMaxRow()
//
VAI->(dbSetOrder(4))
VAI->(MsSeek(xFilial("VAI")+__cUserID)) // Posiciona no VAI do usuario logado
If !lVAI_ATUEND .or. VAI->VAI_ATUEND <> "1" // Permissao para Atualizar o Endereco
	VtBeep(3) // 3 Beep ERRO
	VTAlert(STR0010,STR0004) // Usuario sem permissao para atualizar o Endereco do Item. / Atencao
	Return
EndIf
//
OA1800011_Selecionar_ITEM() // Selecionar qual Item que sera atualizado o Endereco
//
Return

/*/{Protheus.doc} OA1800011_Selecionar_ITEM
Selecionar qual Item que ira atualizar o Endereco

@author Andre Luis Almeida
@since 01/10/2019
@version undefined

@type function
/*/
Static Function OA1800011_Selecionar_ITEM() // Selecionar qual ITEM que sera atualizado o Endereco
While .t.
	cCodSB1 := space(nCodSB1)
	OA1800031_LIMPATELA() // Limpa Tela
	@ 00, 00 VTSay PadR(STR0001, nTamCol) // Atualiza Endereco
	@ 01, 00 VTSay repl("-", nTamCol)
	@ 03, 00 VTSay PadR(STR0002, nTamCol) // Codigo do Item
	@ 04, 00 VTGet cCodSB1 Valid OA1800041_B1CODBAR()
	VTRead
	If VTLastKey() <> 27 // Diferente de ESC
		If !Empty(cCodSB1)
			OA1800021_Atualiza_ENDERECO() // Atualiza o endereco do ITEM
		EndIf
	Else
		Exit
	EndIf
EndDo
Return

/*/{Protheus.doc} OA1800021_Atualiza_ENDERECO
Atualiza o endereco do ITEM

@author Andre Luis Almeida
@since 01/10/2019
@version undefined

@type function
/*/
Static Function OA1800021_Atualiza_ENDERECO() // Atualiza o endereco do ITEM
Local cEndOld := space(TamSX3("B5_LOCALI2")[1])
Local cEndNew := space(TamSX3("B5_LOCALI2")[1])
OA1800031_LIMPATELA() // Limpa Tela
DbSelectArea("SB5")
DbSetOrder(1)
DbSeek(xFilial("SB5")+SB1->B1_COD)
DbSelectArea("SB2")
DbSetOrder(1)
DbSeek(xFilial("SB2")+SB1->B1_COD+SB1->B1_LOCPAD)
If Localiza(SB1->B1_COD)
	VTAlert(STR0005,STR0004) // Item enderecado. Impossivel alterar via coletor. / Atencao
Else
	cEndOld := FM_PRODSBZ(SB1->B1_COD,"SB5->B5_LOCALI2")
	@ 00, 00 VTSay PadR(SB1->B1_GRUPO , nTamCol)
	@ 01, 00 VTSay PadR(SB1->B1_CODITE, nTamCol)
	@ 02, 00 VTSay PadR(SB1->B1_DESC  , nTamCol)
	@ 03, 00 VTSay PadR(left(STR0011+space(30),nTamCol-13)+Transform(SB2->B2_QATU,"@E 99,999,999.99"), nTamCol) // Qtd.
	@ 04, 00 VTSay PadR(cEndOld, nTamCol)
	@ 05, 00 VTSay repl("-",nTamCol)
	@ 06, 00 VTSay PadR(STR0003, nTamCol) // Novo Endereco
	@ 07, 00 VTGet cEndNew
	VTRead
	If VTLastKey() <> 27 // Diferente de ESC
		If VtYesNo(	Alltrim(cEndOld)+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
					STR0009+CHR(13)+CHR(10)+;
					Alltrim(cEndNew),STR0001,.t.) // Para: / Atualiza Endereco
			OA1800051_Grava_ENDERECO(cEndOld,cEndNew) // Atualiza o endereco do ITEM
		EndIf
	EndIf
EndIf
Return

/*/{Protheus.doc} OA1800031_LIMPATELA
Limpa Tela do Coletor/Leitor

@author Andre Luis Almeida
@since 01/10/2019
@version undefined

@type function
/*/
Static Function OA1800031_LIMPATELA() // Limpa Tela
Local ni := 0
VTCLEARBUFFER()
VTClear() // Limpa Tela
For ni := 1 to nTamLin
	@ ni, 00 VTSay repl(" ",nTamCol)
Next
Return

/*/{Protheus.doc} OA1800041_B1CODBAR
Posicionar no SB1 com Codigo de Barras

@author Andre Luis Almeida
@since 01/10/2019
@version undefined

@type function
/*/
Static Function OA1800041_B1CODBAR() // Posicionar no SB1 com Codigo de Barras
Local cMsgTit  := STR0004 // Atencao
Local cMsgErr  := ""
Local lRet     := .t.
Local aProduto := {}
Local oPeca    := DMS_Peca():New()
Local cArq     := "SB5"
If !Empty(cCodSB1)
	//
	aProduto := oPeca:LeCodBarras(cCodSB1) // Leitura do Codigo de Barras
	//
	If Len(aProduto) > 0
		DbSelectArea("SB1")
		DbSetOrder(1)
		If Empty(aProduto[1]) .or. !DbSeek(xFilial("SB1")+aProduto[1])
			lRet := .f.
			cMsgErr := STR0006 // Item nao encontrado no Cadastro de Produtos.
		Else
			If SuperGetMV("MV_ARQPROD",.F.,"SB1") == "SBZ"
				cArq := "SBZ"
			EndIf
			If ExistBlock("OA180SB1")
				ExecBlock("OA180SB1",.f.,.f.,{ SB1->B1_COD , cArq }) // Ponto de Entrada apos Posicionar no SB1
			EndIf
			DbSelectArea(cArq)
			DbSetOrder(1)
			If DbSeek(xFilial(cArq)+SB1->B1_COD)
				VtBeep(1) // 1 Beep OK
			Else			
				lRet := .f.
				cMsgErr := STR0007 // Item nao encontrado no Complemento do Produto.
				cMsgTit += " ( "+cArq+" )"
			EndIf
		EndIf
	Else
		lRet := .f.
		cMsgErr := STR0006 // Item nao encontrado no Cadastro de Produtos.
	EndIf
	If !lRet
		VtBeep(3) // 3 Beep ERRO
		VTAlert(cMsgErr,cMsgTit)
		cCodSB1 := space(nCodSB1)
		VTGetRefresh("cCodSB1")
	EndIf
EndIf
Return lRet

/*/{Protheus.doc} OA1800051_Grava_ENDERECO
Grava Endereco do Item no SBZ ou SB5

@author Andre Luis Almeida
@since 01/10/2019
@version undefined

@type function
/*/
Static Function OA1800051_Grava_ENDERECO(cEndOld,cEndNew)
Local cArq := "B5"
If SuperGetMV("MV_ARQPROD",.F.,"SB1") == "SBZ"
	cArq := "BZ"
EndIf
DbSelectArea("S"+cArq)
DbSetOrder(1)
If DbSeek(xFilial("S"+cArq)+SB1->B1_COD)
	// Gravar SB5 / SBZ
	RecLock("S"+cArq,.f.)
		&("S"+cArq+"->"+cArq+"_LOCALI2") := cEndNew
	MsUnLock()
	If ExistBlock("OA180DGR")
		ExecBlock("OA180DGR",.f.,.f.,{ SB1->B1_COD , "S"+cArq , cEndOld , cEndNew }) // Ponto de Entrada apos a Gravação do Endereço ( B5_LOCALI2 ou BZ_LOCALI2 )
	EndIf
	VtBeep(2) // 2 Beep - Endereco Alterado
	VTAlert(STR0008+CHR(13)+CHR(10)+cEndNew,STR0004) // Endereco alterado com sucesso. / Atencao
EndIf
Return