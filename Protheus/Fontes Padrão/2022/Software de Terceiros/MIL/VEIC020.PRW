#INCLUDE "VEIC020.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE 'FWMVCDEF.CH'

/*/{Protheus.doc} VEIC020
	Histórico Agrega/Desagrega
	@author Fernando Vitor Cavani
	@since 14/02/2019
	@version 1.0
	@param cPARCHASSI, caracter, Chassi do Veículo
	@return lógico
	@type function
/*/
Function VEIC020(cPARCHASSI)
	Private cChassi := ""
	Private oBrowse
	Private aVetCon := {}

	Default cPARCHASSI := ""

	cChassi := cPARCHASSI

	oExecView := FWViewExec():New()
	oExecView:SetTitle(STR0001) // Consulta
	oExecView:SetSource("VEIC020")
	oExecView:SetOperation(MODEL_OPERATION_UPDATE)
	oExecView:OpenView(.T.)
Return .T.

/*/{Protheus.doc} ModelDef
	Model
	@author Fernando Vitor Cavani
	@since 14/02/2019
	@version 1.0
	@return oModel, objeto, Model
	@type function
/*/
Static Function ModelDef()
	Local oModel
	Local oCpoFil := VC0200016_CamposParaFiltro()
	Local oCpoStru := oCpoFil:GetModel()

	oModel := MPFormModel():New("VEIC020", /* <bPre> */, /* <bPost> */, {|| .T.} /* <bCommit> */, {|| .T.} /* <bCancel> */)
	oModel:AddFields("MASTER", /* <cOwner> */, oCpoStru, /* <bPre> */, /* <bPost> */, {||}/* <bLoad> */)

	oModel:SetDescription(STR0002) // Histórico Agrega/Desagrega
	oModel:GetModel("MASTER"):SetDescription(STR0003) // Filtro

	oModel:SetPrimaryKey({})
	oModel:SetActivate()
Return oModel

/*/{Protheus.doc} ViewDef
	View
	@author Fernando Vitor Cavani
	@since 14/02/2019
	@version 1.0
	@return oView, objeto, View
	@type function
/*/
Static Function ViewDef()
	Local oModel := FWLoadModel("VEIC020")
	Local oView  := Nil

	Local oCpoFil := VC0200016_CamposParaFiltro()
	Local oCpoStru := oCpoFil:GetView()

	oView := FWFormView():New()
	oView:SetModel(oModel)

	oView:AddField("FILTRO", oCpoStru, "MASTER")
	oView:AddOtherObject("PAINEL", {|oPanel| VC0200026_GridConsulta(oPanel)})

	oView:EnableTitleView("FILTRO", STR0003) // Filtro
	oView:EnableTitleView("PAINEL", STR0001) // Consulta

	oView:CreateHorizontalBox("TELA_FILTRO", 25)
	oView:CreateHorizontalBox("TELA_PAINEL", 75)

	oView:SetOwnerView("FILTRO", "TELA_FILTRO")
	oView:SetOwnerView("PAINEL", "TELA_PAINEL")

	// Retira o botão de "Salvar e Criar um Novo"
	oView:SetCloseOnOk({||.T.})

	//Executa a ação antes de cancelar a Janela de edição
	//Se ação retornar .F. não apresenta o questionamento ao usuário de formulário modificado
	oView:SetViewAction("ASKONCANCELSHOW", {|| .F.})

	// Marca internamente que algo foi modificado na MODEL
	oView:SetModified(.T.)

	// Retira as mensagens de confirmação ao fechar a Janela
	oView:showUpdateMsg(.F.)
	oView:showInsertMsg(.F.)
Return oView

/*/{Protheus.doc} VC0200016_CamposParaFiltro
	Campos para Filtro
	@author Fernando Vitor Cavani
	@since 14/02/2019
	@version 1.0
	@return oRetorno, objeto, Objetos (Filtro)
	@type function
/*/
Static Function VC0200016_CamposParaFiltro()
	Local oRetorno    := OFDMSStruct():New()
	Local aCombo      := {}
	Local cMV_MIL0113 := GetNewPar("MV_MIL0113", "1")

	oRetorno:AddField({                                      ;
		{"cTitulo" , RetTitle("VDV_FILIAL")},                ; // Filial
		{"cIdField", "PARFILIAL"},                           ;
		{"cTipo"   , "C"},                                   ;
		{"nTamanho", GetSx3Cache("VDV_FILIAL", "X3_TAMANHO")};
	})

	oRetorno:AddField({                                      ;
		{"cTitulo" , STR0004},                               ; // Período - De
		{"cIdField", "PARINIMOV"},                           ;
		{"cTipo"   , "D"},                                   ;
		{"nTamanho", GetSx3Cache("VDV_DATMOV", "X3_TAMANHO")};
	})

	oRetorno:AddField({                                      ;
		{"cTitulo" , STR0005},                               ; // Até
		{"cIdField", "PARFIMMOV"},                           ;
		{"cTipo"   , "D"},                                   ;
		{"nTamanho", GetSx3Cache("VDV_DATMOV", "X3_TAMANHO")};
	})

	oRetorno:AddField({                                       ;
		{"cTitulo" , RetTitle("VV1_CHASSI")},                 ; // Chassi
		{"cIdField", "PARCHASSI"},                            ;
		{"cTipo"   , "C"},                                    ;
		{"nTamanho", GetSx3Cache("VV1_CHASSI", "X3_TAMANHO")},;
		{"cLookUp" , "V11"}                                   ;
	})

	// Agrega / Desagrega
	SX3->(DbSetOrder(2))
	SX3->(DbSeek("VDV_AGRDES"))

	aCombo := X3CBOXAVET(SX3->X3_CAMPO, "1")

	oRetorno:AddField({                          ;
		{"cTitulo"     , RetTitle("VDV_AGRDES")},; // Agrega/Desag
		{"cIdField"    , "PARAGRDES"},           ;
		{"cTipo"       , "C"},                   ;
		{"nTamanho"    , 1},                     ;
		{"aComboValues", aCombo}                 ;
	})

	// Notas Fiscais / Movimentação Interna
	SX3->(DbSetOrder(2))
	SX3->(DbSeek("VDV_TIPDOC"))

	aCombo := X3CBOXAVET(SX3->X3_CAMPO, "1")

	oRetorno:AddField({                          ;
		{"cTitulo"     , RetTitle("VDV_TIPDOC")},; // Tp.Doc.Gerar
		{"cIdField"    , "PARTIPDOC"},           ;
		{"cTipo"       , "C"},                   ;
		{"nTamanho"    , 1},                     ;
		{"aComboValues", aCombo}                 ;
	})

	oRetorno:AddButton(STR0006, "BTNPESQUISA", {|oMdl| VC0200046_Pesquisa(oMdl)}) // Pesquisar
Return oRetorno

/*/{Protheus.doc} VC0200026_GridConsulta
	Grid Consulta
	@author Fernando Vitor Cavani
	@since 14/02/2019
	@version 1.0
	@param oPanel, objeto, Painel para criação do Grid Consulta
	@return
	@type function
/*/
Static Function VC0200026_GridConsulta(oPanel)
	// Carregando apenas na abertura da tela com chassi posicionado
	If !Empty(cChassi)
		VC0200046_Pesquisa()
	EndIf

	// Criando o FWFormBrowse
	oBrowse := FWFormBrowse():New()
	oBrowse:SetOwner(oPanel)
	oBrowse:SetDescription("")
	oBrowse:SetDataArray()
	oBrowse:SetArray(aVetCon)
	oBrowse:SetColumns(VC0200036_ColunasGridConsulta())
	oBrowse:Activate()
Return

/*/{Protheus.doc} VC0200036_ColunasGridConsulta
	Retorna as colunas do Browse
	@author Fernando Vitor Cavani
	@since 18/02/2019
	@version 1.0
	@return aColumns, array, colunas da Grid Consulta
	@type function
/*/
Static Function VC0200036_ColunasGridConsulta()
	Local aColumns := {}

	AAdd(aColumns, FWBrwColumn():New())
	aColumns[1]:SetData(&("{|| aVetCon[oBrowse:At(), 1]}"))
	aColumns[1]:SetTitle(STR0007) // Tipo
	aColumns[1]:SetSize(10) // 10 %

	AAdd(aColumns, FWBrwColumn():New())
	aColumns[2]:SetData(&("{|| aVetCon[oBrowse:At(), 2]}"))
	aColumns[2]:SetTitle(STR0008) // Data
	aColumns[2]:SetPicture("@D")
	aColumns[2]:SetSize(15) // 15 %
	aColumns[2]:SetAlign(0) // Centralizado

	AAdd(aColumns, FWBrwColumn():New())
	aColumns[3]:SetData(&("{|| aVetCon[oBrowse:At(), 3]}"))
	aColumns[3]:SetTitle(RetTitle("VV1_CHASSI")) // Chassi Veic
	aColumns[3]:SetSize(20) // 20 %

	AAdd(aColumns, FWBrwColumn():New())
	aColumns[4]:SetData(&("{|| aVetCon[oBrowse:At(), 4]}"))
	aColumns[4]:SetTitle(RetTitle("VDV_FILIAL")) // Filial
	aColumns[4]:SetSize(5) // 5 %

	AAdd(aColumns, FWBrwColumn():New())
	aColumns[5]:SetData(&("{|| aVetCon[oBrowse:At(), 5]}"))
	aColumns[5]:SetTitle(STR0009) // NF Saída
	aColumns[5]:SetSize(10) // 10 %

	AAdd(aColumns, FWBrwColumn():New())
	aColumns[6]:SetData(&("{|| aVetCon[oBrowse:At(), 6]}"))
	aColumns[6]:SetTitle(STR0010) // NF Saída Peça
	aColumns[6]:SetSize(10) // 10 %

	AAdd(aColumns, FWBrwColumn():New())
	aColumns[7]:SetData(&("{|| aVetCon[oBrowse:At(), 7]}"))
	aColumns[7]:SetTitle(RetTitle("VDV_FILIAL")) // Filial
	aColumns[7]:SetSize(5) // 5 %

	AAdd(aColumns, FWBrwColumn():New())
	aColumns[8]:SetData(&("{|| aVetCon[oBrowse:At(), 8]}"))
	aColumns[8]:SetTitle(STR0011) // NF Entrada
	aColumns[8]:SetSize(10) // 10 %

	AAdd(aColumns, FWBrwColumn():New())
	aColumns[9]:SetData(&("{|| aVetCon[oBrowse:At(), 9]}"))
	aColumns[9]:SetTitle(STR0012) // NF Entrada Peça
	aColumns[9]:SetSize(10) // 10 %

	AAdd(aColumns, FWBrwColumn():New())
	aColumns[10]:SetData(&("{|| aVetCon[oBrowse:At(), 10]}"))
	aColumns[10]:SetTitle(STR0013) // Peça/Produto
	aColumns[10]:SetSize(30) // 30 %

	AAdd(aColumns, FWBrwColumn():New())
	aColumns[11]:SetData(&("{|| aVetCon[oBrowse:At(), 11]}"))
	aColumns[11]:SetTitle(STR0014) // Valor do Custo
	aColumns[11]:SetPicture("@E 99,999,999.99")
	aColumns[11]:SetSize(15) // 15 %
	aColumns[11]:SetAlign(2) // Direita
Return aColumns

/*/{Protheus.doc} VC0200046_Pesquisa
	Pesquisa (SQL)
	@author Fernando Vitor Cavani
	@since 14/02/2019
	@version 1.0
	@return lógico
	@type function
/*/
Static Function VC0200046_Pesquisa()
	Local oModel := FWModelActive()
	Local oView  := FWViewActive()

	Local oMParam := oModel:GetModel("MASTER")

	Local cSQL       := ""
	Local cAlias     := "TAGRDES"
	Local cPARFILIAL := oMParam:GetValue("PARFILIAL")
	Local cPARCHASSI := oMParam:GetValue("PARCHASSI")
	Local cPARINIMOV := oMParam:GetValue("PARINIMOV")
	Local cPARFIMMOV := oMParam:GetValue("PARFIMMOV")
	Local cPARAGRDES := oMParam:GetValue("PARAGRDES")
	Local cPARTIPDOC := oMParam:GetValue("PARTIPDOC")

	Local cNFSai  := ""
	Local cNFEnt  := ""
	Local cNFPSai := ""
	Local cNFPEnt := ""
	Local cItem   := ""
	Local cCusto  := ""

	aVetCon := {}

	// Executado apenas na abertura da tela com chassi posicionado
	If !Empty(cChassi)
		oMParam:SetValue("PARCHASSI", cChassi)
		oView:Refresh()

		cPARCHASSI := cChassi
	EndIf

	// Consulta SQL (AMS)
	cSQL := "(SELECT VDV.VDV_AGRDES, VDV.VDV_DATMOV, VDV.VDV_SFILNF, VDV.VDV_EFILNF, "
	cSQL += "       VDV.VDV_SNUMNF, VDV.VDV_SSERNF, VDV.VDV_SNUMNP, VDV.VDV_SSERNP, "
	cSQL += "       VDV.VDV_ENUMNF, VDV.VDV_ESERNF, VDV.VDV_ENUMNP, VDV.VDV_ESERNP, "
	cSQL += "       VDV.VDV_TIPDOC, VDV.VDV_NUMTRA, VDV.VDV_TRACPA, VV1.VV1_CHASSI, "
	cSQL += "       SC6.C6_VALOR AS CUSTO, SB1.B1_COD, SB1.B1_DESC "
	cSQL += "FROM " + RetSQLName("VDV") + " VDV "
	cSQL += "JOIN " + RetSqlName("VV1") + " VV1 ON VV1.VV1_FILIAL = '" + xFilial("VV1") + "' "
	cSQL += "    AND VV1.VV1_CHAINT = VDV.VDV_CHAINT AND VV1.D_E_L_E_T_ = ' ' "
	cSQL += "JOIN " + RetSqlName("SC5") + " SC5 ON SC5.C5_FILIAL = '" + xFilial("SC5") + "' "
	cSQL += "    AND SC5.C5_NOTA = VDV.VDV_SNUMNF AND SC5.D_E_L_E_T_ = ' ' "
	cSQL += "JOIN " + RetSqlName("SC6") + " SC6 ON SC6.C6_FILIAL = '" + xFilial("SC6") + "' "
	cSQL += "    AND SC6.C6_NOTA = SC5.C5_NOTA AND SC6.C6_SERIE = SC5.C5_SERIE "
	cSQL += "    AND SC6.C6_NUM = SC5.C5_NUM AND SC6.D_E_L_E_T_ = ' ' "
	cSQL += "JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
	cSQL += "    AND SB1.B1_COD = SC6.C6_PRODUTO AND SB1.D_E_L_E_T_ = ' ' "
	cSQL += "WHERE VDV.VDV_FILIAL = '" + xFilial("VDV") + "' "
	cSQL += IIf(Empty(cPARFILIAL), "", " AND (VDV.VDV_SFILNF = '" + cPARFILIAL + "' OR  VDV.VDV_EFILNF = '" + cPARFILIAL + "') ")
	cSQL += IIf(Empty(cPARCHASSI), "", " AND VV1.VV1_CHASSI = '" + cPARCHASSI + "' ")
	cSQL += IIf(Empty(cPARINIMOV), "", " AND VDV.VDV_DATMOV >= '" + DToS(cPARINIMOV) + "' ")
	cSQL += IIf(Empty(cPARFIMMOV), "", " AND VDV.VDV_DATMOV <= '" + DToS(cPARFIMMOV) + "' ")
	cSQL += IIf(Empty(cPARAGRDES) .Or. cPARAGRDES == "0", "", " AND VDV.VDV_AGRDES = '" + cPARAGRDES + "' ")
	cSQL += IIf(Empty(cPARTIPDOC) .Or. cPARTIPDOC <> "2", " AND VDV.VDV_TIPDOC = '1' ", " AND VDV.VDV_TIPDOC = '0' ")
	cSQL += "  AND VDV.VDV_STATUS IN (' ','1') AND VDV.D_E_L_E_T_ = ' ') "

	cSQL += "UNION ALL "

	// Consulta SQL (Movimentação Interna)
	cSQL += "(SELECT VDV.VDV_AGRDES, VDV.VDV_DATMOV, VDV.VDV_SFILNF, VDV.VDV_EFILNF, "
	cSQL += "       VDV.VDV_SNUMNF, VDV.VDV_SSERNF, VDV.VDV_SNUMNP, VDV.VDV_SSERNP, "
	cSQL += "       VDV.VDV_ENUMNF, VDV.VDV_ESERNF, VDV.VDV_ENUMNP, VDV.VDV_ESERNP, "
	cSQL += "       VDV.VDV_TIPDOC, VDV.VDV_NUMTRA, VDV.VDV_TRACPA, VV1.VV1_CHASSI, "
	cSQL += "       SD3.D3_CUSTO1 AS CUSTO, SB1.B1_COD, SB1.B1_DESC "
	cSQL += "FROM " + RetSQLName("VDV") + " VDV "
	cSQL += "JOIN " + RetSqlName("VV1") + " VV1 ON VV1.VV1_FILIAL = '" + xFilial("VV1") + "' "
	cSQL += "    AND VV1.VV1_CHAINT = VDV.VDV_CHAINT AND VV1.D_E_L_E_T_ = ' ' "
	cSQL += "JOIN " + RetSqlName("VBH") + " VBH ON VBH.VBH_FILIAL = '" + xFilial("VBH") + "' "
	cSQL += "    AND VBH.VBH_CODVDV = VDV.VDV_CODIGO AND VBH.D_E_L_E_T_ = ' ' "
	cSQL += "JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
	cSQL += "    AND SB1.B1_COD = VBH.VBH_CODSB1 AND SB1.D_E_L_E_T_ = ' ' "
	cSQL += "JOIN " + RetSqlName("SD3") + " SD3 ON SD3.D3_FILIAL = '" + xFilial("SD3") + "' "
	cSQL += "    AND SD3.D3_DOC = VBH.VBH_DOCSD3 AND SD3.D3_NUMSEQ = VBH.VBH_NUMSEQ "
	cSQL += "    AND SD3.D3_COD = VBH.VBH_CODSB1 AND SD3.D_E_L_E_T_ = ' ' "
	cSQL += "WHERE VDV.VDV_FILIAL = '" + xFilial("VDV") + "' "
	cSQL += IIf(Empty(cPARFILIAL), "", " AND (VDV.VDV_SFILNF = '" + cPARFILIAL + "' OR  VDV.VDV_EFILNF = '" + cPARFILIAL + "') ")
	cSQL += IIf(Empty(cPARCHASSI), "", " AND VV1.VV1_CHASSI = '" + cPARCHASSI + "' ")
	cSQL += IIf(Empty(cPARINIMOV), "", " AND VDV.VDV_DATMOV >= '" + DToS(cPARINIMOV) + "' ")
	cSQL += IIf(Empty(cPARFIMMOV), "", " AND VDV.VDV_DATMOV <= '" + DToS(cPARFIMMOV) + "' ")
	cSQL += IIf(Empty(cPARAGRDES) .Or. cPARAGRDES == "0", "", " AND VDV.VDV_AGRDES = '" + cPARAGRDES + "' ")
	cSQL += IIf(Empty(cPARTIPDOC) .Or. cPARTIPDOC == "0", "", " AND VDV.VDV_TIPDOC = '" + cPARTIPDOC + "' ")
	cSQL += "  AND VDV.VDV_STATUS IN (' ','1') AND VDV.D_E_L_E_T_ = ' ') "
	DBUseArea(.T., "TOPCONN", TcGenQry(,,cSQL), cAlias, .T., .F.)

	While (cAlias)->(!Eof())
		cNFSai  := ""
		cNFEnt  := ""
		cNFPSai := ""
		cNFPEnt := ""

		// Item
		cItem := AllTrim((cAlias)->(B1_COD)) + " - " + (cAlias)->(B1_DESC)

		If (cAlias)->(VDV_TIPDOC) == "2"
			// Movimentação Interna
			cNFSai := STR0015 // Mov. Interna
			cNFEnt := STR0015 // Mov. Interna
		Else
			// Nota Fiscal
			cNFSai := (cAlias)->(VDV_SNUMNF) + "-" + (cAlias)->(VDV_SSERNF) // NF Saída
			cNFEnt := (cAlias)->(VDV_ENUMNF) + "-" + (cAlias)->(VDV_ESERNF) // NF Entrada

			If !Empty((cAlias)->(VDV_SNUMNP))
				cNFPSai := (cAlias)->(VDV_SNUMNP) + "-" + (cAlias)->(VDV_SSERNP) // NF Saída Peça
			EndIf

			If !Empty((cAlias)->(VDV_ENUMNP))
				cNFPEnt := (cAlias)->(VDV_ENUMNP) + "-" + (cAlias)->(VDV_ESERNP) // NF Entrada Peça
			EndIf
		EndIf

		Aadd(aVetCon, {                                      ;
			X3CBOXDESC("VDV_AGRDES", (cAlias)->(VDV_AGRDES)),; // VDV_AGRDES                             // 01
			SToD((cAlias)->(VDV_DATMOV)),                    ; // VVDV_DATMOV (Visualização e Ordenação) // 02
			(cAlias)->(VV1_CHASSI),                          ; // VV1_CHASSI                             // 03
			(cAlias)->(VDV_SFILNF),                          ; // VDV_SFILNF                             // 04
			cNFSai,                                          ; // VDV_SNUMNF / VDV_SSERNF | Mov. Interna // 05
			cNFEnt,                                          ; // VDV_ENUMNF / VDV_ESERNF | Mov. Interna // 06
			(cAlias)->(VDV_EFILNF),                          ; // VDV_EFILNF                             // 07
			cNFPSai,                                         ; // VDV_SNUMNP / VDV_SSERNP                // 08
			cNFPEnt,                                         ; // VDV_ENUMNP / VDV_ESERNP                // 09
			cItem,                                           ; // B1_COD / B1_DESC                       // 10
			(cAlias)->(CUSTO),                               ; // C6_VALOR / D3_CUSTO1                   // 11
			(cAlias)->(VDV_NUMTRA),                          ; // VDV_NUMTRA (Apenas Ordenação)          // 12
			(cAlias)->(VDV_TRACPA)                           ; // VDV_TRACPA (Apenas Ordenação)          // 13
		})

		(cAlias)->(DBSkip())
	EndDo

	(cAlias)->(DBCloseArea())

	If !Empty(aVetCon)
		// Ordenar corretamente o array (VDV.VDV_DATMOV, VDV.VDV_NUMTRA, VDV.VDV_TRACPA)
		aSort(aVetCon,,, {|x,y| DToS(x[2]) + x[12] + x[13] < DToS(y[2]) + y[12] + y[13]})
	EndIf

	If Empty(cChassi)
		// Atualizar Grid Consulta
		oBrowse:SetArray(aVetCon)
		oBrowse:Refresh()
	Else
		// Limpando pois só é considerado na abertura da tela com chassi posicionado
		cChassi := ""
	EndIf
Return .T.