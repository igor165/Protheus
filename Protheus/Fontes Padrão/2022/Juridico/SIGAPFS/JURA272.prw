#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "JURA272.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA272
Geração de e-billing em Lote

@author Jonatas Martins
@since  06/04/2020
/*/
//-------------------------------------------------------------------
Function JURA272()
	Local aArea := GetArea()

	If NXA->(ColumnPos("NXA_ARQEBI")) > 0
		J272MarkBrw()
	Else
		JurMsgErro(STR0027,, STR0028) // "Dicionário de dados desatualizado!" # "Atualize o dicionário de dados para criar o campo de flag na fatura e o relacionamento com o complemento de cliente."
	EndIf

	RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J272MarkBrw
Monta tela de seleção das faturas para geração do arquivo e-billing

@author Jonatas Martins
@since  06/04/2020
/*/
//-------------------------------------------------------------------
Static Function J272MarkBrw()
	Private oMBrw272 := Nil
	Private lMarcar  := .F.

	oMBrw272 := FWMarkBrowse():New()
	oMBrw272:SetDescription(STR0001) // "Geração e-billing em Lote"
	oMBrw272:SetAlias("NXA")
	oMBrw272:SetProfileID("J272")
	oMBrw272:DisableReport()
	oMBrw272:oBrowse:SetDBFFilter(.T.)
	oMBrw272:oBrowse:SetUseFilter()
	oMBrw272:SetMenuDef("")
	oMBrw272:SetFieldMark("NXA_OK")
	oMBrw272:bAllMark := {|| JurMarkALL(@oMBrw272, "NXA", "NXA_OK", lMarcar := !lMarcar,, .F.), oMBrw272:Refresh()}
	oMBrw272:AddButton(STR0002, "VIEWDEF.JURA204", Nil, 2, 0) // "Visualizar"
	oMBrw272:AddButton(STR0003, {|| IIF(J272IsMark(), J272Info(), ApMsgInfo(STR0026))}, Nil, 1, 0) // "Gerar" ## "Nenhum registro selecionado!"
	J272Filter()
	oMBrw272:Activate()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J272IsMark
Função avalia se foi selecionado ao menos um registro

@retunr lValid, logico, Se verdadeiro informa que existe registro marcado

@author Jonatas Martins
@since  06/04/2020
/*/
//-------------------------------------------------------------------
Static Function J272IsMark()
	Local cMarca   := oMBrw272:Mark()
	Local lInvert  := oMBrw272:IsInvert()
	Local cAlsMark := oMBrw272:Alias()
	Local cFiltro  := "(NXA_OK " + IIF(lInvert, "<>", "=" ) + " '" + cMarca + "')"
	
	lValid := JurSql("SELECT COUNT(1) FROM " + RetSqlName(cAlsMark) + " WHERE " + cFiltro, "*")[1][1] > 0

Return (lValid)

//-------------------------------------------------------------------
/*/{Protheus.doc} J272Filter
Adiciona filtros no markbrowse

@param  oMBrw272, objeto, Estrutura da tela de seleção dos registros

@author Jonatas Martins
@since  06/04/2020
/*/
//-------------------------------------------------------------------
Static Function J272Filter()
	oMBrw272:AddFilter(STR0004, "NXA_TIPO == 'FT' .AND. NXA_SITUAC == '1'", .F., .T., ""   , .F.,, "F1") // "Faturas ativas" 
	oMBrw272:AddFilter(STR0005, "NXA_ARQEBI <> '1'"                       , .F., .T., ""   , .F.,, "F1") // "Faturas com arquivos não gerados"
	oMBrw272:AddFilter(STR0006, "NUH_UTEBIL = '1' AND D_E_L_E_T_ = ' '"   , .F., .T., "NUH", .F.,, "F2") // "Faturas de clientes e-billing"
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J272Info
Monta tela para obter dados que serão utilizados na geração dos arquivos

@param  oMBrw272, objeto, Estrutura da tela de seleção dos registros

@author Jonatas Martins
@since  06/04/2020
/*/
//-------------------------------------------------------------------
Function J272Info()
	Local oLayer    := FWLayer():new()
	Local oDlgArq   := Nil
	Local oMainColl := Nil

	Local oNomeArq  := Nil
	Local oDirArq   := Nil
	Local oMoeda    := Nil
	Local oRadio    := Nil
	
	Local cNomeArq  := __cUserId
	Local cDirArq   := GetTempPath(.T.)
	Local cMoeda    := ""
	Local nRadio    := 1

	oDlgArq := FWDialogModal():New()
	oDlgArq:SetFreeArea(250, 110)
	oDlgArq:SetEscClose(.F.)
	oDlgArq:SetBackground(.T.)
	oDlgArq:SetTitle(STR0007) //"Dados da Geração"
	oDlgArq:EnableFormBar(.T.)
	oDlgArq:CreateDialog()
	oDlgArq:AddOkButton({|| lOk := !Empty(cMoeda), IIF(lOk, J272Proc(cMoeda, cNomeArq, cDirArq, nRadio), ApMsgInfo(STR0008)),; // "Preencha a moeda e-billing!"
	                        IIF(lOk, oDlgArq:oOwner:End(), Nil)})
	oDlgArq:AddCloseButton({|| oDlgArq:oOwner:End()})

	oLayer:Init(oDlgArq:GetPanelMain(), .F.)
	oLayer:AddCollumn("MainColl", 100, .F.)
	oMainColl := oLayer:GetColPanel("MainColl")
	
	oNomeArq := TJurPnlCampo():New(10,20,215,20, oMainColl, STR0009,,{||}, {|| cNomeArq := AllTrim(oNomeArq:GetValue())}, Space(50),,,) //"Nome do Arquivo:"
	oNomeArq:SetHelp(STR0010) // "Indique o nome do arquivo a ser gerado."

	oDirArq := TJurPnlCampo():New(37,20,155,20, oMainColl, STR0011,, {||}, {||}, Space(100),,,) // "Informe o caminho:"
	oDirArq:SetHelp(STR0012) // "Indique o caminho para geração do arquivo."
	oBtDir := TButton():New(47,175, "...", oMainColl, {||oDirArq:SetValue(AllTrim(cGetFile("*.*", STR0030, 0,, .T., GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_NETWORKDRIVE))), cDirArq := AllTrim(oDirArq:GetValue())}, 10, 10,,,, .T.)//"Selecione o Diretorio p/ gerar o Arquivo"

	oMoeda := TJurPnlCampo():New(37,193,40,20, oMainColl, STR0013, "CTO_MOEDA", {|| }, {|| cMoeda := oMoeda:GetValue()},,,, "CTO") // "Moeda E-billing:"
	oMoeda:SetHelp(STR0014) // "Código da moeda com a qual será gerado o arquivo e-billing."
	oMoeda:SetValid({|| Empty(oMoeda:GetValue()) .Or. ExistCpo("CTO", oMoeda:GetValue(), 1)})

	@ 68,20 RADIO oRadio VAR nRadio ITEMS STR0015, STR0016, STR0017 3D SIZE 100,10 OF oMainColl PIXEL // "E-billing Ledes 1998B" # "E-billing Ledes 1998BI" # "E-billing Ledes 2000"

	oDlgArq:Activate()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J272Proc
Função que prepara o processamento para geração dos arquivos

@param  cMoeEbi , caracater, Códiga moeda e-Billing
@param  cNomeArq, caracater, Nome do arquivo e-Billing
@param  cDirArq , caracater, Pasta para geração do arquivo e-Billing
@param  nTipoEbi, caracater, Tipo do e-Billing 1=1998; 2=1998BI, 3=2000

@author Jonatas Martins
@since  06/04/2020
/*/
//-------------------------------------------------------------------
Static Function J272Proc(cMoeEbi, cNomeArq, cDirArq, nTipoEbi)
	Local cMarca   := oMBrw272:Mark()
	Local lInvert  := oMBrw272:IsInvert()
	Local cFiltro  := "(NXA_OK " + IIF(lInvert, "<>", "==" ) + " '" + cMarca + "')"
	Local cAux     := &('{||' + cFiltro + '}')
	Local nMarkNXA := 0
	Local oProcess := Nil

	NXA->(DbSetFilter(cAux, cFiltro))
	NXA->(DbSetOrder(1))
	NXA->(DbEval({|| nMarkNXA++}))

	oProcess := MsNewProcess():New({|| J272GerArq(@oProcess, nMarkNXA, cMoeEbi, cNomeArq, cDirArq, nTipoEbi)}, STR0018, STR0019, .T.) // "Aguarde" # "Processando..."
	oProcess:Activate()

	NXA->(DBClearFilter())
	oMBrw272:ExecuteFilter(.T.)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J272GerArq
Geração de arquivos e-billing

@param  oProcess, objeto   , Estrutura das barras de processamentos
@param  nMarkNXA, numerico , Total de faturas selecionadas para gerar arquivo
@param  cMoeEbi , caracater, Códiga moeda e-Billing
@param  cNomeArq, caracater, Nome do arquivo e-Billing
@param  cDirArq , caracater, Pasta para geração do arquivo e-Billing
@param  nTipoEbi, caracater, Tipo do e-Billing 1=1998; 2=1998BI, 3=2000

@return lGerou  , logico   , Se verdadeiro o arquivo foi gerado

@author Jonatas Martins
@since  06/04/2020
/*/
//-------------------------------------------------------------------
Static Function J272GerArq(oProcess, nMarkNXA, cMoeEbi, cNomeArq, cDirArq, nTipoEbi)
	Local lEbi2000  := .F.
	Local l1998BI   := .F.
	Local nReg      := 0
	Local aRetArq   := {.T., ""}
	Local cFileName := ""
	Local cMsgRet   := ""
	Local cTotReg   := cValToChar(nMarkNXA)

	oProcess:SetRegua1(2)
	oProcess:SetRegua2(nMarkNXA)
	oProcess:IncRegua1(STR0020) // "Criando arquivos e-billing, aguarde..."

	If nTipoEbi == 2     // 1998BI
		l1998BI  := .T.
	ElseIf nTipoEbi == 3 // 2000
		lEbi2000 := .T.
	EndIf

	NXA->(DbGotop())
	While NXA->(! EOF())
		nReg ++
		
		oProcess:IncRegua2(I18n(STR0021, {cValToChar(nReg), cTotReg})) // "Gerando arquivo e-Billing #1 de #2"
		cFileName := cNomeArq + "_" + AllTrim(NXA->NXA_CESCR) + "_" + NXA->NXA_COD + "_" + FwTimeStamp(1)
		
		BEGIN TRANSACTION
			If lEbi2000
				aRetArq := LEDES00(NXA->NXA_COD, NXA->NXA_CESCR, cMoeEbi, cFileName, cDirArq, .T.)
			Else
				aRetArq := LEDES98(.T., cFileName, cDirArq, cMoeEbi, IIF(l1998BI, STR0022, STR0023), NXA->NXA_COD, NXA->NXA_CESCR) // "Sim" # "Não"
			EndIf
			
			cMsgRet += J272Log(lEbi2000, aRetArq)

			J272UpdMark()
		END TRANSACTION
		
		JurFreeArr(aRetArq)
		NXA->(DbSkip())
	End

	If !Empty(cMsgRet)
		JurErrLog(cMsgRet, STR0031) // "Log de Processamento"
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J272Log
Função que formata log da geração do arquivo

@param  lEbi2000, logico, Tipo de arquivo E-billing
@param  aRetArq , array , Retorno do processamento na geração do arquivo

@author Jonatas Martins
@since  06/04/2020
/*/
//-------------------------------------------------------------------
Static Function J272Log(lEbi2000, aRetArq)
	Local xMsgLog := Nil
	Local cNewLog := ""
	Local nLog    := 0

	Default lEbi2000 := .F.
	Default aRetArq  := ""

	xMsgLog := IIF(Len(aRetArq) >= 2, aRetArq[2], "")

	If !Empty(xMsgLog)
		cNewLog := STR0024 + NXA->NXA_CESCR + " - " + STR0025 + NXA->NXA_COD + " - " // "Escritório:" # "Fatura"

		If lEbi2000
			cNewLog += AllTrim(xMsgLog)
		Else
			For nLog := 1 To Len(xMsgLog)
				cNewLog += AllTrim(xMsgLog[nLog]) + " | "
			Next nLog
		EndIf

		cNewLog += CRLF + Replicate("-", 80) + CRLF
	EndIf

Return (cNewLog)

//-------------------------------------------------------------------
/*/{Protheus.doc} J272UpdMark
Função que limpa marca de registro que forma processados

@author Jonatas Martins
@since  06/04/2020
/*/
//-------------------------------------------------------------------
Static Function J272UpdMark()
	RecLock("NXA", .F.)
	NXA->NXA_OK := Space(TamSX3("NXA_OK")[1])
	NXA->(MsUnLock())
Return Nil
