#INCLUDE "JURA235B.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE nDtIni    1  // Data Inicial
#DEFINE nDtFim    2  // Data Final
#DEFINE nSolic    3  // "Sigla Solic"
#DEFINE nDespde   4  // "Despesa de:"
#DEFINE nRevis    5  // Revisada?
#DEFINE nCliOr    6  // Cód. Cliente
#DEFINE nLojaOr   7  // Loja
#DEFINE nCaso     8  // Caso
#DEFINE nTpDesp   9  // Cod Tp Desp
#DEFINE nNatur    10 // Natureza
#DEFINE nEscri    11 // Escritório
#DEFINE nCCusto   12 // Centro de Custo
#DEFINE nProfis   13 // Sigla do Profissional
#DEFINE nTabRat   14 // Tabela de Rateio
#DEFINE nMoeda    15 // Moeda da Desp

// Variáveis para filtro do caso e centro de custo
Static cNZQcEscr := CriaVar('NZQ_CESCR', .F.)
Static cCliOr    := CriaVar('A1_COD', .F.)
Static cLojaOr   := CriaVar('A1_LOJA', .F.)

Static oTmpTable := Nil
Static cQueryTmp := ""
Static oMBrw235B := Nil
Static _lFwPDCanUse := FindFunction("FwPDCanUse")

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA235B
Monta tela de Filtros da aprovação de Despesas em Lote

@author  Jonatas Martins / Abner Fogaça
@since   24/08/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA235B(lCriaBrowse)
	Local aArea         := GetArea()
	Local aAreaNZQ      := NZQ->(GetArea())
   
	Local oDlg          := Nil
	Local oScroll       := Nil
	Local oPanel        := Nil
	Local oLayer        := Nil
	Local oMainColl     := Nil
	Local bBtOk         := Nil
   
	Local nPosLoja      := 0
	Local nLarLoja      := 0
	Local nSizeTela     := 0
	Local nTamDialog    := 0
	Local nLargura      := 280
	Local nAltura       := 340
	Local cCaso         := ""
   
	Local oDesSolic     := Nil
	Local oDesCli       := Nil
	Local oDesCas       := Nil
	Local oDesDesp      := Nil
	Local oDesNat       := Nil
	Local oDesEsc       := Nil
	Local oDesCc        := Nil
	Local oDesProf      := Nil
	Local oDesRate      := Nil
   
	Local aSize         := MsAdvSize(.F.)
	Local aFiltros      := Array(15)
   
	Local lLojaAuto     := SuperGetMv("MV_JLOJAUT", .F., "2") == "1" //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
	Local cNumCaso      := SuperGetMV('MV_JCASO1',, '1') //Defina a sequência da numeração do Caso. (1- Por cliente;2- Independente do cliente.)
	Local aCposLGPD     := {}
	Local aNoAccLGPD    := {}
	Local aDisabLGPD    := {}
	
	Default lCriaBrowse := .T.

	If lCriaBrowse // Chamada via tela de aprovação
		bBtOk := {|| IIF(J235FilTOK(aFiltros), FwMsgRun(Nil, {|| IIF(J235BTmp(aFiltros), oDlg:oOwner:End(), Nil)}, STR0004 /*"Processando"*/, STR0005 /*"Buscando dados, aguarde..."*/), Nil)}
	Else // Chamada dentro da própria aprovação em lote
		bBtOk := {|| IIF(J235FilTOK(aFiltros), FwMsgRun(Nil, {|| IIF(J235BAtuBrw(aFiltros), oDlg:oOwner:End(), Nil)}, STR0004 /*"Processando"*/, STR0005 /*"Buscando dados, aguarde..."*/), Nil)}
	EndIf

	// Retorna o tamanho da tela
	aSize     := MsAdvSize(.F.)
	nSizeTela := ((aSize[6] / 2) * 0.85) // Diminui 15% da altura.

	If nAltura > 0 .And. nSizeTela < nAltura
		nTamDialog := nSizeTela
	Else
		nTamDialog := nAltura
	EndIf


	If _lFwPDCanUse .And. FwPDCanUse(.T.)
		aCposLGPD := {"NZQ_DPART","NZQ_DCLIEN","NZQ_DCASO","NZQ_DTPDSP","NZQ_DCTADE","NZQ_DESCR","NZQ_DGRJUR","NZQ_NOMPRO","NZQ_DRATEI"}

		aDisabLGPD := FwProtectedDataUtil():UsrNoAccessFieldsInList(aCposLGPD)
		AEval(aDisabLGPD, {|x| AAdd( aNoAccLGPD, x:CFIELD)})

	EndIf
	oDlg := FWDialogModal():New()
	oDlg:SetFreeArea(nLargura, nTamDialog)
	oDlg:SetBackground(.T.)  // Escurece o fundo da janela
	oDlg:SetTitle(STR0001)   // "Aprovação de Despesas em Lote"
	oDlg:CreateDialog()
	oDlg:AddOkButton(bBtOk)
	oDlg:AddCloseButton({|| oDlg:oOwner:End() }) // "Cancelar"

	// Cria objeto Scroll
	oScroll := TScrollArea():New(oDlg:GetPanelMain(), 01, 01, 365, 545)
	oScroll:Align := CONTROL_ALIGN_ALLCLIENT

	@ 000, 000 MSPANEL oPanel OF oScroll SIZE nLargura, nAltura

	oLayer := FwLayer():New()
	oLayer:Init(oPanel, .F.)
	oLayer:addCollumn("MainColl", 100, .F.) //Cria as colunas do Layer
	oMainColl := oLayer:GetColPanel( 'MainColl' )

	// Define objeto painel como filho do scroll
	oScroll:SetFrame( oPanel )

	// Data de
	aFiltros[nDtIni] := TJurPnlCampo():New(005, 015, 060, 022, oMainColl, STR0002, ("NZQ_DTINCL"), {|| }, {|| },,,,) // "Data de"
	aFiltros[nDtIni]:SetValid({|| J235ValDt(aFiltros[nDtIni]:GetValue())})

	// Data até
	aFiltros[nDtFim] := TJurPnlCampo():New(005, 085, 060, 022, oMainColl, STR0003, ("NZQ_DTINCL"), {|| }, {|| },,,,) // "Data até"
	aFiltros[nDtFim]:SetValid({|| J235ValDt(aFiltros[nDtFim]:GetValue()) .And. J235DtFVld(aFiltros[nDtIni]:GetValue(), aFiltros[nDtFim]:GetValue())})

	// "Sigla Solic"
	aFiltros[nSolic] := TJurPnlCampo():New(035, 015, 060, 022, oMainColl, AllTrim(RetTitle("NZQ_SIGLA")), ("NZQ_SIGLA"), {|| }, {|| },,,, 'RD0ATV')
	aFiltros[nSolic]:SetValid({|| J235BSetChg(aFiltros[nSolic], @oDesSolic, "RD0A") })

	// "Nome Solic" //
	oDesSolic := TJurPnlCampo():New(035, 085, 180, 022, oMainColl, AllTrim(RetTitle("NZQ_DPART ")), ("NZQ_DPART "), {|| }, {|| },,,,,,,,,aScan(aNoAccLGPD,"NZQ_DPART") > 0)
	oDesSolic:SetWhen({|| .F.})

	// "Despesa de:"
	aFiltros[nDespde] := TJurPnlCampo():New(065, 015, 060, 025, oMainColl, AllTrim(RetTitle("NZQ_DESPES")), ("NZQ_DESPES"), {|| }, {|| },,,,,,,, .F.)
	aFiltros[nDespde]:SetChange({|| cCliOr := CriaVar("A1_COD", .F.), cLojaOr := IIF(lLojaAuto,JurGetLjAt(), CriaVar("A1_LOJA", .F.)),;
									aFiltros[nCliOr]:Clear() , IIF(lLojaAuto, Nil, aFiltros[nLojaOr]:Clear()), oDesCli:Clear(),;
									aFiltros[nCaso]:Clear()  , oDesCas:Clear() ,;
									aFiltros[nTpDesp]:Clear(), oDesDesp:Clear(),;
									aFiltros[nNatur]:Clear() , oDesNat:Clear() ,;
									aFiltros[nEscri]:Clear() , oDesEsc:Clear() ,;
									aFiltros[nCCusto]:Clear(), oDesCc:Clear()  ,;
									aFiltros[nProfis]:Clear(), oDesProf:Clear(),;
									aFiltros[nTabRat]:Clear(), oDesRate:Clear()})

	// "Revisada?"
	aFiltros[nRevis] := TJurPnlCampo():New(065, 085, 060, 025, oMainColl, AllTrim(RetTitle("NZQ_REVISA")), '', {|| }, {|| },,,,,, J235CBox("NZQ_REVISA"))

	// "Cód Cliente"
	aFiltros[nCliOr] := TJurPnlCampo():New(095, 015, 060, 022, oMainColl, AllTrim(RetTitle("NZQ_CCLIEN")), ("NZQ_CCLIEN"), {|| }, {|| },,,, 'SA1NUH')
	aFiltros[nCliOr]:SetChange({|| cCliOr := aFiltros[nCliOr]:GetValue()})
	aFiltros[nCliOr]:SetValid({|| JurTrgGCLC(/*oGrupo*/, /*cGrupo*/, @aFiltros[nCliOr], @cCliOr, @aFiltros[nLojaOr], @cLojaOr, @aFiltros[nCaso], @cCaso, "CLI",,, @oDesCli, , @oDesCas) })
	aFiltros[nCliOr]:SetWhen({|| aFiltros[nDespde]:GetValue() == "1"})

	// "Loja"
	aFiltros[nLojaOr] := TJurPnlCampo():New(095, 085, 030, 022, oMainColl, AllTrim(RetTitle("NZQ_CLOJA")), ("NZQ_CLOJA"), {|| }, {|| },,,)
	aFiltros[nLojaOr]:SetChange({|| cLojaOr := aFiltros[nLojaOr]:GetValue()})
	aFiltros[nLojaOr]:SetValid({|| JurTrgGCLC(/*oGrupo*/, /*cGrupo*/ , @aFiltros[nCliOr], @cCliOr, @aFiltros[nLojaOr], @cLojaOr, @aFiltros[nCaso], @cCaso, "LOJ",,, @oDesCli, , @oDesCas) })
	aFiltros[nLojaOr]:SetWhen({|| aFiltros[nDespde]:GetValue() == "1"})
	If lLojaAuto
		aFiltros[nLojaOr]:Hide()
		aFiltros[nLojaOr]:SetValue(JurGetLjAt())
		cLojaOr  := JurGetLjAt()
		nPosLoja := 085
		nLarLoja := 180
	Else
		nPosLoja := 115
		nLarLoja := 150
	EndIf

	// "Desc Cliente"
	oDesCli := TJurPnlCampo():New(095, nPosLoja, nLarLoja, 022, oMainColl, AllTrim(RetTitle("NZQ_DCLIEN")), ("NZQ_DCLIEN"), {|| }, {|| },,,,,,,,,aScan(aNoAccLGPD,"NZQ_DCLIEN") > 0)
	oDesCli:SetWhen({|| .F.})

	// "Caso"
	aFiltros[nCaso] := TJurPnlCampo():New(125, 015, 060, 022, oMainColl, AllTrim(RetTitle("NZQ_CCASO")), ("NZQ_CCASO"), {|| }, {|| },,,, 'NVELOJ')
	aFiltros[nCaso]:SetChange({|| cCaso := aFiltros[nCaso]:GetValue()})
	aFiltros[nCaso]:SetValid({|| JurTrgGCLC(/*oGrupo*/, /*cGrupo*/, @aFiltros[nCliOr], @cCliOr, @aFiltros[nLojaOr], @cLojaOr, @aFiltros[nCaso], @cCaso, "CAS",,, @oDesCli, , @oDesCas) })
	aFiltros[nCaso]:SetWhen({|| aFiltros[nDespde]:GetValue() == "1" .And. ;
	                           (cNumCaso == "2" .Or. (cNumCaso == "1" .And. !Empty(aFiltros[nCliOr]:GetValue()) .And. !Empty(aFiltros[nLojaOr]:GetValue())))})

	// "Desc Caso"
	oDesCas := TJurPnlCampo():New(125, 085, 180, 022, oMainColl, AllTrim(RetTitle("NZQ_DCASO")), ("NZQ_DCASO"), {|| }, {|| },,,,,,,,,aScan(aNoAccLGPD,"NZQ_DCASO") > 0)
	oDesCas:SetWhen({||.F.})

	// "Cód Tp Desp"
	aFiltros[nTpDesp] := TJurPnlCampo():New(155, 015, 060, 022, oMainColl, AllTrim(RetTitle("NZQ_CTPDSP")), ("NZQ_CTPDSP"), {|| }, {|| },,,, 'NRH')
	aFiltros[nTpDesp]:SetValid({|| J235BSetChg(aFiltros[nTpDesp], @oDesDesp, "NRH") })
	aFiltros[nTpDesp]:SetWhen({|| aFiltros[nDespde]:GetValue() == "1"})

	// "Desc Tp Desp"
	oDesDesp := TJurPnlCampo():New(155, 085, 140, 022, oMainColl, AllTrim(RetTitle("NZQ_DTPDSP")), ("NRH_DESC"), {|| }, {|| },,,,,,,,,aScan(aNoAccLGPD,"NZQ_DTPDSP") > 0)
	oDesDesp:SetWhen({|| .F.})

	// "Moeda Desp"
	aFiltros[nMoeda] := TJurPnlCampo():New(155, 225, 040, 022, oMainColl, AllTrim(RetTitle("NZQ_CMOEDA")), ("NZQ_CMOEDA"), {|| }, {|| },,,, 'JURCTO')
	aFiltros[nMoeda]:SetValid({|| J235BSetChg(aFiltros[nMoeda], , "CTO") })

	// "Natureza"
	aFiltros[nNatur] := TJurPnlCampo():New(185, 015, 060, 022, oMainColl, AllTrim(RetTitle("NZQ_CTADES")), ("NZQ_CTADES"), {|| }, {|| },,,, 'SEDOHB')
	aFiltros[nNatur]:SetWhen({|| aFiltros[nDespde]:GetValue() == "2"})
	aFiltros[nNatur]:SetValid({|| J235BSetChg(aFiltros[nNatur], @oDesNat, "SED") })

	// "Desc Naturez"
	oDesNat := TJurPnlCampo():New(185, 085, 180, 022, oMainColl, AllTrim(RetTitle("NZQ_DCTADE")), ("ED_DESCRIC"), {|| }, {|| },,,,,,,,,aScan(aNoAccLGPD,"NZQ_DCTADE") > 0)
	oDesNat:SetWhen({|| .F.})

	// "Escritório"
	aFiltros[nEscri] := TJurPnlCampo():New(215, 015, 060, 022, oMainColl, AllTrim(RetTitle("NZQ_CESCR")), ("NZQ_CESCR"), {|| }, {|| },,,, 'NS7ATV')
	aFiltros[nEscri]:SetWhen({|| aFiltros[nDespde]:GetValue() == "2"})
	aFiltros[nEscri]:SetValid({|| J235BSetChg(@aFiltros[nEscri], @oDesEsc, "NS7", , {aFiltros[nCCusto], oDesCc}) })

	// "Desc. Escrit" //
	oDesEsc := TJurPnlCampo():New(215, 085, 180, 022, oMainColl, AllTrim(RetTitle("NZQ_DESCR")), ("NZQ_DESCR"), {|| }, {|| },,,,,,,,,aScan(aNoAccLGPD,"NZQ_DESCR") > 0)
	oDesEsc:SetWhen({|| .F.})

	// "Centro de Custo"
	aFiltros[nCCusto] := TJurPnlCampo():New(245, 015, 060, 022, oMainColl, AllTrim(RetTitle("NZQ_GRPJUR")), ("NZQ_GRPJUR"), {|| }, {|| },,,, 'CTTNS7')
	aFiltros[nCCusto]:SetValid({|| J235BSetChg(aFiltros[nCCusto], @oDesCc, "CTT", {aFiltros[nEscri]} ) })
	aFiltros[nCCusto]:SetWhen({|| aFiltros[nDespde]:GetValue() == "2" .And. !Empty(aFiltros[nEscri]:GetValue())})

	//"Desc C Custo" 
	oDesCc := TJurPnlCampo():New(245, 085, 180, 022, oMainColl, AllTrim(RetTitle("NZQ_DGRJUR")), ("NZQ_DGRJUR"), {|| }, {|| },,,,,,,,,aScan(aNoAccLGPD,"NZQ_DGRJUR") > 0)
	oDesCc:SetWhen({|| .F.})

	// "Profissional"
	aFiltros[nProfis] := TJurPnlCampo():New(275, 015, 060, 022, oMainColl, AllTrim(RetTitle("NZQ_SIGPRO")), ("NZQ_SIGPRO"), {|| }, {|| },,,, 'RD0REV')
	aFiltros[nProfis]:SetValid({|| J235BSetChg(aFiltros[nProfis], @oDesProf, "RD0B") })

	// "Nome Profissional"
	oDesProf := TJurPnlCampo():New(275, 085, 180, 022, oMainColl, AllTrim(RetTitle("NZQ_NOMPRO")), ("NZQ_NOMPRO"), {|| }, {|| },,,,,,,,,aScan(aNoAccLGPD,"NZQ_NOMPRO") > 0)
	oDesProf:SetWhen({|| .F.})

	// "Tabela de Rateio"
	aFiltros[nTabRat] := TJurPnlCampo():New(305, 015, 060, 022, oMainColl, AllTrim(RetTitle("NZQ_CRATEI")), ("NZQ_CRATEI"), {|| }, {|| },,,, 'OH6')
	aFiltros[nTabRat]:SetValid({|| J235BSetChg(aFiltros[nTabRat], @oDesRate, "OH6") })

	// "Desc. Rateio" //
	oDesRate := TJurPnlCampo():New(305, 085, 180, 022, oMainColl, AllTrim(RetTitle("NZQ_DRATEI")), ("NZQ_DRATEI"), {|| }, {|| },,,,,,,,,aScan(aNoAccLGPD,"NZQ_DRATEI") > 0)
	oDesRate:SetWhen({|| .F.})

	oDlg:Activate()

	RestArea(aAreaNZQ)
	RestArea(aArea)

	JurFreeArr(aFiltros)
	FreeObj(oPanel)
	FreeObj(oLayer)
	FreeObj(oScroll)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J235CBox
Adicona a opção "Todos" nos campos do tipo combo

@Param   cCampo     , caracter, Campo do tipo combo
@Return  cListItens , caracter, Opções do combo

@author  Jonatas Martins / Abner Fogaça
@since   24/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J235CBox(cCampo)
	Local aOptions    := {}
	Local nQtdOptions := 0
	Local cListItens  := ""

	aOptions    := StrToKarr(JurX3cBox(cCampo), ";")
	nQtdOptions := Len(aOptions) + 1
	cListItens  := AtoC(aOptions, ";") + ";" + cValToChar(nQtdOptions) + STR0006 // "=Todos"

Return (cListItens)

//-------------------------------------------------------------------
/*/{Protheus.doc} J235ValDt()
Validação de Data

@Param   dData, Data  , Data digitada
@Return  lRet , logico, Verdadeiro / Falso

@author  Jonatas Martins / Abner Fogaça
@since   24/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J235ValDt(dData)
	Local lRet := .T.

	If ! Empty(dData)
		If dData > Date()
			lRet := .F.
			JurMsgErro(STR0007) // "A data informada não pode ser maior que a data de hoje!"
		EndIf
	EndIf

Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} J235DtFVld
Validação de Data Final

@Param   dDataIni, Data  , Data inicial
@Param   dDataFim, Data  , Data final
@Return  lRet    , logico, Verdadeiro / Falso

@author  Jonatas Martins / Abner Fogaça
@since   24/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J235DtFVld(dDataIni, dDataFim)
	Local lRet := .T.

	If ! Empty(dDataIni) .And. ! Empty(dDataFim)
		If dDataIni > dDataFim
			lRet := .F.
			JurMsgErro(STR0008) // "A data inicial não pode ser maior que a data de final!"
		EndIf
	EndIf

Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} J235VldPro
Validação de Profissional

@Param   cSiglaProf, caracter, Sigla do Profissional
@Return  lRet      , logico, Verdadeiro / Falso

@author  Jonatas Martins / Abner Fogaça
@since   24/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J235VldPro(cSiglaProf)
	Local cPart := ""
	Local aProf := {}
	Local lRet  := .T.

	cPart := JurGetDados("RD0", 9, xFilial("RD0") + cSiglaProf, "RD0_CODIGO")
	aProf := JurGetDados("NUR", 1, xFilial("NUR") + cPart, {"NUR_SOCIO", "NUR_REVFAT"})
	If aProf[1] <> "1" .And. aProf[2]  <> "1"
		lRet := .F.
		JurMsgErro(STR0009) // "Profissional inválido!"
	EndIf

Return (lRet)

//-------------------------------------------------------------------
/*/ { Protheus.doc } J235BSetChg
Função para validar os campos e executar os gatilhos

@param oCod     , objeto   , Objeto que contém o código do registro
@param oDesc    , objeto   , Objeto que contém a descrição do registro
@param cTab     , caractere, Tabela onde serão localizadas as informações
@param aAux     , array    , Array com Objeto(s) para informações auxiliares de validação
@param aLimpa   , array    , Array com Objeto(s) que devem ter seu conteúdo limpo

@Return  lRet   , logico   ,  Indica se o preenchimento do campo está correto

@author  Jorge Martins
@since   28/08/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J235BSetChg(oCod, oDesc, cTab, aAux, aLimpa)
Local lRet      := .T.
Local nI        := 0
Local cCod      := oCod:GetValue()
Local cDesc     := ""
Local cEscrit   := ""
Local aErro     := {}
Local aRetDados := {}

Default oDesc   := Nil
Default aAux    := {}
Default aLimpa  := {}

Do Case
	Case cTab == "RD0A" // Solicitante
		
		lRet := Empty(cCod) .Or. ExistCpo('RD0', cCod, 9)

		If lRet .And. !Empty(cCod)
			cDesc := JurGetDados("RD0", 9, xFilial("RD0") + cCod, "RD0_NOME" )
		EndIf

	Case cTab == "RD0B" // Profissional
		
		lRet := Empty(cCod) .Or. ( ExistCpo('RD0', cCod, 9) .And. J235VldPro(cCod) )

		If lRet .And. !Empty(cCod)
			cDesc := JurGetDados("RD0", 9, xFilial("RD0") + cCod, "RD0_NOME" )
		EndIf

	Case cTab == "NRH" // Tipo de Despesa

		aRetDados := JurGetDados("NRH", 1, xFilial("NRH") + cCod, {"NRH_DESC", "NRH_ATIVO"})
		
		If !Empty(cCod)
			lRet := Len(aRetDados) == 2 .And. aRetDados[2] == '1' /*NRH_ATIVO*/

			If lRet
				cDesc := aRetDados[1]
			Else
				aErro := {STR0016, STR0017} // "Tipo de despesa inválida ou inexistente." "Informe um código válido para o tipo de despesa. Serão aceitos somente tipos de despesa ativos."
			EndIf
		EndIf

	Case cTab == "CTO" // Moeda

		aRetDados := JurGetDados("CTO", 1, xFilial("CTO") + cCod, {"CTO_DESC", "CTO_BLOQ"})
		
		If !Empty(cCod)
			lRet := Len(aRetDados) == 2 .And. aRetDados[2] == '2' /*CTO_BLOQ*/

			If !lRet
				aErro := {STR0022, STR0023} // "Moeda inválida ou inexistente." "Informe um código válido para a moeda. Serão aceitas somente moedas não bloqueadas."
			EndIf
		EndIf

	Case cTab == "SED" // Natureza

		aRetDados := JurGetDados("SED", 1, xFilial("SED") + cCod, {"ED_DESCRIC", "ED_MSBLQL"})

		If !Empty(cCod)
			lRet := Len(aRetDados) == 2 .And. aRetDados[2] != '1' /*ED_MSBLQL*/

			If lRet
				cDesc := aRetDados[1]
			Else
				aErro := {STR0020, STR0021} // "Natureza inválida ou inexistente." "Informe um código válido para a natureza. Serão aceitas somente naturezas não bloqueadas."
			EndIf
		EndIf

	Case cTab == "NS7" // Escritório

		aRetDados := JurGetDados("NS7", 1, xFilial("NS7") + cCod, {"NS7_NOME", "NS7_ATIVO"})

		If !Empty(cCod)
			lRet := Len(aRetDados) == 2 .And. aRetDados[2] == '1' /*NS7_ATIVO*/

			If lRet
				cDesc     := aRetDados[1]
				cNZQcEscr := cCod // Seta variavel private para uso no F3 de Centro de Custo
			Else
				aErro := {STR0014, STR0015} // "Escritório inválido ou inexistente." "Informe um código válido para o escritório. Serão aceitos somente escritórios ativos."
			EndIf
		EndIf

		If Len(aLimpa) > 0 .And. oCod:GetValueOld() != cCod
			For nI := 1 To Len(aLimpa)
				aLimpa[nI]:Clear()
			Next 
		EndIf

		oCod:SetValueOld(cCod)

	Case cTab == "CTT" // Centro de Custo
		
		aRetDados := JurGetDados("CTT", 1, xFilial("CTT") + cCod, {"CTT_DESC01", "CTT_BLOQ", "CTT_CLASSE", "CTT_CESCRI"})

		If !Empty(cCod)

			If Len(aAux) == 1
				cEscrit := aAux[1]:GetValue()
			EndIf

			lRet := Len(aRetDados) == 4 .And. aRetDados[2] == '2' /*CTT_BLOQ*/ .And. aRetDados[2] == '2' /*CTT_CLASSE*/ .And. aRetDados[4] == cEscrit

			If lRet
				cDesc := aRetDados[1]
			Else
				aErro := {STR0018, I18n(STR0019, {cEscrit})} // "Centro de custo inválido." "Informe um código válido para o centro de custo. Serão aceitos somente centros de custo de classe analitica e não bloqueados que estejam vinculados ao escritório '#1'."
			EndIf
		EndIf

	Case cTab == "OH6" // Tabela de Rateio

		aRetDados := JurGetDados("OH6", 1, xFilial("OH6") + cCod, {"OH6_DESCRI", "OH6_ATIVO"} )
		
		lRet := Empty(cCod) .Or. ExistCpo('OH6', cCod, 1)

		If lRet .And. !Empty(cCod)
			cDesc := JurGetDados("OH6", 1, xFilial("OH6") + cCod, "OH6_DESCRI" )
		EndIf

EndCase

If lRet .And. oDesc <> Nil // Existem campos que não tem descrição. Ex: Moeda
	If Empty(cDesc)
		oDesc:SetValue("")
	Else
		oDesc:SetValue(cDesc)
	EndIf

ElseIf Len(aErro) > 0
	JurMsgErro(aErro[1],, aErro[2])
EndIf

JurFreeArr(aErro)
JurFreeArr(aRetDados)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J235FilTOK
Validação na confirmação da tela de filtros

@Param   aFiltros, array , Array com objetos da tela de filtro
@Return  lRet    , logico, Verdadeiro / Falso

@author  Jonatas Martins / Abner Fogaça
@since   24/08/2017
@version 1.0
@obs     Variáveis cCliOr e cLojaOr são privates
/*/
//-------------------------------------------------------------------
Static Function J235FilTOK(aFiltros)
	Local cTpDesp := aFiltros[nDespde]:GetValue()
	Local cCaso   := aFiltros[nCaso]:GetValue()
	Local lRet    := .T.
	Local cCampo  := ""

	If Empty(cTpDesp)
		lRet   := .F.
		cCampo := AllTrim(RetTitle("NZQ_DESPES"))
		JurMsgErro( I18n(STR0068, {cCampo}), ,; // "É obrigatório preencher o filtro '#1'."
		            I18n(STR0069, {cCampo}) ) // "Selecione uma opção valida no filtro '#1'."
	EndIf

	If lRet .And. cTpDesp == "1" // Cliente
		If ! Empty(cCliOr) .And. ! Empty(cLojaOr) .And. ! Empty(cCaso) .And. ;
			Empty(JurGetDados("NVE", 1, xFilial("NVE") + cCliOr + cLojaOr + cCaso, "NVE_NUMCAS"))
			lRet := .F.
			JurMsgErro(STR0010) // "Cliente, loja e caso inválido!"
		EndIf
	EndIf

Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} J235BTmp
Monta tabela temporária de despesas com base nos filtros

@param aFiltros, array , Dados de filtro para carga do browse

@author  Jonatas Martins / Abner Fogaça
@since   24/08/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J235BTmp(aFiltros)
    Local aStruAdic  := J235StruAdic()
	Local aCmpAcBrw  := J235CmpAcBrw()
	Local aCmpNotBrw := J235NotBrw()
	Local aTemp      := {}
	Local aFldsFilt  := {}
	Local aOrder     := {}
	Local aFields    := {}
	Local aOfusca    := {}
	Local cAliasNZQ  := Nil
	Local lRet       := .T.

	cQueryTmp  := J235Query(aFiltros)
	aTemp      := JurCriaTmp(GetNextAlias(), cQueryTmp, "NZQ", , aStruAdic, aCmpAcBrw, aCmpNotBrw)
	oTmpTable  := aTemp[1]
	aFldsFilt  := aTemp[2]
	aOrder     := aTemp[3]
	aFields    := aTemp[4]
	aOfusca    := IIf(Len(aTemp) >= 7 .And. !Empty(aTemp[7]), aTemp[7], {})
	cAliasNZQ  := oTmpTable:GetAlias()

	If (cAliasNZQ)->(Eof())
		lRet := .F.
		ApMsgInfo(STR0011) // "Não foi encontrado nenhum registro!"
	Else
		J235BMBrw(cAliasNZQ, aFields, aOrder, aFldsFilt, aOfusca)
	EndIf

	oTmpTable:Delete()

	JurFreeArr(aStruAdic)
	JurFreeArr(aCmpAcBrw)
	JurFreeArr(aCmpNotBrw)
	JurFreeArr(aTemp)
	JurFreeArr(aFldsFilt)
	JurFreeArr(aOrder)
	JurFreeArr(aFields)
	JurFreeArr(aOfusca)

Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} J235Query
Monta query para a tabela temporaria

@param   aFiltros  , array   , Dados de filtro para carga do browse

@return  cQuery    , caracter, Busca registro no banco

@author  Jonatas Martins / Abner Fogaça
@since   24/08/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J235Query(aFiltros)
	Local cDataIni  := DtoS(aFiltros[nDtIni]:GetValue()) // Data Inicial
	Local cDataFim  := DtoS(aFiltros[nDtFim]:GetValue()) // Data Final
	Local cSolic    := aFiltros[nSolic]:GetValue() // "Sigla Solic"
	Local cDespde   := aFiltros[nDespde]:GetValue() // "Despesa de:"
	Local cRevis    := aFiltros[nRevis]:GetValue() // Revisada?
	Local cCodCli   := aFiltros[nCliOr]:GetValue() // Cód. Cliente
	Local cLojaCli  := aFiltros[nLojaOr]:GetValue() // Loja
	Local cCaso     := aFiltros[nCaso]:GetValue() // Caso
	Local cTpDesp   := aFiltros[nTpDesp]:GetValue() // Cod Tp Desp
	Local cMoeda    := aFiltros[nMoeda]:GetValue() // Moeda da Desp
	Local cNatur    := aFiltros[nNatur]:GetValue() // Natureza
	Local cEscri    := aFiltros[nEscri]:GetValue() // Escritório
	Local cCCusto   := aFiltros[nCCusto]:GetValue() // Centro de Custo
	Local cProfis   := aFiltros[nProfis]:GetValue() // Sigla do Profissional
	Local cTabRat   := aFiltros[nTabRat]:GetValue() // Tabela de Rateio
	Local cPart     := ""

	Local cQuery    := ""
	Local cCampos   := JurCmpSelc("NZQ")
	Local aCamposJL := {}
	Local cCamposJL := ''
	Local cNvCampos := " NZQ.R_E_C_N_O_ REC "

	Aadd(aCamposJL,{"SA1.A1_NOME"    , "NZQ_DCLIEN"})
	Aadd(aCamposJL,{"NVE.NVE_TITULO" , "NZQ_DCASO" })
	Aadd(aCamposJL,{"RD0.RD0_SIGLA"  , "NZQ_SIGLA" })
	Aadd(aCamposJL,{"RD0.RD0_NOME"   , "NZQ_DPART" })
	Aadd(aCamposJL,{"RD0.RD0_NOME"   , "NZQ_SIGRES"})
	Aadd(aCamposJL,{"RD0.RD0_NOME"   , "NZQ_NOMRES"})
	Aadd(aCamposJL,{"CTO.CTO_SIMB"   , "NZQ_DMOEDA"})
	Aadd(aCamposJL,{"NRH.NRH_DESC"   , "NZQ_DTPDSP"})
	Aadd(aCamposJL,{"NTP.NTP_DESC"   , "NZQ_DLOCAL"})
	Aadd(aCamposJL,{"NUO.NUO_DESC"   , "NZQ_DTPCTA"})
	Aadd(aCamposJL,{"NS7.NS7_NOME"   , "NZQ_DESCR" })
	Aadd(aCamposJL,{"CTT.CTT_DESC01" , "NZQ_DGRJUR"})
	Aadd(aCamposJL,{"SED.ED_DESCRIC" , "NZQ_DCTADE"})
	Aadd(aCamposJL,{"RD0.RD0_NOME"   , "NZQ_NOMPRO"})
	Aadd(aCamposJL,{"OH6.OH6_DESCRI" , "NZQ_DRATEI"})

	cCamposJL := JurCaseJL(aCamposJL)

	cQuery := "SELECT ' ' NZQ_OK, "+ cCampos + cCamposJL + cNvCampos + CRLF
	cQuery +=  " FROM " + RetSqlName("NZQ") + " NZQ "
	cQuery += " LEFT JOIN "+ RetSqlName( 'SA1' ) + " SA1 "
	cQuery +=                                         " ON  SA1.A1_FILIAL = '" + xFilial("SA1") + "' "
	cQuery +=                                         " AND SA1.A1_COD = NZQ.NZQ_CCLIEN "
	cQuery +=                                         " AND SA1.A1_LOJA = NZQ.NZQ_CLOJA "
	cQuery +=                                         " AND SA1.D_E_L_E_T_ = ' ' "
	cQuery += " LEFT JOIN "+ RetSqlName( 'NVE' ) + " NVE "
	cQuery +=                                         " ON  NVE.NVE_FILIAL = '" + xFilial("NVE") + "' "
	cQuery +=                                         " AND NVE.NVE_CCLIEN = NZQ.NZQ_CCLIEN "
	cQuery +=                                         " AND NVE.NVE_LCLIEN = NZQ.NZQ_CLOJA "
	cQuery +=                                         " AND NVE.NVE_NUMCAS = NZQ.NZQ_CCASO "
	cQuery +=                                         " AND NVE.D_E_L_E_T_ = ' ' "
	cQuery += " LEFT JOIN "+ RetSqlName( 'RD0' ) + " RD0 "
	cQuery +=                                         " ON  RD0.RD0_FILIAL = '" + xFilial("RD0") + "' "
	cQuery +=                                         " AND RD0.RD0_CODIGO = NZQ.NZQ_CPART "
	cQuery +=                                         " AND RD0.D_E_L_E_T_ = ' ' "
	cQuery += " LEFT JOIN "+ RetSqlName( 'CTO' ) + " CTO"
	cQuery +=                                         " ON  CTO.CTO_FILIAL = '" + xFilial("CTO") + "' "
	cQuery +=                                         " AND CTO.CTO_MOEDA = NZQ.NZQ_CMOEDA "
	cQuery +=                                         " AND CTO.D_E_L_E_T_ = ' ' "
	cQuery += " LEFT JOIN "+ RetSqlName( 'NRH' ) + " NRH"
	cQuery +=                                         " ON  NRH.NRH_FILIAL = '" + xFilial("NRH") + "' "
	cQuery +=                                         " AND NRH.NRH_COD = NZQ.NZQ_CTPDSP "
	cQuery +=                                         " AND NRH.D_E_L_E_T_ = ' ' "
	cQuery += " LEFT JOIN "+ RetSqlName( 'NTP' ) + " NTP"
	cQuery +=                                         " ON  NTP.NTP_FILIAL = '" + xFilial("NTP") + "' "
	cQuery +=                                         " AND NTP.NTP_COD = NZQ.NZQ_CLOCAL "
	cQuery +=                                         " AND NTP.D_E_L_E_T_ = ' ' "
	cQuery += " LEFT JOIN "+ RetSqlName( 'NUO' ) + " NUO"
	cQuery +=                                         " ON  NUO.NUO_FILIAL = '" + xFilial("NUO") + "' "
	cQuery +=                                         " AND NUO.NUO_COD = NZQ.NZQ_CTPCTA "
	cQuery +=                                         " AND NUO.D_E_L_E_T_ = ' ' "
	cQuery += " LEFT JOIN "+ RetSqlName( 'NS7' ) + " NS7"
	cQuery +=                                         " ON  NS7.NS7_FILIAL = '" + xFilial("NS7") + "' "
	cQuery +=                                         " AND NS7.NS7_COD = NZQ.NZQ_CESCR "
	cQuery +=                                         " AND NS7.D_E_L_E_T_ = ' ' "
	cQuery += " LEFT JOIN "+ RetSqlName( 'CTT' ) + " CTT"
	cQuery +=                                         " ON  CTT.CTT_FILIAL = '" + xFilial("CTT") + "' "
	cQuery +=                                         " AND CTT.CTT_CUSTO = NZQ.NZQ_GRPJUR "
	cQuery +=                                         " AND CTT.D_E_L_E_T_ = ' ' "
	cQuery += " LEFT JOIN "+ RetSqlName( 'SED' ) + " SED"
	cQuery +=                                         " ON  SED.ED_FILIAL = '" + xFilial("SED") + "' "
	cQuery +=                                         " AND SED.ED_CODIGO = NZQ.NZQ_CTADES "
	cQuery +=                                         " AND SED.D_E_L_E_T_ = ' ' "
	cQuery += " LEFT JOIN "+ RetSqlName( 'OH6' ) + " OH6"
	cQuery +=                                         " ON  OH6.OH6_FILIAL = '" + xFilial("OH6") + "' "
	cQuery +=                                         " AND OH6.OH6_CODIGO = NZQ.NZQ_CRATEI "
	cQuery +=                                         " AND OH6.D_E_L_E_T_ = ' ' "
	cQuery +=  "WHERE NZQ.NZQ_FILIAL = '" + xFilial("NZQ") + "' "
	cQuery +=  "  AND NZQ.NZQ_SITUAC = '1' "

	If ! Empty(cDataIni) .And. ! Empty(cDataFim)
		cQuery +=   " AND (NZQ.NZQ_DTINCL BETWEEN '" + cDataIni + "' AND '" + cDataFim + "')
	ElseIf ! Empty(cDataIni)
		cQuery +=   " AND NZQ.NZQ_DTINCL >= '" + cDataIni + "' "
	ElseIf ! Empty(cDataFim)
		cQuery +=   " AND NZQ.NZQ_DTINCL <= '" + cDataFim + "' "
	EndIf

	If ! Empty(cSolic)
		cPart := JurGetDados("RD0", 9, xFilial("RD0") + cSolic, "RD0_CODIGO")
		cQuery +=   " AND NZQ.NZQ_CPART  = '" + cPart + "' "
	EndIf

	If cDespde $ "1|2"
		cQuery +=   " AND NZQ.NZQ_DESPES = '" + cDespde + "' "
	EndIf

	If cRevis $ "1|2"
		cQuery +=   " AND NZQ.NZQ_REVISA = '" + cRevis + "' "
	EndIf

	If cDespde == "1" // Cliente
		If ! Empty(cCodCli)
			cQuery +=   " AND NZQ.NZQ_CCLIEN = '" + cCodCli + "' "
		EndIf
		
		If ! Empty(cLojaCli)
			cQuery +=   " AND NZQ.NZQ_CLOJA  = '" + cLojaCli + "' "
		EndIf

		If ! Empty(cCaso)
			cQuery +=   " AND NZQ.NZQ_CCASO  = '" + cCaso + "' "
		EndIf
	ElseIf cDespde == "2" // Escritório
		If ! Empty(cNatur)
			cQuery +=   " AND NZQ.NZQ_CTADES = '" + cNatur + "' "
		EndIf

		If ! Empty(cEscri)
			cQuery +=   " AND NZQ.NZQ_CESCR = '" + cEscri + "' "
		EndIf

		If ! Empty(cCCusto)
			cQuery +=   " AND NZQ.NZQ_GRPJUR = '" + cCCusto + "' "
		EndIf
	EndIf

	If ! Empty(cTpDesp)
		cQuery +=   " AND NZQ.NZQ_CTPDSP = '" + cTpDesp + "' "
	EndIf

	If ! Empty(cMoeda)
		cQuery +=   " AND NZQ.NZQ_CMOEDA = '" + cMoeda + "' "
	EndIf

	If ! Empty(cProfis)
		cPart := JurGetDados("RD0", 9, xFilial("RD0") + cProfis, "RD0_CODIGO")
		cQuery +=   " AND NZQ.NZQ_CODPRO = '" + cPart + "' "
	EndIf

	If ! Empty(cTabRat)
		cQuery +=   " AND NZQ.NZQ_CRATEI = '" + cTabRat + "' "
	EndIf

	cQuery +=   " AND NZQ.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)

Return (cQuery)

//-------------------------------------------------------------------
/*/{Protheus.doc} J235StruAdic
Estrutura adicional para incluir na tabela temporária caso exista na query. - Opcional
        Ex: aStruAdic[n][1] "NVE_SITUAC"     //Nome do campo
            aStruAdic[n][2] "Situação"       //Descrição do campo
            aStruAdic[n][3] "C"              //Tipo
            aStruAdic[n][4] 1                //Tamanho
            aStruAdic[n][5] 0                //Decimal
            aStruAdic[n][6] "@X"             //Picture

@return aStruAdic, array, Campos da estutrura adicional

@author  Jonatas Martins / Abner Fogaça
@since   24/08/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J235StruAdic()
	Local aStruAdic := {}

	Aadd(aStruAdic, {"NZQ_OK", "", "C", 1, 0, ""})
	Aadd(aStruAdic, {"REC", "REC", "N", 100, 0, ""})

Return (aStruAdic)

//-------------------------------------------------------------------
/*/{Protheus.doc} J235CmpAcBrw
Monta array simples de campos onde o X3_BROWSE está como NÃO e devem
ser considerados no Browse (independentemente do seu uso)

@return aCmpAcBrw, array, Campos onde o X3_BROWSE está como NÃO e devem
		ser considerados no Browse

@author  Jonatas Martins / Abner Fogaça
@since   24/08/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J235CmpAcBrw()
	Local aCmpAcBrw := {}

	aCmpAcBrw := {"NZQ_COBRAR"}

Return ( aCmpAcBrw )

//-------------------------------------------------------------------
/*/{Protheus.doc} J235NotBrw
Monta array para remover campos do browse

@return aCmpNotBrw, array, Campos para não aparecer no browse

@author  Jonatas Martins / Abner Fogaça
@since   24/08/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J235NotBrw()
	Local aCmpNotBrw := {}
	Local lLojaAuto  := SuperGetMv( "MV_JLOJAUT", .F., "2", ) == '1' //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)

	Aadd(aCmpNotBrw, "REC")
	Aadd(aCmpNotBrw, "NZQ_OK")

	If lLojaAuto
		Aadd(aCmpNotBrw, "NZQ_CLOJA")
	EndIf

Return ( aCmpNotBrw )

//-------------------------------------------------------------------
/*/{Protheus.doc} J235BMBrw
Monta MarkBrowse da tela de cobrança em lote

@param   cAliasNZQ, Alias temporário do MarkBrowse
@param   aFields  , Campos da tabela para o FWMarkBrowse
@param   aOrder   , Índice para o Browse
@param   aFldsFilt, Campos de filtro da tabela para o FWMarkBrowse
@param   aOfusca  , Campos do Browse que devem ser ofuscados - LGPD

@author  Jonatas Martins / Abner Fogaça
@since   24/08/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J235BMBrw(cAliasNZQ, aFields, aOrder, aFldsFilt, aOfusca)
	Local bseek     := Nil
	Local lMarcar   := .F.

	oMBrw235B := FWMarkBrowse():New()
	oMBrw235B:SetDescription(STR0001) // "Aprovação de Despesas em Lote"
	oMBrw235B:SetAlias(cAliasNZQ)
	oMBrw235B:SetTemporary(.T.)
	oMBrw235B:SetFields(aFields)
	oMBrw235B:SetProfileID("J235B")

	oMBrw235B:oBrowse:SetDBFFilter(.T.)
	oMBrw235B:oBrowse:SetUseFilter()

	If !Empty(aOfusca) // Tratamento para LGPD verifica os campos que devem ser ofuscados
		oMBrw235B:oBrowse:SetObfuscFields(aOfusca)
	EndIf

	//------------------------------------------------------
	// Precisamos trocar o Seek no tempo de execucao,pois
	// na markBrowse, ele não deixa setar o bloco do seek
	// Assim nao conseguiriamos  colocar a filial da tabela
	//------------------------------------------------------
	bseek := {|oSeek| MySeek(oSeek, oMBrw235B:oBrowse)}
	oMBrw235B:oBrowse:SetIniWindow({|| oMBrw235B:oBrowse:oData:SetSeekAction(bseek)})
	oMBrw235B:oBrowse:SetSeek(.T., aOrder)

	oMBrw235B:oBrowse:SetFieldFilter(aFldsFilt)
	oMBrw235B:oBrowse:bOnStartFilter := Nil

	oMBrw235B:SetMenuDef('')
	oMBrw235B:AddButton(STR0013, {|| J235BBtApr(cAliasNZQ)},, 4, 1) // "Aprovar"
	oMBrw235B:AddButton(STR0067, {|| cNZQcEscr := CriaVar('NZQ_CESCR', .F.), cCliOr := CriaVar('A1_COD', .F.), cLojaOr := CriaVar("A1_COD", .F.), JURA235B(.F.)},, 6) // "Filtrar"
	oMBrw235B:SetFieldMark('NZQ_OK')
	oMBrw235B:bAllMark := {|| JurMarkALL(@oMBrw235B, cAliasNZQ, 'NZQ_OK', lMarcar := !lMarcar,, .F.), oMBrw235B:Refresh()}
	JurSetBSize(oMBrw235B)
	oMBrw235B:Activate()

	FreeObj(oMBrw235B)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J235BBtApr
Função para aprovação das solicitações de despesas

@param   cAliasNZQ, caractere, Alias temporário do MarkBrowse

@author  Abner Fogaça / Jorge Martins / Jonatas Martins
@since   28/08/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J235BBtApr(cAliasNZQ)
	Local lRet        := .T.
	Local cMarca      := oMBrw235B:Mark()
	Local lInvert     := oMBrw235B:IsInvert()
	Local nCountNZQ   := 0
	Local cFiltro     := ''
	Local cMsg        := ''
	Local aLanc       := {}
	Local aErroLote   := {}
	Local nAprovadas  := 0
	Local cFilAtu     := cFilAnt
	Local cFilEsc     := ""

	cFiltro := oMBrw235B:FWFilter():GetExprADVPL()

	If Empty(cFiltro)
		cFiltro += "(NZQ_OK " + Iif(lInvert, "<>", "==" ) + " '" + cMarca + "')"
	Else
		cFiltro += " .And. (NZQ_OK " + Iif(lInvert, "<>", "==" ) + " '" + cMarca + "')"
	EndIf

	cAux := &( '{|| ' + cFiltro + ' }')
	(cAliasNZQ)->( dbSetFilter( cAux, cFiltro ) )
	(cAliasNZQ)->( dbSetOrder(1) )

	(cAliasNZQ)->(DbEval({||nCountNZQ++}))

	If nCountNZQ == 0
		JurMsgErro(STR0024,, STR0028) //"Não há dados marcados para execução em lote." - "Selecione ao menos um registro para aprovação."
		lRet := .F.
	Else
		(cAliasNZQ)->(DbGotop())
		J235ATlApr(Nil, .F., .F., "", .T., @aLanc, @cFilEsc)
		lRet := IIF(Len(aLanc) > 1, aLanc[1], .F.)

		If lRet
			cFilAnt := cFilEsc
			While (cAliasNZQ)->(! Eof())
				NZQ->(DbGoto((cAliasNZQ)->REC))

				If J235APreApr(.F., .F., .T., aLanc, @aErroLote)
					nAprovadas++
				EndIf
				(cAliasNZQ)->(DbSkip())
			End

			If nAprovadas == 1
				cMsg := I18n(STR0031, {nAprovadas}) // "#1 solicitação aprovada com sucesso."
			ElseIf nAprovadas > 1
				cMsg := I18n(STR0025, {nAprovadas}) // "#1 solicitações aprovadas com sucesso."
			EndIf
			
			If nAprovadas > 0 .And. Empty(aErroLote)
				ApMsgInfo(cMsg)
			EndIf

			If ! Empty(aErroLote)
				J235BLog(aErroLote, cMsg)
			EndIf
			cFilAnt := cFilAtu
		EndIf
		J235BAtuBrw()
	EndIf

	JurFreeArr(aErroLote)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J235BValLc
Validação dos dados da tela de lançamento

@param cTpLanc      Tipo de Lançamento - Caixinha / Contas a Pagar
@param cEscrit      Código do Escritório
@param cCtPag       Chave do registro de Contas a Pagar
@param lDesdPos     Indica se é desdobramento pós pagamento
@param cHisPad      Histórico Padrão
@param cNaturOri    Natureza de origem
@param lVldDesCli   Indica se está realizando o teste considerando que 
                    não existe uma natureza do tipo 5 - Desp de Cliente
				    (usado para testes automatizados)

@return aLanc       Dados de lançamento para aprovação

@author Jorge Martins
@since 18/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function J235BTlVld(cTpLanc, cEscrit, cCtPag, lDesdPos, cHisPad, cNaturOri)
	Local lRet      := .T.
	Local lCaixinha := (cTpLanc == STR0033) // "Caixinha"
	Local aLanc     := {}
	Local aSaldoSE2 := JurGetDados("SE2", 1, Trim(STRTRAN(cCtPag, "|", "")), {"E2_SALDO", "E2_VALOR"})
	Local nSaldoSE2 := IIF(Empty(aSaldoSE2), 0, aSaldoSE2[1] )
	Local nValorSE2 := IIF(Empty(aSaldoSE2), 0, aSaldoSE2[2] )

	// Valida preenchimento do histórico padrão - Telinha de Aprovação
	If Empty(cHisPad) .And. SuperGetMv("MV_JHISPAD", .F., .F.) // Indica se o campo de Histórico Padrão é obrigatório (.T.) ou não (.F.)
		lRet := .F.
		JurMsgErro(I18N(STR0042, {STR0038}),, STR0043) // "É necessário preencher o campo '#1'." ##"Preencha o campo solicitado"
	EndIf

	If lDesdPos
		If nSaldoSE2 != 0
			lRet := .F.
			JurMsgErro(STR0064,, STR0066) // "Contas a pagar inválido." - "Indique um título totalmente baixado para realizar a aprovação."
		EndIf
	Else
		If nSaldoSE2 != nValorSE2
			lRet := .F.
			JurMsgErro(STR0064,, STR0065) // "Contas a pagar inválido." - "Indique um título sem baixas para realizar a aprovação."
		EndIf
	EndIf

	If lRet
		If !lCaixinha // Tipo de lançamento - Contas a Pagar
			// Valida preenchimento do Nº do contas a pagar - Telinha de Aprovação
			If Empty(cCtPag)
				lRet := .F.
				JurMsgErro(I18N(STR0044, {STR0032, STR0036}), , STR0043) // "Para o tipo de lançamento '#1' é necessário preencher o campo '#2'." ##"Preencha o campo solicitado"
			EndIf

		EndIf
	EndIf

	If !IsBlind() // Se não for execução automática
		If lRet .And. !(ApMsgYesNo(STR0045)) // "Deseja realmente aprovar estas solicitações?"
			lRet := .F.
		EndIf
	EndIf

	aLanc := {lRet, cTpLanc, cEscrit, cCtPag, lDesdPos, cHisPad, cNaturOri}

Return (aLanc)

//-------------------------------------------------------------------
/*/{Protheus.doc} J235BVldMd
Validação do modelo de aprovação despesas

@param oModel       Modelo de dados da Aprovação de Despesa
@param aLanc        Dados da tela de lançamentos
@param aErroLote    Despesas que não foram aprovadas e mensagens da validação.
@param lAutomato    Indica se está sendo executada via teste 
                    automatizado
@param lVldDesCli   Indica se está realizando o teste considerando que 
                    não existe uma natureza do tipo 5 - Desp de Cliente
				    (usado para testes automatizados)

@return lFecha      Indica se a tela de filtro deve ser fechada

@author Jorge Martins
@since 18/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function J235BVldMd(oModel, aLanc, aErroLote, lAutomato, lVldDesCli)
Local lRet         := .T.
Local cTpLanc      := aLanc[2]
Local cEscrit      := aLanc[3]
Local cCtPag       := aLanc[4]
Local lDesdPos     := aLanc[5]
Local cHisPad      := aLanc[6]
Local cNaturOri    := aLanc[7]
Local lCaixinha    := (cTpLanc == STR0033) // "Caixinha"
Local cMsg         := IIf(lCaixinha, STR0046, STR0047) //"Gerando Lançamento" "Gerando Desdobramento"
Local cMoedaTit    := ""
Local cMoedaNat    := ""
Local cNaturDes    := ""
Local cTitCpo      := ""
Local cValCpo      := ""
Local cCCNatOri    := ""
Local oModelNZQ    := oModel:GetModel("NZQMASTER")
Local aRetSed      := {}
Local cCusto       := ""
Local cEscrPart    := ""
Local cPartSolc    := ""
Local cCodDesp     := oModelNZQ:GetValue("NZQ_COD")

Default lAutomato  := .F.
Default lVldDesCli := .F.

// Validações em comum entre Caixinha e Contas a pagar
If lRet

	// Valida se a natureza da solicitação de despesa é válida
	If oModelNZQ:GetValue("NZQ_DESPES") == "1" // 1=Cliente
		cNaturDes := JurBusNat("5") // Natureza

		If Empty(cNaturDes) .Or. lVldDesCli // Não existe natureza de Despesa de cliente ou é um teste negativo (automatização)
			lRet    := .F.
			cTitCpo := AllTrim(RetTitle('ED_CCJURI'))
			cValCpo := JurInfBox("ED_CCJURI", '5' )
			aAdd(aErroLote, {cCodDesp, I18n(STR0048, {cTitCpo, cValCpo}), STR0049}) // "Não foi encontrada uma natureza onde o campo '#1' é igual a '#2'." - "Inclua uma natureza com esse centro de custo jurídico."
		EndIf
	Else // 2=Escritório
		cNaturDes := oModelNZQ:GetValue("NZQ_CTADES")

		If Empty(cNaturDes)
			lRet    := .F.
			cTitCpo := AllTrim(RetTitle('NZQ_CTADES'))
			aAdd(aErroLote, {cCodDesp, STR0050, I18n(STR0051, {cTitCpo})}) // "Não foi encontrada uma natureza na solicitação." - "Preencha o campo '#1' na solicitação."
		EndIf
	EndIf

EndIf

If lRet
	If lCaixinha // Tipo de lançamento - Caixinha

		cPartSolc := oModelNZQ:GetValue("NZQ_CPART")
		// Indica a natureza do solicitante (participante) como natureza origem caso não tenha sido preenchida a natereza na telinha de aprovação
		If Empty(cNaturOri)
			cNaturOri := J159PrtNat(cPartSolc)

			// Valida se foi encontrada uma natureza vinculada ao solitante (participante)
			If Empty(cNaturOri)
				lRet := .F.
				aAdd(aErroLote, {cCodDesp, STR0052, I18n(STR0053, {STR0041})}) // "Não foi encontrada uma natureza vinculada ao solicitante." - "Preencha o campo '#1' na 'Aprovação de despesa' ou vincule uma natureza ao solicitante." - "Cód. Natureza"
			EndIf
		EndIf

		If lRet
			aRetSed   := JurGetDados("SED", 1, xFilial("SED") + cNaturOri, {"ED_CMOEJUR", "ED_CCJURI"})
			If Len(aRetSed) == 2
				cMoedaNat := aRetSed[1]
				cCCNatOri := aRetSed[2]
			EndIf

			// Valida se a moeda da natureza de origem é a mesma da solicitação de despesa
			If cMoedaNat <> oModelNZQ:GetValue("NZQ_CMOEDA")
				lRet := .F.
				aAdd(aErroLote, {cCodDesp, STR0054, STR0055}) // "A moeda indicada na solicitação de despesa está diferente da moeda da natureza origem." - "Ajuste a moeda da solicitação de despesa ou indique uma outra natureza origem."
			EndIf
		EndIf

		If lRet
			If cCCNatOri $ "1|2" //Escritório|Centro de Custo|Vazio(não definido)
				cEscrPart := JurGetDados("NUR", 1, xFilial("NUR") + cPartSolc, "NUR_CESCR")
				If Empty(cEscrPart)
					lRet := .F.
					aAdd(aErroLote, {cCodDesp, i18n(STR0056, {cNaturOri}); // "A natureza de origem selecionada '#1' requer o preenchimento do escritório."
					                       , i18n(STR0057, {oModelNZQ:GetValue("NZQ_SIGLA")})}) // "Indique um escritório no participante sigla '#1' ou indique uma outra natureza origem."
				EndIf

				If lRet .And. cCCNatOri == "2" //Centro de Custo|Vazio(não definido)
					cCusto    := JurGetDados("RD0", 1, xFilial("RD0") + cPartSolc, "RD0_CC")
					If Empty(cCusto)
						lRet := .F.
						aAdd(aErroLote, {cCodDesp, i18n(STR0058, {cNaturOri}); // "A natureza de origem selecionada '#1' requer o preenchimento do centro de custo."
						                       , i18n(STR0059, {oModelNZQ:GetValue("NZQ_SIGLA")})}) // "Indique um centro de custo no participante sigla '#1' ou indique uma outra natureza origem."
					EndIf
				EndIf
			EndIf
		EndIf

	Else // Tipo de lançamento - Contas a Pagar

		// Valida se moeda da solicitação é a mesma do título (Contas a Pagar)
		If lRet
			cMoedaTit := JurGetDados("SE2", 1, Trim(STRTRAN(cCtPag, "|", "")), "E2_MOEDA")
			cMoedaTit := PadL(cMoedaTit, TamSx3('CTO_MOEDA')[1], '0')

			If cMoedaTit <> oModelNZQ:GetValue("NZQ_CMOEDA")
				lRet := .F.
				aAdd(aErroLote, {cCodDesp, STR0060, STR0061}) // "A moeda indicada na solicitação de despesa está diferente da moeda do título a pagar." - "Ajuste a moeda da solicitação de despesa."
			EndIf
		EndIf
	EndIf
EndIf

If lRet
	// Confirma a Aprovação e gera o lançamento/desdobramento
	Processa( {|| lRet := J235AConf(oModel, lCaixinha, cEscrit, cCtPag, lDesdPos, cHisPad, cNaturOri, cNaturDes, @aErroLote, .T.) }, STR0062, cMsg, .F. ) // "Aguarde" - "Processando..."
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J235BLog
Monta log de processamento

@param   aErroLote , array , Despesas que não foram aprovadas e mensagens da validação.
@param   lCriaArq  , logico, Se verdairo cria arquivo de log no system
@param   lShowMsg  , logico, Habilita/Desabilita mensagem de sucesso ou falha

@author  Jonatas Martins / Abner Fogaça
@since   24/08/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J235BLog(aErroLote, cMsgTela, lCriaArq, lShowMsg)
Local cMsgLog     := ""
Local cPathLog    := ""
Local cLogfile    := ""
Local cListDes    := ""
Local cDespesa    := ""
Local cProblema   := ""
Local cSolucao    := ""
Local nDesp       := 0

Default aErroLote := {}
Default cMsgTela  := ""
Default lCriaArq  := .F.
Default lShowMsg  := .F.

If ! Empty(aErroLote)
	cMsgLog := Replicate("=", 80) + CRLF
	cMsgLog += "JURA235B - " + cUserName + " - " + FWTimeStamp(2) + CRLF
	cMsgLog += STR0026 + CRLF // "Falha na aprovação da(s) despesa(s) abaixo:"

	For nDesp := 1 To Len(aErroLote)

		cDespesa  := aErroLote[nDesp][1]
		cProblema := aErroLote[nDesp][2]
		cSolucao  := aErroLote[nDesp][3]

		cListDes += cDespesa + CRLF
		cListDes += STR0029  + cProblema + CRLF // "Problema: "
		cListDes += STR0030  + cSolucao  + CRLF + CRLF // "Solução: "
	Next nDesp

	cMsgLog += cListDes
	cMsgLog += Replicate("=", 80) + CRLF
EndIf

If ! Empty(cMsgLog)
	JurLogMsg(cMsgLog) // Adiciona mensagem no Log

	If Empty(cMsgTela)
		cMsgTela += STR0026 + CRLF + cListDes
	Else
		cMsgTela += CRLF + CRLF + STR0026 + CRLF + cListDes
	EndIf

	// Adiciona mensagem na tela
	JurErrLog(cMsgTela, STR0001) // "Aprovação de Despesas em Lote"

	If lCriaArq
		cMsgLog  := STR0026 + CRLF + cListDes // "Falha na aprovação das despesas abaixo:"
		cPathLog := GetSrvProfString("STARTPATH", "")
		cLogfile := "JURA235B.log"
		If ! JurCrLog(cMsgLog, cPathLog, cLogfile) .And. lShowMsg
			JurMsgErro(STR0027) // "Falha na criação do arquivo de log!"
		EndIf
	EndIf
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J235BAtuBrw()
Atualiza a tela.

@param   aFiltros, array , Dados de filtro para atualização do browse

@author Jorge Martins
@since 30/08/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J235BAtuBrw(aFiltros)
	Local cAliasTab  := oTmpTable:GetAlias()
	Local aStruAdic  := {}
	Local aCmpAcBrw  := {}
	Local aCmpNotBrw := {}
	Local lEmpty     := .F.
	Local cTmpQry    := GetNextAlias()

	Default aFiltros := {}

	If !Empty(aFiltros)
		cQueryTmp := J235Query(aFiltros)
	EndIf

	// Executa a query da tabela temporária para verificar se está vazia.
	cQueryTmp := ChangeQuery(cQueryTmp)
	dbUseArea(.T., "TOPCONN", TcGenQry(,, cQueryTmp), cTmpQry, .T., .T.)

	lEmpty := (cTmpQry)->( EOF() )
	(cTmpQry)->(dbCloseArea())

	If lEmpty .And. !IsBlind()
		JurMsgErro(STR0063) // "Não foram encontrados registros para o filtro indicado!"
	EndIf

	oTmpTable:Delete()

	aStruAdic  := J235StruAdic()
	aCmpAcBrw  := J235CmpAcBrw()
	aCmpNotBrw := J235NotBrw()
	oTmpTable  := JurCriaTmp(cAliasTab, cQueryTmp, "NZQ", , aStruAdic, aCmpAcBrw, aCmpNotBrw)[1]

	oMBrw235B:Refresh(.T.)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} J235BGetEs
Função para obter dados do escritório na tela de aprovação

@return   cNZQcEscr , caractere, Escritório para filtro de centro de custo

@author   Jorge Martins
@since    30/08/2018
@version  1.0
@obs      Função chamada no fonte JURXFUNC na função "JFtCTTNS7"
/*/
//-------------------------------------------------------------------
Function J235BGetEs()
Return cNZQcEscr

//-------------------------------------------------------------------
/*/{Protheus.doc} J235BNVEF3
Função para obter dados do cliente e loja na tela de aprovação

@return   cRet Retorna o Cliente e Loja preenchido na tela.

@author   Abner Fogaça
@since    03/09/2018
@version  1.0
@obs      Função chamada no fonte JURXFUNC na função "JURNVELOJA"
/*/
//-------------------------------------------------------------------
Function J235BNVEF3()
Local cRet      := "@#@#"
Local cLojaAuto := JurGetLjAt()
Local lLojaAuto := SuperGetMv("MV_JLOJAUT", .F., "2") == '1' //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)

If !Empty(cCliOr) .And. !Empty(cLojaOr)
	cRet := "@#NVE->NVE_CCLIEN == '" + cCliOr + "' .And. NVE->NVE_LCLIEN == '" + cLojaOr + "' @#"
EndIf

If Empty(cCliOr) .And. lLojaAuto
	cRet := "@#NVE->NVE_LCLIEN == '" + cLojaAuto + "' @#"
EndIf

Return cRet
