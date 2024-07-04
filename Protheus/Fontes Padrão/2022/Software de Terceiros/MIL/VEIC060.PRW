#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

#INCLUDE "VEIC060.CH"

Static oModFatStruDef
Static oModAtendStruDef
Static oModAtFinancStruDef

/*/{Protheus.doc} VEIC060
Follow-up de negociacao dos Pedidos de Venda de Montadora

@author Rubens
@since 02/04/2019
@version 1.0

@type function
/*/
Function VEIC060()

	Local oBrowse

	Private aSaidaConsole := {}

	// Instanciamento da Classe de Browse
	oBrowse := BrowseDef()
	oBrowse:Activate()

Return

/*/{Protheus.doc} ModelDef
Modelo de Dados
@author Rubens
@since 28/12/2018
@version 1.0

@type function
/*/
Static Function ModelDef()

	Local oModel := FWLoadModel('VEIA060')
	Local oStruVRK := oModel:GetModel("MODEL_VRK"):GetStruct()
	Local oStruVAY := FWFormStruct( 1, 'VAY' )
	Local oStruFat
	Local oStruAtend

	If oModFatStruDef == NIL
		oModFatStruDef := VC0600023_StructResumoFaturamento()
	EndIf
	If oModAtendStruDef == NIL
		oModAtendStruDef := VC0600043_StructAtendimento()
	EndIf
	If oModAtFinancStruDef == NIL
		oModAtFinancStruDef := VC0600063_StructAtendimentoFinanceiro()
	EndIf
	
	oStruFat := oModFatStruDef:GetModel()
	oStruAtend := oModAtendStruDef:GetModel()
	oStruAtFinanc := oModAtFinancStruDef:GetModel()

	oStruVRK:DeActivate()

	oStruVRK:AddField('Legenda', 'Legenda', 'LEGENDA', 'C', 20, 0, , , {}, .F., ;
		FWBuildFeature( STRUCT_FEATURE_INIPAD, "VC0600013_LegendaVeiculo()"), .F., .F., .T., , )

	oStruVRK:Activate()

	oModel:AddGrid(  'MODEL_VAY', 'MODEL_VRJ',oStruVAY, /* <bLinePre > */ , /* <bLinePost > */ , /* <bPre > */ , /* <bLinePost > */,  )
	oModel:GetModel( 'MODEL_VAY' ):SetDescription( STR0001 ) // 'Dados da Tarefa do Pedido de Venda de Montadora'

	oModel:AddGrid(  'MODEL_FATURAMENTO', 'MODEL_VRJ', oStruFat , /* <bLinePre > */ , /* <bLinePost > */ , /* <bPre > */ , /* <bLinePost > */, { |oSubModel| VC0600033_LoadResumoFaturamento(oSubModel) }  )
	oModel:GetModel( 'MODEL_FATURAMENTO' ):SetDescription( STR0002 ) // 'Dados das Notas Fiscais relacionadas ao Pedido de Venda'
	
	oModel:AddGrid(  'MODEL_ATENDIMENTO', 'MODEL_VRJ', oStruAtend , /* <bLinePre > */ , /* <bLinePost > */ , /* <bPre > */ , /* <bLinePost > */, { |oSubModel| VC0600053_LoadResumoAtendimento(oSubModel) }  )
	oModel:GetModel( 'MODEL_ATENDIMENTO' ):SetDescription( STR0003 ) // 'Dados dos Atendimentos relacionadas ao Pedido de Venda'

	oModel:AddGrid(  'MODEL_ATENDIMENTO_FINANCEIRO', 'MODEL_VRJ', oStruAtFinanc , /* <bLinePre > */ , /* <bLinePost > */ , /* <bPre > */ , /* <bLinePost > */, { |oSubModel| VC0600073_LoadResumoFinancAtendimento(oSubModel) }  )
	oModel:GetModel( 'MODEL_ATENDIMENTO_FINANCEIRO' ):SetDescription( STR0004 ) // 'Dados Financeiros dos Atendimentos relacionadas ao Pedido de Venda'

	oModel:SetRelation('MODEL_VAY', { { 'VAY_FILIAL' , 'xFilial("VAY")' } , { 'VAY_NUMIDE' , 'VRJ_PEDIDO' } , { 'VAY_ORIGEM' , '"3"' } } , 'VAY_FILIAL+VAY_NUMIDE+VAY_ORIGEM' )

Return oModel

/*/{Protheus.doc} ViewDef
View
@author Rubens
@since 28/12/2018
@version 1.0

@type function
/*/
Static Function ViewDef()

	Local oModel := FWLoadModel( 'VEIC060' )
	Local oViewPad := FWLoadView(  'VEIA060' )
	Local oView
	Local oStruVRJ := oViewPad:GetViewStruct( 'VIEW_VRJ' )
	Local oStruVRK := oViewPad:GetViewStruct( 'VIEW_VRK' )
	Local oStruVRL := oViewPad:GetViewStruct( 'VIEW_VRL' )
	Local oStruVRLRes := oViewPad:GetViewStruct( 'VIEW_VRLRES' )
	Local oStruResumo := oViewPad:GetViewStruct( 'VIEW_RESUMO' )
	Local oStruFat := oModFatStruDef:GetView()
	Local oStruAtend := oModAtendStruDef:GetView()
	Local oStruAtFinanc := oModAtFinancStruDef:GetView()

	Local oStruVAY := FWFormStruct( 2, 'VAY' )

	CursorWait()

	oStruVRK:DeActivate()
	oStruVRK:AddField( 'LEGENDA','01','','Legenda',, 'Get' ,'@BMP',,,.F.,,,,,,.T.,, )
	oStruVRK:Activate()

	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField('VIEW_VRJ', oStruVRJ, 'MODEL_VRJ' )
	oView:AddGrid( 'VIEW_VRK', oStruVRK, 'MODEL_VRK' )
	oView:AddGrid( 'VIEW_VRL', oStruVRL, 'MODEL_VRL' )
	oView:AddGrid( 'VIEW_VRLRES', oStruVRLRes, 'MODEL_VRLRES' )
	oView:AddGrid( 'VIEW_RESUMO', oStruResumo, 'MODEL_RESUMO' )
	oView:AddGrid( 'VIEW_VAY', oStruVAY, 'MODEL_VAY' )
	oView:AddGrid( 'VIEW_FATURAMENTO', oStruFat, 'MODEL_FATURAMENTO' )
	oView:AddGrid( 'VIEW_ATENDIMENTO', oStruAtend, 'MODEL_ATENDIMENTO' )
	oView:AddGrid( 'VIEW_ATENDIMENTO_FINANCEIRO', oStruAtFinanc, 'MODEL_ATENDIMENTO_FINANCEIRO' )

	oView:CreateFolder( 'TELA_FOLDER_PRINCIPAL')
	oView:AddSheet('TELA_FOLDER_PRINCIPAL' , 'ABA_PRINCIPAL' , 'Pedido')
	oView:AddSheet('TELA_FOLDER_PRINCIPAL' , 'ABA_VEICULOS'  , 'Veículos')

	oView:CreateHorizontalBox( 'TELA_VRK' , 50 , , , 'TELA_FOLDER_PRINCIPAL', 'ABA_VEICULOS')
	oView:CreateHorizontalBox( 'TELA_VRL' , 50 , , , 'TELA_FOLDER_PRINCIPAL', 'ABA_VEICULOS')

	oView:CreateHorizontalBox( 'TELA_VRJ'    , 60 , , , 'TELA_FOLDER_PRINCIPAL', 'ABA_PRINCIPAL')
	oView:CreateHorizontalBox( 'TELA_FOLDER' , 40 , , , 'TELA_FOLDER_PRINCIPAL', 'ABA_PRINCIPAL')

	oView:CreateFolder( 'TELA_FOLDER_RESUMO', 'TELA_FOLDER')
	oView:AddSheet('TELA_FOLDER_RESUMO','ABA_RESUMO_MODELO', STR0005 ) // 'Resumo por Modelo'
	oView:AddSheet('TELA_FOLDER_RESUMO','ABA_RESUMO_FINANCEIRO', STR0006 ) // 'Resumo Financeiro (Pedido de Venda)'
	oView:AddSheet('TELA_FOLDER_RESUMO','ABA_RESUMO_TAREFA', STR0007 ) // 'Tarefas'
	oView:AddSheet('TELA_FOLDER_RESUMO','ABA_RESUMO_FATURAMENTO', STR0008 ) // 'Faturamento'
	oView:AddSheet('TELA_FOLDER_RESUMO','ABA_RESUMO_ATENDIMENTO', STR0009 ) // 'Atendimento'
	oView:AddSheet('TELA_FOLDER_RESUMO','ABA_RESUMO_ATENDIMENTO_FINANCEIRO', STR0010 ) // 'Resumo Financeiro (Atendimento)'

	oView:CreateHorizontalBox( 'TELA_RESUMO_MODELO'      , 100, , , 'TELA_FOLDER_RESUMO', 'ABA_RESUMO_MODELO')
	oView:CreateHorizontalBox( 'TELA_RESUMO_FINANCEIRO'  , 100, , , 'TELA_FOLDER_RESUMO', 'ABA_RESUMO_FINANCEIRO')
	oView:CreateHorizontalBox( 'TELA_RESUMO_TAREFA'      , 100, , , 'TELA_FOLDER_RESUMO', 'ABA_RESUMO_TAREFA')
	oView:CreateHorizontalBox( 'TELA_RESUMO_FATURAMENTO' , 100, , , 'TELA_FOLDER_RESUMO', 'ABA_RESUMO_FATURAMENTO')
	oView:CreateHorizontalBox( 'TELA_RESUMO_ATENDIMENTO' , 100, , , 'TELA_FOLDER_RESUMO', 'ABA_RESUMO_ATENDIMENTO')
	oView:CreateHorizontalBox( 'TELA_RESUMO_ATENDIMENTO_FINANCEIRO' , 100, , , 'TELA_FOLDER_RESUMO', 'ABA_RESUMO_ATENDIMENTO_FINANCEIRO')

	oView:SetOwnerView( 'VIEW_RESUMO', 'TELA_RESUMO_MODELO' )
	oView:SetOwnerView( 'VIEW_VRJ', 'TELA_VRJ' )
	oView:SetOwnerView( 'VIEW_VRK', 'TELA_VRK' )
	oView:SetOwnerView( 'VIEW_VRL', 'TELA_VRL' )
	oView:SetOwnerView( 'VIEW_VRLRES', 'TELA_RESUMO_FINANCEIRO' )
	oView:SetOwnerView( 'VIEW_VAY', 'TELA_RESUMO_TAREFA' )
	oView:SetOwnerView( 'VIEW_FATURAMENTO', 'TELA_RESUMO_FATURAMENTO' )
	oView:SetOwnerView( 'VIEW_ATENDIMENTO', 'TELA_RESUMO_ATENDIMENTO' )
	oView:SetOwnerView( 'VIEW_ATENDIMENTO_FINANCEIRO', 'TELA_RESUMO_ATENDIMENTO_FINANCEIRO' )

	CursorArrow()

Return oView

Function VC0600013_LegendaVeiculo()

	Do Case
	Case VRK->VRK_CANCEL == "1"
		Return "br_vermelho.png"
	Otherwise
		Return "br_verde.png"
	EndCase

Return ""

Function VC0600023_StructResumoFaturamento()

	Local oRetorno := OFDMSStruct():New()

	CursorWait()

	oRetorno:AddFieldDictionary( "SF2" , "F2_DOC"     , { {"cIdField" , "RFATDOC"     } , { "lVirtual", .t. } , { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "SF2" , "F2_SERIE"   , { {"cIdField" , "RFATSERIE"   } , { "lVirtual", .t. } , { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "SF2" , "F2_EMISSAO" , { {"cIdField" , "RFATEMISSAO" } , { "lVirtual", .t. } , { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "SF2" , "F2_VALBRUT" , { {"cIdField" , "RFATVALBRUT" } , { "lVirtual", .t. } , { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "SD2" , "D2_TES"     , { {"cIdField" , "RFATTES"     } , { "lVirtual", .t. } , { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "SD2" , "D2_CF"      , { {"cIdField" , "RFATCF"      } , { "lVirtual", .t. } , { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "SD2" , "D2_LOCAL"   , { {"cIdField" , "RFATLOCAL"   } , { "lVirtual", .t. } , { "lCanChange" , .f. } } )

	CursorArrow()	

Return oRetorno

Function VC0600033_LoadResumoFaturamento(oSubModel)

	Local oStruct := oSubModel:getstruct()
	Local aFields := oStruct:GetFields()
	Local aRetorno := {}

	Local nRFATDOC     := aScan( aFields , { |x| x[MVC_MODEL_IDFIELD] == "RFATDOC"     } )
	Local nRFATSERIE   := aScan( aFields , { |x| x[MVC_MODEL_IDFIELD] == "RFATSERIE"   } )
	Local nRFATEMISSAO := aScan( aFields , { |x| x[MVC_MODEL_IDFIELD] == "RFATEMISSAO" } )
	Local nRFATVALBRUT := aScan( aFields , { |x| x[MVC_MODEL_IDFIELD] == "RFATVALBRUT" } )
	Local nRFATTES     := aScan( aFields , { |x| x[MVC_MODEL_IDFIELD] == "RFATTES"     } )
	Local nRFATCF      := aScan( aFields , { |x| x[MVC_MODEL_IDFIELD] == "RFATCF"      } )
	Local nRFATLOCAL   := aScan( aFields , { |x| x[MVC_MODEL_IDFIELD] == "RFATLOCAL"   } )

	Local cAliasFat := "TRESFAT"

	CursorWait()

	BeginSQL Alias cAliasFat
		COLUMN F2_EMISSAO AS DATE
		COLUMN F2_VALBRUT AS NUMERIC(10,2)
		COLUMN D2_TOTAL   AS NUMERIC(10,2)

		SELECT F2_DOC, F2_SERIE, F2_EMISSAO, F2_VALBRUT, D2_TES, D2_CF, D2_LOCAL, D2_TOTAL
		FROM 
  			%table:VRK% VRK
			  JOIN %table:VV9% VV9 ON VV9.VV9_FILIAL = %xFilial:VV9% AND VV9.VV9_NUMATE = VRK.VRK_NUMTRA AND VV9.%notDel% 
			  JOIN %table:VV0% VV0 ON VV0.VV0_FILIAL = %xFilial:VV0% AND VV0.VV0_NUMTRA = VV9.VV9_NUMATE AND VV0.%notDel% 
			  JOIN %table:VVA% VVA ON VVA.VVA_FILIAL = %xFilial:VVA% AND VVA.VVA_NUMTRA = VV0.VV0_NUMTRA AND VVA.VVA_ITETRA = VRK.VRK_ITETRA  AND VVA.%notDel% 
			  JOIN %table:SF2% SF2 ON SF2.F2_FILIAL  = %xFilial:SF2% AND SF2.F2_SERIE  = VV0.VV0_SERNFI AND SF2.F2_DOC = VV0.VV0_NUMNFI AND SF2.%notDel% 
			  JOIN %table:SD2% SD2 ON SD2.D2_FILIAL  = %xFilial:SD2% AND SD2.D2_SERIE  = SF2.F2_SERIE AND SD2.D2_DOC = SF2.F2_DOC AND SD2.%notDel% 
		WHERE
			VRK.VRK_FILIAL = %xFilial:VRK%
			AND VRK.VRK_PEDIDO = %exp:VRJ->VRJ_PEDIDO%
			AND VV9.VV9_STATUS IN ('F','T') 
			AND VV0.VV0_OPEMOV  = '0' 
			AND VV0.VV0_SITNFI = '1' 
			AND VRK.%notDel% 
		ORDER BY VRK.VRK_ITEPED
	EndSql
	While ! (cAliasFat)->(Eof())
		AADD( aRetorno , { Len(aRetorno) + 1 , Array(Len(aFields)) } )
		nPos := Len(aRetorno)
		aRetorno[ nPos , 2 ] [ nRFATDOC     ] := (cAliasFat)->F2_DOC
		aRetorno[ nPos , 2 ] [ nRFATSERIE   ] := (cAliasFat)->F2_SERIE
		aRetorno[ nPos , 2 ] [ nRFATEMISSAO ] := (cAliasFat)->F2_EMISSAO
		aRetorno[ nPos , 2 ] [ nRFATVALBRUT ] := (cAliasFat)->F2_VALBRUT
		aRetorno[ nPos , 2 ] [ nRFATTES     ] := (cAliasFat)->D2_TES
		aRetorno[ nPos , 2 ] [ nRFATCF      ] := (cAliasFat)->D2_CF
		aRetorno[ nPos , 2 ] [ nRFATLOCAL   ] := (cAliasFat)->D2_LOCAL
		
		(cAliasFat)->(dbSkip())
	End
	(cAliasFat)->(dbCloseArea())

	CursorArrow()

Return aRetorno 

Function VC0600043_StructAtendimento()

	Local oRetorno := OFDMSStruct():New()

	CursorWait()

	oRetorno:AddFieldDictionary( "VV0" , "VV0_NUMTRA" , { {"cIdField" , "RATENUMTRA" } , { "lVirtual", .t. } , { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "VV0" , "VV0_DATMOV" , { {"cIdField" , "RATEDATMOV" } , { "lVirtual", .t. } , { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "VV0" , "VV0_VALTOT" , { {"cIdField" , "RATEVALTOT" } , { "lVirtual", .t. } , { "lCanChange" , .f. } } )
	//oRetorno:AddFieldDictionary( "VV0" , "VV0_VALTRO" , { {"cIdField" , "RATEVALTRO" } , { "lVirtual", .t. } , { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "VVA" , "VVA_CHASSI" , { {"cIdField" , "RATECHASSI" } , { "lVirtual", .t. } , { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "VVA" , "VVA_VALVDA" , { {"cIdField" , "RATEVALVDA" } , {"cTitulo",STR0011},  { "lVirtual", .t. } , { "lCanChange" , .f. } } ) // "Valor Veículo"

	CursorArrow()

Return oRetorno

Function VC0600053_LoadResumoAtendimento(oSubModel)
	Local oStruct := oSubModel:getstruct()
	Local aFields := oStruct:GetFields()
	Local aRetorno := {}

	Local nRATENUMTRA := aScan( aFields , { |x| x[MVC_MODEL_IDFIELD] == "RATENUMTRA" } )
	Local nRATEDATMOV := aScan( aFields , { |x| x[MVC_MODEL_IDFIELD] == "RATEDATMOV" } )
	Local nRATEVALTOT := aScan( aFields , { |x| x[MVC_MODEL_IDFIELD] == "RATEVALTOT" } )
	//Local nRATEVALTRO := aScan( aFields , { |x| x[MVC_MODEL_IDFIELD] == "RATEVALTRO" } )
	Local nRATECHASSI := aScan( aFields , { |x| x[MVC_MODEL_IDFIELD] == "RATECHASSI" } )
	Local nRATEVALVDA := aScan( aFields , { |x| x[MVC_MODEL_IDFIELD] == "RATEVALVDA" } )

	Local cAliasAtend := "TRESATE"

	CursorWait()

	BeginSQL Alias cAliasAtend
		COLUMN VV0_DATMOV AS DATE
		COLUMN VV0_VALTOT AS NUMERIC(10,2)
		COLUMN VVA_VALVDA AS NUMERIC(10,2)

		SELECT VV0_NUMTRA, VV0_DATMOV, VV0_VALTOT, VVA_CHASSI, VVA_VALVDA
	
		FROM 
  			%table:VRK% VRK
			  JOIN %table:VV9% VV9 ON VV9.VV9_FILIAL = %xFilial:VV9% AND VV9.VV9_NUMATE = VRK.VRK_NUMTRA AND VV9.%notDel% 
			  JOIN %table:VV0% VV0 ON VV0.VV0_FILIAL = %xFilial:VV0% AND VV0.VV0_NUMTRA = VV9.VV9_NUMATE AND VV0.%notDel% 
			  JOIN %table:VVA% VVA ON VVA.VVA_FILIAL = %xFilial:VVA% AND VVA.VVA_NUMTRA = VV0.VV0_NUMTRA AND VVA.VVA_ITETRA = VRK.VRK_ITETRA  AND VVA.%notDel% 
		WHERE
			VRK.VRK_FILIAL = %xFilial:VRK%
			AND VRK.VRK_PEDIDO = %exp:VRJ->VRJ_PEDIDO%
			AND VV9.VV9_STATUS IN ('F','T') 
			AND VV0.VV0_OPEMOV  = '0' 
			AND VRK.%notDel% 
		ORDER BY VRK.VRK_ITEPED
	EndSql
	While ! (cAliasAtend)->(Eof())
		AADD( aRetorno , { Len(aRetorno) + 1 , Array(Len(aFields)) } )
		nPos := Len(aRetorno)
		aRetorno[ nPos , 2 ] [ nRATENUMTRA ] := (cAliasAtend)->VV0_NUMTRA
		aRetorno[ nPos , 2 ] [ nRATEDATMOV ] := (cAliasAtend)->VV0_DATMOV
		aRetorno[ nPos , 2 ] [ nRATEVALTOT ] := (cAliasAtend)->VV0_VALTOT
		//aRetorno[ nPos , 2 ] [ nRATEVALTRO ] := (cAliasAtend)->VV0_VALTRO
		aRetorno[ nPos , 2 ] [ nRATECHASSI ] := (cAliasAtend)->VVA_CHASSI
		aRetorno[ nPos , 2 ] [ nRATEVALVDA ] := (cAliasAtend)->VVA_VALVDA
		
		(cAliasAtend)->(dbSkip())
	End
	(cAliasAtend)->(dbCloseArea())

	CursorArrow()

Return aRetorno 

Static Function BrowseDef()

	Local oBrowse := StaticCall(VEIA060,BrowseDef)
	oBrowse:SetDescription( STR0012 ) // "Follow-up Pedido de Venda"
Return oBrowse

Static Function MenuDef()
	Local aRotina := {}
	ADD OPTION aRotina TITLE STR0013 ACTION 'VIEWDEF.VEIC060' OPERATION 2 ACCESS 0 // 'Visualizar'
Return aRotina

Function VC0600063_StructAtendimentoFinanceiro()

	Local oRetorno := OFDMSStruct():New()

	CursorWait()

	oRetorno:AddFieldDictionary( "SE1" , "E1_PREFIXO" , { { "cIdField", "RFIATPREFIXO" } , { "lVirtual", .t. } , { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "SE1" , "E1_NUM"     , { { "cIdField", "RFIATNUM"     } , { "lVirtual", .t. } , { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "SE1" , "E1_PARCELA" , { { "cIdField", "RFIATPARCELA" } , { "lVirtual", .t. } , { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "SE1" , "E1_TIPO"    , { { "cIdField", "RFIATTIPO"    } , { "lVirtual", .t. } , { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "SE1" , "E1_NATUREZ" , { { "cIdField", "RFIATNATUREZ" } , { "lVirtual", .t. } , { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "SE1" , "E1_EMISSAO" , { { "cIdField", "RFIATEMISSAO" } , { "lVirtual", .t. } , { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "SE1" , "E1_VENCTO"  , { { "cIdField", "RFIATVENCTO"  } , { "lVirtual", .t. } , { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "SE1" , "E1_VENCREA" , { { "cIdField", "RFIATVENCREA" } , { "lVirtual", .t. } , { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "SE1" , "E1_BAIXA"   , { { "cIdField", "RFIATBAIXA"   } , { "lVirtual", .t. } , { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "SE1" , "E1_VALOR"   , { { "cIdField", "RFIATVALOR"   } , { "lVirtual", .t. } , { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "SE1" , "E1_SALDO"   , { { "cIdField", "RFIATSALDO"   } , { "lVirtual", .t. } , { "lCanChange" , .f. } } )

	CursorArrow()

Return oRetorno

Function VC0600073_LoadResumoFinancAtendimento(oSubModel)

	Local oStruct := oSubModel:getstruct()
	Local aFields := oStruct:GetFields()
	Local aRetorno := {}
	Local oSQLHelper := DMS_SQLHelper():New()

	Local cPrefOri      := GetNewPar("MV_PREFVEI","VEI")

	Local nRFIATPREFIXO := aScan( aFields , { |x| x[MVC_MODEL_IDFIELD] == "RFIATPREFIXO" })
	Local nRFIATNUM     := aScan( aFields , { |x| x[MVC_MODEL_IDFIELD] == "RFIATNUM"     })
	Local nRFIATPARCELA := aScan( aFields , { |x| x[MVC_MODEL_IDFIELD] == "RFIATPARCELA" })
	Local nRFIATTIPO    := aScan( aFields , { |x| x[MVC_MODEL_IDFIELD] == "RFIATTIPO"    })
	Local nRFIATNATUREZ := aScan( aFields , { |x| x[MVC_MODEL_IDFIELD] == "RFIATNATUREZ" })
	Local nRFIATEMISSAO := aScan( aFields , { |x| x[MVC_MODEL_IDFIELD] == "RFIATEMISSAO" })
	Local nRFIATVENCTO  := aScan( aFields , { |x| x[MVC_MODEL_IDFIELD] == "RFIATVENCTO"  })
	Local nRFIATVENCREA := aScan( aFields , { |x| x[MVC_MODEL_IDFIELD] == "RFIATVENCREA" })
	Local nRFIATBAIXA   := aScan( aFields , { |x| x[MVC_MODEL_IDFIELD] == "RFIATBAIXA"   })
	Local nRFIATVALOR   := aScan( aFields , { |x| x[MVC_MODEL_IDFIELD] == "RFIATVALOR"   })
	Local nRFIATSALDO   := aScan( aFields , { |x| x[MVC_MODEL_IDFIELD] == "RFIATSALDO"   })

	Local cAliasFinAt := "TRESATE"

	CursorWait()

	//cNumTit := "V"+Right(VV9->VV9_NUMATE,TamSx3("E1_NUM")[1]-1)
	//cNumNFI := VV0->VV0_NUMNFI
	//cSerNFI := VV0->VV0_SERNFI
	//" VV0 ON VV0.VV0_FILIAL = '" + xFilial("VV0") + "' AND VV0.VV0_NUMTRA = VV9.VV9_NUMATE AND VV0.D_E_L_E_T_ = ' '" +;
	cQuery := ;
		"SELECT SE1.R_E_C_N_O_ AS RECSE1 " +;
		 " FROM " + RetSQLName("VRK") + " VRK " +;
				" JOIN " + RetSQLName("VV9") + " VV9 ON VV9.VV9_FILIAL = '" + xFilial("VV9") + "' AND VV9.VV9_NUMATE = VRK.VRK_NUMTRA AND VV9.D_E_L_E_T_ = ' '" +;
				" JOIN " + RetSQLName("VV0") + " VV0 ON VV0.VV0_FILIAL = '" + xFilial("VV0") + "' AND VV0.VV0_NUMTRA = VV9.VV9_NUMATE AND VV0.D_E_L_E_T_ = ' '" +;
				" LEFT JOIN " + RetSQLName("SF2") + " SF2 ON SF2.F2_FILIAL = '" + xFilial("SF2") + "' AND SF2.F2_SERIE = VV0.VV0_SERNFI AND SF2.F2_DOC = VV0.VV0_NUMNFI AND SF2.F2_PREFORI = '" + cPrefOri + "' AND SF2.D_E_L_E_T_ = ' ' " +;
				" JOIN " + RetSQLName("SE1") + " SE1 " +; 
					" ON SE1.E1_FILIAL = '" + xFilial("SE1") + "'" +;
					" AND ( " +;
					        " SE1.E1_NUM = " + oSQLHelper:Concat( { "'V'" , oSQLHelper:CompatFunc("SUBSTR") + "(VV9.VV9_NUMATE,2," + Str(TamSx3("E1_NUM")[1],2) + ")" } ) +; // Titulos gerados na aprovacao do atendimento
					        " OR " +;
							  "( SE1.E1_NUM = VV0.VV0_NUMNFI AND SE1.E1_PREFIXO = SF2.F2_PREFIXO AND SE1.E1_PREFORI = '" + cPrefOri + "' )" +; // Titulos gerados no faturamento do atendimento
					        " OR " +;
							  "( SE1.E1_NUM = VV0.VV0_NUMNFI AND SE1.E1_PREFIXO = SF2.F2_PREFIXO AND SE1.E1_SERIE = SF2.F2_SERIE AND SE1.E1_PREFORI = ' ' )" +; // Titulos gerados no faturamento do atendimento através de condicao de pagamento padrao 
					    " ) " +;
					" AND SE1.E1_FILORIG = '" + xFilial("VV9") + "'" +;
					" AND SE1.D_E_L_E_T_=' '" +;
		" WHERE VRK.VRK_FILIAL = '" + xFilial("VRK") + "' " +;
		  " AND VRK.VRK_PEDIDO = '" + VRJ->VRJ_PEDIDO + "' " +;
		  " AND VV9.VV9_STATUS IN ('F','T') " +;
		  " AND VV0.VV0_OPEMOV = '0' " +;
		  " AND VRK.D_E_L_E_T_ = ' '" +;
		" ORDER BY SE1.E1_PREFIXO, SE1.E1_NUM, SE1.E1_PARCELA"
	
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasFinAt, .F., .T. )
	While ! (cAliasFinAt)->(Eof())

		SE1->(dbGoTo((cAliasFinAt)->RECSE1))

		AADD( aRetorno , { Len(aRetorno) + 1 , Array(Len(aFields)) } )
		nPos := Len(aRetorno)
		aRetorno[ nPos , 2 ] [ nRFIATPREFIXO ] := SE1->E1_PREFIXO
		aRetorno[ nPos , 2 ] [ nRFIATNUM     ] := SE1->E1_NUM
		aRetorno[ nPos , 2 ] [ nRFIATPARCELA ] := SE1->E1_PARCELA
		aRetorno[ nPos , 2 ] [ nRFIATTIPO    ] := SE1->E1_TIPO
		aRetorno[ nPos , 2 ] [ nRFIATNATUREZ ] := SE1->E1_NATUREZ
		aRetorno[ nPos , 2 ] [ nRFIATEMISSAO ] := SE1->E1_EMISSAO
		aRetorno[ nPos , 2 ] [ nRFIATVENCTO  ] := SE1->E1_VENCTO
		aRetorno[ nPos , 2 ] [ nRFIATVENCREA ] := SE1->E1_VENCREA
		aRetorno[ nPos , 2 ] [ nRFIATBAIXA   ] := SE1->E1_BAIXA
		aRetorno[ nPos , 2 ] [ nRFIATVALOR   ] := SE1->E1_VALOR
		aRetorno[ nPos , 2 ] [ nRFIATSALDO   ] := SE1->E1_SALDO
		
		(cAliasFinAt)->(dbSkip())
	End
	(cAliasFinAt)->(dbCloseArea())

	CursorArrow()

Return aRetorno 
