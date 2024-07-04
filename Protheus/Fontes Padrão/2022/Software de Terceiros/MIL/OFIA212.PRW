#Include 'FwMVCDef.ch'
#Include 'TOPCONN.CH'
#Include "Protheus.ch"
#INCLUDE "OFIA212.CH"

#DEFINE PECAORC_TIPTEM    02
#DEFINE PECAORC_CLIFAT    03
#DEFINE PECAORC_LOJFAT    04
#DEFINE PECAORC_NOME      05
#DEFINE PECAORC_GRUITE    06
#DEFINE PECAORC_CODITE    07
#DEFINE PECAORC_DESRICAO  08
#DEFINE PECAORC_QTDITE    09
#DEFINE PECAORC_FORMUL    10
#DEFINE PECAORC_VALPEC    11
#DEFINE PECAORC_LOCPAD    12
#DEFINE PECAORC_LOCALIZ   13
#DEFINE PECAORC_RESPEC    14
#DEFINE PECAORC_GRUINCONV 15
#DEFINE PECAORC_CODINCONV 16
#DEFINE PECAORC_DESINCONV 17
#DEFINE PECAORC_RECNO     18
#DEFINE PECAORC_CODTES    19
#DEFINE PECAORC_SEQINCONV 20
#DEFINE PECAORC_NUMORC    21
#DEFINE PECAORC_FORMU2    22
#DEFINE PECAORC_PERDES    23
#DEFINE PECAORC_VALDES    24
#DEFINE PECAORC_VALORLIQ  25
#DEFINE PECAORC_OPER      26
#DEFINE PECAORC_ESTOQUE   27
#DEFINE PECAORC_DEPGAR    28
#DEFINE PECAORC_DEPINT    29
#DEFINE PECAORC_LOTECT    30
#DEFINE PECAORC_NUMLOT    31
#DEFINE PECAORC_CODIGOVSJ 32
#DEFINE PECAORC_ORIDAD    33
#DEFINE PECAORC_B1COD     34

Function OFIA212()

	Local cFiltro    := OA2120211_FiltroBrowse("")
	Local aSize      := FWGetDialogSize( oMainWnd )
	Local nCntFor    := 0
	Local cFStatus   := ""
	Local cFNome     := ""
	Local cQuery     := ""
	Local cQVM3_Ini  := ""
	Local cQVM3_Fin  := ""
	Local cQAlias    := "SQLVX5"

	Private cCadastro := STR0001 // Conferência Peças Oficina

	oDlgOA212 := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], cCadastro, , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. )

		oWorkArea := FWUIWorkArea():New( oDlgOA212 )
		oWorkArea:CreateHorizontalBox( "LINE01", 60 )
		oWorkArea:SetBoxCols( "LINE01", { "OBJ1" } )
		oWorkArea:CreateHorizontalBox( "LINE02", 39 ) // -1 para nao estourar 100% da tela ( criando scroll lateral )
		oWorkArea:SetBoxCols( "LINE02", { "OBJ2" } )
		oWorkArea:Activate()

		oBrwVO1 := FwMBrowse():New()
		oBrwVO1:SetOwner(oWorkarea:GetPanel("OBJ1"))
		oBrwVO1:SetDescription(STR0002) // Ordem de Serviço
		oBrwVO1:SetAlias('VO1')
		oBrwVO1:SetChgAll(.T.) //nao apresentar a tela para informar a filial
		oBrwVO1:SetMenuDef( ' ' )
		oBrwVO1:lOptionReport := .f.
		oBrwVO1:SetFilterDefault( cFiltro )
		If VM3->(FieldPos("VM3_PRISEP")) > 0
			cQVM3_Ini := "@ EXISTS ( "
			cQVM3_Ini += "SELECT VM3.VM3_NUMOSV "
			cQVM3_Ini += "  FROM " + RetSqlName("VM3") + " VM3 "
			cQVM3_Ini += " WHERE VM3.VM3_FILIAL = VO1_FILIAL "
			cQVM3_Ini += "   AND VM3.VM3_NUMOSV = VO1_NUMOSV "
			cQVM3_Ini += "   AND VM3.VM3_PRISEP = '"
			cQVM3_Fin := "'  AND VM3.D_E_L_E_T_ = ' '"
			cQVM3_Fin += ")"
			cQuery := "SELECT VX5_CODIGO , VX5_DESCRI "
			cQuery += "  FROM " + RetSQLName("VX5")
			cQuery += " WHERE VX5_FILIAL = '" + xFilial("VX5") + "'"
			cQuery += "   AND VX5_CHAVE  = '077'"
			cQuery += "   AND D_E_L_E_T_ = ' '"
			cQuery += " ORDER BY VX5_CODIGO"
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias, .F., .T. )
			Do While !( cQAlias )->( Eof())
				oBrwVO1:AddFilter(STR0061+": "+Alltrim(( cQAlias )->( VX5_CODIGO ))+" - "+( cQAlias )->( VX5_DESCRI ),cQVM3_Ini+( cQAlias )->( VX5_CODIGO )+cQVM3_Fin,.f.,.f.,) // Filtro Adicional - deixa marcar/desmarcar / Prioridade
				( cQAlias )->( DbSkip() )
			EndDo
			( cQAlias )->( dbCloseArea() )
			oBrwVO1:AddFilter(STR0062,cQVM3_Ini+"  "+cQVM3_Fin,.f.,.f.,) // Filtro Adicional - deixa marcar/desmarcar / Sem Prioridade
		EndIf
		For nCntFor := 1 to 3 // Criar Filtros por STATUS
			cFStatus := OA2120211_FiltroBrowse(strzero(nCntFor,1))
			cFNome   := ""
			Do Case
				Case nCntFor == 1
					cFNome := STR0003 // Conferencias Pendentes
				Case nCntFor == 2
					cFNome := STR0004 // Conferencias Parciais
				Case nCntFor == 3
					cFNome := STR0005 // Conferencias Finalizadas
			EndCase
			oBrwVO1:AddFilter(cFNome,cFStatus,.f.,.f.,,,,"VO1status"+strzero(nCntFor,1))
		Next
		oBrwVO1:DisableLocate()
		oBrwVO1:DisableDetails()
		oBrwVO1:ForceQuitButton(.T.)
		oBrwVO1:Activate()

		oBrwVM3 := FwMBrowse():New()
		oBrwVM3:SetOwner(oWorkarea:GetPanel("OBJ2"))
		oBrwVM3:SetDescription(STR0006) // Solicitações de Conferências
		oBrwVM3:SetMenuDef( 'OFIA212' )
		oBrwVM3:SetAlias('VM3')
		oBrwVM3:AddStatusColumns({|| OA2120025_ColunaStatusPecasOficina() }, {|| OA2120035_LegendaStatusPecasOficina() })
		oBrwVM3:DisableLocate()
		oBrwVM3:DisableDetails()
		oBrwVM3:SetAmbiente(.F.)
		oBrwVM3:SetWalkthru(.F.)
		oBrwVM3:SetUseFilter()
		oBrwVM3:lOptionReport := .f.
		oBrwVM3:Activate()

		oRelacPed:= FWBrwRelation():New()
		oRelacPed:AddRelation( oBrwVO1 , oBrwVM3 , { { "VM3_FILIAL", "VO1_FILIAL" } , { "VM3_NUMOSV", "VO1_NUMOSV" } } )
		oRelacPed:Activate()

		VM3->(DbGoTop())

	oDlgOA212:Activate( , , , , , , ) //ativa a janela

Return NIL

Static Function MenuDef()
	Local aRotina := {}

	//Criação das opções
	ADD OPTION aRotina TITLE STR0007 ACTION 'OA2120015_ConferenciaItem()' OPERATION 4 ACCESS 0 // Conferir
	ADD OPTION aRotina TITLE STR0008 ACTION 'OA2120165_ImprimeConferencia()' OPERATION 9 ACCESS 0 // Imprimir Conf

Return aRotina

/*/{Protheus.doc} OA2120025_ColunaStatusPecasOficina

@author Renato Vinicius
@since 01/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function OA2120025_ColunaStatusPecasOficina()

	// Variável do Retorno
	Local cImgRPO := "BR_BRANCO"

	//-- Define Status do registro
	Do Case
		Case VM3->VM3_STATUS == "2" //Conf Parcial
			cImgRpo := "BR_AMARELO"
		Case VM3->VM3_STATUS == "3" //Conferido
			cImgRpo := "BR_VERDE"
		Case VM3->VM3_STATUS == "4" //Aprovado
			cImgRpo := "BR_PRETO"
		Case VM3->VM3_STATUS == "5" //Reprovado
			cImgRpo := "BR_VERMELHO"
	EndCase

Return cImgRPO

/*/{Protheus.doc} OA2120035_LegendaStatusPecasOficina

@author Renato Vinicius
@since 01/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function OA2120035_LegendaStatusPecasOficina()
	
	// Array das Legendas
	Local aLegenda := {	{"BR_BRANCO"	, STR0009 }, ; // Pendente
						{"BR_AMARELO"	, STR0010 }, ; // Conf Parcial
						{"BR_VERDE"		, STR0011 }, ; // Conferido
						{"BR_PRETO"		, STR0012 }, ; // Aprovado
						{"BR_VERMELHO"	, STR0013 } } // Reprovado

	//-- Define Status do registro
	BrwLegenda(STR0014,STR0015,aLegenda ) // Status das Ordens de Serviço / Legenda
	
Return .T.

/*/{Protheus.doc} OA2120015_ConferenciaItem

@author Renato Vinicius
@since 01/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function OA2120015_ConferenciaItem()

	Local lAprovador := OA2120195_ChecagemUsuarioAprovador()
	Local lVisualiza := .f.
	Local cMsg       := ""
	Local lVM3OBSCON := VM3->(ColumnPos("VM3_OBSCON")) > 0

	// VM3 vem posicionado do Browse //
	If lVM3OBSCON .and. !Empty(VM3->VM3_OBSCON)
		MsgAlert(VM3->VM3_OBSCON,STR0053) // Observacao para o Conferente
	EndIf

	Do Case
		Case VM3->VM3_STATUS == "1" .or. VM3->VM3_STATUS == "2"
			cMsg := STR0016 // Conferência da OS está Pendente. Deseja Visualizar?
		Case VM3->VM3_STATUS == "3"
			cMsg := STR0017 // Conferência da OS está Finalizada. Deseja Visualizar?
		Case VM3->VM3_STATUS == "4"
			cMsg := STR0018 // Conferência da OS está Aprovada. Deseja Visualizar?
		Case VM3->VM3_STATUS == "5"
			cMsg := STR0019 // Conferência da OS está Reprovada. Deseja Visualizar?
	EndCase
	if lAprovador .or. VM3->VM3_STATUS == "1" .or. VM3->VM3_STATUS == "2"
		If lAprovador .and. VM3->VM3_STATUS <> "3"
			If !MsgYesNo(cMsg)
				Return
			EndIf
			lVisualiza := .t.
		EndIf
	Else
		If VM3->VM3_STATUS <> "3" .or. ( VM3->VM3_STATUS == "3" .and. VM3->VM3_DIVERG == "1" ) // Diferente de Conferencia Finalizada ou ( Conferencia Finalizada com Divergencia )
			If !MsgYesNo(cMsg)
				Return
			EndIf
			lVisualiza := .t.
		EndIf
	EndIf

	If !lVisualiza
		//
		If ExistFunc("OA3620011_Tempo_Total_Conferencia_Oficina")
			OA3620011_Tempo_Total_Conferencia_Oficina( 1 , VM3->VM3_CODIGO , VM3->VM3_NUMOSV ) // 1=Iniciar o Tempo Total da Conferencia de Oficina caso não exista o registro
		EndIf
		//
		If !OA2120251_VerificaStatusOS( VM3->VM3_NUMOSV , "0" ) // OS NÃO esta com Status Em Aberto
			Return
		EndIf
		//
		If !Softlock("VM3") // Travar Registro do VM3
			Return
		EndIf
		//
	EndIf
	OA2120045_TelaConferencia( VM3->VM3_CODIGO, lVisualiza )
	If !lVisualiza
		//
		VM3->(MsUnlock()) // Retirar SoftLock do VM3
		//
	EndIf
Return


/*/{Protheus.doc} OA2120045_TelaConferencia

@author Renato Vinicius
@since 01/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function OA2120045_TelaConferencia( cConferencia, lVisualiza )

	Local aCoors := FWGetDialogSize( oMainWnd )
	Local cTitulo := STR0001 // Conferência Peças Oficina
	Local aButtons		:= {}
	Local lMostraQtd := .t.
	Local lMostraCod := .t.
	Local cStatConf  := ""
	Local lMostraSol := ( GetNewPar("MV_MIL0046","S") == "S" ) // Mostra a Qtde da Solicitacao ( VM4_QTSOLI )

	Local lVM3OBSCON    := VM3->(ColumnPos("VM3_OBSCON")) > 0

	Local lAprovador := OA2120195_ChecagemUsuarioAprovador()

	Default cConferencia := ""
	Default lVisualiza := .f.

	Private aItensOS	:= {}
	Private aItensConf	:= {}

	Private cPictQUANT  := Alltrim(GetSX3Cache("D1_QUANT","X3_PICTURE"))
	Private cCod        := space(50)
	Private nQtd        := 1

	if Empty(cConferencia)
		Return
	EndIf

	If lVisualiza .or. lAprovador
		lMostraQtd := .f.
		lMostraCod := .f.
	EndIf

	OA2120055_LevantaItens(cConferencia)

	oConfBarra := MSDialog():New( aCoors[1], aCoors[2], aCoors[3], aCoors[4], cTitulo, , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. )    // "Área de Trabalho"
	oConfBarra:lEscClose := .F.

		oLayer := FWLayer():new()
		oLayer:Init(oConfBarra,.f.)

		//Cria as linhas do Layer
		oLayer:addLine( 'L1', 95, .F. )

		//Cria as colunas do Layer
		oLayer:addCollumn('C1L1',26,.F.,"L1") 
		oLayer:addCollumn('C2L1',74,.F.,"L1") 

		oLayer:AddWindow('C1L1','WIN_TPINF',STR0020,64,.F.,.F.,,'L1',) // Informações

		_cRight1Win:= oLayer:GetWinPanel('C1L1','WIN_TPINF', 'L1')

		oLayer:AddWindow('C1L1','WIN_LEGEN',STR0015,35,.F.,.F.,,'L1',) // Legenda
		_cRight2Win:= oLayer:GetWinPanel('C1L1','WIN_LEGEN', 'L1')

		_cTopCol2  := oLayer:getColPanel('C2L1','L1')

		// Cria browse
		oListItens := MsBrGetDBase():new( 0, 0, 260, 170,,,, _cTopCol2,,,,,,,,,,,, .F.,, .T.,, .F.,,, )
		oListItens:Align := CONTROL_ALIGN_ALLCLIENT

		// Define vetor para a browse
		oListItens:setArray( aItensConf )

		// Cria colunas do browse
		oListItens:addColumn( TCColumn():new( STR0021, { || aItensConf[oListItens:nAt,2] },,,, "LEFT",, .F., .F.,,,, .F. ) ) // Grupo
		oListItens:addColumn( TCColumn():new( STR0022, { || aItensConf[oListItens:nAt,3] },,,, "LEFT",, .F., .F.,,,, .F. ) ) // Cod.Item
		oListItens:addColumn( TCColumn():new( STR0023, { || aItensConf[oListItens:nAt,4] },,,, "LEFT",, .F., .F.,,,, .F. ) ) // Descricao
		oListItens:addColumn( TCColumn():new( STR0024, { || aItensConf[oListItens:nAt,9] },,,, "LEFT",, .F., .F.,,,, .F. ) ) // Locacao
		oListItens:addColumn( TCColumn():new( STR0025, { || FG_AlinVlrs(Transform(aItensConf[oListItens:nAt,5],cPictQUANT)) },,,, "LEFT",, .F., .T.,,,, .F. ) ) // Qtd.Conferida
		If lMostraSol .or. lAprovador
			oListItens:addColumn( TCColumn():new( STR0026, { || FG_AlinVlrs(Transform(aItensConf[oListItens:nAt,6],cPictQUANT)) },,,, "LEFT",, .F., .F.,,,, .F. ) ) // Qtd.Solicitada
		EndIf

		bColor := &("{|| aItensConf[oListItens:nAt,1] }")
		oListItens:SetBlkBackColor(bColor)

		oCorAmarelo := tBitmap():New(005, 005, 088, 010, 'BR_AMARELO'   , , .T., _cRight2Win, {|| }, {|| }, .F., .F.,,, .F.,, .T.,, .F.)
		oSayAmarelo := tSay():New(005, 015, {|| STR0027 }  , _cRight2Win,,,,,, .T., CLR_HBLUE, CLR_WHITE, 080, 020) // Item não conferido

		oCorVerde := tBitmap():New(015, 005, 088, 010, 'BR_VERDE'   , , .T., _cRight2Win, {|| }, {|| }, .F., .F.,,, .F.,, .T.,, .F.)
		oSayVerde:= tSay():New(015, 015, {|| STR0028 } , _cRight2Win,,,,,, .T., CLR_HBLUE, CLR_WHITE, 080, 020) // Item conferido corretamente

		oCorVermelho := tBitmap():New(025, 005, 088, 010, 'BR_VERMELHO'   , , .T., _cRight2Win, {|| }, {|| }, .F., .F.,,, .F.,, .T.,, .F.)
		oSayVermelho:= tSay():New(025, 015, {|| STR0029 } , _cRight2Win,,,,,, .T., CLR_HBLUE, CLR_WHITE, 080, 020) // Item com divergência

		If !lVisualiza .and. !lAprovador .and. ( VM3->VM3_STATUS == "1" .or. VM3->VM3_STATUS == "2" )
			oListItens:bLDblClick := { || lEditCell( aItensConf , oListItens , cPictQUANT , 5 ), OA2120135_QtdConferida(aItensConf[oListItens:nAt],aItensConf[oListItens:nAt,5],.t.)}
		EndIf

		oListItens:Refresh()

		nLinIni := 5

		If lMostraQtd
			oSayQtd := tSay():New( nLinIni  , 005, {|| STR0030 } , _cRight1Win,,,,,, .T., CLR_HBLUE, CLR_WHITE, 080, 020) // Quantidade
			oGetQtd := TGet():New( nLinIni+8, 005, { | u | If( PCount() == 0, nQtd, nQtd := u ) },_cRight1Win,060, 010, cPictQUANT ,{ || nQtd >= 0 },,,,.F.,,.T.,,.F.,{ || !lAprovador },.F.,.F.,,.F.,.F. ,,"nQtd",,,,)
			nLinIni += 27
		EndIf

		If lMostraCod
			oSayCod := tSay():New( nLinIni  , 005, {|| STR0031 } , _cRight1Win,,,,,, .T., CLR_HBLUE, CLR_WHITE, 080, 020) // Código
			oGetCod := TGet():New( nLinIni+8, 005, { | u | If( PCount() == 0, cCod, cCod := u ) },_cRight1Win, 060, 010, "@!",{ || IIf(!Empty(cCod),(OA2120095_DigitacaoCodigo(),.f.),oListItens:SetFocus()) },,,,.F.,,.T.,,.F.,{ || !lAprovador },.F.,.F.,,.F.,.F. ,,"cCod",,,,)
			nLinIni += 27
		EndIf

		oSayOsv := tSay():New( nLinIni  , 005, {|| STR0032 } , _cRight1Win,,,,,, .T., CLR_HBLUE, CLR_WHITE, 080, 020) // Ordem de Serviço
		oGetOsv := TGet():New( nLinIni+8, 005, { || VM3->VM3_NUMOSV },_cRight1Win, 060, 010, "@!",{ || .t. },,,,.F.,,.T.,,.F.,{ || .f. },.F.,.F.,,.F.,.F. ,,"cOsv",,,,)
		nLinIni += 27

		oSayCon := tSay():New( nLinIni  , 005, {|| STR0033 } , _cRight1Win,,,,,, .T., CLR_HBLUE, CLR_WHITE, 080, 020) // Código Conferência
		oGetCon := TGet():New( nLinIni+8, 005, { || VM3->VM3_CODIGO },_cRight1Win, 060, 010, "@!",{ || .t. },,,,.F.,,.T.,,.F.,{ || .f. },.F.,.F.,,.F.,.F. ,,"cConf",,,,)
		nLinIni += 27

		If lVisualiza
			oSaySta := tSay():New( nLinIni  , 005, {|| STR0034 } , _cRight1Win,,,,,, .T., CLR_HBLUE, CLR_WHITE, 080, 020) // Status Conferencia
			cStatConf := ""
			Do Case
				Case VM3->VM3_STATUS == "1"
					cStatConf := STR0009 // Pendente
				Case VM3->VM3_STATUS == "2"
					cStatConf := STR0035 // Parcial
				Case VM3->VM3_STATUS == "3"
					cStatConf := STR0036 // Finalizada
				Case VM3->VM3_STATUS == "4"
					cStatConf := STR0037 // Aprovada
				Case VM3->VM3_STATUS == "5"
					cStatConf := STR0038 // Reprovada
			EndCase
			oGetSta := TGet():New( nLinIni+8, 005, { || cStatConf },_cRight1Win, 060, 010, "@!",{ || .t. },,,,.F.,,.T.,,.F.,{ || .f. },.F.,.F.,,.F.,.F. ,,"cStatConf",,,,)
			nLinIni += 27
		EndIf

		If lVM3OBSCON .and. !Empty(VM3->VM3_OBSCON)
			oSayObs := tSay():New( nLinIni   , 005, {|| STR0053 } , _cRight1Win,,,,,, .T., CLR_HBLUE, CLR_WHITE, 080, 020) // Observacao para o Conferente
			oGetObs := tMultiget():new( nLinIni+8, 005,{ || VM3->VM3_OBSCON },_cRight1Win,160,050,,,,,,.T.,,,{|| .f. },,,.T.,,,,,.t.)
			nLinIni += 27
		EndIf

	oConfBarra:Activate( , , , .t. , , ,EnchoiceBar( oConfBarra, { || IIf( !lVisualiza .and. OA2120085_ConfirmarConferencia(cConferencia), oConfBarra:End() , oConfBarra:End() ) }, { || oConfBarra:End() }, ,aButtons, , , , , .F., .T. ) ) //ativa a janela criando uma enchoicebar

Return

/*/{Protheus.doc} OA2120055_LevantaItens

@author Renato Vinicius
@since 01/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function OA2120055_LevantaItens( cConferencia )

	cQuery := "SELECT VM4.VM4_COD, VM4.VM4_QTCONF, VM4.VM4_QTSOLI, R_E_C_N_O_ VM4RECNO "
	cQuery += " FROM " + RetSqlName("VM4") + " VM4 "
	cQuery += " WHERE VM4.VM4_FILIAL = '" + xFilial("VM4") + "' "
	cQuery +=	" AND VM4.VM4_CODVM3 = '" + cConferencia + "' "
	cQuery +=	" AND VM4.D_E_L_E_T_ = ' '"

	TcQuery cQuery New Alias "TMPVM4"

	While !TMPVM4->(Eof())

		SB1->(DbSetOrder(1))
		SB1->(DbSeek(xFilial("SB1")+TMPVM4->VM4_COD))

		SB5->(DbSetOrder(1))
		SB5->(DbSeek(xFilial("SB5")+SB1->B1_COD))

		Aadd(aItensOS,{ "",;
						SB1->B1_GRUPO,;
						SB1->B1_CODITE,;
						SB1->B1_DESC,;
						TMPVM4->VM4_QTCONF,;
						TMPVM4->VM4_QTSOLI,;
						SB1->B1_CODBAR,;
						SB1->B1_COD,;
						FM_PRODSBZ(SB1->B1_COD,"SB5->B5_LOCALI2"),;
						TMPVM4->VM4RECNO;
					})

		OA2120075_StatusItem(aItensOS[Len(aItensOS)])

		TMPVM4->(DbSkip())

	EndDo

	TMPVM4->(dbCloseArea())

	aItensConf := aClone(aItensOS)

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
						"",;
						0;
		})
	EndIf

Return

/*/{Protheus.doc} OA2120065_GravaRegistroConferencia

@author Renato Vinicius
@since 01/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function OA2120065_GravaRegistroConferencia( aOS, cTpOrigem )

	Local oModelVM3 := FWLoadModel( 'OFIA211' )
	Local lRetVM3	:= .f.
	Local cNroConf	:= ""

	Default aOS := Array(3)
	Default cTpOrigem := "0" // Tipo de Origem ( 0=Manual / 1-Leitor(Nao usado no momento, nao existe diferenciação em relação ao 0=Manual) / 2=Coletor de Dados )

	oModelVM3:SetOperation( MODEL_OPERATION_INSERT )

	lRetVM3 := oModelVM3:Activate()

	if lRetVM3

		oModelVM3:SetValue( "VM3MASTER", "VM3_NUMOSV", aOS[1] )
		oModelVM3:SetValue( "VM3MASTER", "VM3_STATUS", "1" )
		oModelVM3:SetValue( "VM3MASTER", "VM3_PROSOL", aOS[3] )

		oModelDet := oModelVM3:GetModel("VM4DETAIL")

		cQuery := "SELECT VM4.VM4_CODVSJ, VM4.VM4_COD, VM4.VM4_QTORIG, VM4.VM4_QTSOLI "
		cQuery += "  FROM " + RetSqlName("VM4") + " VM4 "
		cQuery += " WHERE VM4.VM4_FILIAL = '" + xFilial("VM4") + "'"
		cQuery += 	" AND VM4.VM4_CODVM3 = '" + aOS[2] + "' "
		cQuery += 	" AND VM4.D_E_L_E_T_ = ' '"
	
		TcQuery cQuery New Alias "TMPVM4"

		While !TMPVM4->(Eof())

			oModelDet:AddLine()

			oModelDet:SetValue( "VM4_CODVM3", oModelVM3:GetValue( "VM3MASTER", "VM3_CODIGO") )
			oModelDet:SetValue( "VM4_CODVSJ", TMPVM4->VM4_CODVSJ )
			oModelDet:SetValue( "VM4_COD"	, TMPVM4->VM4_COD )
			oModelDet:SetValue( "VM4_QTORIG", TMPVM4->VM4_QTORIG )
			oModelDet:SetValue( "VM4_QTSOLI", TMPVM4->VM4_QTSOLI )

			TMPVM4->(DbSkip())
		EndDo

		TMPVM4->(dbCloseArea())

		If ( lRet := oModelVM3:VldData() )

			if ( lRet := oModelVM3:CommitData())
			Else
				If cTpOrigem == "2" // 2=Coletor de Dados
					VTAlert(STR0039,"COMMITVM3") // Não foi possivel incluir o(s) registro(s)
				Else
					Help("",1,"COMMITVM3",,STR0039+" "+oModelVM3:GetErrorMessage()[6],1,0) // Não foi possivel incluir o(s) registro(s)
				EndIf
			EndIf

		Else
			If cTpOrigem == "2" // 2=Coletor de Dados
				VTAlert(STR0040,"VALIDVM3") // Problema na validação dos campos e não foi possivel concluir o relacionamento
			Else
				Help("",1,"VALIDVM3",,STR0040+" "+oModelVM3:GetErrorMessage()[6],1,0) // Problema na validação dos campos e não foi possivel concluir o relacionamento
			EndIf
		EndIf

		cNroConf := oModelVM3:GetValue("VM3MASTER","VM3_CODIGO")

		oModelVM3:DeActivate()

	Else
		If cTpOrigem == "2" // 2=Coletor de Dados
			VTAlert(STR0041,"ACTIVEVM3") // Não foi possivel ativar o modelo de inclusão da tabela VM3
		Else
			Help("",1,"ACTIVEVM3",,STR0041,1,0) // Não foi possivel ativar o modelo de inclusão da tabela VM3
		EndIf
	EndIf

	FreeObj(oModelVM3)

Return cNroConf


/*/{Protheus.doc} OA2120075_StatusItem

@author Renato Vinicius
@since 01/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function OA2120075_StatusItem(aVetItem)

	//aVetItem[1] - Cor da linha
	//aVetItem[5] - VM4_QTCONF
	//aVetItem[6] - VM4_QTSOLI

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

/*/{Protheus.doc} OA2120085_ConfirmarConferencia

@author Renato Vinicius
@since 01/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function OA2120085_ConfirmarConferencia(cNroConf)

	Local lRetorno := .t.
	Local cQuery   := ""
	Local lVM4_PRBEST := VM4->(ColumnPos("VM4_PRBEST")) > 0
	Local lAprovador  := OA2120195_ChecagemUsuarioAprovador()

	VM3->(DbSetOrder(1))
	VM3->(DbSeek(xfilial("VM3")+cNroConf))

	OA2120175_VerificaDivergencias( VM3->VM3_CODIGO , , .t. ) // Verifica Divergencia e Estoque dos Itens

	if lAprovador .or. ( VM3->VM3_STATUS == "3" .and. VM3->VM3_DIVERG == "0" ) // Aprovador ou ( Conferencia Finalizada e NAO tem divergencia )

		lRetorno := OA2120155_JaneladeAprovacao()

	Else

		If VM3->VM3_STATUS == "3" .and. VM3->VM3_DIVERG == "1" .and. lVM4_PRBEST
			cQuery := "SELECT COUNT(VM4_CODVM3) FROM "+RetSqlName("VM4")
			cQuery += " WHERE VM4_FILIAL = '" + xFilial("VM4") + "'"
			cQuery += "   AND VM4_CODVM3 = '" + VM3->VM3_CODIGO + "'"
			cQuery += "   AND VM4_PRBEST = '1'" // Tem problema de Saldo de Estoque
			cQuery += "   AND D_E_L_E_T_ = ' '"
			If FM_SQL(cQuery) > 0
				MsgInfo(STR0060,STR0044) // Exitem itens com Saldo insuficiente para a Requisição de Peças. Verifique com o usuário Aprovador. / Atencao
				Return .f.
			EndIf
		EndIf

		If MsgNoYes(STR0052,STR0044) // Finaliza Conferência? / Atencao

			If VM3->VM3_DIVERG == "1"

				If !MsgNoYes(STR0042,STR0044) // Há itens com divergencia. Deseja continuar? / Atencao
					Return .f.
				EndIf

			EndIf

			OA2120115_StatusConferencia( VM3->VM3_CODIGO , "3" , "0" )

			if ExistBlock("IMPOSOC")
				ExecBlock("IMPOSOC",.f.,.f.,{VM3->VM3_CODIGO})
			Endif

		EndIf
	EndIf

	oDlgOA212:Refresh()

Return lRetorno

/*/{Protheus.doc} OA2120095_DigitacaoCodigo

@author Renato Vinicius
@since 01/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function OA2120095_DigitacaoCodigo()

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

			nPosItem := OA2120125_BuscaItem(cCodSB1)

			If nPosItem > 0

				oListItens:SetArray(aItensConf)
				oListItens:nAt := nPosItem

				OA2120135_QtdConferida(aItensConf[nPosItem],nQtd)

				nQtd:= 1
				cCod:= space(50)

				oGetQtd:Refresh()
				oGetCod:Refresh()

				oListItens:SetFocus()
				oListItens:Refresh()

			EndIf
		Else
			MsgStop(STR0043,STR0044) // Item não consta no Cadastro de Produtos. Impossível continuar. / Atencao
		EndIf

	EndIf

	FreeObj(oPeca)

Return

/*/{Protheus.doc} OA2120105_DuplicaConferencia

@author Renato Vinicius
@since 01/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function OA2120105_DuplicaConferencia( cConferencia, lComDiverg )

	Local lRetVM3	:= .f.
	Local aOS:= {}
	Local cNovaConf := ""
	Local oModelVM3 := FWLoadModel( 'OFIA211' )
	Local lAlterou  := .f.
	Local lVM4_PRBEST := VM4->(ColumnPos("VM4_PRBEST")) > 0

	Default cConferencia := ""
	Default lComDiverg	:= .f.

	VM3->(DbSetOrder(1))
	If VM3->(DbSeek(xFilial("VM3")+cConferencia))

		aOS := {VM3->VM3_NUMOSV,VM3->VM3_CODIGO,VM3->VM3_PROSOL}

		cNovaConf := OA2120065_GravaRegistroConferencia( aOS )

	EndIf

	If lComDiverg

		VM3->(DbSetOrder(1))
		If VM3->(DbSeek(xFilial("VM3")+cNovaConf))

			oModelVM3:SetOperation( MODEL_OPERATION_UPDATE )

			lRetVM3 := oModelVM3:Activate()

			if lRetVM3
				
				oModelDet := oModelVM3:GetModel("VM4DETAIL")

				cQuery := "SELECT VM4.VM4_COD    , "
				cQuery += "       VM4.VM4_CODVSJ , "
				cQuery += "       VM4.VM4_QTCONF , "
				cQuery += "       VM4.VM4_DATINI , "
				cQuery += "       VM4.VM4_HORINI , "
				cQuery += "       VM4.VM4_DATFIN , "
				cQuery += "       VM4.VM4_HORFIN , "
				cQuery += "       VM4.VM4_USRCON   "
				cQuery += "  FROM " + RetSqlName("VM4") + " VM4 "
				cQuery += " WHERE VM4.VM4_FILIAL = '" + xFilial("VM4") + "' "
				cQuery += "   AND VM4.VM4_CODVM3 = '" + cConferencia + "' "
				cQuery += "   AND VM4.VM4_QTSOLI = VM4.VM4_QTCONF "
				If lVM4_PRBEST
					cQuery += "   AND VM4.VM4_PRBEST <> '1' " // NAO tem problema de Saldo de Estoque
				EndIf
				cQuery += "   AND VM4.D_E_L_E_T_ = ' ' "

				TcQuery cQuery New Alias "TMPVM4"

				While !TMPVM4->(Eof())

					lSeek := oModelDet:SeekLine({;
										{ "VM4_COD"		, TMPVM4->VM4_COD },;
										{ "VM4_CODVSJ"	, TMPVM4->VM4_CODVSJ };
									})

					If lSeek
						lAlterou := .t.
						oModelDet:SetValue( "VM4_QTCONF", TMPVM4->VM4_QTCONF )
						oModelDet:SetValue( "VM4_DATINI", stod(TMPVM4->VM4_DATINI) )
						oModelDet:SetValue( "VM4_HORINI", TMPVM4->VM4_HORINI )
						oModelDet:SetValue( "VM4_DATFIN", stod(TMPVM4->VM4_DATFIN) )
						oModelDet:SetValue( "VM4_HORFIN", TMPVM4->VM4_HORFIN )
						oModelDet:SetValue( "VM4_USRCON", TMPVM4->VM4_USRCON )
					EndIf

					TMPVM4->(DbSkip())

				EndDo

				TMPVM4->(dbCloseArea())

				If lAlterou
					If ( lRet := oModelVM3:VldData() )

						if ( lRet := oModelVM3:CommitData())
						Else
							Help("",1,"COMMITVM3",,STR0039+" "+oModelVM3:GetErrorMessage()[6],1,0) // Não foi possivel incluir o(s) registro(s)
						EndIf

					Else
						Help("",1,"VALIDVM3",,STR0040+" "+oModelVM3:GetErrorMessage()[6],1,0) // Problema na validação dos campos e não foi possivel concluir o relacionamento
					EndIf
				EndIf

				oModelVM3:DeActivate()

			Else
				Help("",1,"ACTIVEVM3",,STR0041,1,0) // Não foi possivel ativar o modelo de inclusão da tabela VM3
			EndIf

		EndIf

	EndIf

	FreeObj(oModelVM3)

	If lAlterou
		OA2120115_StatusConferencia( cNovaConf , "2" , "0" ) // Grava o STATUS Parcial na Tabela de Historico
	EndIf

Return

/*/{Protheus.doc} OA2120115_StatusConferencia

@author Renato Vinicius
@since 01/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function OA2120115_StatusConferencia( cConferencia , cStatus, cTpOrigem )

	Local oModelVM3 := FWLoadModel( 'OFIA211' )
	Local lRetVM3	:= .f.
	Local cStatusRet:= ""
	Local lMudouStatus := .f.

	Default cConferencia := ""
	Default cTpOrigem := "0" // Tipo de Origem ( 0=Manual / 1-Leitor(Nao usado no momento, nao existe diferenciação em relação ao 0=Manual) / 2=Coletor de Dados )

	VM3->(DbSetOrder(1))
	If VM3->(DbSeek(xFilial("VM3")+cConferencia))

		oModelVM3:SetOperation( MODEL_OPERATION_UPDATE )

		lRetVM3 := oModelVM3:Activate()

		if lRetVM3

			if cStatus <> oModelVM3:GetValue("VM3MASTER","VM3_STATUS")
				oModelVM3:SetValue( "VM3MASTER", "VM3_STATUS", cStatus )

				If oModelVM3:VldData()

					if oModelVM3:CommitData()
						lMudouStatus := .t.
					Else
						If cTpOrigem == "2" // 2=Coletor de Dados
							VTAlert(STR0045,"COMMITVM3") // Não foi possivel gravar o(s) registro(s)
						Else
							Help("",1,"COMMITVM3",,STR0045,1,0) // Não foi possivel gravar o(s) registro(s)
						EndIf
					EndIf

				Else
					If cTpOrigem == "2" // 2=Coletor de Dados
						VTAlert(STR0040,"VALIDVM3") // Problema na validação dos campos e não foi possivel concluir o relacionamento
					Else
						Help("",1,"VALIDVM3",,STR0040,1,0) // Problema na validação dos campos e não foi possivel concluir o relacionamento
					EndIf
				EndIf

				cStatusRet := oModelVM3:GetValue("VM3MASTER","VM3_STATUS")

				oModelVM3:DeActivate()
			Else
				cStatusRet := oModelVM3:GetValue("VM3MASTER","VM3_STATUS")
			EndIf
		Else
			If cTpOrigem == "2" // 2=Coletor de Dados
				VTAlert(STR0041,"ACTIVEVM3") // Não foi possivel ativar o modelo de inclusão da tabela VM3
			Else
				Help("",1,"ACTIVEVM3",,STR0041,1,0) // Não foi possivel ativar o modelo de inclusão da tabela VM3
			EndIf
		EndIf

	EndIf

	FreeObj(oModelVM3)

	If lMudouStatus
		If ExistBlock("OA212STA")
			ExecBlock("OA212STA",.f.,.f.,{ cConferencia , cStatus, cTpOrigem })
		EndIf
	EndIf

	OA2120231_TravarVM3( cConferencia , cTpOrigem )

Return cStatusRet

/*/{Protheus.doc} OA2120125_BuscaItem

@author Renato Vinicius
@since 01/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function OA2120125_BuscaItem(cCodigo)

	Local nPosicao := 0

	Default cCodigo:= ""

	If !Empty(cCodigo)

		nPosicao := aScan(aItensConf,{|x| Alltrim(x[8]) == Alltrim(cCodigo) }) // CODIGO ( B1_COD )
		If nPosicao == 0
			MsgStop(STR0046,STR0044) // Item não encontrado nesta conferência. / Atencao
		EndIf

	EndIf

Return nPosicao

/*/{Protheus.doc} OA2120135_QtdConferida

@author Renato Vinicius
@since 01/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function OA2120135_QtdConferida(aItemConf,nQtdConf,lDigitado)

	Local lProblem    := .f.
	Default lDigitado := .f.

	nPosOS := aScan(aItensOS,{ |x| x[10] == aItemConf[10] } )
	If nPosOS > 0
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
			MsgStop(STR0047,STR0044) // Quantidade desejada maior que a Quantidade Solicitada. Impossível continuar. / Atencao
		Else
			If nQtdConf == 0 .or. lDigitado
				aItemConf[5] := nQtdConf
			Else
				aItemConf[5] += nQtdConf
			EndIf
		EndIf
		aItensOS[nPosOS,5] := aItemConf[5]
		OA2120145_GravaQtdConferida( VM3->VM3_CODIGO , aItemConf[10] , aItemConf[5] , "0" )
		OA2120075_StatusItem(aItemConf)
		OA2120115_StatusConferencia( VM3->VM3_CODIGO , "2" , "0" )
	EndIf

Return .t.

/*/{Protheus.doc} OA2120145_GravaQtdConferida

@author Renato Vinicius
@since 01/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function OA2120145_GravaQtdConferida( cConferencia , nRecVM4 , nQtdConf, cTpOrigem )

	Local oModelVM3 := FWLoadModel( 'OFIA211' )

	Default cConferencia := ""
	Default cTpOrigem := "0" // Tipo de Origem ( 0=Manual / 1-Leitor(Nao usado no momento, nao existe diferenciação em relação ao 0=Manual) / 2=Coletor de Dados )
	Default nRecVM4 := 0

	If nRecVM4 > 0

		oModelVM3:SetOperation( MODEL_OPERATION_UPDATE )

		lRetVM3 := oModelVM3:Activate()

		if lRetVM3

			oModelDet := oModelVM3:GetModel("VM4DETAIL")
			oModelDet:GoToDataID(nRecVM4)
			oModelDet:SetValue( "VM4_QTCONF", nQtdConf )

			If Empty(oModelDet:GetValue( "VM4_DATINI"))
				oModelDet:SetValue( "VM4_DATINI", dDataBase )
				oModelDet:SetValue( "VM4_HORINI", Time() )
				oModelDet:SetValue( "VM4_USRCON", __cUserID )
			EndIf
			oModelDet:SetValue( "VM4_DATFIN", dDataBase )
			oModelDet:SetValue( "VM4_HORFIN", Time() )

			If ( lRet := oModelVM3:VldData() )

				if ( lRet := oModelVM3:CommitData())
				Else
					If cTpOrigem == "2" // 2=Coletor de Dados
						VTAlert(STR0045,"COMMITVM3") // Não foi possivel gravar o(s) registro(s)
					Else
						Help("",1,"COMMITVM3",,STR0045,1,0) // Não foi possivel gravar o(s) registro(s)
					EndIf
				EndIf

			Else
				If cTpOrigem == "2" // 2=Coletor de Dados
					VTAlert(STR0040,"VALIDVM3") // Problema na validação dos campos e não foi possivel concluir o relacionamento
				Else
					Help("",1,"VALIDVM3",,STR0040,1,0) // Problema na validação dos campos e não foi possivel concluir o relacionamento
				EndIf
			EndIf

			oModelVM3:DeActivate()

		Else
			If cTpOrigem == "2" // 2=Coletor de Dados
				VTAlert(STR0041,"ACTIVEVM3") // Não foi possivel ativar o modelo de inclusão da tabela VM3
			Else
				Help("",1,"ACTIVEVM3",,STR0041,1,0) // Não foi possivel ativar o modelo de inclusão da tabela VM3
			EndIf
		EndIf

	EndIf

	FreeObj(oModelVM3)

	OA2120231_TravarVM3( cConferencia , cTpOrigem )

Return

/*/{Protheus.doc} OA2120155_JaneladeAprovacao

@author Renato Vinicius
@since 01/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function OA2120155_JaneladeAprovacao()

	Local nOpcao     := 0
	Local lRetorno   := .t.
	Local cQuery     := ""
	Local lVM4_PRBEST := VM4->(ColumnPos("VM4_PRBEST")) > 0

	oDlgOpcoes := MSDialog():New( 0, 0, 90, 620, STR0001, , , , , , , , , .T., , , , .F. ) // Conferência Peças Oficina

	If VM3->VM3_DIVERG == "1" // Tem Divergencia
		If lVM4_PRBEST
			cQuery := "SELECT COUNT(VM4_CODVM3) FROM "+RetSqlName("VM4")
			cQuery += " WHERE VM4_FILIAL = '" + xFilial("VM4") + "'"
			cQuery += "   AND VM4_CODVM3 = '" + VM3->VM3_CODIGO + "'"
			cQuery += "   AND VM4_PRBEST = '1'" // Tem problema de Saldo de Estoque
			cQuery += "   AND D_E_L_E_T_ = ' '"
		EndIf
		If lVM4_PRBEST .and. FM_SQL(cQuery) > 0
			oBotaoVer := tButton():New(10,200,STR0055,oDlgOpcoes, { || OA2120241_Visualiza_Itens_sem_Saldo( VM3->VM3_CODIGO ) } , 100 , 20 ,,,,.T.,,,,{ || .t.  }) // Visualiza Itens sem Saldo
			oBotaoRjD := tButton():New(10,010,STR0056,oDlgOpcoes, { || nOpcao := 2 , oDlgOpcoes:End() } , 90 , 20 ,,,,.T.,,,,{ || .t. }) // Re-Conferir Itens sem Saldo
		Else
			oBotaoApr := tButton():New(10,200,STR0048,oDlgOpcoes, { || nOpcao := 1 , oDlgOpcoes:End() } , 100 , 20 ,,,,.T.,,,,{ || .t.  }) // Aprovar Conferência com Divergências
			oBotaoRjD := tButton():New(10,010,STR0049,oDlgOpcoes, { || nOpcao := 2 , oDlgOpcoes:End() } , 90 , 20 ,,,,.T.,,,,{ || .t. }) // Re-Conferir Itens Divergentes
		EndIf
		oBotaoRjT := tButton():New(10,105,STR0050,oDlgOpcoes, { || nOpcao := 3 , oDlgOpcoes:End() } , 90 , 20 ,,,,.T.,,,,{ || .t. }) // Re-Conferir Todos Itens
	Else
		oBotaoApr := tButton():New(10,010,STR0051,oDlgOpcoes, { || nOpcao := 1 , oDlgOpcoes:End() } , 290 , 20 ,,,,.T.,,,,{ || .t.  }) // Aprovar Conferência
	EndIf

	oDlgOpcoes:Activate( , , , .t. , , , , ,, , , , , , ) //ativa a janela criando uma enchoicebar

	Begin Transaction
		Do Case 
			Case nOpcao == 1
				OA2120115_StatusConferencia( VM3->VM3_CODIGO , "4" , "0" )
				OA2120205_EfetivaRequicao( VM3->VM3_CODIGO )
				If ExistFunc("OA3620011_Tempo_Total_Conferencia_Oficina")
					OA3620011_Tempo_Total_Conferencia_Oficina( 0 , VM3->VM3_CODIGO , VM3->VM3_NUMOSV ) // 0=Finalizar o Tempo Total da Conferencia Oficina
				EndIf
			Case nOpcao == 2
				OA2120115_StatusConferencia( VM3->VM3_CODIGO , "5" , "0" )
				OA2120105_DuplicaConferencia( VM3->VM3_CODIGO , .t. )
			Case nOpcao == 3
				OA2120115_StatusConferencia( VM3->VM3_CODIGO , "5" , "0" )
				OA2120105_DuplicaConferencia( VM3->VM3_CODIGO )
			Otherwise
				lRetorno := .f.
		EndCase
	End Transaction

Return lRetorno


/*/{Protheus.doc} OA2120165_ImprimeConferencia

@author Renato Vinicius
@since 01/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function OA2120165_ImprimeConferencia()
	Local cFiltro := OA2120211_FiltroBrowse("")
	if ExistBlock("IMPOSOC")
		ExecBlock("IMPOSOC",.f.,.f.,{VM3->VM3_CODIGO})
	Endif
	oBrwVO1:SetFilterDefault( cFiltro ) //Filtrar novamente
Return

/*/{Protheus.doc} OA2120175_VerificaDivergencias

@author Renato Vinicius
@since 01/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
function OA2120175_VerificaDivergencias(cConferencia , cTpOrigem , lChkEstoque )

	Local cQuery := ""
	Local oModelVM3 := FWLoadModel( 'OFIA211' )
	Local lRetVM3	:= .f.
	Local lVM4_PRBEST := VM4->(ColumnPos("VM4_PRBEST")) > 0
	Local cLocPad   := ""
	Local nSaldo    := 0
	Local cMVRESITE := PadR( AllTrim(GetMv("MV_RESITE")), GetSX3Cache("B2_LOCAL","X3_TAMANHO") )
	
	Default cConferencia := ""
	Default cTpOrigem := "0" // Tipo de Origem ( 0=Manual / 1-Leitor(Nao usado no momento, nao existe diferenciação em relação ao 0=Manual) / 2=Coletor de Dados )
	Default lChkEstoque := .f.

	If lChkEstoque .and. lVM4_PRBEST
		cQuery := "SELECT VM4.R_E_C_N_O_ AS RECVM4 ,"
		cQuery += "       SB1.R_E_C_N_O_ AS RECSB1 ,"
		cQuery += "       VSJ.VSJ_RESPEC , VSJ.VSJ_TIPTEM "
		cQuery += " FROM " + RetSqlName("VM3") + " VM3 "
		cQuery += " LEFT JOIN " + RetSqlName("VM4") + " VM4 "
		cQuery +=	"  ON VM4.VM4_FILIAL = VM3.VM3_FILIAL "
		cQuery +=	" AND VM4.VM4_CODVM3 = VM3.VM3_CODIGO "
		cQuery +=	" AND VM4.D_E_L_E_T_ = ' ' "
		cQuery += " LEFT JOIN " + RetSqlName("SB1") + " SB1 "
		cQuery +=	"  ON SB1.B1_FILIAL = '"+xFilial("SB1")+"' "
		cQuery +=	" AND SB1.B1_COD = VM4.VM4_COD "
		cQuery +=	" AND SB1.D_E_L_E_T_ = ' ' "
		cQuery += " LEFT JOIN " + RetSqlName("VSJ") + " VSJ "
		cQuery +=	"  ON VSJ.VSJ_NUMOSV = VM3.VM3_NUMOSV "
		cQuery +=	" AND VSJ.VSJ_CODIGO = VM4.VM4_CODVSJ "
		cQuery +=	" AND VSJ.VSJ_GRUITE = SB1.B1_GRUPO "
		cQuery +=	" AND VSJ.VSJ_CODITE = SB1.B1_CODITE "
		cQuery +=	" AND VSJ.D_E_L_E_T_ = ' ' "
		cQuery += " WHERE VM3.VM3_FILIAL = '" + xFilial("VM3") + "'"
		cQuery += 	" AND VM3.VM3_CODIGO = '" + cConferencia + "' "
		cQuery += 	" AND VM3.D_E_L_E_T_ = ' ' "
		TcQuery cQuery New Alias "TMPVM4"
		While !TMPVM4->(Eof())
			SB1->(DbSetOrder(1))
			SB1->(DbGoto( TMPVM4->( RECSB1 ) ))
			If TMPVM4->( VSJ_RESPEC ) == "1"
				cLocPad := cMVRESITE
			Else
				cLocPad := OM0200065_ArmazemOrigem( TMPVM4->( VSJ_TIPTEM ) )
			EndIf
			SB2->(DbSetOrder(1))
			SB2->(DbSeek(xFilial("SB2")+SB1->B1_COD+cLocPad))
			nSaldo := SaldoSB2()
			VM4->(DbGoto( TMPVM4->( RECVM4 ) ))
			DbSelectArea("VM4")
			RecLock("VM4",.f.)
			If VM4->VM4_QTCONF > nSaldo
				VM4->VM4_PRBEST := "1" // Tem problema de Saldo de Estoque
			Else
				VM4->VM4_PRBEST := "0" // Nao tem problema de Saldo de Estoque
			EndIf
			MsUnLock()
			TMPVM4->(DbSkip())
		EndDo
		TMPVM4->(dbCloseArea())
	EndIf

	cQuery := "SELECT COUNT(VM4.VM4_CODVSJ) AS QTDE "
	cQuery += "  FROM " + RetSqlName("VM4") + " VM4 "
	cQuery += " WHERE VM4.VM4_FILIAL = '" + xFilial("VM4") + "'"
	cQuery += "   AND VM4.VM4_CODVM3 = '" + cConferencia + "' "
	If lVM4_PRBEST
		cQuery += "   AND ( VM4.VM4_QTSOLI <> VM4.VM4_QTCONF OR VM4.VM4_PRBEST='1' )" // Qtd.Solicitada diferente da Qtd.Conferida ou tem problema de Saldo de Estoque
	Else
		cQuery += "   AND VM4.VM4_QTSOLI <> VM4.VM4_QTCONF" // Qtd.Solicitada diferente da Qtd.Conferida
	EndIf
	cQuery += "   AND VM4.D_E_L_E_T_ = ' ' "

	TcQuery cQuery New Alias "TMPVM4"

	If !TMPVM4->(Eof())

		VM3->(DbSetOrder(1))
		VM3->(DbSeek(xFilial("VM3")+cConferencia))

		oModelVM3:SetOperation( MODEL_OPERATION_UPDATE )

		lRetVM3 := oModelVM3:Activate()

		if lRetVM3

			If TMPVM4->(QTDE) > 0
				oModelVM3:SetValue( "VM3MASTER", "VM3_DIVERG", "1" ) // Com Divergencia
			Else
				oModelVM3:SetValue( "VM3MASTER", "VM3_DIVERG", "0" ) // Sem Divergencia
			EndIf

			If ( lRet := oModelVM3:VldData() )

				if ( lRet := oModelVM3:CommitData())
				Else
					If cTpOrigem == "2" // 2=Coletor de Dados
						VTAlert(STR0045,"COMMITVM3") // Não foi possivel gravar o(s) registro(s)
					Else
						Help("",1,"COMMITVM3",,STR0045,1,0) // Não foi possivel gravar o(s) registro(s)
					EndIf
				EndIf

			Else
				If cTpOrigem == "2" // 2=Coletor de Dados
					VTAlert(STR0040,"VALIDVM3") // Problema na validação dos campos e não foi possivel concluir o relacionamento
				Else
					Help("",1,"VALIDVM3",,STR0040,1,0) // Problema na validação dos campos e não foi possivel concluir o relacionamento
				EndIf
			EndIf

			oModelVM3:DeActivate()

		Else
			If cTpOrigem == "2" // 2=Coletor de Dados
				VTAlert(STR0041,"ACTIVEVM3") // Não foi possivel ativar o modelo de inclusão da tabela VM3
			Else
				Help("",1,"ACTIVEVM3",,STR0041,1,0) // Não foi possivel ativar o modelo de inclusão da tabela VM3
			EndIf
		EndIf

	EndIf

	TMPVM4->(dbCloseArea())

	FreeObj(oModelVM3)

	OA2120231_TravarVM3( cConferencia , cTpOrigem )

Return

/*/{Protheus.doc} OA2120185_LimpaLinhaBranca

@author Renato Vinicius
@since 01/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function OA2120185_LimpaLinhaBranca()

	Local nPosItem := 0

	nPosItem := aScan(aItensConf,{|x| x[3] == " " })

	If nPosItem > 0
		aDel(aItensConf, nPosItem)
		aSize(aItensConf, Len(aItensConf) - 1)
	EndIf

Return


/*/{Protheus.doc} OA2120195_ChecagemUsuarioAprovador

@author Renato Vinicius
@since 01/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function OA2120195_ChecagemUsuarioAprovador()

	Local lAprovador

	VAI->(dbSetOrder(4))
	VAI->(MsSeek(xFilial("VAI")+__cUserID)) // Posiciona no VAI do usuario logado

	lAprovador := VAI->VAI_APRCON == "1"

Return lAprovador


/*/{Protheus.doc} OA2120205_EfetivaRequicao

@author Renato Vinicius
@since 01/10/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function OA2120205_EfetivaRequicao( cConferencia )

	Local aAuxIteVO3 := {}
	Local aIteVO3    := {}
	Local aDiverg    := {}
	Local lVSJSUGCOM := (VSJ->(FieldPos("VSJ_SUGCOM")) <> 0)

	Private aAvCredPec  := {} // Variavel utilizada no OFIOM020
	Private aPecaOrc	:= {} // Variavel utilizada no OFIOM020 para baixa do VSJ
	Private lVSJCODIGO	:= (VSJ->(FieldPos("VSJ_CODIGO")) <> 0)

	cQuery := "SELECT VM3.VM3_NUMOSV ,"
	cQuery += "       VM4.VM4_QTSOLI ,"
	cQuery += "       VM4.VM4_QTCONF ,"
	cQuery += "       VM4.VM4_COD    ,"
	cQuery += "       VM3.VM3_PROSOL ,"
	cQuery += "       VSJ.VSJ_DEPINT ,"
	cQuery += "       VSJ.VSJ_DEPGAR ,"
	cQuery += "       VSJ.VSJ_CODIGO ,"
	cQuery += "       VSJ.VSJ_LOTECT ,"
	cQuery += "       VSJ.VSJ_NUMLOT ,"
	If lVSJSUGCOM
		cQuery += "   VSJ.VSJ_SUGCOM ,"
	EndIf
	cQuery += "       VSJ.VSJ_RESPEC  "
	cQuery += " FROM " + RetSqlName("VM3") + " VM3 "
	cQuery += " LEFT JOIN " + RetSqlName("VM4") + " VM4 "
	cQuery +=	"  ON VM4.VM4_FILIAL = VM3.VM3_FILIAL "
	cQuery +=	" AND VM4.VM4_CODVM3 = VM3.VM3_CODIGO "
	cQuery +=	" AND VM4.D_E_L_E_T_ = ' ' "
	cQuery += " LEFT JOIN " + RetSqlName("SB1") + " SB1 "
	cQuery +=	"  ON SB1.B1_FILIAL = '"+xFilial("SB1")+"' "
	cQuery +=	" AND SB1.B1_COD = VM4.VM4_COD "
	cQuery +=	" AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += " LEFT JOIN " + RetSqlName("VSJ") + " VSJ "
	cQuery +=	"  ON VSJ.VSJ_NUMOSV = VM3.VM3_NUMOSV "
	cQuery +=	" AND VSJ.VSJ_CODIGO = VM4.VM4_CODVSJ "
	cQuery +=	" AND VSJ.VSJ_GRUITE = SB1.B1_GRUPO "
	cQuery +=	" AND VSJ.VSJ_CODITE = SB1.B1_CODITE "
	cQuery +=	" AND VSJ.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE VM3.VM3_FILIAL = '" + xFilial("VM3") + "'"
	cQuery += 	" AND VM3.VM3_CODIGO = '" + cConferencia + "' "
	cQuery += 	" AND VM3.D_E_L_E_T_ = ' ' "

	TcQuery cQuery New Alias "TMPVM3"

	While !TMPVM3->(Eof())

		If TMPVM3->VM4_QTCONF > 0

			nPos := aScan( aPecaOrc , { |x| x[PECAORC_CODIGOVSJ] == TMPVM3->VSJ_CODIGO } )

			aAuxIteVO3 := {}
			AADD(aAuxIteVO3, { "VO3_NUMOSV" , TMPVM3->VM3_NUMOSV , nil } )
			AADD(aAuxIteVO3, { "VO3_CODVSJ" , TMPVM3->VSJ_CODIGO , nil } )
			AADD(aAuxIteVO3, { "VO3_QTDREQ" , TMPVM3->VM4_QTCONF , nil } )
			AADD(aAuxIteVO3, { "VO3_PROREQ" , TMPVM3->VM3_PROSOL , nil } )

			//Dep. Interno
			If !Empty( TMPVM3->VSJ_DEPINT )
				AADD(aAuxIteVO3, { "VO3_DEPINT" , TMPVM3->VSJ_DEPINT , nil } )
			EndIf

			//Dep. Garantia
			If !Empty( TMPVM3->VSJ_DEPGAR )
				AADD(aAuxIteVO3, { "VO3_DEPGAR" , TMPVM3->VSJ_DEPGAR , nil } )
			EndIf

			AADD( aIteVO3 , aClone( aAuxIteVO3 ) )

		EndIf

		If TMPVM3->VSJ_RESPEC == "1" .and. TMPVM3->VM4_QTSOLI > TMPVM3->VM4_QTCONF // Possui Reserva e tem Divergencia entre a Qtd.Solicitada e Qtd.Conferida

			DbSelectArea("SB1")
			dbSetOrder(1)
			SB1->(DbSeek(xFilial("SB1")+TMPVM3->VM4_COD))
			DbSelectArea("SB2")
			dbSetOrder(1)
			SB2->(DbSeek(xFilial("SB2")+SB1->B1_COD+GetMv("MV_RESITE")))
			nSaldo := SaldoSB2()
			nQtdEst := TMPVM3->VM4_QTSOLI
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se encontrar o registro de ocorrencia de reserva, estornar somente ³
			//³o saldo da reserva da OS                                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cQuery := "SELECT R_E_C_N_O_ VE6RECNO "
			cQuery += "  FROM " + RetSQLName("VE6") + " VE6 "
			cQuery += " WHERE VE6.VE6_FILIAL = '" + xFilial("VE6") + "'"
			cQuery += "   AND VE6.VE6_NUMOSV = '" + TMPVM3->VM3_NUMOSV + "'"
			cQuery += "   AND VE6.VE6_INDREG = '3'" // Registro de Reserva
			cQuery += "   AND VE6.VE6_GRUITE = '" + SB1->B1_GRUPO + "'"  
			cQuery += "   AND VE6.VE6_CODITE = '" + SB1->B1_CODITE + "'"
			cQuery += "   AND VE6.VE6_LOTECT = '" + TMPVM3->VSJ_LOTECT + "'"
			cQuery += "   AND VE6.VE6_NUMLOT = '" + TMPVM3->VSJ_NUMLOT + "'"
			If lVSJSUGCOM .and. !Empty(TMPVM3->VSJ_SUGCOM)
				cQuery += " AND VE6.VE6_SUGCOM = '" + TMPVM3->VSJ_SUGCOM + "'"
			EndIf
			cQuery += "   AND VE6.D_E_L_E_T_ = ' '"
			If FM_SQL(cQuery) > 0
				nQtdEst := FM_SALDORESV( SB1->B1_GRUPO , SB1->B1_CODITE , TMPVM3->VM3_NUMOSV , TMPVM3->VSJ_LOTECT , TMPVM3->VSJ_NUMLOT , IIf(lVSJSUGCOM , TMPVM3->VSJ_SUGCOM , "" ) )
			EndIf
			If nQtdEst > nSaldo
				nQtdEst := nSaldo
			EndIf
			If nQtdEst > 0
				aAdd(aDiverg,{ TMPVM3->VSJ_CODIGO , TMPVM3->VM4_COD , ( nQtdEst - TMPVM3->VM4_QTCONF ) })
			EndIf

		EndIf

		TMPVM3->(DbSkip())
	EndDo

	TMPVM3->(dbCloseArea())

	If Len(aIteVO3) > 0 // Requisitar automaticamente as Pecas Conferidas
		lMSHelpAuto := .t.
		lMsErroAuto := .f.
		MSExecAuto({|x,y,z| OFIOM020(,,x,y,z)},aIteVO3,2 /* Requisita */)
		if lMsErroAuto
			DisarmTransaction()
			RollbackSx8()
			MsUnlockAll()
			MostraErro()
			Return .f.
		Endif
		lMSHelpAuto := .f.
	EndIf

	If Len(aDiverg) > 0 // Se conferencia possuir Divergencia, fazer a movimentacao dessa qtde para o Almoxarifado de Divergencia

		OA2120221_MovimentaDivergencia( aDiverg )

	EndIf

Return

/*/{Protheus.doc} OA2120211_FiltroBrowse

@author Andre Luis Almeida
@since 21/11/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function OA2120211_FiltroBrowse(cStatus)
Local cFiltro   := ""
Default cStatus := ""
cFiltro := "@ EXISTS ( SELECT VM3.VM3_NUMOSV "
cFiltro +=				"FROM " + RetSqlName("VM3") + " VM3 "
cFiltro +=				"WHERE VM3.VM3_FILIAL = VO1_FILIAL "
cFiltro +=					"AND VM3.VM3_NUMOSV = VO1_NUMOSV "
If !Empty(cStatus)
	cFiltro +=				"AND VM3.VM3_STATUS = '"+cStatus+"' "
Else
	cFiltro +=				"AND VM3.VM3_STATUS IN ('1','2','3') "
EndIf
cFiltro +=					"AND VM3.D_E_L_E_T_ = ' ' "
cFiltro +=	") "
Return cFiltro

/*/{Protheus.doc} OA2120221_MovimentaDivergencia

@author Andre Luis Almeida
@since 03/12/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function OA2120221_MovimentaDivergencia( aDiverg )

Local nCntFor   := 0
Local nRecVSJ   := 0
Local nRecVE6   := 0
Local cQuery    := ""

Local aItemMov  := {}
Local oEst      := DMS_Estoque():New()

Local lESTNEG       := ( GetNewPar("MV_ESTNEG","S") == "S" )
Local cMV_MIL0037   := GetNewPar("MV_MIL0037","S") // Movimenta em divergencia de estoque? (S/N) 

Local lVSJSUGCOM := (VSJ->(FieldPos("VSJ_SUGCOM")) <> 0)

///////////////////////////////////////////////////////////////////////////////////////////////////////////
// Faz a Integracao com o MATA261 das Divergencias somente quando Estoque Negativo MV_ESTNEG igual a NAO //
///////////////////////////////////////////////////////////////////////////////////////////////////////////
if cMV_MIL0037 == "S" .and. !lESTNEG

	// reserva itens não conferidos
	aItensNew := {}
	cDocumento  := Criavar("D3_DOC")
	cDocumento	:= IIf(Empty(cDocumento),NextNumero("SD3",2,"D3_DOC",.T.),cDocumento)
	cDocumento	:= A261RetINV(cDocumento)

	// Adiciona cabecalho com numero do documento e data da transferencia modelo II
	aadd (aItensNew,{ cDocumento , dDataBase })
	//
	lIntegra261 := .f.

	BEGIN TRANSACTION

	For nCntFor := 1 to len(aDiverg)

		cQuery := "SELECT R_E_C_N_O_ "
		cQuery += " FROM " + RetSqlName("VSJ")
		cQuery += " WHERE VSJ_FILIAL = '" + xFilial("VSJ") + "' "
		cQuery += "   AND VSJ_CODIGO = '" + aDiverg[nCntFor,1] + "' "
		cQuery += "   AND D_E_L_E_T_ = ' '"
		nRecVSJ := FM_SQL(cQuery)
		If nRecVSJ > 0
			DbSelectArea("VSJ")
			DbGoto(nRecVSJ)
			RecLock("VSJ",.f.)
				VSJ->VSJ_QTDITE -= aDiverg[nCntFor,3] // Subtrair a Qtde Divergente no VSJ
			MsUnLock()
			//
			cQuery := "SELECT R_E_C_N_O_ VE6RECNO "
			cQuery += "  FROM " + RetSQLName("VE6") + " VE6 "
			cQuery += " WHERE VE6.VE6_FILIAL = '" + xFilial("VE6") + "'"
			cQuery += "   AND VE6.VE6_NUMOSV = '" + VSJ->VSJ_NUMOSV + "'"
			cQuery += "   AND VE6.VE6_INDREG = '3'" // Registro de Reserva
			cQuery += "   AND VE6.VE6_GRUITE = '" + VSJ->VSJ_GRUITE + "'"  
			cQuery += "   AND VE6.VE6_CODITE = '" + VSJ->VSJ_CODITE + "'"
			cQuery += "   AND VE6.VE6_LOTECT = '" + VSJ->VSJ_LOTECT + "'"
			cQuery += "   AND VE6.VE6_NUMLOT = '" + VSJ->VSJ_NUMLOT + "'"
			If lVSJSUGCOM .and. !Empty(VSJ->VSJ_SUGCOM)
				cQuery += " AND VE6.VE6_SUGCOM = '" + VSJ->VSJ_SUGCOM + "'"
			EndIf
			cQuery += "   AND VE6.D_E_L_E_T_ = ' '"
			nRecVE6 := FM_SQL(cQuery)
			If nRecVE6 > 0
				DbSelectArea("VE6")
				DbGoto(nRecVE6)
				RecLock("VE6",.f.)
					VE6->VE6_QTDEST += aDiverg[nCntFor,3] // Somar a Qtde Divergente no VE6 para matar a Reserva
				MsUnLock()
			EndIf
		EndIf

		DbSelectArea("SB1")
		DbSetOrder(1)
		DBSeek( xFilial("SB1") + aDiverg[nCntFor,2] )
		//
		DbSelectArea("SB5")
		DbSetOrder(1)
		DbSeek( xFilial("SB5") + SB1->B1_COD )

		// Origem: Reserva
		cLocalRes   := GetMv( "MV_RESITE" )+Space(GetSX3Cache("B2_LOCAL","X3_TAMANHO")-Len(GetMv("MV_RESITE")))
		cLOCALI2Res := IIf(Localiza(SB1->B1_COD),GetMv( "MV_RESLOC" )+Space(GetSX3Cache("B5_LOCALI2","X3_TAMANHO")-Len(GetMv("MV_RESLOC"))),Space(15))
		// Destino: Divergencia
		cLocalDiv   := GetMv( "MV_DIVITE" )+Space(GetSX3Cache("B2_LOCAL","X3_TAMANHO")-Len(GetMv("MV_DIVITE")))
		cLOCALI2Div := IIf(Localiza(SB1->B1_COD),GetMv( "MV_DIVLOC" )+Space(GetSX3Cache("B5_LOCALI2","X3_TAMANHO")-Len(GetMv("MV_DIVLOC"))),Space(15))
		//
		aItemMov := oEst:SetItemSD3(SB1->B1_COD         ,; //Código do Produto
									cLocalRes           ,; // Armazém de Origem
									cLocalDiv           ,; // Armazém de Destino
									cLOCALI2Res         ,; // Localização Origem
									cLOCALI2Div         ,; // Localização Destino
									aDiverg[nCntFor,3]  ,; // Qtd a transferir
									VSJ->VSJ_LOTECT     ,; // Nro de lote
									VSJ->VSJ_NUMLOT     ,; // Nro de Sub-Lote
									VSJ->VSJ_NUMSER      ) // Nro de Série

		aAdd(aItensNew, aClone(aItemMov))

	Next

	///////////////////////////////////////////////////////////////////////////////////////////////////////////
	// Faz a Integracao com o MATA261 das Divergencias somente quando Estoque Negativo MV_ESTNEG igual a NAO //
	///////////////////////////////////////////////////////////////////////////////////////////////////////////
	lMSErroAuto := .f.
	MSExecAuto({|x, y| MATA261(x,y)},aItensNew,3)
	If lMsErroAuto
		MsgInfo(STR0054,STR0044) // Houve um problema na transferencia dos itens com divergencia na conferencia. / Atencao
		MostraErro()
		DisarmTransaction()
		return .f.
	EndIf

	END TRANSACTION

EndIf
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

/*/{Protheus.doc} OA2120231_TravarVM3
Travar VM3 novamente, pois existem UnLock's do VM3 perdendo a trava

@author Andre Luis Almeida
@since 24/02/2021

@type function
/*/
Static Function OA2120231_TravarVM3( cConferencia , cTpOrigem )

	// Como existem UnLock's do VM3 dentro das funcoes, é necessario travar o VM3 novamente
	DbSelectArea("VM3")
	DbSetOrder(1)
	If DbSeek(xFilial("VM3")+cConferencia)
		If cTpOrigem == "2" // Coletor
			SimpleLock() // No coletor utilizar SimpleLock ao inves de SoftLock
		Else
			Softlock("VM3") // Travar Registro do VM3
		EndIf
	EndIf

Return

/*/{Protheus.doc} OA2120241_Visualiza_Itens_sem_Saldo
Visualiza os Itens SEM Saldo para Requisitar

@author Andre Luis Almeida
@since 10/05/2021

@type function
/*/
Static Function OA2120241_Visualiza_Itens_sem_Saldo( cConferencia )

Local cNomRel   := "OFIA212"
Local cTitulo   := STR0055 // Visualiza Itens sem Saldo
Local aIntCab   := {} // Cabeçalhos da função FGX_VISINT
Local aIntIte   := {} // Itens da função FGX_VISINT
Local cLocPad   := ""
Local nSaldo    := 0
Local cMVRESITE := PadR( AllTrim(GetMv("MV_RESITE")), GetSX3Cache("B2_LOCAL","X3_TAMANHO") )
	
aAdd(aIntCab,{STR0021,"C",25,"@!"})				//01 - Grupo
aAdd(aIntCab,{STR0022,"C",60,"@!"})				//02 - Cod.Item
aAdd(aIntCab,{STR0023,"C",100,"@!"})			//03 - Descrição
aAdd(aIntCab,{STR0025,"N",50,"@E 999,999,999"})	//04 - Qtd.Conferida
aAdd(aIntCab,{STR0057,"N",50,"@E 999,999,999"})	//05 - Saldo
aAdd(aIntCab,{STR0058,"C",30,"@!"})				//06 - Armazem

cQuery := "SELECT VM4.R_E_C_N_O_ AS RECVM4 ,"
cQuery += "       SB1.R_E_C_N_O_ AS RECSB1 ,"
cQuery += "       VSJ.VSJ_RESPEC , VSJ.VSJ_TIPTEM "
cQuery += " FROM " + RetSqlName("VM3") + " VM3 "
cQuery += " JOIN " + RetSqlName("VM4") + " VM4 "
cQuery +=	"  ON VM4.VM4_FILIAL = VM3.VM3_FILIAL "
cQuery +=	" AND VM4.VM4_CODVM3 = VM3.VM3_CODIGO "
cQuery +=	" AND VM4.VM4_PRBEST = '1' " // Tem problema de Saldo de Estoque
cQuery +=	" AND VM4.D_E_L_E_T_ = ' ' "
cQuery += " LEFT JOIN " + RetSqlName("SB1") + " SB1 "
cQuery +=	"  ON SB1.B1_FILIAL = '"+xFilial("SB1")+"' "
cQuery +=	" AND SB1.B1_COD = VM4.VM4_COD "
cQuery +=	" AND SB1.D_E_L_E_T_ = ' ' "
cQuery += " LEFT JOIN " + RetSqlName("VSJ") + " VSJ "
cQuery +=	"  ON VSJ.VSJ_NUMOSV = VM3.VM3_NUMOSV "
cQuery +=	" AND VSJ.VSJ_CODIGO = VM4.VM4_CODVSJ "
cQuery +=	" AND VSJ.VSJ_GRUITE = SB1.B1_GRUPO "
cQuery +=	" AND VSJ.VSJ_CODITE = SB1.B1_CODITE "
cQuery +=	" AND VSJ.D_E_L_E_T_ = ' ' "
cQuery += " WHERE VM3.VM3_FILIAL = '" + xFilial("VM3") + "'"
cQuery += 	" AND VM3.VM3_CODIGO = '" + cConferencia + "' "
cQuery += 	" AND VM3.D_E_L_E_T_ = ' ' "
TcQuery cQuery New Alias "TMPVM4"
While !TMPVM4->(Eof())
	SB1->(DbSetOrder(1))
	SB1->(DbGoto( TMPVM4->( RECSB1 ) ))
	If TMPVM4->( VSJ_RESPEC ) == "1"
		cLocPad := cMVRESITE
	Else
		cLocPad := OM0200065_ArmazemOrigem( TMPVM4->( VSJ_TIPTEM ) )
	EndIf
	SB2->(DbSetOrder(1))
	SB2->(DbSeek(xFilial("SB2")+SB1->B1_COD+cLocPad))
	nSaldo := SaldoSB2()
	VM4->(DbGoto( TMPVM4->( RECVM4 ) ))
	aAdd(aIntIte,{	SB1->B1_GRUPO ,;
					SB1->B1_CODITE ,;
					SB1->B1_DESC ,;
					VM4->VM4_QTCONF ,;
					nSaldo ,;
					cLocPad })
	TMPVM4->(DbSkip())
EndDo
TMPVM4->(dbCloseArea())
DbSelectArea("VM4")

FGX_VISINT( cNomRel , cTitulo , aIntCab , aIntIte , .t. )

Return

/*/{Protheus.doc} OA2120251_VerificaStatusOS
Verifica o Status da OS

@author Andre Luis Almeida
@since 12/05/2021

@type function
/*/
Function OA2120251_VerificaStatusOS( cNumOSV , cTpOrigem )
Local lRet := .t.
Default cTpOrigem := "0" // Tipo de Origem ( 0=Manual / 1-Leitor(Nao usado no momento, nao existe diferenciação em relação ao 0=Manual) / 2=Coletor de Dados )
VO1->(DbSetOrder(1))
VO1->(DbSeek( xfilial("VO1") + cNumOSV ))
If VO1->VO1_STATUS <> "A"
	If cTpOrigem == "2" // 2=Coletor de Dados
		VTAlert(STR0059,STR0044) // OS não esta com Status Em Aberto / Atencao
	Else
		MsgStop(STR0059,STR0044) // OS não esta com Status Em Aberto / Atencao
	EndIf
EndIf
Return lRet