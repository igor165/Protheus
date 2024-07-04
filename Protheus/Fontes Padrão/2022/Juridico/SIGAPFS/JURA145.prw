#INCLUDE "JURA145.CH"
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
#DEFINE nPCobraLan 9
#DEFINE nPCobraTip 10
#DEFINE nPCobraCtr 11
#DEFINE nPCobraCli 12
Static _lFwPDCanUse := FindFunction("FwPDCanUse")

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA145
Inclusão de WO - Time Sheets

@author David Gonçalves Fernandes
@since 29/12/2009
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA145(cPreft)
	Local lJura144      := FWIsInCallStack( "JCall145" ) .Or. FWIsInCallStack( "JURA202" )
	Local lVldUser      := Iif(FindFunction("JurVldUxP"), JurVldUxP(), .T.)
	
	Default cPreft      := ""

	Private cQueryTmp   := ""
	Private oBrw145     := Nil
	Private lMarcar     := .F.
	Private oTmpTable   := Nil
 	Private TABLANC     := ""
	Private cDefFiltro  := ""
	
	If lVldUser
		If !lJura144 .And. ExistFunc( "JurFiltrWO" )
			JurFiltrWO("NUE") //Filtro
			If Type( "oTmpTable" ) == "O"
				oTmpTable:Delete() //Apaga a Tabela temporária
			EndIf
		Else
			TABLANC     := "NUE"
			cDefFiltro  := "NUE_SITUAC == '1'"
	
			If !Empty(cPreft) .And. IsInCallStack( 'JURA202' )
				cDefFiltro += " .AND. NUE_CPREFT == '" + cPreft + "' "
			EndIf

			oBrw145 := FWMarkBrowse():New()
			If !IsInCallStack( 'JURA144' ) .And. !IsInCallStack( 'JURA202' )
				oBrw145:SetDescription( STR0007 )
			Else
				oBrw145:SetDescription( STR0012 )
			EndIf
	
			oBrw145:SetAlias( TABLANC )
			oBrw145:SetMenuDef( "JURA145" ) // Redefine o menu a ser utilizado
			oBrw145:SetLocate()
			oBrw145:SetFilterDefault( cDefFiltro )
			oBrw145:SetFieldMark( 'NUE_OK' )
			oBrw145:bAllMark := { || JurMarkALL(oBrw145, "NUE", 'NUE_OK', lMarcar := !lMarcar,,.F.), oBrw145:Refresh() }
			JurSetLeg( oBrw145, "NUE" )
			JurSetBSize( oBrw145 )
			oBrw145:Activate()
		EndIf
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JUR145BrwR
Função para executar um processa para abrir o browse (JUR145Brw)

@param   aFiltros , array , Campos e valores de filtros
@param   lAtualiza, logico, Reabre browse com novos filtros

@author  Bruno Ritter
@since   19/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JUR145BrwR(cPreft, aFiltros, lAtualiza)
Local lRet := .F.

FWMsgRun( , {|| lRet := JUR145Brw(cPreft, aFiltros, lAtualiza)}, STR0089, STR0090 ) // "Processando" - "Processando a rotina..."

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JUR145Brw
Função para montar o browse de WO com filtros

@param   aFiltros , array , Campos e valores de filtros
@param   lAtualiza, logico, Reabre browse com novos filtros

@author  Bruno Ritter
@since   18/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JUR145Brw(cPreft, aFiltros, lAtualiza)
Local aTemp         := {}
Local aFields       := {}
Local aOrder        := {}
Local aFldsFilt     := {}
Local aStruAdic     := {}
Local aCmpAcBrw     := {}
Local aTitCpoBrw    := {}
Local aCmpNotBrw    := {}
Local bseek         := {||}
Local lRet          := .T.

Default cPreft      := ''
Default aFiltros    := Array(12)
Default lAtualiza   := .F.

	cQueryTmp := J145QryTmp( aFiltros )

	If lAtualiza
		lRet := J145AtuBrw(cQueryTmp)

	Else
		If !Empty(cPreft) .And. FWIsInCallStack( 'JURA202' )
			cDefFiltro := "NUE_CPREFT == '" + cPreft + "' "
		EndIf

		aStruAdic  := J145StruAdic()
		aCmpAcBrw  := J145CmpAcBrw()
		aTitCpoBrw := J145TitCpoBrw()
		aCmpNotBrw := J145NotBrw()
		aTemp      := JurCriaTmp(GetNextAlias(), cQueryTmp, "NUE", , aStruAdic, aCmpAcBrw, aCmpNotBrw, , , aTitCpoBrw)
		oTmpTable  := aTemp[1]
		aFldsFilt  := aTemp[2]
		aOrder     := aTemp[3]
		aFields    := aTemp[4]
		TABLANC    := oTmpTable:GetAlias()

		If (TABLANC)->( Eof() )
			lRet := JurMsgErro(STR0081) // "Não foram encontrados dados!"
		Else
			oBrw145 := FWMarkBrowse():New()
			If !FWIsInCallStack( 'JURA144' ) .And. !FWIsInCallStack( 'JURA202' )
				oBrw145:SetDescription( STR0007 ) // "Inclusão de WO - Time-Sheets"
			Else
				oBrw145:SetDescription( STR0012 ) // "Operações em lote - Time-sheets"
			EndIf

			oBrw145:SetAlias( TABLANC )
			oBrw145:SetTemporary( .T. )
			oBrw145:SetFields(aFields)

			oBrw145:oBrowse:SetDBFFilter(.T.)
			oBrw145:oBrowse:SetUseFilter()
			//------------------------------------------------------
			// Precisamos trocar o Seek no tempo de execucao,pois
			// na markBrowse, ele não deixa setar o bloco do seek
			// Assim nao conseguiriamos  colocar a filial da tabela
			//------------------------------------------------------

			bseek := {|oSeek| MySeek(oSeek, oBrw145:oBrowse)}
			oBrw145:oBrowse:SetIniWindow({|| oBrw145:oBrowse:oData:SetSeekAction(bseek)})
			oBrw145:oBrowse:SetSeek(.T., aOrder)

			oBrw145:oBrowse:SetFieldFilter(aFldsFilt)
			oBrw145:oBrowse:bOnStartFilter := Nil

			oBrw145:SetMenuDef( 'JURA145' )
			oBrw145:SetLocate()
			oBrw145:SetFilterDefault( cDefFiltro )
			oBrw145:SetFieldMark( 'NUE_OK' )
			oBrw145:bAllMark := { || JurMarkALL(oBrw145, TABLANC, 'NUE_OK', lMarcar := !lMarcar, , .F.), oBrw145:Refresh() }
			JurSetLeg( oBrw145, "NUE" )
			JurSetBSize( oBrw145 )
			
			If Len(aTemp) >= 7 .And. !Empty(aTemp[7]) // Tratamento para LGPD verifica os campos que devem ser ofuscados
				oBrw145:oBrowse:SetObfuscFields(aTemp[7])
			EndIf

			oBrw145:Activate()
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
Local lJura144 := FWIsInCallStack( "JCall145" )
Local cView    := Iif(lJura144, "JA145View((TABLANC)->(Recno()))", "JA145View((TABLANC)->REC)")

aAdd( aRotina, { STR0002, cView, 0, 2, 0, NIL } ) // "Visualizar"

If !FWIsInCallStack( 'JURA202' )
	If !lJura144 .And. FWIsInCallStack( 'JURA145' ) .And. ExistFunc( "JurFiltrWO" )
		aAdd( aRotina, { STR0082, 'JurFiltrWO("NUE", .T.)', 0, 3, 0, NIL } ) // "Filtros"
	EndIf

	aAdd( aRotina, { STR0013, "JA145SET()", 0, 6, 0, NIL } ) // "WO"
EndIf

If FWIsInCallStack( 'JURA144' )
	aAdd( aRotina, { STR0014, "JA145DLG()"      , 0, 6, 0, .T. } ) // "Alterar lote"
	aAdd( aRotina, { STR0015, "JA145REV()"      , 0, 6, 0, NIL } ) // "Reval. lote"
EndIf

If FWIsInCallStack( 'JURA202' )
	aAdd( aRotina, { STR0014, "JA145DLG()", 0, 6, 0, .T. } ) // "Alterar lote"
EndIf

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} J145AtuBrw
Atualiza o browse com o novo filtro.

@param    cQuery , caracter, Query que será usada como filtro

@author   Bruno Ritter
@since    18/04/2018
@version  1.0
/*/
//-------------------------------------------------------------------
Static Function J145AtuBrw(cQuery)
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
			lFecha := JurMsgErro(STR0081) // "Não foram encontrados registros para o filtro indicado!"
		EndIf
	Else
		oTmpTable:Delete()

		aStruAdic  := J145StruAdic()
		aCmpAcBrw  := J145CmpAcBrw()
		aTitCpoBrw := J145TitCpoBrw()
		aCmpNotBrw := J145NotBrw()
		oTmpTable  := JurCriaTmp(cAlsBrw, cQuery, "NUE", , aStruAdic, aCmpAcBrw, aCmpNotBrw, , , aTitCpoBrw)[1]
		oBrw145:Refresh(.T.)
	EndIf

	RestArea(aArea)

Return lFecha

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Time Sheets dos Profissionais

@author Felipe Bonvicini Conti
@since 17/06/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView      := Nil
Local oModel     := FWLoadModel( "JURA145" )
Local oStructNUE := FWFormStruct( 2, "NUE" )
Local cLojaAuto  :=  SuperGetMv( "MV_JLOJAUT", .F., "2", ) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)

Iif(cLojaAuto == "1", oStructNUE:RemoveField( "NUE_CLOJA" ), )

JurSetAgrp( 'NUE',, oStructNUE )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA145_NUE", oStructNUE, "NUEMASTER"  )
oView:CreateHorizontalBox( "NUEFIELDS", 100 )
oView:SetOwnerView( "JURA145_NUE", "NUEFIELDS" )

oView:SetDescription( oView:SetDescription( Iif(FWIsInCallStack('JURA144'), STR0012, STR0007)  ) ) // #"Operações em lote - Time-sheets" ##"Inclusão de WO - Time-Sheets"
oView:EnableControlBar( .T. )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Time Sheets dos Profissionais

@author Felipe Bonvicini Conti
@since 17/06/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel        := NIL
Local oStructNUE    := FWFormStruct( 1, "NUE" )

oModel:= MPFormModel():New( "JURA145", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:AddFields( "NUEMASTER", NIL, oStructNUE, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( STR0008 ) // "Modelo de Dados de Time Sheets dos Profissionais"
oModel:GetModel( "NUEMASTER" ):SetDescription( STR0009 ) // "Dados de Time Sheets dos Profissionais"
JurSetRules( oModel, "NUEMASTER",, "NUE",,  )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JA145SET
Envia os Lançamentos para WO: Cria um registro na Tabela de WO,
vincula os lançamentos ao número do WO e
atualiza o valor dos lançamentos na tabela WO Caso

@param 	cTipo  	Tipo da alteração a ser executada nos time-Sheets

@author David Gonçalves Fernandes
@since 07/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA145SET()
Local lRet       := .T.
Local aArea      := GetArea()
Local cMarca     := oBrw145:Mark()
Local lInvert    := oBrw145:IsInvert()
Local nCountNUE  := 0
Local cFiltro    := ''
Local cMsg       := ''
Local aOBS       := {}

cFiltro   := oBrw145:FWFilter():GetExprADVPL()

If Empty(cFiltro)
	cFiltro += "(NUE_OK " + Iif(lInvert, "<>", "==" ) + " '" + cMarca + "')"
Else
	cFiltro += " .And. (NUE_OK " + Iif(lInvert, "<>", "==" ) + " '" + cMarca + "')"
EndIf

cAux := &( '{|| ' + cFiltro + ' }')
(TABLANC)->( dbSetFilter( cAux, cFiltro ) )
(TABLANC)->( dbSetOrder(1) )
(TABLANC)->( dbgotop() )

If (TABLANC)->(EOF())
	lRet := JurMsgErro(STR0046) //"Não há dados marcados para execução em lote!"
EndIf

If lRet .And. MsgYesNo( STR0053 )  //"Todos os registros marcados serão alterados. Deseja Continuar?"
	aOBS := JurMotWO('NUF_OBSEMI', STR0007, STR0056, "1") // "Inclusão de WO - Time-Sheets" - "Observação - WO"
	If !Empty(aOBS)
		nCountNUE := JAWOLANCTO(1, aOBS, cFiltro, cDefFiltro, TABLANC)
		cMsg := Alltrim(Str(nCountNUE)) + STR0011 //" lançamentos alterados."
		lRet := nCountNUE > 0
	Else
		lRet := .F.
	EndIf
Else
	lRet := .F.
EndIf

cAux := &( "{|| " + cDefFiltro + " }")  //Retorna o Filtro padrão - somente lançamentos ativos...
(TABLANC)->( dbSetFilter( cAux, cDefFiltro ) )

If !Empty(cMsg)
	If JurGetLog()
		AutoGrLog( cMsg )
		JurLogLote() // Mostra o Log da operação
	Else
		JurLogLote() //Descarta o arquivo de log utlizado
		ApMsgInfo( cMsg )
	EndIf
EndIf

If lRet
	JA145ATU()
EndIf

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA145DLG()
Monta a tela para Alteração de Time Sheets.

@author Luciano Pereira dos Santos
@since 09/08/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA145DLG()
Local cMarca      := oBrw145:Mark()
Local lInvert     := oBrw145:IsInvert()
Local cFilBkpNUE  := ""
Local cFiltro     := oBrw145:FWFilter():GetExprADVPL()
Local aArea       := GetArea()
Local lRet        := .T.
Local cLojaAuto   := SuperGetMv( "MV_JLOJAUT", .F., "2", ) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
Local nLocLj      := 0
Local cJcaso      := SuperGetMv("MV_JCASO1", .F., '1')  //1 – Por Cliente; 2 – Independente de cliente
Local oScroll     := Nil
Local oPanel      := Nil
Local oDlg        := Nil
Local oLayer      := Nil
Local oMainColl   := Nil
Local nSizeTela   := 0
Local nTamDialog  := 0
Local nLargura    := 260
Local nAltura     := 310
Local aSize       := {}
Local cF3Tarefa   := IIf(GetSx3Cache("NUE_CTAREF", "X3_F3") == "NUENRZ", "NUENRZ", "NRZ")
Local aCposLGPD   := {}
Local aNoAccLGPD  := {}
Local aDisabLGPD  := {}
Local lExecTir    := __CUSERID == "000481" .And. CUSERNAME == "PFSCOMPART" .And. GetRemoteType() == REMOTE_HTML // Execução via TIR

Private oCliOr    := Nil
Private oDesCli   := Nil
Private oLojaOr   := Nil
Private oCasoOr   := Nil
Private oDesCas   := Nil
Private oAdv      := Nil
Private oDesAdv   := Nil
Private oAtiv     := Nil
Private oDesAtiv  := Nil
Private oUTR      := Nil
Private oHsR      := Nil
Private oTmpR     := Nil
Private oDataTs   := Nil
Private oRetif    := Nil
Private oDesRet   := Nil
Private oFase     := Nil
Private oDesFas   := Nil
Private oTaref    := Nil
Private oDesTar   := Nil
Private oCobrar   := Nil
Private oRevisado := Nil

Private oChkCli   := Nil
Private oChkAdv   := Nil
Private oChkAtiv  := Nil
Private oChkUtr   := Nil
Private oChkDt    := Nil
Private oChkRet   := Nil
Private oChkCob   := Nil
Private oChkRev   := Nil
Private oDAtEbi   := Nil

Private cCliOr    := CriaVar('A1_COD', .F.)
Private cDesCli   := ""
Private cLojaOr   := CriaVar('A1_LOJA', .F.)
Private cCliGrp   := CriaVar('A1_GRPVEN', .F.)
Private cCasoOr   := CriaVar('NUE_CCASO', .F.)
Private cDesCas   := ""
Private cDesAdv   := ""
Private cAtiv     := CriaVar('NUE_CATIVI', .F.)
Private cDesAtiv  := ""
Private nUTR      := CriaVar('NUE_UTR', .F.)
Private cHsR      := Transform(PADL("0", TamSX3('NUE_HORAR')[1], '0'), PesqPict("NUE", "NUE_HORAR"))
Private nTmpR     := CriaVar('NUE_TEMPOR', .F.)
Private dDataTs   := CToD( '  /  /  ' )
Private cRetif    := CriaVar('NUE_CRETIF', .F.)
Private cDesRet   := ""
Private cFase     := CriaVar('NUE_CFASE', .F.)
Private cDesFas   := ""
Private cTaref    := CriaVar('NUE_CTAREF', .F.)
Private cDesTar   := ""
Private cSigla    := CriaVar('NUE_SIGLA2', .F.)
Private cAtvEbi   := CriaVar('NUE_CTAREB', .F.)
Private cDAtEbi   := ""
Private cCobrar   := CriaVar('NUE_COBRAR', .F.)
Private cRevisado := CriaVar('NUE_REVISA', .F.)

// Variáveis usadas na consulta padrão NVELOJ
Private cGetClie  := Criavar( 'A1_COD', .F.)
Private cGetLoja  := Criavar( 'A1_LOJA', .F. )

Private lChkCli   := lExecTir
Private lChkAdv   := lExecTir
Private lChkAtiv  := lExecTir
Private lChkUtr   := lExecTir
Private lChkDt    := lExecTir
Private lChkRet   := lExecTir
Private lChkCob   := lExecTir
Private lChkRev   := lExecTir

If Empty(cFiltro)
	cFiltro += "(NUE_OK " + Iif(lInvert, "<>", "==" ) + " '" + cMarca + "')" + " .AND. (NUE_FILIAL = '" + xFilial( "NUE" ) + "')"
Else
	cFiltro += " .And. (NUE_OK " + Iif(lInvert, "<>", "==" ) + " '" + cMarca + "')" + " .AND. (NUE_FILIAL = '" + xFilial( "NUE" ) + "')"
EndIf
cFilBkpNUE  := (TABLANC)->( dbFilter() )
cAux := &( '{|| ' + cFiltro + ' }')
(TABLANC)->( dbSetFilter( cAux, cFiltro ) )
(TABLANC)->( dbSetOrder(1) )
(TABLANC)->( dbgotop() )

If (TABLANC)->(EOF())
	lRet := JurMsgErro(STR0046) //"Não há dados marcados para execução em lote!"
EndIf

If lRet

	If _lFwPDCanUse .And. FwPDCanUse(.T.)
		aCposLGPD := {"NUE_DCLIEN","NUE_DCASO","NUE_DPART2","NUE_DATIVI","NUE_DRETIF","NUE_DTAREB","NUE_DFASE"}

		aDisabLGPD := FwProtectedDataUtil():UsrNoAccessFieldsInList(aCposLGPD)
		AEval(aDisabLGPD, {|x| AAdd( aNoAccLGPD, x:CFIELD)})

	EndIf
	// Retorna o tamanho da tela
	aSize     := MsAdvSize(.F.)
	nSizeTela := ((aSize[6]/2)*0.85) // Diminui 15% da altura.

	JurFreeArr(aSize)

	If nAltura > 0 .And. nSizeTela < nAltura
		nTamDialog := nSizeTela
	Else
		nTamDialog := nAltura
	EndIf

	oDlg := FWDialogModal():New()
	oDlg:SetFreeArea(nLargura, nTamDialog)
	oDlg:SetBackground(.T.)  // Escurece o fundo da janela
	oDlg:SetTitle(STR0016)   //"Alteração de Time Sheets em lote"
	oDlg:CreateDialog()
	oDlg:AddOkButton({|| IIf(JA145ALT(), oDlg:oOwner:End(), Nil)})
	oDlg:AddCloseButton({|| oDlg:oOwner:End() }) //"Cancelar"

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

	// "Ativar"//
	oChkCli := TJurCheckBox():New(015, 005, "", {|| }, oMainColl, 08, 08, , {|| }, , , , , , .T., , , )
	oChkCli:SetCheck(lChkCli)
	oChkCli:bChange := {|| lChkCli := oChkCli:Checked(),;
						JurChkCli(@oCliOr, @cCliOr, @oLojaOr, @cLojaOr, @oDesCli, @cDesCli, @oCasoOr, @cCasoOr, @oDesCas, @cDesCas, lChkCli),;
						J145VLDCLI()}

	// "Cód Cliente" //
	oCliOr := TJurPnlCampo():New(005, 015, 060, 022, oMainColl, AllTrim(RetTitle("NUE_CCLIEN")) ,("A1_COD"),{|| },{|| },,,,'SA1NUH')
	oCliOr:SetValid({|| J145VLDCLI("CLI") })
	oCliOr:SetWhen({|| lChkCli})

	// "Loja" //
	oLojaOr := TJurPnlCampo():New(005, 085, 045, 022, oMainColl, AllTrim(RetTitle("NUE_CLOJA")), ("A1_LOJA"), {|| }, {|| },,,)
	oLojaOr:SetValid({|| J145VLDCLI("LOJ") })
	oLojaOr:SetWhen({|| lChkCli})
	If (cLojaAuto == "1")
		oLojaOr:Hide()
		nLocLj := 45
	EndIf

	// "NOME CLIENTE" //
	oDesCli := TJurPnlCampo():New(005, 130 - nLocLj, 120 + nLocLj, 022, oMainColl, AllTrim(RetTitle("NUE_DCLIEN")), ("A1_NOME"), {|| }, {|| },,,,,,,,,aScan(aNoAccLGPD,"NUE_DCLIEN") > 0)
	oDesCli:SetWhen({|| .F.})

	//----------------

	// "CÓD CASO" //
	oCasoOr := TJurPnlCampo():New(030, 015, 060, 022, oMainColl, AllTrim(RetTitle("NUE_CCASO")), ("NUE_CCASO"), {|| }, {|| },,,, 'NVELOJ')
	oCasoOr:SetValid({|| JurTrgGCLC(,, @oCliOr, @cCliOr, @oLojaOr, @cLojaOr, @oCasoOr, @cCasoOr, "CAS",;
	                                ,, @oDesCli, @cDesCli, @oDesCas, @cDesCas, "NVE_LANTS") })
	oCasoOr:SetWhen({||lChkCli .AND. ((cJcaso == "1" .AND. !Empty(cLojaOr)) .OR. cJcaso == "2")})

	// "TÍTULO CASO" //
	oDesCas := TJurPnlCampo():New(030, 085, 165, 022, oMainColl, AllTrim(RetTitle("NUE_DCASO")), ("NUE_DCASO"), {|| }, {|| },,,,,,,,,aScan(aNoAccLGPD,"NUE_DCASO") > 0)
	oDesCas:SetWhen({|| .F.})

	//-----------------

	// "Ativar" //
	oChkAdv := TJurCheckBox():New(065, 005, "",  {|| }, oMainColl, 08, 08, ,{|| } , , , , , , .T., , , )
	oChkAdv:SetCheck(lChkAdv)
	oChkAdv:bChange := {||lChkAdv := oChkAdv:Checked(), JurValAdv(@cSigla,@oAdv, @cDesAdv, @oDesAdv)}

	// "Sigla Adv." //
	oAdv := TJurPnlCampo():New(055, 015, 060, 022, oMainColl, AllTrim(RetTitle("NUE_SIGLA2")), ("NUE_SIGLA2"), {|| }, {|| },,,, 'RD0ATV')
	oAdv:SetValid({|| JurDesAdv(cSigla, @cDesAdv, @oDesAdv)})
	oAdv:SetWhen({|| lChkAdv})
	oAdv:SetChange ({|| cSigla := oAdv:GetValue(), oDesAdv:SetValue(Posicione('RD0', 9, xFilial('RD0') + Alltrim(cSigla), 'RD0_NOME')) })

	// "Nome Adv." //
	oDesAdv := TJurPnlCampo():New(055, 085, 165, 022, oMainColl, AllTrim(RetTitle("NUE_DPART2")), ("NUE_DPART2"), {|| }, {|| },,,,,,,,,aScan(aNoAccLGPD,"NUE_DPART2") > 0)
	oDesAdv:SetWhen({|| .F.})
	oDesAdv:SetChange ({|| cDesAdv := oDesAdv:GetValue()})

	//-----------------

	// "Ativar" //
	oChkAtiv := TJurCheckBox():New(090, 005, "", {|| }, oMainColl, 08, 08, , {|| } , , , , , , .T., , , )
	oChkAtiv:SetCheck(lChkAtiv)
	oChkAtiv:bChange := {|| lChkAtiv := oChkAtiv:Checked(), ValAtiv()}

	// "Cód Ativi" //
	oAtiv := TJurPnlCampo():New(080, 015, 060, 022, oMainColl, AllTrim(RetTitle("NUE_CATIVI")), ("NUE_CATIVI"), {|| }, {|| },,,, 'NRC')
	oAtiv:SetWhen({||lChkAtiv})
	oAtiv:SetValid({|| JurTrgEbil(cCliOr, cLojaOr,;
	                              @oAtiv, @cAtiv, @oDesAtiv, @cDesAtiv,;
	                              @oAtvEbi, @cAtvEbi, @oDAtEbi, @cDAtEbi,;
	                              @oFase, @cFase, @oDesFas, @cDesFas,;
	                              @oTaref, @cTaref, @oDesTar, @cDesTar, "ATIVJUR") })

	// "Desc Ativi" //
	oDesAtiv := TJurPnlCampo():New(080, 085, 165, 022, oMainColl, AllTrim(RetTitle("NUE_DATIVI")), ("NUE_DATIVI"), {|| }, {|| },,,,,,,,,aScan(aNoAccLGPD,"NUE_DATIVI") > 0)
	oDesAtiv:SetWhen({|| .F.})
	oDesAtiv:SetChange ({|| cDesAtiv := oDesAtiv:GetValue()})

	//-----------------

	// "Ativar" //
	oChkUtr := TJurCheckBox():New(115, 005, "", {|| }, oMainColl, 08, 08, , {|| } , , , , , , .T., , , )
	oChkUtr:SetCheck(lChkUtr)
	oChkUtr:bChange := {|| lChkUtr := oChkUtr:Checked(), ValUtr()}

	// "UT Revis." //
	oUTR := TJurPnlCampo():New(105, 015, 060, 022, oMainColl, AllTrim(RetTitle("NUE_UTR")), ("NUE_UTR"), {|| }, {|| },,,,)
	oUTR:SetValid({|| (J145VlUT() .Or. Empty(nUTR)) })
	oUTR:SetWhen({|| (J145WCPO('UTR') .And. lChkUtr) })
	oUTR:SetChange ({|| nUTR := oUTR:GetValue()})

	// "HH:MM Rev" //
	oHsR := TJurPnlCampo():New(105, 085, 060, 022, oMainColl, AllTrim(RetTitle("NUE_HORAR")), ("NUE_HORAR"), {|| }, {|| },,,,)
	oHsR:SetValid({|| (J145VlHS() .Or. Empty(cHsR)) })
	oHsR:SetWhen({|| (J145WCPO('HORAR') .And. lChkUtr) })
	oHsR:SetChange ({|| cHsR := oHsR:GetValue()})
	oHsR:SetValue(cHsR)

	// "Hora F Rev" //
	oTmpR := TJurPnlCampo():New(105, 155, 060, 022, oMainColl, AllTrim(RetTitle("NUE_TEMPOR")), ("NUE_TEMPOR"), {|| }, {|| },,,,)
	oTmpR:SetValid({|| (J145VlTP() .Or. Empty(nTmpR)) })
	oTmpR:SetWhen({|| (J145WCPO('TEMPOR') .And. lChkUtr) })
	oTmpR:SetChange({|| nTmpR := oTmpR:GetValue()})

	//-----------------

	// "Ativar" //
	oChkDt := TJurCheckBox():New(140, 005, "",  {|| }, oMainColl, 08, 08, , {|| } , , , , , , .T., , , )
	oChkDt:SetCheck(lChkDt)
	oChkDt:bChange := {|| lChkDt := oChkDt:Checked(), ValDt()}

	// "Nova Data" //
	oDataTs := TJurPnlCampo():New(130, 015, 060, 022, oMainColl, STR0029, ("NUE_DATATS"), {|| }, {|| },,,,)
	oDataTs:SetValid({|| ValDt() })
	oDataTs:SetWhen({|| lChkDt })
	oDataTs:SetChange ({|| dDataTs := oDataTs:GetValue()})

	//--------------------

	// "Ativar" //
	oChkRet := TJurCheckBox():New(165, 005, "", {|| }, oMainColl, 08, 08, , {|| } , , , , , , .T., , , )
	oChkRet:SetCheck(lChkDt)
	oChkRet:bChange := {||lChkRet := oChkRet:Checked(), ValRet()}

	// "Cód Retifica" //
	oRetif := TJurPnlCampo():New(155, 015, 060, 022,oMainColl, AllTrim(RetTitle("NUE_CRETIF")), ("NUE_CRETIF"), {|| }, {|| },,,, 'NSB')
	oRetif:SetValid({|| DesRet() })
	oRetif:SetWhen({|| lChkRet })
	oRetif:SetChange ({|| cRetif := oRetif:GetValue(), oDesRet:SetValue(JurGetDados("NSB", 1, xFilial("NSB") + cRetif, "NSB_DESC")) })

	// "Des Retifica" //
	oDesRet := TJurPnlCampo():New(155, 085, 165, 022, oMainColl, AllTrim(RetTitle("NUE_DRETIF")), ("NUE_DRETIF"), {|| }, {|| },,,,,,,,,aScan(aNoAccLGPD,"NUE_DRETIF") > 0)
	oDesRet:SetWhen({|| .F. })
	oDesRet:SetChange ({|| cDesRet := oDesRet:GetValue()})

	//--------------------

	// "Cod Ativ Ebi" //
	oAtvEbi := TJurPnlCampo():New(180, 015, 060, 022, oMainColl, AllTrim(RetTitle("NUE_CTAREB")), ("NUE_CTAREB"), {|| }, {|| },,,, 'NS0')
	oAtvEbi:SetWhen({|| JAUSAEBILL(cCliOr, cLojaOr) })
	oAtvEbi:SetValid({|| JurTrgEbil(cCliOr, cLojaOr,;
	                                @oAtiv, @cAtiv, @oDesAtiv, @cDesAtiv,;
	                                @oAtvEbi, @cAtvEbi, @oDAtEbi, @cDAtEbi,;
	                                @oFase, @cFase, @oDesFas, @cDesFas,;
	                                @oTaref, @cTaref, @oDesTar, @cDesTar, "ATIVEBI") })

	// "Des Ativ Ebi" //
	oDAtEbi := TJurPnlCampo():New(180, 085, 165, 022, oMainColl, AllTrim(RetTitle("NUE_DTAREB")), ("NUE_DTAREB"), {|| }, {|| },,,,,,,,,aScan(aNoAccLGPD,"NUE_DTAREB") > 0)
	oDAtEbi:SetWhen({|| .F. })
	oDAtEbi:SetChange({|| cDAtEbi := oDAtEbi:GetValue()})

	//-------------------

	// "Cód Fase" //
	oFase := TJurPnlCampo():New(205, 015, 060, 022, oMainColl, AllTrim(RetTitle("NUE_CFASE")), ("NUE_CFASE"), {|| }, {|| },,,, 'NRY')
	oFase:SetWhen({|| JAUSAEBILL(cCliOr,cLojaOr) })
	oFase:SetValid({|| JurTrgEbil(cCliOr, cLojaOr,;
	                              @oAtiv, @cAtiv, @oDesAtiv, @cDesAtiv,;
	                              @oAtvEbi, @cAtvEbi, @oDAtEbi, @cDAtEbi,;
	                              @oFase, @cFase, @oDesFas, @cDesFas,;
	                              @oTaref, @cTaref, @oDesTar, @cDesTar, "FASE") })

	// "Desc Fase" //
	oDesFas := TJurPnlCampo():New(205, 085, 165, 022, oMainColl, AllTrim(RetTitle("NUE_DFASE")), ("NUE_DFASE"), {|| }, {|| },,,,,,,,,aScan(aNoAccLGPD,"NUE_DFASE") > 0)
	oDesFas:SetWhen({|| .F. })
	oDesFas:SetChange ({|| cDesFas := oDesFas:GetValue()})

	//-------------------

	// "Cód Tarefa" //
	oTaref := TJurPnlCampo():New(230, 015, 060, 022, oMainColl, AllTrim(RetTitle("NUE_CTAREF")), ("NUE_CTAREF"), {|| }, {|| },,,, cF3Tarefa)
	oTaref:SetWhen({|| (JAUSAEBILL(cCliOr, cLojaOr) .And. !Empty(cFase)) })
	oTaref:SetValid({|| JurTrgEbil(cCliOr, cLojaOr,;
	                               @oAtiv, @cAtiv, @oDesAtiv, @cDesAtiv,;
	                               @oAtvEbi, @cAtvEbi, @oDAtEbi, @cDAtEbi,;
	                               @oFase, @cFase, @oDesFas, @cDesFas,;
	                               @oTaref, @cTaref, @oDesTar, @cDesTar, "TAREF") })

	// "Desc Tarefa" //
	oDesTar := TJurPnlCampo():New(230, 085, 165, 022, oMainColl, AllTrim(RetTitle("NUE_DFASE")), ("NUE_DFASE"), {|| }, {|| },,,,,,,,,aScan(aNoAccLGPD,"NUE_DFASE") > 0)
	oDesTar:SetWhen({|| .F. })
	oDesTar:SetChange ({|| cDesTar := oDesTar:GetValue()})

	//--------------------

	// "Ativar" //
	oChkCob := TJurCheckBox():New(265, 005, "", {|| }, oMainColl, 08, 08, , {|| }, , , , , , .T., , , )
	oChkCob:SetCheck(lChkDt)
	oChkCob:bChange := {|| lChkCob := oChkCob:Checked(), ValCob()}

	// "Cobrar?" //
	oCobrar := TJurPnlCampo():New(255, 015, 060, 025, oMainColl, AllTrim(RetTitle("NUE_COBRAR")), ("NUE_COBRAR"), {|| }, {|| },,,,)
	oCobrar:SetValid({|| ValCob() })
	oCobrar:SetWhen({|| lChkCob })
	oCobrar:SetChange ({|| cCobrar := oCobrar:GetValue()})

	//--------------------

	// "Ativar" //
	oChkRev := TJurCheckBox():New(290, 005, "", {|| }, oMainColl, 08, 08, , {|| } , , , , , , .T., , , )
	oChkRev:SetCheck(lChkDt)
	oChkRev:bChange := {|| lChkRev := oChkRev:Checked(), ValRev()}

	// "Revisado?" //
	oRevisado := TJurPnlCampo():New(280, 015, 060, 025, oMainColl, AllTrim(RetTitle("NUE_REVISA")), ("NUE_REVISA"), {|| }, {|| },,,,)
	oRevisado:SetValid({|| ValRev() })
	oRevisado:SetWhen({|| lChkRev })
	oRevisado:SetChange ({|| cRevisado := oRevisado:GetValue()})

	oDlg:Activate()

EndIf

If Empty(cFilBkpNUE)
	(TABLANC)->( dbClearFilter() )
Else
	cAux := &( "{|| " + cFilBkpNUE + " }")  //Retorna o Filtro padrão - somente lançamentos ativos...
	(TABLANC)->( dbSetFilter( cAux, cFilBkpNUE ) )
EndIf

RestArea( aArea )

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} DesRet()
Função para carregar a descrição da Retificação.

@author Luciano Pereira dos Santos
@since 09/08/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function DesRet()
Local lRet     := .T.
Local aArea    := GetArea()
Local aAreaNSB := NSB->(GetArea())

If !Empty(cRetif)
	NSB->(DbSetOrder(1))
	If NSB->(Dbseek(xFilial('NSB') + cRetif))
		cDesRet := JurGetDados("NSB", 1, xFilial("NSB") + cRetif, "NSB_DESC")

	Else
		cRetif := CriaVar('NSB_COD', .F.)
		cDesRet := ""
		oDesRet:Disable()
		ApMsgStop(STR0065) //"Retificação de Time Sheet inválida."
	EndIf
Else
	cDesRet := ""
	oDesRet:Disable()
EndIf

oRetif:SetValue(cRetif)
oDesRet:SetValue(cDesRet)

RestArea(aAreaNSB)
RestArea(aArea)

Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} ValAtiv()
Função habilitar/ Desabilitar a Atividade da alteração de TS em lote

@Return lRet  - Sempre retornará .T.

@author Luciano Pereira dos Santos
@since 09/08/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ValAtiv()
Local lRet := .T.

If lChkAtiv
	oAtiv:Enable()
	oAtiv:Refresh()
	oDesAtiv:Enable()
	oDesAtiv:Refresh()
Else
	cAtiv := CriaVar('NUE_CATIVI', .F.)
	oAtiv:SetValue(cAtiv, cAtiv)
	cDesAtiv := ""
	oDesAtiv:SetValue(cDesAtiv)
	oAtiv:Disable()
	oDesAtiv:Disable()
EndIf

Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} ValUtr()
Função habilitar/ Desabilitar a UTR da alteração de TS em lote

@Return lRet  - Sempre retornará .T.

@author Luciano Pereira dos Santos
@since 09/08/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ValUtr()
Local lRet := .T.

If lChkUtr
	If J145WCPO('UTR')
		oUTR:Enable()
		oUTR:Refresh()
	EndIf

	If J145WCPO('HORAR')
		oHsR:Enable()
		oHsR:Refresh()
	EndIf

	If J145WCPO('TEMPOR')
		oTmpR:Enable()
		oTmpR:Refresh()
	EndIf

Else
	nUTR    := 0.00
	cHsR    := Transform(PADL("0", TamSX3('NUE_HORAR')[1], '0'), PesqPict("NUE", "NUE_HORAR"))
	nTmpR   := CriaVar('NUE_TEMPOR', .F.)
	oUTR:Disable()
	oHsR:Disable()
	oTmpR:Disable()
EndIf

oTmpR:SetValue(nTmpR)
oHsR:SetValue(cHsR)
oUTR:SetValue(nUTR)

Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} ValDt()
Função habilitar/ Desabilitar a Data da alteração de TS em lote

@Return lRet  - Sempre retornará .T.

@author Luciano Pereira dos Santos
@since 09/08/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ValDt()
Local lRet := .T.

If lChkDt
	oDataTs:Enable()
	oDataTs:Refresh()
Else
	dDataTs := CToD( '  /  /  ' )
	oDataTs:Disable()
	oDataTs:SetValue(dDataTs)
EndIf

Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} ValRet()
Função habilitar/ Desabilitar a Retificação da alteração de TS em lote

@Return lRet  - Sempre retornará .T.

@author Luciano Pereira dos Santos
@since 09/08/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ValRet()
Local lRet := .T.

If lChkRet
	oRetif:Enable()
	oRetif:Refresh()
	oDesRet:Enable()
	oDesRet:Refresh()
Else
	cRetif := CriaVar('NUE_CRETIF', .F.)
	oRetif:Disable()
	oRetif:SetValue(cRetif)
	cDesRet := ""
	oDesRet:Disable()
	oDesRet:SetValue(cDesRet)
EndIf

Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} ValCob()
Função habilitar/ Desabilitar o combo Cobrar? (Sim ou Não) da alteração de TS em lote

@Return lRet  - Sempre retornará .T.

@author Jorge Luis Branco Martins Junior
@since 12/04/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ValCob()
Local lRet := .T.

If lChkCob
	oCobrar:Enable()
	oCobrar:Refresh()
Else
	cCobrar := ""
	oCobrar:Disable()
	oCobrar:SetValue(cCobrar)
EndIf

Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} ValRev()
Função habilitar/ Desabilitar o combo Revisado? (Sim ou Não) da alteração de TS em lote

@Return lRet  - Sempre retornará .T.

@author Jorge Luis Branco Martins Junior
@since 12/04/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ValRev()
Local lRet := .T.

If lChkRev
	oRevisado:Enable()
	oRevisado:Refresh()
Else
	cRevisado := ""
	oRevisado:Disable()
	oRevisado:SetValue(cRevisado)
EndIf

Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} J145VlUT()
Função para validar o calculo de UT

@author Luciano Pereira dos Santos
@since 09/08/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J145VlUT()
Local lRet      := .T.
Local lPodeFrac := SuperGetMV( 'MV_JURTS3',, .F. ) //Indica se as uts ou o tempo pode ser possuir frações da unidade de tempo

If !Empty(nUTR)

	If nUTR < 0
		lRet := JurMsgErro(STR0047) //"Informe um valor válido!
		nUTR := '0'
	EndIf

	If !lPodeFrac
		If ((nUTR - Round(nUTR, 0)) != 0 )
			lRet := JurMsgErro(STR0040) //"O valor de UT não pode ser fracionado!"
		EndIf
	EndIf

	If lRet
		nTmpR :=  Val(JURA144C1(1, 2, Str(nUTR) ) ) //hora fracionada Revisada
		cHsR  :=  Transform(PADL(JURA144C1(1, 3, Str(nUTR)), TamSX3('NUE_HORAR')[1], '0'), PesqPict("NUE", "NUE_HORAR")) //HH:MM Revisada
	Else
		nTmpR := 0
		cHsR  := Transform(PADL("0", TamSX3('NUE_HORAR')[1], '0'), PesqPict("NUE", "NUE_HORAR"))
	EndIf

Else
	nTmpR := 0
	cHsR  := Transform(PADL("0", TamSX3('NUE_HORAR')[1], '0'), PesqPict("NUE", "NUE_HORAR"))
EndIf

oTmpR:SetValue(nTmpR)
oHsR:SetValue(cHsR)
oUTR:SetValue(nUTR)

Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} J145VlTP()
Função para validar o calculo de Tempo Revisado

@author Luciano Pereira dos Santos
@since 09/08/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J145VlTP()
Local lRet      := .T.
Local lPodeFrac := SuperGetMV( 'MV_JURTS3',, .F. ) //Indica se as uts ou o tempo pode ser possuir frações da unidade de tempo
Local nMultiplo := SuperGetMV( 'MV_JURTS1',, 10  ) //Define a quantidade de minutos referentes a 1 UT
Local cMsg      := ""

If !Empty(nTmpR)
	If nTmpR < 0
		lRet  := JurMsgErro(STR0047) //"Informe um valor válido!
		nTmpR := 0
	EndIf

	If !lPodeFrac .And. lRet
		nUTR  := Val(JURA144C1(2, 1, Str(nTmpR))) //UT Revisada
		If ((nUTR - Round(nUTR,0)) != 0 )
			nUTR  := VAL( JURA144C1(1 , 1, Str(Round(nUTR, 0)) ) )
			nTmpR := VAL( JURA144C1(1 , 2, Str(Round(nUTR, 0)) ) )
			cHsR  := Transform(PADL(JURA144C1(1, 3, Str(Round(nUTR, 0)) ), TamSX3('NUE_HORAR')[1], '0'), PesqPict("NUE", "NUE_HORAR"))

			cMsg := STR0048 + Alltrim( Str( nMultiplo ) ) + STR0049 //##"Só é permitido apontar tempos múltipos de " ### " minutos!"
			cMsg := cMsg + (CRLF) + STR0050  //"O tempo foi reajustado para um valor válido."
			JurMsgErro(cMsg)
		Else
			nUTR  := Val(JURA144C1(2, 1, Str(nTmpR))) //UT Revisada
			cHsR  := Transform(PADL(JURA144C1(2, 3, Str(nTmpR)), TamSX3('NUE_HORAR')[1], '0'), PesqPict("NUE", "NUE_HORAR")) //HH:MM Revisada
		EndIf
	Else
		nUTR  := Val(JURA144C1(2, 1, Str(nTmpR))) //UT Revisada
		cHsR  := Transform(PADL( JURA144C1(2, 3, Str(nTmpR)), TamSX3('NUE_HORAR')[1], '0'), PesqPict("NUE", "NUE_HORAR")) //HH:MM Revisada
	EndIf
Else
	nUTR  :=  0
	cHsR  :=  Transform(PADL("0", TamSX3('NUE_HORAR')[1], '0'), PesqPict("NUE", "NUE_HORAR"))
EndIf

oTmpR:SetValue(nTmpR)
oHsR:SetValue(cHsR)
oUTR:SetValue(nUTR)

Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} J145VlHS()
Função para validar o calculo de Hora Revisada

@author Luciano Pereira dos Santos
@since 09/08/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J145VlHS()
Local lRet      := .T.
Local lPodeFrac := SuperGetMV( 'MV_JURTS3',, .F. ) //Indica se as uts ou o tempo pode ser possuir frações da unidade de tempo
Local nMultiplo := SuperGetMV( 'MV_JURTS1',, 10  ) //Define a quantidade de minutos referentes a 1 UT
Local cMsg      := ""

If !Empty(cHsR)
	If !lPodeFrac
		nUTR  :=  Val(JURA144C1(3, 1, cHsR)) //UT Revisada
		If ((nUTR - Round(nUTR,0)) != 0 )
			nUTR  := Val( JURA144C1(1 , 1, Str(round(nUTR,0)) ) )
			nTmpR := Val( JURA144C1(1 , 2, Str(round(nUTR,0)) ) )
			cHsR  := Transform(PADL(JURA144C1(1, 3, Str(round(nUTR,0)) ), TamSX3('NUE_HORAR')[1], '0'), PesqPict("NUE", "NUE_HORAR"))

			cMsg := STR0048 + Alltrim( Str( nMultiplo ) ) + STR0049 //##"Só é permitido apontar tempos múltipos de " ### " minutos!"
			cMsg := cMsg + (CRLF) + STR0050  //"O tempo foi reajustado para um valor válido."
			JurMsgErro(cMsg)
		Else
			nUTR := Val(JURA144C1(3, 1, cHsR)) //UT Revisada
			cHsR := Transform(PADL(JURA144C1(3, 3, cHsR ), TamSX3('NUE_HORAR')[1], '0'), PesqPict("NUE", "NUE_HORAR"))  //HH:MM Revisada
		EndIf
	Else
		nUTR  := Val(JURA144C1(3, 1, cHsR)) //UT Revisada
		nTmpR := Val(JURA144C1(3, 2, cHsR)) //hora fracionada Revisada
	EndIf
Else
	nUTR  :=  0
	nTmpR :=  0
EndIf

oTmpR:SetValue(nTmpR)
oHsR:SetValue(cHsR)
oUTR:SetValue(nUTR)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J145WCPO(cCampo)
Função para When dos campos da tela de alteração de TS em lote

@Param cCampo Campo a ser validado

@author Luciano Pereira dos Santos
@since 09/08/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J145WCPO(cCampo)
Local lRet      := .F.
Local nTipoApon := SuperGetMV( 'MV_JURTS2',, 1 )

	Do Case
		Case nTipoApon == 1 .And. cCampo == 'UTR'
			lRet := .T.
		Case nTipoApon == 2 .And. cCampo == 'TEMPOR'
			lRet := .T.
		Case nTipoApon == 3 .And. cCampo == 'HORAR'
			lRet := .T.
	EndCase

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA145ALT()
Alterar os Time Sheets em Lote

@author Luciano Pereira dos Santos
@since 10/08/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA145ALT()
Local lRet := .T.
	Processa( {|| lRet := JA145ALT2() }, STR0016, STR0057, .F. ) // "Alteração de Time Sheets em lote" "Aguarde..."
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA145ALT2()
Alterar os Time Sheets em Lote

@author Luciano Pereira dos Santos
@since 10/08/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA145ALT2()
Local aArea         := GetArea()
Local aAreaNX0      := NX0->(GetArea())
Local lRet          := .T.
Local cMarca        := oBrw145:Mark()
Local lInvert       := oBrw145:IsInvert()
Local cFiltro       := cDefFiltro
Local nCountNue     := 0
Local lJura144      := FWIsInCallStack( "JCall145" ) .Or. FWIsInCallStack( "JURA202" )
Local nPosicao      := Iif(lJura144, (TABLANC)->(Recno()), (TABLANC)->REC)
Local nQtdNUE       := 0
Local cMemoLog      := ""
Local aErro         := {}
Local nCount        := 0
Local cCodTS        := ''
Local lLiberaTudo   := .F.
Local lLibAlteracao := .F.
Local lLibParam     := .T. // Se MV_JCORTE preenchido corretamente
Local aRetBlqTS     := {}

If !lChkCli .And. !lChkAdv .And. !lChkAdv .And. !lChkUtr .And. !lChkDt .And. !lChkRet .And. !lChkAtiv .And. !lChkCob .And. !lChkRev
	lRet := JurMsgErro(STR0045) //"Informe um item para alterar!"
EndIf

If lRet;
  .AND. (lChkCli .AND. (Empty(cCliOr) .OR. Empty(cLojaOr) .OR. Empty(cCasoOr));
  .OR. lChkAdv .AND. Empty(cSigla);
  .OR. lChkAtiv .AND. Empty(cAtiv);
  .OR. lChkDt .AND. Empty(dDataTs);
  .OR. lChkRet .AND. Empty(cRetif);
  .OR. lChkCob .AND. Empty(cCobrar);
  .OR. lChkRev .AND. Empty(cRevisado));

	lRet := JurMsgErro(STR0044) //"Todos os itens marcados devem ser preenchidos!"
EndIf

If lRet .And. lChkCli
	If (JAUSAEBILL(cCliOr,cLojaOr)) .And. (Empty(cFase) .Or. Empty(cTaref) .Or. Empty(cAtvEbi))
		lRet := JurMsgErro(STR0041) // "Cliente EBilling, informe a fase, a tarefa e atividade ebilling!"
	EndIf
EndIf

If lRet

	If Empty(cFiltro)
		cFiltro += "(NUE_OK " + Iif(lInvert, "<>", "==" ) + " '" + cMarca + "')" + " .AND. (NUE_FILIAL = '" + xFilial( "NUE" ) + "')"
	Else
		cFiltro += " .And. (NUE_OK " + Iif(lInvert, "<>", "==" ) + " '" + cMarca + "')" + " .AND. (NUE_FILIAL = '" + xFilial( "NUE" ) + "')"
	EndIf

	cAux := &( '{|| ' + cFiltro + ' }')
	(TABLANC)->( dbSetFilter( cAux, cFiltro ) )
	(TABLANC)->( dbSetOrder(1) )

	(TABLANC)->(dbgotop())
	(TABLANC)->(dbEVal({|| nQtdNUE++},, {|| !EOF()} ))
	If nQtdNUE == 0
		lRet := JurMsgErro(STR0046) //"Não há dados marcados para execução em lote!"
	EndIf

	If lRet .And. MsgYesNo( STR0053 ) //"Todos os registros marcados serão alterados. Deseja Continuar?"
		ProcRegua(nQtdNUE)
		oModelFW := FWLoadModel("JURA144")
		JurSetRules(oModelFW, "NUEMASTER",, "NUE",, )

		(TABLANC)->(dbgotop())

		AutoGrLog(STR0016) //"Alteração de Time-sheets em lote"
		AutoGrLog(Replicate('-', 65) + CRLF)

		(TABLANC)->(DbSetOrder(1))
		While !((TABLANC)->( EOF() ))
			If lLibParam
				aRetBlqTS := JBlqTSheet((TABLANC)->NUE_DATATS)
			EndIf
			lLiberaTudo   := aRetBlqTS[1]
			lLibAlteracao := aRetBlqTS[3]
			lLibParam     := aRetBlqTS[5]

			If !lLiberaTudo .And. !lLibAlteracao
				cCodTS += AllTrim((TABLANC)->NUE_COD) + "; "
				(TABLANC)->( dbSkip() )
				Loop
			EndIf

			If FindFunction("JurBlqLnc") // Proteção
				cVldMsg := JurBlqLnc((TABLANC)->NUE_CCLIEN, (TABLANC)->NUE_CLOJA, (TABLANC)->NUE_CCASO, (TABLANC)->NUE_DATATS, "TS", "0")
			EndIf
			If(Empty(cVldMsg)) .And. NUE->(DbSeek((xFilial("NUE") + (TABLANC)->NUE_COD))) //reposiciona o registro
				oModelFW:SetOperation( 4 )
				oModelFW:Activate()
				nCount++

				If !Empty(cCliOr)
					lRet := oModelFW:SetValue("NUEMASTER", "NUE_CGRPCL", cCliGrp)
					If lRet
						lRet := oModelFW:SetValue("NUEMASTER", "NUE_CCLIEN", cClior)
						If lRet
							lRet := oModelFW:SetValue("NUEMASTER", "NUE_CLOJA", cLojaOr)
							If lRet
								lRet := oModelFW:SetValue("NUEMASTER", "NUE_CCASO", cCasoOr)
							EndIf
						EndIf
					EndIf
				EndIf

				If !Empty(cSigla) .And. lRet
					lRet := oModelFW:SetValue("NUEMASTER", "NUE_SIGLA2", cSigla)
				EndIf

				If !Empty(cAtiv) .And. lRet
					lRet := oModelFW:SetValue("NUEMASTER", "NUE_CATIVI", AllTrim(cAtiv))
					If Empty(FwFldGet("NUE_DESC"))
						lRet := oModelFW:SetValue("NUEMASTER", "NUE_DESC", JurGetDados('NRC', 1, xFilial('NRC') + Alltrim(cAtiv), 'NRC_DESC') )
					EndIf
				EndIf

				If lChkUtr .And. lRet
					lRet := oModelFW:SetValue("NUEMASTER", "NUE_UTR", nUTR)
				EndIf

				If !Empty(dDataTs) .And. lRet
					lRet :=	oModelFW:SetValue("NUEMASTER", "NUE_DATATS", dDataTs)
				EndIf

				If !Empty(cRetif) .And. lRet
					lRet :=	oModelFW:SetValue("NUEMASTER", "NUE_CRETIF", AllTrim(cRetif))
				EndIf

				If !Empty(cFase) .And. lRet
					lRet :=	oModelFW:SetValue("NUEMASTER", "NUE_CFASE", AllTrim(cFase))
				EndIf

				If !Empty(cTaref) .And. lRet
					lRet :=	oModelFW:SetValue("NUEMASTER", "NUE_CTAREF", AllTrim(cTaref))
				EndIf

				If !Empty(cAtvEbi) .And. lRet
					lRet :=	oModelFW:SetValue("NUEMASTER", "NUE_CTAREB", AllTrim(cAtvEbi))
				EndIf

				If !Empty(cCobrar) .And. lRet
					lRet := oModelFW:SetValue("NUEMASTER", "NUE_COBRAR", cCobrar)
				EndIf

				If !Empty(cRevisado) .And. lRet
					lRet := oModelFW:SetValue("NUEMASTER", "NUE_REVISA", cRevisado)
				EndIf

				If lRet := oModelFW:VldData()
					oModelFW:CommitData()
					ncountNUE++

					RecLock("NUE", .F.)
					(TABLANC)->NUE_OK := ""
					(TABLANC)->(MsUnlock())
					(TABLANC)->(DbCommit())

				Else
					aErro := oModelFW:GetErrorMessage()

					cMemoLog := ( STR0061 + (TABLANC)->NUE_COD ) + CRLF //"Time Sheet: "
					If !Empty(AllToChar(aErro[4]))
						cMemoLog += ( STR0062 + AllToChar(aErro[4]) ) + CRLF //"Campo: "
					EndIf
					cMemoLog += ( STR0059 + AllToChar(aErro[6]) ) + CRLF //"Erro: "
					AutoGrLog(cMemoLog) //Grava o Log
					cMemoLog := ""  // Limpa a critica para o proximo TimeSheet
				EndIf
				oModelFW:DeActivate()
			Else
				cMemoLog += ( STR0061 + (TABLANC)->NUE_COD ) + CRLF //"Time Sheet: "
				cMemoLog += ( STR0059 + AllToChar(cVldMsg) ) + CRLF //"Erro: "
				AutoGrLog(cMemoLog) //Grava o Log
				cMemoLog := ""  // Limpa a critica para o proximo TimeSheet
			EndIf

			IncProc(STR0057 + " " + AllTrim(Str(nCount)) + " / " + AllTrim(Str(nQtdNUE))) //#"Aguarde..."

			lRet := .T.  //Volta para .T. para validar o próximo TS
			(TABLANC)->( dbSkip())
		EndDo

		cMemoLog := CRLF + Replicate('-', 65) + CRLF

		If (nCountNUE) != 0
			cMemoLog += AllTrim(Str(nCountNUE)) + STR0042 + CRLF //" Time-sheet(s) alterado(s) com sucesso!"
		EndIf

		If (nQtdNUE - nCountNUE) != 0
			cMemoLog += AllTrim(Str(nQtdNUE - nCountNUE)) + STR0060 + CRLF //# " Time-sheet(s) não alterado(s)!"
		EndIf

		If ! Empty(cCodTS)
			cMemoLog += Replicate('-', 65) + CRLF

			If lLibParam
				cMemoLog += STR0063 + cCodTS  // "Você não tem permissão para alterar os seguintes Time Sheets: "
			Else
				cMemoLog += STR0091 + cCodTS  //"Atualize o parâmetro MV_JCORTE. Deve ser igual a '1' ou '2': 1=Mensal ou 2=Quinzenal: "
			EndIf

			If nCountNUE == 0
				lRet := .F.
			EndIf
		EndIf

		cMemoLog += Replicate('-', 65) + CRLF
		AutoGrLog(cMemoLog)
		JurSetLog(.T.)

		cAux := &( "{|| " + cDefFiltro + " }")  //Retorna o Filtro padrão - somente lançamentos ativos...
		(TABLANC)->( dbSetFilter( cAux, cDefFiltro ) )
		(TABLANC)->(DbGoTO(nPosicao))

		If lRet
			JA145ATU()
		EndIf

		JurLogLote()  // Mostra o Log da operação

	Else
		lRet := .F.
	EndIf

EndIf

RestArea( aAreaNX0 )
RestArea( aArea )

Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} JA145REV()
Chamada da função de revalorização de Time Sheets em Lote

@param cFiltroAut, Filtro enviado pelo teste automatizado

@author Luciano Pereira dos Santos
@since 10/08/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA145REV(cFiltroAut)
	Local lRet := .T.

	Default cFiltroAut := ""

	Processa( {|| lRet := JA145REV2(cFiltroAut) }, STR0016, STR0057, .F. ) // "Alteração de Time Sheets em lote" "Aguarde..."

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA145REV2()
Revaloriza os Time Sheets em Lote

@param cFiltroAut, Filtro enviado pelo teste automatizado

@author Luciano Pereira dos Santos
@since 10/08/11
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA145REV2(cFiltroAut)
Local aArea         := GetArea()
Local lRet          := .T.
Local lRevPre       := .F.  // Indica que o TS está em pré-fatura em revisão ou aguardando sincronização
Local lSitPre       := .F.  // Indica que o TS está em pré-fatura em definitivo ou minuta
Local lTela         := !IsBlind()
Local cMarca        := IIf(lTela, oBrw145:Mark(), "")
Local lInvert       := IIf(lTela, oBrw145:IsInvert(), .F.)
Local cFiltro       := cDefFiltro
Local cMsg          := ''
Local nCountNue     := 0
Local lJura144      := FWIsInCallStack( "JCall145" ) .Or. FWIsInCallStack( "JURA202" )
Local nPosicao      := IIf(lTela, Iif(lJura144, (TABLANC)->(Recno()), (TABLANC)->REC), 0)
Local nQtdNUE       := 0
Local cCodTS        := ''  // Guarda o código dos TSs não alterados devido a permissão do usuário
Local cCodTSFAd     := ''  // Guarda o código dos TSs não alterados devido fatura adicional para o período
Local cCodTSPre     := ''  // Guarda o código dos TSs não alterados devido a pré-fatura estar em processo de revisão
Local cCodTSDef     := ''  // Guarda o código dos TSs não alterados devido a pré-fatura estar em definitivo ou minuta
Local lLiberaTudo   := .F.
Local lLibAlteracao := .F.
Local lLibParam     := .T. // Se MV_JCORTE preenchido corretamente
Local aRetBlqTS     := {}

If !Empty(cFiltroAut) // Filtro enviado pelo teste automatizado
	cFiltro := cFiltroAut
Else
	If Empty(cFiltro)
		cFiltro += "(NUE_OK " + Iif(lInvert, "<>", "==" ) + " '" + cMarca + "')" + " .AND. (NUE_FILIAL = '" + xFilial( "NUE" ) + "')"
	Else
		cFiltro += " .And. (NUE_OK " + Iif(lInvert, "<>", "==" ) + " '" + cMarca + "')" + " .AND. (NUE_FILIAL = '" + xFilial( "NUE" ) + "')"
	EndIf
EndIf

cAux := &( '{|| ' + cFiltro + ' }')
(TABLANC)->(dbSetFilter( cAux, cFiltro ))
(TABLANC)->(dbSetOrder(1))

(TABLANC)->(dbGoTop())
(TABLANC)->(dbEVal({|| nQtdNUE++},, {|| !EOF()} ))
If nQtdNUE == 0
	lRet := JurMsgErro(STR0046) //"Não há dados marcados para execução em lote!"
EndIf

If lRet .And. (!lTela .Or. MsgYesNo( STR0053 + " (" + AllTrim(Str(nQtdNUE)) + " TSs)" )) //"Todos os registros marcados serão alterados. Deseja Continuar?"
	ProcRegua(nQtdNUE)
	nCountNUE := 0
	(TABLANC)->(dbGoTop())
	While !((TABLANC)->(EOF()))
		If lLibParam
			aRetBlqTS := JBlqTSheet((TABLANC)->NUE_DATATS)
		EndIf
		lLiberaTudo   := aRetBlqTS[1]
		lLibAlteracao := aRetBlqTS[3]
		lLibParam     := aRetBlqTS[5]
		If !lLiberaTudo .And. !lLibAlteracao .And. lLibParam
			cCodTS += AllTrim((TABLANC)->NUE_COD) + "; "
			(TABLANC)->( dbSkip() )
			Loop
		ElseIf !lLibParam
			Exit
		EndIf

		lRevPre   := .F.
		lSitPre   := .F.

		If !Empty((TABLANC)->NUE_CPREFT)
			cSituacPF := JurGetDados("NX0", 1, xFilial("NX0") + (TABLANC)->NUE_CPREFT, "NX0_SITUAC")
			lRevPre   := (cSituacPF) $ "C|F"
			lSitPre   := (cSituacPF) $ "4|5|6|7|9|A|B" // Definitivo | Emitir Minuta | Minuta Emitida | Minuta Cancelada | Minuta Sócio | Minuta Sócio Emitida | Minuta Sócio Cancelada
		EndIf

		If lSitPre // TS em pré-fatura não alterável
			cCodTSDef += AllTrim((TABLANC)->NUE_COD) + "; "
		Else
			If lRevPre // TS em pré-fatura em revisão ou aguardando sincronização
				cCodTSPre += AllTrim((TABLANC)->NUE_COD) + "; "
			Else
				If Empty(JurBlqLnc((TABLANC)->NUE_CCLIEN, (TABLANC)->NUE_CLOJA, (TABLANC)->NUE_CCASO, (TABLANC)->NUE_DATATS, "TS", "0"))
					If JA144VALTS((TABLANC)->NUE_COD, .T.)
						RecLock(TABLANC, .F.)
						(TABLANC)->NUE_OK := " "
						(TABLANC)->(MsUnlock())
						(TABLANC)->(DbCommit())

						nCountNUE++
					EndIf
				Else // TS em período com Fatura Adicional
					cCodTSFAd += AllTrim((TABLANC)->NUE_COD) + "; "
				EndIf
			EndIf
		EndIf

		IncProc(STR0057 + " " + AllTrim(Str(nCountNUE)) + " / " + AllTrim(Str(nQtdNUE))) //"Aguarde... "

		(TABLANC)->(dbSkip())
	EndDo

	If lLibParam .And. lTela
		cMsg := Str(nCountNUE) + STR0043 + CRLF + CRLF //" lançamentos revalorizados!"

		If !Empty(cCodTS)
			cMsg += STR0063 + CRLF + "- " + cCodTS + CRLF + CRLF    // "Você não tem permissão para alterar os seguintes Time Sheets: "
		EndIf

		If !Empty(cCodTSFAd)
			cMsg += STR0079 + CRLF + "- " + cCodTSFAd + CRLF + CRLF // "Não foi possível alterar os seguintes Time Sheets por coincidirem com o período de Fatura Adicional faturada: "
		EndIf

		If !Empty(cCodTSPre)
			cMsg += STR0080 + CRLF + "- " + cCodTSPre + CRLF + CRLF // "Não foi possível alterar os seguintes Time Sheets devido a vínculo com pré-fatura em processo de Revisão: "
		EndIf

		If !Empty(cCodTSDef)
			cMsg += STR0092 + CRLF + "- " + cCodTSDef               // "Não foi possível alterar os seguintes Time Sheets devido a vínculo com pré-fatura em processo de emissão de fatura ou minuta: "
		EndIf
	
		ApMsgInfo( cMsg )
	EndIf

EndIf

cAux := &( "{|| " + cDefFiltro + " }")  //Retorna o Filtro padrão - somente lançamentos ativos...
(TABLANC)->( dbSetFilter( cAux, cDefFiltro ) )

RestArea( aArea )
If lTela
	(TABLANC)->(DbGoTo(nPosicao))
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J145VLDCLI()
Função de validação do cliente/loja da alteração de TS em lote

@author Bruno Ritter
@since 11/01/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J145VLDCLI(cVal)
Local lRet       := .T.
Local cCliOld    := ""
Local lChangeCli := .F.

Default cVal := ""

	If(!Empty(cVal))
		cCliOld := cCliOr+cLojaOr
		lRet    :=  JurTrgGCLC(,, @oCliOr, @cCliOr, @oLojaOr, @cLojaOr, @oCasoOr, @cCasoOr, cVal,;
			                                ,, @oDesCli, @cDesCli, @oDesCas, @cDesCas)
		lChangeCli := cCliOld != (cCliOr+cLojaOr)
	EndIf

	If lRet
		If cVal == "CLI"
			cGetClie := oCliOr:GetValue()
			cGetLoja := JurGetLjAt()
		ElseIf cVal == "LOJ"
			cGetLoja := oLojaOr:GetValue()
		EndIf
	EndIf

	If lRet .And. (!lChkCli .Or. lChangeCli)
		cFase := CriaVar('NUE_CFASE', .F.)
		oFase:SetValue(cFase)

		cDesFas := ""
		oDesFas:SetValue(cDesFas)

		cTaref := CriaVar('NUE_CTAREF', .F.)
		oTaref:SetValue(cTaref)

		cDesTar := ""
		oDesTar:SetValue(cDesTar)

		cAtvEbi := CriaVar('NUE_CTAREB', .F.)
		oAtvEbi:SetValue(cAtvEbi, cAtvEbi)

		cDAtEbi := ""
		oDAtEbi:SetValue(cDAtEbi)
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA145ATU()
Atualiza a tela.

@author bruno.ritter
@since 31/03/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA145ATU()
Local aArea      := GetArea()
Local lJura144   := FWIsInCallStack( "JCall145" ) .Or. FWIsInCallStack( "JURA202" )
Local cAlias     := ""
Local aStruAdic  := {}
Local aCmpAcBrw  := {}
Local aTitCpoBrw := {}
Local aCmpNotBrw := {}

If !lJura144
	cAlias := oTmpTable:GetAlias()
	oTmpTable:Delete()

	aStruAdic  := J145StruAdic()
	aCmpAcBrw  := J145CmpAcBrw()
	aTitCpoBrw := J145TitCpoBrw()
	aCmpNotBrw := J145NotBrw()
	oTmpTable  := JurCriaTmp(cAlias, cQueryTmp, "NUE", , aStruAdic, aCmpAcBrw, aCmpNotBrw, , , aTitCpoBrw)[1]
EndIf

oBrw145:Refresh()
oBrw145:GoTop(.T.)

RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA145View()
Visualização do lançamento com base em tabela temporária.

@Params  nRecno número da tabela NUE

@author bruno.ritter
@since 13/04/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA145VIEW(nRecno)
Local aArea    := GetArea()
Local aAreaNUE := NUE->(GetArea())

NUE->(DbGoTO(nRecno))
If NUE->(NUE_FILIAL + NUE_COD) == (TABLANC)->(NUE_FILIAL + NUE_COD)
	FWExecView(STR0002, 'JURA144', 1,, { || lOk := .T., lOk }) // #"Visualizar"
Else
	JurMsgErro( STR0070 ) //"Registro não encontrado!"
EndIf

RestArea( aAreaNUE )
RestArea( aArea )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Ja145WoTs
Prepara e envia Time Sheets para WO.

@param  aTimeSheet - Time Sheets que seram enviados para WO.
@param  cCodMotWo  - Código de Motivo WO
@param  cObsMotWo  - Observação de WO
@param  cCodPart   - Código do Participante
@return aRetorno   - {Código do Time Sheet, Resultado do WO)

@author	 Rafael Tenorio da Costa
@since 	 20/04/17
@version 1.0
/*/
//-------------------------------------------------------------------
Function Ja145WoTs(aTimeSheet, cCodMotWo, cObsMotWo, cCodPart)
	Local aArea        := GetArea()
	Local aAreaNXV     := NXV->( GetArea() )
	Local aAreaNUE     := NUE->( GetArea() )
	Local cMarca       := GetMark( , "NUE", "NUE_OK")
	Local nCont        := 0
	Local cFiltro      := " NUE_OK == '" + cMarca + "' "
	Local aObs         := {}
	Local lContinua    := .T.
	Local aRetorno     := {}
	Local cCodWO       := ""

	Default aTimeSheet := {}
	Default cCodMotWo  := ""
	Default cObsMotWo  := ""
	Default cCodPart   := __cUserId

	//Valida codigo do motivo do WO
	DbSelectArea("NXV")
	NXV->( DbSetOrder(1) ) //NXV_FILIAL + NXV_COD
	If Empty(cCodMotWo) .Or. !NXV->( DbSeek(xFilial("NXV") + cCodMotWo) )
		lContinua := .F.
		Aadd(aRetorno, {STR0071, "", STR0072} ) //"TODOS" //"Código de Motivo WO inválido"
	EndIf

	If lContinua .And. ValType(aTimeSheet) == "A"

		JurConOut(STR0073) //"Inicio da geração de Time Sheet em WO"
		lContinua := .F.

		//Carrega observação de WO
		aObs := {cObsMotWo, cCodMotWo, cCodPart} //Observação de WO, Código do Participante, Código de Motivo WO

		DbSelectArea("NUE")
		NUE->( DbSetOrder(1) ) //NUE_FILIAL + NUE_COD

		//Processa time sheets recebidos
		For nCont := 1 To Len(aTimeSheet)

			If NUE->( DbSeek(xFilial("NUE") + aTimeSheet[nCont]) )

				//Pré validações
				Do Case
					Case !Empty(NUE->NUE_OK)
						Aadd(aRetorno, {aTimeSheet[nCont], "", STR0074} ) //"Time Sheet em processamento por outra instância."
						Loop

					Case NUE->NUE_SITUAC == "2"
						cCodWO := getCodW0(aTimeSheet[nCont])
						Aadd(aRetorno, {aTimeSheet[nCont], cCodWO, STR0075} ) //"Time Sheet já Concluído."
						Loop
				End Case

				//Marca os time sheets
				lContinua := .T.
				RecLock("NUE", .F.)
				NUE->NUE_OK := cMarca
				If JurIsRest() 
					NUE->NUE_CDWOLD := aTimeSheet[nCont]
					NUE->NUE_PARTLD := cCodPart
					NUE->NUE_CMOTWO := cCodMotWo
					NUE->NUE_OBSWO  := cObsMotWo
				EndIf

				NUE->( MsUnLock() )
			Else

				Aadd(aRetorno, {aTimeSheet[nCont], "", STR0076} )	//"Time Sheet não localizado."
			EndIf
		Next nCont

		//Efetua o WO dos time sheets
		If lContinua
			nCont := JaWoLancR(1, /*aCampos,*/ aObs, cFiltro, /*cDefFiltro*/, /*cAliasTmp*/, @aRetorno)

			JurConOut(cValToChar(nCont) + STR0011)	//" lançamento(s) enviado(s) para WO."

			//Retira marcação dos registros
			If TcSqlExec("UPDATE " + RetSqlName("NUE") + " SET NUE_OK = '  ' WHERE NUE_FILIAL = '" + xFilial("NUE") + "' AND NUE_OK = '" + cMarca + "' AND D_E_L_E_T_ = ' '") < 0
				JurConOut(STR0077 + " NUE_OK: " + TcSqlError()) //"Erro ao retirar marcação do campo "
			EndIf
		EndIf

		JurConOut(STR0078) //"Fim da geração de Time Sheet em WO"
	EndIf

	RestArea( aAreaNUE )
	RestArea( aAreaNXV )
	RestArea( aArea )

Return aRetorno

//------------------------------------------------------------------------------
/* /{Protheus.doc}  getCodW0
Busca o código do WO ativo
@since 01/08/2022
@version 1.0
@param cCodTS, character, Código do TS a ser pesquisado
@return cCodWO, cóidigo do WO
/*/
//------------------------------------------------------------------------------
Static Function  getCodW0(cCodTS)
Local cCodWO     := ""
Local cTmpQry    := GetNextAlias()
Local cQuery     := ""

	cQuery := " SELECT NW0_CWO"
	cQuery += " FROM " + RetSqlName('NW0') + " NW0"
	cQuery += " WHERE "
	cQuery +=     " NW0.D_E_L_E_T_ = ' ' "
	cQuery +=     " AND NW0.NW0_FILIAL = '" + xFilial('NW0') + "' "
	cQuery +=     " AND NW0.NW0_CTS = '" + cCodTS + "' "
	cQuery +=     " AND NW0.NW0_SITUAC = '3' " //WO
	cQuery +=     " AND NW0.NW0_CANC = '2' "   //ATIVO

	// Executa a query da tabela temporária para verificar se está vazia.
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cTmpQry, .T., .T.)
	If (cTmpQry)->(!EoF())
		cCodWO := (cTmpQry)->NW0_CWO
	Endif
	(cTmpQry)->(DbCloseArea())

Return cCodWO

//-------------------------------------------------------------------
/*/{Protheus.doc} J145QryTmp
Rotina para gerar uma query da NUE para gerar a tabela temporária na função JurCriaTmp

@param aFiltros, filtros selecionados na tela

@author bruno.ritter
@since 18/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J145QryTmp( aFiltros )
	Local cQry       := ""
	Local cJoinCont  := ""
	Local cCondic    := ""
	Local cNvCampos  := ""
	Local lSubQry    := .F.

	cNvCampos := " , "
	cNvCampos += " CASE " + CRLF //Cobrável no Tipo de Serviço
	cNvCampos += " WHEN NRC.NRC_COBRAR = '2' THEN '" + STR0085 + "' " // Não
 	cNvCampos += " ELSE '" + STR0084 + "' " // "Sim"
	cNvCampos += " END NRCCOBRAR, "

	cNvCampos += " CASE " //Cobrável no Cliente
	cNvCampos += " WHEN EXISTS(SELECT NUB.R_E_C_N_O_ FROM " + RetSqlName("NUB") + " NUB WHERE NUB.NUB_FILIAL = '" + xFilial("NUB") + "' AND NUB.NUB_CCLIEN = NUE.NUE_CCLIEN AND NUB.NUB_CLOJA = NUE.NUE_CLOJA AND NUB.NUB_CTPATI = NUE.NUE_CATIVI AND NUB.D_E_L_E_T_ = ' ') "
	cNvCampos +=            " THEN '" + STR0085 + "' " // "Não"
 	cNvCampos += " ELSE '" + STR0084 + "' " // "Sim"
	cNvCampos += " END NUBCOBRAR, "

	cNvCampos += " CASE " //Cobrável no Contrato
	cNvCampos += " WHEN NUT.NUT_CCONTR IS NULL THEN '   ' "
	cNvCampos += " WHEN NRA.R_E_C_N_O_ IS NULL THEN '   ' " // Contrato não cobra hora
	cNvCampos += " WHEN EXISTS(SELECT NTJ.R_E_C_N_O_ FROM " + RetSqlName("NTJ") + " NTJ WHERE NTJ.NTJ_FILIAL = '" + xFilial("NTJ") + "' AND NTJ.NTJ_CCONTR = NUT.NUT_CCONTR AND NTJ.NTJ_CTPATV = NUE.NUE_CATIVI AND NTJ.D_E_L_E_T_ = ' ' ) "
	cNvCampos +=            " THEN '" + STR0085 + "' " // "Não"
 	cNvCampos += " ELSE '" + STR0084 + "' " // "Sim"
	cNvCampos += " END NTJCOBRAR, "

	cNvCampos += " NUE.R_E_C_N_O_ REC "

	cQry := J144QryTmp(cNvCampos, .T.)

	If ! Empty( aFiltros[nPContr] ) // 5 - Contrato
		cJoinCont := " INNER JOIN "
	Else
		cJoinCont := " LEFT JOIN "
	EndIf

	cQry += cJoinCont + RetSqlName("NUT") + " NUT "
	cQry +=                                       " ON NUT.NUT_FILIAL = '" + xFilial("NUT") + "' "
	cQry +=                                       " AND NUT.NUT_CCLIEN = NUE.NUE_CCLIEN "
	cQry +=                                       " AND NUT.NUT_CLOJA = NUE.NUE_CLOJA "
	cQry +=                                       " AND NUT.NUT_CCASO = NUE.NUE_CCASO "
	If !Empty( aFiltros[nPContr] ) // 5 - Contrato
		cQry +=                                   " AND NUT.NUT_CCONTR = '" + aFiltros[nPContr] + "' " // 5 - Contrato
	EndIf
	cQry +=                                       " AND NUT.D_E_L_E_T_ = ' ' "

	cQry += " LEFT JOIN " + RetSqlName("NT0") + " NT0 "
	cQry +=                                       " ON NT0.NT0_FILIAL = '" + xFilial("NT0") + "' "
	cQry +=                                       " AND NT0.NT0_ATIVO = '1' "
	cQry +=                                       " AND NT0.NT0_COD = NUT.NUT_CCONTR "
	cQry +=                                       " AND NT0.D_E_L_E_T_ = ' ' "

	cQry += " LEFT JOIN " + RetSqlName('NRA') + " NRA "
	cQry +=                                       " ON NRA.NRA_FILIAL = '" + xFilial("NRA") + "' "
	cQry +=                                       " AND NRA.NRA_COD = NT0.NT0_CTPHON "
	cQry +=                                       " AND ((NRA.NRA_COBRAH = '1' AND NRA.NRA_COBRAF = '2') OR "
	cQry +=                                            " (NRA.NRA_COBRAH = '1' AND NT0_FIXEXC = '1') OR "
	cQry +=                                            " (NRA.NRA_COBRAH = '1' AND NRA.NRA_COBRAF = '1')) "
	cQry +=                                       " AND NRA.D_E_L_E_T_ = ' ' "

	cQry += " WHERE NUE.NUE_FILIAL = '"+xFilial( "NUE" )+"' "

	cQry +=       " AND (NRA.R_E_C_N_O_ IS NOT NULL " // Contrato cobra hora
	cQry +=            " OR "                         // Ou
	cQry +=              " NOT EXISTS  (SELECT 1 "    // Não existe nenhum contrato que cobra por hora
	cQry +=                             " FROM " + RetSqlName( 'NUT' ) + " NUT2 "
	cQry +=                                    " INNER JOIN " + RetSqlName( 'NT0' ) + " NT0 "
	cQry +=                                                 " ON NT0.NT0_FILIAL = '" + xFilial("NT0") + "' "
	cQry +=                                                 " AND NT0.NT0_ATIVO = '1' "
	cQry +=                                                 " AND NT0.NT0_COD = NUT2.NUT_CCONTR "
	cQry +=                                                 " AND NT0.D_E_L_E_T_ = ' ' "
	cQry +=                                     " INNER JOIN " + RetSqlName( 'NRA' ) + " NRA "
	cQry +=                                                  " ON NRA.NRA_FILIAL = '" + xFilial("NRA") + "' "
	cQry +=                                                  " AND NRA.NRA_COD = NT0.NT0_CTPHON "
	cQry +=                                                  " AND ((NRA.NRA_COBRAH = '1' AND NRA.NRA_COBRAF = '2') OR "
	cQry +=                                                      " (NRA.NRA_COBRAH = '1' AND NT0_FIXEXC = '1') OR "
	cQry +=                                                      " (NRA.NRA_COBRAH = '1' AND NRA.NRA_COBRAF = '1')) "
	cQry +=                                                  " AND NRA.D_E_L_E_T_ = ' ' "
	cQry +=                             " WHERE NUT2.NUT_FILIAL = '" + xFilial("NUT") + "' "
	cQry +=                                   " AND NUT2.NUT_CCLIEN = NUT.NUT_CCLIEN "
	cQry +=                                   " AND NUT2.NUT_CLOJA =  NUT.NUT_CLOJA "
	cQry +=                                   " AND NUT2.NUT_CCASO =  NUT.NUT_CCASO "
	cQry +=                                   " AND NUT2.D_E_L_E_T_ = ' ') "
	cQry +=          " )"

	cQry += " AND NUE.NUE_SITUAC = '1' "
	cQry += " AND NUE.D_E_L_E_T_ = ' '"

	If !Empty( aFiltros[nPCobraTip] ) // 10 - Tipo de Atividade - NRC
		cQry += " AND NRC_COBRAR = '" + aFiltros[nPCobraTip] + "' "
	EndIf

	If !Empty( aFiltros[nPGrCli] ) .And. ( Empty( aFiltros[nPClien] ) .And. Empty( aFiltros[nPLoja] ) ) // 1 - Filtra Grupo - Apenas quando o Cliente e Loja estiverem vazios
		cQry += " AND NUE.NUE_CGRPCL = '" + aFiltros[nPGrCli] + "' "
	EndIf

	If !Empty( aFiltros[nPClien] ) // 2 - Filtra Cliente
		cQry += " AND NUE.NUE_CCLIEN = '" + aFiltros[nPClien] + "' "
	EndIf

	If !Empty( aFiltros[nPLoja] ) // 3 - Filtra Loja
		cQry += " AND NUE.NUE_CLOJA = '" + aFiltros[nPLoja] + "' "
	EndIf

	If !Empty( aFiltros[nPCaso] ) // 4 - Filtra Caso
		cQry += " AND NUE.NUE_CCASO = '" + aFiltros[nPCaso] + "' "
	EndIf

	If !Empty( aFiltros[nPDtIni] ) // 6 - Data inicial
		cQry += "  AND NUE.NUE_DATATS >= '" + DtoS( aFiltros[nPDtIni] ) + "' "
	EndIf

	If !Empty( aFiltros[nPDtFim] ) // 7 - Data Final
		cQry += "  AND NUE.NUE_DATATS <= '" + DtoS( aFiltros[nPDtFim] ) + "' "
	EndIf

	If !Empty( aFiltros[nPTipo] ) // 8 - Tipo de Atividade
		cQry += " AND NUE.NUE_CATIVI = '" + aFiltros[nPTipo] + "' "
	EndIf

	If !Empty( aFiltros[nPCobraLan] ) // 9 - Cobrar no Time Sheet?
		cQry += " AND NUE.NUE_COBRAR = '" + aFiltros[nPCobraLan] + "' "
	EndIf

	// Filtra Time Sheet no contrato e/ou no cliente
	If !Empty( aFiltros[nPCobraCtr] ) // 11 - Time Sheets cobráveis no contrato?
		//----------------
		// Monta subquery
		//----------------
		cQry     := J145SubQry( cQry )
		lSubQry  := .T.

		Do Case
			Case aFiltros[nPCobraCtr] == "1" // Filtra somente Time Sheets cobráveis no contrato
				cQry += " NTJCOBRAR = '" + STR0084 + "' " // "Sim"

			Case aFiltros[nPCobraCtr] == "2" // Filtra somente Time Sheets NÃO cobráveis no contrato
				cQry += " NTJCOBRAR = '" + STR0085 + "' " // "Não"
		End Case
	EndIf

	If !Empty( aFiltros[nPCobraCli] ) // 12 - Time Sheets cobráveis no cliente?
		//--------------------------------------------------------
		// Verifica se existe subquery e monta condição do WHERE
		//--------------------------------------------------------
		If lSubQry
			cCondic := " AND "
		Else
			cQry := J145SubQry( cQry )
		EndIf

		Do Case
			Case aFiltros[nPCobraCli] == "1" // Filtra somente Time Sheets cobráveis no cliente
				cQry += AllTrim( cCondic ) + " NUBCOBRAR = '" + STR0084 + "' " // "Sim"

			Case aFiltros[nPCobraCli] == "2" // Filtra somente Time Sheets NÃO cobráveis no cliente
				cQry += AllTrim( cCondic ) + " NUBCOBRAR = '" + STR0085 + "' " // "Não"
		End Case
	EndIf

Return cQry

//-------------------------------------------------------------------
/*/{Protheus.doc} J145SubQry
Monta subquery para filtrar despesas no contrato ou cliente

@param   cQry, caracter, Query principal

@author bruno.ritter
@since 18/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J145SubQry( cQry )
	Local cSubQry := ""

	cSubQry := " SELECT QRY.* FROM ( "
	cSubQry += cQry + " ) QRY "
	cSubQry += " WHERE "

Return ( cSubQry )

//-------------------------------------------------------------------
/*/{Protheus.doc} J145StruAdic
Estrutura adicional para incluir na tabela temporária caso exista na query. - Opcional
        Ex: aStruAdic[n][1] "NVE_SITUAC"     //Nome do campo
            aStruAdic[n][2] "Situação"       //Descrição do campo
            aStruAdic[n][3] "C"              //Tipo
            aStruAdic[n][4] 1                //Tamanho
            aStruAdic[n][5] 0                //Decimal
            aStruAdic[n][6] "@X"             //Picture

@return aStruAdic, array, Campos da estutrura adicional

@author bruno.ritter
@since 18/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function  J145StruAdic()
	Local aStruAdic := {}

	Aadd(aStruAdic, { "REC"      , "REC"  , "N", 100, 0, "", ""          })
	Aadd(aStruAdic, { "NRCCOBRAR", STR0086, "C",   3, 0, "", "NRC_COBRAR"}) // "Cobra Ativ."
	Aadd(aStruAdic, { "NUBCOBRAR", STR0088, "C",   3, 0, "", ""          }) // "Cobra Clien."
	Aadd(aStruAdic, { "NTJCOBRAR", STR0087, "C",   3, 0, "", ""          }) // "Cobra Cont."

Return ( aStruAdic )

//-------------------------------------------------------------------
/*/{Protheus.doc} J145CmpAcBrw
Monta array simples de campos onde o X3_BROWSE está como NÃO e devem
ser considerados no Browse (independentemente do seu uso)

@return aCmpAcBrw, array, Campos onde o X3_BROWSE está como NÃO e devem
		ser considerados no Browse

@author bruno.ritter
@since 18/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J145CmpAcBrw()
	Local aCmpAcBrw := {}

	aCmpAcBrw := {"NUE_COBRAR"}

Return ( aCmpAcBrw )

//-------------------------------------------------------------------
/*/{Protheus.doc} J145TitCpoBrw
Monta array com para considerar títulos de campos diferentes do SX3

@return aTitCpoBrw, array, Títulos a ser considerados no browse

@author bruno.ritter
@since 18/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J145TitCpoBrw()
	Local aTitCpoBrw := {}

	Aadd(aTitCpoBrw, {"NT0_COD", STR0083}) // "Cod. Contrato"

Return ( aTitCpoBrw )

//-------------------------------------------------------------------
/*/{Protheus.doc} J145NotBrw
Monta array para remover campos do browse

@return aCmpNotBrw, array, Campos para não aparecer no browse

@author bruno.ritter
@since 18/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J145NotBrw()
	Local aCmpNotBrw    := {}
	Local cLojaAuto     := SuperGetMv( "MV_JLOJAUT", .F., "2", ) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)

	Aadd(aCmpNotBrw, "REC")
	Aadd(aCmpNotBrw, "NRC_COBRAR")
	Aadd(aCmpNotBrw, "NUE_ACAOLD")
	Aadd(aCmpNotBrw, "NUE_CCLILD")
	Aadd(aCmpNotBrw, "NUE_CLJLD")
	Aadd(aCmpNotBrw, "NUE_CCSLD")
	Aadd(aCmpNotBrw, "NUE_PARTLD")
	Aadd(aCmpNotBrw, "NUE_CMOTWO")
	Aadd(aCmpNotBrw, "NUE_OBSWO")
	Aadd(aCmpNotBrw, "NUE_CDWOLD")

	If(cLojaAuto == "1")
		Aadd(aCmpNotBrw, "NUE_CLOJA")
	EndIf

Return ( aCmpNotBrw )
