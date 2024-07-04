#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "VEIA030.CH"

/*/{Protheus.doc} VEIA030
Cadastro de Modelo - MVC
@author Rubens
@since 28/11/2018
@version 1.0


@type function
/*/
Function VEIA030()

	Local oBrowse
	// Instanciamento da Classe de Browse
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('VV2')
	oBrowse:SetDescription(STR0001) // 'Cadastro de Modelo'
	oBrowse:Activate()
Return

Static Function ModelDef()
	
	Local oModel
	Local aAuxTrigger

	Local oStruVV2 := FWFormStruct( 1, 'VV2' )
	
	Local oStruVAG := FWFormStruct( 1, 'VAG' ) // Tabela de Itens de Entrega
	Local oStruVVL := FWFormStruct( 1, 'VVL' ) // Tabela de Periodo de Garantia
	Local oStruVVM := FWFormStruct( 1, 'VVM' ) // Tabela de Opcionais
	Local oStruVVP := FWFormStruct( 1, 'VVP' ) // Tabela de Preços de Veículos
	Local oStruVZP := FWFormStruct( 1, 'VZP' ) // Tabela de Faturamento Direto do Modelo

	oModel := MPFormModel():New('VEIA030' )

	// ============================ //
	// Estrutura da tabela de Preço //
	// ============================ //
	oStruVVP:SetProperty( 'VVP_CODMAR', MODEL_FIELD_OBRIGAT , .f. ) // Campos serão preenchidos pelo Framework MVC
	oStruVVP:SetProperty( 'VVP_MODVEI', MODEL_FIELD_OBRIGAT , .f. ) // Campos serão preenchidos pelo Framework MVC
	oStruVVP:SetProperty( 'VVP_DATPRC', MODEL_FIELD_OBRIGAT , .t. )
	oStruVVP:SetProperty( 'VVP_CUSTAB', MODEL_FIELD_OBRIGAT , .t. )
	oStruVVP:SetProperty( 'VVP_VALTAB', MODEL_FIELD_OBRIGAT , .t. )

	If VVP->(ColumnPos("VVP_FABMOD")) > 0
		oStruVVP:SetProperty( 'VVP_DATPRC', MODEL_FIELD_VALID , FWBuildFeature(STRUCT_FEATURE_VALID,".t.") )
		oStruVVP:SetProperty( 'VVP_FABMOD', MODEL_FIELD_VALID , FWBuildFeature(STRUCT_FEATURE_VALID,".t.") )
	EndIf

	// ================================ //
	// Estrutura da tabela de Opcionais // 
	// ================================ //
	oStruVVM:SetProperty( 'VVM_CODMAR', MODEL_FIELD_OBRIGAT , .f. ) // Campos serão preenchidos pelo Framework MVC
	oStruVVM:SetProperty( 'VVM_MODVEI', MODEL_FIELD_OBRIGAT , .f. ) // Campos serão preenchidos pelo Framework MVC

	oStruVVM:SetProperty( 'VVM_CODOPC', MODEL_FIELD_VALID , FWBuildFeature(STRUCT_FEATURE_VALID,"Vazio() .or. ExistCPO('VVW', FWFldGet('VV2_CODMAR') + FwFldGet('VVM_CODOPC'))") )
	aAuxTrigger := FwStruTrigger("VVM_CODOPC","VVM_DESITE","VVW->VVW_DESOPC",.T.,"VVW",1,"xFilial('VVW') + FWFldGet('VV2_CODMAR') + FwFldGet('VVM_CODOPC')")
	oStruVVM:AddTrigger(aAuxTrigger[1], aAuxTrigger[2], aAuxTrigger[3], aAuxTrigger[4])

	// ========================================== //
	// Estrutura da tabela de Periodo de Garantia // 
	// ========================================== //
	oStruVVL:SetProperty( 'VVL_CODMAR', MODEL_FIELD_OBRIGAT , .f. ) // Campos serão preenchidos pelo Framework MVC
	oStruVVL:SetProperty( 'VVL_MODVEI', MODEL_FIELD_OBRIGAT , .f. ) // Campos serão preenchidos pelo Framework MVC
	oStruVVL:SetProperty( 'VVL_PERGAR', MODEL_FIELD_OBRIGAT , .t. )
	oStruVVL:SetProperty( 'VVL_KILGAR', MODEL_FIELD_OBRIGAT , .t. )

	// ======================================= //
	// Estrutura da tabela de Itens de Entrega // 
	// ======================================= //
	oStruVAG:SetProperty( 'VAG_CODMAR', MODEL_FIELD_OBRIGAT , .f. ) // Campos serão preenchidos pelo Framework MVC
	oStruVAG:SetProperty( 'VAG_MODVEI', MODEL_FIELD_OBRIGAT , .f. ) // Campos serão preenchidos pelo Framework MVC

	oStruVAG:SetProperty( 'VAG_CODIGO', MODEL_FIELD_VALID , FWBuildFeature(STRUCT_FEATURE_VALID,"Vazio() .or. ExistCPO('VAF')") )
	aAuxTrigger := FwStruTrigger("VAG_CODIGO","VAG_DESCRI","VAF->VAF_DESCRI",.T.,"VAF",1,"xFilial('VAF') + FWFldGet('VAG_CODIGO')")
	oStruVAG:AddTrigger(aAuxTrigger[1], aAuxTrigger[2], aAuxTrigger[3], aAuxTrigger[4])

	// ======================================================= //
	// Estrutura da tabela de Percentual de Faturamento Direto // 
	// ======================================================= //
	oStruVZP:SetProperty( 'VZP_VALVEN', MODEL_FIELD_VALID , FWBuildFeature(STRUCT_FEATURE_VALID,"Positivo()") )
	oStruVZP:SetProperty( 'VZP_DESCON', MODEL_FIELD_VALID , FWBuildFeature(STRUCT_FEATURE_VALID,"Positivo()") )
	oStruVZP:SetProperty( 'VZP_COMISS', MODEL_FIELD_VALID , FWBuildFeature(STRUCT_FEATURE_VALID,"Positivo()") )

	aAuxTrigger := FwStruTrigger("VZP_TIPO","VZP_SEQUEN","VA0300013_SequenciaVZP()",.F.,,,,"!Empty(FWFldGet('VZP_TIPO'))",'01')
	oStruVZP:AddTrigger(aAuxTrigger[1], aAuxTrigger[2], aAuxTrigger[3], aAuxTrigger[4])

	// ======================================= //	
	oModel:AddFields( 'MODEL_VV2', /*cOwner*/, oStruVV2)
	oModel:AddGrid( 'MODEL_VVP', 'MODEL_VV2', oStruVVP)
	oModel:AddGrid( 'MODEL_VZP', 'MODEL_VV2', oStruVZP)
	oModel:AddGrid( 'MODEL_VAG', 'MODEL_VV2', oStruVAG)
	oModel:AddGrid( 'MODEL_VVL', 'MODEL_VV2', oStruVVL)
	oModel:AddGrid( 'MODEL_VVM', 'MODEL_VV2', oStruVVM)

	oModel:SetDescription( STR0002 )
	oModel:GetModel( 'MODEL_VV2' ):SetDescription( STR0003 ) // 'Dados de Modelo' 
	oModel:GetModel( 'MODEL_VVP' ):SetDescription( STR0004 ) // 'Dados de Tabela de Preço'
	oModel:GetModel( 'MODEL_VVM' ):SetDescription( STR0005 ) // 'Dados de Opcionais de Fábrica'
	oModel:GetModel( 'MODEL_VVL' ):SetDescription( STR0006 ) // 'Dados de Período de Garantia'
	oModel:GetModel( 'MODEL_VAG' ):SetDescription( STR0007 ) // 'Dados de Itens de Entrega'
	oModel:GetModel( 'MODEL_VZP' ):SetDescription( STR0008 ) // 'Dados de Faturamento Direto do Modelo' 

	oModel:SetRelation('MODEL_VZP', { { 'VZP_FILIAL' , 'xFilial("VZP")' } , { 'VZP_CODMAR' , 'VV2_CODMAR' } , { 'VZP_MODVEI' , 'VV2_MODVEI' } , { 'VZP_SEGMOD' , 'VV2_SEGMOD' } } , 'VZP_FILIAL+VZP_CODMAR+VZP_MODVEI+VZP_SEGMOD' )
	oModel:SetRelation('MODEL_VVM', { { 'VVM_FILIAL' , 'xFilial("VVM")' } , { 'VVM_CODMAR' , 'VV2_CODMAR' } , { 'VVM_MODVEI' , 'VV2_MODVEI' } , { 'VVM_SEGMOD' , 'VV2_SEGMOD' } } , 'VVM_FILIAL+VVM_CODMAR+VVM_MODVEI+VVM_SEGMOD' )
	oModel:SetRelation('MODEL_VVP', { { 'VVP_FILIAL' , 'xFilial("VVP")' } , { 'VVP_CODMAR' , 'VV2_CODMAR' } , { 'VVP_MODVEI' , 'VV2_MODVEI' } , { 'VVP_SEGMOD' , 'VV2_SEGMOD' } } , 'VVP_FILIAL+VVP_CODMAR+VVP_MODVEI+VVP_SEGMOD' )
	oModel:SetRelation('MODEL_VAG', { { 'VAG_FILIAL' , 'xFilial("VAG")' } , { 'VAG_CODMAR' , 'VV2_CODMAR' } , { 'VAG_MODVEI' , 'VV2_MODVEI' } , { 'VAG_SEGMOD' , 'VV2_SEGMOD' } } , 'VAG_FILIAL+VAG_CODMAR+VAG_MODVEI+VAG_SEGMOD' )
	oModel:SetRelation('MODEL_VVL', { { 'VVL_FILIAL' , 'xFilial("VVL")' } , { 'VVL_CODMAR' , 'VV2_CODMAR' } , { 'VVL_MODVEI' , 'VV2_MODVEI' } , { 'VVL_SEGMOD' , 'VV2_SEGMOD' } } , 'VVL_FILIAL+VVL_CODMAR+VVL_MODVEI+VVL_SEGMOD' )

	oModel:SetPrimaryKey( { "VV2_FILIAL", "VV2_CODMAR", "VV2_MODVEI", "VV2_SEGMOD" } )

	If VVP->(ColumnPos("VVP_FABMOD")) > 0
		oModel:GetModel( 'MODEL_VVP' ):SetUniqueLine( { "VVP_DATPRC" , "VVP_FABMOD" } )
	Else
		oModel:GetModel( 'MODEL_VVP' ):SetUniqueLine( { "VVP_DATPRC" } )
	EndIf

	oModel:GetModel( 'MODEL_VVM' ):SetUniqueLine( { "VVM_CODOPC"} )
	oModel:GetModel( 'MODEL_VVL' ):SetUniqueLine( { "VVL_DATGAR"} )
	oModel:GetModel( 'MODEL_VAG' ):SetUniqueLine( { "VAG_CODIGO"} )

	oModel:GetModel( 'MODEL_VVP' ):SetOptional( .T. )
	oModel:GetModel( 'MODEL_VVM' ):SetOptional( .T. )
	oModel:GetModel( 'MODEL_VZP' ):SetOptional( .T. )
	oModel:GetModel( 'MODEL_VAG' ):SetOptional( .T. )
	oModel:GetModel( 'MODEL_VVL' ):SetOptional( .T. )

Return oModel

Static Function ViewDef()

	Local oModel := FWLoadModel( 'VEIA030' )
	Local oStruVV2 := FWFormStruct( 2, 'VV2' )
	Local oStruVZP := FWFormStruct( 2, 'VZP' )
	Local oStruVAG := FWFormStruct( 2, 'VAG' )
	Local oStruVVL := FWFormStruct( 2, 'VVL' )
	Local oStruVVM := FWFormStruct( 2, 'VVM' )
	Local oStruVVP := FWFormStruct( 2, 'VVP' )
	Local oView

	oStruVZP:RemoveField('VZP_CODMAR')
	oStruVZP:RemoveField('VZP_MODVEI')
	oStruVZP:RemoveField('VZP_SEGMOD')
	

	oStruVAG:RemoveField('VAG_CODMAR')
	oStruVAG:RemoveField('VAG_MODVEI')
	oStruVAG:RemoveField('VAG_SEGMOD')

	oStruVVL:RemoveField('VVL_CODMAR')
	oStruVVL:RemoveField('VVL_MODVEI')
	oStruVVL:RemoveField('VVL_SEGMOD')
	oStruVVL:RemoveField('VVL_DESMOD')
	
	oStruVVM:RemoveField('VVM_CODMAR')
	oStruVVM:RemoveField('VVM_MODVEI')
	oStruVVM:RemoveField('VVM_SEGMOD')
	oStruVVM:RemoveField('VVM_DESMOD')
	
	oStruVVP:RemoveField('VVP_CODMAR')
	oStruVVP:RemoveField('VVP_MODVEI')
	oStruVVP:RemoveField('VVP_SEGMOD')
	oStruVVP:RemoveField('VVP_DESMAR')
	oStruVVP:RemoveField('VVP_DESMOD')
	oStruVVP:RemoveField('VVP_DATUSU')

	oView := FWFormView():New()
	oView:SetModel( oModel )
	
	oView:AddField( 'VIEW_VV2', oStruVV2, 'MODEL_VV2' )
	oView:AddGrid( 'VIEW_VZP', oStruVZP, 'MODEL_VZP')
	oView:AddGrid( 'VIEW_VAG', oStruVAG, 'MODEL_VAG')
	oView:AddGrid( 'VIEW_VVL', oStruVVL, 'MODEL_VVL')
	oView:AddGrid( 'VIEW_VVM', oStruVVM, 'MODEL_VVM')
	oView:AddGrid( 'VIEW_VVP', oStruVVP, 'MODEL_VVP')


	oView:CreateHorizontalBox( 'TELAVV2' , 60 )
	oView:CreateHorizontalBox( 'TELAFOLDER' , 40 )

	oView:CreateFolder('VIEW_FOLDER', 'TELAFOLDER')

	oView:AddSheet('VIEW_FOLDER','VIEW_SHEET_VVP',STR0009) // Preços
	oView:AddSheet('VIEW_FOLDER','VIEW_SHEET_VVM',STR0010) // Opcionais de Fábrica
	oView:AddSheet('VIEW_FOLDER','VIEW_SHEET_VVL',STR0011) // Garantia
	oView:AddSheet('VIEW_FOLDER','VIEW_SHEET_VAG',STR0012) // Itens Entrega
	oView:AddSheet('VIEW_FOLDER','VIEW_SHEET_VZP',STR0013) // '% Venda Direta

	oView:CreateHorizontalBox( 'TELAVZP' , 100, , , 'VIEW_FOLDER','VIEW_SHEET_VZP' )
	oView:CreateHorizontalBox( 'TELAVAG' , 100, , , 'VIEW_FOLDER','VIEW_SHEET_VAG' )
	oView:CreateHorizontalBox( 'TELAVVL' , 100, , , 'VIEW_FOLDER','VIEW_SHEET_VVL' )
	oView:CreateHorizontalBox( 'TELAVVM' , 100, , , 'VIEW_FOLDER','VIEW_SHEET_VVM' )
	oView:CreateHorizontalBox( 'TELAVVP' , 100, , , 'VIEW_FOLDER','VIEW_SHEET_VVP' )

	oView:SetOwnerView( 'VIEW_VV2', 'TELAVV2' )
	oView:SetOwnerView( 'VIEW_VZP', 'TELAVZP' )
	oView:SetOwnerView( 'VIEW_VAG', 'TELAVAG' )
	oView:SetOwnerView( 'VIEW_VVL', 'TELAVVL' )
	oView:SetOwnerView( 'VIEW_VVM', 'TELAVVM' )
	oView:SetOwnerView( 'VIEW_VVP', 'TELAVVP' )

Return oView

Static Function MenuDef()
	Local aRotina := {}
	ADD OPTION aRotina Title STR0014 Action 'VIEWDEF.VEIA030' OPERATION 2 ACCESS 0 // 'Visualizar'
	ADD OPTION aRotina Title STR0015 Action 'VIEWDEF.VEIA030' OPERATION 3 ACCESS 0 // 'Incluir'
	ADD OPTION aRotina Title STR0016 Action 'VIEWDEF.VEIA030' OPERATION 4 ACCESS 0 // 'Alterar'
	ADD OPTION aRotina Title STR0017 Action 'VIEWDEF.VEIA030' OPERATION 5 ACCESS 0 // 'Excluir'
	ADD OPTION aRotina Title STR0018 Action 'VIEWDEF.VEIA030' OPERATION 8 ACCESS 0 // 'Imprimir'
	ADD OPTION aRotina Title STR0019 Action 'VIEWDEF.VEIA030' OPERATION 9 ACCESS 0 // 'Copiar'
	ADD OPTION aRotina Title STR0020 Action 'VA0300023_ReplComerc' OPERATION 4 ACCESS 0 // 'Replicar Comercialização'
Return aRotina

Function VA0300013_SequenciaVZP()
	Local oModel := FWModelActive()
	
	Local oMVZP  := oModel:GetModel("MODEL_VZP")
	Local nQtdLinha  := oMVZP:Length()
	Local cTipo := FWFldGet("VZP_TIPO")

	Local nTamSeq := GetSX3Cache("VZP_SEQUEN","X3_TAMANHO")
	Local cSequen := StrZero(1,nTamSeq)
	Local nLinha

	For nLinha := 1 to nQtdLinha

		If oMVZP:GetValue('VZP_TIPO',nLinha) == cTipo .and. oMVZP:GetValue('VZP_SEQUEN',nLinha) >= cSequen 
			cSequen := Soma1(oMVZP:GetValue('VZP_SEQUEN',nLinha))
		EndIf

	Next nLinha

Return cSequen

Function VA0300023_ReplComerc()
	VEIA030A()
Return