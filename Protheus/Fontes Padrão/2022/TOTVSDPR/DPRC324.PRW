#INCLUDE 'DPRC324.CH'
#INCLUDE 'TOTVS.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWADAPTEREAI.CH'

#DEFINE PULALINHA CHR(13)+CHR(10)

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRC324
Custo Fabricação Versão

@author Samantha Preima
@since 08/01/2013
@version P11
@obs aResult - recebe o resultado do cálculo, sendo:
               1 - Item DP
               2 - Versão
               3 - GGF  - Gastos Gerais de Fabricação
               4 - MAT  - Material
               5 - MOD  - Mão de Obra
               6 - PREP - Preparação
               7 - OPER - Operações Externas
               8 - REF  - Refugo
               9 - TOTAL - Somatório de todos os valores acima.
     aDados - parâmetros a serem utilizados para cálculo
               1 - Item DP
               2 - Versão
               3 - Tipo Custo Operação (Total)
               4 - Tipo Preparação (Sem Preparação, Preparação Ordem ou Preparação x Quant.)
               5 - Tipo Preço (Mensal, On-line, Reposição, Última Entrada, Off-line)
               6 - Empresa (apenas para integração DTS)
               7 - Filial (apenas para integração DTS)
               8 - Quantidade
               9 - Se considera apenas componentes DP
               10 - Se considera refugo no custo (apenas para integração DTS)
               11 - Se considera filial padrão do filho (apenas para integração DTS)
/*/
//-------------------------------------------------------------------
Function DPRC324(cProd, cVers)
	Local oDlg
	Local cProduto := if(cProd != nil, cProd, Criavar("DG0_CDACDV",.F.))
	Local cVersao  := if(cVers != nil, cVers, '0000000000')
	Local iDPR     := DPRIntegra()
	Local cArquiv  := ''
	Local cPict    := x3picture('DG0_VLCSPO')
	Local aValidaDPR := ValidaDPR()
	Private cEstado := Criavar("DG0_TPST",.F.)
	Private cDesc   := Criavar("DG0_DSVR",.F.)
	Private aResult := {{cProduto,cVersao,0,0,0,0,0,0,0}}
	Private aDados  := {cProduto,cVersao,1,1,1,,,1,.F.,.F.,.F.}
	Default lAutoMacao := .F.

// Valida se o programa pode ser aberto
	If aValidaDPR[1] .And. !Empty(aValidaDPR[2])
		Final(aValidaDPR[2])
	ElseIf !Empty( aValidaDPR[2] )
		DPRXError( 'DPRC324', aValidaDPR[2], 3 )
	EndIf

	if IsInCallStack('DPRC321')
		aResult[1][1] := DG0->DG0_CDACDV
		aResult[1][2] := DG0->DG0_NRVRAC

		DPRC324VDV()
	Endif

IF !lAutoMacao
	// Cria a janela de seleção
		oDlg := MsDialog():New( 0, 0, 380, 605, STR0001,,,,, CLR_BLACK, CLR_WHITE,,, .T. ) // Custo Fabricação Versão

	// Separando em grupos
		oProduto := TGroup():New(  05,  05, 70 , 300, STR0002, oDlg,,, .T. ) // Versão
		oDetalhe := TGroup():New(  75,  05, 170, 300, STR0003, oDlg,,, .T. ) // Detalhe

	// Preenche a lista de campos para Desenvolvedor de Produto
		TSay():New( 15, 15 , {|| STR0004 }, oProduto,,,,,, .T., CLR_BLACK, CLR_WHITE, 200, 20 ) // Produto Desenvolvido
		TSay():New( 15, 110, {|| STR0002 }, oProduto,,,,,, .T., CLR_BLACK, CLR_WHITE, 200, 20 ) // Versão
		TSay():New( 15, 165, {|| STR0005 }, oProduto,,,,,, .T., CLR_BLACK, CLR_WHITE, 200, 20 ) // Descrição Produto
		TSay():New( 40, 15 , {|| STR0006 }, oProduto,,,,,, .T., CLR_BLACK, CLR_WHITE, 200, 20 ) // Situação
		@ 23,15  MsGet oCDACDV Var aResult[1][1] F3 "DG0001" Size 90 , 10 Of oProduto Pixel HasButton Valid DPRC324VDV() PICTURE x3picture('DG0_CDACDV')
		@ 23,110 MsGet oNRVRAC Var aResult[1][2]             Size 50 , 10 Of oProduto Pixel HasButton Valid DPRC324VDV() PICTURE x3picture('DG0_NRVRAC')
		@ 23,165 MsGet oDSACDV Var cDesc                     Size 130, 10 Of oProduto Pixel HasButton WHEN .F.
		@ 48,15  MsGet oDSVR   Var cEstado                   Size 55 , 10 Of oProduto Pixel HasButton WHEN .F.

	// Resultados
		TSay():New( 85 , 15 , {|| STR0007 }, oDetalhe,,,,,, .T., CLR_BLACK, CLR_WHITE, 200, 20 ) // Gastos Gerais de Fabricação
		TSay():New( 85 , 110, {|| STR0008 }, oDetalhe,,,,,, .T., CLR_BLACK, CLR_WHITE, 200, 20 ) // Matéria-Prima
		if iDPR == 2
			TSay():New( 85 , 205, {|| STR0009 }, oDetalhe,,,,,, .T., CLR_BLACK, CLR_WHITE, 200, 20 ) // Mão de Obra
		Endif
		TSay():New( 110, 15 , {|| STR0010 }, oDetalhe,,,,,, .T., CLR_BLACK, CLR_WHITE, 200, 20 ) // Preparação
		if iDPR == 2
			TSay():New( 110, 110, {|| STR0011 }, oDetalhe,,,,,, .T., CLR_BLACK, CLR_WHITE, 200, 20 ) // Operações Externas
			TSay():New( 110, 205, {|| STR0012 }, oDetalhe,,,,,, .T., CLR_BLACK, CLR_WHITE, 200, 20 ) // Refugo
		Endif
		TSay():New( 135, 15 , {|| STR0013 }, oDetalhe,,,,,, .T., CLR_BLACK, CLR_WHITE, 200, 20 ) // Total Custo Fabricação

		@ 93 ,15  MsGet aResult[1][3] Size 65, 10 Of oProduto Pixel HasButton WHEN .F. PICTURE cPict
		@ 93 ,110 MsGet aResult[1][4] Size 65, 10 Of oProduto Pixel HasButton WHEN .F. PICTURE cPict
		if iDPR == 2
			@ 93 ,205 MsGet aResult[1][5] Size 65, 10 Of oProduto Pixel HasButton WHEN .F. PICTURE cPict
		Endif
		@ 118,15  MsGet aResult[1][6] Size 65, 10 Of oProduto Pixel HasButton WHEN .F. PICTURE cPict
		if iDPR == 2
			@ 118,110 MsGet aResult[1][7] Size 65, 10 Of oProduto Pixel HasButton WHEN .F. PICTURE cPict
			@ 118,205 MsGet aResult[1][8] Size 65, 10 Of oProduto Pixel HasButton WHEN .F. PICTURE cPict
		Endif
		@ 143,15  MsGet aResult[1][9] Size 65, 10 Of oProduto Pixel HasButton WHEN .F. PICTURE cPict

		TButton():New(175,170, STR0014,oDlg,{|| If(DPRC324PAR(aResult[1][1],aResult[1][2]), , )},40,10,,,,.T.) // Parâmetros
		TButton():New(175,215, STR0015,oDlg,{|| If(DPRC324SAL(aResult[1][1],aResult[1][2]), oDlg:End(),)},40,10,,,,.T.) // Salvar
		TButton():New(175,260, STR0016,oDlg,{|| oDlg:End() },40,10,,,,.T.) // Sair

	// Ativação da janela de seleção
		Activate MsDialog oDlg Centered
ENDIF

Return .T.

//-------------------------------------------------------------------
// MenuDef
//-------------------------------------------------------------------
Static Function MenuDef()

Return {}

//-------------------------------------------------------------------
// DPRC324PAR - Tela de parâmetros
//-------------------------------------------------------------------
Static Function DPRC324PAR(cProduto,cVersao)
	Local oDlg
	Local nOrigem1 := 1
	Local nOrigem2 := 1
	Local nOrigem3 := 1
	Local cEmpresa := Criavar("DG0_FILIAL",.F.)
	Local cFilial  := Criavar("DG0_FILIAL",.F.)
	Local nQuant   := Criavar("DG1_QTMT",.F.)
	Local iDPR     := DPRIntegra()
	Local aCusto1
	Local aCusto2
	Local aPreco
	Local lRet   := .T.
	Local cMoeda := GetMv('MV_MOEDA1')

	lRet := DPRC324VDV()

	if lRet

		aDados[1] := cProduto
		aDados[2] := cVersao

		if iDPR == 1
			aCusto1 := {STR0022} // Total
			aCusto2 := {STR0017,STR0018,STR0021} // Sem Custo Preparação, Preparação Ordem, Preparação x Quant.
			aPreco  := {STR0023,STR0024,STR0026,STR0027,STR0066} // Mensal, On-line, Reposição, Última Entrada
		ElseIf iDPR == 2
			aCusto1 := {STR0022,STR0028,STR0029} // Total, Previsto, Previsto 2
			aCusto2 := {STR0017,STR0018,STR0019,STR0020,STR0021} // Sem Custo Preparação, Preparação Ordem, Preparação x Nr. Lote, Prep. Unit x Quant., Preparação x Quant.
			aPreco  := {STR0023,STR0024,STR0025,STR0026,STR0027} // Mensal, On-line, Base, Reposição, Última Entrada
		Endif

		// Cria a janela de seleção
		oDlg := MsDialog():New( 0, 0, 335, 605, STR0030,,,,, CLR_BLACK, CLR_WHITE,,, .T. ) // Parâmetros Custo Fabricação Versão

		// Separando em grupos
		oCusto   := TGroup():New(  05 ,  05, 80 , 150, STR0031 , oDlg,,, .T. ) // Custo Operação
		oPreco   := TGroup():New(  05 , 155, 80 , 300, STR0032 , oDlg,,, .T. ) // Preço Item
		oDetalhe := TGroup():New(  85 , 05 ,145 , 300, '', oDlg,,, .T. )

		// Custo Operação
		oMenu1 := TRadMenu():New( 15, 15, aCusto1, , oCusto,,,,,,,, 100, 12,,,, .T.)
		oMenu1:bSetGet := { |nRadio| If ( PCount()==0, aDados[3], aDados[3] := nRadio ) }
		oMenu1:SetOption(aDados[3])

		// Custo Preparação
		oMenu2 := TRadMenu():New( 15, 70, aCusto2, , oCusto,,,,,,,, 100, 12,,,, .T.)
		oMenu2:bSetGet := { |nRadio| If ( PCount()==0, aDados[4], aDados[4] := nRadio ) }
		oMenu2:SetOption(aDados[4])

		// Preço Item
		oMenu3 := TRadMenu():New( 15, 165, aPreco, , oPreco,,,,,,,, 100, 12,,,, .T.)
		oMenu3:bSetGet := { |nRadio| If ( PCount()==0, aDados[5], aDados[5] := nRadio ) }
		oMenu3:SetOption(aDados[5])

		TSay():New( 90, 15 , {|| STR0037 }, oDetalhe,,,,,, .T., CLR_BLACK, CLR_WHITE, 200, 20 ) // Quantidade
		TSay():New( 90, 95 , {|| STR0043 }, oDetalhe,,,,,, .T., CLR_BLACK, CLR_WHITE, 200, 20 ) // Moeda
		@ 98,15  MsGet aDados[8] Size 65 , 10 Of oDetalhe Pixel HasButton PICTURE "@E 9,999,999,999.9999"
		@ 98,95  MsGet cMoeda    Size 45 , 10 Of oDetalhe Pixel HasButton WHEN .F.

		oCheck1 := TCheckBox():New( 95, 170, STR0042, {|u| if( Pcount()>0, aDados[9] := u, aDados[9]) }, oDetalhe, 100, 07 ) // Considera Apenas Componentes DP

		if iDPR == 2
			TSay():New( 115, 15 , {|| STR0033 }, oDetalhe,,,,,, .T., CLR_BLACK, CLR_WHITE, 200, 20 ) // Empresa
			TSay():New( 115, 95 , {|| STR0034 }, oDetalhe,,,,,, .T., CLR_BLACK, CLR_WHITE, 200, 20 ) // Filial
			@ 123,15  MsGet oEmpresa Var aDados[6] Size 54 , 10 Of oDetalhe Pixel HasButton
			@ 123,95  MsGet oFilial  Var aDados[7] Size 54 , 10 Of oDetalhe Pixel HasButton

			oCheck1 := TCheckBox():New( 105, 170, STR0035, {|u| if( Pcount()>0, aDados[10] := u, aDados[10]) }, oDetalhe, 100, 07 ) // Considera Refugo no CustO
			oCheck1 := TCheckBox():New( 115, 170, STR0036, {|u| if( Pcount()>0, aDados[11] := u, aDados[11]) }, oDetalhe, 100, 07 ) // Considera Filial Padrão do Filho
		Else
			oMenu1:Disable()
		Endif

		TButton():New(150,215,STR0038,oDlg,{|| if(DPRC324OK(),oDlg:End(),NIL)},40,10,,,,.T.) // Confirmar
		TButton():New(150,260,STR0039,oDlg,{|| oDlg:End() },40,10,,,,.T.) // Cancelar

		// Ativação da janela de seleção
		Activate MsDialog oDlg Centered
	Else
		DPRXError('DPRC324', 'DPRC324_NAOEXI', 3) // Não existe registro de Produto para o Código e Versão informados
		lRet := .F.
	Endif

Return lRet

//-------------------------------------------------------------------
// DPRC324VDV - Traz as informações de descrição e estado da versão
//-------------------------------------------------------------------
Static Function DPRC324VDV()
	Local lRet := .T.

	dbSelectArea('DG0')
	DG0->(dbSetOrder(1))
	if DG0->(dbSeek(xFilial('DG0')+aResult[1][1]+aResult[1][2]))

		cDesc   := DG0->DG0_DSVR
		cEstado := X3Combo( 'DG0_TPST', DG0->DG0_TPST)
	Elseif IsInCallStack('DPRC324PAR')
		lRet := .F.
	Endif

Return lRet

//-------------------------------------------------------------------
// DPRC324SAL - Salva informações
//-------------------------------------------------------------------
Static Function DPRC324SAL(cItem, cVersao)
	Local lRet := .T.
	Local nI   := 0

	dbSelectArea('DG0')
	DG0->(dbSetOrder(1))
	if DG0->(dbSeek(xFilial('DG0')+cItem+cVersao))

		if DG0->DG0_TPST == '1'
			RecLock("DG0",.F.)

			DG0->DG0_VLCSPO := aResult[1][9]

			if aDados[5] == 1 .OR. aDados[5] == 2 .OR. aDados[5] == 5 // Mensal, On-line, Off-line

				For nI := 1 to 2 // MAT, GGF
					dbSelectArea('DG5')
					DG5->(dbSetOrder(2))
					//DG5_FILIAL+DG5_CDACDV+DG5_NRVRAC+DG5_TPCS+DG5_TPVLCS+DG5_CDMY
					if DG5->(dbSeek(xFilial('DG5')+cItem+cVersao+ALLTRIM(STR(aDados[5]))+ALLTRIM(STR(nI))+"1"))
						RecLock('DG5',.F.)

						if nI == 1
							DG5->DG5_VLCS := aResult[1][4]
						Else
							DG5->DG5_VLCS := aResult[1][3]
						Endif

						MsUnLock()
					Else
						RecLock('DG5',.T.)

						DG5->DG5_FILIAL := xFilial('DG5')
						DG5->DG5_CDACDV := cItem
						DG5->DG5_NRVRAC := cVersao
						DG5->DG5_TPCS   := ALLTRIM(STR(aDados[5]))
						DG5->DG5_TPVLCS := ALLTRIM(STR(nI))
						DG5->DG5_CDMY   := '1'

						if nI == 1
							DG5->DG5_VLCS := aResult[1][4]
						Else
							DG5->DG5_VLCS := aResult[1][3]
						Endif

						MsUnLock()
					Endif
				Next
			Endif

			MsUnLock()
		Else
			DPRXError('DPRC324', 'DPRC324_NAOSAL', 3) // Produto Desenvolvido não pode ter seus valores salvos devida a situação do mesmo.
			lRet := .F.
		Endif
	Else
		DPRXError('DPRC324', 'DPRC324_NAOEXI', 3) // Não existe registro de Produto para o Código e Versão informados
		lRet := .F.
	Endif

Return lRet

//-------------------------------------------------------------------
// DPRC324OK - Calculando com base na versão e parâmetros
//-------------------------------------------------------------------
Function DPRC324OK()
	Local lRet     := .T.
	Local nGGF     := 0
	Local nPRE     := 0
	Local oTabBrw
	Private aTabela
	Private cTabBrw := ''
	Private nGerGGF := 0
	Private nGerMAT := 0
	Private nGerMOD := 0
	Private nGerPRE := 0
	Private nGerOPE := 0
	Private nGerREF := 0
	Private iDPR    := DPRIntegra()
	PRIVATE nPrecisao := SuperGetMV("MV_PRECISA",.F.,4)
	PRIVATE cTipoTemp := SuperGetMV("MV_TPHR",.F.,"C")
	PRIVATE lCusFil   := SuperGetMV("MV_CUSFIL",.F.,"A") == "F"
	PRIVATE lCusEmp	  := SuperGetMv("MV_CUSFIL",.F.,"A") == "E"
	PRIVATE dInicio   := SuperGetMV("MV_ULMES",.F.,SToD("19970101"))+1
	PRIVATE lBat 	  := .T.
	Private lErroQtd  := .F.
	Default lAutoMacao:= .F.

	aTabela := DPRC324TAB()
	IF !lAutoMacao
		oTabBrw := SFCCriFWTa(aTabela)
		cTabBrw := oTabBrw:GetAlias()
	ENDIF
	aResult := {{aDados[1],aDados[2],0,0,0,0,0,0,0}}

	if Empty(aDados[1]) .OR. Empty(aDados[2])
		DPRXError('DPRC324', 'DPRC324_OBRIGA', 3 ) // Produto e Versão devem ser informados.
		lRet := .F.
	Else
		if aDados[8] <= 0
			DPRXError('DPRC324', 'DPRC324_QUANT', 3 ) // Quantidade deve ser maior que zero
			lRet := .F.
		Endif
	Endif

	if lRet

		dbSelectArea('DG0')
		DG0->(dbSetOrder(1))
		if DG0->(dbSeek(xFilial('DG0')+aDados[1]+aDados[2]))

			DPRC324CAL(0,; // Nivel
			DG0->DG0_CDACDV,; // Item
			DG0->DG0_NRVRAC,; // Versao
			aDados[8],;
				aDados[8]) // Quantidade

			dbSelectArea("DG1")
			DG1->(dbSetOrder(1))
			DG1->(dbSeek(xFilial('DG1')+DG0->DG0_CDACDV+DG0->DG0_NRVRAC))

			aRetorno := DPRA324OPE(DG0->DG0_CDACDV,DG0->DG0_NRVRAC,1 / DG0->DG0_QTACEA, aDados[8])
			nPRE := aRetorno[1]
			nGGF := aRetorno[2]

			if aDados[4] == 1
				nPRE := 0
			Elseif aDados[4] == 3
				nPRE := nPRE * aDados[8]
			Endif

			aResult[1][3] := nGerGGF + (nGGF * aDados[8])
			aResult[1][4] := nGerMAT
			aResult[1][5] := nGerMOD
			aResult[1][6] := nGerPRE + nPRE
			aResult[1][7] := nGerOPE
			aResult[1][8] := nGerREF
			aResult[1][9] := aResult[1][3] + nGerMAT + nGerMOD + nGerOPE + aResult[1][6] + nGerREF

			if !lErroQtd
				DPRC324EXL()
			Else
				DPRXError('DPRC324', 'Não foi possível concluir o cálculo devido ao estouro de campo de valor.' )
				lRet := .F.
			Endif
		Endif
	Endif

	IF !lAutoMacao
		oTabBrw:Delete()
	ENDIF

Return lRet

//-------------------------------------------------------------------
// DPRC324OK - Calculando com base na versão e parâmetros
// Recebe: nivel   - nivel na estrutura
//         produto - item desenvolvido
//         versao  - Versão do Produto
//         Quantidade
//-------------------------------------------------------------------
Static Function DPRC324CAL(iNivel, cProd, cVers, nQuant, nQuantOrig)
	Local lRet   := .T.
	Local nGGF   := 0
	Local nMAT   := 0
	Local nMOD   := 0
	Local nPRE   := 0
	Local nOPE   := 0
	Local nREF   := 0
	Local nQtAux := 0
	Local nOper  := 0
	Local nPrep  := 0
	Local nPosDG1, nPosDG0
	Local aRetorno := {}
	Local cCompon := ''
	Local cVersCp := ''

	dbSelectArea('DG0')
	DG0->(dbSetOrder(1))
	DG0->(dbSeek(xFilial('DG0')+cProd+cVers))

// Verifica se existe estrutura para o item
	dbSelectArea('DG1')
	DG1->(dbSetOrder(1))
	if DG1->(dbSeek(xFilial('DG1')+DG0->DG0_CDACDV+DG0->DG0_NRVRAC))

		// Le todos os componentes
		While DG1->(!EOF()) .AND. DG1->DG1_CDACDV == DG0->DG0_CDACDV .AND. DG1->DG1_NRVRAC == DG0->DG0_NRVRAC

			// Desenvolvido
			if DG1->DG1_LGMTDV == '1'

				nProp := DG1->DG1_VLPN / 100
				nOper := 0
				nPrep := 0

				nQtAux := (DG1->DG1_QTMT / DG1->DG1_QTAC) * nProp

				nPosDG1 := DG1->(Recno())
				nPosDG0 := DG0->(Recno())

				if !aDados[9] // Desce até último nível e não soma DP
					// Operações
					DPRA324OPE(DG1->DG1_CDMTDV,DG1->DG1_NRVRMT,nQtAux,nQuant)

					cCompon := DG1->DG1_CDMTDV
					cVersCp := DG1->DG1_NRVRMT

					dbSelectArea('DG1')
					DG1->(dbSetOrder(1))
					if DG1->(dbSeek(xFilial('DG1')+DG1->DG1_CDMTDV+DG1->DG1_NRVRMT))
						DPRC324CAL(iNivel + 1, DG1->DG1_CDACDV, DG1->DG1_NRVRAC, nQtAux * nQuant, nQuantOrig)
					Else
						aRetorno := DPRC324VAL(cCompon,cVersCp)

						nMAT := aRetorno[1]
						nGGF := aRetorno[2]
						nMOD := aRetorno[3]
					Endif
				Else
					aRetorno := DPRC324VAL(DG1->DG1_CDMTDV,DG1->DG1_NRVRMT)

					nMAT := aRetorno[1]
					nGGF := aRetorno[2]
					nMOD := aRetorno[3]
				Endif

				DG1->(dbGoTo(nPosDG1))
				DG0->(dbGoTo(nPosDG0))
			Else // Engenharia
				IF !aDados[9] // Desce até último nível e não soma DP

					nProp := DG1->DG1_VLPN / 100

					aCusto := CusFabItem(DG1->DG1_CDMT,aDados[5],1)

					nGGF := aCusto[3]
					nMAT := aCusto[1]
					nMOD := 0
					nPRE := aCusto[2]
					nOPE := 0
					nREF := 0
				Else
					nProp := 1
				Endif
			Endif

			RecLock(cTabBrw, .T.)
			(cTabBrw)->PRODUTO := DG1->DG1_CDACDV
			(cTabBrw)->VERSAO  := DG1->DG1_NRVRAC
			(cTabBrw)->COMPON  := if(DG1->DG1_LGMTDV == '1', DG1->DG1_CDMTDV, DG1->DG1_CDMT)
			(cTabBrw)->VERSCP  := DG1->DG1_NRVRMT
			(cTabBrw)->TIPO    := "1"

			nTeste := Transform(nGGF * nProp * (DG1->DG1_QTMT / DG1->DG1_QTAC) * nQuant, x3Picture('DG0_VLPJ'))
			if Subs(nTeste,1,1) == '*'
				(cTabBrw)->GGF := 0
				lErroQtd       := .T.
			Else
				(cTabBrw)->GGF := nGGF * nProp * (DG1->DG1_QTMT / DG1->DG1_QTAC) * nQuant
			Endif

			nTeste := Transform(nMOD * nProp * (DG1->DG1_QTMT / DG1->DG1_QTAC) * nQuant, x3Picture('DG0_VLPJ'))
			if Subs(nTeste,1,1) == '*'
				(cTabBrw)->MOD := 0
				lErroQtd       := .T.
			Else
				(cTabBrw)->MOD := nMOD * nProp * (DG1->DG1_QTMT / DG1->DG1_QTAC) * nQuant
			Endif

			nTeste := Transform(nMAT * nProp * (DG1->DG1_QTMT / DG1->DG1_QTAC) * nQuant, x3Picture('DG0_VLPJ'))
			if Subs(nTeste,1,1) == '*'
				(cTabBrw)->MAT := 0
				lErroQtd       := .T.
			Else
				(cTabBrw)->MAT := nMAT * nProp * (DG1->DG1_QTMT / DG1->DG1_QTAC) * nQuant
			Endif

			IF aDados[4] == 2
				nTeste := Transform(nPRE * nProp, x3Picture('DG0_VLPJ'))

				if Subs(nTeste,1,1) == '*'
					(cTabBrw)->PREP := 0
					lErroQtd       := .T.
				Else
					(cTabBrw)->PREP := nPRE * nProp
				Endif
			ElseIf aDados[4] == 3
				nTeste := Transform(nPRE * nProp * (DG1->DG1_QTMT / DG1->DG1_QTAC) * nQuant, x3Picture('DG0_VLPJ'))

				if Subs(nTeste,1,1) == '*'
					(cTabBrw)->PREP := 0
					lErroQtd       := .T.
				Else
					(cTabBrw)->PREP := nPRE * nProp * (DG1->DG1_QTMT / DG1->DG1_QTAC) * nQuant
				Endif
			Endif

			MsUnlock()

			nGerGGF += nGGF * nProp * (DG1->DG1_QTMT / DG1->DG1_QTAC) * nQuant
			nGerMAT += nMAT * nProp * (DG1->DG1_QTMT / DG1->DG1_QTAC) * nQuant
			nGerMOD += nMOD * nProp * (DG1->DG1_QTMT / DG1->DG1_QTAC) * nQuant
			nGerOPE += nOPE * nProp
			nGerREF += nREF * nProp * (DG1->DG1_QTMT / DG1->DG1_QTAC) * nQuant

			if aDados[4] == 2 // Preparação Ordem
				nGerPRE += nPRE * nProp
			ElseIf aDados[4] == 3 // Preparação x Quantidade
				nGerPRE += nPRE * nProp * (DG1->DG1_QTMT / DG1->DG1_QTAC) * nQuant
			Endif

			nGGF  := 0
			nMAT  := 0
			nMOD  := 0
			nPRE  := 0
			nOPE  := 0
			nREF  := 0

			DG1->(dbSkip())
		End
	Else
		if iNivel == 0
			aRetorno := DPRC324VAL(DG0->DG0_CDACDV,DG0->DG0_NRVRAC)

			nGerMAT := aRetorno[1] * nQuant
			nGerGGF := aRetorno[2] * nQuant
			nGerMOD := aRetorno[3] * nQuant
		Endif
	Endif

Return lRet

//-------------------------------------------------------------------
// DPRC324TAB - Define a tabela a ser utilizada no browsw
//-------------------------------------------------------------------
Static Function DPRC324TAB()
	Local nI   := 0
	Local aDBF := {}
	Local aRes := {}
	Local aRes2:= {}

	aDBF := {{ "PRODUTO", "C", 0, 0, STR0004, .T. , "@!" , "DG0_CDACDV" } , ; // Produto Desenvolvido
	{ "VERSAO" , "C", 0, 0, STR0002, .T. , "@!" , "DG0_NRVRAC" } , ; // Versão
	{ "COMPON" , "C", 0, 0, STR0045, .T. , "@!" , "DG0_CDACDV" } , ; // Componente
	{ "VERSCP" , "C", 0, 0, STR0046, .T. , "@!" , "DG0_NRVRAC" } , ; // Versão Componente
	{ "TIPO"   , "C", 1, 0, STR0059, .T. , "@!" , ""           } , ; // Tipo
	{ "OPERAC" , "C", 0, 0, STR0060, .T. , "@!" , "EXCEPT_DG9" } , ; // Operação
	{ "PRODMOD", "C", 0, 0, STR0061, .T. , "@!" , "B1_COD"     } , ; // Produto MOD
	{ "GGF"    , "N", 0, 0, STR0007, .T. , "@!" , "DG0_VLPJ"   } , ; // Gastos Gerais de Fabricação
	{ "MOD"    , "N", 0, 0, STR0009, .T. , "@!" , "DG0_VLPJ"   } , ; // Mão de Obra
	{ "PREP"   , "N", 0, 0, STR0010, .T. , "@!" , "DG0_VLPJ"   } , ; // Preparação
	{ "MAT"    , "N", 0, 0, STR0008, .T. , "@!" , "DG0_VLPJ"   } } // Matéria Prima

	For nI := 1 to len(aDBF)
		If !Empty(aDBF[nI][8])
			If aDBF[nI][8] = "EXCEPT_DG9"
				aRes := TamSx3("DG9_CDAT")
				aRes2:= TamSx3("DG9_DSAT")
				aDBF[nI][3] := aRes[1] + aRes2[1] + 3 // Tamanho
				aDBF[nI][7] := "@!" // Picture
			Else
				aRes := TamSx3(aDBF[nI][8])
				aDBF[nI][3] := aRes[1] // Tamanho
				aDBF[nI][4] := aRes[2] // Decimais
				aDBF[nI][2] := aRes[3] // Tipo
				aDBF[nI][7] := x3picture(aDBF[nI][8]) // Picture
			EndIf
		EndIf
	Next

Return { aDBF , {"PRODUTO", "VERSAO", "TIPO", "COMPON", "VERSCP", "OPERAC"} }

//-------------------------------------------------------------------
// DPRC324EXL - Gera Excel
//-------------------------------------------------------------------
Static Function DPRC324EXL()
	Local aCabExcel   := {}
	Local aItensExcel := {}
	Local aItem       := {}
	Local aCols       := {}
	Local aRes
	Local lExcel      := .F.
	Local iDPR        := DPRIntegra()
	Local aAux		   := {}
	Local nI, nJ
	Default lAutoMacao := .F.

	If ! ( GetRemoteType() == 5 )
		lExcel := ApOleClient("MsExcel")
	EndIf

	aRes := TamSx3('DG0_VLPJ')

	if !lExcel
		if iDPR == 2
			cLog := STR0047 + ';' + ; // PRODUTO
			STR0048 + ';' + ; // VERSÃO
			STR0049 + ';' + ; // COMPONENTE
			STR0050 + ';' + ; // VERSÃO COMPON
			STR0059 + ';' + ; // TIPO
			STR0060 + ';' + ; // OPERAÇÃO
			STR0061 + ';' + ; // PRODUTO MOD
			STR0051 + ';' + ; // $ MATERIAL
			STR0052 + ';' + ; // $ MÃO DE OBRA
			STR0053 + ';' + ; // $ PREPARAÇÃO
			STR0054 + ';' + PULALINHA // $ GGF
		Else
			cLog := STR0047 + ';' + ; // PRODUTO
			STR0048 + ';' + ; // VERSÃO
			STR0049 + ';' + ; // COMPONENTE
			STR0050 + ';' + ; // VERSÃO COMPON
			STR0059 + ';' + ; // TIPO
			STR0060 + ';' + ; // OPERAÇÃO
			STR0061 + ';' + ; // PRODUTO MOD
			STR0051 + ';' + ; // $ MATERIAL
			STR0053 + ';' + ; // $ PREPARAÇÃO
			STR0054 + ';' + PULALINHA // $ GGF
		Endif
	Else
		// AADD(aCabExcel, {"TITULO DO CAMPO", "TIPO", NTAMANHO, NDECIMAIS})
		AADD(aCabExcel, {STR0047, "C", TamSx3('DG0_CDACDV')[1], 0}) // PRODUTO
		AADD(aCabExcel, {STR0048, "C", TamSx3('DG0_NRVRAC')[1], 0}) // VERSÃO
		AADD(aCabExcel, {STR0049, "C", TamSx3('DG0_CDACDV')[1], 0}) // COMPONENTE
		AADD(aCabExcel, {STR0050, "C", TamSx3('DG0_NRVRAC')[1], 0}) // VERSÃO COMPON
		AADD(aCabExcel, {STR0059, "N", 1, 0}) // TIPO
		AADD(aCabExcel, {STR0060, "C", TamSx3('DG9_CDAT')[1] + TamSx3('DG9_DSAT')[1] + 3, 0}) // OPERAÇÃO
		AADD(aCabExcel, {STR0061, "C", TamSx3('B1_COD')[1], 0}) // PRODUTO MOD
		AADD(aCabExcel, {STR0051, "N", aRes[1], aRes[2]}) // $ MATERIAL

		if iDPR == 2
			AADD(aCabExcel, {STR0052, "N", aRes[1], aRes[2]}) // $ MÃO DE OBRA
		Endif

		AADD(aCabExcel, {STR0053, "N", aRes[1], aRes[2]}) // $ PREPARAÇÃO
		AADD(aCabExcel, {STR0054, "N", aRes[1], aRes[2]}) // $ GGF
		AADD(aCabExcel, {""     , "N", aRes[1], aRes[2]})
	Endif

	IF !lAutoMacao
		dbSelectArea(cTabBrw)
		(cTabBrw)->(dbGoTop())
		While (cTabBrw)->(!EOF())
			if lExcel
				aItem := Array(Len(aCabExcel))

				aItem[1] := (cTabBrw)->PRODUTO
				aItem[2] := (cTabBrw)->VERSAO
				aItem[3] := (cTabBrw)->COMPON
				aItem[4] := (cTabBrw)->VERSCP

				aItem[5] := If( (cTabBrw)->TIPO == "1" ,STR0063,STR0062)
				aItem[6] := (cTabBrw)->OPERAC
				aItem[7] := (cTabBrw)->PRODMOD

				aItem[8] := (cTabBrw)->MAT

				if iDPR == 2
					aItem[9] := (cTabBrw)->MOD
					aItem[10] := (cTabBrw)->PREP
					aItem[11] := (cTabBrw)->GGF
				Else
					aItem[9] := (cTabBrw)->PREP
					aItem[10] := (cTabBrw)->GGF
				Endif

				AADD(aCols,aItem)
				aItem := {}
			Else
				if iDPR == 2
					cLog += ALLTRIM((cTabBrw)->PRODUTO)  + ';' + ;
						ALLTRIM((cTabBrw)->VERSAO)    + ';' + ;
						ALLTRIM((cTabBrw)->COMPON)    + ';' + ;
						ALLTRIM((cTabBrw)->VERSCP)    + ';' + ;
						ALLTRIM((cTabBrw)->TIPO)		  + ';' + ;
						If( (cTabBrw)->TIPO == "1" ,STR0063,STR0062) + ';' + ;
							ALLTRIM((cTabBrw)->OPERAC)    + ';' + ;
							ALLTRIM((cTabBrw)->PRODMOD)   + ';' + ;
							ALLTRIM(STR((cTabBrw)->MAT))  + ';' + ;
							ALLTRIM(STR((cTabBrw)->MOD))  + ';' + ;
							ALLTRIM(STR((cTabBrw)->PREP)) + ';' + ;
							ALLTRIM(STR((cTabBrw)->GGF))  + ';' + PULALINHA
						Else
							cLog += ALLTRIM((cTabBrw)->PRODUTO)  + ';' + ;
									ALLTRIM((cTabBrw)->VERSAO)    + ';' + ;
									ALLTRIM((cTabBrw)->COMPON)    + ';' + ;
									ALLTRIM((cTabBrw)->VERSCP)    + ';' + ;
							If( (cTabBrw)->TIPO == "1" ,STR0063,STR0062) + ';' + ;
								ALLTRIM((cTabBrw)->OPERAC)    + ';' + ;
								ALLTRIM((cTabBrw)->PRODMOD)   + ';' + ;
								ALLTRIM(STR((cTabBrw)->MAT))  + ';' + ;
								ALLTRIM(STR((cTabBrw)->PREP)) + ';' + ;
								ALLTRIM(STR((cTabBrw)->GGF))  + ';' + PULALINHA
						Endif
					Endif

			(cTabBrw)->(dbSkip())
		End
	ENDIF

	if lExcel
		MsgRun(STR0055, STR0056,{||DlgToExcel({{"GETDADOS",STR0057,aCabExcel,aCols}})}) // Favor Aguardar.. ## Exportando os Registros para o Arquivo ## Detalhe Custo Fabricação
	Else
		If GetRemoteType() == 5
			MsgInfo(STR0064, STR0065) // "Relatório não disponível para visualização no SmartCliente HTML." ### "Aviso"
		Else
			MemoWrite('c:\custoFabricação.CSV', cLog)
			DPRXError('DPRC324',STR0058 + 'c:\custoFabricação.CSV',2)
		EndIf
	Endif

Return

//-------------------------------------------------------------------
// DPRC324VAL - Verifica valores da versão
//-------------------------------------------------------------------
Static Function DPRC324VAL(cProd, cVers)
	Local nMAT := 0
	Local nGGF := 0
	Local nMOD := 0
	Local nI   := 0

// Vai apenas até o nível DP
	if aDados[5] == 1 .OR. aDados[5] == 2 .OR. aDados[5] == 5 // Mensal, On-line, Off-line

		For nI := 1 to 3 // MAT, GGF, MOD
			dbSelectArea('DG5')
			DG5->(dbSetOrder(1))
			if DG5->(dbSeek(xFilial('DG5')+cProd+cVers+ALLTRIM(STR(aDados[5]))+ALLTRIM(STR(nI))+'1'))
				Do Case
				Case nI == 1
					nMAT := DG5->DG5_VLCS
				Case nI == 2
					nGGF := DG5->DG5_VLCS
				Case nI == 3
					nMOD := DG5->DG5_VLCS
				End Case
			Endif
		Next
	Else
		// Busca a versão do componente
		dbSelectArea('DG0')
		DG0->(dbSetOrder(1))
		DG0->(dbSeek(xFilial('DG0')+cProd+cVers))

		Do Case
		Case aDados[5] == 3 // Reposição
			nMAT := DG0->DG0_VLPRRO
		Case aDados[5] == 4 // Última Entrada
			nMAT := DG0->DG0_VLULEN
		End Case
	Endif

Return {nMAT, nGGF, nMOD}

//-------------------------------------------------------------------
// DPRC324VAL - Verifica operações da versão
//-------------------------------------------------------------------
Static Function DPRA324OPE(cProd, cVers, nProp, nQuant)
	Local nPRE := 0
	Local nGGF := 0
	Local nValor := 0
	Local nUnit  := 0
	PRIVATE lCusFil := SuperGetMV("MV_CUSFIL",.F.,"A") == "F"
	PRIVATE lCusEmp := SuperGetMv("MV_CUSFIL",.F.,"A") == "E"
	PRIVATE dInicio := SuperGetMV("MV_ULMES",.F.,SToD("19970101"))+1
	PRIVATE lBat    := .T.
	PRIVATE lOpenTRT := .F.

	dbSelectArea('DG9')
	DG9->(dbSetOrder(1))
	if DG9->(dbSeek(xFilial('DG9')+cProd+cVers))
		While DG9->(!EOF()) .AND. DG9->DG9_CDACDV == cProd .AND. DG9->DG9_NRVRAC == cVers
			iF DG9->DG9_DTBG <= date() .AND. DG9->DG9_DTED > date()

				nValor := CusUnitMOD(aDados[5],DG9->DG9_CDMQ,@lOpenTRT)

				nUnit := nValor / DG9->DG9_NRUNAC

				Do Case
				Case DG9->DG9_TPUNTE == "1"
					nGGF += DG9->DG9_QTTEMQ * nUnit
				Case DG9->DG9_TPUNTE == "2"
					nGGF += DG9->DG9_QTTEMQ / 60 * nUnit
				Case DG9->DG9_TPUNTE == "3"
					nGGF += DG9->DG9_QTTEMQ / 3600 * nUnit
				Case DG9->DG9_TPUNTE == "4"
					nGGF += DG9->DG9_QTTEMQ * 24 * nUnit
				end Case

				If aDados[4] == 2
					nPRE := DG9->DG9_QTTESU * nValor
				Elseif aDados[4] == 3
					nPRE := DG9->DG9_QTTESU * nValor * nProp * nQuant
				EndIf

				nGGF := nGGF * nProp * nQuant

				RecLock(cTabBrw, .T.)
				(cTabBrw)->PRODUTO := cProd
				(cTabBrw)->VERSAO  := cVers
				(cTabBrw)->COMPON  := ""
				(cTabBrw)->VERSCP  := ""
				(cTabBrw)->PREP    := nPRE
				(cTabBrw)->GGF     := nGGF
				(cTabBrw)->TIPO    := "2"
				(cTabBrw)->OPERAC  := DG9->DG9_CDAT + " - " + DG9->DG9_DSAT
				(cTabBrw)->PRODMOD := PadR(APrModRec(DG9->DG9_CDMQ),TamSX3("B1_COD")[1])
				MsUnlock()

				nGerGGF += nGGF
				nGerPRE += nPRE
				nPRE := 0
				nGGF := 0
			Endif

			DG9->(dbskip())
		End
	Endif

Return {nPRE, nGGF}
