#INCLUDE "FIVEWIN.CH"
#INCLUDE "APVT100.CH"
#INCLUDE "OFIA070.CH"

/*/{Protheus.doc} OFIA070
Coletor/Leitor VT100 - Conferencia de Saida - Orcamento

@author Andre Luis Almeida
@since 01/10/2018
@version undefined

@type function
/*/
Function OFIA070()
Local lVAI_APRCON := ( VAI->(FieldPos("VAI_APRCON")) <> 0 ) // Usuario Aprova Conferencia? 
Private nCodSB1 := TamSx3("B1_CODBAR")[1]
Private cCodSB1 := space(nCodSB1)
Private nTamCol := VTMaxCol() // Qtde maxima de Colunas no Display do Coletor
Private nTamLin := VTMaxRow() // Qtde maxima de Linhas no Display do Coletor
Private nPosOpc := 1 // Posicao no Menu de Opcoes
Private aVM6    := {} // Itens da Conferencia de Saida - Orcamento
Private lMostraQtd := ( GetNewPar("MV_MIL0046","S") == "S" ) // Mostra a Qtde do Orcamento ( VS3_QTDITE )
Private lVerGrupo  := ( GetNewPar("MV_MIL0119","2") == "2" ) // COLETOR DE DADOS NA CONF.DE ITENS - VISUALIZA: 1 = CODIGO DO ITEM / 2 = GRUPO + CODIGO DO ITEM
Private cOrcSelec  := space(nTamCol)
//
VAI->(dbSetOrder(4))
VAI->(MsSeek(xFilial("VAI")+__cUserID)) // Posiciona no VAI do usuario logado
If lVAI_APRCON .and. VAI->VAI_APRCON == "1" // Aprovacao
	VtBeep(3) // 3 Beep ERRO
	VTAlert(STR0026,STR0002) // Usuario Aprovador, opcao nao disponivel no coletor. / Atencao
	Return
EndIf
//
OA0700011_TelaOrcamentos(.t.) // Escolher qual Orcamento sera conferido
//
Return

/*/{Protheus.doc} OA0700011_TelaOrcamentos
Escolher qual Orcamento sera conferido

@author Andre Luis Almeida
@since 01/10/2018
@version undefined

@type function
/*/
Static Function OA0700011_TelaOrcamentos(lPergOrc) // Escolher qual Orcamento sera conferido
Local cJaConf  := ""
Local nPos     := 0
Local aSize    := {nTamCol}
Local aColunas := {STR0001} // Confer. Orcamento
Local aLinhas  := {}
Local nTamOrc  := TamSX3("VS1_NUMORC")[1]
Local cCodVM5  := ""
Local cQuery   := ""
Local cQAlVS1  := "SQLVS1"
Local cQAlVM6  := "SQLVM6"
Local cNroOrc  := space(nTamOrc)
Local cFaseConf := Alltrim(GetNewPar("MV_MIL0095","4"))
Local lVS1PRISEP := VS1->(ColumnPos("VS1_PRISEP")) > 0
Default lPergOrc := .f.
//
While .t.
	//
	aLinhas  := {}
	//
	If lPergOrc
		cNroOrc := OA0700111_QualOrcamento(nTamOrc)
		If cNroOrc == "ESC"
			Exit
		EndIf
	EndIf
	cQuery := "SELECT VS1.VS1_FILIAL , VS1.VS1_NUMORC , VS1.VS1_NCLIFT , VS1.VS1_TIPORC , VS1.VS1_FILDES , VM5.VM5_STATUS "
	If lVS1PRISEP // Prioridade Separacao do Orcamento 
		cQuery += ", CASE "
		cQuery += "    WHEN VS1.VS1_PRISEP = ' ' THEN 'ZZ' "
		cQuery += "    ELSE VS1.VS1_PRISEP "
		cQuery += "  END PRIORIDADE "
	EndIf
	cQuery += "  FROM "+RetSQLName("VS1")+" VS1 "
	cQuery += "  LEFT JOIN "+RetSqlName("VM5")+" VM5"
	cQuery += "       ON  VM5.VM5_FILIAL='"+xFilial("VM5")+"'"
	cQuery += "       AND VM5.VM5_NUMORC=VS1.VS1_NUMORC"
	cQuery += "       AND VM5.D_E_L_E_T_=' '"
	cQuery += " WHERE VS1.VS1_FILIAL = '"+xFilial("VS1")+"'"
	If !Empty(cNroOrc)
		cQuery += " AND VS1.VS1_NUMORC = '"+cNroOrc+"'"
	EndIf
	cQuery += "   AND VS1.VS1_STATUS = '"+cFaseConf+"'"
	cQuery += "   AND ("
	cQuery += "             VS1.VS1_STARES IN ('1','2')"
	cQuery += "          OR ( VS1.VS1_STARES NOT IN ('1','2') AND VS1.VS1_DATVAL >= '"+dtos(dDatabase)+"' )"
	cQuery += "          OR VS1.VS1_TIPORC = '3'"
	cQuery += "       )" 
	cQuery += "   AND VS1.D_E_L_E_T_ = ' '"
	cQuery += "   AND ( VM5.VM5_STATUS IS NULL OR VM5.VM5_STATUS IN ('1','2') ) " // Nao encontrado VM5 ou Status igual a Pendente ou Conferido Parcialmente
	cQuery += " ORDER BY "
	If lVS1PRISEP // Prioridade Separacao do Orcamento 
		cQuery += "PRIORIDADE , " // Ordem por Prioridade
	EndIf
	cQuery += "VS1.VS1_FILIAL , VS1.VS1_NUMORC"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVS1 , .F., .T. )
	While !( cQAlVS1 )->( Eof() )
		//
		cJaConf := IIf(( cQAlVS1 )->( VM5_STATUS )=="2","*"," ") // Conferido Parcialmente
		cJaConf += IIf(lVS1PRISEP,( cQAlVS1 )->( PRIORIDADE )+"-","   ") // Mostrar a Prioridade de Separacao antes do Nro do Orcamento
		//
		If ( cQAlVS1 )->( VS1_TIPORC ) == "3" // Transferencia
			aAdd(aLinhas,{ left(cJaConf+( cQAlVS1 )->( VS1_NUMORC )+" T "+Alltrim(( cQAlVS1 )->( VS1_FILDES ))+" "+( cQAlVS1 )->( VS1_NCLIFT ),nTamCol) })
		Else // Balcao / Oficina
			aAdd(aLinhas,{ left(cJaConf+( cQAlVS1 )->( VS1_NUMORC )+" "+IIf(( cQAlVS1 )->( VS1_TIPORC )=="1","B","O")+" "+( cQAlVS1 )->( VS1_NCLIFT ),nTamCol) })
		EndIf
		//
		( cQAlVS1 )->( DbSkip() )
	EndDo
	( cQAlVS1 )->( DbCloseArea() )
	DbSelectArea("VS1")
	OA0700061_LimpaTelaColetor()
	If len(aLinhas) > 0
		If len(aLinhas) > 1 .or. Empty(cNroOrc)
			nPos := VTaBrowse(0,0,nTamLin,nTamCol,aColunas,aLinhas,aSize,,1) // Lista os Orcamentos
		Else
			nPos := 1
		EndIf
		If nPos > 0
			cOrcSelec := substr(aLinhas[nPos,1]+" ",5,nTamCol) // Mostra o Orcamento Selecionado
			DbSelectArea("VS1")
			DbSetOrder(1)
			If DbSeek(xFilial("VS1")+substr(aLinhas[nPos,1],5,nTamOrc))
				//
				If ExistBlock("OA070SEL")
					If !ExecBlock("OA070SEL",.f.,.f.,{ VS1->VS1_NUMORC }) // Pode selecionar o Orçamento ?
						lPergOrc := !Empty(cNroOrc)
						Loop
					EndIf
				EndIf
				//
				If ExistFunc("OA3610011_Tempo_Total_Conferencia_Saida_Orcamento")
					OA3610011_Tempo_Total_Conferencia_Saida_Orcamento( 1 , VS1->VS1_NUMORC ) // 1=Iniciar o Tempo Total da Conferencia de Saida caso não exista o registro
				EndIf
				//
				DbSelectArea("VS1")
				If !SimpleLock() // No coletor utilizar SimpleLock ao inves de SoftLock
					//
					VtAlert(STR0027,STR0002) // Orcamento encontra-se Bloqueado por outro usuario! / Atencao
					//
				Else
					//
					aVM6 := {} // Limpar Itens da Conferencia de Saida - Orcamento
					//
					cCodVM5 := OX0020071_ExisteConferencia( VS1->VS1_NUMORC , .f. ) // Verifica se existe o VM5
					If Empty(cCodVM5)
						cCodVM5 := OX0020041_GravaRegistroConferencia( VS1->VS1_NUMORC , "2" ) // Criar VM5/VM6
					EndIf
					VM5->(DbSeek(xfilial("VM5") + cCodVM5 ) )
					//
					cQuery := "SELECT VM6.VM6_QTORIG ,"
					cQuery += "       VM6.VM6_QTCONF ,"
					cQuery += "       VM6.R_E_C_N_O_ AS RECVM6 ,"
					cQuery += "       SB1.R_E_C_N_O_ AS RECSB1 ,"
					cQuery += "       VS3.R_E_C_N_O_ AS RECVS3  "
					cQuery += "  FROM "+RetSQLName("VM6")+" VM6 "
					cQuery += "  JOIN "+RetSQLName("SB1")+" SB1 ON ( SB1.B1_FILIAL = '"+xFilial("SB1")+"' AND SB1.B1_COD = VM6.VM6_COD AND SB1.D_E_L_E_T_ = ' ' ) "
					cQuery += "  JOIN "+RetSQLName("VS3")+" VS3 ON ( VS3.VS3_FILIAL = '"+VS1->VS1_FILIAL+"' AND VS3.VS3_NUMORC = '"+VS1->VS1_NUMORC+"' AND VS3.VS3_SQCONF = VM6.VM6_SEQUEN AND VS3.D_E_L_E_T_ = ' ' ) "
					cQuery += " WHERE VM6.VM6_FILIAL = '"+xFilial("VM6")+"'"
					cQuery += "   AND VM6.VM6_CODVM5 = '"+cCodVM5+"'"
					cQuery += "   AND VM6.D_E_L_E_T_ = ' '"
					cQuery += " ORDER BY "+IIf(lVerGrupo,"SB1.B1_GRUPO , ","")+"SB1.B1_CODITE"
					dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVM6 , .F., .T. )
					While !( cQAlVM6 )->( Eof() )
						SB1->(DbGoTo( ( cQAlVM6 )->( RECSB1 ) ))
						SB5->(DbSetOrder(1))
						SB5->(DbSeek( xFilial("SB5")+SB1->B1_COD))
						aAdd(aVM6,{	SB1->B1_GRUPO  ,;								// 1
									SB1->B1_CODITE ,;								// 2
									SB1->B1_DESC   ,;								// 3
									FM_PRODSBZ(SB1->B1_COD,"SB5->B5_LOCALI2") ,;	// 4
									( cQAlVM6 )->( VM6_QTORIG ) ,;					// 5
									( cQAlVM6 )->( VM6_QTCONF ) ,;					// 6
									( cQAlVM6 )->( RECVM6 )     ,;					// 7
									( cQAlVM6 )->( RECSB1 )     ,;					// 8
									( cQAlVM6 )->( RECVS3 )     })					// 9
						( cQAlVM6 )->( DbSkip() )
					EndDo
					( cQAlVM6 )->( DbCloseArea() )
					DbSelectArea("VS1")
					OA0700071_TelaMenuOpcoes() // Menu de Opcoes
					//
					VS1->(MsUnlock()) // Retirar SimpleLock do VS1
					//
				EndIf
			EndIf
			lPergOrc := !Empty(cNroOrc)
		Else
			lPergOrc := .t.
		EndIf
	Else
		VtBeep(3) // 3 Beep ERRO
		If !Empty(cNroOrc)	
			VTAlert(STR0023,STR0002) // Orcamento nao encontrado! / Atencao
			lPergOrc := .t.
		Else
			VTAlert(STR0003,STR0002) // Nao existem Orcamentos em Fase de Conferencia. / Atencao 
			Exit
		EndIf
	EndIf
	//
EndDo
//
Return

/*/{Protheus.doc} OA0700021_TelaItemBipar
Tela para Bipar todos os Itens do Orcamento ( Item a Item  ou  Item Especifico )

@author Andre Luis Almeida
@since 01/10/2018
@version undefined

@type function
/*/
Static Function OA0700021_TelaItemBipar(nPosIte)
Local lPergFinal := .f. // Pergunta se Finaliza ?
Local lPulaItem  := .t.
Local nCntFor    := 0
Local nPosIni    := 1
Default nPosIte  := 0
If nPosIte > 0
	nPosIni := nPosIte // Apenas um Item especifico - Posicao FIXA
EndIf
For nCntFor := nPosIni to len(aVM6)
	cCodSB1 := space(nCodSB1)
	OA0700061_LimpaTelaColetor()
	@ 00, 00 VTSay PadR(aVM6[nCntFor,1], nTamCol)
	@ 01, 00 VTSay PadR(aVM6[nCntFor,2], nTamCol)
	@ 02, 00 VTSay PadR(aVM6[nCntFor,3], nTamCol)
	@ 03, 00 VTSay PadR(aVM6[nCntFor,4], nTamCol)
	if lMostraQtd // Mostra a Qtde do Orcamento
		@ 04, 00 VTSay PadR(STR0014+": "+Alltrim(Transform(aVM6[nCntFor,5],VS3->(X3PICTURE("VS3_QTDITE")))), nTamCol) // Qtd.
		@ 05, 00 VTSay repl("-", nTamCol)
		@ 06, 00 VTSay PadR(STR0015, nTamCol) // Bipar Cod.Barras
		@ 07, 00 VTGet cCodSB1 Valid OA0700031_PosicionaSB1comCODBAR(.t.,nCntFor)
	Else
		@ 04, 00 VTSay repl("-", nTamCol)
		@ 05, 00 VTSay PadR(STR0015, nTamCol) // Bipar Cod.Barras
		@ 06, 00 VTGet cCodSB1 Valid OA0700031_PosicionaSB1comCODBAR(.t.,nCntFor)
	EndIf
	VTRead
	If VTLastKey() == 27 // ESC
		Exit
	EndIf
	lPulaItem := .t.
	If Empty(cCodSB1)
		lPulaItem := OA0700041_SomaQTD( nCntFor , .t. , 0 )
	ElseIf "["+Alltrim(cCodSB1)+"]" <> "[0]"
		If aVM6[nCntFor,5] <> aVM6[nCntFor,6]
			lPulaItem := .f.
		EndIf
	EndIf
	If lPulaItem
		If nPosIte > 0 // Apenas um Item especifico
			Exit
		EndIf
	Else
		nCntFor-- // Para manter no mesmo Item
	EndIf
Next
If nPosIte == 0 // A opção foi fazer para TODOS os Itens ?
	If lPulaItem // Pulou o Item ?
		If nCntFor > len(aVM6) // É o ultimo Item ?
			lPergFinal := .t. // Pergunta se Finaliza Conferencia
		EndIf
	EndIf
EndIf
Return lPergFinal 

/*/{Protheus.doc} OA0700031_PosicionaSB1comCODBAR
Valida se o Item existe no SB1/Orcamento
Caso exista, verifica a quantidade atraves do Codigo de Barras (EAN13/EAN14/EAN128) e SOMA na Digitacao

@author Andre Luis Almeida
@since 01/10/2018
@version undefined
@return lRet , logico, Indica se o Item existe no SB1/Orcamento

@type function
/*/
Static Function OA0700031_PosicionaSB1comCODBAR(lAtuQtd,nLinha) // Posicionar no SB1 com Codigo de Barras e Verificar se o Item esta no Orcamento
Local lRet      := .t.
Local nQtdSomar := 1
Local aProduto  := {}
Local oPeca     := DMS_Peca():New()
Default lAtuQtd   := .t.
Default nLinha := 1
If !Empty(cCodSB1) .and. "["+Alltrim(cCodSB1)+"]" <> "[0]"
	//
	aProduto := oPeca:LeCodBarras(cCodSB1) // Leitura do Codigo de Barras
	//
	If Len(aProduto) > 0
		DbSelectArea("SB1")
		DbSetOrder(1)
		If !Empty(aProduto[1]) .and. DbSeek(xFilial("SB1")+aProduto[1])
			If lAtuQtd
				If "["+SB1->B1_GRUPO+SB1->B1_CODITE+"]" <> "["+aVM6[nLinha,1]+aVM6[nLinha,2]+"]"
					cCodSB1 := space(nCodSB1)
					VTGetRefresh("cCodSB1")
					lRet := .f.
					VtBeep(3) // 3 Beep ERRO
					VTAlert(STR0016,STR0002) // Item nao corresponde ao selecionado. / Atencao
				Else
					lRet := OA0700041_SomaQTD( nLinha , .f. , nQtdSomar ) // SOMAR QTDE
				EndIf
			Else
				If aScan(aVM6, {|x| x[8] == SB1->(RecNo()) }) == 0 // Se NAO posicionar no Item correspondente
					cCodSB1 := space(nCodSB1)
					VTGetRefresh("cCodSB1")
					lRet := .f.
					VtBeep(3) // 3 Beep ERRO
					VTAlert(STR0017,STR0002) // Item nao encontrado no Orcamento. / Atencao
				EndIf
			EndIf
		Else
			cCodSB1 := space(nCodSB1)
			VTGetRefresh("cCodSB1")
			lRet := .f.
			VtBeep(3) // 3 Beep ERRO
			VTAlert(STR0012,STR0002) // Item nao encontrado no Cadastro de Produtos. / Atencao
		EndIf
	Else
		cCodSB1 := space(nCodSB1)
		VTGetRefresh("cCodSB1")
		lRet := .f.
		VtBeep(3) // 3 Beep ERRO
		VTAlert(STR0012,STR0002) // Item nao encontrado no Cadastro de Produtos. / Atencao
	EndIf
EndIf
FreeObj(oPeca)
Return lRet

/*/{Protheus.doc} OA0700041_SomaQTD
Soma e chama funcao para preencher Quantidade na Conferencia do Orcamento

@author Andre Luis Almeida
@since 01/10/2018
@version undefined
@param nLinha, numerico, Linha no Vetor do VS3 ( itens do Orcamento )
@param lTelaQtd, logico, Abre Tela para o usuario preencher a Quantidade Digitada?
@param nQtdSomar, numerico, Quantidade a Somar na Digitacao
@return lRet, logico, Indica se a Digitacao foi OK ou foi dado ESC

@type function
/*/
Static Function OA0700041_SomaQTD( nLinha , lTelaQtd , nQtdSomar ) // Somar Qtde
Local nQtd := 0
Local lRet := .t.
nQtd := aVM6[nLinha,6]
If lTelaQtd // Tela Qtde
	OA0700061_LimpaTelaColetor()
	@ 00, 00 VTSay PadR(aVM6[nLinha,1], nTamCol)
	@ 01, 00 VTSay PadR(aVM6[nLinha,2], nTamCol)
	@ 02, 00 VTSay PadR(aVM6[nLinha,3], nTamCol)
	@ 03, 00 VTSay PadR(aVM6[nLinha,4], nTamCol)
	if lMostraQtd // Mostra a Qtde do Orcamento
		@ 04, 00 VTSay PadR(STR0014+": "+Alltrim(Transform(aVM6[nLinha,5],VS3->(X3PICTURE("VS3_QTDITE")))), nTamCol) // Qtd.
		@ 05, 00 VTSay repl("-", nTamCol)
		@ 06, 00 VTSay PadR(STR0013, nTamCol) // Quantidade?
		@ 07, 00 VTGet nQtd Valid nQtd>=0
	Else
		@ 04, 00 VTSay repl("-", nTamCol)
		@ 05, 00 VTSay PadR(STR0013, nTamCol) // Quantidade?
		@ 06, 00 VTGet nQtd Valid nQtd>=0
	EndIf
	VTRead
	If VTLastKey() == 27 // ESC
		lRet := .f.
	EndIf
EndIf
If lRet .and. aVM6[nLinha,7] > 0
	//
	If (( nQtd+nQtdSomar ) > aVM6[nLinha,5] ) // Nao deixar digitar/conferir mais que a quantidade do Orcamento
		VtBeep(3) // 3 Beep ERRO
		VTAlert(STR0028,STR0002) // Quantidade desejada maior que a Quantidade do Orcamento. Impossivel continuar. / Atencao
		lRet := .f.
	Else
		aVM6[nLinha,6] := nQtd+nQtdSomar // Gravar Qtde Conferida
		OX0020141_GravaQtdConferida( aVM6[nLinha,7] , aVM6[nLinha,6] , "2" , aVM6[nLinha,9] )
		OX0020061_StatusConferencia( VM5->VM5_CODIGO , "2" , "2" )
		If !lTelaQtd
			VtBeep(1) // 1 Beep OK
		EndIf
	EndIf
	//
EndIf
Return lRet

/*/{Protheus.doc} OA0700061_LimpaTelaColetor
Limpa a Tela do Coletor 

@author Andre Luis Almeida
@since 01/10/2018
@version undefined

@type function
/*/
Static Function OA0700061_LimpaTelaColetor() // Limpa Tela
Local ni := 0
VTCLEARBUFFER()
VTClear() // Limpa Tela
For ni := 1 to nTamLin
	@ ni, 00 VTSay repl(" ",nTamCol)
Next
Return

/*/{Protheus.doc} OA0700071_TelaMenuOpcoes
Menu de Opcoes

@author Andre Luis Almeida
@since 29/11/2018
@version undefined

@type function
/*/
Static Function OA0700071_TelaMenuOpcoes() // Menu de Opcoes
Local aLinhas  := {}
Local aSize    := {nTamCol}
Local aColunas := { cOrcSelec }
Local lVS1OBSCON := VS1->(ColumnPos("VS1_OBSCON")) > 0
//
aAdd(aLinhas,{ STR0019 }) // Todos os Itens
aAdd(aLinhas,{ STR0020 }) // Selecionar Item
aAdd(aLinhas,{ STR0024 }) // Itens com Diverg
aAdd(aLinhas,{ STR0006 }) // Finaliza Confer. ?
aAdd(aLinhas,{ STR0030 }) // Dados do Orcamento
//
If lVS1OBSCON .and. !Empty(VS1->VS1_OBSCON)
	aAdd(aLinhas,{ STR0025 }) // Obs.para Conferente
	VtAlert(VS1->VS1_OBSCON,STR0025) // Obs.para Conferente
EndIf
//
While .t.
	//
	If !OA0700131_VerificaStatus() // Verifica o Status se pode Continuar na Conferencia VM5
		Exit
	EndIf
	//
	OA0700061_LimpaTelaColetor()
	@ 00, 00 VTSay PadR(STR0001, nTamCol) // Confer. Orcamento
	nPosOpc := VTaBrowse(1,0,nTamLin,nTamCol,aColunas,aLinhas,aSize,,nPosOpc) // Lista os Itens
	If nPosOpc > 0
		Do Case
			Case nPosOpc == 1 // Todos os Itens
				If lVerGrupo
					aSort(aVM6,,,{|x,y| x[4] + x[1] + x[2] < y[4] + y[1] + y[2] }) // Ordem: Localizacao + Grupo + Codigo do Item
				Else
					aSort(aVM6,,,{|x,y| x[4] + x[2]        < y[4] + y[2]        }) // Ordem: Localizacao + Codigo do Item
				EndIf
				If OA0700021_TelaItemBipar(0) // Bipar todos os Itens do Orcamento ( Item a Item )
					If OA0700081_FinalizaConferencia() // Finaliza Conferencia
						Exit
					EndIf
				EndIf
			Case nPosOpc == 2 // Selecionar Item
				If lVerGrupo
					aSort(aVM6,,,{|x,y| x[1] + x[2] + x[4] < y[1] + y[2] + y[4] }) // Ordem: Grupo + Codigo do Item + Localizacao
				Else
					aSort(aVM6,,,{|x,y| x[2] + x[4]        < y[2] + y[4]        }) // Ordem: Codigo do Item + Localizacao
				EndIf
				OA0700091_TelaQualItemConferir() // Escolher qual Item que sera Conferido
			Case nPosOpc == 3 // Itens com Diverg
				If lVerGrupo
					aSort(aVM6,,,{|x,y| x[4] + x[1] + x[2] < y[4] + y[1] + y[2] }) // Ordem: Localizacao + Grupo + Codigo do Item
				Else
					aSort(aVM6,,,{|x,y| x[4] + x[2]        < y[4] + y[2]        }) // Ordem: Localizacao + Codigo do Item
				EndIf
				OA0700121_ListaItensDivergentes()
			Case nPosOpc == 4 // Finaliza Confer. ?
				If OA0700081_FinalizaConferencia() // Finaliza Conferencia
					Exit
				EndIf
			Case nPosOpc == 5 // Mostra Dados do Orcamento
				OA0700141_DadosOrcamento() // Dados do Orcamento
			Case nPosOpc == 6 // Mostra a Obs. para o Conferente
				VtAlert(VS1->VS1_OBSCON,STR0025) // Obs.para Conferente
		EndCase
	Else
		nPosOpc := 1
		Exit
	EndIf
	//
EndDo
//
Return

/*/{Protheus.doc} OA0700081_FinalizaConferencia
Finaliza Conferencia

@author Andre Luis Almeida
@since 30/11/2018
@version undefined

@type function
/*/
Static Function OA0700081_FinalizaConferencia() // Finaliza Conferencia
Local lRet := .f.
OA0700061_LimpaTelaColetor()
If VtYesNo(STR0008,STR0007,.t.) // Deseja Finalizar a Conferencia dos Itens do Orcamento? / Finalizar
	lRet := .t.
	OX0020131_VerificaDivergencias( VM5->VM5_CODIGO , "2" )
	If VM5->VM5_DIVERG == "1" // Tem Divergencia
		If !VtYesNo(STR0029,STR0007,.t.) // Ha itens com divergencia. Deseja continuar? / Atencao
			lRet := .f.
		EndIf
	EndIf
	If lRet
		OX0020061_StatusConferencia( VM5->VM5_CODIGO , "3" , "2" )
		If VM5->VM5_DIVERG == "0" // NAO tem Divergencia - Aprova Automaticamente
			If OX0020161_LiberaItensConferidos( "2" ) // Finaliza a Conferencia - chamada pelo 2=Coletor de Dados
				OX0020121_GravaConbar( VM5->VM5_NUMORC )
				OX0020061_StatusConferencia( VM5->VM5_CODIGO , "4" , "2" )
				If ExistFunc("OA3610011_Tempo_Total_Conferencia_Saida_Orcamento")
					OA3610011_Tempo_Total_Conferencia_Saida_Orcamento( 0 , VM5->VM5_NUMORC ) // 0=Finalizar o Tempo Total da Conferencia Saida Orcamento
				EndIf
			Else
				lRet := .f.
			EndIf
		Else
			// Ponto de entrada ao Finalizar a Conferencia
			if ExistBlock("OXX002FIN")
				ExecBlock("OXX002FIN",.f.,.f.)
			Endif
		EndIf
	EndIf
	If lRet
		//
		VS1->(MsUnlock()) // Retirar SimpleLock do VS1
		//
		VTAlert(STR0009+CHR(13)+CHR(10)+;
				VM5->VM5_NUMORC+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
				STR0010,STR0002) // Orcamento / Conferencia Finalizada. / Atencao
	EndIf
EndIf
Return lRet

/*/{Protheus.doc} OA0700091_TelaQualItemConferir
Escolher qual Item que sera Conferido

@author Andre Luis Almeida
@since 03/12/2018
@version undefined

@type function
/*/
Static Function OA0700091_TelaQualItemConferir() // Escolher qual Item que sera Conferido
Local nPosIte := 0
//
While .t.
	//
	If !OA0700131_VerificaStatus() // Verifica o Status se pode Continuar na Conferencia VM5
		Exit
	EndIf
	//
	cCodSB1 := space(nCodSB1)
	OA0700061_LimpaTelaColetor()
	//
	@ 00, 00 VTSay PadR(STR0001, nTamCol) // Confer. Orcamento
	@ 01, 00 VTSay cOrcSelec
	@ 02, 00 VTSay repl("-", nTamCol)
	@ 03, 00 VTSay PadR(STR0004, nTamCol) // Qual Item?
	@ 04, 00 VTGet cCodSB1 Valid OA0700031_PosicionaSB1comCODBAR(.f.,1)
	VTRead
	//
	If VTLastKey() <> 27 // Diferente de ESC
		If Empty(cCodSB1)
			nPosIte := OA0700101_TelaTodosItensdoOrcamento() // Mostrar todos os Itens do Orcamento
		ElseIf "["+Alltrim(cCodSB1)+"]" <> "[0]"
			nPosIte := aScan(aVM6, {|x| x[8] == SB1->(RecNo()) }) // Posiciona no Item correspondente
		EndIf
		If nPosIte > 0
			OA0700021_TelaItemBipar(nPosIte) // Bipar todos os Itens do Orcamento ( Item especifico )
		EndIf
		If "["+Alltrim(cCodSB1)+"]" == "[0]"
			Exit
		EndIf
	Else
		Exit
	EndIf
	//
EndDo
//
Return

/*/{Protheus.doc} OA0700101_TelaTodosItensdoOrcamento
Mostrar todos os Itens do Orcamento

@author Andre Luis Almeida
@since 03/12/2018
@version undefined

@type function
/*/
Static Function OA0700101_TelaTodosItensdoOrcamento() // Mostrar todos os Itens do Orcamento
Local nCntFor  := 0
Local nPosIte  := 0
Local cJaConf  := ""
Local aSize    := {nTamCol}
Local aColunas := {STR0005} // Selecionar Item
Local aLinhas  := {}
For nCntFor := 1 to len(aVM6)
	cJaConf := IIf( aVM6[nCntFor,6] > 0 , "*" , " " ) // Verifica se o Item ja foi Conferido
	aAdd(aLinhas,{ cJaConf + IIf(lVerGrupo,aVM6[nCntFor,1],"") + aVM6[nCntFor,2] })
Next
OA0700061_LimpaTelaColetor()
nPosIte := VTaBrowse(0,0,nTamLin,nTamCol,aColunas,aLinhas,aSize,,1) // Lista os Itens
Return nPosIte


/*/{Protheus.doc} OA0700111_QualOrcamento
Tela Pergunta o Nro do Orcamento

@author Andre Luis Almeida
@since 23/03/2019
@version undefined
@return cRet, caracter, Nro+Serie da NF

@type function
/*/
Static Function OA0700111_QualOrcamento(nTam)
Local cRet := space(nTam)
OA0700061_LimpaTelaColetor()
@ 00, 00 VTSay PadR(STR0001, nTamCol) // Confer. Orcamento
@ 01, 00 VTSay repl("-", nTamCol)
@ 02, 00 VTSay PadR(STR0021, nTamCol) // Digite
@ 04, 00 VTSay PadR(STR0022, nTamCol) // Nro.Orcamento
@ 05, 00 VTGet cRet Picture "@!"
VTRead
If VTLastKey() == 27 // ESC
	cRet := "ESC"
EndIf
Return cRet

/*/{Protheus.doc} OA0700121_ListaItensDivergentes
Lista os Itens com Divergencia

@author Andre Luis Almeida
@since 26/08/2019
@version undefined

@type function
/*/
Static Function OA0700121_ListaItensDivergentes() // Lista Itens com Divergencia
Local aSize    := {nTamCol}
Local aColunas := {STR0024} // Itens com Diverg
Local aLinhas := {}
Local aLinDiv := {}
Local nCntFor := 0
Local nPosIte := 0
Local cJaConf := ""
//
While .t.
	//
	If !OA0700131_VerificaStatus() // Verifica o Status se pode Continuar na Conferencia VM5
		Exit
	EndIf
	//
	aLinhas := {}
	aLinDiv := {}
	//
	For nCntFor := 1 to len(aVM6)
		If aVM6[nCntFor,5] <> aVM6[nCntFor,6]
			cJaConf := IIf( aVM6[nCntFor,6] > 0 , "*" , " " ) // Verifica se o Item ja foi Conferido
			aAdd(aLinhas,{ cJaConf + IIf(lVerGrupo,aVM6[nCntFor,1],"") + aVM6[nCntFor,2] })
			aAdd(aLinDiv,nCntFor) // Linha relacionada ao vetor aVM6
		EndIf
	Next
	OA0700061_LimpaTelaColetor()
	If Len(aLinhas) > 0
		aAdd(aLinhas,{ repl("-",nTamCol) })
		aAdd(aLinhas,{ STR0006 }) // Finaliza Confer. ?
		nPosIte := VTaBrowse(0,0,nTamLin,nTamCol,aColunas,aLinhas,aSize,,1) // Lista os Itens
		If nPosIte > 0
			If nPosIte == len(aLinhas) // Finaliza Confer. ?
				If OA0700081_FinalizaConferencia() // Finaliza Conferencia
					Exit
				EndIf
			ElseIf nPosIte <> ( len(aLinhas) -1 ) // Diferente de tracos - Item a Item
				OA0700021_TelaItemBipar(aLinDiv[nPosIte]) // Bipar todos os Itens do Orcamento ( Item especifico )
			EndIf
		Else
			Exit
		EndIf
	Else
		VTAlert(STR0011,STR0024) // Nenhum Item encontrado! / Itens com Diverg
		Exit
	EndIf
	//
EndDo
//
Return

/*/{Protheus.doc} OA0700131_VerificaStatus
Verifica o Status se pode Continuar na Conferencia VM5

@author Andre Luis Almeida
@since 19/12/2019
@version undefined

@type function
/*/
Static Function OA0700131_VerificaStatus() // Verifica o Status se pode Continuar na Conferencia VM5
Local lRet := .f.
If VM5->VM5_STATUS $ "1/2" // Status igual a Pendente ou Conferido Parcialmente
	lRet := .t.
EndIf
Return lRet

/*/{Protheus.doc} OA0700141_DadosOrcamento
Mostra os Dados do Orcamento

@author Andre Luis Almeida
@since 06/09/2021
/*/
Static Function OA0700141_DadosOrcamento() // Mostra os Dados do Orcamento
Local cTit := ""
Local cCod := ""
Local cNom := ""
Local cDoc := ""
Local cAux := ""
Local cOk  := ">"
Local nLin := 0
Local nCnt := 0
If VS1->VS1_TIPORC == "3" // Transferencia
	cTit := STR0031 // Transferencia
	cCod := STR0032+" "+Alltrim(VS1->VS1_FILDES) // Filial
	cNom := Alltrim(VS1->VS1_NCLIFT)
Else
	If VS1->VS1_TIPORC == "1" // Balcao
		cTit := STR0033 // Orcamento Balcao
	Else // Oficina
		cTit := STR0034 // Orcamento Oficina
	EndIf
	cCod := STR0035+" "+VS1->VS1_CLIFAT+"-"+ VS1->VS1_LOJA // Cliente
	cNom := Alltrim(VS1->VS1_NCLIFT)
	cDoc := Alltrim(FM_SQL("SELECT A1_CGC FROM "+RetSQLName("SA1")+" WHERE A1_FILIAL='"+xFilial("SA1")+"' AND A1_COD='"+VS1->VS1_CLIFAT+"' AND A1_LOJA='"+VS1->VS1_LOJA+"' AND D_E_L_E_T_=' '"))
	If len(cDoc) > 11
		cDoc := Transform(cDoc,"@R 99.999.999/9999-99") //CNPJ
	Else
		cDoc := Transform(cDoc,"@R 999.999.999-99") // CPF
	EndIf
EndIf
//
OA0700061_LimpaTelaColetor()
//
@ nLin++, 00 VTSay PadR(cTit,nTamCol)
@ nLin++, 00 VTSay PadR(VS1->VS1_NUMORC+" "+Transform(VS1->VS1_DATORC,"@D"),nTamCol)
//
@ nLin++, 00 VTSay PadR(cCod,nTamCol)
For nCnt := 0 to 3
	cAux := substr(cNom,(nTamCol*nCnt)+1,nTamCol)
	If !Empty(cAux)
		@ nLin++, 00 VTSay PadR(cAux,nTamCol)
	EndIf
Next
@ nLin++, 00 VTSay PadR(cDoc,nTamCol-1)
//
@ 07, (nTamCol-1) VTGet cOk Picture "@!"
VTRead
//
Return