#INCLUDE "PROTHEUS.CH"
/*/{Protheus.doc} OFIA290
Funcoes DMS - Chamadas pelo MATA103 ( NF ENTRADA POR COMPRA ) e MATA140 ( PRE NF ENTRADA POR COMPRA )

@author Andre Luis Almeida
@since 01/06/2020
@version 1.0
@return NIL
/*/
Function OFIA290()
Return NIL

/*/{Protheus.doc} OA2900011_A103NFiscal_PodeClassificar
	Chamada do MATA103 funcao A103NFiscal ( Verifica se pode Classificar a NF )

	@author Andre Luis Almeida
	@since 02/06/2020
/*/
Function OA2900011_A103NFiscal_PodeClassificar( aParametros )
Local lRetorno := .f.
// Verifica se pode classificar a NF - Conferencia de Itens da NF de Entrada
If ExistBlock("OA290CLA")
	lRetorno := ExecBlock("OA290CLA",.f.,.f.,{	aParametros[1] ,; // Variavel cTipo do MATA103 ( N=Normal / D=Devolucao )
												aParametros[2] ,; // Variavel cNFiscal do MATA103 ( Nro.NF )
												aParametros[3] }) // Variavel INCLUI do MATA103
Else
	lRetorno := OM3900161_PermiteClassificarNFEntrada(	aParametros[1] ,; // Variavel cTipo do MATA103 ( N=Normal / D=Devolucao )
														aParametros[2] ,; // Variavel cNFiscal do MATA103 ( Nro.NF )
														aParametros[3]  ) // Variavel INCLUI do MATA103
EndIf
Return lRetorno

/*/{Protheus.doc} OA2900021_A103NFiscal_AposOK
	Chamada do MATA103 funcao A103NFiscal ( Rotina de Inclusao/Alteracao/Exclusao de NF de Compra )

	@author Andre Luis Almeida
	@since 02/06/2020
/*/
Function OA2900021_A103NFiscal_AposOK( aParametros )
Local lRetorno := .f.
Local oVmi     := OFAGVmi():New()
Local cMVMIL0006 := AllTrim(GetNewPar("MV_MIL0006","")) // Marca que a Filial trabalha
//
 If aParametros[2] == 1 // Confirmou a Tela
	// Apos Ok da Tela - Verifica Conferencia de Entrada - Se houver Divergencia, faz movimentacao do Item
	 If ExistBlock("OA290DOK")
		lRetorno := ExecBlock("OA290DOK",.f.,.f.,{	aParametros[1] ,; // nOpc ( 3-Inclusao / 4-Alteracao / 5-Exclusao )
													aParametros[2] ,; // Opcao OK ( Confirmou a Tela )
													aParametros[3] ,; // Numero da NF
													aParametros[4] ,; // Serie da NF
													aParametros[5] ,; // Fornecedor
													aParametros[6] }) // Loja
	Else
	 	lRetorno := OM3900151_AposOkMATA103(aParametros[1] ,; // nOpc ( 3-Inclusao / 4-Alteracao / 5-Exclusao )
											aParametros[2] ,; // Opcao OK ( Confirmou a Tela )
											aParametros[3] ,; // Numero da NF
											aParametros[4] ,; // Serie da NF
											aParametros[5] ,; // Fornecedor
											aParametros[6]  ) // Loja
	EndIf
	If lRetorno
		If ( "/"+cMVMIL0006+"/" ) $ "/VAL/MSF/FDT/" // VMI somente para VALTRA / MASSEY / FENDT
			oVmi:Trigger({;
					{'EVENTO', oVmi:oVmiMovimentos:Pedido },;
					{'ORIGEM', "MATA103_DMS3"             },;
					{'DELETE', ( aParametros[1] == 5 )    },;
					{'ALTERA', ( aParametros[1] == 4 )    },;
					{'INCLUI', ( aParametros[1] == 3 )    },;
					{'CODIGO', ( aParametros[3] + aParametros[4] + aParametros[5] + aParametros[6] ) } ; // DOC + SERIE + FORNECEDOR + LOJA
			})
		EndIf
	EndIf
EndIf
//
Return lRetorno

/*/{Protheus.doc} OA2900035_MaCanDelF1_Valid
	Chamada do MATA103X funcao MaCanDelF1

	@author Renato Vinicius
	@since 02/12/2021
/*/
Function OA2900035_MaCanDelF1_Valid( aParametros )

	Local lRetorno := .f.

	lRetorno := FM_CHKDNFE( aParametros[1], aParametros[2], aParametros[3], aParametros[4] ) // F1_DOC/F1_SERIE/F1_FORNECE/F1_LOJA

Return lRetorno

/*/{Protheus.doc} OA2900045_a103Grava_AposGravacao do SF1 e SD1
	Chamada do MATA103 funcao a103Grava

	@author Renato Vinicius
	@since 02/12/2021
/*/
Function OA2900045_a103Grava_AposGravacao( aParametros )

	Local aArea    := GetArea()
	Local cCombust := GetMv("MV_COMBUS")
	Local lVerComb := SF1->F1_FORMUL == "S" .and. Alltrim(SF1->F1_ESPECIE) == "SPED"

	CD6->(dbSetOrder(1))
	C0G->(DbSetOrder(7))

	// Chamado 004638 - 
	dbSelectArea("SD1")
	dbSetOrder(1)
	dbSeek(xFilial("SD1") + aParametros[1] + aParametros[2] + aParametros[3] + aParametros[4] )

	While !Eof() .and. (SD1->D1_FILIAL + SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA  == xFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA )

		FM_BXSUGCOM( SD1->D1_PEDIDO, SD1->D1_ITEMPC, SD1->D1_COD, SD1->D1_LOCAL, SD1->D1_DTDIGIT, SD1->D1_TES, SD1->D1_QUANT, SD1->D1_FORNECE, SD1->D1_LOJA, SD1->D1_DOC, SD1->D1_SERIE, SD1->D1_LOTECTL )

		If lVerComb
			If Alltrim(SD1->D1_GRUPO) $ cCombust

				DbSelectArea("SB1")
				DbSeek(xFilial("SB1")+SD1->D1_COD)

				If !CD6->(dbSeek(xFilial("CD6")+"E"+SD1->D1_SERIE+SD1->D1_DOC+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_COD))

					C0G->(DbSeek(xFilial("C0G")+SB1->B1_CODSIMP))

					DbSelectArea("CD6")
					RecLock("CD6",.T.)
						CD6_FILIAL := xFilial("CD6")
						CD6_TPMOV  := "E"
						CD6_DOC    := SD1->D1_DOC
						CD6_SERIE  := SD1->D1_SERIE
						CD6_CLIFOR := SD1->D1_FORNECE
						CD6_LOJA   := SD1->D1_LOJA
						CD6_ITEM   := SD1->D1_ITEM
						CD6_COD    := SD1->D1_COD
						CD6_UFCONS := SF1->F1_EST
						CD6_CODANP := SB1->B1_CODSIMP
						CD6_DESANP := C0G->C0G_DESCRI
					MsUnlock()
				EndIf
				DbSelectArea("SD1")
			Endif
		EndIf

		SD1->(DbSkip())
	Enddo

	RestArea(aArea)

Return
/*/{Protheus.doc} OA2900031_A140NFiscal_AposOK
	Chamada do MATA140 funcao A140NFiscal ( Rotina de Inclusao/Alteracao/Exclusao de Pré-NF de Compra )

	@author Andre Luis Almeida
	@since 17/11/2021
/*/
Function OA2900031_A140NFiscal_AposOK( aParametros )
Local lRetorno := .t.
//
If aParametros[2] == 1 // Confirmou a Tela
	// Apos Ok da Tela - Pre-NF Entrada
	lRetorno := OM3900341_AposOkMATA140(aParametros[1] ,; // nOpc ( 3-Inclusao / 4-Alteracao / 5-Exclusao )
										aParametros[2] ,; // Opcao OK ( Confirmou a Tela )
										aParametros[3] ,; // Numero da NF
										aParametros[4] ,; // Serie da NF
										aParametros[5] ,; // Fornecedor
										aParametros[6] ,; // Loja
										aParametros[7]  ) // Tipo
EndIf
//
Return lRetorno
