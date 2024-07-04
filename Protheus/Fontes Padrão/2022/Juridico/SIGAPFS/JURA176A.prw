#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "JURA176A.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"

Static _lFwPDCanUse := FindFunction("FwPDCanUse")

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA176A
Tela de aprovação de lançamentos do tarifador

@author  Jonatas Martins / Jorge Martins
@since   18/06/2019
/*/
//-------------------------------------------------------------------
Function JURA176A()
	Private cAlsTemp  := ""
	Private aTabTemp  := {}
	Private oTabTemp  := Nil
	Private oMark176A := Nil
	Private lMarcar   := .F.

	If NYX->(ColumnPos("NYX_STATUS")) > 0
		If J176AFiltro()
			J176AMark()
		EndIf
	Else
		JurMsgErro(STR0001,, STR0002) // "Estrutura da tabela NYX não está atualizada!" - "Atualize o dicionário de dados."
	EndIf

	If ValType(oTabTemp) == "O"
		oTabTemp:Delete()
	EndIf

	JurFreeArr(aTabTemp)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J176AFiltro
Tela para filtro dos lançamentos do tarifador

@param  lUpdate, logico, Se .T. informa que a execução do filtro
                         é por dentro do MarkBrowse

@return lFiltro, logico, Se .T. informa que encontrou dados de
                         lançamentos respeitando os filtros

@author Jonatas Martins / Jorge Martins
@since  18/06/2019
/*/
//-------------------------------------------------------------------
Function J176AFiltro(lUpdate)
	Local oLayer     := FWLayer():new()
	Local oMainColl  := Nil
	Local oDlgFil    := Nil
	Local oSigla     := Nil
	Local oDataIni   := Nil
	Local oDataFim   := Nil
	Local oGrpStatus := Nil
	Local oPnlStatus := Nil
	Local oStatus1   := Nil
	Local oStatus2   := Nil
	Local oStatus3   := Nil
	Local oStatus4   := Nil
	Local oStatus5   := Nil
	Local lStatus1   := .F.
	Local lStatus2   := .F.
	Local lStatus3   := .F.
	Local lStatus4   := .F.
	Local lStatus5   := .F.
	Local lFiltro    := .F.
	Local bVldData   := {|| IIf(Empty(oDataIni:GetValue()) .Or. Empty(oDataFim:GetValue()), .T., oDataIni:GetValue() <= oDataFim:GetValue())}
	Local cPart      := JurUsuario(__CUSERID)
	Local lTecnico   := JurGetDados("NUR", 1, xFilial("NUR") + cPart, "NUR_TECNIC") == '1'

	Default lUpdate  := .F.

	oDlgFil := FWDialogModal():New()
	oDlgFil:SetFreeArea(145, 145)
	oDlgFil:SetEscClose(.F.)    // Não permite fechar a tela com o ESC
	oDlgFil:SetCloseButton(.F.) // Não permite fechar a tela com o "X"
	oDlgFil:SetBackground(.T.)  // Escurece o fundo da janela
	oDlgFil:SetTitle(STR0003)   // "Filtro de Lançamentos"
	oDlgFil:CreateDialog()
	oDlgFil:AddOkButton({|| FWMsgRun(, {|| lFiltro := J176ATabTmp(lUpdate,{oSigla:GetValue(),;
	                                                                       oTipo:GetValue(),;
	                                                                       oDataIni:GetValue(),;
	                                                                       oDataFim:GetValue(),;
	                                                                       lStatus1,;
	                                                                       lStatus2,;
	                                                                       lStatus3,;
	                                                                       lStatus4,;
	                                                                       lStatus5})},;
	                                    STR0004, STR0005),; // "Aguarde" - "Executando Filtros..."
                        IIF(lFiltro, oDlgFil:oOwner:End(), .F.)})
	
	oDlgFil:AddCloseButton({|| lFiltro := .F., oDlgFil:oOwner:End()})

	oLayer:Init(oDlgFil:GetPanelMain(), .F.)
	oLayer:AddCollumn("MainColl", 100, .F.)
	oMainColl := oLayer:GetColPanel("MainColl")

	oSigla    := TJurPnlCampo():New(005, 010, 060, 022, oMainColl, STR0006, ("RD0_SIGLA"), {|| }, {|| },,,, "RD0ATV") // "Profissional"
	oSigla:SetValid({|| Empty(oSigla:GetValue()) .Or. ExistCpo("RD0", oSigla:GetValue(), 9)})
	// Se o usuário que estiver utilizando a rotina for Técnico, deverá visualizar somente seus próprios registros.
	// Por isso não terá permissão de alterar o campo de Profissional
	If lTecnico
		oSigla:SetValue(JurGetDados("RD0", 1, xFilial("RD0") + cPart, "RD0_SIGLA"))
	EndIf
	oSigla:oCampo:bWhen := {|| !lTecnico }

	oTipo     := TJurPnlCampo():New(005, 080, 060, 022, oMainColl, AllTrim(RetTitle("NYX_TPDESP")), ("NYX_TPDESP"), {|| }, {|| },,,,"NRHALL")
	oTipo:SetValid({|| Empty(oTipo:GetValue()) .Or. ExistCpo("NRH", oTipo:GetValue(), 1)})

	oDataIni  := TJurPnlCampo():New(035, 010, 060, 022, oMainColl, STR0007, ("NYX_DATAIM"), {|| }, {|| },,,,) // "Data Inicial"
	oDataIni:SetValid(bVldData)

	oDataFim  := TJurPnlCampo():New(035, 080, 060, 022, oMainColl, STR0008, ("NYX_DATAIM"), {|| }, {|| },,,,) // "Data Final"
	oDataFim:SetValid(bVldData)

	oGrpStatus := TGroup():New( 65, 10, 135, 80, STR0009, oMainColl, , , .T.)  // "Situação"
	oPnlStatus := TPanel():New( 73, 13, '', oGrpStatus,,,,,, 60, 60, .F., .F.)

	@ 005, 005 CHECKBOX oStatus1 VAR lStatus1 PROMPT JurInfBox("NYX_STATUS", "1", "1") Size 080, 008 PIXEL OF oPnlStatus // Inconsistência
	@ 016, 005 CHECKBOX oStatus2 VAR lStatus2 PROMPT JurInfBox("NYX_STATUS", "2", "1") Size 080, 008 PIXEL OF oPnlStatus // Não Revisado
	@ 027, 005 CHECKBOX oStatus3 VAR lStatus3 PROMPT JurInfBox("NYX_STATUS", "3", "1") Size 080, 008 PIXEL OF oPnlStatus // Revisado
	@ 038, 005 CHECKBOX oStatus4 VAR lStatus4 PROMPT JurInfBox("NYX_STATUS", "4", "1") Size 080, 008 PIXEL OF oPnlStatus // Revisado Auto
	@ 049, 005 CHECKBOX oStatus5 VAR lStatus5 PROMPT JurInfBox("NYX_STATUS", "5", "1") Size 080, 008 PIXEL OF oPnlStatus // Despesa Gerada

	oDlgFil:Activate()

Return (lFiltro)

//-------------------------------------------------------------------
/*/{Protheus.doc} J176ATabTmp
Cria tabela temporária para uso no MarkBrowse com lançamentos
do tarifador  respeitando os filtros

@param  lUpdate, logico, Se .T. informa que a execução do filtro
                         é por dentro do MarkBrowse
@param  aFiltros, array, Filtros digitados
            aFiltros[1], caracter, Sigla do Profissional
            aFiltros[2], caracter, Tipo do lançamento
            aFiltros[3], data    , Data inicial do lançamento
            aFiltros[4], data    , Data final do lançamento
            aFiltros[5], logico  , Satus de inconsitência
            aFiltros[6], logico  , Satus de não revisado
            aFiltros[7], logico  , Satus Revisado
            aFiltros[8], logico  , Satus Revisado automaticamente
            aFiltros[9], logico  , Satus Despesa gerada

@return lTempTab, logico, Se .T. criou a tabela temporária

@author Jonatas Martins / Jorge Martins
@since  18/06/2019
@Obs    As variáveis aTabTemp, oTabTemp e cAlsTemp são PRIVATE declaradas
        na função JURA176A no início do fonte
/*/
//-------------------------------------------------------------------
Static Function J176ATabTmp(lUpdate, aFiltros)
	Local cQryTmp    := J176AQuery(aFiltros)
	Local cTemp      := GetNextAlias()
	Local lOrdemQry  := .T.
	Local lShowMsg   := .F.
	Local lTempTab   := .F.
	Local lLojaAuto  := SuperGetMv("MV_JLOJAUT", .F., "2") == "1" //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
	Local cCpoIndex  := "NYX_FILIAL+NYX_CODARQ+NYX_COD"
	Local nTamIndex  := TamSX3("NYX_FILIAL")[1] + TamSX3("NYX_CODARQ")[1] + TamSX3("NYX_COD")[1]
	Local aIdxAdic   := {{"01", cCpoIndex, nTamIndex}}
	Local aCmpNotBrw := {"NYX_OK", "RECNO", "NYX_MOEDA", "NYX_TELEFO", "NYX_ESCR", "NYX_TAXA", "NYX_DATA", "NYX_INCONS"}
	Local aStruAdic  := {{"NYX_OK", "NYX_OK", "C", 1 , 0, "", ""          },;
	                     {"DESCR" , STR0010 , "C", 50, 0, "", "NYX_DESCR" },; // "Descrição"
	                     {"JUSTIF", STR0012 , "C", 50, 0, "", "NYX_JUSTIF"},; // "Justificativa"
	                     {"RECNO" , "RECNO" , "N", 20, 0, "", ""          }}

	If lLojaAuto
		AAdd(aCmpNotBrw, "NYX_CLOJA")
	EndIf

	DbUseArea(.T., 'TOPCONN', TcGenQry( , , cQryTmp), cTemp, .T., .F.)

	If (cTemp)->(EOF())
		JurMsgErro(STR0013,, STR0031) // "Não foram encontrados dados." - "Refaça o filtro."
	Else
		lTempTab := .T.

		If lUpdate
			cAlsTemp := oTabTemp:GetAlias() // Variável PRIVATE
			oTabTemp:Delete() // Variável PRIVATE
			oTabTemp := JurCriaTmp(cAlsTemp, cQryTmp, "NYX", aIdxAdic, aStruAdic, /*aCmpAcBrw*/,;
			aCmpNotBrw, lOrdemQry, /*lInsert*/, /*aTitCpoBrw*/, lShowMsg)[1]
			aTabTemp[1] := oTabTemp
			oMark176A:Refresh(.T.) // Variável PRIVATE
		Else
			cAlsTemp := GetNextAlias() // Variável PRIVATE
			aTabTemp := JurCriaTmp(cAlsTemp, cQryTmp, "NYX", aIdxAdic, aStruAdic, /*aCmpAcBrw*/,;
			                       aCmpNotBrw, lOrdemQry, /*lInsert*/, /*aTitCpoBrw*/, lShowMsg)
			oTabTemp := aTabTemp[1] // Variável PRIVATE
		EndIf

		J176AMemo() // Preenche campos MEMO do MarkBrowse
	EndIf

	(cTemp)->(DbCloseArea())

Return (lTempTab)

//-------------------------------------------------------------------
/*/{Protheus.doc} J176AQuery
Query que busca os dados de lançamentos do tarifador considerando
os filtros digitados pelo usuário

@param  aFiltros, array, Filtros digitados
        aFiltros[1], caracter, Sigla do Profissional
        aFiltros[2], caracter, Tipo do lançamento
        aFiltros[3], data    , Data inicial do lançamento
        aFiltros[4], data    , Data final do lançamento
        aFiltros[5], logico  , Status de inconsitência
        aFiltros[6], logico  , Status de não revisado
        aFiltros[7], logico  , Status Revisado
        aFiltros[8], logico  , Status Revisado automaticamente
        aFiltros[9], logico  , Status Despesa gerada

@return cQryTmp, caracter, Query com os filtros

@author Jonatas Martins / Jorge Martins
@since  18/06/2019
/*/
//-------------------------------------------------------------------
Static Function J176AQuery(aFiltros)
	Local cQryTmp  := ""
	Local cSigla   := aFiltros[1]
	Local cTipoDP  := aFiltros[2]
	Local cDataIni := DtoS(aFiltros[3])
	Local cDataFim := DtoS(aFiltros[4])
	Local cStatus1 := IIF(aFiltros[5], "'1',", "") // Inconsistência
	Local cStatus2 := IIF(aFiltros[6], "'2',", "") // Não Revisado
	Local cStatus3 := IIF(aFiltros[7], "'3',", "") // Revisado
	Local cStatus4 := IIF(aFiltros[8], "'4',", "") // Revisado Auto
	Local cStatus5 := IIF(aFiltros[9], "'5',", "") // Despesa Gerada
	Local cStatus  := cStatus1 + cStatus2 + cStatus3 + cStatus4 + cStatus5

	cStatus := Left(cStatus, Len(cStatus) - 1)

	cQryTmp :=      " SELECT ' ' NYX_OK, NYX_FILIAL, NYX_CODARQ, NYX_COD, NYX_DATA, NYX_STATUS, NYX_TPDESP, NYX_CCLIEN, NYX_CLOJA, NYX_CCASO, NYX_MOEDA, NYX_SIGLA, NYX_DATAIM, "
	cQryTmp +=              " NYX_HORAIM, NYX_QTDE, NYX_VALOR + (NYX_VALOR * (NYX_TAXA/100)) NYX_VALOR, NYX_RAMAL, NYX_TELEFO, NYX_DURTEL, NYX_ESCR, NYX_TAXA, ' ' DESCR, ' ' JUSTIF, R_E_C_N_O_ RECNO"
	cQryTmp +=        " FROM " + RetSqlName("NYX") + " NYX "
	cQryTmp +=       " WHERE NYX.NYX_FILIAL = '" + xFilial("NYX") + "'"

	If !Empty(cSigla)
		cQryTmp +=     " AND NYX.NYX_SIGLA = '" + cSigla + "'"
	EndIf

	If !Empty(cTipoDP)
		cQryTmp +=     " AND NYX.NYX_TPDESP = '" + cTipoDP + "'"
	EndIf

	If !Empty(cDataIni) .And. !Empty(cDataFim)
		cQryTmp +=     " AND NYX.NYX_DATAIM BETWEEN '" + cDataIni + "' AND '" + cDataFim + "'"
	ElseIf !Empty(cDataIni)
		cQryTmp +=     " AND NYX.NYX_DATAIM >= '" + cDataIni + "'"
	ElseIf !Empty(cDataFim)
		cQryTmp +=     " AND NYX.NYX_DATAIM <= '" + cDataFim + "'"
	EndIf

	If !Empty(cStatus)
		If Len(cStatus) == 3
			cQryTmp += " AND NYX.NYX_STATUS = " + cStatus
		Else
			cQryTmp += " AND NYX.NYX_STATUS IN (" + cStatus + ")"
		EndIf
	EndIf

	cQryTmp +=         " AND NYX.D_E_L_E_T_ = ' '"

Return (cQryTmp)

//-------------------------------------------------------------------
/*/{Protheus.doc} J176AMemo
Função para preencher campos MEMO na tabela temporária do MarkBrowse

@author  Jonatas Martins / Jorge Martins
@since   18/06/2019
@Obs     A variável cAlsTemp é PRIVATE declarada
         na função JURA176A no início do fonte
/*/
//-------------------------------------------------------------------
Static Function J176AMemo()
	Local aAreaNYX := NYX->(GetArea())

	While (cAlsTemp)->(! Eof())
		NYX->(DbGoTo((cAlsTemp)->RECNO))
		If NYX->(! Eof())
			RecLock(cAlsTemp, .F.)
			(cAlsTemp)->DESCR  := NYX->NYX_DESCR
			(cAlsTemp)->JUSTIF := NYX->NYX_JUSTIF
			(cAlsTemp)->(MsUnLock())
		EndIf
		(cAlsTemp)->(DbSkip())
	End

	(cAlsTemp)->(DbGoTop())
	RestArea(aAreaNYX)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J176AMark
Tela de seleção dos lançamentos do tarifador

@author Jonatas Martins / Jorge Martins
@since  18/06/2019
/*/
//-------------------------------------------------------------------
Static Function J176AMark()
	Local aFieldsFlt := {}
	Local aOrder     := {}
	Local aFieldsBrw := {}
	Local cStatus1   := JurInfBox("NYX_STATUS", "1", "1") // Inconsistência
	Local cStatus2   := JurInfBox("NYX_STATUS", "2", "1") // Não Revisado
	Local cStatus3   := JurInfBox("NYX_STATUS", "3", "1") // Revisado
	Local cStatus4   := JurInfBox("NYX_STATUS", "4", "1") // Revisado Auto
	Local cStatus5   := JurInfBox("NYX_STATUS", "5", "1") // Despesa Gerada
	Local bSeek      := {|oSeek| MySeek(oSeek, oMark176A:oBrowse)}

	//--------------------------------
	// Estrutura da tabela temporária
	//--------------------------------
	aFieldsFlt := aTabTemp[2] // Campos de filtro
	aOrder     := aTabTemp[3] // Indices da tabela
	aFieldsBrw := aTabTemp[4] // Campos do FWMBrowse

	oMark176A := FWMarkBrowse():New()
	oMark176A:SetAlias(cAlsTemp)
	oMark176A:SetTemporary(.T.)
	oMark176A:SetFields(aFieldsBrw)
	oMark176A:SetDescription(STR0014) //"Revisão de Tarifação"

	If Len(aTabTemp) >= 7 .And. !Empty(aTabTemp[7]) // Tratamento para LGPD verifica os campos que devem ser ofuscados
		oMark176A:oBrowse:SetObfuscFields(aTabTemp[7])
	EndIf

	oMark176A:DisableReport()
	oMark176A:oBrowse:SetDBFFilter(.T.)
	oMark176A:oBrowse:SetUseFilter()
	oMark176A:oBrowse:SetIniWindow({|| oMark176A:oBrowse:oData:SetSeekAction(bSeek)})
	oMark176A:oBrowse:SetSeek(.T., aOrder)
	oMark176A:oBrowse:SetFieldFilter(aFieldsFlt)
	oMark176A:oBrowse:bOnStartFilter := Nil
	oMark176A:SetMenuDef("JURA176A")
	oMark176A:SetLocate()
	oMark176A:SetFieldMark("NYX_OK")
	oMark176A:SetCustomMarkRec({|| J176ASetMk()})
	oMark176A:bAllMark := {|| JurMarkALL(oMark176A, cAlsTemp, "NYX_OK", lMarcar := !lMarcar, {|| J176AValMk(.F.)}, .F.), oMark176A:Refresh(.F.)}
	oMark176A:AddLegend("AllTrim(NYX_STATUS) == '1'", "RED"   , cStatus1) // Inconsistência
	oMark176A:AddLegend("AllTrim(NYX_STATUS) == '2'", "YELLOW", cStatus2) // Não Revisado
	oMark176A:AddLegend("AllTrim(NYX_STATUS) == '3'", "GREEN" , cStatus3) // Revisado
	oMark176A:AddLegend("AllTrim(NYX_STATUS) == '4'", "HGREEN", cStatus4) // Revisado Auto
	oMark176A:AddLegend("AllTrim(NYX_STATUS) == '5'", "BLUE"  , cStatus5) // Despesa Gerada
	JurSetBSize(oMark176A)
	oMark176A:Activate()

	JurFreeArr({aFieldsFlt, aOrder, aFieldsBrw})

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J176ASetMk
Função para executar após a marcação de um registro

@retorn lValido , Se pode marcar o proximo registro

@author Jonatas Martins / Jorge Martins
@since  18/06/2019
/*/
//-------------------------------------------------------------------
Static Function J176ASetMk()
	Local cMarca     := oMark176A:Mark()
	Local cDesMarca  := Space(1)
	Local lMarcando  := (cAlsTemp)->NYX_OK != cMarca // Verifica se estar marcando o registro
	Local lValido    := J176AValMK(.T.)
	
	If lValido 
		RecLock(cAlsTemp, .F.)
		(cAlsTemp)->NYX_OK := IIF(lMarcando, cMarca, cDesMarca)
		(cAlsTemp)->(MsUnlock())
	EndIf

Return (lValido)

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
menu de lançamentos do tarifador

@return aRotina, array, Opções do menu

@author Jonatas Martins / Jorge Martins
@since  18/06/2019
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}

	aAdd(aRotina, {STR0017, "J176AExec(.T.)"  , 0, 2, 0, NIL}) //"Visualizar"
	aAdd(aRotina, {STR0018, "J176AExec(.F.)"  , 0, 4, 0, NIL}) //"Revisar"
	aAdd(aRotina, {STR0019, "Processa({|| J176AGerDP()})", 0, 4, 0, NIL}) //"Gerar Despesa"
	aAdd(aRotina, {STR0038, "J176AMail()" , 0, 4, 0, NIL})  //"E-mail Pendências"
	aAdd(aRotina, {STR0020, "J176AFiltro(.T.)", 0, 4, 0, NIL})  //"Filtros"

Return (aRotina)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de lançamentos do tarifador

@return oView, objeto, View de dados

@author Jonatas Martins / Jorge Martins
@since  18/06/2019
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local bFieldNYX  := {|cField| J176AFields(cField)}
	Local oStructNYX := FWFormStruct(2, "NYX", bFieldNYX)
	Local oModel     := FWLoadModel("JURA176A")
	Local lLojaAuto  := SuperGetMv("MV_JLOJAUT", .F., "2") == "1" //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
	Local oView      := Nil

	If lLojaAuto
		oStructNYX:RemoveField("NYX_CLOJA")
	EndIf

	J176AAddCp(.F. /*lModel*/, @oStructNYX)

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("JURA176A_VIEW", oStructNYX, "NYXMASTER")
	oView:CreateHorizontalBox("FORMFIELD", 100)
	oView:SetOwnerView("JURA176A_VIEW", "FORMFIELD")
	oView:SetDescription(STR0021) //"Revisão de Lançamentos"
	oView:EnableControlBar(.T.)

Return (oView)

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de lançamentos do tarifador

@return oModel, objeto, Modelo de dados

@author Jonatas Martins / Jorge Martins
@since  18/06/2019
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	Local oCommit    := J176ACOMMIT():New()
	Local oStructNYX := FWFormStruct(1, "NYX")
	Local lLojaAuto  := SuperGetMv("MV_JLOJAUT", .F., "2") == "1" //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
	Local oModel     := NIL

	oStructNYX:SetProperty("NYX_CCLIEN", MODEL_FIELD_OBRIGAT, .T.)
	oStructNYX:SetProperty("NYX_CCASO" , MODEL_FIELD_OBRIGAT, .T.)

	If !lLojaAuto
		oStructNYX:SetProperty("NYX_CLOJA" , MODEL_FIELD_OBRIGAT, .T.)
	EndIf

	J176AAddCp(.T. /*lModel*/, @oStructNYX)

	J176AWhen(@oStructNYX)

	oModel:= MPFormModel():New( "JURA176A", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
	oModel:AddFields("NYXMASTER", NIL, oStructNYX, /*Pre-Validacao*/, /*Pos-Validacao*/ )
	oModel:SetDescription(STR0021) //"Revisão de Lançamentos"
	oModel:GetModel("NYXMASTER"):SetDescription(STR0021) //"Revisão de Lançamentos"
	oModel:SetPrimaryKey({"NYX_FILIAL", "NYX_COD", "NYX_CCLIEN", "NYX_CLOJA", "NYX_CCASO", "NYX_VALOR"})
	oModel:SetVldActivate({|oModel| J176AVldAct(oModel)})
	oModel:InstallEvent("J176ACOMMIT", /*cOwner*/, oCommit)

Return (oModel)

//-------------------------------------------------------------------
/*/{Protheus.doc} J176AFields
Avalia campos para utilizar na view

@param  cField, caracter, Campo que será avaliado

@return lField, logico  , Indica se o campo deve ser exibido na tela de revisão

@author Jonatas Martins / Jorge Martins
@since  18/06/2019
/*/
//-------------------------------------------------------------------
Static Function J176AFields(cField)
	Local lField    := .F.
	Local cCampos   := "NYX_STATUS|NYX_TPDESP|NYX_CCLIEN|NYX_CLOJA|NYX_CCASO|NYX_SIGLA|NYX_DATAIM|"+;
	                   "NYX_HORAIM|NYX_QTDE|NYX_VALOR|NYX_TAXA|NYX_RAMAL|NYX_DURTEL|NYX_DESCR|NYX_JUSTIF|NYX_INCONS"

	lField := AllTrim(cField) $ cCampos

Return (lField)

//-------------------------------------------------------------------
/*/{Protheus.doc} J176AGerDP
Executa a geração das despesas conforme lançamentos do tarifador

@author Anderson Carvalho / Bruno Ritter
@since  01/07/2019
/*/
//------------------------------------------------------------------
Function J176AGerDP()
	Local cAlsTmp    := oTabTemp:GetAlias()
	Local cNameTbTmp := oTabTemp:GetRealName()
	Local cMarca     := Iif(oMark176A:IsInvert(), " ", oMark176A:Mark())
	Local cQuery     := ""
	Local cCodDesp   := ""
	Local lIntFinanc := NYV->(ColumnPos("NYV_CNATUR")) > 0 .And. SuperGetMV("MV_JURXFIN",, .F.) //Habilita a integracao entre os modulos SIGAFIN - Financeiro e SIGAPFS - Juridico
	Local oModel     := Iif(lIntFinanc, FWLoadModel("JURA241"), FWLoadModel("JURA049"))
	Local nI         := 1
	Local nTotalMark := 0
	Local aMarcados  := {}
	Local aErroModel := {}
	Local cDescCdArq := AllTrim(RetTitle("NYX_CODARQ"))
	Local cDescCdSeq := AllTrim(RetTitle("NYX_COD"))
	Local cMemoLog   := ""
	
	cQuery    := " SELECT R_E_C_N_O_ FROM " + cNameTbTmp + " NYX "
	cQuery    += " WHERE NYX.NYX_FILIAL = '" + xFilial("NYX") + "' "
	cQuery    += "   AND NYX.NYX_OK = '" + cMarca +"' "
	cQuery    += "   AND NYX.D_E_L_E_T_ = ' ' "
	aMarcados := JurSQL(cQuery, {"R_E_C_N_O_"})

	If Empty(aMarcados)
		JurMsgErro(STR0036,,STR0037) // "Nenhum item foi selecionado." "Selecione um item para gerar a despesa."
	Else
		nTotalMark := Len(aMarcados)
		ProcRegua(nTotalMark)

		For nI := 1 To nTotalMark //Percorre todos os itens selecionados do MarkBrowser
			IncProc(I18N("Processando registro #1 de #2",{nI,nTotalMark} )) //"Processando registro #1 de #2"
			(cAlsTmp)->(DbGoto(aMarcados[nI][1]))
			NYX->(dbGoto((cAlsTmp)->RECNO))

			cCodDesp := J176AProDP(oModel, "NYX", @aErroModel, .T.)

			If Empty(aErroModel)
				RecLock("NYX",.F.)
				NYX->NYX_STATUS := '5'
				NYX->NYX_DESP   := cCodDesp
				NYX->(MsUnlock())

				RecLock(cAlsTmp,.F.)
				(cAlsTmp)->NYX_STATUS := '5'
				(cAlsTmp)->(MsUnlock())
				J176ASetMk()

			Else
				cMemoLog += cDescCdArq + ": " + (cAlsTmp)->NYX_CODARQ + CRLF
				cMemoLog += cDescCdSeq + ": " + (cAlsTmp)->NYX_COD + CRLF
				cMemoLog += STR0057 + " " + aErroModel[6] + CRLF // "Erro:"
				If !Empty(Replace(aErroModel[7], CHR(13)+CHR(10), ""))
					cMemoLog += STR0058 + " " + aErroModel[7] + CRLF // "Solução:"
				EndIf
				cMemoLog += Replicate('-',65) + CRLF
				AutoGrLog(cMemoLog)
				JurFreeArr(@aErroModel)
			EndIf
		Next nI

		JurSetLog(.T.)
		JurLogLote()

	EndIf
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J176AExec
Chamada para abertura de alteração dos dados de lançamentos via modelo

@author Jonatas Martins / Jorge Martins
@since  18/06/2019
/*/
//-------------------------------------------------------------------
Function J176AExec(lView)
	Local nRecno     := (cAlsTemp)->RECNO
	Local nOperation := IIF(lView, MODEL_OPERATION_VIEW, MODEL_OPERATION_UPDATE)
	Local nReduction := 50
	Local aButtons   := {{.F., Nil}, {.F., Nil}, {.F., Nil}, {.T., Nil}, {.T., Nil}, {.T., Nil}, {.T., STR0022},; //"Confirmar"
	                     {.T., STR0023}, {.T., Nil}, {.T., Nil}, {.T., Nil}, {.T., Nil}, {.T., Nil}, {.T., Nil}, {.F., Nil}} //"Fechar"

	NYX->(DbGoTo(nRecno))
	FWExecView(STR0021, "JURA176A", nOperation, , {|| .T.}, , nReduction, aButtons) // "Revisão de Lançamentos"

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J176AWhen
Bloqueia campos na edição do lançamento

@param  oStructNYX, objeto, Estrutura de campos do Model

@author Jonatas Martins / Jorge Martins
@since  18/06/2019
@obs    Variável oStructNYX passada como referência na função MODELDEF
/*/
//-------------------------------------------------------------------
Static Function J176AWhen(oStructNYX)
	Local cEditFld   := "NYX_CCLIEN|NYX_CLOJA|NYX_JUSTIF"
	Local cField     := ""
	Local cIgnoraFld := "NYX_SIGLA"
	Local aMFields   := oStructNYX:GetFields()
	Local aStruct    := {}
	Local nI         := 1

	For nI := 1 To Len(aMFields)
		aStruct := aMFields[nI]
		cField := AllTrim(aStruct[MODEL_FIELD_IDFIELD])
		
		IF(cField == "NYX_CCASO")
			aStruct[MODEL_FIELD_WHEN] := {|| J176ACasWh()}

		ElseIf cField $ cEditFld
			aStruct[MODEL_FIELD_WHEN] := {|| .T.}
			
		ElseIf !(cField $ cIgnoraFld)
			aStruct[MODEL_FIELD_WHEN] := {|| .F.}
		EndIf 
	Next nI
Return Nil

//-------------------------------------------------------------------
/*/ { Protheus.doc } J176AVldAct
Valida se o lançamento possui despesa gerada para permitir ou não a
alteração do registro

@param  oModel      , objeto, Estrutura do modelo de dados

@return lVldActivate, logico, Se .T. o registro pode ser alterado

@author Jonatas Martins / Jorge Martins
@since  21/06/2019
/*/
//-------------------------------------------------------------------
Static Function J176AVldAct(oModel)
	Local nOperation   := oModel:GetOperation()
	Local lVldActivate := .T.

	If nOperation == MODEL_OPERATION_UPDATE .And. NYX->NYX_STATUS == "5"
		JurMsgErro(STR0024,, STR0030) // "Esse lançamento já possui despesa gerada e não pode ser alterado!" - "Somente registros sem despesas podem ser revisados."
		lVldActivate := .F.
	EndIf

Return (lVldActivate)

//-------------------------------------------------------------------
/*/ { Protheus.doc } J176ACOMMIT
Classe interna implementando o FWModelEvent, para execução de função
durante o commit

@author Jonatas Martins / Jorge Martins
@since  21/06/2019
/*/
//-------------------------------------------------------------------
Class J176ACOMMIT FROM FWModelEvent
	Data cInconsist

	Method New()
	Method ModelPosVld()
	Method BeforeTTS()
	Method InTTS()
End Class

//-------------------------------------------------------------------
/*/{Protheus.doc} New()
Classe interna implementando o FWModelEvent, para execução de função
para inicializar o metodo.

@author Jonatas Martins / Jorge Martins
@since  21/06/2019
/*/
//-------------------------------------------------------------------
Method New() Class J176ACOMMIT
		Self:cInconsist := ""
	Return Nil

	//-------------------------------------------------------------------
	/*/{Protheus.doc} ModelPosVld()
	Classe interna implementando o FWModelEvent, para execução do metodo
	de pós validação do modelo de dados

	@param  oModel  , objeto  , Modelo de dados
	@param  cModelId, caracter, Id Modelo de dados (Ex: NYXMASTER)

	@return lPosValid, logico, Se .T. o modelo está válido e pronto para commit

	@author Jonatas Martins / Jorge Martins
	@since  21/06/2019
	/*/
//-------------------------------------------------------------------
Method ModelPosVld(oModel, cModelId) Class J176ACOMMIT
	Local lPosValid := .T.
	Local cErro     := ""
	Local cSolucao  := ""

	J176APosVld(oModel, @cErro, @cSolucao)

	If Empty(oModel:GetValue("NYXMASTER", "NYX_SIGLA")) .And. !Empty(cErro)
		lPosValid := .F.
	EndIf

	If !lPosValid
		JurMsgErro(cErro,, cSolucao)
	Else
		Self:cInconsist := Iif(Empty(cErro)    , "", STR0057 + " " + cErro + CRLF) // "Erro:"
		Self:cInconsist += Iif(Empty(cSolucao) , "", STR0058 + " " + cSolucao + CRLF) // "Solução:"
	EndIf

Return (lPosValid)

	//-------------------------------------------------------------------
	/*/{Protheus.doc} BeforeTTS()
	Classe interna implementando o FWModelEvent, para execução do metodo
	de alteração antes da transação.

	@param  oModel  , objeto  , Modelo de dados
	@param  cModelId, caracter, Id Modelo de dados (Ex: NYXMASTER)

	@author Jonatas Martins / Jorge Martins
	@since  21/06/2019
	/*/
//-------------------------------------------------------------------
Method BeforeTTS(oModel, cModelId) Class J176ACOMMIT
	J176AStatus(oModel, self:cInconsist)
Return Nil

	//-------------------------------------------------------------------
	/*/{Protheus.doc} InTTS()
	Classe interna implementando o FWModelEvent, para execução do metodo
	de alteração em transação.

	@param  oModel  , objeto  , Modelo de dados
	@param  cModelId, caracter, Id Modelo de dados (Ex: NYXMASTER)

	@author Jonatas Martins / Jorge Martins
	@since  21/06/2019
	/*/
//-------------------------------------------------------------------
Method InTTS(oModel, cModelId) Class J176ACOMMIT
	J176AUpdTmp()
Return Nil

//-------------------------------------------------------------------
/*/ { Protheus.doc } J176APosVld
Valida a justificativa do lançamento considerando as regras de cliente
do escritório e justificativa obrigatória (NUH_JUSAPR) e cliente, loja
e caso.

@param oModel    , Estrutura do modelo de dados
@param cErro     , Váriavel para retornar o erro
@param cSolucao  , Váriavel para retornar a solução do erro

@return lPosVld, lógico, Se .T. atende as regras

@author Jonatas Martins / Jorge Martins
@since  21/06/2019
/*/
//-------------------------------------------------------------------
Static Function J176APosVld(oModel, cErro, cSolucao)
	Local aAreaNVE   := NVE->(GetArea())
	Local oModelNYX  := oModel:GetModel("NYXMASTER")
	Local cCliEsc    := AvKey(SuperGetMV("MV_JURTS9", , "" ), "A1_COD")   // Informe o código do Cliente que representa o escritório.
	Local cLojEsc    := AvKey(SuperGetMV("MV_JURTS10", , "" ), "A1_LOJA") // Informe a Loja do Cliente que representa o escritório.
	Local cClient    := oModelNYX:GetValue("NYX_CCLIEN")
	Local cLoja      := oModelNYX:GetValue("NYX_CLOJA")
	Local lCliEscr   := (cCliEsc == cClient) .And. (cLojEsc == cLoja)
	Local lJustif    := JurGetDados("NUH", 1, xFilial("NUH") + cClient + cLoja, "NUH_JUSTAP") == "1" .Or. lCliEscr
	Local lJustOk    := IIF(lJustif, !Empty(oModelNYX:GetValue("NYX_JUSTIF")), .T.)
	Local lPosVld    := .T.
	Local oMdlLanc   := Nil
	Local aErroModel := {}
	Local lIntFinanc := NYV->(ColumnPos("NYV_CNATUR")) > 0 .And. SuperGetMV("MV_JURXFIN",, .F.) //Habilita a integracao entre os modulos SIGAFIN - Financeiro e SIGAPFS - Juridico

	NVE->(DbSetOrder(1)) // NVE_FILIAL + NVE_CCLIEN + NVE_LCLIEN + NVE_NUMCAS

	If !lJustOk
		cErro    := STR0025 // "Justificativa inválida!"
		cSolucao := STR0026 // "O preenchimento da justificativa é obrigatório."
		lPosVld  := .F.
	EndIf

	If lPosVld
		oMdlLanc := Iif(lIntFinanc, FWLoadModel("JURA241"), FWLoadModel("JURA049"))
		J176AProDP(oMdlLanc, oModelNYX, @aErroModel, .F., "5")

		If !Empty(aErroModel)
			cErro     := i18n(STR0063, {oMdlLanc:GetDescription()}) + CRLF // "Inconsistencia para gerar '#1'"
			If !Empty(aErroModel[4])
				cErro += STR0065 +" "+ Alltrim(RetTitle(aErroModel[4])) + " (" + aErroModel[4] + ") "  // "Campo:"
			EndIf
			cErro     += CRLF + CRLF + STR0064 +  CRLF // "Detalhes:"
			cErro     += aErroModel[6]
			cSolucao  := aErroModel[7]
			lPosVld   := .F.
			JurFreeArr(@aErroModel)
		EndIf
	EndIf

	RestArea(aAreaNVE)

Return (lPosVld)

//-------------------------------------------------------------------
/*/ { Protheus.doc } J176AStatus
Atualiza status do lançamento após validações do modelo

@param  oModel    , Estrutura do modelo de dados
@param  cInconsist, Mesangem de inconstência quando existe uma.

@author Jonatas Martins / Jorge Martins
@since  21/06/2019
/*/
//-------------------------------------------------------------------
Static Function J176AStatus(oModel, cInconsist)
	Local cStatus := Iif(Empty(cInconsist), "3" /*Revisado*/, "1" /*Inconsistência*/)

	oModel:LoadValue("NYXMASTER", "NYX_STATUS", cStatus)
	
	If NYX->(ColumnPos("NYX_INCONS"))
		oModel:LoadValue("NYXMASTER", "NYX_INCONS", cInconsist)
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/ { Protheus.doc } J176AUpdTmp
Atualiza informações da tabela temporária utilizada no MarkBrowse

@return lUpdTmp, logico, Indica se a tabela temporária foi atualiza 
                         corretamente

@author Jonatas Martins / Jorge Martins
@since  21/06/2019
/*/
//-------------------------------------------------------------------
Static Function J176AUpdTmp()
	Local aArea    := (cAlsTemp)->(GetArea())
	Local cChave   := NYX->NYX_FILIAL + NYX->NYX_CODARQ + NYX->NYX_COD
	Local lUpdTmp  := .T.

	(cAlsTemp)->(DbSetOrder(1)) // NYX_CODARQ + NYX_COD
	If (cAlsTemp)->(DbSeek(cChave))
		RecLock(cAlsTemp, .F.)
		(cAlsTemp)->NYX_STATUS := NYX->NYX_STATUS
		(cAlsTemp)->NYX_CCLIEN := NYX->NYX_CCLIEN
		(cAlsTemp)->NYX_CLOJA  := NYX->NYX_CLOJA
		(cAlsTemp)->NYX_CCASO  := NYX->NYX_CCASO
		(cAlsTemp)->NYX_SIGLA  := NYX->NYX_SIGLA
		(cAlsTemp)->JUSTIF     := NYX->NYX_JUSTIF
		(cAlsTemp)->(MsUnLock())
	Else
		JurMsgErro(STR0029) // "Falha na atualização do lançamento!"
		lUpdTmp := .F.
	EndIf

	oMark176A:Refresh(.F.)

	RestArea(aArea)

Return (lUpdTmp)

//-------------------------------------------------------------------
/*/{Protheus.doc} J176AAddCp
Inclui campos no model e view através da função AddField

@param lModel  , Se .T. incluir campo no Modelo, .F. inclui na View
@param oStruct , Estrutura de dados do Model/View

@author Jonatas Martins / Jorge Martins
@since  24/06/2019
/*/
//-------------------------------------------------------------------
Static Function J176AAddCp(lModel, oStruct)
	Local cOrdem1   := Soma1(GetSx3Cache("NYX_VALOR" , "X3_ORDEM"))
	Local cOrdem2   := Soma1(GetSx3Cache("NYX_TPDESP", "X3_ORDEM"))
	Local aTam1     := TamSx3("NYX_VALOR")
	Local aTam2     := TamSx3("NRH_DESC")
	Local bInitCpo1 := {|| NYX->NYX_VALOR + (NYX->NYX_VALOR * (NYX->NYX_TAXA/100))}
	Local bInitCpo2 := {|| JurGetDados("NRH", 1, XFILIAL("NRH") + NYX->NYX_TPDESP, "NRH_DESC")}
	Local cPict     := PesqPict("NYX", "NYX_VALOR")
	Local aLgpd     := {}

	If lModel

		oStruct:AddField( ;
		STR0032         , ; // [01] Titulo do campo // "Valor Total Desp."
		STR0033         , ; // [02] ToolTip do campo // "Valor Total de Despesa (Valor da despesa com a taxa administrativa)"
		"NYX__VLTOT"    , ; // [03] Id do Field
		aTam1[3]        , ; // [04] Tipo do campo
		aTam1[1]        , ; // [05] Tamanho do campo
		aTam1[2]        , ; // [06] Decimal do campo
		                , ; // [07] Code-block de validação do campo
		                , ; // [08] Code-block de validação When do campo
		                , ; // [09] Lista de valores permitido do campo
		.F.             , ; // [10] Indica se o campo tem preenchimento obrigatório
		bInitCpo1       , ; // [11] Bloco de código de inicializacao do campo
		                , ; // [12] Indica se trata-se de um campo chave
		                , ; // [13] Indica se o campo não pode receber valor em uma operação de update
		.T.               ) // [14] Indica se o campo é virtual

		oStruct:AddField( ;
		STR0034         , ; // [01] Titulo do campo  // "Desc. Tipo Desp."
		STR0035         , ; // [02] ToolTip do campo // "Descrição do Tipo da Despesa"
		"NYX__DTPDP"    , ; // [03] Id do Field
		aTam2[3]        , ; // [04] Tipo do campo
		aTam2[1]        , ; // [05] Tamanho do campo
		aTam2[2]        , ; // [06] Decimal do campo
		                , ; // [07] Code-block de validação do campo
		                , ; // [08] Code-block de validação When do campo
		                , ; // [09] Lista de valores permitido do campo
		.F.             , ; // [10] Indica se o campo tem preenchimento obrigatório
		bInitCpo2       , ; // [11] Bloco de código de inicializacao do campo
		                , ; // [12] Indica se trata-se de um campo chave
		                , ; // [13] Indica se o campo não pode receber valor em uma operação de update
		.T.               ) // [14] Indica se o campo é virtual

	Else

		oStruct:AddField( ;
		"NYX__VLTOT"    , ; // [01] Campo
		cOrdem1         , ; // [02] Ordem
		STR0032         , ; // [03] Titulo // "Valor Total Desp."
		STR0033         , ; // [04] Descricao // "Valor Total de Despesa (Valor da despesa com a taxa administrativa)"
		                , ; // [05] Help
		"GET"           , ; // [06] Tipo do campo   COMBO, Get ou CHECK
		cPict           , ; // [07] Picture
		                , ; // [08] PictVar
		                , ; // [09] F3
		.F.             , ; // [10] When
		                , ; // [11] Folder
		                , ; // [12] Group
		                , ; // [13] Lista Combo
		                , ; // [14] Tam Max Combo
		                , ; // [15] Inic. Browse
		.T.             )   // [16] Virtual

		oStruct:AddField( ;
		"NYX__DTPDP"    , ; // [01] Campo
		cOrdem2         , ; // [02] Ordem
		STR0034         , ; // [03] Titulo // "Desc. Tipo Desp."
		STR0035         , ; // [04] Descricao // "Descrição do Tipo da Despesa"
		                , ; // [05] Help
		"GET"           , ; // [06] Tipo do campo   COMBO, Get ou CHECK
		                , ; // [07] Picture
		                , ; // [08] PictVar
		                , ; // [09] F3
		.F.             , ; // [10] When
		                , ; // [11] Folder
		                , ; // [12] Group
		                , ; // [13] Lista Combo
		                , ; // [14] Tam Max Combo
		                , ; // [15] Inic. Browse
		.T.             )   // [16] Virtual

		aAdd(aLgpd, {"NYX__VLTOT", "NYX_VALOR"})
		aAdd(aLgpd, {"NYX__DTPDP", "NRH_DESC" })
		
		If FindFunction("JPDOfusca")
			JPDOfusca(@oStruct, aLgpd)
		EndIf

	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J176ACasWh
Função usada para carregar a propriedade WHEN do campo de caso.

@return lRet, .T./.F. O campo ficará disponível ou não

@author Jorge Martins
@since  25/06/2019
/*/
//-------------------------------------------------------------------
Static Function J176ACasWh()
	Local lRet      := .T.
	Local oModel    := FWModelActive()
	Local lLojaAuto := SuperGetMv("MV_JLOJAUT", .F., "2") == "1" // Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
	Local lCasoCli  := SuperGetMV("MV_JCASO1" ,    , "1") == "1" // Caso por Cliente

	If lCasoCli
		If lLojaAuto
			If Empty(oModel:GetValue("NYXMASTER", "NYX_CCLIEN"))
				lRet := .F.
			EndIf
		Else
			If Empty(oModel:GetValue("NYXMASTER", "NYX_CCLIEN")) .Or. Empty(oModel:GetValue("NYXMASTER", "NYX_CLOJA"))
				lRet := .F.
			EndIf
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J176AClxCa()
Rotina para verificar se o cliente/loja pertece ao caso.
Utilizado para condição de gatilho

@Return - lRet  .T. quando o cliente PERTENCE ao caso informado OU
                .F. quando o cliente NÃO pertence ao caso informado

@author Jorge Martins
@since  25/06/2019
/*/
//-------------------------------------------------------------------
Function J176AClxCa()
Local lRet      := .F.
Local oModel    := FWModelActive()
Local cClien    := ""
Local cLoja     := ""
Local cCaso     := ""

cClien := oModel:GetValue("NYXMASTER", "NYX_CCLIEN")
cLoja  := oModel:GetValue("NYXMASTER", "NYX_CLOJA")
cCaso  := oModel:GetValue("NYXMASTER", "NYX_CCASO")

lRet := JurClxCa(cClien, cLoja, cCaso)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J176TARIFA()
Rotina para a configuração do Tarifador Ativa

@Return - cConfTarif   Retorna o código da Configuração ativa

@author Anderson Carvalho \ Bruno Ritter
@since  01/07/2019
/*/
//-------------------------------------------------------------------
Static Function J176TARIFA()
	Local cConfTarif := ""
	Local cQueryNYT  := ""
	Local cResNYT    := GetNextAlias()

	cQueryNYT := "SELECT NYT.NYT_COD "
	cQueryNYT += "  FROM " + RetSqlName("NYT") + " NYT "
	cQueryNYT +=  "WHERE NYT.NYT_FILIAL = '"+xFilial("NYT")+"'"
	cQueryNYT += " AND NYT.NYT_ATIVO  = '1'"
	cQueryNYT += " AND NYT.D_E_L_E_T_ = ' '"

	cQueryNYT := ChangeQuery(cQueryNYT)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryNYT),cResNYT,.T.,.T.)
	If (cResNYT)->(! EOF())
		cConfTarif := (cResNYT)->NYT_COD
	EndIf
	(cResNYT)->(DbCloseArea())

Return cConfTarif

//-------------------------------------------------------------------
/*/{Protheus.doc} J176ASetMk
Função para validar a marcação de cada regsitro

@param lExibeMsg, Se exibe mensagem de erro

@retorn lValido , Se pode marcar o proximo registro

@author Anderson Carvalho / Bruno Ritter
@since  03/07/2019
/*/
//-------------------------------------------------------------------
Static Function J176AValMk(lExibeMsg)
	Local cMarca     := oMark176A:Mark()
	Local cStatus    := AllTrim((cAlsTemp)->NYX_STATUS)
	Local lMarcando  := (cAlsTemp)->NYX_OK != cMarca // Verifica se estar marcando o registro
	Local lValido    := .T.
	Local lIntFinanc := NYV->(ColumnPos("NYV_CNATUR")) > 0 .And. SuperGetMV("MV_JURXFIN",, .F.) //Habilita a integracao entre os modulos SIGAFIN - Financeiro e SIGAPFS - Juridico
	Local cConfTarif := J176TarifA()
	Local nTamSigla  := TamSX3("NVY_SIGLA")[1]
	Local lTPDesp    := ExistCpo("NYV", cConfTarif + (cAlsTemp)->NYX_TPDESP, 1,,.F.)
	Local cSigla     := Left((cAlsTemp)->NYX_SIGLA, nTamSigla)//Proteção devido o campo NYX_SIGLA estar com o tamanho errado.
	Local cCodPart   := JurGetDados('RD0', 9, xFilial('RD0') + cSigla, 'RD0_CODIGO')
	Local cInfoBox   := ""
	Local cMsgErro   := ""

	If lMarcando
		If cStatus == "5" .Or. (!lIntFinanc .And. cStatus $ "1|2")
			cInfoBox := JurInfBox("NYX_STATUS", cStatus, "1")
			cMsgErro := I18N(STR0059, {cInfoBox}) // "Lançamentos com a situação '#1' não podem ser marcados!"
			lValido := .F.
		EndIf

		If lValido .And. Empty(cConfTarif)
			cMsgErro := STR0060 // "Não existe nenhuma configuração de tarifador Ativo"
			lValido := .F.
		EndIf

		If lValido .And. !lTPDesp
			cMsgErro := I18N(STR0061, {(cAlsTemp)->NYX_TPDESP, cConfTarif}) //  "Tipo de despesa (#1) não existe na configuração do tarifador Ativo (#2)"
			lValido := .F.
		EndIf

		If lValido .And. Empty(cCodPart) .And. (cStatus == "1" .Or. cStatus == "2")
			cMsgErro := STR0062 // "Necessário identificar o Participante para gerar um débito pessoal"
			lValido := .F.
		EndIf
	EndIf
	
	If (lExibeMsg) .And. !Empty(cMsgErro)
		JurMsgErro(STR0015,,cMsgErro)
	EndIf

Return (lValido)

//-------------------------------------------------------------------
/*/{Protheus.doc} J176AVlCas
Validação do campo: Caso

@Return   lRet  .T. ou .F.

@author Anderson Carvalho \ Bruno Ritter
@since 03/07/2019
/*/
//-------------------------------------------------------------------
Function J176AVlCas()
	Local lRet     := .T.
	Local oModel   := FWModelActive()
	Local cCliente := oModel:GetValue("NYXMASTER", "NYX_CCLIEN")
	Local cLoja    := oModel:GetValue("NYXMASTER", "NYX_CLOJA")
	Local cCaso    := oModel:GetValue("NYXMASTER", "NYX_CCASO")
	Local dDataLC  := oModel:GetValue("NYXMASTER", "NYX_DATA")
	
	lRet := JurVldCli("", cCliente, cLoja, Ccaso,"NVE_LANDSP", "CAS",,, dDataLC)  

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J176AWSigl
Validação para retornar se o usuário logado não é técnico

@Obs      Utilizado no When da SIGLA (NYX_SIGLA)
@Return   lRet  .T. ou .F.

@author Anderson Carvalho \ Bruno Ritter
@since 03/07/2019
/*/
//-------------------------------------------------------------------
Function J176AWSigl()
	Local cPart  := JurUsuario(__CUSERID)
	Local lRet   := JurGetDados("NUR", 1, xFilial("NUR") + cPart, "NUR_TECNIC") == '2'
	
Return lRet

//-------------------------------------------------------------------
/*/ { Protheus.doc } J176AProDP
Gera ou simula o lançamento/despesa com os dados posicionados do Alias "cAls"

@param  oModel    , Modelo da NVY ou OHB conforme o parametro MV_Jurxfin
@param  xOrigDados, Alias ou modelo com a origem dos dados
@param  aErroModel, Array para passar como Referencia para receber o erro do modelo
@param  lCommit   , Se vai comitar
@param  cFoceStatu, Ignora a Status da NYX posicionada e utiliza o que foi passado

@return cDesp, Código da despesa que foi gerado
               para gerar deve passar o lCommit = .T.

@author Bruno Ritter / Anderson Carvalho
@since  04/07/2019
/*/
//-------------------------------------------------------------------
Static Function J176AProDP(oModel, xOrigDados, aErroModel, lCommit, cFoceStatu)
	Local cCodPart   := ""
	Local cConfTarif := J176TARIFA()
	Local cNaturOri  := ""
	Local cCodDesp   := ""
	Local cPartDbtP  := ""
	Local lIntFinanc := NYV->(ColumnPos("NYV_CNATUR")) > 0 .And. SuperGetMV("MV_JURXFIN",, .F.) //Habilita a integracao entre os modulos SIGAFIN - Financeiro e SIGAPFS - Juridico
	Local aDados     := Array(17)
	Local lIsModel   := ValType(xOrigDados) == "O"
	Local cTpDesp    := Iif(lIsModel, xOrigDados:GetValue("NYX_TPDESP"), (xOrigDados)->NYX_TPDESP)
	Local cStatus    := Iif(lIsModel, xOrigDados:GetValue("NYX_STATUS"), (xOrigDados)->NYX_STATUS)
	Local cSigla     := Iif(lIsModel, xOrigDados:GetValue("NYX_SIGLA") , (xOrigDados)->NYX_SIGLA)
	Local cTaxa      := Iif(lIsModel, xOrigDados:GetValue("NYX_TAXA")  , (xOrigDados)->NYX_TAXA)

	cNaturOri := JurGetDados("NYV", 1, xFilial("NVY") + cConfTarif + cTpDesp, "NYV_CNATUR")
	cStatus   := Iif(Empty(cFoceStatu), AllTrim(cStatus), cFoceStatu)
	cSigla    := Left(cSigla, TamSX3("NVY_SIGLA")[1])//Proteção devido o campo NYX_SIGLA estar com o tamanho errado.
	cCodPart  := JurGetDados('RD0', 9, xFilial('RD0') + cSigla, 'RD0_CODIGO')
	cPartDbtP := Iif(cStatus $ "1|2", cCodPart, "")

	aDados[1]  := Iif(lIsModel, xOrigDados:GetValue("NYX_CCLIEN"), (xOrigDados)->NYX_CCLIEN)
	aDados[2]  := Iif(lIsModel, xOrigDados:GetValue("NYX_CLOJA") , (xOrigDados)->NYX_CLOJA)
	aDados[3]  := Iif(lIsModel, xOrigDados:GetValue("NYX_CCASO") , (xOrigDados)->NYX_CCASO)
	aDados[4]  := Iif(lIsModel, xOrigDados:GetValue("NYX_MOEDA") , (xOrigDados)->NYX_MOEDA)
	aDados[5]  := Iif(lIsModel, xOrigDados:GetValue("NYX_VALOR") , (xOrigDados)->NYX_VALOR)
	aDados[6]  := cTpDesp
	aDados[7]  := Iif(lIsModel, xOrigDados:GetValue("NYX_QTDE")  , (xOrigDados)->NYX_QTDE)
	aDados[8]  := cSigla
	aDados[9]  := Iif(lIsModel, xOrigDados:GetValue("NYX_DESCR") , (xOrigDados)->NYX_DESCR)
	aDados[10] := cCodPart
	aDados[11] := Iif(lIsModel, xOrigDados:GetValue("NYX_RAMAL") , (xOrigDados)->NYX_RAMAL)
	aDados[12] := Iif(lIsModel, xOrigDados:GetValue("NYX_TELEFO"), (xOrigDados)->NYX_TELEFO)
	aDados[13] := Iif(lIsModel, xOrigDados:GetValue("NYX_DURTEL"), (xOrigDados)->NYX_DURTEL)
	aDados[14] := Iif(lIsModel, xOrigDados:GetValue("NYX_ESCR")  , (xOrigDados)->NYX_ESCR)
	aDados[15] := cTaxa
	aDados[16] := Iif(lIsModel, xOrigDados:GetValue("NYX_DESCR") , (xOrigDados)->NYX_DESCR)
	aDados[17] := Iif(lIsModel, xOrigDados:GetValue("NYX_DATA")  , (xOrigDados)->NYX_DATA)

	If lIntFinanc
		cCodDesp := J175GeLanc(@oModel, aDados, cNaturOri, cTaxa, @aErroModel, cPartDbtP, lCommit)
	Else
		cCodDesp := J175GeDesp(@oModel, aDados, cTaxa, @aErroModel, lCommit)
	EndIf

	JurFreeArr(@aDados)
Return cCodDesp

//-------------------------------------------------------------------
/*/{Protheus.doc} J176ASMail()
Rotina para envio de e-mails via Schedule com as pendências de aprovação do Tarifador.

@param aParam, Configurações
               aParam[1] - Configuração do Servidor (NR7)
               aParam[2] - Configuração do Usuário  (NR8)
               aParam[3] - Configuração de Envio    (NRU)

@return lRet , Indica o sucesso da execução

@author Cristina Cintra / Jorge Martins
@since  01/07/2019
/*/
//-------------------------------------------------------------------
Function J176ASMail(aParam)
	Local lRet       := .T.
	Local lSchedule  := .T.
	Local cCfgSrv    := ""
	Local cCfgUsrSrv := ""
	Local cCfgEnv    := ""
	Local cEmp       := ""
	Local cFil       := ""
	Local cUser      := ""

	If !Empty(aParam) .And. Len(aParam) >= 7
		cCfgSrv    := aParam[1]
		cCfgUsrSrv := aParam[2]
		cCfgEnv    := aParam[3]
		cEmp       := aParam[4]
		cFil       := aParam[5]
		cUser      := aParam[6]

		If (Empty(cCfgSrv) .Or. Empty(cCfgUsrSrv) .Or. Empty(cCfgEnv))
			lRet := .F.
			JurMsgErro(STR0039) // "A execução via schedule necessita do envio dos parâmetros de envio de e-mail. Ajustar a chamada informando a configuração do servidor de e-mail e de envio."
		Else
			RPCSetType(3) // Prepara o ambiente e não consome licença
			RPCSetEnv(cEmp, cFil, , , , "J176ASMail")
			__cUserID := cUser

			If !ExistCpo("NR7", cCfgSrv, 1) .Or. !ExistCpo("NR8", cCfgUsrSrv, 1) .Or. !ExistCpo("NRU", cCfgEnv, 1)
				lRet := .F.
				JurMsgErro(STR0040) // "Existe inconsistência nos parâmetros enviados. Verifique e indique os códigos corretos para execução."
			EndIf
		EndIf

		If lRet
			J176ASend(lSchedule, cCfgSrv, cCfgUsrSrv, cCfgEnv)
		EndIf
	Else
		lRet := .F.
		JurMsgErro(STR0055) // "Para a execução são esperados três parâmetros referentes a configuração do envio. Verifique."
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J176AMail()
Rotina para preparo e chamada do envio de e-mails com as pendências 
de aprovação do Tarifador.

@return lRet  .T. Envio dos e-mails
              .F. Problemas no envio ou sem permissão

@author Cristina Cintra / Jorge Martins
@since  01/07/2019
/*/
//-------------------------------------------------------------------
Function J176AMail()
Local lRet       := .T.
Local lOk        := .T.
Local aConfig    := {}
Local cCfgSrv    := ""
Local cCfgUsrSrv := ""
Local cCfgEnv    := ""

	If JurGetDados("NUR", 1, xFilial("NUR") + JurUsuario(__CUSERID), "NUR_TECNIC") == '2' // Participantes com campo Técnico = "Não"

		aConfig    := J176ACfgMl()
		lOk        := aConfig[1][1] // Indica se clicou no botão "Confirmar"
		cCfgSrv    := aConfig[1][2]
		cCfgUsrSrv := aConfig[1][3]
		cCfgEnv    := aConfig[1][4]
		
		If lOk
			If (Empty(cCfgSrv) .Or. Empty(cCfgUsrSrv) .Or. Empty(cCfgEnv))
				lRet := .F.
				JurMsgErro(STR0043,, STR0044) // "Necessário o preenchimento das configurações para envio de e-mail." # "Preencha corretamente as informações."
			EndIf
		Else
			lRet := .F.
		EndIf

		If lRet
			FWMsgRun(Nil, { || lRet := J176ASend(.F., cCfgSrv, cCfgUsrSrv, cCfgEnv)}, STR0004, STR0056) // Aguarde - "Enviando E-mail(s)"
		EndIf

	Else
		lRet := JurMsgErro(STR0067,, STR0068) // "Operação não permitida." - "O uso da opção 'E-mail Pendências' não é permitida para participantes com perfil técnico."
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J176AQry()
Executa query para retorno dos registros que possuem pendências de 
aprovação (inconsistentes e não revisados).

@Return aRegs  Array com os registros retornados pela query

@author Cristina Cintra / Jorge Martins
@since  01/07/2019
/*/
//-------------------------------------------------------------------
Static Function J176AQry()
	Local aRegs  := {}
	Local cQuery := ""

	cQuery := " SELECT DISTINCT RD0.RD0_EMAIL "
	cQuery +=   " FROM " + RetSqlName("NYX") + " NYX "
	cQuery +=  " INNER JOIN " + RetSqlName("RD0") + " RD0 "
	cQuery +=     " ON RD0.RD0_FILIAL = '" + xFilial("RD0") + "' "
	cQuery +=    " AND RD0.RD0_SIGLA = NYX.NYX_SIGLA "
	cQuery +=    " AND RD0.D_E_L_E_T_ = ' ' "
	cQuery +=  " WHERE NYX.NYX_FILIAL = '" + xFilial("NYX") + "' "
	cQuery +=    " AND NYX.NYX_STATUS IN ('1', '2') "
	cQuery +=    " AND NYX.D_E_L_E_T_ = ' ' "

	aRegs := JurSQL(cQuery, {"RD0_EMAIL"})

Return aRegs

//-------------------------------------------------------------------
/*/{Protheus.doc} J176ACfgMl()
Abre tela para informar a configuração de servidor e de envio de e-mail.

@Return aInfo  Array com a configuração do servidor e de envio

@author Cristina Cintra
@since  01/07/2019
/*/
//-------------------------------------------------------------------
Static Function J176ACfgMl()
Local aInfo        := {}
Local oLayer       := FWLayer():New()
Local oMainColl    := Nil
Local aCposLGPD     := {}
Local aNoAccLGPD    := {}
Local aDisabLGPD    := {}

Private oDlg       := Nil
Private oTGetCodSe := Nil
Private oTGetDescS := Nil
Private oTGetCodUs := Nil
Private oTGetDesUs := Nil
Private oTGetConf  := Nil
Private oTGetConfD := Nil

oDlg := FWDialogModal():New()
oDlg:SetFreeArea(177, 100)
oDlg:SetEscClose(.F.)    // Não permite fechar a tela com o ESC
oDlg:SetCloseButton(.F.) // Não permite fechar a tela com o "X"
oDlg:SetBackground(.T.)  // Escurece o fundo da janela
oDlg:SetTitle(STR0051)   // "Configurações de Envio de E-mail - Pendências"
oDlg:CreateDialog()
oDlg:addOkButton({|| J176AVDlg(@aInfo) })
oDlg:addCloseButton({|| aInfo := {{.F.,"","",""}}, oDlg:oOwner:End()})

oLayer:init(oDlg:GetPanelMain(), .F.) //Inicializa o FWLayer com a janela que ele pertencera e se sera exibido o botao de fechar
oLayer:AddCollumn("MainColl", 100, .F.) //Cria as colunas do Layer
oMainColl := oLayer:GetColPanel("MainColl")

If _lFwPDCanUse .And. FwPDCanUse(.T.)
	aCposLGPD := {"NR7_DESC","NR8_DESC", "NRU_DESC" }

	aDisabLGPD := FwProtectedDataUtil():UsrNoAccessFieldsInList(aCposLGPD)
	AEval(aDisabLGPD, {|x| AAdd( aNoAccLGPD, x:CFIELD)})

EndIf

oTGetCodSe := TJurPnlCampo():New(05, 10, 050, 22, oMainColl, STR0045, "NR7_COD" , {|| }, {|| },,,, "NR7") // "Config. Serv" ### "Codigo de Configuração do Servidor"
oTGetDescS := TJurPnlCampo():New(05, 70, 100, 22, oMainColl, STR0046, "NR7_DESC", {|| }, {|| },,,,,,,,,aScan(aNoAccLGPD,"NR7_DESC") > 0)       // "Desc. Serv"   ### "Descrição da Configuração do Servidor"

oTGetCodUs := TJurPnlCampo():New(35, 10, 050, 22, oMainColl, STR0047, "NR8_COD" , {|| }, {|| },,,, "NR8") // "Cód. Usuário" ### "Codigo do Usuário de Configuração do Servidor"
oTGetDesUs := TJurPnlCampo():New(35, 70, 100, 22, oMainColl, STR0048, "NR8_DESC", {|| }, {|| },,,,,,,,,aScan(aNoAccLGPD,"NR8_DESC") > 0)       // "Nome Usuário" ### "Nome do Usuário de Configuração do Servidor"

oTGetConf  := TJurPnlCampo():New(65, 10, 050, 22, oMainColl, STR0049, "NRU_COD" , {|| }, {|| },,,, "NRU") // "Config. E-Mail"
oTGetConfD := TJurPnlCampo():New(65, 70, 100, 22, oMainColl, STR0050, "NRU_DESC",,,,, .T.,,,,,,aScan(aNoAccLGPD,"NRU_DESC") > 0)               // "Desc. Config. E-Mail"

oTGetDescS:SetWhen({||.F.})
oTGetDesUs:SetWhen({||.F.})
oTGetConfD:SetWhen({||.F.})
oTGetCodUs:SetWhen({|| !Empty(oTGetCodSe:GetValue()) })

oTGetCodSe:oCampo:bValid := {|| J204VldSrv("NR7_COD")}
oTGetCodUs:oCampo:bValid := {|| J204VldSrv("NR8_COD")}
oTGetConf:oCampo:bValid  := {|| J204VldSrv("NRU_COD"), oTGetConfD:Valor := JurGetDados("NRU", 1, xFilial("NRU") + oTGetConf:Valor, "NRU_DESC")}

oDlg:Activate()

Return aInfo

//-------------------------------------------------------------------
/*/{Protheus.doc} J176AVDlg()
Valida as informações da Dialog de Configuração de Envio de E-mail.

@param  aInfo  Array que será preenchido com as informações dos GETs
               (passado por referência).

@return aInfo  Array com as informações dos GETs.

@obs    oTGetCodSe, oTGetCodUs e oTGetConf são Privates criadas na função
        J176ACfgMl

@author Cristina Cintra
@since  01/07/2019
/*/
//-------------------------------------------------------------------
Static Function J176AVDlg(aInfo)

	If !Empty(oTGetCodSe:GetValue()) .And. !Empty(oTGetCodUs:GetValue()) .And. !Empty(oTGetConf:GetValue())
		aAdd(aInfo, {.T., oTGetCodSe:GetValue(), oTGetCodUs:GetValue(), oTGetConf:GetValue()})
		oDlg:oOwner:End()
	Else
		JurMsgErro(STR0052,, STR0053) // "Necessário preencher todas as informações para realizar o envio de e-mails." # "Preencha todas as informações para realizar o envio dos e-mails com as pendências."
	EndIf

Return aInfo

//-------------------------------------------------------------------
/*/{Protheus.doc} J176ASend()
Rotina para envio de e-mails com as pendências de aprovação do Tarifador.

@param lSchedule , Indica se a chamada veio do Schedule
@param cCfgSrv   , Configuração do Servidor (NR7)
@param cCfgUsrSrv, Configuração do Usuário  (NR8)
@param cCfgEnv   , Configuração de Envio    (NRU)

@return lRet  .T. Envio dos e-mails
              .F. Problemas no envio ou sem permissão

@author Cristina Cintra / Jorge Martins
@since  01/07/2019
/*/
//-------------------------------------------------------------------
Static Function J176ASend(lSchedule, cCfgSrv, cCfgUsrSrv, cCfgEnv)
Local lRet         := .T.
Local lEnvia       := .F.
Local aRegs        := {}
Local aDadosNR7    := {}
Local aDadosNR8    := {}
Local aDadosNRU    := {}
Local aCCO         := {}
Local nI           := 0
Local nLimCCO      := 20 // Número máximo de destinatários na sessão de cópia oculta por envio
Local cDe          := ""
Local cPara        := ""
Local cCc          := ""
Local cCCO         := ""
Local cCCONRU      := ""
Local cAssunto     := ""
Local cAnexo       := ""
Local cCorpo       := ""
Local cServer      := ""
Local cUser        := ""
Local cPass        := ""
Local lAuth        := .F.
Local aCpoNRU      := {"NRU_DESC", "NRU_CC", "NRU_CCO", "NRU_CORPO"}

Default lSchedule  := .F.
Default cCfgSrv    := ""
Default cCfgUsrSrv := ""
Default cCfgEnv    := ""

	aRegs := J176AQry() // Query para verificar os registros com pendências (inconsistentes e não revisados)
	
	If Len(aRegs) > 0

		If NRU->(ColumnPos("NRU_ASSUNT")) > 0
			aCpoNRU := {"NRU_ASSUNT", "NRU_CC", "NRU_CCO", "NRU_CORPO"}
		EndIf

		aDadosNR7 := JurGetDados("NR7", 1, xFilial("NR7") + cCfgSrv   , {"NR7_ENDERE", "NR7_AUTENT"})
		aDadosNR8 := JurGetDados("NR8", 1, xFilial("NR8") + cCfgUsrSrv, {"NR8_EMAIL", "NR8_SENHA"})
		aDadosNRU := JurGetDados("NRU", 1, xFilial("NRU") + cCfgEnv   , aCpoNRU)

		cDe      := AllTrim(aDadosNR8[1])
		cPara    := AllTrim(aDadosNR8[1])
		cCc      := AllTrim(aDadosNRU[2])
		cCCONRU  := AllTrim(aDadosNRU[3])
		cAssunto := AllTrim(aDadosNRU[1])
		cCorpo   := AllTrim(aDadosNRU[4])
		cServer  := AllTrim(aDadosNR7[1])
		cUser    := AllTrim(aDadosNR8[1])
		cPass    := Decode64(Embaralha(AllTrim(aDadosNR8[2]), 1))
		lAuth    := IIf(aDadosNR7[2] == "1", .T., .F.)

		cCCONRU  := StrTran(cCCONRU, ";", ",")
		cCCO     := cCCONRU

		nLimCCO  -= Len(StrTokArr(cCCONRU, ",")) // Tira do Limite a quantidade de e-mails indicada na configuração (NRU)

		For nI := 1 To Len(aRegs)
			If !Empty(aRegs[nI])
				aAdd(aCCO, AllTrim(aRegs[nI][1]))
			EndIf
		Next

		If Len(aCCO) <= nLimCCO // Verifica se é possível enviar todos sem passar do limite estipulado
			cCCO += "," + AtoC(aCCO, ",")
			lRet := JurEnvMail(cDe, cPara, cCc, cCCO, cAssunto, cAnexo, cCorpo, cServer, cUser, cPass, lAuth, cUser, cPass)
		Else
			For nI := 1 To Len(aCCO)
				cCCO += "," + aCCO[nI]

				If nLimCCO == nI .Or. Len(aCCO) == nI // Envia o e-mail quando atingir o limite ou total de destinatários
					lEnvia := .T.
				EndIf

				If lEnvia
					lRet   := JurEnvMail(cDe, cPara, cCc, cCCO, cAssunto, cAnexo, cCorpo, cServer, cUser, cPass, lAuth, cUser, cPass)
					cCCO   := cCCONRU // Preenche a váriavel de Cópia Oculta somente com endereços da configuração (NRU)
					lEnvia := .F. // Zera variável de envio
				EndIf

				If !lRet
					Exit
				EndIf
			Next nI
		EndIf

		If lRet .And. !lSchedule
			ApMsgInfo(STR0054) // "E-mail(s) enviado(s) com sucesso!"
		EndIf
	
	Else
		lRet := .F.
		JurMsgErro(STR0041,, STR0042) // "Não há registros com pendências para envio de e-mail." # "Não há registros não revisados ou inconsistentes."
	EndIf

Return lRet
