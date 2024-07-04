#INCLUDE "JURA235A.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"
Static _lFwPDCanUse := FindFunction("FwPDCanUse")

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA235A
Aprova��o de Despesa

@author bruno.ritter
@since 17/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA235A()
Local oBrowse   := Nil
Local cLojaAuto := SuperGetMv( "MV_JLOJAUT", .F., "2", ) // Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-N�o)
Local cFiltro   := ""

	oBrowse := FWMBrowse():New()
	oBrowse:SetDescription(STR0007) // "Aprova��o de Despesa"
	oBrowse:SetAlias("NZQ")
	oBrowse:SetLocate()
	Iif(cLojaAuto == "1", JurBrwRev(oBrowse, "NZQ", {"NZQ_CLOJA"}), )

	oBrowse:AddLegend("NZQ_SITUAC == '1'", "GREEN", JurInfBox('NZQ_SITUAC', '1')) // "Pendente"
	oBrowse:AddLegend("NZQ_SITUAC == '2'", "BLUE" , JurInfBox('NZQ_SITUAC', '2')) // "Aprovada"
	oBrowse:AddLegend("NZQ_SITUAC == '3'", "RED"  , JurInfBox('NZQ_SITUAC', '3')) // "Reprovada"

	JurSetLeg(oBrowse, "NZQ")
	JurSetBSize(oBrowse)
	J235AFilter(oBrowse, cLojaAuto) // Adiciona filtros padr�es no browse

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
Adiciona filtros padr�es no browse

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
	oBrowse:AddFilter(STR0102, 'NZQ_SITUAC == "%NZQ_SITUAC0%"', .F., .F., , .T., aFilNZQ4, STR0102) // "Situa��o"

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
[n,4] Tipo de Transa��o a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Altera��o sem inclus�o de registros
7 - C�pia
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
aAdd( aRotina, { STR0076, "J235ACancela()"   , 0, 8, 0, NIL } ) // "Cancelar aprova��o/reprova��o"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA235A" , 0, 8, 0, NIL } ) // "Imprimir"

If FindFunction("JURA235B")
	aAdd( aLote, { STR0083, "JURA235B()"     , 0, 8, 0, NIL } ) // "Aprova��o"
EndIf

If FindFunction("JURA235C")
	aAdd( aLote, { STR0088, "JURA235C()"     , 0, 8, 0, NIL } ) // "Altera��o"
EndIf

aAdd( aRotina, { STR0089, aLote              , 0, 0, 0, NIL } ) // "Opera��es em Lote"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Aprova��o de Despesa

@author bruno.ritter
@since 17/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView     := Nil
Local oModel    := FWLoadModel( "JURA235A" )
Local oStruct   := FWFormStruct( 2, "NZQ" )
Local cLojaAuto := SuperGetMv( "MV_JLOJAUT", .F., "2", ) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-N�o)
Local lUtProj   := SuperGetMv( "MV_JUTPROJ", .F., .F., ) // Indica se ser� utilizado Projeto/Finalidade nas rotinas do Financeiro (.T. = Sim; .F. = N�o)
Local lContOrc  := SuperGetMv( "MV_JCONORC", .F., .F., ) // Indica se ser� utilizado Controle Or�ament�rio (.T. = Sim; .F. = N�o)

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
oView:SetDescription( STR0007 ) //"Aprova��o de Despesa"
oView:EnableControlBar( .T. )

If !IsBlind()
	oView:AddUserButton( STR0087, "CLIPS", { | oView | JURANEXDOC("NZQ", "NZQMASTER", "", "NZQ_COD",,,,,,,,,, .T.) } ) // "Anexos"
EndIf

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Aprova��o de Despesa

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
Local lUtProj     := SuperGetMv( "MV_JUTPROJ", .F., .F., ) // Indica se ser� utilizado Projeto/Finalidade nas rotinas do Financeiro (.T. = Sim; .F. = N�o)
Local lContOrc    := SuperGetMv( "MV_JCONORC", .F., .F., ) // Indica se ser� utilizado Controle Or�ament�rio (.T. = Sim; .F. = N�o)

oModel:= MPFormModel():New( "JURA235A", /*Pre-Validacao*/, { |oModel| J235ATOk(oModel) } /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:AddFields( "NZQMASTER", NIL, oStructNZQ, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:InstallEvent("JA235ACOMMIT", /*cOwner*/, oCommit)
oModel:SetDescription( STR0008 ) //"Modelo de Dados de Aprova��o de Despesa"
oModel:GetModel( "NZQMASTER" ):SetDescription( STR0009 ) //"Dados de Aprova��o de Despesa"

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
Valida��es antes de abrir a tela de Aprova��o de Despesa

@param lAutomato  Indica se est� sendo executada via teste
                  automatizado
@param lVldDesCli Indica se est� realizando o teste considerando que
                  n�o existe uma natureza do tipo 5 - Desp de Cliente
                  (usado para testes automatizados)
@param lLote      Indica se � aprova��o em lote
@param aLanc      Dados de lan�amento para aprova��o
@param aErroLote  Despesas que n�o foram aprovadas e mensagens da valida��o.

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
	JurMsgErro(aErro[6],, aErro[7]) // Mensagem de erro vinda da fun��o J235VldACT
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
Tela de Aprova��o de Despesa

@param oModel     Modelo de dados da Aprova��o de Despesa
@param lAutomato  Indica se est� sendo executada via teste
                  automatizado
@param lVldDesCli Indica se est� realizando o teste considerando que
                  n�o existe uma natureza do tipo 5 - Desp de Cliente
                  (usado para testes automatizados)
@param cTestCase  C�digo do caso de teste
                  (usado para testes automatizados)


@param lLote      Indica se � aprova��o em lote
@param aLanc      Dados de lan�amento para aprova��o
@param cFilEsc    Filial do escrit�rio

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
Local oTopLine     := Nil //Nova linha, pois se o comboBox for inserido na mesma line com outros compomentes, o campo de escrit�rio fica inativo.
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

Private cFilNS7    := "" // Filial do escrit�rio indicado na telinha de aprova��o
Private cCmbTpLanc := "" //Private para ser poss�vel acessar o conte�do da v�riavel no filtro da consulta padr�o OHANZQ J235AF3OHA()

	If lAutomato
		If FindFunction("GetParAuto")
			aRetAuto   := GetParAuto(cTestCase)[1]
			Iif( Len(aRetAuto) >= 1 .And. !Empty(aRetAuto[1]), cCmbTpLanc := IIf(aRetAuto[1] == 1, STR0014, STR0013), ) //"Tipo do Lan�amento"
			Iif( Len(aRetAuto) >= 2 .And. !Empty(aRetAuto[2]), cEscrit    := aRetAuto[2], ) //"C�d. Escrit�rio"
			Iif( Len(aRetAuto) >= 3 .And. !Empty(aRetAuto[3]), cCtPag     := aRetAuto[3], ) //"N� Contas a Pagar"
			Iif( Len(aRetAuto) >= 4 .And. !Empty(aRetAuto[4]), lChkDesd   := aRetAuto[4], ) //"Desdobramento P�s Pagto"
			Iif( Len(aRetAuto) >= 5 .And. !Empty(aRetAuto[5]), cHisPad    := aRetAuto[5], ) //"Hist�rico Padr�o"
			Iif( Len(aRetAuto) >= 6 .And. !Empty(aRetAuto[6]), cNatOri    := aRetAuto[6], ) //"C�d. Natureza"
			J235AVldFlt(oModel, cCmbTpLanc, cEscrit, cCtPag, lChkDesd, cHisPad, cNatOri, lVldDesCli) //Bot�o ok
		EndIf
	Else

		If _lFwPDCanUse .And. FwPDCanUse(.T.)
			aCposLGPD := {"NZQ_DESCR", "OHD_DHISTP", "ED_DESCRIC"}

			aDisabLGPD := FwProtectedDataUtil():UsrNoAccessFieldsInList(aCposLGPD)
			AEval(aDisabLGPD, {|x| AAdd( aNoAccLGPD, x:CFIELD)})

		EndIf
		// Aprova��o de Despesas
		Define MsDialog oDlg Title STR0011 FROM 176, 188 To 580, 635 Pixel //"Aprova��o de Despesas"

		oLayer:init(oDlg, .F.) //Inicializa o FWLayer com a janela que ele pertencera e se sera exibido o botao de fechar
		oLayer:addLine("TopLine", 15, .F.) //Cria as colunas do Layer
		oLayer:addLine("MainLine", 85, .F.) //Cria as colunas do Layer
		oTopLine  := oLayer:getLinePanel("TopLine")
		oMainLine := oLayer:getLinePanel("MainLine")

		//"Tipo do Lan�amento"
		@ 005, 005 Say STR0012 Size 085, 062 Pixel Of oTopLine //"Tipo do Lan�amento"
		oCmbTpLanc := TComboBox():New(013, 005, {|u| IIf(PCount() > 0, cCmbTpLanc := u, cCmbTpLanc)},;
		                              aTpLanc, 060, 015, oTopLine,, {||/*A��o*/},,,, .T.,,,,,,,,, 'cCmbTpLanc')

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

		// "Escrit�rio"
		oGetEscrit  := TJurPnlCampo():New(005, 005, 060, 024, oMainLine, STR0035, ("NZQ_CESCR"), {|| }, {|| },,,, 'NS7NZQ') //"C�d. Escrit�rio"
		oGetEscrit:SetValid( { || J235ASetChg(oGetEscrit, oGetDesEscr, "NS7", @cFilAtu) } )

		oGetDesEscr  := TJurPnlCampo():New(005, 070, 153, 024, oMainLine, AllTrim(RetTitle("NZQ_DESCR")), ("NZQ_DESCR"), {|| }, {|| },,, .F.,,,,,,aScan(aNoAccLGPD,"NZQ_DESCR") > 0)

		// "Contas a Pagar"
		oGetNCtPag  := TJurPnlCampo():New(035, 005, 120, 024, oMainLine, STR0019, ("NZQ_DESCR"), {|| }, {|| },,, .T., 'SE2PFS') //"N� Contas a Pagar"
		oGetNCtPag:SetValid( { || J235ASetChg(oGetNCtPag, , "SE2") } )

		// "Desdobramento P�s Pagto"
		@ 046, 131 CheckBox oChkDesd Var lChkDesd Prompt STR0020 Size 080, 012 Pixel Of oMainLine // "Desdobramento P�s Pagto"

		// "Hist�rico Padr�o"
		oGetHistPad  := TJurPnlCampo():New(065, 005, 060, 024, oMainLine, STR0023, ("OHD_CHISTP"), {|| }, {|| },,,, 'OHANZQ') //"Hist�rico Padr�o"
		oGetHistPad:SetValid( { || J235ASetChg(oGetHistPad, oGetDesHist, "OHA") } )

		oGetDesHist  := TJurPnlCampo():New(065, 070, 153, 024, oMainLine, STR0036,("OHD_DHISTP"), {|| }, {|| },,, .F.,,,,,,aScan(aNoAccLGPD,"OHD_DHISTP") > 0) //"Resumo do Hist�rico Padr�o"

		// "Natureza origem do Lanc. Caixinha, se for diferente da conta corrente do profissional"
		@ 155, 005 To 195, 220 Label STR0024 Pixel Of oDlg //Est� no oDlg, pois se for inserido no Layer, o campo de natureza fica inativo.

		oGetNatOri  := TJurPnlCampo():New(106, 009, 60, 024, oMainLine, STR0037, ("ED_CODIGO"), {|| }, {|| },,,, 'SEDOHB') //"C�d. Natureza"
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
Classe interna implementando o FWModelEvent, para execu��o de fun��o
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
M�todo que � chamado pelo MVC quando ocorrer as a��es de pre valida��o 
do Model. Esse evento ocorre uma vez no contexto do modelo principal.

@param oModel  , Objeto   , Modelo principal
@param cModelId, Caractere, Id do submodelo
@param cAction , Caractere, A��o que foi executada no modelo (DELETE, SETVALUE)
@param cId     , Caractere, Campo que est� sendo pr� validado
@param xValue  , Aleat�rio, Novo valor para o campo

@author Abner Foga�a / Jonatas Martins
@since  26/06/2019
@Obs    Executa a fun��o de valida��o ativa��o nesse momento somente quando for REST
        para verificar se o cabe�alho "NZQMASTER" poder� ser edit�vel
        e sempre permitir a altera��o do GRID de anexos
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
M�todo que � chamado pelo MVC quando ocorrer as a��es de pos valida��o do Model

@param  oModel  , Objeto  , Modelo principal
@param  cModelId, Caracter, Id do submodelo
@return lMPosVld, Logico  , Se .T. as valida��es foram efetuadas com sucesso

@author Abner Foga�a / Jonatas Martins
@since  26/06/2019
@Obs    Executa a fun��o de valida��o ativa��o nesse momento somente quando for REST
        para verificar se o cabe�alho "NZQMASTER" poder� ser edit�vel
        e sempre permitir a altera��o do GRID de anexos
/*/
//-------------------------------------------------------------------
Method ModelPosVld(oSubModel, cModelId) Class JA235ACOMMIT
	Local lIsRest  := FindFunction("JurIsRest") .And. JurIsRest()
	Local lMPosVld := .T.

	// Deve ser sempre a �ltima fun��o a ser executada
	If FindFunction("J235Anexo") .And. (lIsRest .Or. oSubModel:GetOperation() == MODEL_OPERATION_DELETE) // Desconsidera quando vier da aprova��o
		J235Anexo(oSubModel:GetModel(), "NZQ", "NZQMASTER", "NZQ_COD")
	EndIf

Return (lMPosVld)

//-------------------------------------------------------------------
Method InTTS(oSubModel, cModelId) Class JA235ACOMMIT
	JFILASINC(oSubModel:GetModel(), "NZQ", "NZQMASTER", "NZQ_COD") // Fila de sincroniza��o
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J235ATOk
P�s valida��o da NZQ para aprova��o de despesa.

Centro de Custo Jur�dico (cCCNatur || cCCNatDest)
1 - Escrit�rio
2 - Centro de Custos
3 - Profissional
4 - Tabela de Rateio
5 - Despesa Cliente
6 - Transit�ria de Pagamentos

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
Fun��o utilizada para valida��o no dicion�rio.
Verifica se a natureza � v�lida.

@Return lRet Se a natureza � v�lida.

@author bruno.ritter
@since  17/10/2017
@Obs    Fun��o chamada no X3_VALID do campo NZQ_CTADES
/*/
//-------------------------------------------------------------------
Function J235AVlNat(cNatur)
	Local lRet       := .T.
	Local cCCNaturez := ""
	Local cTitle     := ""
	Local cBxTPosPag := ""

	Default cNatur   := FwFldGet("NZQ_CTADES")

	cCCNaturez := JurGetDados("SED", 1, xFilial("SED") + cNatur, "ED_CCJURI")

	lRet := JurValNat(/*cCampo*/, /*cValid*/, cNatur) // Valida se a natureza existe, se � anal�tica, n�o bloqueada, com a moeda preenchida

	If lRet .And. cCCNaturez $ "5|6|7|8" // 5 - Despesa de cliente; 6 - Trans. de Pagamento; 7 - Trans. P�s pagamento; 8 - Trans. Recebimento
		lRet       := .F.
		cTitle     := AllTrim(RetTitle('ED_CCJURI'))
		cBxTPosPag := cCCNaturez + " - " + JurInfBox("ED_CCJURI", cCCNaturez )
		JurMsgErro(I18n(STR0031, {cTitle, cBxTPosPag}); //"N�o � poss�vel utilizar uma natureza com o campo '#1' igual a '#2'."
		                ,, STR0032) //"Informe uma natureza v�lida"
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/ { Protheus.doc } J235ASetChg
Fun��o para validar os campos e executar os gatilhos

@param oCod        Objeto que cont�m o c�digo do registro
@param oDesc       Objeto que cont�m a descri��o do registro
@param cTab        Tabela onde ser�o localizadas as informa��es
@param cFilAtu     Filial que o usu�rio estava ao entrar na tela

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
	Case cTab == "OHA" // Hist�rico Padr�o
		
		lHisPad := SuperGetMv("MV_JHISPAD", .F., .F.) // Indica se o campo de Hist�rico Padr�o � obrigat�rio (.T.) ou n�o (.F.)

		If !Empty(oCod:GetValue())
			aRetDados := JurGetDados("OHA", 1, xFilial("OHA") + oCod:GetValue(), {"OHA_RESUMO", "OHA_LANCAM", "OHA_CTAPAG"})
			If Len(aRetDados) == 3
				If lCaixinha
					lRet := aRetDados[2] == '1' // Lan�amento (OHA_LANCAM) = SIM
				Else
					lRet := aRetDados[3] == '1' // Contas a Pagar (OHA_CTAPAG) = SIM
				EndIf
			Else
				lRet := .F.
			EndIf
			
			If !lRet
				aErro := {STR0038, STR0039} // "Hist�rico padr�o inv�lido" "Informe um c�digo v�lido para o hist�rico padr�o."
			EndIf
		Else
			If lHisPad
				lRet  := .F.
				aErro := {STR0086, STR0039} // "� obrigat�rio o preenchimento do Hist�rico Padr�o, conforme o par�metro MV_JHISPAD." "Informe um c�digo v�lido para o hist�rico padr�o."
			EndIf
		EndIf

	Case cTab == "NS7" // Escrit�rio
		aRetDados :=  JurGetDados("NS7", 1, xFilial("NS7") + oCod:GetValue(), {"NS7_NOME", "NS7_ATIVO", "NS7_CEMP", "NS7_CFILIA"})

		If !Empty(oCod:GetValue())
			If lRet := Len(aRetDados) == 4 .And. aRetDados[2] == '1' /*NS7_ATIVO*/ .And. aRetDados[3] == cEmpAnt /*NS7_CEMP*/
				cFilAnt :=  aRetDados[4] // Preenche a vari�vel de FILIAL do sistema com a Filial da NS7 com o conte�do do campo NS7_CFILIA
			EndIf
		Else
			cFilAnt := cFilAtu //Volta a filial que o usu�rio estava ao entrar na tela
		EndIf

		If !lRet
			aErro := {STR0040, STR0041} // "Escrit�rio inv�lido" "Informe um c�digo v�lido para o escrit�rio."
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

		lRet :=  Empty(oCod:GetValue()) .Or. (J235AVlNat(oCod:GetValue())) // Valida��o de Naturezas

		If lRet .And. !Empty(oCod:GetValue()) .And. cCCNatOri $ "4|5|6"
			lRet       := .F.
			cListCusto := CRLF +  STR0081 // "Sem defini��o."
			cListCusto += CRLF + JurInfBox("ED_CCJURI", '1', "3") + "."
			cListCusto += CRLF + JurInfBox("ED_CCJURI", '2', "3") + "."
			cListCusto += CRLF + JurInfBox("ED_CCJURI", '3', "3") + "."
			aErro      := {STR0074, STR0075 + cListCusto} // "Centro de custo jur�dico inv�lido na natureza de origem" "S� � poss�vel utilizar natureza de origem com os seguentes centros de custos jur�dico:"
		EndIf

	Case cTab == "SE2" // Contas a Pagar
		cE2Num :=  JurGetDados("SE2", 1, Trim(STRTRAN(oCod:GetValue(), "|", "")), "E2_NUM")

		If !Empty(oCod:GetValue()) // oCod:GetValue() -> SE2->E2_FILIAL+'|'+SE2->E2_PREFIXO+'|'+SE2->E2_NUM+'|'+SE2->E2_PARCELA+'|'+SE2->E2_TIPO+'|'+SE2->E2_FORNECE+'|'+SE2->E2_LOJA
			If Empty(cE2Num)
				lRet := .F.
			EndIf
		EndIf

		If !lRet
			aErro := {STR0042, STR0043} // "Contas a pagar inv�lido" "Informe uma chave v�lida para o contas a pagar."
		EndIf
EndCase

If lRet
	If cTab <> "SE2" // Campo de N� Contas a Pagar n�o tem descri��o
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
Fun��o filtro da consulta de Contas a Pagar - SE2PFS

Caso o campo de escrit�rio esteja preenchido ser�o exibidos
os t�tulos referente a filial desse escrit�rio. Caso contr�rio,
ser�o exibidos os t�tulos da filial corrente.

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
Fun��o filtro da consulta de Escrit�rio - NS7NZQ

Ser�o exibidos os escrit�rios em que a filial perten�a ao grupo de
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
Fun��o filtro da consulta de Hist�rico Padr�o - OHANZQ

Tipo de lan�amento = Caixinha
                     - Filtra os hist�ricos onde o campo
					 lan�amento = SIM

Tipo de lan�amento = Contas a Pagar
                     - Filtra os hist�ricos onde o campo
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
Valida��o do Filtro de Aprova��o

@param oModel       Modelo de dados da Aprova��o de Despesa
@param cTpLanc      Tipo de Lan�amento - Caixinha / Contas a Pagar
@param cEscrit      C�digo do Escrit�rio
@param cCtPag       Chave do registro de Contas a Pagar
@param lDesdPos     Indica se � desdobramento p�s pagamento
@param cHisPad      Hist�rico Padr�o
@param cNaturOri    Natureza de origem
@param lVldDesCli   Indica se est� realizando o teste considerando que
                    n�o existe uma natureza do tipo 5 - Desp de Cliente
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
Local cMsg      := IIf(lCaixinha, STR0046, STR0047) //"Gerando Lan�amento" "Gerando Desdobramento"
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

// Valida preenchimento do hist�rico padr�o - Telinha de Aprova��o
If Empty(cHisPad) .And. SuperGetMv("MV_JHISPAD", .F., .F.) // Indica se o campo de Hist�rico Padr�o � obrigat�rio (.T.) ou n�o (.F.)
	lRet := .F.
	JurMsgErro(I18N(STR0044, {STR0023}), , STR0082) // "� necess�rio preencher o campo '#1'." ##"Preencha o campo solicitado"
EndIf

// Valida��es em comum entre Caixinha e Contas a pagar
If lRet

	// Valida se a natureza da solicita��o de despesa � v�lida
	If oModelNZQ:GetValue("NZQ_DESPES") == "1" // 1=Cliente
		cNaturDes := JurBusNat("5") // Natureza

		If Empty(cNaturDes) .Or. lVldDesCli // N�o existe natureza de Despesa de cliente ou � um teste negativo (automatiza��o)
			lRet := .F.
			cTitCpo := AllTrim(RetTitle('ED_CCJURI'))
			cValCpo := JurInfBox("ED_CCJURI", '5' )
			JurMsgErro(I18n(STR0057, {cTitCpo, cValCpo}),, STR0058) // "N�o foi encontrada uma natureza onde o campo '#1' � igual a '#2'." - "Inclua uma natureza com esse centro de custo jur�dico."
		EndIf
	Else // 2=Escrit�rio
		cNaturDes := oModelNZQ:GetValue("NZQ_CTADES")

		If Empty(cNaturDes)
			lRet := .F.
			cTitCpo := AllTrim(RetTitle('NZQ_CTADES'))
			JurMsgErro(STR0059,, I18n(STR0060, {cTitCpo})) // "N�o foi encontrada uma natureza na solicita��o." - "Preencha o campo '#1' na solicita��o."
		EndIf
	EndIf

EndIf

If lRet
	If lCaixinha // Tipo de lan�amento - Caixinha

		cPartSolc := oModelNZQ:GetValue("NZQ_CPART")
		// Indica a natureza do solicitante (participante) como natureza origem caso n�o tenha sido preenchida a natereza na telinha de aprova��o
		If Empty(cNaturOri)
			cNaturOri := J159PrtNat(cPartSolc)

			// Valida se foi encontrada uma natureza vinculada ao solitante (participante)
			If Empty(cNaturOri)
				lRet := .F.
				JurMsgErro(STR0061,, I18n(STR0062, {STR0037})) // "N�o foi encontrada uma natureza vinculada ao solicitante." - "Preencha o campo '#1' na 'Aprova��o de despesa' ou vincule uma natureza ao solicitante." - "C�d. Natureza"
			EndIf
		EndIf

		If lRet
			aRetSed   := JurGetDados("SED", 1, xFilial("SED") + cNaturOri, {"ED_CMOEJUR", "ED_CCJURI"})
			If Len(aRetSed) == 2
				cMoedaNat := aRetSed[1]
				cCCNatOri := aRetSed[2]
			EndIf

			// Valida se a moeda da natureza de origem � a mesma da solicita��o de despesa
			If cMoedaNat <> oModelNZQ:GetValue("NZQ_CMOEDA")
				lRet := .F.
				JurMsgErro(STR0063,, STR0064) // "A moeda indicada na solicita��o de despesa est� diferente da moeda da natureza origem." - "Ajuste a moeda da solicita��o de despesa ou indique uma outra natureza origem."
			EndIf
		EndIf

		If lRet
			If cCCNatOri $ "1|2" //Escrit�rio|Centro de Custo|Vazio(n�o definido)
				cEscrPart := JurGetDados("NUR", 1, xFilial("NUR") + cPartSolc, "NUR_CESCR")
				If Empty(cEscrPart)
					lRet := .F.
					JurMsgErro(i18n(STR0070, {cNaturOri}); // "A natureza de origem selecionada '#1' requer o preenchimento do escrit�rio."
							,, i18n(STR0071, {oModelNZQ:GetValue("NZQ_SIGLA")})) // "Indique um escrit�rio no participante sigla '#1' ou indique uma outra natureza origem."
				EndIf

				If lRet .And. cCCNatOri == "2" //Centro de Custo|Vazio(n�o definido)
					cCusto    := JurGetDados("RD0", 1, xFilial("RD0") + cPartSolc, "RD0_CC")
					If Empty(cCusto)
						lRet := .F.
						JurMsgErro(i18n(STR0072, {cNaturOri}); // "A natureza de origem selecionada '#1' requer o preenchimento do centro de custo."
								,, i18n(STR0073, {oModelNZQ:GetValue("NZQ_SIGLA")})) // "Indique um centro de custo no participante sigla '#1' ou indique uma outra natureza origem."
					EndIf
				EndIf
			EndIf
		EndIf

	Else // Tipo de lan�amento - Contas a Pagar

		// Valida preenchimento do N� do contas a pagar - Telinha de Aprova��o
		If Empty(cCtPag)
			lRet := .F.
			JurMsgErro(I18N(STR0045, {STR0014, STR0019}), , STR0082) // "Para o tipo de lan�amento '#1' � necess�rio preencher o campo '#2'." ##"Preencha o campo solicitado"
		EndIf

		// Valida se moeda da solicita��o � a mesma do t�tulo (Contas a Pagar)
		If lRet
			aSE2Info  := JurGetDados("SE2", 1, Trim(STRTRAN(cCtPag, "|", "")), {"E2_MOEDA", "E2_VALOR", "E2_SALDO", "E2_TIPO"})

			If Empty(aSE2Info)
				lRet := .F.
				JurMsgErro(STR0042, , STR0043) // "Contas a pagar inv�lido" "Informe uma chave v�lida para o contas a pagar."

			Else
				cMoedaTit := aSE2Info[1]
				lTemBaixa := aSE2Info[2] != aSE2Info[3]
				lRet      := JVldTipoCp(aSE2Info[4], .T.) // Verifica o tipo da SE2
				cMoedaTit := PADL(cMoedaTit, TamSx3('CTO_MOEDA')[1],'0')

				If lRet .And. cMoedaTit <> oModelNZQ:GetValue("NZQ_CMOEDA")
					lRet := .F.
					JurMsgErro(STR0065,, STR0066) // "A moeda indicada na solicita��o de despesa est� diferente da moeda do t�tulo a pagar." - "Ajuste a moeda da solicita��o de despesa."
				EndIf

				If lRet .And. !lDesdPos .And. lTemBaixa
					lRet := .F.
					JurMsgErro(STR0042, , STR0090) // "Contas a pagar inv�lido" "Informe um t�tulo que n�o possua baixas."
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

If !IsBlind() // Se n�o for execu��o autom�tica
	If lRet .And. !(ApMsgYesNo(STR0056)) // "Deseja realmente aprovar esta solicita��o?"
		lRet := .F.
	EndIf
EndIf

If lRet
	// Confirma a Aprova��o e gera o lan�amento/desdobramento
	Processa( {|| lFecha := J235AConf(oModel, lCaixinha, cEscrit, cCtPag, lDesdPos, cHisPad, cNaturOri, cNaturDes) }, STR0048, cMsg, .F. ) // "Aguarde" - "Processando..."
EndIf

Return lFecha

//-------------------------------------------------------------------
/*/{Protheus.doc} J235AConf
A��o do bot�o Confirmar - Gera��o dos lan�amentos/desdobramentos

@param oModel       Modelo de dados da Aprova��o de Despesa
@param lCaixinha    Tipo de Lan�amento -> .T. Caixinha / .F. Contas a Pagar
@param cEscrit      C�digo do Escrit�rio
@param cCtPag       Chave do registro de Contas a Pagar
@param lDesdPos     Indica se � desdobramento p�s pagamento
@param cHisPad      Hist�rico Padr�o
@param cNaturOri    Natureza Origem para cria��o do lan�amento
                    (Usado quando Tipo de lan�amento � CAIXINHA)
@param cNaturDes    Natureza Destino para cria��o do lan�amento / desdobramento
@param lLote        Indica se � aprova��o em lote
@param aErroLote    Despesas que n�o foram aprovadas e mensagens da valida��o

@return lRet        Indica se a gera��o dos lan�amentos/desdobramentos
                    foi conclu�da com sucesso

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
			cLogNZQ := J235GrvLog(oModel:GetValue("NZQMASTER", "NZQ_LOG"), 1) // Aprova��o de Despesa
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
				cLogNZQ := IIf(Empty(cLogNZQ), J235GrvLog(oModel:GetValue("NZQMASTER", "NZQ_LOG"), 1), cLogNZQ) // Aprova��o de Despesa
				oModel:LoadValue("NZQMASTER", "NZQ_LOG", cLogNZQ)
			EndIf

			FwFormCommit(oModel)
			oModelLanc:CommitData()

		End Transaction

		Iif (IsBlind() .Or. lLote, , ApMsgInfo(STR0067)) // "Solicita��o de Despesa aprovada!"

		FreeObj(oModelLanc)
	EndIf

	oModel:Activate() // Reativa modelo da JURA235A

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J235ADsdb()
Fun��o utilizada no Confirmar da Aprova��o para criar a estrutura de
dados a ser usada na gera��o dos Desdobramentos Financeiros ou P�s
Pagamento (OHF e OHG).

@Param  oModel      Modelo de Solicta��o de Despesas (NZQMASTER)
@Param  cEscrit     C�digo do Escrit�rio digitado na Aprova��o
@Param  cCtPag      Chave completa para seek do Contas a Pagar
@Param  lDesdPos    Indica se � Desdobramento P�s Pagamento
@Param  cHisPad     C�digo do Hist�rico Padr�o usado na Aprova��o
@Param  cNaturDes   C�digo da natureza para cria��o do desdobramento
@param  aErroLote   Array com despesas que tiveram falha no momento da aprova��o em lote
@param  lExibeErro  Indica se as mensagens de erro devem ser exibidas quando houver falha na gera��o do modelo
@param  cLogNZQ     Log das movimenta��es realizadas na solicita��o de despesa

@Return oModelLanc  Modelo do desdobramento para que seja realizado o commit

@author Cristina Cintra
@since 19/10/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J235ADsdb(oModel, cEscrit,�cCtPag,�lDesdPos,�cHisPad, cNaturDes, aErroLote, lExibeErro, cLogNZQ)
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
Local cItem      := JurGetItem(cTabLan, xFilial(cTabLan), cPrefixo + "CITEM", FINGRVFK7("SE2", cCtPag) ) // Tabela e chave para busca do �ltimo c�digo de item

oModelNZQ := oModel:GetModel("NZQMASTER")

// Array para busca do Contas a Pagar na SE2, no qual entrar� o desdobramento
aAdd(aSeek, "SE2")
aAdd(aSeek, 1)
aAdd(aSeek, cChave)

// Array com os campos e os conte�dos a serem considerados no Desdobramento
aAdd(aSetValue, {cPrefixo + "FILIAL", cFilLan})
aAdd(aSetValue, {cPrefixo + "CNATUR", cNaturDes})
aAdd(aSetValue, {cPrefixo + "VALOR" , oModelNZQ:GetValue("NZQ_VALOR")})
aAdd(aSetValue, {cPrefixo + "SIGLA" , oModelNZQ:GetValue("NZQ_SIGLA")})

If cCCNaturez == "3" // Profissional
	aAdd(aSetValue, {cPrefixo + "SIGLA2", oModelNZQ:GetValue("NZQ_SIGPRO")})
ElseIf cCCNaturez $ "1|2" .Or. Empty(cCCNaturez) // Escrit�rio|Centro de Custo|Vazio(n�o definido)
	aAdd(aSetValue, {cPrefixo + "CESCR" , oModelNZQ:GetValue("NZQ_CESCR")})
	If cCCNaturez == "2" .Or. Empty(cCCNaturez) // Centro de Custo|Vazio(n�o definido)
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
Fun��o utilizada no Confirmar da Aprova��o para criar a estrutura de
dados a ser usada na gera��o do Lan�amento Financeiro (OHB).

@param oModel        Modelo da NZQ
@param cEscrit       Escrit�rio prenchido na telinha de aprova��o.
@param cHisPad       C�d Hist�rico padr�o prenchido na telinha de aprova��o.
@param cNaturOri     Natureza Origem para cria��o do lan�amento
@param cNaturDes     Natureza Destino para cria��o do lan�amento
@param aErroLote     Array com despesas que tiveram falha no momento da aprova��o em lote
@param lExibeErro    Indica se as mensagens de erro devem ser exibidas quando houver falha na gera��o do modelo

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
	// Define a origem do lan�amento
	//-------------------------------------------------------------//
	aAdd(aSetValue, {"OHB_ORIGEM", "6"}) //Solicita��o de despesa

	//-------------------------------------------------------------//
	// Dados da natureza de origem
	//-------------------------------------------------------------//
	aAdd(aSetValue, {"OHB_NATORI", cNaturOri})
	Do Case
		Case cCCNatOri == "3" //Profissional
			aAdd(aSetValue, {"OHB_SIGLAO", oModelNZQ:GetValue("NZQ_SIGLA")})

		Case cCCNatOri $ "1|2" //Escrit�rio|Centro de Custo
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
		Case cCCNatDest $ "1|2" //Escrit�rio|Centro de Custo|
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

		Case Empty(cCCNatDest) .And. cTpDesp == "2" // Despesa de Escrit�rio
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
	// Gerar Modelo do Lan�amento
	//-------------------------------------------------------------//
	aAdd(aSetFields, {"OHBMASTER", {} /*aSeekLine*/, aSetValue})
	oModelLanc := JurGrModel("JURA241", MODEL_OPERATION_INSERT, {} /*aSeek*/, aSetFields, @aErroModel, lExibeErro)

	If !lExibeErro .And. !Empty(aErroModel)
		aAdd(aErroLote, {oModelNZQ:GetValue("NZQ_COD"), aErroModel[6], aErroModel[7]})
	EndIf

Return oModelLanc

//-------------------------------------------------------------------
/*/{Protheus.doc} J235ARepro()
Tela de reprova��o de solicita��o de despesa.

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

		If lAutomato .Or. MsgYesNo(STR0055) // "Deseja reprovar a Solicita��o de Despesa?"

			If lAutomato
				If FindFunction("GetParAuto")
					aRetAuto := GetParAuto(cTestCase)[1]
					Iif( Len(aRetAuto) >= 1 .And. !Empty(aRetAuto[1]), cMotivo := aRetAuto[1], )//"Motivo de Reprova��o"
					J235AGvRep(cMotivo, oModel) //Bot�o ok
				EndIf
			Else
				Define MsDialog oDlg Title STR0034 FROM 1, 1 To 220, 420 Pixel  // "Reprova��o de Solicita��o de Despesa"

				oLayer:init(oDlg, .F.) //Inicializa o FWLayer com a janela que ele pertencera e se sera exibido o botao de fechar
				oLayer:addCollumn("MainColl", 100, .F.) //Cria as colunas do Layer
				oMainColl := oLayer:GetColPanel("MainColl")

				oMmMotivo := TJurPnlCampo():New(010, 006, 200, 65, oMainColl, STR0049, ("NZQ_MOTREP"), {|| }, {|| },,,,) // "Motivo de Reprova��o"

				ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar;
							(oDlg,;
							{|| Iif(J235AGvRep(oMmMotivo:Valor, oModel), (oDlg:End(), ApMsgInfo(STR0068)), Nil) },; //# "Solicita��o de Despesa reprovada!"
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
Rotina para atualizar o campo de situa��o e motivo de reprova��o ao reprovar a despesa

@Params  cMotivo - Memo com o motivo da reprova��o
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
	JurMsgErro(STR0069, , STR0082) //"� necess�rio preencher o motivo de reprova��o da solicita��o de despesa." ##"Preencha o campo solicitado"
	lRet := .F.
Else
	IIF(lRet, lRet := oModelNZQ:SetValue('NZQ_MOTREP', Iif(!Empty(cMotRepr), cMotRepr + CRLF, '') + cMotivo), Nil)
	IIF(lRet, lRet := oModelNZQ:LoadValue('NZQ_SITUAC', '3'), Nil)
	If lRet .And. NZQ->(ColumnPos("NZQ_LOG")) > 0
		cLogNZQ := J235GrvLog(oModel:GetValue("NZQMASTER", "NZQ_LOG"), 2) // Reprova��o de Despesa
		lRet    := oModel:LoadValue("NZQMASTER", "NZQ_LOG", cLogNZQ)
	EndIf

	lRet  := oModel:VldData()
	aErro := oModel:GetErrorMessage()

	IIf (lRet, lRet := oModel:CommitData(), JurMsgErro(aErro[6], , aErro[7]))

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J235AtuDesd()
Atualiza a aprova��o de despesa conforme altera��o no desdobramento ou desdobramento p�s pagamento

@Param  oModel,    Submodelo de dados que est� sofrendo altera��o
@Param  nLine,     N�mero da linha quando do grid
@param  nOperacao, Operacao para a Despesa (4=UPDATE;5=DELETE)

@Return oModelNZQ, Modelo da aprova��o de despesa que foi alterado,
                   retorna nil se houve um erro.

@author Abner Foga�a de Oliveira
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
		// Array para busca aprova��o de despesa NZQ que ser� exclu�do
		aAdd(aSeek, "NZQ")
		aAdd(aSeek, 1)
		aAdd(aSeek, xFilial("NZQ") + cCodNZQ)

		aAdd(aSetValue, {"NZQ_MOTREP", STR0085}) // "Reprova��o devido a exclus�o do desdobramento."
		aAdd(aSetValue, {"NZQ_SITUAC", "3"})
		aAdd(aSetValue, {"NZQ_FILLAN", ""})
		aAdd(aSetValue, {"NZQ_CPAGTO", ""})
		aAdd(aSetValue, {"NZQ_ITDES" , ""})
		aAdd(aSetValue, {"NZQ_ITDPGT", ""})

		If NZQ->(ColumnPos("NZQ_LOG")) > 0
			cLogNZQ := J235GrvLog(JurGetDados("NZQ", 1, xFilial("NZQ") + cCodNZQ, "NZQ_LOG"), 2) // Reprova��o de Despesa
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

		If cDespCli == "2" // S� altera a natureza quando a aprova��o de despesas for de escrit�rio
			cNaturez   := oSubModel:GetValue(cPrefixo + "CNATUR", nLine)
			cCCNaturez := JurGetDados("SED", 1, xFilial("SED") + cNaturez, "ED_CCJURI")
			
			aAdd(aSetValue, {"NZQ_CTADES", cNaturez})

			Do Case
				Case cCCNaturez == "3" // Profissional
					aAdd(aSetValue, {"NZQ_SIGPRO", oSubModel:GetValue(cPrefixo + "SIGLA2", nLine)})
				
				Case cCCNaturez $ "1|2" .Or. Empty(cCCNaturez)
					aAdd(aSetValue, {"NZQ_CESCR" , oSubModel:GetValue(cPrefixo + "CESCR" , nLine)})

					cCusto := oSubModel:GetValue(cPrefixo + "CCUSTO", nLine)
					If cCCNaturez == "2" .Or. (Empty(cCCNaturez) .And. !Empty(cCusto)) // Centro de Custo|Vazio(n�o definido)
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
Cancela a opera��o realizada anteriormente (aprova��o/reprova��o)
e retorna a situa��o para pentente

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
	JurMsgErro(STR0079,, STR0080) // "N�o existe aprova��o/reprova��o para esta solicita��o." "Verifique a situa��o da solicita��o."

ElseIf lAprovada .Or. lReprovada
	cMsgYesNo := STR0077 // "Deseja realmente cancelar a aprova��o/reprova��o desta solicita��o?"

EndIf

If lRet .And. (IsBlind() .Or. ApMsgYesNo(cMsgYesNo))
	If !Empty(NZQ->NZQ_CLANC) // Lan�amento entre naturezas

		// Array para busca do Lan�amento na OHB que ser� exclu�do
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
		ElseIf !Empty(NZQ->NZQ_ITDPGT) // Desdobramento p�s pagamento
			aAdd(aSetFields, {'OHGDETAIL', { {"OHG_CITEM", NZQ->NZQ_ITDPGT } }, {}, .F., "" } )
			cFonte := "JURA247"
		EndIf

		If !Empty(cFonte)

			// Array para busca do Desdobramento na OHF / Desdobramento p�s pagamento na OHG que ser� exclu�do
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
			cLogNZQ  := J235GrvLog(NZQ->NZQ_LOG, nLogOper) // Cancelamento da Aprova��o Financeira ou Cancelamento da Reprova��o Financeira
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

		Iif(IsBlind(),, ApMsgInfo(STR0078)) // "Cancelamento conclu�do com sucesso."

	EndIf

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J235ANatWh
When dos campos da Solicita��o de Despesas relacionados a natureza

@param  cCampo, caractere, Nome do campo que est� executando a fun��o

@return lWhen , logico   , Se .T. habilita a edi��o do campo

@author Jonatas Maritns
@since  25/09/2019
@Obs    Fun��o utilizada no X3_WHEN dos campos
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

	If cTipoDesp == "2" // Despesa de escrit�rio
		If lAprDesp // Aprova��o de despesas JURA235A
			Do Case
				Case cCampo == "NZQ_CTADES" // Natureza
					lWhen := .T.

				Case cCampo == "NZQ_CESCR" // Escrit�rio
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
		Else // Solicita��o de despesas JURA235
			lWhen := .T.
		EndIf
	EndIf

Return (lWhen)

//-------------------------------------------------------------------
/*/{Protheus.doc} J235AUpdNZQ
Verifica se o desdobramento tem como origem aprova��o de despesas e atualiza a tabela NZQ.

@param oModel, Modelo ativo

@Return [1]lValid   , Se a fun��o foi executada corretamente
		[2]aModelNZQ, Array com os modelos da aprova��o de despesa que foram atualizados
                   para efeturar o commit na transa��o.

@author Abner Foga�a de Oliveira
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
Gera o Log de aprova��o, reprova��o, cancelamento de aprova��o e 
cancelamento de reprova��o da solicita��o de despesas

@param cLogAtual , Log atual (para que seja complementado)
@param nTipoOper , Tipo da Opera��o
                   1 - Aprova��o Financeira
                   2 - Reprova��o Financeira
                   3 - Cancelamento da Aprova��o Financeira
                   4 - Cancelamento da Reprova��o Financeira

@return cLog     , Log de movimenta��o da solicita��o de despesa

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
			cOper := STR0091 // "Aprova��o Financeira"
		Case nTipoOper == 2
			cOper := STR0092 // "Reprova��o Financeira"
		Case nTipoOper == 3
			cOper := STR0093 // "Cancelamento da Aprova��o Financeira"
		Case nTipoOper == 4
			cOper := STR0094 // "Cancelamento da Reprova��o Financeira"
	End Case

	cLog := STR0095 + cOper + CRLF     // "Opera��o: "
	cLog += STR0096 + cPart + CRLF     // "Participante: "
	cLog += STR0097 + cDataHora + CRLF // "Data e hora: "

	cLog += IIf(Empty(cLogAtual), "", CRLF + Replicate( "-", 100 ) + CRLF + CRLF + cLogAtual) // Inclui o Log atual da solicita��o de despesa

Return cLog
