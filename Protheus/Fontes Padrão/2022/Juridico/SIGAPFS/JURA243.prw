#INCLUDE 'JURA243.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMBROWSE.CH'

Static _lOHTInDic  := .F.
Static _cSpaceNumL := ""

//------------------------------------------------------------------
/*/{Protheus.doc} JURA243
Cobranças

@author Jorge Martins
@since 11/09/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA243()

	_lOHTInDic  := FWAliasInDic("OHT")
	_cSpaceNumL := IIf(_lOHTInDic, Space(TamSx3('OHT_NUMLIQ')[1]), "")

	J243Filtro()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J243Filtro
Tela de filtro das faturas

@param lAtualiza  Indica se a tela de filtro foi chamada pelo MenuDef
@param oTmpTit    Objeto da tabela temporaria de titulos
@param oBrw243    Objeto do browser de titulos

@author Jorge Martins
@since 11/09/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function J243Filtro(lAtualiza, oTmpTit, oBrw243)
Local aArea         := GetArea()
Local oDlg          := Nil
Local oGetClie      := Nil
Local oGetLoja      := Nil
Local oGetCaso      := Nil
Local oChkEscrit    := Nil
Local lChkEscrit    := .F.
Local oRdoSituac    := Nil
Local nRdoSituac    := 1
Local oCmbFtCli     := Nil
Local oMainColl     := Nil
Local cFiltro       := ""
Local oLayer        := FWLayer():New()
Local cTitCodCl     := RetTitle('NVE_CCLIEN')
Local cTitLojCl     := RetTitle('NVE_LCLIEN')
Local cTitCaso      := RetTitle('NVE_NUMCAS')
Local cLojaAuto     := SuperGetMv( "MV_JLOJAUT", .F., "2", ) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
Local aSituac       := {STR0008, STR0009, STR0010, STR0011, STR0012, STR0013, STR0014, STR0015} // "Em atraso","Parcialmente pago","Pago","Pendente","Fat. cancelada","Exceto fat. cancelada","Fat. cancelada por WO","Todas"
Local cJcaso        := SuperGetMv("MV_JCASO1", .F., '1')  //1 – Por Cliente; 2 – Independente de cliente

Private cGetGrup    := Criavar("A1_GRPVEN", .F.) // A consulta padrão precisa dessa variavel mesmo que nao tenha na tela
Private cGetClie    := Criavar("A1_COD", .F.)
Private cGetLoja    := Criavar("A1_LOJA", .F.)
Private cGetCaso    := Criavar("NVE_NUMCAS", .F.)
Private l243CliPag  := .F. // Indica se o cliente é pagador #Usado na consulta padrão

Default lAtualiza   := .F.
Default oTmpTit     := Nil
Default oBrw243     := Nil

DEFINE MSDIALOG oDlg TITLE STR0002 FROM 0, 0 TO 280, 380 PIXEL // "Cobrança - Filtro"

oLayer:init(oDlg, .F.) //Inicializa o FWLayer com a janela que ele pertencera e se sera exibido o botao de fechar
oLayer:addCollumn("MainColl", 100, .F.) //Cria as colunas do Layer
oMainColl := oLayer:GetColPanel( 'MainColl' )

oChkEscrit := TJurCheckBox():New(05, 05, STR0003, {|| }, oMainColl, 220, 008, , {|| } , , , , , , .T., , , ) //"Todos Escritórios"
oChkEscrit:SetCheck(lChkEscrit)
oChkEscrit:bChange := {|| lChkEscrit := oChkEscrit:Checked() }

@ 17, 05 Say STR0004 Size 80, 10 Pixel Of oMainColl // "Filtrar cliente por: "
oCmbFtCli := TJurCmbBox():New(27,05,60,15,oMainColl,{STR0005,STR0006},{||}) // "Caso";"Fatura"
oCmbFtCli:bChange := {|| oGetClie:SetValue(Criavar("A1_COD", .F.)),;
						 oGetLoja:SetValue(Criavar("A1_LOJA", .F.)),;
						 oGetCaso:SetValue(Criavar("NVE_NUMCAS", .F.)),;
						 cFiltro := oCmbFtCli:cValor,;
						 l243CliPag := oCmbFtCli:cValor == STR0006,;
						 oGetLoja:Visible(cLojaAuto == "2" .Or. l243CliPag)}  // "Fatura"

oGetClie := TJurPnlCampo():New(50,05,50,22,oMainColl, cTitCodCl ,("A1_COD"),{|| },{|| },,,,'SA1NUH') // "Cliente"
oGetClie:SetValid({|| JurTrgGCLC( ,, @oGetClie, @cGetClie, @oGetLoja, @cGetLoja, @oGetCaso, @cGetCaso, "CLI",,,,,,,,l243CliPag) })

oGetLoja := TJurPnlCampo():New(50,60,40,22, oMainColl, cTitLojCl,("A1_LOJA"),{|| },{|| },,,,) // "Loja"
oGetLoja:SetValid({|| JurTrgGCLC( ,, @oGetClie, @cGetClie, @oGetLoja, @cGetLoja, @oGetCaso, @cGetCaso, "LOJ",,,,,,,,l243CliPag)})
oGetLoja:Visible(cLojaAuto == "2" .Or. l243CliPag) //"Fatura"- Visivel sempre que não for loja automatica ou o filtro for de fatura

oGetCaso := TJurPnlCampo():New(80,05,50,22, oMainColl, cTitCaso, ("NVE_NUMCAS"),{|| }, {|| },,,,'NVENX0') // "Caso"
oGetCaso:SetValid({|| JurTrgGCLC( ,, @oGetClie, @cGetClie, @oGetLoja, @cGetLoja, @oGetCaso, @cGetCaso, "CAS",,,,,,,,l243CliPag) })
oGetCaso:SetWhen({||oCmbFtCli:cValor == STR0005 .AND. ((cJcaso == "1" .AND. !Empty(cGetLoja)) .OR. cJcaso == "2")}) // "Caso"

@ 05,110 To 90, 185 Label STR0007 Pixel Of oMainColl // "Situação de Pagamento"
oRdoSituac         := TRadMenu():New(13,114, aSituac,,oMainColl,,,,,,,,100,12,,,,.T.)
oRdoSituac:bSetGet := { |nOpcao| IIF(PCount() == 0, nRdoSituac, nRdoSituac := nOpcao)}

bBtOk := {|| IIf(J243VldFlt(lAtualiza, lChkEscrit, oCmbFtCli:cValor, cGetClie, cGetLoja, cGetCaso, nRdoSituac, @oTmpTit, @oBrw243), oDlg:End(), ) }

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,;
															bBtOk,; //# "Carregando..."
															{|| (oDlg:End()) },;
															, /*aButtons*/,/*nRecno*/,/*cAlias*/, .F., .F., .F., .T., .F. )

RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J243VldFlt
Validação do Filtro

@param lAtualiza     Indica se a tela de filtro foi chamada pelo MenuDef
@param lChkEscrit   Indica se deverá demonstrar os registros independente da filial
@param cFiltroCli   Indica se o filtro de cliente/loja será por caso ou fatura
@param cCliente     Filtro de cliente
@param cLoja        Filtro de cliente, loja
@param cCaso        Filtro de cliente, loja e caso
@param nSituacao    Situação das faturas que serão localizadas
                        1 Faturas em atraso (Apresenta as parcelas que já venceram e que ainda não tiveram algum pagamento)
                        2 Faturas parcialmente pagas (Apresenta as parcelas das faturas que foram parcialmente pagas)
                        3 Faturas totalmente pagas (Apresenta as parcelas das faturas que foram totalmente pagas)
                        4 Pendentes (Apresenta todas as parcelas de faturas que possuam valor a receber, mesmo as que ainda não estão vencidas)
                        5 Faturas canceladas (Apresenta todas as parcelas das faturas que estejam canceladas no SIGAPFS)
                        6 Exceto Canceladas (Apresenta todas as parcelas exceto das faturas que estão canceladas no SIGAPFS)
                        7 Faturas canceladas por WO (Apresenta todas as parcelas das faturas que foram canceladas por WO no SIGAPFS)
                        8 Todas (Apresenta todas as parcelas)

@return lFecha      Indica se a tela de filtro deve ser fechada

@author Jorge Martins / Bruno Ritter
@since 18/09/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J243VldFlt(lAtualiza, lChkEscrit, cFiltroCli, cCliente, cLoja, cCaso, nSituacao, oTmpTit, oBrw243)
Local cQuery := ""
Local lFecha := .F.

If !IsBlind() .And. cFiltroCli == STR0005 .And. ;
		( (!Empty(cGetClie) .And. (Empty(cGetLoja) .Or. Empty(cGetCaso))) .Or. ;
		(!Empty(cGetLoja) .And. (Empty(cGetClie) .Or. Empty(cGetCaso))) .Or. ;
		(!Empty(cGetCaso) .And. (Empty(cGetClie) .Or. Empty(cGetLoja))) )
	ApMsgInfo(STR0034) // "Para filtros por caso é necessário preencher todos os campos."
Else
	cQuery := J243Query(lChkEscrit, cFiltroCli, cCliente, cLoja, cCaso, nSituacao)

	If lAtualiza
		Processa( {|| lFecha := J243AtuBrw(cQuery, @oTmpTit, @oBrw243) }, STR0041, STR0042, .F. ) // "Aguarde" - "Processando..."
	Else
		Processa( {|| lFecha := J243Browse(cQuery) }, STR0041, STR0042, .F. ) // "Aguarde" - "Processando..."
	EndIf
EndIf

Return lFecha

//-------------------------------------------------------------------
/*/{Protheus.doc} J243Browse
MarkBrowse utilizado nas cobranças

@param  cQuery   Query que será usada como filtro

@return lFecha   Indica se a tela de filtro deve ser fechada

@author Jorge Martins
@since 11/09/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function J243Browse(cQuery)
Local aTemp      := {}
Local aFields    := {}
Local aTmpFld    := {}
Local aTmpFilt   := {}
Local aOrder     := {}
Local aFldsFilt  := {}
Local aLeg243    := {}
Local aLegPE     := {}
Local lFecha     := .T. // Indica se fechará a tela de filtro
Local lOrdemQry  := .T. // Indica se a ordem dos campos da tabela temporária será a ordem dos campos na query
Local aIndice    := J243Indice() // Índices da tabela temporária
Local aStru      := J243StruAdc() // Estrutura adicional da tabela temporária
Local aStruAdic  := aStru[1] // Estrutura adicional
Local aCmpAcBrw  := aStru[2] // Campos onde o X3_BROWSE está como NÃO mas que devem aparecer no Browse
Local aCmpNotBrw := aStru[3] // Campos onde o X3_BROWSE está como SIM mas que NÃO devem aparecer no Browse
Local aTitCpoBrw := aStru[4] // Títulos do Browse
Local bSeek      := {||}
Local cLojaAuto  := Iif(SuperGetMV('MV_JLOJAUT',, '2') == '1', 'LOJCLIFAT', '')
Local aCoors     := {}
Local oDlg243    := Nil
Local oFWLayer   := Nil
Local oPanelUp   := Nil
Local oPanelDown := Nil
Local aTFolder   := {STR0044, STR0045} // 'Histórico', 'Contatos'
Local oTFolder   := Nil
Local oFolderHis := Nil
Local oFolderCon := Nil
Local oFolderFat := Nil
Local TABSU5     := Nil
Local oTmpTit    := Nil
Local aTmpCon    := Nil
Local oTmpCon    := Nil
Local aTmpFat    := Nil
Local oTmpFat    := Nil
Local oBrw243    := Nil
Local oBrwHist   := Nil
Local oBrwContat := Nil
Local oBrwFat    := Nil

Private TABCOB   := Nil
Private TABFAT   := Nil
Private lMarcar  := .F.

ProcRegua( 0 )
IncProc()

aTemp     := JurCriaTmp(GetNextAlias(), cQuery,, aIndice, aStruAdic, aCmpAcBrw, aCmpNotBrw, lOrdemQry,, aTitCpoBrw)
oTmpTit   := aTemp[1]
aTmpFilt  := aTemp[2]
aOrder    := aTemp[3]
aTmpFld   := aTemp[4]
TABCOB    := oTmpTit:GetAlias()

If (TABCOB)->(EOF())

	If !IsBlind()
		If ApMsgYesNo(STR0016) // "Não foram encontrados registros para o filtro indicado. Deseja refazer a busca?"
			lFecha := .F.
		EndIf
	EndIf

Else

	J243RecLock(@TABCOB)

	// Remove do browse os campos que foram criados em tempo de execução
	AEVAL(aTmpFld,  {|aX| Iif(aX[2] $ "OK|LEGENDA|SALDO|VALORLIQ|IMPOSTOS|NXA_CCONT" + cLojaAuto,, Aadd(aFields ,aX))})
	AEVAL(aTmpFilt, {|aX| Iif(aX[1] $ "OK|LEGENDA|SALDO|VALORLIQ|IMPOSTOS|NXA_CCONT" + cLojaAuto,, Aadd(aFldsFilt, aX))})

	aCoors := FwGetDialogSize( oMainWnd )
	Define MsDialog oDlg243 Title STR0018 From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] STYLE nOR( WS_VISIBLE, WS_POPUP ) Pixel //"Cobrança"

	oFWLayer := FWLayer():New()
	oFWLayer:Init( oDlg243, .F., .T. )

	// Painel Superior
	oFWLayer:AddLine( 'PanelUp', 50, .F. )
	oFWLayer:AddCollumn( 'Titulos', 100, .T., 'PanelUp' )
	oPanelUp := oFWLayer:GetColPanel( 'Titulos', 'PanelUp' )

	oBrw243 := FWMarkBrowse():New()
	oBrw243:SetOwner( oPanelUp )
	oBrw243:SetDescription( STR0018 ) //"Cobrança"
	oBrw243:SetAlias( TABCOB )
	oBrw243:SetTemporary( .T. )
	oBrw243:SetCacheView( .F. )
	oBrw243:SetFields(aFields)
	oBrw243:bAllMark := { || JurMarkALL(oBrw243, TABCOB, "OK", lMarcar := !lMarcar,, .F.), oBrw243:Refresh() }
	oBrw243:oBrowse:SetDBFFilter(.T.)
	oBrw243:oBrowse:SetUseFilter()

	//------------------------------------------------------
	// Precisamos trocar o Seek no tempo de execucao,pois
	// na markBrowse, ele não deixa setar o bloco do seek
	// Assim nao conseguiriamos colocar a filial da tabela
	//------------------------------------------------------

	bSeek := {|oSeek| MySeek(oSeek, oBrw243:oBrowse)}  //Realiza o ajuste da pesquisa para considerar o campo Filial
	oBrw243:oBrowse:SetIniWindow({||oBrw243:oBrowse:oData:SetSeekAction(bSeek)})
	oBrw243:oBrowse:SetSeek(.T., aOrder)

	oBrw243:oBrowse:SetFieldFilter(aFldsFilt)

	// Adiciona as Legendas do Browse
	
	AAdd(aLeg243, {"LEGENDA == 'A'", "GREEN" , STR0020}) // "Faturas em aberto"
	AAdd(aLeg243, {"LEGENDA == 'V'", "BLUE"  , STR0021}) // "Faturas parcialmente pagas"
	AAdd(aLeg243, {"LEGENDA == 'P'", "RED"   , STR0022}) // "Faturas totalmente pagas"
	AAdd(aLeg243, {"LEGENDA == 'C'", "VIOLET", STR0023}) // "Faturas canceladas"
	AAdd(aLeg243, {"LEGENDA == 'W'", "ORANGE", STR0024}) // "Faturas canceladas por WO"
	AAdd(aLeg243, {"LEGENDA == '0'", "BLACK" , STR0025}) // "Títulos sem faturas"
	AAdd(aLeg243, {"LEGENDA == 'L'", "WHITE" , STR0056}) // "Títulos de Renegociação de Faturas"
	AAdd(aLeg243, {"LEGENDA == 'R'", "YELLOW", STR0057}) // "Faturas Renegociadas"

	If Existblock("J243SetLeg") // Ponto de entrada para customização das legendas
		aLegPE := Execblock("J243SetLeg", .F., .F., {aClone(aLeg243)})
		If ValType(aLegPE) == "A" .And. !Empty(aLegPE)
			aLeg243 := aClone(aLegPE)
			JurFreeArr(@aLegPE)
		EndIf
	EndIf

	AEval(aLeg243, {|aLeg| oBrw243:AddLegend(aLeg[1], aLeg[2], aLeg[3])})

	oBrw243:oBrowse:bOnStartFilter := Nil

	oBrw243:SetMenuDef( '' )
	oBrw243:SetFieldMark( "OK" ) // "OK"
	JurSetBSize( oBrw243 )
	oBrw243:AddButton(STR0043, {|| J243IncCob(@oTmpTit, @oBrw243)     },, 3) // "Incluir Cobrança"
	oBrw243:AddButton(STR0001, {|| J243Filtro(.T., @oTmpTit, @oBrw243)},, 6) // "Filtrar"
	oBrw243:AddButton(STR0053, {|| J243SE1Opt((TABCOB)->E1_FILIAL+(TABCOB)->E1_PREFIXO+(TABCOB)->E1_NUM+(TABCOB)->E1_PARCELA+(TABCOB)->E1_TIPO, 2)},, 8) // "Visualizar título"
	oBrw243:AddButton(STR0055, {|| J243SE1Opt((TABCOB)->E1_FILIAL+(TABCOB)->E1_PREFIXO+(TABCOB)->E1_NUM+(TABCOB)->E1_PARCELA+(TABCOB)->E1_TIPO, 1)},, 8) // "Docs Fatura"

	If Len(aTemp) >= 7 .And. !Empty(aTemp[7]) // Tratamento para LGPD verifica os campos que devem ser ofuscados
		oBrw243:oBrowse:SetObfuscFields(aTemp[7])
	EndIf

	oBrw243:SetProfileId('1')
	oBrw243:ForceQuitButton(.T.)
	oBrw243:oBrowse:SetBeforeClose({ || oBrw243:oBrowse:VerifyLayout(), oBrwHist:VerifyLayout(), oBrwContat:VerifyLayout(), IIf(_lOHTInDic, oBrwFat:VerifyLayout(), Nil)})

	oBrw243:Activate()

	// Painel Inferior
	oFWLayer:addLine( 'PanelDown', 50, .F. )
	oFWLayer:AddCollumn( 'Folders', 100, .T., 'PanelDown' )
	oPanelDown := oFWLayer:GetColPanel( 'Folders', 'PanelDown' )

	Iif(_lOHTInDic, aAdd(aTFolder, STR0058), Nil) // "Faturas"

	//Construção dos folders no Painel inferior
	oTFolder := TFolder():New( 1, 1, aTFolder,, oPanelDown,,,, .T.,, 0, 0)
	oTFolder:Align := CONTROL_ALIGN_ALLCLIENT
	oFolderHis := oTFolder:aDialogs[1]
	oFolderCon := oTFolder:aDialogs[2]
	oFolderFat := Iif(_lOHTInDic, oTFolder:aDialogs[3], Nil)

	//Browse dos históricos
	oBrwHist := FWMBrowse():New()
	oBrwHist:SetOwner( oFolderHis )
	oBrwHist:SetDescription( STR0044 ) // "Histórico"
	oBrwHist:SetMenuDef( 'JURA244' )
	oBrwHist:DisableDetails()
	oBrwHist:SetAlias( 'OHD' )
	oBrwHist:SetProfileID( '2' )

	oBrwHist:Activate()

	oRelationHist := FWBrwRelation():New()
	oRelationHist:AddRelation( oBrw243, oBrwHist, { {"OHD_FILIAL", "(TABCOB)->E1_FILIAL" }, {"OHD_PREFIX", "(TABCOB)->E1_PREFIXO"}, {"OHD_NUM", "(TABCOB)->E1_NUM"}, {"OHD_PARCEL", "(TABCOB)->E1_PARCELA"},{"OHD_TIPO", "(TABCOB)->E1_TIPO"} } )
	
	oRelationHist:Activate()

	//Tabela temporaria de contatos
	aStru      := J243SU5Brw()
	aStruAdic  := aStru[1] // Estrutura adicional
	aCmpAcBrw  := aStru[2] // Campos onde o X3_BROWSE está como NÃO mas que devem aparecer no Browse
	aCmpNotBrw := aStru[3] // Campos onde o X3_BROWSE está como SIM mas que NÃO devem aparecer no Browse
	cQuery     := aStru[4]
	aIndice    := aStru[5]

	aTmpCon   := JurCriaTmp(GetNextAlias(), cQuery, 'SU5', aIndice, aStruAdic, aCmpAcBrw, /*aCmpNotBrw*/, lOrdemQry)
	oTmpCon   := aTmpCon[1]
	aTmpFilt  := aTmpCon[2]
	aOrder    := aTmpCon[3]
	aTmpFld   := aTmpCon[4]
	TABSU5    := oTmpCon:GetAlias()

	// Remove do browse os campos que foram criados em tempo de execução
	aFields   := {}
	aFldsFilt := {}
	AEVAL(aTmpFld , {|aX| Iif(aX[2] $ "RECNO|U5_TIPO",, Aadd(aFields  , aX))})
	AEVAL(aTmpFilt, {|aX| Iif(aX[1] $ "RECNO|U5_TIPO",, Aadd(aFldsFilt, aX))})

	//Browse dos contatos
	oBrwContat := FWMBrowse():New()
	oBrwContat:SetOwner( oFolderCon )
	oBrwContat:SetDescription( STR0045 ) //'Contatos'
	oBrwContat:SetMenuDef('') // Referencia uma funcao que nao tem menu para que exiba nenhum
	oBrwContat:DisableDetails()
	oBrwContat:SetAlias(TABSU5)
	oBrwContat:SetTemporary( .T. )
	oBrwContat:SetProfileID( '3' )
	oBrwContat:SetFields(aFields)

	oBrwContat:SetDBFFilter(.T.)
	oBrwContat:SetUseFilter()
	oBrwContat:SetFieldFilter(aFldsFilt)
	oBrwContat:SetSeek(.T., aOrder)

	oBrwContat:SetDoubleClick({|| J243SU5Opt(@TABSU5, @oBrwContat, aCmpAcBrw, 2) })

	oBrwContat:AddButton(STR0048, {|| J243SU5Opt(@TABSU5, @oBrwContat, aCmpAcBrw, 4) },, 6)  //"Alterar"
	oBrwContat:AddButton(STR0054, {|| J243SU5Opt(@TABSU5, @oBrwContat, aCmpAcBrw, 2) },, 2)  //"Visualizar"

	oBrwContat:AddLegend( "U5_CODCONT==(TABCOB)->NXA_CCONT"                   , "GREEN" , STR0050 ) // "Contato utilizado na fatura"
	oBrwContat:AddLegend( "U5_TIPO='3'"                                       , "ORANGE", STR0051 ) // "Contado de cobrança"
	oBrwContat:AddLegend( "U5_CODCONT!=(TABCOB)->NXA_CCONT .AND. U5_TIPO!='3'", "BLUE"  , STR0052 ) // "Outros tipos de contato"

	If Len(aTmpCon) >= 7 .And. !Empty(aTmpCon[7]) // Tratamento para LGPD verifica os campos que devem ser ofuscados
		oBrwContat:SetObfuscFields(aTmpCon[7])
	EndIf

	oBrwContat:Activate()

	oRelation := FWBrwRelation():New()
	oRelation:AddRelation( oBrw243, oBrwContat, { {"AC8_FILIAL", "XFILIAL('AC8')" }, {"AC8_FILENT", "xFilial('SA1')"}, {"AC8_ENTIDA", '"SA1"'}, {"AC8_CODENT","PadR((TABCOB)->CODCLIPAG + LOJCLIPAG, TamSX3('AC8_CODENT')[1] )" } } )
	oRelation:Activate()

	If _lOHTInDic
		// Tabela temporaria de Faturas
		aStru      := J243FatBrw()
		aStruAdic  := aStru[1] // Estrutura adicional
		aCmpAcBrw  := aStru[2] // Campos onde o X3_BROWSE está como NÃO mas que devem aparecer no Browse
		aCmpNotBrw := aStru[3] // Campos onde o X3_BROWSE está como SIM mas que NÃO devem aparecer no Browse
		cQuery     := aStru[4] // Query da tabela Temporária
		aIndice    := aStru[5] // Índices
		aTitCpoBrw := aStru[6] // Títulos do Browse

		aTmpFat    := JurCriaTmp(/*cTmpTable*/, cQuery, , aIndice, aStruAdic, aCmpAcBrw, aCmpNotBrw, lOrdemQry,, aTitCpoBrw)
		oTmpFat    := aTmpFat[1]
		aFldsFilt  := aTmpFat[2]
		aOrder     := aTmpFat[3]
		aFields    := aTmpFat[4]
		TABFAT     := oTmpFat:GetAlias()

		// Browse das Faturas
		oBrwFat := FWMBrowse():New()
		oBrwFat:SetOwner(oFolderFat)
		oBrwFat:SetDescription(STR0058) // "Faturas"
		oBrwFat:SetMenuDef('') // Referencia uma funcao que não tem menu para que não exiba nenhum
		oBrwFat:DisableDetails()
		oBrwFat:SetAlias(TABFAT)
		oBrwFat:SetTemporary(.T.)
		oBrwFat:SetProfileID('4')
		oBrwFat:SetFields(aFields)
		oBrwFat:SetDBFFilter(.T.)
		oBrwFat:SetUseFilter()
		oBrwFat:SetFieldFilter(aFldsFilt)
		oBrwFat:SetSeek(.T., aOrder)

		oBrwFat:SetDoubleClick({|| J243FatOpt(2) }) // "Visualizar"

		oBrwFat:AddButton(STR0059, {|| J243FatOpt(1) },, 2) // "Docs Relacionados"
		oBrwFat:AddButton(STR0054, {|| J243FatOpt(2) },, 2) // "Visualizar"

		oBrwFat:Activate()

		oRelationFat := FWBrwRelation():New()
		oRelationFat:AddRelation( oBrw243, oBrwFat, { {"(TABFAT)->OHT_FILTIT", "(TABCOB)->E1_FILIAL" },;
		                                              {"(TABFAT)->OHT_PREFIX", "(TABCOB)->E1_PREFIXO"},;
		                                              {"(TABFAT)->OHT_TITNUM", "(TABCOB)->E1_NUM"    },;
		                                              {"(TABFAT)->OHT_TITPAR", "(TABCOB)->E1_PARCELA"},;
		                                              {"(TABFAT)->OHT_TITTPO", "(TABCOB)->E1_TIPO"   } } )

		oRelationFat:Activate()
		oBrwFat:Refresh()
	EndIf

	oBrw243:Refresh()
	oBrwContat:Refresh()

	Activate MsDialog oDlg243 CENTER

EndIf

// Apaga as tabelas temporárias
IIf(oTmpTit != Nil, oTmpTit:Delete(), Nil)
IIf(oTmpCon != Nil, oTmpCon:Delete(), Nil)
IIf(oTmpFat != Nil, oTmpFat:Delete(), Nil)

Return lFecha

//-------------------------------------------------------------------
/*/{Protheus.doc} J243AtuBrw()
Atualiza o browse com o novo filtro.

@param cQuery  Query que será usada como filtro
@param oTmpTit Objeto da tabela temporaria de titulos
@param oBrw243 Objeto do browser de titulos

@return lFecha   Indica se a tela de filtro deve ser fechada

@author Jorge Martins
@since 11/09/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J243AtuBrw(cQuery, oTmpTit, oBrw243)
Local aArea      := GetArea()
Local TABCOB     := oTmpTit:GetAlias()
Local aIndice    := {}
Local aStru      := {}
Local aStruAdic  := {}
Local aCmpAcBrw  := {}
Local aCmpNotBrw := {}
Local aTitCpoBrw := {}
Local lEmpty     := .F.
Local lFecha     := .T. // Indica se fechará a tela de filtro
Local lOrdemQry  := .T. // Indica se a ordem dos campos da tabela temporária será a ordem dos campos na query
Local cTmpQry    := GetNextAlias()

ProcRegua( 0 )
IncProc()

// Executa a query da tabela temporária para verificar se está vazia.
// Se estiver vazia, não excluí a tabela anterior, até que seja feito um filtro válido
cQuery := ChangeQuery(cQuery)
dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cTmpQry, .T., .T.)

lEmpty := (cTmpQry)->( EOF() )
(cTmpQry)->(dbCloseArea())

If lEmpty

	If !IsBlind()
		If ApMsgYesNo(STR0016) // "Não foram encontrados registros para o filtro indicado. Deseja refazer a busca?"
			lFecha := .F.
		EndIf
	EndIf

Else

	oTmpTit:Delete()

	aIndice    := J243Indice() // Índices da tabela temporária
	aStru      := J243StruAdc() // Estrutura adicional da tabela temporária
	aStruAdic  := aStru[1] // Estrutura adicional
	aCmpAcBrw  := aStru[2] // Campos onde o X3_BROWSE está como NÃO mas que devem aparecer no Browse
	aCmpNotBrw := aStru[3] // Campos onde o X3_BROWSE está como SIM mas que NÃO devem aparecer no Browse
	aTitCpoBrw := aStru[4] // Títulos do Browse

	oTmpTit    := JurCriaTmp(TABCOB, cQuery, "", aIndice, aStruAdic, aCmpAcBrw, aCmpNotBrw, lOrdemQry,, aTitCpoBrw)[1]

	J243RecLock(@TABCOB)

	oBrw243:Refresh(.T.)

EndIf

RestArea(aArea)

Return lFecha

//-------------------------------------------------------------------
/*/{Protheus.doc} J243StruAdc
Estrutura adicional para o MarkBrowse

@return Array com Estrutura Adicional
            aStruAdic  - Estrutura adicional do Browse
            aCmpAcBrw  - Campos onde o X3_BROWSE está como NÃO mas que devem aparecer no Browse
            aCmpNotBrw - Campos onde o X3_BROWSE está como SIM mas que NÃO devem aparecer no Browse
            aTitCpoBrw - Títulos dos campos no Browse

@author Jorge Martins
@since 11/09/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J243StruAdc()
Local aStruAdic  := {} // Estrutura adicional
Local aCmpAcBrw  := {} // Campos onde o X3_BROWSE está como NÃO mas que devem aparecer no Browse
Local aCmpNotBrw := {} // Campos onde o X3_BROWSE está como SIM mas que NÃO devem aparecer no Browse
Local aTitCpoBrw := {} // Títulos do Browse
Local nTamCod    := TAMSX3("A1_COD")[1]
Local nTamLoja   := TAMSX3("A1_LOJA")[1]
Local nTamNome   := TAMSX3("A1_NOME")[1]
Local nTamVenc   := TAMSX3("E1_VENCTO")[1]
Local lISS       := GetNewPar("MV_DESCISS",.F.)
Local lCpoGrsHon := NXA->(ColumnPos("NXA_VGROSH")) > 0 //@12.1.2310

Aadd(aStruAdic, { "OK"        , STR0017, "C", 2       , 0, ""                       , ""           } ) // "OK"
Aadd(aStruAdic, { "LEGENDA"   , STR0019, "C", 1       , 0, ""                       , ""           } ) // "Legenda"
Aadd(aStruAdic, { "SITUACAO"  , STR0007, "C", 30      , 0, ""                       , "NXA_SITUAC" } ) // "Situação de Pagamento"
Aadd(aStruAdic, { "ATRASO"    , STR0026, "N", 5       , 0, ""                       , ""           } ) // "Atraso em dias"
Aadd(aStruAdic, { "HONORARIOS", STR0027, "N", 16      , 2, "@E 9,999,999,999,999.99", "NXA_VLFATH" + IIF(lCpoGrsHon, " + NXA_VGROSH", "") } ) // "Valor de honorários"
Aadd(aStruAdic, { "HONORLIQ"  , STR0028, "N", 16      , 2, "@E 9,999,999,999,999.99", "NXA_VLFATH" + IIF(lCpoGrsHon, " + NXA_VGROSH", "") } ) // "Valor líq. honorários"
Aadd(aStruAdic, { "DESPESA"   , STR0029, "N", 16      , 2, "@E 9,999,999,999,999.99", "NXA_VLFATD" } ) // "Valor despesa"
Aadd(aStruAdic, { "HONORNAC"  , STR0030, "N", 16      , 2, "@E 9,999,999,999,999.99", "NXA_FATHMN" + IIF(lCpoGrsHon, " + NXA_GRSHMN", "") } ) // "Valor honor. moeda nac."
Aadd(aStruAdic, { "DESPNAC"   , STR0031, "N", 16      , 2, "@E 9,999,999,999,999.99", "NXA_FATDMN" } ) // "Valor desp. moeda nac."
Aadd(aStruAdic, { "SALDO"     , STR0032, "N", 16      , 2, "@E 9,999,999,999,999.99", "E1_SALDO"   } ) // "Saldo fatura"
Aadd(aStruAdic, { "VALORLIQ"  , STR0033, "N", 16      , 2, "@E 9,999,999,999,999.99", "E1_VALOR"   } ) // "Valor líquido fatura"
Aadd(aStruAdic, { "IMPOSTOS"  , ""     , "N", 16      , 2, "@E 9,999,999,999,999.99", ""           } ) // "Impostos"
Aadd(aStruAdic, { "CODCLIFAT" , STR0035, "C", nTamCod , 0, ""                       , "NXA_CCLIEN" } ) // "Cliente Fat."
Aadd(aStruAdic, { "LOJCLIFAT" , STR0036, "C", nTamLoja, 0, ""                       , "NXA_CLOJA"  } ) // "Loja Fat."
Aadd(aStruAdic, { "RAZSOCFAT" , STR0037, "C", nTamNome, 0, ""                       , "A1_NOME"    } ) // "Razão Social Faturado"
Aadd(aStruAdic, { "CODCLIPAG" , STR0038, "C", nTamCod , 0, ""                       , "NXA_CLIPG"  } ) // "Cliente Pag."
Aadd(aStruAdic, { "LOJCLIPAG" , STR0039, "C", nTamLoja, 0, ""                       , "NXA_LOJPG"  } ) // "Loja Pag."
Aadd(aStruAdic, { "RAZSOCPAG" , STR0040, "C", nTamNome, 0, ""                       , "NXA_RAZSOC" } ) // "Razão Social Pagador"
Aadd(aStruAdic, { "DT_BOLETO" , ""     , "D", nTamVenc, 0, ""                       , "E1_VENCTO"  } ) // "Data do Boleto"
Aadd(aStruAdic, { "OHTLEG1"   , "LEG1" , "N", 1       , 0, ""                       , ""           } ) // "Legenda - Títulos gerados pela liquidação / Títulos de faturas liquidadas (renegociadas)"

Aadd(aCmpAcBrw, "E1_FILIAL" )
Aadd(aCmpAcBrw, "E1_INSS"   )
Aadd(aCmpAcBrw, "E1_CSLL"   )
If lISS
	Aadd(aCmpAcBrw, "E1_ISS")
EndIf
Aadd(aCmpAcBrw, "E1_TXMOEDA")
Aadd(aCmpAcBrw, "E1_COFINS" )
Aadd(aCmpAcBrw, "E1_PIS"    )
Aadd(aCmpAcBrw, "RD0_SIGLA" )

Aadd(aCmpNotBrw, "NXA_FILIAL")
Aadd(aCmpNotBrw, "E1_BOLETO" )
Aadd(aCmpNotBrw, "E1_SALDO"  )
Aadd(aCmpNotBrw, "NXA_WO"    )
Aadd(aCmpNotBrw, "E1_TIPO"   )
Aadd(aCmpNotBrw, "DT_BOLETO" )
Aadd(aCmpNotBrw, "E1_JURFAT" )
Aadd(aCmpNotBrw, "OHTLEG1"   )

Aadd(aTitCpoBrw, {"CTO_SIMB", AllTrim(RetTitle("E1_MOEDA"))}) // "Moeda"

Return {aStruAdic, aCmpAcBrw, aCmpNotBrw, aTitCpoBrw}

//-------------------------------------------------------------------
/*/{Protheus.doc} J243RecLock()
Atualiza o browse com o novo filtro.

@param TABCOB Tabela temporária

@author Jorge Martins
@since 11/09/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J243RecLock(TABCOB)
Local nPrazoB    := SuperGetMv( "MV_JPRAZOB", .F., 0, )
Local nPrazoD    := SuperGetMv( "MV_JPRAZOD", .F., 0, )
Local dData      := Date()
Local cBoleto    := ""
Local cSituac    := ""
Local cLegenda   := ""
Local lWO        := .T.
Local dDtVencto  := Nil
Local xAtraso    := Nil

While !(TABCOB)->( EOF() )

	lWO     := Trim((TABCOB)->NXA_WO) == "1"
	cBoleto := Trim((TABCOB)->E1_BOLETO)

	dDtVencto := (TABCOB)->E1_VENCTO

	If cBoleto == '1' // Boleto
		dDtVencto += nPrazoB
	ElseIf cBoleto == '2' // Depósito
		dDtVencto += nPrazoD
	EndIf

	xAtraso := dData - dDtVencto

	If xAtraso < 0
		xAtraso := 0
	EndIf

	cLegenda := J243Legenda(TABCOB, lWO)
	cSituac  := J243Situac(TABCOB, lWO, @xAtraso, cLegenda)

	RecLock( TABCOB, .F. )

    (TABCOB)->ATRASO :=  xAtraso
	(TABCOB)->LEGENDA := cLegenda
	(TABCOB)->SITUACAO :=  cSituac
	(TABCOB)->E1_VENCTO := dDtVencto

	(TABCOB)->(MsUnLock())
	(TABCOB)->(DbSkip())
EndDo

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J243Query
Query para consulta

@param lChkEscrit   Indica se deverá demonstrar os registros independente da filial
@param cFiltroCli   Indica se o filtro de cliente/loja será por caso ou fatura
@param cCliente     Filtro de cliente
@param cLoja        Filtro de cliente, loja
@param cCaso        Filtro de cliente, loja e caso
@param nSituacao    Situação das faturas que serão localizadas
                        1 Faturas em atraso (Apresenta as parcelas que já venceram e que ainda não tiveram algum pagamento)
                        2 Faturas parcialmente pagas (Apresenta as parcelas das faturas que foram parcialmente pagas)
                        3 Faturas totalmente pagas (Apresenta as parcelas das faturas que foram totalmente pagas)
                        4 Pendentes (Apresenta todas as parcelas de faturas que possuam valor a receber e que não estão vencidas)
                        5 Faturas canceladas (Apresenta todas as parcelas das faturas que estejam canceladas no SIGAPFS)
                        6 Exceto Canceladas (Apresenta todas as parcelas exceto das faturas que estão canceladas no SIGAPFS)
                        7 Faturas canceladas por WO (Apresenta todas as parcelas das faturas que foram canceladas por WO no SIGAPFS)
                        8 Todas (Apresenta todas as parcelas)

@return cQuery      Query que será usada como filtro

@author Jorge Martins
@since 11/09/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function J243Query(lChkEscrit, cFiltroCli, cCliente, cLoja, cCaso, nSituacao)
Local cQuery     := ""
Local nPrazoB    := SuperGetMv( "MV_JPRAZOB", .F., 0, )
Local nPrazoD    := SuperGetMv( "MV_JPRAZOD", .F., 0, )
Local lCliFat    := IIf(cFiltroCli == STR0006, .T., .F.) // "Fatura"
Local dData      := Date()
Local dDataBol   := dData - nPrazoB
Local dDataDep   := dData - nPrazoD
Local cSpcDtCanc := Space(TamSx3('NXA_DTCANC')[1])
Local nTamFil    := TamSX3("NXA_FILIAL")[1]
Local nTamEsc    := TamSX3("NXA_CESCR")[1]
Local cTamFilial := cValToChar(nTamFil)
Local cIniEscr   := cValToChar(nTamFil+2)
Local cTamEscr   := cValToChar(nTamEsc)
Local cIniFatur  := cValToChar(nTamFil+1+nTamEsc+2)
Local cTamFatur  := cValToChar(TamSX3("NXA_COD")[1])
Local lISS       := GetNewPar("MV_DESCISS",.F.)
Local lCpoGrsHon := NXA->(ColumnPos("NXA_VGROSH")) > 0 //@12.1.2310

cQuery += " SELECT Y.* From ( "
cQuery += " SELECT X.*, "
cQuery +=        J243CpoQry("SALDO")    + " AS SALDO, "
cQuery +=        J243CpoQry("VALORLIQ") + " AS VALORLIQ, "
cQuery +=        J243CpoQry("IMPOSTOS") + " AS IMPOSTOS "
cQuery +=  " FROM ("

cQuery += " SELECT '' SITUACAO, "
cQuery +=        " '' LEGENDA, "
cQuery +=        " 0 ATRASO, "
cQuery +=        " SE1.E1_JURFAT, "
cQuery +=        " SE1.E1_FILIAL, "
cQuery +=        " SE1.E1_PREFIXO, "
cQuery +=        " SE1.E1_NUM, "
cQuery +=        " SE1.E1_PARCELA, "
cQuery +=        " SE1.E1_TIPO, "
cQuery +=        " CASE "
cQuery +=            " WHEN NXA.NXA_FILIAL IS NULL THEN ' ' "
cQuery +=            " ELSE NXA.NXA_FILIAL "
cQuery +=        " END NXA_FILIAL, "
cQuery +=        " CASE "
cQuery +=            " WHEN NXA.NXA_CESCR IS NULL THEN ' ' "
cQuery +=            " ELSE NXA.NXA_CESCR "
cQuery +=        " END NXA_CESCR, "
cQuery +=        " CASE "
cQuery +=            " WHEN NXA.NXA_COD IS NULL THEN ' ' " 
cQuery +=            " ELSE NXA.NXA_COD " 
cQuery +=        " END NXA_COD, "
cQuery +=        " CASE "
cQuery +=            " WHEN NXA.NXA_DOC IS NULL THEN ' ' " 
cQuery +=            " ELSE NXA.NXA_DOC " 
cQuery +=        " END NXA_DOC, "
cQuery +=        " CASE "
cQuery +=            " WHEN NXA.NXA_CCLIEN IS NULL THEN SE1.E1_CLIENTE " 
cQuery +=            " WHEN NXA.NXA_CCLIEN = '" + Space(TamSx3('NXA_CCLIEN')[1]) + "' THEN SE1.E1_CLIENTE "
cQuery +=            " ELSE NXA.NXA_CCLIEN " 
cQuery +=        " END CODCLIFAT, "
cQuery +=        " CASE "
cQuery +=            " WHEN NXA.NXA_CLOJA IS NULL THEN SE1.E1_LOJA " 
cQuery +=            " WHEN NXA.NXA_CLOJA = '" + Space(TamSx3('NXA_CLOJA')[1]) + "' THEN SE1.E1_LOJA "
cQuery +=            " ELSE NXA.NXA_CLOJA "
cQuery +=        " END LOJCLIFAT, "
cQuery +=        " CASE "
cQuery +=            " WHEN SA1.A1_NOME IS NULL THEN SE1.E1_NOMCLI " 
cQuery +=            " ELSE SA1.A1_NOME " 
cQuery +=        " END RAZSOCFAT, "
cQuery +=        " CASE "
cQuery +=            " WHEN NXA.NXA_CLIPG IS NULL THEN SE1.E1_CLIENTE " 
cQuery +=            " WHEN NXA.NXA_CLIPG = '" + Space(TamSx3('NXA_CLIPG')[1]) + "' THEN SE1.E1_CLIENTE " 
cQuery +=            " ELSE NXA.NXA_CLIPG " 
cQuery +=        " END CODCLIPAG, "
cQuery +=        " CASE "
cQuery +=            " WHEN NXA.NXA_LOJPG IS NULL THEN SE1.E1_LOJA " 
cQuery +=            " WHEN NXA.NXA_LOJPG = '" + Space(TamSx3('NXA_LOJPG')[1]) + "' THEN SE1.E1_LOJA " 
cQuery +=            " ELSE NXA.NXA_LOJPG " 
cQuery +=        " END LOJCLIPAG, "
cQuery +=        " CASE "
cQuery +=            " WHEN NXA.NXA_RAZSOC IS NULL THEN SE1.E1_NOMCLI " 
cQuery +=            " WHEN NXA.NXA_RAZSOC = '" + Space(TamSx3('NXA_RAZSOC')[1]) + "' THEN SE1.E1_NOMCLI " 
cQuery +=            " ELSE NXA.NXA_RAZSOC " 
cQuery +=        " END RAZSOCPAG, "
cQuery +=        " SE1.E1_EMISSAO, "
cQuery +=        " SE1.E1_VENCTO, "
cQuery +=        " CTO.CTO_SIMB, "
cQuery +=        " SE1.E1_VALOR, "
cQuery +=        " CASE "
cQuery +=            " WHEN RD0.RD0_SIGLA IS NULL THEN '" + Space(TamSx3('RD0_SIGLA')[1]) + "' "
cQuery +=            " ELSE RD0.RD0_SIGLA "
cQuery +=        " END RD0_SIGLA, "
cQuery +=        " CASE "
cQuery +=            " WHEN NXA.NXA_DTCANC IS NULL THEN '" + cSpcDtCanc + "' "
cQuery +=            " ELSE NXA.NXA_DTCANC "
cQuery +=        " END NXA_DTCANC, "
cQuery +=        " SE1.E1_HIST, "
cQuery +=        " SE1.E1_SALDO, "

If _lOHTInDic
	cQuery +=    " CASE "
	cQuery +=        " WHEN OHT.OHT_CFATUR IS NULL THEN 0 "
	cQuery +=        " ELSE (OHT.OHT_VLFATH + OHT.OHT_ACRESC - OHT.OHT_DESCON) "
	cQuery +=    " END HONORARIOS, "
Else
	cQuery +=    " CASE "
	cQuery +=        " WHEN NXA.NXA_COD IS NULL THEN 0 "
	cQuery +=        " ELSE (NXA.NXA_VLFATH + " + IIF(lCpoGrsHon, "NXA.NXA_VGROSH +", "") + " NXA.NXA_VLACRE - NXA.NXA_VLDESC) "
	cQuery +=    " END HONORARIOS, "
EndIf

//-------------------
// INICIO HONORLIQ
//-------------------
If _lOHTInDic
	cQuery +=    " CASE "
	cQuery +=        " WHEN OHT.OHT_CFATUR IS NULL THEN "
	cQuery +=           " CASE "
	cQuery +=                "WHEN NXA.NXA_COD IS NOT NULL "
	cQuery +=                "THEN  (NXA.NXA_VLFATH + " + IIF(lCpoGrsHon, "NXA.NXA_VGROSH +", "") + " NXA.NXA_VLACRE - NXA.NXA_VLDESC) - "
	cQuery +=                     " (SELECT SUM(SE1W.E1_IRRF + SE1W.E1_INSS + SE1W.E1_CSLL + SE1W.E1_COFINS + SE1W.E1_PIS " 
	If lISS // Desconta ISS
		cQuery +=                      " +  CASE "
		cQuery +=                             " WHEN SA1W.A1_RECISS = '1' THEN SE1W.E1_ISS "
		cQuery +=                             " ELSE 0 "
		cQuery +=                        "  END "
	EndIf
	cQuery +=                      " ) FROM " + RetSqlName("SE1") + " SE1W "
	If lISS 
		cQuery +=                   " INNER JOIN " + RetSqlName("SA1") + " SA1W "
		cQuery +=                      " ON SA1W.A1_FILIAL = '" + xFilial("SA1") + "' "
		cQuery +=                     " AND SA1W.A1_COD = SE1W.E1_CLIENTE "
		cQuery +=                     " AND SA1W.A1_LOJA = SE1W.E1_LOJA "
		cQuery +=                     " AND SA1W.D_E_L_E_T_ = ' ' "
	EndIf
	cQuery +=                       " WHERE SE1W.E1_FILIAL = SE1.E1_FILIAL "
	cQuery +=                        " AND SE1W.E1_JURFAT = SE1.E1_JURFAT "
	cQuery +=                        " AND SE1W.D_E_L_E_T_ = ' ') "
	cQuery +=               " ELSE 0 "
	cQuery +=            "END "
	cQuery +=        " ELSE (OHT.OHT_VLFATH + OHT.OHT_ACRESC - OHT.OHT_DESCON) - (SE1.E1_IRRF + SE1.E1_INSS + SE1.E1_CSLL + SE1.E1_COFINS + SE1.E1_PIS " 
    If lISS
		cQuery +=                                                                   "+  CASE "
		cQuery +=                                                                         " WHEN SA1X.A1_RECISS  = '1' THEN SE1.E1_ISS "
		cQuery +=                                                                         " ELSE 0 "
		cQuery +=                                                                     " END "
	EndIf
	cQuery +=  " ) END HONORLIQ, "
Else
	cQuery +=    " CASE "
	cQuery +=        " WHEN NXA.NXA_COD IS NULL THEN 0 "
	cQuery +=        " ELSE (NXA.NXA_VLFATH + " + IIF(lCpoGrsHon, "NXA.NXA_VGROSH +", "") + " NXA.NXA_VLACRE - NXA.NXA_VLDESC) - "
	cQuery +=             " (SELECT SUM(SE1W.E1_IRRF + SE1W.E1_INSS + SE1W.E1_CSLL + SE1W.E1_COFINS + SE1W.E1_PIS " 
	If lISS // Desconta ISS
		cQuery +=                  " +  CASE "
		cQuery +=                         " WHEN SA1W.A1_RECISS = '1' THEN SE1W.E1_ISS " // Desconta ISS somente se o cliente recolher
		cQuery +=                         " ELSE 0 "
		cQuery +=                     " END "
	EndIf
	cQuery +=              " ) FROM " + RetSqlName("SE1") + " SE1W " 
	If lISS // Desconta ISS
		cQuery +=           " INNER JOIN " + RetSqlName("SA1") + " SA1W "
		cQuery +=              " ON SA1W.A1_FILIAL = '" + xFilial("SA1") + "' "
		cQuery +=             " AND SA1W.A1_COD = SE1W.E1_CLIENTE "
		cQuery +=             " AND SA1W.A1_LOJA = SE1W.E1_LOJA "
		cQuery +=             " AND SA1W.D_E_L_E_T_ = ' ' "
	EndIf	
	cQuery +=               " WHERE SE1W.E1_FILIAL = SE1.E1_FILIAL "
	cQuery +=                 " AND SE1W.E1_JURFAT = SE1.E1_JURFAT "
	cQuery +=                 " AND SE1W.D_E_L_E_T_ = ' ' ) "
	cQuery +=    " END HONORLIQ, "
EndIf
//-------------------
// FIM HONORLIQ
//-------------------
If _lOHTInDic
	cQuery +=        " CASE "
	cQuery +=            " WHEN OHT.OHT_CFATUR IS NULL THEN CASE  WHEN NXA.NXA_COD IS NULL THEN 0 ELSE NXA.NXA_VLFATD END"
	cQuery +=            " ELSE OHT.OHT_VLFATD "
	cQuery +=        " END DESPESA, "
Else
	cQuery +=        " CASE "
	cQuery +=            " WHEN NXA.NXA_COD IS NULL THEN 0 "
	cQuery +=            " ELSE NXA.NXA_VLFATD " 
	cQuery +=        " END DESPESA, "
EndIf

cQuery +=        " SE1.E1_IRRF, "
cQuery +=        " SE1.E1_PIS, "
cQuery +=        " SE1.E1_COFINS, "
cQuery +=        " SE1.E1_CSLL, "

If lISS
	cQuery +=    " CASE "
	cQuery +=        "  WHEN SA1X.A1_RECISS = '1' THEN SE1.E1_ISS "
	cQuery +=        " ELSE 0 "
	cQuery +=    " END E1_ISS, "
EndIf

cQuery +=        " CASE " 
cQuery +=            " WHEN SE1.E1_TXMOEDA = 0 THEN (SE1.E1_VLCRUZ/SE1.E1_VALOR) "
cQuery +=            " ELSE SE1.E1_TXMOEDA "
cQuery +=        " END E1_TXMOEDA, "

If _lOHTInDic // Como buscar o valor na moeda nacional na OHT
	cQuery +=        " CASE "
	cQuery +=            " WHEN OHT.OHT_CFATUR IS NULL THEN 0 "
	cQuery +=            " ELSE (OHT.OHT_VLFATH + OHT.OHT_ACRESC - OHT.OHT_DESCON) * "
	cQuery +=                  " CASE " 
	cQuery +=                      " WHEN SE1.E1_TXMOEDA = 0 THEN (SE1.E1_VLCRUZ/SE1.E1_VALOR)  "
	cQuery +=                      " ELSE SE1.E1_TXMOEDA "
	cQuery +=                  " END "
	cQuery +=        " END HONORNAC, "
	cQuery +=        " CASE "
	cQuery +=            " WHEN OHT.OHT_CFATUR IS NULL THEN 0 "
	cQuery +=            " ELSE OHT.OHT_VLFATD * "
	cQuery +=                  " CASE " 
	cQuery +=                      " WHEN SE1.E1_TXMOEDA = 0 THEN (SE1.E1_VLCRUZ/SE1.E1_VALOR) "
	cQuery +=                      " ELSE SE1.E1_TXMOEDA "
	cQuery +=                  " END "
	cQuery +=        " END DESPNAC, "
Else
	cQuery +=        " CASE "
	cQuery +=            " WHEN NXA.NXA_COD IS NULL THEN 0 "
	cQuery +=            " ELSE (NXA.NXA_FATHMN + " + IIF(lCpoGrsHon, "NXA.NXA_GRSHMN +", "") + " NXA.NXA_ACREMN - NXA.NXA_DESCMN) "
	cQuery +=        " END HONORNAC, "
	cQuery +=        " CASE "
	cQuery +=            " WHEN NXA.NXA_COD IS NULL THEN 0 "
	cQuery +=            " ELSE NXA.NXA_FATDMN "
	cQuery +=        " END DESPNAC, "
EndIf

cQuery +=        " SE1.E1_INSS, "
cQuery +=        " CASE "
cQuery +=            " WHEN NXA.NXA_DREFIH IS NULL THEN '" + Space(TamSx3('NXA_DREFIH')[1]) + "' "
cQuery +=            " ELSE NXA.NXA_DREFIH "
cQuery +=        " END NXA_DREFIH, "
cQuery +=        " CASE "
cQuery +=            " WHEN NXA.NXA_DREFFH IS NULL THEN '" + Space(TamSx3('NXA_DREFFH')[1]) + "' "
cQuery +=            " ELSE NXA.NXA_DREFFH "
cQuery +=        " END NXA_DREFFH, "
cQuery +=        " CASE "
cQuery +=            " WHEN NXA.NXA_DREFID IS NULL THEN '" + Space(TamSx3('NXA_DREFID')[1]) + "' "
cQuery +=            " ELSE NXA.NXA_DREFID "
cQuery +=        " END NXA_DREFID, "
cQuery +=        " CASE "
cQuery +=            " WHEN NXA.NXA_DREFFD IS NULL THEN '" + Space(TamSx3('NXA_DREFFD')[1]) + "' "
cQuery +=            " ELSE NXA.NXA_DREFFD "
cQuery +=        " END NXA_DREFFD, "
cQuery +=        " CASE "
cQuery +=            " WHEN NXA.NXA_DREFIT IS NULL THEN '" + Space(TamSx3('NXA_DREFIT')[1]) + "' "
cQuery +=            " ELSE NXA.NXA_DREFIT "
cQuery +=        " END NXA_DREFIT, "
cQuery +=        " CASE "
cQuery +=            " WHEN NXA.NXA_DREFFT IS NULL THEN '" + Space(TamSx3('NXA_DREFFT')[1]) + "' "
cQuery +=            " ELSE NXA.NXA_DREFFT "
cQuery +=        " END NXA_DREFFT, "
cQuery +=        " CASE "
cQuery +=            " WHEN NXA.NXA_WO IS NULL THEN '2' "
cQuery +=            " ELSE NXA.NXA_WO "
cQuery +=        " END NXA_WO, "
cQuery +=        " SE1.E1_BOLETO, "
cQuery +=        " CASE "
cQuery +=            " WHEN NXA.NXA_CCONT IS NULL THEN '" + Space(TamSx3('NXA_CCONT')[1]) + "' "
cQuery +=            " ELSE NXA.NXA_CCONT "
cQuery +=        " END NXA_CCONT ,"
cQuery +=        " CASE "
cQuery +=     		" WHEN SE1.E1_BOLETO = '1' THEN '" + DtoS(dDataBol) + "' "
cQuery +=     		" WHEN SE1.E1_BOLETO = '2' THEN '" + DtoS(dDataDep) + "' "
cQuery +=     		" ELSE '" + DtoS(dData) + "' "
cQuery +=        " END  DT_BOLETO, "

If _lOHTInDic
	cQuery +=    " CASE "
	cQuery +=        " WHEN (SELECT DISTINCT 1 "
	cQuery +=                " FROM " + RetSqlName("OHT") + " "
	cQuery +=               " WHERE OHT_FILTIT = SE1.E1_FILIAL "
	cQuery +=                 " AND OHT_PREFIX = SE1.E1_PREFIXO "
	cQuery +=                 " AND OHT_TITNUM = SE1.E1_NUM "
	cQuery +=                 " AND OHT_TITPAR = SE1.E1_PARCELA "
	cQuery +=                 " AND OHT_TITTPO = SE1.E1_TIPO "
	cQuery +=                 " AND OHT_NUMLIQ <> '" + _cSpaceNumL + "' "
	cQuery +=                 " AND D_E_L_E_T_ = ' ') IS NULL "
	cQuery +=        " THEN ( CASE "
	cQuery +=                  " WHEN (SELECT DISTINCT 2 "
	cQuery +=                          " FROM " + RetSqlName("OHT") + " "
	cQuery +=                         " WHERE OHT_FILFAT = NXA.NXA_FILIAL "
	cQuery +=                           " AND OHT_FTESCR = NXA.NXA_CESCR "
	cQuery +=                           " AND OHT_CFATUR = NXA.NXA_COD "
	cQuery +=                           " AND OHT_NUMLIQ <> '" + _cSpaceNumL + "' "
	cQuery +=                           " AND D_E_L_E_T_ = ' ') IS NULL "
	cQuery +=                  " THEN ( CASE "
	cQuery +=                            " WHEN (SELECT DISTINCT 3 "
	cQuery +=                                    " FROM " + RetSqlName("OHT") + " "
	cQuery +=                                   " WHERE OHT_FILFAT = NXA.NXA_FILIAL "
	cQuery +=                                     " AND OHT_FTESCR = NXA.NXA_CESCR "
	cQuery +=                                     " AND OHT_CFATUR = NXA.NXA_COD "
	cQuery +=                                     " AND OHT_NUMLIQ = '" + _cSpaceNumL + "' "
	cQuery +=                                     " AND D_E_L_E_T_ = ' ') IS NULL THEN 0 "
	cQuery +=                            " ELSE 3 "
	cQuery +=                         " END ) "
	cQuery +=                  " ELSE 2 "
	cQuery +=               " END ) "
	cQuery +=        " ELSE 1 "
	cQuery +=    " END OHTLEG1 "
Else
	cQuery +=    " 0 OHTLEG1 "
EndIf

cQuery +=     " FROM " + RetSqlName( "SE1" ) + " SE1 "
If lIss
	cQuery += " LEFT JOIN " + RetSqlName("SA1") + " SA1X "
	cQuery +=   " ON SA1X.A1_FILIAL = '" + xFilial("SA1") + "' "
	cQuery +=  " AND SA1X.A1_COD = SE1.E1_CLIENTE "
	cQuery +=  " AND SA1X.A1_LOJA = SE1.E1_LOJA "
	cQuery +=  " AND SA1X.D_E_L_E_T_ = ' ' "
EndIf

If _lOHTInDic
	cQuery += " LEFT JOIN " + RetSqlName("OHT") + " OHT "
	cQuery +=      " ON ( OHT.OHT_FILIAL = '" + xFilial("OHT") + "' "
	cQuery +=       " AND OHT.OHT_FILTIT = SE1.E1_FILIAL "
	cQuery +=       " AND OHT.OHT_PREFIX = SE1.E1_PREFIXO "
	cQuery +=       " AND OHT.OHT_TITNUM = SE1.E1_NUM "
	cQuery +=       " AND OHT.OHT_TITPAR = SE1.E1_PARCELA "
	cQuery +=       " AND OHT.OHT_TITTPO = SE1.E1_TIPO "
	cQuery +=       " AND OHT.D_E_L_E_T_ = ' ' ) "

	If !Empty(cCliente) .And. !Empty(cLoja) .And. !Empty(cCaso)
		cQuery += " INNER JOIN " + RetSqlName("NXC") + " NXC "
		cQuery +=       " ON ( NXC.NXC_FILIAL = '" + xFilial("NXC") + "' "
		cQuery +=        " AND NXC.NXC_CESCR = OHT.OHT_FTESCR "
		cQuery +=        " AND NXC.NXC_CFATUR = OHT.OHT_CFATUR "
		cQuery +=        " AND NXC.NXC_CCLIEN = '" + cCliente + "' "
		cQuery +=        " AND NXC.NXC_CLOJA = '" + cLoja + "' "
		cQuery +=        " AND NXC.NXC_CCASO = '" + cCaso + "' "
		cQuery +=        " AND NXC.D_E_L_E_T_ = ' ' ) "
	EndIf
EndIf

If _lOHTInDic
	cQuery += " LEFT JOIN " + RetSqlName( "NXA" ) + " NXA "
	cQuery +=      " ON ( NXA.NXA_FILIAL = OHT.OHT_FILFAT "
	cQuery +=       " AND NXA.NXA_CESCR = OHT.OHT_FTESCR "
	cQuery +=       " AND NXA.NXA_COD = OHT.OHT_CFATUR "
	cQuery +=       " AND NXA.D_E_L_E_T_ = ' ' ) "
Else
	cQuery += " LEFT JOIN " + RetSqlName( "NXA" ) + " NXA "
	cQuery +=      " ON ( NXA.NXA_FILIAL = SUBSTRING(E1_JURFAT, 1, " + cTamFilial + ") "
	cQuery +=       " AND NXA.NXA_CESCR = SUBSTRING(E1_JURFAT, " + cIniEscr + ", " + cTamEscr + ") "
	cQuery +=       " AND NXA.NXA_COD = SUBSTRING(E1_JURFAT, " + cIniFatur + ", " + cTamFatur + ") "
	cQuery +=       " AND NXA.D_E_L_E_T_ = ' ' ) "
EndIf

If !_lOHTInDic .And. !lCliFat .And. !Empty(cCliente) .And. !Empty(cLoja) .And. !Empty(cCaso)
	cQuery +=  " LEFT JOIN " + RetSqlName( "NXC" ) + " NXC "
	cQuery +=       " ON ( NXC.NXC_FILIAL = '" + xFilial( "NXC" ) + "' "
	cQuery +=       " AND  NXC.NXC_CESCR  = NXA.NXA_CESCR "
	cQuery +=       " AND  NXC.NXC_CFATUR = NXA.NXA_COD "
	cQuery +=       " AND  NXC.D_E_L_E_T_ = ' ' ) "
EndIf

cQuery +=      " LEFT JOIN " + RetSqlName( "SA1" ) + " SA1 "
cQuery +=           " ON ( SA1.A1_FILIAL = '" + xFilial( "SA1" ) + "' "
cQuery +=           " AND  SA1.A1_COD = NXA.NXA_CCLIEN "
cQuery +=           " AND  SA1.A1_LOJA = NXA.NXA_CLOJA "
cQuery +=           " AND  SA1.D_E_L_E_T_ = ' ' ) "

cQuery +=      " LEFT JOIN " + RetSqlName( "RD0" ) + " RD0 "
cQuery +=           " ON ( RD0.RD0_FILIAL = '" + xFilial( "RD0" ) + "' "
cQuery +=           " AND  RD0.RD0_CODIGO = NXA.NXA_CPART "
cQuery +=           " AND  RD0.D_E_L_E_T_ = ' ' ) "

cQuery +=     " INNER JOIN " + RetSqlName("CTO") + " CTO "
cQuery +=             " ON CTO.CTO_FILIAL = '" + xFilial("CTO") + "'"
cQuery +=            " AND CAST(CTO_MOEDA AS DECIMAL) = SE1.E1_MOEDA"
cQuery +=            " AND CTO.D_E_L_E_T_ = ' '"

cQuery +=   " WHERE SE1.E1_ORIGEM IN ('JURA203','FINA040','FINA460') "

If !lChkEscrit
	cQuery += " AND SE1.E1_FILIAL = '" + xFilial( "SE1" ) + "' "
EndIf

cQuery +=     " AND SE1.E1_TITPAI = '" + Space(TamSx3('E1_TITPAI')[1]) + "' "

If !_lOHTInDic
	cQuery += " AND SE1.E1_TIPOLIQ = ' ' "
EndIf

If !_lOHTInDic .And. !lCliFat .And. !Empty(cCliente) .And. !Empty(cLoja) .And. !Empty(cCaso)
	cQuery += " AND NXC.NXC_CCLIEN = '" + cCliente + "' "
	cQuery += " AND NXC.NXC_CLOJA  = '" + cLoja + "' "
	cQuery += " AND NXC.NXC_CCASO  = '" + cCaso + "' "
EndIf

cQuery +=     " AND SE1.D_E_L_E_T_ = ' ' ) X  WHERE  "

Do Case
	Case nSituacao == 1 // Em atraso
		cQuery +=    " (X.NXA_DTCANC = '" + cSpcDtCanc + "' OR X.NXA_CESCR IS NULL) "
		cQuery += " AND X.E1_SALDO > 0 "
		cQuery += " AND X.E1_VENCTO < X.DT_BOLETO "
	Case nSituacao == 2 // Parcialmente Pago
		cQuery +=    " (X.NXA_DTCANC = '" + cSpcDtCanc + "' OR X.NXA_CESCR IS NULL) "
		cQuery += " AND X.E1_SALDO > 0 "
		cQuery += " AND X.E1_VALOR - X.E1_SALDO > 0 "
	Case nSituacao == 3 // Pago
		cQuery +=    " (X.NXA_DTCANC = '" + cSpcDtCanc + "' OR X.NXA_CESCR IS NULL) "
		cQuery += " AND X.E1_SALDO = 0 "
		cQuery += " AND X.OHTLEG1 <> 2 "
	Case nSituacao == 4 // Pendente
		cQuery +=    " (X.NXA_DTCANC = '" + cSpcDtCanc + "' OR X.NXA_CESCR IS NULL) "
		cQuery += " AND X.E1_SALDO <> 0 "
	Case nSituacao == 5 // Canceladas
		cQuery +=     " X.NXA_DTCANC <> '" + cSpcDtCanc + "' "
		cQuery += " AND X.NXA_WO = '2' "
	Case nSituacao == 6 // Exceto Fat. Cancelada
		cQuery +=     " X.NXA_DTCANC = '" + cSpcDtCanc + "' "
		If _lOHTInDic
			cQuery += " AND X.OHTLEG1 <> 0 "
		Else
			cQuery += " AND X.E1_JURFAT <> ' ' "
		EndIf
	Case nSituacao == 7 // Fat. Canceladas por WO
		cQuery +=     " X.NXA_DTCANC <> '" + cSpcDtCanc + "' "
		cQuery += " AND X.NXA_WO = '1' "
	OtherWise
		cQuery += " 1 = 1 "
EndCase

If lCliFat
	If !Empty(cCliente)
		cQuery += " AND X.CODCLIPAG = '" + cCliente + "' "
		If !Empty(cLoja)
			cQuery += " AND X.LOJCLIPAG = '" + cLoja + "' "
		EndIf
	EndIf
	If _lOHTInDic .And. nSituacao <> 5
		cQuery += " AND X.OHTLEG1 <> 0 "
	ElseIf !_lOHTInDic 
		cQuery += " AND X.E1_JURFAT <> ' ' "
	EndIf
EndIf

cQuery +=     " ) Y  WHERE "

Do Case 
	Case nSituacao == 2 // Parcialmente pago
		cQuery += " Y.SALDO > 0 AND Y.SALDO < ( Y.VALORLIQ + Y.IMPOSTOS ) "
	Case nSituacao == 3 // Pago
		cQuery += " Y.SALDO = 0 "
	Case nSituacao == 4 // Pendente
		cQuery += " Y.NXA_DTCANC = '" + cSpcDtCanc + "' "
		cQuery += " AND (( Y.E1_VENCTO >= Y.DT_BOLETO AND Y.SALDO = ( Y.VALORLIQ + Y.IMPOSTOS )) "
		cQuery +=      " OR ( Y.SALDO > 0  AND Y.SALDO < ( Y.VALORLIQ + Y.IMPOSTOS ))) "
	OtherWise 
		cQuery += " 1 = 1"
EndCase

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} J243Legenda
Função de preenchimento da legenda do registros

@param TABCOB Tabela temporária
@param lWO    Indica se foi cancelada por WO (.T.) ou não (.F.)

@return cLegenda Código da legenda

@author Jorge Martins
@since 11/09/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function J243Legenda(TABCOB, lWO)
	Local cLegenda := "0"

	// Legendas
	// A - Faturas em aberto
	// V - Faturas parcialmente pagas
	// P - Faturas totalmente pagas
	// C - Faturas canceladas
	// W - Faturas canceladas por WO
	// L - Títulos gerados pela Liquidação
	// R - Faturas Liquidadas

	Do Case

	Case _lOHTInDic .And. (TABCOB)->OHTLEG1 == 1 // Títulos gerados pela liquidação
		cLegenda := "L"

	Case _lOHTInDic .And. (TABCOB)->OHTLEG1 == 2 // Títulos de faturas liquidadas (renegociadas)
		cLegenda := "R"

	Case Empty((TABCOB)->NXA_COD) // Títulos sem fatura
		cLegenda := "0"

	Case Empty((TABCOB)->NXA_DTCANC) .And. (TABCOB)->SALDO == ( (TABCOB)->VALORLIQ + (TABCOB)->IMPOSTOS ) // Faturas em aberto
		cLegenda := "A"

	Case Empty((TABCOB)->NXA_DTCANC) .And. (TABCOB)->SALDO > 0 .And. (TABCOB)->SALDO < ( (TABCOB)->VALORLIQ + (TABCOB)->IMPOSTOS ) // Faturas parcialmente pagas
		cLegenda := "V"

	Case Empty((TABCOB)->NXA_DTCANC) .And. (TABCOB)->SALDO == 0 // Faturas totalmente pagas
		cLegenda := "P"

	Case !Empty((TABCOB)->NXA_DTCANC) .And. !lWO // Faturas canceladas
		cLegenda := "C"

	Case !Empty((TABCOB)->NXA_DTCANC) .And. lWO // Faturas canceladas por WO
		cLegenda := "W"

	Otherwise
		cLegenda := "0"
	EndCase

Return cLegenda

//-------------------------------------------------------------------
/*/{Protheus.doc} J243Situac
Função de preenchimento do campo de situação

@param TABCOB  , Tabela temporária
@param lWO     , Indica se foi cancelada por WO (.T.) ou não (.F.)
@param xAtraso , Quantidade de dias para cálculo do atraso
@param cLegenda, Legenda que será utilizada no registro

@return cSituac, Situação da fatura filtrada

@author Jorge Martins
@since  11/09/2017
/*/
//-------------------------------------------------------------------
Function J243Situac(TABCOB, lWO, xAtraso, cLegenda)
Local cSituac := "0"

// Situações
// 1 - Em atraso (Apresenta as parcelas que estão atrasadas (Atraso > 0) e que não foram totalmente pagas)
// 2 - Parcialmente pago (Apresenta somente as parcelas pagas das faturas que foram parcialmente pagas)
// 3 - Pago (Apresenta as parcelas das faturas que foram totalmente pagas)
// 4 - Pendente (Apresenta todas as parcelas de faturas que possuam valor a receber, mesmo as que ainda não estão vencidas)
// 5 - Fat. Cancelada (Apresenta todas as parcelas das faturas que estejam canceladas no SIGAPFS)
// 6 - Exceto Fat. Cancelada (Apresenta todas as parcelas exceto das faturas que estão canceladas no SIGAPFS)
// 7 - Fat. Cancelada por WO (Apresenta todas as parcelas das faturas que foram canceladas por WO no SIGAPFS)
// 8 - Todas (Apresenta todas as parcelas)
// 9 - Renegociado (Apresenta todas as parcelas das faturas que foram renegociadas(passaram por processo de liquidação))

Do Case
Case !Empty((TABCOB)->NXA_DTCANC) .AND. !lWO // Fat. Cancelada
	cSituac := STR0012 // "Fat. cancelada"
	xAtraso := 0 // "Canceladas não tem atraso"

Case !Empty((TABCOB)->NXA_DTCANC) .AND. lWO // WO
	cSituac := STR0014 // "Fat. cancelada por WO"
	xAtraso := 0 // "Canceladas por WO não tem atraso"

Case (TABCOB)->E1_SALDO == 0 .And. cLegenda == "R" // Fatura Renegociada
	cSituac := STR0060 // "Renegociado"

Case (TABCOB)->E1_SALDO > 0 .And. xAtraso > 0 // Em atraso
	cSituac := STR0008 // "Em atraso"

Case (TABCOB)->E1_SALDO == 0 // Pago
	cSituac := STR0010 // "Pago"
	xAtraso := 0 // "Pago não tem atraso"

Case ( (TABCOB)->E1_VALOR - (TABCOB)->E1_SALDO ) > 0 // Pagas Parcial
	cSituac := STR0009 // "Parcialmente pago"

Case (TABCOB)->E1_SALDO > 0 .And. xAtraso == 0 // Pendente
	cSituac := STR0011 // "Pendente"

Otherwise
	cSituac := STR0015 // "Todas"
EndCase

Return cSituac

//-------------------------------------------------------------------
/*/{Protheus.doc} J243Indice()
Criação dos índices de pesquisa do browse de cobrança

@return Array com indice para a função JurCriaTmp

@author Jorge Martins
@since 11/09/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J243Indice()
Local aIndice := {}

Aadd(aIndice, {Alltrim(RetTitle("E1_NUM"))+" + "+ Alltrim(RetTitle("E1_PARCELA")) , "E1_NUM+E1_PARCELA"   , TAMSX3("E1_NUM")[1] + TAMSX3("E1_PARCELA")[1] }) // Número do Titulo + Parcela
Aadd(aIndice, {Alltrim(RetTitle("NXA_CESCR"))+" + "+ Alltrim(RetTitle("NXA_COD")) , "NXA_CESCR+NXA_COD"   , TAMSX3("NXA_CESCR")[1] + TAMSX3("NXA_COD")[1] }) // Código Estritorio + Fatura
Aadd(aIndice, {Alltrim(RetTitle("NXA_COD"))                                       , "NXA_COD"             , TAMSX3("NXA_COD")[1]                          }) // Número da Fatura

Aadd(aIndice, {Alltrim(STR0035 + " + " + STR0036)                                 , "CODCLIFAT+LOJCLIFAT" , TAMSX3("A1_COD")[1]+TAMSX3("A1_LOJA")[1]      }) // Código + Loja do cliente Fatura
Aadd(aIndice, {Alltrim(STR0037)                                                   , "RAZSOCFAT"           , TAMSX3("A1_NOME")[1]                          }) // Nome do cliente Fatura
Aadd(aIndice, {Alltrim(STR0038 + " + " + STR0039)                                 , "CODCLIPAG+LOJCLIPAG" , TAMSX3("A1_COD")[1]+TAMSX3("A1_LOJA")[1]      }) // Código + Loja do cliente pagador
Aadd(aIndice, {Alltrim(STR0040)                                                   , "RAZSOCPAG"           , TAMSX3("A1_NOME")[1]                          }) // Nome do cliente pagador

Aadd(aIndice, {Alltrim(RetTitle("RD0_SIGLA"))                                     , "RD0_SIGLA"           , TAMSX3("RD0_SIGLA")[1]                        }) // Sigla do responsáve

Return aIndice

//-------------------------------------------------------------------
/*/{Protheus.doc} J243CpoQry()
Trecho de query de campos criados manualmente na tabela virtual

@param  cCampo Campo da query

@return cQuery Trecho da query referente ao campo indicado

@author Jorge Martins
@since 19/09/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J243CpoQry(cCampo)
Local cQuery    := ""
Local cCaseWhen := " WHEN X.NXA_COD = ' ' THEN 0 "
Local cJoin     := ""
Local lISS      := GetNewPar("MV_DESCISS",.F.)

If _lOHTInDic
	cCaseWhen := " WHEN OHTLEG1 = 0 THEN 0 "
	cJoin :=      " AND ( #.E1_JURFAT <> ' ' "
	cJoin +=            " OR ( X.OHTLEG1 <> 0 "
	cJoin +=                 " AND #.E1_FILIAL  = X.E1_FILIAL "
	cJoin +=                 " AND #.E1_PREFIXO = X.E1_PREFIXO "
	cJoin +=                 " AND #.E1_NUM     = X.E1_NUM "
	cJoin +=                 " AND #.E1_PARCELA = X.E1_PARCELA "
	cJoin +=                 " AND #.E1_TIPO    = X.E1_TIPO "
	cJoin +=                ")"
	cJoin +=	       ")"
EndIf

Do Case
Case cCampo == 'SALDO'
	cQuery += " ( SELECT "
	cQuery +=            " CASE "
	cQuery +=                cCaseWhen
	cQuery +=                " ELSE SUM(SE1S.E1_SALDO) "
	cQuery +=            " END E1_SALDO "
	cQuery +=     " FROM " + RetSqlName( "SE1" ) + " SE1S "
	cQuery +=        " WHERE SE1S.E1_FILIAL = X.E1_FILIAL "
	cQuery +=          " AND SE1S.E1_JURFAT = X.E1_JURFAT "
	If !_lOHTInDic
		cQuery +=      " AND SE1S.E1_TIPOLIQ = ' ' "
	Else
		cQuery +=      StrTran(cJoin, "#", "SE1S")
	EndIf
	cQuery +=          " AND SE1S.D_E_L_E_T_ = ' ' "
	cQuery += " ) "
Case cCampo == 'VALORLIQ'
	cQuery += " ( SELECT "
	cQuery +=            " CASE "
	cQuery +=                cCaseWhen
	cQuery +=                " ELSE SUM(SE1V.E1_VALOR - ( SE1V.E1_IRRF + SE1V.E1_ISS + SE1V.E1_INSS + SE1V.E1_CSLL + SE1V.E1_COFINS + SE1V.E1_PIS )) "
	cQuery +=            " END VALORLIQ "
	cQuery +=     " FROM " + RetSqlName( "SE1" ) + " SE1V "
	cQuery +=        " WHERE SE1V.E1_FILIAL = X.E1_FILIAL "
	cQuery +=          " AND SE1V.E1_JURFAT = X.E1_JURFAT "
	If !_lOHTInDic
		cQuery +=      " AND SE1V.E1_TIPOLIQ = ' ' "
	Else
		cQuery +=      StrTran(cJoin, "#", "SE1V")
	EndIf
	cQuery +=          " AND SE1V.D_E_L_E_T_ = ' ' "
	cQuery += " ) "
Case cCampo == 'IMPOSTOS'
	cQuery += " ( SELECT "
	cQuery +=            " CASE "
	cQuery +=                cCaseWhen
	cQuery +=                " ELSE SUM(SE1I.E1_IRRF + SE1I.E1_INSS + SE1I.E1_CSLL + SE1I.E1_COFINS + SE1I.E1_PIS " + IIF(lISS, " + ", ") ")
	If lISS // Desconta ISS
		cQuery +=        " CASE "
		cQuery +=            " WHEN SA1Z.A1_RECISS = '1' " // Desconta ISS somente se o cliente recolher
		cQuery +=            " THEN SE1I.E1_ISS "
		cQuery +=            " ELSE 0 "
		cQuery +=        " END) "
	EndIf
	cQuery +=            " END IMPOSTOS "
	cQuery +=         " FROM " + RetSqlName( "SE1" ) + " SE1I "
	If lISS
		cQuery +=    " INNER JOIN " + RetSqlName("SA1") + " SA1Z "
		cQuery +=       " ON SA1Z.A1_FILIAL = '" + xFilial("SA1") + "' "
		cQuery +=      " AND SA1Z.A1_COD = SE1I.E1_CLIENTE "
		cQuery +=      " AND SA1Z.A1_LOJA = SE1I.E1_LOJA "
		cQuery +=      " AND SA1Z.D_E_L_E_T_ = ' ' "
	EndIf
	cQuery +=        " WHERE SE1I.E1_FILIAL = X.E1_FILIAL "
	cQuery +=          " AND SE1I.E1_JURFAT = X.E1_JURFAT "
	If !_lOHTInDic
		cQuery +=      " AND SE1I.E1_TIPOLIQ = ' ' "
	Else
		cQuery +=      StrTran(cJoin, "#", "SE1I")
	EndIf
	cQuery +=          " AND SE1I.D_E_L_E_T_ = ' ' "
	cQuery += " ) "
EndCase

Return cQuery

//-------------------------------------------------------------------
/*/ { Protheus.doc } J243IncCob(oTmpTit, oBrw243)
Função chamar a inclusão de cobrança em lote

@param oTmpTit Objeto da tabela temporaria de titulos
@param oBrw243 Objeto do browser de titulos

@author bruno.ritter
@since 29/09/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function J243IncCob(oTmpTit, oBrw243)
Local cTabTemp   := oTmpTit:GetRealName()
Local cQuery     := ""
Local cQryRes    := Nil
Local lInvert    := oBrw243:IsInvert()
Local cMarca     := oBrw243:Mark()

	cQuery := "SELECT E1_FILIAL, E1_NUM, E1_PREFIXO, E1_PARCELA, E1_TIPO FROM " + cTabTemp + " WHERE OK " + Iif(lInvert, "<>", "=" ) + " '" + cMarca + "'"
	cQuery := ChangeQuery(cQuery, .F.)

	cQryRes := GetNextAlias()
	dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cQryRes, .T., .F. )

	If (cQryRes)->( EOF() )
		JurMsgErro(STR0046,, STR0047) // "Nenhum registro foi marcado." "Selecione ao menos um registro para executar essa operação."
	Else
		If J244BrwInc(cQryRes)
			TCSQLExec("UPDATE " + cTabTemp + " SET OK = ' '") //Usar TCSQLExec apenas na tabela temporária criada pelo FWTemporaryTable()

			oBrw243:SetInvert(.F.)
			oBrw243:Refresh(.T.)
		EndIf
	EndIf
	(cQryRes)->( DbCloseArea() )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J243SU5Brw()
Rotina auxiliar para criar o browser dos contatos.

@return aRet  Array auxiliar para rotina JurCriatmp()
		aRet[1] Array com a estrutura de campos adicional
		aRet[2] Array com os campos que devem aparecer no Browse
		aRet[3] Array com os campos que não devem aparecer no Browse
		aRet[4] String com o Select para alimentar o browse de contatos
		aRet[5] Array com os índices do Browse

@author Luciano Pereira dos Santos
@since 19/09/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J243SU5Brw()
Local aRet       := {}
Local cQuery     := ''
Local aOpcoes    := STRTOKARR(JurX3cBox('U5_ATIVO'), ";")
Local aCmpAcBrw  := {} // Campos que devem aparecer no Browse
Local aCmpNotBrw := {} // Campos que não devem aparecer no Browse
Local aStruAdic  := {} // Estrutura adicional
Local aIndice    := {}
Local nI         := 0
Local nPos       := 0
Local cWhen      := ''
Local cThen      := ''

cQuery := " SELECT AC8.AC8_FILIAL, AC8.AC8_FILENT, AC8.AC8_ENTIDA, AC8.AC8_CODENT, SU5.U5_CODCONT, "
cQuery +=        " SU5.U5_CONTAT, SU5.U5_DDD, SU5.U5_FONE, SU5.U5_FCOM1, SU5.U5_EMAIL, SU5.U5_END, "
cQuery +=        " SU5.U5_BAIRRO, SU5.U5_MUN, SU5.U5_EST, SU5.U5_CEP, SU5.U5_TIPO, SU5.R_E_C_N_O_ RECNO, "
cQuery +=        " CASE "
cQuery +=            " WHEN SYA.YA_DESCR IS NULL THEN ' ' "
cQuery +=            " ELSE SYA.YA_DESCR "
cQuery +=        " END PAIS, "
cQuery +=        " CASE "
For nI := 1 To Len(aOpcoes)
	nPos   := At('=', aOpcoes[nI])
	cWhen  := Left(aOpcoes[nI], nPos - 1)
	cThen  := Right(aOpcoes[nI], Len(aOpcoes[nI]) - nPos)
	cQuery +=     " WHEN SU5.U5_ATIVO = '" + cWhen + "' THEN '" + cThen + "' "
Next nI
cQuery +=        " ELSE ' ' END ATIVO "
cQuery += " FROM " + RetSqlName("SU5") + " SU5 "
cQuery += " INNER JOIN " + RetSqlName("AC8") + " AC8 "
cQuery +=        " ON (AC8.AC8_FILIAL = '" + xFilial("AC8") + "' " 
cQuery +=        " AND AC8.AC8_ENTIDA = 'SA1' "
cQuery +=        " AND AC8.AC8_CODCON = SU5.U5_CODCONT "
cQuery +=        " AND AC8.D_E_L_E_T_ = ' ') "
cQuery += " LEFT JOIN " + RetSqlName("SYA") + " SYA "
cQuery +=       " ON (SYA.YA_FILIAL = '" + xFilial("SYA") + "'"
cQuery +=       " AND SU5.U5_PAIS = SYA.YA_CODGI "
cQuery +=       " AND SYA.D_E_L_E_T_ = ' ') "
cQuery += " WHERE SU5.U5_FILIAL = '" + xFilial("SU5") + "'"
cQuery +=   " AND SU5.D_E_L_E_T_ = ' ' "

aCmpAcBrw := {"U5_CODCONT", "U5_CONTAT", "U5_DDD", "U5_FONE", "U5_FCOM1", "U5_EMAIL", "U5_END", "U5_BAIRRO", "U5_MUN", "U5_EST", "U5_CEP", "U5_ATIVO"}

aCmpNotBrw :={"AC8_FILENT", "AC8_ENTIDA", "AC8_CODENT"}

Aadd(aStruAdic, { "PAIS" , STR0049                      , "C", TamSX3("YA_DESCR")[1],  0, "", "YA_DESCR" } ) // "País"
Aadd(aStruAdic, { "ATIVO", Alltrim(RetTitle("U5_ATIVO")), "C", 10                   ,  0, "", "U5_ATIVO" } ) // "Ativo"
Aadd(aStruAdic, { "RECNO", ""                           , "N", 16                   ,  0, "", "" } ) // "Renco"

Aadd(aIndice, {Alltrim(RetTitle("U5_CODCONT")), "U5_CODCONT", TamSX3("U5_CODCONT")[1] }) // Codigo do Contato
Aadd(aIndice, {Alltrim(RetTitle("U5_CONTAT")) , "U5_CONTAT" , TamSX3("U5_CONTAT")[1]  }) // Nome do Contato

aRet := {aStruAdic, aCmpAcBrw, aCmpNotBrw, cQuery, aIndice}

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J243SU5Opt
Rotina alteração/visualização do browser dos contatos.

@param TABSU5      Area da tabela temporaria de contatos (SU5)
@param oBrwContat  Browser da tabela de contatos (SU5)
@param aCampos     array de campos para atualizar a tabela temporaria
@param nOption     Opção de ação do browser Ex: 2- Visualizar; 4 - Alterar
@return Nil

@author Luciano Pereira dos Santos
@since 01/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J243SU5Opt(TABSU5, oBrwContat, aCampos, nOption)
Local aArea    := GetArea()
Local aAreaSU5 := SU5->(GetArea())
Local nRecno   := (TABSU5)->RECNO
Local nI       := 0
Local cPais    := ''
Local cAtivo   := ''

SU5->(DBGoto(nRecno))

If nOption == 2

	INCLUI := .F.
	ALTERA := .F.

	A70VISUAL('SU5', nRecno, nOption)

ElseIf nOption == 4

	INCLUI := .F.
	ALTERA := .T.

	A70ALTERA('SU5', nRecno, nOption)

	cPais   := JurGetDados("SYA", 1, xFilial("SYA") + SU5->U5_PAIS, "YA_DESCR")
	cAtivo  := JurInfBox('U5_ATIVO', SU5->U5_ATIVO )

	RecLock(TABSU5, .F.)
	For nI := 1 To Len(aCampos)
		(TABSU5)->(FieldPut(FieldPos(aCampos[nI]), SU5->(FieldGet(FieldPos(aCampos[nI]))) ) )
	Next nI
	(TABSU5)->(FieldPut(FieldPos("PAIS") , cPais  ))
	(TABSU5)->(FieldPut(FieldPos("ATIVO"), cAtivo ))

	(TABSU5)->(MsUnLock())

	oBrwContat:Refresh()

EndIf

RestArea(aAreaSU5)
RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J243SE1Opt
Rotina para abrir a visualização dos titulos ou para chamar a demonstração
dos documentos relacionados da fatura.

@param cSE1Chave   Chave da tabela SE1 na ordem 1
@param nOption     Opção de ação onde 2=Visualizar e 1=Docs Relacionados

@return Nil

@author Luciano Pereira dos Santos
@since 01/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function J243SE1Opt(cSE1Chave, nOption)
Local aArea       := GetArea()
Local aAreaSE1    := SE1->(GetArea())
Local cFilAtu     := cFilAnt

Local oModel     := Nil
Local oStructNXM := Nil
Local oView      := Nil
Local oExecView  := Nil
Local lCpoTit    := NXM->(ColumnPos("NXM_TITNUM")) > 0 //@12.1.33
Local cQuery     := ""
Local aResult    := {}
Local nX         := 0
Local cImgFat    := ""
Local cMsgRet    := ""

Default cSE1Chave := ""
Default nOption   := "2"

If !Empty(cSE1Chave)

	SE1->(DbSetOrder(1)) //E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO
	If SE1->(DbSeek(cSE1Chave))
		If nOption == 1  // Docs Relacionados da Fatura
			If (_lOHTInDic := FWAliasInDic("OHT"))
				//Realiza o tramento dos documentos vinculados da fatura
				//Busca os escritórios/faturas vinculados ao título
				cQuery := "SELECT DISTINCT OHT.OHT_FTESCR, OHT.OHT_CFATUR "
				cQuery +=   "FROM " + RetSqlName("OHT") + " OHT "
				cQuery += " WHERE OHT.OHT_FILTIT = '" + SE1->E1_FILIAL  + "'"
				cQuery +=   " AND OHT.OHT_PREFIX = '" + SE1->E1_PREFIXO + "'"
				cQuery +=   " AND OHT.OHT_TITNUM = '" + SE1->E1_NUM     + "'"
				cQuery +=   " AND OHT.OHT_TITPAR = '" + SE1->E1_PARCELA + "'"
				cQuery +=   " AND OHT.OHT_TITTPO = '" + SE1->E1_TIPO    + "'"
				cQuery +=   " AND OHT.OHT_FILIAL = '" + xFilial("OHT") + "'"
				cQuery +=   " AND OHT.D_E_L_E_T_ = ' ' "
				aResult := JurSql(cQuery, {"OHT_FTESCR", "OHT_CFATUR"})

				For nX := 1 to Len(aResult)
					cMsgRet := ""
					cImgFat := JurImgFat(aResult[nX, 01], aResult[nX, 02], .T., .F., @cMsgRet)

					If !Empty(cMsgRet)
						cMsgRet := "J243SE1Opt -> " + cMsgRet
					EndIf

					JurCrLog(cMsgRet)
					J204GetDocs(aResult[nX, 01], aResult[nX, 02], , , cImgFat, .F.)
				Next nX

				If lCpoTit .And. Empty(StrTran(SE1->E1_JURFAT,"-", "")) 
					cImgFat := JurImgFat("", "", .T., .F., @cMsgRet)
					
					If !Empty(cMsgRet)
						cMsgRet := "J243SE1Opt -> " + cMsgRet
					EndIf

					JurCrLog(cMsgRet)
					J204GetDocs("", "", , , cImgFat, .F. , /*cNewDoc*/, .F., SE1->E1_FILIAL, SE1->E1_PREFIXO, SE1->E1_NUM , SE1->E1_PARCELA, SE1->E1_TIPO)
				EndIf

				//Verifica o documento relacionado da fatura
				oModel := FWLoadModel("JURA204")

				oStructNXM := FWFormStruct(2, "NXM")
				oStructNXM:RemoveField("NXM_ORDEM")
				oStructNXM:RemoveField("NXM_NOMORI")
				oStructNXM:RemoveField("NXM_CPATH")
				If lCpoTit
					oStructNXM:RemoveField('NXM_FILTIT')
					oStructNXM:RemoveField('NXM_PREFIX')
					oStructNXM:RemoveField('NXM_TITNUM')
					oStructNXM:RemoveField('NXM_TITPAR')
					oStructNXM:RemoveField('NXM_TITTPO')
				EndIf

				oView := FWFormView():New()
				oView:SetModel(oModel)
				oView:AddGrid("JURA204_NXM", oStructNXM, "NXMDETAIL")
				oView:CreateHorizontalBox("FORMGRID", 100)
				oView:SetOwnerView("JURA204_NXM", "FORMGRID")
				oView:SetCloseOnOk({|| .T.})
				oView:AddUserButton(STR0054, "SDUSEEK", {|oAux| J204PDFViz(oAux)}) //"Visualizar"
				oView:SetDescription(STR0059) // "Docs Relacionados"
				oView:SetOperation(1)

				oExecView := FwViewExec():New()
				oExecView:SetView(oView)
				oExecView:SetSize(200, 515)
				oExecView:SetTitle(STR0059) // "Docs Relacionados"
				oExecView:OpenView(.F.)
			Else
				JurDocVinc()
			EndIf

		ElseIf nOption == 2 // Visualizar
			cCadastro := STR0053 //"Visualizar título" (A função AxVisual() precisa dessa variável estatica)
			cFilAnt   := SE1->E1_FILIAL
			SE1->( AxVisual( "SE1", SE1->(Recno()), nOption ) )
			cFilAnt := cFilAtu
		EndIf
	EndIf

EndIf

RestArea(aAreaSE1)
RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J243FatBrw()
Rotina auxiliar para criar o browse das faturas.

@return aRet,   Array auxiliar para rotina JurCriaTmp()
        aRet[1] Array com a estrutura de campos adicional
        aRet[2] Array com os campos que devem aparecer no Browse
        aRet[3] Array com os campos que não devem aparecer no Browse
        aRet[4] String com o Select para alimentar o Browse de faturas
        aRet[5] Array com índices da tabela
        aRet[6] Array com os títulos dos campos do Browse

@author Jorge Martins
@since  21/06/2021
/*/
//-------------------------------------------------------------------
Static Function J243FatBrw()
Local aRet       := {}
Local aCmpAcBrw  := {} // Campos que devem aparecer no Browse
Local aCmpNotBrw := {} // Campos que não devem aparecer no Browse
Local aStruAdic  := {} // Estrutura adicional
Local aIndice    := {} // Índides da tabela
Local aTitCpoBrw := {} // Títulos do Browse
Local cQuery     := ""
Local lCpoGrsHon := NXA->(ColumnPos("NXA_VGROSH")) > 0 //@12.1.2310

	cQuery += " SELECT NXA.NXA_FILIAL, NXA.NXA_CESCR, NXA.NXA_COD, NXA.R_E_C_N_O_ NXARECNO, CTO.CTO_SIMB, "
	cQuery +=        " NXA.NXA_VLFATH + NXA.NXA_VLACRE + NXA.NXA_VLFATD " + IIF(lCpoGrsHon, "+ NXA.NXA_VGROSH", "") + " TOTALFAT, "
	cQuery +=        " OHT.OHT_FILTIT, OHT.OHT_PREFIX, OHT.OHT_TITNUM, OHT.OHT_TITPAR, OHT.OHT_TITTPO, "
	cQuery +=        " CASE "
	cQuery +=            " WHEN OHT.OHT_NUMLIQ = '" + _cSpaceNumL + "' THEN 0 "
	cQuery +=            " ELSE OHT.OHT_VLFATH + OHT.OHT_VLFATD + OHT.OHT_DESCON + OHT.OHT_ACRESC "
	cQuery +=        " END TOTALREN"
	cQuery +=   " FROM " + RetSqlName("OHT") + " OHT "
	cQuery +=  " INNER JOIN " + RetSqlName("NXA") + " NXA "
	cQuery +=     " ON NXA.NXA_FILIAL = OHT.OHT_FILFAT "
	cQuery +=    " AND NXA.NXA_CESCR  = OHT.OHT_FTESCR "
	cQuery +=    " AND NXA.NXA_COD    = OHT.OHT_CFATUR "
	cQuery +=    " AND NXA.D_E_L_E_T_ = ' ' "
	cQuery +=  " INNER JOIN " + RetSqlName("CTO") + " CTO "
	cQuery +=     " ON CTO.CTO_FILIAL = '" + xFilial("CTO") + "' "
	cQuery +=    " AND CTO.CTO_MOEDA  = NXA.NXA_CMOEDA "
	cQuery +=    " AND CTO.D_E_L_E_T_ = ' ' "
	cQuery +=  " WHERE OHT.OHT_FILIAL = '" + xFilial("OHT") + "'
	cQuery +=    " AND OHT.D_E_L_E_T_ = ' ' "

	Aadd(aStruAdic, { "TOTALFAT", STR0061, "N", 16,  2, "@E 9,999,999,999,999.99", "" } ) // "Total Fatura"
	Aadd(aStruAdic, { "TOTALREN", STR0062, "N", 16,  2, "@E 9,999,999,999,999.99", "" } ) // "Total Renegociado"
	Aadd(aStruAdic, { "NXARECNO", ""     , "N", 16,  0, ""                       , "" } ) // "Recno"

	aCmpAcBrw  := {"NXA_CESCR", "NXA_COD", "CTO_SIMB", "TOTALFAT", "TOTALREN"}
	aCmpNotBrw := {"NXA_FILIAL", "NXARECNO", "OHT_FILTIT", "OHT_PREFIX", "OHT_TITNUM", "OHT_TITPAR", "OHT_TITTPO"}

	Aadd(aIndice, {Alltrim(RetTitle("NXA_CESCR")) + " + " + Alltrim(RetTitle("NXA_COD")) , "NXA_CESCR+NXA_COD"   , TAMSX3("NXA_CESCR")[1] + TAMSX3("NXA_COD")[1] }) // Código Estritorio + Fatura
	Aadd(aIndice, {Alltrim(RetTitle("NXA_COD"))                                          , "NXA_COD"             , TAMSX3("NXA_COD")[1]                          }) // Número da Fatura

	Aadd(aTitCpoBrw, {"CTO_SIMB", AllTrim(RetTitle("E1_MOEDA"))}) // "Moeda"

	aRet := {aStruAdic, aCmpAcBrw, aCmpNotBrw, cQuery, aIndice, aTitCpoBrw}

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J243FatOpt
Opções do browse de Faturas

@param nOpc, Opção de ação do browse
             1 - Docs Relacionados
             2 - Visualizar

@author Jorge Martins
@since  22/06/2021
/*/
//-------------------------------------------------------------------
Static Function J243FatOpt(nOpc)
Local aArea    := GetArea()
Local aAreaNXA := NXA->(GetArea())

	If (TABFAT)->NXARECNO > 0
		NXA->(DBGoto((TABFAT)->NXARECNO))

		If nOpc == 1 // Docs Relacionados
			J204PDF(.T.)
		ElseIf nOpc == 2 // Visualizar
			FWExecView(STR0054, "JURA204") // "Visualizar"
		EndIf
	EndIf

	RestArea(aAreaNXA)
	RestArea(aArea)

Return
