#INCLUDE "JURA142.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

#DEFINE nPGrCli    1
#DEFINE nPClien    2
#DEFINE nPLoja     3
#DEFINE nPCaso     4
#DEFINE nPContr    5
#DEFINE nPDtIni    6
#DEFINE nPDtFim    7
#DEFINE nPTipo     8
#DEFINE nPCobra    9
#DEFINE nPDtInc    13
Static _lFwPDCanUse := FindFunction("FwPDCanUse")

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA142
Inclusão de WO - Tabelado

@author David Gonçalves Fernandes
@since 29/12/2009
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA142()
Local lJura027     := IsInCallStack( "JCall142" )
Local lVldUser     := Iif(FindFunction("JurVldUxP"), JurVldUxP(), .T.)

Private cQueryTmp  := ""
Private oBrw142    := Nil
Private lMarcar    := .F.
Private oTmpTable  := Nil
Private TABLANC    := ""
Private cDefFiltro := ""

If lVldUser
	If !lJura027 .And. ExistFunc( "JurFiltrWO" )
		JurFiltrWO("NV4") // Filtro
		If Type( "oTmpTable" ) == "O"
			oTmpTable:Delete() // Apaga a Tabela temporária
		EndIf
	Else
		TABLANC     := "NV4"
		cDefFiltro  := "NV4_SITUAC == '1'"
	
		oBrw142 := FWMarkBrowse():New()
		If !IsInCallStack( 'JURA142' ) .And. !IsInCallStack( 'JURA202' )
			oBrw142:SetDescription( STR0007 )
		Else
			oBrw142:SetDescription( STR0012 )
		EndIf
	
		oBrw142:SetAlias( TABLANC )
		oBrw142:SetMenuDef( "JURA142" ) // Redefine o menu a ser utilizado
		oBrw142:SetLocate()
		oBrw142:SetFilterDefault( cDefFiltro )
		oBrw142:SetFieldMark( 'NV4_OK' )
		oBrw142:bAllMark := { || JurMarkALL(oBrw142, "NV4", 'NV4_OK', lMarcar := !lMarcar,, .F.), oBrw142:Refresh() }
		JurSetLeg( oBrw142, "NV4" )
		JurSetBSize( oBrw142 )
		oBrw142:Activate()
	EndIf
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JUR142BrwR
Função para executar um processa para abrir o browse (JUR142Brw)

@param   aFiltros , array , Campos e valores de filtros
@param   lAtualiza, logico, Reabre browse com novos filtros

@author  Jorge Martins
@since   20/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function Jur142BrwR(aFiltros, lAtualiza)
Local lRet := .F.

FWMsgRun( , {|| lRet := Jur142Brw(aFiltros, lAtualiza)}, STR0043, STR0044 ) // "Processando" - "Processando a rotina..."

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Jur142Brw
Função para montar o browse de WO com filtros

@param   aFiltros , array , Campos e valores de filtros
@param   lAtualiza, logico, Reabre browse com novos filtros

@author  Jorge Martins
@since   20/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Jur142Brw(aFiltros, lAtualiza)
Local aTemp         := {}
Local aFields       := {}
Local aOrder        := {}
Local aFldsFilt     := {}
Local bseek         := {||}
Local aStruAdic     := {}

Local aCmpAcBrw     := {}
Local aTitCpoBrw    := {}
Local aCmpNotBrw    := {}
Local lRet          := .T.

Default aFiltros    := Array(12)
Default lAtualiza   := .F.

cQueryTmp := J142QryTmp( aFiltros )

If lAtualiza
	lRet := J142AtuBrw(cQueryTmp)

Else
	aStruAdic  := J142StruAdic()
	aCmpAcBrw  := J142CmpAcBrw()
	aTitCpoBrw := J142TitCpoBrw()
	aCmpNotBrw := J142NotBrw()
	aTemp      := JurCriaTmp(GetNextAlias(), cQueryTmp, "NV4", , aStruAdic, aCmpAcBrw, aCmpNotBrw, , , aTitCpoBrw)
	oTmpTable  := aTemp[1]
	aFldsFilt  := aTemp[2]
	aOrder     := aTemp[3]
	aFields    := aTemp[4]
	TABLANC    := oTmpTable:GetAlias()

	If (TABLANC)->( Eof() )
		lRet := JurMsgErro( STR0045 ) // "Não foram encontrados dados!"
	Else

		oBrw142 := FWMarkBrowse():New()
		If !IsInCallStack( 'JURA027' )
			oBrw142:SetDescription( STR0007 ) // "Inclusão de WO - Tabelado"
		Else
			oBrw142:SetDescription( STR0012 ) //"Operações em lote - Lançamento Tabelado"
		EndIf
		oBrw142:SetAlias( TABLANC )
		oBrw142:SetTemporary( .T. )
		oBrw142:SetFields(aFields)

		oBrw142:oBrowse:SetDBFFilter(.T.)
		oBrw142:oBrowse:SetUseFilter()
		//------------------------------------------------------
		// Precisamos trocar o Seek no tempo de execucao,pois
		// na markBrowse, ele não deixa setar o bloco do seek
		// Assim nao conseguiriamos  colocar a filial da tabela
		//------------------------------------------------------

		bseek := {|oSeek| MySeek(oSeek, oBrw142:oBrowse)}
		oBrw142:oBrowse:SetIniWindow({|| oBrw142:oBrowse:oData:SetSeekAction(bseek)})
		oBrw142:oBrowse:SetSeek(.T., aOrder)

		oBrw142:oBrowse:SetFieldFilter(aFldsFilt)
		oBrw142:oBrowse:bOnStartFilter := Nil

		oBrw142:SetMenuDef( 'JURA142' )
		oBrw142:SetFieldMark( 'NV4_OK' )
		oBrw142:bAllMark := { || JurMarkALL(oBrw142, TABLANC, 'NV4_OK', lMarcar := !lMarcar,, .F.), oBrw142:Refresh() }
		JurSetBSize( oBrw142 )

		If Len(aTemp) >= 7 .And. !Empty(aTemp[7]) // Tratamento para LGPD verifica os campos que devem ser ofuscados
			oBrw142:oBrowse:SetObfuscFields(aTemp[7])
		EndIf

		oBrw142:Activate()

		lRet := .T.
	EndIf
EndIf

Return lRet

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

@author Felipe Bonvicini Conti
@since 17/06/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina  := {}
Local lJura027 := IsInCallStack( "JCall142" )
Local cView    := Iif(lJura027, "JA142View((TABLANC)->(Recno()))", "JA142View((TABLANC)->REC)")

aAdd( aRotina, { STR0002, cView, 0, 2, 0, NIL } ) // "Visualizar"

If !lJura027 .And. IsInCallStack( 'JURA142' ) .And. ExistFunc( "JurFiltrWO" )
	aAdd( aRotina, { STR0046, 'JurFiltrWO("NV4", .T.)', 0, 3, 0, NIL } ) // "Filtros"
EndIf

aAdd( aRotina, { STR0013, "JA142SET()", 0, 6, 0, NIL } ) // "WO"

If IsInCallStack( 'JURA027' )
	aAdd( aRotina, { STR0014, "JA142DLG()", 0, 6, 0, NIL } ) // "Alterar lote"
EndIf

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de lançamentos Tabelados dos Profissionais

@author Felipe Bonvicini Conti
@since 17/06/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView      := Nil
Local oModel     := FWLoadModel( "JURA142" )
Local oStructNV4 := FWFormStruct( 2, "NV4" )
Local cLojaAuto  := SuperGetMv( "MV_JLOJAUT", .F., "2", ) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)

Iif(cLojaAuto == "1", oStructNV4:RemoveField( "NV4_CLOJA" ), )
JurSetAgrp( 'NV4',, oStructNV4 )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA142_NV4", oStructNV4, "NV4MASTER"  )
oView:CreateHorizontalBox( "NV4FIELDS", 100 )
oView:SetOwnerView( "JURA142_NV4", "NV4FIELDS" )

If !IsInCallStack( 'JURA027' )
	oView:SetDescription( STR0007 ) // "Lançamentos Tabelados
Else
	oView:SetDescription( STR0012 ) // If( cPaisLoc $ "ANG|PTG", "Operações em lote - Lançamento tabelado", "Operações em lote - Lançamento Tabelado" )
EndIf

oView:EnableControlBar( .T. )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Lançamentos Tabelados

@author Felipe Bonvicini Conti
@since 17/06/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel      := NIL
Local oStructNV4  := FWFormStruct( 1, "NV4" )

oModel:= MPFormModel():New( "JURA142", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:AddFields( "NV4MASTER", NIL, oStructNV4, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( STR0008 ) // "Modelo de Dados de Lançamentos Tabelados"
oModel:GetModel( "NV4MASTER" ):SetDescription( STR0009 ) // "Dados de Lançamentos Tabelados"
JurSetRules( oModel, "NV4MASTER",, "NV4",,  )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JA142SET
Envia os Lançamentos para WO: Cria um registro na Tabela de WO,
vincula os lançamentos ao número do WO e
atualiza o valor dos lançamentos na tabela WO Caso

@param 	cTipo  	Tipo da alteração a ser executada nos Lançamentos Tabelados

@author David Gonçalves Fernandes
@since 07/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA142SET()
Local lRet       := .T.
Local lAtuBrowse := .T.
Local cMarca     := oBrw142:Mark()
Local lInvert    := oBrw142:IsInvert()
Local nCountNV4  := 0
Local cFiltro    := ''
Local cDefFiltro := "NV4_SITUAC == '1'"
Local cMsg       := ''
Local aOBS       := {}

cFiltro   := oBrw142:FWFilter():GetExprADVPL()

If Empty(cFiltro)
	cFiltro += "(NV4_OK " + Iif(lInvert, "<>", "==" ) + " '" + cMarca + "')"
Else
	cFiltro += " .And. (NV4_OK " + Iif(lInvert, "<>", "==" ) + " '" + cMarca + "')"
EndIf

cAux := &( '{|| ' + cFiltro + ' }')
(TABLANC)->( dbSetFilter( cAux, cFiltro ) )
(TABLANC)->( dbSetOrder(1) )

(TABLANC)->(DbEval({|| nCountNV4++}))

If nCountNV4 == 0
	lRet := JurMsgErro(STR0018) //"Não há dados marcados para execução em lote!"
EndIf

If lRet .And. MsgYesNo( STR0034 )  //"Todos os registros marcados serão alterados. Deseja Continuar?"
	aOBS := JurMotWO('NUF_OBSEMI', STR0007, STR0035, "3") // "Inclusão de WO - Tabelado" - "Observação WO"
	If !Empty(aOBS)
		nCountNV4 := JAWOLANCTO(3, aOBS, cFiltro, cDefFiltro, TABLANC)
		cMsg := Alltrim(Str(nCountNV4)) + STR0011 //" lançamentos alterados."
		lAtuBrowse := nCountNV4 > 0
	Else
		lAtuBrowse := .F.
	EndIf
Else
	lAtuBrowse := .F.
EndIf

cAux := &( "{|| " + cDefFiltro + " }")  //Retorna o Filtro padrão - somente lançamentos ativos...
(TABLANC)->( dbSetFilter( cAux, cDefFiltro ) )

If !Empty(cMsg)
	If JurGetLog()
		AutoGrLog( cMsg )
		JurLogLote()  // Mostra o Log da operação
	Else
		JurLogLote()  // Descarta o arquivo de log utlizado
		ApMsgInfo( cMsg )
	EndIf
EndIf

If lAtuBrowse
	JA142ATU()
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA142DLG()
Monta a tela para Alteração de Lançamentos Tabelados.

@author Luciano Pereira dos Santos
@since 11/08/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA142DLG()
Local aArea       := GetArea()
Local lRet        := .T.
Local cMarca      := oBrw142:Mark()
Local lInvert     := oBrw142:IsInvert()
Local cDefFiltro  := "NV4_SITUAC == '1'"
Local cFiltro     := oBrw142:FWFilter():GetExprADVPL()
Local nCountNV4   := 0
Local cLojaAuto   := SuperGetMv( "MV_JLOJAUT", .F., "2", ) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
Local oLayer      := FWLayer():New()
Local oMainColl   := Nil
Local nLocLj      := 0
Local cJcaso      := SuperGetMv("MV_JCASO1", .F., '1')  //1 – Por Cliente; 2 – Independente de cliente
Local aCposLGPD   := {}
Local aNoAccLGPD  := {}
Local aDisabLGPD  := {}
Local lExecTir    := __CUSERID == "000481" .And. CUSERNAME == "PFSCOMPART" .And. GetRemoteType() == REMOTE_HTML // Execução via TIR

Private oAdv      := Nil
Private oDesAdv   := Nil
Private oQtSrv    := Nil
Private oHonFt    := Nil
Private oHonTx    := Nil
Private oConcl    := Nil
Private oDataLT   := Nil
Private oCobra    := Nil

Private oChkServ  := Nil
Private oChkQtSrv := Nil
Private oChkConcl := Nil
Private oChkHonFt := Nil
Private oChkHonTx := Nil
Private oChkCob   := Nil
Private oChkAdv   := Nil

Private oLkUpSA1  := __FWLookUp('SA1NUH')
Private oCliOr    := Nil
Private oDesCli   := Nil
Private oLojaOr   := Nil
Private oCasOr    := Nil

Private oDlg

Private nQtSrv    := 0
Private nHonFt    := 0
Private nHonTx    := 0
Private dDataLT   := CToD( '  /  /  ' )
Private cConcl    := ""
Private cCobra    := ""
Private cCliOr    := CriaVar('A1_COD', .F.)
Private cDesCli   := ""
Private cLojaOr   := CriaVar('A1_LOJA', .F.)
Private cCliGrp   := CriaVar('A1_GRPVEN', .F.)
Private cCasoOr   := CriaVar('NUE_CCASO', .F.)
Private cDesCas   := ""
Private cSigla    := CriaVar('NV4_SIGLA', .F.)
Private cDesAdv   := ""

Private lChkCli   := lExecTir
Private lChkQtSrv := lExecTir
Private lChkHonFt := lExecTir
Private lChkHonTx := lExecTir
Private lChkConcl := lExecTir
Private lChkCob   := lExecTir
Private lChkAdv   := lExecTir

If Empty(cFiltro)
	cFiltro += "(NV4_OK "+Iif(lInvert, "<>", "==" ) + " '" + cMarca + "')" + " .AND. (NV4_FILIAL = '" + xFilial( "NV4" ) + "')"
Else
	cFiltro += " .And. (NV4_OK " + Iif(lInvert, "<>", "==" ) + " '" + cMarca + "')" + " .AND. (NV4_FILIAL = '" + xFilial( "NV4" ) + "')"
EndIf

cAux := &( '{|| ' + cFiltro + ' }')
(TABLANC)->( dbSetFilter( cAux, cFiltro ) )
(TABLANC)->( dbSetOrder(1) )

(TABLANC)->(DbEval({||nCountNV4++}))

If nCountNV4 == 0
	lRet := JurMsgErro(STR0018) //"Não há dados marcados para execução em lote!"
EndIf

If lRet

	If _lFwPDCanUse .And. FwPDCanUse(.T.)
		aCposLGPD := {"NV4_DCLIEN","NV4_DCASO","NV4_DPART"}

		aDisabLGPD := FwProtectedDataUtil():UsrNoAccessFieldsInList(aCposLGPD)
		AEval(aDisabLGPD, {|x| AAdd( aNoAccLGPD, x:CFIELD)})
	EndIf

	DEFINE MSDIALOG oDlg TITLE STR0015 FROM 0, 0 TO 500, 500 PIXEL //"Alteração de Lançamentos Tabelados em lote"

	oLayer:init(oDlg, .F.) //Inicializa o FWLayer com a janela que ele pertencera e se sera exibido o botao de fechar
	oLayer:addCollumn("MainColl", 100, .F.) //Cria as colunas do Layer
	oMainColl := oLayer:GetColPanel( 'MainColl' )

	// "Ativar" //
	oChkCli := TJurCheckBox():New(015, 005, "", {|| }, oMainColl, 08, 08, , {|| }, , , , , , .T., , , )
	oChkCli:SetCheck(lChkCli)
	oChkCli:bChange := {|| lChkCli := oChkCli:Checked(),;
						JurChkCli(@oCliOr, @cCliOr, @oLojaOr, @cLojaOr, @oDesCli, @cDesCli, @oCasoOr, @cCasoOr, @oDesCas, @cDesCas, lChkCli)}

	// "Cód Cliente" //
	oCliOr := TJurPnlCampo():New(005, 015, 060, 022, oMainColl, AllTrim(RetTitle("NV4_CCLIEN")), ("NV4_CCLIEN"), {|| }, {|| },,,, 'SA1NUH')
	oCliOr:SetValid({|| JurTrgGCLC(,, @oCliOr, @cCliOr, @oLojaOr, @cLojaOr, @oCasoOr, @cCasoOr, "CLI",;
									,, @oDesCli, @cDesCli, @oDesCas, @cDesCas) })
	oCliOr:SetWhen({|| lChkCli})

	// "lOJA" //
	oLojaOr := TJurPnlCampo():New(005, 085, 045, 022, oMainColl, AllTrim(RetTitle("NV4_CLOJA")), ("NV4_CLOJA"), {|| }, {|| },,,)
	oLojaOr:SetValid({|| JurTrgGCLC(,, @oCliOr, @cCliOr, @oLojaOr, @cLojaOr, @oCasoOr, @cCasoOr, "LOJ",;
									,,@oDesCli, @cDesCli, @oDesCas, @cDesCas) })
	oLojaOr:SetWhen({|| lChkCli})
	If (cLojaAuto == "1")
		oLojaOr:Hide()
		nLocLj := 45
	EndIf

	// "NOME CLIENTE" //
	oDesCli := TJurPnlCampo():New(005, 130 - nLocLj, 110 + nLocLj, 022, oMainColl, AllTrim(RetTitle("NV4_DCLIEN")), ("NV4_DCLIEN"), {|| }, {|| },,,,,,,,,aScan(aNoAccLGPD ,"NV4_DCLIEN") > 0)
	oDesCli:SetWhen({||.F.})

	//----------------

	// "CÓD CASO" //
	oCasoOr := TJurPnlCampo():New(030, 015, 060, 022, oMainColl, AllTrim(RetTitle("NV4_CCASO")), ("NV4_CCASO"), {|| }, {|| },,,, 'NVEORI')
	oCasoOr:SetValid({|| JurTrgGCLC(,, @oCliOr, @cCliOr, @oLojaOr, @cLojaOr, @oCasoOr, @cCasoOr, "CAS",;
									,, @oDesCli, @cDesCli, @oDesCas, @cDesCas, "NVE_LANTAB") })
	oCasoOr:SetWhen({|| lChkCli .AND. ((cJcaso == "1" .AND. !Empty(cLojaOr)) .OR. cJcaso == "2")})

	// "TÍTULO CASO" //
	oDesCas := TJurPnlCampo():New(030, 085, 155, 022, oMainColl, AllTrim(RetTitle("NV4_DCASO")), ("NV4_DCASO"), {|| }, {|| },,,,,,,,,aScan(aNoAccLGPD,"NV4_DCASO") > 0)
	oDesCas:SetWhen({||.F.})

	//-----------------

	// "Ativar" //
	oChkAdv := TJurCheckBox():New(065, 005, "",  {|| }, oMainColl, 08, 08, , {|| } , , , , , , .T., , , )
	oChkAdv:SetCheck(lChkAdv)
	oChkAdv:bChange := {|| lChkAdv := oChkAdv:Checked(), JurValAdv(@cSigla, @oAdv, @cDesAdv, @oDesAdv)}

	// "Sig Partic" //
	oAdv := TJurPnlCampo():New(055, 015, 060, 022, oMainColl, AllTrim(RetTitle("NV4_SIGLA")), ("NV4_SIGLA"), {|| }, {|| },,,, 'RD0ATV')
	oAdv:SetValid({|| JurDesAdv(cSigla, @cDesAdv, @oDesAdv)})
	oAdv:SetWhen({|| lChkAdv})
	oAdv:SetChange ({|| cSigla := oAdv:GetValue(), oDesAdv:SetValue(Posicione('RD0', 9, xFilial('RD0') + Alltrim(cSigla), 'RD0_NOME'))})

	// "Nome Partic" //
	oDesAdv := TJurPnlCampo():New(055, 085, 155, 022, oMainColl, AllTrim(RetTitle("NV4_DPART")), ("NV4_DPART"), {|| }, {|| },,,,,,,,,aScan(aNoAccLGPD,"NV4_DPART") > 0)
	oDesAdv:SetWhen({|| .F.})
	oDesAdv:SetChange ({|| cDesAdv := oDesAdv:GetValue()})

	//----------------

	// "Ativar" //
	oChkQtSrv := TJurCheckBox():New(090, 005, "", {|| }, oMainColl, 08, 08, , {|| } , , , , , , .T., , , )
	oChkQtSrv:SetCheck(lChkQtSrv)
	oChkQtSrv:bChange := {|| lChkQtSrv := oChkQtSrv:Checked(), ValQtSrv()}

	// "Qtd Serviços" //
	oQtSrv := TJurPnlCampo():New(080, 015, 048, 022, oMainColl, AllTrim(RetTitle("NV4_QUANT")), ("NV4_QUANT"), {|| }, {|| },,,,)
	oQtSrv:SetValid({|| ValQtSrv() })
	oQtSrv:SetWhen({|| lChkQtSrv})
	oQtSrv:SetChange ({|| nQtSrv := oQtSrv:GetValue()})

	//-----------------

	// "Ativar" //
	oChkHonFt := TJurCheckBox():New(115, 005, "", {|| }, oMainColl, 08, 08, , {|| } , , , , , , .T., , , )
	oChkHonFt:SetCheck(lChkHonFt)
	oChkHonFt:bChange := {|| lChkHonFt := oChkHonFt:Checked(), ValHonFt()}

	// "Vlr Hon Fat" //
	oHonFt := TJurPnlCampo():New(105, 015, 070, 022, oMainColl, AllTrim(RetTitle("NV4_VLHFAT")), ("NV4_VLHFAT"), {|| }, {|| },,,,)
	oHonFt:SetWhen({|| lChkHonFt})
	oHonFt:SetChange ({|| nHonFt := oHonFt:GetValue(), ValHonFt(),})

	//-----------------

	// "Ativar" //
	oChkHonTx := TJurCheckBox():New(140, 005, "", {|| }, oMainColl, 08, 08, , {|| } , , , , , , .T., , , )
	oChkHonTx:SetCheck(lChkHonTx)
	oChkHonTx:bChange := {|| lChkHonTx := oChkHonTx:Checked(), ValHonTx()}

	// "Vlr Hon Fat" //
	oHonTx := TJurPnlCampo():New(130, 015, 070, 022, oMainColl, AllTrim(RetTitle("NV4_VLHFAT")), ("NV4_VLHFAT"), {|| }, {|| },,,,)
	oHonTx:SetWhen({|| lChkHonTx})
	oHonTx:SetChange ({|| nHonTx := oHonTx:GetValue(), ValHonTx()})

	//------------------

	// "Ativar" //
	oChkConcl := TJurCheckBox():New(165, 005, "", {|| }, oMainColl, 08, 08, , {|| } , , , , , , .T., , , )
	oChkConcl:SetCheck(lChkConcl)
	oChkConcl:bChange := {|| lChkConcl := oChkConcl:Checked(), ValConcl()}

	// "Concluído?" //
	oConcl := TJurPnlCampo():New(155, 015, 050, 025, oMainColl, AllTrim(RetTitle("NV4_CONC")), ("NV4_CONC"), {|| }, {|| },,,,)
	oConcl:SetWhen({|| lChkConcl})
	oConcl:SetChange ({|| cConcl := oConcl:GetValue(), ConclChg()})

	// "Dt Conclusão" //
	oDataLT := TJurPnlCampo():New(155, 085, 060, 022, oMainColl, AllTrim(RetTitle("NV4_DTCONC")), ("NV4_DTCONC"), {|| }, {|| },,,,)
	oDataLT:SetWhen({|| (cConcl == "1" .AND. lChkConcl) })
	oDataLT:SetValid({|| ValDt() })
	oDataLT:SetChange ({|| dDataLT := oDataLT:GetValue(), ConclChg()})

	//------------------

	// "Ativar" //
	oChkCob := TJurCheckBox():New(190, 005, "",  {|| }, oMainColl, 08, 08, , {|| } , , , , , , .T., , , )
	oChkCob:SetCheck(lChkCob)
	oChkCob:bChange := {|| lChkCob := oChkCob:Checked(), ValCob()}

	// "Cobrar?" //
	oCobra := TJurPnlCampo():New(180, 015, 050, 025, oMainColl, AllTrim(RetTitle("NV4_COBRAR")), ("NV4_COBRAR"), {|| }, {|| },,,,)
	oCobra:SetWhen({|| lChkCob})
	oCobra:SetChange ({|| cCobra := oCobra:GetValue()})

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar;
				(oDlg, {|| IIf(JA142ALT(), oDlg:End(), Nil)}, {|| oDlg:End() },; //"Sair"
				, /*aButtons*/, /*nRecno*/, /*cAlias*/, .F., .F., .F., .T., .F. )

EndIf

cAux := &( "{|| " + cDefFiltro + " }")  //Retorna o Filtro padrão - somente lançamentos ativos...
(TABLANC)->( dbSetFilter( cAux, cDefFiltro ) )

RestArea( aArea )

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} ValQtSrv()
Função habilitar/ Desabilitar o quantidade de serviços da alteração de
lançamentos tabelados em lote

@Return lRet  - Sempre retornará .T.

@author Luciano Pereira dos Santos
@since 09/08/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ValQtSrv()
Local lRet := .T.

If lChkQtSrv
	oQtSrv:Enable()
	oQtSrv:Refresh()
Else
    cQtSrv:= 0
	oQtSrv:Disable()
	oQtSrv:SetValue(cQtSrv)
EndIf
If nQtSrv < 0
	lRet := JurMsgErro(STR0019) //"Informe uma quantidade válida!"
	nQtSrv := 0
	oQtSrv:SetValue(nQtSrv)
EndIf

Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} ValConcl()
Função habilitar/ Desabilitar o concluido da alteração de
lançamentos tabelados em lote

@Return lRet  - Sempre retornará .T.

@author Luciano Pereira dos Santos
@since 13/08/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ValConcl()
Local lRet := .T.

If lChkConcl
	ConclChg()
	oConcl:Enable()
	oConcl:Refresh()
Else
	dDataLT := CToD( '  /  /  ' )
	oDataLT:SetValue(dDataLT)

	cConcl := ""
	oConcl:Disable()
	oConcl:SetValue(cConcl)
EndIf

Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} ValDt()
Função habilitar/ Desabilitar a Data da alteração de
lançamentos tabelados em lote

@Return lRet  - Sempre retornará .T.

@author Luciano Pereira dos Santos
@since 13/08/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ValDt()
Local lRet := .T.

If (oConcl:GetValue() == "1") .And. Empty(dDataLT)
	lRet := JurMsgErro(STR0022) // "Informe a data!"
EndIf

Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} ConclChg()
Função de regra de negócio para o campo data em relação ao combo concluido de
lançamentos tabelados em lote

@Return lRet  - Sempre retornará .T.

@author Luciano Pereira dos Santos
@since 13/08/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ConclChg()
Local lRet := .T.

Do Case
	Case (oConcl:GetValue() == "1") //sim
 		dDataLT := Date()

	Case (oConcl:GetValue() == "2") .Or. (Empty(oConcl:GetValue())) //não ou nulo
		dDataLT := CToD( '  /  /  ' )
EndCase

oDataLT:SetValue(dDataLT)

Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} ValHonFt()
Função habilitar/ Desabilitar a Honorarios faturados da alteração de
lançamentos tabelados em lote

@Return lRet  - Sempre retornará .T.

@author Luciano Pereira dos Santos
@since 13/08/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ValHonFt()
Local lRet := .T.

If lChkHonFt
	oHonFt:Enable()
	oHonFt:Refresh()
Else
	nHonFt:= 0
	oHonFt:Disable()
	oHonFt:SetValue(nHonFt)
EndIf

If nHonFt < 0
	lRet := JurMsgErro(STR0033) //"Informe um valor de honorário válido!"
	nHonFt := 0
	oHonFt:SetValue(nHonFt)
EndIf

Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} ValHonTx()
Função habilitar/ Desabilitar a Honorarios Tabelados da alteração de
lançamentos tabelados em lote

@Return lRet  - Sempre retornará .T.

@author Luciano Pereira dos Santos
@since 13/08/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ValHonTx()
Local lRet := .T.

If lChkHonTx
	oHonTx:Enable()
	oHonTx:Refresh()
Else
	nHonTx:= 0
	oHonTx:Disable()
	oHonTx:SetValue(nHonTx)
EndIf

If nHonTx < 0
	lRet := JurMsgErro(STR0033) //"Informe um valor de honorário válido!"
	nHonTx := 0
	oHonTx:SetValue(nHonTx)
EndIf

Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} ValCob()
Função habilitar/ Desabilitar Cobrar da alteração de
lançamentos tabelados em lote

@Return lRet  - Sempre retornará .T.

@author Luciano Pereira dos Santos
@since 13/08/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ValCob()
Local lRet := .T.

If lChkCob
	oCobra:Enable()
	oCobra:Refresh()
Else
	cCobra := ""
	oCobra:Disable()
	oCobra:SetValue(cCobra)
EndIf

Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} JA142ALT()
Alterar os Lançamentos Tabelados em Lote

@author Luciano Pereira dos Santos
@since 12/08/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA142ALT()
Local lRet := .T.
	Processa( {|| lRet := JA142ALT2() }, STR0015, STR0036, .F. ) // #"Alteração de Lançamentos Tabelados em lote"   ##"Aguarde..."
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA142ALT2()
Alterar os Lançamentos Tabelados em Lote

@author Luciano Pereira dos Santos
@since 12/08/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA142ALT2()
Local aArea      := GetArea()
Local lRet       := .T.
Local cMarca     := oBrw142:Mark()
Local lInvert    := oBrw142:IsInvert()
Local cDefFiltro := "NV4_SITUAC == '1'"
Local cFiltro    := oBrw142:FWFilter():GetExprADVPL()
Local nCountNV4  := 0
Local cCobNew    := oCobra:GetValue()
Local cConNew    := oConcl:GetValue()
Local lJura027   := IsInCallStack( "JCall142" )
Local nPosicao   := Iif(lJura027, (TABLANC)->(Recno()), (TABLANC)->REC)
Local nQtdNV4    := 0
Local cMemoLog   := ""
Local aErro      := {}
Local nCount     := 0
Local cVldMsg    := ""
Local cTpServ    := ""

If Empty(cCasoOr) .And. Empty(nQtSrv) .And. Empty(nHonFt) .And. Empty(nHonTx);
  .And. Empty(cConcl) .And. Empty(cCobra) .And. Empty(cSigla)
	lRet := JurMsgErro(STR0021) //"Informe um item para alterar!"
EndIf

If lRet

	If Empty(cFiltro)
		cFiltro += "(NV4_OK " + Iif(lInvert, "<>", "==" ) + " '" + cMarca + "')" + " .AND. (NV4_FILIAL = '" + xFilial( "NV4" ) + "')"
	Else
		cFiltro += " .And. (NV4_OK " + Iif(lInvert, "<>", "==" ) + " '" + cMarca + "')" + " .AND. (NV4_FILIAL = '" + xFilial( "NV4" ) + "')"
	EndIf

	cAux := &( '{|| ' + cFiltro + ' }')
	(TABLANC)->( dbSetFilter( cAux, cFiltro ) )
	(TABLANC)->( dbSetOrder(1) )

	(TABLANC)->(DbEval({|| nQtdNV4++}))

	If nQtdNV4 == 0
		lRet := JurMsgErro(STR0018) //"Não há dados marcados para execução em lote!"
	EndIf

	If lRet .And. MsgYesNo( STR0034 )  //"Todos os registros marcados serão alterados. Deseja Continuar?"
		ProcRegua(nQtdNV4)
		(TABLANC)->( dbgotop() )

		AutoGrLog(STR0015)  //#"Alteração de Lançamentos Tabelados em lote"
		AutoGrLog(Replicate('-', 65) + CRLF)

		oModelFW := FWLoadModel( "JURA027" )
		JurSetRules( oModelFW, "NV4MASTER",, "NV4",,  )

		(TABLANC)->(DbSetOrder(1))
		While !((TABLANC)->( EOF() ))
			nCount++ //regua

			If FindFunction("JurBlqLnc") // Proteção
				cVldMsg := JurBlqLnc((TABLANC)->NV4_CCLIEN, (TABLANC)->NV4_CLOJA, (TABLANC)->NV4_CCASO, (TABLANC)->NV4_DTCONC, "TAB", "0")
			EndIf

			If(Empty(cVldMsg)) .And. NV4->(DbSeek((xFilial("NV4") + (TABLANC)->NV4_COD))) //reposiciona o registro
				oModelFW:SetOperation( 4 )
				oModelFW:Activate()
				cTpServ := oModelFW:GetValue("NV4MASTER", "NV4_CTPSRV")

				If !Empty(cCliOr)
					lRet := oModelFW:SetValue("NV4MASTER", "NV4_CCLIEN", cCliOr)
				EndIf

				If !Empty(cLojaOr) .And. lRet
					lRet := oModelFW:SetValue("NV4MASTER", "NV4_CLOJA", cLojaOr)
				EndIf

				If !Empty(cCasoOr) .And. lRet
					lRet := oModelFW:SetValue("NV4MASTER", "NV4_CCASO", cCasoOr)
				EndIf

				If !Empty(cTpServ) .And. lRet
					lRet := oModelFW:SetValue("NV4MASTER", "NV4_CTPSRV", cTpServ)
				EndIf

				If !Empty(cSigla) .And. lRet
					lRet := oModelFW:SetValue("NV4MASTER", "NV4_SIGLA", cSigla)
				EndIf

				If !Empty(nQtSrv) .And. lRet
					lRet := oModelFW:SetValue("NV4MASTER", "NV4_QUANT", nQtSrv)
					If lRet
						lRet := J027ValCpo()
					EndIf
				EndIf

				If !Empty(nHonFt) .And. lRet
					lRet := oModelFW:SetValue("NV4MASTER", "NV4_VLHFAT", nHonFt)
				EndIf

				If !Empty(nHonTx) .And. lRet
					lRet := oModelFW:SetValue("NV4MASTER", "NV4_VLDFAT", nHonTx)
				EndIf

				If !Empty(cConcl) .And. lRet
					lRet := oModelFW:SetValue("NV4MASTER", "NV4_CONC", cConNew )
					If lRet
						If cConNew == "1" //concluido sim
							If ( dDataLT >= (oModelFW:GetValue("NV4MASTER", "NV4_DTLANC")) )
								lRet := oModelFW:SetValue("NV4MASTER", "NV4_DTCONC", dDataLT)
							EndIf
						EndIf
					EndIf
				EndIf

				If !Empty(cCobra) .And. lRet
					lRet := oModelFW:SetValue("NV4MASTER", "NV4_COBRAR", cCobNew)
				EndIf

				If lRet := oModelFW:VldData()
					oModelFW:CommitData()
					ncountNV4 ++

					RecLock(TABLANC, .F.)
					(TABLANC)->NV4_OK := ""
					(TABLANC)->(MsUnlock())
					(TABLANC)->(DbCommit())

				Else
					aErro := oModelFW:GetErrorMessage()

					cMemoLog += ( STR0037 + (TABLANC)->NV4_COD ) + CRLF //"Tabelado: "
					If !Empty(AllToChar(aErro[4]))
						cMemoLog += ( STR0038 + AllToChar(aErro[4]) ) + CRLF //"Campo: "
					EndIf
					cMemoLog += ( STR0039 + AllToChar(aErro[6]) ) + CRLF //"Erro: "
					AutoGrLog(cMemoLog) //Grava o Log
					cMemoLog := ""  // Limpa a critica para o proximo TimeSheet
				EndIf
				oModelFW:DeActivate()
			Else
				cMemoLog += ( STR0037 + (TABLANC)->NV4_COD ) + CRLF //"Despesa: "
				cMemoLog += ( STR0039 + AllToChar(cVldMsg) ) + CRLF //"Erro: "
				AutoGrLog(cMemoLog) //Grava o Log
				cMemoLog := ""  // Limpa a critica para o proximo TimeSheet
			EndIf

			IncProc(STR0036 + " " + AllTrim(Str(nCount)) + " / " + AllTrim(Str(nQtdNV4))) //#"Aguarde..."

			lRet := .T.  //Volta para .T. para validar o próximo TB
			(TABLANC)->( dbSkip())
		EndDo

		cMemoLog := CRLF + Replicate('-', 65) + CRLF
		If (nCountNV4) != 0
			cMemoLog += AllTrim(Str(nCountNV4)) + STR0020 + CRLF //" Lançamento(s) Tabelado(s) alterado(s) com sucesso!"
			EndIf
		If (nQtdNV4 - nCountNV4) != 0
			cMemoLog += AllTrim(Str(nQtdNV4 - nCountNV4)) + STR0041 + CRLF //# " Lançamento(s) Tabelado(s) não alterado(s)!"
		EndIf
		cMemoLog += Replicate('-', 65) + CRLF
		AutoGrLog(cMemoLog)
		JurSetLog(.T.)

		cAux := &( "{|| " + cDefFiltro + " }")  //Retorna o Filtro padrão - somente lançamentos ativos...
		(TABLANC)->( dbSetFilter( cAux, cDefFiltro ) )

		(TABLANC)->(DbGoTO(nPosicao))

		If lRet
			JA142ATU()
		EndIf
		JurLogLote()  // Mostra o Log da operação

	Else
		lRet := .F.
	EndIf

EndIf

RestArea( aArea )

Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} JA142ATU()
Atualiza a tela.

@author bruno.ritter
@since 27/03/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA142ATU()
Local aArea      := GetArea()
Local lJura027   := IsInCallStack( "JCall142" )
Local cAlias     := ""
Local aStruAdic  := {}
Local aCmpAcBrw  := {}
Local aTitCpoBrw := {}
Local aCmpNotBrw := {}

If !lJura027
	cAlias := oTmpTable:GetAlias()
	oTmpTable:Delete()

	aStruAdic  := J142StruAdic()
	aCmpAcBrw  := J142CmpAcBrw()
	aTitCpoBrw := J142TitCpoBrw()
	aCmpNotBrw := J142NotBrw()
	oTmpTable  := JurCriaTmp(cAlias, cQueryTmp, "NV4", , aStruAdic, aCmpAcBrw, aCmpNotBrw, , , aTitCpoBrw)[1]
EndIf

oBrw142:Refresh()
oBrw142:GoTop(.T.)

RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA142View()
Visualização do lançamento com base em tabela temporária.

@Params  nRecno  Recno da tabela NV4

@author bruno.ritter
@since 12/04/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA142VIEW(nRecno)
Local aArea    := GetArea()
Local aAreaNV4 := NV4->(GetArea())

NV4->(DbGoTO(nRecno))
If NV4->(NV4_FILIAL + NV4_COD) == (TABLANC)->(NV4_FILIAL + NV4_COD)
	FWExecView(STR0002, 'JURA027', 1,, { || lOk := .T., lOk }) // #"Visualizar"
Else
	JurMsgErro( STR0042 ) //"Registro não encontrado!"
EndIf

RestArea( aAreaNV4 )
RestArea( aArea )

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} J142AtuBrw
Atualiza o browse com o novo filtro.

@param    cQuery , caracter, Query que será usada como filtro

@return   lFecha, lógico, Indica se a tela de filtro deve ser fechada

@author   Jorge Martins
@since    20/04/2018
@version  1.0
/*/
//-------------------------------------------------------------------
Static Function J142AtuBrw(cQuery)
	Local aArea      := GetArea()
	Local cAlsBrw    := oTmpTable:GetAlias()
	Local aStruAdic  := {}
	Local aCmpAcBrw  := {}
	Local aTitCpoBrw := {}
	Local aCmpNotBrw := {}
	Local lEmpty     := .F.
	Local cTmpQry    := GetNextAlias()
	Local lFecha     := .T.

	// Executa a query da tabela temporária para verificar se está vazia.
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cTmpQry, .T., .T.)

	lEmpty := (cTmpQry)->( EOF() )
	(cTmpQry)->(dbCloseArea())

	If lEmpty
		If !IsBlind()
			lFecha := JurMsgErro(STR0047) // "Não foram encontrados registros para o filtro indicado!"
		EndIf
	Else
		oTmpTable:Delete()

		aStruAdic  := J142StruAdic()
		aCmpAcBrw  := J142CmpAcBrw()
		aTitCpoBrw := J142TitCpoBrw()
		aCmpNotBrw := J142NotBrw()
		oTmpTable  := JurCriaTmp(cAlsBrw, cQuery, "NV4", , aStruAdic, aCmpAcBrw, aCmpNotBrw, , , aTitCpoBrw)[1]
		oBrw142:Refresh(.T.)
	EndIf

	RestArea(aArea)

Return lFecha

//-------------------------------------------------------------------
/*/{Protheus.doc} J142QryTmp()
Rotina para gerar uma query da NV4 para criar a tabela temporária
na função JurCriaTmp

@param    aFiltros , array, Array com os filtros que serão aplicados

@return   cQry , caracter, Query filtrada para seleção dos registros

@author   Jorge Martins
@since    20/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J142QryTmp( aFiltros )
	Local cQry       := ""
	Local cJoinCont  := ""
	Local cNvCampos  := ""

	cNvCampos := " , NV4.R_E_C_N_O_ REC "

	cQry := J027QryTmp(cNvCampos)

	If ! Empty( aFiltros[nPContr] ) // 5 - Contrato
		cJoinCont := " INNER JOIN "
	Else
		cJoinCont := " LEFT JOIN "
	EndIf

	cQry += cJoinCont + RetSqlName("NUT") + " NUT "
	cQry +=                              " ON NUT.NUT_FILIAL = '" + xFilial("NUT") + "' "
	cQry +=                             " AND NUT.NUT_CCLIEN = NV4.NV4_CCLIEN "
	cQry +=                             " AND NUT.NUT_CLOJA  = NV4.NV4_CLOJA "
	cQry +=                             " AND NUT.NUT_CCASO  = NV4.NV4_CCASO "
	cQry +=                             " AND NUT.D_E_L_E_T_ = ' ' "
		If ! Empty( aFiltros[nPContr] ) // 5 - Contrato
		cQry +=                         " AND NUT.NUT_CCONTR = '" + aFiltros[nPContr] + "' " // 5 - Contrato
	EndIf

	cQry += " WHERE NV4.NV4_FILIAL = '" + xFilial( "NV4" ) + "'"
	cQry +=   " AND NV4.NV4_SITUAC = '1' "
	cQry +=   " AND NV4.D_E_L_E_T_ = ' ' "

	If !Empty( aFiltros[nPGrCli] ) .And. ( Empty( aFiltros[nPClien] ) .And. Empty( aFiltros[nPLoja] ) ) // 1 - Filtra Grupo - Apenas quando o Cliente e Loja estiverem vazios
		cQry += " AND NV4.NV4_CGRUPO = '" + aFiltros[nPGrCli] + "' "
	EndIf

	If !Empty( aFiltros[nPClien] ) // 2 - Filtra Cliente
		cQry += " AND NV4.NV4_CCLIEN = '" + aFiltros[nPClien] + "' "
	EndIf

	If !Empty( aFiltros[nPLoja] ) // 3 - Filtra Loja
		cQry += " AND NV4.NV4_CLOJA = '" + aFiltros[nPLoja] + "' "
	EndIf

	If !Empty( aFiltros[nPCaso] ) // 4 - Filtra Caso
		cQry += " AND NV4.NV4_CCASO = '" + aFiltros[nPCaso] + "' "
	EndIf

	If !Empty( aFiltros[nPDtIni] ) .And. !Empty(aFiltros[nPDtInc]) // 6 - Data inicial //13 - Data de inclusão/conclusão
		cQry += " AND NV4." + aFiltros[nPDtInc] + " >= '" + DtoS( aFiltros[nPDtIni] ) + "' "
	EndIf

	If !Empty( aFiltros[nPDtFim] ) .And. !Empty(aFiltros[nPDtInc]) // 7 - Data Final  //13 - Data de inclusão/conclusão
		cQry += " AND NV4." + aFiltros[nPDtInc] + " <= '" + DtoS( aFiltros[nPDtFim] ) + "' "
	EndIf

	If !Empty( aFiltros[nPTipo] ) // 8 - Tipo de Atividade
		cQry += " AND NV4.NV4_CTPSRV = '" + aFiltros[nPTipo] + "' "
	EndIf

	If !Empty( aFiltros[nPCobra] ) // 9 - Cobrar no Tabelado?
		cQry += " AND NV4.NV4_COBRAR = '" + aFiltros[nPCobra] + "' "
	EndIf

	cQry +=     " AND ( NUT.NUT_CCONTR IS NULL OR "
	cQry +=           " EXISTS ( "
	cQry +=                      " SELECT NT0.NT0_COD FROM " + RetSqlName( 'NT0' ) + " NT0 "
	cQry +=                       " WHERE NT0.NT0_FILIAL = '" + xFilial("NT0") + "' "
	cQry +=                         " AND NT0.NT0_COD    = NUT.NUT_CCONTR "
	cQry +=                         " AND NT0.NT0_ATIVO  = '1' "
	cQry +=                         " AND NT0.NT0_SERTAB = '1' "
	cQry +=                         " AND NT0.D_E_L_E_T_ = ' ' "
	cQry +=                  " ) "
	cQry +=           " ) "

Return cQry

//-------------------------------------------------------------------
/*/{Protheus.doc} J142StruAdic
Estrutura adicional para incluir na tabela temporária caso exista na query. - Opcional
        Ex: aStruAdic[n][1] "NVE_SITUAC"     //Nome do campo
            aStruAdic[n][2] "Situação"       //Descrição do campo
            aStruAdic[n][3] "C"              //Tipo
            aStruAdic[n][4] 1                //Tamanho
            aStruAdic[n][5] 0                //Decimal
            aStruAdic[n][6] "@X"             //Picture

@return aStruAdic, array, Campos da estutrura adicional

@author  Jorge Martins
@since   20/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function  J142StruAdic()
	Local aStruAdic := {}

	Aadd(aStruAdic, { "REC", "REC", "N", 100, 0, ""} )

Return ( aStruAdic )

//-------------------------------------------------------------------
/*/{Protheus.doc} J142CmpAcBrw
Monta array simples de campos onde o X3_BROWSE está como NÃO e devem
ser considerados no Browse (independentemente do seu uso)

@return aCmpAcBrw, array, Campos onde o X3_BROWSE está como NÃO e devem
		ser considerados no Browse

@author  Jorge Martins
@since   20/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J142CmpAcBrw()
	Local aCmpAcBrw := {}

	aCmpAcBrw := {"NV4_COBRAR"}

Return ( aCmpAcBrw )

//-------------------------------------------------------------------
/*/{Protheus.doc} J142TitCpoBrw
Monta array com para considerar títulos de campos diferentes do SX3

@return aTitCpoBrw, array, Títulos a ser considerados no browse

@author  Jorge Martins
@since   20/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J142TitCpoBrw()
	Local aTitCpoBrw := {}

	Aadd(aTitCpoBrw, {"NT0_COD", STR0048}) // "Cód. Contrato"

Return ( aTitCpoBrw )

//-------------------------------------------------------------------
/*/{Protheus.doc} J142NotBrw
Monta array para remover campos do browse

@return aCmpNotBrw, array, Campos para não aparecer no browse

@author  Jorge Martins
@since   20/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J142NotBrw()
	Local aCmpNotBrw := {}
	Local cLojaAuto  := SuperGetMv( "MV_JLOJAUT", .F., "2", ) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)

	Aadd(aCmpNotBrw, "REC")
	Aadd(aCmpNotBrw, "NV4_ACAOLD")
	Aadd(aCmpNotBrw, "NV4_CCLILD")
	Aadd(aCmpNotBrw, "NV4_CLJLD")
	Aadd(aCmpNotBrw, "NV4_CCSLD")
	Aadd(aCmpNotBrw, "NV4_PARTLD")
	Aadd(aCmpNotBrw, "NV4_CMOTWO")
	Aadd(aCmpNotBrw, "NV4_OBSWO")
	Aadd(aCmpNotBrw, "NV4_CDWOLD")

	If (cLojaAuto == "1")
		Aadd(aCmpNotBrw, "NV4_CLOJA")
	EndIf

Return ( aCmpNotBrw )
