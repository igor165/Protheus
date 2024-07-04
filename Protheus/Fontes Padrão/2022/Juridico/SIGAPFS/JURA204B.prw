#INCLUDE "JURA204B.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"

Static _aFaturas := {}

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA204B
Vínculo de Time Sheets na fatura

@Return lRet, Retorna se pode executar a rotina

@author  Jonatas Martins
@since   17/10/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA204B()
	Local lRet       := .T.
	Local lDatavinc  := NW0->(ColumnPos('NW0_DTVINC')) > 0 //Proteção
	Local cMsgSoluc  := ""

	If lDatavinc
		J204BRetFat(NXA->NXA_CPREFT, NXA->NXA_CFIXO, NXA->NXA_CFTADC) // Carrega as faturas de multiplos pagadores

		If lRet .And. !(NXA->NXA_SITUAC == '1' .And. NXA->NXA_TIPO == 'FT')
			cMsgSoluc := STR0027 // "Para utilizar a rotina de Vínculo de Time Sheets a fatura deve estar ativa."
			lRet      := .F.
		EndIf

		If lRet .And. !J204BTemFix() .And. !J204BTemFA()
			cMsgSoluc := STR0052        //"Para utilizar a rotina de Vínculo de Time Sheets é necessário haver:"
			cMsgSoluc += CRLF + STR0053 //"Contratos com parcela fixa que não cobram hora."
			cMsgSoluc += CRLF + STR0054 //"Ou Fatura adicional com valor de time sheet."
			lRet      := .F.
		EndIf

		If lRet .And. !J204BVldFt(NXA->NXA_CPREFT, NXA->NXA_CFIXO, NXA->NXA_CFTADC, @cMsgSoluc)
			lRet := .F.
		EndIf

		If lRet
			FWMsgRun( , {|| J204BDlg()}, STR0001, STR0002) // "Vínculo de Time Sheets" ## "Carregando dados, aguarde..."
		Else
			JurMsgErro(STR0003, , cMsgSoluc) // "Não é possível acessar a opção Vínculo de Time Sheets."
		EndIf
		JurFreeArr(_aFaturas)
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J204BDlg
Monta tela com Markbrowses

@author  Jonatas Martins
@since   17/10/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J204BDlg()
	Local oFWLayer     := Nil
	Local oPanelUp     := Nil
	Local oPanelCent   := Nil
	Local oPanelDown   := Nil
	Local aCoors       := FwGetDialogSize(oMainWnd)
	Local cLojaAuto    := SuperGetMv("MV_JLOJAUT", .F., "2") //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
	Local aStruPend    := {}
	Local aStruVinc    := {}
	Local aFieldsFlt   := {}
	Local aFieldsTmp   := {}
	Local aOrder       := {}
	Local aFieldsBrw   := {}
	Local aOfuscaPen   := {}
	Local aOfuscaVin   := {}
	Local lLimitaTS    := SuperGetMv("MV_JLIMVTS", .F., .T.) //Indica se o vínculo de TSs será limitado ao valor faturado .T.-Sim ou .F.-Não

	Private oDlg204B   := Nil
	Private oMkBrwPend := Nil
	Private oMkBrwVinc := Nil
	Private oTmpPend   := Nil
	Private oTmpVinc   := Nil
	Private oMoeda     := Nil
	Private oTotBase   := Nil
	Private oTsVEmis   := Nil
	Private oTsVinc    := Nil
	Private oDescFat   := Nil
	Private oSaldoVinc := Nil
	Private oTsPenVinc := Nil
	Private cAlsPend   := ""
	Private cAlsVinc   := ""

	//--------------------------------------------
	//Estrutura da tabela temporária TS Pendentes
	//--------------------------------------------
	aStruPend  := JA204BQry(.T.)
	oTmpPend   := aStruPend[1] // FWTemporaryTable
	aFieldsFlt := aStruPend[2] // Campos de filtro
	aOrder     := aStruPend[3] // Indices da tabela
	aFieldsBrw := aStruPend[4] // Campos do FWMBrowse
	aOfuscaPen := IIf(Len(aStruPend) >= 7 .And. !Empty(aStruPend[7]), aStruPend[7], {})
	cAlsPend   := oTmpPend:GetAlias()
	aFieldsTmp := (cAlsPend)->(dbStruct()) // Campos da tabela temporária

	//--------------------------------------------
	//Estrutura da tabela temporária TS Vinculados
	//--------------------------------------------
	aStruVinc  := JA204BQry(.F.)
	oTmpVinc   := aStruVinc[1]
	aOfuscaVin := IIf(Len(aStruVinc) >= 7 .And. !Empty(aStruVinc[7]), aStruVinc[7], {})
	cAlsVinc   := oTmpVinc:GetAlias()

	// Tela de exibição
	DEFINE MSDIALOG oDlg204B TITLE STR0001 FROM aCoors[1], aCoors[2] To aCoors[3], aCoors[4] STYLE nOR( WS_VISIBLE, WS_POPUP ) PIXEL //"Vínculo de Time Sheets"

	oFWLayer := FWLayer():New()
	oFWLayer:Init(oDlg204B, .F., .T.)

	// Painel Superior
	oFWLayer:AddLine("UP", 45, .F.)
	oFWLayer:AddCollumn("PENDENTE", 100, .T., "UP")
	oPanelUp := oFWLayer:GetColPanel("PENDENTE", "UP")

	// Browse Superior TS pendentes
	oMkBrwPend := FWMarkBrowse():New()
	oMkBrwPend:SetOwner(oPanelUp)
	oMkBrwPend:SetDescription(STR0005) //"Time Sheets Pendentes"
	oMkBrwPend:SetAlias(cAlsPend)
	oMkBrwPend:SetTemporary(.T.)
	oMkBrwPend:SetFields(aFieldsBrw)
	oMkBrwPend:oBrowse:SetSeek(.T., aOrder)
	oMkBrwPend:oBrowse:SetFieldFilter(aFieldsFlt)
	oMkBrwPend:SetProfileID("B")
	oMkBrwPend:ForceQuitButton(.T.)
	oMkBrwPend:oBrowse:SetBeforeClose({ || oMkBrwPend:oBrowse:VerifyLayout(),  oMkBrwVinc:oBrowse:VerifyLayout()})
	IIF(cLojaAuto == "1", JurBrwRev(oMkBrwPend, "NUE", {"NUE_CLOJA"}), Nil)
	
	oMkBrwPend:SetMenuDef("")
	oMkBrwPend:DisableDetails()
	oMkBrwPend:DisableReport()
	oMkBrwPend:SetCustomMarkRec({|| J204BSetMk(oMkBrwPend, .T., cAlsPend)})
	oMkBrwPend:SetAllMark({|| J204BAllMk(oMkBrwPend, .T., cAlsPend)})
	oMkBrwPend:SetFieldMark( "NUE_OK" )

	If !Empty(aOfuscaPen) // Tratamento para LGPD verifica os campos que devem ser ofuscados
		oMkBrwPend:oBrowse:SetObfuscFields(aOfuscaPen)
	EndIf

	// Painel centro
	oFWLayer:addLine("CENTER", 40, .F.)
	oFWLayer:AddCollumn("PANELCENTER",  100, .T., "CENTER")
	oPanelCent := oFWLayer:GetColPanel("PANELCENTER", "CENTER")

	oMkBrwVinc := FWMarkBrowse():New()
	oMkBrwVinc:SetOwner(oPanelCent)
	oMkBrwVinc:SetDescription(STR0006) //"Time Sheets Vinculados"
	oMkBrwVinc:SetAlias(cAlsVinc)
	oMkBrwVinc:SetTemporary(.T.)
	oMkBrwVinc:SetFields(aFieldsBrw)
	oMkBrwVinc:oBrowse:SetSeek(.T., aOrder)
	oMkBrwVinc:oBrowse:SetFieldFilter(aFieldsFlt)
	oMkBrwVinc:SetProfileID("C")
	IIF(cLojaAuto == "1", JurBrwRev(oMkBrwVinc, "NUE", {"NUE_CLOJA"}), )
	
	oMkBrwVinc:SetMenuDef("")
	oMkBrwVinc:DisableDetails()
	oMkBrwVinc:DisableReport()
	oMkBrwVinc:SetFieldMark( "NUE_OK" )
	oMkBrwVinc:SetCustomMarkRec({|| J204BSetMk(oMkBrwVinc, .F., cAlsVinc)})
	oMkBrwVinc:SetAllMark({|| J204BAllMk(oMkBrwVinc, .F., cAlsVinc)})

	If !Empty(aOfuscaVin) // Tratamento para LGPD verifica os campos que devem ser ofuscados
		oMkBrwVinc:oBrowse:SetObfuscFields(aOfuscaVin)
	EndIf

	// Painel Inferior
	oFWLayer:addLine("DOWN", 15, .F.)
	oFWLayer:AddCollumn("PANELDOWN",  100, .T., "DOWN")
	oPanelDown := oFWLayer:GetColPanel("PANELDOWN", "DOWN")

	oMoeda     := TJurPnlCampo():New(005, 005, 080, 025, oPanelDown, STR0029, "CTO_SIMB"  , {|| }, {|| }, "",, .F.) // "Moeda da Fatura"
	oTotBase   := TJurPnlCampo():New(005, 100, 080, 025, oPanelDown, STR0055, "NXA_VLFATH", {|| }, {|| }, 0 ,, .F.) // "Valor Total Base"
	oDescFat   := TJurPnlCampo():New(005, 195, 080, 025, oPanelDown, STR0032, "NXA_VLDESC", {|| }, {|| }, 0 ,, .F.) // "Descontos da Fatura"
	oTsPenVinc := TJurPnlCampo():New(005, 290, 080, 025, oPanelDown, STR0030, "NXA_VLFATH", {|| }, {|| }, 0 ,, .F.) // "Valor TSs Pendentes"
	oTsVEmis   := TJurPnlCampo():New(005, 385, 080, 025, oPanelDown, STR0046, "NXA_VLFATH", {|| }, {|| }, 0 ,, .F.) // "Valor TSs Vinc. na Emissão"
	oTsVinc    := TJurPnlCampo():New(005, 480, 080, 025, oPanelDown, STR0033, "NXA_VLFATH", {|| }, {|| }, 0 ,, .F.) // "Valor TSs Vinc. Pós Emissão"
	If lLimitaTS
		oSaldoVinc := TJurPnlCampo():New(005, 575, 080, 025, oPanelDown, STR0034, "NXA_VLFATH", {|| }, {|| }, 0 ,, .F.) // "Saldo para vínculo"
		oSaldoVinc:oCampo:SetCss("QLineEdit{ font-weight: bold; }")
	EndIf

	J204BLeg()  // Cria legenda nos browses
	J204BMenu(aFieldsTmp) // Cria menu nos browses

	oMkBrwPend:Activate()
	oMkBrwVinc:Activate()

	J204BAtSld() // Atualiza os valores do resumo
	
	ACTIVATE MSDIALOG oDlg204B CENTERED

	// Limpa variáveis Private e Arrays
	JurFreeArr({aStruPend, aStruVinc, aFieldsTmp, aOrder, aFieldsBrw, aFieldsFlt})

	Iif(ValType(oFWLayer) == "O", oFWLayer:Destroy(), Nil)
	Iif(ValType(oTmpPend) == "O", oTmpPend:Destroy(), Nil)
	Iif(ValType(oTmpVinc) == "O", oTmpVinc:Destroy(), Nil)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J204BLeg
Cria legendas dos Browses

@author  Jonatas Martins
@since   17/10/2018
@version 1.0
@obs     oMkBrwPend e oMkBrwVinc são variáveis privates criadas na função J204BDlg
/*/
//-------------------------------------------------------------------
Static Function J204BLeg()
	Local cRevisa := JurInfBox('NUE_REVISA', '1')

	// Time Sheets Pendentes
	oMkBrwPend:AddLegend('Alltrim(NUE_REVISA) == "' + cRevisa + '" ', "HGREEN", STR0007) // "Revisado"
	oMkBrwPend:AddLegend('Alltrim(NUE_REVISA) != "' + cRevisa + '" ', "BLUE"  , STR0008) // "Não Revisado"

	// Time Sheets Vinculados
	oMkBrwVinc:AddLegend('AllTrim(EMISSAO) == "1"'                  , "BLACK" , STR0049) // "Vinculado da Emissão"
	oMkBrwVinc:AddLegend('Alltrim(NUE_REVISA) == "' + cRevisa + '" ', "HGREEN", STR0007) // "Revisado"
	oMkBrwVinc:AddLegend('Alltrim(NUE_REVISA) != "' + cRevisa + '" ', "BLUE"  , STR0008) // "Não Revisado"
	
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J204BMenu
Menu do browse de Time Sheets pendentes e vinculados

@param aFieldsTmp, Campos da tabela temporária

@author  Jonatas Martins
@since   17/10/2018
@version 1.0
@obs     oDlg204B, cAlsPend, cAlsVinc, oMkBrwPend e oMkBrwVinc são variáveis privates criadas na função J204BDlg
/*/
//-------------------------------------------------------------------
Static Function J204BMenu(aFieldsTmp)

	Default aFieldsTmp := {}

	// Time Sheets Pendentes
	oMkBrwPend:AddButton(STR0044, {|| J204BCoAlt(.T., aFieldsTmp)}           , , 3) //"Vincular"
	oMkBrwPend:AddButton(STR0010, {|| J204BView(cAlsPend)}                   , , 2) //"Visualizar"
	oMkBrwPend:AddButton(STR0012, {|| J204BtnLeg()}                          , , 6) //"Legenda"
	oMkBrwPend:AddButton(STR0015, {|| oDlg204B:End()}                        , , 6) //"Sair"
	// Time Sheets Vinculados
	oMkBrwVinc:AddButton(STR0013, {|| J204BCoAlt(.F., aFieldsTmp)}           , , 5) //"Desvincular"
	oMkBrwVinc:AddButton(STR0010, {|| J204BView(cAlsVinc)}                   , , 8) //"Visualizar"

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J204BtnLeg
Monta exibição das legendas

@author  Jonatas Martins
@since   17/10/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J204BtnLeg()
	Local aLegenda := {{"BR_PRETO"       , STR0049},; // "Time Sheet Vinculado na Emissão"
	                   {"BR_VERDE_ESCURO", STR0007},; // "Revisado"
	                   {"BR_AZUL"        , STR0008}}  // "Não Revisado"

	BrwLegenda(STR0014, STR0012, aLegenda) // "Situação do Time Sheet" ## "Legenda"

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J204BVlrCon
Retorna valor do TS convertido para validação do saldo

@param cAliasTmp, Alias do TS que está sendo validado

@return nVlrConv, Valor do TS convertido

@author  Jorge Martins / Bruno Ritter
@since   29/03/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J204BVlrCon(cAliasTmp)
	Local aVlrConv   := {}
	Local nVlrConv   := 0
	Local cErroConv  := ""

	aVlrConv  := J204BConv(NXA->NXA_CMOEDA, (cAliasTmp)->NUE_CMOEDA, (cAliasTmp)->NUE_VALOR) // Conversão TS
	nVlrConv  := aVlrConv[1] // Valor Convertido
	cErroConv := aVlrConv[4] // Texto com o erro ao obter cotação

	If !Empty(cErroConv)
		nVlrConv := 0
		JurMsgErro(cErroConv, , STR0023) // "Verifique a cotação na moeda do timesheet antes de vinculá-lo na fatura."
	EndIf

	JurFreeArr(aVlrConv)

Return nVlrConv

//-------------------------------------------------------------------
/*/{Protheus.doc} J204BContra
Indica o contrato em que o Time Sheet será vinculado

@param cCodTS , Time Sheet que será vinculado

@return cContr, Contrato em que o TS será vinculado

@author  Jorge Martins / Bruno Ritter
@since   29/03/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J204BContra(cCodTS)
	Local cQryCnt    := ""
	Local cContr     := ""
	Local aRet       := {}
	Local cCodFatAdc := NXA->NXA_CFTADC
	Local cCpoVlBase := Iif(Empty(cCodFatAdc), "NXB_VFXVIN", "NXB_VTS")

	cQryCnt := "SELECT MIN(NXB.NXB_CCONTR) NXB_CCONTR FROM " + RetSqlName( 'NXB' ) + " NXB "
	If Empty(cCodFatAdc)
		cQryCnt +=   " INNER JOIN " + RetSqlName( 'NRA' ) + " NRA "
		cQryCnt +=           " ON NRA.NRA_FILIAL = '" + xFilial("NRA") + "' "
		cQryCnt +=          " AND NRA.NRA_COD = NXB.NXB_CTPHON
		cQryCnt +=          " AND NRA.NRA_COBRAH = '2' "
		cQryCnt +=          " AND NRA.D_E_L_E_T_ = ' ' "
	EndIf
	cQryCnt +=       " INNER JOIN " + RetSqlName( 'NXC' ) + " NXC "
	cQryCnt +=               " ON NXC.NXC_FILIAL = '" + xFilial("NXC") + "' "
	cQryCnt +=              " AND NXC.NXC_CESCR  = NXB.NXB_CESCR "
	cQryCnt +=              " AND NXC.NXC_CFATUR = NXB.NXB_CFATUR "
	cQryCnt +=              " AND NXC.NXC_CCONTR = NXB.NXB_CCONTR "
	cQryCnt +=              " AND NXC.D_E_L_E_T_ = ' ' "
	cQryCnt +=       " INNER JOIN " + RetSqlName( 'NUE' ) + " NUE "
	cQryCnt +=               " ON NXC.NXC_FILIAL = '" + xFilial("NUE") + "' "
	cQryCnt +=              " AND NUE.NUE_COD = '" + cCodTS + "' "
	cQryCnt +=              " AND NUE.NUE_CCLIEN = NXC.NXC_CCLIEN "
	cQryCnt +=              " AND NUE.NUE_CLOJA = NXC.NXC_CLOJA "
	cQryCnt +=              " AND NUE.NUE_CCASO = NXC.NXC_CCASO "
	cQryCnt +=              " AND NUE.D_E_L_E_T_ = ' ' "
	cQryCnt += " WHERE NXB.NXB_FILIAL = '" + xFilial("NXB") + "' "
	cQryCnt +=   " AND NXB.NXB_CESCR  = '" + NXA->NXA_CESCR + "' "
	cQryCnt +=   " AND NXB.NXB_CFATUR = '" + NXA->NXA_COD + "' "
	cQryCnt +=   " AND NXB." + cCpoVlBase + " > 0 "
	cQryCnt +=   " AND NXB.D_E_L_E_T_ = ' ' "

	aRet := JurSql(cQryCnt, {"NXB_CCONTR"})

	If Len(aRet) >= 1
		cContr := aRet[1][1]
	EndIf

Return cContr

//-------------------------------------------------------------------
/*/{Protheus.doc} J204BConv
Rotina para converter o valor do TimeSheet na moeda da fatura com a cotação da fatura.
Caso não tenha a cotação, converte com a cotação da data de emissão e adiciona na NXF.

@param cMoeFat, Moeda da fatura
@param cMoeTs , Moeda do TimeSheet
@param nValTS , Valor do TimeSheet

@Return  aRet [1] Valor Convertido
              [2] Taxa 1 (Taxa do faturamento)
              [3] Taxa 2 (Taxa da condição)
              [4] Texto com o erro ao obter cotação

@author  Luciano Pereira dos Santos
@since   05/11/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J204BConv(cMoeFat, cMoeTs, nValTS)
	Local aRetConv  := {nValTS, 1, 1, "", DEC_CREATE('1', 64, 18)}
	Local nCotac    := 0
	Local lTemCotac := .T.
	Local cMoedaNac := SuperGetMv('MV_JMOENAC',, '01')
	Local cMoeCot   := cMoeTs

	If cMoeFat != cMoeTs .And. cMoeTs != cMoedaNac // TS com moeda diferente da moeda da fatura e diferente da moeda nacional
	
		// Verifica se há cotação para a moeda do TS, considerando o dia de emissão da fatura
		If FindFunction("J201FVlCot") 
			lTemCotac := J201FVlCot(cMoeTs, NXA->NXA_DTEMI, .T.)[1]
		EndIf
		
		If lTemCotac
			If (nCotac := J204BCotac(cMoeTs)) > 0 //Verifica se alguma das faturas possui a cotação para o Timesheet e grava nas demais faturas
				J204BGrvCot(cMoeTs, nCotac)
				aRetConv := JA201FConv(cMoeFat, cMoeTs, nValTS, "8", NXA->NXA_DTEMI, /*cCodFImpr*/, /*cPreFt*/, /*cXFilial*/, NXA->NXA_CESCR, NXA->NXA_COD)
			Else
				aRetConv := JA201FConv(cMoeFat, cMoeTs, nValTS, "8", NXA->NXA_DTEMI, /*cCodFImpr*/, /*cPreFt*/, /*cXFilial*/, NXA->NXA_CESCR, NXA->NXA_COD)
				If Empty(aRetConv[4]) .And. (cMoeTs != NXA->NXA_CMOEDA)
					J204BGrvCot(cMoeTs, aRetConv[2]) //Grava a cotação utilizada
				EndIf
			EndIf
		Else
			aRetConv := {0, 1, 1, "", DEC_CREATE('1', 64, 18)}
		EndIf

	ElseIf cMoeFat != cMoeTs .And. cMoeTs == cMoedaNac 
		// Verifica se há cotação para a moeda do TS, considerando o dia de emissão da fatura
		cMoeCot := cMoeFat
		If FindFunction("J201FVlCot") 
			lTemCotac := J201FVlCot(cMoeCot, NXA->NXA_DTEMI, .T.)[1]
		EndIf

		If lTemCotac
			If (nCotac := J204BCotac(cMoeCot)) > 0 //Verifica se alguma das faturas possui a cotação para o Timesheet e grava nas demais faturas
				If (cMoeCot != cMoedaNac)
					J204BGrvCot(cMoeCot, nCotac)
				EndIf
			EndIf
			aRetConv := JA201FConv(cMoeFat, cMoeTs, nValTS, "8", NXA->NXA_DTEMI, /*cCodFImpr*/, /*cPreFt*/, /*cXFilial*/, NXA->NXA_CESCR, NXA->NXA_COD)
		Else
			aRetConv := {0, 1, 1, "", DEC_CREATE('1', 64, 18)}
		EndIf
	EndIf

Return aRetConv

//-------------------------------------------------------------------
/*/{Protheus.doc} J204BCotac
Verifica se algumas das faturas possui a cotação para o timesheet.

@param  cMoeTs, Moeda do TimeSheet

@Return nCotac, O valor da cotação na moeda do timesheet ou 0 se não localizaou a cotação

@author  Luciano Pereira dos Santos
@since   05/11/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J204BCotac(cMoeTs)
	Local aArea  := GetArea()
	Local nCotac := 0
	Local nI     := 0

	NXF->(dbSetOrder(2))  //NXF_FILIAL + NXF_CFATUR + NXF_CESCR + NXF_CMOEDA

	For nI := 1 To Len(_aFaturas)
		If (NXF->(DbSeek(xFilial("NXF") + _aFaturas[nI][2] + _aFaturas[nI][1] + cMoeTs)))
			nCotac := NXF->NXF_COTAC1
			Exit
		EndIf
	Next nI

	RestArea(aArea)

Return nCotac

//-------------------------------------------------------------------
/*/{Protheus.doc} J204BGrvCot
Verifica se algumas das faturas possui a cotação para o timesheet.

@param  cMoeda, Moeda do TimeSheet
@param  nCotac, Cotação para gravar na NXF

@author  Luciano Pereira dos Santos
@since   05/11/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J204BGrvCot(cMoeda, nCotac)
	Local nI      := 0
	Local aArea   := GetArea()
	Local cCodNXF := ''

	NXF->(dbSetOrder(2))  //NXF_FILIAL + NXF_CFATUR + NXF_CESCR + NXF_CMOEDA

	For nI := 1 To Len(_aFaturas)
		If !(NXF->(DbSeek(xFilial("NXF") + _aFaturas[nI][2] + _aFaturas[nI][1] + cMoeda))) // Outras faturas podem ter a cotação qua a fatura posicionada não tem
			cCodNXF := GetSxEnum("NXF", "NXF_COD")

			RecLock("NXF", .T.)
			NXF->NXF_FILIAL := xFilial("NXF")
			NXF->NXF_COD    := cCodNXF
			NXF->NXF_CESCR  := _aFaturas[nI][1]
			NXF->NXF_CFATUR := _aFaturas[nI][2]
			NXF->NXF_CMOEDA := cMoeda
			NXF->NXF_COTAC1 := nCotac
			NXF->(MsUnlock())
			NXF->(DbCommit())
		EndIf
	Next nI

	RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J204BAtuTmp
Atualiza tabelas temporárias e os browses conforme a movimentação dos
time sheets.

@param aFieldsTmp , Campos da tabela temporária
@param cCodTs     , Código do Time Sheet
@param lVincTS    , Indica se os TSs estão sendo vinculados (.T.)
                    - Ou desvinculados (.F.)

@author  Jorge Martins
@since   17/10/2018
@version 1.0
@Obs     cAlsPend e cAlsVinc são variáveis privites criadas na função J204BDlg
/*/
//-------------------------------------------------------------------
Static Function J204BAtuTmp(aFieldsTmp, cCodTs, lVincTS)
	Local cTabInc := Iif(lVincTS, cAlsVinc, cAlsPend)
	Local cTabDel := Iif(lVincTS, cAlsPend, cAlsVinc)
	Local cField  := ""
	Local xValor  := Nil
	Local nI      := 0
	Local cContr  := J204BContra(cCodTS)

	BEGIN TRANSACTION
		// Incluir registro na browse de TS's disponíveis
		RecLock(cTabInc, .T.)
		For nI := 1 To Len(aFieldsTmp)
			cField := aFieldsTmp[nI][1]
			If cField == "NXB_CCONTR"
				xValor := cContr
			Else
				xValor := (cTabDel)->( FieldGet( FieldPos( cField ) ) )
			EndIf
			(cTabInc)->( FieldPut( FieldPos( cField ), xValor ) )
		Next nI
		(cTabInc)->(MsUnLock())

		// Remove o registro na browse de TS's vinculados
		RecLock(cTabDel, .F.)
		(cTabDel)->(DbDelete())
		(cTabDel)->(MsUnlock())
	END TRANSACTION

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J204BView
Abre o Time sheet em modo de visualização

@Param   cAlsTmp, Tabela temporária de TS vinculados ou disponíveis

@author  Jonatas Martins
@since   17/10/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J204BView(cAlsTmp)
	Local aAreaNUE  := NUE->(GetArea())

	Default cAlsTmp := ""

	If ! Empty(cAlsTmp)
		NUE->(DbGoTo((cAlsTmp)->RECNO))
		If NUE->(!Eof())
			FWExecView(STR0010, "JURA144", MODEL_OPERATION_VIEW, , {||.T.}) //"Visualizar"
		EndIf
	EndIf

	RestArea(aAreaNUE)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA204BQry
Função para retornar os TSs que foram vinculados a parcela fixa de
contratos da fatura, ou ainda os TSs pendentes para que sejam vinculados.

@Param lPendente, Indica se deseja o retorno dos lançamentos pendentes (.T.)
                  - ou já na fatura que foram vinculados manualmente (.F.)
@Param nRecNUE  , Recno para filtrar apenas um time sheet

@Return  aRet   , Informações da área temporária
               - Ou se passar o nRecNUE, o retorno será a query

@author  Cristina Cintra
@since   17/10/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA204BQry(lPendente, nRecNUE)
	Local aRet        := {}
	Local cEscr       := NXA->NXA_CESCR
	Local cFatura     := NXA->NXA_COD
	Local cQry        := ""
	Local cCampos	  := AllTrim(JurCmpSelc("NUE", {"NUE_OK    "}))
	Local aStruAdic   := {{"RECNO", "RECNO", "N", 20, 0, ""}, {"EMISSAO", "EMISAO", "C", 1, 0, ""}}
	Local aCmpNotBrw  := {}
	Local aCmpAcBrw   := {"NUE_DPART1"}
	Local lShowMsg    := .F.
	Local cTamMark    := Space(TamSx3("NUE_OK")[1])
	Local cCodFatAdc  := NXA->NXA_CFTADC
	Local cCpoVlBase  := Iif(Empty(cCodFatAdc), "NXB_VFXVIN", "NXB_VTS")

	Default lPendente := .T.
	Default nRecNUE   := 0

	aCmpNotBrw := {"NUE_CLTAB", "NUE_ACAOLD", "NUE_CCLILD", "NUE_CLJLD", "NUE_CCSLD", "NUE_PARTLD", "NW0_DTVINC", "NUE_CPART1", ;
				"NUE_CPREFT", "NUE_COTAC1", "NUE_COTAC2", "NXB_CCONTR", "NUE_CMOTWO", "NUE_CDWOLD", "NUE_CMOED1", "RECNO", "EMISSAO"}

	If lPendente
		cQry := "SELECT DISTINCT '" + cTamMark + "' NUE_OK, " + cCampos + " '' NW0_DTVINC, '' NXB_CCONTR, NRC.NRC_DESC as NUE_DATIVI "
		cQry += ", CASE WHEN CTO.CTO_SIMB <> '" + Space(TamSx3('CTO_SIMB')[1]) + "' THEN CTO.CTO_SIMB ELSE '" + Space(TamSx3('CTO_SIMB')[1]) + "' END NUE_DMOEDA "
		cQry += ", NVE.NVE_TITULO as NUE_DCASO, SA1.A1_NOME as NUE_DCLIEN, RD01.RD0_SIGLA as NUE_SIGLA1, RD01.RD0_NOME as NUE_DPART1, NUE.R_E_C_N_O_ RECNO, '2' EMISSAO"
		cQry += " FROM " + RetSqlName( 'NUE' ) + " NUE "
		cQry +=       " INNER JOIN " + RetSqlName( 'NXB' ) + " NXB "
		cQry +=                                               " ON NXB.NXB_FILIAL = '" + xFilial("NXB") + "' "
		cQry +=                                               " AND NXB.NXB_CESCR  = '" + cEscr + "' "
		cQry +=                                               " AND NXB.NXB_CFATUR = '" + cFatura + "' "
		cQry +=                                               " AND NXB." + cCpoVlBase + " > 0 "
		cQry +=                                               " AND NXB.D_E_L_E_T_ = ' ' "
		If Empty(cCodFatAdc)
			cQry +=  " INNER JOIN " + RetSqlName( 'NRA' ) + " NRA "
			cQry +=                                          " ON NRA.NRA_FILIAL = '" + xFilial("NRA") + "' "
			cQry +=                                          " AND NRA.NRA_COD = NXB.NXB_CTPHON
			cQry +=                                          " AND NRA.NRA_COBRAH = '2' "
			cQry +=                                          " AND NRA.D_E_L_E_T_ = ' ' "
		EndIf
		cQry +=       " INNER JOIN " + RetSqlName( 'NXC' ) + " NXC "
		cQry +=                                               " ON  NXC.NXC_FILIAL = '" + xFilial("NXC") + "' "
		cQry +=                                               " AND NXC.NXC_CESCR  = NXB.NXB_CESCR "
		cQry +=                                               " AND NXC.NXC_CFATUR = NXB.NXB_CFATUR "
		cQry +=                                               " AND NXC.NXC_CCONTR = NXB.NXB_CCONTR "
		cQry +=                                               " AND NXC.D_E_L_E_T_ = ' ' "
		cQry +=       " INNER JOIN "+ RetSqlName( "NRC" ) +" NRC"
		cQry +=                                               " ON  NRC.NRC_FILIAL = '" + xFilial("NRC") +"'"
		cQry +=                                               " AND NRC.NRC_COD = NUE.NUE_CATIVI"
		cQry +=                                               " AND NRC.D_E_L_E_T_ = ' ' "
		cQry +=       " LEFT OUTER JOIN "+ RetSqlName( "CTO" ) +" CTO"
		cQry +=                                               " ON  CTO.CTO_FILIAL = '" + xFilial("CTO") +"'"
		cQry +=                                               " AND CTO.CTO_MOEDA = NUE.NUE_CMOEDA"
		cQry +=                                               " AND CTO.D_E_L_E_T_ = ' ' "
		cQry +=       " INNER JOIN "+ RetSqlName( "NVE" ) +" NVE"
		cQry +=                                               " ON  NVE.NVE_FILIAL = '" + xFilial("NVE") +"'"
		cQry +=                                               " AND NVE.NVE_NUMCAS = NUE.NUE_CCASO"
		cQry +=                                               " AND NVE.NVE_CCLIEN = NUE.NUE_CCLIEN"
		cQry +=                                               " AND NVE.NVE_LCLIEN = NUE.NUE_CLOJA"
		cQry +=                                               " AND NVE.D_E_L_E_T_ = ' ' "
	    cQry +=       " INNER JOIN "+ RetSqlName( "SA1" ) +" SA1"
	    cQry +=                                               " ON  SA1.A1_FILIAL = '" + xFilial("SA1") +"'"
	    cQry +=                                               " AND SA1.A1_COD = NUE.NUE_CCLIEN"
	    cQry +=                                               " AND SA1.A1_LOJA = NUE.NUE_CLOJA"
	    cQry +=                                               " AND SA1.D_E_L_E_T_ = ' ' "
	    cQry +=       " INNER JOIN "+ RetSqlName("RD0") +" RD01"
	    cQry +=                                               " ON  RD01.RD0_FILIAL = '" + xFilial("RD0") +"'"
	    cQry +=                                               " AND RD01.RD0_CODIGO = NUE.NUE_CPART1"
	    cQry +=                                               " AND RD01.D_E_L_E_T_ = ' ' "
		cQry +=       " WHERE NUE.NUE_FILIAL = '" + xFilial("NUE") + "' "
		cQry +=       " AND NUE.NUE_CCLIEN = NXC.NXC_CCLIEN "
		cQry +=       " AND NUE.NUE_CLOJA = NXC.NXC_CLOJA "
		cQry +=       " AND NUE.NUE_CCASO = NXC.NXC_CCASO "
		cQry +=       " AND NUE.NUE_SITUAC = '1' "
		cQry +=       " AND NUE.NUE_CPREFT = '" + Space(TamSx3('NUE_CPREFT')[1]) + "' "
		cQry +=       " AND NUE.NUE_CLTAB = '" + Space(TamSx3('NUE_CLTAB')[1]) + "' "
		If nRecNUE > 0
			cQry +=   " AND NUE.R_E_C_N_O_ = " + cValToChar(nRecNUE)
		EndIf
		cQry +=       " AND NUE.D_E_L_E_T_ = ' ' "

	Else // Vinculados na fatura manualmente
		cQry := "SELECT DISTINCT '" + cTamMark + "' NUE_OK, " + cCampos + " NW0.NW0_DTVINC, '' NXB_CCONTR, NRC.NRC_DESC NUE_DATIVI "
		cQry += ", CASE WHEN CTO.CTO_SIMB <> '" + Space(TamSx3('CTO_SIMB')[1]) + "' THEN CTO.CTO_SIMB ELSE '" + Space(TamSx3('CTO_SIMB')[1]) + "' END NUE_DMOEDA "
		cQry += ", NVE.NVE_TITULO NUE_DCASO, SA1.A1_NOME NUE_DCLIEN , RD01.RD0_SIGLA NUE_SIGLA1 , RD01.RD0_NOME NUE_DPART1, NUE.R_E_C_N_O_ RECNO "
		cQry += ", CASE WHEN NW0_DTVINC = '" + Space(TamSx3('NXB_CCONTR')[1]) + "' THEN '1' ELSE '2' END EMISSAO "
		cQry += " FROM " + RetSqlName( 'NUE' ) + " NUE "
		cQry +=       " INNER JOIN " + RetSqlName( 'NW0' ) + " NW0 "
		cQry +=                                               " ON NUE.NUE_COD = NW0.NW0_CTS "
		cQry +=                                               " AND NW0.NW0_CESCR  = '" + cEscr + "' "
		cQry +=                                               " AND NW0.NW0_CFATUR = '" + cFatura + "' "
		cQry +=                                               " AND NW0.D_E_L_E_T_ = ' ' "
		cQry +=                                               " AND NW0.NW0_FILIAL = '" + xFilial("NW0") + "' "
		cQry +=       " INNER JOIN " + RetSqlName( 'NXB' ) + " NXB "
		cQry +=                                               " ON NXB.NXB_FILIAL = '" + xFilial("NXB") + "' "
		cQry +=                                               " AND NXB.NXB_CESCR = NW0.NW0_CESCR "
		cQry +=                                               " AND NXB.NXB_CFATUR = NW0.NW0_CFATUR "
		cQry +=                                               " AND NXB." + cCpoVlBase + " > 0 "
		cQry +=                                               " AND NXB.D_E_L_E_T_ = ' ' "
		If Empty(cCodFatAdc)
			cQry +=   " INNER JOIN " + RetSqlName( 'NRA' ) + " NRA "
			cQry +=                                           " ON NRA.NRA_FILIAL = '" + xFilial("NRA") + "' "
			cQry +=                                           " AND NRA.NRA_COD = NXB.NXB_CTPHON "
			cQry +=                                           " AND NRA.NRA_COBRAH = '2' "
			cQry +=                                           " AND NRA.D_E_L_E_T_ = ' ' "
		EndIf
		cQry +=       " INNER JOIN " + RetSqlName( 'NXC' ) + " NXC "
		cQry +=                                               " ON NXC.NXC_FILIAL = '" + xFilial("NXC") + "' "
		cQry +=                                               " AND NXC.NXC_CESCR = NXB.NXB_CESCR "
		cQry +=                                               " AND NXC.NXC_CFATUR = NXB.NXB_CFATUR "
		cQry +=                                               " AND NXC.NXC_CCONTR = NXB.NXB_CCONTR "
		cQry +=                                               " AND NXC.D_E_L_E_T_ = ' ' "
		cQry +=       " INNER JOIN "+ RetSqlName( "NRC" ) +" NRC"
		cQry +=                                               " ON  NRC.NRC_FILIAL = '" + xFilial("NRC") +"'"
		cQry +=                                               " AND NRC.NRC_COD = NUE.NUE_CATIVI"
		cQry +=                                               " AND NRC.D_E_L_E_T_ = ' ' "
		cQry +=       " LEFT OUTER JOIN "+ RetSqlName( "CTO" ) +" CTO"
		cQry +=                                               " ON  CTO.CTO_FILIAL = '" + xFilial("CTO") +"'"
		cQry +=                                               " AND CTO.CTO_MOEDA = NUE.NUE_CMOEDA"
		cQry +=                                               " AND CTO.D_E_L_E_T_ = ' ' "
		cQry +=       " INNER JOIN "+ RetSqlName( "NVE" ) +" NVE"
		cQry +=                                               " ON  NVE.NVE_FILIAL = '" + xFilial("NVE") +"'"
		cQry +=                                               " AND NVE.NVE_NUMCAS = NUE.NUE_CCASO"
		cQry +=                                               " AND NVE.NVE_CCLIEN = NUE.NUE_CCLIEN"
		cQry +=                                               " AND NVE.NVE_LCLIEN = NUE.NUE_CLOJA"
		cQry +=                                               " AND NVE.D_E_L_E_T_ = ' ' "
	    cQry +=       " INNER JOIN "+ RetSqlName( "SA1" ) +" SA1"
	    cQry +=                                               " ON  SA1.A1_FILIAL = '" + xFilial("SA1") +"'"
	    cQry +=                                               " AND SA1.A1_COD = NUE.NUE_CCLIEN"
	    cQry +=                                               " AND SA1.A1_LOJA = NUE.NUE_CLOJA"
	    cQry +=                                               " AND SA1.D_E_L_E_T_ = ' ' "
	    cQry +=       " INNER JOIN "+ RetSqlName( "RD0" ) +" RD01"
	    cQry +=                                               " ON  RD01.RD0_FILIAL = '" + xFilial("RD0") +"'"
	    cQry +=                                               " AND RD01.RD0_CODIGO = NUE.NUE_CPART1"
	    cQry +=                                               " AND RD01.D_E_L_E_T_ = ' ' "
		cQry +=       " WHERE NUE.NUE_FILIAL = '" + xFilial("NUE") + "' "
		cQry +=       " AND NUE.NUE_CCLIEN = NXC.NXC_CCLIEN "
		cQry +=       " AND NUE.NUE_CLOJA = NXC.NXC_CLOJA "
		cQry +=       " AND NUE.NUE_CCASO = NXC.NXC_CCASO "
		cQry +=       " AND NUE.NUE_SITUAC = '2' "
		cQry +=       " AND NUE.NUE_CPREFT = '" + Space(TamSx3('NUE_CPREFT')[1]) + "' "
		If nRecNUE > 0
			cQry +=   " AND NUE.R_E_C_N_O_ = " + cValToChar(nRecNUE)
		EndIf
		cQry +=       " AND NUE.D_E_L_E_T_ = ' ' "
	EndIf

	If nRecNUE == 0
		aRet := JurCriaTmp(GetNextAlias(), cQry, "NUE", /*aIdxAdic*/, aStruAdic, aCmpAcBrw, aCmpNotBrw, /*lOrdemQry*/, /*lInsert*/, /*aTitCpoBrw*/, lShowMsg)
	Else
		aRet := {cQry}
	EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J204BVldSal
Valida o saldo para vínculo

@param   nValTS   , Valor do Time Sheet

@return  lSaldoVld, Valida se o contrato possui saldo

@author  Bruno Ritter / Jorge Martins
@since   29/03/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J204BVldSal(nValTS)
	Local lSaldoVld  := .T.
	Local lTSDiv     := .F.
	Local nSaldo     := 0
	Local cCMoedaTS  := (cAlsPend)->NUE_CMOEDA
	Local cCMoedaFT  := NXA->NXA_CMOEDA
	Local cMsg       := ""
	Local nSaldoConv := 0 //Valor do Saldo Convertido
	Local lLimitaTS  := SuperGetMv("MV_JLIMVTS", .F., .T.) //Indica se o vínculo de TSs será limitado ao valor faturado .T.-Sim ou .F.-Não

	Default nValTS   := 0

	If lLimitaTS
		nSaldo     := oSaldoVinc:GetValue()
		nSaldoConv := J204BConv(cCMoedaTS, cCMoedaFT, nSaldo)[1]
	
		If Round(nValTS, 2) > Round(nSaldo, 2) // Caso não tenha saldo realiza a divisão
			cMsg := J204BMsgDv(nSaldo, nValTS) // Mensagem para divisão de TS

			If ApMsgYesNo(cMsg, STR0045) // "Atenção"
				nSaldo := J204BConv(cCMoedaTS, cCMoedaFT, nSaldo)[1] // Conversão Saldo para moeda do TS
				FWMsgRun( , {|| lTSDiv := J204BDivTs(nSaldo)}, STR0043, STR0019) // "Dividindo Time Sheet" "Aguarde..."
				lSaldoVld := lTSDiv
			Else
				lSaldoVld := .F.
			EndIf

		EndIf
	EndIf

Return {lSaldoVld, lTSDiv}

//-------------------------------------------------------------------
/*/{Protheus.doc} J204BMsgDv
Mensagem para divisão de Time Sheet

@param   nSaldo, Saldo para vínculo de TSs
@param   nValTS, Valor do Time Sheet

@return  cMsg  , Mensagem

@author  Bruno Ritter / Jorge Martins
@since   29/03/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J204BMsgDv(nSaldo, nValTS)
	Local cMsg      := ""
	Local cSaldo    := AllTrim(TransForm(nSaldo, "@E 99,999,999.99"))
	Local cPicture  := PesqPict("NUE", "NUE_VALOR")
	Local cValorTS  := AllTrim(TransForm((cAlsPend)->NUE_VALOR, cPicture))
	Local cValCvTS  := AllTrim(TransForm(nValTS, cPicture))
	Local cDMoedaTS := (cAlsPend)->NUE_DMOEDA
	Local cDMoedaFT := JurGetDados("CTO", 1, xFilial("CTO") + NXA->NXA_CMOEDA, "CTO_SIMB")

	cMsg := I18n(STR0038, {(cAlsPend)->NUE_COD}) + CRLF // "O valor do Time Sheet '#1' ultrapassa o saldo para vínculo."
	If cDMoedaTS == cDMoedaFT
		cMsg += I18n(STR0039, {cDMoedaTS, cValorTS}) + CRLF // "- Valor do Time Sheet: '#1 #2'."
	Else
		cMsg += I18n(STR0040, {cDMoedaTS, cValorTS, cDMoedaFT, cValCvTS}) + CRLF // "- Valor do Time Sheet: '#1 #2' ('#3 #4')."
	EndIf
	cMsg += I18n(STR0041, {cDMoedaFT, cSaldo}) + CRLF + CRLF // "- Saldo para Vínculo: '#1 #2'."
	cMsg += STR0042 // "Deseja dividir o Time Sheet e selecioná-lo para o vínculo?. "

Return cMsg

//-------------------------------------------------------------------
/*/{Protheus.doc} J204BTemFix
Função para retornar se há parcelas fixas na fatura de contratos que não
cobram hora.

@Return  lRet   , Indica se tem Fixo (.T.) ou não (.F.)

@author  Cristina Cintra
@since   18/10/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J204BTemFix()
	Local lRet       := .T.
	Local cQry       := ""
	Local aContr     := {}
	Local cEscr      := NXA->NXA_CESCR
	Local cFatura    := NXA->NXA_COD
	Local cCodFatAdc := NXA->NXA_CFTADC
	Local cCpoVlBase := Iif(Empty(cCodFatAdc), "NXB_VFXVIN", "NXB_VTS")

	cQry := "SELECT NXB.NXB_CCONTR CCONTR "
	cQry += " FROM " + RetSqlName("NXB") + " NXB "
	If Empty(cCodFatAdc)
		cQry +=  " INNER JOIN " + RetSqlName("NRA") + " NRA "
		cQry +=                                          " ON NRA.NRA_FILIAL = '" + xFilial("NRA") + "' "
		cQry +=                                          " AND NRA.NRA_COD = NXB.NXB_CTPHON "
		cQry +=                                          " AND NRA.NRA_COBRAH = '2' "
		cQry +=                                          " AND NRA.D_E_L_E_T_ = ' ' "
	EndIf
	cQry +=       " WHERE NXB.NXB_FILIAL = '" + xFilial("NXB") + "' "
	cQry +=       " AND NXB.NXB_CESCR  = '" + cEscr + "' "
	cQry +=       " AND NXB.NXB_CFATUR = '" + cFatura + "' "
	cQry +=       " AND NXB." + cCpoVlBase + " > 0 "
	cQry +=       " AND NXB.D_E_L_E_T_ = ' ' "

	aContr := JurSQL(cQry, {"CCONTR"})

	If Empty(aContr) .Or. (Len(aContr) > 0 .And. Empty(aContr[1][1]))
		lRet := .F.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J204BTemFA
Função para retornar se há valor de honorários na fatura adicional
para vincular TS

@return  lRet   , Indica se pode vincular TS (.T.) ou não (.F.)

@author  Bruno Ritter
@since   03/10/2019
/*/
//-------------------------------------------------------------------
Static Function J204BTemFA()
	Local lRet := NXA->NXA_TS == "1" .And. NXA->NXA_FATADC == "1"

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J204BAtSld
Atualiza o resumo com os dados de fixo, Time Sheet e saldo

@author  Jonatas Martins / Jorge Martins
@since   19/10/2018
@version 1.0
@obs     cAlsVinc é variável private criada na função J204BDlg
/*/
//-------------------------------------------------------------------
Static Function J204BAtSld()
	Local cQry       := ""
	Local cMoeFat    := NXA->NXA_CMOEDA
	Local cCodPre    := NXA->NXA_CPREFT
	Local cCodFatAdc := NXA->NXA_CFTADC
	Local cCodFixo   := NXA->NXA_CFIXO
	Local cEscr      := NXA->NXA_CESCR
	Local cFatura    := NXA->NXA_COD
	Local dDtEmit    := NXA->NXA_DTEMI
	Local dDataVinc  := CtoD("  /  /  ")
	Local aResult    := {}
	Local nI         := 1
	Local nDescont   := 0
	Local nVlBase    := 0
	Local nVlTSVin   := 0
	Local nTotBase   := 0
	Local nTotDesc   := 0
	Local nTotTSEmis := 0
	Local nTotTSVin  := 0
	Local cCpoVlBase := Iif(Empty(cCodFatAdc), "NXB_VFIXO", "NXB_VTS")
	Local lLimitaTS  := SuperGetMv("MV_JLIMVTS", .F., .T.) //Indica se o vínculo de TSs será limitado ao valor faturado .T.-Sim ou .F.-Não

	While (cAlsVinc)->(!Eof())
		// Calcula os valores para a moeda da fatura
		nVlTSVin  := JA201FConv(cMoeFat, (cAlsVinc)->NUE_CMOEDA, (cAlsVinc)->NUE_VALOR, "8", dDtEmit, /*cCodFImpr*/, /*cPreFt*/, /*cXFilial*/, cEscr, cFatura)[1]
		dDataVinc := (cAlsVinc)->NW0_DTVINC

		If Empty(dDataVinc)
			nTotTSEmis += nVlTSVin
		Else
			nTotTSVin += nVlTSVin
		EndIf
		(cAlsVinc)->(DbSkip())
	EndDo
	(cAlsVinc)->(DbGoTop())

	cQry := " SELECT NXA.NXA_COD, NXA.NXA_CESCR, NXA.NXA_CMOEDA, NXA.NXA_DTEMI, NXB." + cCpoVlBase + ", NXB.NXB_VTSVIN, NXB.NXB_DRATF, NXB.NXB_CCONTR "
	cQry += " FROM " + RetSqlName( 'NXA' ) + " NXA "
	cQry += " INNER JOIN " + RetSqlName( 'NXB' ) + " NXB "
	cQry +=       "  ON NXB.NXB_FILIAL = '" + xFilial("NXB") + "' "
	cQry +=       " AND NXB.NXB_CESCR = NXA.NXA_CESCR "
	cQry +=       " AND NXB.NXB_CFATUR = NXA.NXA_COD "
	cQry +=       " AND NXB." + cCpoVlBase + " > 0 "
	cQry +=       " AND NXB.D_E_L_E_T_ = ' ' "
	If Empty(cCodFatAdc)
		cQry += " INNER JOIN " + RetSqlName( 'NRA' ) + " NRA "
		cQry +=       "  ON NRA.NRA_FILIAL = '" + xFilial("NRA") + "' "
		cQry +=       " AND NRA.NRA_COD = NXB.NXB_CTPHON "
		cQry +=       " AND NRA.NRA_COBRAH = '2' "
		cQry +=       " AND NRA.NRA_COBRAF = '1' "
		cQry +=       " AND NRA.D_E_L_E_T_ = ' ' "
	EndIf
	cQry += " WHERE NXA.NXA_FILIAL = '" + xFilial("NXA") + "' "
	If !Empty(cCodFixo)
		cQry +=   " AND NXA.NXA_CFIXO = '" + cCodFixo + "' "

	ElseIf !Empty(cCodPre)
		cQry +=   " AND NXA.NXA_CPREFT = '" + cCodPre + "' "

	ElseIf !Empty(cCodFatAdc)
		cQry +=   " AND NXA.NXA_CFTADC = '" + cCodFatAdc + "' "
	EndIf
	cQry +=       " AND (NXA.NXA_SITUAC = '1' "
	cQry +=            " OR NXA.NXA_WO = '1') "
	cQry +=       " AND NXA.D_E_L_E_T_ = ' ' "
	cQry +=       " ORDER BY NXB.NXB_CCONTR "

	aResult := JurSQL(cQry, {"NXA_CMOEDA", "NXA_CESCR", "NXA_COD", cCpoVlBase, "NXB_VTSVIN", "NXB_DRATF", "NXB_CCONTR", "NXA_DTEMI"})

	For nI := 1 To Len(aResult)
		// Calcula os valores para a moeda da fatura
		nVlBase  := JA201FConv(cMoeFat, Alltrim(aResult[nI][1]), aResult[nI][4], "8", SToD(aResult[nI][8]), /*cCodFImpr*/, /*cPreFt*/, /*cXFilial*/, aResult[nI][2], aResult[nI][3])[1]
		nDescont := JA201FConv(cMoeFat, Alltrim(aResult[nI][1]), aResult[nI][6], "8", SToD(aResult[nI][8]), /*cCodFImpr*/, /*cPreFt*/, /*cXFilial*/, aResult[nI][2], aResult[nI][3])[1]

		nTotBase  += nVlBase
		nTotDesc  += nDescont
	Next nI

	oMoeda:SetValue(JurGetDados("CTO", 1, xFilial("CTO") + cMoeFat, "CTO_SIMB"))
	oTotBase:SetValue(nTotBase)
	oDescFat:SetValue(nTotDesc)
	oTsVEmis:SetValue(nTotTSEmis)
	oTsVinc:SetValue(nTotTSVin)
	If lLimitaTS
		oSaldoVinc:SetValue(nTotBase - nTotDesc - nTotTSEmis - nTotTSVin)
	EndIf
	oTsPenVinc:SetValue(J204BTsPen(cMoeFat))

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J204BRetFat
Função para retornar as faturas relacionadas a pré-fatura ou fixo quando
for multipagadores.

@Param  cCodPre   , caractere, Código da Pré-fatura relacionada a fatura (quando houver)
@Param  cCodFixo  , caractere, Código da Parcela Fixa relacionada a fatura (quando houver)
@Param  cCodFatAdc, Código da Fatura Adicional relacionada a fatura (quando houver)

@Return  aRet, array, Faturas (Escritório e Código)

@author  Cristina Cintra
@since   18/10/2018
@version 1.0
@obs     Variável estática _aFaturas
/*/
//-------------------------------------------------------------------
Static Function J204BRetFat(cCodPre, cCodFixo, cCodFatAdc)
	Local cQry         := ""

	Default cCodPre    := ""
	Default cCodFixo   := ""
	Default cCodFatAdc := ""

	cQry := "SELECT NXA.NXA_CESCR, NXA.NXA_COD, NXA.NXA_PERFAT, NXA.NXA_CMOEDA, NXA.NXA_WO, NXA.NXA_DTEMI, NUF.NUF_COD "
	cQry +=  " FROM " + RetSqlName( 'NXA' ) + " NXA "
	cQry +=  " LEFT JOIN " + RetSQlName('NUF') + " NUF "
	cQry +=    " ON NUF.NUF_CESCR = NXA.NXA_CESCR "
	cQry +=   " AND NUF.NUF_CFATU = NXA.NXA_COD "
	cQry +=   " AND NUF.D_E_L_E_T_ = ' ' "
	cQry += " WHERE NXA.NXA_FILIAL = '" + xFilial("NXA") + "' "
	cQry +=   " AND NXA.NXA_WO = '1' "
	If !Empty(cCodFixo)
		cQry += " AND NXA.NXA_CFIXO = '" + cCodFixo + "' "
		cQry +=  " OR ( NXA.NXA_SITUAC = '1' "
		cQry += " AND NXA.NXA_CFIXO = '" + cCodFixo + "'  )

	ElseIf !Empty(cCodPre)
		cQry += " AND NXA.NXA_CPREFT = '" + cCodPre + "' "
		cQry +=  " OR ( NXA.NXA_SITUAC = '1' "
		cQry += " AND NXA.NXA_CPREFT = '" + cCodPre + "'  )

	ElseIf !Empty(cCodFatAdc)
		cQry += " AND NXA.NXA_CFTADC = '" + cCodFatAdc + "' "
		cQry +=  " OR ( NXA.NXA_SITUAC = '1' "
		cQry += " AND NXA.NXA_CFTADC = '" + cCodFatAdc + "'  )
	EndIf
	cQry +=     " AND NXA.NXA_TITGER = '1' "
	cQry +=     " AND NXA.NXA_TIPO = 'FT' "
	cQry +=     " AND NXA.D_E_L_E_T_ = ' ' "
	cQry += " UNION ALL "
	cQry += " SELECT NXA.NXA_CESCR, NXA.NXA_COD, 0 NXA_PERFAT, NXA.NXA_CMOEDA, NXA.NXA_WO, NXA.NXA_DTEMI, NUF.NUF_COD "
	cQry +=   " FROM " + RetSqlName( 'NXA' ) + " NXA "
	cQry +=   " LEFT JOIN " + RetSQlName('NUF') + " NUF "
	cQry +=     " ON NUF.NUF_CESCR = NXA.NXA_CESCR "
	cQry +=    " AND NUF.NUF_CFATU = NXA.NXA_COD "
	cQry +=    " AND NUF.D_E_L_E_T_ = ' ' "
	cQry +=  " WHERE NXA.NXA_FILIAL = '" + xFilial("NXA") + "' "
	cQry +=    " AND NXA.NXA_WO = '1'"
	If !Empty(cCodFixo)
		cQry +=" AND NXA.NXA_CFIXO = '" + cCodFixo + "' "

	ElseIf !Empty(cCodPre)
		cQry +=" AND NXA.NXA_CPREFT = '" + cCodPre + "' "

	ElseIf !Empty(cCodFatAdc)
		cQry +=" AND NXA.NXA_CFTADC = '" + cCodFatAdc + "' "
	EndIf
	cQry +=    " AND NXA.NXA_TITGER = '1' "
	cQry +=    " AND NXA.NXA_TIPO = 'FT' "
	cQry +=    " AND NXA.D_E_L_E_T_ = ' ' "

	_aFaturas := JurSQL(cQry, {"NXA_CESCR", "NXA_COD", "NXA_PERFAT", "NXA_CMOEDA", "NXA_WO", "NUF_COD", "NXA_DTEMI"})

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J204BVldFt
Função para validar se as faturas relacionadas a pré-fatura ou fixo quando
for multipagadores.

@Param  cCodPre   , Código da Pré-fatura relacionada a fatura (quando houver)
@Param  cCodFixo  , Código da Parcela Fixa relacionada a fatura (quando houver)
@Param  cCodFatAdc, Código da Fatura Adicional relacionada a fatura (quando houver)
@Param  cMsgErro  , Mensagem de erro passada por referência.

@Return lRet    , .T. se todas as faturas relacionadas estão ativas.

@author  Luciano
@since   18/10/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J204BVldFt(cCodPre, cCodFixo, cCodFatAdc, cMsgErro)
	Local lRet     := .T.
	Local nPerc    := 0
	Local aParcela := {}
	Local cOrigem  := ""

	aEval(_aFaturas, {|a| nPerc += a[3] })

	If !(lRet := (nPerc == 100))
		If !Empty(cCodPre)
			cOrigem := I18n(STR0025, {cCodPre}) //"Pré-fatura '#1'"

		ElseIf !Empty(cCodFixo)
			aParcela := JurGetDados("NT1", 1, xFilial("NT1") + cCodFixo, {"NT1_PARC", "NT1_CCONTR"})
			cOrigem  := I18n(STR0026, {aParcela[1], aParcela[2]}) //"Parcela de Fixo '#1' do Contrato '#2'"

		ElseIf !Empty(cCodFatAdc)
			cOrigem := I18n(STR0056, {cCodFatAdc}) //"Fatura Adicional '#1'"
		EndIf

		cMsgErro := I18n(STR0024, {cOrigem}) //"Existe(m) fatura(s) cancelada(s) - sem WO - ou em processo de emissão, relacionadas à #1."
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J204BVlCal
Valida se o período do calendário contábil que contempla a data do
vínculo do TS está aberto. Caso esteja bloqueado não permitirá
que o TS seja removido da fatura.

@param   dDataVinc Data do vínculo do TS na fatura

@return  lRet      Indica se o TS pode ser removido da fatura

@author  Jorge Martins
@since   18/10/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J204BVlCal(dDataVinc)
	Local lRet        := .T.
	Local cQuery      := ''
	Local cDataVinc   := DToS( dDataVinc )
	Local cFilEscr    := JurGetDados("NS7", 1, xFilial("NS7") + NXA->NXA_CESCR, "NS7_CFILIA")

	Default dDataVinc := CtoD("  /  /    ")

	cQuery := " SELECT CQD.CQD_STATUS "
	cQuery +=   " FROM " + RetSqlName('CQD') + " CQD "
	cQuery +=     " INNER JOIN " + RetSqlName('CTE') + " CTE "
	cQuery +=        " ON ( CTE.CTE_FILIAL = CQD.CQD_FILIAL AND "
	cQuery +=             " CTE.CTE_CALEND = CQD.CQD_CALEND AND "
	cQuery +=             " CTE.CTE_MOEDA  = '" + NXA->NXA_CMOEDA + "' AND "
	cQuery +=             " CTE.D_E_L_E_T_ = ' ' "
	cQuery +=           " ) "
	cQuery +=     " INNER JOIN " + RetSqlName('CTG') + " CTG "
	cQuery +=        " ON ( CTG.CTG_FILIAL = CQD.CQD_FILIAL AND "
	cQuery +=             " CTG.CTG_PERIOD = CQD.CQD_PERIOD AND "
	cQuery +=             " CTG.CTG_CALEND = CQD.CQD_CALEND AND "
	cQuery +=             " CTG.CTG_DTINI <= '" + cDataVinc + "' AND "
	cQuery +=             " CTG.CTG_DTFIM >= '" + cDataVinc + "' AND "
	cQuery +=             " CTG.D_E_L_E_T_ = ' ' "
	cQuery +=           " ) "
	cQuery += " WHERE CQD.CQD_FILIAL = '" + FWxFilial("SE1", cFilEscr) + "' AND "
	cQuery +=       " CQD.CQD_PROC   = 'FIN002' AND " // Contas a Receber
	cQuery +=       " CQD.CQD_STATUS = '1' AND "
	cQuery +=       " CQD.D_E_L_E_T_ = ' ' "

	If Empty(JurSQL(cQuery, {"CQD_STATUS"}))
		lRet := .F.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J204BConf
Grava movimentações de vínculos dos Time Sheets efetuadas na tela

@param lVincTS , Indica se os TSs estão sendo vinculados (.T.)
                 - Ou desvinculados (.F.)

@author  Luciano Pereira dos Santos
@since   17/10/2018
@version 1.0
@obs     oMkBrwPend e oMkBrwVinc são variáveis privates criadas na função J204BDlg
/*/
//-------------------------------------------------------------------
Static Function J204BConf(lVincTS)
	Local aArea      := GetArea()
	Local cTablePend := oTmpPend:GetRealName()
	Local cTableVinc := oTmpVinc:GetRealName()
	Local cFiltPend  := oMkBrwVinc:FWFilter():GetExprSQL()
	Local cFiltVinc  := oMkBrwPend:FWFilter():GetExprSQL()

	If lVincTS
		//Vincular Pendentes
		cFiltVinc := Iif(!Empty(cFiltVinc), cFiltVinc + " AND ", "") + " (NW0_DTVINC = '" + Space(TamSx3('NW0_DTVINC')[1]) + "') AND (EMISSAO = '2') "
		FWMsgRun( , {|| J204BProc(cTableVinc, "2", cFiltVinc, cAlsVinc)}, STR0018, STR0019) //#"Atualizando lançamentos" ##"Aguarde..."
	Else
		//Remover vinculo
		cFiltPend := Iif(!Empty(cFiltPend), cFiltPend + " AND ", "") + " (NW0_DTVINC > '"+ Space(TamSx3('NW0_DTVINC')[1]) + "') "
		FWMsgRun( , {|| J204BProc(cTablePend, "1", cFiltPend, cAlsPend)}, STR0018, STR0019) //#"Atualizando lançamentos" ##"Aguarde..."
	EndIf

	RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J204BProc
Aplica um filtro em uma tabela.

@Param cTableTmp Tabela temporária onde será aplicado o filtro
@Param cTpOper   Tipo de operação  '1' - Remover vinculo; '2' - Vincular
@Param cFiltro   Filtro em Sql para tabela temporaria
@Param cAliasTmp Alias Temporário do Time sheet que será movimentado

@author  Luciano Pereira dos Santos
@since   17/10/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J204BProc(cTableTmp, cTpOper, cFiltro, cAliasTmp)
	Local aArea      := GetArea()
	Local nFat       := 0
	Local nTs        := 0
	Local nRecno     := 0
	Local nRecnoTmp  := 0
	Local aLancs     := J204BFilt(cTableTmp, cFiltro)
	Local aFieldsTmp := (cAlsPend)->(dbStruct()) // Campos da tabela temporária
	Local lAltHr     := NUE->(ColumnPos('NUE_ALTHR')) > 0

	BEGIN TRANSACTION
		For nTs := 1 To Len(aLancs)
			nRecno    := aLancs[nTs][1]
			cContr    := aLancs[nTs][2]
			nRecnoTmp := aLancs[nTs][3]
			NUE->(DbGoto(nRecno))
			If NUE->(!Eof())
				Reclock("NUE", .F.)
				NUE->NUE_SITUAC := cTpOper //Situação: 1=Pendente;2=Concluido
				NUE->NUE_CUSERA := JurUsuario(__CUSERID)
				NUE->NUE_ALTDT  := Date()
				If lAltHr
					NUE->NUE_ALTHR := Time()
				EndIf
				NUE->(MsUnlock())
				NUE->(DbCommit())

				// Grava na fila de sincronização a alteração
				J170GRAVA("NUE", xFilial("NUE") + NUE->NUE_COD, "4")

				For nFat := 1 To Len(_aFaturas)
					J204BVinc(nRecno, _aFaturas[nFat], cContr, cTpOper) // Efetiva o vínculo/remove os TSs da fatura
				Next nFat

				J204BAjTmp(aFieldsTmp, nRecno, .F., cAliasTmp, nRecnoTmp) // Ajusta tabela temporária por registro

			EndIf
		Next nTs
	END TRANSACTION

	RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J204BFilt
Aplica um filtro em uma tabela.

@Param cTableTmp, Tabela temporária onde será aplicado o filtro
@Param cFiltro  , filtro para aplicar no Alias

@Return aRet, Retorna os registros filtrados

@author  Luciano Pereira dos Santos
@since   17/10/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J204BFilt(cTableTmp, cFiltro)
	Local cQuery  := ""
	Local aRet    := {}

	cQuery := "SELECT TMP.RECNO, TMP.NXB_CCONTR, TMP.R_E_C_N_O_ RECTMP"
	cQuery +=       " FROM " + cTableTmp + " TMP "
	cQuery +=       " WHERE " + cFiltro + " "
	cQuery +=       " AND TMP.D_E_L_E_T_ = ' '"

	aRet := JurSQL(cQuery, {"RECNO", "NXB_CCONTR", "RECTMP"})

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J204BVinc
Efetiva o vínculo ou remove os time sheets da fatura

@param nRecTs , Recno do TimeSheet
@param aFatura, array com informações da fatura.
@param cContr , Código do contrato
@param cTpOper, Tipo de operação  '1' - Remover vinculo; '2' - Vincular

@author  Luciano Pereira dos Santos
@since   17/10/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J204BVinc(nRecTs, aFatura, cContr, cTpOper)
	Local lRet       := .F.
	Local aCampos    := {}
	Local aValores   := {}
	Local cEscr      := aFatura[1]
	Local cFatura    := aFatura[2]
	Local nPerc      := (aFatura[3] / 100.00)
	Local cMoeFat    := aFatura[4]
	Local dDtEmi     := SToD(aFatura[7])
	Local cChave     := ""
	Local cCodWo     := ""
	Local cSituac    := ""
	Local cNW0Canc   := ""
	Local nOperacao  := 0
	Local nAjuste    := Iif(cTpOper == "1", -1, 1)
	Local aConvLanc  := {}
	Local lCpoCotac  := NUE->(ColumnPos('NUE_COTAC ')) > 0 //Proteção
	Local lTemTS     := .F.
	Local aContratos := {}
	Local nLoopCtr   := 1
	Local nQtdContr  := 1
	Local nValVinc   := 0
	Local lTSNCobra  := SuperGetMV( 'MV_JTSNCOB',, .F. ) // Indica se vincula TimeSheet não cobrável na emissão
	Local nVTSNCobra := 0

	NXB->(DbSetOrder(3)) // NXB_FILIAL+NXB_CESCR+NXB_CFATUR+NXB_CCONTR
	NXC->(DbSetOrder(1)) // NXC_FILIAL+NXC_CESCR+NXC_CFATUR+NXC_CCLIEN+NXC_CLOJA+NXC_CCONTR+NXC_CCASO
	NW0->(DbSetOrder(1)) // NW0_FILIAL+NW0_CTS+NW0_SITUAC+NW0_PRECNF+NW0_CFATUR+NW0_CESCR+NW0_CWO
	NUE->(DbGoto(nRecTs))

	//Regra de preenchimento do WO.
	If nPerc == 0.0 .And. !Empty(aFatura[6])
		cSituac  := "3"
		cCodWo   := aFatura[6]
		cNW0Canc := "2"
	ElseIf nPerc != 0.0 .And. !Empty(aFatura[6])
		cSituac  := "2"
		cNW0Canc := "1"
	ElseIf nPerc != 0.0 .And. Empty(aFatura[6])
		cSituac  := "2"
		cNW0Canc := "2"
	EndIf

	aConvLanc := JA201FConv(cMoeFat, NUE->NUE_CMOEDA, NUE->NUE_VALOR, "8", dDtEmi, /*cCodFImpr*/, /*cPreFt*/, /*cXFilial*/, cEscr, cFatura)
	nValor1   := aConvLanc[1] // Valor convertido na moeda da fatura
	nVTAXA1   := aConvLanc[2] // Moeda da condição (TS)
	nVTAXA2   := aConvLanc[3] // Moeda da pré

	aCampos   := {"NW0_CTS", "NW0_CESCR", "NW0_CFATUR", "NW0_SITUAC", "NW0_CANC", "NW0_CODUSR","NW0_CCLIEN", "NW0_CLOJA", "NW0_CCASO",;
	              "NW0_CPART1", "NW0_TEMPOL", "NW0_TEMPOR", "NW0_VALORH", "NW0_CMOEDA", "NW0_DATATS", "NW0_DTVINC", "NW0_COTAC1", "NW0_COTAC2", "NW0_CWO"}

	aValores  := {NUE->NUE_COD, cEscr  , cFatura     ,  cSituac     , cNW0Canc   , __CUSERID, NUE->NUE_CCLIEN, NUE->NUE_CLOJA, NUE->NUE_CCASO,; // NW0_CANC: 1=Sim;2=Não
	              NUE->NUE_CPART1, NUE->NUE_TEMPOL, NUE->NUE_TEMPOR, NUE->NUE_VALORH, NUE->NUE_CMOEDA, NUE->NUE_DATATS, Date(), nVTAXA1, nVTAXA2, cCodWo}
	If lCpoCotac //Proteção
		Aadd(aCampos, "NW0_COTAC")
		Aadd(aValores, JurCotac(nVTAXA1, nVTAXA2))
	EndIf

	cChave   := xFilial('NW0') + NUE->NUE_COD + cSituac + Criavar('NUE_CPREFT', .F.) + cFatura + cEscr

	If NW0->(dbSeek(cChave))
		nOperacao := Iif(cTpOper == "1", 5, 4)
	Else
		nOperacao := 3
	EndIf

	If (lRet := JurOperacao(nOperacao, "NW0", 1, cChave, aCampos, aValores))

		// Tratamento para mesmo cliente, loja e caso em mais de um contrato de fixo com junção
		If !Empty(NXA->NXA_CJCONT)
			aContratos := J204BDivCtr(cEscr, cFatura, NUE->NUE_CCLIEN, NUE->NUE_CLOJA, NUE->NUE_CCASO)
			nQtdContr  := IIF(Empty(aContratos), 1, Len(aContratos))
		EndIf

		For nLoopCtr := 1 To nQtdContr
			If lRet
				cContr := IIF(nQtdContr == 1, cContr, aContratos[nLoopCtr][1]) // Divide valor do TS pela quantidade de contratos
				
				If NUE->NUE_COBRAR == "1" .And. J201DAtivC(NUE->NUE_CATIVI, cContr) //Atividade cobrável
					nValVinc := Round(J204BVinPar(nRecTs, aFatura, cContr, AnoMes(Date()), cTpOper, nQtdContr) * nPerc, TamSX3("NXC_VTSVIN")[2])
				Else
					If lTSNCobra // Vincula TimeSheet não cobrável
						nVTSNCobra := Round((nValor1 * nPerc * nAjuste) / nQtdContr, TamSX3("NXC_VTSVIN")[2])
					Else
						nValVinc := Round((nValor1 * nPerc * nAjuste) / nQtdContr, TamSX3("NXC_VTSVIN")[2])
					EndIf
				EndIf

				cChave := xFilial("NXC") + cEscr + cFatura + NUE->NUE_CCLIEN + NUE->NUE_CLOJA + cContr + NUE->NUE_CCASO
				If NXC->(DbSeek(cChave))
					aCampos  := {"NXC_VTSVIN"}
					aValores := {NXC->NXC_VTSVIN + nValVinc + nVTSNCobra}
					If lTSNCobra // Vincula TimeSheet não cobrável
						aAdd(aCampos, "NXC_VTSNC")
						aAdd(aValores, NXC->NXC_VTSNC + nVTSNCobra)
					EndIf
					lRet := JurOperacao(4, "NXC", 1, cChave, aCampos, aValores)
				EndIf

				cChave := xFilial("NXB") + cEscr + cFatura + cContr
				If lRet .And. NXB->(DbSeek(cChave))
					aCampos  := {"NXB_VTSVIN"}
					aValores := {NXB->NXB_VTSVIN + nValVinc + nVTSNCobra}
					If lTSNCobra // Vincula TimeSheet não cobrável
						aAdd(aCampos, "NXB_VTSNC")
						aAdd(aValores, NXB->NXB_VTSNC + nVTSNCobra)
					EndIf
					lRet := JurOperacao(4, "NXB", 3, cChave, aCampos, aValores)
				EndIf
			EndIf
		Next nLoopCtr
		
		// Só altera o NXA_TS se for fatura de Fixo.
		// Faturas de Fatura Adicional não serão ajustadas poios o NXA_TS vem SEMPRE como 1, mesmo que não tenha nenhum TS vinculado.
		If lRet .And. !J204BTemFA()
			cChave   := xFilial("NXA") + cEscr + cFatura
			lTemTS   := J204BTemTs(cEscr, cFatura)
			aCampos  := {"NXA_TS"}
			aValores := {IIf(lTemTS, "1", "2")}
			lRet := JurOperacao(4, "NXA", , cChave, aCampos, aValores)
		EndIf
	EndIf

	If lRet
		J170GRAVA("NXA", xFilial("NXA") + cEscr + cFatura, "4")
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J204BTemTs
Verifica se tem timesheet vinculado a fatura de fixo

@param cEscrit, Escritório da fatura
@param cFatura, Código da fatura

@return lTemTS, Se .T. tem timesheet vinculado.

@author Jorge Martins / Abner Fogaça
@since  08/02/2021
/*/
//-------------------------------------------------------------------
Static Function J204BTemTs(cEscrit, cFatura)
Local cQuery  := ""
Local lTemTS  := .F.
Local aQtdNW0 := {}

	cQuery := "SELECT COUNT(R_E_C_N_O_) RECNO"
	cQuery +=  " FROM " + RetSqlName("NW0") + " NW0 "
	cQuery += " WHERE NW0.NW0_FILIAL = '" + xFilial('NW0') + "' "
	cQuery +=   " AND NW0.NW0_CFATUR = '" + cFatura + "' "
	cQuery +=   " AND NW0.NW0_CESCR = '" + cEscrit + "' "
	cQuery +=   " AND NW0.NW0_SITUAC = '2' "
	cQuery +=   " AND NW0.NW0_CANC = '2' "
	cQuery +=   " AND NW0.D_E_L_E_T_ = ' ' "
	
	aQtdNW0 := JurSQL(cQuery, "*")

	lTemTS := Len(aQtdNW0) > 0 .And. aQtdNW0[1][1] > 0

	JurFreeArr(@aQtdNW0)

Return lTemTS

//-------------------------------------------------------------------
/*/{Protheus.doc} J204BVinPar
Efetiva o vínculos/remoções dos time sheets na fatura

@param nRecTs   , Recno do TimeSheet
@param aFatura  , array com informações da fatura.
@param cContr   , Código do contrato
@param cAnoMes  , Ano-mês vínculo na Fatura
@param cTpOper  , Tipo de operação  '1' - Remover vinculo; '2' - Vincular
@param cTpOper  , Tipo de operação  '1' - Remover vinculo; '2' - Vincular
@param nQtdContr, Quantidade de contratos para o mesmo cliente, loja e caso

@author  Luciano Pereira dos Santos
@since   17/10/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J204BVinPar(nRecTs, aFatura, cContr, cAnoMes, cTpOper, nQtdContr)
	Local lPartCli   := .F.
	Local cEscr      := aFatura[1]
	Local cFatura    := aFatura[2]
	Local cMoeFat    := aFatura[4]
	Local dDtEmi     := SToD(aFatura[7])
	Local cChave     := ""
	Local nOperacao  := 0
	Local nUTCli     := 0
	Local nHrFracCli := 0
	Local cHoraMinC  := PADL('0000:00', TamSX3('NXD_HRCLI')[1], '0')
	Local nUTRev     := 0
	Local nHrFracRev := 0
	Local cHoraMinR  := PADL('0000:00', TamSX3('NXD_HRREV')[1], '0')
	Local nUTLanc    := 0
	Local nHrFracLan := 0
	Local cHoraMinL  := PADL('0000:00', TamSX3('NXD_HRLANC')[1], '0')
	Local nValor     := 0
	Local nValor1    := 0
	Local lEncontrou := .F.
	Local nRecno     := 0
	Local cSeq       := ""
	Local nAjuste    := Iif(cTpOper == "1", -1, 1)
	Local nVlAdv     := 0
	Local nVlCorr    := 0

	NUE->(DbGoto(nRecTs))
	NXD->(dbSetOrder(1)) //NXD_FILIAL+NXD_CFATUR+NXD_CESCR+NXD_CCLIEN+NXD_CLOJA+NXD_CCASO+NXD_CCONTR+NXD_CPART+NXD_CCATEG+NXD_ANOMES
	lPartCli  := JurGetDados("NRC", 1, xFilial("NRC") + NUE->NUE_CATIVI, "NRC_PART") == "1" //Participação do cliente

	cChave := xFilial('NXD') + cFatura + cEscr + NUE->NUE_CCLIEN + NUE->NUE_CLOJA + NUE->NUE_CCASO + cContr + NUE->NUE_CPART2 + NUE->NUE_CCATEG + cAnoMes

	If NXD->(DbSeek(cChave))
		While NXD->NXD_FILIAL + NXD->NXD_CFATUR + NXD->NXD_CESCR + NXD->NXD_CCLIEN + NXD->NXD_CLOJA + NXD->NXD_CCASO + NXD->NXD_CCONTR + NXD->NXD_CPART + NXD->NXD_CCATEG + NXD->NXD_ANOMES == cChave
			//Completa a localização do registro pelo valor hora e participação do cliente
			If NXD->NXD_VLHORA != NUE->NUE_VALORH
				NXD->(DbSkip())
			Else
				lEncontrou := .T.
				Exit
			EndIf
		EndDo
		If lEncontrou
			nOperacao := 4
			cSeq      := NXD->NXD_CSEQ
			nUTCli    := NXD->NXD_UTCLI
			nUTRev    := NXD->NXD_UTREV
			nUTLanc   := NXD->NXD_UTLANC
			nVlAdv    := NXD->NXD_VLADVG
			nVlCorr   := NXD->NXD_VLCORR
			nRecno    := NXD->(Recno())
		Else //Se o valor hora ou participação do cliente diferente, inclui uma nova NXD
			nOperacao := 3
			cSeq      := J204BSeq(cEscr, cFatura, NUE->NUE_CCLIEN, NUE->NUE_CLOJA, NUE->NUE_CCASO, NUE->NUE_CPART2)
		EndIf
	Else
		nOperacao := 3
		cSeq      := J204BSeq(cEscr, cFatura, NUE->NUE_CCLIEN, NUE->NUE_CLOJA, NUE->NUE_CCASO, NUE->NUE_CPART2)
	EndIf

	//Se Ts esta sendo desvinculado e os valores de UT são iguais, o registro da NXD é somente para esse Ts e também será removido.
	If cTpOper == "1" .And. nUTLanc == NUE->NUE_UTL .And. Iif(lPartCli, nUTCli, nUTRev) == NUE->NUE_UTR .And. Iif(lPartCli, nUTRev, nUTCli) == 0
		nOperacao := 5
	Else
		If !lPartCli
			nUTRev     += (NUE->NUE_UTR * nAjuste) / nQtdContr
			nHrFracRev := Val(JURA144C1(1, 2, Str(nUTRev)))
			cHoraMinR  := PADL(JURA144C1(1, 3, Str(nUTRev), 4), TamSX3('NXD_HRREV')[1], '0')
		Else
			nUTCli     += (NUE->NUE_UTR * nAjuste) / nQtdContr
			nHrFracCli := Val(JURA144C1(1, 2, Str(nUTCli)))
			cHoraMinC  := PADL(JURA144C1(1, 3, Str(nUTCli), 4), TamSX3('NXD_HRCLI')[1], '0')
		EndIf
		nUTLanc    += (NUE->NUE_UTL * nAjuste) / nQtdContr
		nHrFracLan := Val(JURA144C1(1, 2, Str(nUTLanc)))
		cHoraMinL  := PADL(JURA144C1(1, 3, Str(nUTLanc), 4), TamSX3('NXD_HRLANC')[1], '0')
	EndIf

	nValor   := Round((NUE->NUE_VALOR * nAjuste) / nQtdContr, TamSX3("NXD_VLADVG")[2])
	nValor1  := JA201FConv(cMoeFat, NUE->NUE_CMOEDA, nValor, "8", dDtEmi, /*cCodFImpr*/, /*cPreFt*/, /*cXFilial*/, cEscr, cFatura)[1]
	nValor1  := Round(nValor1, TamSX3("NXD_VLCORR")[2]) //O valor do trabalho do participante não é dividido pelo percentual do pagador. A montetização ocorre apartir da NXC
	nVlAdv   += nValor
	nVlCorr  += nValor1

	aCampos  := {"NXD_CFATUR","NXD_CESCR","NXD_CCONTR","NXD_CCLIEN","NXD_CLOJA","NXD_CCASO","NXD_CPART","NXD_CCATEG","NXD_CSEQ","NXD_UTCLI","NXD_HRCLI","NXD_HFCLI",;
	             "NXD_UTLANC","NXD_HRLANC","NXD_HFLANC","NXD_UTREV","NXD_HRREV","NXD_HFREV","NXD_CMOEDT","NXD_VLHORA","NXD_VLADVG","NXD_CMOEDF","NXD_VLCORR","NXD_ANOMES"}

	aValores := {cFatura, cEscr, cContr, NUE->NUE_CCLIEN, NUE->NUE_CLOJA, NUE->NUE_CCASO, NUE->NUE_CPART2, NUE->NUE_CCATEG, cSeq, nUTCli, cHoraMinC, nHrFracCli,;
	             nUTLanc, cHoraMinL, nHrFracLan, nUTRev, cHoraMinR, nHrFracRev, NUE->NUE_CMOEDA, NUE->NUE_VALORH, nVlAdv , cMoeFat, nVlCorr, cAnoMes}

	lRet := JurOperacao(nOperacao, "NXD", 1, cChave, aCampos, aValores, nRecno)

Return nValor1

//-------------------------------------------------------------------
/*/{Protheus.doc} J204BSeq
Rotina para retornar o proximo numero da sequência para o registro de
participante da fatura

@param cEscr   , Código do escritório da fatura
@param cFatura , Código da fatura
@param cCliente, Código do cliente do caso da fatura
@param cLoja   , Código do loja do caso da fatura
@param cCaso   , Código do caso da fatura
@param cPart   , Código do participante

@return cSeq, Número da sequência para o part. da fatura

@author  Luciano Pereira
@since   17/10/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J204BSeq(cEscr, cFatura, cCliente, cLoja, cCaso, cPart)
	Local cQuery  := ""
	Local cQryRes := GetNextAlias()
	Local cSeq    := ""

	cQuery := " SELECT MAX(NXD.NXD_CSEQ) NXD_CSEQ "
	cQuery +=   " FROM " + RetSqlName("NXD") + " NXD "
	cQuery +=  " WHERE NXD.NXD_FILIAL = '" + xFilial("NXD") + "' "
	cQuery +=    " AND NXD.NXD_CESCR = '" + cEscr + "' "
	cQuery +=    " AND NXD.NXD_CFATUR = '" + cFatura + "' "
	cQuery +=    " AND NXD.NXD_CCLIEN = '" + cCliente + "' "
	cQuery +=    " AND NXD.NXD_CLOJA = '" + cLoja + "' "
	cQuery +=    " AND NXD.NXD_CCASO = '" + cCaso + "' "
	cQuery +=    " AND NXD.NXD_CPART = '" + cPart + "' "
	cQuery +=    " AND NXD.D_E_L_E_T_ = ' ' "

	DbUseArea( .T., "TOPCONN", TcGenQry( ,,cQuery ), cQryRes, .T., .T. )

	If !Empty((cQryRes)->NXD_CSEQ)
		cSeq := Soma1((cQryRes)->NXD_CSEQ)
	Else
		cSeq := StrZero( 1, TamSX3("NXD_CSEQ")[1] )
	EndIf

	(cQryRes)->(DbCloseArea())

Return cSeq

//-------------------------------------------------------------------
/*/{Protheus.doc} J204BTsPen
Retorna o total de TS pendente

@param cMoeFat, Moeda da fatura

@return nTotal, Total de time sheets pendentes

@author  Bruno Ritter
@since   20/03/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J204BTsPen(cMoeFat)
	Local cQryTotPen := ""
	Local nI         := 0
	Local nTotal     := 0
	Local cEscr      := NXA->NXA_CESCR
	Local cFatura    := NXA->NXA_COD
	Local dDtEmi     := NXA->NXA_DTEMI
	Local cTablePend := oTmpPend:GetRealName()

	cQryTotPen := " SELECT TEMP.NUE_CMOEDA, SUM(TEMP.NUE_VALOR) VALOR FROM " + cTablePend + " TEMP "
	cQryTotPen += " WHERE TEMP.D_E_L_E_T_ = ' '"
	cQryTotPen += " GROUP BY TEMP.NUE_CMOEDA"

	aDados := JurSql(cQryTotPen, {"NUE_CMOEDA", "VALOR"})

	For nI := 1 To Len(aDados)
		nTotal += JA201FConv(cMoeFat, aDados[nI][1], aDados[nI][2], "8", dDtEmi, , , , cEscr, cFatura)[1]
	Next nI

Return nTotal

//-------------------------------------------------------------------
/*/{Protheus.doc} J204BAtRes
Atualiza os campos de resumo

@param lReduzSld , Indica se o saldo para vínculo de TSs na fatura está sendo reduzido
                   - Marcação de TSs pendentes para vínculo
                   - Desmarcação de TSs vinculados para remoção
@param cMoeda    , Moeda do valor a ser ajustado
@param nValor    , Valor a ser ajustado

@author  Bruno Ritter
@since   20/03/2019
@version 1.0
@Obs oTsPenVinc, oTsVEmis, oTsVinc e oSaldoVinc são variáveis privates criadas na função J204BDlg
/*/
//-------------------------------------------------------------------
Static Function J204BAtRes(lReduzSld, cMoeda, nValor)
	Local nValConv    := JA201FConv(NXA->NXA_CMOEDA, cMoeda, nValor, "8", NXA->NXA_DTEMI, , , , NXA->NXA_CESCR, NXA->NXA_COD)[1]
	Local nTsPenVinc  := Iif(lReduzSld, -1,  1) * nValConv
	Local nTsVinc     := Iif(lReduzSld,  1, -1) * nValConv
	Local nSaldoVinc  := 0
	Local lLimitaTS   := SuperGetMv("MV_JLIMVTS", .F., .T.) //Indica se o vínculo de TSs será limitado ao valor faturado .T.-Sim ou .F.-Não

	oTsPenVinc:SetValue(oTsPenVinc:GetValue() + nTsPenVinc)
	oTsVinc:SetValue(oTsVinc:GetValue() + nTsVinc)
	If lLimitaTS
		nSaldoVinc := Iif(lReduzSld, -1,  1) * nValConv
		oSaldoVinc:SetValue(oSaldoVinc:GetValue() + nSaldoVinc)
	EndIf
	
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J204BSetMk
Função para executar após a marcação de um registro, valida e marca o registro

@param oMarkBrw , FWMarkBrowse que foi realizado a marcação
@param lBrwPend , Se foi marcado o FWMarkBrowse dos TSs pendentes
@param cAliasTmp, Alias da tabela que foi marcada
@param lMarkAll , Se está sendo executado o marcar todos registros

@return lMarcPrx , Se pode marcar o proximo registro (usado no MarkAll)

@author  Bruno Ritter
@since   20/03/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J204BSetMk(oMarkBrw, lBrwPend, cAliasTmp, lMarkAll)
	Local cMarca     := oMarkBrw:Mark()
	Local cDesMarca  := Space(TamSx3("NUE_OK")[1])
	Local lMarcando  := (cAliasTmp)->NUE_OK != cMarca // Verifica se estar marcando o registro
	Local lReduzSld  := lBrwPend == lMarcando // Verifica se o saldo será reduzido (Marcação no oMkBrwPend e desmarcação no oMkBrwVinc)
	Local dDataVinc  := (cAliasTmp)->NW0_DTVINC
	Local aVldSld    := {.T., .T.}
	Local lMarcar    := .T.
	Local lDividiu   := .F.
	Local lMarcPrx   := .T.
	Local lLimitaTS  := SuperGetMv("MV_JLIMVTS", .F., .T.) //Indica se o vínculo de TSs será limitado ao valor faturado .T.-Sim ou .F.-Não

	Default lMarkAll := .F.

	If lLimitaTS
		If !lReduzSld
			If cAliasTmp == cAlsVinc
				If Empty(dDataVinc)
					If !lMarkAll // Exibe a mensagem apenas quando não for a opção de marcar todos
						JurMsgErro(STR0047, , STR0048) // "Time Sheet Vinculado na Emissão!" # "Somente Time Sheets vinculados manualmente podem ser desvinculados."
					EndIf
					lMarcar  := .F.
				ElseIf !J204BVlCal(dDataVinc) // Validação Calend. Contábil (Usado para desvincular TSs)
					lMarcPrx := .F.
					lMarcar  := .F.
					JurMsgErro( I18n(STR0016, {(cAliasTmp)->NUE_COD}), , ; // "Não é possível remover o time sheet da fatura #1."
								I18n(STR0017, { DToC( dDataVinc ) } ) ) // "Verifique se o processo 'Contas a receber' está em aberto para o período do calendário contábil que contempla a data do vínculo ('#1') do time sheet nessa fatura."
				EndIf
			EndIf
		Else
			If oSaldoVinc:GetValue() < 0.01 // Verifica o saldo disponível
				lMarcPrx := .F.
				lMarcar  := .F.
				ApMsgInfo(i18n(STR0037, {(cAliasTmp)->NUE_COD}), STR0045) // "Saldo insuficiente para vincular o Time Sheet '#1'." | "Atenção"

			Else
				nVlrConv := J204BVlrCon(cAliasTmp) // Retorna valor convertido do TS

				If nVlrConv > 0
					If cAliasTmp == cAlsPend
						aVldSld  := J204BVldSal(nVlrConv) // Valida Saldo (Realiza a divisão do TS caso necessário)
						lMarcar  := aVldSld[1] // Indica se o TS atual foi validado e deve ser marcado
						lDividiu := aVldSld[2] // Indica que o TS foi divido
						lMarcPrx := lMarcar .And. !lDividiu // Indica que pode marcar o próximo registro (Usado na marcação em lote)
					EndIf
				Else
					lMarcar  := .F.
					lMarcPrx := .F.
					If Empty((cAliasTmp)->NUE_CMOEDA)
						If lMarkAll
							lMarcPrx := .T. // Caso não tenha moeda e for via markall, permite continuar marcando os registros, pois será emitida mensagem na função J204BAllMK
						Else
							ApMsgInfo(i18n(STR0050, {(cAliasTmp)->NUE_COD}), STR0045) // "Não é possível marcar o Time Sheet '#1', pois o mesmo não possui valor. Verifique." | "Atenção"
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	If lMarcar
		J204BAtRes(lReduzSld, (cAliasTmp)->NUE_CMOEDA, (cAliasTmp)->NUE_VALOR) // Atualiza os valores do resumo

		RecLock(cAliasTmp, .F.)
		(cAliasTmp)->NUE_OK := Iif(lMarcando, cMarca, cDesMarca)
		(cAliasTmp)->(MsUnlock())

		If !lMarkAll
			J204BDisEn() // Habilita e desabilita o MarkBrowse
		EndIf
	EndIf

	JurFreeArr(aVldSld)

Return lMarcPrx

//-------------------------------------------------------------------
/*/{Protheus.doc} J204BAllMk
Marca todos registro do FWMarkBrowse

@param oMarkBrw , FWMarkBrowse que foi realizado a marcação
@param lBrwPend , Se foi marcado o FWMarkBrowse dos TSs pendentes
@param cAliasTmp, Alias da tabela que foi marcada

@author  Bruno Ritter
@since   20/03/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J204BAllMk(oMarkBrw, lBrwPend, cAliasTmp)
	Local cMarca     := oMarkBrw:Mark()
	Local nRecOld    := (cAliasTmp)->(Recno())
	Local lMarcPrx   := .T.
	Local aDesMark   := {}
	Local lMarkAll   := .T.
	Local cTSSemMoe  := ""

	(cAliasTmp)->(DbGoTop())
	While !(cAliasTmp)->(Eof()) .And. lMarcPrx

		If (cAliasTmp)->NUE_OK == cMarca
			lMarcPrx := J204BSetMk(oMarkBrw, lBrwPend, cAliasTmp, lMarkAll)
			Aadd(aDesMark, (cAliasTmp)->RECNO)
		EndIf

		(cAliasTmp)->(dbSkip())
	EndDo

	(cAliasTmp)->(DbGoTop())
	While !(cAliasTmp)->(Eof()) .And. lMarcPrx

		If aScan(aDesMark, (cAliasTmp)->RECNO) == 0 // Se não estava desmarcado
			lMarcPrx := J204BSetMk(oMarkBrw, lBrwPend, cAliasTmp, lMarkAll)

			If lBrwPend .And. lMarcPrx .And. Empty((cAliasTmp)->NUE_CMOEDA) // Identifica os TSs sem moeda para emitir mensagem.
				cTSSemMoe += IIf(Empty(cTSSemMoe), (cAliasTmp)->NUE_COD, ", " + (cAliasTmp)->NUE_COD)
			EndIf

		EndIf

		(cAliasTmp)->(dbSkip())
	EndDo

	If lMarcPrx // Todos que estavam desmarcados foram marcados
		oMarkBrw:GoTo(nRecOld, .T.)
	Else
		oMarkBrw:Refresh(.T.)
	EndIf

	// Habilita e desabilita o MarkBrowse
	J204BDisEn()
	JurFreeArr(aDesMark)

	If !Empty(cTSSemMoe)
		ApMsgInfo(i18n(STR0051, {cTSSemMoe}), STR0045) // "Não é possível marcar Time Sheets sem valor. Verifique o(s) Time Sheet(s) '#1'." | "Atenção"
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J204BCoAlt
Confirma os TSs marcados, vinculando ou desvinculado

@param lVincTS   , Indica se os TSs estão sendo vinculados (.T.)
                   - Ou desvinculados (.F.)
@param aFieldsTmp, Campos da tabela temporária

@author  Bruno Ritter
@since   20/03/2019
@version 1.0
@Obs oMkBrwPend, cAlsPend, oMkBrwVinc, cAlsVinc são variáveis privates criadas na função J204BDlg
/*/
//-------------------------------------------------------------------
Static Function J204BCoAlt(lVincTS, aFieldsTmp)
	Local cAliasTmp := IIf(lVincTS, cAlsPend  , cAlsVinc)
	Local oMkBrwTmp := IIf(lVincTS, oMkBrwPend, oMkBrwVinc)

	If J204BEnvMk(lVincTS, aFieldsTmp, cAliasTmp, oMkBrwTmp)
		J204BConf(lVincTS) // Vincular na fatura
		J204BDisEn() // Habilita e desabilita o MarkBrowse
		oMkBrwPend:Refresh(.T.)
		oMkBrwVinc:Refresh(.T.)
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J204BEnvMk
Atualiza a tabela temporária com os registros marcados (Envia os
registros marcados para o outro browse)

@param lVincTS   , Indica se os TSs estão sendo vinculados (.T.)
                   - Ou desvinculados (.F.)
@param aFieldsTmp, Campos da tabela temporária
@param cAliasTmp , Alias da tabela que foi marcada
@param oMarkBrw  , FWMarkBrowse que foi realizado a marcação

@return lEnviou  , Indica se algum TS foi enviado para o outro browse (vinculado ou desvinculado)

@author  Bruno Ritter
@since   20/03/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J204BEnvMk(lVincTS, aFieldsTmp, cAliasTmp, oMarkBrw)
	Local cCodTS   := ""
	Local cMarca   := oMarkBrw:Mark()
	Local lEnviou  := .F.

	(cAliasTmp)->(DbGoTop())

	While !(cAliasTmp)->(Eof())
		If (cAliasTmp)->NUE_OK == cMarca
			cCodTS := (cAliasTmp)->NUE_COD

			J204BAtuTmp(aFieldsTmp, cCodTS, lVincTS) // Atualização da Tabela Temporária
			lEnviou := .T.
		EndIf
		(cAliasTmp)->(dbSkip())
	EndDo

Return lEnviou

//-------------------------------------------------------------------
/*/{Protheus.doc} J204BDivTs
Divide o TS pendente com base no valor passado por parâmetro
- O TS atual ficará com o valor mais perto possível do enviado por parâmetro (nNewVal)
- O TS que será criado ficará com a diferença entre o novo valor e o valor antigo do TS

@param nNewVal, O valor utilizado como base para o novo valor do time sheet
                posicionado (cAlsPend) que será dividido

@return lRet  , Indica se a divisão foi efetuada com sucesso

@author Jorge Martins / Bruno Ritter
@since  26/03/2019
@obs    O TS alterado nunca vai ficar com o valor maior que o parâmetro (nNewVal)
/*/
//-------------------------------------------------------------------
Static Function J204BDivTs(nNewVal)
	Local lRet       := .T.
	Local lInclui    := .T.
	Local cContr     := ""
	Local nRecTmp    := (cAlsPend)->(Recno())
	Local nAtuRecTs  := (cAlsPend)->RECNO
	Local nNewRecTS  := JA144DivVl(nAtuRecTs, nNewVal) // Recno do novo TS
	Local aFieldsTmp := {}

	If nNewRecTS == 0
		lRet := .F.
		JurMsgErro(STR0035, , STR0036) // "Não foi possível dividir o time sheet" "O saldo pode ser muito baixo para efetuar a divisão."
	Else
		aFieldsTmp := (cAlsPend)->(dbStruct())
		cContr     := J204BContra((cAlsPend)->NUE_COD)

		J204BAjTmp(aFieldsTmp, nAtuRecTs, !lInclui, cAlsPend) // Altera na tabela temporária o TS posicionado
		J204BAjTmp(aFieldsTmp, nNewRecTS, lInclui, cAlsPend)  // Incluir na tabela temporária o novo TS criado pela divisão

		oMkBrwPend:GoTo(nRecTmp, .T.)
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J204BAjTmp
Insere ou altera um registro na tabela temporaria de
Time Sheets pendentes conforme o recno da NUE

@param aFieldsTmp, Campos da tabela temporária.
@param nRecNUE   , Recno do TS (NUE) que deve ser usado
                   para cópiar para a tabela temporária.
@param lInclui   , Indica se o TS (NUE) deve ser incluído na tabela temporária
                   (Em caso de alteração será enviado .F.)
@param cAliasTmp , Alias da tabela que foi marcada (TSs pendentes ou TSs vinculados)
@param nRecTmp   , Recno na tabela temporária que deve ser alterado
                   caso o parâmetro lInclui for .F.

@author Jorge Martins / Bruno Ritter
@since  26/03/2019
/*/
//-------------------------------------------------------------------
Static Function J204BAjTmp(aFieldsTmp, nRecNUE, lInclui, cAliasTmp, nRecTmp)
	Local cField    := ""
	Local xValor    := Nil
	Local nI        := 0
	Local lBrwPend  := cAliasTmp == cAlsPend // Indica que o alias que será atualizado é o de TSs pendentes
	Local cQuery    := JA204BQry(lBrwPend, nRecNUE)[1]
	Local cQryRes   := GetNextAlias()
	Local cContr    := Criavar('NXB_CCONTR', .F.)

	Default nRecTmp := 0

	cQuery := ChangeQuery(cQuery, .F.)
	dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cQryRes, .T., .F. )

	If nRecTmp > 0
		(cAliasTmp)->(DbGoTo(nRecTmp))
	EndIf

	If (cQryRes)->(!Eof()) .And. (cAliasTmp)->(!Eof())
		BEGIN TRANSACTION
			RecLock(cAliasTmp, lInclui)

			For nI := 1 To Len(aFieldsTmp)
				cField := aFieldsTmp[nI][1]
				If cField == "EMISSAO"
					xValor := '2'
				ElseIf cField == "NXB_CCONTR"
					xValor := cContr
				Else
					xValor := (cQryRes)->(FieldGet(FieldPos(cField)))
					If ValType((cAliasTmp)->(FieldGet(FieldPos(cField)))) == "D" .And. ValType(xValor) == "C"
						xValor := StoD(xValor)
					EndIf
				EndIf

				(cAliasTmp)->(FieldPut(FieldPos(cField), xValor))

			Next nI

			(cAliasTmp)->(MsUnLock())
		END TRANSACTION
	EndIf

	(cQryRes)->(DbCloseArea())

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J204BDisEn
Habilita e desabilita o MarkBrowse

@author  Jorge Martins / Bruno Ritter
@since   26/03/2019
/*/
//-------------------------------------------------------------------
Static Function J204BDisEn()
	Local cTablePend := oTmpPend:GetRealName()
	Local cTableVinc := oTmpVinc:GetRealName()
	Local cTamMark   := Space(TamSx3("NUE_OK")[1])
	Local cMarcaPend := Iif(oMkBrwPend:IsInvert(), cTamMark, oMkBrwPend:Mark())
	Local cMarcaVinc := Iif(oMkBrwVinc:IsInvert(), cTamMark, oMkBrwVinc:Mark())

	If J204BMark(cTableVinc, cMarcaVinc) // Verifica se existe algum TS marcado no Grid de TSs vinculados
		oMkBrwPend:Disable()
	Else
		oMkBrwPend:Enable()
	EndIf

	If J204BMark(cTablePend, cMarcaPend) // Verifica se existe algum TS marcado no Grid de TSs pendentes
		oMkBrwVinc:Disable()
	Else
		oMkBrwVinc:Enable()
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J204BMark
Retorna se existe um registro marcado no MarkBrowse

@param cTableTmp, Tabela temporária que será verificada
@param cMarca   , Identificação da marca na tabela temporária

@return lAchou  , Indica se encontrou algum registro marcado

@author  Jorge Martins / Bruno Ritter
@since   26/03/2019
/*/
//-------------------------------------------------------------------
Static Function J204BMark(cTableTmp, cMarca)
	Local lAchou    := .F.
	Local cQryAlias := GetNextAlias()
	Local cQuery    := ""

	 cQuery := " SELECT COUNT(1) CONTA FROM " + cTableTmp + " TMP "
	 cQuery += " WHERE TMP.NUE_OK = '" + cMarca + "'"
	 cQuery +=   " AND TMP.D_E_L_E_T_ = ' '"

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TCGenQry(, , cQuery), cQryAlias, .F., .T.)

	If (cQryAlias)->(!Eof())
		lAchou := (cQryAlias)->CONTA > 0
	EndIf

	(cQryAlias)->(dbCloseArea())

Return lAchou

//-------------------------------------------------------------------
/*/{Protheus.doc} J204BDivCtr
Retorna os contratos da fatura que estão vinculados ao cliente, loja e caso.
Pode existir mais de um contrato para o mesmo cliente, loja e caso quando
for uma junção de contratos de fixo.

@param  cEscrit , Código do escritório da fatura
@param  cFatura , Código da fatura
@param  cCliente, Código do cliente
@param  cLoja   , Loja do cliente
@param  cCaso   , Caso do cliente

@return aContratos, Retorna os contratos da fatura que estão vinculados
                    ao cliente, loja e caso.

@author Jorge Martins
@since  21/08/2019
/*/
//-------------------------------------------------------------------
Static Function J204BDivCtr(cEscrit, cFatura, cCliente, cLoja, cCaso)
	Local cQueryNXC  := ""
	Local aContratos := {}

	cQueryNXC := "SELECT NXC_CCONTR, NXC_VLTS "
	cQueryNXC +=   "FROM " + RetSQlName("NXC") + " NXC "
	cQueryNXC +=  "WHERE NXC.NXC_FILIAL = '" + xFilial("NXC") + "' "
	cQueryNXC +=    "AND NXC.NXC_CESCR  = '" + cEscrit + "' "
	cQueryNXC +=    "AND NXC.NXC_CFATUR = '" + cFatura + "' "
	cQueryNXC +=    "AND NXC.NXC_CCLIEN = '" + cCliente + "' "
	cQueryNXC +=    "AND NXC.NXC_CLOJA  = '" + cLoja + "' "
	cQueryNXC +=    "AND NXC.NXC_CCASO  = '" + cCaso + "' "
	cQueryNXC +=    "AND NXC.NXC_VlTS   = 0 "
	cQueryNXC +=    "AND NXC.D_E_L_E_T_ = ' ' "

	aContratos := JurSQL(cQueryNXC, "*")

Return (aContratos)
