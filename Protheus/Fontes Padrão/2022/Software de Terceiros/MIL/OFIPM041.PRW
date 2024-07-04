#INCLUDE 'FIVEWIN.CH'
#INCLUDE 'APVT100.CH'
#INCLUDE 'OFIPM041.CH'

/*/{Protheus.doc} OFIPM041
Coletor/Leitor VT100 - Digitacao do Inventario via Coletor

@author Andre Luis Almeida
@since 10/01/2018
@version undefined

@type function
/*/
Function OFIPM041()
Private nCodSB1  := TamSx3("B1_CODBAR")[1]
Private nEndCont := TamSx3("VPF_LOCAC")[1]
Private cCodSB1  := space(nCodSB1)
Private cEndCont := space(nEndCont)
Private nLinT1   := 1 // Linha posicionada na Tela 1
Private nLinT3   := 1 // Linha posicionada na Tela 3
Private nLinT5   := 1 // Linha posicionada na Tela 5
Private nTamCol  := VTMaxCol() // Qtde maxima de Colunas no Display do Coletor
Private nTamLin  := VTMaxRow() // Qtde maxima de Linhas no Display do Coletor
Private lVerGrupo := ( GetNewPar("MV_MIL0120","2") == "2" ) // COLETOR DE DADOS NA DIG.INVENTARIO - VISUALIZA: 1 = CODIGO DO ITEM / 2 = GRUPO + CODIGO DO ITEM
//
OPM041T1() // T1 - Escolher qual Inventario que sera digitado 
//
Return

/*/{Protheus.doc} OPM041T1
T1 - Escolher qual Inventario que sera digitado

@author Andre Luis Almeida
@since 10/01/2018
@version undefined

@type function
/*/
Static Function OPM041T1() // T1 - Escolher qual Inventario que sera digitado 
Local cJaDig   := ""
Local nPos     := 0
Local aSize    := {nTamCol}
Local aColunas := {STR0017} // Inventario
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
	cJaDig := FS_JADIGITADO( ( cQAlVPE )->( VPE_FILIAL ) , ( cQAlVPE )->( VPE_CODIGO ) , "" ) // Verifica se o Inventario Total ja foi Digitado
	//
	aAdd(aLinhas,{ cJaDig + ( cQAlVPE )->( VPE_CODIGO ) +" "+ ( cQAlVPE )->( VPE_FASE ) +" "+ cDtInv })
	//
	( cQAlVPE )->( DbSkip() )
EndDo
( cQAlVPE )->( DbCloseArea() )
DbSelectArea("VPE")
FS_LIMPATELA()
If len(aLinhas) > 0
	If nLinT1 > len(aLinhas)
		nLinT1 := 1 // Volta para o primeiro registro da Tela 1 ( Inventarios )
	EndIf
	nPos := VTaBrowse(0,0,nTamLin,nTamCol,aColunas,aLinhas,aSize,,nLinT1) // Lista os Inventarios
	If nPos > 0
		nLinT1 := nPos // Posiciona no registro da Tela 1 ( Invantarios )
		nLinT3 := 1 // Posiciona no primeiro registro da Tela 3 ( Enderecos )
		nLinT5 := 1 // Posiciona no primeiro registro da Tela 5 ( Itens )
		DbSelectArea("VPE")
		DbSetOrder(1)
		If DbSeek(xFilial("VPE")+substr(aLinhas[nPos,1],2,nVPE_CODIGO)) .and. FS_VLDFASE(.t.)
			OPM041T2() // T2 - Escolher qual Endereco que sera digitado
		EndIf
		nLinT3 := 1 // Posiciona no primeiro registro da Tela 3 ( Enderecos )
		nLinT5 := 1 // Posiciona no primeiro registro da Tela 5 ( Itens )
		OPM041T1() // T1 - Escolher qual Inventario que sera digitado 
	EndIf
Else
	VtBeep(3) // 3 Beep ERRO
	VTAlert(STR0008,STR0020) // Nao existe Inventario em fase de Digitacao. / Atencao
EndIf
Return

/*/{Protheus.doc} OPM041T2
T2 - Escolher qual Endereco que sera digitado

@author Andre Luis Almeida
@since 10/01/2018
@version undefined

@type function
/*/
Static Function OPM041T2() // T2 - Escolher qual Endereco que sera digitado
Local xDtInv := ""
Local cDtInv := ""
cEndCont := space(nEndCont)
FS_LIMPATELA()
If FS_VLDFASE(.t.)
	//
	xDtInv := Transform( VPE->VPE_DATINI , "@D" ) // Converter Data
	cDtInv :=  left( xDtInv , 6 )
	cDtInv += right( xDtInv , 2 )
	//
	@ 00, 00 VTSay PadR(STR0001, nTamCol) // Digitac. Inventario
	@ 01, 00 VTSay PadR(VPE->VPE_CODIGO+" "+VPE->VPE_FASE+" "+cDtInv, nTamCol)
	@ 02, 00 VTSay repl("-", nTamCol)
	@ 03, 00 VTSay PadR(STR0002, nTamCol) // Qual Endereco?
	@ 04, 00 VTGet cEndCont Valid FS_ENDERECO()
	VTRead
	//
	If VTLastKey() <> 27 // Diferente de ESC
		If Empty(cEndCont)
			OPM041T3() // T3 - Mostrar todos os enderecos do Inventario
		Else
			OPM041T4() // T4 - Escolher qual Item que sera digitado
		EndIf
	EndIf
EndIf
Return

/*/{Protheus.doc} OPM041T3
T3 - Mostrar todos os Enderecos do Inventario

@author Andre Luis Almeida
@since 10/01/2018
@version undefined

@type function
/*/
Static Function OPM041T3() // T3 - Mostrar todos os Enderecos do Inventario
Local cJaDig   := ""
Local nPos     := 0
Local aSize    := {nTamCol}
Local aColunas := {STR0003} // Selecionar Endereco
Local aLinhas  := {}
Local cQuery   := ""
Local cQAlVPF  := "SQLVPF"
//
If FS_VLDFASE(.t.)
	cQuery := "SELECT DISTINCT VPF_LOCAC"
	cQuery += "  FROM "+RetSQLName('VPF')
	cQuery += " WHERE VPF_FILIAL = '"+VPE->VPE_FILIAL+"'"
	cQuery += "   AND VPF_CODIGO = '"+VPE->VPE_CODIGO+"'"
	cQuery += "   AND VPF_NROREL <> ' '"
	cQuery += "   AND D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY VPF_LOCAC"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVPF , .F., .T. )
	While !( cQAlVPF )->( Eof() )
		//
		cJaDig := FS_JADIGITADO( VPE->VPE_FILIAL , VPE->VPE_CODIGO , ( cQAlVPF )->( VPF_LOCAC ) ) // Verifica se o Inventario/Endereco ja foi Digitado
		//
		aAdd(aLinhas,{ cJaDig + ( cQAlVPF )->( VPF_LOCAC ) })
		//
		( cQAlVPF )->( DbSkip() )
	EndDo
	( cQAlVPF )->( DbCloseArea() )
	DbSelectArea("VPF")
	If len(aLinhas) > 0
		aAdd(aLinhas,{ repl("-",nTamCol) })
		aAdd(aLinhas,{ STR0004 }) // Zera NAO Digitados?
		FS_LIMPATELA()
		If nLinT3 > len(aLinhas)
			nLinT3 := 1 // Volta para o primeiro registro da Tela 3 ( Enderecos )
		EndIf
		nPos := VTaBrowse(0,0,nTamLin,nTamCol,aColunas,aLinhas,aSize,,nLinT3) // Lista os Enderecos
		If nPos > 0
			If nPos == len(aLinhas) // Zera NAO Digitados?
				FS_ZERARITENS(0,{})
				OPM041T3() // Continua na T3 - Mostrar todos os Enderecos do Inventario
			ElseIf nPos == ( len(aLinhas) -1 ) // tracos - continuar na mesma tela
				OPM041T3() // Continua na T3 - Mostrar todos os Enderecos do Inventario
			Else // Item a Item
				nLinT3 := nPos // Posiciona no registro da Tela 3 ( Enderecos )
				nLinT5 := 1 // Posiciona no primeiro registro da Tela 5 ( Itens )
				cEndCont := substr(aLinhas[nPos,1],2) // Endereco a ser Inventariado
				OPM041T4() // T4 - Escolher qual Item que sera digitado
				If len(aLinhas) > nLinT3
					nLinT3++ // Pula linha automaticamente na Tela 3
				Else
					nLinT3 := 1 // Volta para o primeiro registro da Tela 3 ( Enderecos )
				EndIf
				nLinT5 := 1 // Posiciona no primeiro registro da Tela 5 ( Itens )
			EndIf
		Else
			OPM041T2() // voltar para T2 - Escolher qual endereco que sera digitado
		EndIf
	Else
		VtBeep(3) // 3 Beep ERRO
		VTAlert(STR0017        +CHR(13)+CHR(10)+;
				VPE->VPE_CODIGO+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
				STR0016,STR0020) // Inventario / Nenhum Item encontrado. / Atencao
	EndIf
EndIf
Return

/*/{Protheus.doc} OPM041T4
T4 - Escolher qual Item que sera digitado

@author Andre Luis Almeida
@since 10/01/2018
@version undefined

@type function
/*/
Static Function OPM041T4() // T4 - Escolher qual Item que sera digitado
Local xDtInv := ""
Local cDtInv := ""
cCodSB1 := space(nCodSB1)
FS_LIMPATELA()
If FS_VLDFASE(.t.)
	//
	xDtInv := Transform( VPE->VPE_DATINI , "@D" ) // Converter Data
	cDtInv :=  left( xDtInv , 6 )
	cDtInv += right( xDtInv , 2 )
	//
	@ 00, 00 VTSay PadR(STR0001, nTamCol) // Digitac. Inventario
	@ 01, 00 VTSay PadR(VPE->VPE_CODIGO+" "+VPE->VPE_FASE+" "+cDtInv, nTamCol)
	@ 02, 00 VTSay PadR(cEndCont, nTamCol)
	@ 03, 00 VTSay repl("-", nTamCol)
	@ 04, 00 VTSay PadR(STR0019, nTamCol) // Bipar Cod.Barras
	@ 05, 00 VTGet cCodSB1 Valid FS_B1CODBAR(.t.)
	VTRead
	//
	If VTLastKey() <> 27 // ESC
		If Empty(cCodSB1)
			OPM041T6() // T6 - Selecionar um Item Especifico
		EndIf
		OPM041T4() // Continua na T4 - Escolher qual Item que sera digitado
	Else
		OPM041T2() // Voltar para T2 - Escolher qual Endereco que sera digitado
	EndIf
EndIf
Return

/*/{Protheus.doc} OPM041T5
T5 - Mostrar todos os Itens do Endereco/Inventario

@author Andre Luis Almeida
@since 10/01/2018
@version undefined

@type function
/*/
Static Function OPM041T5() // T5 - Mostrar todos os Itens do Endereco/Inventario
Local cJaDig   := ""
Local nPos     := 0
Local aSize    := {nTamCol}
Local aColunas := {STR0006} // Selecionar Item
Local aLinhas  := {}
Local aRecVPF  := {}
Local cQuery   := ""
Local cQAlVPF  := "SQLVPF"
//
If FS_VLDFASE(.t.)
	cQuery := "SELECT VPF_GRUITE , VPF_CODITE , VPF_OKDIG , R_E_C_N_O_ AS RECVPF"
	cQuery += "  FROM "+RetSQLName('VPF')
	cQuery += " WHERE VPF_FILIAL = '"+VPE->VPE_FILIAL+"'"
	cQuery += "   AND VPF_CODIGO = '"+VPE->VPE_CODIGO+"'"
	cQuery += "   AND VPF_LOCAC  = '"+cEndCont+"'"
	cQuery += "   AND VPF_NROREL <> ' '"
	cQuery += "   AND D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY VPF_NROREL"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVPF , .F., .T. )
	While !( cQAlVPF )->( Eof() )
		//
		cJaDig := IIf( ( cQAlVPF )->( VPF_OKDIG ) == "0" , " " , "*" ) // Verifica se o Item ja foi Digitado
		//
		aAdd(aLinhas,{ cJaDig + IIf(lVerGrupo,( cQAlVPF )->( VPF_GRUITE ),"") + ( cQAlVPF )->( VPF_CODITE ) })
		aAdd(aRecVPF, ( cQAlVPF )->( RECVPF ) )
		//
		( cQAlVPF )->( DbSkip() )
	EndDo
	( cQAlVPF )->( DbCloseArea() )
	DbSelectArea("VPF")
	If len(aLinhas) > 0
		aAdd(aLinhas,{ repl("-",nTamCol) })
		aAdd(aLinhas,{ STR0004 }) // Zera NAO Digitados?
		FS_LIMPATELA()
		If nLinT5 > len(aLinhas)
			nLinT5 := 1 // Volta para o primeiro registro da Tela 5 ( Itens )
		EndIf
		nPos := VTaBrowse(0,0,nTamLin,nTamCol,aColunas,aLinhas,aSize,,nLinT5) // Lista os Itens
		If nPos > 0
			If nPos == len(aLinhas) // Zera NAO Digitados?
				FS_ZERARITENS(1,aRecVPF)
				OPM041T5() // Continua na T5 - Mostrar todos os Itens do Endereco/Inventario
			ElseIf nPos == ( len(aLinhas) -1 ) // tracos - continuar na mesma tela
				OPM041T5() // Continua na T5 - Mostrar todos os Itens do Endereco/Inventario
			Else // Item a Item
				nLinT5 := nPos // Posiciona no registro da Tela 5 ( Itens )
				If OPM041QTD( aRecVPF[nPos] , .t. , 0 ) // SOMA QTDE
					If len(aLinhas) > nLinT5
						nLinT5++ // Pula linha automaticamente na Tela 5
					Else
						nLinT5 := 1 // Volta para o primeiro registro da Tela 5 ( Itens )
					EndIf
				EndIf
				OPM041T5() // Continua na T5 - Mostrar todos os Itens do Endereco/Inventario
			EndIf
		EndIf
	Else
		VtBeep(3) // 3 Beep ERRO
		VTAlert(STR0017        +CHR(13)+CHR(10)+;
				VPE->VPE_CODIGO+CHR(13)+CHR(10)+;
				STR0018        +CHR(13)+CHR(10)+;
				cEndCont       +CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
				STR0016,STR0020) // Inventario / Endereco / Nenhum Item encontrado. / Atencao
	EndIf
EndIf
Return

/*/{Protheus.doc} OPM041T6
T6 - Selecionar um Item Especifico

@author Andre Luis Almeida
@since 20/12/2018
@version undefined

@type function
/*/
Static Function OPM041T6() // T6 - Selecionar um Item Especifico
Local xDtInv := ""
Local cDtInv := ""
cCodSB1 := space(nCodSB1)
FS_LIMPATELA()
If FS_VLDFASE(.t.)
	//
	xDtInv := Transform( VPE->VPE_DATINI , "@D" ) // Converter Data
	cDtInv :=  left( xDtInv , 6 )
	cDtInv += right( xDtInv , 2 )
	//
	@ 00, 00 VTSay PadR(STR0001, nTamCol) // Digitac. Inventario
	@ 01, 00 VTSay PadR(VPE->VPE_CODIGO+" "+VPE->VPE_FASE+" "+cDtInv, nTamCol)
	@ 02, 00 VTSay PadR(cEndCont, nTamCol)
	@ 03, 00 VTSay repl("-", nTamCol)
	@ 04, 00 VTSay PadR(STR0005, nTamCol) // Qual Item?
	@ 05, 00 VTGet cCodSB1 Valid FS_B1CODBAR(.f.)
	VTRead
	//
	If VTLastKey() <> 27 // Diferente de ESC
		If Empty(cCodSB1)
			OPM041T5() // T5 - Mostrar todos os Itens do Endereco/Inventario
		EndIf
		OPM041T6() // Manter na mesma Tela - Selecionar o Item Especifico
	EndIf
	//
EndIf
Return

/*/{Protheus.doc} FS_JADIGITADO
Verifica se o Inventario/Endereco esta Digitado

@author Andre Luis Almeida
@since 10/01/2018
@version undefined
@param cFilVPE, character, Filial do Inventario
@param cCodVPE, character, Codigo do Inventario
@param cVPF_LOCAC, character, Endereço referente a Digitacao
@return cRet , caracter, Indica se o Inventario/Endereco esta Digitado ( "*" = Ja Digitado )

@type function
/*/
Static Function FS_JADIGITADO( cFilVPE , cCodVPE , cVPF_LOCAC ) // Verifica se ja esta Digitado ( Inventario / Endereço )
Local cRet   := " " // " " - FALTA DIGITACAO
Local cQuery := ""
cQuery := "SELECT R_E_C_N_O_"
cQuery += "  FROM "+RetSQLName('VPF')
cQuery += " WHERE VPF_FILIAL  = '"+cFilVPE+"'"
cQuery += "   AND VPF_CODIGO  = '"+cCodVPE+"'"
If !Empty(cVPF_LOCAC)
	cQuery += " AND VPF_LOCAC = '"+cVPF_LOCAC+"'" // Verificar Endereco especifico
EndIf
cQuery += " AND VPF_NROREL <> ' '"
cQuery += " AND VPF_OKDIG  = '0' "
cQuery += " AND D_E_L_E_T_ = ' ' "
If FM_SQL(cQuery) <= 0
	cRet := "*" // "*" - JA DIGITADO
EndIf
Return cRet

/*/{Protheus.doc} FS_VLDFASE
Valida se esta em Fase de Digitacao do Inventario

@author Andre Luis Almeida
@since 10/01/2018
@version undefined
@param lMsg, logico, Mostra Mensagem ( .t. / .f. )
@return lRet , logico, Indica se o Inventario esta em Fase de Digitacao

@type function
/*/
Static Function FS_VLDFASE( lMsg )
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
		VTAlert(STR0007,STR0020) // Inventario nao esta na fase de Digitacao. / Atencao
	EndIf
EndIf
Return lRet

/*/{Protheus.doc} FS_ENDERECO
Valida se o Endereco existe no Inventario

@author Andre Luis Almeida
@since 10/01/2018
@version undefined
@return lRet , logico, Indica se o Endereco existe no Inventario

@type function
/*/
Static Function FS_ENDERECO() // Posicionar no Endereco
Local lRet   := .t.
Local cQuery := ""
If !Empty(cEndCont)
	cQuery := "SELECT R_E_C_N_O_"
	cQuery += "  FROM "+RetSQLName('VPF')
	cQuery += " WHERE VPF_FILIAL = '"+VPE->VPE_FILIAL+"'"
	cQuery += "   AND VPF_CODIGO = '"+VPE->VPE_CODIGO+"'"
	cQuery += "   AND VPF_NROREL <> ' '"
	cQuery += "   AND VPF_LOCAC = '"+cEndCont+"'"
	cQuery += "   AND D_E_L_E_T_ = ' '"
	If FM_SQL(cQuery) <= 0
		cEndCont := space(nEndCont)
		VTGetRefresh("cEndCont")
		lRet := .f.
		VtBeep(3) // 3 Beep ERRO
		VTAlert(STR0009,STR0020) // Endereco nao encontrado neste Inventario. / Atencao
	Else
		VtBeep(1) // 1 Beep OK
	EndIf
EndIf
Return lRet

/*/{Protheus.doc} FS_B1CODBAR
Valida se o Item existe no SB1/Inventario/Endereco
Caso exista, verifica a quantidade atraves do Codigo de Barras (EAN13/EAN14/EAN128) e SOMA na Digitacao

@author Andre Luis Almeida
@since 10/01/2018
@version undefined
@param lSomaQTD, logico, Somar a Quantidade?
@return lRet , logico, Indica se o Item existe no SB1/Inventario/Endereco

@type function
/*/
Static Function FS_B1CODBAR(lSomaQTD) // Posicionar no SB1 com Codigo de Barras e Verificar se o Item esta no Inventario/Endereco
Local lRet      := .t.
Local nRecVPF   := 0
Local nQtdSomar := 0
Local cQuery    := ""
Local aProduto  := {}
Local oPeca     := DMS_Peca():New()
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
			cQuery += "   AND VPF_LOCAC  = '"+cEndCont+"'"
			cQuery += "   AND VPF_GRUITE = '"+SB1->B1_GRUPO+"'"
			cQuery += "   AND VPF_CODITE = '"+SB1->B1_CODITE+"'"
			cQuery += "   AND D_E_L_E_T_ = ' '"
			nRecVPF := FM_SQL(cQuery)
			If nRecVPF <= 0
				cCodSB1 := space(nCodSB1)
				VTGetRefresh("cCodSB1")
				lRet := .f.
				VtBeep(3) // 3 Beep ERRO
				VTAlert(STR0010,STR0020) // Item nao encontrado neste Inventario/Endereco. / Atencao
			Else
				If lSomaQTD // Somar QTDE
					lRet := OPM041QTD( nRecVPF , .f. , nQtdSomar ) // SOMAR QTDE
				Else // Digitar QTDE
					OPM041QTD( nRecVPF , .t. , 0 ) // DIGITAR QTDE
				EndIf
			EndIf
		Else
			cCodSB1 := space(nCodSB1)
			VTGetRefresh("cCodSB1")
			lRet := .f.
			VtBeep(3) // 3 Beep ERRO
			VTAlert(STR0011,STR0020) // Item nao encontrado no Cadastro de Produtos. / Atencao
		EndIf
	Else
		cCodSB1 := space(nCodSB1)
		VTGetRefresh("cCodSB1")
		lRet := .f.
		VtBeep(3) // 3 Beep ERRO
		VTAlert(STR0011,STR0020) // Item nao encontrado no Cadastro de Produtos. / Atencao
	EndIf
EndIf
Return lRet

/*/{Protheus.doc} FS_LIMPATELA
Limpa a Tela do Coletor 

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

/*/{Protheus.doc} OPM041QTD
Soma e chama funcao para preencher Quantidade na Contagem do Inventario

@author Andre Luis Almeida
@since 10/01/2018
@version undefined
@param nRecVPF, numerico, RecNo da tabela VPF ( itens do Inventario )
@param lTelaQtd, logico, Abre Tela para o usuario preencher a Quantidade Digitada?
@param nQtdSomar, numerico, Quantidade a Somar na Digitacao
@return lRet, logico, Indica se a Digitacao foi OK ou foi dado ESC

@type function
/*/
Static Function OPM041QTD( nRecVPF , lTelaQtd , nQtdSomar ) // Somar Qtde
Local nQtdVPF     := 0
Local lRet        := .t.
If FS_VLDFASE(.t.)
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
		FS_LIMPATELA()
		@ 00, 00 VTSay PadR(SB1->B1_GRUPO, nTamCol)
		@ 01, 00 VTSay PadR(SB1->B1_CODITE, nTamCol)
		@ 02, 00 VTSay PadR(SB1->B1_DESC, nTamCol)
		@ 03, 00 VTSay repl("-", nTamCol)
		@ 04, 00 VTSay PadR(STR0012, nTamCol) // Quantidade?
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

/*/{Protheus.doc} FS_ZERARITENS
Zera os Itens do Inventario/Endereco

@author Andre Luis Almeida
@since 10/01/2018
@version undefined
@param nTp, numerico, 0 - Zera TODOS os Enderecos / 1 - Zera apenas um Endereco
@param aRecVPF, array, Vetor com os Itens ( RecNo do VPF ) que serao Zerados

@type function
/*/
Static Function FS_ZERARITENS( nTp , aRecVPF ) // Zerar Itens NAO Digitados
Local cMsg    := ""
Local lMsg    := .f.
Local lOk     := .f.
Local ni      := 0
Local cQuery  := ""
Local cQAlVPF := "SQLVPF"
If nTp == 0 // Zerar TODOS Itens NAO Digitados de TODOS os Enderecos
	If VtYesNo(STR0013,STR0004,.t.) // Zerar TODOS os Itens que NAO foram Digitados em TODOS os Enderecos? / Zera NAO Digitados?
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
		cMsg += STR0017 // Inventario
		cMsg += CHR(13)+CHR(10)
		cMsg += VPE->VPE_CODIGO
		//
	EndIf
Else // nTp == 1 // Zerar TODOS Itens NAO Digitados de um determinado Endereco
	If VtYesNo(STR0014+CHR(13)+CHR(10)+cEndCont,STR0004,.t.) // Zerar TODOS os Itens que NAO foram Digitados no Endereco? / Zera NAO Digitados?
		lMsg := .t.
		For ni := 1 to len(aRecVPF)
			VPF->(DbGoTo(aRecVPF[ni]))
			If VPF->VPF_OKDIG == "0" // Ainda NAO digitado
				lOk := .t.
				//
				OPM040QTD( 0 , , , ) // Digita automaticamente 0 nos Itens
				//
			EndIf
		Next
		//
		cMsg := CHR(13)+CHR(10)+CHR(13)+CHR(10)
		cMsg += STR0018 // Endereco
		cMsg += CHR(13)+CHR(10)
		cMsg += cEndCont
		//
	EndIf
EndIf
If lMsg // Mostra Mensagem
	If lOk // Zerou Itens
		VtBeep(1) // 1 Beep OK
		VTAlert(STR0015+cMsg,STR0020) // Itens zerados com sucesso. / Atencao
	Else // Nao Zerou
		VtBeep(3) // 3 Beep ERRO
		VTAlert(STR0016+cMsg,STR0020) // Nenhum Item encontrado. / Atencao
	EndIf
EndIf
Return