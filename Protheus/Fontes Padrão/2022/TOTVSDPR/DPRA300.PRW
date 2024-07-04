#INCLUDE 'DPRA300.CH'
#INCLUDE 'TOTVS.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWADAPTEREAI.CH'
#INCLUDE "APWIZARD.CH"

//-----------------------------------------------------------------
/*/{Protheus.doc} DPRA300
Tela de Cadastro de Versão

@author Ana Carolina Tome Klock
@since 17/01/2012
@version P12
/*/
//-----------------------------------------------------------------
Function DPRA300()
Local oBrowse
Local aValidaDPR := ValidaDPR()

// Valida se o programa pode ser aberto
If aValidaDPR[1] .And. !Empty(aValidaDPR[2])
	Final(aValidaDPR[2])
ElseIf !Empty( aValidaDPR[2] )
	DPRXError( 'DPRA300', aValidaDPR[2], 3 )
EndIf

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('DG0')
oBrowse:SetDescription( STR0001 ) // 'Cadastro de Versão'
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina	:= {}
	Local lFicha	:= .F.
	If FindFunction("DPRFicha")
		lFicha := DPRFicha(1)
	EndIf
	
	aAdd( aRotina, { STR0002, 'PesqBrw'        , 0, 1, 0, NIL } ) // 'Pesquisar'
	aAdd( aRotina, { STR0003, "VIEWDEF.DPRA300", 0, 2, 0, nil} )  // 'Visualizar'
	aAdd( aRotina, { STR0004, 'VIEWDEF.DPRA300', 0, 3, 0, NIL } ) // 'Incluir'
	aAdd( aRotina, { STR0005, 'VIEWDEF.DPRA300', 0, 4, 0, NIL } ) // 'Alterar'
	aAdd( aRotina, { STR0006, 'VIEWDEF.DPRA300', 0, 5, 0, NIL } ) // 'Excluir'
	aAdd( aRotina, { STR0007, 'VIEWDEF.DPRA300', 0, 8, 0, NIL } ) // 'Imprimir'
	aAdd( aRotina, { STR0009, 'DPRA330SEL()'   , 0, 2, 0, .F. } ) // 'Importar Versão'
	aAdd( aRotina, { STR0010, 'DPRA340INT(3)'  , 0, 2, 0, .F. } ) // 'Gerar Ordem Protótipo'
	aAdd( aRotina, { STR0052, 'DPRFORMULA(1)'  , 0, 2, 0, NIL } ) // 'Fórmulas'
	aAdd( aRotina, { STR0035, 'DPRA300CON()'   , 0, 4, 0, NIL } ) // 'Conhecimento'
	aAdd( aRotina, { STR0047, 'DPRA300ROT(,1)'   , 0, 9, 0, .F. } ) // 'Gerar Roteiro'
	aAdd( aRotina, { STR0053, 'DPRC310()'      , 0, 9, 0, .F. } ) // 'Comparativo'
	
	If lFicha
		aAdd( aRotina, { STR0036, 'DPRA210()', 0, 4, 0, NIL } ) // 'Ficha Técnica'
		aAdd( aRotina, { STR0043, 'PCPA104()', 0, 4, 0, NIL } ) // 'Ficha Família Técnica'
	Endif
Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()
	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStructDG0 := FWFormStruct( 1, 'DG0', /*bAvalCampo*/, /*lViewUsado*/ )
	Local oStructDG1 := FWFormStruct( 1, 'DG1', /*bAvalCampo*/, /*lViewUsado*/ )
	Local oStructDG9 := FWFormStruct( 1, 'DG9', /*bAvalCampo*/, /*lViewUsado*/ )
	Local oStructDGD := FWFormStruct( 1, 'DGD', /*bAvalCampo*/, /*lViewUsado*/ )
	Local oStructDG6 := FWFormStruct( 1, 'DG6', /*bAvalCampo*/, /*lViewUsado*/ )
	Local oStructDGJ := FWFormStruct( 1, 'DGJ', /*bAvalCampo*/, /*lViewUsado*/ )
	Local oStructDGM := FWFormStruct( 1, 'DGM', /*bAvalCampo*/, /*lViewUsado*/ )
	Local oStructDGG := FWFormStruct( 1, 'DGG', /*bAvalCampo*/, /*lViewUsado*/ )
	Local oStructDG5 := FWFormStruct( 1, 'DG5', /*bAvalCampo*/, /*lViewUsado*/ )
	Local oStruDG2R  := FWFormStruct( 1, 'DG2', {|cCampo| AllTrim(cCampo) != "DG2_CDFE" .AND. AllTrim(cCampo) != "DG2_DSFE" }, /*lViewUsado*/ )
	Local oStruDG2F  := FWFormStruct( 1, 'DG2', {|cCampo| AllTrim(cCampo) == "DG2_CDFE" .Or. AllTrim(cCampo) == "DG2_DSFE" }, /*lViewUsado*/ )
	Local oStructDGN
	Local oStructDGO
	Local oModel

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New('DPRA300', /*bPreValidacao*/, { |oModel| lRet := DPRA300POS( oModel ), If(lRet, lWARNDG9 := .T., lRet) }, /*bCommit*/, /*bCancel*/ )

	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields( 'DG0MASTER', /*cOwner*/, oStructDG0, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

	// Adiciona ao modelo uma estrutura de formulário de edição por grid
	oModel:AddGrid( 'DG1DETAIL', 'DG0MASTER', oStructDG1, { |oModel| DPRA300DG1( oModel, 1 ) }, { |oModel| DPRA300DG1( oModel, 2 ) }, /*bPreVal*/, { |oModel| DPRA300DG1( oModel, 3 ) }, /*bLoad*/ )
	oModel:AddGrid( 'DG9DETAIL', 'DG0MASTER', oStructDG9, { |oModel| DPRA300DG9( oModel, 1 ) }, { |oModel| DPRA300DG9( oModel, 2 ) }, /*bPreVal*/, { |oModel| DPRA300DG9( oModel, 3 ) }, /*BLoad*/ )
	oModel:AddGrid( 'DG6DETAIL', 'DG0MASTER', oStructDG6, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
	oModel:AddGrid( 'DGJDETAIL', 'DG0MASTER', oStructDGJ, /*bLinePre*/, { |oModel| DPRA300DGJ( oModel, 2 ) }, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
	oModel:AddGrid( 'DGMDETAIL', 'DG0MASTER', oStructDGM, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
	oModel:AddGrid( 'DGGDETAIL', 'DG0MASTER', oStructDGG, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
	oModel:AddGrid( 'DG5DETAIL', 'DG0MASTER', oStructDG5, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
	oModel:AddGrid( 'DG2DETREC', 'DG9DETAIL', oStruDG2R , /*bLinePre*/, { |oModel| DPRA300DG2( oModel, 1 ) }, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
	oModel:AddGrid( 'DG2DETFER', 'DG9DETAIL', oStruDG2F , /*bLinePre*/, { |oModel| DPRA300DG2( oModel, 2 ) }, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

	// Faz relaciomaneto entre os compomentes do model
	oModel:SetRelation( 'DG1DETAIL', { { 'DG1_FILIAL', 'xFilial( "DG1" )' }, { 'DG1_CDACDV', 'DG0_CDACDV' }, { 'DG1_NRVRAC', 'DG0_NRVRAC'} }, DG1->( IndexKey(1)) )
	oModel:SetRelation( 'DG9DETAIL', { { 'DG9_FILIAL', 'xFilial( "DG9" )' }, { 'DG9_CDACDV', 'DG0_CDACDV' }, { 'DG9_NRVRAC', 'DG0_NRVRAC'} }, DG9->( IndexKey(1)) )
	oModel:SetRelation( 'DG6DETAIL', { { 'DG6_FILIAL', 'xFilial( "DG6" )' }, { 'DG6_IDNV'  , 'DG0_IDNV'   } }, DG6->( IndexKey(1)) )
	oModel:SetRelation( 'DGJDETAIL', { { 'DGJ_FILIAL', 'xFilial( "DGJ" )' }, { 'DGJ_CDACDV', 'DG0_CDACDV' }, { 'DGJ_NRVRAC', 'DG0_NRVRAC'} }, DGJ->( IndexKey(1)) )
	oModel:SetRelation( 'DGMDETAIL', { { 'DGM_FILIAL', 'xFilial( "DGM" )' }, { 'DGM_CDACDV', 'DG0_CDACDV' }, { 'DGM_NRVRAC', 'DG0_NRVRAC'} }, DGM->( IndexKey(1)) )
	oModel:SetRelation( 'DGGDETAIL', { { 'DGG_FILIAL', 'xFilial( "DGG" )' }, { 'DGG_CDACDV', 'DG0_CDACDV' }, { 'DGG_NRVRAC', 'DG0_NRVRAC'} }, DGG->( IndexKey(1)) )
	oModel:SetRelation( 'DG5DETAIL', { { 'DG5_FILIAL', 'xFilial( "DG5" )' }, { 'DG5_CDACDV', 'DG0_CDACDV' }, { 'DG5_NRVRAC', 'DG0_NRVRAC'} }, DG5->( IndexKey(1)) )
	oModel:SetRelation( 'DG2DETREC', { { 'DG2_FILIAL', 'xFilial( "DG2" )' }, { 'DG2_IDAT'  , 'DG9_IDAT'   } }, DG2->( IndexKey(1)) )
	oModel:SetRelation( 'DG2DETFER', { { 'DG2_FILIAL', 'xFilial( "DG2" )' }, { 'DG2_IDAT'  , 'DG9_IDAT'   } }, DG2->( IndexKey(1)) )

	// Adiciona a descricao do Modelo de Dados
	oModel:SetDescription( STR0011 ) //'Modelo de Dados da Versão'

	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:GetModel( 'DG0MASTER' ):SetDescription( STR0012 ) // 'Dados da Versão'
	oModel:GetModel( 'DG1DETAIL' ):SetDescription( STR0013 ) // 'Dados da Estrutura da Versão'
	oModel:GetModel( 'DG9DETAIL' ):SetDescription( STR0014 ) // 'Dados da Operação da Versão'
	oModel:GetModel( 'DG6DETAIL' ):SetDescription( STR0016 ) // 'Dados do Tutorial da Versão'
	oModel:GetModel( 'DGJDETAIL' ):SetDescription( STR0017 ) // 'Dados do Critério da Versão'
	oModel:GetModel( 'DGMDETAIL' ):SetDescription( STR0018 ) // 'Dados do Desenho da Versão'
	oModel:GetModel( 'DGGDETAIL' ):SetDescription( STR0019 ) // 'Dados do Atributo Extra'
	oModel:GetModel( 'DG5DETAIL' ):SetDescription( STR0020 ) // 'Dados do Custo'
	oModel:GetModel( 'DG2DETREC' ):SetDescription( 'Dados de alternativos' )
	oModel:GetModel( 'DG2DETFER' ):SetDescription( 'Dados de alternativos' )

	// Indica que é opcional ter dados informados na Grid
	oModel:GetModel( 'DG1DETAIL' ):SetOptional(.T.)
	oModel:GetModel( 'DG9DETAIL' ):SetOptional(.T.)
	oModel:GetModel( 'DG6DETAIL' ):SetOptional(.T.)
	oModel:GetModel( 'DGJDETAIL' ):SetOptional(.T.)
	oModel:GetModel( 'DGMDETAIL' ):SetOptional(.T.)
	oModel:GetModel( 'DGGDETAIL' ):SetOptional(.T.)
	oModel:GetModel( 'DG5DETAIL' ):SetOptional(.T.)
	oModel:GetModel( 'DG2DETREC' ):SetOptional(.T.)
	oModel:GetModel( 'DG2DETFER' ):SetOptional(.T.)
	
	oModel:GetModel( 'DG6DETAIL' ):SetNoInsertLine()
	
	// Liga o controle de nao repeticao de linha
	If !IsInCallStack('DPRA330')
		oModel:GetModel( 'DG1DETAIL' ):SetUniqueLine( { 'DG1_CDMT', 'DG1_CDMTDV', 'DG1_NRSQET' } )
	EndIf
	oModel:GetModel( 'DGMDETAIL' ):SetUniqueLine( { 'DGM_CDDR' } )
	oModel:GetModel( 'DGJDETAIL' ):SetUniqueLine( { 'DGJ_CDJZ' } )
	oModel:GetModel( 'DGGDETAIL' ):SetUniqueLine( { 'DGG_DSAB' } )
	oModel:GetModel( 'DG5DETAIL' ):SetUniqueLine( { 'DG5_TPCS', 'DG5_TPVLCS', 'DG5_CDMY' } )
	
	// Caso esteja integrando com o Datasul, torna o campo obrigatório
	If DPRIntegra() == 1
		oStructDG9:SetProperty( 'DG9_CDCETR', MODEL_FIELD_OBRIGAT,  .T. )
		oStructDG6:SetProperty( 'DG6_IDNV'  , MODEL_FIELD_OBRIGAT,  .F. )
	Else
		oStructDG0:SetProperty( 'DG0_CDES'  , MODEL_FIELD_OBRIGAT,  .T. )
		oStructDG9:SetProperty( 'DG9_CDMQ'  , MODEL_FIELD_OBRIGAT,  .F. )
	EndIf
	
	oStructDG1:SetProperty( 'DG1_NRSQ'  , MODEL_FIELD_OBRIGAT,  .T. )

	// Carrega os dados do produto desenvolvido
	oModel:SetActivate( { |oModel| DPR100LOAD( oModel ) } )

	oStructDGN := FWFormStruct( 1, 'DGN', /*bAvalCampo*/, /*lViewUsado*/ )
	oStructDGO := FWFormStruct( 1, 'DGO', /*bAvalCampo*/, /*lViewUsado*/ )

	oModel:AddGrid( 'DGNDETAIL', 'DG0MASTER', oStructDGN, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
	oModel:AddGrid( 'DGODETAIL', 'DGNDETAIL', oStructDGO, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

	oModel:SetRelation( 'DGNDETAIL', { { 'DGN_FILIAL', 'xFilial( "DGN" )' }, { 'DGN_CDACDV', 'DG0_CDACDV' }, { 'DGN_NRVRAC', 'DG0_NRVRAC'} }, DGN->( IndexKey(1)) )
	oModel:SetRelation( 'DGODETAIL', { { 'DGO_FILIAL', 'xFilial( "DGO" )' }, { 'DGO_CDACDV', 'DGN_CDACDV' }, { 'DGO_NRVRAC', 'DGN_NRVRAC'}, { 'DGO_CDMQ', 'DGN_CDMQ'}, { 'DGO_CDMD', 'DGN_CDMD'} }, DGO->( IndexKey(1)) )

	oModel:GetModel( 'DGNDETAIL' ):SetDescription( STR0038 ) // Dados da Ficha Ténica
	oModel:GetModel( 'DGODETAIL' ):SetDescription( STR0044 ) // Dados dos Atributos da Ficha Técnica

	oModel:GetModel( 'DGNDETAIL' ):SetOptional(.T.)
	oModel:GetModel( 'DGODETAIL' ):SetOptional(.T.)

	oModel:GetModel( 'DGNDETAIL' ):SetUniqueLine( { 'DGN_CDMD', 'DGN_CDMD' } )
	oModel:GetModel( 'DGODETAIL' ):SetUniqueLine( { 'DGO_CDAB' } )

	oModel:GetModel( 'DGNDETAIL' ):SetNoInsertLine()
	oModel:GetModel( 'DGNDETAIL' ):SetNoUpdateLine()
	oModel:GetModel( 'DGNDETAIL' ):SetNoDeleteLine()
	oModel:GetModel( 'DGODETAIL' ):SetNoInsertLine()
	oModel:GetModel( 'DGODETAIL' ):SetNoUpdateLine()
	oModel:GetModel( 'DGODETAIL' ):SetNoDeleteLine()
	
	oStructDG9:SetProperty( 'DG9_LGATBG', MODEL_FIELD_WHEN, {|| .F.} )
	oStructDG9:SetProperty( 'DG9_LGATED', MODEL_FIELD_WHEN, {|| .F.} )
	oStructDG0:SetProperty( 'DG0_CDACPY', MODEL_FIELD_WHEN, { |oModel| DPRA300WHN( oModel ) } )
	
	oModel:GetModel("DG9DETAIL"):SetUseOldGrid()
	oModel:GetModel("DG1DETAIL"):SetUseOldGrid()

	oModel:GetModel('DG2DETREC'):SetLoadFilter({{'DG2_CDMQ',"'"+CriaVar("DG2_CDMQ")+"'",MVC_LOADFILTER_NOT_EQUAL}})
	oModel:GetModel('DG2DETFER'):SetLoadFilter({{'DG2_CDFE' ,"'"+CriaVar("DG2_CDFE")+"'",MVC_LOADFILTER_NOT_EQUAL}})

Return oModel
//-------------------------------------------------------------------
Static Function ViewDef()
	Local lFicha     := .F.
	// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
	Local oModel     := FWLoadModel( 'DPRA300' )
	// Cria a estrutura a ser usada na View
	Local oStructDG0 := FWFormStruct( 2, 'DG0' ) // Versão
	Local oStructDG1 := FWFormStruct( 2, 'DG1' ) // Estrutura
	Local oStructDG9 := FWFormStruct( 2, 'DG9' ) // Operação
	Local oStructDG6 := FWFormStruct( 2, 'DG6' ) // Narrativa
	Local oStructDGJ := FWFormStruct( 2, 'DGJ' ) // Valor Critério
	Local oStructDGM := FWFormStruct( 2, 'DGM' ) // Desenho
	Local oStructDGG := FWFormStruct( 2, 'DGG' ) // Atributo
	Local oStructDG5 := FWFormStruct( 2, 'DG5' ) // Custo
	Local oStruDG2R  := FWFormStruct( 2, 'DG2', {|cCampo| AllTrim(cCampo) != "DG2_CDFE" .AND. AllTrim(cCampo) != "DG2_DSFE"} )
	Local oStruDG2F  := FWFormStruct( 2, 'DG2', {|cCampo| AllTrim(cCampo) == "DG2_CDFE" .Or. AllTrim(cCampo) == "DG2_DSFE"} )
	Local oStructDGN
	Local oStructDGO
	
	If FindFunction("DPRFicha")
		lFicha := DPRFicha(1)
	EndIf	
	
	// Cria o objeto de View
	oView := FWFormView():New()
	
	// Define qual o Modelo de dados será utilizado
	oView:SetModel( oModel )
	
	// Adiciona botões extras
	If DPRIntegra() == 2
		oView:AddUserButton( STR0021, 'DPRA300', { |oModel| DPRA300DG1(oModel, 4) } )  // 'Componente Alternativo'
		oView:AddUserButton( STR0022, 'DPRA300', { |oModel| DPRA300DG9(oModel, 4) } )  // 'Operação Alternativa'
		oView:AddUserButton( STR0023, 'DPRA300', { |oModel| DPRA300DGD( oModel )  } )  // 'Gerar Rede-Pert'
	EndIf
	
	// Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( 'VIEW_DG0', oStructDG0, 'DG0MASTER' )
	
	// Adiciona no nosso View um controle do tipo FormGrid (antiga newgetdados)
	oView:AddGrid(  'VIEW_DG1', oStructDG1, 'DG1DETAIL' )
	oView:AddGrid(  'VIEW_DG9', oStructDG9, 'DG9DETAIL' )
	oView:AddGrid(  'VIEW_DG6', oStructDG6, 'DG6DETAIL' )
	oView:AddGrid(  'VIEW_DGJ', oStructDGJ, 'DGJDETAIL' )
	If DPRIntegra() == 2
		oView:AddGrid(  'VIEW_DGM', oStructDGM, 'DGMDETAIL' )
		oView:AddGrid(  'VIEW_DGG', oStructDGG, 'DGGDETAIL' )
	EndIf
	oView:AddGrid(  'VIEW_DG5', oStructDG5, 'DG5DETAIL' )
	oView:AddGrid(  'VIEW_DG2R', oStruDG2R, 'DG2DETREC' )
	oView:AddGrid(  'VIEW_DG2F', oStruDG2F, 'DG2DETFER' )
	
	// Cria um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'SUPERIOR', 50 )
	oView:CreateHorizontalBox( 'INFERIOR', 50 )
	
	// Cria Folder na view
	oView:CreateFolder( 'FOLDER', 'INFERIOR' )
	
	// Cria pastas nas folders
	oView:AddSheet( 'FOLDER', 'TAB01', STR0025 )   // 'Estrutura'
	oView:AddSheet( 'FOLDER', 'TAB02', STR0026 )   // 'Operação'
	oView:AddSheet( 'FOLDER', 'TAB03', STR0028 )   // 'Tutorial'
	oView:AddSheet( 'FOLDER', 'TAB04', STR0029 )   // 'Critério'
	If DPRIntegra() == 2
		oView:AddSheet( 'FOLDER', 'TAB05', STR0030 )   // 'Desenho'
		oView:AddSheet( 'FOLDER', 'TAB06', STR0031 )   // 'Atributo'
	EndIf
	oView:AddSheet( 'FOLDER', 'TAB07', STR0032 )   // 'Custos'
		
	// Cria um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'DG1', 100, , ,'FOLDER', 'TAB01' )
	
	// Cria duas áreas de DG1, uma para o browse e outra para o botão
	oView:CreateVerticalBox( 'DG1A', 97, 'DG1', ,'FOLDER', 'TAB01' )
	oView:CreateVerticalBox( 'DG1B', 03, 'DG1', ,'FOLDER', 'TAB01' )
	
	oView:CreateHorizontalBox( 'DG9', 100, , ,'FOLDER', 'TAB02' )
	
	// Cria duas áreas de DG9, uma para o browse e outra para o botão
	oView:CreateVerticalBox( 'DG9REG', 97, 'DG9', ,'FOLDER', 'TAB02' )
	oView:CreateVerticalBox( 'DG9BUT', 03, 'DG9', ,'FOLDER', 'TAB02' )

	// Cria duas áreas dentro da área de browse, uma para DG9 e outra para DG2	
	oView:CreateHorizontalBox( 'DG9BRW', 50, 'DG9REG', ,'FOLDER', 'TAB02' )
	oView:CreateHorizontalBox( 'DG2'   , 50, 'DG9REG', ,'FOLDER', 'TAB02' )
	
	// Cria Folder para os 2 tipos de alternativos
	oView:CreateFolder( 'FOLDER2', 'DG2' )
	
	// Cria pastas na folder 2
	oView:AddSheet( 'FOLDER2', 'TABREC', 'Recursos Alternativos/Secundários' )
	oView:AddSheet( 'FOLDER2', 'TABFER', 'Ferramentas Alternativas' )
	
	// Cria um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'DG2REC', 100, , ,'FOLDER2', 'TABREC' )
	oView:CreateHorizontalBox( 'DG2FER', 100, , ,'FOLDER2', 'TABFER' )
	
	oView:CreateHorizontalBox( 'DG6', 100, , ,'FOLDER', 'TAB03' )
	oView:CreateHorizontalBox( 'DGJ', 100, , ,'FOLDER', 'TAB04' )
	If DPRIntegra() == 2
		oView:CreateHorizontalBox( 'DGM', 100, , ,'FOLDER', 'TAB05' )
		oView:CreateHorizontalBox( 'DGG', 100, , ,'FOLDER', 'TAB06' )
	EndIf
	oView:CreateHorizontalBox( 'DG5', 100, , ,'FOLDER', 'TAB07' )
	
	// Relaciona o ID da View com o 'box' para exibicao
	oView:SetOwnerView( 'VIEW_DG0', 'SUPERIOR' )
	oView:SetOwnerView( 'VIEW_DG1', 'DG1A' )
	oView:SetOwnerView( 'VIEW_DG9', 'DG9BRW' )
	oView:SetOwnerView( 'VIEW_DG6', 'DG6' )
	oView:SetOwnerView( 'VIEW_DGJ', 'DGJ' )
	If DPRIntegra() == 2
		oView:SetOwnerView( 'VIEW_DGM', 'DGM' )
		oView:SetOwnerView( 'VIEW_DGG', 'DGG' )
	EndIf
	oView:SetOwnerView( 'VIEW_DG5', 'DG5' )
	oView:SetOwnerView( 'VIEW_DG2R', 'DG2REC' )
	oView:SetOwnerView( 'VIEW_DG2F', 'DG2FER' )
		
	// Remove os campos repetidos da tela
	oStructDG0:RemoveField( 'DG0_DSFOPJ' )
	oStructDG0:RemoveField( 'DG0_DSFOCS' )
	oStructDG0:RemoveField( 'DG0_DSFOUT' )
	oStructDG0:RemoveField( 'DG0_IDNV'   )
	oStructDG1:RemoveField( 'DG1_CDACDV' )
	oStructDG1:RemoveField( 'DG1_NRVRAC' )
	oStructDG1:RemoveField( 'DG1_LGMTDV' )
	oStructDG1:RemoveField( 'DG1_IDNV'   )
	oStructDG9:RemoveField( 'DG9_CDACDV' )
	oStructDG9:RemoveField( 'DG9_NRVRAC' )
	oStructDG9:RemoveField( 'DG9_IDNVTU' )
	oStructDG9:RemoveField( 'DG9_IDNV'   )
	oStructDG9:RemoveField( 'DG9_IDAT'   )
	oStructDG6:RemoveField( 'DG6_IDNV'   )
	oStructDGJ:RemoveField( 'DGJ_CDACDV' )
	oStructDGJ:RemoveField( 'DGJ_DSACDV' )
	oStructDGJ:RemoveField( 'DGJ_NRVRAC' )
	oStructDGJ:RemoveField( 'DGJ_DSVR'   )
	oStructDGG:RemoveField( 'DGG_CDACDV' )
	oStructDGG:RemoveField( 'DGG_NRVRAC' )
	oStructDGG:RemoveField( 'DGG_VLAB2'  )
	oStructDG5:RemoveField( 'DG5_CDACDV' )
	oStructDG5:RemoveField( 'DG5_NRVRAC' )
	oStruDG2R:RemoveField( 'DG2_IDAT' )
	If DPRIntegra() == 1
		oStructDG0:RemoveField( 'DG0_CDES'   )
		oStructDG0:RemoveField( 'DG0_CDRE'   )
		oStructDG0:RemoveField( 'DG0_CDTBMT' )
		oStructDG0:RemoveField( 'DG0_DTPRBA' )
		oStructDG0:RemoveField( 'DG0_DTPRFI' )
		oStructDG0:RemoveField( 'DG0_VLPNRF' )
		oStructDG0:RemoveField( 'DG0_VLPRBA' )
		oStructDG0:RemoveField( 'DG0_VLPRFI' )
		oStructDG1:RemoveField( 'DG1_LGAV'   )
		oStructDG1:RemoveField( 'DG1_TPSB'   )
		oStructDG1:RemoveField( 'DG1_NRSRBG' )
		oStructDG1:RemoveField( 'DG1_NRSRED' )
		oStructDG1:RemoveField( 'DG1_CDRE'   )
		oStructDG1:RemoveField( 'DG1_QTAC'   )
		oStructDG9:RemoveField( 'DG9_LGAV'   )
		oStructDG9:RemoveField( 'DG9_VLPN'   )
		oStructDG9:RemoveField( 'DG9_DTBG'   )
		oStructDG9:RemoveField( 'DG9_DTED'   )
		oStructDG9:RemoveField( 'DG9_LGATBG' )
		oStructDG9:RemoveField( 'DG9_LGATED' )
		oStructDG9:RemoveField( 'DG9_LGATVF' )
		oStructDG9:RemoveField( 'DG9_CDATVF' )
		oStructDG9:RemoveField( 'DG9_CDMOD'  )
		oStructDG9:RemoveField( 'DG9_CDRE'   )
		oStructDG9:RemoveField( 'DG9_TPAT'   )
		oStructDG9:RemoveField( 'DG9_QTTERC' )
		oStructDG9:RemoveField( 'DG9_CDUNAT' )
		oStructDG9:RemoveField( 'DG9_NRATSM' )
		oStructDG6:SetProperty( 'DG6_DSNV'  , MODEL_FIELD_TAMANHO, { 30 } )
		oView:GetViewStruct('VIEW_DG9'):SetProperty( 'DG9_TPUNTE', MVC_VIEW_CANCHANGE, .F.    )
	Else
		oStructDG0:RemoveField( 'DG0_CDPJ'   )
		oStructDG0:RemoveField( 'DG0_QTACEA' )
		oStructDG0:RemoveField( 'DG0_DSPJ'   )
		oStructDG0:RemoveField( 'DG0_CDATPJ' )
		oStructDG9:RemoveField( 'DG9_CDMQ'	 )
		oStructDG9:RemoveField( 'DG9_TPALFE' )
		oStructDG9:RemoveField( 'DG9_CDFE'   )
		oStructDG9:RemoveField( 'DG9_TPTEOV' )
		oStructDG9:RemoveField( 'DG9_QTTEOV' )
		oStructDGM:RemoveField( 'DGM_CDACDV' )
		oStructDGM:RemoveField( 'DGM_DSACDV' )
		oStructDGM:RemoveField( 'DGM_NRVRAC' )
		oStructDG6:SetProperty( 'DG6_DSNV'  , MODEL_FIELD_TAMANHO, { 15000 } )
	EndIf
	
	oStructDG5:SetProperty('DG5_CDMY', MVC_VIEW_COMBOBOX, { '1='+GetMV('MV_MOEDA1'), '2='+GetMV('MV_MOEDA2'), '3='+GetMV('MV_MOEDA3'), '4='+GetMV('MV_MOEDA4'), '5='+GetMV('MV_MOEDA5') } )
	
	// Impede edição de determinados campos
	oStructDG1:SetProperty( 'DG1_QTUT'  , MVC_VIEW_CANCHANGE, .T. )
	oStructDG0:SetProperty( 'DG0_VLPJDV', MVC_VIEW_CANCHANGE, .T. )
	
	// Valida a situação para ativar as grids filhas
	oView:SetViewCanActivate( { |oView| DPRA300PRE( oView ) } )
	
	oView:AddOtherObject("BUTTON_DG1", {|oPanel| DPRA300BUT(oPanel,1)})
	oView:SetOwnerView("BUTTON_DG1",'DG1B')
	
	oView:AddOtherObject("BUTTON_DG9", {|oPanel| DPRA300BUT(oPanel,2)})
	oView:SetOwnerView("BUTTON_DG9",'DG9BUT')
	
 	If lFicha
		oStructDGN := FWFormStruct( 2, 'DGN' ) // Ficha Técnica
		oStructDGO := FWFormStruct( 2, 'DGO' ) // Atributos Ficha Técnica
		
		oView:AddGrid(  'VIEW_DGN', oStructDGN, 'DGNDETAIL' )
		oView:AddGrid(  'VIEW_DGO', oStructDGO, 'DGODETAIL' )
		
		oView:AddSheet( 'FOLDER', 'TAB08', STR0041 ) // Ficha Técnica Versão
		
		oView:CreateHorizontalBox( 'DGN1', 50, , ,'FOLDER', 'TAB08' )
		oView:CreateHorizontalBox( 'DGN2', 50, , ,'FOLDER', 'TAB08' )
		
		oView:SetOwnerView( 'VIEW_DGN', 'DGN1' )
		oView:SetOwnerView( 'VIEW_DGO', 'DGN2' )
		
		oStructDGN:RemoveField( 'DGN_CDACDV' )
		oStructDGN:RemoveField( 'DGN_NRVRAC' )
		oStructDGN:RemoveField( 'DGN_DSVR' )
	
		oStructDGO:RemoveField( 'DGO_CDACDV' )
		oStructDGO:RemoveField( 'DGO_NRVRAC' )
		oStructDGO:RemoveField( 'DGO_CDMD' )
		oStructDGO:RemoveField( 'DGO_CDMQ' )
		
		// Inclusão de botão em ações relacionadas
		oView:AddUserButton( STR0045, 'DGO_BOT', { |oView| DPRA300DG3() } ) // Ficha Técnica Produto Desenvolvido
	Endif
	
	oView:GetViewStruct('VIEW_DG9'):SetProperty('DG9_CDAT'  , MVC_VIEW_ORDEM, '01' )
	oView:GetViewStruct('VIEW_DG9'):SetProperty('DG9_CDATET', MVC_VIEW_ORDEM, '02' )
		
	oView:GetViewStruct('VIEW_DG1'):SetProperty('DG1_NRSQ'  , MVC_VIEW_ORDEM, '01' )
	oView:GetViewStruct('VIEW_DG1'):SetProperty('DG1_NRSQET', MVC_VIEW_ORDEM, '02' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRA300MAQ
Validação da máquina da operação

@return 	lRet		validações ok

@author Samantha Preima
@since 17/06/2015
@version P11
/*/
//-------------------------------------------------------------------
Function DPRA300MAQ()
Local lRet    := .T.
Local lIntSfc := FindFunction('ExisteSFC') .And. ExisteSFC("SG2")
Local cMaquin := FwFldGet("DG9_CDMQ")
Local cCT     := FwFldGet("DG9_CDCETR")

lRet := ExistCpo("CYB", cMaquin)

if lRet .AND. lIntSfc
	// Quando SFC a máquina deve pertencer ao CT informado
	if cCT != Posicione('CYB',1,xFilial('CYB')+cMaquin,'CYB_CDCETR')
		DPRXError( 'DPRA300', STR0059, 4 ) // 'Máquina deve pertencer ao centro de trabalho informado'  
		lRet := .F.
	Endif
Endif

Return lRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRA300DG2
Validações de DG2 - Alternativos do Roteiro

@return 	lRet		validações ok

@author Samantha Preima
@since 12/06/2015
@version P11
/*/
//-------------------------------------------------------------------
Static Function DPRA300DG2(oModel, nTipo)
Local lRet := .T.
Local cMaqPrin
Local cMaqAlt
Local oModelDG9 := oModel:GetModel('DG9DETAIL')
Local lIntSfc   := FindFunction('ExisteSFC') .And. ExisteSFC("SG2")

if nTipo == 1
	cMaqAlt  := oModel:GetValue('DG2_CDMQ')
	cMaqPrin := oModelDG9:GetValue('DG9DETAIL','DG9_CDMQ')

	// Verifica se máquina alternativa/secundária é a mesma da operação
	if cMaqPrin == cMaqAlt
		DPRXError( 'DPRA300', STR0057 + cMaqPrin, 4 ) //'Máquina alternativa/secundária é igual à máquina da operação. Máquina: '  
		lRet := .F.
	Endif
	
	// Verifica se máquina alternativa/secundária pertence ao mesmo CT da operação
	if lIntSfc .AND. oModelDG9:GetValue('DG9DETAIL','DG9_CDCETR') != Posicione('CYB',1,xFilial('CYB')+cMaqAlt,'CYB_CDCETR')
		DPRXError( 'DPRA300', STR0058 + cMaqAlt, 4 ) // 'Máquina alterantiva/secundária informada possui centro de trabalho diferente. Máquina: '
		lRet := .F.
	Endif
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRA300WHN
When - Retorna se pode alterado o código de protótipo da versão

@return 	lRet		Informa pode alterar

@author Samantha Preima
@since 30/01/2014
@version P12
/*/
//-------------------------------------------------------------------
Function DPRA300WHN( oModel )
Local lRet := .T.

if oModel:GetOperation() == 4
	if !Empty(DG0->DG0_CDRT) .OR. !Empty(DPExistDGH(DG0->DG0_CDACDV, DG0->DG0_NRVRAC)[2])
		lRet := .F.
	Endif
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRA300ROT
Gera código de roteiro e cria um roteiro para protótipo no PCP
@Param1	oModelDG0 - Modelo de dados
@Param2	nOrigem 1= Outras Acoes/Gera Roteiro , 2= Rotina de atualização
@return 	lRet		Informa se o campo está correto
@author Samantha Preima
@since 27/01/2014
@version P12
/*/
//-------------------------------------------------------------------
Function DPRA300ROT(oModelDG0,nOrigem)
Local lRet       := .T.
Local lRunPCP124 := ExistFunc('PCPA124')
Local oModel, oModelRot, oMdlRotSG2
Local cRot       := ''
Local cModelId   := Iif(lRunPCP124,"PCPA124_CAB","MATA632_CAB")
Local nI         := 0
Local nI2        := 0
Local oModelDG9
Local lQipMat	 	:= SuperGetMV("MV_QIPMAT",.F.,"N") == "S"
Default	oModelDG0	:= ""
Default	nOrigem		:= 1 

IF !Empty(oModelDG0)
	oModelDG9 := oModelDG0:GetModel('DG9DETAIL'):GetModel('DG9DETAIL')
Endif

//Vefica se rotina é de origem do Menu - Outras Ações
IF nOrigem = 1
	IF ! Empty(DG0->DG0_CDRT)
		DPRXError( 'DPRA300',STR0063 ,4 ) //"Roteiro já gerado!"
		Return
	Endif

Endif

IF VAL(DG0->DG0_TPST) > 3
	DPRXError( 'DPRA300', 'DPRA300_ROTEST', 3 ) // 'Estado da versão não permite geração de roteiro.'  
	lRet := .F.
Endif

if Empty(DG0->DG0_CDACPY)
	DPRXError( 'DPRA300', 'DPRA300_ROTPRO', 3 ) // 'Versão não possui Produto Protótipo informado'
	lRet := .F.
Endif	

if SuperGetMV('MV_DPRQIP',.F.,.F.) == .F.
	DPRXError( 'DPRA300', 'DPRA300_DPRQIP', 3 ) // 'Integração QIP x DPR (MV_DPRQIP) não está ativa. '
	lRet := .F.
Endif

if SuperGetMV("MV_QIPMAT",.F.,"N") == 'N'
	DPRXError( 'DPRA300', 'DPRA300_QIPMAT', 3 ) // 'Integração Inspeção de Processos (QIP) x Materiais (MV_QIPMAT) não está ativa'
	lRet := .F.
Endif
	
if lRet 
	Begin Transaction
		IF Empty(DG0->DG0_CDRT)
			If lRunPCP124
				cRot := A124DPCod(DG0->DG0_CDACPY)
			Else
				cRot := A632DPCod(DG0->DG0_CDACPY)
			EndIf
		Else
			cRot := DG0->DG0_CDRT
		Endif
	    
		// Se opção selecionada no menu, gerar com base no dicionário
		IF Empty(oModelDG0)
	
			dbSelectArea('DG9')
			DG9->(dbSetOrder(1))
			if DG9->(dbSeek(xFilial('DG9')+DG0->DG0_CDACDV+DG0->DG0_NRVRAC))
		    
				IF Empty(DG0->DG0_CDRT)					
					oModel := FwLoadModel('DPRA300')
					oModel:SetOperation(4)
					if oModel:Activate()
					
						oModel:SetValue('DG0MASTER','DG0_CDRT',cRot)
					
						if oModel:VldData()
							oModel:CommitData()
						Endif
					Endif
				Endif
			Else
				DPRXError( 'DPRA300', 'DPRA300_NAOROT', 3 ) // 'Não existem operações para esta versão'
				lRet := .F.
			Endif				
		Else
			IF Empty(DG0->DG0_CDRT)
				oModelDG0:SetValue('DG0_CDRT',cRot)
			Endif			
		Endif
		
		if lRet
			If lRunPCP124
				oModelRot := FWLoadModel('PCPA124')
				oModelRot:SetDescription(STR0060)
			Else
				oModelRot := FwLoadModel("MATA632")
			EndIf
			
			dbSelectArea('SG2')
			SG2->(dbSetOrder(1))
			if SG2->(dbSeek(xFilial('SG2')+DG0->DG0_CDACPY+cRot))

				//Exclusao da Integracao PCP x QIP
				If lQipMat 
					QAtuMatQIP(DG0->DG0_CDACPY,,cRot,"PCP",.T.)
				EndIf

				oModelRot:SetOperation(5)
				If !lRunPCP124 .Or. oModelRot:CanActivate()
					if oModelRot:Activate()
						if oModelRot:VldData()
							lRet := oModelRot:CommitData()
						Else
							lRet := .F.
						Endif
						
						if !lRet
							aErro := oModelRot:GetErrorMessage()
							DPRXError( 'DPRA300', aErro[6] )
						Endif
						
						oModelRot:DeActivate()
					Else
						aErro := oModelRot:GetErrorMessage()
						DPRXError( 'DPRA300', aErro[6] )
						lRet := .F.
					Endif
				EndIf 
			Endif
		Endif
			
		IF lRet
			// Se opção selecionada no menu, gerar com base no dicionário
			IF Empty(oModelDG0)
				IF DG9->(dbSeek(xFilial('DG9')+DG0->DG0_CDACDV+DG0->DG0_NRVRAC))
			
					oModelRot:SetOperation(3)
					if oModelRot:Activate()
							
						oModelRot:SetValue(cModelId,'G2_CODIGO' , cRot)
						oModelRot:SetValue(cModelId,'G2_PRODUTO', DG0->DG0_CDACPY)
					
						If lRunPCP124
							oMdlRotSG2 := oModelRot:GetModel('PCPA124_SG2')
						Else
							oMdlRotSG2 := oModelRot:GetModel('MATA632_SG2')
						EndIf
					
						While DG9->(!EOF()) .AND. DG9->DG9_CDACDV == DG0->DG0_CDACDV .AND. DG9->DG9_NRVRAC == DG0->DG0_NRVRAC
							nI++
							
							IF nI > 1
								oMdlRotSG2:AddLine()
							Endif
							
							oMdlRotSG2:SetValue('G2_OPERAC' , DG9->DG9_CDATET)
							oMdlRotSG2:SetValue('G2_DESCRI' , Substr(DG9->DG9_DSAT,1,TamSX3("G2_DESCRI")[1]))
							oMdlRotSG2:SetValue('G2_RECURSO', ALLTRIM(DG9->DG9_CDMQ))
							
							if !Empty(DG9->DG9_CDFE)
								oMdlRotSG2:SetValue('G2_FERRAM' , ALLTRIM(DG9->DG9_CDFE))
							Endif
							
							oMdlRotSG2:SetValue('G2_TPALOCF', DG9->DG9_TPALFE)
				
							Do Case
								Case DG9->DG9_TPUNTE == '1'
									oMdlRotSG2:SetValue('G2_SETUP', DG9->DG9_QTTESU)
								Case DG9->DG9_TPUNTE == '2'
									oMdlRotSG2:SetValue('G2_SETUP', DG9->DG9_QTTESU / 60)
								Case DG9->DG9_TPUNTE == '3'
									oMdlRotSG2:SetValue('G2_SETUP', DG9->DG9_QTTESU / 3600)
								Case DG9->DG9_TPUNTE == '4'
									oMdlRotSG2:SetValue('G2_SETUP', DG9->DG9_QTTESU * 24)
							End Case
				
							oMdlRotSG2:SetValue('G2_FORMSTP', DG9->DG9_CDFOSU)
							oMdlRotSG2:SetValue('G2_LOTEPAD', DG9->DG9_NRUNAC)
							oMdlRotSG2:SetValue('G2_TEMPAD' , DG9->DG9_QTTEMQ)
							oMdlRotSG2:SetValue('G2_TPOPER' , If(DG9->DG9_TPTEAT=="1","3",If(DG9->DG9_TPTEAT=="3","4",DG9->DG9_TPTEAT)))
							oMdlRotSG2:SetValue('G2_TPSOBRE', DG9->DG9_TPTEOV)
							oMdlRotSG2:SetValue('G2_TEMPSOB', DG9->DG9_QTTEOV)
							oMdlRotSG2:SetValue('G2_CTRAB'  , ALLTRIM(DG9->DG9_CDCETR))
							oMdlRotSG2:SetValue('G2_TEMPEND', DG9->DG9_QTTEPP)
						
							DG9->(dbSkip())
						End
						
						if lRet
						
							if oModelRot:VldData()
								lRet := oModelRot:CommitData()
								DPRXError( 'DPRA300', STR0046 + cRot, 2 ) // 'Roteiro gerado com sucesso'
							Else
								lRet := .F.
								aErro := oModelRot:GetErrorMessage()
								DPRXError( 'DPRA300', aErro[6] )
							Endif
						Endif
						
						oModelRot:DeActivate()
					Else
						aErro := oModelRot:GetErrorMessage()
						DPRXError( 'DPRA300', aErro[6] )
						lRet := .F.
					Endif
				Endif
			Else // Via alteração de operações, gerando com dados do model
				For nI2 := 1 to oModelDG9:GetQtdLine()
					oModelDG9:GoLine(nI2)
					
					if !oModelDG9:IsDeleted()
						lRet := .T.
						Exit
					Endif
				Next
				
				IF lRet
					oModelRot:SetOperation(3)
					if oModelRot:Activate()
						oModelRot:SetValue(cModelId,'G2_CODIGO' , cRot)
						oModelRot:SetValue(cModelId,'G2_PRODUTO', DG0->DG0_CDACPY)
				
						If lRunPCP124
							oMdlRotSG2 := oModelRot:GetModel('PCPA124_SG2')
						Else
							oMdlRotSG2 := oModelRot:GetModel('MATA632_SG2')
						EndIf
						
						nI := 0
					
						For nI2 := 1 to oModelDG9:GetQtdLine()
							oModelDG9:GoLine(nI2)
							
							if !oModelDG9:IsDeleted()
								nI++
							
								IF nI > 1
									oMdlRotSG2:AddLine()
								Endif
								
								If Empty(oModelDG9:GetValue('DG9_CDATET'))
									DPRXError( 'DPRA300', 'DPRA300_OPEPCP', 2 ) // 'Não foi informado código de operação PCP'
									lRet := .F.
									Exit
								Endif
									
								oMdlRotSG2:SetValue('G2_OPERAC' , oModelDG9:GetValue('DG9_CDATET'))
								oMdlRotSG2:SetValue('G2_DESCRI' , Substr(oModelDG9:GetValue('DG9_DSAT'),1,TamSX3("G2_DESCRI")[1]))
								oMdlRotSG2:SetValue('G2_RECURSO', ALLTRIM(oModelDG9:GetValue('DG9_CDMQ')))
								
								if !Empty(DG9->DG9_CDFE)
									oMdlRotSG2:SetValue('G2_FERRAM' , ALLTRIM(oModelDG9:GetValue('DG9_CDFE')))
								Endif
								
								oMdlRotSG2:SetValue('G2_TPALOCF', oModelDG9:GetValue('DG9_TPALFE'))
					
								Do Case
									Case DG9->DG9_TPUNTE == '1'
										oMdlRotSG2:SetValue('G2_SETUP', oModelDG9:GetValue('DG9_QTTESU'))
									Case DG9->DG9_TPUNTE == '2'
										oMdlRotSG2:SetValue('G2_SETUP', oModelDG9:GetValue('DG9_QTTESU') / 60)
									Case DG9->DG9_TPUNTE == '3'
										oMdlRotSG2:SetValue('G2_SETUP', oModelDG9:GetValue('DG9_QTTESU') / 3600)
									Case DG9->DG9_TPUNTE == '4'
										oMdlRotSG2:SetValue('G2_SETUP', oModelDG9:GetValue('DG9_QTTESU') * 24)
								End Case
					
								oMdlRotSG2:SetValue('G2_FORMSTP', oModelDG9:GetValue('DG9_CDFOSU'))
								oMdlRotSG2:SetValue('G2_LOTEPAD', oModelDG9:GetValue('DG9_NRUNAC'))
								oMdlRotSG2:SetValue('G2_TEMPAD' , oModelDG9:GetValue('DG9_QTTEMQ'))
								oMdlRotSG2:SetValue('G2_TPOPER' , If(oModelDG9:GetValue('DG9_TPTEAT')=="1","3",If(oModelDG9:GetValue('DG9_TPTEAT')=="3","4",oModelDG9:GetValue('DG9_TPTEAT'))))
								oMdlRotSG2:SetValue('G2_TPSOBRE', oModelDG9:GetValue('DG9_TPTEOV'))
								oMdlRotSG2:SetValue('G2_TEMPSOB', oModelDG9:GetValue('DG9_QTTEOV'))
								oMdlRotSG2:SetValue('G2_CTRAB'  , ALLTRIM(oModelDG9:GetValue('DG9_CDCETR')))
								oMdlRotSG2:SetValue('G2_TEMPEND', oModelDG9:GetValue('DG9_QTTEPP'))
							Endif
						Next
						
						IF lRet
					
							if oModelRot:VldData()
								lRet := oModelRot:CommitData()
								DPRXError( 'DPRA300', STR0046 + cRot, 2 ) // 'Roteiro gerado com sucesso'
							Else
								lRet := .F.
								aErro := oModelRot:GetErrorMessage()
								DPRXError( 'DPRA300', aErro[6] )
							Endif
						Endif
							
						oModelRot:DeActivate()
					Else
						aErro := oModelRot:GetErrorMessage()
						DPRXError( 'DPRA300', aErro[6] )
						lRet := .F.
					Endif
				Else
					lRet := .T.
				Endif
			Endif
		Endif
		
		if !lRet
			DisarmTransaction()
		Endif
		
	End Transaction
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRA300PRT
Valida o Produto Protótipo

@param 		cCDACPY		Código do Produto Protótipo
@param 		cCDACDE		Código do Produto Destino
@return 	lRet		Informa se o campo está correto

@author Samantha Preima
@since 11/12/2013
@version P12
/*/
//-------------------------------------------------------------------
Function DPRA300PRT( cCDACPY, cCDACDE )
Local lRet := .T.

If AllTrim(cCDACPY) == Posicione("DG3",1,xFilial("DG3")+cCDACDE,"DG3_CDACDE")
	DPRXError( 'DPRA300', 'DPRA300_PROT', 3 )
	lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRA300BUT
Criação de botão para movimentação de estrutura e operações

@param 		oPainel			Painel aonde será criado os botões
@param 		iOrigem			Aonde está sendo criado o botão

@author 	Samantha Preima
@since 		09/12/2013
@version 	P12
/*/
//-------------------------------------------------------------------
Function DPRA300BUT (oPanel, iOrigem)
Local lRet := .T.

@ 10, 03 Button '/\' Size 10, 13 Message '' Pixel Action DPRA300MOV(iOrigem,1) of oPanel
@ 30, 03 Button '\/' Size 10, 13 Message '' Pixel Action DPRA300MOV(iOrigem,2) of oPanel

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRA300MOV
Movimentação de registros

@param 		iOrigem			Aonde está sendo executada a operação
@param 		nOper			Operação 1=Subir 2=Descer

@author 	Samantha Preima
@since 		09/12/2013
@version 	P12
/*/
//-------------------------------------------------------------------
Function DPRA300MOV (iOrigem, nOper)
Local lRet      := .T.
Local cOrigem   := if(iOrigem == 1, 'DG1DETAIL', 'DG9DETAIL')
Local oModel    := FWMODELACTIVE()
Local oModelDET := oModel:GetModel(cOrigem)
Local oView     := FWViewActive()
Local nLinhaOld := oView:GetLine(cOrigem)
Local aSeqOld   := ACLONE(oModelDET:ACOLS[nLinhaOld])
Local aSeqNew   := {}
Local aHeader   := ACLONE(oModelDET:AHEADER)
Local nI        := 0

If nOper == 1 // para cima
	if nLinhaOld != 1

		if oModelDET:IsDeleted(nLinhaOld - 1) .OR. oModelDET:IsDeleted(nLinhaOld)
			DPRXError( 'DPRA300_DEL', STR0015, 1, STR0024 ) // 'Linha deletada portanto processo não pode ser concluído.' ## 'Salve o registro antes de fazer a alteração de linha'
		Else
			aSeqNew := ACLONE(oModelDET:ACOLS[nLinhaOld - 1])

			oModelDET:GoLine(nLinhaOld - 1)

			For nI := 5 to Len(aHeader)
				if oModelDET:CanSetValue(aHeader[nI][2])
					oModelDET:SetValue(aHeader[nI][2], aSeqOld[nI])
				Endif
			Next

			oModelDET:GoLine(nLinhaOld)

			For nI := 5 to Len(aHeader)
				if oModelDET:CanSetValue(aHeader[nI][2])
					oModelDET:SetValue(aHeader[nI][2], aSeqNew[nI])
				Endif
			Next

			oModelDET:GoLine(nLinhaOld - 1)
		Endif
	Endif
Else // para baixo
	if nLinhaOld < oView:Length(cOrigem)
		if oModelDET:IsDeleted(nLinhaOld + 1) .OR. oModelDET:IsDeleted(nLinhaOld)
			DPRXError( 'DPRA300_DEL', STR0015, 1, STR0024 ) // 'Linha deletada portanto processo não pode ser concluído.' ## 'Salve o registro antes de fazer a alteração de linha'
		Else
			aSeqNew := ACLONE(oModelDET:ACOLS[nLinhaOld + 1])

			oModelDET:GoLine(nLinhaOld + 1)

			For nI := 5 to Len(aHeader)
				if oModelDET:CanSetValue(aHeader[nI][2])
					oModelDET:SetValue(aHeader[nI][2], aSeqOld[nI])
				Endif
			Next

			oModelDET:GoLine(nLinhaOld)

			For nI := 5 to Len(aHeader)
				if oModelDET:CanSetValue(aHeader[nI][2])
					oModelDET:SetValue(aHeader[nI][2], aSeqNew[nI])
				Endif
			Next

			oModelDET:GoLine(nLinhaOld + 1)
		Endif
	Endif
EndIf

oView:Refresh(cOrigem)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRA300DG3
Abertura da tela de visualização de produto desenvolvido

@param 		oModel			Modelo de dados da tela

@author 	Samantha Preima
@since 		29/11/2013
@version 	P12
/*/
//-------------------------------------------------------------------
Function DPRA300DG3()
Local oModelDG3

dbSelectArea('DG3')
DG3->(dbSetOrder(1))
DG3->(dbSeek(xFilial('DG3')+DG0->DG0_CDACDV))

FWExecView('','DPRA100', 1,,{ || .T. }, /*bOk*/,,, /*bCancel*/,,,  )

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} DPR100LOAD
Realiza a carga dos dados do Produto Desenvolvido

@param 		oModel			Modelo de dados da tela

@author 	Ana Carolina Tome Klock
@since 		27/06/2013
@version 	P12
/*/
//-------------------------------------------------------------------
Static Function DPR100LOAD( oModel )

If IsInCallStack('DPRA100') .And. !IsInCallStack('DPRFORMULA') .And. oModel:GetOperation() != 1
	oModel:GetModel('DG0MASTER'):SetValue( 'DG0_CDACDV', AllTrim(DG3->DG3_CDACDV) )
	oModel:GetModel('DG0MASTER'):SetValue( 'DG0_DSVR'  , AllTrim(DG3->DG3_DSACDV) )
EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRA300PRE
Realiza a pre-validacao da tela, desabilitando a alteração da DG1/DG9

@param 		oView			Objeto visual que representa o modelo

@author Ana Carolina Tome Klock
@since 27/09/2012
@version P12
/*/
//-------------------------------------------------------------------
Static Function DPRA300PRE( oView )
Local lRet  	:= .T.
Local nOpc  	:= oView:GetOperation()

If nOpc == 4 .OR. nOpc == 5
	Do Case
		Case DG0->DG0_TPST == '1'
			oView:GetModel('DG1DETAIL'):SetNoUpdateLine(.F.)
			oView:GetModel('DG1DETAIL'):SetNoInsertLine(.F.)
			oView:GetModel('DG9DETAIL'):SetNoUpdateLine(.F.)
			oView:GetModel('DG9DETAIL'):SetNoInsertLine(.F.)
			oView:GetModel('DG2DETREC'):SetNoUpdateLine(.F.)
			oView:GetModel('DG2DETFER'):SetNoUpdateLine(.F.)
			oView:GetModel('DG2DETREC'):SetNoInsertLine(.F.)
			oView:GetModel('DG2DETFER'):SetNoInsertLine(.F.)
		Case DG0->DG0_TPST == '2'
			DPRXError( 'DPRA300', 'DPRA300_EDIT1', 3 )
			lRet := .F.
		Case DG0->DG0_TPST == '3'
			oView:GetModel('DG1DETAIL'):SetNoUpdateLine(.T.)
			oView:GetModel('DG1DETAIL'):SetNoInsertLine(.T.)
			oView:GetModel('DG9DETAIL'):SetNoUpdateLine(.F.)
			oView:GetModel('DG9DETAIL'):SetNoInsertLine(.F.)
			oView:GetModel('DG2DETREC'):SetNoUpdateLine(.F.)
			oView:GetModel('DG2DETFER'):SetNoUpdateLine(.F.)
			oView:GetModel('DG2DETREC'):SetNoInsertLine(.F.)
			oView:GetModel('DG2DETFER'):SetNoInsertLine(.F.)
		Case DG0->DG0_TPST == '4'
			oView:GetModel('DG1DETAIL'):SetNoUpdateLine(.F.)
			oView:GetModel('DG1DETAIL'):SetNoInsertLine(.F.)
			oView:GetModel('DG9DETAIL'):SetNoUpdateLine(.T.)
			oView:GetModel('DG9DETAIL'):SetNoInsertLine(.T.)
			oView:GetModel('DG2DETREC'):SetNoUpdateLine(.T.)
			oView:GetModel('DG2DETFER'):SetNoUpdateLine(.T.)
			oView:GetModel('DG2DETREC'):SetNoInsertLine(.T.)
			oView:GetModel('DG2DETFER'):SetNoInsertLine(.T.)
		Case DG0->DG0_TPST == '5'
			DPRXError( 'DPRA300', 'DPRA300_EDIT2', 3 )
			lRet := .F.
		Case DG0->DG0_TPST > '5'
			DPRXError( 'DPRA300', 'DPRA300_EDIT3', 3 )
			lRet := .F.
	End Case
ElseIf nOpc == 3
	oView:GetModel('DG1DETAIL'):SetNoUpdateLine(.F.)
	oView:GetModel('DG9DETAIL'):SetNoUpdateLine(.F.)
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRA300DG1
Realiza a Pre/Pos validação da Linha/Modelo para a tabela DG1 (Estrutura)

@param 		oModel		Modelo de dados da tela
@param 		nValida		Identifica o tipo de validação (1=PreLine, 2=PosLine, 3=PosValidacao, 4=Alternativo)
@return 	lRet		Se foi validado (.T.) ou não (.F.)

@author Ana Carolina Tome Klock
@since 28/02/2012
@version P12
/*/
//-------------------------------------------------------------------
Function DPRA300DG1( oModel, nValida )
Local cCDMT     := AllTrim(FwFldGet('DG1_CDMT'  ))
Local cCDMTDV   := AllTrim(FwFldGet('DG1_CDMTDV'))
Local lRet      := .T.

// PreLine
If nValida == 1
	oModel:LoadValue('DG1_QTAC', FwFldGet('DG0_QTACEA'))
	
	// Carrega um Número de Sequência automático
   	If lRet .And. Empty( oModel:GetValue('DG1_NRSQ', oModel:GetLine()) ) .And. DPRXVldMdl( oModel )
   		lRet := DPRXSetVal( oModel, 'DG1_NRSQ' )
	EndIf

	nLiq := DPRA300LIQ(oModel:GetValue('DG1_VLPN'),oModel:GetValue('DG1_VLPNLS'))

	oModel:LoadValue('DG1_QTLQ', nLiq)
	oModel:LoadValue('DG1_QTUT', DPRXTRIG( 'DG1' ))

// PosLine
ElseIf nValida == 2
	// Caso tenha informado um componente desenvolvido e não tenha informado versão, solicita a mesma
	If !Empty(cCDMTDV) .And. Empty(FwFldGet('DG1_NRVRMT')) .And. !oModel:IsDeleted()
		DPRXError( 'DPRA300', 'DPRA300_COMPO1', 3 )
		lRet := .F.
	ElseIf Empty(cCDMT) .And. Empty(cCDMTDV)
		If !IsInCallStack('DPRA330')
			DPRXError( 'DPRA300', 'DPRA300_COMPO2', 3 )
			lRet := .F.
		Else
			oModel:DeleteLine()
		EndIf
	EndIf

	// Verifica loop
	If lRet
		lRet := DPR_CDMTDV( FwFldGet('DG1_CDMTDV'), FwFldGet('DG1_NRVRMT') )
	EndIf

	If lRet .And. FwFldGet('DG1_DTED') < FwFldGet('DG1_DTBG')
		DPRXError('DPRA300', 'DPRA300_COMPO3', 3 )
		lRet := .F.
	EndIf

	If lRet .And. FwFldGet('DG1_NRSRED') < FwFldGet('DG1_NRSRBG')
		DPRXError('DPRA300', 'DPRA300_COMPO4', 3 )
		lRet := .F.
	EndIf

	// Caso esteja integrando com o sistema protheus
	If DPRIntegra() == 1
		// Quando a quantidade do componente for positiva, altera Tipo de Sobra para "Normal"
		If FwFldGet('DG1_QTMT') >= 0  .And. FwFldGet('DG1_TPSB') == '1'
			lRet := FwFldPut('DG1_TPSB', '2')
		// Quando a quantidade do componente for negativa, altera Tipo de Sobra para "Coproduto"
		ElseIf FwFldGet('DG1_QTMT') < 0  .And. FwFldGet('DG1_TPSB') == '2'
		 	lRet := FwFldPut('DG1_TPSB', '1')
		EndIf
	// Caso esteja integrando com o sistema datasul
	Else
		// Quando a quantidade do componente for positiva, altera Tipo de Sobra para "Normal"
		If FwFldGet('DG1_QTMT') >= 0  .And. FwFldGet('DG1_TPSB') != '4'
			lRet := FwFldPut('DG1_TPSB', '4')

		// Quando a quantidade do componente for negativa, exibe erro para que seja informado outro tipo de sobra
		ElseIf FwFldGet('DG1_QTMT') < 0  .And. FwFldGet('DG1_TPSB') == '4'
		 	DPRXError( 'DPRA300', 'DPRA300_COMPO5', 3 )
		 	lRet := .F.
		EndIf
	EndIf


EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRA300DG9
Realiza a Pre/Pos validação da Linha/Modelo para a tabela DG9 (Operação)

@param 		oModel		Modelo de dados da tela
@param 		nValida		Identifica o tipo de validação (1=PreLine, 2=PosLine, 3=PosVal, 4=Alternativa)
@return 	lRet		Se foi validado (.T.) ou não (.F.)

@author Ana Carolina Tome Klock
@since 28/02/2012
@version P12
/*/
//-------------------------------------------------------------------
Function DPRA300DG9( oModel, nValida )
Local lRet      := .T.

// PreLine
If nValida == 1
	// Carrega um Número de Sequência automático
    If lRet .And. Empty( FwFldGet('DG9_CDAT') ) .And. DPRXVldMdl( oModel )
   		lRet := DPRXSetVal( oModel, 'DG9_CDAT' )
	EndIf

// PosLine
ElseIf nValida == 2
	// Exige Centro de Trabalho quando Tipo da Operação for Interno
	If FwFldGet('DG9_TPAT') == '1'  .And. Empty(FwFldGet('DG9_CDCETR')) .And. !oModel:IsDeleted()
		DPRXError( 'DPRA300', 'DPRA300_OPER1', 3 )
		lRet := .F.

	// Limpa Centro de Trabalho quando Tipo da Operação for Externo
	ElseIf FwFldGet('DG9_TPAT') == '2' .And. !Empty(FwFldGet('DG9_CDCETR')) .And. !oModel:IsDeleted()
   		lRet := FwFldPut('DG9_CDCETR', '')

	EndIf

	// Exige que seja informado Ponto de Controle quando for Ponto de Controle
	If lRet .And. FwFldGet('DG9_LGATVF') == '1' .And. Empty(FwFldGet('DG9_CDATVF')) .And. !oModel:IsDeleted()
		DPRXError( 'DPRA300', 'DPRA300_OPER2', 3 )
		lRet := .F.

	// Limpa o Ponto de Controle quanto não for Ponto de Controle
	ElseIf lRet .And. FwFldGet('DG9_LGATVF') == '0' .And. !Empty(FwFldGet('DG9_CDATVF')) .And. !oModel:IsDeleted()
		lRet := FwFldPut('DG9_CDATVF', 0)
	EndIf  

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRA300DGD
Realiza a Pre/Pos validação da Linha/Modelo para a tabela DGD (Rede-Pert)

@param 		oModel		Modelo de dados da tela
@return 	lRet		Se foi validado (.T.) ou não (.F.)

@author Ana Carolina Tome Klock
@since 08/03/2012
@version P12
/*/
//-------------------------------------------------------------------
Function DPRA300DGD( oModel )
Local lRet        := .T.
Local aArea       := GetArea()
Local aAreaDG0    := DG0->( GetArea() )
Private oModelDG9 := oModel:GetModel('DG9DETAIL')

If oModelDG9:Length() > 1
	If !oModelDG9:IsModified()
		// Executa o Modelo
		dbSelectArea('DG0')
		If dbSeek( xFilial('DG0') + FwFldGet('DG0_CDACDV') + FwFldGet('DG0_NRVRAC') )
			FWExecView('','DPRA322', 4,,{ || .T. } )
		EndIf

		RestArea( aAreaDG0 )
		RestArea( aArea )

	Else
		DPRXError('DPRA300', 'DPRA300_PERT1', 3 )
	EndIf
Else
	DPRXError('DPRA300', 'DPRA300_PERT2', 3 )
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRA300DGJ
Realiza a Pre/Pos validação da Linha/Modelo para a tabela DGJ (Critério)

@param 		oModel		Modelo de dados da tela
@param 		nValida		Identifica o tipo de validação (1=PreLine, 2=PosLine, 3=PosValidacao, 4=Alternativo)
@return 	lRet		Se foi validado (.T.) ou não (.F.)

@author Samantha Preima
@since 13/03/2012
@version P11
/*/
//-------------------------------------------------------------------
Function DPRA300DGJ( oModel, nValida )
Local lRet := .T.
Local nI   := 0

If nValida == 2 .AND. !IsInCallStack('DPRA330')
	For nI := 1 to oModel:Length()
		oModel:GoLine(nI)

		If !oModel:IsDeleted() .And. !Empty(oModel:GetValue('DGJ_CDJZ'))
			dbSelectArea('DGF')
			DGF->( dbSetOrder(1) )
			If !DGF->( dbSeek( xFilial('DGF') + FwFldGet('DG0_CDACDV') + oModel:GetValue('DGJ_CDJZ') ) )
				DPRXError( 'DPRA300', 'DPRA300_CRIT', 3 ) // Necessário existir o critério na DG3
				lRet := .F.
			Endif
		Endif
	Next
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRA300POS
Realiza a pos-validacao dos dados da tela

@author Ana Carolina Tome Klock
@since 11/01/2012
@version P12
/*/
//-------------------------------------------------------------------
Function DPRA300POS( oModel )
Local lRet := .T.
Local nI   := 0
Local nJ   := 0
Local oModelDG0 := oModel:GetModel('DG0MASTER')
Local oModelDGJ := oModel:GetModel('DGJDETAIL')
Local oModelDG9 := oModel:GetModel('DG9DETAIL')
Local oModelDG1 := oModel:GetModel('DG1DETAIL')
Local nOpc      := oModel:GetOperation()
Local aAreaDG3  := DG3->(GetArea())
Local aAreaDG1  := DG1->(GetArea())
Local aAreaDG9  := DG9->(GetArea())
Local aArea     := GetArea()
Local cCDACDV   := oModelDG0:GetValue('DG0_CDACDV')
Local cNRVRAC   := oModelDG0:GetValue('DG0_NRVRAC')
Local lExist    := .F.
Local cCDATET   := ''

// Ajusta a situação da versão e as operações, caso cópia
If nOpc == 3
	oModelDG0:LoadValue('DG0_DTVR', Date() )
	oModelDG0:LoadValue('DG0_HRVR', Time() )
	oModelDG0:LoadValue('DG0_CDUSBG', RetCodUsr() )
	For nI := 1 To oModel:GetModel('DG9DETAIL'):Length()
		oModel:GetModel('DG9DETAIL'):GoLine(nI)
		dbSelectArea( 'DG9' )
		DG9->(dbSetOrder(2))
		If DG9->(dbSeek( xFilial( 'DG9' )+ FwFldGet('DG9_IDAT') ))
			oModel:GetModel('DG9DETAIL'):LoadValue('DG9_IDAT', GETSXENUM('DG9', 'DG9_IDAT', RetSQLName( 'DG9' ), nI ) )
		EndIf
	Next
	          
	dbSelectArea('DG3')
	DG3->(dbSetOrder(1))
	DG3->(dbSeek(xFilial('DG3')+cCDACDV))
	
	// Para registros novos colocar a fórmula do produto
	oModelDG0:SetValue('DG0_DSFOPJ', DG3->DG3_DSFOPJ)
	oModelDG0:SetValue('DG0_DSFOCS', DG3->DG3_DSFOCS)
	oModelDG0:SetValue('DG0_DSFOUT', DG3->DG3_DSFOUT)
EndIf

If nOpc == 3 .Or. nOpc == 4
	// Limpa os campos de atributo
	For nI := 1 To oModel:GetModel('DGGDETAIL'):Length()
		oModel:GetModel('DGGDETAIL'):GoLine(nI)
		If !Empty( FwFldGet('DGG_DSAB') )
			dbSelectArea( 'DGB' )
			DGB->(dbSetOrder(1))
			If DGB->(dbSeek( xFilial( 'DGB' )+FwFldGet('DGG_DSAB') ))
				If DGB->DGB_TPAB != '1'
					oModel:ClearField('DGGDETAIL', 'DGG_VLAB1')
				EndIf
				If DGB->DGB_TPAB != '2'
					oModel:LoadValue('DGGDETAIL', 'DGG_VLABFM', 0)
				Else
					oModel:LoadValue('DGGDETAIL', 'DGG_VLAB2', oModel:GetModel('DGGDETAIL'):GetValue('DGG_VLABFM')*(10^DGB->DGB_NRFM) )
				EndIf
				If DGB->DGB_TPAB != '3'
					oModel:ClearField('DGGDETAIL', 'DGG_VLAB3')
				EndIf
				If DGB->DGB_TPAB != '4'
					oModel:ClearField('DGGDETAIL', 'DGG_VLAB4')
				EndIf
			EndIf
		EndIf
	Next

	// Define o valor da narrativa
	If !IsInCallStack('DPRA330')
		If !Empty( oModel:GetModel('DG6DETAIL'):GetValue('DG6_DSNV') ) .And. Empty( oModel:GetModel('DG6DETAIL'):GetValue('DG6_IDNV') )
			oModel:GetModel('DG6DETAIL'):LoadValue('DG6_IDNV', GETSXENUM('DG6', 'DG6_IDNV', RetSQLName( 'DG6' ), 1 ) )
		 	oModelDG0:LoadValue('DG0_IDNV', oModel:GetModel('DG6DETAIL'):GetValue('DG6_IDNV') )
		EndIf

		For nI := 1 to oModelDGJ:Length()
			oModelDGJ:GoLine(nI)

			If !oModelDGJ:IsDeleted() .And. !Empty(FwFldGet('DGJ_CDJZ'))
				dbSelectArea('DGF')
				DGF->( dbSetOrder(1) )
				If !DGF->( dbSeek( xFilial('DGF') + cCDACDV + FwFldGet('DGJ_CDJZ') ) )
					DPRXError( 'DPRA300', 'DPRA101_INCONS', 3 )
					lRet := .F.
				Endif
			Endif
		Next
	EndIf
	
	// Não permite eliminar ou alterar máquina, caso possua ficha técnica relacionada	
	dbSelectArea('DGN')
	DGN->(dbSetOrder(1))
   	if DGN->(dbSeek( xFilial('DGN')+cCDACDV+cNRVRAC))
   	    While DGN->(!EOF()) .AND. DGN->DGN_CDACDV == cCDACDV .and. DGN->DGN_NRVRAC == cNRVRAC
   	    
   	    	if !Empty(DGN->DGN_CDMQ)
   	    		lRet := .F.
   	    	
				For nI := 1 to oModelDG9:Length()
					oModelDG9:GoLine(nI)
				
					if !oModelDG9:IsDeleted()
						IF oModelDG9:GetValue('DG9_CDMQ') == DGN->DGN_CDMQ
							lRet := .T. 
							Exit
						Endif
					Endif
				Next
				
				if !lRet
					DPRXError( 'DPRA300', 'DPRA300_ALTOPE', 3 ) // Há ficha técnica ligada àlguma máquina que na alteração das operações invalidou os registros
					Exit
				Endif
			Endif
   	    
   	    	DGN->(dbSkip())
   	    End   		
   	Endif
   	
	// Verificar se existem operações com operação PCP repetida
	For nI := 1 to oModelDG9:GetQtdLine()
		oModelDG9:GoLine(nI)
		
		If !oModelDG9:IsDeleted()
		
			cCDATET := oModelDG9:GetValue('DG9_CDATET')  
			
			For nJ := 1 to oModelDG9:GetQtdLine()
				oModelDG9:GoLine(nJ)
				
				if nI != nJ .AND. !oModelDG9:IsDeleted() .and. cCDATET == oModelDG9:GetValue('DG9_CDATET')
					lRet := .F.
					
   					DPRXError( 'DPRA300', 'DPRA300_REPETI', 3) // Existe operação PCP repetida
   					
   					Exit					  
				Endif
			Next nJ
			
			IF !lRet
				Exit
			Endif 
		Endif
	Next nI

	// Verifica se os componentes possuem operação que exista
   	For nI := 1 to oModelDG1:GetQtdLine()
   		oModelDG1:GoLine(nI)
   		
   		if !oModelDG1:IsDeleted()
   			if !Empty(oModelDG1:GetValue('DG1_CDATET'))
   				lExist := .F.
   			
   				For nJ := 1 to oModelDG9:GetQtdLine()
   					oModelDG9:GoLine(nJ)
   					
   					if !oModelDG9:IsDeleted()
   						if oModelDG9:GetValue('DG9_CDATET') == oModelDG1:GetValue('DG1_CDATET')
   							lExist := .T.
   							
   							Exit
   						Endif
   					Endif
   				Next
   				
   				if !lExist
   					lRet := .F.
   					
   					DPRXError( 'DPRA300', STR0056 + IF(oModelDG1:GetValue('DG1_LGMTDV')=='0',oModelDG1:GetValue('DG1_CDMT'),oModelDG1:GetValue('DG1_CDMTDV')) ) // 'Não existe registro de operação para componente '
   				Endif
   			Endif
   		Endif
   	Next

	if DPRIntegra() == 1
		if oModelDG0:GetValue('DG0_QTACEA') == 0
			oModelDG0:SetValue('DG0_QTACEA', 1)
		Endif
	Else
		oModelDG0:SetValue('DG0_QTACEA',1)
	Endif
	
	// Verificar se alguma operação foi alterada
	if lRet .AND. SuperGetMv('MV_DPRQIP',.F.,.F.) .AND. !Empty(oModelDG0:GetValue('DG0_CDRT')) .AND. oModel:GetModel('DG9DETAIL'):IsModified()
		IF MsgYesNo(STR0037) // 'Já existe Roteiro Gerado para o Produto Protótipo. Confirma regeração das operações?'
			lRet := DPRA300ROT(oModelDG0,2)
		Else
			DPRXError( 'DPRA300', STR0064, 4 ) //'Operacao Cancelada!
			lRet := .F.
		Endif
	Endif
	
	// -----Atualiza detalhes do Produto para informar se o mesmo é protótipo ou não
	If lRet .AND. DPRIntegra() == 1 .AND. !Empty(oModelDG0:GetValue('DG0_CDACPY'))
		lRet := DPRA100SB5(nOpc, oModelDG0:GetValue('DG0_CDACPY'))
	EndIf
	
ElseIf nOpc == 5
	dbSelectArea('DG1')
	DG1->(dbSetOrder(2))
	If DG1->(dbSeek( xFilial('DG1')+cCDACDV+cNRVRAC ))
		DPRXError( 'DPRA300', 'DPRA300_INCON1', 3 )
		lRet := .F.
	EndIf
	
	dbSelectArea('QP6')
	QP6->(dbSetOrder(2)) // QP6_FILIAL+QP6_PRODUT+QP6_REVI+QP6_CODREC
	if QP6->(dbSeek(xFilial('QP6')+oModelDG0:GetValue('DG0_CDACPY'))) // Tem q verificar antes se tem QP6 para o produto antes de chamar função QIPRevRot
		IF QP6->(dbSeek(xFilial('QP6')+oModelDG0:GetValue('DG0_CDACPY')+QIPRevRot(oModelDG0:GetValue('DG0_CDACPY'))[1]+oModelDG0:GetValue('DG0_CDRT')))
			DPRXError( 'DPRA300', 'DPRA300_ESPECI', 3 )
			lRet := .F.
		Endif
	Endif
EndIf

RestArea(aArea)
RestArea(aAreaDG3)
RestArea(aAreaDG1)
RestArea(aAreaDG9)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRA300VER
Calcula o próximo número da versão do produto

@param 		cCDACDV		(Obrigatório) Código do Produto Desenvolvido
@return		cNRVRAC		Número da próxima versão do Produto

@author Samantha Preima
@since 14/02/2013
@version P11
/*/
//-------------------------------------------------------------------
Static Function DPRA300VER(cCDACDV)
Local nLen    := TamSX3('DG0_NRVRAC')[1]
Local cNRVRAC := ''

dbSelectArea('DG0')
DG0->(dbSetOrder(1))
If DG0->(dbSeek( xFilial('DG0')+cCDACDV ))
	While DG0->(!EOF()) .AND. AllTrim(DG0->DG0_CDACDV) == AllTrim(cCDACDV)
		cNRVRAC := DG0->DG0_NRVRAC
		DG0->(dbSkip())
	End
	cNRVRAC := DPRXCOUNT( nLen, Val(cNRVRAC) )
Else
	cNRVRAC := DPRXCOUNT( nLen, 0 )
EndIf

Return cNRVRAC

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRA300NRV
Atualiza o numero da versão do Produto Desenvolvido e critérios
Executado através de gatilho do produto - DG0_CDACDV

@param 		cCDACDV		(Obrigatório) Código do Produto Desenvolvido
@return		cNRVRAC		Número da próxima versão do Produto

@author Ana Carolina Tome Klock
@since 01/03/2012
@version P12
/*/
//-------------------------------------------------------------------
Function DPRA300NRV( cCDACDV )
Local cNRVRAC
Local oModel    := FwModelActive()
Local oModelDGJ := oModel:GetModel('DGJDETAIL')
Local nI        := 0

If !IsInCallStack('DPRA322')

	cNRVRAC := DPRA300VER(cCDACDV)

	For nI := 1 to oModelDGJ:GetQtdLine()
		oModelDGJ:GoLine(nI)
		oModelDGJ:DeleteLine()
	Next

	nI := 0

	dbSelectArea('DGF')
	dbSetOrder(1)
	If DGF->(dbSeek( xFilial('DGF')+cCDACDV ))
		While DGF->(!EOF()) .AND. DGF->DGF_CDACDV == cCDACDV
			nI++

			if nI > oModelDGJ:GetQtdLine()
				oModelDGJ:AddLine()
			Else
				oModelDGJ:GoLine(nI)
				oModelDGJ:UnDeleteLine()
			Endif

			oModelDGJ:SetValue('DGJ_CDJZ', DGF->DGF_CDJZ)
			oModelDGJ:SetValue('DGJ_VLJZ', 1)

			DGF->(dbSkip())
		End
	Endif

	dbSelectArea('DG3')
	dbSetOrder(1)
	If DG3->(dbSeek( xFilial('DG3')+cCDACDV))
		oModel:SetValue('DG0MASTER','DG0_DTULRO',DG3->DG3_DTULRO)
		oModel:SetValue('DG0MASTER','DG0_VLPRRO',DG3->DG3_VLPRRO)
		oModel:SetValue('DG0MASTER','DG0_DTULEN',DG3->DG3_DTULEN)
		oModel:SetValue('DG0MASTER','DG0_VLULEN',DG3->DG3_VLULEN)
		oModel:SetValue('DG0MASTER','DG0_CDACPY',DG3->DG3_CDACPY)
	Endif

	oModelDGJ:GoLine(1)
EndIf

Return cNRVRAC

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRA300PRO
Atualiza a descrição do Produto Desenvolvido/Item Engenharia

@param 		cCDACDV		(Obrigatório) Código do Produto Desenvolvido
@param		nType		Tipo de busca (1=Inic Padrão/2=Gatilho)
@return		cRet		Descrição do Componente

@author Ana Carolina Tome Klock
@since 01/03/2012
@version P12
/*/
//-------------------------------------------------------------------
Function DPRA300PRO( cCDACDV, nType )
Local cRet    := ''
Default nType := 1

// Se estiver na tela de versão ou criando uma versão via produto desenvolvido, busca na DG0
If IsInCallStack('DPRA300') .Or. IsInCallStack('DPRA100')
	cCDACDV := M->DG0_CDACDV
EndIf

// Se estiver abrindo a tela
If !Empty( cCDACDV ) .And. nType == 1
	If !IsInCallStack( 'ADDLINE' )
		If !Empty(DG1->DG1_NRSQ) .And. !Empty(Posicione('CZ3', 1, xFilial('CZ3')+DG1->DG1_CDMT, 'CZ3_DSAC'))
			cRet :=  AllTrim(Posicione('CZ3', 1, xFilial('CZ3')+DG1->DG1_CDMT, 'CZ3_DSAC'))
		ElseIf !Empty(DG1->DG1_NRSQ)
			cRet :=  AllTrim(Posicione('DG0', 1, xFilial('DG0')+DG1->DG1_CDMTDV+DG1->DG1_NRVRMT, 'DG0_DSVR'))
		EndIf
	EndIf

// Se estiver inserindo um novo registro
ElseIf nType == 2
	If !Empty(FwFldGet('DG1_CDMT'))
		cRet :=  AllTrim(Posicione('CZ3', 1, xFilial('CZ3')+FwFldGet('DG1_CDMT'), 'CZ3_DSAC'))
	ElseIf !Empty(FwFldGet('DG1_NRSQ'))
		cRet :=  AllTrim(Posicione('DG0', 1, xFilial('DG0')+FwFldGet('DG1_CDMTDV')+FwFldGet('DG1_NRVRMT'), 'DG0_DSVR'))
	EndIf
EndIf

If !Empty(cRet)
	cRet := PadR(cRet,GetSx3Cache("DG1_DSMT","X3_TAMANHO"))
EndIf

Return cRet

//-------------------------------------------------------------------
// DPRA300LIQ - Calcular quantidade líquida
//-------------------------------------------------------------------
Function DPRA300LIQ(nVLPN, nVPPNLS)
Local nLiq := 0
Local oModel := FWModelActive()

If oModel:GetModel( FWFindID( 'DG1_QTMT') ):GetQtdLine() == 0
	nVLPN   := 100
	nVPPNLS := 0
Endif

nLiq := DPRXTRIG( 'DG1' ) * (nVLPN / 100) * ( 1 - (nVPPNLS / 100))

Return nLiq

//-------------------------------------------------------------------
// DPRA300CON - Conhecimento
//-------------------------------------------------------------------
Function DPRA300CON()
Local lRet := .T.
PRIVATE cCadastro := OemToAnsi(STR0034) // Versão Produto Desenvolvido
PRIVATE aRotina	  := MenuDef()

if VAL(DG0->DG0_TPST) < 6
	lRet := MsDocument( 'DG0', DG0->(Recno()), 4, , 1, , )
Else
	DPRXError( 'DPRA300', 'DPRA300_CONHEC', 3 ) // Banco de Conhecimento só pode ser utilizado para produtos que não foram liberados
Endif

Return lRet

//-------------------------------------------------------------------
// DPRA300BAS - Atualiza quantidade base
//-------------------------------------------------------------------
Function DPRA300BAS()
Local oModel    := FwModelActive()
Local oModelDG1 := oModel:GetModel('DG1DETAIL')
Local nI        := 0

For nI := 1 to oModelDG1:GetQtdLine()
	oModelDG1:GoLine(nI)

	if !oModelDG1:IsDeleted() .AND. (!Empty(oModelDG1:GetValue('DG1_CDMT')) .OR. !Empty(oModelDG1:GetValue('DG1_CDMTDV')))
		oModelDG1:SetValue('DG1_QTAC',M->DG0_QTACEA)
	Endif
Next

Return M->DG0_QTACEA 

//-------------------------------------------------------------------
//-------------------------------------------------------------------
// Validade de quantidade base DG0_QTACEA
//-------------------------------------------------------------------
Function DPRA300QTA(cSitu)
Local lRet := .T.

if cSitu == '3'
	DPRXError( 'DPRA300', 'DPRA300_QTDBAS', 3 )
	
	lRet := .F.
Endif

Return lRet

//-------------------------------------------------------------------
// consulta padrão para operação do componente
//-------------------------------------------------------------------
Function DPRA300_DG1()
Local lRet      := .T.
Local oModel    := FwModelActive()
Local oModelDG9 := oModel:GetModel('DG9DETAIL')
Local nI        := 0
Local aOper     := {}
Local oDlg, oLbx 

VAR_IXB := ' '

For nI := 1 to oModelDG9:GetQtdLine()
	oModelDG9:GoLine(nI)
	
	if !oModelDG9:IsDeleted()
		AADD(aOper, {oModelDG9:GetValue('DG9_CDATET'), oModelDG9:GetValue('DG9_DSAT')})
	Endif
Next

DEFINE MSDIALOG oDlg TITLE STR0054 FROM 0,0 TO 240,500 PIXEL // 'Operações'

	//Codigo, Descrição
	@ 10,10 LISTBOX oLbx FIELDS HEADER STR0026, STR0055 SIZE 230,90 OF oDlg PIXEL // 'Operação' ## 'Descrição'

	oLbx:SetArray( aOper )
	oLbx:bLine      := {|| {aOper[oLbx:nAt,1], aOper[oLbx:nAt,2]}}
	oLbx:bLDblClick := {|| {oDlg:End(), VAR_IXB := oLbx:aArray[oLbx:nAt,1]}}

	DEFINE SBUTTON FROM 105,213 TYPE 1 ACTION (oDlg:End(), lRet := .T., VAR_IXB := oLbx:aArray[oLbx:nAt,1])  ENABLE OF oDlg
	
ACTIVATE MSDIALOG oDlg CENTER

Return lRet

//-------------------------------------------------------------------
/*Static Function IntegDef( cXML, nTypeTrans, cTypeMessage )
Local oXML, oModel, oModelDG1, oModelDG6, oModelDGD
Local aDeveloped, aVersion, aMaterial
Local aActivity, aAlternat, aTools, aItens, aPert
Local oBusinessContent, oBusinessEvent
Local cCode, cVersion, cSequence
Local aCDACDV 		:= {}
Local aNRVRAC			:= {}
Local nI, nJ, nK, nL, nM
Local nCount, nOpc	:= 3
Local aArea    		:= GetArea()
Local lRet    		:= .T.
Local cXMLRet  		:= ''
Private oModelDG9

// Se mensagem for de Recebimento
If nTypeTrans == TRANS_RECEIVE

	// Se mensagem for de Negócio
	If cTypeMessage == EAI_MESSAGE_BUSINESS
		cXml :=  SFCXMREAD("C:\Users\ana.klock\Desktop\item.xml")
		cError := ''
		cWarning := ''
		lValid := .F.

		// Cria um objeto XML a partir da estutura dos dados do Model
		oXML := XmlParser(FwNoAccent(cXML), '_', @cError, @cWarning)

		If oXML != NIL
			If XmlChildEx(oXML, '_TOTVSMESSAGE') != NIL
				oBusinessContent = oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent
				oBusinessEvent = oXML:_TOTVSMessage:_BusinessMessage:_BusinessEvent:_EVENT:TEXT
				lValid := .T.
			ElseIf XmlChildEx(oXML, '_BUSINESSCONTENT') != NIL
				oBusinessContent = oXML:_BusinessContent
				oBusinessEvent = EAI_EVENT_UPSERT
				lValid := .T.
			EndIf
		EndIf

		If lValid == .F.
			Return { lValid, STR0027 } // 'Não foi enviada uma mensagem válida'
		EndIf

		// Realiza a carga dos Produtos Desenvolvidos
		If XmlChildEx(oBusinessContent, '_LISTOFDEVELOPEDITENS') != NIL .AND. XmlChildCount(oBusinessContent:_ListOfDevelopedItens) > 0
			aDeveloped := oBusinessContent:_ListOfDevelopedItens:_DevelopedItem
			If ValType( aDeveloped ) == 'O'
				aDeveloped := { aDeveloped }
			EndIf

			// Para cada Produto Desenvolvido
			For nI := 1 to len( aDeveloped )

				// Verifica se a chave primaria que veio pelo XML ja existe na Base de Dados
				cCode := Pad( SUBSTR( UPPER( aDeveloped[nI]:_DestinyItemCode:TEXT ), 1, TamSX3("DG3_CDACDV")[1] ), TamSX3("DG3_CDACDV")[1])
				cCode += SPACE( TamSX3("DG3_CDACDV")[1] - Len( cCode ) )
				dbSelectArea('DG3')
				dbSetOrder(2)

				// Se foi encontrado, envia como Alteração
				If dbSeek( xFilial('DG3') + cCode )
					nOpc 	:= 4
				// Caso não esteja cadastrado na Base de Dados, trata como Inclusão
				Else
					nOpc 	:= 3
					nCount := 1
				EndIf

				// Instancia o modelo
				oModel := FWLoadModel( 'DPRA100' )

				// Set a operação e Ativa o Model
				oModel:SetOperation( nOpc )
				oModel:Activate()

				// Adiciona a chave apenas se for inclusão
				If nOpc == 3
					lAssign := oModel:SetValue('DG3MASTER', 'DG3_CDACDV', cCode )

					// Caso já exista o valor para a chave, cria um sequencial
					While !lAssign

						// Caso a chave seja sequencial menor do que o tamanho do campo
						If Len( AllTrim( cCode ) ) + Len( cValToChar( nCount ) ) <= TamSX3("DG3_CDACDV")[1]
							lAssign := oModel:SetValue('DG3MASTER', 'DG3_CDACDV', AllTrim(cCode) + cValToChar(nCount) )
						Else
							lAssign := oModel:SetValue('DG3MASTER', 'DG3_CDACDV', SubStr( AllTrim(cCode), 1, TamSX3("DG3_CDACDV")[1] - Len( cValToChar( nCount ) ) ) + cValToChar( nCount ) )
						EndIf
						nCount++
					End
				EndIf

				lAssign := oModel:SetValue('DG3MASTER', 'DG3_DSACDV'	, aDeveloped[nI]:_Description:TEXT)    										;If !lAssign; Return INTEGERROR( oModel ); EndIf
				lAssign := oModel:SetValue('DG3MASTER', 'DG3_CDUN' 	, Upper( AllTrim( aDeveloped[nI]:_UnitOfMeasureCode:TEXT )) )				;If !lAssign; Return INTEGERROR( oModel ); EndIf
				lAssign := oModel:SetValue('DG3MASTER', 'DG3_CDACDE'	, cCode )																		;If !lAssign; Return INTEGERROR( oModel ); EndIf
				lAssign := oModel:SetValue('DG3MASTER', 'DG3_CDUNNG'	, aDeveloped[nI]:_BusinessUnitCode:TEXT)										;If !lAssign; Return INTEGERROR( oModel ); EndIf
				lAssign := oModel:SetValue('DG3MASTER', 'DG3_TPST'	, aDeveloped[nI]:_StatusType:TEXT)    											;If !lAssign; Return INTEGERROR( oModel ); EndIf
				lAssign := oModel:SetValue('DG3MASTER', 'DG3_VLULEN'	, INTEGSTOX(aDeveloped[nI]:_LastEntryPriceValue:TEXT, 'N'))    			;If !lAssign; Return INTEGERROR( oModel ); EndIf
				lAssign := oModel:SetValue('DG3MASTER', 'DG3_VLPRRO'	, INTEGSTOX(aDeveloped[nI]:_LastReplacementPriceValue:TEXT, 'N')) 			;If !lAssign; Return INTEGERROR( oModel ); EndIf
				lAssign := oModel:SetValue('DG3MASTER', 'DG3_VLPNRF'	, INTEGSTOX(aDeveloped[nI]:_PercentageScrapValue:TEXT, 'N'))    			;If !lAssign; Return INTEGERROR( oModel ); EndIf											;If !lAssign; Return INTEGERROR( oModel ); EndIf

				If AllTrim(aDeveloped[nI]:_LastEntryPriceDate:TEXT) != "1900-01-01"
					lAssign := oModel:SetValue('DG3MASTER', 'DG3_DTULEN'	, INTEGSTOX(aDeveloped[nI]:_LastEntryPriceDate:TEXT, 'D'))    			;If !lAssign; Return INTEGERROR( oModel ); EndIf
				EndIf
				If AllTrim(aDeveloped[nI]:_LastReplacementPriceDate:TEXT) != "1900-01-01"
					lAssign := oModel:SetValue('DG3MASTER', 'DG3_DTULRO'	, INTEGSTOX(aDeveloped[nI]:_LastReplacementPriceDate:TEXT, 'D'))  		;If !lAssign; Return INTEGERROR( oModel ); EndIf
				EndIf

				// Coloca os valores para campos carregados pelo Produto Destino
				dbSelectArea( "CZ3" )
				If !dbSeek( xFilial("CZ3") + cCode )
					lAssign := oModel:SetValue('DG3MASTER', 'DG3_DSACDE'	, aDeveloped[nI]:_Description:TEXT )    									;If !lAssign; Return INTEGERROR( oModel ); EndIf
					lAssign := oModel:SetValue('DG3MASTER', 'DG3_CDUNDE'	, Upper( AllTrim( aDeveloped[nI]:_DestinyUnitOfMeasureCode:TEXT)) )  	;If !lAssign; Return INTEGERROR( oModel ); EndIf
					lAssign := oModel:SetValue('DG3MASTER', 'DG3_CDGE'	, Upper( AllTrim( aDeveloped[nI]:_StockGroupCode:TEXT)) )  				;If !lAssign; Return INTEGERROR( oModel ); EndIf
					lAssign := oModel:SetValue('DG3MASTER', 'DG3_CDFA'	, Upper( AllTrim( aDeveloped[nI]:_FamilyCode:TEXT)) )  					;If !lAssign; Return INTEGERROR( oModel ); EndIf
					lAssign := oModel:SetValue('DG3MASTER', 'DG3_CDFACM'	, Upper( AllTrim( aDeveloped[nI]:_CommercialFamilyCode:TEXT)) )   		;If !lAssign; Return INTEGERROR( oModel ); EndIf
					lAssign := oModel:SetValue('DG3MASTER', 'DG3_CDES'	, Upper( AllTrim( aDeveloped[nI]:_BranchID:TEXT)) )						;If !lAssign; Return INTEGERROR( oModel ); EndIf
					lAssign := oModel:SetValue('DG3MASTER', 'DG3_CDDPPA'	, Upper( AllTrim( aDeveloped[nI]:_StandardWarehouseCode:TEXT)) )		;If !lAssign; Return INTEGERROR( oModel ); EndIf
					If  oModel:GetValue('DG3MASTER', 'DG3_CDUN') != oModel:GetValue('DG3MASTER', 'DG3_CDUNDE') .And. ;
						!Empty(oModel:GetValue('DG3MASTER', 'DG3_CDUNDE'))
							lAssign := oModel:SetValue('DG3MASTER', 'DG3_VLPNUN'	, INTEGSTOX(aDeveloped[nI]:_UnitOfMeasureConversionValue:TEXT, 'N'))	;If !lAssign; Return INTEGERROR( oModel ); EndIf
					EndIf
				Else
					DPRCanEdit( cCode, 1 )
				EndIf

				// Coloca o valor do parâmetro MV_DPRPROT caso o Produto Protótipo não exista
				If !Empty( aDeveloped[nI]:_PrototypeItemCode:TEXT )
					lAssign := oModel:SetValue('DG3MASTER', 'DG3_CDACPY'	, Upper( AllTrim( aDeveloped[nI]:_PrototypeItemCode:TEXT)) )			;If !lAssign; Return INTEGERROR( oModel ); EndIf
				ElseIf !Empty( SuperGetMV('MV_DPRPROT',.F.,'') )
					lAssign := oModel:SetValue('DG3MASTER', 'DG3_CDACPY'	, SuperGetMV('MV_DPRPROT',.F.,'') )    									;If !lAssign; Return INTEGERROR( oModel ); EndIf
				EndIf

				// Validação no Model
				If oModel:VldData()
					// Caso nao ocorra erros, efetiva os dados no banco
					oModel:CommitData()

					// Retorna OK
					cXMLRet := STR0028 + IF(nOpc == 3, STR0029, IF(nOpc == 4, STR0030, STR0031)) + STR0032  // 'Mensagem de ' ### 'criação' ### 'alteração' ### 'remoção' ## ' recebida com sucesso.'
				Else
					// Cria TAG com o Erro ocorrido para retornar ao EAI
					aErro := oModel:GetErrorMessage()
					cXMLRet := INTEGXTOS( aErro[6] ) + ' (' + INTEGXTOS( aErro[4] ) + ' = "' + INTEGXTOS( aErro[9] ) + '")'
					lRet := .F.
				EndIf


				// Desativa o Model
				oModel:DeActivate()

			Next
		EndIf

		// Realiza a carga das Versões dos Produtos Desenvolvidos
		If XmlChildEx(oBusinessContent, '_LISTOFITEMVERSIONS') != NIL .AND. XmlChildCount(oBusinessContent:_ListOfItemVersions) > 0
			aVersion := oBusinessContent:_ListOfItemVersions:_ItemVersion
			If ValType( aVersion ) == 'O'
				aVersion := { aVersion }
			EndIf

			aSize( aCDACDV, len( aVersion ) )
			aSize( aNRVRAC, len( aVersion ) )

			// Para cada Versão
			For nI := 1 to len( aVersion )
				oVersion := aVersion[nI]

				// Verifica se a chave primaria que veio pelo XML ja existe na Base de Dados
				aCDACDV[nI] := Pad( SUBSTR( UPPER( oVersion:_Code:TEXT ), 1, TamSX3("DG0_CDACDV")[1] ), TamSX3("DG0_CDACDV")[1] )
				aCDACDV[nI] := Posicione( "DG3", 2, xFilial( "DG3" ) + aCDACDV[nI] , "DG3_CDACDE" )
				aNRVRAC[nI] := ALLTRIM( oVersion:_VersionNumber:TEXT )
				aNRVRAC[nI] := Replicate( "0", TamSX3("DG0_NRVRAC")[1] - Len( aNRVRAC[nI] ) ) + aNRVRAC[nI]
				dbSelectArea('DG0')
				dbSetOrder(1)

				// Se foi encontrado, envia como Alteração
				If dbSeek( xFilial('DG3') + aCDACDV[nI] + aNRVRAC[nI] )
					nOpc 	:= 4
				// Caso não esteja cadastrado na Base de Dados, trata como Inclusão
				Else
					nOpc 	:= 3
				EndIf

				// Instancia o modelo
				oModel := FWLoadModel( 'DPRA300' )

				// Set a operação e Ativa o Model
				oModel:SetOperation( nOpc )
				oModel:Activate()

				// Adiciona a chave apenas se for inclusão
				If nOpc == 3
					lAssign := oModel:SetValue('DG0MASTER', 'DG0_CDACDV', aCDACDV[nI] )
					lAssign := oModel:SetValue('DG0MASTER', 'DG0_NRVRAC', aNRVRAC[nI] )
				EndIf

				lAssign := oModel:SetValue('DG0MASTER', 'DG0_DSVR'	, oVersion:_Description:TEXT									)	;If !lAssign; Return INTEGERROR( oModel ); EndIf
				lAssign := oModel:SetValue('DG0MASTER', 'DG0_DTVR'	, INTEGSTOX(oVersion:_VersionDate:TEXT, 'D')					)	;If !lAssign; Return INTEGERROR( oModel ); EndIf
				lAssign := oModel:SetValue('DG0MASTER', 'DG0_HRVR'	, '00:00:00'															)	;If !lAssign; Return INTEGERROR( oModel ); EndIf
				lAssign := oModel:SetValue('DG0MASTER', 'DG0_CDES'	, Posicione("DG3", 2, xFilial("DG3")+aCDACDV[nI], "DG3_CDES" )	)	;If !lAssign; Return INTEGERROR( oModel ); EndIf
				lAssign := oModel:SetValue('DG0MASTER', 'DG0_CDTBMT'	, oVersion:_ComponentListCode:TEXT								)	;If !lAssign; Return INTEGERROR( oModel ); EndIf
				lAssign := oModel:SetValue('DG0MASTER', 'DG0_CDRT'	, oVersion:_RoutingCode:TEXT									)	;If !lAssign; Return INTEGERROR( oModel ); EndIf
				lAssign := oModel:SetValue('DG0MASTER', 'DG0_CDRE'	, oVersion:_ReferenceCode:TEXT									)	;If !lAssign; Return INTEGERROR( oModel ); EndIf
				lAssign := oModel:SetValue('DG0MASTER', 'DG0_DTPRBA'	, INTEGSTOX(oVersion:_BasePriceDate:TEXT, 'D')				)	;If !lAssign; Return INTEGERROR( oModel ); EndIf
				lAssign := oModel:SetValue('DG0MASTER', 'DG0_VLPRBA'	, INTEGSTOX(oVersion:_BasePriceValue:TEXT	, 'N')				)	;If !lAssign; Return INTEGERROR( oModel ); EndIf
				lAssign := oModel:SetValue('DG0MASTER', 'DG0_DTPRFI'	, INTEGSTOX(oVersion:_FiscalPriceDate:TEXT, 'D')				)	;If !lAssign; Return INTEGERROR( oModel ); EndIf
				lAssign := oModel:SetValue('DG0MASTER', 'DG0_VLPRFI'	, INTEGSTOX(oVersion:_FiscalPriceValue:TEXT, 'N')			)	;If !lAssign; Return INTEGERROR( oModel ); EndIf
				lAssign := oModel:SetValue('DG0MASTER', 'DG0_DTULRO'	, INTEGSTOX(oVersion:_LastReplacementPriceDate:TEXT, 'D') 	)	;If !lAssign; Return INTEGERROR( oModel ); EndIf
				lAssign := oModel:SetValue('DG0MASTER', 'DG0_VLPRRO'	, INTEGSTOX(oVersion:_LastReplacementPriceValue:TEXT, 'N')	)	;If !lAssign; Return INTEGERROR( oModel ); EndIf
				lAssign := oModel:SetValue('DG0MASTER', 'DG0_DTULEN'	, INTEGSTOX(oVersion:_LastEntryPriceDate:TEXT, 'D')			)	;If !lAssign; Return INTEGERROR( oModel ); EndIf
				lAssign := oModel:SetValue('DG0MASTER', 'DG0_VLULEN'	, INTEGSTOX(oVersion:_LastEntryPriceValue:TEXT, 'N')		)	;If !lAssign; Return INTEGERROR( oModel ); EndIf
				lAssign := oModel:SetValue('DG0MASTER', 'DG0_VLPNRF'	, INTEGSTOX(oVersion:_PercentageScrapValue:TEXT, 'N')		)	;If !lAssign; Return INTEGERROR( oModel ); EndIf
				lAssign := oModel:SetValue('DG0MASTER', 'DG0_CDUSBG'	, RetCodUsr()															)	;If !lAssign; Return INTEGERROR( oModel ); EndIf
				lAssign := oModel:SetValue('DG0MASTER', 'DG0_TPST'	, oVersion:_StatusType:TEXT										)	;If !lAssign; Return INTEGERROR( oModel ); EndIf

				// Validação no Model
				If oModel:VldData()
					// Caso nao ocorra erros, efetiva os dados no banco
					oModel:CommitData()

					// Retorna OK
					cXMLRet := STR0028 + IF(nOpc == 3, STR0029, IF(nOpc == 4, STR0030, STR0031)) + STR0032  // 'Mensagem de ' ### 'criação' ### 'alteração' ### 'remoção' ## ' recebida com sucesso.'
				Else
					// Cria TAG com o Erro ocorrido para retornar ao EAI
					aErro := oModel:GetErrorMessage()
					cXMLRet := INTEGXTOS( aErro[6] ) + ' (' + INTEGXTOS( aErro[4] ) + ' = "' + INTEGXTOS( aErro[9] ) + '")'
					lRet := .F.
				EndIf

				// Desativa o Model
				oModel:DeActivate()
			Next

			// Adiciona os filhos de cada versão
			For nI := 1 to len( aVersion )
				oVersion := aVersion[nI]

				// Verifica se foi cadastrado na base
				dbSelectArea("DG0")
				dbSetOrder(1)
				If dbSeek( xFilial("DG0") + aCDACDV[nI] + aNRVRAC[nI] )

					// Instancia o modelo
					oModel 	:= FWLoadModel( 'DPRA300' )
					oModelDG1 	:= oModel:GetModel( 'DG1DETAIL' )
					oModelDG9 	:= oModel:GetModel( 'DG9DETAIL' )
					oModelDG6	:= oModel:GetModel( 'DG6DETAIL' )

					// Set a operação e Ativa o Model
					oModel:SetOperation( 4 )
					oModel:Activate()

					// Define Tutorial
					If !Empty(oVersion:_Tutorial:TEXT)
						oModelDG6:SetValue('DG6_DSNV'  , oVersion:_Tutorial:TEXT ); If !lAssign; Return INTEGERROR( oModel ); EndIf
					EndIf

					// Define Componentes
					If XmlChildEx(oVersion, "_LISTOFMATERIALS") != NIL .AND. XmlChildCount(oVersion:_ListOfMaterials) > 0
						aMaterial := oVersion:_ListOfMaterials:_Material
						If ValType( aMaterial ) == 'O'
							aMaterial := { aMaterial }
						EndIf

						For nJ := 1 To Len( aMaterial )
							oMaterial 	:= aMaterial[nJ]
							cSequence 	:= ALLTRIM( oMaterial:_SequenceNumber:TEXT )
							cSequence 	:= Replicate( "0", TamSX3("DG1_NRSQ")[1] - Len( cSequence ) ) + cSequence
							cCode 		:= Pad( SUBSTR( UPPER( oMaterial:_MaterialCode:TEXT ), 1, TamSX3("DG1_CDMT")[1] ), TamSX3("DG1_CDMT")[1])
							cVersion	:= ALLTRIM( oMaterial:_MaterialVersionNumber:TEXT )
							cVersion 	:= Replicate( "0", TamSX3("DG1_NRVRMT")[1] - Len( cVersion ) ) + cVersion
							cVersion 	:= If ( Val( cVersion ) == 0 , '', cVersion )

							// Caso Engenharia
							If Empty(cVersion)
								// Incluindo
								If !oModelDG1:SeekLine( { {'DG1_CDMT', cCode} } )
									oModelDG1:AddLine()
									lAssign := oModelDG1:SetValue('DG1_CDMT', cCode );	If !lAssign; Return INTEGERROR(oModel); EndIf
								// Alterando
								Else
									nK := 1
									While !oModelDG1:GetValue('DG1_CDMT', nK) == cCode
										nK++
									End
									oModelDG1:GoLine(nK)
								EndIf
							// Caso Desenvolvido
							Else
								// Incluindo
								If !oModelDG1:SeekLine( { {'DG1_CDMTDV', cCode}, {'DG1_NRVRMT', cVersion } } )
									oModelDG1:AddLine()
									lAssign := oModelDG1:SetValue('DG1_CDMTDV', cCode 	);	If !lAssign; Return INTEGERROR(oModel); EndIf
									lAssign := oModelDG1:SetValue('DG1_NRVRMT', cVersion );	If !lAssign; Return INTEGERROR(oModel); EndIf
								// Alterando
								Else
									nK := 1
									While !(oModelDG1:GetValue('DG1_CDMTDV', nK) == cCode .And. oModelDG1:GetValue('DG1_NRVRMT', nK) == cVersion )
										nK++
									End
									oModelDG1:GoLine( nK )
								EndIf
							EndIf

							lAssign := oModelDG1:LoadValue('DG1_NRSQ'  , cSequence 													);	If !lAssign; Return INTEGERROR(oModel); EndIf
							lAssign := oModelDG1:SetValue ('DG1_DTBG'  , INTEGSTOX(oMaterial:_StartDate:TEXT				, 'D') );	If !lAssign; Return INTEGERROR( oModel ); EndIf
							lAssign := oModelDG1:SetValue ('DG1_DTED'  , INTEGSTOX(oMaterial:_EndDate:TEXT  				, 'D') );	If !lAssign; Return INTEGERROR( oModel ); EndIf
							lAssign := oModelDG1:SetValue ('DG1_LGVI'  , INTEGSTOX(oMaterial:_IsVirtual:TEXT				, 'L') );	If !lAssign; Return INTEGERROR( oModel ); EndIf
							lAssign := oModelDG1:SetValue ('DG1_NRSRBG', oMaterial:_StartSeriesNumber:TEXT						);	If !lAssign; Return INTEGERROR( oModel ); EndIf
							lAssign := oModelDG1:SetValue ('DG1_NRSRED', oMaterial:_EndSeriesNumber:TEXT							);	If !lAssign; Return INTEGERROR( oModel ); EndIf
							lAssign := oModelDG1:SetValue ('DG1_QTAC'  , INTEGSTOX(oMaterial:_ItemQuantity:TEXT			, 'N')	);	If !lAssign; Return INTEGERROR( oModel ); EndIf
							lAssign := oModelDG1:SetValue ('DG1_QTMT'  , INTEGSTOX(oMaterial:_MaterialQuantity:TEXT		, 'N')	);	If !lAssign; Return INTEGERROR( oModel ); EndIf
							lAssign := oModelDG1:SetValue ('DG1_QTUT'  , INTEGSTOX(oMaterial:_UsedQuantity:TEXT			, 'N')	);	If !lAssign; Return INTEGERROR( oModel ); EndIf
							lAssign := oModelDG1:LoadValue('DG1_QTLQ'  , INTEGSTOX(oMaterial:_NetQuantity:TEXT			, 'N')	);	If !lAssign; Return INTEGERROR( oModel ); EndIf
							lAssign := oModelDG1:SetValue ('DG1_VLPN'  , INTEGSTOX(oMaterial:_ProportionValue:TEXT		, 'N') );	If !lAssign; Return INTEGERROR( oModel ); EndIf
							lAssign := oModelDG1:SetValue ('DG1_TPSB'  , oMaterial:_ScrapType:TEXT								);	If !lAssign; Return INTEGERROR( oModel ); EndIf
							lAssign := oModelDG1:SetValue ('DG1_CDRE'  , oMaterial:_ReferenceCode:TEXT							);	If !lAssign; Return INTEGERROR( oModel ); EndIf
							lAssign := oModelDG1:SetValue ('DG1_VLPNLS', INTEGSTOX(oMaterial:_PercentageLossValue:TEXT	, 'N')	);	If !lAssign; Return INTEGERROR( oModel ); EndIf
							oMaterial:_SequenceNumber:TEXT := cSequence
						Next
					EndIf

					// Define Atividades
					If XmlChildEx(oVersion, "_LISTOFACTIVITIES") != NIL .AND. XmlChildCount(oVersion:_ListOfActivities) > 0
						aActivity := oVersion:_ListOfActivities:_Activity
						If ValType( aActivity ) == 'O'
							aActivity := { aActivity }
						EndIf

						For nJ := 1 To Len( aActivity )
							oActivity 	:= aActivity[nJ]

							cSequence 	:= ALLTRIM( oActivity:_ActivityCode:TEXT )
							cSequence 	:= Replicate( "0", TamSX3("DG9_CDAT")[1] - Len( cSequence ) ) + cSequence
							cVersion	:= ALLTRIM( oActivity:_ActivityID:TEXT )
							cVersion 	:= Replicate( "0", TamSX3("DG9_IDAT")[1] - Len( cVersion ) ) + cVersion

							// Incluindo
							If !oModelDG9:SeekLine( { {'DG9_CDAT', cSequence } } )
								oModelDG9:AddLine()
								lAssign := oModelDG9:LoadValue('DG9_CDAT'  , cSequence					 									); If !lAssign; Return INTEGERROR( oModel ); EndIf
							// Alterando
							Else
								nK := 1
								While !(oModelDG9:GetValue('DG9_CDAT', nK) == cSequence )
									nK++
								End
								oModelDG9:GoLine( nK )
							EndIf

							lAssign := oModelDG9:LoadValue('DG9_IDAT'  , cVersion				 										); If !lAssign; Return INTEGERROR( oModel ); EndIf
							lAssign := oModelDG9:SetValue ('DG9_DSAT'  , oActivity:_ActivityDescription:TEXT 							); If !lAssign; Return INTEGERROR( oModel ); EndIf
							lAssign := oModelDG9:SetValue ('DG9_TPAT'  , oActivity:_ActivityType:TEXT 									); If !lAssign; Return INTEGERROR( oModel ); EndIf
							lAssign := oModelDG9:SetValue ('DG9_VLPN'  , INTEGSTOX(oActivity:_ProportionValue:TEXT, 'N') 				); If !lAssign; Return INTEGERROR( oModel ); EndIf
							lAssign := oModelDG9:SetValue ('DG9_DTBG'  , INTEGSTOX(oActivity:_StartDate:TEXT, 'D') 						); If !lAssign; Return INTEGERROR( oModel ); EndIf
							lAssign := oModelDG9:SetValue ('DG9_DTED'  , INTEGSTOX(oActivity:_EndDate:TEXT, 'D') 						); If !lAssign; Return INTEGERROR( oModel ); EndIf
							lAssign := oModelDG9:SetValue ('DG9_CDCETR', oActivity:_WorkcenterCode:TEXT 									); If !lAssign; Return INTEGERROR( oModel ); EndIf
							lAssign := oModelDG9:SetValue ('DG9_LGATVF', INTEGSTOX(oActivity:_IsActivityControl:TEXT, 'L') 			); If !lAssign; Return INTEGERROR( oModel ); EndIf
							lAssign := oModelDG9:SetValue ('DG9_CDATVF', INTEGSTOX(oActivity:_ActivityControlCode:TEXT, 'N')			); If !lAssign; Return INTEGERROR( oModel ); EndIf
							lAssign := oModelDG9:SetValue ('DG9_CDMOD' , oActivity:_LaborCode:TEXT 										); If !lAssign; Return INTEGERROR( oModel ); EndIf
							lAssign := oModelDG9:SetValue ('DG9_NRUNAC', INTEGSTOX(oActivity:_UnitQuantity:TEXT, 'N') 					); If !lAssign; Return INTEGERROR( oModel ); EndIf
							lAssign := oModelDG9:SetValue ('DG9_TPUNTE', oActivity:_TimeType:TEXT 										); If !lAssign; Return INTEGERROR( oModel ); EndIf
							lAssign := oModelDG9:SetValue ('DG9_QTTESU', INTEGSTOX(oActivity:_SetupTimeQuantity:TEXT, 'N') 			); If !lAssign; Return INTEGERROR( oModel ); EndIf
							lAssign := oModelDG9:SetValue ('DG9_QTTEMQ', INTEGSTOX(oActivity:_MachineTimeQuantity:TEXT, 'N') 			); If !lAssign; Return INTEGERROR( oModel ); EndIf
							lAssign := oModelDG9:SetValue ('DG9_QTTERC', INTEGSTOX(oActivity:_ResourceTimeQuantity:TEXT, 'N') 		); If !lAssign; Return INTEGERROR( oModel ); EndIf
							lAssign := oModelDG9:SetValue ('DG9_CDUNAT', oActivity:_ActivityUnitOfMeasureCode:TEXT 						); If !lAssign; Return INTEGERROR( oModel ); EndIf
							lAssign := oModelDG9:SetValue ('DG9_NRATSM', INTEGSTOX(oActivity:_SimultaneousActivityQuantity:TEXT, 'N')); If !lAssign; Return INTEGERROR( oModel ); EndIf
							lAssign := oModelDG9:SetValue ('DG9_QTRC'  , INTEGSTOX(oActivity:_ResourceQuantity:TEXT, 'N')				); If !lAssign; Return INTEGERROR( oModel ); EndIf
							lAssign := oModelDG9:SetValue ('DG9_CDRE'  , oActivity:_ReferenceCode:TEXT 									); If !lAssign; Return INTEGERROR( oModel ); EndIf
							lAssign := oModelDG9:SetValue ('DG9_TPTEAT', oActivity:_TimeTreatmentType:TEXT 								); If !lAssign; Return INTEGERROR( oModel ); EndIf
							oActivity:_ActivityCode:TEXT := cSequence
							oActivity:_ActivityID:TEXT   := cVersion
						Next
					EndIf

					// Validação no Model
					If oModel:VldData()
						// Caso nao ocorra erros, efetiva os dados no banco
						oModel:CommitData()

						// Retorna OK
						cXMLRet := STR0028 + IF(nOpc == 3, STR0029, IF(nOpc == 4, STR0030, STR0031)) + STR0032  // 'Mensagem de ' ### 'criação' ### 'alteração' ### 'remoção' ## ' recebida com sucesso.'
					Else
						// Cria TAG com o Erro ocorrido para retornar ao EAI
						aErro := oModel:GetErrorMessage()
						cXMLRet := INTEGXTOS( aErro[6] ) + ' (' + INTEGXTOS( aErro[4] ) + ' = "' + INTEGXTOS( aErro[9] ) + '")'
						lRet := .F.
					EndIf

					oModel:Deactivate()

					// Para cada material
					For nJ := 1 To Len( aMaterial )

						// Verifica se foi cadastrado na base
						dbSelectArea( 'DG1' )
						dbSeek( xFilial('DG1') + aCDACDV[nI] + aNRVRAC[nI] + aMaterial[nJ]:_SequenceNumber:TEXT )

						// Instancia o modelo
						oModel 	:= FWLoadModel( 'DPRA310' )
						oModelDG4 	:= oModel:GetModel( 'DG4DETAIL' )
						oModelDG6 	:= oModel:GetModel( 'DG6DETAIL' )

						// Set a operação e Ativa o Model
						oModel:SetOperation( 4 )
						oModel:Activate()

						// Adiciona a narrativa
						lAssign := oModelDG6:SetValue ('DG6_DSNV'  , aMaterial[nJ]:_Narrative:TEXT ); If !lAssign; Return INTEGERROR( oModel ); EndIf

						// Adiciona os componentes alternativos
						If XmlChildEx(aMaterial[nJ], "_LISTOFALTERNATIVEMATERIALS") != NIL .And. XmlChildCount(aMaterial[nJ]:_ListOfAlternativeMaterials) > 0
							aAlternat 	:= aMaterial[nJ]:_ListOfAlternativeMaterials:_AlternativeMaterial
							If ValType( aAlternat ) == 'O'
								aAlternat := { aAlternat }
							EndIf

							For nK := 1 to len( aAlternat )

								cSequence 	:= ALLTRIM( aAlternat[nK]:_SequenceNumber:TEXT )
								cSequence 	:= Replicate( "0", TamSX3("DG4_NRSQAV")[1] - Len( cSequence ) ) + cSequence

								// Incluindo
								If !oModelDG4:SeekLine(	{	{ 'DG4_CDACDV' , aCDACDV[nI] }, { 'DG4_NRVRAC', aNRVRAC[nI] } , ;
																{ 'DG4_NRSQ'   , aMaterial[nJ]:_SequenceNumber:TEXT }, { 'DG4_NRSQAV', cSequence } } )
									oModelDG4:AddLine()
									lAssign := oModelDG4:LoadValue('DG4_NRSQAV', cSequence 														); If !lAssign; Return INTEGERROR( oModel ); EndIf
								// Alterando
								Else
									nL := 1
									While !oModelDG4:GetValue('DG4_NRSQAV', nL) == cSequence
										nL++
									End
									oModelDG4:GoLine(nL)
								EndIf

								lAssign := oModelDG4:SetValue ('DG4_CDMTAV', aAlternat[nK]:_AlternativeMaterialCode:TEXT 				); If !lAssign; Return INTEGERROR( oModel ); EndIf
								lAssign := oModelDG4:SetValue ('DG4_QTAC'  , INTEGSTOX(aAlternat[nK]:_ItemQuantity:TEXT, 'N') 			); If !lAssign; Return INTEGERROR( oModel ); EndIf
								lAssign := oModelDG4:SetValue ('DG4_QTMT'  , INTEGSTOX(aAlternat[nK]:_MaterialQuantity:TEXT, 'N') 	); If !lAssign; Return INTEGERROR( oModel ); EndIf
								lAssign := oModelDG4:LoadValue('DG4_QTUT'  , INTEGSTOX(aAlternat[nK]:_UsedQuantity:TEXT, 'N') 			); If !lAssign; Return INTEGERROR( oModel ); EndIf
								lAssign := oModelDG4:SetValue ('DG4_VLPN'  , INTEGSTOX(aAlternat[nK]:_ProportionValue:TEXT, 'N') 		); If !lAssign; Return INTEGERROR( oModel ); EndIf
								lAssign := oModelDG4:SetValue ('DG4_VLPNLS', INTEGSTOX(aAlternat[nK]:_PercentageLossValue:TEXT, 'N')	); If !lAssign; Return INTEGERROR( oModel ); EndIf

								// Grava narrativa do componente alternativo
								If !Empty( aAlternat[nK]:_Narrative:TEXT )
									dbSelectArea( 'DG6' )
									RecLock( 'DG6', .T. )
						        	DG6->DG6_FILIAL := xFilial( 'DG6' )
						        	DG6->DG6_IDNV   := GetSXENum( 'DG6', 'DG6_IDNV' )
									DG6->DG6_DSNV   := aAlternat[nK]:_Narrative:TEXT
									lAssign := oModelDG4:SetValue ('DG4_IDNV', DG6->DG6_IDNV												); If !lAssign; Return INTEGERROR( oModel ); EndIf
					        		MsUnLock()
								EndIf
							Next
						EndIf

						// Validação no Model
						If oModel:VldData()
							// Caso nao ocorra erros, efetiva os dados no banco
							oModel:CommitData()

							// Retorna OK
							cXMLRet := STR0028 + IF(nOpc == 3, STR0029, IF(nOpc == 4, STR0030, STR0031)) + STR0032  // 'Mensagem de ' ### 'criação' ### 'alteração' ### 'remoção' ## ' recebida com sucesso.'
						Else
							// Cria TAG com o Erro ocorrido para retornar ao EAI
							aErro := oModel:GetErrorMessage()
							cXMLRet := INTEGXTOS( aErro[6] ) + ' (' + INTEGXTOS( aErro[4] ) + ' = "' + INTEGXTOS( aErro[9] ) + '")'
							lRet := .F.
						EndIf

						oModel:Deactivate()
					Next

					// Para cada Atividade
					For nJ := 1 To Len( aActivity )

						// Verifica se foi cadastrado na base
						dbSelectArea( 'DG9' )
						dbSeek( xFilial('DG9') + aCDACDV[nI] + aNRVRAC[nI] + aActivity[nJ]:_ActivityCode:TEXT )

						// Instancia o modelo
						oModel 	:= FWLoadModel( 'DPRA320' )
						oModelDG2	:= oModel:GetModel( 'DG2DETAIL' )
						oModelDG8 	:= oModel:GetModel( 'DG8DETAIL' )
						oModelDG7 	:= oModel:GetModel( 'DG7DETAIL' )

						// Set a operação e Ativa o Model
						oModel:SetOperation( 4 )
						oModel:Activate()
						lAssign := oModel:SetValue('DG9MASTER', 'DG9_CDAT', aActivity[nJ]:_ActivityCode:TEXT 											); If !lAssign; Return INTEGERROR( oModel ); EndIf

						// Adiciona a narrativa
						lAssign := oModel:SetValue('DG6DETAIL', 'DG6_DSNV', aActivity[nJ]:_Narrative:TEXT 								); If !lAssign; Return INTEGERROR( oModel ); EndIf

						// Adiciona o tutorial
						lAssign := oModel:SetValue('TUTDETAIL', 'DG6_DSNV', aActivity[nJ]:_Tutorial:TEXT 								); If !lAssign; Return INTEGERROR( oModel ); EndIf

						// Adiciona as ferramentas
						If XmlChildEx(aActivity[nJ], "_LISTOFACTIVITYTOOLS") != NIL .And. XmlChildCount(aActivity[nJ]:_ListOfActivityTools) > 0
							aTools	:= aActivity[nJ]:_ListOfActivityTools:_ActivityTool
							If ValType( aTools ) == 'O'
								aTools := { aTools }
							EndIf

							For nK := 1 to len( aTools )
								cSequence 	:= ALLTRIM( Upper (aTools[nK]:_ToolCode:TEXT) )
								cSequence 	+= Space( TamSX3("DG2_CDFE")[1] - Len( cSequence ) )


								// Incluindo
								If !oModelDG2:SeekLine(	{ {'DG2_CDFE', cSequence } } )
									oModelDG2:AddLine()
									lAssign := oModelDG2:LoadValue('DG2_CDFE', cSequence							 			); If !lAssign; Return INTEGERROR( oModel ); EndIf
								// Alterando
								Else
									nL := 1
									While !(oModelDG2:GetValue('DG2_CDFE', nL) == cSequence)
										nL++
									End
									oModelDG2:GoLine(nL)
								EndIf
								lAssign := oModelDG2:SetValue ('DG2_LGFE'  , INTEGSTOX(aTools[nK]:_IsToolUsed:TEXT, 'L') 				); If !lAssign; Return INTEGERROR( oModel ); EndIf
								lAssign := oModelDG2:SetValue ('DG2_VLPN'  , INTEGSTOX(aTools[nK]:_ProportionValue:TEXT, 'N')			); If !lAssign; Return INTEGERROR( oModel ); EndIf
								lAssign := oModelDG2:SetValue ('DG2_QTUNCI', INTEGSTOX(aTools[nK]:_UnitCycleQuantity:TEXT, 'N') 		); If !lAssign; Return INTEGERROR( oModel ); EndIf

								// Grava narrativa da ferramenta
								If !Empty( aTools[nK]:_Narrative:TEXT )
									dbSelectArea( 'DG6' )
									RecLock( 'DG6', .T. )
						        	DG6->DG6_FILIAL := xFilial( 'DG6' )
						        	DG6->DG6_IDNV   := GetSXENum( 'DG6', 'DG6_IDNV' )
									DG6->DG6_DSNV   := aTools[nK]:_Narrative:TEXT
									lAssign := oModelDG2:SetValue ('DG2_IDNV', DG6->DG6_IDNV												); If !lAssign; Return INTEGERROR( oModel ); EndIf
					        		MsUnLock()
								EndIf

							Next

						EndIf

						// Adiciona os itens consumíveis
						If XmlChildEx(aActivity[nJ], "_LISTOFACTIVITYITENS") != NIL .And. XmlChildCount(aActivity[nJ]:_ListOfActivityItens) > 0
							aItens := aActivity[nJ]:_ListOfActivityItens:_ActivityItem
							If ValType( aItens ) == 'O'
								aItens := { aItens }
							EndIf

							For nK := 1 to len( aItens )
								cSequence 	:= ALLTRIM( Upper (aItens[nK]:_ItemCode:TEXT) )
								cSequence 	+= Space( TamSX3("DG8_CDAC")[1] - Len( cSequence ) )

								// Incluindo
								If !oModelDG8:SeekLine(	{ {'DG8_CDAC', cSequence } } )
									oModelDG8:AddLine()
									lAssign := oModelDG8:LoadValue('DG8_CDAC', cSequence			 			); If !lAssign; Return INTEGERROR( oModel ); EndIf
								// Alterando
								Else
									nL := 1
									While !(oModelDG8:GetValue('DG8_CDAC', nL) == cSequence)
										nL++
									End
									oModelDG8:GoLine(nL)
								EndIf
								lAssign := oModelDG8:SetValue ('DG8_VLPN'  , INTEGSTOX(aItens[nK]:_ProportionValue:TEXT, 'N')			); If !lAssign; Return INTEGERROR( oModel ); EndIf
								lAssign := oModelDG8:SetValue ('DG8_QTRY'  , INTEGSTOX(aItens[nK]:_UsedQuantity:TEXT, 'N') 			); If !lAssign; Return INTEGERROR( oModel ); EndIf
								lAssign := oModelDG8:SetValue ('DG8_QTAT'  , INTEGSTOX(aItens[nK]:_ActivityQuantity:TEXT, 'N') 		); If !lAssign; Return INTEGERROR( oModel ); EndIf

								// Grava narrativa do componente alternativo
								If !Empty( aItens[nK]:_Narrative:TEXT )
									dbSelectArea( 'DG6' )
									RecLock( 'DG6', .T. )
						        	DG6->DG6_FILIAL := xFilial( 'DG6' )
						        	DG6->DG6_IDNV   := GetSXENum( 'DG6', 'DG6_IDNV' )
									DG6->DG6_DSNV   := aItens[nK]:_Narrative:TEXT
									lAssign := oModelDG8:SetValue ('DG8_IDNV', DG6->DG6_IDNV												); If !lAssign; Return INTEGERROR( oModel ); EndIf
					        		MsUnLock()
								EndIf
							Next
						EndIf

						// Adiciona as atividades alternativas
						If XmlChildEx(aActivity[nJ], "_LISTOFALTERNATIVEACTIVITIES") != NIL .And. XmlChildCount(aActivity[nJ]:_ListOfAlternativeActivities) > 0
							aAlternat 	:= aActivity[nJ]:_ListOfAlternativeActivities:_AlternativeActivity
							If ValType( aAlternat ) == 'O'
								aAlternat := { aAlternat }
							EndIf

							For nK := 1 to len( aAlternat )
								cSequence 	:= ALLTRIM( aAlternat[nK]:_AlternativeActivityCode:TEXT )
								cSequence 	:= Replicate( "0", TamSX3("DG7_CDATAV")[1] - Len( cSequence ) ) + cSequence

								// Incluindo
								If !oModelDG7:SeekLine(	{ {'DG7_CDATAV', cSequence } } )
									oModelDG7:AddLine()
									lAssign := oModelDG7:LoadValue('DG7_CDATAV', cSequence					 			); If !lAssign; Return INTEGERROR( oModel ); EndIf
								// Alterando
								Else
									nL := 1
									While !(oModelDG7:GetValue('DG7_CDATAV', nL) == cSequence )
										nL++
									End
									oModelDG7:GoLine(nL)
								EndIf

								lAssign := oModelDG7:SetValue ('DG7_DSAT'	 , aAlternat[nK]:_AlternativeActivityDescription:TEXT 				); If !lAssign; Return INTEGERROR( oModel ); EndIf
								lAssign := oModelDG7:SetValue ('DG7_TPAT'  , aAlternat[nK]:_AlternativeActivityType:TEXT 						); If !lAssign; Return INTEGERROR( oModel ); EndIf
								lAssign := oModelDG7:SetValue ('DG7_CDCETR', aAlternat[nK]:_WorkcenterCode:TEXT 									); If !lAssign; Return INTEGERROR( oModel ); EndIf
								lAssign := oModelDG7:SetValue ('DG7_CDMOD' , aAlternat[nK]:_LaborCode:TEXT 										); If !lAssign; Return INTEGERROR( oModel ); EndIf
								lAssign := oModelDG7:SetValue ('DG7_NRUNAC', INTEGSTOX(aAlternat[nK]:_UnitQuantity:TEXT 	, 'N')				); If !lAssign; Return INTEGERROR( oModel ); EndIf
								lAssign := oModelDG7:SetValue ('DG7_TPUNTE', aAlternat[nK]:_TimeType:TEXT 										); If !lAssign; Return INTEGERROR( oModel ); EndIf
								lAssign := oModelDG7:SetValue ('DG7_QTTESU', INTEGSTOX(aAlternat[nK]:_SetupTimeQuantity:TEXT , 'N')			); If !lAssign; Return INTEGERROR( oModel ); EndIf
								lAssign := oModelDG7:SetValue ('DG7_QTTEMQ', INTEGSTOX(aAlternat[nK]:_MachineTimeQuantity:TEXT, 'N') 			); If !lAssign; Return INTEGERROR( oModel ); EndIf
								lAssign := oModelDG7:SetValue ('DG7_QTTERC', INTEGSTOX(aAlternat[nK]:_ResourceTimeQuantity:TEXT , 'N')		); If !lAssign; Return INTEGERROR( oModel ); EndIf
								lAssign := oModelDG7:LoadValue('DG7_CDUNAT', AllTrim( aAlternat[nK]:_ActivityUnitOfMeasureCode:TEXT )			); If !lAssign; Return INTEGERROR( oModel ); EndIf
								lAssign := oModelDG7:SetValue ('DG7_NRATSM', INTEGSTOX(aAlternat[nK]:_SimultaneousActivityQuantity:TEXT,'N')	); If !lAssign; Return INTEGERROR( oModel ); EndIf
								lAssign := oModelDG7:SetValue ('DG7_QTRC'  , INTEGSTOX(aAlternat[nK]:_ResourceQuantity:TEXT , 'N')			); If !lAssign; Return INTEGERROR( oModel ); EndIf
								aAlternat[nK]:_AlternativeActivityCode:TEXT := cSequence
							Next
						Else
							aAlternat := {}
						EndIf

						// Validação no Model
						If oModel:VldData()
							// Caso nao ocorra erros, efetiva os dados no banco
							oModel:CommitData()

							// Retorna OK
							cXMLRet := STR0028 + IF(nOpc == 3, STR0029, IF(nOpc == 4, STR0030, STR0031)) + STR0032  // 'Mensagem de ' ### 'criação' ### 'alteração' ### 'remoção' ## ' recebida com sucesso.'
						Else
							// Cria TAG com o Erro ocorrido para retornar ao EAI
							aErro := oModel:GetErrorMessage()
							cXMLRet := INTEGXTOS( aErro[6] ) + ' (' + INTEGXTOS( aErro[4] ) + ' = "' + INTEGXTOS( aErro[9] ) + '")'
							lRet := .F.
						EndIf

						oModel:Deactivate()

						// Para cada alternativa
						For nK := 1 to len( aAlternat )

							// Verifica se foi cadastrado na base
							dbSelectArea( 'DG7' )
							dbSeek( xFilial('DG7') + aActivity[nJ]:_ActivityID:TEXT + aAlternat[nK]:_AlternativeActivityCode:TEXT )

							// Instancia o modelo
							oModel 	:= FWLoadModel( 'DPRA321' )
							oModelDG2	:= oModel:GetModel( 'DG2DETAIL' )
							oModelDG8 	:= oModel:GetModel( 'DG8DETAIL' )
							oModelDG6 	:= oModel:GetModel( 'DG6DETAIL' )

							// Set a operação e Ativa o Model
							oModel:SetOperation( 4 )
							oModel:Activate()

							// Adiciona a narrativa
							lAssign := oModel:SetValue('DG6DETAIL', 'DG6_DSNV', aAlternat[nK]:_Narrative:TEXT 								); If !lAssign; Return INTEGERROR( oModel ); EndIf

							// Adiciona o tutorial
							lAssign := oModel:SetValue('TUTDETAIL', 'DG6_DSNV', aAlternat[nK]:_Tutorial:TEXT 								); If !lAssign; Return INTEGERROR( oModel ); EndIf

							// Adiciona as ferramentas
							If XmlChildEx(aAlternat[nK], "_LISTOFACTIVITYTOOLS") != NIL .And. XmlChildCount(aAlternat[nK]:_ListOfActivityTools) > 0
								aTools	:= aAlternat[nK]:_ListOfActivityTools:_ActivityTool
								If ValType( aTools ) == 'O'
									aTools := { aTools }
								EndIf

								For nL := 1 to len( aTools )
									cSequence 	:= ALLTRIM( Upper (aTools[nL]:_ToolCode:TEXT) )
									cSequence 	+= Space( TamSX3("DG2_CDFE")[1] - Len( cSequence ) )

									// Incluindo
									If !oModelDG2:SeekLine(	{ {'DG2_CDFE', cSequence } } )
										oModelDG2:AddLine()
										lAssign := oModelDG2:LoadValue('DG2_CDFE', cSequence						 			); If !lAssign; Return INTEGERROR( oModel ); EndIf
									// Alterando
									Else
										nM := 1
										While !(oModelDG2:GetValue('DG2_CDFE', nM) == cSequence)
											nM++
										End
										oModelDG2:GoLine(nM)
									EndIf
									lAssign := oModelDG2:SetValue ('DG2_LGFE'  , INTEGSTOX(aTools[nK]:_IsToolUsed:TEXT, 'L') 				); If !lAssign; Return INTEGERROR( oModel ); EndIf
									lAssign := oModelDG2:SetValue ('DG2_VLPN'  , INTEGSTOX(aTools[nK]:_ProportionValue:TEXT, 'N')			); If !lAssign; Return INTEGERROR( oModel ); EndIf
									lAssign := oModelDG2:SetValue ('DG2_QTUNCI', INTEGSTOX(aTools[nK]:_UnitCycleQuantity:TEXT, 'N') 		); If !lAssign; Return INTEGERROR( oModel ); EndIf

									// Grava narrativa da ferramenta
									If !Empty( aTools[nK]:_Narrative:TEXT )
										dbSelectArea( 'DG6' )
										RecLock( 'DG6', .T. )
							        	DG6->DG6_FILIAL := xFilial( 'DG6' )
							        	DG6->DG6_IDNV   := GetSXENum( 'DG6', 'DG6_IDNV' )
										DG6->DG6_DSNV   := aTools[nK]:_Narrative:TEXT
										lAssign := oModelDG2:SetValue ('DG2_IDNV', DG6->DG6_IDNV												); If !lAssign; Return INTEGERROR( oModel ); EndIf
						        		MsUnLock()
									EndIf

								Next

							EndIf

							// Adiciona os itens consumíveis
							If XmlChildEx(aAlternat[nK], "_LISTOFACTIVITYITENS") != NIL .And. XmlChildCount(aAlternat[nK]:_ListOfActivityItens) > 0
								aItens := aAlternat[nK]:_ListOfActivityItens:_ActivityItem
								If ValType( aItens ) == 'O'
									aItens := { aItens }
								EndIf

								For nL := 1 to len( aItens )
									cSequence 	:= ALLTRIM( Upper (aItens[nL]:_ItemCode:TEXT) )
									cSequence 	+= Space( TamSX3("DG8_CDAC")[1] - Len( cSequence ) )

									// Incluindo
									If !oModelDG8:SeekLine(	{ {'DG8_CDAC', cSequence } } )
										oModelDG8:AddLine()
										lAssign := oModelDG8:LoadValue('DG8_CDAC', cSequence 									); If !lAssign; Return INTEGERROR( oModel ); EndIf
									// Alterando
									Else
										nM := 1
										While !(oModelDG8:GetValue('DG8_CDAC', nM) == cSequence)
											nM++
										End
										oModelDG8:GoLine(nM)
									EndIf
									lAssign := oModelDG8:SetValue ('DG8_VLPN'  , INTEGSTOX(aItens[nK]:_ProportionValue:TEXT, 'N')			); If !lAssign; Return INTEGERROR( oModel ); EndIf
									lAssign := oModelDG8:SetValue ('DG8_QTRY'  , INTEGSTOX(aItens[nK]:_UsedQuantity:TEXT, 'N') 			); If !lAssign; Return INTEGERROR( oModel ); EndIf
									lAssign := oModelDG8:SetValue ('DG8_QTAT'  , INTEGSTOX(aItens[nK]:_ActivityQuantity:TEXT, 'N') 		); If !lAssign; Return INTEGERROR( oModel ); EndIf

									// Grava narrativa do componente alternativo
									If !Empty( aItens[nK]:_Narrative:TEXT )
										dbSelectArea( 'DG6' )
										RecLock( 'DG6', .T. )
							        	DG6->DG6_FILIAL := xFilial( 'DG6' )
							        	DG6->DG6_IDNV   := GetSXENum( 'DG6', 'DG6_IDNV' )
										DG6->DG6_DSNV   := aItens[nK]:_Narrative:TEXT
										lAssign := oModelDG8:SetValue ('DG8_IDNV', DG6->DG6_IDNV												); If !lAssign; Return INTEGERROR( oModel ); EndIf
						        		MsUnLock()
									EndIf
								Next
							EndIf

							// Validação no Model
							If oModel:VldData()
								// Caso nao ocorra erros, efetiva os dados no banco
								oModel:CommitData()

								// Retorna OK
								cXMLRet := STR0028 + IF(nOpc == 3, STR0029, IF(nOpc == 4, STR0030, STR0031)) + STR0032  // 'Mensagem de ' ### 'criação' ### 'alteração' ### 'remoção' ## ' recebida com sucesso.'
							Else
								// Cria TAG com o Erro ocorrido para retornar ao EAI
								aErro := oModel:GetErrorMessage()
								cXMLRet := INTEGXTOS( aErro[6] ) + ' (' + INTEGXTOS( aErro[4] ) + ' = "' + INTEGXTOS( aErro[9] ) + '")'
								lRet := .F.
							EndIf

							oModel:Deactivate()
						Next
					Next

					// Adiciona a rede pert
					If XmlChildEx(oVersion, "_LISTOFPERT") != NIL .And. XmlChildCount(oVersion:_ListOfPert) > 0
						aPert 	:= oVersion:_ListOfPert:_Pert
						If ValType( aPert ) == 'O'
							aPert := { aPert }
						EndIf

						// Verifica se foi cadastrado na base
						dbSelectArea( 'DG0' )
						dbSeek( xFilial('DG0') + aCDACDV[nI] + aNRVRAC[nI] )

						// Instancia o modelo
						oModel 	:= FWLoadModel( 'DPRA300' )
						oModelDG9 	:= oModel:GetModel( 'DG9DETAIL' )

						// Set a operação e Ativa o Model
						oModel:SetOperation( 4 )
						oModel:Activate()

						// Verifica se foi cadastrado na base
						dbSelectArea( 'DGD' )
						dbSeek( xFilial('DGD') + aCDACDV[nI] + aNRVRAC[nI] )
						oModelDG0 	:= FWLoadModel( 'DPRA322' )
						oModelDGD 	:= oModelDG0:GetModel( 'DGDDETAIL' )

						// Set a operação e Ativa o Model
						oModelDG0:SetOperation( 4 )
						oModelDG0:Activate()

						// Limpa valores
						For nJ := 1 to oModelDGD:Length()
							oModelDGD:GoLine( nJ )
							If !oModelDGD:IsDeleted()
								oModelDGD:DeleteLine()
							Endif
						Next

						// Inclui rede-pert
						For nJ := 1 to len( aPert )
							oModelDGD:AddLine()

							cSequence 	:= ALLTRIM( aPert[nJ]:_SequenceNumber:TEXT )
							cSequence 	:= Replicate( "0", TamSX3("DGD_NRSQ")[1] - Len( cSequence ) ) + cSequence
							lAssign := oModelDGD:LoadValue('DGD_NRSQ'  , cSequence 														); If !lAssign; Return INTEGERROR( oModel ); EndIf

							cSequence 	:= ALLTRIM( aPert[nJ]:_PreviousActivityID:TEXT )
							cSequence 	:= Replicate( "0", TamSX3("DGD_IDATPV")[1] - Len( cSequence ) ) + cSequence
							lAssign := oModelDGD:SetValue ('DGD_IDATPV', cSequence						 								); If !lAssign; Return INTEGERROR( oModel ); EndIf

							cSequence 	:= ALLTRIM( aPert[nJ]:_PreviousActivityCode:TEXT )
							cSequence 	:= Replicate( "0", TamSX3("DGD_CDATPV")[1] - Len( cSequence ) ) + cSequence
							lAssign := oModelDGD:SetValue ('DGD_CDATPV', cSequence						 								); If !lAssign; Return INTEGERROR( oModel ); EndIf

							cSequence 	:= ALLTRIM( aPert[nJ]:_NextActivityID:TEXT )
							cSequence 	:= Replicate( "0", TamSX3("DGD_IDATNX")[1] - Len( cSequence ) ) + cSequence
							lAssign := oModelDGD:SetValue ('DGD_IDATNX', cSequence						 								); If !lAssign; Return INTEGERROR( oModel ); EndIf

							cSequence 	:= ALLTRIM( aPert[nJ]:_NextActivityCode:TEXT )
							cSequence 	:= Replicate( "0", TamSX3("DGD_CDATNX")[1] - Len( cSequence ) ) + cSequence
							lAssign := oModelDGD:SetValue ('DGD_CDATNX', cSequence						 								); If !lAssign; Return INTEGERROR( oModel ); EndIf

							lAssign := oModelDGD:SetValue ('DGD_VLPNOV', INTEGSTOX(aPert[nJ]:_PercentageOverlapValue:TEXT, 'N')	); If !lAssign; Return INTEGERROR( oModel ); EndIf
							lAssign := oModelDGD:SetValue ('DGD_QTTETS', INTEGSTOX(aPert[nJ]:_TransportTimeQuantity:TEXT, 'N')	); If !lAssign; Return INTEGERROR( oModel ); EndIf
							lAssign := oModelDGD:SetValue ('DGD_TPUNTE', aPert[nJ]:_TimeType:TEXT										); If !lAssign; Return INTEGERROR( oModel ); EndIf
						Next

						// Validação no Model
						If oModelDG0:VldData()
							// Caso nao ocorra erros, efetiva os dados no banco
							oModelDG0:CommitData()

							// Retorna OK
							cXMLRet := STR0028 + IF(nOpc == 3, STR0029, IF(nOpc == 4, STR0030, STR0031)) + STR0032  // 'Mensagem de ' ### 'criação' ### 'alteração' ### 'remoção' ## ' recebida com sucesso.'
						Else
							// Cria TAG com o Erro ocorrido para retornar ao EAI
							aErro := oModel:GetErrorMessage()
							cXMLRet := INTEGXTOS( aErro[6] ) + ' (' + INTEGXTOS( aErro[4] ) + ' = "' + INTEGXTOS( aErro[9] ) + '")'
							lRet := .F.
						EndIf

						oModelDG0:Deactivate()
						oModel:Deactivate()
					EndIf
				EndIf
			Next
		EndIf

		// Mensagem é de Response
		ElseIf cTypeMessage == EAI_MESSAGE_RESPONSE
			cXMLRet := STR0033 // 'Resposta recebida com sucesso.'

		// Mensagem é de Whois
		ElseIf   cTypeMessage == EAI_MESSAGE_WHOIS
			Return {.T., '1.000'}
		EndIf

EndIf

RestArea(aArea)

Return { lRet, cXMLRet }*/
