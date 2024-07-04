#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "JURA281.CH"

Static __cMdlPFS   := ""  // Variável que monta xml para cache do modelo
Static __lRecord   := .F. // Variável que define se vai gravar os dados no commit do modelo
Static __lSaveData := .F. // Variável que controla se obteve sucesso na gravação dos dados nas tabelas físicas
Static __aAutoDes  := {}  // Dados de desdobramentos enviados através da rotina automática
Static __aRecSE2   := {}  // Recnos dos títulos vinculados a NF de entrada
Static __lDialog   := .F. // Indice se abriu a tela da naturuza definida
 
#DEFINE CAMPOSCAB "OHV_FILIAL|OHV_DOC|OHV_SERIE|OHV_FORNEC|OHV_LOJA|"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA281
Desdobramento na NF de entrada

@param  lConfirm   , lógico  , Se verdadeiro indica que a chamada vem do confirmar da tela de NF
@param  nOperNF    , numérico, Numero da operação na rotina de NF
@param  aRecGerSE2 , array   , Recnos dos títulos a pagar vinculados a NF
@param  aAutoDes   , array   , Dados de desdobramentos enviados através da rotina automática

@return __lSaveData, lógico  , Se verdadeiro a gravação/cache dos dados foi efetuada com sucesso

@author Jonatas Martins
@since  06/04/2020
@obs    Chamado no fonte MATA103
/*/
//-------------------------------------------------------------------
Function JURA281(lConfirm, nOperNF, aRecGerSE2, aAutoDes)
	Local aArea          := GetArea()
	Local aAreaSF1       := SF1->(GetArea())
	Local aAreaSD1       := SD1->(GetArea())
	Local cTitulo        := STR0020 // Itens
	Local cPrograma      := "JURA281"
	Local nOperation     := 0
	Local aEnableButtons := {}
	Local oModelAct      := Nil
	Local cCodNat        := ""
	Local lTransit       := .F.

	Default nOperNF    :=  0
	Default lConfirm   := .F.
	Default aRecGerSE2 := {}
	Default aAutoDes   := {}

	__lRecord  := lConfirm
	__aRecSE2  := aRecGerSE2
	__aAutoDes := aAutoDes

	nOperation := IIF(nOperNF == MODEL_OPERATION_UPDATE, MODEL_OPERATION_INSERT, nOperNF)

	If l103Auto .Or. nOperation == MODEL_OPERATION_DELETE .Or. nOperation == MODEL_OPERATION_VIEW
		__lSaveData := J281Auto(nOperation)
	ElseIf __lRecord .And. Len(__aRecSE2) == 0
		__lSaveData := .T.

	ElseIf J281PreVld(@cCodNat, @lTransit) // Validações para permitir abrir a tela de Desdobramentos
		aEnableButtons := J281Buttons()
		__lDialog      := !lTransit
		
		If Empty(__cMdlPFS)
			If lTransit
				FWExecView(cTitulo, cPrograma, nOperation, /*oDlg*/, /*bCloseOnOK*/, /*bOk*/, /*nPercReduc*/, aEnableButtons, /*bCancel*/,/*cOperatId*/,/*cToolBar*/, /*oModelAct*/)
			Else
				__lSaveData := J281Dialog(Nil, cCodNat, nOperation)
			EndIf
		Else
			oModelAct := FWLoadModel("JURA281")
			oModelAct:LoadXMLData(__cMdlPFS, .T.)
			J281LoadData(oModelAct)

			If lTransit
				FWExecView(cTitulo, cPrograma, nOperation, /*oDlg*/, /*bCloseOnOK*/, /*bOk*/, /*nPercReduc*/, aEnableButtons, /*bCancel*/,/*cOperatId*/,/*cToolBar*/, oModelAct)
			Else
				__lSaveData := J281Dialog(oModelAct, cCodNat, nOperation)
			EndIf
		EndIf
		
		JurFreeArr(aEnableButtons)
	EndIf

	// Restaura operação as variáveis privates devido as alterações do modelo atual
	If nOperNF == MODEL_OPERATION_UPDATE .And. INCLUI
		INCLUI := .F.
		ALTERA := .T.
	EndIf

	RestArea(aAreaSD1)
	RestArea(aAreaSF1)
	RestArea(aArea)

Return (__lSaveData)

//-------------------------------------------------------------------
/*/{Protheus.doc} J281PreVld
Validações para permitir abrir a tela de desdobramentos

@param  cCodNat , caractere, Código da natureza da NF de entrada
@param  lTransit, lógico   , Se verdadeiro a natureza é transitória de pagamento
@param  cError  , caractere, Variável para informações de erro

@return lValid  , lógico   , Se verdeiro os dados foram validados com sucesso

@author Abner Oliveira / Jorge Martins
@since  28/07/2020
/*/
//-------------------------------------------------------------------
Static Function J281PreVld(cCodNat, lTransit, cError)
	Local nReg       := 0
	Local nPosDel    := 0
	Local lDelLine   := .T.
	Local lValid     := .T.

	If Type("ACOLS") == "A" .And. Type("AHEADER") == "A"
		nPosDel  := Len(AHEADER) + 1
		For nReg := 1 To Len(ACOLS)
			If !ACOLS[nReg][nPosDel]
				lDelLine := .F.
				If Empty(GdFieldGet("D1_COD", nReg)) .Or. GdFieldGet("D1_TOTAL", nReg) == 0
					lValid := .F.
					JurMsgErro(STR0002,, I18N(STR0003,{Alltrim(RetTitle("D1_COD")),Alltrim(RetTitle("D1_TOTAL"))})) // "Nota fiscal incompleta!" "Para realizar o desdobramento da NF é necessário ao menos que as informações de '#1' e '#2' estejam preenchidos."
					Exit
				EndIf
			EndIf
		Next nReg
		
		If lDelLine .And. lValid
			lValid := .F.
			JurMsgErro(STR0002,, I18N(STR0003,{Alltrim(RetTitle("D1_COD")),Alltrim(RetTitle("D1_TOTAL"))})) // "Nota fiscal incompleta!" "Para realizar o desdobramento da NF é necessário ao menos que as informações de '#1' e '#2' estejam preenchidos."
		EndIf

		If lValid
			cCodNat := MaFisRet(,"NF_NATUREZA")
			lValid  := J281VldNat(cCodNat, @lTransit)
		EndIf
	EndIf

Return (lValid)

//-------------------------------------------------------------------
/*/{Protheus.doc} J281VldNat
Validações nos dados de natureza.

@param  cCodNat , caractere, Código da natureza da NF de entrada
@param  lTransit, logico   , Se verdadeiro a natureza é transitória de pagamento
@return lValid  , logico   , Se verdeiro a natureza 

@author Abner Oliveira
@since  28/07/2020
@obs    Chamado no fonte MATA103 - Função A103TudOk
/*/
//-------------------------------------------------------------------
Function J281VldNat(cNatValid, lTransit)
	Local cNatTransPag := ""
	Local lValid       := .T.
	Local nPosDel      := 0
	Local nQtdLin      := 0
	
	Default cNatValid := ""
	Default lTransit  := .F.

	If !Empty(cNatValid)
		If JurValNat(Nil, "1", cNatValid, .F., "6")
			nPosDel := Len(AHEADER) + 1
			AEval(ACOLS, {|aLine| nQtdLin += IIF(!aLine[nPosDel], 1, 0)})
			lTransit := JurGetDados("SED", 1, xFilial("SED") + cNatValid, "ED_CCJURI") == "7" // Transitória de Pagamento

			If nQtdLin > 1 .And. !lTransit
				cNatTransPag := JurBusNat("7") // Natureza Transitória de Pagamento
				If Empty(cNatTransPag)
					JurMsgErro(STR0004, ,STR0005) // "Natureza incorreta!" "Quando há mais de um item na NF é necessário utilizar uma natureza transitória."
				Else
					MaFisAlt("NF_NATUREZA", cNatTransPag,)
					IIf(IsBlind(), Nil, ApMsgInfo(STR0006)) // "A natureza da NF foi alterada para uma transitória de pagamento!"
					lTransit := .T.
				EndIf
			EndIf
		Else
			lValid := .F.
		EndIf
	Else
		lValid := .F.
		JurMsgErro(STR0007, , STR0008) // "Natureza não preenchida!" "Não foi informado uma natureza para o NF, informe uma natureza válida na aba duplicatas"
	EndIf

Return (lValid)

//-------------------------------------------------------------------
/*/{Protheus.doc} J281CondPg
Validação da condição de pagamento, bloquei o uso de condição que 
utilize adiantamento.

@param  cCondicao , caractere, Código da condição de pagamento
@param  lUsaAdi   , logico   , Se verdadeiro a condição de pagamento utiliza adiantamento
@return lCondPag  , logico   , Se a condição de pagamento é válida

@author Jonatas Martins / Abner Oliveira
@since  10/08/2020
@obs    Chamado no fonte MATA103 - Função A103TudOk
/*/
//-------------------------------------------------------------------
Function J281CondPg(cCondicao, lUsaAdi)
	Local lCondPag := .T.

	Default cCondicao := ""
	Default lUsaAdi   := .F.

	If !Empty(cCondicao) .And. lUsaAdi
		lCondPag := .F.
		JurMsgErro(I18N(STR0021, {AllTrim(cCondicao)}), , STR0022) //Condição de pagamento: '#1' não permitida! ## Escolha uma condição de pagamento que não utilize adiantamento.
	EndIf

Return (lCondPag)

//-------------------------------------------------------------------
/*/{Protheus.doc} J281Buttons
Botões da tela de desdobramento

@author Jonatas Martins / Reginaldo Borges
@since  28/07/2020
/*/
//-------------------------------------------------------------------
Static Function J281Buttons()
Local aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},;
					{.F.,Nil},{.F.,Nil},{.T.,STR0023},{.T.,STR0024},; // "Salvar" # "Cancelar"
					{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}

	If __lRecord
		aButtons[8][1] := .F.
	EndIf
	
Return (aButtons)

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de desdobramento

@author Jonatas Martins / Reginaldo Borges
@since  28/07/2020
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	Local oStructCab  := FWFormStruct(1, "OHV", {|cCampo| AllTrim(cCampo) + '|' $ CAMPOSCAB})
	Local oStructOHV  := FWFormStruct(1, "OHV", {|cCampo| !AllTrim(cCampo) + '|' $ CAMPOSCAB})
	Local bCommit     := {|oModel| __lSaveData := J281Commit(oModel)}
	Local bPosValid   := {|oModel| J281BOK(oModel)}
	Local oModel      := Nil

	oModel := MPFormModel():New("JURA281", /* bPreValidacao */, bPosValid , bCommit, /*bCancel*/)

	oModel:AddFields("OHVMASTER", /*cOwner*/, oStructCab, /*Pre-Validacao*/, /*Pos-Validacao*/, /*bLoadCab*/)
	oModel:AddGrid("OHVDETAIL", "OHVMASTER", oStructOHV, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*bLoadGrid*/)
	oModel:AddCalc("OHVCALC", "OHVMASTER", "OHVDETAIL", "OHV_TOTAL", "OHV__SUM", "SUM", {||.T.},, STR0017) // "Total Desdobramento"

	oModel:SetRelation("OHVDETAIL", {{"OHV_FILIAL", "xFilial('OHV')"},{"OHV_DOC", "OHV->OHV_DOC"}}, OHV->(IndexKey(1)))

	oModel:SetDescription(STR0001) // "Desdobramentos NF de entrada"
	oModel:GetModel("OHVMASTER"):SetDescription(STR0009) // "Cabeçalho desdobramento NF entrada"
	oModel:GetModel("OHVDETAIL"):SetDescription(STR0010) // "Itens desdobramento NF entrada"

	oModel:GetModel("OHVDETAIL"):SetOptional(.T.)

	oModel:SetPrimaryKey({"OHV_FILIAL", "OHV_DOC", "OHV_SERIE", "OHV_FORNEC", "OHV_LOJA"})

	oModel:SetActivate({|oModel| IIF(Empty(__cMdlPFS) .And. oModel:GetOperation() <> 5, J281LoadData(oModel), Nil)})

Return (oModel)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de desdobramentos

@author Jonatas Martins / Reginaldo Borges
@since  28/07/2020
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oStructCab := FWFormStruct(2, "OHV", {|cCampo| AllTrim(cCampo) + '|' $ CAMPOSCAB})
	Local oStructOHV := FWFormStruct(2, "OHV", {|cCampo| !AllTrim(cCampo) + '|' $ CAMPOSCAB})
	Local oModel     := FWLoadModel("JURA281")
	Local oStruCalc  := FWCalcStruct(oModel:GetModel("OHVCALC"))
	Local lUtProj    := SuperGetMv( "MV_JUTPROJ", .F., .F., )
	Local oView      := Nil

	oStructOHV:RemoveField("OHV_CPART")
	oStructOHV:RemoveField("OHV_CPART2")
	oStructOHV:RemoveField("OHV_DTINCL")

	If !lUtProj
		oStructOHV:RemoveField("OHV_CPROJE")
		oStructOHV:RemoveField("OHV_DPROJE")
		oStructOHV:RemoveField("OHV_CITPRJ")
		oStructOHV:RemoveField("OHV_DITPRJ")
	EndIf

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("JURA281_CAB" , oStructCab, "OHVMASTER")
	oView:AddField("JURA281_CALC", oStruCalc , "OHVCALC")
	oView:AddGrid("JURA281_ITEM" , oStructOHV, "OHVDETAIL")

	oView:CreateHorizontalBox("UP_BOX"  , 0)
	oView:CreateHorizontalBox("CALC_BOX", 13)
	oView:CreateHorizontalBox("DOWN_BOX", 87)

	oView:SetOwnerView("JURA281_CAB" , "UP_BOX")
	oView:SetOwnerView("JURA281_CALC", "CALC_BOX")
	oView:SetOwnerView("JURA281_ITEM", "DOWN_BOX")

	// Habilita detalhamento
	oView:SetViewProperty("JURA281_ITEM", "ENABLEDGRIDDETAIL", {40})

	// Desabilita mensagens ao confirmar
	oView:ShowInsertMessage(.F.)
	oView:ShowUpdateMessage(.F.)

Return (oView)

//-------------------------------------------------------------------
/*/{Protheus.doc} J281LoadData
Carga das informações de desdobramentos da NF de Entrada

@param oModel, Modelo de dados de desdobramentos

@author Jonatas Martins / Reginaldo Borges
@since  28/07/2020
/*/
//-------------------------------------------------------------------
Static Function J281LoadData(oModel)
	Local oModelCab   := oModel:GetModel("OHVMASTER")
	Local oModelCalc  := oModel:GetModel("OHVCALC")
	Local oModelGrid  := oModel:GetModel("OHVDETAIL")
	Local nTotalNF    := MaFisRet(,"NF_TOTAL")
	Local aFieldsGrid := {}
	Local nSaveLine   := 0
	Local nPosDel     := 0
	Local cItemSD1    := ""
	Local nLinSD1     := 0

	// Atualiza dados do Cabeçalho
	oModelCab:LoadValue("OHV_FILIAL", xFilial("OHV"))
	oModelCab:LoadValue("OHV_DOC"   , CNFISCAL)
	oModelCab:LoadValue("OHV_SERIE" , CSERIE)
	oModelCab:LoadValue("OHV_FORNEC", CA100FOR)
	oModelCab:LoadValue("OHV_LOJA"  , CLOJA)

	If Type("ACOLS") == "A" .And. Type("AHEADER") == "A" .And. !Empty(ACOLS)
		aFieldsGrid := AClone(oModelGrid:GetStruct():GetFields())
		nPosDel     := Len(AHEADER) + 1

		oModelGrid:SetNoDeleteLine(.F.)
		oModelGrid:SetNoInsertLine(.F.)

		For nLinSD1  := 1 To Len(ACOLS)
			cItemSD1 := GdFieldGet("D1_ITEM", nLinSD1)
			lDelSD1  := ACOLS[nLinSD1][nPosDel]

			If oModelGrid:SeekLine({{"OHV_ITEM", cItemSD1}}, .T., .T.)
				If lDelSD1 .And. !oModelGrid:IsDeleted()
					oModelGrid:DeleteLine(.T.)
				Else
					SetValGrid(oModelGrid, aFieldsGrid, nLinSD1, .F.) // Atualiza linha
					nSaveLine := IIF(__lDialog, oModelGrid:GetLine(), 0)
				EndIf
			ElseIf !lDelSD1
				SetValGrid(oModelGrid, aFieldsGrid, nLinSD1, .T.) // Cria nova linha
				nSaveLine := IIF(__lDialog, oModelGrid:GetLine(), 0)
			EndIf
		Next nLinSD1

		If __lDialog .And. nSaveLine > 0
			oModelGrid:GoLine(nSaveLine)
		EndIf

		// Atualiza totalizador do desdobramento
		oModelCalc:LoadValue("OHV__SUM", IIF(nTotalNF < 0, 0, nTotalNF))

		oModelGrid:SetNoDeleteLine(.T.)
		oModelGrid:SetNoInsertLine(.T.)

		JurFreeArr(aFieldsGrid)
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} SetValGrid
Função para carga da linha do grid

@param  oModelGrid , objeto  , Modelo de dados do grid de desdobrametos
@param  aFieldsGrid, array   , Estrutura de campos do grid
@param  nLineSD1   , numérico, Número da linha do desdobramento no grid
@param  lInsertLine, lógico  , Se verdadeiro indica que é inserção de linha

@retunr lContinue  , lógico  , Se verdadeiro indica a carga foi etivada

@author Jonatas Martins / Reginaldo Borges
@since  28/07/2020
/*/
//-------------------------------------------------------------------
Static Function SetValGrid(oModelGrid, aFieldsGrid, nLineSD1, lInsertLine)
	Local nTotLineGrid := 0
	Local nNewLine     := 0
	Local nField       := 0
	Local cField       := ""
	Local cType        := ""
	Local nLength      := 0
	Local xValue       := ""
	Local lVirtual     := .F.
	Local lContinue    := .T.

	If lInsertLine
		oModelGrid:SetNoInsertLine(.F.)
		nTotLineGrid := oModelGrid:Length()
		nNewLine     := IIF(nTotLineGrid == 1 .And. nLineSD1 == 1, 1, oModelGrid:AddLine())
		lContinue    := nNewLine == 1 .Or. nNewLine > nTotLineGrid
	EndIf

	If lContinue
		For nField := 1 To Len(aFieldsGrid)
			cField   := AllTrim(aFieldsGrid[nField][MODEL_FIELD_IDFIELD])
			lVirtual := aFieldsGrid[nField][MODEL_FIELD_VIRTUAL]
			If oModelGrid:CanSetValue(cField) .And. (!lVirtual .Or. cField $ "OHV_DESCOD|OHV_SIGLA|OHV_SIGLA2")
				cType   := aFieldsGrid[nField][MODEL_FIELD_TIPO]
				nLength := aFieldsGrid[nField][MODEL_FIELD_TAMANHO]
				xValue  := GetValGrid(oModelGrid, cField, nLineSD1)
				xValue  := IIF(cType == "C", SubStr(AllTrim(xValue), 1, nLength), xValue)

				If !oModelGrid:SetValue(cField, xValue)
					lContinue := .F.
					Exit
				EndIf
			EndIf
		Next nField
	EndIf

Return (lContinue)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetValGrid
Obtem valores dos campos da linha do grid

@param  oModelGrid, objeto   , Modelo de dados do grid de desdobrametos
@param  cField    , caractere, Campo da linha do grid
@param  nLineSD1  , numérico , Número da linha do item da NF de entrada

@return xValField, Valor a ser atribuido no campo do grid

@author Jonatas Martins / Reginaldo Borges
@since  28/07/2020
/*/
//-------------------------------------------------------------------
Static Function GetValGrid(oModelGrid, cField, nLineSD1)
	Local cCodProd  := ""
	Local xValField := ""

	If AllTrim(cField) + "|" $ "OHV_ITEM|OHV_COD|OHV_TOTAL|"
		cFieldSD1 := StrTran(cField, "OHV_", "D1_")
		If GdFieldPos(cFieldSD1) > 0
			xValField := GdFieldGet(cFieldSD1, nLineSD1)
		EndIf
	Else
		If cField == "OHV_VLDESP" // Despesa
			xValField := MaFisRet(nLineSD1, "IT_DESPESA")
		ElseIf cField == "OHV_VALFRE" // Frete
			xValField := MaFisRet(nLineSD1, "IT_FRETE")
		ElseIf cField == "OHV_VLDESC" // Desconto
			xValField := MaFisRet(nLineSD1, "IT_DESCONTO")
		ElseIf cField == "OHV_VALSEG" // Seguro
			xValField := MaFisRet(nLineSD1, "IT_SEGURO")
		ElseIf cField == "OHV_DESCOD"
			cCodProd  := GdFieldGet("D1_COD", nLineSD1)
			xValField := JurGetDados("SB1", 1, xFilial("SB1") + cCodProd, "B1_DESC")
		ElseIf cField == "OHV_CNATUR" .And. !l103Auto
			xValField := IIF(__lDialog, MaFisRet(,"NF_NATUREZA"), oModelGrid:GetValue(cField))
		Else
			If l103Auto .And. !(cField $ "OHV_CPART|OHV_CPART2|OHV_DTINCL")
				xValField := GetValAuto(cField, nLineSD1)
			Else
				xValField := oModelGrid:GetValue(cField) // Mantém dados do modelo carregado via XML
			EndIf
		EndIf
	EndIf

Return (xValField)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetValAuto
Obtem valores dos campos da linha do grid quando é rotina automática

@param  cField  , caractere, Campo da linha do grid
@param  nLineSD1, numérico , Número da linha do item da NF de entrada

@return xValAuto, Valor a ser atribuido no campo do grid

@author Jonatas Martins / Reginaldo Borges
@since  28/07/2020
/*/
//-------------------------------------------------------------------
Static Function GetValAuto(cField, nLineSD1)
	Local cItem       := GdFieldGet("D1_ITEM", nLineSD1)
	Local nPosCpoItem := 0  // Posição do campo de item
	Local nPosValItem := 0  // Posição do valor do campo de item
	Local nPosField   := 0  // Posição do campo enviado por parâmetro para busca
	Local xValAuto    := "" // Valor esperado para setar no modelo

	If cField == "OHV_CNATUR" .And. Len(ACOLS) == 1
		xValAuto := MaFisRet(,"NF_NATUREZA")
	Else
		nPosCpoItem := aScan(__aAutoDes[1], {|x| AllTrim(x[1]) == "OHV_ITEM"})
		
		If nPosCpoItem > 0 // Acha campo de item
			nPosValItem := aScan(__aAutoDes, {|x| x[nPosCpoItem][2] == cItem}) // 1º Nível
			If nPosValItem > 0
				nPosField := aScan(__aAutoDes[nPosValItem], {|x| AllTrim(x[1]) == cField}) // 2º Nível
				If nPosField > 0
					xValAuto := __aAutoDes[nPosValItem][nPosField][2] // 3º Nível 
				EndIf
			EndIf
		EndIf
	EndIf

Return (xValAuto)

//-------------------------------------------------------------------
/*/{Protheus.doc} J281Commit
Função para commit/cache dos do modelo OHV

@param  oModel281, objeto   , Modelo de dados de desdobramento da NF de entrada (OHV)
@param  cError   , caractere, Variável para atribuição de erro

@return lCommit   , lógico  , Se verdadeiro o modelo foi comitado/cacheado com sucesso

@author Jonatas Martins / Reginaldo Borges
@since  28/07/2020
/*/
//-------------------------------------------------------------------
Function J281Commit(oModel281, cError)
Local lCommit   := .T.

Default oModel281 := Nil
Default cError    := ""

	If ValType(oModel281) == "O" .And. oModel281:IsActive() .And. !oModel281:GetModel("OHVDETAIL"):IsEmpty()
		If __lRecord // Gravação dos dados
			If oModel281:VldData()
				If J281GrvDes(oModel281, @cError) // Grava OHF
					FWFormCommit(oModel281)
					oModel281:DeActivate()
					__cMdlPFS := ""
				Else
					lCommit := .F.
					JurMsgErro(cError, , STR0011) // "Ajustes as inconsistências."
				EndIf
			Else
				lCommit := .F.
				cError := cValToChar(oModel281:GetErrorMessage()[4]) + ' - '
				cError += cValToChar(oModel281:GetErrorMessage()[5]) + ' - '
				cError += cValToChar(oModel281:GetErrorMessage()[6])
				JurMsgErro(cError, , STR0011) // "Ajustes as inconsistências."
			EndIf
		Else
			__cMdlPFS := oModel281:GetXmlData(,,,,.F.) // Cria cache do modelo em XML
			oModel281:DeActivate()
		EndIf
	EndIf

Return (lCommit)

//-------------------------------------------------------------------
/*/{Protheus.doc} J281Auto
Função para rotina automática

@param  nOperation, numérico, Número da operação

@return lAuto     , logico  , Se verdadeiro a exclusão foi efetivada

@author Jorge Martins / Jonatas Martins
@since  28/07/2020
/*/
//-------------------------------------------------------------------
Static Function J281Auto(nOperation)
	Local aAreaOHV := OHV->(GetArea())
	Local oModel   := Nil
	Local cError   := ""
	Local lFound   := .T.
	Local lAuto    := .T.

	If nOperation == MODEL_OPERATION_DELETE .Or. nOperation == MODEL_OPERATION_VIEW
		OHV->(DBSetOrder(1)) // OHV_FILIAL+OHV_DOC+OHV_SERIE+OHV_FORNEC+OHV_LOJA+OHV_COD+OHV_ITEM
		lFound := OHV->(DBSeek(xFilial("OHV") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA))
	EndIf

	If lFound
		If  nOperation == MODEL_OPERATION_VIEW
			If J281NatTit() == "7" // Transitória de pagamento
				FWExecView(STR0020, "JURA281", nOperation, /*oDlg*/, {|| .T.}/*bCloseOnOK*/, {|| .T.}/*bOk*/, /*nPercReduc*/, /*aEnableButtons*/, {|| .T.}/*bCancel*/,/*cOperatId*/,/*cToolBar*/, /*oModelAct*/)
			Else
				J281Dialog(Nil, OHV->OHV_CNATUR, nOperation)
			EndIf
		Else
			oModel := FWLoadModel("JURA281")
			oModel:SetOperation(nOperation)
			If oModel:Activate()
				lAuto := J281Commit(oModel, @cError)
				oModel:DeActivate()
			EndIf
		EndIf
	EndIf

	If !lAuto
		If Empty(cError)
			cError := cValToChar(oModel:GetErrorMessage()[4]) + ' - '
			cError += cValToChar(oModel:GetErrorMessage()[5]) + ' - '
			cError += cValToChar(oModel:GetErrorMessage()[6])
		EndIf

		JurMsgErro(cError, , STR0011) // "Ajustes as inconsistências."
	EndIf

	RestArea(aAreaOHV)

Return (lAuto)

//-------------------------------------------------------------------
/*/{Protheus.doc} J281BOK
Bloco de pós-validação do modelo de dados

@param  oModel, objeto, Modelo de dados OHV

@return lBOk  , lógico, Se verdadeiro as validações de TUDOOK estão corretas

@author Jorge Martins
@since  28/07/2020
/*/
//-------------------------------------------------------------------
Function J281BOK(oModel)
	Local oModelGrid := oModel:GetModel("OHVDETAIL")
	Local cItem      := ""
	Local nLine      := .F.
	Local lBOk       := .T.
	Local lHisPad    := SuperGetMv("MV_JHISPAD", .F., .F.) // Indica se o campo de Histórico Padrão é obrigatório (.T.) ou não (.F.)

	If __lRecord .And. oModel:GetOperation() <> MODEL_OPERATION_DELETE
		For nLine := 1 To oModelGrid:Length()
			oModelGrid:GoLine(nLine)

			If !oModelGrid:IsDeleted()
				If Empty(oModelGrid:GetValue("OHV_CNATUR"))
					lBOk  := .F.
					cItem := oModelGrid:GetValue("OHV_ITEM")
					JurMsgErro(STR0007,, I18N(STR0012,{cItem})) // "Natureza não preenchida!" ### "Preencha a natureza do item #1"
				EndIf

				lBOk := lBOk .And. JurVldNCC(oModel, "OHVDETAIL", "OHV_CNATUR", "OHV_CESCR", "OHV_CCUSTO", "OHV_CPART2", "OHV_SIGLA2", "OHV_CRATEI", "OHV_CCLIEN", "OHV_CLOJA", ;
						"OHV_CCASO", "OHV_CTPDSP", "OHV_QTDDSP", "OHV_COBRA ", "OHV_DTDESP", "OHV_CPART", "OHV_SIGLA", "OHV_CPROJE", "OHV_CITPRJ" )

				If lBOk .And. lHisPad .And. Empty(oModel:GetValue("OHVDETAIL", "OHV_CHISTP"))
					lBOk := .F.
					JurMsgErro(STR0013,, STR0014) // "É obrigatório o preenchimento do Histórico Padrão, conforme o parâmetro MV_JHISPAD." # "Informe um código válido para o Histórico Padrão."
				EndIf

				If lBOk .And. Empty(oModel:GetValue("OHVDETAIL", "OHV_HISTOR"))
					lBOk := .F.
					JurMsgErro(STR0015,, STR0016) // "É obrigatório o preenchimento do histórico!" # "Preencha o histórico."
				EndIf
			EndIf

			If !lBOk
				Exit
			EndIf

		Next nLineSD1
	EndIf

Return (lBOk)

//-------------------------------------------------------------------
/*/{Protheus.doc} J281Dialog
Monta a tela para o Desdobramento após a inclusão do título a pagar.

@param  oModel   , objeto   , Modelo de dados de desdobramento da NF de entrada (OHV)
@param  cNaturNFE, caractere, Código da natureza da NF de entrada
@param  nOperacao, numérico , Numero da operação

@return lRetDlg  , lógico   , Se verdeiro a tela foi exibida

@author Jorge Martins
@since  28/07/2020
/*/
//-------------------------------------------------------------------
Function J281Dialog(oModel, cNaturNFE, nOperacao)
	Local aArea       := GetArea()
	Local aSize       := {}
	Local oLayer      := FWLayer():new()
	Local oModelOHV   := Nil
	Local oMainColl   := Nil
	Local oScroll     := Nil
	Local oPanel      := Nil
	Local nAltura     := 0
	Local nSizeTela   := 0
	Local nTamDialog  := 0
	Local nCoordPos   := 95
	Local nLargura    := 270
	Local nPosLoja    := 0
	Local nLarLoja    := 0
	Local nValorNFE   := MaFisRet(,"NF_TOTAL")
	Local cCCJuri     := JurGetDados("SED", 1, xFilial("SED") + cNaturNFE, "ED_CCJURI")
	Local lCCJuriDef  := !Empty(cCCJuri) // Indica se a natureza tem Centro de Custo Jurídico definido
	Local lVisualiza  := .F.
	Local lUtProj     := SuperGetMv( "MV_JUTPROJ", .F., .F., ) // Indica se será utilizado Projeto/Finalidade nas rotinas do Financeiro (.T. = Sim; .F. = Não)
	Local lContOrc    := SuperGetMv( "MV_JCONORC", .F., .F., ) // Indica se será utilizado Controle Orçamentário (.T. = Sim; .F. = Não)
	Local cLojaAuto   := SuperGetMv( "MV_JLOJAUT", .F., "2", ) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
	Local aCampos     := {}
	Local aNoAcess    := {}
	Local aOfuscar    := {}
	Local lRetDlg     := .T.
	Local bOk		  := {|| }
	Local bCancel	  := {|| }
	Local nProp		  := 2.24 //Proporção coordenadas x pixel

	Private oDlg      := Nil
	Private oCliOr    := Nil
	Private oDesCli   := Nil
	Private oLojaOr   := Nil
	Private oLojaOrF3 := Nil
	Private oCodNat   := Nil
	Private oDesNat   := Nil
	Private oVlTit    := Nil
	Private oSiglSol  := Nil
	Private oNomSigl  := Nil
	Private oCodEsc   := Nil
	Private oDesEsc   := Nil
	Private oCodCc    := Nil
	Private oDesCc    := Nil
	Private oSigPart  := Nil
	Private oDesPart  := Nil
	Private oCodRate  := Nil
	Private oDesRate  := Nil
	Private oCasoOr   := Nil
	Private oDesCas   := Nil
	Private oCodDesp  := Nil
	Private oDesDesp  := Nil
	Private oQtdDes   := Nil
	Private oDtDesp   := Nil
	Private oCbDesp   := Nil
	Private oCodHp    := Nil
	Private oHistor   := Nil
	Private oCodProj  := Nil
	Private oDesProj  := Nil
	Private oCItProj  := Nil
	Private oDItProj  := Nil

	Private cCliOr    := ""
	Private cLojaOr   := ""

	Default oModel    := FWLoadModel("JURA281")
	Default lConfirma := .F.
	Default nOperacao := MODEL_OPERATION_UPDATE

	lVisualiza := nOperacao == MODEL_OPERATION_VIEW

	cCliOr    := CriaVar('OHV_CCLIEN', .F.) // Filtro do F3 caso
	cLojaOr   := CriaVar('OHV_CLOJA',  .F.) // Filtro do F3 caso

	If !oModel:IsActive() .And. oModel:CanActivate()
		oModel:SetOperation(nOperacao)
		lRetDlg := oModel:Activate()
	EndIf
	
	If lRetDlg
		oModelOHV := oModel:GetModel("OHVDETAIL")

		If lUtProj .Or. lContOrc // Aumenta a quantidade de pixels para ajustar a tela e acionar o scroll
			nAltura := 60
		EndIf

		Do Case
			Case Empty(cCCJuri) .Or. cCCJuri $ "5" // Não definido ou Despesa de Cliente
				nAltura += 340
			Case cCCJuri $ "1|3|4" // Escritório / Profissional / Tabela de Rateio
				nAltura += 250
			Case cCCJuri $ "2"     // Escritório e Centro de Custo
				nAltura += 280
		EndCase

		If FindFunction("FwPDCanUse") .And. FwPDCanUse(.T.) // LGPD
			aCampos := {"OHV_DPART","OHV_DCLIEN","OHV_DCASO","OHV_DPROJE","OHV_DITPRJ","OHV_HISTOR"}
			aNoAcess := FwProtectedDataUtil():UsrNoAccessFieldsInList(aCampos)
			AEval(aNoAcess, {|x| AAdd( aOfuscar, x:CFIELD)})
		EndIf

		// Retorna o tamanho da tela
		aSize   := MsAdvSize(.T.) //Utiliza enchoice na tela
		nSizeTela := aSize[6]*0.95 // Diminui 5% da altura.

		If GetScreenRes()[01] >= 1920 .and. (  (Empty(cCCJuri) .Or. cCCJuri $ "5")  .Or. (lUtProj .Or. lContOrc) )
			If ! (cCCJuri $ "1|3|4") // Escritório / Profissional / Tabela de Rateio
				nProp := 2.18
			Else
				nProp := 2.2
			EndIf
		Else
			If lUtProj .Or. lContOrc		
				nProp := 2.20
			ElseIf cCCJuri $ "2" 	
				nProp := 2.22
			EndIf
		EndIf
			

		If nAltura > 0 .And. nSizeTela < (nAltura * nProp)
			nTamDialog := nSizeTela
		Else
			nTamDialog := nAltura * nProp
		EndIf


 		Define MsDialog oDlg title STR0018 STYLE DS_MODALFRAME FROM 0,0 To nTamDialog, 570  PIXEL//"Complemento NF de Entrada"
			oDlg:lEscClose := .F.
			
			If !lVisualiza
				bOk := {|| IIF(J281BOK(@oModel), ( J281Commit(@oModel), oDlg:End(), ) , nil) }
			EndIf

			If !__lRecord
				bCancel := {|| oDlg:End() } //"Cancelar"
			EndIf 

			oScroll := TScrollArea():New(oDlg,01,01,365,545)
			oScroll:Align := CONTROL_ALIGN_ALLCLIENT

			@ 000,000 MSPANEL oPanel OF oScroll SIZE nLargura, nAltura

			oLayer := FwLayer():New()
			oLayer:Init(oPanel, .F.)
			oLayer:addCollumn("MainColl",100,.F.) //Cria as colunas do Layer
			oMainColl := oLayer:GetColPanel( 'MainColl' )

			// Define objeto painel como filho do scroll
			oScroll:SetFrame(oPanel) 

			// "Cód Natureza"
			oCodNat := TJurPnlCampo():New(005,015,060,022,oMainColl, AllTrim(RetTitle("OHV_CNATUR")), ("OHV_CNATUR"),{|| },{|| },,,,,,,,,)
			oCodNat:SetWhen({|| J281DlgVal(@oModel, "OHV_CNATUR", cNaturNFE, cCCJuri) .And. .F. })
			oCodNat:SetValue(cNaturNFE)

			// "Desc Naturez"
			oDesNat := TJurPnlCampo():New(005,085,170,022,oMainColl, AllTrim(RetTitle("OHV_DNATUR")) ,("ED_DESCRIC"),{|| },{|| },,,,,,,,,aScan(aOfuscar,"OHV_DNATUR") > 0)
			oDesNat:SetWhen({||.F.})

			// "Vl. Título."
			oVlTit := TJurPnlCampo():New(035,015,90,022,oMainColl, STR0019, ("OHV_TOTAL"),{|| },{|| },,,,,,,,,) // "Vl. Título"
			oVlTit:SetWhen({|| .F.})
			oVlTit:SetValue(nValorNFE)

			// "Sigla Solic."
			oSiglSol := TJurPnlCampo():New(065,015,060,022,oMainColl, AllTrim(RetTitle("OHV_SIGLA")) ,("RD0_SIGLA"),{|| },{|| },,,,'RD0ATV',,,,,)
			oSiglSol:SetValid({|| J281DlgVal(@oModel, "OHV_SIGLA", oSiglSol:GetValue(), cCCJuri)})
			oSiglSol:SetWhen({||oModelOHV:CanSetValue("OHV_SIGLA")})
			oSiglSol:Enable(!lVisualiza)

			// "Nome Solic"
			oNomSigl := TJurPnlCampo():New(065,085,170,022,oMainColl, AllTrim(RetTitle("OHV_DPART ")) ,("OHV_DPART "),{|| },{|| },,,,,,,,,aScan(aOfuscar,"OHV_DPART") > 0)
			oNomSigl:SetWhen({||.F.})

			If cCCJuri $ "1|2" .Or. !lCCJuriDef // Escritório / Escritório - Centro de Custo / Não Definido
				// "Escritório  "
				oCodEsc := TJurPnlCampo():New(nCoordPos,015,060,022,oMainColl, AllTrim(RetTitle("OHV_CESCR")) ,("OHV_CESCR"),{|| },{|| },,,,'NS7ATV',,,,,)
				oCodEsc:SetValid({|| J281DlgVal(@oModel, "OHV_CESCR", oCodEsc:GetValue(), cCCJuri)})
				oCodEsc:SetWhen({||oModelOHV:CanSetValue("OHV_CESCR")})
				oCodEsc:Enable(!lVisualiza)

				// "Desc. Escrit"
				oDesEsc := TJurPnlCampo():New(nCoordPos,085,170,022,oMainColl, AllTrim(RetTitle("OHV_DESCR")) ,("OHV_DESCR"),{|| },{|| },,,,,,,,,aScan(aOfuscar,"OHV_DESCR") > 0)
				oDesEsc:SetWhen({||.F.})

				nCoordPos += 30

				If cCCJuri == "2" .Or. !lCCJuriDef // Escritório - Centro de Custo / Não Definido
					// "Centro Custo"
					oCodCc := TJurPnlCampo():New(nCoordPos,015,060,022,oMainColl, AllTrim(RetTitle("OHV_CCUSTO")) ,("OHV_CCUSTO"),{|| },{|| },,,,'CTTNS7',,,,,)
					oCodCc:SetValid({||J281DlgVal(@oModel, "OHV_CCUSTO", oCodCc:GetValue(), cCCJuri)})
					oCodCc:SetWhen({||oModelOHV:CanSetValue("OHV_CCUSTO")})
					oCodCc:Enable(!lVisualiza)

					//"Desc C Custo"
					oDesCc := TJurPnlCampo():New(nCoordPos,085,170,022,oMainColl, AllTrim(RetTitle("OHV_DCUSTO")) ,("OHV_DCUSTO"),{|| },{|| },,,,,,,,,aScan(aOfuscar,"OHV_DCUSTO") > 0)
					oDesCc:SetWhen({||.F.})

					nCoordPos += 30
				EndIf
			EndIf

			If cCCJuri == "3" .Or. !lCCJuriDef // Profissional / Não Definido
				// "Sigla Partic"
				oSigPart := TJurPnlCampo():New(nCoordPos,015,060,022,oMainColl, AllTrim(RetTitle("OHV_SIGLA2")) ,("RD0_SIGLA"),{|| },{|| },,,,'RD0ATV',,,,,)
				oSigPart:SetValid({||J281DlgVal(@oModel, "OHV_SIGLA2", oSigPart:GetValue(), cCCJuri)})
				oSigPart:SetWhen({||oModelOHV:CanSetValue("OHV_SIGLA2")})
				oSigPart:Enable(!lVisualiza)

				// "Nome Part." //
				oDesPart := TJurPnlCampo():New(nCoordPos,085,170,022,oMainColl, AllTrim(RetTitle("OHV_DPART2")) ,("OHV_DPART2"),{|| },{|| },,,,,,,,,aScan(aOfuscar,"OHV_DPART2") > 0)
				oDesPart:SetWhen({||.F.})

				nCoordPos += 30
			EndIf

			If cCCJuri == "4" .Or. !lCCJuriDef // Tabela de Rateio / Não Definido
				// "Tab. Rateio "
				oCodRate := TJurPnlCampo():New(nCoordPos,015,060,022,oMainColl, AllTrim(RetTitle("OHV_CRATEI")) ,("OH6_CODIGO"),{|| },{|| },,,,'OH6',,,,,)
				oCodRate:SetValid({||J281DlgVal(@oModel, "OHV_CRATEI", oCodRate:GetValue(), cCCJuri)})
				oCodRate:SetWhen({||oModelOHV:CanSetValue("OHV_CRATEI")})
				oCodRate:Enable(!lVisualiza)

				// "Desc. Rateio"
				oDesRate := TJurPnlCampo():New(nCoordPos,085,170,022,oMainColl, AllTrim(RetTitle("OHV_DRATEI")) ,("OHV_DRATEI"),{|| },{|| },,,,,,,,,aScan(aOfuscar,"OHV_DRATEI") > 0)
				oDesRate:SetWhen({||.F.})

				nCoordPos += 30
			EndIf

			If cCCJuri == "5" // Despesa de Cliente
				// "Cód Cliente" //
				oCliOr := TJurPnlCampo():New(nCoordPos,015,060,022,oMainColl, AllTrim(RetTitle("OHV_CCLIEN")) ,("OHV_CCLIEN"),{|| },{|| },,,,'SA1NUH',,,,,)
				oCliOr:SetValid({||J281DlgVal(@oModel, "OHV_CCLIEN", oCliOr:GetValue(), cCCJuri)})
				oCliOr:SetWhen({||oModelOHV:CanSetValue("OHV_CCLIEN")})
				oCliOr:Enable(!lVisualiza)
				If(cLojaAuto == "1")
					oCliOr:SetChange( {|| cCliOr := oCliOr:GetValue(), oLojaOr:SetValue(JurGetLjAt()), cLojaOr := JurGetLjAt() } )
				Else
					oCliOr:SetChange( {|| cCliOr := oCliOr:GetValue(), cLojaOr := oLojaOr:GetValue() } )
				EndIf

				// "Loja do F3, usado pois a função de valid apaga a loja quando o preenchimento veio do F3" //
				oLojaOrF3 := TJurPnlCampo():New(nCoordPos,085,030,022,oMainColl, "" ,("OHV_CLOJA "),{|| },{|| },,,,,,,,,)
				oLojaOrF3:SetValid({||J281DlgVal(@oModel, "OHV_CLOJA", oLojaOrF3:GetValue(), cCCJuri)})
				oLojaOrF3:SetWhen({||oModelOHV:CanSetValue("OHV_CLOJA")})
				oLojaOrF3:SetChange({|| cCliOr  := oCliOr:GetValue(),;
										cLojaOr := oLojaOr:GetValue()})
				oLojaOrF3:Visible(.F.)

				// "Loja"
				oLojaOr := TJurPnlCampo():New(nCoordPos,085,030,022,oMainColl, "" ,("OHV_CLOJA "),{|| },{|| },,,,,,,,,)
				oLojaOr:SetValid({||J281DlgVal(@oModel, "OHV_CLOJA", oLojaOr:GetValue(), cCCJuri)})
				oLojaOr:SetWhen({||oModelOHV:CanSetValue("OHV_CLOJA")})
				oLojaOr:Enable(!lVisualiza)
				oLojaOr:SetChange({|| cCliOr  := oCliOr:GetValue(),;
									cLojaOr := oLojaOr:GetValue()})
				oLojaOr:Visible(cLojaAuto == "2")

				// "Nome do Cliente"
				If cLojaAuto == "2"
					nPosLoja := 115
					nLarLoja := 140
				Else
					nPosLoja := 085
					nLarLoja := 170
				EndIf

				oDesCli := TJurPnlCampo():New(nCoordPos,nPosLoja,nLarLoja,022,oMainColl, AllTrim(RetTitle("OHV_DCLIEN")) ,("OHV_DCLIEN"),{|| },{|| },,,,,,,,,aScan(aOfuscar,"OHV_DCLIEN") > 0)
				oDesCli:SetWhen({||.F.})

				nCoordPos += 30

				// "Código Caso"
				oCasoOr := TJurPnlCampo():New(nCoordPos,015,060,022,oMainColl, AllTrim(RetTitle("OHV_CCASO")) ,("OHV_CCASO"),{|| },{|| },,,,'NVELOJ',,,,,)
				oCasoOr:SetValid({||J281DlgVal(@oModel, "OHV_CCASO", oCasoOr:GetValue(), cCCJuri)})
				oCasoOr:SetWhen({||oModelOHV:CanSetValue("OHV_CCASO")})
				oCasoOr:Enable(!lVisualiza)

				// "Desc. Caso"
				oDesCas := TJurPnlCampo():New(nCoordPos,085,170,022,oMainColl, AllTrim(RetTitle("OHV_DCASO")) ,("OHV_DCASO"),{|| },{|| },,,,,,,,,aScan(aOfuscar,"OHV_DCASO") > 0)
				oDesCas:SetWhen({||.F.})

				nCoordPos += 30

				// "Tipo Despesa"
				oCodDesp := TJurPnlCampo():New(nCoordPos,015,060,022,oMainColl, AllTrim(RetTitle("OHV_CTPDSP")) ,("NRH_COD"),{|| },{|| },,,,'NRH',,,,,)
				oCodDesp:SetValid({|| J281DlgVal(@oModel, "OHV_CTPDSP", oCodDesp:GetValue(), cCCJuri)})
				oCodDesp:SetWhen({|| oModelOHV:CanSetValue("OHV_CTPDSP") })
				oCodDesp:Enable(!lVisualiza)

				// "Desc Tp Desp"
				oDesDesp := TJurPnlCampo():New(nCoordPos,085,170,022,oMainColl, AllTrim(RetTitle("OHV_DTPDSP")) ,("NRH_DESC"),{|| },{|| },,,,,,,,,aScan(aOfuscar,"OHV_DTPDSP") > 0)
				oDesDesp:SetWhen({||.F.})

				nCoordPos += 30

				// "Qtd despesa "
				oQtdDes := TJurPnlCampo():New(nCoordPos,015,040,022,oMainColl, AllTrim(RetTitle("OHV_QTDDSP")) ,("OHV_QTDDSP"),{|| },{|| },,,,,,,,,)
				oQtdDes:SetValid({|| J281DlgVal(@oModel, "OHV_QTDDSP", oQtdDes:GetValue(), cCCJuri)})
				oQtdDes:SetWhen({|| oModelOHV:CanSetValue("OHV_QTDDSP") })
				oQtdDes:Enable(!lVisualiza)

				// "Data Despesa"
				oDtDesp := TJurPnlCampo():New(nCoordPos,085,060,022,oMainColl, AllTrim(RetTitle("OHV_DTDESP")) ,("OHV_DTDESP"),{|| },{|| },,,,,,,,,)
				oDtDesp:SetValid({|| J281DlgVal(@oModel, "OHV_DTDESP", oDtDesp:GetValue(), cCCJuri)})
				oDtDesp:SetWhen({|| oModelOHV:CanSetValue("OHV_DTDESP") })
				oDtDesp:Enable(!lVisualiza)

				// "Cobrar Desp?"
				oCbDesp := TJurPnlCampo():New(nCoordPos,155,060,025,oMainColl, AllTrim(RetTitle("OHV_COBRA")) ,("OHV_COBRA"),{|| },{|| },,,,,,,,,)
				oCbDesp:SetValid({|| J281DlgVal(@oModel, "OHV_COBRA", oCbDesp:GetValue(), cCCJuri)})
				oCbDesp:SetWhen({|| !lVisualiza .And. oModelOHV:CanSetValue("OHV_COBRA") .And. GetSX3Cache("OHV_COBRA", "X3_VISUAL") <> "V"})

				nCoordPos += 30
			EndIf

			If lUtProj .Or. lContOrc
				// "Código Projeto"
				oCodProj := TJurPnlCampo():New(nCoordPos,015,060,022, oMainColl, AllTrim(RetTitle("OHV_CPROJE")) ,("OHV_CPROJE"),{|| },{|| },,,,'OHL',,,,,)
				oCodProj:SetValid({||J281DlgVal(@oModel, "OHV_CPROJE", oCodProj:GetValue(), cCCJuri)})
				oCodProj:SetWhen({||oModelOHV:CanSetValue("OHV_CPROJE")})
				oCodProj:Enable(!lVisualiza)

				// "Desc. Projeto"
				oDesProj := TJurPnlCampo():New(nCoordPos,085,170,022, oMainColl, AllTrim(RetTitle("OHV_DPROJE")) ,("OHV_DPROJE"),{|| },{|| },,,,,,,,,aScan(aOfuscar,"OHV_DPROJE") > 0)
				oDesProj:SetWhen({||.F.})

				nCoordPos += 30

				// "Código Item Projeto"
				oCItProj := TJurPnlCampo():New(nCoordPos,015,060,022, oMainColl, AllTrim(RetTitle("OHV_CITPRJ")) ,("OHV_CITPRJ"),{|| },{|| },,,,'OHM',,,,,)
				oCItProj:SetValid({||J281DlgVal(@oModel, "OHV_CITPRJ", oCItProj:GetValue(), cCCJuri)})
				oCItProj:SetWhen({||!Empty(oCodProj:GetValue()) .And. oModelOHV:CanSetValue("OHV_CITPRJ")})
				oCItProj:Enable(!lVisualiza)

				// "Desc. Item Projeto"
				oDItProj := TJurPnlCampo():New(nCoordPos,085,170,022, oMainColl, AllTrim(RetTitle("OHV_DITPRJ")) ,("OHV_DITPRJ"),{|| },{|| },,,,,,,,,aScan(aOfuscar,"OHV_DITPRJ") > 0)
				oDItProj:SetWhen({||.F.})

				nCoordPos += 30
			EndIf

			// "Cód Hist Pad"
			oCodHp := TJurPnlCampo():New(nCoordPos,015,080,022,oMainColl, AllTrim(RetTitle("OHV_CHISTP")) ,("OHV_CHISTP"),{|| },{|| },,,,,,,,,)
			oCodHp:SetValid({|| J281DlgVal(@oModel, "OHV_CHISTP", oCodHp:GetValue(), cCCJuri)})
			oCodHp:SetWhen({|| oModelOHV:CanSetValue("OHV_CHISTP") })
			oCodHp:Enable(!lVisualiza)

			nCoordPos += 30

			// "Histórico"
			oHistor := TJurPnlCampo():New(nCoordPos,015,200,090,oMainColl, AllTrim(RetTitle("OHV_HISTOR")), ("OHV_HISTOR"),{|| },{|| },,,,,,,,,aScan(aOfuscar,"OHV_HISTOR") > 0)
			oHistor:SetValid({|| J281DlgVal(@oModel, "OHV_HISTOR", oHistor:GetValue(), cCCJuri)})
			oHistor:SetWhen({|| oModelOHV:CanSetValue("OHV_HISTOR") })
			oHistor:Enable(!lVisualiza)

		ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,bOK,bCancel,, nil     ,/*nRecno*/,/*cAlias*/, .F., .F.,.F.,.T.,.F. )

		oModel:DeActivate()
	EndIf

	RestArea(aArea)

Return lRetDlg

//-------------------------------------------------------------------
/*/{Protheus.doc} J281DlgVal
Valid dos campos da Dialog.
Valida os campos e preenche os campos referentes aos gatilhos da OHV

@param  oModel    Modelo de dados de Detalhes / Desdobramentos
@param  cCampo    Campo que será atualizado
@param  cValue    Valor que será indicado no cCampo
@param  cCCJuri   Centro de Custo Jurídico da natureza indicada no título
@param lLoadObj  Atualiza o arquivo alterado
@return lRet      Se verdadeiro o valor foi setado no modelo de dados

@author Jorge Martins
@since  28/07/2020
/*/
//-------------------------------------------------------------------
Static Function J281DlgVal(oModel, cCampo, cValue, cCCJuri)
Local aErro      := {}
Local lRet       := .T.
Local oModelOHV  := oModel:GetModel("OHVDETAIL")
Local lCCJuriDef := !Empty(cCCJuri) // Indica se a natureza tem Centro de Custo Jurídico definido
Local lUtProj    := SuperGetMv("MV_JUTPROJ", .F., .F., ) // Indica se será utilizado Projeto/Finalidade nas rotinas do Financeiro (.T. = Sim; .F. = Não)
Local lContOrc   := SuperGetMv("MV_JCONORC", .F., .F., ) // Indica se será utilizado Controle Orçamentário (.T. = Sim; .F. = Não)
Local cLojaAuto  := SuperGetMv("MV_JLOJAUT", .F., "2", ) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)

	If oModel:IsActive()
		If oModel:GetOperation() != MODEL_OPERATION_VIEW
			If oModelOHV:CanSetValue(cCampo)
				lRet := oModelOHV:SetValue(cCampo, cValue)
			EndIf

			If lRet .And. cCCJuri == "5" .And. !Empty(oLojaOrF3:GetValue()) .And. cLojaAuto == '2'
				lRet := oModelOHV:SetValue("OHV_CLOJA", oLojaOrF3:GetValue())
				oLojaOrF3:SetValue(CriaVar('OHV_CLOJA', .F.))
			EndIf
		EndIf

		If lRet
			oCodNat:SetValue( oModelOHV:GetValue("OHV_CNATUR"))
			oDesNat:SetValue( oModelOHV:GetValue("OHV_DNATUR"))
			oSiglSol:SetValue(oModelOHV:GetValue("OHV_SIGLA "))
			oNomSigl:SetValue(oModelOHV:GetValue("OHV_DPART "))
			If cCCJuri $ "1|2" .Or. !lCCJuriDef
				oCodEsc:SetValue( oModelOHV:GetValue("OHV_CESCR "))
				oDesEsc:SetValue( oModelOHV:GetValue("OHV_DESCR "))
				If cCCJuri == "2" .Or. !lCCJuriDef
					oCodCc:SetValue( oModelOHV:GetValue("OHV_CCUSTO"))
					oDesCc:SetValue( oModelOHV:GetValue("OHV_DCUSTO"))
				EndIf
			EndIf
			If cCCJuri == "3" .Or. !lCCJuriDef
				oSigPart:SetValue(oModelOHV:GetValue("OHV_SIGLA2"))
				oDesPart:SetValue(oModelOHV:GetValue("OHV_DPART2"))
			EndIf
			If cCCJuri == "4" .Or. !lCCJuriDef
				oCodRate:SetValue(oModelOHV:GetValue("OHV_CRATEI"))
				oDesRate:SetValue(oModelOHV:GetValue("OHV_DRATEI"))
			EndIf
			If cCCJuri == "5"
				oCliOr:SetValue(  oModelOHV:GetValue("OHV_CCLIEN"))
				oLojaOr:SetValue( oModelOHV:GetValue("OHV_CLOJA "))
				oDesCli:SetValue( oModelOHV:GetValue("OHV_DCLIEN"))
				oCasoOr:SetValue( oModelOHV:GetValue("OHV_CCASO "))
				oDesCas:SetValue( oModelOHV:GetValue("OHV_DCASO "))
				oCodDesp:SetValue(oModelOHV:GetValue("OHV_CTPDSP"))
				oDesDesp:SetValue(oModelOHV:GetValue("OHV_DTPDSP"))
				oQtdDes:SetValue( oModelOHV:GetValue("OHV_QTDDSP"))
				oDtDesp:SetValue( oModelOHV:GetValue("OHV_DTDESP"))
				oCbDesp:SetValue( oModelOHV:GetValue("OHV_COBRA "))
			EndIf
			If lUtProj .Or. lContOrc
				oCodProj:SetValue(oModelOHV:GetValue("OHV_CPROJE"))
				oDesProj:SetValue(oModelOHV:GetValue("OHV_DPROJE"))
				oCItProj:SetValue(oModelOHV:GetValue("OHV_CITPRJ"))
				oDItProj:SetValue(oModelOHV:GetValue("OHV_DITPRJ"))
			EndIf
			oCodHp:SetValue(  oModelOHV:GetValue("OHV_CHISTP"))
			oHistor:SetValue( oModelOHV:GetValue("OHV_HISTOR"))
		Else
			aErro := oModel:GetErrorMessage(.T.)
			Help("", 1, "HELP",, aErro[6], 1,,,,,,, {aErro[7]})
		EndIf
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J281GrvDes
Função para gravar desdobramentos com base nos títulos da NF

@param    oModel281, objeto   , Modelo de dados de desdobramentos da NF (OHV)
@param    cError   , caractere, Variável para mensagem de erro

@return   lGrvDes  , logico, Se verdadeiro a gravação dos desdobramento foi efetuada

@author  Jonatas Martins / Jorge Martins
@since   29/07/2020
/*/
//-------------------------------------------------------------------
Function J281GrvDes(oModel281, cError)
	Local aArea      := GetArea()
	Local aSE2       := SE2->(GetArea())
	Local aSE5       := SE5->(GetArea())
	Local lDeleteOHV := oModel281:GetOperation() == MODEL_OPERATION_DELETE
	Local nTotalNF   := MaFisRet(,"NF_TOTAL")
	Local nTotalTit  := 0
	Local nTit       := 0
	Local lGrvDes    := .T.
	Local aSaldoOHV  := {}
	Local nQtdTit    := Len(__aRecSE2)

	AEval(__aRecSE2, {|nRecno| nTotalTit += JCPVlBruto(nRecno)})

	For nTit := 1 to nQtdTit
		SE2->(DbGoTo(__aRecSE2[nTit]))

		If lDeleteOHV
			lGrvDes := JDelTitCP(__aRecSE2[nTit])
		Else
			lGrvDes := J281SetOHF(oModel281, @cError, @aSaldoOHV, nTotalNF, nTotalTit, nTit == nQtdTit)
		EndIf

		If !lGrvDes
			Exit
		EndIf
	Next nTit

	JurFreeArr(@aSaldoOHV)

	RestArea(aSE5)
	RestArea(aSE2)
	RestArea(aArea)

Return (lGrvDes)

//-------------------------------------------------------------------
/*/{Protheus.doc} J281SetOHF
Função para setar valores no modelo de desdobramentos

@param   oModel281 , objeto   , Modelo de dados de desdobramentos da NF (OHV)
@param   cError    , caractere, Variável para mensagem de erro
@param   nPropSE2  , numerico , Proporção com base na quantidade de títulos gerados
@param   aSaldoOHV , array    , Array com saldos da OHV para distribução em OHF,
                                quando houver parcelamento
@param   nTotalNF  , numérico , Valor total da NF de entrada
@param   nTotalNF  , numérico , Valor total na moeda do título
@param   lUltimoTit, lógico   , Indica se está sendo o cálculo do último título

@return  lSet     , logico   , Se verdadeiro a gravação dos desdobramento foi efetuada

@author  Jonatas Martins / Jorge Martins
@since   29/07/2020
/*/
//-------------------------------------------------------------------
Static Function J281SetOHF(oModel281, cError, aSaldoOHV, nTotalNF, nTotalTit, lUltimoTit)
	Local oModelOHV  := Nil
	Local oModel     := Nil
	Local oModelOHF  := Nil
	Local aSetValue  := {}
	Local nTotalItem := 0
	Local nLineOHV   := 0
	Local nVal       := 0
	Local lAddLine   := .F.
	Local lSet       := .T.
	Local nValSE2    := JCPVlBruto(SE2->(Recno()))

	J281VldFK7() // Função para validar a existência da FK7 devido a problemas de cache dos dados

	oModel := FWLoadModel("JURA246")
	oModel:SetOperation(MODEL_OPERATION_UPDATE)
	If oModel:Activate()
		oModelOHF := oModel:GetModel("OHFDETAIL")
		oModelOHV := oModel281:GetModel("OHVDETAIL")
	
		For nLineOHV := 1 To oModelOHV:Length()
			IIf(lAddLine, oModelOHF:AddLine(), lAddLine := .T.)

			If !oModel:HasErrorMessage()
				nTotalItem := oModelOHV:GetValue("OHV_TOTAL" , nLineOHV) ;
				           +  oModelOHV:GetValue("OHV_VALFRE", nLineOHV) ;
				           +  oModelOHV:GetValue("OHV_VLDESP", nLineOHV) ;
				           +  oModelOHV:GetValue("OHV_VALSEG", nLineOHV) ;
				           -  oModelOHV:GetValue("OHV_VLDESC", nLineOHV)

				IIf(Len(aSaldoOHV) < nLineOHV, aAdd(aSaldoOHV, RatPontoFl(nTotalItem, nTotalNF, nTotalTit, 2)), Nil)
				
				nTotalItem := RatPontoFl(nTotalItem, nTotalNF, nValSE2, 2)

				If lUltimoTit
					nTotalItem := aSaldoOHV[nLineOHV]
				Else
					aSaldoOHV[nLineOHV] -= nTotalItem
				EndIf

				// Array com os campos e os conteúdos a serem considerados no Desdobramento
				aAdd(aSetValue, {"OHF_FILIAL", SE2->E2_FILIAL})
				aAdd(aSetValue, {"OHF_CITEM" , oModelOHV:GetValue("OHV_ITEM", nLineOHV)})
				aAdd(aSetValue, {"OHF_CNATUR", oModelOHV:GetValue("OHV_CNATUR", nLineOHV)})
				aAdd(aSetValue, {"OHF_VALOR" , Round(nTotalItem, 2)})
				aAdd(aSetValue, {"OHF_SIGLA" , oModelOHV:GetValue("OHV_SIGLA" , nLineOHV)})
				aAdd(aSetValue, {"OHF_SIGLA2", oModelOHV:GetValue("OHV_SIGLA2", nLineOHV)})
				aAdd(aSetValue, {"OHF_CESCR" , oModelOHV:GetValue("OHV_CESCR" , nLineOHV)})
				aAdd(aSetValue, {"OHF_CCUSTO", oModelOHV:GetValue("OHV_CCUSTO", nLineOHV)})
				aAdd(aSetValue, {"OHF_CCLIEN", oModelOHV:GetValue("OHV_CCLIEN", nLineOHV)})
				aAdd(aSetValue, {"OHF_CLOJA" , oModelOHV:GetValue("OHV_CLOJA" , nLineOHV)})
				aAdd(aSetValue, {"OHF_CCASO" , oModelOHV:GetValue("OHV_CCASO" , nLineOHV)})
				aAdd(aSetValue, {"OHF_CTPDSP", oModelOHV:GetValue("OHV_CTPDSP", nLineOHV)})
				aAdd(aSetValue, {"OHF_QTDDSP", oModelOHV:GetValue("OHV_QTDDSP", nLineOHV)})
				aAdd(aSetValue, {"OHF_DTDESP", oModelOHV:GetValue("OHV_DTDESP", nLineOHV)})
				aAdd(aSetValue, {"OHF_COBRA" , oModelOHV:GetValue("OHV_COBRA" , nLineOHV)})
				aAdd(aSetValue, {"OHF_CRATEI", oModelOHV:GetValue("OHV_CRATEI", nLineOHV)})
				aAdd(aSetValue, {"OHF_CPROJE", oModelOHV:GetValue("OHV_CPROJE", nLineOHV)})
				aAdd(aSetValue, {"OHF_CITPRJ", oModelOHV:GetValue("OHV_CITPRJ", nLineOHV)})
				aAdd(aSetValue, {"OHF_CHISTP", oModelOHV:GetValue("OHV_CHISTP", nLineOHV)})
				aAdd(aSetValue, {"OHF_HISTOR", oModelOHV:GetValue("OHV_HISTOR", nLineOHV)})

				For nVal := 1 To Len(aSetValue)
					If oModelOHF:CanSetValue(aSetValue[nVal][1]) .And. !oModelOHF:SetValue(aSetValue[nVal][1], aSetValue[nVal][2])
						lSet := .F. // Saida do preenchimento de campos em caso de erro no modelo
						Exit
					EndIf
				Next nVal

				If !lSet
					Exit // Saida do While em caso de erro no modelo
				EndIf
			Else
				lSet := .F.
				Exit // Saida do While em caso de erro no modelo
			EndIf
		Next nLineOHV

		If lSet .And. oModel:VldData()
			oModel:CommitData()
			J281RepAnex(oModel, oModelOHV) // Replica os anexos do documento de entrada para os desdobramentos (OHF)
		Else
			lSet := .F.
			cError := cValToChar(oModel:GetErrorMessage()[4]) + ' - '
			cError += cValToChar(oModel:GetErrorMessage()[5]) + ' - '
			cError += cValToChar(oModel:GetErrorMessage()[6])
		EndIf

		oModel:DeActivate()
	EndIf
	
	JurFreeArr(@aSetValue)

Return (lSet)

//-------------------------------------------------------------------
/*/{Protheus.doc} J281VldFK7
Função para validar a existência da FK7 devido ao cache dos dados

@return  lFK7, Se verdadeiro a FK7 foi encontrada

@author  Jonatas Martins / Abner Fogaça
@since   09/03/2021
/*/
//-------------------------------------------------------------------
Static Function J281VldFK7()
Local cChave    := SE2->E2_FILIAL+'|'+SE2->E2_PREFIXO+'|'+SE2->E2_NUM+'|'+SE2->E2_PARCELA+'|'+SE2->E2_TIPO+'|'+SE2->E2_FORNECE+'|'+SE2->E2_LOJA
Local cIdDoc    := FINGRVFK7('SE2', cChave)
Local cNewIdDoc := ""
Local lFK7      := .F.
	
	FK7->(DbSetOrder(1)) // FK7_FILIAL + FK7_IDDOC
	If !FK7->(DbSeek(xFilial("FK7") + cIdDoc))
		cNewIdDoc := FINGRVFK7("SE2", cChave)
	Else
		cNewIdDoc := cIdDoc
	EndIf

	FK7->(DbSetOrder(2)) // FK7_FILIAL + FK7_ALIAS + FK7_CHAVE
	FK7->(DbSeek(xFilial("FK7") + "SE2" + cChave))

	lFK7 := FK7->FK7_IDDOC == cNewIdDoc

Return (lFK7)

//-------------------------------------------------------------------
/*/{Protheus.doc} JA281WHEN
When dos campos da OHV - Desdobramento financeiro da NF de entrada

1 - Escritório
2 - Escritório e Centro de Custos
3 - Profissional
4 - Tabela de Rateio
5 - Despesa Cliente
6 - Transitória de Pagamentos

@author bruno.ritter
@since  07/08/2017
@obs    Função chamada no X3_WHEN dos campos da OHV
/*/
//-------------------------------------------------------------------
Function JA281WHEN()
	Local cCampo  := Alltrim(StrTran(ReadVar(), 'M->', ''))
	Local cModelo := "OHVDETAIL"
	Local cNatur  := "OHV_CNATUR"
	Local cEscrit := "OHV_CESCR"
	Local cCusto  := "OHV_CCUSTO"
	Local cSigla  := "OHV_SIGLA2"
	Local cRateio := "OHV_CRATEI"
	Local cClient := "OHV_CCLIEN"
	Local cLoja   := "OHV_CLOJA"
	Local cCaso   := "OHV_CCASO"
	Local lX3When := .T.

	// Grupo Natureza
	If cCampo $ 'OHV_CESCR'
		lX3When := JurWhNatCC("1", cModelo, cNatur, cEscrit, cCusto, cSigla, cRateio)

	ElseIf cCampo $ 'OHV_CCUSTO'
		lX3When := JurWhNatCC("2", cModelo, cNatur, cEscrit, cCusto, cSigla, cRateio)

	ElseIf cCampo $ 'OHV_SIGLA2|OHV_CPART2'
		lX3When := JurWhNatCC("3", cModelo, cNatur, cEscrit, cCusto, cSigla, cRateio)

	ElseIf cCampo $ 'OHV_CRATEI'
		lX3When := JurWhNatCC("4", cModelo, cNatur, cEscrit, cCusto, cSigla, cRateio)

	// Grupo Despesa
	ElseIf cCampo $ 'OHV_CCLIEN|OHV_CLOJA|OHV_QTDDSP|OHV_COBRA|OHV_DTDESP|OHV_CTPDSP'
		lX3When := JurWhNatCC("5", cModelo, cNatur, , , , , cClient, cLoja, cCaso)

	ElseIf cCampo $ 'OHV_CCASO'
		lX3When := JurWhNatCC("6", cModelo, cNatur, , , , , cClient, cLoja, cCaso)
	EndIf

Return (lX3When)

//-------------------------------------------------------------------
/*/{Protheus.doc} J281NatTit
Identifica se a natureza do título da NF de entrada
é transitório ou definida.

@return  cCCJurNat, caractere, Centro de custo jurídico da natureza

@author  Jorge Martins
@since   29/07/2020
/*/
//-------------------------------------------------------------------
Static Function J281NatTit()
	Local aNatur     := {}
	Local cCCJurNat  := ""
	Local cQuery     := ""

	cQuery := " SELECT DISTINCT ED_CCJURI CCJURNAT "
	cQuery +=   " FROM " + RetSqlName("SE2") + " SE2 "
	cQuery +=   " INNER JOIN " + RetSqlName("SED") + " SED "
	cQuery +=           " ON SED.ED_FILIAL  = '" + xFilial("SED") + "' "
	cQuery +=          " AND SED.ED_CODIGO = SE2.E2_NATUREZ "
	cQuery +=          " AND SED.D_E_L_E_T_ = ' ' "
	cQuery +=  " WHERE SE2.E2_FILIAL  = '" + xFilial("SE2") + "' "
	cQuery +=    " AND SE2.E2_PREFIXO = '" + SF1->F1_PREFIXO + "' "
	cQuery +=    " AND SE2.E2_NUM     = '" + SF1->F1_DOC + "' "
	cQuery +=    " AND SE2.E2_TIPO    = '" + MVNOTAFIS + "' "
	cQuery +=    " AND SE2.E2_ORIGEM  = '" + PadR("MATA100", TamSx3("E2_ORIGEM")[1], "") + "' "
	cQuery +=    " AND SE2.D_E_L_E_T_ = ' ' "

	aNatur := JurSQL(cQuery, "CCJURNAT")

	If Len(aNatur)
		cCCJurNat := aNatur[1][1]
	EndIf

Return (cCCJurNat)

//-------------------------------------------------------------------
/*/{Protheus.doc} J281VldExc
Função para validar se é possível excluir os desdobramentos

@param   aRecSE2, array , Recno dos títulos a pagar vinculados NF de entrada

@return  lVldExc, logico, Se verdairo permite a exclusão dos desdobramentos

@author  Jonatas Martins / Abner Fogaça
@since   29/07/2020
@obs     Função chamada no fonte MATA103
/*/
//-------------------------------------------------------------------
Function J281VldExc(aRecSE2)
	Local aArea     := GetArea()
	Local aAreaSE2  := SE2->(GetArea())
	Local oModel246 := Nil
	Local oModelOHF := Nil
	Local nTit      := 1
	Local nLine     := 0
	Local nQtdOHF   := 0
	Local lVldExc   := .T.

	Default aRecSE2 := {}

	For nTit := 1 To Len(aRecSE2)
		SE2->(DbGoTo(aRecSE2[nTit]))

		// Ignora títulos de impostos
		If SE2->E2_TIPO == MVTAXA
			Loop
		EndIf
	
		oModel246 := FWLoadModel("JURA246")
		oModel246:SetOperation(MODEL_OPERATION_UPDATE)
		
		If oModel246:Activate()
			oModelOHF := oModel246:GetModel("OHFDETAIL")
			nQtdOHF   := oModelOHF:GetQtdLine()
			For nLine := 1 To nQtdOHF
				oModelOHF:GoLine(nLine)
				If !oModelOHF:DeleteLine()
					lVldExc := .F.
					Exit
				EndIf
			Next nLine
			
			If lVldExc .And. !oModel246:VldData()
				lVldExc := .F.
				Exit
			EndIf
		Else
			lVldExc := .F.
			Exit
		EndIf
		oModel246:DeActivate()
	Next nTit

	If !lVldExc
		JurMsgErro("", , STR0011) // "Ajustes as inconsistências."
		If oModel246:IsActive()
			oModel246:DeActivate()
		EndIf
	EndIf

	RestArea(aAreaSE2)
	RestArea(aArea)

Return (lVldExc)

//-------------------------------------------------------------------
/*/{Protheus.doc} J281Clear
Função para limpar o cache do modelo ao Cancelar o documento de entrada

@author  Jonatas Martins / Abner Fogaça
@since   11/08/2020
@obs     Função chamada no botão cancelar do fonte MATA103
/*/
//-------------------------------------------------------------------
Function J281Clear()
	If ValType("__cMdlPFS") == "C"
		__cMdlPFS := ""
	EndIf
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J281DelImp
Função para excluir desdobramento de títulos de impostos

@author  Jonatas Martins / Abner Fogaça
@since   11/08/2020
@obs     Função no fonte MATA103
/*/
//-------------------------------------------------------------------
Function J281DelImp(nSE2Recno)
	Local lDelOHFImp := .T.

	// Título de impostos a pagar
	If SE2->E2_TIPO == MVTAXA
		lDelOHFImp := JDelTitCP(nSE2Recno)
	EndIf

Return (lDelOHFImp)

//-------------------------------------------------------------------
/*/{Protheus.doc} JAnexoM103
Função utilizada no botão de anexar documentos no cadastro de 
documento de entrada

@author Jorge Martins / Abner Oliveira
@since  26/03/2021
@Obs    Função chamada no fonte MATA103
/*/
//-------------------------------------------------------------------
Function JAnexoM103()
Local cChaveSF1 := CNFISCAL + CSERIE + CA100FOR + CLOJA

	JurAnexos("SF1", cChaveSF1, , , .T.)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JAnxM103
Função utilizada no botão de anexar documentos no cadastro de 
documento de entrada

@author Jorge Martins / Abner Oliveira
@since  26/03/2021
@Obs    Função chamada no fonte MATA103
/*/
//-------------------------------------------------------------------
Function JAnxM103()
Local cChaveSF1 := SF1->(F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA)
Local oModel    := NIL
Local nTamTipo  := SE2->(TamSx3("E2_TIPO")[1])
Local cQuery    := ""
Local aSE2      := {}
Local nC        := 0
Local aAreaSE2  := {}
Local oModel281 := FwLoadModel("JURA281")
Local oModelOHV := NIL
Local aAnxAnt   := J281GtAnNF()
Local aArea     := GetArea()
Local aAreaOHV  := OHV->(GetArea())

	JurAnexos("SF1", cChaveSF1, , , .T.)

	OHV->(DBSetOrder(1)) // OHV_FILIAL + OHV_DOC + OHV_SERIE + OHV_FORNEC + OHV_LOJA + OHV_COD + OHV_ITEM
	If OHV->(DBSeek(xFilial("OHV") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA))

		oModel281:SetOperation(MODEL_OPERATION_VIEW)
		__cMdlPFS := oModel281:GetXmlData(,,,,.F.) 
		If !oModel281:IsActive() .And. oModel281:CanActivate()
			oModel281:Activate()
		EndIf
		
		oModelOHV := oModel281:GetModel("OHVDETAIL")
		__cMdlPFS := ""

		cQuery := "SELECT R_E_C_N_O_ "
		cQuery +=  " FROM " + RetSqlName("SE2")
		cQuery += " WHERE E2_FILIAL = '" + xFilial("SE2") + "'"
		cQuery +=   " AND E2_NUM      = '" + SF1->F1_DOC  + "'"
		cQuery +=   " AND E2_PREFIXO  = '" + SF1->F1_SERIE + "'"
		cQuery +=   " AND E2_FORNECE  = '" + SF1->F1_FORNECE + "'"
		cQuery +=   " AND E2_LOJA     = '" + SF1->F1_LOJA + "'"
		cQuery +=   " AND E2_TIPO     = '" + Left(MVNOTAFIS,nTamTipo) + "'"
		cQuery +=   " AND D_E_L_E_T_  = ' '"

		aSE2 := JurSql(cQuery, "*")

		// Posiciona nos dedobramentos para realizar os anexos
		If Len(aSE2) > 0
			aAreaSE2 := SE2->(GetArea())

			For nC := 1 to Len(aSE2)
				SE2->(DbGoTo(aSE2[nC, 01]))
				If J281VldFK7()
					oModel := FWLoadModel("JURA246")
					oModel:SetOperation(MODEL_OPERATION_VIEW)
					If oModel:Activate()
						// Replica os desdobramentos cadastrados
						J281RepAnex(oModel, oModelOHV, aAnxAnt)
						oModel:DeActivate()
					EndIf
				EndIf
			Next nC
			RestArea(aAreaSE2)
		EndIf

		oModel281:DeActivate()
	EndIf

	RestArea(aAreaOHV)
	RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J281RepAnex
Replica os anexos no momento da classificação do documento NF entrada
para os desdobramentos (OHF).

@param oModel   , Modelo de dados dos desdobramentos (OHF)
@param oModelOHV, Modelo de dados dos desdobramentos da NF (OHV)
@param aAnxAnt  , Anexos cadastrados anteriormente

@author Jorge Martins | Abner Fogaça
@since 26/02/21
/*/
//-------------------------------------------------------------------
Function J281RepAnex(oModel, oModelOHV, aAnxAnt)
Local aAreaNUM   := {}
Local aDados     := {}
Local nArq       := 0
Local nLine      := 0
Local lReplica   := .T.
Local cArquivo   := ""
Local cNomArq    := ""
Local cExtencao  := ""
Local cDescArq   := ""
Local cTpAnexo   := AllTrim( SuperGetMv("MV_JDOCUME", , "1"))
Local cFilEnt    := ""
Local cEntidade  := "OHF"
Local cItem      := ""
Local cChave     := SE2->E2_FILIAL+'|'+SE2->E2_PREFIXO+'|'+SE2->E2_NUM+'|'+SE2->E2_PARCELA+'|'+SE2->E2_TIPO+'|'+SE2->E2_FORNECE+'|'+SE2->E2_LOJA
Local cIdDoc     := NIL
Local lWorkSite  := cTpAnexo == "1"
Local lJurClass  := .T.
Local oModelOHF  := Nil
Local cEntId     := ""
Local lAtivo     := .T. //Excluído ativo
Local lFoundNUM  := .F.
Local nX         := 0
Local nPos       := 0
Local cQuery     := ""
Local aQuery     := {}
Local cAddQry    := ""
Local cPath      := ""
Local cNomObj    := ""
Local cNatPosPag := ""

Default aAnxAnt := {}
	
	oModelOHF := oModel:GetModel("OHFDETAIL")
	If !oModelOHV:IsEmpty() .And. !oModelOHF:IsEmpty()

		aDados := J281GtAnNF() //Retorna os anexos da NF

		//Identifica os novos anexos e anexos excluídos, baseado no cadastrado anteriormente
		For nX := 1 to Len(aAnxAnt)
			If (nPos := aScan(aDados, {|a| a[1] == aAnxAnt[nX, 01] })) = 0
				aAnxAnt[nX, 05] := "*"
				aAdd(aDados, aClone(aAnxAnt[nX]))
			Else
				aDel(aDados, nPos)
				aSize(aDados, Len(aDados)-1)
			EndIf
		Next nX 

		If Len(aDados) > 0
			aAreaNUM   := NUM->(GetArea())
			lJurClass  := FindFunction("JurHasClas") .And. JurHasClas()
			cFilEnt    := xFilial("OHF")
			cPath      := IIf(lJurClass, MsDocPath(), "")
			cIdDoc     := FINGRVFK7('SE2', cChave)
			cNatPosPag := JurBusNat("6") // Natureza transitória de pós pagamento

			cQuery := "SELECT R_E_C_N_O_"
			cQuery +=  " FROM " + RetSqlName("NUM") + " NUM "
			cQuery += " WHERE NUM.NUM_FILIAL = '" + xFilial("NUM") + "'"
			cQuery +=   " AND NUM.NUM_FILENT = '" + xFilial("OHF") + "'"
			cQuery +=   " AND NUM.NUM_ENTIDA = 'OHF'"
			cQuery +=   " AND NUM.D_E_L_E_T_ = ' '"

			For nArq := 1 To Len(aDados)
				cNomObj   := Alltrim(aDados[nArq][1])
				cNomArq   := AllTrim(aDados[nArq][2])
				cDescArq  := AllTrim(aDados[nArq][4])
				cExtencao := AllTrim(aDados[nArq][3])
				lAtivo    := Empty(aDados[nArq][5])
				
				For nLine := 1 To oModelOHV:GetQtdLine()

					If !oModelOHV:IsDeleted(nLine) .And. oModelOHV:GetValue("OHV_CNATUR", nLine) <> cNatPosPag;
					   .And. oModelOHF:SeekLine({{"OHF_CITEM", oModelOHV:GetValue("OHV_ITEM", nLine)}}, .F.,.T. )

						cItem  := oModelOHF:GetValue("OHF_CITEM")
						//Verifica se o arquivo não existe
						If lJurClass .Or. lWorkSite
							cEntId := cIdDoc + cItem
						Else
							cEntId := cFilEnt  + cIdDoc + cItem 
						EndIf	
						cAddQry := " AND NUM_CENTID = '" + cEntId + "'"+;
								   " AND NUM_DOC = '" + cNomArq + "'"
						aQuery := JurSQL(cQuery+cAddQry, '*')

						If (lFoundNUM := Len(aQuery) > 0 .And. !Empty(aQuery[01, 01]))
							NUM->(DbGoTo(aQuery[01, 01]))
						EndIf

						If !lFoundNUM .And. lAtivo
			
							If lWorkSite
								lReplica := J235GrvAnx(cEntidade, cFilEnt, cIdDoc + cItem, cNomArq, cExtencao, cDescArq, cTpAnexo)[1]
							Else
								cArquivo := cPath + "\" + cNomObj
								If J026Anexar(cEntidade, cFilEnt, cIdDoc + cItem, "", cArquivo, .T.)[1]
									lReplica := J235GrvAnx(cEntidade, cFilEnt, cIdDoc + cItem, cNomArq, cExtencao, cDescArq, cTpAnexo)[1]
								EndIf
							EndIf

							If !lReplica
								Exit
							EndIf
						ElseIf !lAtivo .And. lFoundNUM
							//Anexo excluído e localizado
							If FindFunction("JExcDAnSinc")
								JExcDAnSinc(cTpAnexo == "2") // Exclui os anexos vinculados ao desdobramento excluído
							EndIf
						EndIf
					EndIf
				Next nLine
			Next nArq
			RestArea(aAreaNUM)
		EndIf
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J281ExcDoc
Rotina chamada ao excluir o documento de entrada (NF)

@OBS: Utilizado nas funções:
      - A103NFiscal (MATA103) - Exclusão de notas classificadas
                                (Tela do Documento de Entrada - Desdobramento)
      - A140NFiscal (MATA140) - Exclusão de notas não classificadas
                                (Tela da Pré nota)

@author Jorge Martins | Abner Fogaça
@since  01/03/21
/*/
//-------------------------------------------------------------------
Function J281ExcDoc()
Local cChaveSF1 := SF1->(F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA)//CNFISCAL + CSERIE + CA100FOR + CLOJA

	If FindFunction("JExcAnxSinc")
		JExcAnxSinc("SF1", cChaveSF1) // Exclui os anexos vinculados a NF de Entrada e registra na fila de sincronização
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J281GtAnNF
Rotina chamada para retornar os anexos vinculados a NF de Entrada

@author fabiana.silva
@since  12/08/2021
/*/
//-------------------------------------------------------------------
Static Function J281GtAnNF()
Local cQuery  := ""
Local aAnexos := {}

	// Verifica se existem anexos vinculados a NF
	cQuery :=     "SELECT NUM.NUM_NUMERO, NUM.NUM_DOC, NUM.NUM_EXTEN, NUM.NUM_DESC, NUM.D_E_L_E_T_ AS EXCLUIDO"
	cQuery +=      " FROM " + RetSqlName("NUM") + " NUM "
	cQuery +=     " INNER JOIN " + RetSqlName("SF1") + " SF1 "
	cQuery +=        " ON SF1.F1_FILIAL = '" + xFilial("SF1") + "'"
	cQuery +=       " AND SF1.F1_DOC = '" + SF1->F1_DOC + "'"
	cQuery +=       " AND SF1.F1_SERIE = '" + SF1->F1_SERIE + "'"
	cQuery +=       " AND SF1.F1_FORNECE = '" + SF1->F1_FORNECE + "'"
	cQuery +=       " AND SF1.F1_LOJA = '"  + SF1->F1_LOJA + "'"
	cQuery +=       " AND SF1.D_E_L_E_T_ = ' '"
	cQuery +=     " WHERE NUM.NUM_FILIAL = '" + xFilial("NUM") + "'"
	cQuery +=       " AND NUM.NUM_FILENT = '" + xFilial("SF1") + "'"
	cQuery +=       " AND NUM.NUM_ENTIDA = 'SF1'"
	cQuery +=       " AND NUM.NUM_CENTID = '" + SF1->(F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA) + "'"
	cQuery +=       " AND NUM.D_E_L_E_T_ = ' '"
	cQuery +=     " ORDER BY NUM.NUM_NUMERO "

	aAnexos := JurSQL(cQuery, "*")

Return aAnexos
