// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º  09    º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#Include "PROTHEUS.CH" 
#Include "OFIOM450.CH"

/*/{Protheus.doc} mil_ver()
    Versao do fonte modelo novo

    @author Vinicius Gati
    @since  12/08/2015
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "007756_1"

/*/{Protheus.doc} OFIOM450
	@author       Luis Delorme
	@since        27/10/2013
	@description  Requisição e Devolução de Ferramentas
/*/
Function OFIOM450()
	Private lOM450Req := .T.
	Private oReqFer := Mil_RequisicaoFerramenta():New()
	Private aRotina := MenuDef()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define o cabecalho da tela de atualizacoes                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private cCadastro := OemToAnsi(STR0005)
	Private nUsado    := 0
	Private cAlmBFer  := GetNewPar("MV_MIL0020", '') // BLOQUEADO FERRAMENTAS     
	Private cDocumento := ""
	
	If(Empty(cAlmBFer))
		Alert(STR0021) // explicação de necessidade de parametro
		Return
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Endereca a funcao de BROWSE                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	mBrowse( 6, 1, 22, 75, "VDP" )
Return

/*/{Protheus.doc} OA450D
	@author       Luis Delorme
	@since        27/10/2013
	@description  Chama função padrão de novo row porém de devolução
/*/
Function OA450D(cAlias, nReg, nOpc)
	lOM450Req := .F. // Devolucao
	OA450(cAlias, nReg, nOpc)
	lOM450Req := .T.
return

/*/{Protheus.doc} OA450
	@author       Luis Delorme
	@since        27/10/2013
	@description  Monta Tela
/*/
Function OA450(cAlias, nReg, nOpc)
	Local oSize     := FwDefSize():New(.T.) // Com enchoicebar
	Local bCampo    := { |nCPO| Field(nCPO) }, nCntFor := 0, _ni := 0, _lRet := .T.
	Local nPosRec   := 0
	Local cTitulo, cAliasEnchoice, cAliasGetD, cLinOk, cTudOk, cFieldOk
	Local nQtdTot   := nQtdReq := nQtdDev := 0
	Local laCols    := .T.
	Local lVDP_NUMOSV := VDP->(FieldPos("VDP_NUMOSV")) <> 0
	Local lVD3_LOCAL := VD3->(FieldPos("VD3_LOCAL")) <> 0
	Local cSlvcCad  := ""

	Private nRecVDP := 0
	Private aCols   := {}
	Private aHeader := {}
	Private aCpoEnchoice := {}
	Private aTELA[0][0], aGETS[0]
	Private nLenAcols := 0

	If Type("cCadastro") == "U"
		cCadastro := ""
	EndIf
	cSlvcCad := cCadastro

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Opcoes de acesso para a Modelo 3                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpc == 4
		nOpcE  := 2
		nOpcG  := 4
		Inclui := .F.
		Altera := .T.
	Else
		nOpcE := nOpcG := nOpc
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria variaveis M->????? da Enchoice                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RegToMemory("VDP", Inclui)

	aCpoEnchoice := {}

	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek("VDP")

	While !Eof() .And. (x3_arquivo == "VDP")
		If X3USO(x3_usado) .And. cNivel >= x3_nivel .And. Alltrim(x3_campo) != "VDP_TIPMOV"
			AADD(aCpoEnchoice, x3_campo)
			//&("M->"+x3_campo) := CriaVar(x3_campo)
		EndIf

		dbSkip()
	EndDo

	If !(Inclui)
		DbSelectArea("VDP")
		nRecVDP := VDP->(RecNo()) // VDP posicionado no Browse

		For nCntFor := 1 TO FCount()
			M->&(EVAL(bCampo, nCntFor)) := FieldGet(nCntFor)
		Next

		If nOpc == 4
			M->VDP_TIPMOV := "0"
		ElseIf nOpc == 2
			If M->VDP_TIPMOV == "1"
				cCadastro += " "+STR0051 // Requisição
			Else
				cCadastro += " "+STR0052 // Devolução
			EndIf
		EndIf
	Else
		M->VDP_TIPMOV := "1"
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria aHeader e aCols da GetDados                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nUsado := 0

	dbSelectArea("SX3")
	DbSetOrder(1)
	dbSeek("VD3")
	aHeader := {}

	While !Eof() .And. (x3_arquivo == "VD3")
		If X3USO(x3_usado) .And. cNivel >= x3_nivel;
			.And. !(Alltrim(x3_campo) $ "VD3_CODIGO.VD3_SEQUEN.VD3_NUMOSV.VD3_TIPTEM";
			+ Iif(M->VDP_TIPMOV == "1".or.nOpc==2, ".VD3_QTDDEV", "")) // Tipo Requisição ou Visualizar não traz o campo
			nUsado := nUsado + 1

			Aadd(aHeader, { TRIM(X3Titulo()), x3_campo, x3_picture,;
				x3_tamanho, x3_decimal,x3_valid,;
				x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv })
			&("M->"+x3_campo) := CriaVar(x3_campo)
		EndIf

		dbSkip()
	EndDo

	// Inclui coluna de registro atraves de funcao generica
	dbSelectArea("VD3")
	ADHeadRec("VD3", aHeader)

	// Posicao do registro
	nPosRec := Len(aHeader)
	nUsado  := Len(aHeader)

	aCols   := {}

	dbSelectArea("VD3")
	dbSetOrder(1)
	VD3->(dbSeek(xFilial("VD3") + M->VDP_CODIGO))

	// 'Devolver' e Tipo Devolucao nao pega row do VDP setado para mostrar na tela, só requisição
	If nOpc == 3 .Or. !VD3->(Found()) .Or. (nOpc == 4 .And. (VDP->(Eof())))
		// cabeçalho e row em branco
		aCols := { Array(nUsado + 1) }
		aCols[1, nUsado + 1] := .F.

		For _ni:=1 to nUsado
			If IsHeadRec(aHeader[_ni,2])
				aCols[Len(aCols),_ni] := 0
			ElseIf IsHeadAlias(aHeader[_ni,2])
				aCols[Len(aCols),_ni] := "VD3"
			Else
				aCols[1,_ni] := CriaVar(aHeader[_ni,2])
			EndIf
		Next
	Else
		While !eof() .And. VD3->VD3_FILIAL == xFilial("VD3") .And. M->VDP_CODIGO == VD3->VD3_CODIGO
			// Caso Tipo Devolução de Ferramenta
			If M->VDP_TIPMOV == "0"
				// Verificar se já foi totalmente devolvida para não listar no grid
				cQuery := "SELECT SUM(VD3.VD3_QTDMOV) AS QTD "
				cQuery += "FROM " + RetSQLName("VD3") + " VD3 "
				cQuery += "WHERE VD3.VD3_FILIAL = '" + xFilial("VD3") + "' "
				cQuery += "  AND VD3.VD3_CODPRO = '" + VD3->VD3_CODPRO + "' "

				If lVDP_NUMOSV
					cQuery += "  AND VD3.VD3_NUMOSV = '" + VD3->VD3_NUMOSV + "' "
					cQuery += "  AND VD3.VD3_TIPTEM = '" + VD3->VD3_TIPTEM + "' "
				EndIf

				cQuery += "  AND VD3.VD3_CODFER = '" + VD3->VD3_CODFER + "' "
				cQuery += "  AND VD3.D_E_L_E_T_=' ' "

				// Requisitadas
				nQtdReq := FM_SQL(cQuery + " AND VD3.VD3_TIPMOV = '1'")

				// Devolvidas
				nQtdDev := FM_SQL(cQuery + " AND VD3.VD3_TIPMOV = '0'")

				// Caso Devolver não lista, caso Visualizar (nOpc == 2) lista
				If nOpc == 4 .And. (nQtdDev >= nQtdReq)
					laCols := .F.
				Else
					laCols := .T.
				EndIf
			EndIf

			If laCols
				AADD(aCols, Array(nUsado + 1))

				For _ni := 1 to nUsado
					If IsHeadRec(aHeader[_ni,2])
						aCols[Len(aCols), _ni] := VD3->(RecNo())
					ElseIf IsHeadAlias(aHeader[_ni,2])
						aCols[Len(aCols), _ni] := "VD3"
					Else
						aCols[Len(aCols), _ni] := IIf( aHeader[_ni,10] # "V", FieldGet(FieldPos(aHeader[_ni,2])), CriaVar(aHeader[_ni,2]))
					EndIf
				Next

				aCols[Len(aCols), nUsado + 1] := .F.

				If !(Inclui)
					DBSelectArea("VO9")
					DBSetOrder(1) // VO9_FILIAL+VO9_CODFER
					DBSeek(xFilial("VO9") + VD3->VD3_CODFER)

					DBSelectArea("SB1")
					DBSetOrder(1)
					DBSeek(xFilial("SB1") + VO9->VO9_CODPRO)

					If !lVD3_LOCAL
						M->VD3_LOCAL := FM_PRODSBZ(SB1->B1_COD, "SB1->B1_LOCPAD")
					EndIf

					DbSelectArea("SB5")
					DBSetOrder(1)
					DbSeek(xFilial("SB5") + VO9->VO9_CODPRO)

					If FG_POSVAR("VD3_LOCALI") > 0 
						aCols[Len(aCols), FG_POSVAR("VD3_LOCALI")] := FM_PRODSBZ(SB1->B1_COD, "SB5->B5_LOCALI2")
					EndIf

					// Caso Tipo Devolução de Ferramenta
					If M->VDP_TIPMOV == "0" .And. FG_POSVAR("VD3_QTDDEV") > 0
						M->VD3_QTDDEV := nQtdReq - nQtdDev

						aCols[Len(aCols), FG_POSVAR("VD3_QTDDEV")] := M->VD3_QTDDEV
					EndIf

					If GetNewPar("MV_MIL0076","S") == "S" // Controla Estoque no SB2
						DBSelectArea("SB2")
						DBSetOrder(1) // B2_FILIAL+B2_COD+B2_LOCAL

						nSaldoFer := 0
						If DBSeek(xFilial("SB2") + VO9->VO9_CODPRO + IIF(M->VDP_TIPMOV == "1", M->VD3_LOCAL, cAlmBFer))
							nSaldoFer := SaldoSb2()
						EndIf

						M->VD3_QTDDIS := nSaldoFer

						aCols[Len(aCols), FG_POSVAR("VD3_QTDDIS")] := nSaldoFer
					Else
						cQuery := "SELECT SUM(VD3.VD3_QTDMOV) AS QTD "
						cQuery += "FROM " + RetSQLName("VD3") + " VD3 "
						cQuery += "WHERE VD3.VD3_FILIAL = '" + xFilial("VD3") + "' "
						cQuery += "  AND VD3.VD3_CODFER = '" + VD3->VD3_CODFER + "' "
						cQuery += "  AND VD3.D_E_L_E_T_=' ' "

						// Requisitadas
						nQtdReq := FM_SQL(cQuery + " AND VD3.VD3_TIPMOV = '1'")

						// Devolvidas
						nQtdDev := FM_SQL(cQuery + " AND VD3.VD3_TIPMOV = '0'")

						// Total
						cQuery := "SELECT SUM(VO9.VO9_QTDFER) AS QTD "
						cQuery += "FROM " + RetSQLName("VO9") + " VO9 "
						cQuery += "WHERE VO9.VO9_FILIAL = '" + xFilial("VO9") + "' "
						cQuery += "  AND VO9.VO9_CODFER = '" + VD3->VD3_CODFER + "' "
						cQuery += "  AND VO9.D_E_L_E_T_=' ' "
						nQtdTot := FM_SQL(cQuery)

						M->VD3_QTDDIS := nQtdTot + (nQtdDev - nQtdReq)

						aCols[Len(aCols), FG_POSVAR("VD3_QTDDIS")] := M->VD3_QTDDIS
					EndIf
				EndIf
			EndIf

			DbSelectArea("VD3")
			dbSkip()
		EndDo

		nLenaCols := Len(aCols)
	EndIf

	If nOpc == 4 // alterar/devolver
		nOpc          := 3
		Inclui        := .T.
		Altera        := .F.
		M->VDP_TIPMOV := "0"
	EndIf

	If nOpc == 3 // incluir/requisitar
		M->VDP_CODIGO = GetSXENum('VDP', 'VDP_CODIGO')

		ROLLBACKSXE()
	EndIf

	If Len(aCols) > 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Executa a Modelo 3                                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cTitulo        := STR0005
		cAliasEnchoice := "VDP"
		cAliasGetD     := "VD3"
		cLinOk         := "FG_OBRIGAT() .And. OM450VQTD()"
		cTudOk         := "AllwaysTrue()"
		cFieldOk       := "OA450FOK() .And. FG_MEMVAR()"

		// Calcula as dimensões dos objetos
		oSize:lLateral := .F. // Cálculo vertical

		oSize:AddObject("ENCHOICE", 0,  40, .T., .F.) // Adiciona Enchoice
		oSize:AddObject("GETDADOS", 0, 100, .T., .T.) // Adiciona Getdados

		// Dispara o cálculo
		oSize:Process()

		// Desenha a Dialog
		DEFINE MSDIALOG oOFIOM450 TITLE cTitulo FROM oSize:aWindSize[1], oSize:aWindSize[2] TO;
			oSize:aWindSize[3], oSize:aWindSize[4] PIXEL

		// Monta a Enchoice
		oEnChoice := MsMGet():New(cAliasEnchoice, nReg, nOpcE,,,, aCpoEnchoice                  ,;
			{oSize:GetDimension("ENCHOICE", "LININI"), oSize:GetDimension("ENCHOICE", "COLINI") ,;
			 oSize:GetDimension("ENCHOICE", "LINEND"), oSize:GetDimension("ENCHOICE", "COLEND")},;
			 , 3,,,,,, .F.)

		// Monta a Getdados
		oGetDados := MSGetDados():New(oSize:GetDimension("GETDADOS", "LININI"), ;
			oSize:GetDimension("GETDADOS", "COLINI"),                           ;
			oSize:GetDimension("GETDADOS", "LINEND"),                           ;
			oSize:GetDimension("GETDADOS", "COLEND"), nOpcG, cLinOk, cTudOk, "",;
			IIf(nOpcG > 2 .And. nOpcG < 5, .T., .F.),,,,, cFieldOk)

		oGetDados:oBrowse:bChange := {|| FG_AALTER("VD3", nLenaCols, oGetDados) }

		// Dispara a tela com os objetos montados
		ACTIVATE MSDIALOG oOFIOM450 ON INIT EnchoiceBar(oOFIOM450, {|| IIf(oGetDados:TudoOk() .And.;
			obrigatorio(aGets, aTela) .And. OA450GRA(nOpc,.f.), oOFIOM450:End(), .F.) },               ;
			{|| OM450Fechar(oOFIOM450) }) CENTER
	ElseIf !(lOM450Req)
		MsgInfo(STR0044, STR0026) // Todas as Ferramentas desta Requisição já foram Devolvidas! / Atenção
	EndIf
	cCadastro := cSlvcCad // salva da Variavel cCadastro
Return

/*/{Protheus.doc} OA450FOK
	@author       Luis Delorme
	@since        27/10/2013
	@description  Verifica duplicidade
/*/
Function OA450FOK()
Local nQtdTot := 0
Local nQtdReq := 0
Local nQtdDev := 0
Local lVD3_LOCAL := VD3->(FieldPos("VD3_LOCAL")) <> 0

Do Case	
	
	Case ReadVar() == "M->VDP_NUMOSV"
		If !Empty(M->VDP_NUMOSV)
			VO1->(DbSetOrder(1))
			If !VO1->(DbSeek(xFilial("VO1")+M->VDP_NUMOSV))
				MsgStop(STR0027,STR0026) // Ordem de Serviço não encontrada!
				Return .f.
			EndIf
			If VO1->VO1_STATUS <> "A"
				MsgStop(STR0028,STR0026) // O status da Ordem de Serviço deve ser Aberta!
				Return .f.
			EndIf
		EndIf
		M->VPD_TIPTEM := space(TamSX3("VDP_TIPTEM")[1])

	Case ReadVar() == "M->VDP_TIPTEM"
		If !Empty(M->VDP_TIPTEM)
			aSER := FMX_CALSER(M->VDP_NUMOSV, M->VDP_TIPTEM, , , .f., .f., .t., .f., .f., .f., , )
			aPEC := FMX_CALPEC(M->VDP_NUMOSV, M->VDP_TIPTEM, , , .f., .f., .f., .t., .f., .f., .f., , , .f., .f.)
			If ( len(aSER)+len(aPEC) ) <= 0
				MsgStop(STR0029,STR0026) // O Tipo de Tempo não esta Aberto!
				Return .f.
			EndIf
		EndIf

	Case ReadVar() == "M->VD3_CODFER"
		if Ascan(aCols,{|x| x[FG_POSVAR("VD3_CODFER")] == M->VD3_CODFER }) # 0 .and. Ascan(aCols,{|x| x[FG_POSVAR("VD3_CODFER")] == M->VD3_CODFER }) # n
			Help("  ",1,"EXISTCHAV")
			Return .F.
		EndIf
		DBSelectArea("VO9")
		DBSetOrder(1) // VO9_FILIAL+VO9_CODFER
		if !DBSeek(xFilial("VO9") + M->VD3_CODFER)
			return .F.
		EndIf
		DBSelectArea("SB1")
		DBSetOrder(1)
		DBSeek(xFilial("SB1")+VO9->VO9_CODPRO)
		M->VD3_LOCAL := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD")
		If lVD3_LOCAL
			aCols[n,FG_POSVAR("VD3_LOCAL")] := M->VD3_LOCAL
		Endif

		DbSelectArea("SB5")
		DBSetOrder(1)
		DbSeek( xFilial("SB5") + VO9->VO9_CODPRO )

		If FG_POSVAR("VD3_LOCALI") > 0 
			M->VD3_LOCALI := aCols[n, FG_POSVAR("VD3_LOCALI")] := FM_PRODSBZ(SB1->B1_COD,"SB5->B5_LOCALI2")
		Endif
		
		DBSelectArea("SB2")
		DBSetOrder(1) // B2_FILIAL+B2_COD+B2_LOCAL
		If GetNewPar("MV_MIL0076","S") == "S" // Controla Estoque no SB2
			nSaldoFer := 0
			if DBSeek(xFilial("SB2")+VO9->VO9_CODPRO + IIF(M->VDP_TIPMOV == "1", M->VD3_LOCAL, cAlmBFer))
				nSaldoFer := SaldoSB2()
			EndIf
			M->VD3_QTDDIS := nSaldoFer	
			aCols[n,FG_POSVAR("VD3_QTDDIS")] := nSaldoFer
		Else
			cQuery := "SELECT SUM(VD3.VD3_QTDMOV) AS QTD"
			cQuery += "  FROM "+RetSQLName("VD3")+" VD3 "
			cQuery += " WHERE VD3.VD3_FILIAL = '"+xFilial("VD3")+"'"
			cQuery += "   AND VD3.VD3_CODFER = '"+M->VD3_CODFER+"'"
			cQuery += "   AND VD3.D_E_L_E_T_=' '"
			nQtdReq := FM_SQL(cQuery+" AND VD3.VD3_TIPMOV='1'")
			nQtdDev := FM_SQL(cQuery+" AND VD3.VD3_TIPMOV='0'")
			cQuery := "SELECT SUM(VO9.VO9_QTDFER) AS QTD"
			cQuery += "  FROM "+RetSQLName("VO9")+" VO9 "
			cQuery += " WHERE VO9.VO9_FILIAL = '"+xFilial("VO9")+"'"
			cQuery += "   AND VO9.VO9_CODFER = '"+M->VD3_CODFER+"'"
			cQuery += "   AND VO9.D_E_L_E_T_=' '"
			nQtdTot := FM_SQL(cQuery)
			M->VD3_QTDDIS := nQtdTot + ( nQtdDev - nQtdReq )   
			aCols[n,FG_POSVAR("VD3_QTDDIS")] := M->VD3_QTDDIS
		Endif
		M->VD3_GRUFER := VO9->VO9_GRUFER
		aCols[n,FG_POSVAR("VD3_GRUFER")] := VO9->VO9_GRUFER

	Case ReadVar() == "M->VD3_QTDMOV"
		if M->VD3_QTDMOV > M->VD3_QTDDIS .and. lOM450Req
			MsgInfo(STR0006,STR0026) // Quantidade requisitada maior que a disponível.
			return .F.
		EndIf

	Case ReadVar() == "M->VD3_LOCAL" .and. M->VDP_TIPMOV == "1"

		DBSelectArea("SB2")
		DBSetOrder(1) // B2_FILIAL+B2_COD+B2_LOCAL
		If GetNewPar("MV_MIL0076","S") == "S" // Controla Estoque no SB2
			nSaldoFer := 0
			if DBSeek(xFilial("SB2")+VO9->VO9_CODPRO + M->VD3_LOCAL)
				nSaldoFer := SaldoSB2()
			EndIf
			M->VD3_QTDDIS := nSaldoFer	
			aCols[n,FG_POSVAR("VD3_QTDDIS")] := nSaldoFer
		Else
			cQuery := "SELECT SUM(VD3.VD3_QTDMOV) AS QTD"
			cQuery += "  FROM "+RetSQLName("VD3")+" VD3 "
			cQuery += " WHERE VD3.VD3_FILIAL = '"+xFilial("VD3")+"'"
			cQuery += "   AND VD3.VD3_CODFER = '"+M->VD3_CODFER+"'"
			cQuery += "   AND VD3.D_E_L_E_T_=' '"
			nQtdReq := FM_SQL(cQuery+" AND VD3.VD3_TIPMOV='1'")
			nQtdDev := FM_SQL(cQuery+" AND VD3.VD3_TIPMOV='0'")
			cQuery := "SELECT SUM(VO9.VO9_QTDFER) AS QTD"
			cQuery += "  FROM "+RetSQLName("VO9")+" VO9 "
			cQuery += " WHERE VO9.VO9_FILIAL = '"+xFilial("VO9")+"'"
			cQuery += "   AND VO9.VO9_CODFER = '"+M->VD3_CODFER+"'"
			cQuery += "   AND VO9.D_E_L_E_T_=' '"
			nQtdTot := FM_SQL(cQuery)
			M->VD3_QTDDIS := nQtdTot + ( nQtdDev - nQtdReq )   
			aCols[n,FG_POSVAR("VD3_QTDDIS")] := M->VD3_QTDDIS
		Endif

EndCase
//
Return .T.

/*/{Protheus.doc} OA450GRA
	@author       Luis Delorme
	@since        27/10/2013
	@description  Checagem de validade da movimentação / Gravacao da Movimentacao das Ferramentas
/*/
Function OA450GRA(nOpc,lAgrupado)
	Local nQtdReq   := 0
	Local nQtdDev   := 0
	Local cQueryAux := ''
	Local cQueryReq := ''
	Local cQueryDev := ''
	Local nRecVD3   := 0 
	Local lDOCSDB := VD3->(FieldPos("VD3_DOCSDB")) <> 0
	Local lVDP_NUMOSV := VDP->(FieldPos("VDP_NUMOSV")) <> 0
	Local lVD3_LOCAL := VD3->(FieldPos("VD3_LOCAL")) <> 0
	Local lRet := .T. , i := 0
	Private lMsFinalAuto := .T., lMsHelpAuto := .T.
	Default lAgrupado := .f.
	
	If lAgrupado // Devolucao Agrupada - Pegar aCols
		aCols   := aClone(oGetDados:aCols)
		aHeader := aClone(oGetDados:aHeader)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executar processamento                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Inclui := .F.
	Altera := .F.

	If nOpc # 2
		
		Inclui := IIF( M->VDP_TIPMOV == oReqFer:TipoRequisicao(), .T., .F. ) // INCLUIR/REQUISITAR
		Altera := IIF( M->VDP_TIPMOV == oReqFer:TipoDevolucao() , .T., .F. ) // ALTERA/DEVOLVER

		Begin Transaction
		
		// Grava arquivo filho
		If lRet

			//Checa se existe ao menos uma ferramenta requisitada
			// Contar o numero de rows que nao estao deletados(== .F.na ultima coluna) e deve retornar mais de 0
			If !lAgrupado // NAO EH DEVOLUCAO AGRUPADA
				oArrHelp := Mil_ArrayHelper():New()
				If oArrHelp:Count(aCols, {|el| el[Len(el)] == .F. }) < 1
					MsgStop(STR0022,STR0026) // Ao menos uma requisição/devolução de ferramenta é necessária para continuar
					DisarmTransaction()
					return .F.
				EndIf
			EndIf

			// Grava arquivo pai
			If Inclui .OR. Altera
				RecLock("VDP",.T.)
				FG_GRAVAR("VDP")
				VDP->VDP_FILIAL := xFilial("VDP")
				VDP->VDP_CODIGO := GetSXENum("VDP","VDP_CODIGO")
				VDP->VDP_TIPMOV := M->VDP_TIPMOV
				VDP->VDP_CODPRO := M->VDP_CODPRO
				If lVDP_NUMOSV
					VDP->VDP_NUMOSV := M->VDP_NUMOSV
					VDP->VDP_TIPTEM := M->VDP_TIPTEM
				EndIf
				VDP->VDP_DATMOV := dDatabase
				MsUnlock()
				CONFIRMSX8()
			EndIf

			nSeqReq := 0

			For i:=1 to len(aCols)

				If aCols[i,Len(aCols[i])]
					Loop // Desconsiderar linha deletada
				EndIf

				If !lOM450Req
	
					cQueryAux := "SELECT SUM(VD3_QTDMOV) AS SOMA FROM "+RetSqlName("VD3") + " VD3 "
					cQueryAux += "INNER JOIN "+RetSqlName("VDP") + " VDP ON ( "
					cQueryAux += "     VDP_FILIAL = '" + xFilial("VDP") + "'"
					cQueryAux += "     AND VDP_CODIGO = VD3_CODIGO " 
					cQueryAux += "     AND VDP.D_E_L_E_T_ =  ' ' ) "
					cQueryAux += " WHERE VD3_FILIAL ='" + xFilial("VD3") + "'"
					cQueryAux += " AND VD3_CODFER='" + aCols[I,FG_POSVAR("VD3_CODFER")] + "'"
					cQueryAux += " AND VDP_CODPRO = '" + M->VDP_CODPRO + "'"
					If lVDP_NUMOSV
						cQueryAux += " AND VDP_NUMOSV = '" + M->VDP_NUMOSV + "'"
						cQueryAux += " AND VDP_TIPTEM = '" + M->VDP_TIPTEM + "'"
					EndIf
					cQueryAux += " AND VD3.D_E_L_E_T_=' '"

					cQueryReq := cQueryAux+" AND VDP_TIPMOV = '1'"
					nQtdReq := FM_SQL(cQueryReq)

					cQueryDev := cQueryAux+" AND VDP_TIPMOV = '0'"
					nQtdDev := FM_SQL(cQueryDev)

					If aCols[I,FG_POSVAR("VD3_QTDMOV")] > (nQtdReq - nQtdDev)
						MsgStop( IIf(lVDP_NUMOSV, AllTrim(RetTitle("VDP_NUMOSV"))+": "+M->VDP_NUMOSV+IIf(!Empty(M->VDP_TIPTEM)," - "+M->VDP_TIPTEM,"")+CHR(13)+CHR(10)+CHR(13)+CHR(10),"")+; 
								 STR0023 + Alltrim(aCols[I,FG_POSVAR("VD3_CODFER")]) + STR0024 + Alltrim(STR(nQtdReq - nQtdDev)) ,STR0026) // Não há saldo suficiente para a devolução da ferramenta '...'. Saldo em poder do produtivo: 
						DisarmTransaction()
						If nRecVDP > 0
							VDP->(DbGoTo(nRecVDP)) // voltar no registro posicionado no browse VDP
						EndIf
						return .F.
					EndIf
				EndIf

				If (Inclui .or. Altera) .And. !aCols[i,Len(aCols[i])]
					RecLock("VD3", .T. )
					FG_GRAVAR("VD3",aCols,aHeader,i)
					VD3->VD3_FILIAL := xFilial("VD3")
					VD3->VD3_CODIGO := VDP->VDP_CODIGO
					VD3->VD3_TIPMOV := VDP->VDP_TIPMOV
					VD3->VD3_CODPRO := VDP->VDP_CODPRO
					If lVDP_NUMOSV
						VD3->VD3_NUMOSV := VDP->VDP_NUMOSV
						VD3->VD3_TIPTEM := VDP->VDP_TIPTEM
					EndIf
					VD3->VD3_QTDMOV := aCols[I,FG_POSVAR("VD3_QTDMOV")]
					VD3->VD3_DATMOV := VDP->VDP_DATMOV
					nSeqReq++
					VD3->VD3_SEQUEN := STRZERO(nSeqReq,TamSX3("VD3_SEQUEN")[1])
					MsUnlock()  
					nRecVD3 := VD3->(Recno())
				EndIf
				DBSelectArea("VO9")
				DBSetOrder(1) // VO9_FILIAL+VO9_CODFER
				DBSeek(xFilial("VO9") + VD3->VD3_CODFER)
				If GetNewPar("MV_MIL0076","S") == "S" // Controla Estoque no SB2
					if !OA450RESIT(VO9->VO9_CODPRO, VD3->VD3_QTDMOV, VDP->VDP_TIPMOV,IIf(lVD3_LOCAL,aCols[I,FG_POSVAR("VD3_LOCAL")],nil))
						Return(.f.)					
					Endif
					If nRecVD3 > 0 .and. lDOCSDB
						DBSelectArea("VD3")
						Dbgoto(nRecVD3)
						RecLock("VD3", .F. )
						VD3->VD3_DOCSDB := cDocumento 
						MsUnlock()
					Endif	
				Endif
			Next
			
		EndIf
		
		END TRANSACTION
		
		lMsHelpAuto := .F.
		lMsFinalAuto := .F.

		If !lRet
			MostraErro()
			Return( .F. )
		Else
			OM450DocComp()
		EndIf
	EndIf

Return(lRet)

/*/{Protheus.doc} OA450RESIT
	@author       Luis Delorme
	@since        27/10/13
	@description  Grava Movimentação
	@param cCodProd , String , Codigo do produto(SB1)
	@param nQuant   , Number , Quantidade Movimentada
	@param cOper    , String , Tipo de Movimentacao do VDP, estao documentadas na classe Mil_RequisicaoFerramenta
	@param cArmLoc  , String , Armazém de onde a Ferramente será Retirada ou Retornada (em caso de Devolução)
/*/
Function OA450RESIT(cCodProd, nQuant, cOper, cArmLoc)

	Local cArmOri := ""
	Local cLocOri := ""
	Local cArmDes := ""
	Local cLocDes := ""

	Local aItemMov := {}
	Local oEst     := DMS_Estoque():New()

	Default cArmLoc := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD")

	cDocumento  := Criavar("D3_DOC")
	cDocumento	:= IIf(Empty(cDocumento),NextNumero("SD3",2,"D3_DOC",.T.),cDocumento)
	cDocumento	:= A261RetINV(cDocumento)

	aItensNew := {}
	AADD (aItensNew, { cDocumento, ddatabase })
	DBSelectArea("SB1")
	DBSetOrder(1)
	DBSeek(xFilial("SB1") + cCodProd)

	cArmOri := IIf(cOper == oReqFer:TipoRequisicao(), cArmLoc , cAlmBFer)
	cLocOri := FM_PRODSBZ(SB1->B1_COD,"SB5->B5_LOCALI2")

	cArmDes := IIf(cOper == oReqFer:TipoRequisicao(), cAlmBFer, cArmLoc )
	cLocDes := FM_PRODSBZ(SB1->B1_COD,"SB5->B5_LOCALI2")

	aItemMov := oEst:SetItemSD3(SB1->B1_COD        ,; //Código do Produto
								cArmOri            ,; // Armazém de Origem
								cArmDes            ,; // Armazém de Destino
								cLocOri            ,; // Localização Origem
								cLocDes            ,; // Localização Destino
								nQuant             ) // Qtd a transferir

	aAdd(aItensNew, aClone(aItemMov))

	If (ExistBlock("OM450AP"))
		aItensNew := ExecBlock("OM450AP", .f., .f., {aItensNew})
	EndIf

	lMsErroAuto := .F.
	MSExecAuto({ |x| MATA261(x) }, aItensNew)
	If lMsErroAuto
		DisarmTransaction()
		MostraErro()
		Return .F.
	EndIf

return(.T.)

/*/{Protheus.doc} MenuDef
	@author       Vinicius Gati
	@since        07/05/2014
	@description  Monta o menu do browse
/*/
Static Function MenuDef()
	Local aRotina := {                      ; 
		{ STR0001 ,"axPesqui"       , 0 , 1 },; // Pesquisar
		{ STR0002 ,"OA450"          , 0 , 2 },; // Visualizar
		{ STR0003 ,"OA450"          , 0 , 3 },; // Requisitar
		{ STR0004 ,"OA450D"         , 0 , 4 },; // Devolver
		{ STR0045 ,"OM450DevAG"     , 0 , 6 },; // Devolver Agrupado
		{ STR0020 ,"OM450DocComp"   , 0 , 5 },; // Imprimir Req/Dev
		{ STR0053 ,"OFIOC480"       , 0 , 2 } ; // Con.Mov.Ferramentas
	}
Return aRotina


/*/{Protheus.doc} OM450DocComp
	@author       Vinicius Gati
	@since        30/04/2014
	@description  Impressão de um documento de comprovação de movimento de ferramenta, DEVE ESTAR POSICIONADO O VDP
/*/
Function OM450DocComp()
	If ExistBlock("OM450IMP")
		ExecBlock("OM450IMP",.f.,.f.,{VDP->VDP_CODIGO})
	EndIf
Return

/*/{Protheus.doc} OM450PrintLine
	@author       Vinicius Gati
	@since        30/04/2014
	@description  Usado para imprimir uma linha em um relatorio retornando a prox. linha para imprimir mais conteudo
	@param        nLin , Int   , linha que sera colocada o conteudo
	@param        cData, String, Será impresso em uma linha no relatorio
/*/
Function OM450PrintLine(nLin, cData)
	@ nLin, 00 PSAY cData
Return nLin+1

/*/{Protheus.doc} OM450Fechar
	@author       Vinicius Gati
	@since        30/04/2014
	@description  Cancela SX3Num e fecha a dialog
	
/*/
Static Function OM450Fechar(oFrm)
	ROLLBACKSXE()
Return oFrm:End()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OM450VQTD³ Autor ³ Andre Luis Almeida    ³ Data ³ 01/11/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao da Qtde de Ferramentas                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nQtdTot = Quantidade TOTAL da ferramenta a validar         ³±±
±±³          ³ cCodFer = Codigo da ferramenta a validar                   ³±±
±±³          ³ cTipMov = Tipo de Movimento a validar                      ³±±
±±³          ³           ' ' = Alteracao na Qtd do cadastro da ferramenta ³±±
±±³          ³           '1' = Requisicao da ferramenta                   ³±±
±±³          ³           '0' = Devolucao da ferramenta                    ³±±
±±³          ³ cCodPro = Codigo do Produtivo                              ³±±
±±³          ³ cNumOSV = Numero da OS                                     ³±±
±±³          ³ cTipTem = Tipo de Tempo                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OM450VQTD(nQtdTot,cCodFer,cTipMov,cCodPro,cNumOSV,cTipTem)
Local lRet    := .f.
Local nQtdReq := 0
Local nQtdDev := 0
Local cQuery  := ""
Local lVDP_NUMOSV := VDP->(FieldPos("VDP_NUMOSV")) <> 0
Default nQtdTot := 0
Default cTipMov := M->VDP_TIPMOV
Default cCodPro := M->VDP_CODPRO
Default cCodFer := M->VD3_CODFER
Default cNumOSV := IIf(lVDP_NUMOSV,M->VDP_NUMOSV,"")
Default cTipTem := IIf(lVDP_NUMOSV,M->VDP_TIPTEM,"")
//
If GetNewPar("MV_MIL0076","S") == "S" // Controla Estoque no SB2

	lRet := .t.

Else

	If cTipMov == "0"
		////////////////////////////////////////////////
		// Esta tentando DEVOLVER ferramenta          //
		////////////////////////////////////////////////
		cQuery := "SELECT SUM(VD3.VD3_QTDMOV) AS QTD"
		cQuery += "  FROM "+RetSQLName("VD3")+" VD3 "
		cQuery += " WHERE VD3.VD3_FILIAL = '"+xFilial("VD3")+"'"
		cQuery += "   AND VD3.VD3_CODPRO = '"+cCodPro+"'"
		If lVDP_NUMOSV
			If !Empty(cNumOSV)
				cQuery += " AND VD3.VD3_NUMOSV = '"+cNumOSV+"'"
			EndIf
			If !Empty(cTipTem)
				cQuery += " AND VD3.VD3_TIPTEM = '"+cTipTem+"'"
			EndIf
		EndIf
		cQuery += "   AND VD3.VD3_CODFER = '"+cCodFer+"'"
		cQuery += "   AND VD3.D_E_L_E_T_=' '"
		nQtdReq := FM_SQL(cQuery+" AND VD3.VD3_TIPMOV='1'")
		nQtdDev := FM_SQL(cQuery+" AND VD3.VD3_TIPMOV='0'")
		nQtdDev += M->VD3_QTDMOV // somar variavel de memoria
		If ( nQtdDev <= nQtdReq )
			lRet := .t.
		Else
			MsgStop(STR0037+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
					STR0038+Transform(( nQtdReq - ( nQtdDev - M->VD3_QTDMOV ) ),"@E 9999"),STR0026) // Impossivel devolver a ferramenta! / Quantidade maxima permitida: / Atencao
		EndIf
	Else
		cQuery := "SELECT SUM(VD3.VD3_QTDMOV) AS QTD"
		cQuery += "  FROM "+RetSQLName("VD3")+" VD3 "
		cQuery += " WHERE VD3.VD3_FILIAL = '"+xFilial("VD3")+"'"
		cQuery += "   AND VD3.VD3_CODFER = '"+cCodFer+"'"
		cQuery += "   AND VD3.D_E_L_E_T_=' '"
		nQtdReq := FM_SQL(cQuery+" AND VD3.VD3_TIPMOV='1'")
		nQtdDev := FM_SQL(cQuery+" AND VD3.VD3_TIPMOV='0'")
		If nQtdTot == 0
			cQuery := "SELECT SUM(VO9.VO9_QTDFER) AS QTD"
			cQuery += "  FROM "+RetSQLName("VO9")+" VO9 "
			cQuery += " WHERE VO9.VO9_FILIAL = '"+xFilial("VO9")+"'"
			cQuery += "   AND VO9.VO9_CODFER = '"+cCodFer+"'"
			cQuery += "   AND VO9.D_E_L_E_T_=' '"
			nQtdTot := FM_SQL(cQuery)
		EndIf
		If Funname() == "OFIOA050" // Condicao chamada pelo cadastro de Ferramentas
			////////////////////////////////////////////////
			// Esta tentando ALTERAR a qtde de ferramenta //
			////////////////////////////////////////////////
			If ( nQtdTot + ( nQtdDev - nQtdReq ) ) >= 0
				lRet := .t.
			Else
				MsgStop(STR0039+CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
						STR0040+Transform(( nQtdReq - nQtdDev ),"@E 9999"),STR0026) // Impossivel alterar a quantidade da ferramenta! / Quantidade minima permitida: / Atencao
			EndIf
		Else
			If cTipMov == "1"
				////////////////////////////////////////////////
				// Esta tentando REQUISITAR ferramenta        //
				////////////////////////////////////////////////
				nQtdReq += M->VD3_QTDMOV // somar variavel de memoria
				If ( nQtdTot + ( nQtdDev - nQtdReq ) ) >= 0
					// verificar/informar que o produtivo ja esta com a mesma ferramenta requisitada //
					cQuery := "SELECT SUM(VD3.VD3_QTDMOV) AS QTD"
					cQuery += "  FROM "+RetSQLName("VD3")+" VD3 "
					cQuery += " WHERE VD3.VD3_FILIAL = '"+xFilial("VD3")+"'"
					cQuery += "   AND VD3.VD3_CODPRO = '"+cCodPro+"'"
					If lVDP_NUMOSV
						If !Empty(cNumOSV)
							cQuery += " AND VD3.VD3_NUMOSV = '"+cNumOSV+"'"
						EndIf
						If !Empty(cTipTem)
							cQuery += " AND VD3.VD3_TIPTEM = '"+cTipTem+"'"
						EndIf
					EndIf
					cQuery += "   AND VD3.VD3_CODFER = '"+cCodFer+"'"
					cQuery += "   AND VD3.D_E_L_E_T_=' '"
					nQtdReq := FM_SQL(cQuery+" AND VD3.VD3_TIPMOV='1'")
					nQtdDev := FM_SQL(cQuery+" AND VD3.VD3_TIPMOV='0'")
					If nQtdReq > nQtdDev
		                VO9->(DbSetOrder(1))
		                VO9->(DbSeek(xFilial("VO9")+cCodFer))
						If MsgYesNo(STR0041+;
									CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
									Alltrim(VO9->VO9_DESFER)+" ( "+cCodFer+" - "+VO9->VO9_GRUFER+" )"+;
									CHR(13)+CHR(10)+CHR(13)+CHR(10)+;
									STR0042,STR0026) // O produtivo ja possui a mesma ferramenta requisitada! / Deseja requisitar mais? / Atencao
							lRet := .t.
						EndIf
					Else
						lRet := .t.
					EndIf
				Else	
					MsgStop(STR0043+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0038+Transform(( nQtdTot + ( nQtdDev - ( nQtdReq - M->VD3_QTDMOV ) ) ),"@E 9999"),STR0026) // Impossivel requisitar a ferramenta! / Quantidade maxima permitida: / Atencao
				EndIf
			EndIf
		EndIf
	EndIf

EndIf

Return(lRet)

/*/{Protheus.doc} OM450VFER
	@author       Andre Luis Almeida
	@since        21/11/2017
	@description  Valida se existe Ferramentas Requisitadas e não devolvidas
	@param        _cNroOS, String, Numero da OS
	@param        _cTpTem, String, Tipo de Tempo da OS
	@param        _cChamada, String, Momento da Chamada ( 1 - Liberação / 2 - Fechamento / 3 - Cancelamento )
/*/
Function OM450VFER( _cNroOS , _cTpTem , _cChamada )
Local nCntFor   := 0
Local nQtdReq   := 0
Local nQtdDev   := 0
Local cQuery    := ""
Local cQueryAux := ""
Local lRet      := .t.
//
	AjustaHelp()
//
VAI->(dbSetOrder(4))
VAI->(MsSeek(xFilial("VAI")+__cUserID))
If !Empty(VAI->VAI_VOSFER) .and. _cChamada $ VAI->VAI_VOSFER
	cQuery := "SELECT SUM(VD3.VD3_QTDMOV) AS QTD"
	cQuery += "  FROM "+RetSQLName("VD3")+" VD3 "
	cQuery += " WHERE VD3.VD3_FILIAL = '"+xFilial("VD3")+"'"
	cQuery += "   AND VD3.VD3_NUMOSV = '"+_cNroOS+"'"
	cQuery += "   AND VD3.D_E_L_E_T_ = ' '"
	For nCntFor := 1 to 2
		If nCntFor == 1 // Verifica "SEM" TIPO DE TEMPO
			cQueryAux := cQuery +" AND VD3.VD3_TIPTEM = ' '"
		ElseIf nCntFor == 2 // Verifica "COM" TIPO DE TEMPO
			cQueryAux := cQuery +" AND VD3.VD3_TIPTEM = '"+_cTpTem+"'"
		EndIf
		nQtdReq := FM_SQL(cQueryAux+" AND VD3.VD3_TIPMOV='1'")
		nQtdDev := FM_SQL(cQueryAux+" AND VD3.VD3_TIPMOV='0'")
		If nQtdReq > nQtdDev
			Help(" ",1,"M450VFERR",,CHR(13)+CHR(10)+_cNroOS+IIf(nCntFor==2,(" - "+_cTpTem),""),3,0)
			lRet := .f.
			Exit
		EndIf
	Next
EndIf
Return lRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³AjustaHelp ³ Autor ³ Andre Luis Almeida   ³ Data ³ 21/11/17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Ajuta help da Rotina                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AjustaHelp()

Local aHelpEng, aHelpSpa, aHelpPor

aHelpPor := { STR0031 , STR0032 } // "Existe(m) Ferramenta(s) requisitada(s)" "para a Ordem de Serviço / Tipo de Tempo."
aHelpEng := aHelpSpa :=	aHelpPor
PutHelp("PM450VFERR",aHelpPor,aHelpEng,aHelpSpa,.t.)

aHelpPor := { STR0033 } // Favor devolver a(s) Ferramenta(s).
aHelpEng := aHelpSpa :=	aHelpPor
PutHelp("SM450VFERR",aHelpPor,aHelpEng,aHelpSpa,.t.)

Return

/*----------------------------------------------------
 Suavizar a nova verificação de integração com o WMS
------------------------------------------------------*/
Static Function a261IntWMS(cProduto)
Default cProduto := ""
	If FindFunction("IntWMS")
		Return IntWMS(cProduto)
	Else
		Return IntDL(cProduto)
	EndIf
Return

/*/{Protheus.doc} OM450DevAG
	@author       Fernando Vitor Cavani
	@since        27/03/2018
	@description  Monta Tela Devolução Agrupada
/*/
Function OM450DevAG(cAlias, nReg, nOpc)
	Local oSizeL    := FwDefSize():New(.T.) // Com enchoicebar
	Local oSizeC    := FwDefSize():New(.T.)
	Local bCampo    := { |nCPO| Field(nCPO) }, nCntFor := 0, _ni := 0, _lRet := .T.
	Local nPosRec   := 0
	Local cTitulo, cAliasGetD, cTudOk, cFieldOk
	Local aCpoAlt   := {}
	Local anAtLBx   := {1,1,1} // nAt dos ListBox
	Private nOpcDevPor := 1  // Opcao Radio: Devolver por: 1 - Produtivo / 2 - OS
	Private nRecVDP := 0
	Private aCols   := {}
	Private aHeader := {}
	Private aTELA[0][0], aGETS[0]
	Private nLenAcols := 0
	Private oOkTik    := LoadBitmap( GetResources() , "LBTIK" )
	Private oNoTik    := LoadBitmap( GetResources() , "LBNO" )
	Private aProd     := {}
	Private aOrdS     := {}
	Private aTTpo     := {}
	Private cProdSelect := VDP->VDP_CODPRO
	Private cNrOSSelect := VDP->VDP_NUMOSV 
	Private cTTpoSelect := VDP->VDP_TIPTEM
	Private cCodFer   := ""

	OM450PROD( .f. , @anAtLBx )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Opcoes de acesso para a Modelo 3                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nOpc   := 4
	nOpcG  := 4
	Inclui := .T.
	Altera := .F.

	DbSelectArea("VDP")
	nRecVDP := VDP->(RecNo()) // VDP posicionado no Browse
	For nCntFor := 1 TO FCount()
		M->&(EVAL(bCampo, nCntFor)) := FieldGet(nCntFor)
	Next

	lOM450Req := .T.
	M->VDP_TIPMOV := "0"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria aHeader e aCols da GetDados                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nUsado := 0

	dbSelectArea("SX3")
	DbSetOrder(1)
	dbSeek("VD3")

	aHeader := {}

	While !Eof() .And. (x3_arquivo == "VD3")
		If X3USO(x3_usado) .And. cNivel >= x3_nivel;
			.And. !(Alltrim(x3_campo) $ "VD3_CODIGO.VD3_SEQUEN.VD3_NUMOSV.VD3_TIPTEM.VD3_QTDDIS")
			nUsado := nUsado + 1
			AADD(aHeader, {	AllTrim(X3Titulo()),	SX3->X3_CAMPO,		SX3->X3_PICTURE,	SX3->X3_TAMANHO,;
						SX3->X3_DECIMAL,		SX3->X3_VALID,		SX3->X3_USADO,		SX3->X3_TIPO,;
						SX3->X3_F3,				SX3->X3_CONTEXT,	X3CBOX(),			SX3->X3_RELACAO })
			If Alltrim(x3_campo) $ "VD3_QTDMOV."
				Aadd(aCpoAlt,x3_campo)
			EndIf
		EndIf

		dbSkip()
	EndDo

	// Posicao do registro
	nPosRec := Len(aHeader)
	nUsado  := Len(aHeader)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa a Modelo 3                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cTitulo        := STR0005
	cAliasGetD     := "VD3"
	cTudOk         := "OM450TOKAGR()"
	cFieldOk       := "OM450QTDAGR()"

	// GERAL - Calcula as dimensões dos objetos
	oSizeL:lLateral := .F. // Cálculo vertical
	oSizeL:AddObject("L1",  0,  30, .T., .F.) // Linha 1 fixa  30pix - Topo - Radio Devolver Por:
	oSizeL:AddObject("L2",  0, 100, .T., .F.) // Linha 1 fixa 100pix - Meio ListBox's
	oSizeL:AddObject("L3",  0,   0, .T., .T.) // Linha 2 restante   - Getdados FERRAMENTAS
	oSizeL:Process()

	// COLUNAS - Calcula as dimensões dos objetos
	oSizeC:lLateral := .T. // Cálculo vertical
	oSizeC:AddObject("C1",  0,   0, .T., .T.) // Coluna 1 33,33% - ListBox Produtivos
	oSizeC:AddObject("C2",  0,   0, .T., .T.) // Coluna 2 33,33% - ListBox OSs
	oSizeC:AddObject("C3",  0,   0, .T., .T.) // Coluna 3 33,33% - ListBox Tps.Tempo
	oSizeC:Process()

	// Desenha a Dialog
	DEFINE MSDIALOG oOFIOM450 TITLE cTitulo FROM oSizeL:aWindSize[1], oSizeL:aWindSize[2] TO oSizeL:aWindSize[3], oSizeL:aWindSize[4] PIXEL

	@ oSizeL:GetDimension("L1", "LININI")+000,oSizeC:GetDimension("C1", "COLINI")+000 TO oSizeL:GetDimension("L1", "LINEND"),oSizeC:GetDimension("C1", "COLEND") LABEL STR0054 OF oOFIOM450 PIXEL // Devolução Agrupada por:
	@ oSizeL:GetDimension("L1", "LININI")+008,oSizeC:GetDimension("C1", "COLINI")+010 RADIO oRadio1 VAR nOpcDevPor 3D SIZE 100,20 PROMPT STR0046,STR0055 OF oOFIOM450 PIXEL ON CHANGE FS_DevPor() // Produtivos / Ordem de Serviço

	oLbProd1 := TWBrowse():New(	oSizeL:GetDimension("L2", "LININI"),;
								oSizeC:GetDimension("C1", "COLINI"),;
								oSizeC:GetDimension("C1", "COLEND")-oSizeC:GetDimension("C1", "COLINI"),;
								oSizeL:GetDimension("L2", "LINEND")-oSizeL:GetDimension("L2", "LININI"),;
								,,,oOFIOM450,,,,,{ || FS_TIK(1,oLbProd1:nAt) },,,,,,,.F.,,.T.,,.F.,,,)
	oLbProd1:addColumn( TCColumn():New( ""      , { || IIf(aProd[oLbProd1:nAt,1],oOkTik,oNoTik) }         ,,,, "LEFT" , 08 ,.T.,.F.,,,,.F.,) ) // Tik
	oLbProd1:addColumn( TCColumn():new( STR0046 , { || aProd[oLbProd1:nAt,2] }                            ,,,, "LEFT" , 40 ,.F.,.F.,,,,.F.,) ) // Produtivos
	oLbProd1:addColumn( TCColumn():new( STR0047 , { || aProd[oLbProd1:nAt,3] }                            ,,,, "LEFT" , 60 ,.F.,.F.,,,,.F.,) ) // Nome
	oLbProd1:SetArray(aProd)
	oLbProd1:nAt := anAtLBx[1]

	oLbOrdS1 := TWBrowse():New(	oSizeL:GetDimension("L1", "LININI"),;
								oSizeC:GetDimension("C2", "COLINI"),;
								oSizeC:GetDimension("C2", "COLEND")-oSizeC:GetDimension("C2", "COLINI"),;
								oSizeL:GetDimension("L2", "LINEND")-oSizeL:GetDimension("L1", "LININI"),;
								,,,oOFIOM450,,,,,{ || FS_TIK(2,oLbOrdS1:nAt) },,,,,,,.F.,,.T.,,.F.,,,)
	oLbOrdS1:addColumn( TCColumn():New( ""      , { || IIf(aOrdS[oLbOrdS1:nAt,1],oOkTik,oNoTik) }         ,,,, "LEFT" , 08 ,.T.,.F.,,,,.F.,) ) // Tik
	oLbOrdS1:addColumn( TCColumn():new( STR0055 , { || aOrdS[oLbOrdS1:nAt,2] }                            ,,,, "LEFT" , 40 ,.F.,.F.,,,,.F.,) ) // Ordem de Servico
	oLbOrdS1:SetArray(aOrdS)
	oLbOrdS1:nAt := anAtLBx[2]

	oLbTTpo1 := TWBrowse():New(	oSizeL:GetDimension("L1", "LININI"),;
								oSizeC:GetDimension("C3", "COLINI"),;
								oSizeC:GetDimension("C3", "COLEND")-oSizeC:GetDimension("C3", "COLINI"),;
								oSizeL:GetDimension("L2", "LINEND")-oSizeL:GetDimension("L1", "LININI"),;
								,,,oOFIOM450,,,,,{ || FS_TIK(3,oLbTTpo1:nAt) },,,,,,,.F.,,.T.,,.F.,,,)
	oLbTTpo1:addColumn( TCColumn():New( ""      , { || IIf(aTTpo[oLbTTpo1:nAt,1],oOkTik,oNoTik) }         ,,,, "LEFT" , 08 ,.T.,.F.,,,,.F.,) ) // Tik
	oLbTTpo1:addColumn( TCColumn():new( STR0036 , { || aTTpo[oLbTTpo1:nAt,2] }                            ,,,, "LEFT" , 40 ,.F.,.F.,,,,.F.,) ) // Tip.Tpo.
	oLbTTpo1:SetArray(aTTpo)
	oLbTTpo1:nAt := anAtLBx[3]

	oLbOrdS2 := TWBrowse():New(	oSizeL:GetDimension("L2", "LININI"),;
								oSizeC:GetDimension("C1", "COLINI"),;
								oSizeC:GetDimension("C1", "COLEND")-oSizeC:GetDimension("C1", "COLINI"),;
								oSizeL:GetDimension("L2", "LINEND")-oSizeL:GetDimension("L2", "LININI"),;
								,,,oOFIOM450,,,,,{ || FS_TIK(2,oLbOrdS2:nAt) },,,,,,,.F.,,.T.,,.F.,,,)
	oLbOrdS2:addColumn( TCColumn():New( ""      , { || IIf(aOrdS[oLbOrdS2:nAt,1],oOkTik,oNoTik) }         ,,,, "LEFT" , 08 ,.T.,.F.,,,,.F.,) ) // Tik
	oLbOrdS2:addColumn( TCColumn():new( STR0055 , { || aOrdS[oLbOrdS2:nAt,2] }                            ,,,, "LEFT" , 40 ,.F.,.F.,,,,.F.,) ) // Ordem de Servico
	oLbOrdS2:SetArray(aOrdS)
	oLbOrdS2:nAt := anAtLBx[2]

	oLbTTpo2 := TWBrowse():New(	oSizeL:GetDimension("L1", "LININI"),;
								oSizeC:GetDimension("C2", "COLINI"),;
								oSizeC:GetDimension("C2", "COLEND")-oSizeC:GetDimension("C2", "COLINI"),;
								oSizeL:GetDimension("L2", "LINEND")-oSizeL:GetDimension("L1", "LININI"),;
								,,,oOFIOM450,,,,,{ || FS_TIK(3,oLbTTpo2:nAt) },,,,,,,.F.,,.T.,,.F.,,,)
	oLbTTpo2:addColumn( TCColumn():New( ""      , { || IIf(aTTpo[oLbTTpo2:nAt,1],oOkTik,oNoTik) }         ,,,, "LEFT" , 08 ,.T.,.F.,,,,.F.,) ) // Tik
	oLbTTpo2:addColumn( TCColumn():new( STR0036 , { || aTTpo[oLbTTpo2:nAt,2] }                            ,,,, "LEFT" , 40 ,.F.,.F.,,,,.F.,) ) // Tip.Tpo.
	oLbTTpo2:SetArray(aTTpo)
	oLbTTpo2:nAt := anAtLBx[3]

	oLbProd2 := TWBrowse():New(	oSizeL:GetDimension("L1", "LININI"),;
								oSizeC:GetDimension("C3", "COLINI"),;
								oSizeC:GetDimension("C3", "COLEND")-oSizeC:GetDimension("C3", "COLINI"),;
								oSizeL:GetDimension("L2", "LINEND")-oSizeL:GetDimension("L1", "LININI"),;
								,,,oOFIOM450,,,,,{ || FS_TIK(1,oLbProd2:nAt) },,,,,,,.F.,,.T.,,.F.,,,)
	oLbProd2:addColumn( TCColumn():New( ""      , { || IIf(aProd[oLbProd2:nAt,1],oOkTik,oNoTik) }         ,,,, "LEFT" , 08 ,.T.,.F.,,,,.F.,) ) // Tik
	oLbProd2:addColumn( TCColumn():new( STR0046 , { || aProd[oLbProd2:nAt,2] }                            ,,,, "LEFT" , 40 ,.F.,.F.,,,,.F.,) ) // Produtivos
	oLbProd2:addColumn( TCColumn():new( STR0047 , { || aProd[oLbProd2:nAt,3] }                            ,,,, "LEFT" , 60 ,.F.,.F.,,,,.F.,) ) // Nome
	oLbProd2:SetArray(aProd)
	oLbProd2:nAt := anAtLBx[1]

	FS_DevPor() // Habilita / Desabilita ListBox's

	DbSelectArea("VD3")

	// Monta a Getdados
	oGetDados := MsNewGetDados():New(oSizeL:GetDimension("L3", "LININI"), ;
		oSizeL:GetDimension("L3", "COLINI"),                           ;
		oSizeL:GetDimension("L3", "LINEND"),                           ;
		oSizeL:GetDimension("L3", "COLEND"),                           ;
		3 ,;
		"AlwaysTrue()",;
		cTudOk,;
		,;
		aCpoAlt ,; 	// Campos alteraveis da GetDados
		/* nFreeze */,;	// Campos estaticos da GetDados
		999 ,;
		cFieldOk,;
		/* cSuperDel */,; 	// Funcao executada quando pressionado <Ctrl>+<Del>
		/*cDelOk*/,; 		// Funcao executada para validar a exclusao de uma linha
		oOFIOM450,;
		aHeader ,;
		aCols)
	oGetDados:oBrowse:bChange := {|| IIf(nLenAcols<len(oGetDados:aCols),;
										(	oGetDados:aCols[len(oGetDados:aCols),len(oGetDados:aCols[len(oGetDados:aCols)])] := .t. ,;
											oGetDados:GoTo(nLenAcols) ,;
											oGetDados:nAt:=nLenAcols ,;
											oGetDados:oBrowse:Refresh();
										), .t. ) }
	oGetDados:oBrowse:bDelete := {|| OM450DELAGR() }

	OM450MONTACOLS( .f. )

	ACTIVATE MSDIALOG oOFIOM450 ON INIT EnchoiceBar(oOFIOM450, {|| IIf(oGetDados:TudoOk() .And.;
		obrigatorio(aGets, aTela) .And. OA450GRA(nOpc,.t.), ( IIf(nOpcDevPor== 1,OM450PROD( .t. , ),OM450ORDS( .t. , )) , OM450MONTACOLS( .t. ) ) , .F.) },               ;
		{|| oOFIOM450:End() }) CENTER
Return

/*/{Protheus.doc} FS_TIK
	@author       Andre Luis Almeida
	@since        15/05/2018
	@description  Devolucao Agrupada - Tik nos ListBox de Produtivos / OSs / Tipos de Tempo
/*/
Static Function FS_TIK(nTip,nLinha)
Do Case
	Case nTip == 1 // Produtivo
		cProdSelect := " "
		If nOpcDevPor == 1 // Por Produtivo
			cNrOSSelect := " "
			cTTpoSelect := " "
		EndIf
		aEval( aProd , { |x| x[1] := .f. } )
		If !Empty(aProd[nLinha,2])
			aProd[nLinha,1] := .t.
			cProdSelect := aProd[nLinha,2]
		EndIf
		&("oLbProd"+Alltrim(str(nOpcDevPor))+":Refresh()")
		If nOpcDevPor == 1 // Por Produtivo
			OM450ORDS(.t.,)
		EndIf
	Case nTip == 2 // OS
		cNrOSSelect := " "
		cTTpoSelect := " "
		If nOpcDevPor == 2 // Por OS
			cProdSelect := " "
		EndIf
		aEval( aOrdS , { |x| x[1] := .f. } )
		aOrdS[nLinha,1] := .t.
		cNrOSSelect := aOrdS[nLinha,2]
		&("oLbOrdS"+Alltrim(str(nOpcDevPor))+":Refresh()")
		OM450TTPO(.t.,)
	Case nTip == 3 // Tipo de Tempo
		cTTpoSelect := " "
		If nOpcDevPor == 2 // Por OS
			cProdSelect := " "
		EndIf
		aEval( aTTpo , { |x| x[1] := .f. } )
		aTTpo[nLinha,1] := .t.
		cTTpoSelect := aTTpo[nLinha,2]
		&("oLbTTpo"+Alltrim(str(nOpcDevPor))+":Refresh()")
		If nOpcDevPor == 2 // Por OS
			OM450PROD(.t.,)
		EndIf
EndCase
OM450MONTACOLS( .t. )
Return

/*/{Protheus.doc} OM450MONTACOLS
	@author       Andre Luis Almeida
	@since        15/05/2018
	@description  Devolucao Agrupada - Monta aCols das Ferramentas
/*/
Static Function OM450MONTACOLS( lRefresh )
Local nCntFor   := 0
Local cQuery    := ""
Local naCols    := 0
Local nVD3CODFER := FG_POSVAR("VD3_CODFER")
Local nVD3LOCAL  := FG_POSVAR("VD3_LOCAL")
Local nVD3DESPRO := FG_POSVAR("VD3_DESPRO")
Local nVD3GRUFER := FG_POSVAR("VD3_GRUFER")
Local nVD3LOCALI := FG_POSVAR("VD3_LOCALI")
Local nVD3QTDMOV := FG_POSVAR("VD3_QTDMOV")
Local nVD3QTDDEV := FG_POSVAR("VD3_QTDDEV")
Local aRecVD3     := {}

oGetDados:aCols := {} // Limpa aCols

//////////////////////////////////////////////////////////////
// Retorna as Ferramentas que ainda precisam ser Devolvidas //
//////////////////////////////////////////////////////////////
aRecVD3 := FS_REQDEV( cProdSelect , cNrOSSelect , cTTpoSelect , .t. , .t. , .t. )

For nCntFor := 1 to len(aRecVD3)
		
	DbSelectArea("VD3")
	DbGoto(aRecVD3[nCntFor,3])
	DbSelectArea("VO9")
	DbGoto(aRecVD3[nCntFor,4])
	SB1->(DBSetOrder(1))
	SB1->(DbSeek(xFilial("SB1") + VO9->VO9_CODPRO))

	AADD(oGetDados:aCols, Array(nUsado + 1))
	naCols := Len(oGetDados:aCols)
	oGetDados:aCols[naCols, nUsado + 1] := .F.
	oGetDados:aCols[naCols, nVD3CODFER] := VD3->VD3_CODFER // Codigo da Feramenta
	oGetDados:aCols[naCols, nVD3DESPRO] := VO9->VO9_DESFER // Descrição
	oGetDados:aCols[naCols, nVD3GRUFER] := VO9->VO9_GRUFER // Grupo
	If nVD3LOCAL > 0
		oGetDados:aCols[naCols, nVD3LOCAL] := VD3->VD3_LOCAL // Almoxarifado
	EndIf
	If nVD3LOCALI > 0
		SB5->(DBSetOrder(1))
		SB5->(DbSeek(xFilial("SB5") + SB1->B1_COD))
		oGetDados:aCols[naCols, nVD3LOCALI] := FM_PRODSBZ(SB1->B1_COD, "SB5->B5_LOCALI2") // Localização
	EndIf
	oGetDados:aCols[naCols, nVD3QTDMOV] := aRecVD3[nCntFor,2] // Quantidade de Movimento
	If nVD3QTDDEV > 0
		oGetDados:aCols[naCols, nVD3QTDDEV] := aRecVD3[nCntFor,2] // Quantidade para Devolução
	EndIf
Next
	
DbSelectArea("VD3")
nLenaCols := naCols

If len(oGetDados:aCols) <= 0
	AADD(oGetDados:aCols, Array(nUsado + 1))
	naCols := Len(oGetDados:aCols)
	If nVD3QTDDEV > 0
		oGetDados:aCols[naCols, nVD3QTDDEV] := 0
	EndIf
	oGetDados:aCols[naCols, nVD3QTDMOV] := 0
	oGetDados:aCols[naCols, nUsado + 1] := .F.
EndIf

If lRefresh
	oGetDados:oBrowse:Refresh()
EndIf

Return()

/*/{Protheus.doc} OM450PROD
	@author       Andre Luis Almeida
	@since        15/05/2018
	@description  Devolucao Agrupada - Carrega ListBox dos Produtivos com Ferramentas em Aberto
/*/
Function OM450PROD( lRefresh , anAtLBx )
Local cQuery     := ""
Local cQAlias    := "SQLAUX"
Local aAux       := {}
Local lMarcar    := .f.
Default lRefresh := .f.
Default anAtLBx     := {1,1,1}
aProd := {}
cQuery := "SELECT DISTINCT VDP.VDP_CODPRO , VAI.VAI_NOMTEC "
cQuery += "  FROM " + RetSQLName("VDP")+ " VDP "
cQuery += "  JOIN " + RetSQLName("VAI")+ " VAI ON ( VAI.VAI_FILIAL='"+xFilial("VAI")+"' AND VAI.VAI_CODTEC=VDP.VDP_CODPRO AND VAI.D_E_L_E_T_=' ' ) "
cQuery += " WHERE VDP.VDP_FILIAL='"+xFilial("VDP")+"'"
cQuery += "   AND VDP.VDP_CODPRO <> ' '"
If nOpcDevPor == 2 // Por OS
	cQuery += "   AND VDP.VDP_NUMOSV = '"+cNrOSSelect+"'"
	cQuery += "   AND VDP.VDP_TIPTEM = '"+cTTpoSelect+"'"
EndIf
cQuery += "   AND VDP.D_E_L_E_T_=' '"
dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cQAlias, .F., .T.)
While !(cQAlias)->(Eof())
	If nOpcDevPor == 1 // Por Produtivo
		aAux := FS_REQDEV( (cQAlias)->( VDP_CODPRO ) , " "         , " "         , .t. , .f. , .f. ) // Retorna as Ferramentas que ainda precisam ser Devolvidas
	Else // nOpcDevPor == 2 // Por OS
		aAux := FS_REQDEV( (cQAlias)->( VDP_CODPRO ) , cNrOSSelect , cTTpoSelect , .t. , .t. , .t. ) // Retorna as Ferramentas que ainda precisam ser Devolvidas
	EndIf
	If len(aAux) > 0 // Tem Ferramentas para Devolver
		lMarcar := (cProdSelect==(cQAlias)->( VDP_CODPRO ))
		aAdd(aProd,{ lMarcar , (cQAlias)->( VDP_CODPRO ) , (cQAlias)->( VAI_NOMTEC ) })
		If lMarcar
			anAtLBx[1] := len(aProd)
		EndIf
	EndIf
	(cQAlias)->(DbSkip())
EndDo
(cQAlias)->(dbCloseArea())
If len(aProd) <= 0
	aAdd(aProd,{.f.," "," "})
EndIf
If lRefresh
	If len(aProd) == 1 .and. !Empty(aProd[1,2])
		anAtLBx[1] := 1
		aProd[1,1] := .t.
		cProdSelect := aProd[1,2]
	EndIf
	If anAtLBx[1] <= 5
		anAtLBx[1] := 1
	Else
		anAtLBx[1] -= 5
	EndIf
	&("oLbProd"+Alltrim(str(nOpcDevPor))+":nAt") := anAtLBx[1]
	&("oLbProd"+Alltrim(str(nOpcDevPor))+":SetArray(aProd)")
	&("oLbProd"+Alltrim(str(nOpcDevPor))+":Refresh()")
EndIf
If nOpcDevPor == 1 // Por Produtivo
	OM450ORDS( lRefresh , @anAtLBx )
EndIf
Return()

/*/{Protheus.doc} OM450ORDS
	@author       Andre Luis Almeida
	@since        15/05/2018
	@description  Devolucao Agrupada - Carrega ListBox das OS's de um determinado Produtivo
/*/
Function OM450ORDS( lRefresh , anAtLBx )
Local cQuery     := ""
Local cQAlias    := "SQLAUX"
Local aAux       := {}
Local lMarcar    := .f.
Default lRefresh := .f.
Default anAtLBx     := {1,1,1}
aOrdS := {}
cQuery := "SELECT DISTINCT VDP_NUMOSV "
cQuery += "  FROM " + RetSQLName("VDP")
cQuery += " WHERE VDP_FILIAL='"+xFilial("VDP")+"'"
If nOpcDevPor == 1 // Por Produtivo
	cQuery += "   AND VDP_CODPRO = '"+cProdSelect+"'"
EndIf
cQuery += "   AND D_E_L_E_T_=' '"
dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cQAlias, .F., .T.)
While !(cQAlias)->(Eof())
	If nOpcDevPor == 1 // Por Produtivo
		aAux := FS_REQDEV( cProdSelect , (cQAlias)->( VDP_NUMOSV ) , " " , .t. , .t. , .f. ) // Retorna as Ferramentas que ainda precisam ser Devolvidas
	Else // nOpcDevPor == 2 // Por OS
		aAux := FS_REQDEV( " "         , (cQAlias)->( VDP_NUMOSV ) , " " , .f. , .t. , .f. ) // Retorna as Ferramentas que ainda precisam ser Devolvidas
	EndIf
	If len(aAux) > 0 // Tem Ferramentas para Devolver
		lMarcar := (cNrOSSelect==(cQAlias)->( VDP_NUMOSV ))
		aAdd(aOrdS,{ lMarcar , (cQAlias)->( VDP_NUMOSV ) })
		If lMarcar
			anAtLBx[2] := len(aOrdS)
		EndIf
	EndIf
	(cQAlias)->(DbSkip())
EndDo
(cQAlias)->(dbCloseArea())
If len(aOrdS) <= 0
	aAdd(aOrdS,{ .f. , " " })
EndIf
If aScan( aOrdS , {|x| x[1] == .t. }) <= 0
	anAtLBx[2] := 1
	aOrdS[1,1] := .t.
	cNrOSSelect := aOrdS[1,2]
EndIf
If lRefresh
	If anAtLBx[2] <= 5
		anAtLBx[2] := 1
	Else
		anAtLBx[2] -= 5
	EndIf
	&("oLbOrdS"+Alltrim(str(nOpcDevPor))+":nAt") := anAtLBx[2]
	&("oLbOrdS"+Alltrim(str(nOpcDevPor))+":SetArray(aOrdS)")
	&("oLbOrdS"+Alltrim(str(nOpcDevPor))+":Refresh()")
EndIf
OM450TTPO( lRefresh , @anAtLBx )
Return()

/*/{Protheus.doc} OM450TTPO
	@author       Andre Luis Almeida
	@since        15/05/2018
	@description  Devolucao Agrupada - Carrega ListBox dos Tipos de Tempo de um determinado Produtivo / OS
/*/
Function OM450TTPO( lRefresh , anAtLBx )
Local cQuery     := ""
Local cQAlias    := "SQLAUX"
Local aAux       := {}
Local lMarcar    := .f.
Default lRefresh := .f.
Default anAtLBx     := {1,1,1}
aTTpo := {}
cQuery := "SELECT DISTINCT VDP_TIPTEM "
cQuery += "  FROM " + RetSQLName("VDP")
cQuery += " WHERE VDP_FILIAL='"+xFilial("VDP")+"'"
If nOpcDevPor == 1 // Por Produtivo
	cQuery += "   AND VDP_CODPRO = '"+cProdSelect+"'"
EndIf
cQuery += "   AND VDP_NUMOSV = '"+cNrOSSelect+"'"
cQuery += "   AND D_E_L_E_T_=' '"
dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cQAlias, .F., .T.)
While !(cQAlias)->(Eof())
	If nOpcDevPor == 1 // Por Produtivo
		aAux := FS_REQDEV( cProdSelect , cNrOSSelect , (cQAlias)->( VDP_TIPTEM ) , .t. , .t. , .t. ) // Retorna as Ferramentas que ainda precisam ser Devolvidas
	Else // nOpcDevPor == 2 // Por OS
		aAux := FS_REQDEV( " "         , cNrOSSelect , (cQAlias)->( VDP_TIPTEM ) , .f. , .t. , .t. ) // Retorna as Ferramentas que ainda precisam ser Devolvidas
	EndIf
	If len(aAux) > 0 // Tem Ferramentas para Devolver
		lMarcar := (cTTpoSelect==(cQAlias)->( VDP_TIPTEM ))
		aAdd(aTTpo,{ lMarcar , (cQAlias)->( VDP_TIPTEM ) })
		If lMarcar
			anAtLBx[3] := len(aTTpo)
		EndIf
	EndIf
	(cQAlias)->(DbSkip())
EndDo
(cQAlias)->(dbCloseArea())
If len(aTTpo) <= 0
	aAdd(aTTpo,{ .f. , " " })
EndIf
If aScan( aTTpo , {|x| x[1] == .t. }) <= 0
	anAtLBx[3] := 1
	aTTpo[1,1] := .t.
	cTTpoSelect := aTTpo[1,2]
EndIf
If lRefresh
	If anAtLBx[3] <= 5
		anAtLBx[3] := 1
	Else
		anAtLBx[3] -= 5
	EndIf
	&("oLbTTpo"+Alltrim(str(nOpcDevPor))+":nAt") := anAtLBx[3]
	&("oLbTTpo"+Alltrim(str(nOpcDevPor))+":SetArray(aTTpo)")
	&("oLbTTpo"+Alltrim(str(nOpcDevPor))+":Refresh()")
EndIf
If nOpcDevPor == 2 // Por OS
	OM450PROD( lRefresh , @anAtLBx )
EndIf
Return()

/*/{Protheus.doc} FS_REQDEV
	@author       Andre Luis Almeida
	@since        15/05/2018
	@description  Devolucao Agrupada - Retorna vetor com as Ferramentas que ainda precisam ser Devolvidas
/*/
Static Function FS_REQDEV( _cProd , _cNumOS , _cTipTpo , lConsPd , lConsOS , lConsTT )
Local cQAlVD3 := "SQLVD3"
Local aRecVD3 := {}
Local aRet    := {}
Local nCntFor := 0
Local nLinha  := 0
Local cQuery  := ""
cQuery := "SELECT VD3.R_E_C_N_O_ AS RECVD3 , "
cQuery += "       VD3.VD3_CODFER , "
cQuery += "       VD3.VD3_LOCAL , "
cQuery += "       CASE "
cQuery += "         WHEN VD3.VD3_TIPMOV = '1' "
cQuery += "         THEN ( VD3.VD3_QTDMOV * ( 1) ) "
cQuery += "         ELSE ( VD3.VD3_QTDMOV * (-1) ) "
cQuery += "       END QTDMOV , "
cQuery += "       VO9.R_E_C_N_O_ AS RECVO9 "
cQuery += " FROM " + RetSQLName("VD3") + " VD3 "
cQuery += " JOIN " + RetSQLName("VO9") + " VO9 ON ("
cQuery += "       VO9.VO9_FILIAL = '" + xFilial("VO9") + "' AND VO9.VO9_CODFER = VD3.VD3_CODFER AND VO9.D_E_L_E_T_ = ' ' ) "
cQuery += " WHERE VD3.VD3_FILIAL = '" + xFilial("VD3") + "' "
If lConsPd
	cQuery += "  AND VD3.VD3_CODPRO = '" + _cProd + "' "
EndIf
If lConsOS
	cQuery += "  AND VD3.VD3_NUMOSV = '" + _cNumOS + "' "
EndIf
If lConsTT
	cQuery += "  AND VD3.VD3_TIPTEM = '" + _cTipTpo + "' "
EndIf
cQuery += "  AND VD3.VD3_CODFER <> ' ' "
cQuery += "  AND VD3.D_E_L_E_T_ = ' ' "
dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cQAlVD3, .F., .T.)
While !(cQAlVD3)->(Eof())
 	// Necessario o ASCAN pq deve conter um RECNO do VD3 por Ferramenta para montar a aCols
	nLinha := aScan( aRecVD3 , {|x| x[1] + x[5] == (cQAlVD3)->( VD3_CODFER ) + (cQAlVD3)->( VD3_LOCAL ) })
	If nLinha == 0
		aAdd( aRecVD3 , { (cQAlVD3)->( VD3_CODFER ) , 0 , (cQAlVD3)->( RECVD3 ) , (cQAlVD3)->( RECVO9 ) , (cQAlVD3)->( VD3_LOCAL ) })
		nLinha := len(aRecVD3)
	EndIf
	aRecVD3[nLinha,2] += (cQAlVD3)->( QTDMOV )
	(cQAlVD3)->(DbSkip())
EndDo
(cQAlVD3)->(dbCloseArea())
For nCntFor := 1 to len(aRecVD3)
	If aRecVD3[nCntFor,2] > 0 // Tem quantidade a Devolver
		aAdd(aRet,aClone(aRecVD3[nCntFor]))
	EndIf
Next
DbSelectArea("VD3")
Return aClone(aRet)

/*/{Protheus.doc} OM450QTDAGR
	@author       Andre Luis Almeida
	@since        15/05/2018
	@description  Devolucao Agrupada - Digitacao da Qtd.Movimento na aCols das Ferramentas
/*/
Function OM450QTDAGR()
Local nVD3QTDDEV := FG_POSVAR("VD3_QTDDEV")
Local lRet := .t.
If nVD3QTDDEV > 0
	If M->VD3_QTDMOV > oGetDados:aCols[oGetDados:nAt,nVD3QTDDEV]
		lRet := .f.
		MsgInfo(STR0006,STR0026) // Quantidade requisitada maior que a disponível.
	EndIf
EndIf
Return lRet

/*/{Protheus.doc} OM450TOKAGR
	@author       Andre Luis Almeida
	@since        15/05/2018
	@description  Devolucao Agrupada - Tudo OK da Tela
/*/
Function OM450TOKAGR()
Local lRet := .f.
Local lOk  := .f.
Local ni   := 0
Local nVD3QTDMOV := FG_POSVAR("VD3_QTDMOV")
Local nVD3QTDDEV := FG_POSVAR("VD3_QTDDEV")
Local nVD3CODFER := FG_POSVAR("VD3_CODFER")
// Verifica se o usuario deixou Ferramenta na aCols para ser devolvida
If !Empty(cProdSelect)
	For ni := 1 to len(oGetDados:aCols)
		If !oGetDados:aCols[ni,Len(oGetDados:aCols[ni])] .and. !Empty(oGetDados:aCols[ni,nVD3CODFER])
			If oGetDados:aCols[ni, nVD3QTDMOV] > 0 .and. ( nVD3QTDDEV == 0 .or. oGetDados:aCols[ni, nVD3QTDDEV] > 0 )
				lOk := .t.
				Exit
			EndIf
		EndIf
	Next
EndIf
If !lOk // Nenhuma Ferramenta foi deixada na aCols para ser devolvida
	MsgStop(STR0050,STR0026) // Ao menos uma devolução de ferramenta é necessária para continuar / Atencao
Else
	If MsgYesNo(STR0048,STR0026) // Confirma a Devolução das Ferramentas requisitadas para o Produtivo, OS e Tipo de Tempo selecionados ? / Atenção
		lRet    := .t.
		M->VDP_CODPRO := cProdSelect // Variaveis utilizadas na Funcao de Gravação OA450GRA
		M->VDP_NUMOSV := cNrOSSelect // Variaveis utilizadas na Funcao de Gravação OA450GRA
		M->VDP_TIPTEM := cTTpoSelect // Variaveis utilizadas na Funcao de Gravação OA450GRA
	EndIf
EndIf
Return lRet

/*/{Protheus.doc} OM450DELAGR
	@author       Andre Luis Almeida
	@since        15/05/2018
	@description  Devolucao Agrupada - Delete na aCols das Ferramentas
/*/
Function OM450DELAGR()
Local lRet := .t.
Local lOk  := .f.
Local ni   := 0
If !oGetDados:aCols[oGetDados:nAt,Len(oGetDados:aCols[oGetDados:nAt])]
	For ni := 1 to len(oGetDados:aCols)
		If ni <> oGetDados:nAt .and. !oGetDados:aCols[ni,Len(oGetDados:aCols[ni])]
			lOk := .t.
			Exit
		EndIf
	Next
Else
	lOk := .t.
EndIf
If lOk
	oGetDados:aCols[oGetDados:nAt,Len(oGetDados:aCols[oGetDados:nAt])] := !oGetDados:aCols[oGetDados:nAt,Len(oGetDados:aCols[oGetDados:nAt])]
	oGetDados:oBrowse:Refresh()
Else
	MsgStop(STR0049,STR0026) // Impossivel retirar todas as Ferramentas da grid para efetuar a Devolução. / Atenção
EndIf
Return lRet

Static Function FS_DevPor()
oLbProd1:lVisible := .f.
oLbProd2:lVisible := .f.
oLbOrdS1:lVisible := .f.
oLbOrdS2:lVisible := .f.
oLbTTpo1:lVisible := .f.
oLbTTpo2:lVisible := .f.
&("oLbProd"+Alltrim(str(nOpcDevPor))+":lVisible") := .t.
&("oLbOrdS"+Alltrim(str(nOpcDevPor))+":lVisible") := .t.
&("oLbTTpo"+Alltrim(str(nOpcDevPor))+":lVisible") := .t.
If nOpcDevPor == 1 // Por Produtivo
	OM450PROD( .t. , )
Else// nOpcDevPor == 2 // Por OS
	OM450ORDS( .t. , )
EndIf
Return