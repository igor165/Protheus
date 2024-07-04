#INCLUDE "FIVEWIN.CH"
#INCLUDE "APVT100.CH"
#INCLUDE "OFIA220.CH"

/*/{Protheus.doc} OFIA220
Coletor/Leitor VT100 - Conferencia de Oficina

@author Andre Luis Almeida
@since 07/11/2019
@version undefined

@type function
/*/
Function OFIA220()
Local lVAI_APRCON := ( VAI->(FieldPos("VAI_APRCON")) <> 0 ) // Usuario Aprova Conferencia? 
Private nCodSB1 := TamSx3("B1_CODBAR")[1]
Private cCodSB1 := space(nCodSB1)
Private nLinT1  := 1 // Linha posicionada na Tela 1
Private nLinT3  := 1 // Linha posicionada na Tela 3
Private nTamCol := VTMaxCol() // Qtde maxima de Colunas no Display do Coletor
Private nTamLin := VTMaxRow() // Qtde maxima de Linhas no Display do Coletor
Private nPosOpc := 1 // Posicao no Menu de Opcoes
Private aVM4    := {} // VM4 da OS selecionada - Itens
Private lMostraSol := ( GetNewPar("MV_MIL0046","S") == "S" ) // Mostra a Qtde da Solicitacao ( VM4_QTSOLI )
Private lVerGrupo := ( GetNewPar("MV_MIL0119","2") == "2" ) // COLETOR DE DADOS NA CONF.DE ITENS - VISUALIZA: 1 = CODIGO DO ITEM / 2 = GRUPO + CODIGO DO ITEM
//
VAI->(dbSetOrder(4))
VAI->(MsSeek(xFilial("VAI")+__cUserID)) // Posiciona no VAI do usuario logado
If lVAI_APRCON .and. VAI->VAI_APRCON == "1" // Aprovacao
	VtBeep(3) // 3 Beep ERRO
	VTAlert(STR0003,STR0002) // Usuario Aprovador, opcao nao disponivel no coletor. / Atencao
	Return
EndIf
//
OA2200011_TELA1(.t.) // T1 - Escolher qual Oficina sera conferida
//
Return

/*/{Protheus.doc} OA2200011_TELA1
T1 - Escolher qual OS/Solicitacao sera conferida

@author Andre Luis Almeida
@since 07/11/2019
@version undefined

@type function
/*/
Static Function OA2200011_TELA1(lPergOS) // T1 - Escolher qual OS/Solicitacao sera conferida
Local cJaConf  := ""
Local nPos     := 0
Local nTamOS   := TamSx3("VO1_NUMOSV")[1]
Local cNroOS   := space(nTamOS)
Local aSize    := {nTamCol}
Local aColunas := {STR0001} // Conferencia da OS
Local aLinhas  := {}
Local aRecVM3  := {}
Local cQuery   := ""
Local cQAlVM3  := "SQLVM3"
Local cQAlVM4  := "SQLVM4"
Local cEnder   := ""
Local lVM3PRISEP := VM3->(ColumnPos("VM3_PRISEP")) > 0
Default lPergOS := .f.
//
While .t.
	//
	aLinhas  := {}
	aRecVM3  := {}
	//
	If lPergOS
		cNroOS := OA2200071_QualOS(nTamOS)
		If cNroOS == "ESC"
			Exit
		EndIf
	EndIf
	cQuery := "SELECT VM3.VM3_NUMOSV ,"
	cQuery += "       VM3.VM3_CODIGO ,"
	cQuery += "       VM3.VM3_STATUS ,"
	cQuery += "       VM3.R_E_C_N_O_ AS RECVM3 ,"
	cQuery += "       SA1.A1_NOME "
	If lVM3PRISEP // Prioridade Separacao da OS
		cQuery += ", CASE "
		cQuery += "    WHEN VM3.VM3_PRISEP = ' ' THEN 'ZZ' "
		cQuery += "    ELSE VM3.VM3_PRISEP "
		cQuery += "  END PRIORIDADE "
	EndIf
	cQuery += "  FROM "+RetSQLName("VM3")+" VM3"
	cQuery += "  JOIN "+RetSQLName("VO1")+" VO1 ON VO1.VO1_FILIAL = '"+xFilial("VO1")+"' AND VO1.VO1_NUMOSV = VM3.VM3_NUMOSV AND VO1.D_E_L_E_T_ = ' '"
	cQuery += "  LEFT JOIN "+RetSQLName("VV1")+" VV1 ON VV1.VV1_FILIAL = '"+xFilial("VV1")+"' AND VV1.VV1_CHAINT = VO1.VO1_CHAINT AND VV1.D_E_L_E_T_ = ' '"
	cQuery += "  LEFT JOIN "+RetSQLName("SA1")+" SA1 ON SA1.A1_FILIAL = '"+xFilial("SA1")+"' AND SA1.A1_COD = VV1.VV1_PROATU AND SA1.A1_LOJA = VV1.VV1_LJPATU AND SA1.D_E_L_E_T_ = ' '"
	cQuery += " WHERE VM3.VM3_FILIAL = '"+xFilial("VM3")+"'"
	If !Empty(cNroOS)
		cQuery += " AND VM3.VM3_NUMOSV = '"+cNroOS+"'"
	EndIf
	cQuery += "   AND VM3.VM3_STATUS IN ('1','2') " // Status igual a Pendente ou Conferido Parcialmente
	cQuery += "   AND VM3.D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY "
	If lVM3PRISEP // Prioridade Separacao da OS
		cQuery += "PRIORIDADE , " // Ordem por Prioridade
	EndIf
	cQuery += "VM3.VM3_NUMOSV , VM3.VM3_CODIGO"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVM3 , .F., .T. )
	While !( cQAlVM3 )->( Eof() )
		//
		cJaConf := IIf(( cQAlVM3 )->( VM3_STATUS )=="2","*"," ") // Conferido Parcialmente
		cJaConf += IIf(lVM3PRISEP,( cQAlVM3 )->( PRIORIDADE )+"-","   ") // Mostrar a Prioridade de Separacao antes do Nro da OS
		//
		aAdd(aLinhas,{ left( cJaConf+( cQAlVM3 )->( VM3_NUMOSV )+"-"+( cQAlVM3 )->( VM3_CODIGO )+" "+( cQAlVM3 )->( A1_NOME ),nTamCol) })
		aAdd(aRecVM3,( cQAlVM3 )->( RECVM3 ))
		//
		( cQAlVM3 )->( DbSkip() )
	EndDo
	( cQAlVM3 )->( DbCloseArea() )
	DbSelectArea("VM3")
	OA2200021_LimpaTelaColetor()
	If len(aLinhas) > 0
		If nLinT1 > len(aLinhas)
			nLinT1 := 1 // Volta para o primeiro registro da Tela 1 ( OS/Solicitacoes )
		EndIf
		If len(aLinhas) > 1 .or. Empty(cNroOS)
			nPos := VTaBrowse(0,0,nTamLin,nTamCol,aColunas,aLinhas,aSize,,nLinT1) // Lista as OS/Solicitacoes
		Else
			nPos := 1
		EndIf
		If nPos > 0
			nLinT1 := nPos // Posiciona no registro da Tela 1 ( OS/Solicitacoes )
			nLinT3 := 1 // Posiciona no primeiro registro da Tela 3 ( Itens )
			If aRecVM3[nPos] > 0
				//
				DbSelectArea("VM3")
				VM3->(DbGoTo(aRecVM3[nPos]))
				//
				If ExistBlock("OA220SEL")
					If !ExecBlock("OA220SEL",.f.,.f.,{ VM3->VM3_CODIGO , VM3->VM3_NUMOSV }) // Pode selecionar a Solicitação de Peças / OS ?
						lPergOS := .t.
						Loop
					EndIf
				EndIf
				//
				If ExistFunc("OA3620011_Tempo_Total_Conferencia_Oficina")
					OA3620011_Tempo_Total_Conferencia_Oficina( 1 , VM3->VM3_CODIGO , VM3->VM3_NUMOSV ) // 1=Iniciar o Tempo Total da Conferencia de Oficina caso não exista o registro
				EndIf
				//
				If OA2120251_VerificaStatusOS( VM3->VM3_NUMOSV , "2" ) // OS NÃO esta com Status Em Aberto
					//
					DbSelectArea("VM3")
					If !SimpleLock() // No coletor utilizar SimpleLock ao inves de SoftLock
						//
						VtAlert(STR0004,STR0002) // Solicitacao de Pecas encontra-se Bloqueada por outro usuario! / Atencao
						//			
					Else
						//
						aVM4 := {} // Limpar Itens
						//
						cQuery := "SELECT SB1.B1_GRUPO   , "
						cQuery += "       SB1.B1_CODITE  , "
						cQuery += "       SB1.B1_DESC    , "
						cQuery += "       VM4.VM4_QTSOLI , "
						cQuery += "       VM4.VM4_QTCONF , "
						cQuery += "       VM4.R_E_C_N_O_ AS RECVM4 , "
						cQuery += "       SB1.R_E_C_N_O_ AS RECSB1 "
						cQuery += "  FROM "+RetSQLName("VM4")+" VM4"
						cQuery += "  JOIN "+RetSqlName("SB1")+" SB1"
						cQuery += "       ON  SB1.B1_FILIAL='"+xFilial("SB1")+"'"
						cQuery += "       AND SB1.B1_COD=VM4.VM4_COD"
						cQuery += "       AND SB1.D_E_L_E_T_=' '"
						cQuery += " WHERE VM4.VM4_FILIAL = '"+VM3->VM3_FILIAL+"'"
						cQuery += "   AND VM4.VM4_CODVM3 = '"+VM3->VM3_CODIGO+"'"
						cQuery += "   AND VM4.D_E_L_E_T_ = ' '"
						cQuery += " ORDER BY "+IIf(lVerGrupo,"SB1.B1_GRUPO , ","")+"SB1.B1_CODITE"
						dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVM4 , .F., .T. )
						While !( cQAlVM4 )->( Eof() )
							SB1->(DbGoTo( ( cQAlVM4 )->( RECSB1 ) ))
							SB5->(DbSetOrder(1))
							SB5->(DbSeek( xFilial("SB5")+SB1->B1_COD))
							If !Localiza(SB1->B1_COD)
								cEnder := FM_PRODSBZ(SB1->B1_COD,"SB5->B5_LOCALI2")
							Else
								cEnder := STR0005 // Item Enderecado
							EndIf
							aAdd(aVM4,{ ( cQAlVM4 )->( B1_GRUPO )                 ,; // 1
										( cQAlVM4 )->( B1_CODITE )                ,; // 2
										( cQAlVM4 )->( B1_DESC )                  ,; // 3
										cEnder                                    ,; // 4
										( cQAlVM4 )->( VM4_QTSOLI )               ,; // 5
										( cQAlVM4 )->( VM4_QTCONF )               ,; // 6
										( cQAlVM4 )->( RECVM4 )                   ,; // 7
										( cQAlVM4 )->( RECSB1 )                   }) // 8
							( cQAlVM4 )->( DbSkip() )
						EndDo
						( cQAlVM4 )->( DbCloseArea() )
						DbSelectArea("VM4")
						OA2200031_TelaMenuOpcoes() // Menu de Opcoes
						//
						VM3->(MsUnlock()) // Retirar SimpleLock do VM3
						//
					EndIf
					//
				EndIf
				//
			EndIf
			nLinT3 := 1 // Posiciona no primeiro registro da Tela 3 ( Itens )
			lPergOS := .t.
		Else
			lPergOS := .t.
		EndIf
	Else
		VtBeep(3) // 3 Beep ERRO
		If !Empty(cNroOS)	
			VTAlert(STR0006,STR0002) // OS nao encontrada! / Atencao
		Else
			VTAlert(STR0007,STR0002) // Nao existe OS para Conferir. / Atencao
		EndIf
		lPergOS := .t.
	EndIf
	//
EndDo
//
Return

/*/{Protheus.doc} OA2200021_LimpaTelaColetor
Limpa a Tela do Coletor 

@author Andre Luis Almeida
@since 05/11/2019
@version undefined

@type function
/*/
Static Function OA2200021_LimpaTelaColetor() // Limpa Tela
Local ni := 0
VTCLEARBUFFER()
VTClear() // Limpa Tela
For ni := 1 to nTamLin
	@ ni, 00 VTSay repl(" ",nTamCol)
Next
Return

/*/{Protheus.doc} OA2200031_TelaMenuOpcoes
Menu de Opcoes

@author Andre Luis Almeida
@since 05/11/2019
@version undefined

@type function
/*/
Static Function OA2200031_TelaMenuOpcoes() // Menu de Opcoes
Local aLinhas  := {}
Local aSize    := {nTamCol}
Local aColunas := { PadR(VM3->VM3_NUMOSV+" "+VM3->VM3_CODIGO, nTamCol) }
Local lVoltaMenu := .t.
Local lVM3OBSCON := VM3->(ColumnPos("VM3_OBSCON")) > 0
//
aAdd(aLinhas,{ STR0008 }) // Todos os Itens
aAdd(aLinhas,{ STR0009 }) // Selecionar Item
aAdd(aLinhas,{ STR0010 }) // Itens com Diverg
aAdd(aLinhas,{ STR0011 }) // Finaliza Confer. ?
//
If lVM3OBSCON .and. !Empty(VM3->VM3_OBSCON)
	aAdd(aLinhas,{ STR0031 }) // Obs.para Conferente
	VtAlert(VM3->VM3_OBSCON,STR0031) // Obs.para Conferente
EndIf
//
OA2200021_LimpaTelaColetor()
//
@ 00, 00 VTSay PadR(STR0001, nTamCol) // Confererencia OS
nPosOpc := VTaBrowse(1,0,nTamLin,nTamCol,aColunas,aLinhas,aSize,,nPosOpc) // Lista os Itens
If nPosOpc > 0
	Do Case
		Case nPosOpc == 1 // Todos os Itens
			If lVerGrupo
				aSort(aVM4,,,{|x,y| x[4] + x[1] + x[2] < y[4] + y[1] + y[2] }) // Ordem: Localizacao + Grupo + Codigo do Item
			Else
				aSort(aVM4,,,{|x,y| x[4] + x[2]        < y[4] + y[2]        }) // Ordem: Localizacao + Codigo do Item
			EndIf
			If OA2200041_TelaItemBipar(0) // Bipar todos os Itens da OS/Solicitacao ( Item a Item )
				If OA2200111_FinalizaConferencia() // Finaliza Conferencia
					lVoltaMenu := .f.
				EndIf
			EndIf		
		Case nPosOpc == 2 // Selecionar Item
			OA2200081_TelaQualItemConferir()
		Case nPosOpc == 3 // Itens com Diverg
			OA2200101_ListaItensDivergentes()
		Case nPosOpc == 4 // Finaliza Confer. ?
			If OA2200111_FinalizaConferencia() // Finaliza Conferencia
				lVoltaMenu := .f.
			EndIf
		Case nPosOpc == 5 // Mostra a Obs. para o Conferente
			VtAlert(VM3->VM3_OBSCON,STR0031) // Obs.para Conferente
	EndCase
	If lVoltaMenu
		OA2200031_TelaMenuOpcoes() // Voltar para Menu de Opcoes
	EndIf
Else
	nPosOpc := 1
EndIf
Return

/*/{Protheus.doc} OA2200041_TelaItemBipar
Tela para Bipar todos os Itens da OS/Solicitacao ( Item a Item  ou  Item Especifico )

@author Andre Luis Almeida
@since 05/11/2019
@version undefined

@type function
/*/
Static Function OA2200041_TelaItemBipar(nPosIte)
Local lPergFinal := .f. // Pergunta se Finaliza ?
Local lPulaItem  := .t.
Local nCntFor    := 0
Local nPosIni    := 1
Default nPosIte  := 0
If nPosIte > 0
	nPosIni := nPosIte // Apenas um Item especifico - Posicao FIXA
EndIf
For nCntFor := nPosIni to len(aVM4)
	cCodSB1 := space(nCodSB1)
	OA2200021_LimpaTelaColetor()
	@ 00, 00 VTSay PadR(aVM4[nCntFor,1], nTamCol)
	@ 01, 00 VTSay PadR(aVM4[nCntFor,2], nTamCol)
	@ 02, 00 VTSay PadR(aVM4[nCntFor,3], nTamCol)
	@ 03, 00 VTSay PadR(aVM4[nCntFor,4], nTamCol)
	If lMostraSol
		@ 04, 00 VTSay PadR(STR0012+": "+Alltrim(Transform(aVM4[nCntFor,5],VM4->(X3PICTURE("VM4_QTSOLI")))), nTamCol) // Qtd.
		@ 05, 00 VTSay repl("-", nTamCol)
		@ 06, 00 VTSay PadR(STR0013, nTamCol) // Bipar Cod.Barras
		@ 07, 00 VTGet cCodSB1 Valid OA2200051_PosicionaSB1comCODBAR(.t.,nCntFor)
	Else
		@ 04, 00 VTSay repl("-", nTamCol)
		@ 05, 00 VTSay PadR(STR0013, nTamCol) // Bipar Cod.Barras
		@ 06, 00 VTGet cCodSB1 Valid OA2200051_PosicionaSB1comCODBAR(.t.,nCntFor)
	EndIf
	VTRead
	If VTLastKey() == 27 // ESC
		Exit
	EndIf
	lPulaItem := .t.
	If Empty(cCodSB1)
		lPulaItem := OA2200061_SomaQTD( nCntFor , .t. , 0 )
	ElseIf "["+Alltrim(cCodSB1)+"]" <> "[0]"
		If aVM4[nCntFor,5] <> aVM4[nCntFor,6]
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
		If nCntFor > len(aVM4) // É o ultimo Item ?
			lPergFinal := .t. // Pergunta se Finaliza Conferencia
		EndIf
	EndIf
EndIf
Return lPergFinal 

/*/{Protheus.doc} OA2200051_PosicionaSB1comCODBAR
Valida se o Item existe no SB1/OS
Caso exista, verifica a quantidade atraves do Codigo de Barras (EAN13/EAN14/EAN128) e SOMA na Digitacao

@author Andre Luis Almeida
@since 05/11/2018
@version undefined
@return lRet , logico, Indica se o Item existe no SB1/OS

@type function
/*/
Static Function OA2200051_PosicionaSB1comCODBAR(lAtuQtd,nLinhaVM4) // Posicionar no SB1 com Codigo de Barras e Verificar se o Item esta na OS
Local lRet      := .t.
Local lErro     := .f.
Local cErro     := ""
Local nQtdSomar := 1
Local aProduto  := {}
Local oPeca     := DMS_Peca():New()
Default lAtuQtd := .t.
Default nLinhaVM4 := 1
If !Empty(cCodSB1) .and. "["+Alltrim(cCodSB1)+"]" <> "[0]"
	//
	aProduto := oPeca:LeCodBarras(cCodSB1) // Leitura do Codigo de Barras
	//
	If Len(aProduto) > 0
		DbSelectArea("SB1")
		DbSetOrder(1)
		If !Empty(aProduto[1]) .and. DbSeek(xFilial("SB1")+aProduto[1])
			If lAtuQtd // Atualiza QTDE
				If "["+SB1->B1_GRUPO+SB1->B1_CODITE+"]" <> "["+aVM4[nLinhaVM4,1]+aVM4[nLinhaVM4,2]+"]"
					lErro := .t.
					cErro := STR0014 // Item nao corresponde ao selecionado.
				Else
					lRet := OA2200061_SomaQTD( nLinhaVM4 , .f. , nQtdSomar ) // SOMAR QTDE
				EndIf
			Else
				If aScan(aVM4, {|x| x[8] == SB1->(RecNo()) }) == 0 // Se NAO posicionar no Item correspondente
					lErro := .t.
					cErro := STR0015 // Item nao encontrado na solicitacao da OS.
				EndIf
			EndIf
		Else
			lErro := .t.
			cErro := STR0016 // Item nao encontrado no Cadastro de Produtos.
		EndIf
	Else
		lErro := .t.
		cErro := STR0016 // Item nao encontrado no Cadastro de Produtos.
	EndIf
EndIf
If lErro
	cCodSB1 := space(nCodSB1)
	VTGetRefresh("cCodSB1")
	lRet := .f.
	VtBeep(3) // 3 Beep ERRO
	VTAlert(cErro,STR0002) // Atencao
EndIf
FreeObj(oPeca)
Return lRet

/*/{Protheus.doc} OA2200061_SomaQTD
Soma e chama funcao para preencher Quantidade na Conferencia da Oficina

@author Andre Luis Almeida
@since 01/10/2018
@version undefined
@param nLinha, numerico, Linha do Vetor aVM4 ( itens da OS / Solicitacao )
@param lTelaQtd, logico, Abre Tela para o usuario preencher a Quantidade Digitada?
@param nQtdSomar, numerico, Quantidade a Somar na Digitacao
@return lRet, logico, Indica se a Digitacao foi OK ou foi dado ESC

@type function
/*/
Static Function OA2200061_SomaQTD( nLinha , lTelaQtd , nQtdSomar ) // Somar Qtde
Local nQtd := aVM4[nLinha,6]
Local lRet := .t.
If lTelaQtd // Tela Qtde
	OA2200021_LimpaTelaColetor()
	@ 00, 00 VTSay PadR(aVM4[nLinha,1], nTamCol)
	@ 01, 00 VTSay PadR(aVM4[nLinha,2], nTamCol)
	@ 02, 00 VTSay PadR(aVM4[nLinha,3], nTamCol)
	@ 03, 00 VTSay PadR(aVM4[nLinha,4], nTamCol)
	If lMostraSol
		@ 04, 00 VTSay PadR(STR0012+": "+Alltrim(Transform(aVM4[nLinha,5],VM4->(X3PICTURE("VM4_QTSOLI")))), nTamCol) // Qtd.
		@ 05, 00 VTSay repl("-", nTamCol)
		@ 06, 00 VTSay PadR(STR0017, nTamCol) // Quantidade?
		@ 07, 00 VTGet nQtd Valid nQtd>=0
	Else
		@ 04, 00 VTSay repl("-", nTamCol)
		@ 05, 00 VTSay PadR(STR0017, nTamCol) // Quantidade?
		@ 06, 00 VTGet nQtd Valid nQtd>=0
	EndIf
	VTRead
	If VTLastKey() == 27 // ESC
		lRet := .f.
	EndIf
EndIf
If lRet .and. aVM4[nLinha,7] > 0
	//
	If (( nQtd+nQtdSomar ) > aVM4[nLinha,5] ) // Nao deixar digitar/conferir mais que a quantidade solicitada
		VtBeep(3) // 3 Beep ERRO
		VTAlert(STR0018,STR0002) // Quantidade desejada maior que a Quantidade Solicitada. Impossivel continuar. / Atencao
		lRet := .f.
	Else
		aVM4[nLinha,6] := nQtd+nQtdSomar
		OA2120145_GravaQtdConferida( VM3->VM3_CODIGO , aVM4[nLinha,7] , aVM4[nLinha,6] , "2" )
		OA2120115_StatusConferencia( VM3->VM3_CODIGO , "2" , "2" )
		If !lTelaQtd
			VtBeep(1) // 1 Beep OK
		EndIf
	EndIf
	//
EndIf
Return lRet

/*/{Protheus.doc} OA2200071_QualOS
Tela Pergunta o Nro da OS

@author Andre Luis Almeida
@since 07/11/2019
@version undefined
@return cRet, caracter, Nro.OS

@type function
/*/
Static Function OA2200071_QualOS(nTam)
Local cRet := space(nTam)
OA2200021_LimpaTelaColetor()
@ 00, 00 VTSay PadR(STR0001, nTamCol) // Confererencia OS
@ 01, 00 VTSay repl("-", nTamCol)
@ 02, 00 VTSay PadR(STR0019, nTamCol) // Digite:
@ 04, 00 VTSay PadR(STR0020, nTamCol) // Nro. Ordem Servico
@ 05, 00 VTGet cRet Picture "@!"
VTRead
If VTLastKey() == 27 // ESC
	cRet := "ESC"
EndIf
Return cRet

/*/{Protheus.doc} OA2200081_TelaQualItemConferir
Escolher qual Item que sera Conferido

@author Andre Luis Almeida
@since 07/03/2019
@version undefined

@type function
/*/
Static Function OA2200081_TelaQualItemConferir() // Escolher qual Item que sera Conferido
//
While .t.
	//
	If !OA2200121_VerificaStatus() // Verifica o Status se pode Continuar na Conferencia VM3
		Exit
	EndIf
	//
	cCodSB1 := space(nCodSB1)
	OA2200021_LimpaTelaColetor()
	//
	@ 00, 00 VTSay PadR(STR0001, nTamCol) // Confererencia OS
	@ 01, 00 VTSay PadR(VM3->VM3_NUMOSV+" "+VM3->VM3_CODIGO, nTamCol)
	@ 02, 00 VTSay repl("-", nTamCol)
	@ 04, 00 VTSay PadR(STR0021, nTamCol) // Qual Item?
	@ 05, 00 VTGet cCodSB1 Valid OA2200051_PosicionaSB1comCODBAR(.f.,0)
	VTRead
	//
	If VTLastKey() <> 27 // Diferente de ESC
		If Empty(cCodSB1)
			OA2200091_TELA3(.f.) // Mostrar todos os Itens da OS/Solicitados
			Exit
		ElseIf "["+Alltrim(cCodSB1)+"]" <> "[0]"
			OA2200091_TELA3(.t.) // Mostrar todos os Itens da OS/Solicitados ( escolher Item Especifico )
			Exit
		EndIf
	Else
		If nPosOpc <> 1
			Exit
		EndIf
	EndIf
	//
EndDo
//
Return

/*/{Protheus.doc} OA2200091_TELA3
T3 - Mostrar todos os Itens da OS/Solicitacao

@author Andre Luis Almeida
@since 01/10/2018
@version undefined

@type function
/*/
Static Function OA2200091_TELA3(lItemEspec) // T3 - Mostrar todos os Itens da OS/Solicitacao
Local nPos     := 0
Local cJaConf  := ""
Local nCntFor  := 0
Local aSize    := {nTamCol}
Local aColunas := {STR0009} // Selecionar Item
Local aLinhas  := {}
Default lItemEspec := .f.
//
While .t.
	//
	If !OA2200121_VerificaStatus() // Verifica o Status se pode Continuar na Conferencia VM3
		Exit
	EndIf
	//
	aLinhas := {}
	//
	For	nCntFor := 1 to len(aVM4)
		cJaConf := IIf( aVM4[nCntFor,6] > 0 , "*" , " " ) // Verifica se o Item ja foi Conferido
		aAdd(aLinhas,{ cJaConf + IIf(lVerGrupo,aVM4[nCntFor,1],"") + aVM4[nCntFor,2] })
	Next
	DbSelectArea("VM4")
	If len(aLinhas) > 0
		If lItemEspec
			nPos := aScan(aVM4, {|x| x[8] == SB1->(RecNo()) })
			OA2200041_TelaItemBipar(nPos)
			Exit
		Else
			aAdd(aLinhas,{ repl("-",nTamCol) })
			aAdd(aLinhas,{ STR0011 }) // Finaliza Confer. ?
			OA2200021_LimpaTelaColetor()
			If nLinT3 > len(aLinhas)
				nLinT3 := 1 // Volta para o primeiro registro da Tela 3 ( Itens )
			EndIf
			nPos := VTaBrowse(0,0,nTamLin,nTamCol,aColunas,aLinhas,aSize,,nLinT3) // Lista os Itens
			If nPos > 0
				If nPos == len(aLinhas) // Finaliza Confer. ?
					If OA2200111_FinalizaConferencia() // Finaliza / Grava Conferencia
						Exit
					EndIf
				ElseIf nPos <> ( len(aLinhas) -1 ) // Diferente de tracos - Item a Item
					nLinT3 := nPos // Posiciona no registro da Tela 3 ( Itens )
					If OA2200061_SomaQTD( nPos , .t. , 0 ) // SOMA QTDE
						If len(aLinhas) > nLinT3
							nLinT3++ // Pula linha automaticamente na Tela 3
						Else
							nLinT3 := 1 // Volta para o primeiro registro da Tela 3 ( Itens )
						EndIf
					EndIf
				EndIf
			Else
				Exit
			EndIf
		EndIf
	Else
		VtBeep(3) // 3 Beep ERRO
		VTAlert(STR0022+VM3->VM3_NUMOSV+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
				STR0023,STR0002) // OS / Nenhum Item encontrado. / Atencao
		Exit
	EndIf
	//
	lItemEspec := .f.
	//
EndDo
//
Return()

/*/{Protheus.doc} OA2200101_ListaItensDivergentes
Lista os Itens com Divergencia

@author Andre Luis Almeida
@since 02/10/2019
@version undefined

@type function
/*/
Static Function OA2200101_ListaItensDivergentes() // Lista Itens com Divergencia
Local aSize    := {nTamCol}
Local aColunas := {STR0024} // Itens com Diverg
Local aLinhas  := {}
Local aLinDiv  := {}
Local nCntFor  := 0
Local nPosIte  := 0
Local cJaConf  := ""
//
While .t.
	//
	If !OA2200121_VerificaStatus() // Verifica o Status se pode Continuar na Conferencia VM3
		Exit
	EndIf
	//
	aLinhas  := {}
	aLinDiv  := {}
	//
	For nCntFor := 1 to len(aVM4)
		If aVM4[nCntFor,5] <> aVM4[nCntFor,6]
			cJaConf := IIf( aVM4[nCntFor,6] > 0 , "*" , " " ) // Verifica se o Item ja foi Conferido
			aAdd(aLinhas,{ cJaConf + IIf(lVerGrupo,aVM4[nCntFor,1],"") + aVM4[nCntFor,2] })
			aAdd(aLinDiv,nCntFor) // Linha relacionada ao vetor aVM4
		EndIf
	Next
	OA2200021_LimpaTelaColetor()
	If Len(aLinhas) > 0
		aAdd(aLinhas,{ repl("-",nTamCol) })
		aAdd(aLinhas,{ STR0011 }) // Finaliza Confer. ?
		nPosIte := VTaBrowse(0,0,nTamLin,nTamCol,aColunas,aLinhas,aSize,,1) // Lista os Itens
		If nPosIte > 0
			If nPosIte == len(aLinhas) // Finaliza Confer. ?
				If OA2200111_FinalizaConferencia() // Finaliza / Grava Conferencia
					Exit
				EndIf
			ElseIf nPosIte <> ( len(aLinhas) -1 ) // Diferente de tracos - Item a Item
				OA2200061_SomaQTD( aLinDiv[nPosIte] , .t. , 0 ) // DIGITA QTDE PARA ITEM ESPECIFICO
			EndIf
		Else
			Exit
		EndIf
	Else
		VTAlert(STR0025,STR0002) // Nenhum Item com Divergencia encontrado! Atencao
		Exit
	EndIf
	//
EndDo
//
Return

/*/{Protheus.doc} OA2200111_FinalizaConferencia
Finaliza a Conferencia - Gravacao VM1

@author Andre Luis Almeida
@since 08/10/2018
@version undefined

@type function
/*/
Static Function OA2200111_FinalizaConferencia()
Local lRet      := .f.
If VtYesNo(STR0026,STR0027,.t.) // Deseja Finalizar a Conferencia dos Itens da OS? / Finalizar?
	lRet := .t.
	OA2120175_VerificaDivergencias( VM3->VM3_CODIGO , "2" )
	If VM3->VM3_DIVERG == "1" // Tem Divergencia
		If !VtYesNo(STR0028,STR0029,.t.) // Existem divergencias na Conferencia. / Deseja continuar?
			lRet := .f.
		EndIf
	EndIf
	If lRet // Conferencia OK - Liberar automaticamente para Aprovar e Requisitar as Pecas
		OA2120115_StatusConferencia( VM3->VM3_CODIGO , "3" , "2" )
		//
		VM3->(MsUnlock()) // Retirar SimpleLock do VM3
		//
		VTAlert(STR0022+VM3->VM3_NUMOSV+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
				STR0030,STR0002) // OS / Conferencia Finalizada. Aguardando Aprovacao. / Atencao
	EndIf
EndIf
Return lRet

/*/{Protheus.doc} OA2200121_VerificaStatus
Verifica o Status se pode Continuar na Conferencia VM3

@author Andre Luis Almeida
@since 19/12/2019
@version undefined

@type function
/*/
Static Function OA2200121_VerificaStatus() // Verifica o Status se pode Continuar na Conferencia VM3
Local lRet := .f.
If VM3->VM3_STATUS $ "1/2" // Status igual a Pendente ou Conferido Parcialmente
	lRet := .t.
EndIf
Return lRet