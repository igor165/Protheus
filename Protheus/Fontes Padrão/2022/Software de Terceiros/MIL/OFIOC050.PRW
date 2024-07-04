#INCLUDE 'FIVEWIN.CH'
#INCLUDE 'APVT100.CH'
#INCLUDE 'OFIOC050.CH'

/*/{Protheus.doc} mil_ver()
    Versao do fonte modelo novo

    @author Andre Luis Almeida
    @since  10/01/2018
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "006132_1"

/*/{Protheus.doc} OFIOC050
Coletor/Leitor VT100 - Consulta de Enderecos de um determinado Item

@author Andre Luis Almeida
@since 10/01/2018
@version undefined

@type function
/*/
Function OFIOC050()
Private nCodSB1 := TamSx3("B1_CODBAR")[1]
Private cCodSB1 := space(nCodSB1)
Private nTamCol := VTMaxCol()
Private nTamLin := VTMaxRow()
//
FS_SEL_ITEM() // Selecionar qual Item que sera verificado o Endereco
//
Return

/*/{Protheus.doc} FS_SEL_ITEM
Selecionar qual Item que ira listar os Enderecos

@author Andre Luis Almeida
@since 10/01/2018
@version undefined

@type function
/*/
Static Function FS_SEL_ITEM() // Selecionar qual ITEM que sera verificado o Endereco
While .t.
	cCodSB1 := space(nCodSB1)
	FS_LIMPATELA() // Limpa Tela
	@ 00, 00 VTSay PadR(STR0001, nTamCol) // Lista Enderecos
	@ 01, 00 VTSay repl("-", nTamCol)
	@ 03, 00 VTSay PadR(STR0002, nTamCol) // Codigo do Item
	@ 04, 00 VTGet cCodSB1 Valid FS_B1CODBAR()
	VTRead
	If VTLastKey() <> 27 // Diferente de ESC
		If !Empty(cCodSB1)
			FS_LISTA_END() // Mostrar todos os enderecos que o ITEM se encontra
		EndIf
	Else
		Exit
	EndIf
EndDo
Return

/*/{Protheus.doc} FS_LISTA_END
Lista todos os Enderecos do Item

@author Andre Luis Almeida
@since 10/01/2018
@version undefined

@type function
/*/
Static Function FS_LISTA_END() // Mostrar todos os enderecos que o ITEM se encontra
Local aSize    := {nTamCol}
Local aColunas := {}
Local aLinhas  := {}
Local lMostraQtd := ( GetNewPar("MV_MIL0137","1") == "1" ) // Consulta Endereco pelo Coletor - Mostra Saldo? ( 0=Nao / 1=Sim )
DbSelectArea("SB5")
DbSetOrder(1)
DbSeek(xFilial("SB5")+SB1->B1_COD)
If Localiza(SB1->B1_COD)
	DbSelectArea("SBF")
	DbSetOrder(2)
	DbSeek(xFilial("SBF")+SB1->B1_COD)
	Do While !Eof() .and. xFilial("SBF") == SBF->BF_FILIAL .and. SBF->BF_PRODUTO == SB1->B1_COD // Levantar os Enderecos do ITEM
		aAdd(aLinhas,{SBF->BF_LOCAL+" "+SBF->BF_LOCALIZ})
		If lMostraQtd
			aAdd(aLinhas,{left(" ->"+space(10),nTamCol-13)+Transform(SBF->BF_QUANT,"@E 99,999,999.99")})
		EndIf
		DbSelectArea("SBF")
		DbSkip()
	EndDo
Else
	aAdd(aLinhas,{FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD")+" "+FM_PRODSBZ(SB1->B1_COD,"SB5->B5_LOCALI2")})
	If lMostraQtd
		aAdd(aLinhas,{repl("-", nTamCol)})
		DbSelectArea("SB2")
		DbSetOrder(1)
		DbSeek(xFilial("SB2")+SB1->B1_COD)
		Do While !Eof() .and. xFilial("SB2") == SB2->B2_FILIAL .and. SB2->B2_COD == SB1->B1_COD // Levantar os Saldos por Armazem
			aAdd(aLinhas,{left(SB2->B2_LOCAL+space(10),nTamCol-13)+Transform(SB2->B2_QATU,"@E 99,999,999.99")})
			DbSelectArea("SB2")
			DbSkip()
		EndDo
	EndIf
EndIf
FS_LIMPATELA() // Limpa Tela
@ 00, 00 VTSay PadR(SB1->B1_GRUPO, nTamCol)
@ 01, 00 VTSay PadR(SB1->B1_CODITE, nTamCol)
aColunas := { PadR(SB1->B1_DESC, nTamCol) }
VTaBrowse(2,0,nTamLin,nTamCol,aColunas,aLinhas,aSize,,)
cCodSB1 := space(nCodSB1)
VTGetRefresh("cCodSB1")
Return()

/*/{Protheus.doc} FS_LIMPATELA
Limpa Tela do Coletor/Leitor

@author Andre Luis Almeida
@since 10/01/2018
@version undefined

@type function
/*/
Static Function FS_LIMPATELA() // Limpa Tela
Local ni := 0
VTCLEARBUFFER()
VTClear() // Limpa Tela
For ni := 1 to nTamLin
	@ ni, 00 VTSay repl(" ",nTamCol)
Next
Return

/*/{Protheus.doc} FS_B1CODBAR
Posicionar no SB1 com Codigo de Barras

@author Andre Luis Almeida
@since 10/01/2018
@version undefined

@type function
/*/
Static Function FS_B1CODBAR() // Posicionar no SB1 com Codigo de Barras
Local lRet     := .t.
Local aProduto := {}
Local oPeca    := DMS_Peca():New()
If !Empty(cCodSB1)
	//
	aProduto := oPeca:LeCodBarras(cCodSB1) // Leitura do Codigo de Barras
	//
	If Len(aProduto) > 0
		DbSelectArea("SB1")
		DbSetOrder(1)
		If Empty(aProduto[1]) .or. !DbSeek(xFilial("SB1")+aProduto[1])
			cCodSB1 := space(nCodSB1)
			VTGetRefresh("cCodSB1")
			lRet := .f.
			VtBeep(3) // 3 Beep ERRO
			VTAlert(STR0004) // Item nao encontrado no Cadastro de Produtos.
		Else
			VtBeep(1) // 1 Beep OK
		EndIf
	Else
		cCodSB1 := space(nCodSB1)
		VTGetRefresh("cCodSB1")
		lRet := .f.
		VtBeep(3) // 3 Beep ERRO
		VTAlert(STR0004) // Item nao encontrado no Cadastro de Produtos.
	EndIf
EndIf
Return lRet