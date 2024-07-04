#INCLUDE "PROTHEUS.CH"
#INCLUDE "JURA263.CH"

Static cSocioAnt := ""

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA263
Cobrança em Lote

@author  Jonatas Martins / Bruno Ritter / Anderson Carvalho
@since   24/05/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA263(lAutomato, aFiltros)
	Local oMBrowse    := Nil

	Default lAutomato := .F.
	Default oTempTable := NIL
	Default aFiltros := {} //1 - socio, escritorio, fatura, cNomArq
	
	If !lAutomato
		Processa({|| J263MBrw(@oMBrowse, @oTempTable, lAutomato, nil)})
		If (oTempTable:GetAlias())->( Eof() )
			ApMsgInfo( STR0008 ) // "Não foi encontrado nenhum registro!"
		Else
			oMBrowse:Activate()
		EndIf
	Else
		J263MBrw(NIL, @oTempTable, lAutomato, aFiltros)
	EndIf
	
	oTempTable:Delete()
	
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J263MBrw
Monta MarkBrowse da tela de cobrança em lote

@param   oMBrowse  , objeto, MarkBrowse da tela
@param   oTempTable, objeto, Estrutura da Tabela temporária

@author  Jonatas Martins / Bruno Ritter / Anderson Carvalho
@since   24/05/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J263MBrw(oMBrowse, oTempTable, lAutomato, aFiltros)
	Local cTempAls    := GetNextAlias()
	Local cQuery      := J263Query(IIF(!lAutomato, , aFiltros))
	Local aIdxAdic    := J263IdxAdc()
	Local aStruAdic   := J263StrAdc()
	Local aCmpNotBrw  := J263RmvBrw()
	Local aTitCpoBrw  := J263TitCpo()
	Local aTabTmp     := {}
	Local aFldsFilt   := {}
	Local aFields     := {}
	Local aOrder      := {}
	Local lPDUserAc   := Iif(FindFunction("JPDUserAc"), JPDUserAc(), .T.) // Indica se o usuário possui acesso a dados sensíveis ou pessoais (LGPD)

	aTabTmp     := JurCriaTmp(cTempAls, cQuery, "SE1", aIdxAdic, aStruAdic, , aCmpNotBrw, .T., , aTitCpoBrw)
	oTempTable  := aTabTmp[1]
	aFldsFilt   := aTabTmp[2]
	aOrder      := aTabTmp[3]
	aFields     := aTabTmp[4]

	If !lAutomato
		oMBrowse := FWMarkBrowse():New()
		oMBrowse:SetDescription( STR0001 ) //"Cobrança em lote"
		oMBrowse:SetAlias( cTempAls )
		oMBrowse:SetTemporary( .T. )
		oMBrowse:SetFields( aFields )
		oMBrowse:oBrowse:SetDBFFilter( .T. )
		oMBrowse:SetUseFilter()

		If Len(aTabTmp) >= 7 .And. !Empty(aTabTmp[7]) // Tratamento para LGPD verifica os campos que devem ser ofuscados
			oMBrowse:oBrowse:SetObfuscFields(aTabTmp[7])
		EndIf

		oMBrowse:SetSeek( .T., aOrder)
		oMBrowse:oBrowse:SetFieldFilter( aFldsFilt )
		oMBrowse:oBrowse:bOnStartFilter := Nil
		
		oMBrowse:SetMenuDef( "" )
		oMBrowse:SetFieldMark( "OK" )
		oMBrowse:AddButton(STR0009, {|| J263FilSoc(@oMBrowse, @oTempTable)}, ,4) // "Filtrar Sócio Resp."
		If lPDUserAc
			oMBrowse:AddButton(STR0017, {|| J263Imp(@oMBrowse, @oTempTable)}, ,8) // "Aviso de Cobrança"
		EndIf
	Else
		 J263Imp(@oMBrowse, @oTempTable, lAutomato, aFiltros[04])
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J263Query
Monta query para a tabela temporaria

@param   cSocio    , caracter, Código do sócio que será filtrado
@return  cQuery    , caracter, Busca registro no banco

@author  Jonatas Martins / Bruno Ritter / Anderson Carvalho
@since   24/05/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J263Query(uFilter)
	Local cQuery     := ""
	Local nValMax    := SuperGetMV("MV_JVALMAX", .F., 0)
    Local nTamFil    := TamSX3("NXA_FILIAL")[1]
	Local nTamEsc    := TamSX3("NXA_CESCR")[1]
	Local cTamFilial := cValToChar(nTamFil)
	Local cIniEscr   := cValToChar(nTamFil+2)
	Local cTamEscr   := cValToChar(nTamEsc)
	Local cIniFatur  := cValToChar(nTamFil+1+nTamEsc+2)
	Local cTamFatur  := cValToChar(TamSX3("NXA_COD")[1])
	Local cSocio	 := ""
	Local cEscri	 := ""
	Local cFatura	 := ""
	Local lExistOHT  := AliasInDic("OHT")
	Local lIntPFS    := lExistOHT .And. SuperGetMV("MV_JURXFIN",, .F.) // Integração SIGAPFS x SIGAFIN

	cSocio := uFilter
	
	If ValType(uFilter) == "A"
		cEscri	 := uFilter[02]
		cFatura	 := uFilter[03]
		cSocio	 := uFilter[01]
	EndIf
	
	lFilterSoc := !Empty(cSocio)

	cQuery := " SELECT OK, E1_CLIENTE, E1_LOJA, A1_CGC, A1_NOME, U5_CODCONT, U5_CONTAT, CTO_MOEDA, CTO_SIMB, TOTAL"
	cQuery +=   " FROM (SELECT ' ' OK,"
	
	// Considera o Sócio quando existe filtro
	If lFilterSoc
		cQuery +=     " ISNULL(RD0.RD0_SIGLA, '     ') RD0_SIGLA,"
	EndIf
	
	cQuery +=     " SE1.E1_CLIENTE,"
	cQuery +=     " SE1.E1_LOJA,"
	cQuery +=     " SA1.A1_CGC,"
	cQuery +=     " SA1.A1_NOME,"
	cQuery +=     " ISNULL(SU5.U5_CODCONT, '') U5_CODCONT,"
	cQuery +=     " ISNULL(SU5.U5_CONTAT, '') U5_CONTAT,"
	cQuery +=     " CTO.CTO_MOEDA,"
	cQuery +=     " CTO.CTO_SIMB,"
	cQuery +=     " SUM(SE1.E1_SALDO) TOTAL,"
	cQuery +=     " SUM(SE1.E1_SALDO * (SE1.E1_VLCRUZ / SE1.E1_VALOR)) TOTAL_CONV"
	cQuery +=  " FROM " + RetSqlName("SE1") + " SE1"
	
	// Dados do Cliente
	cQuery += " INNER JOIN " + RetSqlName("SA1") + " SA1"
	cQuery +=    " ON SA1.A1_FILIAL = '" + xFilial("SA1") + "'"
	cQuery +=   " AND SA1.A1_COD = SE1.E1_CLIENTE"
	cQuery +=   " AND SA1.A1_LOJA = SE1.E1_LOJA"
	cQuery +=   " AND SA1.D_E_L_E_T_ = ' '"
	
	// Dados da Fatura
	If lIntPFS
		cQuery += "INNER JOIN " + RetSqlName("OHT") + " OHT"
		cQuery +=   " ON OHT.OHT_FILFAT = '" + xFilial("NXA") + "'"
		cQuery +=  " AND OHT.OHT_PREFIX = SE1.E1_PREFIXO"
		cQuery +=  " AND OHT.OHT_TITNUM = SE1.E1_NUM"
		cQuery +=  " AND OHT.OHT_TITPAR = SE1.E1_PARCELA"
		cQuery +=  " AND OHT.OHT_TITTPO = SE1.E1_TIPO"
		cQuery +=  " AND OHT.OHT_FILTIT = SE1.E1_FILIAL"
		cQuery +=  " AND OHT.D_E_L_E_T_ = ' '"

		cQuery += " INNER JOIN " + RetSqlName("NXA") + " NXA"
        cQuery +=   "  ON NXA.NXA_FILIAL = OHT.OHT_FILFAT"
        cQuery +=   " AND NXA.NXA_CESCR = OHT.OHT_FTESCR"
        cQuery +=   " AND NXA.NXA_COD = OHT.OHT_CFATUR"
	Else
		cQuery += " INNER JOIN " + RetSqlName("NXA") + " NXA"
		cQuery +=    " ON NXA.NXA_FILIAL = SUBSTRING(E1_JURFAT, 1, " + cTamFilial + ")"
		cQuery +=   " AND NXA.NXA_CESCR = SUBSTRING(E1_JURFAT, " + cIniEscr + ", " + cTamEscr + ")"
		cQuery +=   " AND NXA.NXA_COD = SUBSTRING(E1_JURFAT, " + cIniFatur + ", " + cTamFatur + ")"
	EndIf
	// Filtra Sócio Responsável
	If lFilterSoc
		cQuery +=   " AND NXA.NXA_CPART = '" + cSocio + "'"
	EndIf

	If !Empty(cFatura)
		cQuery +=   " AND NXA.NXA_CESCR =  '" + cEscri + "'"
		cQuery +=   " AND NXA.NXA_COD = '" + cFatura + "'"
	EndIf
	cQuery +=       " AND NXA.D_E_L_E_T_ = ' '"
	
	// Dados do Contato
	cQuery +=      " LEFT JOIN " + RetSqlName("SU5") + " SU5"
	cQuery +=        " ON SU5.U5_FILIAL = '" + xFilial("SU5") + "'"
	cQuery +=       " AND SU5.U5_CODCONT = NXA.NXA_CCONT"
	cQuery +=       " AND SU5.D_E_L_E_T_ = ' '"
	// Dados da Moeda
	cQuery +=     " INNER JOIN " + RetSqlName("CTO") + " CTO"
	cQuery +=        " ON CTO.CTO_FILIAL = '" + xFilial("CTO") + "'"
	cQuery +=       " AND CAST(CTO_MOEDA AS DECIMAL) = SE1.E1_MOEDA"
	cQuery +=       " AND CTO.D_E_L_E_T_ = ' '"
	
	// Dados do Sócio Responsável quando existe filtro
	If lFilterSoc
		cQuery += " INNER JOIN " + RetSqlName("RD0") + " RD0"
		cQuery +=    " ON RD0.RD0_FILIAL = '" + xFilial("RD0") + "'"
		cQuery +=   " AND RD0.RD0_CODIGO = NXA.NXA_CPART"
		cQuery +=   " AND RD0.D_E_L_E_T_ = ' '"
	EndIf
	
	cQuery +=     " WHERE SE1.E1_FILIAL = '" + xFilial("SE1") + "'"
	cQuery +=       " AND SE1.E1_SALDO > 0"
	cQuery +=       " AND SE1.E1_VENCTO < '" + DtoS(Date()) + "'"
	cQuery +=       " AND SE1.D_E_L_E_T_ = ' '"
	
	// Agrupa por sócio quando existir filtro
	If lFilterSoc
		cQuery += " GROUP BY RD0.RD0_SIGLA,"
	Else
		cQuery += " GROUP BY"
	EndIf
	
	cQuery +=     " SE1.E1_CLIENTE,"
	cQuery +=     " SE1.E1_LOJA,"
	cQuery +=     " SA1.A1_CGC,"
	cQuery +=     " SA1.A1_NOME,"
	cQuery +=     " SU5.U5_CODCONT,"
	cQuery +=     " SU5.U5_CONTAT,"
	cQuery +=     " CTO.CTO_MOEDA,"
	cQuery +=     " CTO.CTO_SIMB) QRY"
	cQuery += " WHERE QRY.TOTAL_CONV <= " + cValToChar(nValMax) + " "
	cQuery += " ORDER BY QRY.E1_CLIENTE, QRY.E1_LOJA"
	cQuery := ChangeQuery(cQuery)
	
Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} J263IdxAdc
Monta Indices para a tabela temporária

@return  aIdxAdic, array, Indices para a tabela temporária

@author  Jonatas Martins / Bruno Ritter / Anderson Carvalho
@since   24/05/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J263IdxAdc()
	Local aIdxAdic   := {}
	Local nTamIdxCli := TamSX3("E1_CLIENTE")[1] + TamSX3("E1_LOJA")[1]

	Aadd(aIdxAdic, {STR0003, "E1_CLIENTE+E1_LOJA", nTamIdxCli})    // "Cliente"

Return ( aIdxAdic )

//-------------------------------------------------------------------
/*/{Protheus.doc} J263StrAdc
Monta a estrutura de campos que não existe no SX3 para a tabela temporária

@return  aStruAdic, array, Campos que não existe no SX3 para a tabela temporária

@author  Jonatas Martins / Bruno Ritter / Anderson Carvalho
@since   24/05/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J263StrAdc()
	Local aStruAdic := {}
	Local aTamSaldo := TamSX3("E1_SALDO")

	Aadd(aStruAdic, {"OK", "OK", "C", 1, 0, ""} )
	Aadd(aStruAdic, {"TOTAL", STR0005, "N", aTamSaldo[1], aTamSaldo[2], PesqPict("SE1", "E1_SALDO"), "E1_SALDO"} ) // "Total"

Return ( aStruAdic )

//-------------------------------------------------------------------
/*/{Protheus.doc} J263RmvBrw
Monta array com os campos que não devem apareder na tela

@return  aCmpNotBrw, array, Campos que não devem apareder na tela

@author  Jonatas Martins / Bruno Ritter / Anderson Carvalho
@since   24/05/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J263RmvBrw()
	Local cLojaAuto  := SuperGetMv("MV_JLOJAUT" , .F. , "2" ,  ) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
	Local aCmpNotBrw := {}
	
	Aadd(aCmpNotBrw, "OK")
	Aadd(aCmpNotBrw, "CTO_MOEDA")
	Aadd(aCmpNotBrw, "U5_CODCONT")
	
	If cLojaAuto == "1"
		Aadd(aCmpNotBrw, "E1_LOJA")
	EndIf

Return ( aCmpNotBrw )

//-------------------------------------------------------------------
/*/{Protheus.doc} J263TitCpo
Monta array para alterar os títulos dos campos da tela

@return  aTitCpoBrw, array, Alterar os títulos dos campos da tela

@author  Jonatas Martins / Bruno Ritter / Anderson Carvalho
@since   24/05/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J263TitCpo()
	Local aTitCpoBrw := {{"U5_CONTAT", STR0006}} // "Contato"
	
Return ( aTitCpoBrw )

//-------------------------------------------------------------------
/*/{Protheus.doc} J263FilSoc
Função para filtrar o Sócio Responsáveil

@param  oMBrowse  , obejto, MarkBrowse dos registros
@param  oTempTable, obejto, Estrutura da Tabela temporária

@author  Jonatas Martins / Bruno Ritter / Anderson Carvalho
@since   24/05/2018
@version 1.0
@Obs     As variáveis oMBrowse e oTempTable são passadas como referência da função J263MBrw
/*/
//-------------------------------------------------------------------
Static Function J263FilSoc(oMBrowse, oTempTable)
	Local oLayer     := FWLayer():new()
	Local oMainColl  := Nil
	Local oDlg       := Nil
	Local oGetSoc    := Nil
	Local lRet       := .F.

	DbSelectArea("RD0")
	
	DEFINE MsDialog oDlg TITLE STR0002 FROM 0,0 TO 130,220 PIXEL  // "Filtrar Sócio Resp."

	oLayer:init(oDlg,.F.) //Inicializa o FWLayer com a janela que ele pertencera e se sera exibido o botao de fechar
	oLayer:addCollumn("MainColl",100,.F.) //Cria as colunas do Layer
	oMainColl := oLayer:GetColPanel( 'MainColl' )

	oGetSoc := TJurPnlCampo():New(008,005,70,22,oMainColl,,"NUH_SIGLA") // "Sócio Resp"
	oGetSoc:SetValue( PADR(cSocioAnt, TamSX3("NUH_SIGLA")[1]) )

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,;
															{|| lRet := J263FilOk(oGetSoc:GetValue(), @oMBrowse, @oTempTable), IIF(lRet, oDlg:End(), '') },; //# "Carregando..."
															{|| oDlg:End() },;
															, /*aButtons*/,/*nRecno*/,/*cAlias*/, .F., .F.,.F.,.T.,.F. )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J263FilOk
Função do botão ok da tela de filtro de sócio

@param  cSocio    , Socio, Sigla do Sócio Responsável digitado
@param  oMBrowse  , obejto, MarkBrowse dos registros
@param  oTempTable, obejto, Estrutura da Tabela temporária

@author  Bruno Ritter
@since   28/05/2018
@version 1.0
@Obs     A variável cSocioAnt é uma STATIC declarada no topo do fonte
/*/
//-------------------------------------------------------------------
Static Function J263FilOk(cSocio, oMBrowse, oTempTable)
	Local lFecharDlg := .F.
	Local cCodSocio  := ""

	If AllTrim(cSocio) == AllTrim(cSocioAnt)//Se for igual, não precisa fazer filtro.
		lFecharDlg := .T.

	ElseIf J263VldSoc(cSocio, @cCodSocio)
		Processa({|| J263RunFil(cCodSocio, @oMBrowse, @oTempTable)})
		lFecharDlg := .T.
	EndIf

Return lFecharDlg

//-------------------------------------------------------------------
/*/{Protheus.doc} J263VldSoc
Valida a existência do Sócio Responsável digitado

@param  cSigSocio, Sigla do Sócio Responsável digitado
@param  cCodSocio, Código do Sócio Responsável digitado (passar como referência)

@return lExisteSoc, Se deve atualizar o browse

@author  Jonatas Martins / Bruno Ritter / Anderson Carvalho
@since   24/05/2018
@version 1.0
@Obs     A variável cSocioAnt é uma STATIC declarada no topo do fonte
/*/
//-------------------------------------------------------------------
Static Function J263VldSoc(cSigSocio, cCodSocio)
	Local lExisteSoc := .T.

	If !Empty(cSigSocio)
		cCodSocio := JurGetDados("RD0", 9, xFilial("RD0") + AllTrim(cSigSocio), "RD0_CODIGO") // RD0_FILIAL + RD0_SIGLA
		If Empty(cCodSocio)
			JurMsgErro(STR0011) // "Sócio responsável inválido!"
			lExisteSoc := .F.
		Else
			cSocioAnt  := cSigSocio
			lExisteSoc := .T.
		EndIf

	Else
		cSocioAnt  := ""
		lExisteSoc := .T.
	EndIf

Return lExisteSoc

//-------------------------------------------------------------------
/*/{Protheus.doc} J263RunFil
Executa filtro de sócio e atualiza MarkBrowse na tela

@param  cSocio    , Socio , Código do Sócio Responsável que será filtrado
@param  oMBrowse  , obejto, MarkBrowse dos registros
@param  oTempTable, obejto, Estrutura da Tabela temporária

@author  Jonatas Martins / Bruno Ritter / Anderson Carvalho
@since   24/05/2018
@version 1.0
@Obs     As variáveis oMBrowse e oTempTable são passadas como referência da função J263MBrw
/*/
//-------------------------------------------------------------------
Static Function J263RunFil(cSocio, oMBrowse, oTempTable)
	Local cQryFilter  := ""
	Local cAlsFilter  := ""
	Local aIdxAdic    := J263IdxAdc()
	Local aStruAdic   := J263StrAdc()
	Local aCmpNotBrw  := J263RmvBrw()
	Local aTitCpoBrw  := J263TitCpo()
	
	cQryFilter := J263Query(cSocio)
	cAlsFilter := oTempTable:GetAlias()
	
	oTempTable:Delete()
	oTempTable  := JurCriaTmp(cAlsFilter, cQryFilter, "SE1", aIdxAdic, aStruAdic, , aCmpNotBrw, .T., , aTitCpoBrw)[1]
	
	oMBrowse:Refresh()
	oMBrowse:GoTop(.T.)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J263Imp
Função parar gerar a tela de aviso de cobrança

@param  oMBrowse  , obejto, MarkBrowse dos registros
@param  oTempTable, obejto, Estrutura da Tabela temporária

@author  Jorge Martins / Bruno Ritter
@since   05/11/2018
@version 1.0
@Obs     As variáveis oMBrowse e oTempTable são passadas como referência da função J263MBrw
/*/
//-------------------------------------------------------------------
Static Function J263Imp(oMBrowse, oTempTable, lAutomato, cNomeArq)
	Local lClose     := .F.
	Local cAlsTmp    := oTempTable:GetAlias()
	Local cNameTbTmp := oTempTable:GetRealName()
	Local aAreas     := { (cAlsTmp)->(GetArea()), GetArea() }
	Local oLayer     := FWLayer():new()
	Local oMainColl  := Nil
	Local oDlg       := Nil
	Local oCkCarta   := Nil
	Local oCkRelat   := Nil
	Local oCbResult  := Nil
	Local cCbResult  := ""
	Local aCbResult  := { STR0012, STR0013, STR0014 } //"Tela", "Impressora", "Salvar em disco"
	Local cMarca     := ""
	Local cQuery     := ""

	Default lAutomato := .F.
	Default cNomeArq := ""

	cMarca     := Iif(lAutomato .OR. oMBrowse:IsInvert(), " ", oMBrowse:Mark())
	cQuery     := "SELECT R_E_C_N_O_ FROM " + cNameTbTmp + " WHERE OK = '" + cMarca +"'"

	aMarcados := JurSQL(cQuery, {"R_E_C_N_O_"})

	If !lAutomato

		If Empty(aMarcados)
			JurMsgErro(STR0015,,STR0016) // "Nenhum item foi selecionado." "Selecione um item para gerar o aviso de cobrança."

		Else
			DEFINE MsDialog oDlg TITLE STR0017 FROM 0,0 TO 190,230 PIXEL  // "Aviso de Cobrança"

			oLayer:init(oDlg,.F.) //Inicializa o FWLayer com a janela que ele pertencera e se sera exibido o botao de fechar
			oLayer:addCollumn("MainColl",100,.F.) //Cria as colunas do Layer
			oMainColl := oLayer:GetColPanel( 'MainColl' )

			oCkCarta := TJurCheckBox():New(008, 005, STR0018,  {|| }, oMainColl, 100, 008, ,{|| } , , , , , , .T., , , ) // "Carta de Cobrança"
			oCkCarta:SetCheck(.F.)
			oCkRelat := TJurCheckBox():New(018, 005, STR0019,  {|| }, oMainColl, 100, 008, ,{|| } , , , , , , .T., , , ) // "Relatório"
			oCkRelat:SetCheck(.F.)
			TSay():New(035,005,{||STR0020},oMainColl,,,,,,.T.,,,030,008) // "Resultado:"
			oCbResult := TComboBox():New(045,005,{|u|if(PCount()>0,cCbResult:=u,cCbResult)},;
						aCbResult, 070, 010, oMainColl,,,,,,.T.,,,,,,,,,'cCbResult')

			ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,;
																	{|| Processa({||;
																				lClose := J263Relat(cCbResult, oCkCarta:Checked(), oCkRelat:Checked(), aMarcados, @oMBrowse, @oTempTable, lAutomato);
																				, STR0021, STR0022, .F.; // "Aguarde" "Processando..."
																				}), IIF(lClose, oDlg:End(), '') },;
																	{|| oDlg:End() },;
																	, /*aButtons*/,/*nRecno*/,/*cAlias*/, .F., .F.,.F.,.T.,.F. )
			EndIf
	Else
		 J263Relat("1", .T., .F., aMarcados, @oMBrowse, @oTempTable, lAutomato, cNomeArq)
	EndIf
	Aeval( aAreas, {|aArea| RestArea( aArea ) } )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J263Relat
Função parar gerar o aviso de cobrança

@param  cOpc       , Forma que será apresentado o aviso de cobrança.
@param  lCarta     , Se é para gerar a carta de cobrança.
@param  lRelatorio , Se é para gerar os relatórios da fatura.
@param  aMarcados  , Array com os recnos dos registros marcados.
@param  oMBrowse   , MarkBrowse dos registros.
@param  oTempTable , Estrutura da Tabela temporária.

@author  Bruno Ritter
@since   05/11/2018
@version 1.0
@Obs     As variáveis oMBrowse e oTempTable são passadas como referência da função J263MBrw
/*/
//-------------------------------------------------------------------
Static Function J263Relat(cOpc, lCarta, lRelatorio, aMarcados, oMBrowse, oTempTable, lAutomato, cNomeArq)
	Local lOk        := .T.
	Local cPath      := ""
	Local cTpSaida   := "" // Tipo de saída do relatório
	Local cNameTbTmp := oTempTable:GetRealName()
	Local cAlsTmp    := oTempTable:GetAlias()
	Local aFaturas   := {}
	Local cPasta     := ""
	Local nRecTmp    := 0
	Local nRecTmpAt  := (cAlsTmp)->(Recno())
	Local nI         := 0
	Local nRpt       := 0
	Local cEscrit    := ""
	Local cFatura    := ""
	Local cArquivo   := ""
	Local cDestPath  := ""
	Local cMsgRet    := ""
	Local nTotalMark := Len(aMarcados)
	Local cCodSocio  := JurGetDados("RD0", 9, xFilial("RD0") + AllTrim(cSocioAnt), "RD0_CODIGO") // RD0_FILIAL + RD0_SIGLA
	Local lJPAD036   := ExistBlock( 'JURAPAD036' )
	Local cFunc      := "U_JURAPAD036"

	Default lAutomato := .F.
	Default cNomeArq := ""

	IIF(!lAutomato, ProcRegua(nTotalMark), )

	Do Case
		Case STR0013 == cOpc // "Impressora"
			cTpSaida := "1"
		Case STR0012 == cOpc // "Tela"
			cTpSaida := "2"
		Case STR0014 == cOpc // "Salvar em disco"
			cTpSaida := "3"

			cPath := AllTrim(cGetFile(STR0023+" |", STR0024, , , .F., GETF_RETDIRECTORY + GETF_LOCALHARD + GETF_NETWORKDRIVE, .F., .T.)) // "Selecione o Diretório" "Selecione o diretório para gerar os arquivos"
			If Empty(cPath)
				lOk   := .F.
			Else
				lOk   := .T.
				cPath += STR0025 + "\" // COBRANCA_LOTE
				MakeDir(cPath,,.F.)
				If !Empty(cSocioAnt)
					cPath += AllTrim(cSocioAnt) + "\"
					MakeDir(cPath,,.F.)
				EndIf
			EndIf
	EndCase

	// Gera relatórios
	If lOk
		If FindFunction("JPDLogUser")
			JPDLogUser("JURAPAD036") // Log LGPD Relatório de Aviso de Cobrança
		EndIf
		
		For nI := 1 To nTotalMark
			IIF(!lAutomato,IncProc(I18n(STR0026,{nI, nTotalMark})), ) // "Processando #1 de #2..."
			nRecTmp := aMarcados[nI][1]
			(cAlsTmp)->(dbGoTo(nRecTmp))

			If cTpSaida == "3" //"Salvar em disco"
				cPasta := cPath + AllTrim((cAlsTmp)->E1_CLIENTE) + "_" +;
				                  AllTrim((cAlsTmp)->E1_LOJA) + "_" +;
				                  AllTrim((cAlsTmp)->U5_CODCONT) + "_" +;
				                  AllTrim((cAlsTmp)->CTO_MOEDA) + "\"
				MakeDir(cPasta,,.F.)
			EndIf

			aFaturas := J263Fatura(cNameTbTmp, nRecTmp, lCarta, lRelatorio, cCodSocio)

			// Veririca se existe ponto de entrada para o relatório
			If lJPAD036
				&cFunc.(oTempTable, cTpSaida, cPasta, cCodSocio)
			Else
				JURAPAD036(oTempTable, cTpSaida, cPasta, cCodSocio, lAutomato, cNomeArq)
			EndIf

			For nRpt := 1 To Len(aFaturas)
				cEscrit   := aFaturas[nRpt][1]
				cFatura   := aFaturas[nRpt][2]
				cArquivo  := AllTrim(aFaturas[nRpt][3])
				If !lAutomato
					cDestPath := JurImgFat(cEscrit, cFatura, .T., .F., @cMsgRet)

					If cTpSaida == "3" 
						JurCopyS2T(cArquivo, cDestPath, .F., .T., @cMsgRet, cPasta)
					Else
						JurOpenFile(cArquivo, cDestPath, cTpSaida, .F., @cMsgRet)
					EndIf
				EndIf
			Next nRpt

			If !lAutomato
				(cAlsTmp)->OK := Iif(oMBrowse:IsInvert(), oMBrowse:Mark(), " ") // Limpa a marca
			EndIf
			(cAlsTmp)->( DbSkip() )

		Next nI
		If !lAutomato
			oMBrowse:GoTo(nRecTmpAt, .T.)
		EndIf
	EndIf

Return lOk

//-------------------------------------------------------------------
/*/{Protheus.doc} J263Fatura
Query para retornar as faturas da cobrança

@param  cNameTbTmp , Nome da Tabela Temporária
@param  nRecTmp    , Recno do registro posicionado da tabela temporária
@param  lCarta     , Se é para gerar o relatório de carta de cobrança
@param  lRelatorio , Se é para gerar os relatórios da fatura
@param  cCodSocio  , Código do participante filtrado
@return aFaturas   , Informações sobre as faturas do cliente

@author  Bruno Ritter
@since   06/11/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J263Fatura(cNameTbTmp, nRecTmp, lCarta, lRelatorio, cCodSocio)
	Local cQuery     := ""
	Local nTamFil    := TamSX3("NXA_FILIAL")[1]
	Local nTamEsc    := TamSX3("NXA_CESCR")[1]
	Local cTamFilial := cValToChar(nTamFil)
	Local cIniEscr   := cValToChar(nTamFil+2)
	Local cTamEscr   := cValToChar(nTamEsc)
	Local cIniFatur  := cValToChar(nTamFil+1+nTamEsc+2)
	Local cTamFatur  := cValToChar(TamSX3("NXA_COD")[1])
	Local aFaturas   := {}
	Local lExistOHT  := AliasInDic("OHT")
	Local lIntPFS    := lExistOHT .And. SuperGetMV("MV_JURXFIN",, .F.) // Integração SIGAPFS x SIGAFIN
	Local lNXMTpArq  := NXM->(ColumnPos("NXM_CTPARQ")) > 0 
	Local cStrBol    := IIF( !lNXMTpArq, Upper(STR0027), "4") // "boleto"
	Local cStrCarta  := IIF( !lNXMTpArq, Upper(STR0028), "1")  // "carta"

	If lCarta .Or. lRelatorio
		cQuery := " SELECT DISTINCT NXA.NXA_CESCR, NXA.NXA_COD, NXM.NXM_NOMARQ "
		cQuery +=   " FROM " + cNameTbTmp + " TABTMP "

		// Dados do Título
		cQuery +=  " INNER JOIN " + RetSqlName('SE1') + " SE1 "
		cQuery +=     " ON SE1.E1_FILIAL = '" + xFilial("SE1") + "' "
		cQuery +=    " AND SE1.E1_CLIENTE = TABTMP.E1_CLIENTE "
		cQuery +=    " AND SE1.E1_LOJA = TABTMP.E1_LOJA "
		cQuery +=    " AND SE1.E1_SALDO > 0 "
		cQuery +=    " AND SE1.E1_VENCTO < '" + DtoS(Date()) + "' "
		cQuery +=    " AND SE1.D_E_L_E_T_ = ' ' "
		// Dados da Fatura
		If lIntPFS
			cQuery += " INNER JOIN " + RetSqlName("OHT") + " OHT"
			cQuery +=    " ON OHT.OHT_FILFAT = '" + xFilial("NXA") + "'"
			cQuery +=   " AND OHT.OHT_PREFIX = SE1.E1_PREFIXO"
			cQuery +=   " AND OHT.OHT_TITNUM = SE1.E1_NUM"
			cQuery +=   " AND OHT.OHT_TITPAR = SE1.E1_PARCELA"
			cQuery +=   " AND OHT.OHT_TITTPO = SE1.E1_TIPO"
			cQuery +=   " AND OHT.OHT_FILTIT = SE1.E1_FILIAL"
			cQuery +=   " AND OHT.D_E_L_E_T_ = ' '"
			cQuery += " INNER JOIN " + RetSqlName("NXA") + " NXA "
			cQuery +=   "  ON NXA.NXA_FILIAL = OHT.OHT_FILFAT "
			cQuery +=   " AND NXA.NXA_CESCR = OHT.OHT_FTESCR "
			cQuery +=   " AND NXA.NXA_COD = OHT.OHT_CFATUR "
		Else
			cQuery +=  " INNER JOIN " + RetSqlName("NXA") + " NXA "
			cQuery +=     " ON NXA.NXA_FILIAL = SUBSTRING(E1_JURFAT, 1, " + cTamFilial + ") "
			cQuery +=    " AND NXA.NXA_CESCR = SUBSTRING(E1_JURFAT, " + cIniEscr + ", " + cTamEscr + ") "
			cQuery +=    " AND NXA.NXA_COD = SUBSTRING(E1_JURFAT, " + cIniFatur + ", " + cTamFatur + ") "
		EndIf
		cQuery +=        " AND NXA.NXA_CCONT  = TABTMP.U5_CODCONT "
		cQuery +=        " AND NXA.NXA_CMOEDA = TABTMP.CTO_MOEDA "
		cQuery +=        " AND NXA.NXA_SITUAC = '1' "
		cQuery +=        " AND NXA.D_E_L_E_T_ = ' ' "

		If !Empty(cCodSocio)
			cQuery +=    " AND NXA.NXA_CPART = '" + cCodSocio + "' "
		EndIf

		// Documentos Relacionados
		cQuery +=      " INNER JOIN " + RetSqlName("NXM") + " NXM "
		cQuery +=         " ON NXM.NXM_FILIAL = NXA.NXA_FILIAL "
		cQuery +=        " AND NXM.NXM_CESCR = NXA.NXA_CESCR "
		cQuery +=        " AND NXM.NXM_CFATUR = NXA.NXA_COD "
		If !lNXMTpArq
			If lCarta .And. lRelatorio
				cQuery +=    " AND NXM.NXM_NOMARQ NOT LIKE '" + cStrBol + "%' "
			ElseIf lCarta
				cQuery +=    " AND NXM.NXM_NOMARQ LIKE '" + cStrCarta + "%' "
			ElseIf lRelatorio
				cQuery +=    " AND NXM.NXM_NOMARQ NOT LIKE '" + cStrBol + "%' "
				cQuery +=    " AND NXM.NXM_NOMARQ NOT LIKE '" + cStrCarta + "%' "
			EndIf
		Else
			If lCarta .And. lRelatorio
				cQuery +=    " AND NXM.NXM_CTPARQ <> '" + cStrBol + "' "
			ElseIf lCarta
				cQuery +=    " AND NXM.NXM_CTPARQ = '" + cStrCarta + "' "
			ElseIf lRelatorio
				cQuery +=    " AND NXM.NXM_CTPARQ <> '" + cStrBol + "' "
				cQuery +=    " AND NXM.NXM_CTPARQ <> '" + cStrCarta + "' "
			EndIf	
		EndIf
		cQuery +=        " AND NXM.D_E_L_E_T_ = ' ' "

		cQuery += " WHERE TABTMP.R_E_C_N_O_ = " + cValToChar(nRecTmp) + " "

		aFaturas := JurSQL(cQuery, {"NXA_CESCR", "NXA_COD", "NXM_NOMARQ"})
	EndIf

Return aFaturas
