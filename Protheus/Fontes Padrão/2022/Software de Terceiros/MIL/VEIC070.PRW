#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "VEIC070.CH"

#define lDebug .f.


/*/{Protheus.doc} VEIC070
Consulta de Estoque de Veiculos

@author Rubens
@since 02/04/2019
@version 1.0
@type function
/*/

Function VEIC070()

	Local oModel
	Local oView

	Private nQtdAtendPed := 2 // Quantidade de atendimentos / pedidos que serão listados ...

	Private nTamColAtendRelacionado  := (nQtdAtendPed * (TamSX3("VVA_NUMTRA")[1] + 1))
	Private nTamColPedidoRelacionado := (nQtdAtendPed * (TamSX3("VRJ_PEDIDO")[1] + 1))

	If lDebug
		aRetParam := {}
		aParParam := {}
		// Paramebox para selecionar o tipo de garantia que será criado
		AADD( aParParam, { 3,"Opcional",1,{"Agrupado","Detalhado"},90,,.T.,"" } )
		AADD( aParParam, { 3,"Cor Externa",1,{"Agrupado","Detalhado"},90,,.T.,"" } )
		AADD( aParParam, { 3,"Cor Interna",1,{"Agrupado","Detalhado"},90,,.T.,"" } )
		If ParamBox(aParParam,"Configuração",aRetParam) // "Tipo de Garantia"
			lOpcionalFiltroDetalhado   := ( aRetParam[1] == 2 )
			lCorExternaFiltroDetalhado := ( aRetParam[2] == 2 )
			lCorInternaFiltroDetalhado := ( aRetParam[3] == 2 )
		EndIf

	EndIf
	// ------------------------------------------------------------------------------------------------------------------


	CursorWait()
	
	oModel := FWLoadModel("VEIC070")

	VC0700293_CriaVariaveis("VEIC070")

	VC0700013_ConfigConsulta(@oVEConsVeicQuery)
	VC0700023_ConfigBrowseEstoque(@oBrwStruConsVeic)
	VC0700453_ConfigBrowseResumoEstq(@oBSEstqResumo)
	VC0700423_ConfiguraAmbiente()

	oView := FWLoadView("VEIC070")
	oModel:setOperation(MODEL_OPERATION_UPDATE)
	If ! oModel:Activate()
		MostraErro()
		CursorArrow()
		Return .f.
	EndIf


	VC0700313_AtualizaGrids(oModel, .f.)

	oExecView := FWViewExec():New()
	oExecView:setTitle("Estoque")
	oExecView:setModel(oModel)
	oExecView:setView(oView)
	//oExecView:setOK( { || .T. } )
	oExecView:setOK( { || VC0700433_AtualizarView(oModel, oView) } )
	oExecView:setCancel( { || .T. } )
	oExecView:SetButtons( {;
		{ .f. , NIL } ,; // 1 - Copiar
		{ .f. , NIL } ,; // 2 - Recortar
		{ .f. , NIL } ,; // 3 - Colar
		{ .f. , NIL } ,; // 4 - Calculadora
		{ .f. , NIL } ,; // 5 - Spool
		{ .f. , NIL } ,; // 6 - Imprimir
		{ .t. , STR0002 } ,; // 7 - Confirmar - 'Atualizar'
		{ .t. , STR0003 } ,; // 8 - Cancelar - 'Fechar'
		{ .f. , NIL } ,; // 9 - WalkTrhough
		{ .f. , NIL } ,; // 10 - Ambiente
		{ .f. , NIL } ,; // 11 - Mashup
		{ .f. , NIL } ,; // 12 - Help
		{ .f. , NIL } ,; // 13 - Formulário HTML
		{ .f. , NIL }  ; // 14 - ECM
		})
	//oExecView:setOperation(MODEL_OPERATION_UPDATE)
	CursorArrow()
	oExecView:openView(.T.)

	VC0700443_Fim()

Return

Function VC0700293_CriaVariaveis(cOwner)

	Default cOwner := FMX_OwnerFunc()

	_SetNamedPrvt( "oBrwStruConsVeic"  , , cOwner )   
	_SetNamedPrvt( "oVEConsVeicQuery"  , , cOwner ) // Componente para criacao de query de Estoque de Veiculos
	_SetNamedPrvt( "oBrwVC070"         , , cOwner )   

	_SetNamedPrvt( "oBSEstqResumo"     , , cOwner )   
	_SetNamedPrvt( "oBrw070ResumoEstq" , , cOwner )   

	_SetNamedPrvt( "oTabConsVeiculo"   , , cOwner ) // FWTemporaryTable - Tabela temporaria contendo todo o estoque atual de veiculos
	_SetNamedPrvt( "cNomeTabConsulta"  , , cOwner )   

	_SetNamedPrvt( "oVC070SQL" , DMS_SqlHelper():New() , cOwner )

	_SetNamedPrvt( "nTamDOpcional" , VC0700383_MaxDescrVX5('068') , cOwner )
	_SetNamedPrvt( "nTamDCorExt"   , VC0700383_MaxDescrVX5('067') , cOwner )
	_SetNamedPrvt( "nTamDCorInt"   , VC0700383_MaxDescrVX5('066') , cOwner )

	_SetNamedPrvt( "lVV2OPCION" , VV2->(FieldPos("VV2_OPCION")) <> 0 , cOwner )
	_SetNamedPrvt( "lExistVJR" , FWAliasInDic("VJR") , cOwner )
	
	_SetNamedPrvt( "oPrincipal" , VC0700043_Marca() , cOwner ) // Criado somente para criar uma FIELD que é obrigatorio no MVC

	_SetNamedPrvt( "aCpoTREsumo" , { "VV1_CODMAR","VV1_MODVEI","VV1_SEGMOD","VV1_FABMOD","VV2_DESMOD","VV2_OPCION","VV2_COREXT","VV2_CORINT","VE1_DESMAR","VV1_SITVEI" } , cOwner ) 

	_SetNamedPrvt( "lOpcionalFiltroDetalhado"   , .t. , cOwner ) // Controla se os filtros de cor interna e externa serão por Descricao
	_SetNamedPrvt( "lCorExternaFiltroDetalhado" , .t. , cOwner ) // Controla se os filtros de cor interna e externa serão por Descricao
	_SetNamedPrvt( "lCorInternaFiltroDetalhado" , .t. , cOwner ) // Controla se os filtros de cor interna e externa serão por Descricao

	_SetNamedPrvt( "oDMSStr01_Marca"       , VC0700043_Marca()       , cOwner )
	_SetNamedPrvt( "oDMSStr02_Modelo"      , VC0700053_Modelo()      , cOwner )
	_SetNamedPrvt( "oDMSStr03_Opcional"    , VC0700063_Opcional()    , cOwner )
	_SetNamedPrvt( "oDMSStr04_CorExterna"  , VC0700073_CorExterna()  , cOwner )
	_SetNamedPrvt( "oDMSStr05_CorInterna"  , VC0700083_CorInterna()  , cOwner )
	_SetNamedPrvt( "oDMSStr06_AnoFabMod"   , VC0700093_AnoFabMod()   , cOwner )
	_SetNamedPrvt( "oDMSStr07_Situacao"    , VC0700253_Situacao()    , cOwner )
	_SetNamedPrvt( "oDMSStr10_Imobilizado" , VC0700413_Imobilizado() , cOwner )
	_SetNamedPrvt( "oDMSStr08_SitVei"      , VC0700473_SitVei()      , cOwner )
	_SetNamedPrvt( "oDMSStr09_Evento"      , VC0700483_Evento()      , cOwner )

	_SetNamedPrvt( "oTResumo"         , , cOwner ) // FWTemporaryTable
	_SetNamedPrvt( "oTResMarca"       , , cOwner ) // FWTemporaryTable
	_SetNamedPrvt( "oTResModelo"      , , cOwner ) // FWTemporaryTable
	_SetNamedPrvt( "oTResOpcional"    , , cOwner ) // FWTemporaryTable
	_SetNamedPrvt( "oTResCorExt"      , , cOwner ) // FWTemporaryTable
	_SetNamedPrvt( "oTResCorInt"      , , cOwner ) // FWTemporaryTable
	_SetNamedPrvt( "oTResAnoFabMod"   , , cOwner ) // FWTemporaryTable
	_SetNamedPrvt( "oTResSituacao"    , , cOwner ) // FWTemporaryTable
	_SetNamedPrvt( "oTResImobilizado" , , cOwner ) // FWTemporaryTable
	_SetNamedPrvt( "oTResSitVei" , , cOwner ) // FWTemporaryTable
	_SetNamedPrvt( "oTResEvento" , , cOwner ) // FWTemporaryTable
	//Private oTRelVX5 // Tabela temporaria auxiliar para relacionamento com a VX5 => 066 - Cor Interna / 067 - Cor Externa / 068 - Opcional


Return

Function VC0700423_ConfiguraAmbiente()
	VC0700113_CriaTabResumo()
	VC0700213_CriaTabConsulta()
	VC0700223_AtuTabConsulta()
Return

Function VC0700313_AtualizaGrids(oModel, lClear)
	VC0700153_AtualizaGridMarcas(oModel, lClear )
	VC0700163_AtualizaGridModelos(oModel , lClear )
	If lVV2OPCION
		VC0700173_AtualizaGridOpcionais(oModel , lClear )
		VC0700183_AtualizaGridCorExterna(oModel , lClear )
		VC0700193_AtualizaGridCorInterna(oModel , lClear )
	EndIf
	VC0700203_AtualizaGridAnoFabMod(oModel , lClear )
	VC0700263_AtualizaGridSituacao(oModel , lClear )
	VC0700303_AtualizaGridImobilizado(oModel , lClear )
	VC0700343_AtualizaGridSitVei(oModel, lClear )
	If lExistVJR .and. oVEConsVeicQuery:GetPedCompra()
		VC0700373_AtualizaGridEvento(oModel, lClear )
	EndIf
Return

Function VC0700443_Fim()
	oBrwStruConsVeic:DelTrabTmp()
	oTResumo:CloseTable()
	oTResMarca:CloseTable()
	oTResModelo:CloseTable()
	oTResOpcional:CloseTable()
	oTResCorExt:CloseTable()
	oTResCorInt:CloseTable()
	oTResAnoFabMod:CloseTable()
	oTResSituacao:CloseTable()
	oTResSitVei:CloseTable()
	oTResImobilizado:CloseTable()
	//oTRelVX5:CloseTable()
	If lExistVJR
		oTResEvento:CloseTable()
	EndIf
	
Return

Function VC0700013_ConfigConsulta(oVEConsVeicQuery)

	oVEConsVeicQuery := VEConsultaVeiculo():New()
	oVEConsVeicQuery:SetSoEstoque(.t.)
	oVEConsVeicQuery:SetImobilizado(.t.)
	oVEConsVeicQuery:ColAtendimento(.t.)
	oVEConsVeicQuery:ColPedido(.t.)
	oVEConsVeicQuery:SetCamposRet(;
		"VV1_CODMAR, " +;
		"VE1_DESMAR, " +;
		"VV1_MODVEI, " +;
		"VV2_DESMOD, " +;
		"VV1_SEGMOD, " +;
		IIf( lVV2OPCION , "VV2_OPCION, DESCOPCION, VV2_COREXT, DESCCOREXT, VV2_CORINT, DESCCORINT, " , "" ) +;
		"VV1_CHASSI, " +;
		"VV1_CHAINT, " +;
		"VV1_FABMOD, " +;
		"VV1_COMVEI, " +;
		"VV1_CHARED, " +;
		"VV1_IMOBI , " +;
		"VV1_SITVEI , " +;
		" CASE " +;
			" WHEN PEDMONT = 1 THEN '3'" +;
			" WHEN ATEND   = 1 THEN '4'" +;
			" WHEN BLOQ = 1 THEN '2'" +;
			" ELSE '1'" +;
		" END AS SITUACAO," +;
		oVC070SQL:CompatFunc("SUBSTR") + "(COLPEDIDO, 1, " + Str(nTamColPedidoRelacionado,3) + ") COLPEDIDO ," + ;
		oVC070SQL:CompatFunc("SUBSTR") + "(COLATEND, 1, " + Str(nTamColAtendRelacionado,3) + ") COLATEND ," + ;
		"COALESCE(DIAESTQ,0) DIAESTQ, " +;
		IIf(lDebug, "PEDMONT, ATEND, BLOQ, RESTEMP," , "" ) +;
		" 0 AS MARCADO ")

	cAuxCpoQuery := oVEConsVeicQuery:GetCamposQuery()
	oVEConsVeicQuery:SetCamposQuery(cAuxCpoQuery + ", VV1_CHARED, VV1_IMOBI, VV2_DESMOD")

Return

Function VC0700023_ConfigBrowse(oBrwStruConsVeic)
	oBrwStruConsVeic := OFBrowseStruct():New({"VV1", "VV2", "VVR"})

	oBrwStruConsVeic:AddField( "VV1_CODMAR" )
	oBrwStruConsVeic:AddField( "VE1_DESMAR" )
	oBrwStruConsVeic:AddField( "VV1_MODVEI" )
	oBrwStruConsVeic:AddField( "VV2_DESMOD" )
	oBrwStruConsVeic:AddField( "VV1_SEGMOD" )
	If lVV2OPCION
		oBrwStruConsVeic:AddField( "VV2_OPCION" )
		oBrwStruConsVeic:AddFieldManual( DMS_DataContainer():New( { { 'cIdField' , 'DESCOPCION' }, { 'cTitulo' , STR0004 }, { 'cTipo' , 'C' }, { 'nTamanho' , nTamDOpcional }, { 'nDecimal' , 0 }, { 'cPicture' , '@!' }} ) ) // 'Descr. Opcional' 
		oBrwStruConsVeic:AddField( "VV2_COREXT" )
		oBrwStruConsVeic:AddFieldManual( DMS_DataContainer():New( { { 'cIdField' , 'DESCCOREXT' }, { 'cTitulo' , STR0005 }, { 'cTipo' , 'C' }, { 'nTamanho' , nTamDCorExt }, { 'nDecimal' , 0 }, { 'cPicture' , '@!' }} ) ) // 'Descr. Cor Externa' 
		oBrwStruConsVeic:AddField( "VV2_CORINT" )
		oBrwStruConsVeic:AddFieldManual( DMS_DataContainer():New( { { 'cIdField' , 'DESCCORINT' }, { 'cTitulo' , STR0006 }, { 'cTipo' , 'C' }, { 'nTamanho' , nTamDCorInt }, { 'nDecimal' , 0 }, { 'cPicture' , '@!' }} ) ) // 'Descr. Cor Interna' 
	Endif
	oBrwStruConsVeic:AddField( "VV1_CHASSI" )
	oBrwStruConsVeic:AddField( "VV1_CHAINT" )
	oBrwStruConsVeic:AddField( "VV1_FABMOD" )
	oBrwStruConsVeic:AddField( "VV1_COMVEI" )
	oBrwStruConsVeic:AddField( "VV1_CHARED" )
	oBrwStruConsVeic:AddField( "VV1_IMOBI"  )
	oBrwStruConsVeic:AddField( "VV1_SITVEI" )
	oBrwStruConsVeic:AddFieldManual( DMS_DataContainer():New( {;
											{ 'cIdField' , 'SITUACAO' },;
											{ 'cTitulo' , STR0007 },; // 'Situação'
											{ 'cTipo' , 'C' },;
											{ 'nTamanho' , 1 },;
											{ 'nDecimal' , 0 },;
											{ 'cPicture' , '@!' },;
											{ 'aComboValues', {"1=DISPONÍVEL","2=BLOQUEADO","3=REL. PEDIDO","4=REL. ATENDIMENTO"} } } ) )
	oBrwStruConsVeic:AddFieldManual( DMS_DataContainer():New( {;
											{ 'cIdField' , 'COLPEDIDO' },;
											{ 'cTitulo' ,  STR0008 },; // 'Pedido Relacion.'
											{ 'cTipo' , 'C' },;
											{ 'nTamanho' , nTamColPedidoRelacionado },;
											{ 'nDecimal' , 0 },;
											{ 'cPicture' , '@!' } } ) )
	oBrwStruConsVeic:AddFieldManual( DMS_DataContainer():New( {;
											{ 'cIdField' , 'COLATEND' },;
											{ 'cTitulo' , STR0009 },; // 'Atend. Relacion.'
											{ 'cTipo' , 'C' },;
											{ 'nTamanho' , nTamColAtendRelacionado },;
											{ 'nDecimal' , 0 },;
											{ 'cPicture' , '@!' } } ) )
	oBrwStruConsVeic:AddFieldManual( DMS_DataContainer():New({;
											{ 'cIdField' , 'DIAESTQ' },;
											{ 'cTitulo' , STR0010  },; // 'Dias de Estoque'
											{ 'cTipo' , 'N' },;
											{ 'nTamanho' , 5 },;
											{ 'nDecimal' , 0 },;
											{ 'cPicture' , '@! 99999' } } ) )
	If lDebug // A parte dentro de LDEBUG nao precisa traduzir
		oBrwStruConsVeic:AddFieldManual( DMS_DataContainer():New( {;
												{ 'cIdField' , 'PEDMONT' },;
												{ 'cTitulo' , 'Ped. Montadora' },;
												{ 'cTipo' , 'N' },;
												{ 'nTamanho' , 1 },;
												{ 'nDecimal' , 0 } } ) )
		oBrwStruConsVeic:AddFieldManual( DMS_DataContainer():New( {;
												{ 'cIdField' , 'ATEND' },;
												{ 'cTitulo' , 'Atendimento' },;
												{ 'cTipo' , 'N' },;
												{ 'nTamanho' , 1 },;
												{ 'nDecimal' , 0 } } ) )
		oBrwStruConsVeic:AddFieldManual( DMS_DataContainer():New( {;
												{ 'cIdField' , 'BLOQ' },;
												{ 'cTitulo' , 'Bloqueado' },;
												{ 'cTipo' , 'N' },;
												{ 'nTamanho' , 1 },;
												{ 'nDecimal' , 0 } } ) )
		oBrwStruConsVeic:AddFieldManual( DMS_DataContainer():New( {;
												{ 'cIdField' , 'RESTEMP' },;
												{ 'cTitulo' , 'Reserva Temp.' },;
												{ 'cTipo' , 'N' },;
												{ 'nTamanho' , 1 },;
												{ 'nDecimal' , 0 } } ) )

	EndIf
	oBrwStruConsVeic:AddFieldManual( DMS_DataContainer():New({;
											{ 'cIdField' , 'MARCADO' },;
											{ 'cTitulo' , STR0011 },; // 'Marcado'
											{ 'cTipo' , 'N' },;
											{ 'nTamanho' , 1 },;
											{ 'nDecimal' , 0 },;
											{ 'cPicture' , '@! 9' } } ) , .f. )

	oBrwStruConsVeic:CriaTabTmp()

Return

Function VC0700143_AtuBrowseConsulta(lParFiltro)

	Local cSQL

	// ------------------------------------------------------------------------------------------------------------------
	cSQL := "SELECT VV1_CODMAR, VE1_DESMAR, VV1_MODVEI, VV2_DESMOD, VV1_SEGMOD, " +;
		IIf( lVV2OPCION , "VV2_OPCION, DESCOPCION, VV2_COREXT, DESCCOREXT, VV2_CORINT, DESCCORINT, " , "" ) +;
		"VV1_CHASSI, VV1_CHAINT, VV1_FABMOD, VV1_COMVEI, VV1_CHARED, VV1_IMOBI, " +;
		"VV1_SITVEI, SITUACAO, COLPEDIDO, COLATEND, DIAESTQ," +;
		IIf(lDebug, "PEDMONT, ATEND, BLOQ, RESTEMP," , "" ) +;
		"MARCADO " +;
		 " FROM " + oTabConsVeiculo:GetRealName()
	If lParFiltro
		cSQL += " WHERE MARCADO = 1"
	EndIf
	// ------------------------------------------------------------------------------------------------------------------
	oBrwStruConsVeic:LoadData( cSQL , .t. )
	// ------------------------------------------------------------------------------------------------------------------

	// ------------------------------------------------------------------------------------------------------------------
	dbSelectArea(oBrwStruConsVeic:GetAlias())
	dbGoTop()
	// ------------------------------------------------------------------------------------------------------------------

	// ------------------------------------------------------------------------------------------------------------------

Return

Static Function VC0700213_CriaTabConsulta()
	oTabConsVeiculo := OFDMSTempTable():New()
	oTabConsVeiculo:SetVetCampos(oBrwStruConsVeic:GetColTabTMP())
	oTabConsVeiculo:CreateTable()
	cNomeTabConsulta := oTabConsVeiculo:GetRealName()
Return

Static Function VC0700223_AtuTabConsulta()
	oTabConsVeiculo:ClearTable()
	oTabConsVeiculo:InsertSQL( oVEConsVeicQuery:GetQuery() )
	VC0700133_AtuTabResumo()
Return


Static Function ModelDef()
	Local oModel

	Local oPrinStru
	Local oModMarca
	Local oModModelo
	Local oModOpcional
	Local oModCorExterna
	Local oModCorInterna
	Local oModAnoFabMod
	Local oModSituacao
	Local oModImobilizado
	Local oModSitVei
	Local oModEvento

	If Type("oPrincipal") == "U"
		VC0700293_CriaVariaveis()
	EndIf

	oPrinStru  := oPrincipal:GetModel()

	oModMarca      := oDMSStr01_Marca:GetModel()
	oModModelo     := oDMSStr02_Modelo:GetModel()
	oModOpcional   := oDMSStr03_Opcional:GetModel()
	oModCorExterna := oDMSStr04_CorExterna:GetModel()
	oModCorInterna := oDMSStr05_CorInterna:GetModel()
	oModAnoFabMod  := oDMSStr06_AnoFabMod:GetModel()
	oModSituacao   := oDMSStr07_Situacao:GetModel()
	oModImobilizado:= oDMSStr10_Imobilizado:GetModel()
	oModSitVei     := oDMSStr08_SitVei:GetModel()
	oModEvento     := oDMSStr09_Evento:GetModel()

	oModel := MPFormModel():New( 'VEIC070', /* bPre */, /* bPost */ , { || .t. } /* bCommit */ , { || .T. } /* bCancel */ )
	oModel:AddFields('PARMASTER', /* cOwner */ , oPrinStru, /* <bPre> */ , /* <bPost> */ , /* <bLoad> */ { || } )

	oModel:AddGrid('LISTA_MARCA'      ,'PARMASTER', oModMarca      , /* <bLinePre > */ , /* <bLinePost > */ , /* <bPre > */ , /* <bLinePost > */, /* <bLoad> */ )
	oModel:AddGrid('LISTA_MODELO'     ,'PARMASTER', oModModelo     , /* <bLinePre > */ , /* <bLinePost > */ , /* <bPre > */ , /* <bLinePost > */, /* <bLoad> */ )
	If lVV2OPCION
		oModel:AddGrid('LISTA_OPCIONAL'   ,'PARMASTER', oModOpcional   , /* <bLinePre > */ , /* <bLinePost > */ , /* <bPre > */ , /* <bLinePost > */, /* <bLoad> */ )
		oModel:AddGrid('LISTA_COREXTERNA' ,'PARMASTER', oModCorExterna , /* <bLinePre > */ , /* <bLinePost > */ , /* <bPre > */ , /* <bLinePost > */, /* <bLoad> */ )
		oModel:AddGrid('LISTA_CORINTERNA' ,'PARMASTER', oModCorInterna , /* <bLinePre > */ , /* <bLinePost > */ , /* <bPre > */ , /* <bLinePost > */, /* <bLoad> */ )
	EndIf
	oModel:AddGrid('LISTA_ANOFABMOD'  ,'PARMASTER', oModAnoFabMod  , /* <bLinePre > */ , /* <bLinePost > */ , /* <bPre > */ , /* <bLinePost > */, /* <bLoad> */ )
	oModel:AddGrid('LISTA_SITUACAO'   ,'PARMASTER', oModSituacao   , /* <bLinePre > */ , /* <bLinePost > */ , /* <bPre > */ , /* <bLinePost > */, /* <bLoad> */ )
	oModel:AddGrid('LISTA_IMOBILIZADO','PARMASTER', oModImobilizado, /* <bLinePre > */ , /* <bLinePost > */ , /* <bPre > */ , /* <bLinePost > */, /* <bLoad> */ )
	oModel:AddGrid('LISTA_SITVEI'    ,'PARMASTER', oModSitVei     , /* <bLinePre > */ , /* <bLinePost > */ , /* <bPre > */ , /* <bLinePost > */, /* <bLoad> */ )
	If lExistVJR
		oModel:AddGrid('LISTA_EVENTO'    ,'PARMASTER', oModEvento     , /* <bLinePre > */ , /* <bLinePost > */ , /* <bPre > */ , /* <bLinePost > */, /* <bLoad> */ )
	EndIf

	oModel:SetDescription(STR0012) // 'Consulta de Estoque de Veículos'
	oModel:GetModel('PARMASTER'        ):SetDescription(STR0013) // 'Lista de Parâmetros'
	oModel:GetModel('LISTA_MARCA'      ):SetDescription(STR0014) // 'Lista de Marcas'
	oModel:GetModel('LISTA_MODELO'     ):SetDescription(STR0015) // 'Lista de Modelos'
	If lVV2OPCION
		oModel:GetModel('LISTA_OPCIONAL'   ):SetDescription(STR0016) // 'Lista de Opcionais'
		oModel:GetModel('LISTA_COREXTERNA' ):SetDescription(STR0017) // 'Lista de Cor Externa'
		oModel:GetModel('LISTA_CORINTERNA' ):SetDescription(STR0018) // 'Lista de Cor Interna'
	EndIf
	oModel:GetModel('LISTA_ANOFABMOD'  ):SetDescription(STR0019) // 'Lista de Ano de Fabricação e Modelo'
	oModel:GetModel('LISTA_SITUACAO'   ):SetDescription(STR0020) // 'Lista de Situação'
	oModel:GetModel('LISTA_IMOBILIZADO'):SetDescription(STR0021) // 'Lista de Imobilizado'
	oModel:GetModel('LISTA_SITVEI'    ):SetDescription('Lista de ')
	If lExistVJR
		oModel:GetModel('LISTA_EVENTO'    ):SetDescription('Lista de ')
	EndIf

	oModel:GetModel('LISTA_MARCA'      ):SetOnlyQuery( .T. )
	oModel:GetModel('LISTA_MODELO'     ):SetOnlyQuery( .T. )
	If lVV2OPCION
		oModel:GetModel('LISTA_OPCIONAL'   ):SetOnlyQuery( .T. )
		oModel:GetModel('LISTA_COREXTERNA' ):SetOnlyQuery( .T. )
		oModel:GetModel('LISTA_CORINTERNA' ):SetOnlyQuery( .T. )
	EndIf
	oModel:GetModel('LISTA_ANOFABMOD'  ):SetOnlyQuery( .T. )
	oModel:GetModel('LISTA_SITUACAO'   ):SetOnlyQuery( .T. )
	oModel:GetModel('LISTA_IMOBILIZADO'):SetOnlyQuery( .T. )
	oModel:GetModel('LISTA_SITVEI'    ):SetOnlyQuery( .T. )
	If lExistVJR
		oModel:GetModel('LISTA_EVENTO'    ):SetOnlyQuery( .T. )
	EndIf
	
	oModel:SetPrimaryKey({})

	oAuxEvDev := VEIC070EVDEF():New()
	oAuxEvDev:SetOpcionalCampoFiltro( IIf( lOpcionalFiltroDetalhado , "VV2_OPCION" , "DESCOPCION" ) )
	oAuxEvDev:SetCorExternaCampoFiltro( IIf( lCorExternaFiltroDetalhado , "VV2_COREXT" , "DESCCOREXT" ) )
	oAuxEvDev:SetCorInternaCampoFiltro( IIf( lCorInternaFiltroDetalhado , "VV2_CORINT" , "DESCCORINT" ) )

	//oAuxLogEV := MVCLogEv():New("VEIC070")
	//oModel:InstallEvent("LOG",,oAuxLogEV)
	oModel:InstallEvent("PADRAO",,oAuxEvDev)


Return oModel

Static Function ViewDef()

	Local oModel	:= FWLoadModel( 'VEIC070' )
	Local oView 	:= Nil

	//Local oPrinStru  := oPrincipal:GetView()

	Local oModMarca      := oDMSStr01_Marca:GetView()
	Local oModModelo     := oDMSStr02_Modelo:GetView()
	Local oModOpcional   := oDMSStr03_Opcional:GetView()
	Local oModCorExterna := oDMSStr04_CorExterna:GetView()
	Local oModCorInterna := oDMSStr05_CorInterna:GetView()
	Local oModAnoFabMod  := oDMSStr06_AnoFabMod:GetView()
	Local oModSituacao   := oDMSStr07_Situacao:GetView()
	Local oModImobilizado   := oDMSStr10_Imobilizado:GetView()

	oView := FWFormView():New()
	oView:SetModel(oModel)
	//oView:AddField('FORM_PARAM', oPrinStru , 'PARMASTER')

	oView:AddGrid('GRID_LISTA_MARCA'        , oModMarca       , 'LISTA_MARCA' )
	oView:AddGrid('GRID_LISTA_MODELO'       , oModModelo      , 'LISTA_MODELO' )
	If lVV2OPCION
		oView:AddGrid('GRID_LISTA_OPCIONAL'     , oModOpcional    , 'LISTA_OPCIONAL' )
		oView:AddGrid('GRID_LISTA_COREXTERNA'   , oModCorExterna  , 'LISTA_COREXTERNA' )
		oView:AddGrid('GRID_LISTA_CORINTERNA'   , oModCorInterna  , 'LISTA_CORINTERNA' )
	Endif
	oView:AddGrid('GRID_LISTA_ANOFABMOD'    , oModAnoFabMod   , 'LISTA_ANOFABMOD' )
	oView:AddGrid('GRID_LISTA_SITUACAO'     , oModSituacao    , 'LISTA_SITUACAO' )
	oView:AddGrid('GRID_LISTA_IMOBILIZADO' , oModImobilizado , 'LISTA_IMOBILIZADO' )

	oView:AddOtherObject('BROWSE', { |oPanel| VC0700103_CriaBrowseEstoque(oPanel) })
	oView:AddOtherObject('BROWSE_RES', { |oPanel| VC0700363_CriaBrowseEstoqueResumo(oPanel) })

	oView:CreateFolder('FOLDER')
	oView:AddSheet('FOLDER', 'ABA_PARAMETROS', STR0022 ) // 'Parâmetros de Filtro'
	oView:AddSheet('FOLDER', 'ABA_RESUMO'    , STR0023 ) // 'Resumo'
	oView:AddSheet('FOLDER', 'ABA_BROWSE'    , STR0024 ) // 'Estoque'

	oView:CreateHorizontalBox('TELA_PARAM_LINHA_1', 100,,   ,'FOLDER','ABA_PARAMETROS')
	oView:CreateHorizontalBox('TELA_PARAM_LINHA_2', 190,,.t.,'FOLDER','ABA_PARAMETROS')

	oView:CreateHorizontalBox('TELA_RESUMO' ,100,,,'FOLDER','ABA_RESUMO')

	oView:CreateHorizontalBox('TELA_BROWSE' ,100,,,'FOLDER','ABA_BROWSE')

	   //:createVerticalBox(<cID >, <nPercHeight >, <cIdOwner >, <lFixPixel >, <cIDFolder >, <cIDSheet >)-
	oView:createVerticalBox('TELA_MARCA'      , 250 , 'TELA_PARAM_LINHA_1' , .T. , 'FOLDER' , 'ABA_PARAMETROS' )
	oView:createVerticalBox('TELA_MODELO'     , 100 , 'TELA_PARAM_LINHA_1' , .F. , 'FOLDER' , 'ABA_PARAMETROS' )
	If lVV2OPCION
		oView:createVerticalBox('TELA_OPCIONAL'   , 300 , 'TELA_PARAM_LINHA_1' , .T. , 'FOLDER' , 'ABA_PARAMETROS' )
	EndIf
	
	If lVV2OPCION
		oView:createVerticalBox('TELA_COREXTERNA'  , 050 , 'TELA_PARAM_LINHA_2' , .F. , 'FOLDER' , 'ABA_PARAMETROS' )
		oView:createVerticalBox('TELA_CORINTERNA'  , 050 , 'TELA_PARAM_LINHA_2' , .F. , 'FOLDER' , 'ABA_PARAMETROS' )
		oView:createVerticalBox('TELA_ANOFABMOD'   , 170 , 'TELA_PARAM_LINHA_2' , .T. , 'FOLDER' , 'ABA_PARAMETROS' )
		oView:createVerticalBox('TELA_SITUACAO'    , 210 , 'TELA_PARAM_LINHA_2' , .T. , 'FOLDER' , 'ABA_PARAMETROS' )
		oView:createVerticalBox('TELA_IMOBILIZADO' , 210 , 'TELA_PARAM_LINHA_2' , .T. , 'FOLDER' , 'ABA_PARAMETROS' )
	Else
		oView:createVerticalBox('TELA_ANOFABMOD'   , 170 , 'TELA_PARAM_LINHA_2' , .T. , 'FOLDER' , 'ABA_PARAMETROS' )
		oView:createVerticalBox('TELA_SITUACAO'    , 050 , 'TELA_PARAM_LINHA_2' , .F. , 'FOLDER' , 'ABA_PARAMETROS' )
		oView:createVerticalBox('TELA_IMOBILIZADO' , 050 , 'TELA_PARAM_LINHA_2' , .F. , 'FOLDER' , 'ABA_PARAMETROS' )
	EndIf

	//oView:createVerticalBox('TELA_RES_PARAM'   , 200 , 'TELA_RESUMO'  , .T. , 'FOLDER' , 'ABA_RESUMO' )
	oView:createVerticalBox('TELA_RES_BROWSE'  , 100 , 'TELA_RESUMO'  , .F. , 'FOLDER' , 'ABA_RESUMO' )

	oView:SetOwnerView( 'GRID_LISTA_MARCA'     , 'TELA_MARCA' )
	oView:SetOwnerView( 'GRID_LISTA_MODELO'    , 'TELA_MODELO' )
	If lVV2OPCION
		oView:SetOwnerView( 'GRID_LISTA_OPCIONAL'  , 'TELA_OPCIONAL' )
		oView:SetOwnerView( 'GRID_LISTA_COREXTERNA', 'TELA_COREXTERNA' )
		oView:SetOwnerView( 'GRID_LISTA_CORINTERNA', 'TELA_CORINTERNA' )
	EndIf
	oView:SetOwnerView( 'GRID_LISTA_ANOFABMOD' , 'TELA_ANOFABMOD' )
	oView:SetOwnerView( 'GRID_LISTA_SITUACAO'  , 'TELA_SITUACAO' )
	oView:SetOwnerView( 'GRID_LISTA_IMOBILIZADO'  , 'TELA_IMOBILIZADO' )

	oView:EnableTitleView( 'GRID_LISTA_MARCA'       , STR0025 ) // 'Marca' 
	oView:EnableTitleView( 'GRID_LISTA_MODELO'      , STR0026 ) // 'Modelo' 
	If lVV2OPCION
		oView:EnableTitleView( 'GRID_LISTA_OPCIONAL'    , STR0027 ) // 'Opcional' 
		oView:EnableTitleView( 'GRID_LISTA_COREXTERNA'  , STR0028 ) // 'Cor Externa' 
		oView:EnableTitleView( 'GRID_LISTA_CORINTERNA'  , STR0029 ) // 'Cor Interna' 
	EndIf
	oView:EnableTitleView( 'GRID_LISTA_ANOFABMOD'   , STR0030 ) // 'Ano Fab./Mod.' 
	oView:EnableTitleView( 'GRID_LISTA_SITUACAO'    , STR0031 ) // 'Situação' 
	oView:EnableTitleView( 'GRID_LISTA_IMOBILIZADO' , STR0032 ) // 'Imobilizado' 

	oView:SetOwnerView( 'BROWSE' , 'TELA_BROWSE' )

	oView:SetOwnerView( 'BROWSE_RES' , 'TELA_RES_BROWSE' )

	VC0700463_ConfiguraView(oView)
	oView:SetCloseOnOk( { || .F. })

	oView:SetVldFolder({ |cFolderID, nOldSheet, nSelSheet | VC0700283_ChangeFolder(cFolderID, nOldSheet, nSelSheet) })

Return oView


//Static Function MenuDef()
//	Local aRotina := {}
//	//ADD OPTION aRotina TITLE 'Parametros'             ACTION 'VC070_Param' OPERATION 4 ACCESS 0
//	ADD OPTION aRotina TITLE 'Parâmetros'             ACTION 'VC0700033_Param' OPERATION 3 ACCESS 0
//Return aRotina

/*/{Protheus.doc} VC0700043_Marca
	(long_description)
	@type  Static Function
	@author Rubens
	@since 12/07/2019
	@version 1.0
	@return oRetorno, OFDMSStruct, Struct
	/*/
Static Function VC0700043_Marca()
	Local oRetorno := OFDMSStruct():New()

	oRetorno:AddSelect('','SELMARCA', , .t.)
	oRetorno:AddFieldDictionary( "VE1", "VE1_CODMAR" , { {"cIdField" , "MARCACODMAR"} , { "lVirtual", .t. } , { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "VE1", "VE1_DESMAR" , { {"cIdField" , "MARCADESMAR"} , { "lVirtual", .t. } , { "lCanChange" , .f. } } )

Return oRetorno

/*/{Protheus.doc} VC0700053_Modelo
	(long_description)
	@type  Static Function
	@author Rubens
	@since 12/07/2019
	@version 1.0
	@return oRetorno, OFDMSStruct, Struct
	/*/
Static Function VC0700053_Modelo()
	Local oRetorno := OFDMSStruct():New()

	oRetorno:AddSelect('','SELMODELO', , .t.)
	oRetorno:AddFieldDictionary( "VV1", "VV1_MODVEI" , { {"cIdField" , "MODMODVEI"} , { "lVirtual", .t. } , { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "VV2", "VV2_DESMOD" , { {"cIdField" , "MODDESMOD"} , { "lVirtual", .t. } , { "lCanChange" , .f. } } )

Return oRetorno

/*/{Protheus.doc} VC0700063_Opcional
	(long_description)
	@type  Static Function
	@author Rubens
	@since 12/07/2019
	@version 1.0
	@return oRetorno, OFDMSStruct, Struct
	/*/
Static Function VC0700063_Opcional()
	Local oRetorno := OFDMSStruct():New()

	oRetorno:AddSelect('','SELOPCIONAL', , .t.)
	If lVV2OPCION
		If lOpcionalFiltroDetalhado
			oRetorno:AddFieldDictionary( "VV2", "VV2_OPCION" , { {"cIdField" , "MODOPCION"} , { "lVirtual", .t. } , { "lCanChange" , .f. } } )
			oRetorno:AddFieldDictionary( "VX5", "VX5_DESCRI" , { {"cIdField" , "DESCOPCION"} , { "nTamanho", nTamDOpcional } , { "lVirtual", .t. } , { "lCanChange" , .f. } } )
		Else
			oRetorno:AddFieldDictionary( "VV2", "VV2_OPCION" , { {"cIdField" , "MODOPCION"} , { "nTamanho", nTamDOpcional } , { "lVirtual", .t. } , { "lCanChange" , .f. } } )
		EndIf
	Endif
Return oRetorno

/*/{Protheus.doc} VC0700073_CorExterna
	(long_description)
	@type  Static Function
	@author Rubens
	@since 12/07/2019
	@version 1.0
	@return oRetorno, OFDMSStruct, Struct
	/*/
Static Function VC0700073_CorExterna()
	Local oRetorno := OFDMSStruct():New()

	oRetorno:AddSelect('','SELCOREXT', , .t.)
	If lVV2OPCION
		If lCorExternaFiltroDetalhado
			oRetorno:AddFieldDictionary( "VV2", "VV2_COREXT" , { {"cIdField" , "MODCOREXT"} , { "lVirtual", .t. } , { "lCanChange" , .f. } } )
			oRetorno:AddFieldDictionary( "VX5", "VX5_DESCRI" , { {"cIdField" , "DESCCOREXT"} , {"nTamanho", nTamDCorExt } , { "lVirtual", .t. } , { "lCanChange" , .f. } } )
		Else
			oRetorno:AddFieldDictionary( "VV2", "VV2_COREXT" , { {"cIdField" , "MODCOREXT"} , {"nTamanho", nTamDCorExt } , { "lVirtual", .t. } , { "lCanChange" , .f. } } )
		EndIf
	EndIf

Return oRetorno

/*/{Protheus.doc} VC0700083_CorInterna
	(long_description)
	@type  Static Function
	@author Rubens
	@since 12/07/2019
	@version 1.0
	@return oRetorno, OFDMSStruct, Struct
	/*/
Static Function VC0700083_CorInterna()
	Local oRetorno := OFDMSStruct():New()

	oRetorno:AddSelect('','SELCORINT', , .t.)
	If lVV2OPCION
		If lCorInternaFiltroDetalhado
			oRetorno:AddFieldDictionary( "VV2", "VV2_CORINT" , { {"cIdField" , "MODCORINT"} , { "lVirtual", .t. } , { "lCanChange" , .f. } } )
			oRetorno:AddFieldDictionary( "VX5", "VX5_DESCRI" , { {"cIdField" , "DESCCORINT"} , { "nTamanho" , nTamDCorInt } , { "lVirtual", .t. } , { "lCanChange" , .f. } } )
		Else
			oRetorno:AddFieldDictionary( "VV2", "VV2_CORINT" , { {"cIdField" , "MODCORINT"} , { "nTamanho" , nTamDCorInt } , { "lVirtual", .t. } , { "lCanChange" , .f. } } )
		EndIf
	EndIf

Return oRetorno

/*/{Protheus.doc} VC0700093_AnoFabMod
	(long_description)
	@type  Static Function
	@author Rubens
	@since 12/07/2019
	@version 1.0
	@return oRetorno, OFDMSStruct, Struct
	/*/
Static Function VC0700093_AnoFabMod()
	Local oRetorno := OFDMSStruct():New()

	oRetorno:AddSelect('','SELFABMOD', , .t.)
	oRetorno:AddFieldDictionary( "VV1", "VV1_FABMOD" , { {"cIdField" , "MODFABMOD"} , { "lVirtual", .t. } , { "lCanChange" , .f. } } )

Return oRetorno

Static Function VC0700253_Situacao()
	Local oRetorno := OFDMSStruct():New()

	oRetorno:AddSelect('','SELSITUAC', , .t.)
	oRetorno:AddField( {;
							{ 'cIdField' , 'SITUACAO' },;
							{ 'cTitulo' , STR0033 },; // 'Situação'
							{ 'cTipo' , 'C' },;
							{ 'nTamanho' , 1 },;
							{ 'nDecimal' , 0 },;
							{ 'cPicture' , '@!' },;
							{ 'aComboValues', {"1=" + STR0034 , "2=" + STR0035 , "3=" + STR0036 , "4=" + STR0037} },; // "1=DISPONÍVEL" / "2=BLOQUEADO" / "3=EM PEDIDO" / "4=EM ATENDIMENTO"
							{ "lVirtual" , .t. },;
							{ "lCanChange" , .f. } } )

Return oRetorno


/*/{Protheus.doc} VC0700413_Imobilizado
	(long_description)
	@type  Static Function
	@author Rubens
	@since 12/07/2019
	@version 1.0
	@return oRetorno, OFDMSStruct, Struct
	/*/
Static Function VC0700413_Imobilizado()
	Local oRetorno := OFDMSStruct():New()

	oRetorno:AddSelect('','SELIMOB', , .t.)
	oRetorno:AddFieldDictionary( "VV1", "VV1_IMOBI" , { {"cIdField" , "VEICIMOB"} , { "lVirtual", .t. } , { "lCanChange" , .f. } } )

Return oRetorno


Function VC0700103_CriaBrowse(oPanel, cDescript)

	Default cDescript := STR0001

	// Cria um Form Browse
	oBrwVC070 := FWmBrowse():New()

	oBrwStruConsVeic:SetBrwOwner(oBrwVC070)

	//oBrwVC070:SetTemporary(.T.)
	oBrwVC070:AddButton(STR0038,{ || VC0700393_PlanilhaEstoque() } ) // "Gerar Planilha"

	oBrwVC070:SetUseFilter( .T. ) 
	oBrwVC070:SetDescription(STR0024) // 'Estoque'

	oBrwVC070:SetUseFilter()
	oBrwVC070:SetWalkThru(.F.)
	oBrwVC070:SetAmbiente(.F.)
	oBrwVC070:DisableDetails()

	oBrwVC070:SetSeek(.T.,oBrwStruConsVeic:GetSeek())

	oBrwVC070:SetFieldFilter(oBrwStruConsVeic:_aColFilter)

	oBrwVC070:SetQueryIndex(oBrwStruConsVeic:_aIndex)

	oBrwStruConsVeic:AddBrwColumn()

	oBrwVC070:SetAlias(oBrwStruConsVeic:GetAlias())

	oBrwVC070:SetOwner(oPanel)
	oBrwVC070:Activate()

Return

Static Function VC0700393_PlanilhaEstoque()

	Local oExcel
	Local aAuxLinha
	Local nQtdCol
	Local nLoopRec
	Local nPosCol

	If oBrwVC070:LogicLen() <= 0
		Return .t.
	EndIf

	Pergunte("VEIC070",.t.)

	oExcel := FWMSEXCEL():New()
	oExcel:AddworkSheet("Estoque") //
	oExcel:AddTable("Estoque","Estoque") //

	nQtdCol := Len(oBrwVC070:aColumns)
	For nPosCol := 1 to nQtdCol
		oExcel:AddColumn( "Estoque" , "Estoque" , oBrwVC070:GetColumn(nPosCol):GetTitle() , 1 , 1 , .f. )
	Next nPosCol

	oBrwVC070:GoTop()
	nUlRec := oBrwVC070:LogicLen()
	nCurrRec := oBrwVC070:At()
	While .T.
		nLoopRec := oBrwVC070:At()

		aAuxLinha := Array(nQtdCol)
		For nPosCol := 1 to nQtdCol
			aAuxLinha[nPosCol] := oBrwVC070:GetColumnData(nPosCol)
		Next nPosCol

		oExcel:AddRow("Estoque","Estoque",aAuxLinha) // Peças / Peças

		oBrwVC070:GoDown()
		If nLoopRec == oBrwVC070:At()
			Exit
		EndIf
	End

	oExcel:Activate()

	oExcel:GetXMLFile(AllTrim(MV_PAR01))
	oExcel:DeActivate()

	oBrwVC070:GoTo( nCurrRec, .T. )

	MsgInfo(STR0039) // "Arquivo Gerado."

Return


Static Function VC0700113_CriaTabResumo()

	Local aAuxCpoDic := {}

	VC0700123_AddTabStru( @aAuxCpoDic, "VV1", "VV1_CODMAR/VV1_MODVEI/VV1_SEGMOD/VV1_FABMOD/VV1_SITVEI/VV1_IMOBI /" )
	VC0700123_AddTabStru( @aAuxCpoDic, "VV2", "VV2_DESMOD/VV2_OPCION/VV2_COREXT/VV2_CORINT/" )
	VC0700123_AddTabStru( @aAuxCpoDic, "VE1", "VE1_DESMAR/" )
	VC0700123_AddTabStru( @aAuxCpoDic, "VJR", "VJR_EVENTO/" )
	VC0700123_AddTabStru( @aAuxCpoDic, "VX5", "VX5_CHAVE /VX5_CODIGO/VX5_DESCRI/" )

	VC0700233_ConfigTempTable( @oTResumo , aAuxCpoDic , aCpoTResumo )
	VC0700233_ConfigTempTable( @oTResMarca , aAuxCpoDic , { "VV1_CODMAR","VE1_DESMAR" })
	VC0700233_ConfigTempTable( @oTResModelo , aAuxCpoDic , { "VV1_MODVEI","VV2_DESMOD" })
	VC0700233_ConfigTempTable( @oTResOpcional , aAuxCpoDic , { "VV2_OPCION" }, {{"DESCOPCION","C",nTamDOpcional,0}} )
	VC0700233_ConfigTempTable( @oTResCorExt , aAuxCpoDic , { "VV2_COREXT" }, {{"DESCCOREXT","C",nTamDCorExt,0}} )
	VC0700233_ConfigTempTable( @oTResCorInt , aAuxCpoDic , { "VV2_CORINT" }, {{"DESCCORINT","C",nTamDCorInt,0}} )
	VC0700233_ConfigTempTable( @oTResAnoFabMod , aAuxCpoDic , { "VV1_FABMOD" })
	VC0700233_ConfigTempTable( @oTResSituacao , , , {{"SITUACAO","C",1,0}} )
	VC0700233_ConfigTempTable( @oTResImobilizado , aAuxCpoDic , { "VV1_IMOBI" })
	VC0700233_ConfigTempTable( @oTResSitVei , aAuxCpoDic , { "VV1_SITVEI" } )

	If lExistVJR
		VC0700233_ConfigTempTable( @oTResEvento , aAuxCpoDic , { "VJR_EVENTO" } )
	EndIf

Return

Static Function VC0700123_AddTabStru(aAuxCpoDic, cTabela, cCampos)
	Local aAuxStru := FWFormStruct(3, cTabela , { |x| AllTrim(x) $ cCampos }, .f. )
	Local nPosAuxStru

	For nPosAuxStru := 1 to Len(aAuxStru[FORM_STRUCT_TABLE_MODEL])
		AADD(aAuxCpoDic, { ;
			aAuxStru[ FORM_STRUCT_TABLE_MODEL ][ nPosAuxStru ][ MVC_MODEL_IDFIELD ] ,;
			aAuxStru[ FORM_STRUCT_TABLE_MODEL ][ nPosAuxStru ][ MVC_MODEL_TIPO ] ,;
			aAuxStru[ FORM_STRUCT_TABLE_MODEL ][ nPosAuxStru ][ MVC_MODEL_TAMANHO ] ,;
			aAuxStru[ FORM_STRUCT_TABLE_MODEL ][ nPosAuxStru ][ MVC_MODEL_DECIMAL ]  ;
		 } )
	Next nPosAuxStru

Return

Static FUNCTION VC0700233_ConfigTempTable(oAuxObjTT, aAuxCpoDic, aParCampos , aAuxStru )

	Local nPos
	Local nPosCpos
	Local aCpoTab := {}
	Local cAuxCpo

	Default aParCampos := {}
	Default aAuxStru := {}

	For nPos := 1 to Len(aParCampos)
		cAuxCpo := aParCampos[nPos]
		nPosCpos := aScan(aAuxCpoDic, { |x| x[1] == cAuxCpo })
		If nPosCpos <> 0
			AADD( aCpoTab , aAuxCpoDic[nPosCpos] )
		EndIf
	Next nPos
	For nPos := 1 to Len(aAuxStru)
		AADD( aCpoTab , aAuxStru[nPos] )
	Next nPos


	AADD(aCpoTab, { "MARCADO" ,"N" ,1 ,0  } )

	oAuxObjTT := OFDMSTempTable():New()
	oAuxObjTT:aVetCampos := aCpoTab
	oAuxObjTT:CreateTable()

Return

Static Function VC0700133_AtuTabResumo()
	VC0700243_ExecAtuTabResumo( @oTResumo )
	VC0700243_ExecAtuTabResumo( @oTResMarca )
	VC0700243_ExecAtuTabResumo( @oTResModelo )
	If lVV2OPCION
		VC0700243_ExecAtuTabResumo( @oTResOpcional )
		VC0700243_ExecAtuTabResumo( @oTResCorExt )
		VC0700243_ExecAtuTabResumo( @oTResCorInt )
	EndIf
	VC0700243_ExecAtuTabResumo( @oTResAnoFabMod )
	VC0700243_ExecAtuTabResumo( @oTResSituacao )
	VC0700243_ExecAtuTabResumo( @oTResImobilizado )
	VC0700243_ExecAtuTabResumo( @oTResSitVei )
	If lExistVJR .and. oVEConsVeicQuery:GetPedCompra()
		VC0700243_ExecAtuTabResumo( @oTResEvento )
	EndIf
Return

Static Function VC0700243_ExecAtuTabResumo(oAuxObjTT)

	Local cSQL
	Local nPos

	cSQL := "SELECT DISTINCT "
	For nPos := 1 to Len(oAuxObjTT:aVetCampos) - 1 // Nao considera ultimo campo, pois é um campo criado manualmente
		cSQL += oAuxObjTT:aVetCampos[npos,1] + ","
	Next nPos
	cSQL += " 0 AS MARCADO FROM " + cNomeTabConsulta // oTabConsVeiculo:GetRealName()

	oAuxObjTT:ClearTable()
	oAuxObjTT:InsertSQL(cSQL)

Return

Static Function VC0700323_LimpaGridResumo(lClear, oAuxGrid)
	oAuxGrid:SetNoInsertLine(.F.)
	If lClear .and. oAuxGrid:CanClearData()
		oAuxGrid:ClearData(.T., .T. )
		oAuxGrid:GoLine(1)
	EndIf
Return

Static Function VC0700333_TravaGridResumo(oAuxGrid)
	oAuxGrid:SetNoInsertLine(.T.)
	oAuxGrid:SetLine(1)
	dbSelectArea("VV1")
Return

Static Function VC0700153_AtualizaGridMarcas(oModel, lClear)

	Local oMGrid
	Local cAls := "TMARCA"
	Local cSQL

	Default oModel := FWModelActive()

	oMGrid	:= oModel:GetModel("LISTA_MARCA")

	cSQL := "SELECT * FROM " + oTResMarca:GetRealName() + " ORDER BY VE1_DESMAR"
	dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cSQL) , cAls , .T. , .F.)

	VC0700323_LimpaGridResumo(lClear, @oMGrid)

	While ! (cAls)->(Eof())
		If oMGrid:CanInsertLine()
			oMGrid:AddLine()
		EndIf
		oMGrid:LoadValue("SELMARCA" , ((cAls)->MARCADO == 1)  , .t. )
		oMGrid:LoadValue("MARCACODMAR" , (cAls)->VV1_CODMAR , .t. )
		oMGrid:LoadValue("MARCADESMAR" , (cAls)->VE1_DESMAR , .t. )

		(cAls)->(dbSkip())
	End
	(cAls)->(dbCloseArea())

	VC0700333_TravaGridResumo(oMGrid)

Return .t.


Static Function VC0700163_AtualizaGridModelos(oModel, lClear)

	Local oMGrid
	Local cAls := "TMODELO"
	Local cSQL

	Default oModel := FWModelActive()

	oMGrid	:= oModel:GetModel("LISTA_MODELO")

	cSQL := "SELECT * FROM " + oTResModelo:GetRealName() + "  ORDER BY VV2_DESMOD"
	dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cSQL) , cAls , .T. , .F.)

	VC0700323_LimpaGridResumo(lClear, @oMGrid)
	While ! (cAls)->(Eof())
		oMGrid:AddLine()
		oMGrid:LoadValue("SELMODELO" , ((cAls)->MARCADO == 1)  , .t. )
		oMGrid:LoadValue("MODMODVEI" , (cAls)->VV1_MODVEI , .t. )
		oMGrid:LoadValue("MODDESMOD" , (cAls)->VV2_DESMOD , .t. )

		(cAls)->(dbSkip())
	End
	(cAls)->(dbCloseArea())

	VC0700333_TravaGridResumo(@oMGrid)

Return .t.

Static Function VC0700173_AtualizaGridOpcionais(oModel, lClear)

	Local oMGrid
	Local cAls := "TOPC"
	Local cSQL

	Default oModel := FWModelActive()

	oMGrid	:= oModel:GetModel("LISTA_OPCIONAL")

	cSQL := "SELECT DISTINCT " + IIf( lOpcionalFiltroDetalhado , "VV2_OPCION, " , "" ) + "DESCOPCION, MARCADO FROM " + oTResOpcional:GetRealName() + " ORDER BY 1"
	dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cSQL) , cAls , .T. , .F.)

	VC0700323_LimpaGridResumo(lClear, @oMGrid)
	While ! (cAls)->(Eof())

		oMGrid:AddLine()
		oMGrid:LoadValue("SELOPCIONAL" , ((cAls)->MARCADO == 1)  , .t. )
		If lOpcionalFiltroDetalhado
			oMGrid:LoadValue("MODOPCION" , (cAls)->VV2_OPCION , .t. )
			oMGrid:LoadValue("DESCOPCION" , (cAls)->DESCOPCION , .t. )
		Else
			oMGrid:LoadValue("MODOPCION" , (cAls)->DESCOPCION , .t. )
		EndIf

		(cAls)->(dbSkip())
	End
	(cAls)->(dbCloseArea())

	VC0700333_TravaGridResumo(@oMGrid)

Return .t.

Static Function VC0700183_AtualizaGridCorExterna(oModel, lClear)

	Local oMGrid
	Local cAls := "TCOREXT"
	Local cSQL

	Default oModel := FWModelActive()

	oMGrid	:= oModel:GetModel("LISTA_COREXTERNA")

	cSQL := "SELECT DISTINCT " + IIf( lCorExternaFiltroDetalhado , " VV2_COREXT, ", "" ) + "DESCCOREXT,MARCADO FROM " + oTResCorExt:GetRealName() + " ORDER BY 1"
	dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cSQL) , cAls , .T. , .F.)

	VC0700323_LimpaGridResumo(lClear, @oMGrid)
	While ! (cAls)->(Eof())
		oMGrid:AddLine()
		oMGrid:LoadValue("SELCOREXT" , ((cAls)->MARCADO == 1)  , .t. )
		If lCorExternaFiltroDetalhado
			oMGrid:LoadValue("MODCOREXT" , (cAls)->VV2_COREXT , .t. )
			oMGrid:LoadValue("DESCCOREXT" , (cAls)->DESCCOREXT , .t. )
		Else
			oMGrid:LoadValue("MODCOREXT" , (cAls)->DESCCOREXT , .t. )
		EndIf

		(cAls)->(dbSkip())
	End
	(cAls)->(dbCloseArea())

	VC0700333_TravaGridResumo(@oMGrid)

Return .t.

Static Function VC0700193_AtualizaGridCorInterna(oModel, lClear)

	Local oMGrid
	Local cAls := "TCORINT"
	Local cSQL

	Default oModel := FWModelActive()

	oMGrid	:= oModel:GetModel("LISTA_CORINTERNA")

	cSQL := "SELECT DISTINCT " + IIf( lCorInternaFiltroDetalhado , "VV2_CORINT, ", "" ) + "DESCCORINT, MARCADO FROM " + oTResCorInt:GetRealName() + " ORDER BY 1"
	dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cSQL) , cAls , .T. , .F.)

	VC0700323_LimpaGridResumo(lClear, @oMGrid)
	While ! (cAls)->(Eof())

		oMGrid:AddLine()
		oMGrid:LoadValue("SELCORINT" , ((cAls)->MARCADO == 1)  , .t. )
		If lCorInternaFiltroDetalhado
			oMGrid:LoadValue("MODCORINT" , (cAls)->VV2_CORINT , .t. )
			oMGrid:LoadValue("DESCCORINT" , (cAls)->DESCCORINT , .t. )
		Else
			oMGrid:LoadValue("MODCORINT" , (cAls)->DESCCORINT , .t. )
		EndIf

		(cAls)->(dbSkip())
	End
	(cAls)->(dbCloseArea())

	VC0700333_TravaGridResumo(@oMGrid)

Return .t.

Static Function VC0700203_AtualizaGridAnoFabMod(oModel, lClear)

	Local oMGrid
	Local cAls := "TANOFAB"
	Local cSQL

	Default oModel := FWModelActive()

	oMGrid	:= oModel:GetModel("LISTA_ANOFABMOD")

	cSQL := "SELECT * FROM " + oTResAnoFabMod:GetRealName() + " ORDER BY VV1_FABMOD"
	dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cSQL) , cAls , .T. , .F.)

	VC0700323_LimpaGridResumo(lClear, @oMGrid)
	While ! (cAls)->(Eof())
		oMGrid:AddLine()
		oMGrid:LoadValue("SELFABMOD" , ((cAls)->MARCADO == 1)  , .t. )
		oMGrid:LoadValue("MODFABMOD" , (cAls)->VV1_FABMOD , .t. )

		(cAls)->(dbSkip())
	End
	(cAls)->(dbCloseArea())

	VC0700333_TravaGridResumo(@oMGrid)

Return .t.

Static Function VC0700263_AtualizaGridSituacao(oModel, lClear)

	Local oMGrid
	Local cAls := "TSITUAC"
	Local cSQL

	Default oModel := FWModelActive()

	oMGrid	:= oModel:GetModel("LISTA_SITUACAO")

	cSQL := "SELECT * FROM " + oTResSituacao:GetRealName() + " ORDER BY SITUACAO"
	dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cSQL) , cAls , .T. , .F.)

	VC0700323_LimpaGridResumo(lClear, @oMGrid)
	While ! (cAls)->(Eof())
		oMGrid:AddLine()
		oMGrid:LoadValue("SELSITUAC" , ((cAls)->MARCADO == 1)  , .t. )
		oMGrid:LoadValue("SITUACAO" , (cAls)->SITUACAO , .t. )

		(cAls)->(dbSkip())
	End
	(cAls)->(dbCloseArea())

	VC0700333_TravaGridResumo(@oMGrid)

Return .t.

Static Function VC0700303_AtualizaGridImobilizado(oModel, lClear)

	Local oMGrid
	Local cAls := "TVIMOB"
	Local cSQL

	Default oModel := FWModelActive()

	oMGrid	:= oModel:GetModel("LISTA_IMOBILIZADO")

	cSQL := "SELECT * FROM " + oTResImobilizado:GetRealName() + " ORDER BY VV1_IMOBI"
	dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cSQL) , cAls , .T. , .F.)

	VC0700323_LimpaGridResumo(lClear, @oMGrid)
	While ! (cAls)->(Eof())
		oMGrid:AddLine()
		oMGrid:LoadValue("SELIMOB" , ((cAls)->MARCADO == 1)  , .t. )
		oMGrid:LoadValue("VEICIMOB" , (cAls)->VV1_IMOBI , .t. )

		(cAls)->(dbSkip())
	End
	(cAls)->(dbCloseArea())

	VC0700333_TravaGridResumo(@oMGrid)

Return .t.

Static Function VC0700343_AtualizaGridSitVei(oModel, lClear)

	Local oMGrid
	Local cAls := "TSITVEI"
	Local cSQL

	Default oModel := FWModelActive()

	oMGrid	:= oModel:GetModel("LISTA_SITVEI")

	oMGrid:SetNoInsertLine(.F.)

	cSQL := "SELECT * FROM " + oTResSitVei:GetRealName() + " ORDER BY VV1_SITVEI"
	dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cSQL) , cAls , .T. , .F.)

	VC0700323_LimpaGridResumo(lClear, @oMGrid)

	While ! (cAls)->(Eof())
		oMGrid:AddLine()
		oMGrid:LoadValue("SELSITVEI" , ((cAls)->MARCADO == 1)  , .t. )
		oMGrid:LoadValue("MODSITVEI" , (cAls)->VV1_SITVEI , .t. )

		(cAls)->(dbSkip())
	End
	(cAls)->(dbCloseArea())

	VC0700333_TravaGridResumo(@oMGrid)

Return .t.

Static Function VC0700373_AtualizaGridEvento(oModel, lClear)

	Local oMGrid
	Local cAls := "TEVENTO"
	Local cSQL

	Default oModel := FWModelActive()

	oMGrid	:= oModel:GetModel("LISTA_EVENTO")

	oMGrid:SetNoInsertLine(.F.)

	cSQL := "SELECT * FROM " + oTResEvento:GetRealName() + " ORDER BY VJR_EVENTO"
	dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cSQL) , cAls , .T. , .F.)

	VC0700323_LimpaGridResumo(lClear, @oMGrid)

	While ! (cAls)->(Eof())
		oMGrid:AddLine()
		oMGrid:LoadValue("SELEVENTO" , ((cAls)->MARCADO == 1)  , .t. )
		oMGrid:LoadValue("MODEVENTO" , (cAls)->VJR_EVENTO , .t. )

		VX5->(DbSeek(xFilial("VX5")+"051"+(cAls)->VJR_EVENTO))
		oMGrid:LoadValue("DESEVENTO" , Left(VX5->VX5_DESCRI,40) , .t. )

		(cAls)->(dbSkip())
	End
	(cAls)->(dbCloseArea())

	VC0700333_TravaGridResumo(@oMGrid)

Return .t.

Function VC0700273_AtuMarcacaoTabResumo(lParFiltro)

	Local cJoin := ""
	Local cSQL
	Local lParSituac := .f.
	Local lParImobil := .f.
	Local lParSitVei := .f.
	Local cWhere
	Local cSGBD := TcGetDb()
	
	lParFiltro := .f.

	// ------------------------------------------------------------------------------------------------------------------
	oTabConsVeiculo:ExecSQL("UPDATE " + oTabConsVeiculo:GetRealName() + " SET MARCADO = 0")
	// ------------------------------------------------------------------------------------------------------------------

	// ------------------------------------------------------------------------------------------------------------------
	cAuxTab := oTResMarca:GetRealName()
	If FM_SQL("SELECT COUNT(*) FROM " + cAuxTab + " WHERE MARCADO = 1") <> 0
		lParFiltro := .t.
		cJoin += " JOIN " + cAuxTab + " TMAR ON TMAR.VV1_CODMAR = TESTQ.VV1_CODMAR AND TMAR.MARCADO = 1 "
	EndIf
	// ------------------------------------------------------------------------------------------------------------------

	// ------------------------------------------------------------------------------------------------------------------
	cAuxTab := oTResModelo:GetRealName()
	If FM_SQL("SELECT COUNT(*) FROM " + cAuxTab + " WHERE MARCADO = 1") <> 0
		lParFiltro := .t.
		cJoin += " JOIN " + cAuxTab + " TMOD ON TMOD.VV1_MODVEI = TESTQ.VV1_MODVEI AND TMOD.MARCADO = 1 "
	EndIf
	// ------------------------------------------------------------------------------------------------------------------

	If lVV2OPCION
		// ------------------------------------------------------------------------------------------------------------------
		cAuxTab := oTResOpcional:GetRealName()
		If FM_SQL("SELECT COUNT(*) FROM " + cAuxTab + " WHERE MARCADO = 1") <> 0
			lParFiltro := .t.
			cJoin += " JOIN " + cAuxTab + " TOPC ON TOPC.VV2_OPCION = TESTQ.VV2_OPCION AND TOPC.MARCADO = 1 "
		EndIf
		// ------------------------------------------------------------------------------------------------------------------

		// ------------------------------------------------------------------------------------------------------------------
		cAuxTab := oTResCorExt:GetRealName()
		If FM_SQL("SELECT COUNT(*) FROM " + cAuxTab + " WHERE MARCADO = 1") <> 0
			lParFiltro := .t.
			cJoin += " JOIN " + cAuxTab + " TCEXT ON TCEXT.VV2_COREXT = TESTQ.VV2_COREXT AND TCEXT.MARCADO = 1 "
		EndIf
		// ------------------------------------------------------------------------------------------------------------------

		// ------------------------------------------------------------------------------------------------------------------
		cAuxTab := oTResCorInt:GetRealName()
		If FM_SQL("SELECT COUNT(*) FROM " + cAuxTab + " WHERE MARCADO = 1") <> 0
			lParFiltro := .t.
			cJoin += " JOIN " + cAuxTab + " TCINT ON TCINT.VV2_CORINT = TESTQ.VV2_CORINT AND TCINT.MARCADO = 1 "
		EndIf
		// ------------------------------------------------------------------------------------------------------------------
	EndIf

	// ------------------------------------------------------------------------------------------------------------------
	cAuxTab := oTResAnoFabMod:GetRealName()
	If FM_SQL("SELECT COUNT(*) FROM " + cAuxTab + " WHERE MARCADO = 1") <> 0
		lParFiltro := .t.
		cJoin += " JOIN " + cAuxTab + " TFMOD ON TFMOD.VV1_FABMOD = TESTQ.VV1_FABMOD AND TFMOD.MARCADO = 1 "
	EndIf
	// ------------------------------------------------------------------------------------------------------------------

	// ------------------------------------------------------------------------------------------------------------------
	cAuxTab := oTResSituacao:GetRealName()
	If FM_SQL("SELECT COUNT(*) FROM " + cAuxTab + " WHERE MARCADO = 1") <> 0
		lParFiltro := .t.
		lParSituac := .t.
	EndIf
	// ------------------------------------------------------------------------------------------------------------------

	// ------------------------------------------------------------------------------------------------------------------
	cAuxTab := oTResImobilizado:GetRealName()
	If FM_SQL("SELECT COUNT(*) FROM " + cAuxTab + " WHERE MARCADO = 1") <> 0
		lParFiltro := .t.
		lParImobil := .t.
	EndIf
	// ------------------------------------------------------------------------------------------------------------------

	// ------------------------------------------------------------------------------------------------------------------
	cAuxTab := oTResSitVei:GetRealName()
	If FM_SQL("SELECT COUNT(*) FROM " + cAuxTab + " WHERE MARCADO = 1") <> 0
		lParFiltro := .t.
		lParSitVei := .t.
	EndIf
	// ------------------------------------------------------------------------------------------------------------------

	// ------------------------------------------------------------------------------------------------------------------
	If lExistVJR
		cAuxTab := oTResEvento:GetRealName()
		If FM_SQL("SELECT COUNT(*) FROM " + cAuxTab + " WHERE MARCADO = 1") <> 0
			lParFiltro := .t.
			cJoin += " JOIN " + cAuxTab + " TEVENTO ON TEVENTO.VJR_EVENTO = TESTQ.VJR_EVENTO AND TEVENTO.MARCADO = 1 "
		EndIf
	EndIf
	// ------------------------------------------------------------------------------------------------------------------

	// ------------------------------------------------------------------------------------------------------------------
	If lParFiltro

		// Monta query para execucao no ORACLE
		If "ORACLE" $ cSGBD
			cWhere := ""
			If ! Empty(cJoin)
				cWhere += ;
					"(" +;
					" SELECT COUNT(*) " +;
						" FROM " + oTabConsVeiculo:GetRealName() + " TESTQ " +;
							cJoin +;
						" WHERE " + ;
							"     TESTQ.VV1_MODVEI = RES.VV1_MODVEI" +;
							" AND TESTQ.VV1_SEGMOD = RES.VV1_SEGMOD" +;
							IIF( VV2->(ColumnPos("VV2_OPCION") == 0), "" , " AND TESTQ.VV2_OPCION = RES.VV2_OPCION AND TESTQ.VV2_COREXT = RES.VV2_COREXT AND TESTQ.VV2_CORINT = RES.VV2_CORINT" ) +;
					") > 0"
			EndIf

			If lParSituac
				cWhere += IIf( ! Empty(cWhere) , " AND " , "" ) +;
					"(" +;
					" RES.SITUACAO IN ( SELECT TSITUA.SITUACAO FROM " + oTResSituacao:GetRealName() + " TSITUA WHERE TSITUA.MARCADO = 1 ) " +;
					")"
			EndIf

			If lParImobil
				cWhere += IIf( ! Empty(cWhere) , " AND " , "" ) +;
					"(" +;
					" RES.VV1_IMOBI IN ( SELECT TIMOB.VV1_IMOBI FROM " + oTResImobilizado:GetRealName() + " TIMOB WHERE TIMOB.MARCADO = 1 ) " +;
					")"
			EndIf

			If lParSitVei
				cWhere += IIf( ! Empty(cWhere) , " AND " , "" ) +;
					"(" +;
					" RES.VV1_SITVEI IN ( SELECT TSITVEI.VV1_SITVEI FROM " + oTResSitVei:GetRealName() + " TSITVEI WHERE TSITVEI.MARCADO = 1 ) " +;
					")"
			EndIf

			cSQL := "UPDATE " + oTabConsVeiculo:GetRealName() + " RES SET RES.MARCADO = 1 " +;
				"WHERE ( " + cWhere + " )"

		// Monta query para execucao no SQL SERVER
		ElseIf "MSSQL" $ cSGBD

			cWhere := ""

			If lParSituac
				cWhere += IIf( ! Empty(cWhere) , " AND " , "" ) +;
					"(" +;
					" SITUACAO IN ( SELECT TSITUA.SITUACAO FROM " + oTResSituacao:GetRealName() + " TSITUA WHERE TSITUA.MARCADO = 1 ) " +;
					")"
			EndIf

			If lParImobil
				cWhere += IIf( ! Empty(cWhere) , " AND " , "" ) +;
					"(" +;
					" VV1_IMOBI IN ( SELECT TIMOB.VV1_IMOBI FROM " + oTResImobilizado:GetRealName() + " TIMOB WHERE TIMOB.MARCADO = 1 ) " +;
					")"
			EndIf

			If lParSitVei
				cWhere += IIf( ! Empty(cWhere) , " AND " , "" ) +;
					"(" +;
					" VV1_SITVEI IN ( SELECT TSITVEI.VV1_SITVEI FROM " + oTResSitVei:GetRealName() + " TSITVEI WHERE TSITVEI.MARCADO = 1 ) " +;
					")"
			EndIf


			cSQL := "UPDATE " + oTabConsVeiculo:GetRealName() + " SET MARCADO = 1 " +;
					" FROM " + oTabConsVeiculo:GetRealName() + " TESTQ " +;
					cJoin +;
					IIf( ! Empty(cWhere) , " WHERE " + cWhere , "" )
		EndIf

		If lDebug
			Conout("----------------------------------------------------")
			ConOut(cSQL)
			Conout( " ")
			CopytoClipboard(cSQL)
			Conout( " ")
			Conout( cValToChar(oTabConsVeiculo:ExecSQL(cSQL )))
			Conout( " ")
			Conout(cValToChar(FM_SQL("SELECT COUNT(*) FROM " + oTabConsVeiculo:GetRealName() + " WHERE MARCADO = 1")))
			Conout( " ")
		Else
			oTabConsVeiculo:ExecSQL(cSQL )
		EndIf

	EndIf
	// ------------------------------------------------------------------------------------------------------------------

Return


Function VC0700283_ChangeFolder(cIdField, nOldSheet, nSelSheet)
	Local lParFiltro := .f.

	CursorWait()

	// ------------------------------------------------------------------------------------------------------------------

	If nOldSheet == 1
		VC0700273_AtuMarcacaoTabResumo(@lParFiltro)
	Else
		lParFiltro := (FM_SQL("SELECT COUNT(*) FROM " + oTabConsVeiculo:GetRealName() + " WHERE MARCADO = 1") > 0)
	EndIf

	If nSelSheet == 2
		VC0700353_AtuBrowseEstoqueResumo(lParFiltro)
		oBrw070ResumoEstq:GoTop(.t.)
		oBrw070ResumoEstq:Refresh(.t.)
	EndIf

	If nSelSheet == 3
		VC0700143_AtuBrowseConsulta(lParFiltro)
		oBrwVC070:GoTop(.t.)
		oBrwVC070:Refresh(.t.)
	EndIf

	CursorArrow()

Return .t.

Function VC0700433_AtualizarView(oModel, oView)

	VC0700223_AtuTabConsulta()
	VC0700313_AtualizaGrids(oModel, .t.)
	//VC0700153_AtualizaGridMarcas(oModel, .t. )
	//VC0700163_AtualizaGridModelos(oModel , .t. )
	//If lVV2OPCION
	//	VC0700173_AtualizaGridOpcionais(oModel , .t. )
	//	VC0700183_AtualizaGridCorExterna(oModel , .t. )
	//	VC0700193_AtualizaGridCorInterna(oModel , .t. )
	//EndIf
	//VC0700203_AtualizaGridAnoFabMod(oModel , .t. )
	//VC0700263_AtualizaGridSituacao(oModel , .t. )
	//VC0700303_AtualizaGridImobilizado(oModel , .t. )

	oView:Refresh()

Return


Function VC0700453_ConfigBrowseResumoEstq(oBSEstqResumo)
	oBSEstqResumo := OFBrowseStruct():New({"VV1", "VV2", "VVR"})

	oBSEstqResumo:AddFieldManual( DMS_DataContainer():New({;
											{ 'cIdField' , 'MODELO' },;
											{ 'cTitulo' , STR0026 },; // 'Modelo'
											{ 'cTipo' , 'C' },;
											{ 'nTamanho' , TamSX3("VV1_MODVEI")[1] + 3 + TamSX3("VV2_DESMOD")[1] },;
											{ 'nDecimal' , 0 },;
											{ 'cPicture' , '@!' } } ) )
	oBSEstqResumo:AddFieldManual( DMS_DataContainer():New({;
											{ 'cIdField' , 'ANO' },;
											{ 'cTitulo' , STR0030 },; // 'Ano Fabr./Mod.'
											{ 'cTipo' , 'C' },;
											{ 'nTamanho' , 25 },;
											{ 'nDecimal' , 0 },;
											{ 'cPicture' , '@!' } } ) )
	If lVV2OPCION
		oBSEstqResumo:AddField( "VV2_OPCION" )
		oBSEstqResumo:AddFieldManual( DMS_DataContainer():New({;
												{ 'cIdField' , 'DESCOPCION' },;
												{ 'cTitulo' , STR0027 },; // 'Opcional'
												{ 'cTipo' , 'C' },;
												{ 'nTamanho' , nTamDOpcional },;
												{ 'nDecimal' , 0 },;
												{ 'cPicture' , '@!' } } ) )
		oBSEstqResumo:AddField( "VV2_COREXT" )
		oBSEstqResumo:AddFieldManual( DMS_DataContainer():New({;
												{ 'cIdField' , 'DESCCOREXT' },;
												{ 'cTitulo' , STR0028 },; // 'Cor Externa'
												{ 'cTipo' , 'C' },;
												{ 'nTamanho' , nTamDCorExt },;
												{ 'nDecimal' , 0 },;
												{ 'cPicture' , '@!' } } ) )
		oBSEstqResumo:AddField( "VV2_CORINT" )
		oBSEstqResumo:AddFieldManual( DMS_DataContainer():New({;
												{ 'cIdField' , 'DESCCORINT' },;
												{ 'cTitulo' , STR0029 },; // 'Cor Interna'
												{ 'cTipo' , 'C' },;
												{ 'nTamanho' , nTamDCorInt },;
												{ 'nDecimal' , 0 },;
												{ 'cPicture' , '@!' } } ) )
	Endif

	oBSEstqResumo:AddFieldManual( DMS_DataContainer():New({;
											{ 'cIdField' , 'QTDE' },;
											{ 'cTitulo' , STR0040 },; // 'Quantidade'
											{ 'cTipo' , 'N' },;
											{ 'nTamanho' , 5 },;
											{ 'nDecimal' , 0 },;
											{ 'cPicture' , '@! 99999' } } ) )
	oBSEstqResumo:CriaTabTmp()

Return

Static Function VC0700353_AtuBrowseEstoqueResumo(lParFiltro)

	Local cSQL

	Local cCmdSubtr := oVC070SQL:CompatFunc("SUBSTR")
	Local cCmdRTRIM := oVC070SQL:CompatFunc("RTRIM")

	Local cStrTotalGeral := STR0041 // 'TOTAL GERAL'
	Local cStrTotal := STR0042 // 'TOTAL'
	Local cStrSubTotal := STR0043 // 'SUB-TOTAL'

	cParGroupingID := "VV1_MODVEI, VV1_FABMOD" + IIf( lVV2OPCION , ", VV2_OPCION" , "" )

	cSQL := ;
	"SELECT " +;
		"CASE " +;
		" GROUPING_ID(" + cParGroupingID + ") " +;
			" WHEN 7 THEN '" + cStrTotalGeral + "' " +; // 'TOTAL GERAL'
			" WHEN 3 THEN " + oVC070SQL:Concat({"'" + cStrTotal + " - ' ", " VV2_DESMOD "}) +; // 'TOTAL'
			" WHEN 0 THEN " + oVC070SQL:Concat({cCmdRTRIM + "(COALESCE(VV1_MODVEI,' ')) "," ' - ' "," COALESCE(VV2_DESMOD,' ') "}) +;
			" ELSE ' ' " +;
		"END AS MODELO, " +;
		"CASE " +;
		" GROUPING_ID(" + cParGroupingID + ") " +;
			" WHEN 1 THEN " + oVC070SQL:Concat({"'" + cStrSubTotal + " - ' ", " " + cCmdSubtr + "(VV1_FABMOD,1,4) ", " '/' ", " " + cCmdSubtr + "(VV1_FABMOD,5,4) "}) +; // 'SUB-TOTAL'
			" WHEN 0 THEN " + oVC070SQL:Concat({cCmdSubtr + "(VV1_FABMOD,1,4) ", " '/' ", " " + cCmdSubtr + "(VV1_FABMOD,5,4) "}) +;
			" ELSE ' ' " +;
		"END AS VV1_FABMOD, "
	
	If lVV2OPCION
		cSQL += "COALESCE( " + cCmdRTRIM + "(VV2_OPCION),' ') VV2_OPCION, " +;
			"COALESCE( " + cCmdRTRIM + "(DESCOPCION),' ') DESCOPCION, " +;
			"COALESCE( " + cCmdRTRIM + "(VV2_COREXT),' ') VV2_COREXT, " +;
			"COALESCE( " + cCmdRTRIM + "(DESCCOREXT),' ') DESCCOREXT, " +;
			"COALESCE( " + cCmdRTRIM + "(VV2_CORINT),' ') VV2_CORINT, " +;
			"COALESCE( " + cCmdRTRIM + "(DESCCORINT),' ') DESCCORINT, "
	EndIf

	cSQL += "COUNT(*) QTDE " +;
	" FROM " + oTabConsVeiculo:GetRealName()

	If lParFiltro
		cSQL += " WHERE MARCADO = 1"
	EndIf
	cSQL += " GROUP BY ROLLUP( (VV1_MODVEI, VV2_DESMOD), VV1_FABMOD "
	If lVV2OPCION
		cSQL += " ,(VV2_OPCION, DESCOPCION, VV2_COREXT, DESCCOREXT, VV2_CORINT, DESCCORINT) "
	EndIf
	cSQL += " ) "

	oBSEstqResumo:LoadData( cSQL , .t. )

	dbSelectArea(oBSEstqResumo:GetAlias())
	dbGoTop()

Return

Static Function VC0700363_CriaBrowseEstoqueResumo(oPanel)

	// Cria um Form Browse
	oBrw070ResumoEstq := FWmBrowse():New()

	oBSEstqResumo:SetBrwOwner(oBrw070ResumoEstq)

	oBrw070ResumoEstq:SetDescription(STR0044)// "Resumo do Estoque"

	oBrw070ResumoEstq:SetWalkThru(.F.)
	oBrw070ResumoEstq:SetAmbiente(.F.)
	oBrw070ResumoEstq:DisableDetails()

	oBSEstqResumo:AddBrwColumn()

	oBrw070ResumoEstq:SetAlias(oBSEstqResumo:GetAlias())

	oBrw070ResumoEstq:SetOwner(oPanel)
	oBrw070ResumoEstq:Activate()

Return


Static Function VC0700383_MaxDescrVX5(cTabela)

	cSQL := "SELECT COALESCE(MAX(" + oVC070SQL:CompatFunc('LEN') + "(RTRIM(VX5_DESCRI))),0) + 5 FROM " + RetSQLName("VX5") + " WHERE VX5_CHAVE = '" + cTabela + "' AND D_E_L_E_T_ = ' '"

Return FM_SQL(cSQL)

Function VC0700463_ConfiguraView(oView)

	oView:SetCloseOnOk( { || .T. } )

	//Executa a ação antes de cancelar a Janela de edição se ação retornar .F. não apresenta o
	// qustionamento ao usuario de formulario modificado
	oView:SetViewAction("ASKONCANCELSHOW", { || .F. })

	//Executa a ação no acionamento do botão confirmar da View
	//oView:SetViewAction("BUTTONOK", {|oView| VC0100053_ButtonOK(oView,"SetViewAction") })

	//Desabilita order no grid
	//oView:SetViewProperty( "*", "GRIDNOORDER")

	oView:SetViewProperty("GRID_LISTA_MODELO", "GRIDSEEK", {.T.})
	//oView:SetViewProperty('FORM_PARAM','SETLAYOUT',{FF_LAYOUT_VERT_DESCR_TOP , 2})

	oView:SetModified(.t.) // Marca internamente que algo foi modificado no MODEL

	oView:showUpdateMsg(.f.)
	oView:showInsertMsg(.f.)

Return

/*/{Protheus.doc} VC0700423_SitVei
	(long_description)
	@type  Static Function
	@author Rubens
	@since 12/07/2019
	@version 1.0
	@return oRetorno, OFDMSStruct, Struct
	/*/
Static Function VC0700473_SitVei()

	Local oRetorno := OFDMSStruct():New()

	oRetorno:AddSelect('','SELSITVEI', , .t.)
	oRetorno:AddFieldDictionary( "VV1", "VV1_SITVEI" , { {"cIdField" , "MODSITVEI"} , { "lVirtual", .t. } , { "lCanChange" , .f. } } )

Return oRetorno



/*/{Protheus.doc} VC0710073_Evento
	(long_description)
	@type  Static Function
	@author Rubens
	@since 12/07/2019
	@version 1.0
	@return oRetorno, OFDMSStruct, Struct
	/*/
Static Function VC0700483_Evento()
	Local oRetorno := OFDMSStruct():New()

	oRetorno:AddSelect('','SELEVENTO', , .t.)
	If lExistVJR
		oRetorno:AddFieldDictionary( "VJR", "VJR_EVENTO" , { {"cIdField" , "MODEVENTO"} , { "lVirtual", .t. } , { "lCanChange" , .f. } } )
		oRetorno:AddField( {;
								{ 'cIdField' , 'DESEVENTO' },;
								{ 'cTitulo' , 'Descrição' },;
								{ 'cTipo' , 'C' },;
								{ 'nTamanho' , 40 },;
								{ 'nDecimal' , 0 },;
								{ 'cPicture' , '@!' },;
								{ "lVirtual" , .t. },;
								{ "lCanChange" , .f. } } )
	EndIf
Return oRetorno