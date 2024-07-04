#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "VEIC071.CH"

/*/{Protheus.doc} VEIC071
Consulta de Veiculos

@author Rubens
@since 02/04/2019
@version 1.0
@type function
/*/

Function VEIC071()

	Local oModel
	Local oView

	CursorWait()

	VC0700293_CriaVariaveis("VEIC071")
	
	lVV2OPCION := .F.
	aCpoTREsumo := { "VV1_CODMAR","VV1_MODVEI","VV1_SEGMOD","VV1_FABMOD","VV2_DESMOD","VE1_DESMAR","VV1_SITVEI" }

	VC0710013_ConfigConsulta(@oVEConsVeicQuery)
	VC0710023_ConfigBrowse(@oBrwStruConsVeic)
	VC0700423_ConfiguraAmbiente()
	VC0710143_AtuBrowseConsulta(.f.)

	oModel := FWLoadModel("VEIC070")
	oView := FWLoadView("VEIC071")
	oModel:setOperation(MODEL_OPERATION_UPDATE)
	If ! oModel:Activate()
		MostraErro()
		CursorArrow()
		Return .f.
	EndIf


	VC0700313_AtualizaGrids(oModel)
	
	oExecView := FWViewExec():New()
	oExecView:setTitle( STR0001 )
	oExecView:setModel(oModel)
	oExecView:setView(oView)
	oExecView:setOK( { || VC0700433_AtualizarView(oModel, oView) } )
	oExecView:setCancel( { || .T. } )
	oExecView:SetButtons( {;
		{ .f. , NIL } ,; // 1 - Copiar
		{ .f. , NIL } ,; // 2 - Recortar
		{ .f. , NIL } ,; // 3 - Colar
		{ .f. , NIL } ,; // 4 - Calculadora
		{ .f. , NIL } ,; // 5 - Spool
		{ .f. , NIL } ,; // 6 - Imprimir
		{ .t. , "Atualizar" } ,; // 7 - Confirmar - 'Atualizar'
		{ .t. , "Fechar" } ,; // 8 - Cancelar - 'Fechar'
		{ .f. , NIL } ,; // 9 - WalkTrhough
		{ .f. , NIL } ,; // 10 - Ambiente
		{ .f. , NIL } ,; // 11 - Mashup
		{ .f. , NIL } ,; // 12 - Help
		{ .f. , NIL } ,; // 13 - Formulário HTML
		{ .f. , NIL }  ; // 14 - ECM
		})
	CursorArrow()
	oExecView:openView(.T.)

	VC0700443_Fim()

Return

Static Function ViewDef()

	Local oModel	:= FWLoadModel( 'VEIC070' )
	Local oView 	:= Nil

	Local oModMarca      := oDMSStr01_Marca:GetView()
	Local oModModelo     := oDMSStr02_Modelo:GetView()
	Local oModAnoFabMod  := oDMSStr06_AnoFabMod:GetView()
	Local oModSitVei     := oDMSStr08_SitVei:GetView()
	Local oModEvento     := oDMSStr09_Evento:GetView()

	oView := FWFormView():New()
	oView:SetModel(oModel)
	
	oView:AddGrid('GRID_LISTA_MARCA'      , oModMarca      , 'LISTA_MARCA' )
	oView:AddGrid('GRID_LISTA_MODELO'     , oModModelo     , 'LISTA_MODELO' )
	oView:AddGrid('GRID_LISTA_ANOFABMOD'  , oModAnoFabMod  , 'LISTA_ANOFABMOD' )
	oView:AddGrid('GRID_LISTA_SITVEI'     , oModSitVei     , 'LISTA_SITVEI' )
	oView:AddGrid('GRID_LISTA_EVENTO'     , oModEvento     , 'LISTA_EVENTO' )

	oView:AddOtherObject('BROWSE', { |oPanel| VC0700103_CriaBrowse(oPanel) })

	oView:CreateFolder('FOLDER')
	oView:AddSheet('FOLDER', 'ABA_PARAMETROS', STR0002 ) //Parâmetros de Filtro
	oView:AddSheet('FOLDER', 'ABA_BROWSE', STR0003 ) //Máquinas

	oView:CreateHorizontalBox('TELA_BROWSE' ,100,,,'FOLDER','ABA_BROWSE')

	oView:createVerticalBox('TELA_PARAM1'     , 300 , '' , .T. , 'FOLDER' , 'ABA_PARAMETROS' )
	oView:createVerticalBox('TELA_MODELO'     , 100 , '' , .F. , 'FOLDER' , 'ABA_PARAMETROS' )
	oView:createVerticalBox('TELA_PARAM2'     , 300 , '' , .T. , 'FOLDER' , 'ABA_PARAMETROS' )
	
	oView:CreateHorizontalBox('TELA_MARCA'    , 50,'TELA_PARAM1',,'FOLDER','ABA_PARAMETROS')
	oView:CreateHorizontalBox('TELA_ANOFABMOD', 50,'TELA_PARAM1',,'FOLDER','ABA_PARAMETROS')

	oView:CreateHorizontalBox('TELA_SITVEI'   , 50,'TELA_PARAM2',,'FOLDER','ABA_PARAMETROS')
	oView:CreateHorizontalBox('TELA_EVENTO'   , 50,'TELA_PARAM2',,'FOLDER','ABA_PARAMETROS')

	oView:SetOwnerView( 'GRID_LISTA_MARCA'     , 'TELA_MARCA' )
	oView:SetOwnerView( 'GRID_LISTA_ANOFABMOD' , 'TELA_ANOFABMOD' )
	oView:SetOwnerView( 'GRID_LISTA_MODELO'    , 'TELA_MODELO' )
	oView:SetOwnerView( 'GRID_LISTA_SITVEI'    , 'TELA_SITVEI' )
	oView:SetOwnerView( 'GRID_LISTA_EVENTO'    , 'TELA_EVENTO' )

	oView:EnableTitleView( 'GRID_LISTA_MARCA'     , STR0004 ) // Marca
	oView:EnableTitleView( 'GRID_LISTA_MODELO'    , STR0005 ) // Modelo
	oView:EnableTitleView( 'GRID_LISTA_ANOFABMOD' , STR0006 ) // Ano Fab./Mod.
	oView:EnableTitleView( 'GRID_LISTA_SITVEI'    , STR0007 ) // Situação Veículo
	oView:EnableTitleView( 'GRID_LISTA_EVENTO'    , STR0008 ) // Evento

	oView:SetOwnerView( 'BROWSE' , 'TELA_BROWSE' )

	VC0700463_ConfiguraView(oView)

	oView:SetVldFolder({ |cFolderID, nOldSheet, nSelSheet | VC0710283_ChangeFolder(cFolderID, nOldSheet, nSelSheet) })

Return oView

Function VC0710013_ConfigConsulta(oVEConsVeicQuery)

	Local cSGBD   := TcGetDb()
	Local cReserv := ""

	oVEConsVeicQuery := VEConsultaVeiculo():New()
	
	oVEConsVeicQuery:SetMovEntrada(.t.)
	oVEConsVeicQuery:SetMovSaida(.t.)
	oVEConsVeicQuery:SetPedCompra(.t.)
	oVEConsVeicQuery:SetVendidoSitVei(.f.)
	oVEConsVeicQuery:SetVazioSitVei(.f.)

	lPedCompra := .t. // Preparacao para configurar o VEConsultaVeiculo para exibir as informacoes de Pedido de Compra

	// Configura os campos que serao utilizados na classe para pesquisa
	oVEConsVeicQuery:SetCamposQuery(;
		"VV1_CODMAR, VV1_MODVEI, VV1_SEGMOD, VV1_CHASSI, VV1_CHAINT, VV1_FABMOD, VV1_COMVEI, VV1_CHARED, VV1_SITVEI, VV1_IMOBI," +;
		"VV2_DESMOD, " +;
		"VE1_DESMAR, " +;
		"VV0_NUMNFI, VV0_SERNFI, VV0_DTHEMI, VV0_CODCLI, VV0_LOJA, " +;
		"VQ0_NUMPED, VQ0_DATPED, VQ0_DATVEN, VQ0_DATENT, " +;
		"VJR_DATFDD, VJR_DATORS, VJR_EVENTO, VJR_STAFAB, VJR_ORDNUM, " +;
		"VVA_RESERV, VVA_DATVAL ")
	
	If "ORACLE" $ cSGBD
		cReserv := " WHEN VVA_RESERV IN ('1','3') AND SYSDATE < VVA_DATVAL THEN '4'"
	ElseIf "MSSQL" $ cSGBD
		cReserv := " WHEN VVA_RESERV IN ('1','3') AND GETDATE() < VVA_DATVAL THEN '4'"
	EndIf

	// Configura os campo que serao retornados no metodo GetQuery
	// Os campos deste metodo devem existir na SetCamposQuery...
	oVEConsVeicQuery:SetCamposRet(;
		"VV1_CODMAR, " +;
		"VE1_DESMAR, " +;
		"VV1_MODVEI, " +;
		"VV2_DESMOD, " +;
		"VV1_SEGMOD, " +;
		"VV1_CHASSI, " +;
		"VV1_CHAINT, " +;
		"VV1_FABMOD, " +;
		"VV1_COMVEI, " +;
		"VV1_CHARED, " +;
		"VV1_SITVEI, " +;
		"VV1_IMOBI, " +;
		"COALESCE(VV0_NUMNFI,' '), " +;
		"COALESCE(VV0_SERNFI,' '), " +;
		"COALESCE(VV0_DTHEMI,' '), " +;
		"COALESCE(VV0_CODCLI,' '), " +;
		"COALESCE(VV0_LOJA,' '), " +;
		"COALESCE(VQ0_NUMPED,' '), " +;
		"COALESCE(VQ0_DATPED,' '), " +;
		"COALESCE(VQ0_DATVEN,' '), " +;
		"COALESCE(VQ0_DATENT,' '), " +;
		"COALESCE(VJR_DATFDD,' '), " +;
		"COALESCE(VJR_DATORS,' '), " +;
		"COALESCE(VJR_EVENTO,' '), " +;
		"COALESCE(VJR_STAFAB,' '), " +;
		"COALESCE(VJR_ORDNUM,' '), " +;
		" CASE " +;
			" WHEN VV1_IMOBI = '1' THEN '3'" +;
			" WHEN BLOQ = 1 THEN '2'" +;
			cReserv +;
			" ELSE '1'" +;
		" END AS SITUACAO," +;
		"COALESCE(DIAESTQ,0) DIAESTQ , " +;
		" 0 AS MARCADO ")

Return

Function VC0710023_ConfigBrowse(oBrwStruConsVeic)
	oBrwStruConsVeic := OFBrowseStruct():New({"VV1", "VV2", "VVR"})

	oBrwStruConsVeic:AddField( "VV1_CODMAR" )
	oBrwStruConsVeic:AddField( "VE1_DESMAR" )
	oBrwStruConsVeic:AddField( "VV1_MODVEI" )
	oBrwStruConsVeic:AddField( "VV2_DESMOD" )
	oBrwStruConsVeic:AddField( "VV1_SEGMOD" )
	oBrwStruConsVeic:AddField( "VV1_CHASSI" )
	oBrwStruConsVeic:AddField( "VV1_CHAINT" )
	oBrwStruConsVeic:AddField( "VV1_FABMOD" )
	oBrwStruConsVeic:AddField( "VV1_COMVEI" )
	oBrwStruConsVeic:AddField( "VV1_CHARED" )
	oBrwStruConsVeic:AddField( "VV1_SITVEI" )
	oBrwStruConsVeic:AddField( "VV1_IMOBI" ,, .F. )
	oBrwStruConsVeic:AddField( "VV0_NUMNFI" )
	oBrwStruConsVeic:AddField( "VV0_SERNFI" )
	oBrwStruConsVeic:AddField( "VV0_DTHEMI" )
	oBrwStruConsVeic:AddField( "VV0_CODCLI" )
	oBrwStruConsVeic:AddField( "VV0_LOJA"   )
	oBrwStruConsVeic:AddField( "VQ0_NUMPED" )
	oBrwStruConsVeic:AddField( "VQ0_DATPED" )
	oBrwStruConsVeic:AddField( "VQ0_DATVEN" )
	oBrwStruConsVeic:AddField( "VQ0_DATENT" )
	oBrwStruConsVeic:AddField( "VJR_DATFDD" )
	oBrwStruConsVeic:AddField( "VJR_DATORS" )
	oBrwStruConsVeic:AddField( "VJR_EVENTO" )
	oBrwStruConsVeic:AddField( "VJR_STAFAB" )
	oBrwStruConsVeic:AddField( "VJR_ORDNUM" )
	oBrwStruConsVeic:AddFieldManual( DMS_DataContainer():New( {;
											{ 'cIdField' , 'SITUACAO' },;
											{ 'cTitulo' , STR0009 },; // Situação
											{ 'cTipo' , 'C' },;
											{ 'nTamanho' , 1 },;
											{ 'nDecimal' , 0 },;
											{ 'cPicture' , '@!' },;
											{ 'aComboValues', {"1=" + STR0010 ,"2=" + STR0011 ,"3=" + STR0012 ,"4=" + STR0013 } } } ) ) //"DISPONÍVEL" / "BLOQUEADO" / "IMOBILIZADO" / "RESERVADO"
	oBrwStruConsVeic:AddFieldManual( DMS_DataContainer():New({;
											{ 'cIdField' , 'DIAESTQ' },;
											{ 'cTitulo' , STR0014 },; // Dias de Estoque
											{ 'cTipo' , 'N' },;
											{ 'nTamanho' , 5 },;
											{ 'nDecimal' , 0 },;
											{ 'cPicture' , '@! 99999' } } ) )
	oBrwStruConsVeic:AddFieldManual( DMS_DataContainer():New({;
											{ 'cIdField' , 'MARCADO' },;
											{ 'cTitulo' , STR0015 },; // Marcado
											{ 'cTipo' , 'N' },;
											{ 'nTamanho' , 1 },;
											{ 'nDecimal' , 0 },;
											{ 'cPicture' , '@! 9' } } ) , .f. )

	oBrwStruConsVeic:CriaTabTmp()

Return


Static Function VC0710143_AtuBrowseConsulta(lParFiltro)

	Local cSQL

	cSQL := "SELECT VV1_CODMAR, VE1_DESMAR, VV1_MODVEI, VV2_DESMOD, VV1_SEGMOD, "
	cSQL +=		" VV1_CHASSI, VV1_CHAINT, VV1_FABMOD, VV1_COMVEI, VV1_CHARED, "
	cSQL +=		" VV1_SITVEI, VV1_IMOBI, VV0_NUMNFI, VV0_SERNFI, VV0_DTHEMI, VV0_CODCLI, "
	cSQL +=		" VV0_LOJA, VQ0_NUMPED, VQ0_DATPED, VQ0_DATVEN, VQ0_DATENT, "
	cSQL +=		" VJR_DATFDD, VJR_DATORS, VJR_EVENTO, VJR_STAFAB, VJR_ORDNUM, "
	cSQL +=		" SITUACAO, DIAESTQ, MARCADO "
	cSQL +=" FROM " + oTabConsVeiculo:GetRealName()
	If lParFiltro
		cSQL += " WHERE MARCADO = 1"
	EndIf

	oBrwStruConsVeic:LoadData( cSQL , .t. )
	
	dbSelectArea(oBrwStruConsVeic:GetAlias())
	dbGoTop()
	
Return

Function VC0710283_ChangeFolder(cIdField, nOldSheet, nSelSheet)
	Local lParFiltro := .f.

	CursorWait()

	If nSelSheet == 2
		VC0700273_AtuMarcacaoTabResumo(@lParFiltro)
		VC0710143_AtuBrowseConsulta(lParFiltro)
		oBrwVC070:GoTop(.t.)
		oBrwVC070:Refresh(.t.)
	EndIf

	CursorArrow()

Return .t.
