#INCLUDE 'JURA205.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'FWMBROWSE.CH'

Static _lSX1Jr205 := .F.

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA205
Emissão de Documentos Fiscais

@author Ernani Forastieri
@since 15/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA205()
	Local lMark        := .T.

	Local oFWLayer     := Nil
	Local oPanelUp     := Nil
	Local oPanelDown   := Nil
	Local aCoors       := FwGetDialogSize( oMainWnd )
	
	Local oTmpTable    := Nil
	Local aFldsFilt    := {}
	Local aOrder       := {}
	Local aFields      := {}
	Local cTpCotac     := SuperGetMV("MV_JNFSCOT",, "1") // Define qual cotação será utilizada na emissão da NFS
	Local lIntFinanc   := SuperGetMV("MV_JURXFIN",, .F.) //Habilita a integracao entre os modulos SIGAFIN - Financeiro e SIGAPFS - Juridico
	Local lExistOHI    := FWAliasInDic("OHI")
	Local lEmisFat     := SuperGetMV("MV_JEMINF",, .T.)
	Local lCotMensal   := SuperGetMv("MV_JTPCONV",, "1") == "2"
	Local cMoedaNac    := GetMV("MV_JMOENAC",, "01") // Moeda Nacional
	Local lVldPagas    := cTpCotac == "3" .And. lIntFinanc .And. lExistOHI
	Local lIsBlind     := IsBlind()
	Local cPerg        := "JURA205"
	Local cCpoCot      := ""

	Private oDlg205    := Nil
	Private oBrw205    := Nil
	Private oBrw205Cot := Nil
	Private oRelation  := Nil
	Private cAlsCot    := ""
	Private cRealName  := ""

	_lSX1Jr205 := FindFunction("JurvldSx1") .And. JurVldSX1(cperg)
	
	Pergunte(cPerg, .F.)
	If _lSX1Jr205 .AND. !lIsBlind
		SetKey(VK_F12,{|| Pergunte(cPerg, .T.)})
	EndIf

	DEFINE MSDIALOG oDlg205 TITLE STR0001 From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] STYLE nOR( WS_VISIBLE, WS_POPUP ) Pixel //"Geração de Documento Fiscal"

		// Tabela temporária de cotação
		J205TabCot(/*codfat*/, /*cescr*/, @oTmpTable, @aFldsFilt, @aOrder, @aFields, cTpCotac, lIntFinanc, lEmisFat, lCotMensal, lExistOHI)

		cAlsCot    := oTmpTable:GetAlias()
		cRealName  := oTmpTable:GetRealName()

		aEval((cAlsCot)->(DbStruct()), {|c| cCpoCot += "," + AllTrim(c[1])})
		cCpoCot := SubStr(cCpoCot, 2)

		oFWLayer := FWLayer():New()
		oFWLayer:Init( oDlg205, .F., .T. )

		// Painel Superior
		oFWLayer:AddLine( 'UP', 70, .F. )
		oFWLayer:AddCollumn( 'FATURAS', 100, .T., 'UP' )

		oPanelUp := oFWLayer:GetColPanel( 'FATURAS', 'UP' )
		
		oBrw205 := FWMarkBrowse():New()
		oBrw205:SetOwner( oPanelUp )
		oBrw205:SetDescription( STR0031 ) // "Faturas"
		oBrw205:SetAlias( 'NXA' )
		oBrw205:SetMenuDef( 'JURA205' )
		oBrw205:SetFilterDefault( "@NXA_NFGER = '2' AND NXA_TITGER = '1' AND NXA_TIPO = 'FT' AND NXA_SITUAC = '1' " )
		oBrw205:SetFieldMark( 'NXA_OK' )
		oBrw205:SetAllMark( {|| JA205All(oBrw205, @lMark, lVldPagas, .F., cTpCotac, lIntFinanc, lEmisFat, lCotMensal, lExistOHI, cMoedaNac, cCpoCot)} )
		oBrw205:SetCustomMarkRec( {|| JA205SetMk(oBrw205, lVldPagas, .F., cTpCotac, lIntFinanc, lEmisFat, lCotMensal, lExistOHI, cMoedaNac, cCpoCot)} )
		oBrw205:SetProfileID( '1' )
		oBrw205:ForceQuitButton(.T.)
		oBrw205:oBrowse:SetBeforeClose( {|| oBrw205:oBrowse:VerifyLayout(), oBrw205Cot:VerifyLayout()} )
		JurSetLeg( oBrw205, 'NXA' )
		JurSetBSize( oBrw205 )
		oBrw205:Activate()
		
		// Painel Inferior
		oFWLayer:addLine( 'DOWN', 30, .F. )
		oFWLayer:AddCollumn( 'COTACAO', 100, .T., 'DOWN' )
		oPanelDown := oFWLayer:GetColPanel( 'COTACAO', 'DOWN' )

		oBrw205Cot := FWMBrowse():New()
		oBrw205Cot:SetOwner( oPanelDown )
		oBrw205Cot:SetProfileID( '2' )
		oBrw205Cot:SetDescription( STR0032 ) // "Cotação"
		oBrw205Cot:SetAlias( cAlsCot )
		oBrw205Cot:SetTemporary( .T. )
		oBrw205Cot:SetFields( aFields )
		oBrw205Cot:SetMenuDef( '' )
		oBrw205Cot:AddButton( STR0033, "J205UpdCot()", , 4 ) // "Alterar"
		oBrw205Cot:DisableReport()
		oBrw205Cot:DisableDetail()

		oBrw205Cot:Activate()

		oRelation := FWBrwRelation():New()
		oRelation:AddRelation( oBrw205, oBrw205Cot, { { 'NXF_FILIAL', "xFilial( 'NXF' )" }, { 'NXF_CFATUR', 'NXA_COD' }, { 'NXF_CESCR', 'NXA_CESCR' }, { 'NXF_CMOEDA', 'NXA_CMOEDA' } } )
		oRelation:Activate()

	ACTIVATE MSDIALOG oDlg205 CENTER

	JurFreeArr(@aFldsFilt)
	JurFreeArr(@aOrder)
	JurFreeArr(@aFields)
	oTmpTable:Delete()

	If _lSX1Jr205 .AND. !lIsBlind
		SetKey(VK_F12, NIL)
	EndIf

	_lSX1Jr205 := .F.

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J205QryCot
Monta query da tabela temporária do browse de cotação

@param   cCodFatur , Código da Fatura
@param   cEscr     , Código do Escritório
@param   cTpCotac  , Tipo de Cotação
@param   lIntFinanc, Integração Financeiro
@param   lEmisFat  , Emissão pela Data da Fatura
@param   lCotMensal, Cotação Mensal
@param   lExistOHI , Existe OHI
@param   cMoedaNac , Moeda Nacional
@param   cTabTemp  , Nome da Tabela Temporária

@return  cQueryCot , Query de cotação

@author  Jonatas Martins / Jorge Martins
@since   07/08/2019
/*/
//-------------------------------------------------------------------
Static Function J205QryCot(cCodFatur, cEscr, cTpCotac, lIntFinanc, lEmisFat, lCotMensal, lExistOHI, cTabTemp)
Local cCpoCotac   := ""
Local cQueryCot   := ""
Local cQueryTmp   := ""

Default cCodFatur := ""
Default cEscr     := ""
Default cTabTemp  := ""

	cCpoCotac := Iif(lCotMensal, "NXQ.NXQ_COTAC", "CTP.CTP_TAXA")

	If cTpCotac == "1" .Or. (cTpCotac == "3" .And. (!lIntFinanc .Or. !lExistOHI)) // Cotação da emissão da fatura
		cQueryCot := "SELECT NXF.NXF_FILIAL, NXF.NXF_CFATUR, NXF.NXF_CESCR, NXF.NXF_CMOEDA, CTO.CTO_DESC NXF_DMOEDA, NXF.NXF_COTAC1 COTNOVA, NXF.NXF_COTAC1 COTORIG "
		cQueryCot +=   "FROM " + RetSqlName("NXF") + " NXF "
		cQueryCot +=  "INNER JOIN " + RetSqlName("CTO") + " CTO "
		cQueryCot +=     "ON CTO.CTO_FILIAL = '" + xFilial("CTO") + "' "
		cQueryCot +=    "AND CTO.CTO_MOEDA  = NXF.NXF_CMOEDA "
		cQueryCot +=    "AND CTO.D_E_L_E_T_ = ' ' "
		cQueryCot +=  "INNER JOIN " + RetSqlName("NXA") + " NXA "
		cQueryCot +=     "ON NXA.NXA_FILIAL = '" + xFilial("NXA") + "' "
		cQueryCot +=    "AND NXA.NXA_CESCR = NXF.NXF_CESCR "
		cQueryCot +=    "AND NXA.NXA_COD = NXF.NXF_CFATUR "
		cQueryCot +=    "AND NXA.NXA_NFGER = '2' "
		cQueryCot +=    "AND NXA.NXA_TITGER = '1' "
		cQueryCot +=    "AND NXA.NXA_TIPO = 'FT' "
		cQueryCot +=    "AND NXA.NXA_SITUAC = '1' "
		cQueryCot +=    "AND NXA.D_E_L_E_T_ = ' ' "
		cQueryCot +=  "WHERE NXF.NXF_FILIAL = '" + xFilial("NXF") + "' "
		cQueryCot +=    "AND NXF.D_E_L_E_T_ = ' ' "
	
	ElseIf cTpCotac == "2" // Cotação da data de emissão da NFSe
		cQueryCot := "SELECT NXA_FILIAL NXF_FILIAL, NXA_COD NXF_CFATUR, NXA_CESCR NXF_CESCR , NXA_CMOEDA NXF_CMOEDA, CTO.CTO_DESC NXF_DMOEDA, "
		cQueryCot +=  cCpoCotac + " COTNOVA, NXF.NXF_COTAC1 COTORIG "
		cQueryCot +=   "FROM " + RetSqlName("NXA") + " NXA "
		cQueryCot +=  "INNER JOIN " + RetSqlName("NXF") + " NXF "
		cQueryCot +=     "ON NXF.NXF_FILIAL = '" + xFilial("NXF") + "' "
		cQueryCot +=    "AND NXF.NXF_CESCR  = NXA.NXA_CESCR "
		cQueryCot +=    "AND NXF.NXF_CFATUR = NXA.NXA_COD "
		cQueryCot +=    "AND NXF.NXF_CMOEDA = NXA.NXA_CMOEDA "
		cQueryCot +=    "AND NXF.D_E_L_E_T_ = ' ' "
		cQueryCot +=  "INNER JOIN " + RetSqlName("CTO") + " CTO "
		cQueryCot +=     "ON CTO.CTO_FILIAL = '" + xFilial("CTO") + "' "
		cQueryCot +=    "AND CTO.CTO_MOEDA  = NXA.NXA_CMOEDA "
		cQueryCot +=    "AND CTO.D_E_L_E_T_ = ' ' "
		If lCotMensal
			cQueryCot += "INNER JOIN " + RetSqlName("NXQ") + " NXQ "
			cQueryCot +=    "ON NXQ.NXQ_FILIAL = '" + xFilial("NXQ") + "' "
			If lEmisFat
				cQueryCot +=   "AND NXQ.NXQ_ANOMES = SUBSTRING(NXA.NXA_DTEMI, 1, 6) "
			Else
				cQueryCot +=   "AND NXQ.NXQ_ANOMES = '" + AnoMes(Date()) + "' "
			EndIf
			cQueryCot +=   "AND NXQ.NXQ_CMOEDA = NXA.NXA_CMOEDA "
			cQueryCot +=   "AND NXQ.D_E_L_E_T_ = ' ' "
		Else
			cQueryCot += "INNER JOIN " + RetSqlName("CTP") + " CTP "
			cQueryCot +=    "ON CTP.CTP_FILIAL  = '" + xFilial("CTP") + "' "
			If lEmisFat
				cQueryCot +=   "AND CTP.CTP_DATA = NXA.NXA_DTEMI "
			Else
				cQueryCot +=   "AND CTP.CTP_DATA = '" + DtoS(Date()) + "' "
			EndIf
			cQueryCot +=   "AND CTP.CTP_MOEDA = NXA.NXA_CMOEDA "
			cQueryCot +=   "AND CTP.CTP_BLOQ = '2' "
			cQueryCot +=   "AND CTP.D_E_L_E_T_ = ' ' "
		EndIf
		cQueryCot +=  "WHERE NXA.NXA_FILIAL = '" + xFilial("NXA") + "' "
		cQueryCot +=    "AND NXA.NXA_TIPO = 'FT' "
		cQueryCot +=    "AND NXA.NXA_NFGER = '2' "
		cQueryCot +=    "AND NXA.NXA_TITGER = '1' "
		cQueryCot +=    "AND NXA.NXA_SITUAC = '1' "
		cQueryCot +=    "AND NXA.D_E_L_E_T_ = ' ' "
	
	ElseIf cTpCotac == "3" .And. lIntFinanc .And. lExistOHI // Cotação do recebimento da fatura
		cQueryCot := "SELECT OHI.OHI_FILIAL NXF_FILIAL, OHI.OHI_CFATUR NXF_CFATUR, "
		cQueryCot +=        "OHI.OHI_CMOEDA NXF_CMOEDA, CTO.CTO_DESC NXF_DMOEDA, OHI.OHI_CESCR NXF_CESCR, "
		cQueryCot +=        "CASE WHEN OHI.OHI_COTAC = 0 THEN 1 ELSE OHI.OHI_COTAC END COTNOVA, "
		cQueryCot +=        "CASE WHEN OHI.OHI_COTAC = 0 THEN 1 ELSE OHI.OHI_COTAC END COTORIG "
		cQueryCot +=   "FROM " + RetSqlName("OHI") + " OHI "
		cQueryCot +=  "INNER JOIN " + RetSqlName("CTO") + " CTO "
		cQueryCot +=     "ON CTO.CTO_FILIAL = '" + xFilial("CTO") + "' "
		cQueryCot +=    "AND CTO.CTO_MOEDA = OHI.OHI_CMOEDA "
		cQueryCot +=    "AND CTO.D_E_L_E_T_ = ' ' "
		cQueryCot +=  "WHERE OHI.OHI_FILIAL = '" + xFilial("OHI") + "' "
		cQueryCot +=    "AND OHI.OHI_ITEM = (SELECT MAX(B.OHI_ITEM) "
        cQueryCot +=                          "FROM " + RetSqlName("OHI") + " B "
		cQueryCot +=                         "WHERE B.OHI_FILIAL = OHI.OHI_FILIAL "
		cQueryCot +=                           "AND B.OHI_CFATUR = OHI.OHI_CFATUR "
		cQueryCot +=                           "AND B.OHI_CESCR  = OHI.OHI_CESCR "
		cQueryCot +=                           "AND B.D_E_L_E_T_ = ' ' "
		cQueryCot +=                         "GROUP BY B.OHI_FILIAL, B.OHI_CFATUR, B.OHI_CESCR) "
		cQueryCot +=    "AND OHI.D_E_L_E_T_ = ' ' "
	EndIf

	If !Empty(cCodFatur) .AND. !Empty(cEscr)
		cQueryCot := "SELECT * FROM ( " + cQueryCot + ") X "
		cQueryCot +=  "WHERE NXF_CFATUR = '" + cCodFatur + "' "
		cQueryCot +=    "AND NXF_CESCR = '" + cEscr + "' "
	EndIf

	If !Empty(cTabTemp)
		cQueryTmp := "SELECT Y.* "
		cQueryTmp +=   "FROM (" + cQueryCot + ") Y "
		cQueryTmp +=  "WHERE NOT EXISTS (SELECT NXF_CFATUR " 
		cQueryTmp +=                      "FROM " + cTabTemp + " Z "
		cQueryTmp +=                     "WHERE Z.NXF_FILIAL = Y.NXF_FILIAL "
		cQueryTmp +=                       "AND Z.NXF_CFATUR = Y.NXF_CFATUR "
		cQueryTmp +=                       "AND Z.NXF_CESCR = Y.NXF_CESCR "
		cQueryTmp +=                       "AND Z.NXF_CMOEDA = Y.NXF_CMOEDA)"
		cQueryCot := cQueryTmp
	EndIf

Return (cQueryCot)

//-------------------------------------------------------------------
/*/{Protheus.doc} J205UpdCot
Altera cotação

@author  Jonatas Martins
@since   07/08/2019
/*/
//-------------------------------------------------------------------
Function J205UpdCot(nNovaCot, cAliasCota, lAutomato)
Local cMoedaNac    := GetMV("MV_JMOENAC",, "01") // Moeda Nacional
Local cMoedaFat    := NXA->NXA_CMOEDA

Default nNovaCot   := 0
Default cAliasCota := cAlsCot
Default lAutomato  := .F.
	
	If NXA->(ColumnPos("NXA_NFCOTA")) == 0
		JurMsgErro(STR0034, , STR0035) // "Operação não permitida pois o campo 'NXA_NFCOTA' não foi encontrado!" - "Atualize o ambiente!"
	Else
		If cMoedaNac == cMoedaFat
			JurMsgErro(STR0036, , STR0037) // "Operação não permitida!" - "Somente a cotação de faturas com moeda estrangeira pode ser alterada."
		Else
			If lAutomato  .OR. J205DlgCot(@nNovaCot) // Exibe tela para informar a cotação
				RecLock(cAliasCota, .F.)
				(cAliasCota)->COTNOVA := nNovaCot
				(cAliasCota)->(MsUnlock())
				If !lAutomato
					oBrw205Cot:Refresh()
				EndIf
			EndIf
		EndIf
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J205CotDlg
Exibe janela para informar o valor da cotação

@author  Jonatas Martins
@since   07/08/2019
/*/
//-------------------------------------------------------------------
Static Function J205DlgCot(cNovaCot)
	Local oLayer    := FWLayer():new()
	Local oMainColl := Nil
	Local oDlgCot   := Nil
	Local oCotac    := Nil
	Local lCotac    := .F.

	oDlgCot := FWDialogModal():New()
	oDlgCot:SetFreeArea(100, 50)
	oDlgCot:SetEscClose(.F.)    // Não permite fechar a tela com o ESC
	oDlgCot:SetCloseButton(.F.) // Não permite fechar a tela com o "X"
	oDlgCot:SetBackground(.T.)  // Escurece o fundo da janela
	oDlgCot:SetTitle(STR0038)   // "Valor da Cotação"
	oDlgCot:CreateDialog()
	oDlgCot:addOkButton({|| cNovaCot := oCotac:GetValue(), lCotac := Positivo(cNovaCot), IIF(lCotac, oDlgCot:oOwner:End(), .F.)})
	oDlgCot:addCloseButton({|| cNovaCot := 0, lCotac := .F., oDlgCot:oOwner:End()})

	oLayer:init(oDlgCot:GetPanelMain(), .F.) // Inicializa o FWLayer com a janela que ele pertencera e se sera exibido o botao de fechar
	oLayer:AddCollumn("MainColl", 100, .F.)  // Cria as colunas do Layer
	oMainColl := oLayer:GetColPanel("MainColl")
	oCotac    := TJurPnlCampo():New(015, 035, 060, 022, oMainColl, STR0032, ("NXA_NFCOTA"), {|| }, {|| },,,,) // "Cotação"
	
	oDlgCot:Activate()

Return (lCotac)

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura
[n,1] Nome a aparecer no cabecalho
[n,2] Nome da Rotina associada
[n,3] Reservado
[n,4] Tipo de Transação a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Alteração sem inclusão de registros
7 - Cópia
8 - Imprimir
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author Ernani Forastieri
@since 15/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0002, 'VIEWDEF.JURA204'     , 0, 2, 0, NIL } ) //"Visualizar"
aAdd( aRotina, { STR0003, 'JA205PROC( oBrw205 )', 0, 6, 0, NIL } ) //"Gerar"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} JA205PROC
Geração de Documentos Fiscais

@author Ernani Forastieri
@since 15/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA205PROC( oBrw205 )

If ApMsgYesNo( STR0004 ) //"Confirma a geração dos documentos fiscais ?"
	Processa( { |lEnd| JA205GERA( oBrw205, @lEnd ) }, STR0010, STR0005, .T. ) //"Aguarde"###"Gerando Doc. Fiscal..."
EndIf

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} JA205GERA
Rotina para gerar as notas fiscais da fatura

@param oBrw205  , Browser de Faturas (NXA)
@param lEnd     , Fim do processa
@param lAutomato, Se está sendo executado pela automação
@param cTestCase, Caso de teste para buscar o GetParAuto

@author Luciano Pereira dos Santos
@since 27/11/17
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA205GERA(oBrw205, lEnd, lAutomato, cTestCase)
Local lInvert     := Iif(Type("oBrw205") == "U", .F., oBrw205:IsInvert())
Local cMarca      := Iif(Type("oBrw205") == "U", "", oBrw205:Mark())
Local cDesMark    := Iif(lInvert, cMarca, Space(TamSX3("NXA_OK")[1]))
Local aArea       := GetArea()
Local aAreaNS7    := NS7->(GetArea())
Local cQuery      := ""
Local cQryRes     := GetNextAlias()
Local cFilAtu     := cFilAnt
Local dDataAnt    := dDataBase
Local lOk         := .T.
Local cEscr       := ""
Local lFirst      := .T. //Controle de numeração por filial
Local lExit       := .F.
Local cMsgLog     := ""
Local cSerieNF    := ""
Local nQtd        := 0
Local nCotacao    := 1
Local nCotOrig    := 1
Local lMostraCtb  := .F.
Local lAglutCtb	  := .F.
Local lCtbOnLine  := .F.
Local cPerg       := "JURA205"
Local cTabTmp     := ""
Local lCpoGrsHon  := NXA->(ColumnPos("NXA_VGROSH")) > 0 .And. NXA->(ColumnPos("NXA_GRSHMN")) > 0

Default lEnd      := .F.
Default lAutomato := .F.
Default cTestCase := "JURA205TestCase"

If lAutomato .And. FindFunction("GetParAuto")
	aRetAuto := GetParAuto(cTestCase)
	cMarca   := aRetAuto[1]
	nCotacao := IIF(Len(aRetAuto) >= 2 .AND. !Empty(aRetAuto[2]), aRetAuto[2], 1)
	nCotOrig := IIF(Len(aRetAuto) >= 3 .AND. !Empty(aRetAuto[3]), aRetAuto[3], 1)
	cTabTmp  := IIF(Len(aRetAuto) >= 4, aRetAuto[4], "")

	If _lSX1Jr205 := FindFunction("JurvldSx1") .And. JurVldSx1(cperg)
		Pergunte(cPerg, .F.)
	EndIf

Else
	cTabTmp := cRealName
EndIf

If _lSX1Jr205
	lMostraCtb  := MV_PAR01==1
	lAglutCtb	:= MV_PAR02==1
	lCtbOnLine  := MV_PAR03==1
EndIf

cQuery := "SELECT NXA.R_E_C_N_O_ NXARECNO, NXA.NXA_CESCR, NXA.NXA_COD"
If !lAutomato .Or. !Empty(cTabTmp)
	cQuery += ", COALESCE(COTNOVA, 1) COTACAO, COALESCE(COTORIG, 1) COTORIG "
EndIf

cQuery +=  " FROM " + RetSqlName("NXA") + " NXA "
If !lAutomato .Or. !Empty(cTabTmp)
	cQuery +=  " LEFT JOIN " + cTabTmp + " COTAC " // Tabela temporária do browse de cotação
	cQuery +=   "  ON COTAC.NXF_FILIAL = '" + xFilial("NXF") + "' "
	cQuery +=   " AND COTAC.NXF_CESCR = NXA.NXA_CESCR "
	cQuery +=   " AND COTAC.NXF_CFATUR = NXA.NXA_COD "
	cQuery +=   " AND COTAC.NXF_CMOEDA = NXA.NXA_CMOEDA "
	cQuery +=   " AND COTAC.D_E_L_E_T_ = ' ' "
EndIf
cQuery += " WHERE NXA.NXA_FILIAL = '" + xFilial("NXA") + "' "
cQuery +=   " AND NXA.NXA_NFGER = '2' "
cQuery +=   " AND NXA.NXA_TITGER = '1' "
cQuery +=   " AND NXA.NXA_TIPO = 'FT' "
cQuery +=   " AND NXA.NXA_OK = '" + cMarca + "' "
cQuery +=   " AND NXA.D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY NXA.NXA_CESCR, NXA.NXA_COD "
cQuery := ChangeQuery(cQuery)

DbUseArea(.T., 'TOPCONN', TcGenQry( ,, cQuery ), cQryRes, .T., .F. )

(cQryRes)->(dbEVal({|| nQtd++},, {|| !EOF()}))
(cQryRes)->(dbgotop())

If nQtd > 0

	ProcRegua(nQtd)

	NS7->(DbSetOrder(1))

	While !(cQryRes)->( EOF() )
		IncProc(STR0005 + " (" + (cQryRes)->NXA_CESCR + "|" + (cQryRes)->NXA_COD + ")")

		If cEscr != (cQryRes)->NXA_CESCR
			cEscr    := (cQryRes)->NXA_CESCR
			lFirst   := .T.
			lExit    := .F.
			cSerieNF := ""
		Else
			lFirst   := .F.
		EndIf

		If !lAutomato .Or. !Empty(cTabTmp)
			nCotacao := (cQryRes)->COTACAO
			nCotOrig := (cQryRes)->COTORIG
		EndIf

		If !lEnd
			If !lExit .And. NS7->( DbSeek(xFilial('NS7') + (cQryRes)->NXA_CESCR ) )
				cFilAnt  := NS7->NS7_CFILIA
				If !J205GERANF((cQryRes)->NXARECNO, lFirst, cDesMark, @lExit, ;
								@cSerieNF, nCotacao, nCotOrig, lMostraCtb,;
								lAglutCtb, lCtbOnLine, lCpoGrsHon)
					lOk := .F.
				EndIf
			EndIf
		Else
			cMsgLog := STR0009 + CRLF //"Não foi possivel gerar doc. fiscal para fatura "
			cMsgLog += STR0023 + (cQryRes)->NXA_CESCR + CRLF //"Escritório: "
			cMsgLog += STR0024 + (cQryRes)->NXA_COD + CRLF //"Fatura: "
			cMsgLog += STR0027 + CRLF // "A operação foi cancela."
			cMsgLog += (Replicate('-',90))+ CRLF
			AutoGRLog( cMsgLog )
			lOk  := .F.
			Exit
		EndIf
		(cQryRes)->(dbSkip())
	EndDo

	(cQryRes)->(dbCloseArea())

	cFilAnt   := cFilAtu
	dDataBase := dDataAnt

	If !lOk
		Iif(lAutomato, JurMsgErro(cMsgLog), MostraErro())
	Else
		ApMsgInfo(STR0028) //"Documentos fiscais gerados com sucesso."
	EndIf

Else
	ApMsgAlert(STR0029) //"Selecione uma fatura para gerar documento fiscal."
EndIf

RestArea( aAreaNS7 )
RestArea( aArea )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J205GERANF
Rotina para gerar a nota fiscal da fatura

@Param nNXARECNO  Recno da tabela de Faturas (NXA)
@Param lFirst     Indica a primeira execução para chamar o controle de numeração da nota fiscal. Padrão: .T.
@Param cDesMark   Controle para desmarcar o browser após a operação. Padrão: ""
@Param lExit      Controle para abortar a geração de notas por escritório. Passado por referencia (Execução em lote) . Padrão: .F.
@Param cSerieNF   Serie da nota fiscal. Passado por referencial. Padrão conteudo do parametro MV_JSERNF
@Param nCotacao   Nova Cotação para emissão da NFS
@Param nCotOrig   Cotação Original da Fatura
@Param lMostraCtb Se verdadeiro mostra lançamentos contábeis
@Param lAglutCtb  Se verdadeiro aglutina lançamentos contábeis
@Param lCtbOnLine Se verdadeiro executa contabilização on-line
@Param lCpoGrsHon Se verdadeiro existem os campos de Gross up de Honorários
@Param cLogFatNF  Variável para acumular mesagens de emissão da NF quando chamada após a geração da fatura

@Obs Se o paramentros da rotina não tiver filial, mesma configuração dos parametros serão usadas para todos os escritórios.

@author Ricardo Ferreira Neves
@since 27/11/17
@version 1.0
/*/
//-------------------------------------------------------------------
Function J205GERANF(nNXARECNO, lFirst, cDesMark, lExit, cSerieNF, nCotacao, nCotOrig, lMostraCtb, lAglutCtb, lCtbOnLine, lCpoGrsHon, cLogFatNF)
Local aArea         := GetArea()
Local aAreaSA1      := SA1->(GetArea())
Local aAreaCTP      := CTP->(GetArea())
Local aAreaPE       := {}
Local aDocOri       := {}
Local aSF2          := {}
Local aStruSF2      := SF2->( DbStruct() )
Local cCond         := AvKey(SuperGetMV("MV_JCONFAT",, ""), "E4_CODIGO")
Local cPrefixo      := AvKey(SuperGetMV("MV_JPREFAT",, "PFS"), "F2_PREFIXO")
Local cSerie        := AvKey(SuperGetMV("MV_JSERNF",, ""), "F2_SERIE")
Local lEmisFat      := SuperGetMV("MV_JEMINF",, .T. )
Local cPaisLoc      := SuperGetMV("MV_PAISLOC",, "BRA" )
Local cItem         := Replicate("0", TamSX3("D2_ITEM")[1])
Local aSD2          := {}
Local aAux          := {}
Local cNumNfs       := ""
Local lRet          := .T.
Local nI            := 0
Local cSD2          := ""
Local bSD2          := {||}
Local nValHon       := 0
Local nValDes       := 0
Local nValIss       := 0
Local cMsg          := ""
Local cMsgLog       := ""
Local cTpDtEmiss    := SuperGetMV("MV_HORARMT",, "2") // 1=Horário/Data do SmartClient; 2=Horário/Data do servidor; 3=Fuso horário/Data da filial corrente
Local cMoedaFat     := ""
Local cMoedaNac     := GetMV("MV_JMOENAC", , "01") // Moeda Nacional
Local cTpCotac      := SuperGetMV("MV_JNFSCOT", , "1") // Define qual cotação será utilizada na emissão da NFS
Local aValores      := {}
Local lConverte     := .F.
Local lIntFinanc    := SuperGetMV("MV_JURXFIN", , .F.) // Habilita a integracao entre os modulos SIGAFIN - Financeiro e SIGAPFS - Juridico
Local lExistOHI     := FWAliasInDic("OHI")
Local cTpNrFfs      := SuperGetMV("MV_TPNRNFS", .F., "1") // Define o tipo de controle da numeracao dos documentos de saida ( 1-SX5 | 2-SXE/SXF | 3-SD9 )
Local aDadosPE      := {}
Local lEndPSer      := NXA->(ColumnPos("NXA_ESTPS")) > 0
Local lNfSubst      := NXA->(ColumnPos("NXA_NFSUBS")) > 0
Local aDadosEmp     := FWSM0Util():GetSM0Data(cEmpAnt, cFilAnt, {"M0_ESTENT"})
Local lApPisCof     := OHP->(ColumnPos("OHP_TES")) > 0 //Funcionalidade de Apuração de Pis/Cofins Ativa

Default cDesMark    := ""
Default lFirst      := .T.
Default lExit       := .F.
Default cSerieNF    := ""
Default nCotacao    := 1
Default nCotOrig    := 1
default lMostraCtb  := .F. 
Default	lAglutCtb 	:= .F. 
Default lCtbOnLine  := .F.
Default lCpoGrsHon  := NXA->(ColumnPos("NXA_VGROSH")) > 0 .And. NXA->(ColumnPos("NXA_GRSHMN")) > 0
Default cLogFatNF   := ""

If lFirst
	If (!Empty(cSerie) .And. Len(FWGetSX5("01", cSerie)) > 0) .Or. (!FWIsInCallStack("JA203HFatu") .And. Sx5NumNota(@cSerie, cTpNrFfs)) //Valida a serie do parâmetro ou solicita apresenta tela para seleção
		cSerieNF := cSerie 
	Else
		cMsg  := CRLF + I18N(STR0016, {"MV_JSERNF"}) //"Selecione a série para gerar o documento fiscal." ##"Verifique a configuração do parametro '#1'."
		lRet  := .F.
		lExit := .T. //Já que a serie não é valida, vai para o próximo escritório (filial)
	EndIf
Else
	cSerie := cSerieNF //Atualiza a serie para as faturas do mesmo escritório (filial)
EndIf

If lRet
	Begin Transaction //IMPORTANTE - Não colocar o Begin antes do SX5NumNota, gera erro de DBRUnlock

		// Geracao do documento fiscal
		NXA->(DbGoTo(nNXARECNO))
		If lRet .And. !(SA1->(DbSeek(xFilial("SA1") + NXA->NXA_CLIPG + NXA->NXA_LOJPG))) //Valida o cliente existe e nao esta bloqueado.
			lRet := .F.
			cMsg := I18N(STR0020, {NXA->NXA_CLIPG + "|" + NXA->NXA_LOJPG}) //O cliente '#1' não é válido para a emissão.
		EndIf
	
		// Determina e verifica a data da emissao
		If lEmisFat // Pela data da Fatura
			PutMV("MV_HORARMT", "1") // Considera a dDataBase na gravação do campo F2_EMISSAO
			dDataBase := NXA->NXA_DTEMI
		EndIf
	
		If lRet .And. dDataBase < JA205UltNF( cSerie )
			cMsg := STR0006 + DToC(dDataBase) + CRLF + I18N(STR0016, {"MV_JEMINF"}) //"Já existem documentos fiscais emitidos com data superior a data da fatura " ##"Verifique a configuração do parametro '#1'."
			lRet := .F.
		EndIf

		If !Empty(NXA->NXA_CCDPGT)
			cCond := NXA->NXA_CCDPGT
			If lRet .And. !ExistCpo("SE4",cCond, 1, , .F.) //Valida se a condição de pagamento existe e não esta bloqueada.
				cMsg := I18N(STR0022, {cCond}) + CRLF + I18N(STR0016, {"MV_JCONFAT"}) //"A condição de pagamento '#1' não é válida para a emissão." ##"Verifique a configuração do parametro '#1'."
				lRet  := .F.
			EndIf
		EndIf

		If lRet .And. ExistBlock("J205VDoc")
			aAreaPE := GetArea()
			aDadosPE := ExecBlock("J205VDoc", .F., .F., {NXA->NXA_CESCR, NXA->NXA_COD})
			If ValType(aDadosPE) == "A" .And. Len(aDadosPE) == 2
				if ValType(aDadosPE[1]) == "L" .And. !aDadosPE[1]
					lRet := .F.
					cMsg := IIF(ValType(aDadosPE[2]) == "C", aDadosPE[2], "")
				EndIf
			EndIf
			RestArea(aAreaPE)
		EndIf
	
		If lRet //Para o bloco funcionar, o item de honorarios deve ser impreterivelmente o primeiro item (nY == 1)
			// ISS
			cSD2 := 'IIf(nY == 1, MaFisAlt("IT_BASEISS",aItemOri[nY,aScan(aStruSD2,{|x| AllTrim(x[1])=="D2_BASEISS"})],nY,.F.,,,,.F.), .T.),'
			cSD2 += 'IIf(nY == 1, MaFisAlt("IT_VALISS" ,aItemOri[nY,aScan(aStruSD2,{|x| AllTrim(x[1])=="D2_VALISS" })],nY,.F.,,,,.F.), .T.),'
			// PIS RETENÇÕES
			cSD2 += 'IIf(nY == 1, MaFisAlt("IT_BASEPIS" ,aItemOri[nY,aScan(aStruSD2,{|x| AllTrim(x[1])=="D2_BASEPIS" })],nY,.F.,,,,.F.), .T.),'
			cSD2 += 'IIf(nY == 1, MaFisAlt("IT_ALIQPIS" ,aItemOri[nY,aScan(aStruSD2,{|x| AllTrim(x[1])=="D2_ALQPIS" })],nY,.F.,,,,.F.), .T.),'
			cSD2 += 'IIf(nY == 1, MaFisAlt("IT_VALPIS" ,aItemOri[nY,aScan(aStruSD2,{|x| AllTrim(x[1])=="D2_VALPIS" })],nY,.F.,,,,.F.), .T.),'
			If lApPisCof
				//PIS APURAÇÃO
				cSD2 += 'IIf(nY == 1, MaFisAlt("IT_BASEPS2" ,aItemOri[nY,aScan(aStruSD2,{|x| AllTrim(x[1])=="D2_BASIMP6" })],nY,.F.,,,,.F.), .T.),'
				cSD2 += 'IIf(nY == 1, MaFisAlt("IT_ALIQPS2" ,aItemOri[nY,aScan(aStruSD2,{|x| AllTrim(x[1])=="D2_ALQIMP6" })],nY,.F.,,,,.F.), .T.),'
				cSD2 += 'IIf(nY == 1, MaFisAlt("IT_VALPS2" ,aItemOri[nY,aScan(aStruSD2,{|x| AllTrim(x[1])=="D2_VALIMP6" })],nY,.F.,,,,.F.), .T.),'	
			EndIf
			// COFINS
			cSD2 += 'IIf(nY == 1, MaFisAlt("IT_BASECOF" ,aItemOri[nY,aScan(aStruSD2,{|x| AllTrim(x[1])=="D2_BASECOF" })],nY,.F.,,,,.F.), .T.),'
			cSD2 += 'IIf(nY == 1, MaFisAlt("IT_ALIQCOF" ,aItemOri[nY,aScan(aStruSD2,{|x| AllTrim(x[1])=="D2_ALQCOF" })],nY,.F.,,,,.F.), .T.),'
			cSD2 += 'IIf(nY == 1, MaFisAlt("IT_VALCOF" ,aItemOri[nY,aScan(aStruSD2,{|x| AllTrim(x[1])=="D2_VALCOF" })],nY,.F.,,,,.F.), .T.),'
			If lApPisCof
				// COFINS APURAÇÃO
				cSD2 += 'IIf(nY == 1, MaFisAlt("IT_BASECF2" ,aItemOri[nY,aScan(aStruSD2,{|x| AllTrim(x[1])=="D2_BASIMP5" })],nY,.F.,,,,.F.), .T.),'
				cSD2 += 'IIf(nY == 1, MaFisAlt("IT_ALIQCF2" ,aItemOri[nY,aScan(aStruSD2,{|x| AllTrim(x[1])=="D2_ALQIMP5" })],nY,.F.,,,,.F.), .T.),'
				cSD2 += 'IIf(nY == 1, MaFisAlt("IT_VALCF2" ,aItemOri[nY,aScan(aStruSD2,{|x| AllTrim(x[1])=="D2_VALIMP5" })],nY,.F.,,,,.F.), .T.),'							
			EndIf
			// CSLL
			cSD2 += 'IIf(nY == 1, MaFisAlt("IT_BASECSL" ,aItemOri[nY,aScan(aStruSD2,{|x| AllTrim(x[1])=="D2_BASECSL" })],nY,.F.,,,,.F.), .T.),'
			cSD2 += 'IIf(nY == 1, MaFisAlt("IT_ALIQCSL" ,aItemOri[nY,aScan(aStruSD2,{|x| AllTrim(x[1])=="D2_ALQCSL" })],nY,.F.,,,,.F.), .T.),'
			cSD2 += 'IIf(nY == 1, MaFisAlt("IT_VALCSL" ,aItemOri[nY,aScan(aStruSD2,{|x| AllTrim(x[1])=="D2_VALCSL" })],nY,.F.,,,,.F.), .T.),'
			// IRRF
			cSD2 += 'IIf(nY == 1, MaFisAlt("IT_BASEIRR" ,aItemOri[nY,aScan(aStruSD2,{|x| AllTrim(x[1])=="D2_BASEIRR" })],nY,.F.,,,,.F.), .T.),'
			cSD2 += 'IIf(nY == 1, MaFisAlt("IT_ALIQIRR" ,aItemOri[nY,aScan(aStruSD2,{|x| AllTrim(x[1])=="D2_ALQIRRF" })],nY,.F.,,,,.F.), .T.),'
			cSD2 += 'IIf(nY == 1, MaFisAlt("IT_VALIRR" ,aItemOri[nY,aScan(aStruSD2,{|x| AllTrim(x[1])=="D2_VALIRRF" })],nY,.F.,,,,.F.), .T.)'
	
			bSD2 := &( '{|| ' + cSD2 + '}' )

			cMoedaFat := NXA->NXA_CMOEDA
			lConverte := cMoedaFat <> cMoedaNac .And. nCotacao != 0

			If cTpCotac == "3" .And. lIntFinanc .And. lExistOHI// Considera o valor recebido (Baixas) para emitir a NF
				aValores  := J205ValBx(lConverte, cMoedaNac)
				nValHon   := aValores[1] // Honorários
				nValDes   := aValores[2] // Despesas
			Else
				If lConverte // Valores na moeda da fatura
					nValHon := NXA->NXA_VLFATH + IIF(lCpoGrsHon, NXA->NXA_VGROSH, 0) - NXA->NXA_VLDESC + NXA->NXA_VLACRE + NXA->NXA_VLTXAD + NXA->NXA_VLGROS + NXA->NXA_VLTRIB
					nValDes := NXA->NXA_VLREMB
				Else // Valores na moeda da nacional
					nValHon := NXA->NXA_FATHMN + IIF(lCpoGrsHon, NXA->NXA_GRSHMN, 0) - NXA->NXA_DESCMN + NXA->NXA_ACREMN + NXA->NXA_TXADMN + NXA->NXA_GROSMN + NXA->NXA_TRIBMN
					nValDes := NXA->NXA_REMBMN
				EndIf
			EndIf
			
			nValIss     := NXA->NXA_ISS

			// Conversão para moeda nacional
			If lConverte
				nValHon   := JA201FConv(cMoedaFat, cMoedaNac, nValHon, "A", , , , , , , , , nCotacao)[1]
				nValDes   := JA201FConv(cMoedaFat, cMoedaNac, nValDes, "A", , , , , , , , , nCotacao)[1]
			EndIf
	
			// Alimenta o Array contendo o cabecalho da nota fiscal com campos zerados
			// É preciso informar toda a estrutura do SF2
			For nI := 1 To Len( aStruSF2 )
				cCampo := aStruSF2[nI, 1]
				
				If cPaisLoc == "BRA"
				
					Do Case
					Case cCampo == 'F2_FILIAL'
						Aadd(aSF2, xFilial("SF2") )
					Case cCampo == 'F2_TIPO'
						aAdd(aSF2, "N")
					Case cCampo == 'F2_EMISSAO'
						aAdd(aSF2, dDataBase)
					Case cCampo == 'F2_CLIENTE'
						aAdd(aSF2, NXA->NXA_CLIPG )
					Case cCampo == 'F2_LOJA'
						aAdd(aSF2, NXA->NXA_LOJPG )
					Case cCampo == 'F2_EST'
						aAdd(aSF2, SA1->A1_EST)
					Case cCampo == 'F2_UFDEST'
						aAdd(aSF2, SA1->A1_EST)
					Case cCampo == 'F2_UFORIG'
						aAdd(aSF2, aDadosEmp[01, 02])
					Case cCampo == 'F2_COND'
						aAdd(aSF2, cCond )
					Case cCampo == 'F2_SERIE'
						aAdd(aSF2, cSerie )
					Case cCampo == 'F2_ESPECIE'
						aAdd(aSF2, A460Especie(cSerie) )
					Case cCampo == 'F2_PREFIXO'
						aAdd(aSF2, cPrefixo)
					Case cCampo == 'F2_MOEDA'
						aAdd(aSF2, 1)
					Case cCampo == 'F2_TIPOCLI'
						aAdd(aSF2, SA1->A1_TIPO)
					Case cCampo == 'F2_HORA'
						aAdd(aSF2, SubStr(Time(), 1, 5) )
					Case cCampo == 'F2_CLIENT'
						aAdd(aSF2, NXA->NXA_CLIPG )
					Case cCampo == 'F2_LOJENT'
						aAdd(aSF2, NXA->NXA_LOJPG )
					Case cCampo == 'F2_DESPESA'
						aAdd(aSF2, nValDes )
					Case lEndPSer .And. cCampo == 'F2_ESTPRES'
						aAdd(aSF2, NXA->NXA_ESTPS )
					Case lEndPSer .And. cCampo == 'F2_MUNPRES'
						aAdd(aSF2, NXA->NXA_CMUNPS )
					Case lNfSubst .And. cCampo == 'F2_NFSUBST'
						aAdd(aSF2, NXA->NXA_NFSUBS)
					Case lNfSubst .And. cCampo == 'F2_SERSUBS'
						aAdd(aSF2, NXA->NXA_SERSUB)
					OtherWise
						If aStruSF2[nI,2] $  'C/M'
							aAdd(aSF2, '' )
						ElseIf aStruSF2[nI,2] == 'N'
							aAdd(aSF2, 0 )
						ElseIf aStruSF2[nI,2] == 'D'
							aAdd(aSF2, CToD('  /  /  ') )
						ElseIf aStruSF2[nI,2] == 'L'
							aAdd(aSF2, .F. )
						EndIf
					EndCase
				
				Else
				
					Do Case
					Case cCampo == 'F2_TIPO'
						aAdd(aSF2, {cCampo, "N", Nil} )
					Case cCampo == 'F2_EMISSAO'
						aAdd(aSF2, {cCampo, dDataBase, Nil} )
					Case cCampo == 'F2_CLIENTE'
						aAdd(aSF2, {cCampo, NXA->NXA_CLIPG, Nil} )
					Case cCampo == 'F2_LOJA'
						aAdd(aSF2, {cCampo, NXA->NXA_LOJPG, Nil} )
					Case cCampo == 'F2_EST'
						aAdd(aSF2, {cCampo, SA1->A1_EST, Nil} )
					Case cCampo == 'F2_UFDEST'
						aAdd(aSF2, {cCampo, SA1->A1_EST, Nil} )
					Case cCampo == 'F2_UFORIG'
						aAdd(aSF2, {cCampo, aDadosEmp[01, 02], Nil} )
					Case cCampo == 'F2_COND'
						aAdd(aSF2, {cCampo, cCond, Nil} )
					Case cCampo == 'F2_DOC'
						AAdd(aSF2, {cCampo, cNumNfs := JA205GrNum(cSerie), Nil} )
					Case cCampo == 'F2_SERIE'
						aAdd(aSF2, {cCampo, cSerie, Nil} )
					Case cCampo == 'F2_ESPECIE'
						aAdd(aSF2, {cCampo, A460Especie(cSerie), Nil} )
					Case cCampo == 'F2_TIPODOC'	
						aAdd(aSF2,{"F2_TIPODOC", "01", Nil})
					Case cCampo == 'F2_PREFIXO'
						aAdd(aSF2, {cCampo, cPrefixo, Nil} )
					Case cCampo == 'F2_MOEDA'
						aAdd(aSF2, {cCampo, 1, Nil} )
					Case cCampo == 'F2_TIPOCLI'
						aAdd(aSF2, {cCampo, SA1->A1_TIPO, Nil} )
					Case cCampo == 'F2_HORA'
						aAdd(aSF2, {cCampo, SubStr(Time(), 1, 5), Nil} )
					Case cCampo == 'F2_CLIENT'
						aAdd(aSF2, {cCampo, NXA->NXA_CLIPG, Nil} )
					Case cCampo == 'F2_LOJENT'
						aAdd(aSF2, {cCampo, NXA->NXA_LOJPG, Nil} )
					Case cCampo == 'F2_TXMOEDA'
						aAdd(aSF2, {cCampo, 1, Nil} )
					Case cCampo == 'F2_DESPESA'
						aAdd(aSF2, {cCampo, nValDes, Nil})
					EndCase
	
				EndIf
			Next nI
	
			// Gera um item da nota se tem valor de honorarios
			If nValHon > 0
				aAdd(aDocOri, 0)
				cItem := Soma1( cItem )
	
				If Len(aAux := JA205Item(NXA->NXA_CLIPG, NXA->NXA_LOJPG, cItem, SA1->A1_EST, nValHon, nValIss, @cMsg, NXA->NXA_CESCR, NXA->NXA_COD, cMoedaNac, nCotacao, cMoedaFat, lConverte)) == 0
					lRet := .F.
				Else
					aAdd( aSD2, aAux )
				EndIf
			EndIf
	
			// Funcao que gera o documento fiscal a partir dos vetores sem existencia de pedido
			If lRet
				
				If cPaisLoc == "BRA"
	
					cNumNfs := MaNfs2Nfs(   "", ;                   // [01] Serie do Documento de Origem
											"", ;                   // [02] Numero do Documento de Origem
											NXA->NXA_CLIPG, ;     // [03] Cliente/Fornecedor do documento
											NXA->NXA_LOJPG, ;     // [04] Loja do Documento
											cSerie , ;            // [05] Serie do Documento a ser gerado
											lMostraCtb, ;                   // [06] Mostra Lct.Contabil                            ( OPC )
											lAglutCtb, ;                   // [07] Aglutina Lct.Contabil                          ( OPC )
											lCtbOnLine, ;                   // [08] Contabiliza On-Line                            ( OPC )
											, ;                   // [09] Contabiliza Custo On-Line                      ( OPC )
											, ;                   // [10] Reajuste de preco na nota fiscal               ( OPC )
											, ;                   // [11] Tipo de Acrescimo Financeiro                   ( OPC )
											, ;                   // [12] Tipo de Arredondamento                         ( OPC )
											, ;                   // [13] Atualiza Amarracao Cliente x Produto           ( OPC )
											, ;                   // [14] Cupom Fiscal                                   ( OPC )
											, ;                   // [15] CodeBlock de Selecao do SD2                    ( OPC )
											, ;                   // [16] CodeBlock a ser executado para o SD2           ( OPC )
											, ;                   // [17] CodeBlock a ser executado para o SF2           ( OPC )
											, ;                   // [18] CodeBlock a ser executado no final da transacao( OPC )
											aDocOri, ;            // [19] Array com os Recnos do SF2
											aSD2, ;               // [20] Array com o conteudo dos campos do SD2
											aSF2, ;               // [21] Array com o conteudo dos campos do SF2
											.F., ;                // [22] Calculo Fiscal. Desabilita o calculo fiscal pois as informacoes ja foram passadas nos campos do SD2 e SF2.
											, ;                   // [23] bFiscalSF2 - Bloco Fiscal para o SF2
											bSD2, ;               // [24] bFiscalSD2 - Bloco Fiscal para o SD2
											,;                    // [25] bFatSE1
											)                     // [26] cNumNFS - Numero de Nota Inicial
	
				Else
					lMSErroAuto := .F.
					MSExecAuto({|x,y,z| MATA467N(x,y,z)}, aSF2, aSD2, 3, , 3)
					If lMSErroAuto
						lRet := .F.
					EndIf
				EndIf
				
				// Gerou o Documento entao atualiza a fatura
				If lRet .And. !Empty( cNumNfs )
					RecLock('NXA', .F.)
					NXA->NXA_NFGER  := '1'
					NXA->NXA_DOC    := cNumNfs
					NXA->NXA_SERIE  := cSerie
					If NXA->(ColumnPos("NXA_NFCOTA")) > 0 // Proteção
						NXA->NXA_NFCOTA := IIF(lConverte, nCotacao, nCotOrig)
					EndIf
					NXA->NXA_OK     := cDesMark // Limpa a marca
					NXA->(MsUnlock())
				Else
					If nValDes > 0 .And. nValHon == 0
						cMsg := STR0030 //"Não é possivel gerar documento fiscal de faturas com somente despesas reembolsáveis." 
					EndIf
	
					DisarmTransaction()
					While __lSX8
						RollBackSX8()
					EndDo
					lRet := .F.
				EndIf
	
			EndIf
	
		EndIf
	
	End Transaction
EndIf

If !lRet
	cMsgLog := STR0009 + CRLF //"Não foi possivel gerar doc. fiscal para fatura "
	cMsgLog += STR0023 + NXA->NXA_CESCR + CRLF //"Escritório: "
	cMsgLog += STR0024 + NXA->NXA_COD + CRLF //"Fatura: "
	cMsgLog += cMsg + CRLF
	cMsgLog += (Replicate('-', 90)) + CRLF
	
	If FWIsInCallStack("JA203HFatu") // Geração da NF junto com a emissão da fatura
		cLogFatNF += cMsgLog + CRLF
	Else
		AutoGRLog(cMsgLog)
	EndIf
EndIf

If lEmisFat
	PutMV("MV_HORARMT", cTpDtEmiss) // Retorna o valor original do parâmetro
EndIf

JurFreeArr(@aValores)

RestArea( aAreaSA1 )
RestArea( aAreaCTP )
RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J205ValBx
Indica os valores de honorários e despesas para emissão das notas

@param lConverte,  Indica se deve ser feita a conversão dos valores
@param cMoeNac,  Moeda Naciona
@return aValores,  Valores de honorários e despesas para emissão das notas

@author  Jonatas Martins / Jorge Martins
@since   09/08/2019
/*/
//-------------------------------------------------------------------
Static Function J205ValBx(lConverte, cMoeNac)
	Local aAreaOHI   := OHI->(GetArea())
	Local cEscr      := NXA->NXA_CESCR
	Local cFatura    := NXA->NXA_COD
	Local aValores   := {0, 0}
	Local nValHon    := 0
	Local nValDes    := 0
	Local nCotac     := 0
	Local nPorcTrib  := Iif(NXA->NXA_VLFATD > 0 .And. NXA->NXA_VLTOTD > 0, NXA->NXA_VLTOTD / NXA->NXA_VLFATD, 0)
	Local nPorcRemb  := 1 - nPorcTrib
	Local nDesTribBx := 0
	Local nDesRembBx := 0
	Local nDespBaixa := 0

	OHI->(DbSetOrder(1)) // OHI_FILIAL, OHI_CESCR, OHI_CFATUR, OHI_CCONTR, OHI_ITEM
	If OHI->(DbSeek(xFilial("OHI") + cEscr + cFatura ) )
		While !OHI->( EOF() ) .And. xFilial("OHI") == OHI->OHI_FILIAL .And. cEscr == OHI->OHI_CESCR .And. cFatura == OHI->OHI_CFATUR
			
			// Registros muito antigos não tinham o OHI_CMOERE preenchido e os valores da OHI ficavam convertidos na moeda da baixa
			If lConverte .And. OHI->OHI_COTAC > 0 .And. Empty(OHI->OHI_CMOERE) .And. cMoeNac == OHI->OHI_CMOEDA 
				nCotac := OHI->OHI_COTAC
			Else
				nCotac := 1
			EndIf

			nDespBaixa := OHI->OHI_VLDCAS - OHI->OHI_VLDESD + OHI->OHI_VLACRD
			nDesTribBx := nDespBaixa * nPorcTrib
			nDesRembBx := nDespBaixa * nPorcRemb

			nValHon += (OHI->OHI_VLHCAS - OHI->OHI_VLDESH + OHI->OHI_VLACRH + nDesTribBx) / nCotac
			nValDes += nDesRembBx / nCotac

			OHI->(DbSkip())
		EndDo

		aValores := {nValHon, nValDes}
	EndIf

	RestArea(aAreaOHI)

Return (aValores)

//-------------------------------------------------------------------
/*/{Protheus.doc} JA205Item
Determina a ultima data de emissao de uma serie de Doc. Fiscal

@Param cClient  , Codigo do cliente
@Param cLoja    , Codigo da loja do cliente
@Param cItem    , numero do Item Ex.:  "01"
@Param cUF      , Unidade federativa E.: "SP"
@Param nValBase , Valor do base do produto
@Param nValIss  , Valor do Iss
@Param cMsg     , Messagem de retono da rotina. Passado por referencia
@Param cEscr    , Código do escritório da fatura
@Param cFatura  , Código da fatura
@Param cMoedaNac, Moeda nacional
@Param nCotacao , Nova Cotação para emissão da NFS
@Param cMoedaFat, Moeda da fatura
@Param lConverte, Indica se deve ser feita a conversão dos valores

@author Luciano Pereira dos Santos
@since  28/11/2017
/*/
//-------------------------------------------------------------------
Static Function JA205Item(cClient, cLoja, cItem, cUF, nValBase, nValIss, cMsg, cEscr, cFatura, cMoedaNac, nCotacao, cMoedaFat, lConverte)
Local lRet       := .T.
Local aArea      := GetArea()
Local aAreaSB1   := SB1->( GetArea() )
Local aAreaSF4   := SF4->( GetArea() )
Local cProd      := SuperGetMV("MV_JPRODH",, "" )
Local cTes       := SuperGetMV("MV_JTESNF",, "" )
Local aStruSD2   := SD2->(dbStruct())
Local aSD2       := {}
Local cCampo     := ''
Local nI         := 0
Local cPaisLoc   := SuperGetMV("MV_PAISLOC",, "BRA" )
Local aPisCof    := {}
Local nPis       := 1
Local nCofins    := 2
Local nBase      := 2
Local nAliquota  := 3
Local nValor     := 4
Local lApPisCof  := OHP->(ColumnPos("OHP_TES")) > 0 //Funcionalidade de Apuração de Pis/Cofins Ativa
Local cCtaFin    := ""
Local cFilSD2    := ""

If lApPisCof
	aPisCof := J205ApPC(cEscr, cFatura, cMoedaNac, nCotacao,cMoedaFat, lConverte, nValBase, @cTes)
	cCtaFin := aPisCof[03]
EndIf

SF4->(DbSetOrder(1)) //F4_FILIAL + F4_CODIGO
If Empty(cTes) .Or. !SF4->(DbSeek(xFilial('SF4') + cTes)) .Or. SF4->F4_MSBLQL == "1"
	lRet := .F.
	cMsg := I18N(STR0015, {cTes}) + CRLF + I18N(STR0016, {"MV_JTESNF"}) //"O TES - Tipo de Entrada e Saida '#1' não é válido." ##"Verifique a configuração do parâmetro '#1' ou a TES classificada na Natureza"    
Else
	If SF4->F4_DUPLIC == "S"
		lRet := .F.
		cMsg := STR0018 + CRLF + I18N(STR0019, {cTes, "MV_JTESNF"}) //"Verifique a configuração do TES '#1' no cadastro de TES - Tipos de Entrada e Saida ou altere a configuração do parametro '#2'." ##"Verifique a configuração do TES '#1' no cadastro de TES - Tipos de Entrada e Saida ou altere a configuração do parâmetro '#2'/TES classificada na Natureza"    
	EndIf
EndIf

If lRet
	SB1->(DbSetOrder(1))
	If SB1->(DbSeek(xFilial('SB1') + cProd))
		
		If lApPisCof .And. Empty(cCtaFin)
			cCtaFin := SB1->B1_CONTA
		EndIf

		cFilSD2 := xFilial("SD2")

		For nI := 1 To Len( aStruSD2 )
			cCampo := aStruSD2[nI, 1]
			
			If cPaisLoc == "BRA"
				Do Case
				Case cCampo == 'D2_FILIAL'
					aAdd( aSD2, cFilSD2 )
				Case cCampo == 'D2_CLIENTE'
					aAdd( aSD2, cClient )
				Case cCampo == 'D2_LOJA'
					aAdd( aSD2, cLoja )
				Case cCampo == 'D2_EST'
					aAdd( aSD2, cUF )
				Case cCampo == 'D2_TIPO'
					aAdd( aSD2, "N" )
				Case cCampo == 'D2_ITEM'
					aAdd( aSD2, cItem  )
				Case cCampo == 'D2_COD'
					aAdd( aSD2, SB1->B1_COD )
				Case cCampo == 'D2_QUANT'
					aAdd( aSD2,  1  )
				Case cCampo == 'D2_PRCVEN'
					aAdd( aSD2, Round(nValBase, TamSX3(cCampo)[2]) )
				Case cCampo == 'D2_PRUNIT'
					aAdd( aSD2, Round(nValBase, TamSX3(cCampo)[2]) )
				Case cCampo == 'D2_TOTAL'
					aAdd( aSD2, Round(nValBase, TamSX3(cCampo)[2]) )
				Case cCampo == 'D2_EMISSAO'
					aAdd( aSD2, dDataBase )
				Case cCampo == 'D2_TES'
					aAdd( aSD2, cTes )
				Case cCampo == 'D2_LOCAL'
					aAdd( aSD2, SB1->B1_LOCPAD )
				Case cCampo == 'D2_UM'
					aAdd( aSD2, SB1->B1_UM )
				Case cCampo == 'D2_TP'
					aAdd( aSD2, SB1->B1_TIPO )
				Case cCampo == 'D2_CODISS'
					aAdd( aSD2, SB1->B1_CODISS )
				Case cCampo == 'D2_BASEISS'
					aAdd( aSD2, Round(nValBase, TamSX3(cCampo)[2]) )
				Case cCampo == 'D2_VALISS'
					aAdd( aSD2, nValIss )
				// PIS
				Case cCampo == 'D2_BASEPIS'
					aAdd( aSD2, Round(nValBase, TamSX3(cCampo)[2]) )
				Case cCampo == 'D2_ALQPIS'
					aAdd( aSD2, NXA->NXA_PPIS )
				Case cCampo == 'D2_VALPIS'
					aAdd( aSD2, NXA->NXA_PIS )
				//COFINS
				Case cCampo == 'D2_BASECOF'
					aAdd( aSD2, Round(nValBase, TamSX3(cCampo)[2]) )
				Case cCampo == 'D2_ALQCOF'
					aAdd( aSD2, NXA->NXA_PCOFIN )
				Case cCampo == 'D2_VALCOF'
					aAdd( aSD2, NXA->NXA_COFINS )
				// CSLL
				Case cCampo == 'D2_BASECSL'
					aAdd( aSD2, Round(nValBase, TamSX3(cCampo)[2]) )
				Case cCampo == 'D2_ALQCSL'
					aAdd( aSD2, NXA->NXA_PCSLL )
				Case cCampo == 'D2_VALCSL'
					aAdd( aSD2, NXA->NXA_CSLL )
				// IRRF
				Case cCampo == 'D2_BASEIRR'
					aAdd( aSD2, Round(nValBase, TamSX3(cCampo)[2]) )
				Case cCampo == 'D2_ALQIRRF'
					aAdd( aSD2, NXA->NXA_PIRRF )
				Case cCampo == 'D2_VALIRRF'
					aAdd( aSD2, NXA->NXA_IRRF )
				Case cCampo == 'D2_CONTA' .And. lApPisCof
					aAdd( aSD2, cCtaFin )
				Case cCampo == 'D2_BASIMP5' .And. lApPisCof
					aAdd( aSD2, aPisCof[nCofins, nBase ] )
				Case cCampo == 'D2_VALIMP5' .And. lApPisCof
					aAdd( aSD2, aPisCof[nCofins, nValor ] )
				Case cCampo == 'D2_ALQIMP5' .And. lApPisCof
					aAdd( aSD2, aPisCof[nCofins, nAliquota ] )
				Case cCampo == 'D2_BASIMP6' .And. lApPisCof
					aAdd( aSD2, aPisCof[nPis,nBase ] )
				Case cCampo == 'D2_VALIMP6' .And. lApPisCof
					aAdd( aSD2, aPisCof[nPis,nValor ] )
				Case cCampo == 'D2_ALQIMP6' .And. lApPisCof
					aAdd( aSD2, aPisCof[nPis,nAliquota ] )
				OtherWise
					If aStruSD2[nI,2] $ 'C/M'
						aAdd(aSD2, '' )
					ElseIf aStruSD2[nI,2] == 'N'
						aAdd(aSD2,  0 )
					ElseIf aStruSD2[nI,2] == 'D'
						aAdd(aSD2, CToD('  /  /  ') )
					ElseIf aStruSD2[nI,2] == 'L'
						aAdd(aSD2, .F. )
					EndIf
				EndCase

			Else			
			
				Do Case
				Case cCampo == 'D2_CLIENTE'
					aAdd( aSD2, {cCampo, cClient, Nil })
				Case cCampo == 'D2_LOJA'
					aAdd( aSD2, {cCampo, cLoja, Nil })
				Case cCampo == 'D2_EST'
					aAdd( aSD2, {cCampo, cUF, Nil })
				Case cCampo == 'D2_TIPO'
					aAdd( aSD2, {cCampo, "N", Nil })
				Case cCampo == 'D2_ITEM'
					aAdd( aSD2, {cCampo, cItem, Nil })
				Case cCampo == 'D2_COD'
					aAdd( aSD2, {cCampo, SB1->B1_COD, Nil })
				Case cCampo == 'D2_QUANT'
					aAdd( aSD2, {cCampo, 1, Nil })
				Case cCampo == 'D2_PRCVEN'
					aAdd( aSD2, {cCampo, Round(nValBase, TamSX3(cCampo)[2]), Nil })
				Case cCampo == 'D2_PRUNIT'
					aAdd( aSD2, {cCampo, Round(nValBase, TamSX3(cCampo)[2]), Nil })
				Case cCampo == 'D2_TOTAL'
					aAdd( aSD2, {cCampo, Round(nValBase, TamSX3(cCampo)[2]), Nil })
				Case cCampo == 'D2_EMISSAO'
					aAdd( aSD2, {cCampo, dDataBase, Nil })
				Case cCampo == 'D2_TES'
					aAdd( aSD2, {cCampo, cTes, Nil })
				Case cCampo == 'D2_LOCAL'
					aAdd( aSD2, {cCampo, SB1->B1_LOCPAD, Nil })
				Case cCampo == 'D2_UM'
					aAdd( aSD2, {cCampo, SB1->B1_UM, Nil })
				Case cCampo == 'D2_TP'
					aAdd( aSD2, {cCampo, SB1->B1_TIPO, Nil })
				Case cCampo == 'D2_CODISS'
					aAdd( aSD2, {cCampo, SB1->B1_CODISS, Nil })
				Case cCampo == 'D2_BASEISS'
					aAdd( aSD2, {cCampo, Round(nValBase, TamSX3(cCampo)[2]), Nil })
				Case cCampo == 'D2_VALISS'
					aAdd( aSD2, {cCampo, nValIss, Nil })
				Case cCampo == 'D2_CONTA' .And. lApPisCof
					aAdd( aSD2, {cCampo, cCtaFin , Nil })
				Case cCampo == 'D2_BASIMP5' .And. lApPisCof
					aAdd( aSD2, {cCampo, aPisCof[nCofins, nBase], Nil })
				Case cCampo == 'D2_VALIMP5' .And. lApPisCof
					aAdd( aSD2, {cCampo, aPisCof[nCofins, nValor], Nil })
				Case cCampo == 'D2_ALQIMP5' .And. lApPisCof
					aAdd( aSD2, {cCampo, aPisCof[nCofins, nAliquota], Nil })
				Case cCampo == 'D2_BASIMP6' .And. lApPisCof
					aAdd( aSD2, {cCampo, aPisCof[nPis, nBase], Nil })
				Case cCampo == 'D2_VALIMP6' .And. lApPisCof
					aAdd( aSD2, {cCampo, aPisCof[nPis, nValor], Nil })
				Case cCampo == 'D2_ALQIMP6' .And. lApPisCof
					aAdd( aSD2, {cCampo, aPisCof[nPis, nAliquota], Nil })

				EndCase

			EndIf
		Next nI
	Else
		cMsg := I18N(STR0017, {cProd}) + CRLF + I18N(STR0016, {"MV_JPRODH"}) //#"O produto '#1' não é válido." ##"Verifique a configuração do parametro '#1'."
	EndIf
EndIf

RestArea( aAreaSF4 )
RestArea( aAreaSB1 )
RestArea( aArea )

Return aSD2

//-------------------------------------------------------------------
/*/{Protheus.doc} JA205ULTNF
Determina a ultima data de emissao de uma serie de Doc. Fiscal

@author Ernani Forastieri
@since 15/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA205ULTNF( cSerie )
Local cQuery := ''
Local dRet   := CToD( '  /  /  ' )
Local aArea  := GetArea()
Local cTmp   := GetNextAlias()

cQuery := " Select max(SF2.F2_EMISSAO) ULTDIA "
cQuery += " from " + RetSqlName("SF2") + " SF2 "
cQuery += " where SF2.F2_FILIAL = '" + xFilial( 'SF2' ) + "' "
cQuery +=   " and SF2.F2_SERIE = '" + AvKey(cSerie,"F2_SERIE") + "' "
cQuery +=   " and SF2.D_E_L_E_T_ = ' '"

DbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cTmp, .T., .F.)

dRet := StoD( (cTmp)->ULTDIA )

(cTmp)->( dbCloseArea() )

RestArea( aArea )

Return dRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA205All
Chamada da rotina que avalia a ação de marcar todos

@param  oBrowse   , MarkBrowse
@param  lMark     , Indica se está marcando (.T.) ou desmarcando (.F.)
@param  lVldPagas , Indica se deve permitir marcar somente faturas totalmente pagas
@param  lAutomato , Execução via automação
@param  cTpCotac  , Tipo de Cotação
@param  lIntFinanc, Integração Financeiro
@param  lEmisFat  , Emissão pela Data da Fatura
@param  lCotMensal, Cotação Mensal
@param  lExistOHI , Existe OHI
@param  cMoedaNac , Moeda Nacional
@param  cCpoCot   , Campos da Cotação

@author Luciano Pereira dos Santos
@since 07/12/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA205All(oBrowse, lMark, lVldPagas, lAutomato, cTpCotac, lIntFinanc, lEmisFat, lCotMensal, lExistOHI, cMoedaNac, cCpoCot)

	FWMsgRun(, {|| J205MarkAll(oBrowse, @lMark, lVldPagas, lAutomato, cTpCotac, lIntFinanc, lEmisFat, lCotMensal, lExistOHI, cMoedaNac, cCpoCot) }, STR0013, STR0012) //"Aguarde... Marcando Registros"###"Marcar Todos"

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J205MarkAll
Função para marcar efetivamente os registros ao utilizar o recurso
de marcar todos (duplo clique na header da marcação)

@param   oBrowse   , MarkBrowse
@param   lMark     , Indica se está marcando (.T.) ou desmarcando (.F.)
@param   lVldPagas , Indica se deve permitir marcar somente faturas totalmente  pagas
@param   lAutomato , Execução via automação
@param   cTpCotac  , Tipo de Cotação
@param   lIntFinanc, Integração Financeiro
@param   lEmisFat  , Emissão pela Data da Fatura
@param   lCotMensal, Cotação Mensal
@param   lExistOHI , Existe OHI
@param   cMoedaNac , Moeda Nacional
@param   cCpoCot   , Campos da Cotação

@author Luciano Pereira dos Santos
@since  07/12/2017
/*/
//-------------------------------------------------------------------
Static Function J205MarkAll(oBrowse, lMark, lVldPagas, lAutomato, cTpCotac, lIntFinanc, lEmisFat, lCotMensal, lExistOHI, cMoedaNac, cCpoCot)
Local aArea := GetArea()
Local cQryCot := ""
Local nRec    := ""
Local cInsert := ""

	//Realiza a Query das cotações nao cadastradas e insere na tabela
	cQryCot := J205QryCot("", "", cTpCotac, lIntFinanc, lEmisFat, lCotMensal, lExistOHI, cRealName)
	nRec := Len(JurSql(cQryCot, "*"))

	If nRec > 0
		cQryCot := StrTran(cQryCot, "* FROM", cCpoCot + " FROM ")
		cInsert := "INSERT INTO " + cRealName +" ("
		cInsert += cCpoCot + " ) "
		cQryCot := ChangeQuery(cQryCot, .F.)
		cInsert += cQryCot

		If (TCSQLExec(cInsert) < 0) // Usar TCSQLExec apenas na tabela temporária criada pelo FWTemporaryTable()
			JurLogMsg( TCSQLError() )
			lRet := JurMsgErro(STR0043, "J205MarkAll()", STR0044) //#"Erro ao executar query temporária." ##"Para mais detalhes verificar o log do console."
		ElseIf !lAutomato
			oBrw205Cot:Refresh(.T.)
		EndIf
	EndIf 

	J205SetAll(oBrowse, "NXA", "NXA_OK", lMark, {|| IIf(lVldPagas, J204PFinan(.F.) == '2', .T. )})

	If lVldPagas
		ApMsgInfo(STR0039) // "Foram selecionadas apenas faturas totalmente pagas."
	EndIf

	lMark := !lMark

	oBrowse:Refresh()

	RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J205SetAll
Grava marca na tabela do browse

@param   oBrowse   , Objeto do MarkBrowse
@param   cTabela   , Alias da tabela do browse
@param   cCampo    , Campo de Marca do browse
@param   lMark     , Indica se está marcando (.T.) ou desmarcando (.F.)
@param   bCondicao , Filtro condional para marcar o registro do browse

@author Jonatas Martins
@since  20/10/2021
/*/
//------------------------------------------------------------------
Static Function J205SetAll(oBrowse, cTabela, cCampo, lMarcar, bCondicao)
Local aArea  := GetArea()
Local cMarca := oBrowse:Mark()

	(cTabela)->(DbGoTop())

	While (cTabela)->(! EOF())
		If Eval(bCondicao)
			RecLock( cTabela, .F. )
			(cTabela)->&cCampo := IIf(lMarcar, cMarca, '  ')
			MsUnLock()
		EndIf
		(cTabela)->( dbSkip() )
	EndDo

	RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA205GrNum
Função para retornar a numeração de Documento Fiscal atual e gravar a 
próxima na SX5.

@Param   cSerie   Código da Série que será usada

@Return           String com a mumeração atual respeitando o tamanho do 
                  F2_DOC

@author Cristina Cintra / Bruno Ritter
@since 03/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA205GrNum(cSerie)
Local aArea    := GetArea()
Local aSeries  := {}
Local nDoc     := 0
Local nI       := 0
Local nTamDoc  := TamSX3("F2_DOC")[1]
Local cNovoNum := ""

aSeries := FWGetSX5("01")

For nI := 1 To Len(aSeries)
	If Alltrim(aSeries[nI][3]) == Alltrim(cSerie)
		nDoc := Val(aSeries[nI][4])
	EndIf
Next nI

cNovoNum := Strzero(nDoc + 1, nTamDoc)

FwPutSX5(, "01", cSerie, cNovoNum, cNovoNum, cNovoNum )

RestArea( aArea )

Return Strzero(nDoc, nTamDoc)

//-------------------------------------------------------------------
/*/{Protheus.doc} JA205SetMk
Função para realizar a marcação de um registro

@param  oBrw205   , MarkBrowse
@param  lVldPagas , Indica se deve permitir marcar somente faturas totalmente pagas
@param  lAutomato , Execução via automação
@param  cTpCotac  , Tipo de Cotação
@param  lIntFinanc, Integração Financeiro
@param  lEmisFat  , Emissão pela Data da Fatura
@param  lCotMensal, Cotação Mensal
@param  lExistOHI , Existe OHI
@param  cMoedaNac , Moeda Nacional
@param  cCpoCot   , Campos da Cotação

@return lValido   , Se verdadeiro o registro pode ser marcado

@author Jorge Martins
@since  13/08/2019
/*/
//-------------------------------------------------------------------
Static Function JA205SetMk(oBrw205, lVldPagas, lAutomato, cTpCotac, lIntFinanc, lEmisFat, lCotMensal, lExistOHI, cMoedaNac, cCpoCot)
	Local cMarca     := oBrw205:Mark()
	Local cDesmarca  := Space(1)
	Local lMarcando  := NXA->NXA_OK != cMarca // Verifica se estar marcando o registro
	Local lValido    := .T.
	
	If lVldPagas
		lValido := J204PFinan(.F.) == '2' // Indica se a fatura foi totalmente paga
	EndIf

	If lValido
		If (lValido := J205RetCot(lAutomato, cTpCotac, lIntFinanc, lEmisFat, lCotMensal, lExistOHI, cMoedaNac, cCpoCot))
			RecLock("NXA", .F.)
			NXA->NXA_OK := IIF(lMarcando, cMarca, cDesmarca)
			NXA->(MsUnlock())
		EndIf
	Else
		JurMsgErro(STR0040, , I18N(STR0041, {Alltrim(RetTitle("NXA_STATUS"))})) // "Não é permitido gerar notas para faturas que não foram totalmente pagas." - "Selecione apenas faturas com #1 'Paga' para gerar as notas."
	EndIf

Return (lValido)

//-------------------------------------------------------------------
/*/{Protheus.doc} J205TabCot
Função para realizar a criação da Tabela Temporária de Cotação

@param  cNXACod   , Codigo da Fatura
@param  cEscr     , Escritório
@param  oTmpTable , Tabela Temporária
@param  aOrder    , Ordem dos Campos
@param  aFields   , Campos da Tabela
@param  cTpCotac  , Tipo de Cotação
@param  lIntFinanc, Integração Financeiro
@param  lEmisFat  , Emissão pela Data da Fatura
@param  lCotMensal, Cotação Mensal
@param  lExistOHI , Existe OHI

@author fabiana.silva
@since  25/11/2020
/*/
//-------------------------------------------------------------------
Function J205TabCot(cNXACod, cEscr, oTmpTable, aFldsFilt, aOrder, aFields, cTpCotac, lIntFinanc, lEmisFat, lCotMensal, lExistOHI)
	Local aTemp 		:= {} //Tabela temporária
	Local cQueryTmp 	:= "" //Query Temporária
	Local aCmpNotBrw 	:= {} //Campos a nao serem exibidos
	Local aStruAdic 	:= {} //Campos Virtuais
	Local lCpoNXACot    := NXA->(ColumnPos("NXA_NFCOTA")) > 0
	Local cCpo          := IIF(lCpoNXACot, "NXA_NFCOTA", "NXF_COTAC1")
	Local cPictCotac    := GetSX3Cache("NXF_COTAC1", "X3_PICTURE")
	Local aCpoCotac     := TamSX3("NXF_COTAC1")
	Local aCpoCota2    := TamSX3(cCpo)
	Local cPictCota2    := GetSX3Cache(cCpo, "X3_PICTURE")

	Default cNXACod     := ""
	Default cEscr       := ""
	Default aFldsFilt   := {}
	Default aOrder      := {}
	Default aFields     := {}
	Default cTpCotac    := SuperGetMV("MV_JNFSCOT",, "1") // Define qual cotação será utilizada na emissão da NFS
	Default lIntFinanc  := SuperGetMV("MV_JURXFIN",, .F.) // Habilita a integracao entre os modulos SIGAFIN - Financeiro e SIGAPFS - Juridico
	Default lEmisFat    := SuperGetMV("MV_JEMINF",, .T.)  // Data de emissão do Documento Fiscal de Saída. Se .T. - Data da Fatura; .F. - Data base.
	Default lCotMensal  := SuperGetMv('MV_JTPCONV',,'1') == "2" // Cotação '1' = Diária / '2' = Mensal
	Default lExistOHI   := FWAliasInDic("OHI")
	
	cQueryTmp  := J205QryCot(cNXACod, cEscr, cTpCotac, lIntFinanc, lEmisFat, lCotMensal, lExistOHI)

	aStruAdic  := {{"COTORIG", "COTORIG", "N", aCpoCotac[1], aCpoCotac[2], cPictCotac, "NXF_COTAC1"},;
	               {"COTNOVA", STR0042  , "N", aCpoCota2[1], aCpoCota2[2], cPictCota2, cCpo}} // "Cotação"

	aCmpNotBrw := { "NXF_CFATUR", "NXF_CESCR", "COTORIG" }
	aTemp      := JurCriaTmp( GetNextAlias(), cQueryTmp, "NXF", , aStruAdic, /*aCmpAcBrw*/, aCmpNotBrw, , ,/*aTitCpoBrw*/ )
	oTmpTable  := aTemp[1]
	aFldsFilt  := aTemp[2]
	aOrder     := aTemp[3]
	aFields    := aTemp[4]

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J205RetCot
Retorna a cotação da Fatura

@param   lAutomato , Execução via automação
@param   cTpCotac  , Tipo de Cotação
@param   lIntFinanc, Integração Financeiro
@param   lEmisFat  , Emissão pela Data da Fatura
@param   lCotMensal, Cotação Mensal
@param   lExistOHI , Existe OHI
@param   cMoedaNac , Moeda Nacional
@param   cCpoCot   , Campos da Cotação

@return  lRet      , Cotação retornada com sucesso

@author  fabiana.silva
@since   14/09/2021
/*/
//-------------------------------------------------------------------
Static Function J205RetCot(lAutomato, cTpCotac, lIntFinanc, lEmisFat, lCotMensal, lExistOHI, cMoedaNac, cCpoCot)
Local cCodFatur    := NXA->NXA_COD
Local cEscr        := NXA->NXA_CESCR
Local cMoeda       := NXA->NXA_CMOEDA
Local cQryCot      := ""
Local cInsert      := ""
Local lRet         := .T.

Default lPosiciona := .T.
Default lAutomato  := .T.

	If cMoedaNac <> cMoeda .And. !Empty(cAlsCot) .And. !Empty(cRealName) .And. (cAlsCot)->(Eof())
		cQryCot := J205QryCot(cCodFatur, cEscr, cTpCotac, lIntFinanc, lEmisFat, lCotMensal, lExistOHI)
			
		cQryCot := StrTran(cQryCot, "* FROM", cCpoCot + " FROM ")

		cInsert := "INSERT INTO " + cRealName +" ("
		cInsert += cCpoCot + " ) "
		cInsert += ChangeQuery(cQryCot, .F.)

		If (TCSQLExec(cInsert) < 0) // Usar TCSQLExec apenas na tabela temporária criada pelo FWTemporaryTable()
			JurLogMsg(TCSQLError())
			lRet := JurMsgErro(STR0043, "J205RetCot()", STR0044) // "Erro ao executar query temporária." ##"Para mais detalhes verificar o log do console."
		ElseIf !lAutomato
			oBrw205Cot:Refresh(.T.)
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J205ApPC
Função para retornar os valores de PIS/Cofins - Apuração

@param  cEscr    , Escritório
@param  cFatura  , Codigo da Fatura
@param  cMoedaNac, Código da Moeda Nacional
@param  nCotacao , Cotação utilizada na Fatura
@param  cMoedaFat, Moeda da Fatura
@param  lConverte, Indica se deve ser feita a conversão dos valores
@param  nValItem , Valor do item
@param  cTesProd , TES padrão

@return aRet      , Array com os Impostos onde
        aRet[1]   , Valores de Pis
        aRet[2]   , Valores de Cofins onde:
        aRet[n][1], Imposto
        aRet[n][2], Base
        aRet[n][3], Aliquota
        aRet[n][4], Valor
        aRet[n][5], CST
        aRet[3]   , Conta Contabil
@author fabiana.silva
@since  12/08/2021
/*/
//-------------------------------------------------------------------
Function J205ApPC(cEscr, cFatura, cMoedaNac, nCotacao, cMoedaFat, lConverte, nValItem, cTesProd)
Local cFilEscr  := JurGetDados("NS7", 1, xFilial("NS7") + cEscr, "NS7_CFILIA")
Local aRet      := {{"PIS", 0, 0, 0, "", "" }, {"COFINS", 0, 0, 0, "", ""}, ""}
Local cAlias205 := GetNextAlias()
Local nValBase  := 0
Local nPis      := 1
Local nCofins   := 2
Local nConta	:= 3
Local nBase     := 2
Local nAliquota := 3
Local nValor    := 4
Local nCST      := 5
Local cQuery    := ""
Local cTipoTit  := MVTAXA + "|" + MVPROVIS + "|" + MVABATIM + "|" + "PR|PRE" + MVRECANT
Local cFatJur   := xFilial("NXA") + AllTrim("-" + cEscr + "-" + cFatura + "-" + cFilEscr)

	cQuery := " SELECT ED_CODIGO, ED_PERCPIS, ED_PERCCOF, ED_REDPIS, ED_REDCOF, ED_CSTCOF, ED_CSTPIS, "
	cQuery +=         "ED_CONTA, ED_PCAPPIS, ED_PCAPCOF, ED_APURPIS, ED_APURCOF, " 
	cQuery +=         "MAX(E1_MOEDA) E1_MOEDA, MAX(E1_TXMOEDA) E1_TXMOEDA, SUM(E1_BASEIRF) E1_BASEIRF, "
	cQuery +=         "SUM(E1_PIS) E1_PIS, SUM(E1_COFINS) E1_COFINS, SUM(E1_BASEPIS) E1_BASEPIS, "
	cQuery +=         "SUM(E1_BASECOF) E1_BASECOF "
	cQuery +=   " FROM " + RetSqlName("SE1") + " SE1 "
	cQuery +=   "INNER JOIN " + RetSqlName("SED") + " SED "
	cQuery +=      "ON SED.ED_CODIGO = SE1.E1_NATUREZ "
	cQuery +=     "AND (SED.ED_APURCOF <> '' OR SED.ED_APURPIS <> '') "
	cQuery +=     "AND SED.ED_FILIAL = '" + xFilial("SED", cFilEscr) + "' "
	cQuery +=     "AND SED.D_E_L_E_T_ = ' ' "
	cQuery +=   "WHERE E1_JURFAT = '" + cFatJur + "' "
	cQuery +=     "AND SE1.E1_FILIAL ='" + xFilial("SE1", cFilEscr) + "' AND  SE1.D_E_L_E_T_ = ' ' "
	cQuery +=     "AND SE1.E1_TIPO NOT IN " + FormatIn(cTipoTit, IIF("|" $ cTipoTit, "|", ",")) + " "
	cQuery +=     "AND E1_ORIGEM = 'JURA203' "
	cQuery +=   "GROUP BY ED_CODIGO, ED_PERCPIS, ED_PERCCOF, ED_REDPIS, ED_REDCOF, ED_CSTCOF, ED_CSTPIS, "
	cQuery +=            "ED_CONTA, ED_PCAPPIS, ED_PCAPCOF , ED_APURPIS, ED_APURCOF"

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T., "TOPCONN", TCGENQRY(,, cQuery), cAlias205, .F., .T.)

	If (cAlias205)->(!Eof())

		cTESProd            := J205TESPC((cAlias205)->ED_CODIGO, cTESProd)
		aRet[nCofins][nCST] := (cAlias205)->ED_CSTCOF
		aRet[nPis][nCST]    := (cAlias205)->ED_CSTPIS
		aRet[nConta]        := (cAlias205)->ED_CONTA

		If !(!Empty((cAlias205)->ED_PERCPIS) .And. !Empty((cAlias205)->ED_PERCCOF) .And.;
			 (cAlias205)->E1_PIS == 0 .And. (cAlias205)->E1_COFINS == 0 .And.;
			 (cAlias205)->E1_BASEPIS == 0 .And. (cAlias205)->E1_BASECOF == 0) 
			 // Copiado da Regra de Apuração registro f100 - Fonte FINXSPD							   

			// Calculo inverso assim caso seja base reduzida ou normal o valor vai ser gerado correto.
			If (cAlias205)->E1_PIS > 0 .And. !Empty((cAlias205)->ED_PERCPIS)
				nValBase := (cAlias205)->E1_BASEPIS
			ElseIf (cAlias205)->E1_COFINS > 0 .And. !Empty((cAlias205)->ED_PERCCOF)
				nValBase := (cAlias205)->E1_BASECOF
			EndIf

			If nValBase == 0
				nValBase := (cAlias205)->E1_BASEIRF
				If nValBase == 0
					nValBase := nValItem
					lConverte := .F.
				EndIf
				If !Empty((cAlias205)->ED_REDPIS) .And. Empty((cAlias205)->ED_PERCPIS)
					nValBase *= ((cAlias205)->ED_REDPIS / 100)
				ElseIf !Empty((cAlias205)->ED_REDCOF) .And. Empty((cAlias205)->ED_PERCCOF)
					nValBase *= ((cAlias205)->ED_REDCOF / 100)
				EndIf
			EndIf

			//Realiza conversão da taxa da moeda
			If lConverte
				nValBase := JA201FConv(cMoedaFat, cMoedaNac, nValBase, "A", , , , , , , , , nCotacao)[1]
			EndIf

			If nValBase > 0
				// PIS
				aRet[nPis][nAliquota] := (cAlias205)->ED_PCAPPIS
				If !(aRet[nPis][nCST] $ "07_08_09_49")
					aRet[nPis][nBase]  := nValBase
					aRet[nPis][nValor] := Round(aRet[nPis][nBase] * aRet[nPis][nAliquota] / 100, 2)
				EndIf

				// COFINS
				aRet[nCofins][nAliquota] := (cAlias205)->ED_PCAPCOF
				If !(aRet[nCofins][nCST] $ "07_08_09_49")
					aRet[nCofins][nBase] := nValBase // Base COFINS
				EndIf
				If !Empty((cAlias205)->ED_APURCOF)
					aRet[nCofins][nValor] := aRet[nCofins][nBase] * aRet[nCofins][nAliquota] / 100
				EndIf
			EndIf
		EndIf
		aRet[nConta] := (cAlias205)->ED_CONTA
	EndIf

	(cAlias205)->(DbCloseArea())

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J205TESPC
Função para retornar a TES Associada à Natureza

@param  cNatureza, Código da Natureza
@param  cTESProd , TES Padrão

@return cTES     , Codigo da TES

@author fabiana.silva
@since  08/09/2021
/*/
//-------------------------------------------------------------------
Static Function J205TESPC(cNatureza, cTESProd)
Local cTES := ""

	If OHP->(ColumnPos("OHP_TES")) > 0
		cTES := JurGetDados("OHP", 3, xFilial("OHP") + "5" + cNatureza, "OHP_TES")
	EndIf

	cTES := IIF(Empty(cTES), cTESProd, cTES)

Return cTES
