#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

#INCLUDE "VEIA060.CH"

//#DEFINE lDebug .f.
#DEFINE lMostraLog .f.

STATIC aVRJ_RelImp
STATIC aVRK_RelImp

STATIC oLogger

Static oResModStruDef := VA0600223_StructResumoModelo()

Static cPRETIT := "PVM"

/*/{Protheus.doc} VEIA060
Cadastro de Pedido de Veículo

@author Rubens
@since 28/12/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function VEIA060()
	Local oBrowse
	//Local oBrowseDet

	Private aHeader := {}
	Private aCols := {}
	Private N := 1

	Private bRefresh := { || .t. } // Variavel utilizada no FISCAL

	SetKey(VK_F12,{ || Pergunte( "VEIA060" , .T. ,,,,.f.)})
	
	// Instanciamento da Classe de Browse
	oBrowse := BrowseDef()
	oBrowse:Activate()

	SetKey(VK_F12,Nil)

Return

Static Function BrowseDef()
	Local oBrowse := FWMBrowse():New()

	oBrowse:SetAlias('VRJ')
	oBrowse:SetDescription( STR0001 ) // 'Cadastro Pedido de Veiculo'

	oBrowse:AddLegend( 'VRJ->VRJ_STATUS == "A"' , 'BR_VERDE'    , STR0002 ) // "Em Aberto"
	oBrowse:AddLegend( 'VRJ->VRJ_STATUS == "P"' , 'BR_AMARELO'  , STR0003 ) // "Pendente de Aprovação"
	oBrowse:AddLegend( 'VRJ->VRJ_STATUS == "O"' , 'BR_BRANCO'   , STR0004 ) // "Pré-Aprovado"
	oBrowse:AddLegend( 'VRJ->VRJ_STATUS == "L"' , 'BR_AZUL'     , STR0005 ) // "Aprovado"
	oBrowse:AddLegend( 'VRJ->VRJ_STATUS == "R"' , 'BR_LARANJA'  , STR0006 ) // "Reprovado"
	oBrowse:AddLegend( 'VRJ->VRJ_STATUS == "F"' , 'BR_PRETO'    , STR0007 ) // "Finalizado"
	oBrowse:AddLegend( 'VRJ->VRJ_STATUS == "C"' , 'BR_VERMELHO' , STR0008 ) // "Cancelado"

	oBrowse:AddStatusColumns( { || VA0600343_StatusAtend(VRJ->VRJ_PEDIDO) }, { || VA0600353_LegendaAtend() } )

Return oBrowse

Static Function VA0600343_StatusAtend(cNumPedido)


	BeginSQL Alias 'FATSTA'
		COLUMN FAT AS NUMERIC(2,0)
		COLUMN ABE AS NUMERIC(2,0)
		COLUMN PED AS NUMERIC(2,0)

		SELECT 
			SUM(FAT) FAT,
			SUM(ABE) ABE,
			SUM(PED) PED
		FROM (
			SELECT 
				CASE WHEN VV9.VV9_STATUS = 'F' AND VV0.VV0_SITNFI = '1' THEN 1 ELSE 0 END AS FAT,
				CASE WHEN VV9.VV9_STATUS <> 'F' THEN 1 ELSE 0 END AS ABE,
				1 PED
			FROM
	  			%table:VRK% VRK
				  LEFT JOIN %table:VV9% VV9 ON VV9.VV9_FILIAL = %xFilial:VV9% AND VV9.VV9_NUMATE = VRK.VRK_NUMTRA AND VV9.VV9_STATUS <> 'C' AND VV9.%notDel% 
				  LEFT JOIN %table:VV0% VV0 ON VV0.VV0_FILIAL = %xFilial:VV0% AND VV0.VV0_NUMTRA = VV9.VV9_NUMATE AND VV0.%notDel% 
				  LEFT JOIN %table:VVA% VVA ON VVA.VVA_FILIAL = %xFilial:VVA% AND VVA.VVA_NUMTRA = VV0.VV0_NUMTRA AND VVA.VVA_ITETRA = VRK.VRK_ITETRA  AND VVA.%notDel% 

			WHERE VRK.VRK_FILIAL = %xFilial:VRK%
			  AND VRK.VRK_PEDIDO = %exp:cNumPedido%
			  AND VRK_CANCEL IN (' ' ,'0')
			  AND VRK.D_E_L_E_T_ = ' '
		) TEMP 

	EndSql

	Do Case
	Case FATSTA->PED == FATSTA->ABE
		cStatus := "BR_BRANCO"
	Case FATSTA->PED == FATSTA->FAT
		cStatus := "BR_PRETO"
	Case FATSTA->PED > 0 .AND. (FATSTA->ABE <> 0 .OR. FATSTA->FAT <> 0) .AND. FATSTA->PED == (FATSTA->ABE + FATSTA->FAT)
		cStatus := "BR_AMARELO"
	Case FATSTA->PED > 0 .AND. (FATSTA->ABE <> 0 .OR. FATSTA->FAT <> 0) .AND. FATSTA->PED > (FATSTA->ABE + FATSTA->FAT)
		cStatus := "BR_PINK"
	Case FATSTA->PED > 0 .AND. FATSTA->ABE == 0
		cStatus := ""
	Otherwise
		cStatus := ""
	EndCase

	FATSTA->(dbCloseArea())

Return cStatus

Static Function VA0600353_LegendaAtend()
	Local oLegenda  :=  FWLegend():New()

	oLegenda:Add( '', " "   , STR0009 ) // 'Sem atendimento gerado'
	oLegenda:Add( '', "BR_BRANCO"  , STR0010 ) // 'Aberto'
	oLegenda:Add( '', "BR_PINK"    , STR0011 ) // 'Gerado parcialmente'
	oLegenda:Add( '', "BR_AMARELO" , STR0012 ) // 'Faturado parcialmente'
	oLegenda:Add( '', "BR_PRETO"   , STR0013 ) // 'Faturado'

	oLegenda:Activate()
	oLegenda:View()
	oLegenda:DeActivate()

Return Nil



/*/{Protheus.doc} ModelDef
Modelo de Dados
@author Rubens
@since 28/12/2018
@version 1.0

@type function
/*/
Static Function ModelDef()
	Local oStruVRJ := FWFormStruct( 1, 'VRJ' )
	Local oStruVRK := FWFormStruct( 1, 'VRK' )
	Local oStruVRL := FWFormStruct( 1, 'VRL' )
	Local oStruVRLRes := FWFormStruct( 1, 'VRL' )
	Local oStruVX0 := FWFormStruct( 1, 'VX0' )
	Local oStruResumo := oResModStruDef:GetModel()
	Local oModel

	VA0600053_RelacaoImpostos()

	// Cabecalho do Pedido
	VA0600363_AddTrigger( oStruVRJ , FwStruTrigger("VRJ_CODCLI","VRJ_NOMCLI","Left(SA1->A1_NOME," + cValToChar(GetSX3Cache("VRJ_NOMCLI","X3_TAMANHO")) + ")",.T.,"SA1",1,"xFilial('SA1') + FWFldGet('VRJ_CODCLI') + FwFldGet('VRJ_LOJA')","!Empty(FWFldGet('VRJ_CODCLI'))") )
	VA0600363_AddTrigger( oStruVRJ , FwStruTrigger("VRJ_LOJA","VRJ_NOMCLI","Left(SA1->A1_NOME," + cValToChar(GetSX3Cache("VRJ_NOMCLI","X3_TAMANHO")) + ")",.T.,"SA1",1,"xFilial('SA1') + FWFldGet('VRJ_CODCLI') + FwFldGet('VRJ_LOJA')") )
	VA0600363_AddTrigger( oStruVRJ , FwStruTrigger("VRJ_LOJA","VRJ_TIPOCL","SA1->A1_TIPO",.T.,"SA1",1,"xFilial('SA1') + FWFldGet('VRJ_CODCLI') + FwFldGet('VRJ_LOJA')","!Empty(FWFldGet('VRJ_LOJA'))") )
	VA0600363_AddTrigger( oStruVRJ , FwStruTrigger("VRJ_LOJA","VRJ_CLIMUN","Left(SA1->A1_MUN," + cValToChar(GetSX3Cache("VRJ_CLIMUN","X3_TAMANHO")) + ")",.T.,"SA1",1,"xFilial('SA1') + FWFldGet('VRJ_CODCLI') + FwFldGet('VRJ_LOJA')") )
	VA0600363_AddTrigger( oStruVRJ , FwStruTrigger("VRJ_CODVEN","VRJ_NOMVEN","Left(SA3->A3_NOME,40)",.T.,"SA3",1,"xFilial('SA3') + FWFldGet('VRJ_CODVEN')") )

	VA0600363_AddTrigger( oStruVRL , FwStruTrigger("VRJ_CODCLI","VRL_E1CLIE","FWFldGet('VRJ_CODCLI')",.F.,,,,"Empty(FWFldGet('VRL_E1CLIE'))") )
	VA0600363_AddTrigger( oStruVRL , FwStruTrigger("VRJ_LOJA","VRL_E1LOJA","FWFldGet('VRJ_LOJA')",.F.,,,,"Empty(FWFldGet('VRL_E1LOJA'))") )

	VA0600363_AddTrigger( oStruVRJ , FwStruTrigger("VRJ_FORPAG","VRJ_DESFPG","SE4->E4_DESCRI",.T.,"SE4",1,"xFilial('SE4') + FWFldGet('VRJ_FORPAG')") )

	cWhen := "!Empty(FWFldGet('VRJ_LOJA'))"
	bWhen := FWBuildFeature( STRUCT_FEATURE_WHEN, cWhen )
	oStruVRJ:SetProperty('VRJ_TIPOCL',MODEL_FIELD_WHEN,bWhen)

	// TEMPORARIO ...
	oStruVRJ:SetProperty('VRJ_FORPAG',MODEL_FIELD_OBRIGAT,.T.)
	//

	// Itens do Pedido
	VA0600363_AddTrigger( oStruVRK, FwStruTrigger("VRK_MODVEI","VRK_GRUMOD","VV2->VV2_GRUMOD",.T.,"VV2",1,"xFilial('VV2') + FWFldGet('VRK_CODMAR')+FWFldGet('VRK_MODVEI')") )
	VA0600363_AddTrigger( oStruVRK, FwStruTrigger("VRK_SEGMOD","VRK_COREXT","VV2->VV2_COREXT",.T.,"VV2",1,"xFilial('VV2') + FWFldGet('VRK_CODMAR')+FWFldGet('VRK_MODVEI')+FWFldGet('VRK_SEGMOD')") )
	VA0600363_AddTrigger( oStruVRK, FwStruTrigger("VRK_SEGMOD","VRK_CORINT","VV2->VV2_CORINT",.T.,"VV2",1,"xFilial('VV2') + FWFldGet('VRK_CODMAR')+FWFldGet('VRK_MODVEI')+FWFldGet('VRK_SEGMOD')") )
	VA0600363_AddTrigger( oStruVRK, FwStruTrigger("VRK_SEGMOD","VRK_OPCION","VV2->VV2_OPCION",.T.,"VV2",1,"xFilial('VV2') + FWFldGet('VRK_CODMAR')+FWFldGet('VRK_MODVEI')+FWFldGet('VRK_SEGMOD')") )
	VA0600363_AddTrigger( oStruVRK, FwStruTrigger("VRK_CHAINT","VRK_CORVEI","VV1->VV1_CORVEI",.T.,"VV1",1,"xFilial('VV1') + FWFldGet('VRK_CHAINT')","!Empty(FWFldGet('VRK_CHAINT'))") )
	VA0600363_AddTrigger( oStruVRK, FwStruTrigger("VRK_CHASSI","VRK_CORVEI","VV1->VV1_CORVEI",.T.,"VV1",2,"xFilial('VV1') + FWFldGet('VRK_CHASSI')","!Empty(FWFldGet('VRK_CHASSI'))") )
	VA0600363_AddTrigger( oStruVRK, FwStruTrigger("VRK_CORVEI","VRK_DESCOR","VVC->VVC_DESCRI",.T.,"VVC",1,"xFilial('VVC') + FWFldGet('VRK_CODMAR') + FWFldGet('VRK_CORVEI')","!Empty(FWFldGet('VRK_CORVEI'))") )

	// Se necessario alterar este gatilho, verificar se tambem sera necessário alterar o evento de alteracao de CODIGO DE TES
	VA0600363_AddTrigger( oStruVRK , FwStruTrigger("VRK_VALPRE","VRK_VALMOV","VA060E0093_ValorPretendido()",.F.) )
	
	bWhen := FWBuildFeature( STRUCT_FEATURE_WHEN, "Empty(FWFldGet('VRK_CHAINT'))" )
	oStruVRK:SetProperty('VRK_FABMOD',MODEL_FIELD_WHEN,bWhen)
	bWhen := FWBuildFeature( STRUCT_FEATURE_WHEN, "! Empty(FWFldGet('B1COD'))" )
	oStruVRK:SetProperty('VRK_VALPRE',MODEL_FIELD_WHEN,bWhen)
	oStruVRK:SetProperty('VRK_VALMOV',MODEL_FIELD_WHEN,bWhen)
	oStruVRK:SetProperty('VRK_VALDES',MODEL_FIELD_WHEN,bWhen)

	oStruVRK:SetProperty('VRK_PEDIDO',MODEL_FIELD_OBRIGAT,.f.)

	oStruVRK:AddField(;
		STR0014,; // cTitulo - 'Legenda'
		'',; // cTooltip
		'LEGENDA',; // cIdField
		'C',; // cTipo
		30,; // nTamanho
		0,; // nDecimal
		,; // bValid
		,; // bWhen
		{},; // aValues
		.F.,; // lObrigat
		FWBuildFeature( STRUCT_FEATURE_INIPAD, "VA0600373_LegendaItemPedido()"),; // bInit
		.F.,; // lKey
		.F.,; // lNoUpd
		.T.,; // lVirtual
		) // cValid


	oStruVRK:AddField(;
		STR0015,; // cTitulo - "Item Fiscal"
		STR0015,; // cTooltip - "Item Fiscal"
		"ITEMFISCAL",; // cIdField
		"N",; // cTipo
		4,; // nTamanho
		0,; // nDecimal
		{ || .T. },; // bValid
		FWBuildFeature( STRUCT_FEATURE_WHEN, ".t." ),; // bWhen
		NIL,; // aValues
		.F.,; // lObrigat
		NIL,; // bInit
		.f.,; // lKey
		.f. ,; // lNoUpd
		.t. ,; // lVirtual
		NIL ) // cValid

	oStruVRK:AddField(;
		RetTitle("B1_COD"),; // cTitulo
		RetTitle("B1_COD"),; // cTooltip
		"B1COD",; // cIdField
		"C",; // cTipo
		GetSX3Cache("B1_COD","X3_TAMANHO"),; // nTamanho
		0,; // nDecimal
		FWBuildFeature( STRUCT_FEATURE_VALID , "VA0600133_AtuFiscalProduto()" ),; // bValid
		FWBuildFeature( STRUCT_FEATURE_WHEN, ".t." ),; // bWhen
		NIL,; // aValues
		.T.,; // lObrigat
		NIL,; // bInit
		.f.,; // lKey
		.f. ,; // lNoUpd
		.t. ,; // lVirtual
		NIL ) // cValid

	oStruVRK:AddField(;
		"VV2 RECNO",; // cTitulo
		"Recno da VV2",; // cTooltip
		"VV2RECNO",; // cIdField
		"N",; // cTipo
		10,; // nTamanho
		0,; // nDecimal
		NIL,; // bValid
		FWBuildFeature( STRUCT_FEATURE_WHEN, ".t." ),; // bWhen
		NIL,; // aValues
		.T.,; // lObrigat
		NIL,; // bInit
		.f.,; // lKey
		.f. ,; // lNoUpd
		.t. ,; // lVirtual
		NIL ) // cValid

	oStruVRK:AddField(;
		STR0016,; // cTitulo - "Status Ped"
		STR0017,; // cTooltip - "Status Pedido"
		"STATPED",; // cIdField
		"C",; // cTipo
		1,; // nTamanho
		0,; // nDecimal
		NIL,; // bValid
		FWBuildFeature( STRUCT_FEATURE_WHEN, ".t." ),; // bWhen
		NIL,; // aValues
		.F.,; // lObrigat
		FWBuildFeature( STRUCT_FEATURE_INIPAD,  GetSx3Cache("VRJ_STATUS", "X3_RELACAO") ),; // bInit
		.f.,; // lKey
		.f. ,; // lNoUpd
		.t. ,; // lVirtual
		NIL ) // cValid

	cValidDef := ".t."
	bValidDef := FWBuildFeature( STRUCT_FEATURE_VALID, cValidDef )
	oStruVRK:SetProperty("VRK_CHASSI" , MODEL_FIELD_VALID , bValidDef )
	oStruVRK:SetProperty("VRK_CODTES" , MODEL_FIELD_VALID , bValidDef )
	oStruVRK:SetProperty("VRK_VALTAB" , MODEL_FIELD_VALID , bValidDef )
	oStruVRK:SetProperty("VRK_VALMOV" , MODEL_FIELD_VALID , bValidDef )
	oStruVRK:SetProperty("VRK_VALDES" , MODEL_FIELD_VALID , bValidDef )
	oStruVRK:SetProperty("VRK_VALVDA" , MODEL_FIELD_VALID , bValidDef )
	oStruVRK:SetProperty("VRK_VBAICM" , MODEL_FIELD_VALID , bValidDef )
	oStruVRK:SetProperty("VRK_ALIICM" , MODEL_FIELD_VALID , bValidDef )
	oStruVRK:SetProperty("VRK_ICMVEN" , MODEL_FIELD_VALID , bValidDef )

	// Financeiro do Item do Pedido 
	oStruVRL:SetProperty('VRL_CODIGO',MODEL_FIELD_OBRIGAT,.f.)
	oStruVRL:SetProperty('VRL_PEDIDO',MODEL_FIELD_OBRIGAT,.f.)
	oStruVRL:SetProperty('VRL_ITEPED',MODEL_FIELD_OBRIGAT,.f.)

	VA0600363_AddTrigger(oStruVRL , FwStruTrigger("VRL_E1DTVE","VRL_E1DTVR","DataValida(FWFldGet('VRL_E1DTVE'))",.F.,,,,"!Empty(FWFldGet('VRL_E1DTVE'))") )

	bInitPad := FWBuildFeature( STRUCT_FEATURE_INIPAD, "'" + cPRETIT + "'")
	oStruVRL:SetProperty('VRL_E1PREF',MODEL_FIELD_INIT,bInitPad)

	bAuxValid := FWBuildFeature( STRUCT_FEATURE_VALID , "Vazio() .or. ExistCPO('SX5','05' + M->VRL_E1TIPO)")
	oStruVRL:SetProperty('VRL_E1TIPO',MODEL_FIELD_VALID,bAuxValid)

	oStruVRL:AddField(;
		STR0014,; // cTitulo - 'Legenda'
		'',; // cTooltip
		'LEGENDA',; // cIdField
		'C',; // cTipo
		20,; // nTamanho
		0,; // nDecimal
		,; // bValid
		,; // bWhen
		{},; // aValues
		.F.,; // lObrigat
		FWBuildFeature( STRUCT_FEATURE_INIPAD, "VA0600313_LegendaFinanceiro()"),; // bInit
		.F.,; // lKey
		.F.,; // lNoUpd
		.T.,; // lVirtual
		) // cValid

	oStruVRL:AddField(;
		STR0018,; // cTitulo - 'Status Tit.'
		'',; // cTooltip
		'STATUS_FIN',; // cIdField
		'C',; // cTipo
		12,; // nTamanho
		0,; // nDecimal
		,; // bValid
		,; // bWhen
		{},; // aValues
		.F.,; // lObrigat
		FWBuildFeature( STRUCT_FEATURE_INIPAD, "VA0600323_StatusFinanc()"),; // bInit
		.F.,; // lKey
		.F.,; // lNoUpd
		.T.,; // lVirtual
		) // cValid

	oStruVRLRes:AddField(;
		STR0014,; // cTitulo - 'Legenda'
		'',; // cTooltip
		'LEGENDA',; // cIdField
		'C',; // cTipo
		20,; // nTamanho
		0,; // nDecimal
		,; // bValid
		,; // bWhen
		{},; // aValues
		.F.,; // lObrigat
		FWBuildFeature( STRUCT_FEATURE_INIPAD, "VA0600313_LegendaFinanceiro()"),; // bInit
		.F.,; // lKey
		.F.,; // lNoUpd
		.T.,; // lVirtual
		) // cValid

	//	oModel := MPFormModel():New('VEIA060',,,bCommit )
	oModel := MPFormModel():New('VEIA060',,, )
	oModel:AddFields('MODEL_VRJ', /*cOwner*/, oStruVRJ       , /* <bPre > */ , /* <bPost > */ , { |oSubModel| VA0600163_LoadVRJ(oSubModel) })
	//oModel:AddGrid(  'MODEL_VRK', 'MODEL_VRJ',oStruVRK, /* <bLinePre > */ , /* <bLinePost > */ , /* <bPre > */ , /* <bLinePost > */, { |oSubModel| VA0600153_LoadVRK(oSubModel) } )
	oModel:AddGrid(  'MODEL_VRK', 'MODEL_VRJ',oStruVRK, /* <bLinePre > */ , /* <bLinePost > */ , /* <bPre > */ , /* <bLinePost > */,  )
	oModel:AddGrid(  'MODEL_VRL', 'MODEL_VRK',oStruVRL, /* <bLinePre > */ , /* <bLinePost > */ , /* <bPre > */ , /* <bLinePost > */,  )
	oModel:AddGrid(  'MODEL_VRLRES', 'MODEL_VRJ',oStruVRLRes, /* <bLinePre > */ , /* <bLinePost > */ , /* <bPre > */ , /* <bLinePost > */,  )
	oModel:AddGrid(  'MODEL_VX0', 'MODEL_VRJ',oStruVX0, /* <bLinePre > */ , /* <bLinePost > */ , /* <bPre > */ , /* <bLinePost > */,  )

	//oModel:AddGrid(  'MODEL_RESUMO', 'MODEL_VRK',oStruResumo, /* <bLinePre > */ , /* <bLinePost > */ , /* <bPre > */ , /* <bLinePost > */, { |oSubModel| VA0600243_LoadResumo(oSubModel) } )
	oModel:AddGrid(  'MODEL_RESUMO', 'MODEL_VRJ',oStruResumo, /* <bLinePre > */ , /* <bLinePost > */ , /* <bPre > */ , /* <bLinePost > */, { |oSubModel| VA0600243_LoadResumo(oSubModel) }  )

	oModel:SetDescription( STR0065 ) // 'Pedido de Venda de Montadora'
	oModel:GetModel( 'MODEL_VRJ' ):SetDescription( STR0019 ) // 'Dados de Pedido de Venda de Montadora'
	oModel:GetModel( 'MODEL_VRK' ):SetDescription( STR0020 ) // 'Dados de Itens do Pedido de Venda de Montadora'
	oModel:GetModel( 'MODEL_VRL' ):SetDescription( STR0021 ) // 'Dados de Negociacao Financeira do Pedido de Venda de Montadora'
	oModel:GetModel( 'MODEL_VRLRES' ):SetDescription( STR0022 ) // 'Dados do Resumo da Negociacao Financeira do Pedido de Venda de Montadora'
	oModel:GetModel( 'MODEL_VX0' ):SetDescription( STR0023 ) // 'Dados do Log de Alteracao do Status do Pedido'
	oModel:GetModel( 'MODEL_RESUMO' ):SetDescription( STR0024 ) // 'Dados do Resumo Pedido de Venda de Montadora'

	oModel:GetModel('MODEL_VX0'):SetOptional(.T.)
	oModel:GetModel('MODEL_VRL'):SetOptional(.T.)

	oModel:GetModel('MODEL_RESUMO'  ):SetOnlyQuery( .T. )
	oModel:GetModel('MODEL_RESUMO'  ):SetOptional( .T. )

	oModel:GetModel('MODEL_VRLRES'  ):SetOnlyQuery( .T. )
	oModel:GetModel('MODEL_VRLRES'  ):SetOptional( .T. )

	oModel:SetRelation('MODEL_VRK', { { 'VRK_FILIAL' , 'xFilial("VRK")' } , { 'VRK_PEDIDO' , 'VRJ_PEDIDO' } } , 'VRK_FILIAL+VRK_PEDIDO' )
	oModel:SetRelation('MODEL_VRL',;
		{ ;
			{ 'VRL_FILIAL' , 'xFilial("VRL")' } ,;
			{ 'VRL_PEDIDO' , 'VRJ_PEDIDO' } ,;
			{ 'VRL_ITEPED' , 'VRK_ITEPED' } ;
		} ,;
		'VRL_FILIAL+VRL_PEDIDO+VRL_ITEPED' )

	oModel:SetRelation('MODEL_VRLRES',;
		{ ;
			{ 'VRL_FILIAL' , 'xFilial("VRL")' } ,;
			{ 'VRL_PEDIDO' , 'VRJ_PEDIDO' } ;
		} ,;
		'VRL_FILIAL+VRL_PEDIDO' )

	oModel:SetRelation('MODEL_VX0', { { 'VX0_FILIAL' , 'xFilial("VX0")' } , { 'VX0_CODIGO' , 'VRJ_LOGVX0' } } , 'VX0_FILIAL+VX0_CODIGO' )

	oModel:AddRules( 'MODEL_VRJ', 'VRJ_LOJA', 'MODEL_VRJ', 'VRJ_CODCLI', 3)
	oModel:AddRules( 'MODEL_VRJ', 'VRJ_LOJENT', 'MODEL_VRJ', 'VRJ_CLIENT', 3)
	oModel:AddRules( 'MODEL_VRJ', 'VRJ_LOJRET', 'MODEL_VRJ', 'VRJ_CLIRET', 3)
	oModel:AddRules( 'MODEL_VRL', 'VRL_E1LOJA', 'MODEL_VRL', 'VRL_E1CLIE', 3)

	If oModel:GetModel( 'MODEL_VRJ' ):HasField("VRJ_CLIALI")
		oModel:AddRules( 'MODEL_VRJ', 'VRJ_LOJALI', 'MODEL_VRJ', 'VRJ_CLIALI', 3)
	EndIf	

	oModel:AddRules( 'MODEL_VRK', 'VRK_GRUMOD', 'MODEL_VRK', 'VRK_CODMAR', 3)
	oModel:AddRules( 'MODEL_VRK', 'VRK_MODVEI', 'MODEL_VRK', 'VRK_CODMAR', 3)
	oModel:AddRules( 'MODEL_VRK', 'VRK_SEGMOD', 'MODEL_VRK', 'VRK_MODVEI', 3)

	oModel:GetModel( 'MODEL_VRL' ):SetUniqueLine( {"VRL_E1PREF" , "VRL_E1NUM" , "VRL_E1PARC" , "VRL_E1TIPO" })

	oModel:SetPrimaryKey( { "VRJ_FILIAL", "VRJ_PEDIDO" } )

	//If lDebug .and. ExistFunc("MVCLogEv")
	//	Conout("InstallEvent - MVCLogEv")
	//	oAuxLogEV := MVCLogEv():New("VEIA060")
	//	oModel:InstallEvent("LOG",,oAuxLogEV)
	//EndIf
	oModel:InstallEvent("PADRAO",, VEIA060EVDEF():New())

	// Removendo warning de compilacao
	If .f.
		VA0600133_AtuFiscalProduto()
	EndIf


Return oModel

/*/{Protheus.doc} ViewDef
View
@author Rubens
@since 28/12/2018
@version 1.0

@type function
/*/
Static Function ViewDef()

	Local oModel := FWLoadModel( 'VEIA060' )
	Local oStruVRJ := FWFormStruct( 2, 'VRJ' )
	Local oStruVRK := FWFormStruct( 2, 'VRK' )
	Local oStruVRL := FWFormStruct( 2, 'VRL' )
	Local oStruVRLRes := FWFormStruct( 2, 'VRL' )
	Local oStruVX0
	Local oStruResumo := oResModStruDef:GetView()
	Local oView

	//// VA060_SaidaConsole("ViewDef")


	oStruVRJ:RemoveField('VRJ_LOGVX0')
	oStruVRJ:RemoveField('VRJ_CODVRL')
	oStruVRJ:RemoveField('VRJ_TOTENT')
	oStruVRJ:RemoveField('VRJ_VALNEG')

	If lMostraLog
		oStruVX0 := FWFormStruct( 2, 'VX0' )
	EndIf
	oStruVRK:RemoveField('VRK_PEDIDO')

	oStruVRK:AddField( 'LEGENDA','01',' ','Legenda',, 'Get' ,'@BMP',,,.F.,,,,,,.T.,, )    
	oStruVRK:AddField(;
		'ITEMFISCAL',; // cIdField
		'ZY',; // cOrdem
		STR0015 ,; // cTitulo - 'Item Fiscal'
		STR0015 ,; // cDescric - 'Item Fiscal'
		{},; // aHelp
		'N',; // cTipo
		'@ 9999',; // cPicture
		NIL,; // bPictVar
		'  ',; // cLookUp
		.f. ,; // lCanChange,;
		NIL ,; // cFolder
		NIL ,; // cGroup
		NIL ,; // aComboValues
		NIL ,; // nMaxLenCombo
		NIL ,; // cIniBrow
		.t. ,; // lVirtual
		NIL ,; // cPictVar
		NIL ,; // lInsertLine
		NIL  ) // nWidth

	oStruVRK:AddField(;
		'B1COD',; // cIdField
		'ZZ' ,; // cOrdem
		RetTitle("B1_COD"),; // cTitulo
		RetTitle("B1_COD"),; // cDescric
		{},; // aHelp
		'C',; // cTipo
		'@!',; // cPicture
		NIL,; // bPictVar
		'  ',; // cLookUp
		.f. ,; // lCanChange,;
		NIL ,; // cFolder
		NIL ,; // cGroup
		NIL ,; // aComboValues
		NIL ,; // nMaxLenCombo
		NIL ,; // cIniBrow
		.t. ,; // lVirtual
		NIL ,; // cPictVar
		NIL ,; // lInsertLine
		NIL  ) // nWidth

	oStruVRK:AddField(;
		'VV2RECNO',; // cIdField
		'ZZ' ,; // cOrdem
		"VV2 RECNO",; // cTitulo
		"VV2 RECNO",; // cDescric
		{},; // aHelp
		'N',; // cTipo
		'@! 9999999999',; // cPicture
		NIL,; // bPictVar
		'  ',; // cLookUp
		.f. ,; // lCanChange,;
		NIL ,; // cFolder
		NIL ,; // cGroup
		NIL ,; // aComboValues
		NIL ,; // nMaxLenCombo
		NIL ,; // cIniBrow
		.t. ,; // lVirtual
		NIL ,; // cPictVar
		NIL ,; // lInsertLine
		NIL  ) // nWidth

	oStruVRK:AddField(;
		'STATPED',; // cIdField
		'ZZ' ,; // cOrdem
		STR0016,; // cTitulo - "Status Ped"
		STR0017,; // cDescric - "Status Pedido"
		{},; // aHelp
		'C',; // cTipo
		'!',; // cPicture
		NIL,; // bPictVar
		'  ',; // cLookUp
		.f. ,; // lCanChange,;
		NIL ,; // cFolder
		NIL ,; // cGroup
		NIL ,; // aComboValues
		NIL ,; // nMaxLenCombo
		NIL ,; // cIniBrow
		.t. ,; // lVirtual
		NIL ,; // cPictVar
		NIL ,; // lInsertLine
		NIL  ) // nWidth

	oStruVRL:RemoveField('VRL_CODIGO')
	oStruVRL:RemoveField('VRL_PEDIDO')
	oStruVRL:RemoveField('VRL_ITEPED')
	oStruVRL:RemoveField('VRL_E1FILI')
	oStruVRL:SetProperty("VRL_E1NUM", MVC_VIEW_CANCHANGE , .F. )
	oStruVRL:AddField( 'LEGENDA','01',' ','Legenda',, 'Get' ,'@BMP',,,.F.,,,,,,.T.,, )    
	oStruVRL:AddField(;
		'STATUS_FIN',; // cIdField
		'ZZ' ,; // cOrdem
		STR0025,; // cTitulo - "Status Fin."
		STR0025,; // cDescric - "Status Fin."
		{},; // aHelp
		'C',; // cTipo
		'',; // cPicture
		NIL,; // bPictVar
		'  ',; // cLookUp
		.f. ,; // lCanChange,;
		NIL ,; // cFolder
		NIL ,; // cGroup
		NIL ,; // aComboValues
		NIL ,; // nMaxLenCombo
		NIL ,; // cIniBrow
		.t. ,; // lVirtual
		NIL ,; // cPictVar
		NIL ,; // lInsertLine
		NIL  ) // nWidth

	oStruVRLRes:RemoveField('VRL_CODIGO')
	oStruVRLRes:RemoveField('VRL_PEDIDO')
	oStruVRLRes:AddField( 'LEGENDA','01',' ','Legenda',, 'Get' ,'@BMP',,,.F.,,,,,,.T.,, )    


	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField('VIEW_VRJ', oStruVRJ, 'MODEL_VRJ' )
	oView:AddGrid( 'VIEW_VRK', oStruVRK, 'MODEL_VRK' )
	oView:AddGrid( 'VIEW_VRL', oStruVRL, 'MODEL_VRL' )
	oView:AddGrid( 'VIEW_VRLRES', oStruVRLRes, 'MODEL_VRLRES' )
	oView:AddGrid( 'VIEW_RESUMO', oStruResumo, 'MODEL_RESUMO' )

	oView:CreateFolder( 'TELA_FOLDER_PRINCIPAL')
	oView:AddSheet('TELA_FOLDER_PRINCIPAL' , 'ABA_PRINCIPAL' , STR0026 ) // 'Pedido'
	oView:AddSheet('TELA_FOLDER_PRINCIPAL' , 'ABA_VEICULOS'  , STR0027 ) // 'Veículos'
	
	oView:CreateHorizontalBox( 'TELA_VRJ'    , 60 , , , 'TELA_FOLDER_PRINCIPAL', 'ABA_PRINCIPAL')
	oView:CreateHorizontalBox( 'TELA_FOLDER' , 40 , , , 'TELA_FOLDER_PRINCIPAL', 'ABA_PRINCIPAL')

	oView:CreateFolder( 'TELA_FOLDER_RESUMO', 'TELA_FOLDER')
	oView:AddSheet('TELA_FOLDER_RESUMO','ABA_RESUMO_MODELO', STR0028 ) // 'Resumo por Modelo'
	oView:AddSheet('TELA_FOLDER_RESUMO','ABA_RESUMO_FINANCEIRO', STR0029 ) // 'Resumo Financeiro'

	oView:CreateHorizontalBox( 'TELA_VRK' , 50 , , , 'TELA_FOLDER_PRINCIPAL', 'ABA_VEICULOS')
	oView:CreateHorizontalBox( 'TELA_VRL' , 50 , , , 'TELA_FOLDER_PRINCIPAL', 'ABA_VEICULOS')

	oView:CreateHorizontalBox( 'TELA_RESUMO_MODELO' , 100, , .F. , 'TELA_FOLDER_RESUMO', 'ABA_RESUMO_MODELO')

	oView:CreateHorizontalBox( 'TELA_RESUMO_FINANCEIRO', 100, , , 'TELA_FOLDER_RESUMO', 'ABA_RESUMO_FINANCEIRO')

	oView:SetOwnerView( 'VIEW_VRJ', 'TELA_VRJ' )
	oView:SetOwnerView( 'VIEW_VRK', 'TELA_VRK' )
	oView:SetOwnerView( 'VIEW_VRL', 'TELA_VRL' )
	oView:SetOwnerView( 'VIEW_RESUMO', 'TELA_RESUMO_MODELO' )
	oView:SetOwnerView( 'VIEW_VRLRES', 'TELA_RESUMO_FINANCEIRO' )

	oView:AddIncrementField( 'VIEW_VRK', 'VRK_ITEPED' )

	If lMostraLog
		oView:AddGrid( 'VIEW_VX0', oStruVX0, 'MODEL_VX0' )
		oView:AddSheet('TELA_FOLDER_RESUMO','ABA_RESUMO_VX0',STR0028) // 'Resumo por Modelo'
		oView:CreateHorizontalBox( 'TELA_VX0', 100, , , 'TELA_FOLDER_RESUMO', 'ABA_RESUMO_VX0')
		oView:SetOwnerView( 'VIEW_VX0', 'TELA_VX0' )
		oView:SetViewProperty("VIEW_VX0", "ONLYVIEW")
	EndIf

	oView:addUserButton('Consulta Modelo' ,'', { |oView| VA0600013_ConsultaModelo(oView)  },,VK_F10, { MODEL_OPERATION_INSERT, MODEL_OPERATION_UPDATE } , .t. )
	oView:addUserButton('Relaciona Chassi','', { |oView| VA0600213_RelacionaChassi(oView) },,VK_F11, { MODEL_OPERATION_INSERT, MODEL_OPERATION_UPDATE } , .t. )
	//If lDebug
	//	oView:addUserButton('DEBUG - Valores do Fiscal','', { |oView| u_verFiscal(oView:GetModel("MODEL_VRK"):GetLine(), oView:GetModel("MODEL_VRK"):GetQTDLine()) })
	//	oView:addUserButton('Saida Console','', { |oView| VA0600___VisualizaASaidaConsole(oView) })
	//EndIf

	If ( ExistBlock("VA060ABT") )
		ExecBlock("VA060ABT",.f.,.f.,{ oView } )
	EndIf

	oView:SetNoInsertLine('VIEW_RESUMO')
	oView:SetNoDeleteLine('VIEW_RESUMO')

	oView:SetNoInsertLine('VIEW_VRLRES')
	oView:SetNoDeleteLine('VIEW_VRLRES')
	oView:SetViewProperty("VIEW_VRLRES", "ONLYVIEW")

//	oView:SetViewProperty("VIEW_VRK","ENABLENEWGRID")
//	oView:SetViewProperty("VIEW_VRK", "GRIDSEEK", {.T.})

//	oView:SetAfterViewActivate( { |oView| CarregaFiscal(oView) })

	oView:SetFieldAction("VRJ_CODCLI", { |oView, cIDView, cField, xValue| VA0600043_FActVRJClienteLoja( oView, cIDView, cField, xValue ) } )
	oView:SetFieldAction("VRJ_LOJA", { |oView, cIDView, cField, xValue| VA0600043_FActVRJClienteLoja( oView, cIDView, cField, xValue ) } )

//	oView:SetFieldAction("VRK_VALMOV", { |oView, cIDView, cField, xValue| VA0600063_FActVRKVALMOV( oView, cIDView, cField, xValue ) } )

	oView:SetViewAction("DELETELINE"  , { |oView,cIdView,nNumLine| VA0600113_VActDeleteLine( oView,cIdView,nNumLine ) } )
	oView:SetViewAction("UNDELETELINE", { |oView,cIdView,nNumLine| VA0600123_VActUNDeleteLine( oView,cIdView,nNumLine ) } )

	oView:EnableTitleView('VIEW_VRK', STR0030 ) // 'Modelos/Veículos do pedido'
	oView:EnableTitleView('VIEW_VRL', STR0031 ) // 'Negociação para o veículo selecionado'

Return oView

/*/{Protheus.doc} VA0600013_ConsultaModelo
Consulta de Veículos para Adicionar no pedido
@author Rubens
@since 28/12/2018
@version 1.0
@param oView, object, descricao
@type function
/*/
Static Function VA0600013_ConsultaModelo(oView)
	Local oModel := FWModelActive()

	Local oModelVRK := oModel:GetModel("MODEL_VRK")
	Local oModelVRL := oModel:GetModel("MODEL_VRL")
	Local oModelRES := oModel:GetModel("MODEL_RESUMO")

	Local aRetFiltro
	Local nLinRet
	Local lAddLine := .t.
	Local nLinhaAtual := oModelVRK:Length()
	Local aSaveLines	:= FWSaveRows()

	Local nValorVeic := 0

	Local cCodCli := ""
	Local cLojCli := ""

	Local cOperPad := ""
	Local cTESPad  := ""

	If ! oModel:GetValue("MODEL_VRJ","VRJ_STATUS") == "A"
		FMX_HELP("VA060ERR007",STR0032) // "Status do pedido não permite a inclusão de novos veículos."
		Return .t.
	EndIf

	If !MaFisFound("NF")
		FMX_HELP("VA060ERR001", STR0033 , STR0034) // "Cliente não informado no pedido." // "Por favor informar um código de cliente."
		Return .t.
	EndIf

	Pergunte("VEIA060",.f.,,,,.f.)
	cOperPad := MV_PAR01
	cTESPad  := MV_PAR02

	cCodCli := MaFisRet(,"NF_CODCLIFOR")
	cLojCli := MaFisRet(,"NF_LOJA")

	aRetFiltro := VEIC010()

	If Len(aRetFiltro) == 1 .and. Empty(aRetFiltro[1,3])
		Return .t.
	EndIf

	dbSelectArea("VRK")

	oModelVRK:GoLine(nLinhaAtual)
	If Empty(oModelVRK:GetValue("VRK_MODVEI")) .and. Empty(oModelVRK:GetValue("VRK_CHAINT")) .and. oModelVRK:GetValue("VRK_CANCEL") $ " /0" .and. ! oModelVRK:isDeleted()
		lAddLine := .f.
	EndIf

	nItemFiscal := VA0600103_ProximoItemFiscal()

	CursorWait()
	For nLinRet := 1 to Len(aRetFiltro)

		If lAddLine
			If oModelVRK:AddLine() == nLinhaAtual
				aErro := oModel:GetErrorMessage(.T.)
				FMX_HELP(aErro[MODEL_MSGERR_ID],;
					STR0035 + CRLF + ; // "Não foi possível adicionar itens."
					STR0036 + ": " + AllToChar(nLinhaAtual) + CRLF + CRLF +; // Linha atual
					aErro[MODEL_MSGERR_IDFIELDERR ] + CRLF +;
					aErro[MODEL_MSGERR_ID         ] + CRLF +;
					aErro[MODEL_MSGERR_MESSAGE    ])
				Exit
			EndIf
			oView:Refresh("VIEW_VRK")
		Else
			lAddLine := .t.
		EndIf

		nLinhaAtual := oModelVRK:Length()
		dbSelectArea("VRK")

		nValorVeic := aRetFiltro[nLinRet, 09]

		oModelVRK:LoadValue("VRK_CODMAR", aRetFiltro[nLinRet, 03])
		oModelVRK:LoadValue("VRK_GRUMOD", aRetFiltro[nLinRet, 04])

		// VA060_SaidaConsole("VA0600013_ConsultaModelo - VRK_MODVEI - " + cValToChar(aRetFiltro[nLinRet, 05]))
		If ! oModelVRK:Setvalue( "VRK_MODVEI", aRetFiltro[nLinRet, 05])
			VA0600293_MostraErrorModel( oModel )
		EndIf

		If ! Empty(aRetFiltro[nLinRet, 10])
			// VA060_SaidaConsole("VA0600013_ConsultaModelo - VRK_SEGMOD - " + cValToChar(aRetFiltro[nLinRet, 10]))
			If ! oModelVRK:Setvalue( "VRK_SEGMOD", aRetFiltro[nLinRet, 10])
				VA0600293_MostraErrorModel( oModel )
			EndIf
		EndIf

		// Atualiza valor do modelo para o correto processamento do resumo quando o usuario preenche o ano de fab/mod na consulta
		// VA060_SaidaConsole("VA0600013_ConsultaModelo - VRK_VALTAB - " + cValToChar(nValorVeic))
		oModelVRK:SetValue("VRK_VALTAB", nValorVeic)

		If Len(aRetFiltro[nLinRet]) > 10 .and. ! Empty(aRetFiltro[nLinRet, 11])
			// VA060_SaidaConsole("VA0600013_ConsultaModelo - VRK_FABMOD - " + cValToChar(aRetFiltro[nLinRet, 11]))
			If ! oModelVRK:Setvalue( "VRK_FABMOD", aRetFiltro[nLinRet, 11])
				VA0600293_MostraErrorModel( oModel )
			EndIf

			If oModelVRK:GetValue("VRK_VALTAB") <> nValorVeic
				// VA060_SaidaConsole("VA0600013_ConsultaModelo - VRK_VALTAB - " + cValToChar(nValorVeic))
				oModelVRK:SetValue("VRK_VALTAB", nValorVeic)
			EndIf
		EndIf

	Next nLinRet

	VA0600033_FiscalAtualizaCabecalho()

	If Empty(FWFldGet("VRL_E1CLIE"))
		oModelVRL:ClearData(.t.,.t.)
	EndIf
	
	FWRestRows(aSaveLines)

	// Posiciona a Grid de Resumo por Modelo 
	aAuxSeekParam := {{ "RESCODMAR" , aRetFiltro[ 01, 03] },;
							{ "RESMODVEI" , aRetFiltro[ 01, 05] }}
	If ! Empty(aRetFiltro[ 01, 10])
		AADD( aAuxSeekParam , { "RESSEGMOD" , aRetFiltro[ 01, 10] } )
	EndIf
	If Len(aRetFiltro[ 01]) > 10 .and. ! Empty(aRetFiltro[ 01, 11])
		AADD( aAuxSeekParam , { "RESFABMOD" , aRetFiltro[ 01, 11] } )
	EndIf
	oModelRes:SeekLine( aAuxSeekParam , .f. , .t.)
	//

	oView:Refresh()

	CursorArrow()


Return

/*/{Protheus.doc} VA0600043_FActVRJClienteLoja
Field Action do Código de Cliente / Loja

@author Rubens
@since 28/12/2018
@version 1.0
@param oView, object, descricao
@param cIDView, characters, descricao
@param cField, characters, descricao
@param xValue, , descricao
@type function
/*/
Static Function VA0600043_FActVRJClienteLoja(oView, cIDView, cField, xValue)

	Local cCliente , cLoja
	Local oModel := FWModelActive()

	If cField == "VRJ_CODCLI"
		cLoja := oModel:GetModel("MODEL_VRJ"):GetValue("VRJ_LOJA")
		If Empty(cLoja)
			Return
		EndIf
		cCliente := xValue
	Else
		cCliente := oModel:GetModel("MODEL_VRJ"):GetValue("VRJ_CODCLI")
		cLoja := xValue
	EndIf

	CursorWait()

	If MaFisFound("NF")
		bRefresh := { || .t. }
		MaFisRef("NF_CODCLIFOR","VA060",cCliente)
		MaFisRef("NF_LOJA","VA060",cLoja)
		VA0600083_FiscalAtuCampoIT(oView)
	Else
		VA0600023_IniFiscal(cCliente, cLoja)
	EndIf

	CursorArrow()

Return


/*/{Protheus.doc} VA0600023_IniFiscal
Inicializa Fiscal

@author Rubens
@since 28/12/2018
@version 1.0
@param cCliente, characters, descricao
@param cLoja, characters, descricao
@type function
/*/
Function VA0600023_IniFiscal(cCliente, cLoja)
	CursorWait()
	If MaFisFound("NF")
		Return
	EndIf

	SA1->(dbSetOrder(1))
	SA1->(MsSeek(xFilial("SA1") + cCliente + cLoja ))

	// VA060_SaidaConsole("VA0600023_IniFiscal " + cCliente + " - " + cLoja)

	MaFisIni(cCliente, cLoja, 'C', 'N', SA1->A1_TIPO, MaFisRelImp("VA060", {"VRJ","VRK"}) )
	CursorArrow()
Return

/*/{Protheus.doc} MenuDef
Menu
@author Rubens
@since 28/12/2018
@version 1.0

@type function
/*/
Static Function MenuDef()
	Local aRotina := {}

	Local nPosPE
	Local aRotPE

	ADD OPTION aRotina TITLE STR0037 ACTION 'VIEWDEF.VEIA060' OPERATION 2 ACCESS 0 // 'Visualizar'
	ADD OPTION aRotina TITLE STR0038 ACTION 'VIEWDEF.VEIA060' OPERATION 3 ACCESS 0 // 'Incluir'
	ADD OPTION aRotina TITLE STR0039 ACTION 'VIEWDEF.VEIA060' OPERATION 4 ACCESS 0 // 'Alterar'
	ADD OPTION aRotina TITLE STR0040 ACTION 'VEIA060A' OPERATION 4 ACCESS 0 // 'Avançar Pedido'
	ADD OPTION aRotina TITLE STR0041 ACTION 'VEIA060B' OPERATION 4 ACCESS 0 // 'Cancelar Pedido'
	ADD OPTION aRotina TITLE STR0042 ACTION 'VA0600273_TelaFaturarAtendimentos' OPERATION 4 ACCESS 0 // 'Faturar Atendimentos'
	ADD OPTION aRotina TITLE STR0043 ACTION 'VA0600383_Conhecimento' OPERATION 4 ACCESS 0 // 'Conhecimento'
	ADD OPTION aRotina TITLE STR0044 ACTION 'VA0600453_DesvincularChassi' OPERATION 4 ACCESS 0 // 'Desvincular Chassi'

	If ExistBlock("PROPPED")
		ADD OPTION aRotina TITLE STR0045 ACTION 'VA0600423_TelaImpressaoProposta' OPERATION 2 ACCESS 0 // 'Impressão Proposta'
	EndIf

 	If ExistBlock("VA060MNU")
		aRotPE := ExecBlock("VA060MNU",.f.,.f.)
		For nPosPE := 1 to Len(aRotPE)
			AADD(aRotina,aClone(aRotPE[nPosPE]))
		Next nPosPE
	EndIf


Return aRotina

/*/{Protheus.doc} VA0600033_FiscalAtualizaCabecalho
Atualiza os campos da VRJ que tem relação com Fiscal
@author Rubens
@since 28/12/2018
@version 1.0

@type function
/*/
Function VA0600033_FiscalAtualizaCabecalho()
	Local oModel := FWModelActive()
	Local nPosVRk
	Local oModelVRK
	Local nQtdVei := 0

	// VA060_SaidaConsole("VA0600033_FiscalAtualizaCabecalho")

	aEval( aVRJ_RelImp , { |x| oModel:LoadValue("MODEL_VRJ", x[2], MaFisRet(,x[3]), .t.) } )

	If oModel:GetModel("MODEL_VRJ"):HasField("VRJ_QTDVEI")
		oModelVRK := oModel:GetModel("MODEL_VRK")
		For nPosVRk := 1 to oModelVRK:Length()
			If oModelVRK:GetValue("VRK_CANCEL", nPosVRk) == "1" .or. oModelVRK:isDeleted(nPosVRk)
				Loop
			EndIf
			nQtdVei++
		Next nPosVRk
		oModel:LoadValue("MODEL_VRJ","VRJ_QTDVEI", nQtdVei) 
	EndIf
Return

/*/{Protheus.doc} VA0600053_RelacaoImpostos
Cria array com os campos que possuem relação com Fiscal
@author Rubens
@since 28/12/2018
@version 1.0

@type function
/*/
Function VA0600053_RelacaoImpostos()
	If aVRJ_RelImp == NIL
		aVRJ_RelImp := MaFisRelImp("VA060", {"VRJ"})
		aVRK_RelImp := MaFisRelImp("VA060", {"VRK"})
	EndIf
Return

/*/{Protheus.doc} VA0600063_FActVRKVALMOV
Field Action do campo de Valor do Movimento do item do pedido de venda
@author Rubens
@since 28/12/2018
@version 1.0
@param oView, object, descricao
@param cIDView, characters, descricao
@param cField, characters, descricao
@param xValue, , descricao
@type function
/*/
Function VA0600063_FActVRKVALMOV(oView, cIDView, cField, xValue)
	VA0600033_FiscalAtualizaCabecalho()
Return


/*/{Protheus.doc} VA0600073_FiscalAdProduto
Adiciona um item no ambiente fiscal
@author Rubens
@since 28/12/2018
@version 1.0
@return ${return}, ${return_description}
@param nItemFiscal, numeric, descricao
@param nValorVeic, numeric, descricao
@param cTES, characters, descricao
@param cB1Cod, characters, descricao
@param lRecalcFiscal, logical, descricao
@param nValorMov, numeric, descricao
@type function
/*/
Function VA0600073_FiscalAdProduto(nItemFiscal, nValorVeic, cTES, cB1Cod, lRecalcFiscal, nValorMov )

	Default nItemFiscal := VA0600103_ProximoItemFiscal()
	Default cB1Cod := "" // Se nao passar B1_COD, o produto ja deve estar posicionado
	Default lRecalcFiscal := .t.
	Default nValorMov := nValorVeic

	Private bRefresh := { || .t. }


	SF4->(dbSetOrder(1))
	SF4->(MsSeek(xFilial("SF4") + cTES))

	If ! Empty(cB1Cod)
		SB1->(dbSetOrder(1))
		SB1->(MsSeek(xFilial("SB1") + cB1Cod))
	EndIf

	N := nItemFiscal

	// VA060_SaidaConsole("VA0600073_FiscalAdProduto " + cB1Cod + " - " + SB1->B1_COD)

	MaFisIniLoad(nItemFiscal,;
		{ SB1->B1_COD,; // IT_PRODUTO
			cTES,; // IT_TES
			Space(TamSX3("D1_CODISS")[1]),; // IT_VALISS - Valor do ISS do item sem aplicar o arredondamento
			1,; // IT_QUANT - Quantidade do Item
			"",;// IT_NFORI - Numero da NF Original
			"",;// IT_SERORI - Serie da NF Original
			SB1->(RecNo()) ,;  // IT_RECNOSB1
			SF4->(RecNo()) ,;  // IT_RECNOSF4
			0 })        //IT_RECORI

	MaFisLoad("IT_PRODUTO"  , SB1->B1_COD , nItemFiscal)
	MaFisLoad("IT_QUANT"    , 1           , nItemFiscal)
	MaFisLoad("IT_TES"      , cTES        , nItemFiscal)
	MaFisLoad("IT_PRCUNI"   , nValorVeic  , nItemFiscal)
	MaFisLoad("IT_VALMERC"  , nValorMov   , nItemFiscal)
//		MaFisLoad("IT_DESCONTO" , oGetDetVO3:aCols[nCntFor,DVO3VALDES],n)
	MaFisRecal("",nItemFiscal)

	// Finaliza a carga dos itens Fiscais
	// 1-(default) Executa o recalculo de todos os itens para efetuar a atualizacao do cabecalho
	// 2-Executa a soma do item para atualizacao do cabecalho
	MaFisEndLoad(nItemFiscal, IIf( lRecalcFiscal , 1, 2 ) )
	//

Return nItemFiscal

/*/{Protheus.doc} VA0600083_FiscalAtuCampoIT
Atualiza a GRID de acordo com os campos do fiscal
@author Rubens
@since 28/12/2018
@version 1.0

@param oView, object, descricao
@type function
/*/
Function VA0600083_FiscalAtuCampoIT(oView)
	Local oModel := FWModelActive()
	Local oModelVRK := oModel:GetModel("MODEL_VRK")
	Local nLinhaAtual := 1
	Local nLinhaTotal := oModelVRK:Length()
	Local aSaveLines := FWSaveRows()

	For nLinhaAtual := 1 to nLinhaTotal
		// VA060_SaidaConsole("Atualizando Model a partir do Fiscal - " + cValToChar(nLinhaAtual) + " - " + cValToChar( oModelVRK:IsInserted(nLinhaAtual) ))
		oModelVRK:GoLine(nLinhaAtual)
		If oModelVRK:GetValue("VRK_VALMOV") <> 0
			VA0600143_FiscalAtuCampoLinhaAtual(oModel, oModelVRK)
		EndIf
	Next nLinhaAtual
	// VA060_SaidaConsole(" ")
	FWRestRows(aSaveLines)
	oView:Refresh("VIEW_VRK")
Return

/*/{Protheus.doc} VA0600093_VeiFis
Atualiza variavel N de acordo com o item fiscal relacionada a linha da grid
@author Rubens
@since 28/12/2018
@version 1.0

@type function
/*/
Function VA0600093_VeiFis()
	Local oModel := FWModelActive()
	N := oModel:GetValue("MODEL_VRK","ITEMFISCAL")
//	// VA060_SaidaConsole("VA0600093_VeiFis - " + cValToChar(N))
Return N


//Function VA060_SaidaConsole(Mensagem, cPrefixo)
//	Default cPrefixo := "VEIA060"
//	If lDebug
//		If oLogger == NIL
//			oLogger := tkLogger():New()
//			oLogger:SetComment("VEIA060")
//		EndIf
//		oLogger:Log(PadR(cPrefixo,12," ") + " | " + Mensagem )
//		//Conout("| VEIA060      | " + Time() + " |" + " " + Mensagem)
//		//AADD( aSaidaConsole , {"| VEIA060      | " + Time() + " |" + " " + Mensagem })
//	EndIf
//Return .t.

/*/{Protheus.doc} VA0600103_ProximoItemFiscal
Procura o proximo numero do item fiscal para atualizar o FISCAL
@author Rubens
@since 28/12/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function VA0600103_ProximoItemFiscal()

	Local oModel := FWModelActive()
	Local oModelVRK := oModel:GetModel("MODEL_VRK")
	Local nLinhaAtual := 0
	Local nLinhaTotal := oModelVRK:Length()
	Local nProxItemFiscal := 0

	For nLinhaAtual := 1 to nLinhaTotal
		If oModelVRK:GetValue("ITEMFISCAL", nLinhaAtual) > nProxItemFiscal
			nProxItemFiscal := oModelVRK:GetValue("ITEMFISCAL", nLinhaAtual)
		EndIf
	Next nLinhaAtual

	nProxItemFiscal++

	If Len(aHeader) > 0
		aHeader := {}
	EndIf

Return nProxItemFiscal

/*/{Protheus.doc} VA0600113_VActDeleteLine
Atualiza campos do cabecalho do pedido apos a exclusao de uma linha da grid
@author Rubens
@since 28/12/2018
@version 1.0
@param oView, object, descricao
@param cIdView, characters, descricao
@param nNumLine, numeric, descricao
@type function
/*/
Static Function VA0600113_VActDeleteLine( oView,cIdView,nNumLine )
	VA0600033_FiscalAtualizaCabecalho()
	// VA060_SaidaConsole("VA0600113_VActDeleteLine - Atualizando VIEW - DELETE")
Return

/*/{Protheus.doc} VA0600123_VActUNDeleteLine
Atualiza campos do cabecalho do pedido apos a recuperar uma linha da grid
@author Rubens
@since 28/12/2018
@version 1.0

@param oView, object, descricao
@param cIdView, characters, descricao
@param nNumLine, numeric, descricao
@type function
/*/
Static Function VA0600123_VActUNDeleteLine( oView,cIdView,nNumLine )
	VA0600033_FiscalAtualizaCabecalho()
	// VA060_SaidaConsole("VA0600123_VActUNDeleteLine - Atualizando VIEW - UNDELETE")
Return

Static Function VA0600133_AtuFiscalProduto()

Return lRetorno


/*/{Protheus.doc} VA0600143_FiscalAtuCampoLinhaAtual
Atualiza campos da linha da grid atual de acordo com o FISCAL
@author Rubens
@since 28/12/2018
@version 1.0
@return ${return}, ${return_description}
@param nLinhaAtual, numeric, descricao
@type function
/*/
Function VA0600143_FiscalAtuCampoLinhaAtual(oModel, oModelVRK)
	Local nItemFiscal
	Local nPosAtu

	Default oModel := FWModelActive()
	Default oModelVRK := oModel:GetModel("MODEL_VRK")

	nItemFiscal := oModelVRK:GetValue("ITEMFISCAL")

	For nPosAtu := 1 to Len(aVRK_RelImp)
		oModelVRK:LoadValue(aVRK_RelImp[nPosAtu][2] , MaFisRet(nItemFiscal,aVRK_RelImp[nPosAtu][3]), .t.)
	Next nPosAtu

Return

/*/{Protheus.doc} VA0600153_LoadVRK
Load da VRK
@author Rubens
@since 28/12/2018
@version 1.0
@return ${return}, ${return_description}
@param oSubModel, object, descricao
@type function
/*/
//Function VA0600153_LoadVRK(oSubModel)
//	Local oModel := FWModelActive()
//	Local nOperation := oModel:GetOperation()
//
//	Local oStruct := oSubModel:getstruct()
//	Local aFields := oStruct:GetFields()
//	Local aRetorno := FormLoadGrid(oSubModel)
//
//	Local cMVMIL0010 := GetNewPar("MV_MIL0010","0")
//	Local cAuxGruVei := PadR( AllTrim(GetMv("MV_GRUVEI")) , TamSx3("B1_GRUPO")[1] )
//
//	Local nPosB1COD  := aScan(aFields , { |x| x[MVC_MODEL_IDFIELD] == "B1COD" })
//	Local nPosCHAINT := aScan(aFields , { |x| x[MVC_MODEL_IDFIELD] == "VRK_CHAINT" })
//	Local nPosCODMAR := aScan(aFields , { |x| x[MVC_MODEL_IDFIELD] == "VRK_CODMAR" })
//	Local nPosMODVEI := aScan(aFields , { |x| x[MVC_MODEL_IDFIELD] == "VRK_MODVEI" })
//	Local nPosSEGMOD := aScan(aFields , { |x| x[MVC_MODEL_IDFIELD] == "VRK_SEGMOD" })
//	Local nPosVALTAB := aScan(aFields , { |x| x[MVC_MODEL_IDFIELD] == "VRK_VALTAB" })
//	Local nPosVALMOV := aScan(aFields , { |x| x[MVC_MODEL_IDFIELD] == "VRK_VALMOV" })
//	Local nPosCODTES := aScan(aFields , { |x| x[MVC_MODEL_IDFIELD] == "VRK_CODTES" })
//	Local nPosCANCEL := aScan(aFields , { |x| x[MVC_MODEL_IDFIELD] == "VRK_CANCEL" })
//	Local nPosITEMFISCAL := aScan(aFields , { |x| x[MVC_MODEL_IDFIELD] == "ITEMFISCAL" })
//	Local nPosVV2RECNO := aScan(aFields , { |x| x[MVC_MODEL_IDFIELD] == "VV2RECNO" })
//
//	Local nLinhaAtual
//	Local nLinhaTotal := Len(aRetorno)
//	Local nItemFiscal := 0
//
//	VV2->(dbSetOrder(1))
//
//	For nLinhaAtual := 1 to nLinhaTotal
//
//		If aRetorno[ nLinhaAtual ][2][ nPosCANCEL ] == "1"
//			Loop
//		EndIf
//
//		cCodMar := aRetorno[ nLinhaAtual ][2] [nPosCODMAR ]
//		cModVei := aRetorno[ nLinhaAtual ][2] [nPosMODVEI ]
//		cSegMod := aRetorno[ nLinhaAtual ][2] [nPosSEGMOD ]
//
//		lAddFiscal := .f.
//		If ! Empty(aRetorno[ nLinhaAtual ][2][nPosCHAINT])
//			If FGX_VV1SB1("CHAINT", aRetorno[ nLinhaAtual ][2][nPosCHAINT] , cMVMIL0010 , cAuxGruVei )
//				aRetorno[nLinhaAtual][2][nPosB1COD] := SB1->B1_COD
//				lAddFiscal := .t.
//			EndIf
//		EndIf
//		If ! lAddFiscal 
//			If FGX_VV2SB1( cCodMar , cModVei , cSegMod)
//				aRetorno[nLinhaAtual][2][nPosB1COD] := SB1->B1_COD
//				lAddFiscal := .t.
//			EndIf
//		EndIf
//
//		If VV2->(MsSeek(xFilial("VV2") + cCodMar + cModVei + cSegMod))
//			aRetorno[ nLinhaAtual ][2] [nPosVV2RECNO ] := VV2->(Recno())
//		EndIf
//
//		If lAddFiscal
//			
//			nItemFiscal++
//
//			VA0600073_FiscalAdProduto(;
//				nItemFiscal,; // nItemFiscal
//				aRetorno[ nLinhaAtual ][2][ nPosVALTAB ],; // nValorVeic
//				aRetorno[ nLinhaAtual ][2][ nPosCODTES ],; // cTES
//				SB1->B1_COD,; // cB1Cod
//				( nLinhaAtual == nLinhaTotal ),; // lRecalcFiscal
//				aRetorno[ nLinhaAtual ][2][ nPosVALMOV ] ) // nValorMov
//
//			aRetorno[ nLinhaAtual ][2][nPosITEMFISCAL] := nItemFiscal
//
//		EndIf
//
//
//	Next nLinhaAtual
//
//	If nOperation <> MODEL_OPERATION_DELETE .and. nOperation <> MODEL_OPERATION_VIEW
//		VA0600033_FiscalAtualizaCabecalho()
//	EndIf
//
//Return aRetorno

/*/{Protheus.doc} VA0600163_LoadVRJ
Load da VRJ
@author Rubens
@since 28/12/2018
@version 1.0
@return ${return}, ${return_description}
@param oSubModel, object, descricao
@type function
/*/
Function VA0600163_LoadVRJ(oSubModel)
	Local aRetorno := FormLoadField(oSubModel)
	Local oStruct := oSubModel:getstruct()
	Local aFields := oStruct:GetFields()

	cCodCli := aRetorno[1,aScan(aFields , { |x| x[MVC_MODEL_IDFIELD] == "VRJ_CODCLI" })]
	cLoja   := aRetorno[1,aScan(aFields , { |x| x[MVC_MODEL_IDFIELD] == "VRJ_LOJA" })]

	VA0600023_IniFiscal(cCodCli, cLoja)

Return aRetorno

/*/{Protheus.doc} VA0600173_GerarAtendimento
Gera um atendimento para cada linha do pedido de venda
@author Rubens
@since 28/12/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
FUNCTION VA0600173_GerarAtendimento()

	Local lRetorno

	If ! MsgYesNo(STR0046) // "Deseja gerar atendimento para os itens do pedido"
		Return .f.
	EndIf

	oModel := FWLoadModel( 'VEIA060' )
	oModel:GetModel("MODEL_VRK"):SetLoadFilter(," VRK_NUMTRA = ' ' AND VRK_CANCEL IN (' ','0') ")
	oModel:SetOperation( MODEL_OPERATION_UPDATE )
	If !oModel:Activate()
		aErro := oModel:GetErrorMessage(.T.)
		MsgInfo(aErro[6])
		Return .f.
	EndIf

	lRetorno := VA0600183_IntegraVEIXX002(oModel)

	oModel:DeActivate()

Return lRetorno



/*/{Protheus.doc} VA0600183_IntegraVEIXX002
Integração com VEIXX002
@author Rubens
@since 28/12/2018
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type function
/*/
Function VA0600183_IntegraVEIXX002(oModel)

	Local aAutoVV0 := {}
	Local aAutoVV9 := {}
	Local aAutoVVA := {} // Campos Itens
	Local aAutoIt
	Local aAutoPagto := {} // Campos Pagamento
	Local aAutoPg
	Local lProcessar := .f.

	Local oModelVRJ := oModel:GetModel("MODEL_VRJ")
	Local oModelVRK := oModel:GetModel("MODEL_VRK")
	Local oModelVRL := oModel:GetModel("MODEL_VRL")

	Local nLinhaAtual
	Local nLinhaFinan
	Local cBkpFunName := FunName()
	Local lPagNegociado := .f.

	Local lVA060ATE := ExistBlock("VA060ATE")

	For nLinhaAtual := 1 to oModelVRK:Length()
		If Empty(oModelVRK:GetValue("VRK_NUMTRA", nLinhaAtual)) .and. oModelVRK:GetValue("VRK_CANCEL", nLinhaAtual) <> "1"
			lProcessar := .t.
			Exit
		EndIf
	Next nLinhaAtual

	If lProcessar == .f.
		MsgInfo(STR0047) // "Itens já possuem atendimento gerado."
		Return .t.
	EndIf

	aAdd(aAutoVV9, { "VV9_CODCLI" , oModelVRJ:GetValue("VRJ_CODCLI") , NIL } )
	aAdd(aAutoVV9, { "VV9_LOJA"   , oModelVRJ:GetValue("VRJ_LOJA")   , NIL } )
	If VV9->(ColumnPos("VV9_VRKNUM"))
		aAdd(aAutoVV9, { "VV9_VRKNUM" , oModelVRJ:GetValue("VRJ_PEDIDO") , NIL } )
	EndIf
	If lVA060ATE
		aAutoVV9 := ExecBlock("VA060ATE",.f.,.f.,{ "VV9", oModelVRJ, aClone(aAutoVV9) })
	EndIf

	aAutoVV0 := {} // Campos Cabecalho
	aAdd(aAutoVV0,{"VV0_CODCLI"  ,oModelVRJ:GetValue("VRJ_CODCLI") , NIl })
	aAdd(aAutoVV0,{"VV0_LOJA"    ,oModelVRJ:GetValue("VRJ_LOJA")   , NIl })
	aAdd(aAutoVV0,{"VV0_TIPVEN"  ,oModelVRJ:GetValue("VRJ_TIPVEN")   , NIl })
	If ! Empty(oModelVRJ:GetValue("VRJ_CODVEN"))
		aAdd(aAutoVV0,{"VV0_CODVEN" , oModelVRJ:GetValue("VRJ_CODVEN") , NIl })
	EndIf
	If ! Empty(oModelVRJ:GetValue("VRJ_FORPAG"))
		aAdd(aAutoVV0,{"VV0_FORPAG" , oModelVRJ:GetValue("VRJ_FORPAG") , NIl })
	EndIf
	If ! Empty(oModelVRJ:GetValue("VRJ_CODTRA"))
		aAdd(aAutoVV0,{"VV0_CODTRA" , oModelVRJ:GetValue("VRJ_CODTRA") , NIl })
	EndIf
	If ! Empty(oModelVRJ:GetValue("VRJ_TPFRET"))
		aAdd(aAutoVV0,{"VV0_TPFRET" , oModelVRJ:GetValue("VRJ_TPFRET") , NIl })
	EndIf
	If oModelVRJ:GetValue("VRJ_DESACE") <> 0
		aAdd(aAutoVV0,{"VV0_DESACE" , oModelVRJ:GetValue("VRJ_DESACE") , NIl })
	EndIf
	If oModelVRJ:GetValue("VRJ_PESOL") <> 0
		aAdd(aAutoVV0,{"VV0_PESOL" , oModelVRJ:GetValue("VRJ_PESOL") , NIl })
	EndIf
	If oModelVRJ:GetValue("VRJ_PBRUTO") <> 0
		aAdd(aAutoVV0,{"VV0_PBRUTO" , oModelVRJ:GetValue("VRJ_PBRUTO") , NIl })
	EndIf
	If oModelVRJ:GetValue("VRJ_VOLUME") <> 0
		aAdd(aAutoVV0,{"VV0_VOLUME" , oModelVRJ:GetValue("VRJ_VOLUME") , NIl })
	EndIf
	If ! Empty(oModelVRJ:GetValue("VRJ_ESPECI"))
		aAdd(aAutoVV0,{"VV0_ESPECI" , oModelVRJ:GetValue("VRJ_ESPECI") , NIl })
	EndIf
	If ! Empty(oModelVRJ:GetValue("VRJ_NATURE"))
		aAdd(aAutoVV0,{"VV0_NATFIN" , oModelVRJ:GetValue("VRJ_NATURE") , NIl })
	EndIf
	If ! Empty(oModelVRJ:GetValue("VRJ_MENNOT"))
		aAdd(aAutoVV0,{"VV0_MENNOT" , oModelVRJ:GetValue("VRJ_MENNOT") , NIl })
	EndIf
	If ! Empty(oModelVRJ:GetValue("VRJ_MENPAD"))
		aAdd(aAutoVV0,{"VV0_MENPAD" , oModelVRJ:GetValue("VRJ_MENPAD") , NIl })
	EndIf
	If ! Empty(oModelVRJ:GetValue("VRJ_OBSENF"))
		aAdd(aAutoVV0,{"VV0_OBSENF" , oModelVRJ:GetValue("VRJ_OBSENF") , NIl })
	EndIf
	If ! Empty(oModelVRJ:GetValue("VRJ_CLIENT"))
		aAdd(aAutoVV0,{"VV0_CLIENT" , oModelVRJ:GetValue("VRJ_CLIENT") , NIl })
		aAdd(aAutoVV0,{"VV0_LOJENT" , oModelVRJ:GetValue("VRJ_LOJENT") , NIl })
	EndIf
	If ! Empty(oModelVRJ:GetValue("VRJ_CLIRET"))
		aAdd(aAutoVV0,{"VV0_CLIRET" , oModelVRJ:GetValue("VRJ_CLIRET") , NIl })
		aAdd(aAutoVV0,{"VV0_LOJRET" , oModelVRJ:GetValue("VRJ_LOJRET") , NIl })
	EndIf
	If oModelVRJ:HasField("VRJ_CLIALI")
		If ! Empty(oModelVRJ:GetValue("VRJ_CATVEN"))
			aAdd(aAutoVV0,{"VV0_CATVMA" , "1" , NIl })
			aAdd(aAutoVV0,{"VV0_CATVEN" , oModelVRJ:GetValue("VRJ_CATVEN") , NIl })
			aAdd(aAutoVV0,{"VV0_CLIALI" , oModelVRJ:GetValue("VRJ_CLIALI") , NIl })
			aAdd(aAutoVV0,{"VV0_LOJALI" , oModelVRJ:GetValue("VRJ_LOJALI") , NIl })
		EndIf
	EndIf

	If lVA060ATE
		aAutoVV0 := ExecBlock("VA060ATE",.f.,.f.,{ "VV0", oModelVRJ, aClone(aAutoVV0) })
	EndIf

	CursorWait()

	Begin Transaction
	Begin Sequence

		For nLinhaAtual := 1 to oModelVRK:Length()

			oModelVRK:GoLine(nLinhaAtual)

			If ! Empty(oModelVRK:GetValue("VRK_NUMTRA")) .or. oModelVRK:GetValue("VRK_CANCEL") == "1"
				Loop
			EndIf

			If Empty(oModelVRK:GetValue("VRK_CHAINT"))
				Loop
			EndIf

			aAutoVVA:= {} // Campos Itens
			aAutoIt := {}
			aAdd( aAutoIt , { 'VVA_VRKNUM' , oModelVRK:GetValue( 'VRK_PEDIDO' ) , NIL } ) // Devem ser os primeiros registros a serem gravados
			aAdd( aAutoIt , { 'VVA_VRKITE' , oModelVRK:GetValue( 'VRK_ITEPED' ) , NIL } ) // Devem ser os primeiros registros a serem gravados

			If Empty(oModelVRK:GetValue('VRK_CHASSI'))
				aAdd( aAutoIt , { 'VVA_CODMAR' , oModelVRK:GetValue( 'VRK_CODMAR' ) , NIL } )
				aAdd( aAutoIt , { 'VVA_GRUMOD' , oModelVRK:GetValue( 'VRK_GRUMOD' ) , NIL } )
				aAdd( aAutoIt , { 'VVA_MODVEI' , oModelVRK:GetValue( 'VRK_MODVEI' ) , NIL } )
				aAdd( aAutoIt , { 'VVA_SEGMOD' , oModelVRK:GetValue( 'VRK_SEGMOD' ) , NIL } )
			Else
				aAdd( aAutoIt , { 'VVA_CHASSI' , oModelVRK:GetValue( 'VRK_CHASSI' ) , NIL} )
			EndIf

			aAdd( aAutoIt , { 'VVA_CODTES' , oModelVRK:GetValue( 'VRK_CODTES' ) , NIL } )
			//aAdd( aAutoIt , { 'VVA_VALTAB' , oModelVRK:GetValue( 'VRK_VALTAB' ) , NIL } )
			aAdd( aAutoIt , { 'VVA_VALTAB' , oModelVRK:GetValue( 'VRK_VALMOV' ) , NIL } )
			//aAdd( aAutoIt , { 'VVA_VALMOV' , oModelVRK:GetValue( 'VRK_VALMOV' ) , NIL } )
			If VRK->(ColumnPos("VRK_CENCUS")) <> 0 .and. ! Empty( oModelVRK:GetValue( 'VRK_CENCUS' ) )
				aAdd( aAutoIt , { 'VVA_CENCUS' , oModelVRK:GetValue( 'VRK_CENCUS' ) , NIL } )
			EndIf
			If VRK->(ColumnPos("VRK_CONTA")) <> 0 .and. ! Empty(oModelVRK:GetValue( 'VRK_CONTA' ))
				aAdd( aAutoIt , { 'VVA_CONTA'  , oModelVRK:GetValue( 'VRK_CONTA'  ) , NIL } )
			EndIf
			If VRK->(ColumnPos("VRK_ITEMCT")) <> 0 .and. ! Empty(oModelVRK:GetValue( 'VRK_ITEMCT' ))
				aAdd( aAutoIt , { 'VVA_ITEMCT' , oModelVRK:GetValue( 'VRK_ITEMCT' ) , NIL } )
			EndIf
			If VRK->(ColumnPos("VRK_CLVL")) <> 0 .and. ! Empty(oModelVRK:GetValue( 'VRK_CLVL' ))
				aAdd( aAutoIt , { 'VVA_CLVL'   , oModelVRK:GetValue( 'VRK_CLVL'   ) , NIL } )
			EndIf
			If lVA060ATE
				aAutoIt := ExecBlock("VA060ATE",.f.,.f.,{ "VVA", oModelVRK, aClone(aAutoIt) })
			EndIf
			aAdd(aAutoVVA,aAutoIt)

			//oLogExecAuto := RHST_LogExecAuto():New("VEIA060")
			//oLogExecAuto:AddExecAutoMod3( "VV0", aAutoVV0, "VVA", aAutoVVA )
			aAuxPagto := {"6",{}}
			For nLinhaFinan := 1 to oModelVRL:Length()
				oModelVRL:GoLine(nLinhaFinan)
				If oModelVRL:GetValue("VRL_E1VALO") == 0 .or. oModelVRL:GetValue("VRL_CANCEL") == "1"
					Loop
				EndIf
				aAutoPg := {}
				//AADD( aAutoPg , { "VS9_TIPPAG" , oModelVRL:GetValue("VRL_E1TIPO") , NIL } )
				AADD( aAutoPg , { "VS9_TIPPAG" , 'DP' , NIL } )
				AADD( aAutoPg , { "VS9_DATPAG" , oModelVRL:GetValue("VRL_E1DTVR") , NIL } )
				AADD( aAutoPg , { "VS9_VALPAG" , oModelVRL:GetValue("VRL_E1VALO") , NIL } )
				AADD( aAutoPg , { "VS9_SEQUEN" , oModelVRL:GetValue("VRL_E1PARC") , NIL } )
				If ! Empty(oModelVRL:GetValue("VRL_E1NATU"))
					AADD( aAutoPg , { "VS9_NATURE" , oModelVRL:GetValue("VRL_E1NATU") , NIL } )
				EndIf
				If lVA060ATE
					aAutoPg := ExecBlock("VA060ATE",.f.,.f.,{ "VS9", oModelVRL, aClone(aAutoPg) })
				EndIf
				AADD(aAuxPagto[2], aClone(aAutoPg) )

				lPagNegociado := .t.

			Next nLinhaFinan

			AADD( aAutoPagto , aAuxPagto )

			If VV0->(FieldPos("VV0_FPGPAD")) > 0
				aAdd(aAutoVV0,{"VV0_FPGPAD" , IIf( lPagNegociado == .f. , "1" , "0" ), NIl })
			EndIf

			// Chamada obrigatorio pois a rotina VEIXX002 nao esta em MVC
			// VA060_SaidaConsole("Setando variavel da CTBA105 - CTB105MVC")
			CTB105MVC(.T.)
			
			SetFunName("VEIXA018")
	//		lMSHelpAuto := .t.
			lMsErroAuto := .f.
			// VA060_SaidaConsole("Iniciando integracao com VEIXX002")
			MSExecAuto({|x,y,z,w,v| VEIXX002(x,y,,z,,w,,,,,,v)}, aAutoVV0, aAutoVVA, 3, aAutoVV9, aAutoPagto )
			// VA060_SaidaConsole("Integracao finalizada com VEIXX002")
			If lMsErroAuto
				Break
			Endif

			//// VA060_SaidaConsole("---------------------------------------------------------------------------")
			//// VA060_SaidaConsole(" ")
			//// VA060_SaidaConsole("VVA POSICIONADO  - " + VVA->VVA_NUMTRA + VVA->VVA_ITETRA )
			//// VA060_SaidaConsole(" ")
			//// VA060_SaidaConsole("---------------------------------------------------------------------------")

			oModelVRK:LoadValue("VRK_NUMTRA" , VVA->VVA_NUMTRA )
			oModelVRK:LoadValue("VRK_ITETRA" , VVA->VVA_ITETRA )

		Next nLinhaAtual

		If oModel:VldData()
			If !oModel:CommitData()
				Break
			EndIf
		Else
			aErro := oModel:GetErrorMessage(.T.)
			FMX_HELP(STR0048,; // "Dados inválidos"
				aErro[MODEL_MSGERR_IDFORMERR  ] + CRLF +;
				aErro[MODEL_MSGERR_IDFIELDERR ] + CRLF +;
				aErro[MODEL_MSGERR_ID         ] + CRLF +;
				aErro[MODEL_MSGERR_MESSAGE    ],;
				aErro[MODEL_MSGERR_SOLUCTION] )
			Break
		EndIf

	Recover
		DisarmTransaction()
		RollbackSx8()
		MsUnlockAll()
		MostraErro()
		SetFunName(cBkpFunName)

		Return .f.

	End Sequence

	End Transaction

	SetFunName(cBkpFunName)
	CursorArrow()

Return .t.

Function VA0600193_RetTESOperPadrao(oModelVRK, cRetTES, cRetOper, cCodCli, cLojCli, cOperPad, cTESPad, cB1Cod)

	cRetTES := ""
	cRetOper := ""

	If !Empty(oModelVRK:GetValue("VRK_OPER"))
		cRetTES := MaTesInt(2,oModelVRK:GetValue("VRK_OPER"), cCodCli, cLojCli ,"C", cB1Cod)
		If !Empty(cRetTES)
			cRetOper := oModelVRK:GetValue("VRK_OPER")
			Return .t.
		EndIf
	EndIf

	If !Empty(oModelVRK:GetValue("VRK_CODTES"))
		cRetTES := oModelVRK:GetValue("VRK_CODTES")
		Return .t.
	EndIf

	If !Empty(cOperPad)
		cRetTES := MaTesInt(2,cOperPad, cCodCli, cLojCli ,"C", cB1Cod)
		If !Empty(cRetTES)
			cRetOper := cOperPad
			Return .t.
		EndIf
	EndIf

	If !Empty(cTESPad)
		cRetTES := cTESPad
		Return .t.
	EndIf

Return .f.


Function VA0600203_FormatINMarca(oModelVRK)
	Local nPosVRK := 0
	Local cRetorno := ""

	For nPosVRK := 1 to oModelVRK:Length()
		If oModelVRK:isDeleted(nPosVRK)
			Loop
		EndIf

		If oModelVRK:GetValue("VRK_CODMAR", nPosVRK) $ cRetorno
			Loop
		EndIf

		cRetorno += IIf( Empty(cRetorno) , "" , "," ) + "'" + oModelVRK:GetValue("VRK_CODMAR", nPosVRK) + "'"

	Next nPosVRK
	
Return cRetorno

Static Function VA0600213_RelacionaChassi(oView)
	Local oModel060

	Local oModelVRJ
	Local oModelVRK
	Local oModelRES
	Local oParConsulta
	Local aRetConsulta
	Local aSaveLines
	Local nLinRet
	Local nX 
	//Local oVeiculos   := DMS_Veiculo():New()

	Local aFolderAct
	
	oModel060 := FWModelActive()
	oModelVRJ := oModel060:GetModel("MODEL_VRJ")
	oModelVRK := oModel060:GetModel("MODEL_VRK")
	oModelRES := oModel060:GetModel("MODEL_RESUMO")

	aFolderAct := oView:GetFolderActive("TELA_FOLDER_PRINCIPAL", 2)
	Do Case
	Case aFolderAct[1] == 1
		If oModelRes:isDeleted() .or. Empty(oModelRES:GetValue("RESFABMOD"))
			FMX_HELP("VA060ERR002", STR0049, STR0050 ) // "Posicione no modelo que deseja relacionar chassi." // "Selecionar um modelo na aba de Resumo por Modelo"
			Return
		EndIf
	
	Case aFolderAct[1] == 2
		If oModelVRK:isDeleted() .or. Empty(oModelVRK:GetValue("VRK_FABMOD")) .or. oModelVRK:GetValue("VRK_CANCEL") == "1"
			FMX_HELP("VA060ERR005", STR0051, STR0052) // "Posicione em um item válido para relacionar chassi." // "Selecionar um item não deletado/cancelado e com ano de fábricação/modelo informado."
			Return
		EndIf
		If ! oModelRES:SeekLine( { { "VV2RECNO" , oModelVRK:GetValue("VV2RECNO") } , { "RESFABMOD" , oModelVRK:GetValue("VRK_FABMOD") } } , .f. , .t. )
			FMX_HELP("VA060ERR006", STR0053) // "Modelo não encontrado na aba de resumo."
			Return
		EndIf
	Otherwise
		Return
	EndCase

	aSaveLines	:= FWSaveRows()

	Private cPARCODMAR := oModelRES:GetValue("RESCODMAR") //  "HYU"
	Private cPARMODVEI := oModelRES:GetValue("RESMODVEI") //  "GBZ5"
	Private cPARSEGMOD := oModelRES:GetValue("RESSEGMOD") //  "1K20K42S"
	Private cPAROPCION := oModelRES:GetValue("RESOPCION") //  "K42S"
	Private cPARCOREXT := oModelRES:GetValue("RESCOREXT") //  "1K "
	Private cPARCORINT := oModelRES:GetValue("RESCORINT") //  "20 "
	Private cPARFABMOD := oModelRES:GetValue("RESFABMOD") //  

	If Empty(cPARFABMOD)
		FMX_HELP("VA060ERR004",STR0054) // "Informar o ano/modelo do veículo."
		Return
	EndIf

	If oModelRES:GetValue("RESQTDEVEND") == oModelRES:GetValue("RESQTDEVINC")
		FMX_HELP("VA060ERR003",STR0055) // "Quantidade de chassis já foram vinculadas no Pedido."
		Return
	EndIf

	oParConsulta := DMS_DataContainer():New( {;
		{ "PARCODMAR" , cPARCODMAR } ,;
		{ "PARMODVEI" , cPARMODVEI } ,;
		{ "PARSEGMOD" , cPARSEGMOD } ,;
		{ "PAROPCION" , cPAROPCION } ,;
		{ "PARCOREXT" , cPARCOREXT } ,;
		{ "PARCORINT" , cPARCORINT } ,;
		{ "PARFABMOD" , cPARFABMOD } ,;
		{ "PARVENDIDO" , oModelRES:GetValue("RESQTDEVEND") } ,;
		{ "PARSELEC"   , oModelRES:GetValue("RESQTDEVINC") } ;
	} )

	aRetConsulta := VEIC030(oParConsulta)

	FWModelActive(oModel060)

	If Len(aRetConsulta) == 0
		FWRestRows(aSaveLines)
		Return .t.
	EndIf

	dbSelectArea("VRK")

	CursorWait()
	For nLinRet := 1 to Len(aRetConsulta)

		For nX := 1 to oModelVRK:Length()

			If oModelVRK:isDeleted(nX)
				Loop
			EndIf

			oModelVRK:GoLine(nX)

			If ! Empty(oModelVRK:GetValue("VRK_CHAINT")) .or. oModelVRK:GetValue("VRK_CANCEL") == "1"
				Loop
			EndIf

			If oModelVRK:GetValue("VRK_CODMAR") <> cPARCODMAR .or.;
				oModelVRK:GetValue("VRK_MODVEI") <> cPARMODVEI .or.;
				oModelVRK:GetValue("VRK_SEGMOD") <> cPARSEGMOD .or.;
				oModelVRK:GetValue("VRK_OPCION") <> cPAROPCION .or.;
				oModelVRK:GetValue("VRK_COREXT") <> cPARCOREXT .or.;
				oModelVRK:GetValue("VRK_CORINT") <> cPARCORINT .or.;
				oModelVRK:GetValue("VRK_FABMOD") <> cPARFABMOD 
				Loop
			EndIf

			If ! oModelVRK:SetValue("VRK_CHAINT", aRetConsulta[nLinRet,1])
				MostraErro()
				FWRestRows(aSaveLines)
				Return .f.
			EndIf

			Exit

		Next nX
	Next nLinRet

	oView:Refresh()

	CursorArrow()

	FWRestRows(aSaveLines)

Return

Function VA0600223_StructResumoModelo()
	Local oRetorno := OFDMSStruct():New()

	oRetorno:AddFieldDictionary( "VRK", "VRK_CODMAR" , { {"cIdField" , "RESCODMAR"} , { "lVirtual", .t. } , { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "VRK", "VRK_MODVEI" , { {"cIdField" , "RESMODVEI"} , { "lVirtual", .t. } , { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "VRK", "VRK_SEGMOD" , { {"cIdField" , "RESSEGMOD"} , { "lVirtual", .t. } , { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "VRK", "VRK_DESMOD" , { {"cIdField" , "RESDESMOD"} , { "lVirtual", .t. } , { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "VRK", "VRK_OPCION" , { {"cIdField" , "RESOPCION"} , { "lVirtual", .t. } , { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "VRK", "VRK_COREXT" , { {"cIdField" , "RESCOREXT"} , { "lVirtual", .t. } , { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "VRK", "VRK_CORINT" , { {"cIdField" , "RESCORINT"} , { "lVirtual", .t. } , { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "VRK", "VRK_FABMOD" , { {"cIdField" , "RESFABMOD"} , { "lVirtual", .t. } , { "lCanChange" , .f. } } )

	oRetorno:AddField( { ;
		{ "cTitulo"  , STR0056 } ,; // "Qtde Vendido"
		{ "cTooltip" , STR0056 } ,; // "Qtde Vendido"
		{ "cIdField" , "RESQTDEVEND" } ,;
		{ "cTipo"    , "N" } ,;
		{ "nTamanho" , 3 } ,;
		{ "lCanChange" , .f. } ,;
		{ "cPicture" , "@E 999"} ,;
		{ "lVirtual" , .t. } ;
	})
	oRetorno:AddField( { ;
		{ "cTitulo"  , STR0057 } ,; // "Qtde Vinculado"
		{ "cTooltip" , STR0057 } ,; // "Qtde Vinculado"
		{ "cIdField" , "RESQTDEVINC" } ,;
		{ "cTipo"    , "N" } ,;
		{ "nTamanho" , 3 } ,;
		{ "lCanChange" , .f. } ,;
		{ "cPicture" , "@E 999"} ,;
		{ "lVirtual" , .t. } ;
	})
	oRetorno:AddFieldDictionary( "VRJ", "VRJ_VALTOT" , { {"cIdField" , "RESVALTOT"} , { "lVirtual", .t. } , { "lCanChange" , .f. } } )
	oRetorno:AddField( { ;
		{ "cTitulo"  , "VV2 Recno" } ,;
		{ "cTooltip" , "VV2 Recno" } ,;
		{ "cIdField" , "VV2RECNO" } ,;
		{ "cTipo"    , "N" } ,;
		{ "nTamanho" , 10 } ,;
		{ "lCanChange" , .f. } ,;
		{ "cPicture" , "@E 9999999999"} ,;
		{ "lVirtual" , .t. } ;
	})


Return oRetorno

Function VA0600233_AddResumo(oModelRes, oModelVRK, aChaveNova)

	Local lSeek

	If oModelRes == NIL
		oAuxModel := FWModelActive()
		oModelRes := oAuxModel:GetModel("MODEL_RESUMO")
	EndIf
	
	lSeek := oModelRES:SeekLine( { { "VV2RECNO" , aChaveNova[1] } , { "RESFABMOD" , aChaveNova[2] } } , .t. )

	// VA060_SaidaConsole("VA0600233_AddResumo - lSeek - " + cValToChar(lSeek) + " - VV2_RECNO " + cValToChar(aChaveNova[1]) + " - FABMOD " + cValToChar(aChaveNova[2]))

	If ! lSeek

		If oModelRES:Length() == 1 .and. Empty(oModelRES:GetValue("RESCODMAR"))
		Else
			// VA060_SaidaConsole("VA0600233_AddResumo - Adicionando linha - " + " - " + cValToChar(aChaveNova[1]) + " - " + cValToChar(aChaveNova[2]))
			oModelRES:SetNoInsertLine(.F.)
			oModelRES:AddLine()
			oModelRES:SetNoInsertLine(.T.)
		EndIf

		VV2->(dbGoTo(aChaveNova[1]))
		oModelRES:SetValue( "RESCODMAR" , VV2->VV2_CODMAR )
		oModelRES:SetValue( "RESMODVEI" , VV2->VV2_MODVEI )
		oModelRES:SetValue( "RESSEGMOD" , VV2->VV2_SEGMOD )
		oModelRES:SetValue( "RESDESMOD" , VV2->VV2_DESMOD )
		oModelRES:SetValue( "RESOPCION" , VV2->VV2_OPCION )
		oModelRES:SetValue( "RESCOREXT" , VV2->VV2_COREXT )
		oModelRES:SetValue( "RESCORINT" , VV2->VV2_CORINT )
		oModelRES:SetValue( "RESFABMOD" , aChaveNova[2] )
		oModelRES:SetValue( "RESQTDEVEND" , 1 )
		oModelRES:SetValue( "VV2RECNO" , aChaveNova[1] )
	Else
		If oModelRES:isDeleted()
			oModelRES:SetNoDeleteLine(.f.)
			oModelRES:UnDeleteLine()
			oModelRES:SetNoDeleteLine(.t.)
		EndIf
		oModelRES:SetValue( "RESQTDEVEND" , oModelRES:GetValue( "RESQTDEVEND") + 1 )
	EndIf

Return

Function VA0600243_LoadResumo(oSubModel)
	Local oModel := FWModelActive()
	//Local nOperation := oModel:GetOperation()

	Local oStruct := oSubModel:getstruct()
	Local aFields := oStruct:GetFields()
	Local aRetorno := {}

	Local aProc := {}

	Local oModelVRK := oModel:GetModel("MODEL_VRK")

	Local nRESCODMAR := aScan(aFields , { |x| x[MVC_MODEL_IDFIELD] == "RESCODMAR" } )
	Local nRESMODVEI := aScan(aFields , { |x| x[MVC_MODEL_IDFIELD] == "RESMODVEI" } )
	Local nRESSEGMOD := aScan(aFields , { |x| x[MVC_MODEL_IDFIELD] == "RESSEGMOD" } )
	Local nRESDESMOD := aScan(aFields , { |x| x[MVC_MODEL_IDFIELD] == "RESDESMOD" } )
	Local nRESOPCION := aScan(aFields , { |x| x[MVC_MODEL_IDFIELD] == "RESOPCION" } )
	Local nRESCOREXT := aScan(aFields , { |x| x[MVC_MODEL_IDFIELD] == "RESCOREXT" } )
	Local nRESCORINT := aScan(aFields , { |x| x[MVC_MODEL_IDFIELD] == "RESCORINT" } )
	Local nRESFABMOD := aScan(aFields , { |x| x[MVC_MODEL_IDFIELD] == "RESFABMOD" } )
	Local nRESQTDEVEND := aScan(aFields , { |x| x[MVC_MODEL_IDFIELD] == "RESQTDEVEND" } )
	Local nRESQTDEVINC := aScan(aFields , { |x| x[MVC_MODEL_IDFIELD] == "RESQTDEVINC" } )
	Local nRESVALTOT := aScan(aFields , { |x| x[MVC_MODEL_IDFIELD] == "RESVALTOT" } )
	Local nVV2RECNO := aScan(aFields , { |x| x[MVC_MODEL_IDFIELD] == "VV2RECNO" } )

	Local nLinhaAtual
	Local nLinhaTotal := oModelVRK:Length()

	VV2->(dbSetOrder(1))

	// VA060_SaidaConsole("Load Resumo")

	For nLinhaAtual := 1 to nLinhaTotal

		oModelVRK:GoLine(nLinhaAtual)
		If oModelVRK:GetValue("VRK_CANCEL") == "1"
			Loop
		EndIf

		nPos := aScan( aProc, { |x| ;
			x[1] == oModelVRK:GetValue("VRK_CODMAR") .and. ;
			x[2] == oModelVRK:GetValue("VRK_MODVEI") .and. ;
			x[3] == oModelVRK:GetValue("VRK_SEGMOD") .and. ;
			x[4] == oModelVRK:GetValue("VRK_OPCION") .and. ;
			x[5] == oModelVRK:GetValue("VRK_COREXT") .and. ;
			x[6] == oModelVRK:GetValue("VRK_CORINT") .and. ;
			x[7] == oModelVRK:GetValue("VRK_FABMOD") ;
			} )

		If nPos == 0

			AADD( aProc , {;
				oModelVRK:GetValue("VRK_CODMAR") ,;
				oModelVRK:GetValue("VRK_MODVEI") ,;
				oModelVRK:GetValue("VRK_SEGMOD") ,;
				oModelVRK:GetValue("VRK_OPCION") ,;
				oModelVRK:GetValue("VRK_COREXT") ,;
				oModelVRK:GetValue("VRK_CORINT") ,;
				oModelVRK:GetValue("VRK_FABMOD") })

			AADD( aRetorno , { Len(aRetorno) + 1 , Array(Len(aFields)) } )
			nPos := Len(aRetorno)
			aRetorno[ nPos , 2 ][nRESCODMAR  ] := oModelVRK:GetValue("VRK_CODMAR")
			aRetorno[ nPos , 2 ][nRESMODVEI  ] := oModelVRK:GetValue("VRK_MODVEI")
			aRetorno[ nPos , 2 ][nRESSEGMOD  ] := oModelVRK:GetValue("VRK_SEGMOD")
			aRetorno[ nPos , 2 ][nRESDESMOD  ] := oModelVRK:GetValue("VRK_DESMOD")
			aRetorno[ nPos , 2 ][nRESOPCION  ] := oModelVRK:GetValue("VRK_OPCION")
			aRetorno[ nPos , 2 ][nRESCOREXT  ] := oModelVRK:GetValue("VRK_COREXT")
			aRetorno[ nPos , 2 ][nRESCORINT  ] := oModelVRK:GetValue("VRK_CORINT")
			aRetorno[ nPos , 2 ][nRESFABMOD  ] := oModelVRK:GetValue("VRK_FABMOD")
			aRetorno[ nPos , 2 ][nRESQTDEVEND] := 0
			aRetorno[ nPos , 2 ][nRESQTDEVINC] := 0
			aRetorno[ nPos , 2 ][nRESVALTOT  ] := 0
			aRetorno[ nPos , 2 ][nVV2RECNO   ] := 0

			If VV2->(MsSeek(xFilial("VV2") + aRetorno[ nPos , 2 ][ nRESCODMAR ] + aRetorno[ nPos , 2 ][ nRESMODVEI ] + aRetorno[ nPos , 2 ][ nRESSEGMOD ]))
				aRetorno[ nPos , 2 ][nVV2RECNO   ] := VV2->(Recno())
			EndIf

		EndIf

		If ! Empty(oModelVRK:GetValue("VRK_CHASSI"))
			aRetorno[nPos,2][nRESQTDEVINC] += 1
		EndIf
		aRetorno[ nPos , 2 ][nRESQTDEVEND] += 1
		aRetorno[ nPos , 2 ][nRESVALTOT] += oModelVRK:GetValue("VRK_VALVDA")

	Next nLinhaAtual

Return aRetorno

Function VA0600253_AtualizaResumo(oModelRES, aChaveNova, aCampoValor)
	Local lSeek
	Local nPos

	If Len(aCampoValor) == 0
		Return
	EndIf

	If oModelRes == NIL
		oAuxModel := FWModelActive()
		oModelRes := oAuxModel:GetModel("MODEL_RESUMO")
	EndIf

	lSeek := oModelRES:SeekLine( { { "VV2RECNO" , aChaveNova[1] } , { "RESFABMOD" , aChaveNova[2] } } )

	// VA060_SaidaConsole("VA0600253_AtualizaResumo - lSeek - " + cValToChar(lSeek) + " - " + cValToChar(aChaveNova[1]) + " - " + cValToChar(aChaveNova[2]) )

	If lSeek
		For nPos := 1 to Len(aCampoValor)
			// VA060_SaidaConsole("                                 - " + aCampoValor[nPos,1] + " - " + cValToChar(aCampoValor[nPos,2]))
			If ! oModelRES:SetValue(aCampoValor[nPos,1], oModelRES:GetValue(aCampoValor[nPos,1]) + aCampoValor[nPos,2])
				// VA060_SaidaConsole("Erro ao atualizar valor do resumo - " + cValToChar(aCampoValor[nPos,1]))
			EndIf
		Next nPos
		If oModelRES:GetValue("RESQTDEVEND") == 0
			VA0600263_DelResumo(oModelRES)
		Endif
	EndIf
Return

Function VA0600263_DelResumo(oModelRES)

	// VA060_SaidaConsole("VA0600263_DelResumo")

	oModelRES:SetNoDeleteLine(.f.)
	oModelRES:DeleteLine()
	oModelRES:SetNoDeleteLine(.t.)

Return

FUNCTION VA0600273_TelaFaturarAtendimentos(cAlias,nReg,nOpc)

	Local lRetorno
	Local oModel060
	Local oExViewFat

	Private lMarcarDesmarcar := .f.

	VA0600393_TelaSelecaoItem("FATURAMENTO", @oModel060, @oExViewFat)
	
	oExViewFat:setOK( { |oModel| lRetorno := VA0600443_FaturarAtendimentos(oModel) })
	oExViewFat:openView(.t.)

	oModel060:DeActivate()

Return lRetorno

Function VA0600443_FaturarAtendimentos(oModel)

	Local cSerParam

	lRetorno := SX5NumNota(@cSerParam, GetNewPar("MV_TPNRNFS","1"))
	If lRetorno
		lRetorno := VA0600283_ProcFaturamento(oModel, "F", cSerParam)
	EndIf

Return lRetorno

Function VA0600283_ProcFaturamento(oModel, cFaseAte, cSerParam)

	//Local aAutoVV0 := {}
	Local aAutoVV9 := {}
	//Local aAutoVVA := {} // Campos Itens
	Local lRetorno := .f.

	Local oModelVRJ
	Local oModelVRK

	Local nLinhaAtual
	Local cBkpFunName := FunName()

	Local aAtendProc := {}

	Default cFaseAte := "F"
	Default cSerParam := ""

	oModelVRJ := oModel:GetModel("MODEL_VRJ")
	oModelVRK := oModel:GetModel("MODEL_VRK")

	// VA060_SaidaConsole("VA0600283_ProcFaturamento")

	CursorWait()

	For nLinhaAtual := 1 to oModelVRK:Length()

		oModelVRK:GoLine(nLinhaAtual)

		If Empty(oModelVRK:GetValue("VRK_NUMTRA")) .or. oModelVRK:GetValue("VRK_CANCEL") == "1"
			Loop
		EndIf

		If oModelVRK:HasField("SEL_FATURAMENTO") .and. ! oModelVRK:GetValue("SEL_FATURAMENTO")
			Loop
		EndIf

		// VA060_SaidaConsole("Faturamento do atendimento " + oModelVRK:GetValue("VRK_NUMTRA"))

		VV9->(dbSetOrder(1))
		If ! VV9->(dbSeek(xFilial("VV9") + oModelVRK:GetValue("VRK_NUMTRA") ))
			Loop
		EndIf

		If VV9->VV9_STATUS $ "F/C" .or. (VV9->VV9_STATUS == cFaseAte)
			Loop
		EndIf

		VV0->(dbSetOrder(1))
		VV0->(dbSeek(xFilial("VV0") + VV9->VV9_NUMATE))

		aAutoVV9 := { { "VV9_NUMATE" , oModelVRK:GetValue("VRK_NUMTRA") , NIL } }
		aAutoCab := {} // Campos Cabecalho
		aAutoItens:= {} // Campos Itens

		// Nao pode estar dentro de uma transacao ...
		SetFunName("VEIXA018")
		lMSHelpAuto := .t.
		lMsErroAuto := .f.
	//	VEIXX002(                            xAutoCab, xAutoItens,xAutoCP,nOpc,aRecInter,xAutoVV9,xOpcCanc,xMotCanc,xAutoAvanca, xFaseInter, xSerieNF)
		MSExecAuto({|x,y,z,w,u,v,t| VEIXX002(x       , y         ,       , z  ,         , w      ,        ,        , u         , v         , t       )}, aAutoCab, aAutoItens, 4     , aAutoVV9,.t.,cFaseAte, cSerParam)
		SetFunName(cBkpFunName)
		if lMsErroAuto
			CursorArrow()
			MostraErro()
			Exit
		Endif

		If cFaseAte == "F"
			// Adiciona na matriz de atendimentos processados para exibir tela de notas fiscais geradas ...
			VV0->(dbSetOrder(1))
			VV0->(dbSeek(xFilial("VV0") + oModelVRK:GetValue("VRK_NUMTRA") ))
			AADD( aAtendProc , { Alltrim(VV0->VV0_SERNFI) , Alltrim(VV0->VV0_NUMNFI) , VV0->VV0_NUMTRA } )
		EndIf

	Next nLinhaAtual

	CursorArrow()
	
	If Len(aAtendProc) > 0
		FMX_TELAINF( "1" , aAtendProc ) // "EMITIDO"
		lRetorno := .t.
	EndIf

Return lRetorno

Static Function VA0600293_MostraErrorModel(oModel)
	aErro := oModel:GetErrorMessage(.T.)
	FMX_HELP(aErro[MODEL_MSGERR_ID],;
		aErro[MODEL_MSGERR_IDFIELDERR ] + CRLF +;
		aErro[MODEL_MSGERR_ID         ] + CRLF +;
		aErro[MODEL_MSGERR_MESSAGE    ],;
		aErro[MODEL_MSGERR_SOLUCTION  ])
Return

Function VA0600313_LegendaFinanceiro()

	If INCLUI
		Return "br_laranja.png"
	Else
		If VRL->VRL_CANCEL == "1"
			Return "xclose.png"
		Else
			SE1->(dbSetOrder(1))
			If ! SE1->(dbSeek(FWxFilial("SE1") + VRL->VRL_E1PREF + VRL->VRL_E1NUM + VRL->VRL_E1PARC + VRL->VRL_E1TIPO ))
				Return "br_laranja.png"
			Else
				Do Case
				Case SE1->E1_SALDO == SE1->E1_VALOR
					Return "br_verde.png"
				Case SE1->E1_SALDO == 0
					Return "br_vermelho.png"
				Case SE1->E1_SALDO > 0
					Return "br_azul.png"
				EndCase
			EndIf
		EndIf
	EndIf

Return ""

Function VA0600323_StatusFinanc()

	If INCLUI
		Return "SEM_FINANC"
	Else
		SE1->(dbSetOrder(1))
		If ! SE1->(dbSeek(FWxFilial("SE1") + VRL->VRL_E1PREF + VRL->VRL_E1NUM + VRL->VRL_E1PARC + VRL->VRL_E1TIPO ))
			Return "SEM_FINANC"
		Else
			Do Case
			Case SE1->E1_SALDO == SE1->E1_VALOR
				Return "ABERTO"
			Case SE1->E1_SALDO == 0
				Return "BAIXADO"
			Case SE1->E1_SALDO > 0
				Return "BAIXADO_PARC"
			EndCase
		EndIf
	EndIf

Return ""


Function VA0600___VisualizaASaidaConsole(oView)

	Local oVisualLog := OFVisualizaDados():New("VEIA060", "SaidaConsole") // "Detalhe do Cálculo"
	Local nPos

	Local aSaidaConsole := {}
	Local aAuxLog := oLogger:getLog()

	cClipboard := ""
	For nPos := 1 to Len(aAuxLog)
		AADD(aSaidaConsole, {aAuxLog[nPos,2]})
		cClipboard += AllTrim(aAuxLog[nPos,2]) + CRLF
	Next nPos

	oVisualLog:AddColumn( { { "TITULO" , "Log"                } , { "TAMANHO" , 250 } } ) // "Id Conta"
	oVisualLog:SetData(aSaidaConsole)
	If oVisualLog:HasData()
		oVisualLog:Activate()

		CopytoClipboard(cClipboard)

	//	If MsgYesNo("Limpar saida ?")
	//		aSaidaConsole := {}
	//	EndIf

	EndIf

Return

Static Function VA0600363_AddTrigger(oAuxStru, aAuxTrigger)
	oAuxStru:AddTrigger(aAuxTrigger[1], aAuxTrigger[2], aAuxTrigger[3], aAuxTrigger[4])
Return

Function VA0600373_LegendaItemPedido()

	If INCLUI
		Return ""
	Else
		If VRK->VRK_CANCEL == "1"
			Return "xclose.png"
		Else 
			If !Empty( VRK->VRK_NUMTRA )
				VV9->(dbSetOrder(1))
				If VV9->(dbSeek(xFilial("VV9") + VRK->VRK_NUMTRA ))
					Do Case
						Case VV9->VV9_STATUS == "A" ; Return "br_verde.png" // Em Aberto
						Case VV9->VV9_STATUS == "P" ; Return "br_amarelo.png" // endente de Aprovacao
						Case VV9->VV9_STATUS == "O" ; Return "br_branco.png" // Pre-Aprovado
						Case VV9->VV9_STATUS == "L" ; Return "br_azul.png"  // Aprovado
						Case VV9->VV9_STATUS == "R" ; Return "br_laranja.png" // Reprovado
						Case VV9->VV9_STATUS == "F" ; Return "br_preto.png" // Finalizado
						Case VV9->VV9_STATUS == "C" ; Return "br_vermelho.png" // Cancelado
					EndCase
				EndIf
			EndIf
		EndIf
	EndIf

Return ""

Function VA0600383_Conhecimento(cAlias,nReg,nOpc)
	Private cCadastro := "Pedido de Veículo"
	Private aRotina	:= MenuDef()

	MsDocument(cAlias,nReg, 4)
Return


Function VA0600393_TelaSelecaoItem(cChamada, oModel, oExecView)

	Local nPos
	Local nAuxOrdem

	//Local oModel
	Local oAuxVRKStrModel

	Local oStruVRJ
	Local oStruVRK
	Local bOtherView
	Local aButtons := { { .f. , NIL} /* 1 - Copiar */ , { .f. , NIL} /* 2 - Recortar */ , { .f. , NIL} /* 3 - Colar */ , { .f. , NIL} /* 4 - Calculadora */ , { .f. , NIL} /* 5 - Spool */ , { .f. , NIL} /* 6 - Imprimir */ , { .f. , ""} /* 7 - Confirmar */ , { .f. , ""} /* 8 - Cancelar */ , { .f. , NIL} /* 9 - WalkTrhough */ , { .f. , NIL} /* 10 - Ambiente */ , { .f. , NIL} /* 11 - Mashup */ , { .f. , NIL} /* 12 - Help */ , { .f. , NIL} /* 13 - Formulário HTML */ , { .f. , NIL} /* 14 - ECM */ }
	
	Local cIdField := "SEL_" + cChamada

	Local aFields := { cIdField ,"LEGENDA","VRK_ITEPED","VRK_NUMTRA","VRK_ITETRA","VRK_CHASSI","VRK_CODMAR","VRK_MODVEI","VRK_SEGMOD","VRK_CORINT","VRK_COREXT","VRK_OPCION","VRK_FABMOD","VRK_VALTAB","VRK_VALPRE","VRK_VALMOV","VRK_VALDES","VRK_VALVDA" }

	CursorWait()
	oModel := FWLoadModel( 'VEIA060' )
	oAuxVRKStrModel :=  oModel:GetModel("MODEL_VRK"):GetStruct()

	oStruVRJ := FWFormStruct( 2, 'VRJ' , { |x| AllTrim(x) $ "/VRJ_PEDIDO/VRJ_DATDIG/" }  )
	oStruVRK := FWFormStruct( 2, 'VRK' , { |x| AllTrim(x) $ "/VRK_ITEPED/VRK_NUMTRA/VRK_ITETRA/VRK_CODMAR/VRK_MODVEI/VRK_SEGMOD/VRK_CORINT/VRK_COREXT/VRK_OPCION/VRK_FABMOD/VRK_CHASSI/VRK_VALTAB/VRK_VALPRE/VRK_VALMOV/VRK_VALDES/VRK_VALVDA/" } )

	oAuxVRKStrModel:DeActivate()
	oAuxVRKStrModel:AddField('SELECT', ' ', cIdField , 'L', 1, 0, , , {}, .F.,FWBuildFeature( STRUCT_FEATURE_INIPAD, ".f.")) 
	oAuxVRKStrModel:Activate()

	oStruVRJ:SetProperty("*", MVC_VIEW_CANCHANGE , .F. )

	aAuxFields := oStruVRK:GetFields()
	For nPos := 1 to Len(aAuxFields)
		oStruVRK:SetProperty( aAuxFields[nPos, MVC_VIEW_IDFIELD], MVC_VIEW_CANCHANGE , .F. )
		
		nAuxOrdem := aScan(aFields, aAuxFields[nPos, MVC_VIEW_IDFIELD] )
		oStruVRK:SetProperty( aAuxFields[nPos, MVC_VIEW_IDFIELD], MVC_VIEW_ORDEM , StrZero(IIf( nAuxOrdem <> 0 , nAuxOrdem , Len(aFields) + nPos ),2) )
	Next nPos
	oStruVRK:AddField( cIdField,'01','','SELECT',, 'Check')
	oStruVRK:AddField( 'LEGENDA','02',' ',STR0058,, 'Get' ,'@BMP',,,.F.,,,,,,.T.,, ) // 'Legenda'

	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField('VIEW_VRJ', oStruVRJ, 'MODEL_VRJ' )
	oView:AddGrid( 'VIEW_VRK', oStruVRK, 'MODEL_VRK' )

	oView:SetViewProperty("VIEW_VRK", "GRIDSEEK", {.T.})
	oView:SetNoInsertLine('VIEW_VRK')

	oView:CreateHorizontalBox( 'TELA_VRJ' , 120 ,, .t. )
	oView:CreateHorizontalBox( 'TELA_VRK' , 100 )
	oView:CreateHorizontalBox( 'BOXBT', 20 ,, .t.)

	oView:SetOwnerView('VIEW_VRK', 'TELA_VRK')
	oView:SetOwnerView('VIEW_VRJ', 'TELA_VRJ')

	oView:SetCloseOnOk( {||.T.} )
	oView:SetViewAction("ASKONCANCELSHOW", {|| .F.})
	oView:SetModified(.t.) // Marca internamente que algo foi modificado no MODEL

	oView:showUpdateMsg(.f.)
	oView:showInsertMsg(.f.)

	Do Case
	Case cChamada == "FATURAMENTO"
		oModel:GetModel("MODEL_VRK"):SetLoadFilter(," VRK_NUMTRA <> ' ' AND VRK_CANCEL IN (' ','0') ")
	Case cChamada == "PROPOSTA"
		oModel:GetModel("MODEL_VRK"):SetLoadFilter(," VRK_NUMTRA <> ' ' AND VRK_CANCEL IN (' ','0') ")
	Case cChamada == "DESVINCULAR"
		oModel:GetModel("MODEL_VRK"):SetLoadFilter(," VRK_CHASSI <> ' ' AND VRK_CANCEL IN (' ','0') ")
	EndCase
	oModel:setOperation(MODEL_OPERATION_UPDATE)
	lRet := oModel:Activate()
	If ! lRet
		Alert("Erro ao carregar model.")
		Return .f.
	EndIf

	bOtherView := &("{ |oPanel,oView| VA0600403_SelecionaTudo(oPanel,oView, '" + cIdField + "') }")
	oView:AddOtherObject("VIEW_BT", bOtherView)
	oView:SetOwnerView("VIEW_BT",'BOXBT')

	oExecView := FWViewExec():New()
	oExecView:setTitle(STR0059) // "Itens do Pedido de Venda"
	oExecView:setModel(oModel)
	oExecView:setView(oView)
	oExecView:setOperation(MODEL_OPERATION_UPDATE)
	oExecView:SetReduction(30)

	Do Case
	Case cChamada == "FATURAMENTO"
		aButtons[7] := { .t. , STR0060 } // "Faturar"
		aButtons[8] := { .t. , STR0061 } // Cancelar
	Case cChamada == "PROPOSTA"
		aButtons[7] := { .t. , STR0062 } // Imprimir
		aButtons[8] := { .t. , STR0061 } // Cancelar
		oExecView:SetCloseOnOk( { || .f. })
	Case cChamada == "DESVINCULAR"
		aButtons[7] := { .t. , STR0063 } // "Desvincular"
		aButtons[8] := { .t. , STR0061 } // Cancelar
		//oExecView:SetCloseOnOk( { || .f. })
	EndCase
	oExecView:SetButtons(aButtons)

	CursorArrow()

Return


/*/{Protheus.doc} VA0600403_SelecionaTudo
//TODO Descrição auto-gerada.
@author rubens.takahashi
@since 02/08/2019
@version 1.0
@return ${return}, ${return_description}
@param oPanel, object, description
@param oView, object, description
@type function
/*/
Function VA0600403_SelecionaTudo(oPanel, oView, cIdField)
	@ 001, 010 CheckBox oChK VAR lMarcarDesmarcar OF oPanel SIZE 100, 15 PROMPT STR0064 PIXEL ON Click VA0600413_BotaoSelecionaTudo(cIdField) // "Marca / Desmarca Todos"
Return


/*/{Protheus.doc} VA0600413_BotaoSelecionaTudo
Seleciona todos os registros da grid
@author rubens.takahashi
@since 12/11/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function VA0600413_BotaoSelecionaTudo(cIdField, lMarcar )

	Local oModel := FWModelActive()
	Local oView	 := FWViewActive()
	Local oModelGrid := oModel:GetModel('MODEL_VRK')
	Local nLinhasGrid := oModelGrid:Length()
	Local nAuxLinha := 0
	Local nBkpLine := oModelGrid:GetLine()

	Default lMarcar := lMarcarDesmarcar

	For nAuxLinha := 1 To nLinhasGrid
		oModelGrid:GoLine(nAuxLinha)
		If oModelGrid:CanSetValue(cIdField)
			oModelGrid:SetValue(cIdField, lMarcar )
		EndIf
	Next nAuxLinha

	oModelGrid:SetLine(nBkpLine)

	oView:Refresh()

Return

Function VA0600423_TelaImpressaoProposta(cAlias,nReg,nOpc)

	Local oModel060
	Local oExViewImp

	Private lMarcarDesmarcar := .f.

	VA0600393_TelaSelecaoItem("PROPOSTA", @oModel060, @oExViewImp)
	
	oExViewImp:setOK( { |oModel| VA0600433_ImprimirProposta(oModel) })
	oExViewImp:openView(.t.)

Return .T.

Function VA0600433_ImprimirProposta(oModel060)
	ExecBlock("PROPPED",.f.,.f.,{ oModel060 }) 
	VA0600413_BotaoSelecionaTudo("SEL_PROPOSTA", .F. )
Return

FUNCTION VA0600453_DesvincularChassi(cAlias,nReg,nOpc)

	Local lRetorno
	Local oModel060
	Local oExDesvChassi

	Private lMarcarDesmarcar := .f.

	VA0600393_TelaSelecaoItem("DESVINCULAR", @oModel060, @oExDesvChassi)
	
	oExDesvChassi:setOK( { |oModel| lRetorno := VA0600463_ProcDesvincularChassi(oModel) })
	oExDesvChassi:openView(.t.)

	oModel060:DeActivate()

Return lRetorno


Function VA0600463_ProcDesvincularChassi(oModel)

	Local nLinhaAtual
	Local lRet

	Local oModelVRK := oModel:GetModel("MODEL_VRK")

	// VA060_SaidaConsole("VA0600463_ProcDesvincularChassi")

	CursorWait()

	For nLinhaAtual := 1 to oModelVRK:Length()

		oModelVRK:GoLine(nLinhaAtual)

		If ! Empty(oModelVRK:GetValue("VRK_NUMTRA")) .or. oModelVRK:GetValue("VRK_CANCEL") == "1" .or. Empty(oModelVRK:GetValue("VRK_CHASSI"))
			Loop
		EndIf

		If ! oModelVRK:GetValue("SEL_DESVINCULAR")
			Loop
		EndIf

		// VA060_SaidaConsole("Desvincular chassi " + oModelVRK:GetValue("VRK_CHASSI"))

		If ! oModelVRK:SetValue("VRK_CHASSI", " ")
			VA0600293_MostraErrorModel( oModel )
		EndIf

	Next nLinhaAtual

	If ( lRet := oModel:VldData() )
		lRet := oModel:CommitData()
	EndIf

	CursorArrow()
	
	If ! lRet
		VA0600293_MostraErrorModel( oModel )
	EndIf
	
Return lRet
