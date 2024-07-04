#Include 'FwMVCDef.ch'
#Include 'TOPCONN.CH'
#Include "OFIXX002.ch"
#Include "Protheus.ch"

/*/{Protheus.doc} OFIXX002

@author Andre Luis Almeida
@since 25/11/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function OFIXX002(cNumOrc)
Local lValidos	 := .t.
Local lVisualiza := .f.
Local cMsg		 := ""
Local lAprovador := OX0020151_UsuarioAprovador()
Local lVS1OBSCON := VS1->(ColumnPos("VS1_OBSCON")) > 0
Default cNumOrc := ""

// VS1 vem posicionado do Browse do OFIXA013 //
If lVS1OBSCON .and. !Empty(VS1->VS1_OBSCON)
	MsgAlert(VS1->VS1_OBSCON,STR0029) // Observacao para o Conferente
EndIf

cNroConf := OX0020071_ExisteConferencia( cNumOrc , lValidos )
If Empty(cNroConf)
	cNroConf := OX0020041_GravaRegistroConferencia( cNumOrc )
EndIf

If ExistFunc("OA3610011_Tempo_Total_Conferencia_Saida_Orcamento")
	OA3610011_Tempo_Total_Conferencia_Saida_Orcamento( 1 , cNumOrc ) // 1=Iniciar o Tempo Total da Conferencia de Saida caso não exista o registro
EndIf

VM5->( DbSeek( xFilial("VM5") + cNroConf ) )
Do Case
	Case VM5->VM5_STATUS == "1" .or. VM5->VM5_STATUS == "2"
		cMsg := STR0030 // Conferência do Orçamento está Pendente. Deseja Visualizar?
	Case VM5->VM5_STATUS == "3"
		cMsg := STR0031 // Conferência do Orçamento está Finalizada. Deseja Visualizar
	Case VM5->VM5_STATUS == "4"
		cMsg := STR0032 // Conferência do Orçamento está Aprovada. Deseja Visualizar?"
	Case VM5->VM5_STATUS == "5"
		cMsg := STR0033 // Conferência do Orçamento está Reprovada. Deseja Visualizar?
EndCase
if lAprovador .or. VM5->VM5_STATUS == "1" .or. VM5->VM5_STATUS == "2"
	If lAprovador .and. VM5->VM5_STATUS <> "3"
		If !MsgYesNo(cMsg)
			Return
		EndIf
		lVisualiza := .t.
	EndIf
Else
	If !MsgYesNo(cMsg)
		Return
	EndIf
	lVisualiza := .t.
EndIf

// CI 010343 - identificado situação onde há conflitos entre o softlock e o lockbyname 
// da rotina OFIXX001, por isso se fez necessário verificar se está travado e realizar o unlock
// e novamente o lock para não permitir que a conferencia e o orçamento fiquem abertos ao mesmo tempo
If !LockByName( 'OFIXX001_' +VS1->VS1_NUMORC, .T., .F. ) 
	UnlockByName( 'OFIXX001_' + VS1->VS1_NUMORC, .T., .F. ) 
	LockByName( 'OFIXX001_' +VS1->VS1_NUMORC, .T., .F. )
EndIf

OX0020011_TelaConferencia( cNroConf, lVisualiza ) // Tela de Conferencia dos Itens

UnlockByName( 'OFIXX001_' + VS1->VS1_NUMORC, .T., .F. ) 

Return


/*/{Protheus.doc} OX0020011_TelaConferencia

@author Andre Luis Almeida
@since 25/11/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function OX0020011_TelaConferencia( cConferencia, lVisualiza )

	Local aCoors        := FWGetDialogSize( oMainWnd )
	Local cTitulo       := STR0034 // Conferência de Peças Orçamento
	Local aButtons		:= {}
	Local lAprovador    := OX0020151_UsuarioAprovador()
	Local lVS1OBSCON    := VS1->(ColumnPos("VS1_OBSCON")) > 0

	Default cConferencia := ""
	Default lVisualiza  := .f.

	Private lMostraCod	:= .t.
	Private lMostraQtd  := .t.
	Private aItensConf	:= {}

	Private cPictQUANT  := Alltrim(GetSX3Cache("VS3_QTDCON","X3_PICTURE"))
	Private cCod        := space(50)
	Private nQtd        := 1

	if Empty(cConferencia)
		Return
	EndIf

	If lVisualiza .or. lAprovador
		lMostraQtd  := .f.
		lMostraCod  := .f.
	EndIf
	
	VM5->(DbSeek(xFilial("VM5")+cConferencia))

	OX0020021_LevantaItens(cConferencia)

	oConfBarra := MSDialog():New( aCoors[1], aCoors[2], aCoors[3], aCoors[4], cTitulo, , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. )    // "Área de Trabalho"
	oConfBarra:lEscClose := .F.

		oLayer := FWLayer():new()
		oLayer:Init(oConfBarra,.f.)

		//Cria as linhas do Layer
		oLayer:addLine( 'L1', 95, .F. )

		//Cria as colunas do Layer
		oLayer:addCollumn('C1L1',26,.F.,"L1") 
		oLayer:addCollumn('C2L1',74,.F.,"L1") 

		oLayer:AddWindow('C1L1','WIN_TPINF',STR0035,64,.F.,.F.,,'L1',) // Informações

		_cRight1Win:= oLayer:GetWinPanel('C1L1','WIN_TPINF', 'L1')
		
		oLayer:AddWindow('C1L1','WIN_LEGEN',STR0036,35,.F.,.F.,,'L1',) // Legenda
		_cRight2Win:= oLayer:GetWinPanel('C1L1','WIN_LEGEN', 'L1')

		_cTopCol2  := oLayer:getColPanel('C2L1','L1')

		// Cria browse
		oListItens := MsBrGetDBase():new( 0, 0, 260, 170,,,, _cTopCol2,,,,,,,,,,,, .F.,, .T.,, .F.,,, )
		oListItens:Align := CONTROL_ALIGN_ALLCLIENT

		// Define vetor para a browse
		oListItens:setArray( aItensConf )
	
		// Cria colunas do browse
		oListItens:addColumn( TCColumn():new( STR0037 , { || aItensConf[oListItens:nAt,2] },,,, "LEFT",, .F., .F.,,,, .F. ) ) // Grupo
		oListItens:addColumn( TCColumn():new( STR0038 , { || aItensConf[oListItens:nAt,3] },,,, "LEFT",, .F., .F.,,,, .F. ) ) // Cod.Item
		oListItens:addColumn( TCColumn():new( STR0039 , { || aItensConf[oListItens:nAt,4] },,,, "LEFT",, .F., .F.,,,, .F. ) ) // Descrição
		oListItens:addColumn( TCColumn():new( STR0040 , { || aItensConf[oListItens:nAt,9] },,,, "LEFT",, .F., .F.,,,, .F. ) ) // Locação
		oListItens:addColumn( TCColumn():new( STR0041 , { || FG_AlinVlrs(Transform(aItensConf[oListItens:nAt,5],cPictQUANT)) },,,, "LEFT",, .F., .T.,,,, .F. ) ) // Qtd.Conferida
		
		If lAprovador .or. ( GetNewPar("MV_MIL0046","S") == "S" )
			oListItens:addColumn( TCColumn():new( STR0042 , { || FG_AlinVlrs(Transform(aItensConf[oListItens:nAt,6],cPictQUANT)) },,,, "LEFT",, .F., .F.,,,, .F. ) ) // Qtd.Original
		EndIf

		bColor := &("{|| aItensConf[oListItens:nAt,1] }")
		oListItens:SetBlkBackColor(bColor)

		oCorAmarelo := tBitmap():New(005, 005, 068, 010, 'BR_AMARELO'   , , .T., _cRight2Win, {|| }, {|| }, .F., .F.,,, .F.,, .T.,, .F.)
		oSayAmarelo := tSay():New(005, 015, {|| STR0043 }  , _cRight2Win,,,,,, .T., CLR_HBLUE, CLR_WHITE, 080, 020) // Item não conferido

		oCorVerde := tBitmap():New(015, 005, 088, 010, 'BR_VERDE'   , , .T., _cRight2Win, {|| }, {|| }, .F., .F.,,, .F.,, .T.,, .F.)
		oSayVerde:= tSay():New(015, 015, {|| STR0044 } , _cRight2Win,,,,,, .T., CLR_HBLUE, CLR_WHITE, 080, 020) // Item conferido corretamente

		oCorVermelho := tBitmap():New(025, 005, 088, 010, 'BR_VERMELHO'   , , .T., _cRight2Win, {|| }, {|| }, .F., .F.,,, .F.,, .T.,, .F.)
		oSayVermelho:= tSay():New(025, 015, {|| STR0045 } , _cRight2Win,,,,,, .T., CLR_HBLUE, CLR_WHITE, 080, 020) // Item com divergência

		If !lVisualiza .and. !lAprovador
			oListItens:bLDblClick := { || lEditCell( aItensConf , oListItens , cPictQUANT , 5 ), OX0020101_QtdConferida(aItensConf[oListItens:nAt],aItensConf[oListItens:nAt,5],.t.)}
		EndIf

		oListItens:Refresh()

		nLinIni := 5

		If lMostraQtd // Mostra Qtde - Sim
			oSayQtd := tSay():New( nLinIni   , 005, {|| STR0046 } , _cRight1Win,,,,,, .T., CLR_HBLUE, CLR_WHITE, 080, 020) // Quantidade
			oGetQtd := TGet():New( nLinIni+8, 005, { | u | If( PCount() == 0, nQtd, nQtd := u ) },_cRight1Win,060, 010, cPictQUANT ,{ || nQtd >= 0 },,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"nQtd",,,,)
			nLinIni += 27
		EndIf

		If lMostraCod
			oSayCod := tSay():New( nLinIni   , 005, {|| STR0004 } , _cRight1Win,,,,,, .T., CLR_HBLUE, CLR_WHITE, 080, 020) // Cód.Barras:
			oGetCod := TGet():New( nLinIni+8, 005, { | u | If( PCount() == 0, cCod, cCod := u ) },_cRight1Win, 060, 010, "@!",{ || IIf(!Empty(cCod),(OX0020081_DigitacaoCodigo(),.f.),oListItens:SetFocus()) },,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cCod",,,,)
			nLinIni += 27
		EndIf

		oSayOrc := tSay():New( nLinIni   , 005, {|| STR0047 } , _cRight1Win,,,,,, .T., CLR_HBLUE, CLR_WHITE, 080, 020) // Orçamento
		oGetOrc := TGet():New( nLinIni+8, 005, { || VM5->VM5_NUMORC },_cRight1Win, 060, 010, "@!",{ || .t. },,,,.F.,,.T.,,.F.,{ || .f. },.F.,.F.,,.F.,.F. ,,"cNumOrc",,,,)
		nLinIni += 27

		If lVisualiza
			oSaySta := tSay():New( nLinIni  , 005, {|| STR0048 } , _cRight1Win,,,,,, .T., CLR_HBLUE, CLR_WHITE, 080, 020) // Status Conferencia
			cStatConf := ""
			Do Case
				Case VM5->VM5_STATUS == "1"
					cStatConf := STR0049 // Pendente
				Case VM5->VM5_STATUS == "2"
					cStatConf := STR0050 // Parcial
				Case VM5->VM5_STATUS == "3"
					cStatConf := STR0051 // Finalizada
				Case VM5->VM5_STATUS == "4"
					cStatConf := STR0052 // Aprovada
				Case VM5->VM5_STATUS == "5"
					cStatConf := STR0053 // Reprovada
			EndCase
			oGetSta := TGet():New( nLinIni+8, 005, { || cStatConf },_cRight1Win, 060, 010, "@!",{ || .t. },,,,.F.,,.T.,,.F.,{ || .f. },.F.,.F.,,.F.,.F. ,,"cStatConf",,,,)
			nLinIni += 27
		EndIf

		If lVS1OBSCON .and. !Empty(VS1->VS1_OBSCON)
			oSayObs := tSay():New( nLinIni   , 005, {|| STR0029 } , _cRight1Win,,,,,, .T., CLR_HBLUE, CLR_WHITE, 080, 020) // Observacao para o Conferente
			oGetObs := tMultiget():new( nLinIni+8, 005,{ || VS1->VS1_OBSCON },_cRight1Win,160,050,,,,,,.T.,,,{|| .f. },,,.T.,,,,,.t.)
			nLinIni += 27
		EndIf

	oConfBarra:Activate( , , , .t. , , ,EnchoiceBar( oConfBarra, { || IIf( !lVisualiza .and. OX0020031_ConfirmarConferencia(cConferencia), oConfBarra:End() , oConfBarra:End() ) }, { || oConfBarra:End() }, ,aButtons, , , , , .F., .T. ) ) //ativa a janela criando uma enchoicebar

Return

/*/{Protheus.doc} OX0020021_LevantaItens

@author Andre Luis Almeida
@since 25/11/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function OX0020021_LevantaItens( cConferencia )

	cQuery := "SELECT VM6.VM6_COD, VM6.VM6_QTCONF, VM6.VM6_QTORIG, VM6.R_E_C_N_O_ AS VM6RECNO , VS3.R_E_C_N_O_ AS VS3RECNO "
	cQuery += "  FROM " + RetSqlName("VM6") + " VM6 "
	cQuery += "  JOIN " + RetSqlName("VM5") + " VM5 ON ( VM5.VM5_FILIAL = '" + xFilial("VM5") + "' AND VM5.VM5_CODIGO='" + cConferencia + "' AND VM5.D_E_L_E_T_ = ' ' )"
	cQuery += "  JOIN " + RetSqlName("VS3") + " VS3 ON ( VS3.VS3_FILIAL = '" + xFilial("VS3") + "' AND VS3.VS3_NUMORC=VM5.VM5_NUMORC AND VS3.VS3_SQCONF=VM6.VM6_SEQUEN AND VS3.D_E_L_E_T_ = ' ' )"
	cQuery += " WHERE VM6.VM6_FILIAL = '" + xFilial("VM6") + "' "
	cQuery += "   AND VM6.VM6_CODVM5 = '" + cConferencia + "' "
	cQuery += "   AND VM6.D_E_L_E_T_ = ' '"

	TcQuery cQuery New Alias "TMPVM6"

	While !TMPVM6->(Eof())

		SB1->(DbSetOrder(1))
		SB1->(DbSeek(xFilial("SB1")+TMPVM6->VM6_COD))

		SB5->(DbSetOrder(1))
		SB5->(DbSeek(xFilial("SB5")+SB1->B1_COD))

		Aadd(aItensConf,{ "",;
						SB1->B1_GRUPO,;
						SB1->B1_CODITE,;
						SB1->B1_DESC,;
						TMPVM6->VM6_QTCONF,;
						TMPVM6->VM6_QTORIG,;
						SB1->B1_CODBAR,;
						SB1->B1_COD,;
						FM_PRODSBZ(SB1->B1_COD,"SB5->B5_LOCALI2"),;
						TMPVM6->VS3RECNO,;
						TMPVM6->VM6RECNO;
					})

		OX0020091_StatusItem(aItensConf[Len(aItensConf)])

		TMPVM6->(DbSkip())

	EndDo

	TMPVM6->(dbCloseArea())

	If Len(aItensConf) == 0
		Aadd(aItensConf,{ "",;
						"",;
						"",;
						"",;
						0,;
						0,;
						"",;
						"",;
						"",;
						0,;
						0;
		})
	EndIf

Return

/*/{Protheus.doc} OX0020031_ConfirmarConferencia

@author Andre Luis Almeida
@since 25/11/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function OX0020031_ConfirmarConferencia(cNroConf)

	Local lRetorno := .t.
	Local lAprovador := OX0020151_UsuarioAprovador()

	if lAprovador

		lRetorno := OX0020111_JaneladeAprovacao()

	Else
		If MsgNoYes(STR0054,STR0005) // Finaliza Conferência? / Atencao

			VM5->(DbSeek(xfilial("VM5") + cNroConf ) )

			OX0020131_VerificaDivergencias( VM5->VM5_CODIGO )

			If VM5->VM5_DIVERG == "1"
				If !MsgNoYes(STR0055,STR0005) // Há itens com divergencia. Deseja continuar? / Atencao
					lRetorno := .f.
				EndIf
			EndIf

			If lRetorno
				OX0020061_StatusConferencia( VM5->VM5_CODIGO , "3" )
				If VM5->VM5_DIVERG == "0" // NAO tem Divergencia - Aprova Automaticamente
					If OX0020161_LiberaItensConferidos( "0" )
						OX0020121_GravaConbar( VM5->VM5_NUMORC )
						OX0020061_StatusConferencia( VM5->VM5_CODIGO , "4" )
						If ExistFunc("OA3610011_Tempo_Total_Conferencia_Saida_Orcamento")
							OA3610011_Tempo_Total_Conferencia_Saida_Orcamento( 0 , VM5->VM5_NUMORC ) // 0=Finalizar o Tempo Total da Conferencia Saida Orcamento
						EndIf
					Else
						lRetorno := .f.
					EndIf
				Else
					// Ponto de entrada ao Finalizar a Conferencia
					if ExistBlock("OXX002FIN")
						ExecBlock("OXX002FIN",.f.,.f.)
					Endif
				EndIf
			EndIf

		EndIf
	EndIf

Return lRetorno

/*/{Protheus.doc} OX0020041_GravaRegistroConferencia

@author Andre Luis Almeida
@since 25/11/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function OX0020041_GravaRegistroConferencia( cNumOrc , cTpOrigem )

	Local oModelVM5 := FWLoadModel( 'OFIA230' )
	Local lRetVM5	:= .f.
	Local cNroConf	:= ""
	Local aVS3      := {}
	Local nCntFor   := 0
	Local nTamSeq   := GetSX3Cache("VM6_SEQUEN","X3_TAMANHO")
	Local cSeqVS3   := ""

	Default cNumOrc   := ""
	Default cTpOrigem := "0" // Tipo de Origem ( 0=Manual / 1-Leitor(Nao usado no momento, nao existe diferenciação em relação ao 0=Manual) / 2=Coletor de Dados )

	oModelVM5:SetOperation( MODEL_OPERATION_INSERT )

	lRetVM5 := oModelVM5:Activate()

	if lRetVM5

		oModelVM5:SetValue( "VM5MASTER", "VM5_NUMORC", cNumOrc )
		oModelVM5:SetValue( "VM5MASTER", "VM5_STATUS", "1" )

		oModelDet := oModelVM5:GetModel("VM6DETAIL")

		cQuery := "SELECT SB1.B1_COD, VS3.VS3_SEQUEN, VS3.VS3_SQCONF, VS3.VS3_QTDITE , VS3.R_E_C_N_O_ AS VS3REC "
		cQuery += "  FROM " + RetSqlName("VS3") + " VS3 "
		cQuery += "  JOIN " + RetSqlName("SB1") + " SB1 "
		cQuery += "    ON SB1.B1_FILIAL = '" + xFilial("SB1") + "'"
		cQuery += "   AND SB1.B1_GRUPO  = VS3.VS3_GRUITE"
		cQuery += "   AND SB1.B1_CODITE = VS3.VS3_CODITE"
		cQuery += "   AND SB1.D_E_L_E_T_ = ' '"
		cQuery += " WHERE VS3.VS3_FILIAL = '" + xFilial("VS3") + "'"
		cQuery += 	" AND VS3.VS3_NUMORC = '" + cNumOrc + "' "
		cQuery += 	" AND VS3.D_E_L_E_T_ = ' '"

		TcQuery cQuery New Alias "TMPVS3"

		While !TMPVS3->(Eof())

			oModelDet:AddLine()

			oModelDet:SetValue( "VM6_CODVM5", oModelVM5:GetValue( "VM5MASTER", "VM5_CODIGO") )
			If !Empty(TMPVS3->VS3_SQCONF)
				oModelDet:SetValue( "VM6_SEQUEN", TMPVS3->VS3_SQCONF )
			Else
				cSeqVS3 := strzero(Val(TMPVS3->VS3_SEQUEN),nTamSeq)
				oModelDet:SetValue( "VM6_SEQUEN", cSeqVS3 )
				aAdd(aVS3,{ TMPVS3->VS3REC , cSeqVS3 })
			EndIf
			oModelDet:SetValue( "VM6_COD"	, TMPVS3->B1_COD )
			oModelDet:SetValue( "VM6_QTORIG", TMPVS3->VS3_QTDITE )

			TMPVS3->(DbSkip())
		EndDo

		TMPVS3->(dbCloseArea())

		If ( lRet := oModelVM5:VldData() )

			if ( lRet := oModelVM5:CommitData())
			Else
				If cTpOrigem == "2" // 2=Coletor de Dados
					VTAlert(STR0056,"COMMITVM5") // Não foi possivel incluir o(s) registro(s)
				Else
					Help("",1,"COMMITVM5",,STR0056,1,0) // Não foi possivel incluir o(s) registro(s)
				EndIf
			EndIf

		Else
			If cTpOrigem == "2" // 2=Coletor de Dados
				VTAlert(STR0057,"VALIDVM5") // Problema na validação dos campos e não foi possivel concluir o relacionamento
			Else
				Help("",1,"VALIDVM5",,STR0057,1,0) // Problema na validação dos campos e não foi possivel concluir o relacionamento
			EndIf
		EndIf

		cNroConf := oModelVM5:GetValue("VM5MASTER","VM5_CODIGO")

		oModelVM5:DeActivate()

		If lRet .and. len(aVS3) > 0
			DbSelectArea("VS3")
			For nCntFor := 1 to len(aVS3)
				VS3->(DbGoTo(aVS3[nCntFor,1]))
				RecLock("VS3",.f.)
					VS3->VS3_SQCONF := aVS3[nCntFor,2] // Grava Sequencial para Conferencia
				MsUnLock()
			Next
		EndIf

	Else
		If cTpOrigem == "2" // 2=Coletor de Dados
			VTAlert(STR0058,"ACTIVEVM5") // Não foi possivel ativar o modelo de inclusão da tabela VM5
		Else
			Help("",1,"ACTIVEVM5",,STR0058,1,0) // Não foi possivel ativar o modelo de inclusão da tabela VM5
		EndIf
	EndIf

	FreeObj(oModelVM5)

Return cNroConf

/*/{Protheus.doc} OX0020051_DuplicaConferencia

@author Andre Luis Almeida
@since 25/11/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function OX0020051_DuplicaConferencia( cConferencia, lComDiverg )

	Local lRetVM5	:= .f.
	Local cNovaConf := ""
	Local oModelVM5 := FWLoadModel( 'OFIA230' )
	Local lAlterou  := .f.

	Default cConferencia := ""
	Default lComDiverg	:= .f.

	If VM5->( DbSeek( xFilial("VM5") + cConferencia ) )

		cNovaConf := OX0020041_GravaRegistroConferencia( VM5->VM5_NUMORC )

	EndIf

	If lComDiverg

		If VM5->( DbSeek( xFilial("VM5") + cNovaConf ) )

			oModelVM5:SetOperation( MODEL_OPERATION_UPDATE )

			lRetVM5 := oModelVM5:Activate()

			if lRetVM5
				
				oModelDet := oModelVM5:GetModel("VM6DETAIL")

				cQuery := "SELECT VM6.VM6_COD    , "
				cQuery += "       VM6.VM6_SEQUEN , "
				cQuery += "       VM6.VM6_QTCONF , "
				cQuery += "       VM6.VM6_DATINI , "
				cQuery += "       VM6.VM6_HORINI , "
				cQuery += "       VM6.VM6_DATFIN , "
				cQuery += "       VM6.VM6_HORFIN , "
				cQuery += "       VM6.VM6_USRCON   "
				cQuery += "  FROM " + RetSqlName("VM6") + " VM6 "
				cQuery += " WHERE VM6.VM6_FILIAL = '" + xFilial("VM6") + "' "
				cQuery += "   AND VM6.VM6_CODVM5 = '" + cConferencia + "' "
				cQuery += "   AND VM6.VM6_QTORIG = VM6.VM6_QTCONF "
				cQuery += "   AND VM6.D_E_L_E_T_ = ' ' "

				TcQuery cQuery New Alias "TMPVM6"

				While !TMPVM6->(Eof())

					lSeek := oModelDet:SeekLine({;
										{ "VM6_COD"		, TMPVM6->VM6_COD },;
										{ "VM6_SEQUEN"	, TMPVM6->VM6_SEQUEN };
									})

					If lSeek
						lAlterou := .t.
						oModelDet:SetValue( "VM6_QTCONF", TMPVM6->VM6_QTCONF )
						oModelDet:SetValue( "VM6_DATINI", stod(TMPVM6->VM6_DATINI) )
						oModelDet:SetValue( "VM6_HORINI", TMPVM6->VM6_HORINI )
						oModelDet:SetValue( "VM6_DATFIN", stod(TMPVM6->VM6_DATFIN) )
						oModelDet:SetValue( "VM6_HORFIN", TMPVM6->VM6_HORFIN )
						oModelDet:SetValue( "VM6_USRCON", TMPVM6->VM6_USRCON )
					EndIf

					TMPVM6->(DbSkip())

				EndDo

				TMPVM6->(dbCloseArea())

				If lAlterou
					If ( lRet := oModelVM5:VldData() )

						if ( lRet := oModelVM5:CommitData())
						Else
							Help("",1,"COMMITVM5",,STR0056+oModelVM5:GetErrorMessage()[6],1,0) // Não foi possivel incluir o(s) registro(s)
						EndIf

					Else
						Help("",1,"VALIDVM5",,STR0057+oModelVM5:GetErrorMessage()[6],1,0) // Problema na validação dos campos e não foi possivel concluir o relacionamento
					EndIf
				EndIf

				oModelVM5:DeActivate()

			Else
				Help("",1,"ACTIVEVM5",,STR0058,1,0) // Não foi possivel ativar o modelo de inclusão da tabela VM5
			EndIf

		EndIf

	EndIf

	FreeObj(oModelVM5)

	If lAlterou
		OX0020061_StatusConferencia( cNovaConf , "2" ) // Grava o STATUS Parcial na Tabela de Historico
	EndIf

Return

/*/{Protheus.doc} OX0020061_StatusConferencia

@author Andre Luis Almeida
@since 25/11/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function OX0020061_StatusConferencia( cConferencia , cStatus, cTpOrigem )

	Local oModelVM5 := FWLoadModel( 'OFIA230' )
	Local lRetVM5	:= .f.
	Local cStatusRet:= ""
	Local lMudouStatus := .f.

	Default cConferencia := ""
	Default cTpOrigem := "0" // Tipo de Origem ( 0=Manual / 1-Leitor(Nao usado no momento, nao existe diferenciação em relação ao 0=Manual) / 2=Coletor de Dados )

	If VM5->( DbSeek( xFilial("VM5") + cConferencia ) )

		oModelVM5:SetOperation( MODEL_OPERATION_UPDATE )

		lRetVM5 := oModelVM5:Activate()

		if lRetVM5

			if cStatus <> oModelVM5:GetValue("VM5MASTER","VM5_STATUS")
				oModelVM5:SetValue( "VM5MASTER", "VM5_STATUS", cStatus )

				If oModelVM5:VldData()

					if oModelVM5:CommitData()
						lMudouStatus := .t.
					Else
						If cTpOrigem == "2" // 2=Coletor de Dados
							VTAlert(STR0059,"COMMITVM5") // Não foi possivel gravar o(s) registro(s)
						Else
							Help("",1,"COMMITVM5",,STR0059,1,0) // Não foi possivel gravar o(s) registro(s)
						EndIf
					EndIf

				Else
					If cTpOrigem == "2" // 2=Coletor de Dados
						VTAlert(STR0057,"VALIDVM5") // Problema na validação dos campos e não foi possivel concluir o relacionamento
					Else
						Help("",1,"VALIDVM5",,STR0057,1,0) // Problema na validação dos campos e não foi possivel concluir o relacionamento
					EndIf
				EndIf

				cStatusRet := oModelVM5:GetValue("VM5MASTER","VM5_STATUS")

				oModelVM5:DeActivate()
			Else
				cStatusRet := oModelVM5:GetValue("VM5MASTER","VM5_STATUS")
			EndIf
		Else
			If cTpOrigem == "2" // 2=Coletor de Dados
				VTAlert(STR0058,"ACTIVEVM5") // Não foi possivel ativar o modelo de inclusão da tabela VM5
			Else
				Help("",1,"ACTIVEVM5",,STR0058,1,0) // Não foi possivel ativar o modelo de inclusão da tabela VM5
			EndIf
		EndIf

	EndIf

	FreeObj(oModelVM5)

	If lMudouStatus
		If ExistBlock("OX002STA")
			ExecBlock("OX002STA",.f.,.f.,{ cConferencia , cStatus, cTpOrigem })
		EndIf
	EndIf

Return cStatusRet

/*/{Protheus.doc} OX0020071_ExisteConferencia

@author Andre Luis Almeida
@since 25/11/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function OX0020071_ExisteConferencia(cNumOrc, lSoValidos, cDesprConf )

	Local cQuery := ""
	Local cRetorno := ""

	Default lSoValidos := .f.
	Default cDesprConf := ""

	cQuery := "SELECT VM5.VM5_CODIGO "
	cQuery += " FROM " + RetSqlName("VM5") + " VM5 "
	cQuery += " WHERE VM5.VM5_FILIAL = '" + xFilial("VM5") + "'"
	cQuery +=	" AND VM5.VM5_NUMORC = '" + cNumOrc + "'"
	
	if !Empty(cDesprConf)
		cQuery +=	" AND VM5.VM5_CODIGO <> '" + cDesprConf + "'" // Despresa conferencia
	EndIf

	If lSoValidos
		cQuery +=	" AND VM5.VM5_STATUS IN ('1','2','3','4')"
	EndIf

	cQuery +=	" AND VM5.D_E_L_E_T_ = ' '"
	cQuery +=" ORDER BY VM5_CODIGO DESC"

	TcQuery cQuery New Alias "TMPVM5"

	If !TMPVM5->(Eof())
		cRetorno := TMPVM5->VM5_CODIGO
	EndIf

	TMPVM5->(dbCloseArea())

Return cRetorno

/*/{Protheus.doc} OX0020081_DigitacaoCodigo

@author Andre Luis Almeida
@since 25/11/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function OX0020081_DigitacaoCodigo()

	Local lCodBarra := .f.

	Local aProduto  := {}
	Local oPeca     := DMS_Peca():New()

	Private cCodSB1   := ""

	If !Empty(cCod)

		aProduto := oPeca:LeCodBarras(cCod) // Leitura do Codigo de Barras
		lCodBarra := Len(aProduto) > 0 .and. !Empty(aProduto[1])
		
		If lCodBarra
			cCodSB1 := aProduto[1]
		Else
			cCodSB1 := PadR(cCod, GetSX3Cache("B1_COD","X3_TAMANHO"))
		EndIf

		If FG_POSSB1("cCodSB1","SB1->B1_COD","")

			nPosItem := aScan(aItensConf,{|x| Alltrim(x[8]) == Alltrim(cCodSB1) }) // CODIGO ( B1_COD )

			If nPosItem > 0

				oListItens:SetArray(aItensConf)
				oListItens:nAt := nPosItem

				OX0020101_QtdConferida(aItensConf[nPosItem],nQtd)

				nQtd:= 1
				cCod:= space(50)

				If lMostraQtd
					oGetQtd:Refresh()
				EndIf
				If lMostraCod
					oGetCod:Refresh()
				EndIf
				oListItens:SetFocus()
				oListItens:Refresh()
			Else
				MsgStop(STR0060,STR0005) // Item não encontrado neste Orçamento. / Atencao
			EndIf

		Else
			MsgStop(STR0061,STR0005) // Item não consta no Cadastro de Produtos. / Atencao
		EndIf

	EndIf

	FreeObj(oPeca)

Return

/*/{Protheus.doc} OX0020091_StatusItem

@author Andre Luis Almeida
@since 25/11/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function OX0020091_StatusItem(aVetItem)

	//aVetItem[1] - Cor da linha
	//aVetItem[5] - VM6_QTCONF
	//aVetItem[6] - VM6_QTORIG

	Do Case
		Case aVetItem[5] == 0 // Item nao conferido
			aVetItem[1] := RGB(255,215,0)
		Case aVetItem[5] == aVetItem[6] // Quantidade conferida 
			aVetItem[1] := RGB(80,200,0)
		Case aVetItem[5] <> aVetItem[6] // Divergencia na conferencia 
			aVetItem[1] := RGB(255,99,71)
		OtherWise
			aVetItem[1] := RGB(30,144,255)
	EndCase

Return

/*/{Protheus.doc} OX0020101_QtdConferida

@author Andre Luis Almeida
@since 25/11/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

Static Function OX0020101_QtdConferida(aItemConf,nQtdConf,lDigitado)

	Local lProblem    := .f.
	Default lDigitado := .f.

	If nQtdConf < 0
		nQtdConf := 0
	EndIf

	If lDigitado
		If nQtdConf > aItemConf[6]
			lProblem := .t.
			aItemConf[5] := aItemConf[6]
		EndIf
	Else
	 	If aItemConf[5] + nQtdConf > aItemConf[6]
			lProblem := .t.
		EndIf
	EndIf
	If lProblem
		MsgStop(STR0062,STR0005) // / Atencao
	Else
		If nQtdConf == 0 .or. lDigitado
			aItemConf[5] := nQtdConf
		Else
			aItemConf[5] += nQtdConf
		EndIf
	EndIf

	OX0020141_GravaQtdConferida( aItemConf[11] , aItemConf[5] , "0" , aItemConf[10] )
	OX0020091_StatusItem(aItemConf)
	OX0020061_StatusConferencia( VM5->VM5_CODIGO , "2" )

Return .t.

/*/{Protheus.doc} OX0020111_JaneladeAprovacao

@author Andre Luis Almeida
@since 25/11/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function OX0020111_JaneladeAprovacao()

	Local nOpcao     := 0
	Local lRetorno := .t.
	Local lTemDiverg := VM5->VM5_DIVERG == "1"

	oDlgOpcoes := MSDialog():New( 0, 0, 90, 620, STR0034, , , , , , , , , .T., , , , .F. ) // Conferencia de Pecas Orcamento

	If lTemDiverg
		oBotaoApr := tButton():New(10,200,STR0063,oDlgOpcoes, { || nOpcao := 1 , oDlgOpcoes:End() } , 100 , 20 ,,,,.T.,,,,{ || .t.  }) // Aprovar Conferência com Divergencias
		oBotaoRjD := tButton():New(10,010,STR0064,oDlgOpcoes, { || nOpcao := 2 , oDlgOpcoes:End() } , 90 , 20 ,,,,.T.,,,,{ || .t. }) // Re-Conferir Itens Divergentes
		oBotaoRjT := tButton():New(10,105,STR0065,oDlgOpcoes, { || nOpcao := 3 , oDlgOpcoes:End() } , 90 , 20 ,,,,.T.,,,,{ || .t. }) // Re-Conferir Todos Itens
	Else
		oBotaoApr := tButton():New(10,010,STR0066,oDlgOpcoes, { || nOpcao := 1 , oDlgOpcoes:End() } , 290 , 20 ,,,,.T.,,,,{ || .t.  }) // Aprovar Conferência
	EndIf

	oDlgOpcoes:Activate( , , , .t. , , , , ,, , , , , , ) //ativa a janela criando uma enchoicebar

	Begin Transaction
		Do Case 
			Case nOpcao == 1
				If OX0020161_LiberaItensConferidos( "0" )
					OX0020121_GravaConbar( VM5->VM5_NUMORC )
					OX0020061_StatusConferencia( VM5->VM5_CODIGO , "4" )
					If ExistFunc("OA3610011_Tempo_Total_Conferencia_Saida_Orcamento")
						OA3610011_Tempo_Total_Conferencia_Saida_Orcamento( 0 , VM5->VM5_NUMORC ) // 0=Finalizar o Tempo Total da Conferencia Saida Orcamento
					EndIf
				Else
					lRetorno := .f.
				EndIf
			Case nOpcao == 2
				OX0020061_StatusConferencia( VM5->VM5_CODIGO , "5" )
				OX0020051_DuplicaConferencia( VM5->VM5_CODIGO , .t. )
			Case nOpcao == 3
				OX0020061_StatusConferencia( VM5->VM5_CODIGO , "5" )
				OX0020051_DuplicaConferencia( VM5->VM5_CODIGO )
			Otherwise
				lRetorno := .f.
		EndCase
	End Transaction

Return lRetorno

/*/{Protheus.doc} OX0020121_GravaConbar

@author Andre Luis Almeida
@since 25/11/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function OX0020121_GravaConbar(cNumOrc)

	DbSelectArea("VS3")

	cQuery := "SELECT VS3.R_E_C_N_O_ AS VS3REC "
	cQuery += "  FROM " + RetSqlName("VS3") + " VS3 "
	cQuery += " WHERE VS3.VS3_FILIAL = '" + xFilial("VS3") + "'"
	cQuery += "   AND VS3.VS3_NUMORC = '" + cNumOrc + "'"
	cQuery += "   AND VS3.D_E_L_E_T_ = ' '"

	TcQuery cQuery New Alias "TMPVS3"

	While !TMPVS3->(Eof())

		VS3->(DbGoTo(TMPVS3->VS3REC))

		RecLock("VS3",.f.)
			VS3->VS3_CONBAR := '1'
		MsUnlock()

		TMPVS3->(DbSkip())

	EndDo

	TMPVS3->(dbCloseArea())

Return

/*/{Protheus.doc} OX0020131_VerificaDivergencias

@author Andre Luis Almeida
@since 25/11/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function OX0020131_VerificaDivergencias(cConferencia , cTpOrigem)

	Local cQuery := ""
	Local oModelVM5 := FWLoadModel( 'OFIA230' )
	Local lRetVM5	:= .f.

	Default cConferencia := ""
	Default cTpOrigem := "0" // Tipo de Origem ( 0=Manual / 1-Leitor(Nao usado no momento, nao existe diferenciação em relação ao 0=Manual) / 2=Coletor de Dados )

	cQuery := "SELECT COUNT(VM6.VM6_SEQUEN) AS QTDE "
	cQuery += "  FROM " + RetSqlName("VM6") + " VM6 "
	cQuery += " WHERE VM6.VM6_FILIAL = '" + xFilial("VM6") + "'"
	cQuery += "   AND VM6.VM6_CODVM5 = '" + cConferencia + "' "
	cQuery += "   AND VM6.VM6_QTORIG <> VM6.VM6_QTCONF "
	cQuery += "   AND VM6.D_E_L_E_T_ = ' ' "

	TcQuery cQuery New Alias "TMPVM6"

	If !TMPVM6->(Eof())

		VM5->(DbSeek(xFilial("VM5") + cConferencia))

		oModelVM5:SetOperation( MODEL_OPERATION_UPDATE )

		lRetVM5 := oModelVM5:Activate()

		if lRetVM5

			If TMPVM6->(QTDE) > 0
				oModelVM5:SetValue( "VM5MASTER", "VM5_DIVERG", "1" ) // Com Divergencia
			Else
				oModelVM5:SetValue( "VM5MASTER", "VM5_DIVERG", "0" ) // Sem Divergencia
			EndIf

			If ( lRet := oModelVM5:VldData() )

				if ( lRet := oModelVM5:CommitData())
				Else
					If cTpOrigem == "2" // 2=Coletor de Dados
						VTAlert(STR0059,"COMMITVM5") // Não foi possivel gravar o(s) registro(s)
					Else
						Help("",1,"COMMITVM5",,STR0059,1,0) // Não foi possivel gravar o(s) registro(s)
					EndIf
				EndIf

			Else
				If cTpOrigem == "2" // 2=Coletor de Dados
					VTAlert(STR0057,"VALIDVM5") // Problema na validação dos campos e não foi possivel concluir o relacionamento
				Else
					Help("",1,"VALIDVM5",,STR0057,1,0) // Problema na validação dos campos e não foi possivel concluir o relacionamento
				EndIf
			EndIf

			oModelVM5:DeActivate()

		Else
			If cTpOrigem == "2" // 2=Coletor de Dados
				VTAlert(STR0058,"ACTIVEVM5") // Não foi possivel ativar o modelo de inclusão da tabela VM5
			Else
				Help("",1,"ACTIVEVM5",,STR0058,1,0) // Não foi possivel ativar o modelo de inclusão da tabela VM5
			EndIf
		EndIf

	EndIf

	TMPVM6->(dbCloseArea())

	FreeObj(oModelVM5)

Return

/*/{Protheus.doc} OX0020141_GravaQtdConferida
Grava Qtde Conferida

@author Andre Luis Almeida
@since 25/11/2019
@version undefined
@param cTpOrigem Tipo de Origem ( 0=Manual / 1-Leitor(Nao usado no momento, nao existe diferenciação em relação ao 0=Manual) / 2=Coletor de Dados )

@type function
/*/
Function OX0020141_GravaQtdConferida( nRecVM6 , nQtdConf, cTpOrigem , nRecVS3 )

	Local oModelVM5 := FWLoadModel( 'OFIA230' )

	Default cTpOrigem := "0" // Tipo de Origem ( 0=Manual / 1-Leitor(Nao usado no momento, nao existe diferenciação em relação ao 0=Manual) / 2=Coletor de Dados )
	Default nRecVM6 := 0
	Default nRecVS3 := 0

	If nRecVM6 > 0

		oModelVM5:SetOperation( MODEL_OPERATION_UPDATE )

		lRetVM5 := oModelVM5:Activate()

		if lRetVM5

			oModelDet := oModelVM5:GetModel("VM6DETAIL")
			oModelDet:GoToDataID(nRecVM6)
			oModelDet:SetValue( "VM6_QTCONF", nQtdConf )

			If Empty(oModelDet:GetValue( "VM6_DATINI"))
				oModelDet:SetValue( "VM6_DATINI", dDataBase )
				oModelDet:SetValue( "VM6_HORINI", Time() )
				oModelDet:SetValue( "VM6_USRCON", __cUserID )
			EndIf
			oModelDet:SetValue( "VM6_DATFIN", dDataBase )
			oModelDet:SetValue( "VM6_HORFIN", Time() )

			If ( lRet := oModelVM5:VldData() )

				if ( lRet := oModelVM5:CommitData())
				Else
					If cTpOrigem == "2" // 2=Coletor de Dados
						VTAlert(STR0059,"COMMITVM5") // Não foi possivel gravar o(s) registro(s)
					Else
						Help("",1,"COMMITVM5",,STR0059,1,0) // Não foi possivel gravar o(s) registro(s)
					EndIf
				EndIf

			Else
				If cTpOrigem == "2" // 2=Coletor de Dados
					VTAlert(STR0057,"VALIDVM5") // Problema na validação dos campos e não foi possivel concluir o relacionamento
				Else
					Help("",1,"VALIDVM5",,STR0057,1,0) // Problema na validação dos campos e não foi possivel concluir o relacionamento
				EndIf
			EndIf

			oModelVM5:DeActivate()

			If lRet .and. nRecVS3 > 0
				DbSelectArea("VS3")
				DbGoTo(nRecVS3)
				RecLock("VS3",.F.)
				VS3->VS3_QTDCON := nQtdConf
				MsUnlock()
			EndIf

		Else
			If cTpOrigem == "2" // 2=Coletor de Dados
				VTAlert(STR0058,"ACTIVEVM5") // Não foi possivel ativar o modelo de inclusão da tabela VM5
			Else
				Help("",1,"ACTIVEVM5",,STR0058,1,0) // Não foi possivel ativar o modelo de inclusão da tabela VM5
			EndIf
		EndIf

	EndIf

	FreeObj(oModelVM5)

Return

/*/{Protheus.doc} OX0020151_UsuarioAprovador
Retorna se o usuario logado é Aprovador

@author Andre Luis Almeida
@since 25/11/2019
@version 1.0
@return logico ( .t. / .f. )

@type function
/*/
Function OX0020151_UsuarioAprovador()
	VAI->(dbSetOrder(4))
	VAI->(MsSeek(xFilial("VAI")+__cUserID)) // Posiciona no VAI do usuario logado
Return VAI->VAI_APRCON == "1"

/*/{Protheus.doc} OX0020161_LiberaItensConferidos
	Libera itens conferidos

	@author Andre Luis Almeida
	@since  25/11/2019

	@param cTpOrigem Tipo de Origem ( 0=Manual / 1-Leitor(Nao usado no momento, nao existe diferenciação em relação ao 0=Manual) / 2=Coletor de Dados )
/*/
Function OX0020161_LiberaItensConferidos( cTpOrigem )

Local aAuxItens := {}
Local cFaseConfer := Alltrim(GetNewPar("MV_MIL0095","4")) // Fase de Conferencia e Separacao

Local oPeca := DMS_Peca():New()

Local aItemMov    := {}
Local oEst        := DMS_Estoque():New()

Local lExcluiItem	:= .f.
Local nContItem     := 0

Local lESTNEG       := ( GetNewPar("MV_ESTNEG","S") == "S" )
Local cMV_MIL0037   := GetNewPar("MV_MIL0037","S") // Movimenta em divergencia de estoque? (S/N) 

Local lReservado	:= .f.

Private aHeaderP    := {} // Variavel ultilizada na OX001RESITE

Default cTpOrigem   := "0" // Tipo de Origem ( 0=Manual / 1-Leitor(Nao usado no momento, nao existe diferenciação em relação ao 0=Manual) / 2=Coletor de Dados )

// Ponto de entrada chamado quando clica em Liberar.
if ExistBlock("OX002LIB")
	lRetorn := ExecBlock("OX002LIB",.f.,.f.)
	if !lRetorn
		If cTpOrigem == "2" // 2=Coletor de Dados
			VTAlert(STR0022,"PE OX002LIB") // Conferencia nao finalizada. / PE OX002LIB
		EndIf
		FreeObj(oPeca)
		return .f.
	Endif
Endif

cQuery := "SELECT R_E_C_N_O_"
cQuery += "  FROM "+RetSQLName('VS3')
cQuery += " WHERE VS3_FILIAL = '"+VS1->VS1_FILIAL+"'"
cQuery += "   AND VS3_NUMORC = '"+VS1->VS1_NUMORC+"'"
cQuery += "   AND VS3_QTDITE <> VS3_QTDCON "
cQuery += "   AND D_E_L_E_T_ = ' ' "
If FM_SQL(cQuery) > 0
	If cTpOrigem == "2" // 2=Coletor de Dados
		If !VtYesNo(STR0067,STR0023,.t.) // Existem divergencias nos Itens. Deseja Liberar com divergencia? / Deseja Liberar?
			FreeObj(oPeca)
			return .f.
		EndIf
		If !VtYesNo(STR0024,STR0023,.t.) // Se o Orcamento for liberado, nao havera possibilidade de nova conferencia! / Deseja Liberar?
			FreeObj(oPeca)
			return .f.
		EndIf
	Else
		If !MsgYesNo(STR0067,STR0005) // Existem divergencias nos Itens. Deseja Liberar com divergencia? / Atencao
			FreeObj(oPeca)
			return .f.
		endif
		If !MsgYesNo(STR0009,STR0005) // Se o orcamento for liberado nao havera possibilidade de nova conferencia! Deseja liberar com divergencia? / Atencao 
			FreeObj(oPeca)
			return .f.
		endif
	EndIf
EndIf

// reserva itens não conferidos
aItensNew := {}
cDocumento  := Criavar("D3_DOC")
cDocumento	:= IIf(Empty(cDocumento),NextNumero("SD3",2,"D3_DOC",.T.),cDocumento)
cDocumento	:= A261RetINV(cDocumento)

BEGIN TRANSACTION

DBSelectArea("VS3")
DBSetOrder(1)
DBSeek(xFilial("VS3")+VS1->VS1_NUMORC)
// Adiciona cabecalho com numero do documento e data da transferencia modelo II
aadd (aItensNew,{ cDocumento , VS1->VS1_DATORC})
//
lIntegra261 := .f.
while !eof() .and. xFilial("VS3") + VS1->VS1_NUMORC == VS3->VS3_FILIAL + VS3->VS3_NUMORC
	nQtdReserva := VS3->VS3_QTDITE - VS3->VS3_QTDCON
	if nQtdReserva > 0
		//
		lIntegra261 := .t.
		lReservado  := .f.
		//
		DbSelectArea("SB1")
		DbSetOrder(7)
		DBSeek(xFilial("SB1")+VS3->VS3_GRUITE+VS3->VS3_CODITE)
		//
		DbSelectArea("SB5")
		DbSetOrder(1)
		DbSeek( xFilial("SB5") + SB1->B1_COD )
		//
		DbSelectArea("SB1")
		DbSetOrder(1)

		// sequencia
		// produto, descricao, unidade de medida, local/localizacao origem
		// produto, descricao, unidade de medida, local/localizacao destino
		// numero de serie, lote, sublote, data de validade, qunatidade
		// quantidade na 2 unidade, estorno, numero de sequencia
		cFaseOrc := OI001GETFASE(VS1->VS1_NUMORC)
		nPosR := At("R",cFaseOrc)
		nPosA := At(cFaseConfer,cFaseOrc)
		if VS1->VS1_TIPORC <> '3' // Orcamento Balcao / Orcamento Oficina
			if (nPosR < nPosA .and. nPosR != 0) .or. (VS3->VS3_RESERV == '1')
				cLocalDis   := GetMv( "MV_RESITE" )+Space(TamSx3("B2_LOCAL")[1]-Len(GetMv("MV_RESITE")))
				cLOCALI2Dis := IIf(Localiza(SB1->B1_COD),GetMv( "MV_RESLOC" )+Space(TamSx3("B5_LOCALI2")[1]-Len(GetMv("MV_RESLOC"))),Space(15))
				lReservado := .t.
			else // Nao teve Reserva
				cLocalDis   := VS3->VS3_LOCAL
				cLOCALI2Dis := FM_PRODSBZ(SB1->B1_COD,"SB5->B5_LOCALI2") //SB5->B5_LOCALI2
			endif
		Else // VS1->VS1_TIPORC == '3' // Orcamento de Transferencia
			if VS3->VS3_QTDRES > 0
				cLocalDis   := GetMv( "MV_RESITE" )+Space(TamSx3("B2_LOCAL")[1]-Len(GetMv("MV_RESITE")))
				cLOCALI2Dis := IIf(Localiza(SB1->B1_COD),GetMv( "MV_RESLOC" )+Space(TamSx3("B5_LOCALI2")[1]-Len(GetMv("MV_RESLOC"))),Space(15))
				lReservado := .t.
			else // Nao teve Reserva
				cLocalDis   := VS3->VS3_LOCAL
				cLOCALI2Dis := FM_PRODSBZ(SB1->B1_COD,"SB5->B5_LOCALI2") //SB5->B5_LOCALI2
			endif
		Endif
		//
		cLocalRes  := GetMv( "MV_DIVITE" )+Space(TamSx3("B2_LOCAL")[1]-Len(GetMv("MV_DIVITE")))
		cLOCALI2Res := IIf(Localiza(SB1->B1_COD),GetMv( "MV_DIVLOC" )+Space(TamSx3("B5_LOCALI2")[1]-Len(GetMv("MV_DIVLOC"))),Space(15))
		//
		nPosAEstq := aScan(aItensNew,{|x| x[1]+[12]+[13] == SB1->B1_COD+IIF(VS3->(FieldPos("VS3_LOTECT"))> 0 .and.!Empty(VS3->VS3_LOTECT),VS3->VS3_LOTECT,"")+IIF(VS3->(FieldPos("VS3_NUMLOT"))> 0 .and. !Empty(VS3->VS3_NUMLOT),VS3->VS3_NUMLOT,"") })
		If nPosAEstq == 0

			aItemMov := oEst:SetItemSD3(SB1->B1_COD          ,; //Código do Produto
										cLocalDis            ,; // Armazém de Origem
										cLocalRes            ,; // Armazém de Destino
										cLOCALI2Dis          ,; // Localização Origem
										cLOCALI2Res          ,; // Localização Destino
										nQtdReserva          ,; // Qtd a transferir
										VS3->VS3_LOTECT      ,; // Nro de lote
										VS3->VS3_NUMLOT       ) // Nro de Sub-Lote

			aAdd(aItensNew, aClone(aItemMov))

		Else

			aItensNew[nPosAEstq,16] += nQtdReserva

		Endif

		If ( ExistBlock("OX002ARS") )
			aAuxItens := ExecBlock("OX002ARS",.F.,.F.,{aItensNew})
			If ( ValType(aAuxItens) == "A" )
				aItensNew := aClone(aAuxItens)
			EndIf
		EndIf

		If lReservado
			// Gravacao do VE6
			OX001VE6(VS1->VS1_NUMORC,.T.) // RESERVA DO ITEM
			//
		EndIf

	endif

	DBSelectArea("VS3")
	DBSkip()
enddo
///////////////////////////////////////////////////////////////////////////////////////////////////////////
// Faz a Integracao com o MATA261 das Divergencias somente quando Estoque Negativo MV_ESTNEG igual a NAO //
///////////////////////////////////////////////////////////////////////////////////////////////////////////
if lIntegra261 .and. cMV_MIL0037 == "S" .and. !lESTNEG
	lMSErroAuto := .f.
	lExcluiItem := .t.
	MSExecAuto({|x, y| MATA261(x,y)},aItensNew,3)
	If lMsErroAuto
		If cTpOrigem == "2" // 2=Coletor de Dados
			VtBeep(3) // 3 Beep ERRO
			VTAlert(STR0025,STR0026) // Houve um problema na transferencia dos itens com divergencia na conferencia. / Transferencia Itens
		Else // 0=Manual / 1=Leitor
			MsgInfo(STR0021,STR0005) // Houve um problema na transferencia dos itens com divergencia na conferencia. Clique em Fechar para exibir a mensagem que indica o ocorrido.
			MostraErro()
		EndIf
		DisarmTransaction()
		FreeObj(oPeca)
		return .f.
	EndIf
EndIf
// Ponto de entrada depois da gravação da transferencia.
if ExistBlock("OXX002DTR")
	lRetorn := ExecBlock("OXX002DTR",.f.,.f.)
	if !lRetorn
		DisarmTransaction()
		If cTpOrigem == "2" // 2=Coletor de Dados
			VTAlert(STR0022,"PE OXX002DTR") // Conferencia nao finalizada. / PE OXX002DTR
		Else // 0=Manual / 1=Leitor
			MsgInfo(STR0022,"PE OXX002DTR") // Conferencia nao finalizada. / PE OXX002DTR
		EndIf
		FreeObj(oPeca)
		return .f.
	Endif
Endif

If VS1->VS1_TIPORC == '3' // Orcamento de Transferencia

	If OX0020181_Finaliza_Orcto_Transf( .t. , cTpOrigem , lExcluiItem , @nContItem )
		DBSelectArea("VS1")
		reclock("VS1",.f.)
		If nContItem > 0
			VS1->VS1_STATUS := "F" // Mudar STATUS do Orcamento Transferencia
		Else
			VS1->VS1_STATUS := "C"
		EndIf
		msunlock()
		If ExistFunc("OA3700011_Grava_DTHR_Status_Orcamento")
			OA3700011_Grava_DTHR_Status_Orcamento( VS1->VS1_NUMORC , VS1->VS1_STATUS , STR0001 ) // Grava Data/Hora na Mudança de Status do Orçamento / Orcamento - Conferencia de Itens
		EndIf
	Else
		Return .f.
	EndIf
	
EndIf

END TRANSACTION
//
FreeObj(oPeca)
//
if VS1->VS1_TIPORC <> '3' // Orcamento Balcao / Orcamento Oficina
	OFIXI001(VS1->VS1_NUMORC,.t.) // Chamar mudanca de Fase
Endif

//
// Ponto de entrada ao Finalizar a Conferencia
if ExistBlock("OXX002FIN")
	ExecBlock("OXX002FIN",.f.,.f.)
Endif

//
Return .t.

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

/*/{Protheus.doc} OX0020171_ExcluirConferencia
	Exclui registros referente a Conferencia do Orcamento

	@author Andre Luis Almeida
	@since  27/12/2019

	@param cNumOrc Numero do Orcamento que sera excluido
/*/
Function OX0020171_ExcluirConferencia( cNumOrc )
Local cQuery    := ""
Local cCodVM5   := ""
Local cFilVM5   := ""
Local cQAlVM2   := "SQLVM2"
Local cQAlVM5   := "SQLVM5"
Local cQAlVM6   := "SQLVM6"
Default cNumOrc := ""

If !Empty(cNumOrc) .AND. ChkFile("VM5")
	cQuery := "SELECT R_E_C_N_O_ AS RECVM5 "
	cQuery += "  FROM "+RetSQLName("VM5")
	cQuery += " WHERE VM5_FILIAL='"+xFilial("VM5")+"'"
	cQuery += "   AND VM5_NUMORC='"+cNumOrc+"'"
	cQuery += "   AND D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVM5 , .F., .T. )
	While !( cQAlVM5 )->( Eof() )
		DbSelectArea("VM5")
		VM5->(DbGoTo(( cQAlVM5 )->( RECVM5 )))
		cFilVM5 := VM5->VM5_FILIAL
		cCodVM5 := VM5->VM5_CODIGO
		RecLock("VM5",.F.,.T.)
		DbDelete()
		MsUnlock()
		//
		cQuery := "SELECT VM2.R_E_C_N_O_ AS RECVM2 "
		cQuery += "  FROM "+RetSQLName("VM2")+" VM2 "
		cQuery += " WHERE VM2.VM2_FILIAL='"+cFilVM5+"'"
		cQuery += "   AND VM2.VM2_CODIGO='"+cCodVM5+"'"
		cQuery += "   AND VM2.VM2_TIPO='3'"
		cQuery += "   AND VM2.D_E_L_E_T_=' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVM2 , .F., .T. )
		While !( cQAlVM2 )->( Eof() )
			DbSelectArea("VM2")
			VM2->(DbGoTo(( cQAlVM2 )->( RECVM2 )))
			RecLock("VM2",.F.,.T.)
			DbDelete()
			MsUnlock()
			( cQAlVM2 )->( DbSkip() )
		EndDo
		( cQAlVM2 )->( DbCloseArea() )
		//
		cQuery := "SELECT VM6.R_E_C_N_O_ AS RECVM6 "
		cQuery += "  FROM "+RetSQLName("VM6")+" VM6 "
		cQuery += " WHERE VM6.VM6_FILIAL='"+cFilVM5+"'"
		cQuery += "   AND VM6.VM6_CODVM5='"+cCodVM5+"'"
		cQuery += "   AND VM6.D_E_L_E_T_=' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVM6 , .F., .T. )
		While !( cQAlVM6 )->( Eof() )
			DbSelectArea("VM6")
			VM6->(DbGoTo(( cQAlVM6 )->( RECVM6 )))
			RecLock("VM6",.F.,.T.)
			DbDelete()
			MsUnlock()
			( cQAlVM6 )->( DbSkip() )
		EndDo
		( cQAlVM6 )->( DbCloseArea() )
		//
		( cQAlVM5 )->( DbSkip() )
	EndDo
	( cQAlVM5 )->( DbCloseArea() )
	DbSelectArea("VS1")
Endif
Return

/*/{Protheus.doc} OX0020181_Finaliza_Orcto_Transf
	Finalizar Orcamento de Transferencia

	@author Andre Luis Almeida
	@since  27/12/2019
/*/
Static Function OX0020181_Finaliza_Orcto_Transf( lMostraMsg , cTpOrigem , lExcluiItem , nContItem )
Local cQuery    := ""
Local nEx       := 0
Local nConfirma := 0
Local aExcItem  := {}
Local aResDel   := {}

dbSelectArea("VS3")
dbSetOrder(1)
if dbSeek(xFilial("VS3")+VS1->VS1_NUMORC)
		
	cQuery := "SELECT COUNT(*) "
	cQuery += "FROM "+RetSqlName("VS3")+" VS3 "
	cQuery += "WHERE VS3.VS3_FILIAL = '" + xFilial("VS3")  + "' AND "
	cQuery +=      " VS3.VS3_NUMORC = '" + VS1->VS1_NUMORC + "' AND "
	cQuery +=      " VS3.D_E_L_E_T_ = ' '"

	nContItem := FM_SQL(cQuery) //Quantidade de Itens no orçamento

	While !Eof() .and. xFilial("VS3") == VS3->VS3_FILIAL .and. VS1->VS1_NUMORC == VS3->VS3_NUMORC

		If VS3->VS3_QTDCON == 0 // NAO CONFERIDO
				
			If lMostraMsg
				lMostraMsg := .f.
				nConfirma := 0
				If cTpOrigem == "2" // 2=Coletor de Dados
					If !VtYesNo(STR0017,STR0018,.t.)
						nConfirma := 2
					EndIf
				Else // 0=Manual / 1=Leitor
					nConfirma := Aviso(STR0005,;
					STR0017+;
					CHR(10)+CHR(13)+;
					CHR(10)+CHR(13)+;
					STR0018,;
					{STR0019,STR0020},2)
				EndIf
				If nConfirma == 2
					DisarmTransaction()
					return .f.
				Endif
			EndIf
			
			nContItem--

			aAdd(aExcItem,VS3->(RecNo()))

			If !lExcluiItem .and. VS3->VS3_RESERV == "1" //NAO EFETUADA A MOVIMENTACAO PARA DIVERGENTE
				reclock("VS3",.f.)
					VS3->VS3_RESERV := "0"
				MsUnlock()
				aAdd(aResDel,VS3->VS3_SEQUEN)
			EndIf
		Endif
		dbSelectArea("VS3")
		dbSkip()
	Enddo
Endif

If Len(aResDel) > 0
	If Empty(OX001RESITE(VS1->VS1_NUMORC,.f.,aResDel ))
		If cTpOrigem == "2" // 2=Coletor de Dados
			VtBeep(3) // 3 Beep ERRO
			VTAlert(STR0027,STR0028) // Houve um problema na Desreserva dos Itens. Desreserva Itens
		EndIf
		DisarmTransaction()
		return .f.
	Endif
EndIf

For nEx := 1 to Len(aExcItem)
	VS3->(DbGoTo(aExcItem[nEx]))
	RecLock("VS3" , .F.,.T. )
	DbDelete()
	MsUnLock()
Next

Return .t.