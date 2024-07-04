#INCLUDE 'FIVEWIN.CH'
#INCLUDE 'APVT100.CH'
#INCLUDE 'OFIA040.CH'

/*/{Protheus.doc} OFIA040
Coletor/Leitor VT100 - Digitacao do Inventario via Coletor 
ATENCAO: Rotina duplicada do OFIPM041, porem SEM uso do ENDERECO do ITEM

@author Andre Luis Almeida
@since 29/11/2018
@version undefined

@type function
/*/
Function OFIA040()
Private nCodSB1  := TamSx3("B1_CODBAR")[1]
Private cCodSB1  := space(nCodSB1)
Private nLinT1   := 1 // Linha posicionada na Tela 1
Private nLinT3   := 1 // Linha posicionada na Tela 3
Private nTamCol  := VTMaxCol() // Qtde maxima de Colunas no Display do Coletor
Private nTamLin  := VTMaxRow() // Qtde maxima de Linhas no Display do Coletor
Private lVerGrupo := ( GetNewPar("MV_MIL0120","2") == "2" ) // COLETOR DE DADOS NA DIG.INVENTARIO - VISUALIZA: 1 = CODIGO DO ITEM / 2 = GRUPO + CODIGO DO ITEM
//
OA0400011_TELA1() // T1 - Escolher qual Inventario que sera digitado 
//
Return

/*/{Protheus.doc} OA0400011_TELA1
T1 - Escolher qual Inventario que sera digitado

@author Andre Luis Almeida
@since 29/11/2018
@version undefined

@type function
/*/
Static Function OA0400011_TELA1() // T1 - Escolher qual Inventario que sera digitado 
Local cJaDig   := ""
Local nPos     := 0
Local aSize    := {nTamCol}
Local aColunas := {STR0001} // Inventario
Local aLinhas  := {}
Local cQuery   := ""
Local cQAlVPE  := "SQLVPE"
Local xDtInv   := ""
Local cDtInv   := ""
Local nVPE_CODIGO := TamSx3("VPE_CODIGO")[1]
cQuery := "SELECT VPE_FILIAL , VPE_CODIGO , VPE_FASE , VPE_DATINI "
cQuery += "  FROM "+RetSQLName('VPE')
cQuery += " WHERE VPE_FILIAL = '"+xFilial("VPE")+"'"
cQuery += "   AND VPE_FASE IN ('D1','D2','D3','D4','D5') "
cQuery += "   AND D_E_L_E_T_ = ' '"
cQuery += " ORDER BY VPE_CODIGO"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVPE , .F., .T. )
While !( cQAlVPE )->( Eof() )
	//
	xDtInv := Transform( stod( ( cQAlVPE )->( VPE_DATINI ) ) , "@D" ) // Converter Data
	cDtInv :=  left( xDtInv , 6 )
	cDtInv += right( xDtInv , 2 )
	//
	cJaDig := OA0400051_JADIGITADO( ( cQAlVPE )->( VPE_FILIAL ) , ( cQAlVPE )->( VPE_CODIGO ) ) // Verifica se o Inventario Total ja foi Digitado
	//
	aAdd(aLinhas,{ cJaDig + ( cQAlVPE )->( VPE_CODIGO ) +" "+ ( cQAlVPE )->( VPE_FASE ) +" "+ cDtInv })
	//
	( cQAlVPE )->( DbSkip() )
EndDo
( cQAlVPE )->( DbCloseArea() )
DbSelectArea("VPE")
OA0400041_LIMPATELA()
If len(aLinhas) > 0
	If nLinT1 > len(aLinhas)
		nLinT1 := 1 // Volta para o primeiro registro da Tela 1 ( Inventarios )
	EndIf
	nPos := VTaBrowse(0,0,nTamLin,nTamCol,aColunas,aLinhas,aSize,,nLinT1) // Lista os Inventarios
	If nPos > 0
		nLinT1 := nPos // Posiciona no registro da Tela 1 ( Invantarios )
		nLinT3 := 1 // Posiciona no primeiro registro da Tela 3 ( Itens )
		DbSelectArea("VPE")
		DbSetOrder(1)
		If DbSeek(xFilial("VPE")+substr(aLinhas[nPos,1],2,nVPE_CODIGO)) .and. OA0400061_VLDFASE(.t.)
			OA0400101_MENUOPCOES(1) // Menu de Opcoes
		EndIf
		nLinT3 := 1 // Posiciona no primeiro registro da Tela 3 ( Itens )
		OA0400011_TELA1() // T1 - Escolher qual Inventario que sera digitado 
	EndIf
Else
	VtBeep(3) // 3 Beep ERRO
	VTAlert(STR0003,STR0017) // Nao existe Inventario em fase de Digitacao. / Atencao
EndIf
Return

/*/{Protheus.doc} OA0400021_TELA2
T2 - Escolher qual Item que sera digitado

@author Andre Luis Almeida
@since 29/11/2018
@version undefined

@type function
/*/
Static Function OA0400021_TELA2() // T2 - Escolher qual Item que sera digitado
Local xDtInv := ""
Local cDtInv := ""
cCodSB1 := space(nCodSB1)
OA0400041_LIMPATELA()
If OA0400061_VLDFASE(.t.)
	//
	xDtInv := Transform( VPE->VPE_DATINI , "@D" ) // Converter Data
	cDtInv :=  left( xDtInv , 6 )
	cDtInv += right( xDtInv , 2 )
	//
	@ 00, 00 VTSay PadR(STR0002, nTamCol) // Digitac. Inventario
	@ 01, 00 VTSay PadR(VPE->VPE_CODIGO+" "+VPE->VPE_FASE+" "+cDtInv, nTamCol)
	@ 02, 00 VTSay repl("-", nTamCol)
	@ 03, 00 VTSay PadR(STR0016, nTamCol) // Bipar Cod.Barras
	@ 04, 00 VTGet cCodSB1 Valid OA0400071_B1CODBAR(.t.)
	VTRead
	//
	If VTLastKey() <> 27 // Diferente de ESC
		If Empty(cCodSB1)
			OA0400111_TELA4() // T4 - Selecionar o Item Especifico
		EndIf
		OA0400021_TELA2() // Continua na T2 - Escolher qual Item que sera digitado
	EndIf
EndIf
Return

/*/{Protheus.doc} OA0400031_TELA3
T3 - Mostrar todos os Itens do Inventario

@author Andre Luis Almeida
@since 29/11/2018
@version undefined
@param lItDigSIM, logico, Lista Itens Digitados?
@param lItDigNAO, logico, Lista Itens NAO Digitados?
@param lTelaEsc, logico, Volta Tela no ESC?

@type function
/*/
Static Function OA0400031_TELA3(lItDigSIM,lItDigNAO,lTelaEsc) // T3 - Mostrar todos os Itens do Inventario
Local cJaDig   := ""
Local nPos     := 0
Local aSize    := {nTamCol}
Local aColunas := {STR0005} // Selecionar Item
Local aLinhas  := {}
Local aRecVPF  := {}
Local cQuery   := ""
Local cQAlVPF  := "SQLVPF"
Default lItDigSIM := .t.
Default lItDigNAO := .t.
Default lTelaEsc  := .t.
//
If OA0400061_VLDFASE(.t.)
	cQuery := "SELECT VPF_GRUITE , VPF_CODITE , VPF_OKDIG , R_E_C_N_O_ AS RECVPF"
	cQuery += "  FROM "+RetSQLName('VPF')
	cQuery += " WHERE VPF_FILIAL = '"+VPE->VPE_FILIAL+"'"
	cQuery += "   AND VPF_CODIGO = '"+VPE->VPE_CODIGO+"'"
	cQuery += "   AND VPF_NROREL <> ' '"
	cQuery += "   AND D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY VPF_NROREL"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVPF , .F., .T. )
	While !( cQAlVPF )->( Eof() )
		//
		cJaDig := IIf( ( cQAlVPF )->( VPF_OKDIG ) == "0" , " " , "*" ) // Verifica se o Item ja foi Digitado
		//
		If ( lItDigSIM .and. cJaDig == "*" ) .or. ( lItDigNAO .and. Empty(Alltrim(cJaDig)) )
			aAdd(aLinhas,{ cJaDig + IIf(lVerGrupo,( cQAlVPF )->( VPF_GRUITE ),"") + ( cQAlVPF )->( VPF_CODITE ) })
			aAdd(aRecVPF, ( cQAlVPF )->( RECVPF ) )
		EndIf
		//
		( cQAlVPF )->( DbSkip() )
	EndDo
	( cQAlVPF )->( DbCloseArea() )
	DbSelectArea("VPF")
	If len(aLinhas) > 0
		aAdd(aLinhas,{ repl("-",nTamCol) })
		aAdd(aLinhas,{ STR0006 }) // Zera NAO Digitados?
		OA0400041_LIMPATELA()
		If nLinT3 > len(aLinhas)
			nLinT3 := 1 // Volta para o primeiro registro da Tela 3 ( Itens )
		EndIf
		nPos := VTaBrowse(0,0,nTamLin,nTamCol,aColunas,aLinhas,aSize,,nLinT3) // Lista os Itens
		If nPos > 0
			If nPos == len(aLinhas) // Zera NAO Digitados?
				OA0400091_ZERARITENS() // Zerar Itens NAO Digitados
				OA0400031_TELA3(lItDigSIM,lItDigNAO,lTelaEsc) // Continua na T3 - Mostrar todos os Itens do Inventario
			ElseIf nPos == ( len(aLinhas) -1 ) // tracos - continuar na mesma tela
				OA0400031_TELA3(lItDigSIM,lItDigNAO,lTelaEsc) // Continua na T3 - Mostrar todos os Itens do Inventario
			Else // Item a Item
				nLinT3 := nPos // Posiciona no registro da Tela 3 ( Itens )
				If OA0400081_SOMAQTD( aRecVPF[nPos] , .t. , 0 ) // SOMA QTDE
					If len(aLinhas) > nLinT3
						If lItDigSIM .and. lItDigNAO
							nLinT3++ // Pula linha automaticamente na Tela 3
						EndIf
					Else
						nLinT3 := 1 // Volta para o primeiro registro da Tela 3 ( Itens )
					EndIf
				EndIf
				OA0400031_TELA3(lItDigSIM,lItDigNAO,lTelaEsc) // Continua na T3 - Mostrar todos os Itens do Inventario
			EndIf
		Else
			If lTelaEsc
				OA0400021_TELA2() // voltar para T2 - Escolher qual Item que sera digitado
			EndIf
		EndIf
	Else
		VtBeep(3) // 3 Beep ERRO
		VTAlert(STR0001        +CHR(13)+CHR(10)+;
				VPE->VPE_CODIGO+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
				STR0007,STR0017) // Inventario / Nenhum Item encontrado. / Atencao
	EndIf
EndIf
Return

/*/{Protheus.doc} OA0400041_LIMPATELA
Limpa a Tela do Coletor 

@author Andre Luis Almeida
@since 29/11/2018
@version undefined

@type function
/*/
Static Function OA0400041_LIMPATELA() // Limpa Tela
Local ni := 0
VTCLEARBUFFER()
VTClear() // Limpa Tela
For ni := 1 to nTamLin
	@ ni, 00 VTSay repl(" ",nTamCol)
Next
Return

/*/{Protheus.doc} OA0400051_JADIGITADO
Verifica se o Inventario esta Digitado

@author Andre Luis Almeida
@since 29/11/2018
@version undefined
@param cFilVPE, character, Filial do Inventario
@param cCodVPE, character, Codigo do Inventario
@return cRet , caracter, Indica se o Inventario esta Digitado ( "*" = Ja Digitado )

@type function
/*/
Static Function OA0400051_JADIGITADO( cFilVPE , cCodVPE ) // Verifica se ja esta Digitado ( Inventario )
Local cRet   := " " // " " - FALTA DIGITACAO
Local cQuery := ""
cQuery := "SELECT R_E_C_N_O_"
cQuery += "  FROM "+RetSQLName('VPF')
cQuery += " WHERE VPF_FILIAL  = '"+cFilVPE+"'"
cQuery += "   AND VPF_CODIGO  = '"+cCodVPE+"'"
cQuery += " AND VPF_NROREL <> ' '"
cQuery += " AND VPF_OKDIG  = '0' "
cQuery += " AND D_E_L_E_T_ = ' ' "
If FM_SQL(cQuery) <= 0
	cRet := "*" // "*" - JA DIGITADO
EndIf
Return cRet

/*/{Protheus.doc} OA0400061_VLDFASE
Valida se esta em Fase de Digitacao do Inventario

@author Andre Luis Almeida
@since 29/11/2018
@version undefined
@param lMsg, logico, Mostra Mensagem ( .t. / .f. )
@return lRet , logico, Indica se o Inventario esta em Fase de Digitacao

@type function
/*/
Static Function OA0400061_VLDFASE( lMsg )
Local lRet   := .f.
Local cQuery := ""
cQuery := "SELECT R_E_C_N_O_"
cQuery += "  FROM "+RetSQLName('VPE')
cQuery += " WHERE VPE_FILIAL = '"+VPE->VPE_FILIAL+"'"
cQuery += "   AND VPE_CODIGO = '"+VPE->VPE_CODIGO+"'"
cQuery += "   AND VPE_FASE IN ('D1','D2','D3','D4','D5') " // Fase de Digitacao ( 1 / 2 / 3 / 4 / 5 )
cQuery += "   AND D_E_L_E_T_ = ' '"
If FM_SQL(cQuery) > 0 // SQL necessario para verificar novamente a FASE gravada no banco de dados
	lRet := .t.
Else
	If lMsg
		VtBeep(3) // 3 Beep ERRO
		VTAlert(STR0008,STR0017) // Inventario nao esta na fase de Digitacao. / Atencao
	EndIf
EndIf
Return lRet

/*/{Protheus.doc} OA0400071_B1CODBAR
Valida se o Item existe no SB1/Inventario
Caso exista, verifica a quantidade atraves do Codigo de Barras (EAN13/EAN14/EAN128) e SOMA na Digitacao

@author Andre Luis Almeida
@since 29/11/2018
@version undefined
@param lSomaQTD, logico, Somar a Quantidade?
@return lRet , logico, Indica se o Item existe no SB1/Inventario

@type function
/*/
Static Function OA0400071_B1CODBAR(lSomaQTD) // Posicionar no SB1 com Codigo de Barras e Verificar se o Item esta no Inventario
Local lRet       := .t.
Local nRecVPF    := 0
Local nQtdSomar  := 0
Local cQuery     := ""
Local aProduto   := {}
Local oPeca      := DMS_Peca():New()
Default lSomaQTD := .t. // Somar QTDE
If !Empty(cCodSB1)
	//
	aProduto := oPeca:LeCodBarras(cCodSB1) // Leitura do Codigo de Barras
	//
	If Len(aProduto) > 0
		DbSelectArea("SB1")
		DbSetOrder(1)
		If !Empty(aProduto[1]) .and. DbSeek(xFilial("SB1")+aProduto[1])
			If lSomaQTD // Somar QTDE
				nQtdSomar := aProduto[2]
				If nQtdSomar == 0
					nQtdSomar := 1
				EndIf
			EndIf
			cQuery := "SELECT R_E_C_N_O_"
			cQuery += "  FROM "+RetSQLName('VPF')
			cQuery += " WHERE VPF_FILIAL = '"+VPE->VPE_FILIAL+"'"
			cQuery += "   AND VPF_CODIGO = '"+VPE->VPE_CODIGO+"'"
			cQuery += "   AND VPF_NROREL <> ' '"
			cQuery += "   AND VPF_GRUITE = '"+SB1->B1_GRUPO+"'"
			cQuery += "   AND VPF_CODITE = '"+SB1->B1_CODITE+"'"
			cQuery += "   AND D_E_L_E_T_ = ' '"
			nRecVPF := FM_SQL(cQuery)
			If nRecVPF <= 0
				cCodSB1 := space(nCodSB1)
				VTGetRefresh("cCodSB1")
				lRet := .f.
				VtBeep(3) // 3 Beep ERRO
				VTAlert(STR0009,STR0017) // Item nao encontrado neste Inventario. / Atencao
			Else
				If lSomaQTD // Somar QTDE
					lRet := OA0400081_SOMAQTD( nRecVPF , .f. , nQtdSomar ) // SOMAR QTDE
				Else // Digitar QTDE
					OA0400081_SOMAQTD( nRecVPF , .t. , 0 ) // DIGITAR QTDE
				EndIf
			EndIf
		Else
			cCodSB1 := space(nCodSB1)
			VTGetRefresh("cCodSB1")
			lRet := .f.
			VtBeep(3) // 3 Beep ERRO
			VTAlert(STR0010,STR0017) // Item nao encontrado no Cadastro de Produtos. / Atencao
		EndIf
	Else
		cCodSB1 := space(nCodSB1)
		VTGetRefresh("cCodSB1")
		lRet := .f.
		VtBeep(3) // 3 Beep ERRO
		VTAlert(STR0010,STR0017) // Item nao encontrado no Cadastro de Produtos. / Atencao
	EndIf
EndIf
Return lRet

/*/{Protheus.doc} OA0400081_SOMAQTD
Soma e chama funcao para preencher Quantidade na Contagem do Inventario

@author Andre Luis Almeida
@since 29/11/2018
@version undefined
@param nRecVPF, numerico, RecNo da tabela VPF ( itens do Inventario )
@param lTelaQtd, logico, Abre Tela para o usuario preencher a Quantidade Digitada?
@param nQtdSomar, numerico, Quantidade a Somar na Digitacao
@return lRet, logico, Indica se a Digitacao foi OK ou foi dado ESC

@type function
/*/
Static Function OA0400081_SOMAQTD( nRecVPF , lTelaQtd , nQtdSomar ) // Somar Qtde
Local nQtdVPF     := 0
Local lRet        := .t.
If OA0400061_VLDFASE(.t.)
	VPF->(DbGoTo(nRecVPF))
	Do Case
		Case VPE->VPE_FASE == "D1" // 1a.Digitacao
			nQtdVPF := VPF->VPF_CONTA1
		Case VPE->VPE_FASE == "D2" // 2a.Digitacao
			nQtdVPF := VPF->VPF_CONTA2
		Case VPE->VPE_FASE == "D3" // 3a.Digitacao
			nQtdVPF := VPF->VPF_CONTA3
		Case VPE->VPE_FASE == "D4" // 4a.Digitacao
			nQtdVPF := VPF->VPF_CONTA4
		Case VPE->VPE_FASE == "D5" // 5a.Digitacao
			nQtdVPF := VPF->VPF_CONTA5
	EndCase
	If lTelaQtd // Tela Qtde
		SB1->(DbSetOrder(7))
		SB1->(DbSeek(xFilial("SB1")+VPF->VPF_GRUITE+VPF->VPF_CODITE))
		OA0400041_LIMPATELA()
		@ 00, 00 VTSay PadR(SB1->B1_GRUPO, nTamCol)
		@ 01, 00 VTSay PadR(SB1->B1_CODITE, nTamCol)
		@ 02, 00 VTSay PadR(SB1->B1_DESC, nTamCol)
		@ 03, 00 VTSay repl("-", nTamCol)
		@ 04, 00 VTSay PadR(STR0011, nTamCol) // Quantidade?
		@ 05, 00 VTGet nQtdVPF Valid nQtdVPF>=0
		VTRead
		If VTLastKey() == 27 // ESC
			lRet := .f.
		EndIf
	EndIf
	If lRet
		//
		OPM040QTD( nQtdVPF+nQtdSomar , , , ) // Digita quantidade no Item
		If !lTelaQtd
			VtBeep(1) // 1 Beep OK
		EndIf
		//
	EndIf
EndIf
Return lRet

/*/{Protheus.doc} OA0400091_ZERARITENS
Zera os Itens NAO digitados do Inventario

@author Andre Luis Almeida
@since 29/11/2018
@version undefined

@type function
/*/
Static Function OA0400091_ZERARITENS() // Zerar Itens NAO Digitados
Local cMsg    := ""
Local lMsg    := .f.
Local lOk     := .f.
Local ni      := 0
Local cQuery  := ""
Local cQAlVPF := "SQLVPF"
If VtYesNo(STR0012,STR0006,.t.) // Zerar TODOS os Itens que NAO foram Digitados? / Zera NAO Digitados?
	lMsg := .t.
	cQuery := "SELECT R_E_C_N_O_ AS RECVPF"
	cQuery += "  FROM "+RetSQLName('VPF')
	cQuery += " WHERE VPF_FILIAL = '"+VPE->VPE_FILIAL+"'"
	cQuery += "   AND VPF_CODIGO = '"+VPE->VPE_CODIGO+"'"
	cQuery += "   AND VPF_NROREL <> ' '"
	cQuery += "   AND VPF_OKDIG  = '0'"
	cQuery += "   AND D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY VPF_LOCAC"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVPF , .F., .T. )
	While !( cQAlVPF )->( Eof() )
		lOk := .t.
		//
		OPM040QTD( 0 , ( cQAlVPF )->( RECVPF ) , , ) // Digita automaticamente 0 nos Itens
		//
		( cQAlVPF )->( DbSkip() )
	EndDo
	( cQAlVPF )->( DbCloseArea() )
	//
	cMsg := CHR(13)+CHR(10)+CHR(13)+CHR(10)
	cMsg += STR0001 // Inventario
	cMsg += CHR(13)+CHR(10)
	cMsg += VPE->VPE_CODIGO
	//
EndIf
If lMsg // Mostra Mensagem
	If lOk // Zerou Itens
		VtBeep(1) // 1 Beep OK
		VTAlert(STR0013+cMsg,STR0017) // Itens zerados com sucesso. / Atencao
	Else // Nao Zerou
		VtBeep(3) // 3 Beep ERRO
		VTAlert(STR0007+cMsg,STR0017) // Nenhum Item encontrado. / Atencao
	EndIf
EndIf
Return

/*/{Protheus.doc} OA0400101_MENUOPCOES
Menu de Opcoes

@author Andre Luis Almeida
@since 29/11/2018
@version undefined
@param nLinOpc, numerico, Posiciona na linha das Opcoes do Menu ( default 1 )

@type function
/*/
Static Function OA0400101_MENUOPCOES(nLinOpc) // Menu de Opcoes
Local nPos     := 0
Local aLinhas  := {}
Local aSize    := {nTamCol}
Local aColunas := {STR0018} // Opcoes Digitacao
Default nLinOpc := 1
aAdd(aLinhas,{ STR0019 }) // Todos Itens
aAdd(aLinhas,{ STR0020 }) // Item Especifico
aAdd(aLinhas,{ STR0021 }) // Item Especifico
aAdd(aLinhas,{ STR0022 }) // Itens NAO Digitados
aAdd(aLinhas,{ STR0006 }) // Zera NAO Digitados?
OA0400041_LIMPATELA()
If OA0400061_VLDFASE(.t.)
	//
	nPos := VTaBrowse(0,0,nTamLin,nTamCol,aColunas,aLinhas,aSize,,nLinOpc) // Lista os Itens
	If nPos > 0
		If nPos == 1 // Digitacao dos Itens
			nLinT3 := 1 // Posiciona no primeiro registro da Tela 3 ( Itens )
			OA0400021_TELA2() // T2 - Escolher qual Item que sera digitado
		ElseIf nPos == 2 // Item Especifico
			OA0400111_TELA4() // T4 - Selecionar o Item Especifico
		ElseIf nPos == 3 // Itens Digitados
			OA0400031_TELA3(.t.,.f.,.f.) // T3 - Mostrar todos os Itens do Inventario ( Digitados )
		ElseIf nPos == 4 // Itens NAO Digitados
			OA0400031_TELA3(.f.,.t.,.f.) // T3 - Mostrar todos os Itens do Inventario ( NAO Digitados )
		Else // Zerar Itens NAO Digitados
			OA0400091_ZERARITENS() // Zerar Itens NAO Digitados
		EndIf
		OA0400101_MENUOPCOES(nPos) // Menu de Opcoes
	EndIf
EndIf
Return

/*/{Protheus.doc} OA0400111_TELA4
Selecionar o Item Especifico

@author Andre Luis Almeida
@since 10/12/2018
@version undefined

@type function
/*/
Static Function OA0400111_TELA4() // Selecionar o Item Especifico
Local xDtInv  := ""
Local cDtInv  := ""
Local nPosIte := 0
cCodSB1 := space(nCodSB1)
OA0400041_LIMPATELA()
If OA0400061_VLDFASE(.t.)
	//
	xDtInv := Transform( VPE->VPE_DATINI , "@D" ) // Converter Data
	cDtInv :=  left( xDtInv , 6 )
	cDtInv += right( xDtInv , 2 )
	//
	@ 00, 00 VTSay PadR(STR0002, nTamCol) // Digitac. Inventario
	@ 01, 00 VTSay PadR(VPE->VPE_CODIGO+" "+VPE->VPE_FASE+" "+cDtInv, nTamCol)
	@ 02, 00 VTSay repl("-", nTamCol)
	@ 03, 00 VTSay PadR(STR0004, nTamCol) // Qual Item?
	@ 04, 00 VTGet cCodSB1 Valid OA0400071_B1CODBAR(.f.)
	VTRead
	//
	If VTLastKey() <> 27 // Diferente de ESC
		If Empty(cCodSB1)
			OA0400031_TELA3(.t.,.t.,.f.) // T3 - Mostrar todos os Itens do Inventario
		EndIf
		OA0400111_TELA4() // Manter na mesma Tela - Selecionar o Item Especifico
	EndIf
EndIf
//
Return