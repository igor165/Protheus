#INCLUDE "JURA235A.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"
Static _lFwPDCanUse := FindFunction("FwPDCanUse")

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA235A
Aprovação de Despesa

@author bruno.ritter
@since 17/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA235A()
Local oBrowse   := Nil
Local cLojaAuto := SuperGetMv( "MV_JLOJAUT", .F., "2", ) // Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
Local cFiltro   := ""

	oBrowse := FWMBrowse():New()
	oBrowse:SetDescription(STR0007) // "Aprovação de Despesa"
	oBrowse:SetAlias("NZQ")
	oBrowse:SetLocate()
	Iif(cLojaAuto == "1", JurBrwRev(oBrowse, "NZQ", {"NZQ_CLOJA"}), )

	oBrowse:AddLegend("NZQ_SITUAC == '1'", "GREEN", JurInfBox('NZQ_SITUAC', '1')) // "Pendente"
	oBrowse:AddLegend("NZQ_SITUAC == '2'", "BLUE" , JurInfBox('NZQ_SITUAC', '2')) // "Aprovada"
	oBrowse:AddLegend("NZQ_SITUAC == '3'", "RED"  , JurInfBox('NZQ_SITUAC', '3')) // "Reprovada"

	JurSetLeg(oBrowse, "NZQ")
	JurSetBSize(oBrowse)
	J235AFilter(oBrowse, cLojaAuto) // Adiciona filtros padrões no browse

	If ExistBlock("JURA235A")
		cFiltro := ExecBlock("JURA235A", .F., .F., {Nil, "BROWSEFILTER", "JURA235A"})
		If !Empty(cFiltro) .And. ValType(cFiltro) == "C"
			oBrowse:SetFilterDefault(cFiltro)
		EndIf
	EndIf

	oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} J235AFilter
Adiciona filtros padrões no browse

@param  oBrowse, objeto, browse da rotina

@author Reginaldo Borges / Cristina Cintra
@since  08/08/2022
/*/
//-------------------------------------------------------------------
Static Function J235AFilter(oBrowse, cLojaAuto)
Local aFilNZQ1 := {}
Local aFilNZQ2 := {}
Local aFilNZQ3 := {}
Local aFilNZQ4 := {}
Local aFilNZQ5 := {}
Local aFilNZQ6 := {}
Local aFilNZQ7 := {}

	If cLojaAuto == "2"
		SAddFilPar("NZQ_CCLIEN", "==", "%NZQ_CCLIEN0%", @aFilNZQ1)
		SAddFilPar("NZQ_CLOJA", "==", "%NZQ_CLOJA0%", @aFilNZQ1)
		oBrowse:AddFilter(STR0098, 'NZQ_CCLIEN == "%NZQ_CCLIEN0%" .AND. NZQ_CLOJA == "%NZQ_CLOJA0%"', .F., .F., , .T., aFilNZQ1, STR0098) // "Cliente"
	Else
		SAddFilPar("NZQ_CCLIEN", "==", "%NZQ_CCLIEN0%", @aFilNZQ1)
		oBrowse:AddFilter(STR0098, 'NZQ_CCLIEN == "%NZQ_CCLIEN0%"', .F., .F., , .T., aFilNZQ1, STR0098) // "Cliente"
	EndIf

	SAddFilPar("NZQ_CCASO", "==", "%NZQ_CCASO0%", @aFilNZQ2)
	oBrowse:AddFilter(STR0100, 'NZQ_CCASO == "%NZQ_CCASO0%"', .F., .F., , .T., aFilNZQ2, STR0100) // "Caso"

	SAddFilPar("NZQ_CPART", "==", "%NZQ_CPART0%", @aFilNZQ3)
	oBrowse:AddFilter(STR0101, 'NZQ_CPART == "%NZQ_CPART0%"', .F., .F., , .T., aFilNZQ3, STR0101) // "Solicitante"

	SAddFilPar("NZQ_SITUAC", "==", "%NZQ_SITUAC0%", @aFilNZQ4)
	oBrowse:AddFilter(STR0102, 'NZQ_SITUAC == "%NZQ_SITUAC0%"', .F., .F., , .T., aFilNZQ4, STR0102) // "Situação"

	SAddFilPar("NZQ_DESPES", "==", "%NZQ_DESPES0%", @aFilNZQ5)
	oBrowse:AddFilter(STR0103, 'NZQ_DESPES == "%NZQ_DESPES0%"', .F., .F., , .T., aFilNZQ5, STR0103) // "Tipo"

	SAddFilPar("NZQ_DTINCL", ">=", "%NZQ_DTINCL0%", @aFilNZQ6)
	oBrowse:AddFilter(STR0104, 'NZQ_DTINCL >= "%NZQ_DTINCL0%"', .F., .F., , .T., aFilNZQ6, STR0104) // "Data Maior ou Igual a"

	SAddFilPar("NZQ_DTINCL", "<=", "%NZQ_DTINCL0%", @aFilNZQ7)
	oBrowse:AddFilter(STR0105, 'NZQ_DTINCL <= "%NZQ_DTINCL0%"', .F., .F., , .T., aFilNZQ7, STR0105) // "Data Menor ou Igual a"

Return Nil

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

@author bruno.ritter
@since 17/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}
Local aLote   := {}

aAdd( aRotina, { STR0001, "PesqBrw"          , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA235A" , 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA235A" , 0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA235A" , 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA235A" , 0, 5, 0, NIL } ) // "Excluir"
aAdd( aRotina, { STR0010, "J235APreApr()"    , 0, 8, 0, NIL } ) // "Aprovar"
aAdd( aRotina, { STR0033, "J235ARepro()"     , 0, 8, 0, NIL } ) // "Reprovar"
aAdd( aRotina, { STR0076, "J235ACancela()"   , 0, 8, 0, NIL } ) // "Cancelar aprovação/reprovação"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA235A" , 0, 8, 0, NIL } ) // "Imprimir"

If FindFunction("JURA235B")
	aAdd( aLote, { STR0083, "JURA235B()"     , 0, 8, 0, NIL } ) // "Aprovação"
EndIf

If FindFunction("JURA235C")
	aAdd( aLote, { STR0088, "JURA235C()"     , 0, 8, 0, NIL } ) // "Alteração"
EndIf

aAdd( aRotina, { STR0089, aLote              , 0, 0, 0, NIL } ) // "Operações em Lote"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Aprovação de Despesa

@author bruno.ritter
@since 17/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView     := Nil
Local oModel    := FWLoadModel( "JURA235A" )
Local oStruct   := FWFormStruct( 2, "NZQ" )
Local cLojaAuto := SuperGetMv( "MV_JLOJAUT", .F., "2", ) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
Local lUtProj   := SuperGetMv( "MV_JUTPROJ", .F., .F., ) // Indica se será utilizado Projeto/Finalidade nas rotinas do Financeiro (.T. = Sim; .F. = Não)
Local lContOrc  := SuperGetMv( "MV_JCONORC", .F., .F., ) // Indica se será utilizado Controle Orçamentário (.T. = Sim; .F. = Não)

oStruct:RemoveField( "NZQ_CPART" )
oStruct:RemoveField( "NZQ_CODPRO" )
oStruct:RemoveField( "NZQ_CODRES" )
oStruct:RemoveField( "NZQ_DTAPRV" )
oStruct:RemoveField( "NZQ_APROVA" )
oStruct:RemoveField( "NZQ_DTEMSO" )
oStruct:RemoveField( "NZQ_DTEMCA" )
oStruct:RemoveField( "NZQ_DTEMAP" )
oStruct:RemoveField( "NZQ_EMSOLI" )
oStruct:RemoveField( "NZQ_EMCANC" )
oStruct:RemoveField( "NZQ_EMAPRO" )
oStruct:RemoveField( "NZQ_FILLAN" )
oStruct:RemoveField( "NZQ_CLANC"  )
oStruct:RemoveField( "NZQ_CPAGTO" )
oStruct:RemoveField( "NZQ_ITDES"  )
oStruct:RemoveField( "NZQ_ITDPGT" )
If !lUtProj .And. !lContOrc .And. NZQ->(ColumnPos("NZQ_CPROJE")) > 0
	oStruct:RemoveField("NZQ_CPROJE")
	oStruct:RemoveField("NZQ_DPROJE")
	oStruct:RemoveField("NZQ_CITPRJ")
	oStruct:RemoveField("NZQ_DITPRJ")
EndIf

If NZQ->(FieldPos("NZQ_CODLD")) > 0
	oStruct:RemoveField('NZQ_CODLD')
EndIf

Iif(cLojaAuto == "1", oStruct:RemoveField( "NZQ_CLOJA" ), )

JurSetAgrp( 'NZQ',, oStruct )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA235A_VIEW", oStruct, "NZQMASTER"  )
oView:CreateHorizontalBox( "FORMFIELD", 100 )
oView:SetOwnerView( "JURA235A_VIEW", "FORMFIELD" )
oView:SetDescription( STR0007 ) //"Aprovação de Despesa"
oView:EnableControlBar( .T. )

If !IsBlind()
	oView:AddUserButton( STR0087, "CLIPS", { | oView | JURANEXDOC("NZQ", "NZQMASTER", "", "NZQ_COD",,,,,,,,,, .T.) } ) // "Anexos"
EndIf

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Aprovação de Despesa

@author bruno.ritter
@since 17/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel      := NIL
Local oStructNZQ  := FWFormStruct( 1, "NZQ" )
Local oCommit     := JA235ACOMMIT():New()
Local bBlockFalse := FwBuildFeature( STRUCT_FEATURE_WHEN, ".F." )
Local lUtProj     := SuperGetMv( "MV_JUTPROJ", .F., .F., ) // Indica se será utilizado Projeto/Finalidade nas rotinas do Financeiro (.T. = Sim; .F. = Não)
Local lContOrc    := SuperGetMv( "MV_JCONORC", .F., .F., ) // Indica se será utilizado Controle Orçamentário (.T. = Sim; .F. = Não)

oModel:= MPFormModel():New( "JURA235A", /*Pre-Validacao*/, { |oModel| J235ATOk(oModel) } /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:AddFields( "NZQMASTER", NIL, oStructNZQ, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:InstallEvent("JA235ACOMMIT", /*cOwner*/, oCommit)
oModel:SetDescription( STR0008 ) //"Modelo de Dados de Aprovação de Despesa"
oModel:GetModel( "NZQMASTER" ):SetDescription( STR0009 ) //"Dados de Aprovação de Despesa"

If !lUtProj .And. !lContOrc .And. NZQ->(ColumnPos("NZQ_CPROJE")) > 0
	oStructNZQ:SetProperty( 'NZQ_CPROJE', MODEL_FIELD_WHEN, bBlockFalse)
	oStructNZQ:SetProperty( 'NZQ_CITPRJ', MODEL_FIELD_WHEN, bBlockFalse)
EndIf

J235MAnexo(@oModel, "NZQMASTER", "NZQ", "NZQ_COD") // Grid de Anexos

JurSetRules( oModel, 'NZQMASTER',, 'NZQ' )
oModel:SetVldActivate( { |oModel| J235VldACT( oModel,, .T. ) } )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} J235APreApr
Validações antes de abrir a tela de Aprovação de Despesa

@param lAutomato  Indica se está sendo executada via teste
                  automatizado
@param lVldDesCli Indica se está realizando o teste considerando que
                  não existe uma natureza do tipo 5 - Desp de Cliente
                  (usado para testes automatizados)
@param lLote      Indica se é aprovação em lote
@param aLanc      Dados de lançamento para aprovação
@param aErroLote  Despesas que não foram aprovadas e mensagens da validação.

@return lRet      Indica se a tela de filtro deve ser fechada

@author Jorge Luis Branco Martins Junior
@since 19/10/17
@version 1.0
/*/
//-------------------------------------------------------------------
Function J235APreApr(lAutomato, lVldDesCli, lLote, aLanc, aErroLote)
Local lRet         := .T.
Local oModel       := Nil
Local aErro        := {}

Default lAutomato  := .F.
Default lVldDesCli := .F.
Default lLote      := .F.
Default aLanc      := {}
Default aErroLote  := {}

oModel := FWLoadModel("JURA235A")
oModel:SetOperation(MODEL_OPERATION_UPDATE)

If oModel:CanActivate()
	oModel:Activate()
Else
	lRet  := .F.
	aErro := oModel:GetErrorMessage()
	JurMsgErro(aErro[6],, aErro[7]) // Mensagem de erro vinda da função J235VldACT
EndIf

If lRet
	If lLote
		lRet := J235BVldMd(oModel, aLanc, @aErroLote, lAutomato, lVldDesCli)
	Else
		J235ATlApr(oModel, lAutomato, lVldDesCli)
	EndIf
EndIf

ASize(aErro, 0)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J235ATlApr
Tela de Aprovação de Despesa

@param oModel     Modelo de dados da Aprovação de Despesa
@param lAutomato  Indica se está sendo executada via teste
                  automatizado
@param lVldDesCli Indica se está realizando o teste considerando que
                  não existe uma natureza do tipo 5 - Desp de Cliente
                  (usado para testes automatizados)
@param cTestCase  Código do caso de teste
                  (usado para testes automatizados)


@param lLote      Indica se é aprovação em lote
@param aLanc      Dados de lançamento para aprovação
@param cFilEsc    Filial do escritório

@author Jorge Luis Branco Martins Junior
@since 28/04/17
@version 1.0
/*/
//-------------------------------------------------------------------
Function J235ATlApr(oModel, lAutomato, lVldDesCli, cTestCase, lLote, aLanc, cFilEsc)
Local oDlg         := Nil
Local oCmbTpLanc   := Nil
Local oGetNCtPag   := Nil
Local oChkDesd     := Nil
Local oGetEscrit   := Nil
Local oGetDesEscr  := Nil
Local oGetHistPad  := Nil
Local oGetDesHist  := Nil
Local oGetNatOri   := Nil
Local oGetDesNatOri:= Nil
Local oMainLine    := Nil
Local oTopLine     := Nil //Nova linha, pois se o comboBox for inserido na mesma line com outros compomentes, o campo de escritório fica inativo.
Local oLayer       := FWLayer():New()
Local lChkDesd     := .F.
Local aTpLanc      := {STR0014, STR0013} // Contas a pagar / Caixinha
Local cFilAtu      := cFilAnt
Local aRetAuto     := {}
Local bBtOk        := Nil
Local bBtCan       := Nil
Local cEscrit      := ""
Local cCtPag       := ""
Local cHisPad      := ""
Local cNatOri      := ""
Local aCposLGPD     := {}
Local aNoAccLGPD    := {}
Local aDisabLGPD    := {}

Default lAutomato  := .F.
Default lVldDesCli := .F.
Default cTestCase  := "JURA235ATestCase"
Default lLote      := .F.
Default aLanc      := {}

Private cFilNS7    := "" // Filial do escritório indicado na telinha de aprovação
Private cCmbTpLanc := "" //Private para ser possível acessar o conteúdo da váriavel no filtro da consulta padrão OHANZQ J235AF3OHA()

	If lAutomato
		If FindFunction("GetParAuto")
			aRetAuto   := GetParAuto(cTestCase)[1]
			Iif( Len(aRetAuto) >= 1 .And. !Empty(aRetAuto[1]), cCmbTpLanc := IIf(aRetAuto[1] == 1, STR0014, STR0013), ) //"Tipo do Lançamento"
			Iif( Len(aRetAuto) >= 2 .And. !Empty(aRetAuto[2]), cEscrit    := aRetAuto[2], ) //"Cód. Escritório"
			Iif( Len(aRetAuto) >= 3 .And. !Empty(aRetAuto[3]), cCtPag     := aRetAuto[3], ) //"Nº Contas a Pagar"
			Iif( Len(aRetAuto) >= 4 .And. !Empty(aRetAuto[4]), lChkDesd   := aRetAuto[4], ) //"Desdobramento Pós Pagto"
			Iif( Len(aRetAuto) >= 5 .And. !Empty(aRetAuto[5]), cHisPad    := aRetAuto[5], ) //"Histórico Padrão"
			Iif( Len(aRetAuto) >= 6 .And. !Empty(aRetAuto[6]), cNatOri    := aRetAuto[6], ) //"Cód. Natureza"
			J235AVldFlt(oModel, cCmbTpLanc, cEscrit, cCtPag, lChkDesd, cHisPad, cNatOri, lVldDesCli) //Botão ok
		EndIf
	Else

		If _lFwPDCanUse .And. FwPDCanUse(.T.)
			aCposLGPD := {"NZQ_DESCR", "OHD_DHISTP", "ED_DESCRIC"}

			aDisabLGPD := FwProtectedDataUtil():UsrNoAccessFieldsInList(aCposLGPD)
			AEval(aDisabLGPD, {|x| AAdd( aNoAccLGPD, x:CFIELD)})

		EndIf
		// Aprovação de Despesas
		Define MsDialog oDlg Title STR0011 FROM 176, 188 To 580, 635 Pixel //"Aprovação de Despesas"

		oLayer:init(oDlg, .F.) //Inicializa o FWLayer com a janela que ele pertencera e se sera exibido o botao de fechar
		oLayer:addLine("TopLine", 15, .F.) //Cria as colunas do Layer
		oLayer:addLine("MainLine", 85, .F.) //Cria as colunas do Layer
		oTopLine  := oLayer:getLinePanel("TopLine")
		oMainLine := oLayer:getLinePanel("MainLine")

		//"Tipo do Lançamento"
		@ 005, 005 Say STR0012 Size 085, 062 Pixel Of oTopLine //"Tipo do Lançamento"
		oCmbTpLanc := TComboBox():New(013, 005, {|u| IIf(PCount() > 0, cCmbTpLanc := u, cCmbTpLanc)},;
		                              aTpLanc, 060, 015, oTopLine,, {||/*Ação*/},,,, .T.,,,,,,,,, 'cCmbTpLanc')

		oCmbTpLanc:bChange := { || oGetHistPad:Clear(), oGetDesHist:Clear(),;
		                           IIf( cCmbTpLanc == STR0013, ( oGetNatOri:Enable()    ,;
		                                                         lChkDesd := .F.        ,;
																 oChkDesd:Disable()     ,;
																 oGetNCtPag:Clear()     ,;
																 oGetNCtPag:Disable() ) ,;
											  /*Else*/         ( oGetNatOri:Clear()     ,;
											                     oGetDesNatOri:Clear()  ,;
											                     oGetNatOri:Disable()   ,;
																 oChkDesd:Enable()      ,;
		                                                         oGetNCtPag:Enable() ) ) }

		// "Escritório"
		oGetEscrit  := TJurPnlCampo():New(005, 005, 060, 024, oMainLine, STR0035, ("NZQ_CESCR"), {|| }, {|| },,,, 'NS7NZQ') //"Cód. Escritório"
		oGetEscrit:SetValid( { || J235ASetChg(oGetEscrit, oGetDesEscr, "NS7", @cFilAtu) } )

		oGetDesEscr  := TJurPnlCampo():New(005, 070, 153, 024, oMainLine, AllTrim(RetTitle("NZQ_DESCR")), ("NZQ_DESCR"), {|| }, {|| },,, .F.,,,,,,aScan(aNoAccLGPD,"NZQ_DESCR") > 0)

		// "Contas a Pagar"
		oGetNCtPag  := TJurPnlCampo():New(035, 005, 120, 024, oMainLine, STR0019, ("NZQ_DESCR"), {|| }, {|| },,, .T., 'SE2PFS') //"Nº Contas a Pagar"
		oGetNCtPag:SetValid( { || J235ASetChg(oGetNCtPag, , "SE2") } )

		// "Desdobramento Pós Pagto"
		@ 046, 131 CheckBox oChkDesd Var lChkDesd Prompt STR0020 Size 080, 012 Pixel Of oMainLine // "Desdobramento Pós Pagto"

		// "Histórico Padrão"
		oGetHistPad  := TJurPnlCampo():New(065, 005, 060, 024, oMainLine, STR0023, ("OHD_CHISTP"), {|| }, {|| },,,, 'OHANZQ') //"Histórico Padrão"
		oGetHistPad:SetValid( { || J235ASetChg(oGetHistPad, oGetDesHist, "OHA") } )

		oGetDesHist  := TJurPnlCampo():New(065, 070, 153, 024, oMainLine, STR0036,("OHD_DHISTP"), {|| }, {|| },,, .F.,,,,,,aScan(aNoAccLGPD,"OHD_DHISTP") > 0) //"Resumo do Histórico Padrão"

		// "Natureza origem do Lanc. Caixinha, se for diferente da conta corrente do profissional"
		@ 155, 005 To 195, 220 Label STR0024 Pixel Of oDlg //Está no oDlg, pois se for inserido no Layer, o campo de natureza fica inativo.

		oGetNatOri  := TJurPnlCampo():New(106, 009, 60, 024, oMainLine, STR0037, ("ED_CODIGO"), {|| }, {|| },,,, 'SEDOHB') //"Cód. Natureza"
		oGetNatOri:SetWhen( {|| cCmbTpLanc == STR0013 } ) // "Caixinha"
		oGetNatOri:SetValid( { || J235ASetChg(oGetNatOri, oGetDesNatOri, "SED") } )

		oGetDesNatOri  := TJurPnlCampo():New(106, 070, 148, 024, oMainLine, AllTrim(RetTitle("ED_DESCRIC")), ("ED_DESCRIC"), {|| }, {|| },,, .F.,,,,,,aScan(aNoAccLGPD,"ED_DESCRIC") > 0)

		If lLote
			bBtOk   := {|| aLanc := J235BTlVld(cCmbTpLanc, oGetEscrit:Valor, oGetNCtPag:Valor, lChkDesd, oGetHistPad:Valor, oGetNatOri:Valor), IIF(aLanc[1], (cFilEsc := cFilAnt, oDlg:End()), )}
			bBtCan  := {|| aLanc := {.F.}, oDlg:End()}
		Else
			bBtOk  := {|| IIf(J235AVldFlt(oModel, cCmbTpLanc, oGetEscrit:Valor, oGetNCtPag:Valor, lChkDesd, oGetHistPad:Valor, oGetNatOri:Valor), oDlg:End(), )}
			bBtCan := {|| oDlg:End()}
		EndIf

		ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar;
					(oDlg,;
					bBtOk,;
					bBtCan,; //"Sair"
					, /*aButtons*/,/*nRecno*/,/*cAlias*/, .F., .F.,.F.,.T.,.F. )
	EndIf

cFilAnt := cFilAtu

Return

//-------------------------------------------------------------------
/*/ { Protheus.doc } JA235ACOMMIT
Classe interna implementando o FWModelEvent, para execução de função
durante o commit.

@author bruno.ritter
@since 17/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Class JA235ACOMMIT FROM FWModelEvent
	Method New()
	Method FieldPreVld()
	Method ModelPosVld()
	Method InTTS()
End Class

Method New() Class JA235ACOMMIT
Return Nil

//-------------------------------------------------------------------
/*/ { Protheus.doc } FieldPreVld
Método que é chamado pelo MVC quando ocorrer as ações de pre validação 
do Model. Esse evento ocorre uma vez no contexto do modelo principal.

@param oModel  , Objeto   , Modelo principal
@param cModelId, Caractere, Id do submodelo
@param cAction , Caractere, Ação que foi executada no modelo (DELETE, SETVALUE)
@param cId     , Caractere, Campo que está sendo pré validado
@param xValue  , Aleatório, Novo valor para o campo

@author Abner Fogaça / Jonatas Martins
@since  26/06/2019
@Obs    Executa a função de validação ativação nesse momento somente quando for REST
        para verificar se o cabeçalho "NZQMASTER" poderá ser editável
        e sempre permitir a alteração do GRID de anexos
/*/
//-------------------------------------------------------------------
Method FieldPreVld(oModel, cModelId, cAction, cId, xValue) Class JA235ACOMMIT
	Local lMPreVld := .T.
	Local lIsRest  := FindFunction("JurIsRest") .And. JurIsRest()
 
	If lIsRest .And. cAction == "SETVALUE"
		lMPreVld := J235VldACT(oModel,, .T.)
	EndIf

Return (lMPreVld)

//-------------------------------------------------------------------
/*/ { Protheus.doc } ModelPosVld
Método que é chamado pelo MVC quando ocorrer as ações de pos validação do Model

@param  oModel  , Objeto  , Modelo principal
@param  cModelId, Caracter, Id do submodelo
@return lMPosVld, Logico  , Se .T. as validações foram efetuadas com sucesso

@author Abner Fogaça / Jonatas Martins
@since  26/06/2019
@Obs    Executa a função de validação ativação nesse momento somente quando for REST
        para verificar se o cabeçalho "NZQMASTER" poderá ser editável
        e sempre permitir a alteração do GRID de anexos
/*/
//-------------------------------------------------------------------
Method ModelPosVld(oSubModel, cModelId) Class JA235ACOMMIT
	Local lIsRest  := FindFunction("JurIsRest") .And. JurIsRest()
	Local lMPosVld := .T.

	// Deve ser sempre a última função a ser executada
	If FindFunction("J235Anexo") .And. (lIsRest .Or. oSubModel:GetOperation() == MODEL_OPERATION_DELETE) // Desconsidera quando vier da aprovação
		J235Anexo(oSubModel:GetModel(), "NZQ", "NZQMASTER", "NZQ_COD")
	EndIf

Return (lMPosVld)

//-------------------------------------------------------------------
Method InTTS(oSubModel, cModelId) Class JA235ACOMMIT
	JFILASINC(oSubModel:GetModel(), "NZQ", "NZQMASTER", "NZQ_COD") // Fila de sincronização
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J235ATOk
Pós validação da NZQ para aprovação de despesa.

Centro de Custo Jurídico (cCCNatur || cCCNatDest)
1 - Escritório
2 - Centro de Custos
3 - Profissional
4 - Tabela de Rateio
5 - Despesa Cliente
6 - Transitória de Pagamentos

@author bruno.ritter
@since 17/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function J235ATOk(oModel)
	Local lRet := Jur235TOk(oModel, .T.)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J235AVlNat()
Função utilizada para validação no dicionário.
Verifica se a natureza é válida.

@Return lRet Se a natureza é válida.

@author bruno.ritter
@since  17/10/2017
@Obs    Função chamada no X3_VALID do campo NZQ_CTADES
/*/
//-------------------------------------------------------------------
Function J235AVlNat(cNatur)
	Local lRet       := .T.
	Local cCCNaturez := ""
	Local cTitle     := ""
	Local cBxTPosPag := ""

	Default cNatur   := FwFldGet("NZQ_CTADES")

	cCCNaturez := JurGetDados("SED", 1, xFilial("SED") + cNatur, "ED_CCJURI")

	lRet := JurValNat(/*cCampo*/, /*cValid*/, cNatur) // Valida se a natureza existe, se é analítica, não bloqueada, com a moeda preenchida

	If lRet .And. cCCNaturez $ "5|6|7|8" // 5 - Despesa de cliente; 6 - Trans. de Pagamento; 7 - Trans. Pós pagamento; 8 - Trans. Recebimento
		lRet       := .F.
		cTitle     := AllTrim(RetTitle('ED_CCJURI'))
		cBxTPosPag := cCCNaturez + " - " + JurInfBox("ED_CCJURI", cCCNaturez )
		JurMsgErro(I18n(STR0031, {cTitle, cBxTPosPag}); //"Não é possível utilizar uma natureza com o campo '#1' igual a '#2'."
		                ,, STR0032) //"Informe uma natureza válida"
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/ { Protheus.doc } J235ASetChg
Função para validar os campos e executar os gatilhos

@param oCod        Objeto que contém o código do registro
@param oDesc       Objeto que contém a descrição do registro
@param cTab        Tabela onde serão localizadas as informações
@param cFilAtu     Filial que o usuário estava ao entrar na tela

@author Jorge Martins
@since 17/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function J235ASetChg(oCod, oDesc, cTab, cFilAtu)
Local aRetDados  := {}
Local aErro      := {}
Local lRet       := .T.
Local lCaixinha  := (cCmbTpLanc == STR0013)
Local aRetNat    := {}
Local cCCNatOri  := ""
Local cListCusto := ""
Local cE2Num     := ""
Local lHisPad    := .F.

Default oDesc    := Nil
Default cFilAtu  := ""

Do Case
	Case cTab == "OHA" // Histórico Padrão
		
		lHisPad := SuperGetMv("MV_JHISPAD", .F., .F.) // Indica se o campo de Histórico Padrão é obrigatório (.T.) ou não (.F.)

		If !Empty(oCod:GetValue())
			aRetDados := JurGetDados("OHA", 1, xFilial("OHA") + oCod:GetValue(), {"OHA_RESUMO", "OHA_LANCAM", "OHA_CTAPAG"})
			If Len(aRetDados) == 3
				If lCaixinha
					lRet := aRetDados[2] == '1' // Lançamento (OHA_LANCAM) = SIM
				Else
					lRet := aRetDados[3] == '1' // Contas a Pagar (OHA_CTAPAG) = SIM
				EndIf
			Else
				lRet := .F.
			EndIf
			
			If !lRet
				aErro := {STR0038, STR0039} // "Histórico padrão inválido" "Informe um código válido para o histórico padrão."
			EndIf
		Else
			If lHisPad
				lRet  := .F.
				aErro := {STR0086, STR0039} // "É obrigatório o preenchimento do Histórico Padrão, conforme o parâmetro MV_JHISPAD." "Informe um código válido para o histórico padrão."
			EndIf
		EndIf

	Case cTab == "NS7" // Escritório
		aRetDados :=  JurGetDados("NS7", 1, xFilial("NS7") + oCod:GetValue(), {"NS7_NOME", "NS7_ATIVO", "NS7_CEMP", "NS7_CFILIA"})

		If !Empty(oCod:GetValue())
			If lRet := Len(aRetDados) == 4 .And. aRetDados[2] == '1' /*NS7_ATIVO*/ .And. aRetDados[3] == cEmpAnt /*NS7_CEMP*/
				cFilAnt :=  aRetDados[4] // Preenche a variável de FILIAL do sistema com a Filial da NS7 com o conteúdo do campo NS7_CFILIA
			EndIf
		Else
			cFilAnt := cFilAtu //Volta a filial que o usuário estava ao entrar na tela
		EndIf

		If !lRet
			aErro := {STR0040, STR0041} // "Escritório inválido" "Informe um código válido para o escritório."
		EndIf

	Case cTab == "SED" // Natureza
		aRetNat := JurGetDados("SED", 1, xFilial("SED") + oCod:GetValue(), {"ED_DESCRIC", "ED_CCJURI"})

		If Len(aRetNat) == 2
			aAdd(aRetDados, aRetNat[1] )
			cCCNatOri := aRetNat[2]
		Else
			aAdd(aRetDados, "" )
			cCCNatOri := ""
		EndIf

		lRet :=  Empty(oCod:GetValue()) .Or. (J235AVlNat(oCod:GetValue())) // Validação de Naturezas

		If lRet .And. !Empty(oCod:GetValue()) .And. cCCNatOri $ "4|5|6"
			lRet       := .F.
			cListCusto := CRLF +  STR0081 // "Sem definição."
			cListCusto += CRLF + JurInfBox("ED_CCJURI", '1', "3") + "."
			cListCusto += CRLF + JurInfBox("ED_CCJURI", '2', "3") + "."
			cListCusto += CRLF + JurInfBox("ED_CCJURI", '3', "3") + "."
			aErro      := {STR0074, STR0075 + cListCusto} // "Centro de custo jurídico inválido na natureza de origem" "Só é possível utilizar natureza de origem com os seguentes centros de custos jurídico:"
		EndIf

	Case cTab == "SE2" // Contas a Pagar
		cE2Num :=  JurGetDados("SE2", 1, Trim(STRTRAN(oCod:GetValue(), "|", "")), "E2_NUM")

		If !Empty(oCod:GetValue()) // oCod:GetValue() -> SE2->E2_FILIAL+'|'+SE2->E2_PREFIXO+'|'+SE2->E2_NUM+'|'+SE2->E2_PARCELA+'|'+SE2->E2_TIPO+'|'+SE2->E2_FORNECE+'|'+SE2->E2_LOJA
			If Empty(cE2Num)
				lRet := .F.
			EndIf
		EndIf

		If !lRet
			aErro := {STR0042, STR0043} // "Contas a pagar inválido" "Informe uma chave válida para o contas a pagar."
		EndIf
EndCase

If lRet
	If cTab <> "SE2" // Campo de Nº Contas a Pagar não tem descrição
		If Len(aRetDados) == 0
			oDesc:SetValue("")
		Else
			oDesc:SetValue(aRetDados[1])
		EndIf
	EndIf
ElseIf Len(aErro) > 0
	JurMsgErro(aErro[1],, aErro[2])
EndIf

Return lRet

//-------------------------------------------------------------------
/*/ { Protheus.doc } J235AF3SE2
Função filtro da consulta de Contas a Pagar - SE2PFS

Caso o campo de escritório esteja preenchido serão exibidos
os títulos referente a filial desse escritório. Caso contrário,
serão exibidos os títulos da filial corrente.

@author Jorge Martins
@since 18/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function J235AF3SE2()
Local cRet := "@# "

cRet += " SE2->E2_FILIAL == '" + xFilial("SE2") + "'"

cRet += "@#"

Return cRet

//-------------------------------------------------------------------
/*/ { Protheus.doc } J235AF3NS7
Função filtro da consulta de Escritório - NS7NZQ

Serão exibidos os escritórios em que a filial pertença ao grupo de
empresas escolhido no acesso ao sistema.

@author Jorge Martins
@since 18/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function J235AF3NS7()
Local cRet := "@# "

cRet += " NS7->NS7_CEMP == '" + cEmpAnt + "' .AND."
cRet += " NS7->NS7_ATIVO == '1'"

cRet += "@#"

Return cRet

//-------------------------------------------------------------------
/*/ { Protheus.doc } J235AF3OHA
Função filtro da consulta de Histórico Padrão - OHANZQ

Tipo de lançamento = Caixinha
                     - Filtra os históricos onde o campo
					 lançamento = SIM

Tipo de lançamento = Contas a Pagar
                     - Filtra os históricos onde o campo
					 contas a pagar = SIM

@author Jorge Martins
@since 18/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function J235AF3OHA()
Local cRet      := "@# "
Local lCaixinha := cCmbTpLanc == STR0013 // "Caixinha"

If lCaixinha
	cRet += " OHA->OHA_LANCAM == '1'"
Else // Contas a Pagar
	cRet += " OHA->OHA_CTAPAG == '1'"
EndIf

cRet += "@#"

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J235AVldFlt
Validação do Filtro de Aprovação

@param oModel       Modelo de dados da Aprovação de Despesa
@param cTpLanc      Tipo de Lançamento - Caixinha / Contas a Pagar
@param cEscrit      Código do Escritório
@param cCtPag       Chave do registro de Contas a Pagar
@param lDesdPos     Indica se é desdobramento pós pagamento
@param cHisPad      Histórico Padrão
@param cNaturOri    Natureza de origem
@param lVldDesCli   Indica se está realizando o teste considerando que
                    não existe uma natureza do tipo 5 - Desp de Cliente
                    (usado para testes automatizados)

@return lFecha      Indica se a tela de filtro deve ser fechada

@author Jorge Martins
@since 18/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J235AVldFlt(oModel, cTpLanc, cEscrit, cCtPag, lDesdPos, cHisPad, cNaturOri, lVldDesCli)
Local lFecha    := .F.
Local lRet      := .T.
Local lCaixinha := (cTpLanc == STR0013)
Local cMsg      := IIf(lCaixinha, STR0046, STR0047) //"Gerando Lançamento" "Gerando Desdobramento"
Local cMoedaTit := ""
Local aSE2Info  := {}
Local lTemBaixa := .F.
Local cMoedaNat := ""
Local cNaturDes := ""
Local cTitCpo   := ""
Local cValCpo   := ""
Local cCCNatOri := ""
Local oModelNZQ := oModel:GetModel("NZQMASTER")
Local aRetSed   := {}
Local cCusto    := ""
Local cEscrPart := ""
Local cPartSolc := ""

// Valida preenchimento do histórico padrão - Telinha de Aprovação
If Empty(cHisPad) .And. SuperGetMv("MV_JHISPAD", .F., .F.) // Indica se o campo de Histórico Padrão é obrigatório (.T.) ou não (.F.)
	lRet := .F.
	JurMsgErro(I18N(STR0044, {STR0023}), , STR0082) // "É necessário preencher o campo '#1'." ##"Preencha o campo solicitado"
EndIf

// Validações em comum entre Caixinha e Contas a pagar
If lRet

	// Valida se a natureza da solicitação de despesa é válida
	If oModelNZQ:GetValue("NZQ_DESPES") == "1" // 1=Cliente
		cNaturDes := JurBusNat("5") // Natureza

		If Empty(cNaturDes) .Or. lVldDesCli // Não existe natureza de Despesa de cliente ou é um teste negativo (automatização)
			lRet := .F.
			cTitCpo := AllTrim(RetTitle('ED_CCJURI'))
			cValCpo := JurInfBox("ED_CCJURI", '5' )
			JurMsgErro(I18n(STR0057, {cTitCpo, cValCpo}),, STR0058) // "Não foi encontrada uma natureza onde o campo '#1' é igual a '#2'." - "Inclua uma natureza com esse centro de custo jurídico."
		EndIf
	Else // 2=Escritório
		cNaturDes := oModelNZQ:GetValue("NZQ_CTADES")

		If Empty(cNaturDes)
			lRet := .F.
			cTitCpo := AllTrim(RetTitle('NZQ_CTADES'))
			JurMsgErro(STR0059,, I18n(STR0060, {cTitCpo})) // "Não foi encontrada uma natureza na solicitação." - "Preencha o campo '#1' na solicitação."
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
				JurMsgErro(STR0061,, I18n(STR0062, {STR0037})) // "Não foi encontrada uma natureza vinculada ao solicitante." - "Preencha o campo '#1' na 'Aprovação de despesa' ou vincule uma natureza ao solicitante." - "Cód. Natureza"
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
				JurMsgErro(STR0063,, STR0064) // "A moeda indicada na solicitação de despesa está diferente da moeda da natureza origem." - "Ajuste a moeda da solicitação de despesa ou indique uma outra natureza origem."
			EndIf
		EndIf

		If lRet
			If cCCNatOri $ "1|2" //Escritório|Centro de Custo|Vazio(não definido)
				cEscrPart := JurGetDados("NUR", 1, xFilial("NUR") + cPartSolc, "NUR_CESCR")
				If Empty(cEscrPart)
					lRet := .F.
					JurMsgErro(i18n(STR0070, {cNaturOri}); // "A natureza de origem selecionada '#1' requer o preenchimento do escritório."
							,, i18n(STR0071, {oModelNZQ:GetValue("NZQ_SIGLA")})) // "Indique um escritório no participante sigla '#1' ou indique uma outra natureza origem."
				EndIf

				If lRet .And. cCCNatOri == "2" //Centro de Custo|Vazio(não definido)
					cCusto    := JurGetDados("RD0", 1, xFilial("RD0") + cPartSolc, "RD0_CC")
					If Empty(cCusto)
						lRet := .F.
						JurMsgErro(i18n(STR0072, {cNaturOri}); // "A natureza de origem selecionada '#1' requer o preenchimento do centro de custo."
								,, i18n(STR0073, {oModelNZQ:GetValue("NZQ_SIGLA")})) // "Indique um centro de custo no participante sigla '#1' ou indique uma outra natureza origem."
					EndIf
				EndIf
			EndIf
		EndIf

	Else // Tipo de lançamento - Contas a Pagar

		// Valida preenchimento do Nº do contas a pagar - Telinha de Aprovação
		If Empty(cCtPag)
			lRet := .F.
			JurMsgErro(I18N(STR0045, {STR0014, STR0019}), , STR0082) // "Para o tipo de lançamento '#1' é necessário preencher o campo '#2'." ##"Preencha o campo solicitado"
		EndIf

		// Valida se moeda da solicitação é a mesma do título (Contas a Pagar)
		If lRet
			aSE2Info  := JurGetDados("SE2", 1, Trim(STRTRAN(cCtPag, "|", "")), {"E2_MOEDA", "E2_VALOR", "E2_SALDO", "E2_TIPO"})

			If Empty(aSE2Info)
				lRet := .F.
				JurMsgErro(STR0042, , STR0043) // "Contas a pagar inválido" "Informe uma chave válida para o contas a pagar."

			Else
				cMoedaTit := aSE2Info[1]
				lTemBaixa := aSE2Info[2] != aSE2Info[3]
				lRet      := JVldTipoCp(aSE2Info[4], .T.) // Verifica o tipo da SE2
				cMoedaTit := PADL(cMoedaTit, TamSx3('CTO_MOEDA')[1],'0')

				If lRet .And. cMoedaTit <> oModelNZQ:GetValue("NZQ_CMOEDA")
					lRet := .F.
					JurMsgErro(STR0065,, STR0066) // "A moeda indicada na solicitação de despesa está diferente da moeda do título a pagar." - "Ajuste a moeda da solicitação de despesa."
				EndIf

				If lRet .And. !lDesdPos .And. lTemBaixa
					lRet := .F.
					JurMsgErro(STR0042, , STR0090) // "Contas a pagar inválido" "Informe um título que não possua baixas."
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

If !IsBlind() // Se não for execução automática
	If lRet .And. !(ApMsgYesNo(STR0056)) // "Deseja realmente aprovar esta solicitação?"
		lRet := .F.
	EndIf
EndIf

If lRet
	// Confirma a Aprovação e gera o lançamento/desdobramento
	Processa( {|| lFecha := J235AConf(oModel, lCaixinha, cEscrit, cCtPag, lDesdPos, cHisPad, cNaturOri, cNaturDes) }, STR0048, cMsg, .F. ) // "Aguarde" - "Processando..."
EndIf

Return lFecha

//-------------------------------------------------------------------
/*/{Protheus.doc} J235AConf
Ação do botão Confirmar - Geração dos lançamentos/desdobramentos

@param oModel       Modelo de dados da Aprovação de Despesa
@param lCaixinha    Tipo de Lançamento -> .T. Caixinha / .F. Contas a Pagar
@param cEscrit      Código do Escritório
@param cCtPag       Chave do registro de Contas a Pagar
@param lDesdPos     Indica se é desdobramento pós pagamento
@param cHisPad      Histórico Padrão
@param cNaturOri    Natureza Origem para criação do lançamento
                    (Usado quando Tipo de lançamento é CAIXINHA)
@param cNaturDes    Natureza Destino para criação do lançamento / desdobramento
@param lLote        Indica se é aprovação em lote
@param aErroLote    Despesas que não foram aprovadas e mensagens da validação

@return lRet        Indica se a geração dos lançamentos/desdobramentos
                    foi concluída com sucesso

@author Jorge Martins
@since 19/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function J235AConf(oModel, lCaixinha, cEscrit, cCtPag, lDesdPos, cHisPad, cNaturOri, cNaturDes, aErroLote, lLote)
	Local oModelLanc  := Nil
	Local cTab        := ""
	Local cLogNZQ     := ""
	Local lExibeErro  := .T.
	Local lRet        := .T.
	Local lCpoLog     := NZQ->(ColumnPos("NZQ_LOG")) > 0

	Default cCtPag    := ""
	Default aErroLote := {}
	Default lLote     := .F.

	If lLote
		lExibeErro := .F.
	EndIf

	ProcRegua( 0 )
	IncProc()

	If lCaixinha
		oModelLanc := J235ALanc(oModel, cEscrit, cHisPad, cNaturOri, cNaturDes, @aErroLote, lExibeErro)
	Else
		If !lDesdPos .And. lCpoLog // Somente para Desdobramentos (OHF)
			cLogNZQ := J235GrvLog(oModel:GetValue("NZQMASTER", "NZQ_LOG"), 1) // Aprovação de Despesa
		EndIf
		oModelLanc := J235ADsdb(oModel, cEscrit, cCtPag, lDesdPos, cHisPad, cNaturDes, @aErroLote, lExibeErro, cLogNZQ)
	EndIf

	IIf( oModelLanc == Nil, lRet := .F., lRet := .T. )

	If lRet

		Begin Transaction

			oModel:LoadValue("NZQMASTER", "NZQ_SITUAC", "2")
			oModel:LoadValue("NZQMASTER", "NZQ_DTAPRV", Date())
			If lCaixinha
				oModel:LoadValue("NZQMASTER", "NZQ_FILLAN", xFilial("OHB") )
				oModel:LoadValue("NZQMASTER", "NZQ_CLANC", oModelLanc:GetValue("OHBMASTER", "OHB_CODIGO") )
			Else
				cTab := Iif(lDesdPos, "OHG", "OHF")

				oModel:LoadValue("NZQMASTER", "NZQ_FILLAN", oModelLanc:GetValue(cTab + "DETAIL", cTab + "_FILIAL") )
				oModel:LoadValue("NZQMASTER", "NZQ_CPAGTO", cCtPag )

				If cTab == "OHF"
					oModel:LoadValue("NZQMASTER", "NZQ_ITDES", oModelLanc:GetValue(cTab + "DETAIL", cTab + "_CITEM") )
				Else
					oModel:LoadValue("NZQMASTER", "NZQ_ITDPGT", oModelLanc:GetValue(cTab + "DETAIL", cTab + "_CITEM") )
				EndIf
			EndIf
			If lCpoLog
				cLogNZQ := IIf(Empty(cLogNZQ), J235GrvLog(oModel:GetValue("NZQMASTER", "NZQ_LOG"), 1), cLogNZQ) // Aprovação de Despesa
				oModel:LoadValue("NZQMASTER", "NZQ_LOG", cLogNZQ)
			EndIf

			FwFormCommit(oModel)
			oModelLanc:CommitData()

		End Transaction

		Iif (IsBlind() .Or. lLote, , ApMsgInfo(STR0067)) // "Solicitação de Despesa aprovada!"

		FreeObj(oModelLanc)
	EndIf

	oModel:Activate() // Reativa modelo da JURA235A

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J235ADsdb()
Função utilizada no Confirmar da Aprovação para criar a estrutura de
dados a ser usada na geração dos Desdobramentos Financeiros ou Pós
Pagamento (OHF e OHG).

@Param  oModel      Modelo de Solictação de Despesas (NZQMASTER)
@Param  cEscrit     Código do Escritório digitado na Aprovação
@Param  cCtPag      Chave completa para seek do Contas a Pagar
@Param  lDesdPos    Indica se é Desdobramento Pós Pagamento
@Param  cHisPad     Código do Histórico Padrão usado na Aprovação
@Param  cNaturDes   Código da natureza para criação do desdobramento
@param  aErroLote   Array com despesas que tiveram falha no momento da aprovação em lote
@param  lExibeErro  Indica se as mensagens de erro devem ser exibidas quando houver falha na geração do modelo
@param  cLogNZQ     Log das movimentações realizadas na solicitação de despesa

@Return oModelLanc  Modelo do desdobramento para que seja realizado o commit

@author Cristina Cintra
@since 19/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J235ADsdb(oModel, cEscrit, cCtPag, lDesdPos, cHisPad, cNaturDes, aErroLote, lExibeErro, cLogNZQ)
Local oModelLanc := Nil
Local oModelNZQ  := Nil
Local cFonte     := Iif(lDesdPos, "JURA247", "JURA246")
Local cSubModel  := Iif(lDesdPos, "OHGDETAIL", "OHFDETAIL")
Local cTabLan    := Iif(lDesdPos, "OHG", "OHF")
Local cPrefixo   := Iif(lDesdPos, "OHG_", "OHF_")
Local cFilLan    := xFilial(cTabLan)
Local cChave     := StrTran(cCtPag, "|", "")
Local cCCNaturez := JurGetDados("SED", 1, xFilial("SED") + cNaturDes, "ED_CCJURI")
Local aSetValue  := {}
Local aSeek      := {}
Local aSetFields := {}
Local aErroModel := {}
Local cItem      := JurGetItem(cTabLan, xFilial(cTabLan), cPrefixo + "CITEM", FINGRVFK7("SE2", cCtPag) ) // Tabela e chave para busca do último código de item

oModelNZQ := oModel:GetModel("NZQMASTER")

// Array para busca do Contas a Pagar na SE2, no qual entrará o desdobramento
aAdd(aSeek, "SE2")
aAdd(aSeek, 1)
aAdd(aSeek, cChave)

// Array com os campos e os conteúdos a serem considerados no Desdobramento
aAdd(aSetValue, {cPrefixo + "FILIAL", cFilLan})
aAdd(aSetValue, {cPrefixo + "CNATUR", cNaturDes})
aAdd(aSetValue, {cPrefixo + "VALOR" , oModelNZQ:GetValue("NZQ_VALOR")})
aAdd(aSetValue, {cPrefixo + "SIGLA" , oModelNZQ:GetValue("NZQ_SIGLA")})

If cCCNaturez == "3" // Profissional
	aAdd(aSetValue, {cPrefixo + "SIGLA2", oModelNZQ:GetValue("NZQ_SIGPRO")})
ElseIf cCCNaturez $ "1|2" .Or. Empty(cCCNaturez) // Escritório|Centro de Custo|Vazio(não definido)
	aAdd(aSetValue, {cPrefixo + "CESCR" , oModelNZQ:GetValue("NZQ_CESCR")})
	If cCCNaturez == "2" .Or. Empty(cCCNaturez) // Centro de Custo|Vazio(não definido)
		aAdd(aSetValue, {cPrefixo + "CCUSTO", oModelNZQ:GetValue("NZQ_GRPJUR")})
	EndIf
ElseIf cCCNaturez == "5" // Despesa de Cliente
	aAdd(aSetValue, {cPrefixo + "CCLIEN", oModelNZQ:GetValue("NZQ_CCLIEN")})
	aAdd(aSetValue, {cPrefixo + "CLOJA" , oModelNZQ:GetValue("NZQ_CLOJA")})
	aAdd(aSetValue, {cPrefixo + "CCASO" , oModelNZQ:GetValue("NZQ_CCASO")})
	aAdd(aSetValue, {cPrefixo + "CTPDSP", oModelNZQ:GetValue("NZQ_CTPDSP")})
	aAdd(aSetValue, {cPrefixo + "QTDDSP", oModelNZQ:GetValue("NZQ_QTD")})
	aAdd(aSetValue, {cPrefixo + "DTDESP", oModelNZQ:GetValue("NZQ_DATA")})
	aAdd(aSetValue, {cPrefixo + "COBRA" , oModelNZQ:GetValue("NZQ_COBRAR")})
ElseIf cCCNaturez == "4" // Tabela de Rateio
	aAdd(aSetValue, {cPrefixo + "CRATEI", oModelNZQ:GetValue("NZQ_CRATEI")})
EndIf

aAdd(aSetValue, {cPrefixo + "CPROJE", oModelNZQ:GetValue("NZQ_CPROJE")})
aAdd(aSetValue, {cPrefixo + "CITPRJ", oModelNZQ:GetValue("NZQ_CITPRJ")})
aAdd(aSetValue, {cPrefixo + "CHISTP", cHisPad})
aAdd(aSetValue, {cPrefixo + "HISTOR", oModelNZQ:GetValue("NZQ_DESC")})

If OHF->(ColumnPos("OHF_NZQCOD")) > 0
	aAdd(aSetValue, {cPrefixo + "NZQCOD", oModelNZQ:GetValue("NZQ_COD")})
EndIf

If !lDesdPos .And. !Empty(cLogNZQ) .And. OHF->(ColumnPos("OHF_LOG")) > 0
	aAdd(aSetValue, {"OHF_LOG", cLogNZQ})
EndIf

aAdd(aSetFields, {cSubModel, {}, aSetValue, .T., cItem})

oModelLanc := JurGrModel(cFonte, 4, aSeek, aSetFields, @aErroModel, lExibeErro)

If !lExibeErro .And. !Empty(aErroModel)
	aAdd(aErroLote, {oModelNZQ:GetValue("NZQ_COD"), aErroModel[6], aErroModel[7]})
EndIf

Return oModelLanc

//-------------------------------------------------------------------
/*/{Protheus.doc} J235ALanc()
Função utilizada no Confirmar da Aprovação para criar a estrutura de
dados a ser usada na geração do Lançamento Financeiro (OHB).

@param oModel        Modelo da NZQ
@param cEscrit       Escritório prenchido na telinha de aprovação.
@param cHisPad       Cód Histórico padrão prenchido na telinha de aprovação.
@param cNaturOri     Natureza Origem para criação do lançamento
@param cNaturDes     Natureza Destino para criação do lançamento
@param aErroLote     Array com despesas que tiveram falha no momento da aprovação em lote
@param lExibeErro    Indica se as mensagens de erro devem ser exibidas quando houver falha na geração do modelo

@Return oModelLanc   Retorna o modelo da OHB preparado para o commit

@author bruno.ritter
@since 18/09/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J235ALanc(oModel, cEscrit, cHisPad, cNaturOri, cNaturDes, aErroLote, lExibeErro)
Local oModelLanc  := Nil
Local oModelNZQ   := oModel:GetModel("NZQMASTER")
Local cCCNatOri   := JurGetDados("SED", 1, xFilial("SED") + cNaturOri, "ED_CCJURI")
Local cCCNatDest  := JurGetDados("SED", 1, xFilial("SED") + cNaturDes, "ED_CCJURI")
Local aSetFields  := {}
Local aSetValue   := {}
Local aErroModel  := {}
Local cEscrPart   := ""
Local cCusto      := ""
Local cTpDesp     := oModel:GetValue("NZQMASTER", "NZQ_DESPES")

	//-------------------------------------------------------------//
	// Define a origem do lançamento
	//-------------------------------------------------------------//
	aAdd(aSetValue, {"OHB_ORIGEM", "6"}) //Solicitação de despesa

	//-------------------------------------------------------------//
	// Dados da natureza de origem
	//-------------------------------------------------------------//
	aAdd(aSetValue, {"OHB_NATORI", cNaturOri})
	Do Case
		Case cCCNatOri == "3" //Profissional
			aAdd(aSetValue, {"OHB_SIGLAO", oModelNZQ:GetValue("NZQ_SIGLA")})

		Case cCCNatOri $ "1|2" //Escritório|Centro de Custo
			cEscrPart := JurGetDados("NUR", 1, xFilial("NUR") + oModelNZQ:GetValue("NZQ_CPART"), "NUR_CESCR")
			aAdd(aSetValue, {"OHB_CESCRO", cEscrPart})

			If cCCNatOri == "2" //Centro de Custo
				cCusto := JurGetDados("RD0", 1, xFilial("RD0") + oModelNZQ:GetValue("NZQ_CPART"), "RD0_CC")
				aAdd(aSetValue, {"OHB_CCUSTO", cCusto})
			EndIf
	EndCase

	//-------------------------------------------------------------//
	// Dados da natureza de Destino
	//-------------------------------------------------------------//
	aAdd(aSetValue, {"OHB_NATDES", cNaturDes})
	Do Case
		Case cCCNatDest $ "1|2" //Escritório|Centro de Custo|
			aAdd(aSetValue, {"OHB_CESCRD", oModelNZQ:GetValue("NZQ_CESCR")})

			If cCCNatDest == "2"//Centro de Custo
				aAdd(aSetValue, {"OHB_CCUSTD", oModelNZQ:GetValue("NZQ_GRPJUR")})
			EndIf

		Case cCCNatDest == "3" //Profissional
			aAdd(aSetValue, {"OHB_SIGLAD", oModelNZQ:GetValue("NZQ_SIGPRO")})

		Case cCCNatDest == "4" //Tabela de rateio
			aAdd(aSetValue, {"OHB_CTRATD", oModelNZQ:GetValue("NZQ_CRATEI")})

		Case cCCNatDest == "5" //Despesa de Cliente
			aAdd(aSetValue, {"OHB_CCLID ", oModelNZQ:GetValue("NZQ_CCLIEN")})
			aAdd(aSetValue, {"OHB_CLOJD ", oModelNZQ:GetValue("NZQ_CLOJA ")})
			aAdd(aSetValue, {"OHB_CCASOD", oModelNZQ:GetValue("NZQ_CCASO ")})
			aAdd(aSetValue, {"OHB_CPART ", oModelNZQ:GetValue("NZQ_CPART ")})
			aAdd(aSetValue, {"OHB_CTPDPD", oModelNZQ:GetValue("NZQ_CTPDSP")})
			aAdd(aSetValue, {"OHB_QTDDSD", oModelNZQ:GetValue("NZQ_QTD   ")})
			aAdd(aSetValue, {"OHB_COBRAD", oModelNZQ:GetValue("NZQ_COBRAR")})
			aAdd(aSetValue, {"OHB_DTDESP", oModelNZQ:GetValue("NZQ_DATA  ")})

		Case Empty(cCCNatDest) .And. cTpDesp == "2" // Despesa de Escritório
			aAdd(aSetValue, {"OHB_CESCRD", oModelNZQ:GetValue("NZQ_CESCR")})
			aAdd(aSetValue, {"OHB_CCUSTD", oModelNZQ:GetValue("NZQ_GRPJUR")})

	EndCase

	//-------------------------------------------------------------//
	// Outros dados
	//-------------------------------------------------------------//
	aAdd(aSetValue, {"OHB_CPROJE", oModelNZQ:GetValue("NZQ_CPROJE")})
	aAdd(aSetValue, {"OHB_CITPRJ", oModelNZQ:GetValue("NZQ_CITPRJ")})
	aAdd(aSetValue, {"OHB_SIGLA ", oModelNZQ:GetValue("NZQ_SIGLA")})
	aAdd(aSetValue, {"OHB_DTLANC", Date()})
	aAdd(aSetValue, {"OHB_CMOELC", oModelNZQ:GetValue("NZQ_CMOEDA")})
	aAdd(aSetValue, {"OHB_VALOR ", oModelNZQ:GetValue("NZQ_VALOR")})
	aAdd(aSetValue, {"OHB_CHISTP", cHisPad})
	aAdd(aSetValue, {"OHB_HISTOR", oModelNZQ:GetValue("NZQ_DESC")})
	aAdd(aSetValue, {"OHB_FILORI", cFilAnt})

	//-------------------------------------------------------------//
	// Gerar Modelo do Lançamento
	//-------------------------------------------------------------//
	aAdd(aSetFields, {"OHBMASTER", {} /*aSeekLine*/, aSetValue})
	oModelLanc := JurGrModel("JURA241", MODEL_OPERATION_INSERT, {} /*aSeek*/, aSetFields, @aErroModel, lExibeErro)

	If !lExibeErro .And. !Empty(aErroModel)
		aAdd(aErroLote, {oModelNZQ:GetValue("NZQ_COD"), aErroModel[6], aErroModel[7]})
	EndIf

Return oModelLanc

//-------------------------------------------------------------------
/*/{Protheus.doc} J235ARepro()
Tela de reprovação de solicitação de despesa.

@author ricardo.neves
@since 18/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function J235ARepro(lAutomato, cTestCase)
Local lRet        := .T.
Local aErro       := {}
Local aArea       := GetArea()
Local aAreaNZQ    := NZQ->(GetArea())
Local oDlg        := Nil
Local oLayer      := FWLayer():new()
Local oMainColl   := Nil
Local oMmMotivo   := Nil
Local oModelNZQ   := Nil
Local oModel      := Nil
Local aRetAuto    := {}
Local cMotivo     := ""

Default lAutomato := .F.
Default cTestCase := "JURA235ATestCase"

	oModel := FWLoadModel('JURA235A')
	oModel:SetOperation(MODEL_OPERATION_UPDATE)
	If lRet := oModel:CanActivate()
		oModel:Activate()
	EndIf

	If lRet
		oModelNZQ := oModel:GetModel("NZQMASTER")

		If lAutomato .Or. MsgYesNo(STR0055) // "Deseja reprovar a Solicitação de Despesa?"

			If lAutomato
				If FindFunction("GetParAuto")
					aRetAuto := GetParAuto(cTestCase)[1]
					Iif( Len(aRetAuto) >= 1 .And. !Empty(aRetAuto[1]), cMotivo := aRetAuto[1], )//"Motivo de Reprovação"
					J235AGvRep(cMotivo, oModel) //Botão ok
				EndIf
			Else
				Define MsDialog oDlg Title STR0034 FROM 1, 1 To 220, 420 Pixel  // "Reprovação de Solicitação de Despesa"

				oLayer:init(oDlg, .F.) //Inicializa o FWLayer com a janela que ele pertencera e se sera exibido o botao de fechar
				oLayer:addCollumn("MainColl", 100, .F.) //Cria as colunas do Layer
				oMainColl := oLayer:GetColPanel("MainColl")

				oMmMotivo := TJurPnlCampo():New(010, 006, 200, 65, oMainColl, STR0049, ("NZQ_MOTREP"), {|| }, {|| },,,,) // "Motivo de Reprovação"

				ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar;
							(oDlg,;
							{|| Iif(J235AGvRep(oMmMotivo:Valor, oModel), (oDlg:End(), ApMsgInfo(STR0068)), Nil) },; //# "Solicitação de Despesa reprovada!"
							{|| oDlg:End() },; // "Sair"
							, /*aButtons*/,/*nRecno*/,/*cAlias*/, .F., .F., .F., .T., .F. )
			EndIf
		EndIf
	Else
		aErro := oModel:GetErrorMessage()
		JurMsgErro(aErro[6], , aErro[7])
	EndIf

RestArea(aAreaNZQ)
RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J235AGvRep(cMotivo, oModel)
Rotina para atualizar o campo de situação e motivo de reprovação ao reprovar a despesa

@Params  cMotivo - Memo com o motivo da reprovação
@Params  oModel  - Modelo

@author ricardo.neves
@since 19/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J235AGvRep(cMotivo, oModel)
Local lRet       := .T.
Local aErro      := {}
Local cLogNZQ    := ""
Local oModelNZQ  := oModel:GetModel("NZQMASTER")
Local cMotRepr   := oModelNZQ:GetValue('NZQ_MOTREP')

If Empty(cMotivo)
	JurMsgErro(STR0069, , STR0082) //"É necessário preencher o motivo de reprovação da solicitação de despesa." ##"Preencha o campo solicitado"
	lRet := .F.
Else
	IIF(lRet, lRet := oModelNZQ:SetValue('NZQ_MOTREP', Iif(!Empty(cMotRepr), cMotRepr + CRLF, '') + cMotivo), Nil)
	IIF(lRet, lRet := oModelNZQ:LoadValue('NZQ_SITUAC', '3'), Nil)
	If lRet .And. NZQ->(ColumnPos("NZQ_LOG")) > 0
		cLogNZQ := J235GrvLog(oModel:GetValue("NZQMASTER", "NZQ_LOG"), 2) // Reprovação de Despesa
		lRet    := oModel:LoadValue("NZQMASTER", "NZQ_LOG", cLogNZQ)
	EndIf

	lRet  := oModel:VldData()
	aErro := oModel:GetErrorMessage()

	IIf (lRet, lRet := oModel:CommitData(), JurMsgErro(aErro[6], , aErro[7]))

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J235AtuDesd()
Atualiza a aprovação de despesa conforme alteração no desdobramento ou desdobramento pós pagamento

@Param  oModel,    Submodelo de dados que está sofrendo alteração
@Param  nLine,     Número da linha quando do grid
@param  nOperacao, Operacao para a Despesa (4=UPDATE;5=DELETE)

@Return oModelNZQ, Modelo da aprovação de despesa que foi alterado,
                   retorna nil se houve um erro.

@author Abner Fogaça de Oliveira
@since 26/03/2019
/*/
//-------------------------------------------------------------------
Function J235AtuDesd(oSubModel, nLine, nOperacao)
	Local aSeek      := {}
	Local aSetValue  := {}
	Local aSetFields := {}
	Local cPrefixo   := ""
	Local cCodNZQ    := ""
	Local cDespCli   := ""
	Local cNaturez   := ""
	Local cCusto     := ""
	Local cProjeto   := ""
	Local cItemProj  := ""
	Local cCCNaturez := ""
	Local cLogNZQ    := ""
	Local oModelNZQ  := Nil

	If oSubModel:GetId() == 'OHFDETAIL'
		cCodNZQ  := oSubModel:GetValue("OHF_NZQCOD", nLine)
		cPrefixo := "OHF_"
	Else
		cCodNZQ  := oSubModel:GetValue("OHG_NZQCOD", nLine)
		cPrefixo := "OHG_"
	EndIf

	If !Empty(cCodNZQ) .And. nOperacao == MODEL_OPERATION_DELETE
		// Array para busca aprovação de despesa NZQ que será excluído
		aAdd(aSeek, "NZQ")
		aAdd(aSeek, 1)
		aAdd(aSeek, xFilial("NZQ") + cCodNZQ)

		aAdd(aSetValue, {"NZQ_MOTREP", STR0085}) // "Reprovação devido a exclusão do desdobramento."
		aAdd(aSetValue, {"NZQ_SITUAC", "3"})
		aAdd(aSetValue, {"NZQ_FILLAN", ""})
		aAdd(aSetValue, {"NZQ_CPAGTO", ""})
		aAdd(aSetValue, {"NZQ_ITDES" , ""})
		aAdd(aSetValue, {"NZQ_ITDPGT", ""})

		If NZQ->(ColumnPos("NZQ_LOG")) > 0
			cLogNZQ := J235GrvLog(JurGetDados("NZQ", 1, xFilial("NZQ") + cCodNZQ, "NZQ_LOG"), 2) // Reprovação de Despesa
			aAdd(aSetValue, {"NZQ_LOG", cLogNZQ})
		EndIf

		aAdd(aSetFields, {"NZQMASTER", {} /*aSeekLine*/, aSetValue})
		oModelNZQ := JurGrModel("JURA235A", MODEL_OPERATION_UPDATE, aSeek, aSetFields)

	ElseIf nOperacao == MODEL_OPERATION_UPDATE
		aAdd(aSeek, "NZQ")
		aAdd(aSeek, 1)
		aAdd(aSeek, xFilial("NZQ") + cCodNZQ)
		cDespCli   := JurGetDados("NZQ", 1, xFilial("NZQ") + cCodNZQ, "NZQ_DESPES")

		aAdd(aSetValue, {"NZQ_SIGLA", oSubModel:GetValue(cPrefixo + "SIGLA", nLine)})

		If cDespCli == "2" // Só altera a natureza quando a aprovação de despesas for de escritório
			cNaturez   := oSubModel:GetValue(cPrefixo + "CNATUR", nLine)
			cCCNaturez := JurGetDados("SED", 1, xFilial("SED") + cNaturez, "ED_CCJURI")
			
			aAdd(aSetValue, {"NZQ_CTADES", cNaturez})

			Do Case
				Case cCCNaturez == "3" // Profissional
					aAdd(aSetValue, {"NZQ_SIGPRO", oSubModel:GetValue(cPrefixo + "SIGLA2", nLine)})
				
				Case cCCNaturez $ "1|2" .Or. Empty(cCCNaturez)
					aAdd(aSetValue, {"NZQ_CESCR" , oSubModel:GetValue(cPrefixo + "CESCR" , nLine)})

					cCusto := oSubModel:GetValue(cPrefixo + "CCUSTO", nLine)
					If cCCNaturez == "2" .Or. (Empty(cCCNaturez) .And. !Empty(cCusto)) // Centro de Custo|Vazio(não definido)
						aAdd(aSetValue, {"NZQ_GRPJUR", cCusto})
					EndIf
				
				Case cCCNaturez == "4" // Tabela de Rateio
					aAdd(aSetValue, {"NZQ_CRATEI", oSubModel:GetValue(cPrefixo + "CRATEI", nLine)})

				EndCase
				
				cProjeto := oSubModel:GetValue(cPrefixo + "CPROJE", nLine)
				If !Empty(cProjeto)
					aAdd(aSetValue, {"NZQ_CPROJE", cProjeto})
				EndIf

				cItemProj := oSubModel:GetValue(cPrefixo + "CITPRJ", nLine)
				If !Empty(cProjeto)
					aAdd(aSetValue, {"NZQ_CITPRJ", cItemProj})
				EndIf
		Else
			aAdd(aSetValue, {"NZQ_CCLIEN", oSubModel:GetValue(cPrefixo + "CCLIEN", nLine)})
			aAdd(aSetValue, {"NZQ_CLOJA" , oSubModel:GetValue(cPrefixo + "CLOJA" , nLine)})
			aAdd(aSetValue, {"NZQ_CCASO" , oSubModel:GetValue(cPrefixo + "CCASO" , nLine)})
			aAdd(aSetValue, {"NZQ_CTPDSP", oSubModel:GetValue(cPrefixo + "CTPDSP", nLine)})
			aAdd(aSetValue, {"NZQ_QTD"   , oSubModel:GetValue(cPrefixo + "QTDDSP", nLine)})
			aAdd(aSetValue, {"NZQ_COBRAR", oSubModel:GetValue(cPrefixo + "COBRA" , nLine)})
			aAdd(aSetValue, {"NZQ_DATA"  , oSubModel:GetValue(cPrefixo + "DTDESP", nLine)})
		EndIf

		aAdd(aSetValue, {"NZQ_VALOR", oSubModel:GetValue(cPrefixo + "VALOR" , nLine)})
		aAdd(aSetValue, {"NZQ_DESC" , oSubModel:GetValue(cPrefixo + "HISTOR", nLine)})

		aAdd(aSetFields, {"NZQMASTER", {} /*aSeekLine*/, aSetValue})
		oModelNZQ := JurGrModel("JURA235A", MODEL_OPERATION_UPDATE, aSeek, aSetFields)
	EndIf

	JurFreeArr(@aSeek)
	JurFreeArr(@aSetValue)
	JurFreeArr(@aSetFields)

Return oModelNZQ

//-------------------------------------------------------------------
/*/{Protheus.doc} J235ACancela()
Cancela a operação realizada anteriormente (aprovação/reprovação)
e retorna a situação para pentente

@author Jorge Martins
@since 23/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function J235ACancela()
Local cMsgYesNo  := ""
Local cFonte     := ""
Local oModelLanc := Nil
Local aSeek      := {}
LOcal aSetFields := {}
Local lRet       := .T.
Local lAprovada  := NZQ->NZQ_SITUAC == "2"
Local lReprovada := NZQ->NZQ_SITUAC == "3"
Local cFilAtu    := cFilAnt
Local lCpoLog    := NZQ->(ColumnPos("NZQ_LOG")) > 0
Local nLogOper   := 0
Local cLogNZQ    := ""
Local cCodNZQ    := ""

If NZQ->NZQ_SITUAC == "1" // Pendente
	lRet := .F.
	JurMsgErro(STR0079,, STR0080) // "Não existe aprovação/reprovação para esta solicitação." "Verifique a situação da solicitação."

ElseIf lAprovada .Or. lReprovada
	cMsgYesNo := STR0077 // "Deseja realmente cancelar a aprovação/reprovação desta solicitação?"

EndIf

If lRet .And. (IsBlind() .Or. ApMsgYesNo(cMsgYesNo))
	If !Empty(NZQ->NZQ_CLANC) // Lançamento entre naturezas

		// Array para busca do Lançamento na OHB que será excluído
		aAdd(aSeek, "OHB")
		aAdd(aSeek, 1)
		aAdd(aSeek, NZQ->NZQ_FILLAN + NZQ->NZQ_CLANC)

		Iif(!Empty(NZQ->NZQ_FILLAN), cFilAnt := NZQ->NZQ_FILLAN, )
		oModelLanc := JurGrModel("JURA241", MODEL_OPERATION_DELETE, aSeek)
		cFilAnt := cFilAtu
	Else

		If !Empty(NZQ->NZQ_ITDES) // Desdobramento
			aAdd(aSetFields, {'OHFDETAIL', { {"OHF_CITEM", NZQ->NZQ_ITDES } }, {}, .F., "" } )
			cFonte := "JURA246"
		ElseIf !Empty(NZQ->NZQ_ITDPGT) // Desdobramento pós pagamento
			aAdd(aSetFields, {'OHGDETAIL', { {"OHG_CITEM", NZQ->NZQ_ITDPGT } }, {}, .F., "" } )
			cFonte := "JURA247"
		EndIf

		If !Empty(cFonte)

			// Array para busca do Desdobramento na OHF / Desdobramento pós pagamento na OHG que será excluído
			aAdd(aSeek, "SE2")
			aAdd(aSeek, 1)
			aAdd(aSeek, Trim(STRTRAN(NZQ->NZQ_CPAGTO, "|", "")))

			cFilAnt    := NZQ->NZQ_FILLAN
			oModelLanc := JurGrModel(cFonte, MODEL_OPERATION_UPDATE, aSeek, aSetFields)
			cFilAnt    := cFilAtu
		EndIf

	EndIf

	If lAprovada .And. oModelLanc == Nil
		lRet := .F.
	Else

		If lCpoLog
			nLogOper := IIf(lAprovada, 3, 4) 
			cLogNZQ  := J235GrvLog(NZQ->NZQ_LOG, nLogOper) // Cancelamento da Aprovação Financeira ou Cancelamento da Reprovação Financeira
		EndIf

		cCodNZQ := NZQ->NZQ_COD

		Begin Transaction

			RecLock("NZQ", .F.)
			NZQ->NZQ_MOTREP := ""
			NZQ->NZQ_SITUAC := "1"
			NZQ->NZQ_DTAPRV := CToD("")
			NZQ->NZQ_FILLAN := ""
			NZQ->NZQ_CLANC  := ""
			NZQ->NZQ_CPAGTO := ""
			NZQ->NZQ_ITDES  := ""
			NZQ->NZQ_ITDPGT := ""
			If lCpoLog
				NZQ->NZQ_LOG := cLogNZQ
			EndIf
			NZQ->(MsUnlock())
			NZQ->(DbCommit())

			J170GRAVA("JURA235A", xFilial("NZQ") + cCodNZQ, "4")

			If !Empty(oModelLanc)
				FwFormCommit(oModelLanc)
			EndIf

		End Transaction

		Iif(IsBlind(),, ApMsgInfo(STR0078)) // "Cancelamento concluído com sucesso."

	EndIf

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J235ANatWh
When dos campos da Solicitação de Despesas relacionados a natureza

@param  cCampo, caractere, Nome do campo que está executando a função

@return lWhen , logico   , Se .T. habilita a edição do campo

@author Jonatas Maritns
@since  25/09/2019
@Obs    Função utilizada no X3_WHEN dos campos
        NZQ_CTADES
        NZQ_CESCR 
        NZQ_GRPJUR
        NZQ_SIGPRO
        NZQ_CRATEI
        NZQ_CPROJE
/*/
//-------------------------------------------------------------------
Function J235ANatWh(cCampo)
	Local oModel    := FWModelActive()
	Local cTipoDesp := oModel:GetValue("NZQMASTER", "NZQ_DESPES")
	Local lAprDesp  := oModel:GetID() == "JURA235A"
	Local lWhen     := .F.

	Default cCampo  := ""

	If cTipoDesp == "2" // Despesa de escritório
		If lAprDesp // Aprovação de despesas JURA235A
			Do Case
				Case cCampo == "NZQ_CTADES" // Natureza
					lWhen := .T.

				Case cCampo == "NZQ_CESCR" // Escritório
					lWhen := JurWhNatCC("1", "NZQMASTER", "NZQ_CTADES", "NZQ_CESCR", "NZQ_GRPJUR", "NZQ_SIGPRO", "NZQ_CRATEI")
			
				Case  cCampo == "NZQ_GRPJUR" // Centro de Custo
					lWhen := JurWhNatCC("2", "NZQMASTER", "NZQ_CTADES", "NZQ_CESCR", "NZQ_GRPJUR", "NZQ_SIGPRO", "NZQ_CRATEI")
			
				Case cCampo == "NZQ_SIGPRO" // Sigla do Profissional
					lWhen := JurWhNatCC("3", "NZQMASTER", "NZQ_CTADES", "NZQ_CESCR", "NZQ_GRPJUR", "NZQ_SIGPRO", "NZQ_CRATEI")
			
				Case cCampo == "NZQ_CRATEI" // Tabela de Rateio
					lWhen := JurWhNatCC("4", "NZQMASTER", "NZQ_CTADES", "NZQ_CESCR", "NZQ_GRPJUR", "NZQ_SIGPRO", "NZQ_CRATEI")
				
				Case cCampo == "NZQ_CPROJE" // Projeto
					lWhen := .T.

			End Case
		Else // Solicitação de despesas JURA235
			lWhen := .T.
		EndIf
	EndIf

Return (lWhen)

//-------------------------------------------------------------------
/*/{Protheus.doc} J235AUpdNZQ
Verifica se o desdobramento tem como origem aprovação de despesas e atualiza a tabela NZQ.

@param oModel, Modelo ativo

@Return [1]lValid   , Se a função foi executada corretamente
		[2]aModelNZQ, Array com os modelos da aprovação de despesa que foram atualizados
                   para efeturar o commit na transação.

@author Abner Fogaça de Oliveira
@since 29/03/2019
/*/
//-------------------------------------------------------------------
Function J235AUpdNZQ(oModel)
	Local aModelNZQ  := {}
	Local oSubModel  := Nil
	Local nLine      := 1
	Local nUltimoMld := 0
	Local nQtdOHF    := 1
	Local nOperDesp  := 0
	Local cPrefixo   := ""
	Local cCodAprov  := ""
	Local lValid     := .T.

	If oModel:GetId() == "JURA246"
		oSubModel := oModel:GetModel("OHFDETAIL")
		cPrefixo  := "OHF_"
	Else
		oSubModel := oModel:GetModel("OHGDETAIL")
		cPrefixo  := "OHG_"
	EndIf

	nQtdOHF   := oSubModel:GetQTDLine()

	For nLine := 1 To nQtdOHF
		If oSubModel:IsDeleted(nLine)
			nOperDesp := MODEL_OPERATION_DELETE
		ElseIf oSubModel:IsUpdated(nLine)
			nOperDesp := MODEL_OPERATION_UPDATE
		EndIf
		cCodAprov := oSubModel:GetValue(cPrefixo + 'NZQCOD', nLine)
		If !Empty(cCodAprov) .And. (nOperDesp == MODEL_OPERATION_UPDATE .Or. nOperDesp == MODEL_OPERATION_DELETE)

			Aadd(aModelNZQ, J235AtuDesd(oSubModel, nLine, nOperDesp) )

			nUltimoMld := Len(aModelNZQ)
			If Empty(aModelNZQ[nUltimoMld])
				lValid := .F.
				JurFreeArr(@aModelNZQ)
				Exit
			EndIf

			nOperDesp := 0
		EndIf
	Next

Return {lValid, aModelNZQ}

//-------------------------------------------------------------------
/*/{Protheus.doc} J235GrvLog
Gera o Log de aprovação, reprovação, cancelamento de aprovação e 
cancelamento de reprovação da solicitação de despesas

@param cLogAtual , Log atual (para que seja complementado)
@param nTipoOper , Tipo da Operação
                   1 - Aprovação Financeira
                   2 - Reprovação Financeira
                   3 - Cancelamento da Aprovação Financeira
                   4 - Cancelamento da Reprovação Financeira

@return cLog     , Log de movimentação da solicitação de despesa

@author Jorge Martins
@since  20/10/2020
/*/
//-------------------------------------------------------------------
Static Function J235GrvLog(cLogAtual, nTipoOper)
	Local aPart     := JurGetDados("RD0", 1, xFilial("RD0") + JurUsuario(__cUserId), {"RD0_CODIGO", "RD0_SIGLA", "RD0_NOME"})
	Local cPart     := IIf(Len(aPart) == 3, AllTrim(aPart[1]) + " - " + AllTrim(aPart[2]) + " - " + AllTrim(aPart[3]), "")
	Local cDataHora := cValToChar(Date()) + " - " + Time()
	Local cLog      := ""
	Local cOper     := ""

	Do Case
		Case nTipoOper == 1
			cOper := STR0091 // "Aprovação Financeira"
		Case nTipoOper == 2
			cOper := STR0092 // "Reprovação Financeira"
		Case nTipoOper == 3
			cOper := STR0093 // "Cancelamento da Aprovação Financeira"
		Case nTipoOper == 4
			cOper := STR0094 // "Cancelamento da Reprovação Financeira"
	End Case

	cLog := STR0095 + cOper + CRLF     // "Operação: "
	cLog += STR0096 + cPart + CRLF     // "Participante: "
	cLog += STR0097 + cDataHora + CRLF // "Data e hora: "

	cLog += IIf(Empty(cLogAtual), "", CRLF + Replicate( "-", 100 ) + CRLF + CRLF + cLogAtual) // Inclui o Log atual da solicitação de despesa

Return cLog
