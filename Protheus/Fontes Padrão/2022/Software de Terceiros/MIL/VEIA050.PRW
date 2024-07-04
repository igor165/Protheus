#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

#INCLUDE "VEIA050.CH"


Static cCpoCabVV2 := "VV2_CODMAR/VV2_DESMAR/VV2_GRUMOD/VV2_DESGRU/VV2_MODVEI/VV2_DESMOD/VV2_INIMOD/VV2_FINMOD/VV2_CATVEI/" +;
							"VV2_TIPVEI/VV2_ESPVEI/VV2_QTDEIX/VV2_DESCAT/VV2_DESTIP/VV2_DESESP/" +;
							"VV2_RELDIF/VV2_CAPTRA/VV2_TIPCAB/VV2_QTDCIL/VV2_TIPCAM/VV2_CILMOT/VV2_TIPMOT/" +;
							"VV2_POTMOT/VV2_DISEIX/VV2_CM3/VV2_TANQUE/VV2_COMVEI/VV2_CARREN/"
Static cCpoCabPar := "VV2_CODMAR/VV2_GRUMOD/VV2_MODVEI"

Static oModVV2Par := VA0500013_Cabecalho()

/*/{Protheus.doc} VEIA050
Cadastro de Modelo - MVC - Mod.2 
@author Rubens
@since 28/11/2018
@version 1.0


@type function
/*/
Function VEIA050()

	Local oBrowse

	Private M->VV2_CODMAR := ""
	Private M->VV2_GRUMOD := ""
	Private M->VV2_MODVEI := ""

	Private M->VO6_CODMAR := ""
	Private M->VAG_CODMAR := ""
	Private M->VVL_CODMAR := ""
	Private M->VVM_CODMAR := ""
	Private M->VVP_CODMAR := ""
	Private M->VZP_CODMAR := ""

	// Instanciamento da Classe de Browse
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('VV2')
	oBrowse:SetDescription(STR0001) // 'Cadastro de Modelo - Mod. 2'
	oBrowse:Activate()

Return

Static Function ModelDef()
	
	Local oModel
	Local aAuxTrigger

	Local oStruVV2Cab := FWFormStruct( 1, 'VV2', { |cCampo| ALLTRIM(cCampo) $ cCpoCabVV2 } )
	Local oStruVV2    := FWFormStruct( 1, 'VV2' )
	
	Local oStruVV2Par := oModVV2Par:GetModel()

	Local oStruVAG := FWFormStruct( 1, 'VAG' ) // Tabela de Itens de Entrega
	Local oStruVVL := FWFormStruct( 1, 'VVL' ) // Tabela de Periodo de Garantia
	Local oStruVVM := FWFormStruct( 1, 'VVM' ) // Tabela de Opcionais
	Local oStruVVP := FWFormStruct( 1, 'VVP' ) // Tabela de Preços de Veículos
	Local oStruVZP := FWFormStruct( 1, 'VZP' ) // Tabela de Faturamento Direto do Modelo

	Local bAuxInit
	Local aAuxFields
	Local nPosField

	oModel := MPFormModel():New('VEIA050')

	oStruVV2:SetProperty( 'VV2_DESAGM', MODEL_FIELD_INIT , FWBuildFeature(STRUCT_FEATURE_INIPAD,"IF(!INCLUI,POSICIONE('VSX',1,XFILIAL('VSX')+VV2->VV2_CODAGM,'VSX_DESAGM'),'')") )

	bAuxInit := FWBuildFeature(STRUCT_FEATURE_INIPAD,"FWFldGet('VV2_CODMAR')")
//	oStruVV2:SetProperty( 'VV2_CODMAR', MODEL_FIELD_INIT , bAuxInit )
	oStruVVP:SetProperty( 'VVP_CODMAR', MODEL_FIELD_INIT , bAuxInit )
	oStruVVL:SetProperty( 'VVL_CODMAR', MODEL_FIELD_INIT , bAuxInit )
	oStruVVM:SetProperty( 'VVM_CODMAR', MODEL_FIELD_INIT , bAuxInit )
	oStruVAG:SetProperty( 'VAG_CODMAR', MODEL_FIELD_INIT , bAuxInit )
	oStruVZP:SetProperty( 'VZP_CODMAR', MODEL_FIELD_INIT , bAuxInit ) 

	bAuxInit := FWBuildFeature(STRUCT_FEATURE_INIPAD,"FWFldGet('VV2_MODVEI')")
//	oStruVV2:SetProperty( 'VV2_MODVEI', MODEL_FIELD_INIT , bAuxInit )
	oStruVVP:SetProperty( 'VVP_MODVEI', MODEL_FIELD_INIT , bAuxInit )
	oStruVVL:SetProperty( 'VVL_MODVEI', MODEL_FIELD_INIT , bAuxInit )
	oStruVVM:SetProperty( 'VVM_MODVEI', MODEL_FIELD_INIT , bAuxInit )
	oStruVAG:SetProperty( 'VAG_MODVEI', MODEL_FIELD_INIT , bAuxInit )

//	bAuxInit := FWBuildFeature(STRUCT_FEATURE_INIPAD,"FWFldGet('VV2_GRUMOD')")
//	oStruVV2:SetProperty( 'VV2_GRUMOD', MODEL_FIELD_INIT , bAuxInit )

	// ========================================= //
	// Estrutura da tabela de Modelo - Cabecalho //
	// ========================================= //
	oStruVV2Cab:SetProperty( 'VV2_GRUMOD', MODEL_FIELD_VALID , FWBuildFeature(STRUCT_FEATURE_VALID,"Vazio() .or. ExistCPO('VVR',FWFldGet('VV2_CODMAR')+FWFldGet('VV2_GRUMOD'),2)") )
	oStruVV2Cab:SetProperty( 'VV2_MODVEI', MODEL_FIELD_VALID , FWBuildFeature(STRUCT_FEATURE_VALID,"Vazio() .or. ExistCHAV('VV2', FWFldGet('VV2_CODMAR')+FWFldGet('VV2_MODVEI'))") )

	aAuxTrigger := FwStruTrigger("VV2_GRUMOD","VV2_DESGRU","VVR->VVR_DESCRI",.T.,"VVR",2,"xFilial('VVR') + FWFldGet('VV2_CODMAR') + FwFldGet('VV2_GRUMOD')")
	oStruVV2Cab:AddTrigger(aAuxTrigger[1], aAuxTrigger[2], aAuxTrigger[3], aAuxTrigger[4])
	
	oStruVV2Cab:SetProperty( 'VV2_CATVEI', MODEL_FIELD_VALID , FWBuildFeature(STRUCT_FEATURE_VALID,"Vazio() .or. ExistCPO('VVB')") )
	aAuxTrigger := FwStruTrigger("VV2_CATVEI","VV2_DESCAT","VVB->VVB_DESCRI",.T.,"VVB",1,"xFilial('VVB') + FwFldGet('VV2_CATVEI')","NaoVazio()")
	oStruVV2Cab:AddTrigger(aAuxTrigger[1], aAuxTrigger[2], aAuxTrigger[3], aAuxTrigger[4])

	oStruVV2Cab:SetProperty( 'VV2_TIPVEI', MODEL_FIELD_VALID , FWBuildFeature(STRUCT_FEATURE_VALID,"Vazio() .or. ExistCPO('VV8')") )
	aAuxTrigger := FwStruTrigger("VV2_TIPVEI","VV2_DESTIP","VV8->VV8_DESCRI",.T.,"VV8",1,"xFilial('VV8') + FwFldGet('VV2_TIPVEI')","NaoVazio()")
	oStruVV2Cab:AddTrigger(aAuxTrigger[1], aAuxTrigger[2], aAuxTrigger[3], aAuxTrigger[4])

	oStruVV2Cab:SetProperty( 'VV2_ESPVEI', MODEL_FIELD_VALID , FWBuildFeature(STRUCT_FEATURE_VALID,"Vazio() .or. ExistCPO('VVE')") )
	aAuxTrigger := FwStruTrigger("VV2_ESPVEI","VV2_DESESP","VVE->VVE_DESCRI",.T.,"VVE",1,"xFilial('VVE') + FwFldGet('VV2_ESPVEI')","NaoVazio()")
	oStruVV2Cab:AddTrigger(aAuxTrigger[1], aAuxTrigger[2], aAuxTrigger[3], aAuxTrigger[4])

	// ============================= //
	// Estrutura da tabela de Modelo //
	// ============================= //
	aAuxFields := oStruVV2:GetFields()
	For nPosField := 1 to Len(aAuxFields)
		If (AllTrim(aAuxFields[nPosField,MODEL_FIELD_IDFIELD]) + "/") $ cCpoCabVV2 .and. aAuxFields[nPosField,MODEL_FIELD_OBRIGAT]
			oStruVV2:SetProperty( aAuxFields[nPosField,MODEL_FIELD_IDFIELD] , MODEL_FIELD_OBRIGAT , .F. ) // Configura como .f. para não dar mensagem de campo obrigatorio na grid
		EndIf
	Next nPosField

	oStruVV2:SetProperty( 'VV2_SEGMOD', MODEL_FIELD_OBRIGAT , .T. )

	oStruVV2:SetProperty( 'VV2_PLAREV', MODEL_FIELD_VALID , FWBuildFeature(STRUCT_FEATURE_VALID,"Vazio() .or. ExistCPO('VF0')") )
	aAuxTrigger := FwStruTrigger("VV2_PLAREV","VV2_DESPLA","VF0->VF0_DESPLA",.T.,"VF0",1,"xFilial('VF0') + FwFldGet('VV2_CODMAR') + FwFldGet('VV2_PLAREV')","NaoVazio()")
	oStruVV2:AddTrigger(aAuxTrigger[1], aAuxTrigger[2], aAuxTrigger[3], aAuxTrigger[4])

	// ============================ //
	// Estrutura da tabela de Preço //
	// ============================ //
	oStruVVP:SetProperty( 'VVP_CODMAR', MODEL_FIELD_OBRIGAT , .f. ) // Campos serão preenchidos pelo Framework MVC
	oStruVVP:SetProperty( 'VVP_MODVEI', MODEL_FIELD_OBRIGAT , .f. ) // Campos serão preenchidos pelo Framework MVC
	oStruVVP:SetProperty( 'VVP_DATPRC', MODEL_FIELD_OBRIGAT , .t. )
	oStruVVP:SetProperty( 'VVP_CUSTAB', MODEL_FIELD_OBRIGAT , .t. )
	oStruVVP:SetProperty( 'VVP_VALTAB', MODEL_FIELD_OBRIGAT , .t. )
	
	oStruVVP:SetProperty( 'VVP_SEGMOD', MODEL_FIELD_OBRIGAT , .t. )
	oStruVVP:SetProperty( 'VVP_SEGMOD', MODEL_FIELD_KEY , .t. )
	oStruVVP:SetProperty( 'VVP_SEGMOD', MODEL_FIELD_VALID , FWBuildFeature(STRUCT_FEATURE_VALID,"ExistCPO('VV2', FWFldGet('PARCODMAR')+FWFldGet('PARMODVEI')+FWFldGet('VVP_SEGMOD'))") )

	oStruVVP:SetProperty( 'VVP_DATPRC', MODEL_FIELD_VALID , FWBuildFeature(STRUCT_FEATURE_VALID,".t.") )
	If VVP->(ColumnPos("VVP_FABMOD")) > 0
		oStruVVP:SetProperty( 'VVP_FABMOD', MODEL_FIELD_VALID , FWBuildFeature(STRUCT_FEATURE_VALID,".t.") )
	EndIf

	// ================================ //
	// Estrutura da tabela de Opcionais // 
	// ================================ //
	oStruVVM:SetProperty( 'VVM_CODMAR', MODEL_FIELD_OBRIGAT , .f. ) // Campos serão preenchidos pelo Framework MVC
	oStruVVM:SetProperty( 'VVM_MODVEI', MODEL_FIELD_OBRIGAT , .f. ) // Campos serão preenchidos pelo Framework MVC

	oStruVVM:SetProperty( 'VVM_SEGMOD', MODEL_FIELD_KEY , .t. )
	oStruVVM:SetProperty( 'VVM_SEGMOD', MODEL_FIELD_VALID , FWBuildFeature(STRUCT_FEATURE_VALID,"ExistCPO('VV2', FWFldGet('PARCODMAR')+FWFldGet('PARMODVEI')+FWFldGet('VVM_SEGMOD'))") )

	oStruVVM:SetProperty( 'VVM_CODOPC', MODEL_FIELD_VALID , FWBuildFeature(STRUCT_FEATURE_VALID,"Vazio() .or. ExistCPO('VVW', FWFldGet('PARCODMAR') + FwFldGet('VVM_CODOPC'))") )
	aAuxTrigger := FwStruTrigger("VVM_CODOPC","VVM_DESITE","VVW->VVW_DESOPC",.T.,"VVW",1,"xFilial('VVW') + FWFldGet('PARCODMAR') + FwFldGet('VVM_CODOPC')")
	oStruVVM:AddTrigger(aAuxTrigger[1], aAuxTrigger[2], aAuxTrigger[3], aAuxTrigger[4])

	// ========================================== //
	// Estrutura da tabela de Periodo de Garantia // 
	// ========================================== //
	oStruVVL:SetProperty( 'VVL_CODMAR', MODEL_FIELD_OBRIGAT , .f. ) // Campos serão preenchidos pelo Framework MVC
	oStruVVL:SetProperty( 'VVL_MODVEI', MODEL_FIELD_OBRIGAT , .f. ) // Campos serão preenchidos pelo Framework MVC
	oStruVVL:SetProperty( 'VVL_PERGAR', MODEL_FIELD_OBRIGAT , .t. )
	oStruVVL:SetProperty( 'VVL_KILGAR', MODEL_FIELD_OBRIGAT , .t. )

	oStruVVL:SetProperty( 'VVL_SEGMOD', MODEL_FIELD_KEY , .t. )
	oStruVVL:SetProperty( 'VVL_SEGMOD', MODEL_FIELD_VALID , FWBuildFeature(STRUCT_FEATURE_VALID,"ExistCPO('VV2', FWFldGet('PARCODMAR')+FWFldGet('PARMODVEI')+FWFldGet('VVL_SEGMOD'))") )

	oStruVVL:SetProperty( 'VVL_DATGAR', MODEL_FIELD_VALID , FWBuildFeature(STRUCT_FEATURE_VALID,".t.") )

	// ======================================= //
	// Estrutura da tabela de Itens de Entrega // 
	// ======================================= //
	oStruVAG:SetProperty( 'VAG_CODMAR', MODEL_FIELD_OBRIGAT , .f. ) // Campos serão preenchidos pelo Framework MVC
	oStruVAG:SetProperty( 'VAG_MODVEI', MODEL_FIELD_OBRIGAT , .f. ) // Campos serão preenchidos pelo Framework MVC

	oStruVAG:SetProperty( 'VAG_SEGMOD', MODEL_FIELD_KEY , .t. )
	oStruVAG:SetProperty( 'VAG_SEGMOD', MODEL_FIELD_VALID , FWBuildFeature(STRUCT_FEATURE_VALID,"ExistCPO('VV2', FWFldGet('PARCODMAR')+FWFldGet('PARMODVEI')+FWFldGet('VAG_SEGMOD'))") )

	oStruVAG:SetProperty( 'VAG_CODIGO', MODEL_FIELD_VALID , FWBuildFeature(STRUCT_FEATURE_VALID,"Vazio() .or. ExistCPO('VAF')") )
	aAuxTrigger := FwStruTrigger("VAG_CODIGO","VAG_DESCRI","VAF->VAF_DESCRI",.T.,"VAF",1,"xFilial('VAF') + FWFldGet('VAG_CODIGO')")
	oStruVAG:AddTrigger(aAuxTrigger[1], aAuxTrigger[2], aAuxTrigger[3], aAuxTrigger[4])

	// ======================================================= //
	// Estrutura da tabela de Percentual de Faturamento Direto // 
	// ======================================================= //
	oStruVZP:SetProperty( 'VZP_VALVEN', MODEL_FIELD_VALID , FWBuildFeature(STRUCT_FEATURE_VALID,"Positivo()") )
	oStruVZP:SetProperty( 'VZP_DESCON', MODEL_FIELD_VALID , FWBuildFeature(STRUCT_FEATURE_VALID,"Positivo()") )
	oStruVZP:SetProperty( 'VZP_COMISS', MODEL_FIELD_VALID , FWBuildFeature(STRUCT_FEATURE_VALID,"Positivo()") )

	oStruVZP:SetProperty( 'VZP_SEGMOD', MODEL_FIELD_KEY , .t. )
	oStruVZP:SetProperty( 'VZP_SEGMOD', MODEL_FIELD_VALID , FWBuildFeature(STRUCT_FEATURE_VALID,"ExistCPO('VV2', FWFldGet('PARCODMAR')+FWFldGet('PARMODVEI')+FWFldGet('VZP_SEGMOD'))") )

	aAuxTrigger := FwStruTrigger("VZP_TIPO","VZP_SEQUEN","VA0500063_SequenciaVZP()",.F.,,,,"!Empty(FWFldGet('VZP_TIPO'))",'01')
	oStruVZP:AddTrigger(aAuxTrigger[1], aAuxTrigger[2], aAuxTrigger[3], aAuxTrigger[4])

	// ======================================= //	
	oModel:AddFields( 'MODEL_VV2CAB', /*cOwner*/, oStruVV2Cab, /* <bPre> */ , /* <bPost> */ , /* <bLoad> */ { |oFieldModel, lCopy| loadCab(oFieldModel, lCopy) } )
	oModel:AddFields( 'MODEL_VV2PAR', 'MODEL_VV2CAB', oStruVV2Par, /* <bPre> */ , /* <bPost> */ , /* <bLoad> */  { |oFieldModel, lCopy| loadCabPar(oFieldModel, lCopy) } )
	oModel:AddGrid( 'MODEL_VV2', 'MODEL_VV2CAB', oStruVV2)
	oModel:AddGrid( 'MODEL_VVP', 'MODEL_VV2CAB', oStruVVP)
	oModel:AddGrid( 'MODEL_VZP', 'MODEL_VV2CAB', oStruVZP)
	oModel:AddGrid( 'MODEL_VAG', 'MODEL_VV2CAB', oStruVAG)
	oModel:AddGrid( 'MODEL_VVL', 'MODEL_VV2CAB', oStruVVL)
	oModel:AddGrid( 'MODEL_VVM', 'MODEL_VV2CAB', oStruVVM)

	oModel:SetDescription( STR0002 ) // 
	oModel:GetModel( 'MODEL_VV2CAB' ):SetDescription( STR0003 ) // 'Dados de Modelo Cabeçalho' 
	oModel:GetModel( 'MODEL_VV2PAR' ):SetDescription( STR0004 ) // 'Parametros internos' 
	oModel:GetModel( 'MODEL_VV2' ):SetDescription( STR0005 ) // 'Dados de Modelo por Segmento' 
	oModel:GetModel( 'MODEL_VVP' ):SetDescription( STR0006 ) // 'Dados de Tabela de Preço'
	oModel:GetModel( 'MODEL_VVM' ):SetDescription( STR0007 ) // 'Dados de Opcionais de Fábrica'
	oModel:GetModel( 'MODEL_VVL' ):SetDescription( STR0008 ) // 'Dados de Período de Garantia'
	oModel:GetModel( 'MODEL_VAG' ):SetDescription( STR0009 ) // 'Dados de Itens de Entrega'
	oModel:GetModel( 'MODEL_VZP' ):SetDescription( STR0010 ) // 'Dados de Faturamento Direto do Modelo' 

	oModel:SetRelation('MODEL_VV2', { { 'VV2_FILIAL' , 'xFilial("VV2")' } , { 'VV2_CODMAR' , 'VV2_CODMAR' } , { 'VV2_MODVEI' , 'VV2_MODVEI' } } , 'VV2_FILIAL+VV2_CODMAR+VV2_MODVEI' )
	oModel:SetRelation('MODEL_VZP', { { 'VZP_FILIAL' , 'xFilial("VZP")' } , { 'VZP_CODMAR' , 'VV2_CODMAR' } , { 'VZP_MODVEI' , 'VV2_MODVEI' } } , 'VZP_FILIAL+VZP_CODMAR+VZP_MODVEI' )
	oModel:SetRelation('MODEL_VVM', { { 'VVM_FILIAL' , 'xFilial("VVM")' } , { 'VVM_CODMAR' , 'VV2_CODMAR' } , { 'VVM_MODVEI' , 'VV2_MODVEI' } } , 'VVM_FILIAL+VVM_CODMAR+VVM_MODVEI' )
	oModel:SetRelation('MODEL_VVP', { { 'VVP_FILIAL' , 'xFilial("VVP")' } , { 'VVP_CODMAR' , 'VV2_CODMAR' } , { 'VVP_MODVEI' , 'VV2_MODVEI' } } , 'VVP_FILIAL+VVP_CODMAR+VVP_MODVEI' )
	oModel:SetRelation('MODEL_VAG', { { 'VAG_FILIAL' , 'xFilial("VAG")' } , { 'VAG_CODMAR' , 'VV2_CODMAR' } , { 'VAG_MODVEI' , 'VV2_MODVEI' } } , 'VAG_FILIAL+VAG_CODMAR+VAG_MODVEI' )
	oModel:SetRelation('MODEL_VVL', { { 'VVL_FILIAL' , 'xFilial("VVL")' } , { 'VVL_CODMAR' , 'VV2_CODMAR' } , { 'VVL_MODVEI' , 'VV2_MODVEI' } } , 'VVL_FILIAL+VVL_CODMAR+VVL_MODVEI' )

	oModel:SetPrimaryKey( { } )
	oModel:GetModel('MODEL_VV2PAR'):SetOnlyQuery( .T. )

	oModel:GetModel( 'MODEL_VV2' ):SetUniqueLine( { "VV2_SEGMOD"} )
	If VVP->(ColumnPos("VVP_FABMOD")) > 0
		oModel:GetModel( 'MODEL_VVP' ):SetUniqueLine( { "VVP_SEGMOD" , "VVP_DATPRC" , "VVP_FABMOD" } )
	Else
		oModel:GetModel( 'MODEL_VVP' ):SetUniqueLine( { "VVP_SEGMOD" , "VVP_DATPRC" } )
	EndIf
	oModel:GetModel( 'MODEL_VVM' ):SetUniqueLine( { "VVM_SEGMOD" , "VVM_CODOPC"} )
	oModel:GetModel( 'MODEL_VVL' ):SetUniqueLine( { "VVL_SEGMOD" , "VVL_DATGAR"} )
	oModel:GetModel( 'MODEL_VAG' ):SetUniqueLine( { "VAG_SEGMOD" , "VAG_CODIGO"} )

	oModel:GetModel( 'MODEL_VV2' ):SetOptional( .F. )
	oModel:GetModel( 'MODEL_VVP' ):SetOptional( .T. )
	oModel:GetModel( 'MODEL_VVM' ):SetOptional( .T. )
	oModel:GetModel( 'MODEL_VZP' ):SetOptional( .T. )
	oModel:GetModel( 'MODEL_VAG' ):SetOptional( .T. )
	oModel:GetModel( 'MODEL_VVL' ):SetOptional( .T. )

	oModel:AddRules( 'MODEL_VV2CAB', 'VV2_MODVEI', 'MODEL_VV2CAB', 'VV2_CODMAR', 3)
	oModel:AddRules( 'MODEL_VV2CAB', 'VV2_GRUMOD', 'MODEL_VV2CAB', 'VV2_CODMAR', 3)
	oModel:AddRules( 'MODEL_VV2', 'VV2_SEGMOD', 'MODEL_VV2CAB', 'VV2_MODVEI', 3)
	
	oModel:InstallEvent("DEF",, VEIA050EVDEF():New())

Return oModel

Static Function ViewDef()

	Local oModel := FWLoadModel( 'VEIA050' )
	
	Local oStruVV2Cab := FWFormStruct( 2, 'VV2' , { |cCampo| ALLTRIM(cCampo) $ cCpoCabVV2 } )
	Local oStruVV2    := FWFormStruct( 2, 'VV2' , { |cCampo| ! ALLTRIM(cCampo) $ cCpoCabVV2 } )
	Local oStruVZP := FWFormStruct( 2, 'VZP' )
	Local oStruVAG := FWFormStruct( 2, 'VAG' )
	Local oStruVVL := FWFormStruct( 2, 'VVL' )
	Local oStruVVM := FWFormStruct( 2, 'VVM' )
	Local oStruVVP := FWFormStruct( 2, 'VVP' )
	Local oView

	oStruVZP:RemoveField('VZP_CODMAR')
	oStruVZP:RemoveField('VZP_MODVEI')

	oStruVAG:RemoveField('VAG_CODMAR')
	oStruVAG:RemoveField('VAG_MODVEI')

	oStruVVL:RemoveField('VVL_CODMAR')
	oStruVVL:RemoveField('VVL_MODVEI')
	oStruVVL:RemoveField('VVL_DESMOD')
	
	oStruVVM:RemoveField('VVM_CODMAR')
	oStruVVM:RemoveField('VVM_MODVEI')
	oStruVVM:RemoveField('VVM_DESMOD')
	
	oStruVVP:RemoveField('VVP_CODMAR')
	oStruVVP:RemoveField('VVP_MODVEI')
	oStruVVP:RemoveField('VVP_DESMAR')
	oStruVVP:RemoveField('VVP_DESMOD')
	oStruVVP:RemoveField('VVP_DATUSU')

	oStruVVP:SetProperty('VVP_SEGMOD', MVC_VIEW_CANCHANGE , .T.)
	oStruVVP:SetProperty('VVP_SEGMOD', MVC_VIEW_LOOKUP , "VVX")

	oStruVZP:SetProperty('VZP_SEGMOD', MVC_VIEW_CANCHANGE , .T.)
	oStruVZP:SetProperty('VZP_SEGMOD', MVC_VIEW_LOOKUP , "VVX")

	oView := FWFormView():New()
	oView:SetModel( oModel )
	
	oView:AddField( 'VIEW_VV2CAB', oStruVV2Cab, 'MODEL_VV2CAB' )
	oView:AddGrid( 'VIEW_VV2', oStruVV2, 'MODEL_VV2' )
	oView:AddGrid( 'VIEW_VZP', oStruVZP, 'MODEL_VZP')
	oView:AddGrid( 'VIEW_VAG', oStruVAG, 'MODEL_VAG')
	oView:AddGrid( 'VIEW_VVL', oStruVVL, 'MODEL_VVL')
	oView:AddGrid( 'VIEW_VVM', oStruVVM, 'MODEL_VVM')
	oView:AddGrid( 'VIEW_VVP', oStruVVP, 'MODEL_VVP')


	oView:CreateHorizontalBox( 'TELAVV2CAB' , 30 )
	oView:CreateHorizontalBox( 'TELAFOLDER' , 70 )

	oView:CreateFolder('VIEW_FOLDER', 'TELAFOLDER')

	oView:AddSheet('VIEW_FOLDER','VIEW_SHEET_VV2', STR0011 ) // 'Segmento'
	oView:AddSheet('VIEW_FOLDER','VIEW_SHEET_VVP', STR0012 ) // 'PreÇos'
	oView:AddSheet('VIEW_FOLDER','VIEW_SHEET_VVM', STR0013 ) // 'Opcionais de Fabrica'
	oView:AddSheet('VIEW_FOLDER','VIEW_SHEET_VVL', STR0014 ) // 'Garantia'
	oView:AddSheet('VIEW_FOLDER','VIEW_SHEET_VAG', STR0015 ) // 'Itens Entrega'
	oView:AddSheet('VIEW_FOLDER','VIEW_SHEET_VZP', STR0016 ) // '% Venda Direta'

	oView:CreateHorizontalBox( 'TELAVV2' , 100, , , 'VIEW_FOLDER','VIEW_SHEET_VV2' )
	oView:CreateHorizontalBox( 'TELAVZP' , 100, , , 'VIEW_FOLDER','VIEW_SHEET_VZP' )
	oView:CreateHorizontalBox( 'TELAVAG' , 100, , , 'VIEW_FOLDER','VIEW_SHEET_VAG' )
	oView:CreateHorizontalBox( 'TELAVVL' , 100, , , 'VIEW_FOLDER','VIEW_SHEET_VVL' )
	oView:CreateHorizontalBox( 'TELAVVM' , 100, , , 'VIEW_FOLDER','VIEW_SHEET_VVM' )
	oView:CreateHorizontalBox( 'TELAVVP' , 100, , , 'VIEW_FOLDER','VIEW_SHEET_VVP' )

	oView:SetOwnerView( 'VIEW_VV2CAB', 'TELAVV2CAB' )
	oView:SetOwnerView( 'VIEW_VV2', 'TELAVV2' )
	oView:SetOwnerView( 'VIEW_VZP', 'TELAVZP' )
	oView:SetOwnerView( 'VIEW_VAG', 'TELAVAG' )
	oView:SetOwnerView( 'VIEW_VVL', 'TELAVVL' )
	oView:SetOwnerView( 'VIEW_VVM', 'TELAVVM' )
	oView:SetOwnerView( 'VIEW_VVP', 'TELAVVP' )

	oView:SetViewProperty( 'VIEW_VV2', "CHANGELINE", { { |oView, cViewID| VA0500023_ChangeLineVV2(oView, cViewID) } } )

	oView:SetFieldAction( 'VV2_CODMAR', { |oView, cIDView, cField, xValue| VA0500033_FieldAction( oView, cIDView, cField, xValue ) } )
	oView:SetFieldAction( 'VV2_GRUMOD', { |oView, cIDView, cField, xValue| VA0500033_FieldAction( oView, cIDView, cField, xValue ) } )
	oView:SetFieldAction( 'VV2_MODVEI', { |oView, cIDView, cField, xValue| VA0500033_FieldAction( oView, cIDView, cField, xValue ) } )

Return oView

Static Function MenuDef()
	Local aRotina := {}
	ADD OPTION aRotina Title STR0017 Action 'VIEWDEF.VEIA050' OPERATION 2 ACCESS 0 // 'Visualizar'
	ADD OPTION aRotina Title STR0018 Action 'VIEWDEF.VEIA050' OPERATION 3 ACCESS 0 // 'Incluir'
	ADD OPTION aRotina Title STR0019 Action 'VIEWDEF.VEIA050' OPERATION 4 ACCESS 0 // 'Alterar'
	ADD OPTION aRotina Title STR0020 Action 'VIEWDEF.VEIA050' OPERATION 5 ACCESS 0 // 'Excluir'
Return aRotina

Function VA0500063_SequenciaVZP()
	Local oModel := FWModelActive()
	
	Local oMVZP  := oModel:GetModel("MODEL_VZP")
	Local nQtdLinha  := oMVZP:Length()
	Local cTipo := FWFldGet("VZP_TIPO")
	Local cSegMod := FWFldGet("VZP_SEGMOD")

	Local nTamSeq := GetSX3Cache("VZP_SEQUEN","X3_TAMANHO")
	Local cSequen := StrZero(1,nTamSeq)
	Local nLinha

	For nLinha := 1 to nQtdLinha

		If oMVZP:GetValue('VZP_SEGMOD',nLinha) == cSegMod .and. oMVZP:GetValue('VZP_TIPO',nLinha) == cTipo .and. oMVZP:GetValue('VZP_SEQUEN',nLinha) >= cSequen 
			cSequen := Soma1(oMVZP:GetValue('VZP_SEQUEN',nLinha))
		EndIf

	Next nLinha

Return cSequen

Static Function VA0500013_Cabecalho()

	Local oRetorno := OFDMSStruct():New()
	Local aCpoCab := Strtokarr2( cCpoCabPar, "/")
	Local nLinha

	For nLinha := 1 to Len(aCpoCab)
	oRetorno:AddField( { ;
			{ "cTitulo"    , RetTitle(aCpoCab[nLinha]) } ,;
			{ "cTooltip"   , RetTitle(aCpoCab[nLinha]) } ,;
			{ "cIdField"   , StrTran(aCpoCab[nLinha],"VV2_","PAR") } ,;
			{ "cTipo"      , GetSX3Cache(aCpoCab[nLinha], "X3_TIPO") } ,;
			{ "nTamanho"   , GetSX3Cache(aCpoCab[nLinha], "X3_TAMANHO") } ,;
		{ "lVirtual" , .t. } ;
	})

	Next nLinha

Return oRetorno

Static Function loadCab(oFieldModel, lCopy)
	Local aLoad := {}
	Local aAuxFields := oFieldModel:GetStruct():GetFields()
	Local nPosField

	RegToMemory("VV2",INCLUI)

	For nPosField := 1 to Len(aAuxFields)
		AADD( aLoad, &("M->" + aAuxFields[nPosField, 3] ) )
	Next nPosField
	//aAdd(aLoad, VV2->VV2_CODMAR )
	//aAdd(aLoad, Posicione("VE1",1,xFilial("VE1")+VV2->VV2_CODMAR,"VE1_DESMAR") ) 
	//aAdd(aLoad, VV2->VV2_GRUMOD )
	//aAdd(aLoad, Posicione("VVR",2,xFilial("VVR")+VV2->VV2_CODMAR+VV2->VV2_GRUMOD,"VVR_DESCRI") ) 
	//aAdd(aLoad, VV2->VV2_MODVEI )

	M->VV2_CODMAR := VV2->VV2_CODMAR
	M->VV2_GRUMOD := VV2->VV2_GRUMOD
	M->VV2_MODVEI := VV2->VV2_MODVEI

	M->VO6_CODMAR := VV2->VV2_CODMAR
	M->VAG_CODMAR := VV2->VV2_CODMAR
	M->VVL_CODMAR := VV2->VV2_CODMAR
	M->VVM_CODMAR := VV2->VV2_CODMAR
	M->VVP_CODMAR := VV2->VV2_CODMAR
	M->VZP_CODMAR := VV2->VV2_CODMAR

Return aLoad

Static Function loadCabPar(oFieldModel, lCopy)
	Local aLoad := {}

	aAdd(aLoad, VV2->VV2_CODMAR )
	aAdd(aLoad, VV2->VV2_GRUMOD )
	aAdd(aLoad, VV2->VV2_MODVEI )

Return aLoad

Function VA0500023_ChangeLineVV2(oView, cViewID)
	M->VV2_CODMAR := FWFldGet('PARCODMAR')
	M->VV2_GRUMOD := FWFldGet('PARGRUMOD')
	M->VV2_MODVEI := FWFldGet('PARMODVEI')
	
	M->VO6_CODMAR := M->VV2_CODMAR
	M->VAG_CODMAR := M->VV2_CODMAR
	M->VVL_CODMAR := M->VV2_CODMAR
	M->VVM_CODMAR := M->VV2_CODMAR
	M->VVP_CODMAR := M->VV2_CODMAR
	M->VZP_CODMAR := M->VV2_CODMAR

Return

Function VA0500033_FieldAction(oView, cIDView, cField, xValue)
	Local oModel := FWModelActive()
	Local oMPar := oModel:GetModel("MODEL_VV2PAR")

	oMPar:LoadValue(StrTran(cField,"VV2_","PAR"), xValue)

Return