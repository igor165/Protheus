#INCLUDE "JURA235C.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE nNatur    1 // Natureza
#DEFINE nEscri    2 // Escritório
#DEFINE nCCusto   3 // Centro de Custo
#DEFINE nProfis   4 // Sigla do Profissional
#DEFINE nTabRat   5 // Tabela de Rateio
#DEFINE nProjeto  6 // Projeto
#DEFINE nItem     7 // Item do Projeto
#DEFINE CSSLINHA  "color: #C2C2C2;"

Static _cEscrit  := CriaVar("NZQ_CESCR", .F.)  // Variável utilzada para filtro no F3 do centro de custo
Static _cProjeto := CriaVar("OHM_CPROJE", .F.) // Variável utilzada para filtro no F3 de item do Projeto
Static _aRegMark := {}                         // Variável para controle de marca dos registros
Static _lFwPDCanUse := FindFunction("FwPDCanUse")

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA235C
Alteração em lote de solicitação de despesas

@author  Jonatas Martins
@since   07/00/2019
/*/
//-------------------------------------------------------------------
Function JURA235C()
	Local aArea     := GetArea()
	Local aCoors    := FwGetDialogSize(oMainWnd)
	Local oMBrw235C := Nil
	Local oDlg235C  := Nil

	DEFINE MSDIALOG oDlg235C TITLE STR0001 FROM aCoors[1], aCoors[2] To aCoors[3], aCoors[4] STYLE nOR( WS_VISIBLE, WS_POPUP ) PIXEL //"Alteração em Lote"

	oMBrw235C := FWMarkBrowse():New()
	oMBrw235C:SetDescription(STR0001) // "Alteração em Lote"
	oMBrw235C:SetAlias("NZQ")
	oMBrw235C:DisableReport()
	oMBrw235C:oBrowse:SetDBFFilter(.T.)
	oMBrw235C:oBrowse:SetUseFilter()
	oMBrw235C:oBrowse:SetVldExecFilter({|| J235CClear()})
	oMBrw235C:SetMenuDef('')
	oMBrw235C:AddButton(STR0002, {|| IIF(Empty(_aRegMark), JurMsgErro(STR0003, "JURA235C"), J235CDlgEsc(oMBrw235C)),, 4, 1}) // "Alterar" ### "Nenhum registro selecionado!"
	oMBrw235C:AddButton(STR0025, {|| FWExecView(STR0025, "JURA235A", 1)},, 1, 1) // "Visualizar"
	oMBrw235C:SetOwner(oDlg235C)
	oMBrw235C:AddMarkColumns({|| IIF(aScan(_aRegMark, NZQ->(Recno())) > 0, "LBOK", "LBNO")}, {|| J235CMark()}, {|| J235CAllMark(oMBrw235C)})
	oMBrw235C:SetFilterDefault("NZQ->NZQ_SITUAC == '1' .And. NZQ->NZQ_DESPES == '2'") // Filtra despesas de escritório que estão em aberto
	oMBrw235C:ForceQuitButton(.T.)
	oMBrw235C:oBrowse:SetBeforeClose({ || oMBrw235C:oBrowse:VerifyLayout()})
	oMBrw235C:SetProfileID("1")
	oMBrw235C:Activate()

	ACTIVATE MSDIALOG oDlg235C CENTERED

	JurFreeArr(_aRegMark)
	_cEscrit  := ""
	_cProjeto := ""
	
	RestArea(aArea)
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J235CClear
Limpar registros marcados ao executar um filtro no browse

@author Jonatas Martins
@since  07/09/2019
/*/
//-------------------------------------------------------------------
Function J235CClear()
	JurFreeArr(_aRegMark)
Return (.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} J235CMark
Faz o controle da marcação/desmarção de cada registro.

@author Jonatas Martins
@since  07/09/2019
/*/
//-------------------------------------------------------------------
Static Function J235CMark()
	Local nNZQRecno := NZQ->(Recno())
	Local nTotReg   := Len(_aRegMark)
	Local nPosReg   := 0

	nPosReg := IIF(nTotReg == 0, 0, aScan(_aRegMark, nNZQRecno))

	If nPosReg > 0
		ADel(_aRegMark, nPosReg)
		ASize(_aRegMark, nTotReg - 1)
	Else
		AAdd(_aRegMark, nNZQRecno)
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J235CAllMark
Faz o controle da marcação/desmarção de todos os registros.

@param  oMBrw235C, objeto, Estrutura do MarkBrowse

@author Jonatas Martins
@since  07/09/2019
/*/
//-------------------------------------------------------------------
Static Function J235CAllMark(oMBrw235C)
	Local nTotReg   := Len(_aRegMark)
	Local nNZQRecno := 0
	Local nPosReg   := 0

	oMBrw235C:GoTop(.T.)

	While NZQ->(! EOF())
		nNZQRecno := NZQ->(Recno())
		nPosReg   := aScan(_aRegMark, nNZQRecno)
		If nPosReg > 0
			ADel(_aRegMark, nPosReg)
			ASize(_aRegMark, nTotReg - 1)
			nTotReg -= 1
		Else
			AAdd(_aRegMark, nNZQRecno)
			nTotReg += 1
		EndIf

		NZQ->(DbSkip())
	EndDo

	oMBrw235C:Refresh(.T.)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J235CDlgEsc
Exibe tela de alteração dos dados para escritório

@param  oMBrw235C, objeto, Estrutura do MarkBrowse

@author Jonatas Martins
@since  07/09/2019
/*/
//-------------------------------------------------------------------
Static Function J235CDlgEsc(oMBrw235C)
	Local lProjetos  := SuperGetMV("MV_JUTPROJ", .F., .F.) // Indica se será utilizado Projeto/Finalidade nas rotinas do Financeiro. (.T. = Sim; .F. = Não)
	Local lContOrc   := SuperGetMv("MV_JCONORC", .F., .F.) // Indica se será utilizado Controle Orçamentário (.T. = Sim; .F. = Não)
	Local oDlg       := Nil
	Local oLayer     := Nil
	Local oMainColl  := Nil
	Local aDados     := Array(7)
	Local nLargura   := 270
	Local nTamanho   := IIF(lProjetos .Or. lContOrc, 215, 155)

	Local oDesNat    := Nil
	Local oDesEsc    := Nil
	Local oDesCc     := Nil
	Local oDesProf   := Nil
	Local oDesRate   := Nil
	Local oDesProj   := Nil
	Local oDesItem   := Nil
	Local oSay       := Nil
	Local aCposLGPD     := {}
	Local aNoAccLGPD    := {}
	Local aDisabLGPD    := {}


	If _lFwPDCanUse .And. FwPDCanUse(.T.)
		aCposLGPD := {"NZQ_DCTADE","NZQ_DESCR","NZQ_DGRJUR","NZQ_NOMPRO","NZQ_DRATEI","OHL_DPROJE","NZQ_DITPRJ"}

		aDisabLGPD := FwProtectedDataUtil():UsrNoAccessFieldsInList(aCposLGPD)
		AEval(aDisabLGPD, {|x| AAdd( aNoAccLGPD, x:CFIELD)})

	EndIf

	oDlg := FWDialogModal():New()
	oDlg:SetFreeArea(nLargura, nTamanho)
	oDlg:SetEscClose(.F.)    // Não permite fechar a tela com o ESC
	oDlg:SetCloseButton(.F.) // Não permite fechar a tela com o "X"
	oDlg:SetBackground(.T.)  // Escurece o fundo da janela
	oDlg:SetTitle(STR0001) // "Alteração em Lote"
	oDlg:CreateDialog()
	oDlg:AddOkButton({|| IIF(J235CTOk(aDados), FwMsgRun(Nil, {|| J235CProc(aDados, oMBrw235C), oDlg:oOwner:End()}, STR0004, STR0005), Nil)}) //"Processando" ### "Alterando dados, aguarde..."
	oDlg:AddCloseButton({|| oDlg:oOwner:End() }) // "Botão Cancelar"

	oLayer := FwLayer():New()
	oLayer:Init(oDlg:GetPanelMain(), .F.)
	oLayer:AddCollumn("MainColl", 100, .F.) //Cria as colunas do Layer
	oMainColl := oLayer:GetColPanel("MainColl")

	// "Natureza"
	aDados[nNatur] := TJurPnlCampo():New(005,015,060,022,oMainColl, AllTrim(RetTitle("NZQ_CTADES")) ,("NZQ_CTADES"),{|| },{|| },,,,'SEDOHB')
	aDados[nNatur]:SetValid({|| J235CSetChg(aDados[nNatur], @oDesNat, "SED", , {aDados[nEscri], @oDesEsc, aDados[nCCusto], oDesCc, aDados[nProfis], oDesProf, aDados[nTabRat], oDesRate}, aDados),;
	                            J235CTrig(aDados[nNatur]:GetValue(), aDados[nTabRat], oDesRate)})

	// "Desc Naturez"
	oDesNat := TJurPnlCampo():New(005,085,170,022,oMainColl, AllTrim(RetTitle("NZQ_DCTADE")) ,("ED_DESCRIC"),{|| },{|| },,,,,,,,,aScan(aNoAccLGPD,"NZQ_DCTADE") > 0)
	oDesNat:SetWhen({||.F.})

	// "Escritório"
	aDados[nEscri] := TJurPnlCampo():New(035,015,060,022,oMainColl, AllTrim(RetTitle("NZQ_CESCR")) ,("NZQ_CESCR"),{|| },{|| },,,,'NS7ATV')
	aDados[nEscri]:SetWhen({|| J235CWhen(aDados, "NZQ_CESCR")})
	aDados[nEscri]:SetValid({|| J235CSetChg(@aDados[nEscri], @oDesEsc, "NS7", , {aDados[nCCusto], oDesCc}, aDados)})

	// "Desc. Escrit" //
	oDesEsc := TJurPnlCampo():New(035,085,170,022,oMainColl, AllTrim(RetTitle("NZQ_DESCR")) ,("NZQ_DESCR"),{|| },{|| },,,,,,,,,aScan(aNoAccLGPD,"NZQ_DESCR") > 0)
	oDesEsc:SetWhen({||.F.})

	// "Centro de Custo"
	aDados[nCCusto] := TJurPnlCampo():New(065,015,060,022,oMainColl, AllTrim(RetTitle("NZQ_GRPJUR")) ,("NZQ_GRPJUR"),{|| },{|| },,,,'CTTNS7')
	aDados[nCCusto]:SetWhen({|| J235CWhen(aDados, "NZQ_GRPJUR")})
	aDados[nCCusto]:SetValid({|| J235CSetChg(aDados[nCCusto], @oDesCc, "CTT", {aDados[nEscri]})})
	
	//"Desc C Custo" 
	oDesCc := TJurPnlCampo():New(065,085,170,022,oMainColl, AllTrim(RetTitle("NZQ_DGRJUR")) ,("NZQ_DGRJUR"),{|| },{|| },,,,,,,,,aScan(aNoAccLGPD,"NZQ_DGRJUR") > 0)
	oDesCc:SetWhen({||.F.})

	// "Profissional"
	aDados[nProfis] := TJurPnlCampo():New(095,015,060,022,oMainColl, AllTrim(RetTitle("NZQ_SIGPRO")) ,("NZQ_SIGPRO"),{|| },{|| },,,,'RD0REV')
	aDados[nProfis]:SetWhen({|| J235CWhen(aDados, "NZQ_SIGPRO")})
	aDados[nProfis]:SetValid({|| J235CSetChg(aDados[nProfis], @oDesProf, "RD0B")})

	// "Nome Profissional"
	oDesProf := TJurPnlCampo():New(095,085,170,022,oMainColl, AllTrim(RetTitle("NZQ_NOMPRO")) ,("NZQ_NOMPRO"),{|| },{|| },,,,,,,,,aScan(aNoAccLGPD,"NZQ_NOMPRO") > 0)
	oDesProf:SetWhen({||.F.})

	// "Tabela de Rateio"
	aDados[nTabRat] := TJurPnlCampo():New(125,015,060,022,oMainColl, AllTrim(RetTitle("NZQ_CRATEI")) ,("NZQ_CRATEI"),{|| },{|| },,,,'OH6')
	aDados[nTabRat]:SetWhen({|| J235CWhen(aDados, "NZQ_CRATEI")})
	aDados[nTabRat]:SetValid({|| J235CSetChg(aDados[nTabRat], @oDesRate, "OH6")})

	// "Desc. Rateio"
	oDesRate := TJurPnlCampo():New(125,085,170,022,oMainColl, AllTrim(RetTitle("NZQ_DRATEI")) ,("NZQ_DRATEI"),{|| },{|| },,,,,,,,,aScan(aNoAccLGPD,"NZQ_DRATEI") > 0)
	oDesRate:SetWhen({||.F.})

	If lProjetos .Or. lContOrc
		// "Projeto"
		oSay := TSay():Create(oMainColl,{|| Replicate("-", 300) },148,015,,,,,,.T.,,,237,020)
		oSay:SetCSS(CSSLINHA)
		aDados[nProjeto] := TJurPnlCampo():New(155,015,060,022,oMainColl, AllTrim(RetTitle("NZQ_CPROJE")) ,("NZQ_CPROJE"),{|| },{|| },,,,'OHL')
		aDados[nProjeto]:SetValid({|| J235CSetChg(aDados[nProjeto], @oDesProj, "OHL", ,{aDados[nItem], oDesItem})})

		// "Desc. Projeto"
		oDesProj := TJurPnlCampo():New(155,085,170,022,oMainColl, AllTrim(RetTitle("OHL_DPROJE")) ,("OHL_DPROJE"),{|| },{|| },,,,,,,,,aScan(aNoAccLGPD,"OHL_DPROJE") > 0)
		oDesProj:SetWhen({||.F.})

		// Item do Projeto
		aDados[nItem] := TJurPnlCampo():New(185,015,060,022,oMainColl, AllTrim(RetTitle("NZQ_CITPRJ")) ,("NZQ_CITPRJ"),{|| },{|| },,,,'OHM')
		aDados[nItem]:SetWhen({|| !Empty(aDados[nProjeto]:GetValue())})
		aDados[nItem]:SetValid({|| J235CSetChg(aDados[nItem], @oDesItem, "OHM", {aDados[nProjeto]})})

		// "Desc. Item Projeto"
		oDesItem := TJurPnlCampo():New(185,085,170,022,oMainColl, AllTrim(RetTitle("NZQ_DITPRJ")) ,("NZQ_DITPRJ"),{|| },{|| },,,,,,,,,aScan(aNoAccLGPD,"NZQ_DITPRJ") > 0)
		oDesItem:SetWhen({||.F.})
	EndIf

	oDlg:Activate()

	JurFreeArr(aDados)
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J235ANatWh
Libera alteração dos campos de tabela de rateio ou participante 
dependendo do Centro de Custo Jurídico da natureza

@param   cNatureza, caractere, código da natureza
@param   cCampo   , caractere, campo de avaliação do when
@param   cValor   , caractere, valor da tabela de reteio ou profissional

@author  Jonatas Martins
@since   17/10/2017
/*/
//-------------------------------------------------------------------
Function J235CWhen(aDados, cCampo)
	Local cNatureza  := aDados[nNatur]:GetValue()
	Local cTpConta   := ""
	Local cCCJuriNat := ""
	Local cEscrit    := ""
	Local cCCusto    := ""
	Local cProfis    := ""
	Local cTabRat    := ""
	Local lWhen      := .F.

	If !Empty(cNatureza) 
		cTpConta := JurGetDados("SED", 1, xFilial("SED") + cNatureza, "ED_TPCOJR") 
	
		If cTpConta != "1" // 1-Banco/Caixa
			cCCJuriNat := JurGetDados("SED", 1, xFilial("SED") + cNatureza, "ED_CCJURI")
			cEscrit    := aDados[nEscri]:GetValue()
			cCCusto    := aDados[nCCusto]:GetValue()
			cProfis    := aDados[nProfis]:GetValue()
			cTabRat    := aDados[nTabRat]:GetValue()
			
			Do Case
				Case cCampo == "NZQ_CESCR"  // 1=Escritório
					lWhen := cCCJuriNat $ "1|2" .Or. Empty(cCCJuriNat + cProfis + cTabRat)

				Case cCampo == "NZQ_GRPJUR" // 2=Escritório e C.C. Jurídico
					
					lWhen := !Empty(cEscrit) .And. (cCCJuriNat == "2" .Or. Empty(cCCJuriNat + cProfis + cTabRat))
					
				Case cCampo == "NZQ_SIGPRO" // 3=Profissional
					lWhen := cCCJuriNat == "3" .Or. (Empty(cCCJuriNat + cEscrit + cTabRat))

				Case cCampo == "NZQ_CRATEI" // 4=Tabela de Rateio
					lWhen := cCCJuriNat == "4" .Or. (Empty(cCCJuriNat + cEscrit + cProfis))
			End Case
		EndIf
	EndIf

Return lWhen

//-------------------------------------------------------------------
/*/ { Protheus.doc } J235CSetChg
Função para validar os campos e executar os gatilhos

@param   oCod   , objeto   , Objeto que contém o código do registro
@param   oDesc  , objeto   , Objeto que contém a descrição do registro
@param   cTab   , caractere, Tabela onde serão localizadas as informações
@param   aAux   , array    , Array com Objeto(s) para informações auxiliares de validação
@param   aLimpa , array    , Array com Objeto(s) que devem ter seu conteúdo limpo
@param   aDados , arrau    , Array com objetos da tela de alteração

@Return  lRet   , logico   ,  Indica se o preenchimento do campo está correto

@author  Jonatas Martins
@since   28/08/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J235CSetChg(oCod, oDesc, cTab, aAux, aLimpa, aDados)
	Local lRet      := .T.
	Local nI        := 0
	Local cCod      := oCod:GetValue()
	Local cDesc     := ""
	Local cEscrit   := ""
	Local cProjeto  := ""
	Local cBoxCCJur := ""
	Local aErro     := {}
	Local aRetDados := {}

	Default oDesc   := Nil
	Default aAux    := {}
	Default aLimpa  := {}

	Do Case
		Case cTab == "RD0B" // Profissional
			
			lRet := Empty(cCod) .Or. ( ExistCpo('RD0', cCod, 9) .And. J235CVldPro(cCod))

			If lRet .And. !Empty(cCod)
				cDesc := JurGetDados("RD0", 9, xFilial("RD0") + cCod, "RD0_NOME")
			EndIf

		Case cTab == "SED" // Natureza

			If !Empty(cCod)
				aRetDados := JurGetDados("SED", 1, xFilial("SED") + cCod, {"ED_MSBLQL", "ED_CMOEJUR", "ED_CCJURI", "ED_DESCRIC"})
				lRet      := Len(aRetDados) == 4 .And. aRetDados[1] != "1" .And. !Empty(aRetDados[2]) .And. !(aRetDados[3] $ "5|6|7|8") // 5 - Despesa de cliente; 6 - Trans. de Pagamento; 7 - Trans. Pós pagamento; 8 - Trans. Recebimento

				If lRet
					cDesc := aRetDados[4]
					If Len(aLimpa) > 0
						For nI := 1 To Len(aLimpa)
							If !J235CWhen(aDados, aLimpa[nI]:CNOMECAMPO)
								aLimpa[nI]:Clear()
							EndIf
						Next 
					EndIf
				Else
					cBoxCCJur := CRLF + AllTrim(JurInfBox("ED_CCJURI", "5", "3")) // 5 - Despesa de Cliente
					cBoxCCJur += CRLF + AllTrim(JurInfBox("ED_CCJURI", "6", "3")) // 6 - Transitória de Pagamento
					cBoxCCJur += CRLF + AllTrim(JurInfBox("ED_CCJURI", "7", "3")) // 7 - Transitória Pós Pagamento
					cBoxCCJur += CRLF + AllTrim(JurInfBox("ED_CCJURI", "8", "3")) // 8 - Transitória de Recebimento
					aErro := {STR0006, I18N(STR0007, {cBoxCCJur})} // "Natureza inválida ou inexistente." ### "Serão aceitas somente naturezas não bloqueadas e com Centro de Custo Jurídico diferentes de: #1"
				EndIf
			EndIf

		Case cTab == "NS7" // Escritório

			If !Empty(cCod)
				aRetDados := JurGetDados("NS7", 1, xFilial("NS7") + cCod, {"NS7_NOME", "NS7_ATIVO"})
				lRet      := Len(aRetDados) == 2 .And. aRetDados[2] == '1' /*NS7_ATIVO*/

				If lRet
					cDesc     := aRetDados[1]
					_cEscrit  := cCod // Seta variavel private para filtro no F3 de Centro de Custo
				Else
					aErro := {STR0008, STR0009} // "Escritório inválido ou inexistente!" ### "Informe um código válido para o escritório. Serão aceitos somente escritórios ativos."
				EndIf
			EndIf

			If Len(aLimpa) > 0
				For nI := 1 To Len(aLimpa)
					If !J235CWhen(aDados, aLimpa[nI]:CNOMECAMPO)
						aLimpa[nI]:Clear()
					EndIf
				Next 
			EndIf

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
					aErro := {STR0010, I18n(STR0011, {cEscrit})} // "Centro de custo inválido."  ### "Informe um código válido para o centro de custo. Serão aceitos somente centros de custo de classe analitica e não bloqueados que estejam vinculados ao escritório '#1'."
				EndIf
			EndIf

		Case cTab == "OH6" // Tabela de Rateio

			lRet := Empty(cCod) .Or. JURRAT(cCod, .T.)

			If lRet .And. !Empty(cCod)
				cDesc := JurGetDados("OH6", 1, xFilial("OH6") + cCod, "OH6_DESCRI")
			EndIf

		Case cTab == "OHL" // Tabela de Projetos
			lRet := Empty(cCod) .Or. JurVldProj(cCod)

			If lRet .And. !Empty(cCod)
				cDesc      := JurGetDados("OHL", 1, xFilial("OHL") + cCod, "OHL_DPROJE")
				_cProjeto  := cCod // Seta variavel estatica para filtro no F3 de Item do Projeto
			EndIf

			If Len(aLimpa) > 0 .And. oCod:GetValueOld() != cCod
				For nI := 1 To Len(aLimpa)
					aLimpa[nI]:Clear()
				Next 
			EndIf

		Case cTab == "OHM" // Tabela de Projetos
		
			If !Empty(cCod)

				If Len(aAux) == 1
					cProjeto := aAux[1]:GetValue()
				EndIf
				
				lRet := ExistCpo('OHM', cProjeto + cCod, 1)

				If lRet .And. !Empty(cCod)
					cDesc := JurGetDados("OHM", 1, xFilial("OHM") + cProjeto + cCod, "OHM_DITEM")
				EndIf
			
			EndIf

	EndCase

	If lRet
		oDesc:SetValue(AllTrim(cDesc))
	ElseIf Len(aErro) > 0
		JurMsgErro(aErro[1],, aErro[2])
	EndIf

	JurFreeArr(aErro)
	JurFreeArr(aRetDados)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J235CVldPro
Validação de Profissional

@Param   cSiglaProf, caracter, Sigla do Profissional
@Return  lRet      , logico, Verdadeiro / Falso

@author  Jonatas Martins
@since   07/09/2019
/*/
//-------------------------------------------------------------------
Static Function J235CVldPro(cSiglaProf)
	Local cPart := ""
	Local aProf := {}
	Local lRet  := .T.

	cPart := JurGetDados("RD0", 9, xFilial("RD0") + cSiglaProf, "RD0_CODIGO")
	aProf := JurGetDados("NUR", 1, xFilial("NUR") + cPart, {"NUR_SOCIO", "NUR_REVFAT"})
	If aProf[1] <> "1" .And. aProf[2]  <> "1"
		lRet := .F.
		JurMsgErro(STR0012) // "Profissional inválido!"
	EndIf

Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} J235CTOk
Valida se foram digitados dados na tela de alteração

@return  lTOk, logico, Verdadeiro / Falso

@author  Jonatas Martins
@since   07/09/2019
/*/
//-------------------------------------------------------------------
Static Function J235CTOk(aDados)
	Local cNatureza  := aDados[nNatur]:GetValue()
	Local cCCJuriNat := JurGetDados("SED", 1, xFilial("SED") + cNatureza, "ED_CCJURI")
	Local cTpConta   := JurGetDados("SED", 1, xFilial("SED") + cNatureza, "ED_TPCOJR")
	Local lContOrc   := SuperGetMv("MV_JCONORC", .F., .F.) // Indica se será utilizado Controle Orçamentário (.T. = Sim; .F. = Não)

	Local cProjeto   := ""
	Local cItem      := ""
	Local lTOk       := .F.

	If Empty(cNatureza) .Or. cTpConta == "1" // 1-Banco/Caixa
		lTOk := .T.
	Else
		Do Case
			Case cCCJuriNat == "1" .And. Empty(aDados[nEscri]:GetValue()) //1=Escritório
				JurMsgErro(STR0015, "J235CTOk", STR0016) // "Escritório não preenchido!" ### "Preencha o escritório."

			Case cCCJuriNat == "2" .And. (Empty(aDados[nEscri]:GetValue()) .Or. Empty(aDados[nCCusto]:GetValue())) //2=Escritório e C.C. Jurídico
				JurMsgErro(STR0017, "J235CTOk", STR0018) // "Escritório ou centro de custo não preenchido!" ### "Preencha o escritório e o centro de custo."

			Case cCCJuriNat == "3" .And. Empty(aDados[nProfis]:GetValue()) //3=Profissional
				JurMsgErro(STR0019, "J235CTOk", STR0020) // "Profissional não preenchido!" ### "Preencha o profissional."

			Case cCCJuriNat == "4" .And. Empty(aDados[nTabRat]:GetValue()) //4=Tabela de Rateio
				JurMsgErro(STR0021, "J235CTOk", STR0022) // "Tabela de rateio não preenchida!" ### "Preencha a tabela de rateio."
				
			OtherWise
				lTOk := .T.
		End Case
	EndIf

	If lTOk .And. lContOrc
		cProjeto := aDados[nProjeto]:GetValue()
		cItem    := aDados[nItem]:GetValue()

		If !Empty(cProjeto) .And. Empty(cItem)
			lTOk := .F.
			JurMsgErro(STR0023, "J235CTOk", STR0024) // "Item do projeto não preenchido!" ### "Preencha o item do projeto."

		ElseIf !Empty(cNatureza) .And. cTpConta $ "4|8" .And. (Empty(cProjeto) .Or. Empty(cItem))
			lTOk := .F.
			cBoxTpCta := AllTrim(JurInfBox("ED_TPCOJR", "4", "3")) + " e " + AllTrim(JurInfBox("ED_TPCOJR", "8", "3"))
			JurMsgErro(I18N(STR0026, {cBoxTpCta}), "J235CTOk", STR0027) // "Para os tipos de conta: #1 , o preenchimento do projeto e item é obrigatório!" ### "Preencha o projeto e item."
		EndIf
	EndIf
	
Return (lTOk)

//-------------------------------------------------------------------
/*/{Protheus.doc} J235CProc
Processa as alterações das solicitações de despesas

@param  aDados   , array, Dados que serão alterados
@param  oMBrw235C, objeto, Estrutura do MarkBrowse

@author  Jonatas Martins
@since   07/09/2019
/*/
//-------------------------------------------------------------------
Static Function J235CProc(aDados, oMBrw235C)
	Local aAreaNZQ  := NZQ->(GetArea())
	Local lProjetos := SuperGetMV("MV_JUTPROJ", .F., .F.) // Indica se será utilizado Projeto/Finalidade nas rotinas do Financeiro. (.T. = Sim; .F. = Não)
	Local lContOrc  := SuperGetMv("MV_JCONORC", .F., .F.) // Indica se será utilizado Controle Orçamentário (.T. = Sim; .F. = Não)
	Local nTotReg   := Len(_aRegMark)
	Local nReg      := 0

	Local cNatureza := aDados[nNatur]:GetValue()
	Local cEscrit   := aDados[nEscri]:GetValue()
	Local cCCusto   := aDados[nCCusto]:GetValue()
	Local cProfis   := JurGetDados("RD0", 9, xFilial("RD0") + aDados[nProfis]:GetValue(), "RD0_CODIGO") 
	Local cTabRat   := aDados[nTabRat]:GetValue()
	Local cProj     := ""
	Local cItem     := ""

	If lProjetos .Or. lContOrc
		cProj := aDados[nProjeto]:GetValue()
		cItem := aDados[nItem]:GetValue()
	EndIf

	For nReg := 1 To nTotReg
		NZQ->(DbGoTo(_aRegMark[nReg]))
		
		If NZQ->(! Eof())
			RecLock("NZQ", .F.)
			NZQ->NZQ_CTADES := IIF(Empty(cNatureza), NZQ->NZQ_CTADES, cNatureza)
			NZQ->NZQ_CESCR  := IIF(Empty(cEscrit)  , NZQ->NZQ_CESCR , cEscrit  )
			NZQ->NZQ_GRPJUR := IIF(Empty(cCCusto)  , NZQ->NZQ_GRPJUR, cCCusto  )
			NZQ->NZQ_CODPRO := IIF(Empty(cProfis)  , NZQ->NZQ_CODPRO, cProfis  )
			NZQ->NZQ_CRATEI := IIF(Empty(cTabRat)  , NZQ->NZQ_CRATEI, cTabRat  )
			If lProjetos .Or. lContOrc
				NZQ->NZQ_CPROJE := IIF(Empty(cProj), NZQ->NZQ_CPROJE, cProj)
				NZQ->NZQ_CITPRJ := IIF(Empty(cItem), NZQ->NZQ_CITPRJ, cItem)
			EndIf
			NZQ->(MsUnLock())
		
			J170GRAVA("JURA235A", xFilial("NZQ") + NZQ->NZQ_COD, "4")
		EndIf
	Next nReg

	ApMsgInfo(I18N(STR0028, {AllTrim(Str(IIF(nReg == 1, nReg, nReg -1))), AllTrim(Str(nTotReg))})) // "#1 de #2 despesa(s) alterada(s) com sucesso!"
	
	JurFreeArr(_aRegMark)
	RestArea(aAreaNZQ)
	oMBrw235C:GoTop(.T.)
	oMBrw235C:Refresh(.T.)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J235CGetEs
Função para obter dados do escritório na tela de de alteração em lote da
solicitação.

@return   _cEscrit, caractere, Escritório para filtro de centro de custo

@author   Jonatas Martins
@since    07/09/2019
@obs      Função chamada no fonte JURXFUNC na função "JFtCTTNS7"
/*/
//-------------------------------------------------------------------
Function J235CGetEs()
Return (_cEscrit)

//-------------------------------------------------------------------
/*/{Protheus.doc} J235CGetPrj
Função para obter dados do projeto na tela de alteração em lote da
solicitação.

@return   _cProjeto, caractere, Código do projeto para filtro de item do projeto

@author   Jonatas Martins
@since    07/09/2019
@obs      Função chamada no fonte JURXFIN na função "JFiltPrj"
/*/
//-------------------------------------------------------------------
Function J235CGetPrj()
Return (_cProjeto)

//-------------------------------------------------------------------
/*/{Protheus.doc} J235CTrig
Tringger para sugerir a tabela de rateio após informar uma natureza do mesmo tipo

@param cNatureza, Código da natureza
@param oTabRat  , Objeto do código da tabela de rateio
@param oDesRate , Objeto da descrição da tabela de rateio

@return   Nil

@author   Bruno Ritter
@since    02/10/2019
/*/
//-------------------------------------------------------------------
Static Function J235CTrig(cNatureza, oTabRat, oDesRate)
	Local cCodRat  := ""
	Local cDescRat := ""

	If !Empty(cNatureza)
		cCodRat := JurGetDados("SED", 1, xFilial("SED") + cNatureza, "ED_RATJUR")

		If !Empty(cCodRat)
			cDescRat := JurGetDados("OH6", 1, xFilial("OH6") + cCodRat, "OH6_DESCRI")

			oTabRat:SetValue(cCodRat)
			oDesRate:SetValue(cDescRat)
		EndIf
	EndIf

Return Nil