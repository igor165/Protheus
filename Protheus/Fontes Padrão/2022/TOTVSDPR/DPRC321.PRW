#INCLUDE 'DPRC321.CH'
#INCLUDE 'TOTVS.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWADAPTEREAI.CH'

#DEFINE PULALINHA CHR(13)+CHR(10)

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRC321
Tela de Simular Retorno sobre Investimento - ROI

@author Samantha Preima
@since 08/01/2013
@version P11
/*/
//-------------------------------------------------------------------
Function DPRC321()
Local aValidaDPR := ValidaDPR()
Private oBrowse

// Valida se o programa pode ser aberto
If aValidaDPR[1] .And. !Empty(aValidaDPR[2])
	Final(aValidaDPR[2])
ElseIf !Empty( aValidaDPR[2] )
	DPRXError( 'DPRC321', aValidaDPR[2], 3 )
EndIf

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('DG0')
oBrowse:SetDescription( STR0001 ) // 'Simular Retorno sobre Investimento'

if DPRC321PAR()
	oBrowse:Activate()
Endif

Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

If IsInCallStack('DPRC321')
	ADD OPTION aRotina TITLE STR0002 ACTION 'PesqBrw'         OPERATION 1 ACCESS 0    // 'Pesquisar'
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.DPRC321' OPERATION 2 ACCESS 0    // 'Visualizar'
	ADD OPTION aRotina TITLE STR0020 ACTION 'DPRC321PAR()'    OPERATION 3 ACCESS 0    // 'Parâmetros'
	ADD OPTION aRotina TITLE STR0021 ACTION 'DPRC324()'       OPERATION 3 ACCESS 0    // 'Calcular Custo Fabricação'
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
Local oModel

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('DPRC321', /*bPreValidacao*/, { |oModel| DPRC321POS( oModel ) }, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'DG0MASTER', /*cOwner*/, oStructDG0, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por grid
oModel:AddGrid( 'DG1DETAIL', 'DG0MASTER', oStructDG1, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*bLoad*/ )
oModel:AddGrid( 'DG9DETAIL', 'DG0MASTER', oStructDG9, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
oModel:AddGrid( 'DG6DETAIL', 'DG0MASTER', oStructDG6, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
oModel:AddGrid( 'DGJDETAIL', 'DG0MASTER', oStructDGJ, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
oModel:AddGrid( 'DGMDETAIL', 'DG0MASTER', oStructDGM, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
oModel:AddGrid( 'DGGDETAIL', 'DG0MASTER', oStructDGG, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
oModel:AddGrid( 'DG5DETAIL', 'DG0MASTER', oStructDG5, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

// Faz relaciomaneto entre os compomentes do model
oModel:SetRelation( 'DG1DETAIL', { { 'DG1_FILIAL', 'xFilial( "DG1" )' }, { 'DG1_CDACDV', 'DG0_CDACDV' }, { 'DG1_NRVRAC', 'DG0_NRVRAC'} }, DG1->( IndexKey(1)) )
oModel:SetRelation( 'DG9DETAIL', { { 'DG9_FILIAL', 'xFilial( "DG9" )' }, { 'DG9_CDACDV', 'DG0_CDACDV' }, { 'DG9_NRVRAC', 'DG0_NRVRAC'} }, DG9->( IndexKey(1)) )
oModel:SetRelation( 'DG6DETAIL', { { 'DG6_FILIAL', 'xFilial( "DG6" )' }, { 'DG6_IDNV'  , 'DG0_IDNV'   } }, DG6->( IndexKey(1)) )
oModel:SetRelation( 'DGJDETAIL', { { 'DGJ_FILIAL', 'xFilial( "DGJ" )' }, { 'DGJ_CDACDV', 'DG0_CDACDV' }, { 'DGJ_NRVRAC', 'DG0_NRVRAC'} }, DGJ->( IndexKey(1)) )
oModel:SetRelation( 'DGMDETAIL', { { 'DGM_FILIAL', 'xFilial( "DGM" )' }, { 'DGM_CDACDV', 'DG0_CDACDV' }, { 'DGM_NRVRAC', 'DG0_NRVRAC'} }, DGM->( IndexKey(1)) )
oModel:SetRelation( 'DGGDETAIL', { { 'DGG_FILIAL', 'xFilial( "DGG" )' }, { 'DGG_CDACDV', 'DG0_CDACDV' }, { 'DGG_NRVRAC', 'DG0_NRVRAC'} }, DGG->( IndexKey(1)) )
oModel:SetRelation( 'DG5DETAIL', { { 'DG5_FILIAL', 'xFilial( "DG5" )' }, { 'DG5_CDACDV', 'DG0_CDACDV' }, { 'DG5_NRVRAC', 'DG0_NRVRAC'} }, DG5->( IndexKey(1)) )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0004 ) //'Modelo de Dados Preço Novo Produto'

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'DG0MASTER' ):SetDescription( STR0005 ) // 'Dados da Versão'
oModel:GetModel( 'DG1DETAIL' ):SetDescription( STR0006 ) // 'Dados da Estrutura da Versão'
oModel:GetModel( 'DG9DETAIL' ):SetDescription( STR0007 ) // 'Dados da Operação da Versão'
oModel:GetModel( 'DG6DETAIL' ):SetDescription( STR0008 ) // 'Dados do Tutorial da Versão'
oModel:GetModel( 'DGJDETAIL' ):SetDescription( STR0009 ) // 'Dados do Critério da Versão'
oModel:GetModel( 'DGMDETAIL' ):SetDescription( STR0010 ) // 'Dados do Desenho da Versão'
oModel:GetModel( 'DGGDETAIL' ):SetDescription( STR0011 ) // 'Dados do Atributo Extra'
oModel:GetModel( 'DG5DETAIL' ):SetDescription( STR0012 ) // 'Dados do Custo'

// Indica que é opcional ter dados informados na Grid
oModel:GetModel( 'DG1DETAIL' ):SetOptional(.T.)
oModel:GetModel( 'DG9DETAIL' ):SetOptional(.T.)
oModel:GetModel( 'DG6DETAIL' ):SetOptional(.T.)
oModel:GetModel( 'DGJDETAIL' ):SetOptional(.T.)
oModel:GetModel( 'DGMDETAIL' ):SetOptional(.T.)
oModel:GetModel( 'DGGDETAIL' ):SetOptional(.T.)
oModel:GetModel( 'DG5DETAIL' ):SetOptional(.T.)

// Liga o controle de nao repeticao de linha
oModel:GetModel( 'DG6DETAIL' ):SetNoInsertLine()
If !IsInCallStack('DPRA330')
	oModel:GetModel( 'DG1DETAIL' ):SetUniqueLine( { 'DG1_CDMT', 'DG1_CDMTDV', 'DG1_NRVRAC' } )
EndIf
oModel:GetModel( 'DGMDETAIL' ):SetUniqueLine( { 'DGM_CDDR' } )
oModel:GetModel( 'DGJDETAIL' ):SetUniqueLine( { 'DGJ_CDJZ' } )
oModel:GetModel( 'DGGDETAIL' ):SetUniqueLine( { 'DGG_DSAB' } )
oModel:GetModel( 'DG5DETAIL' ):SetUniqueLine( { 'DG5_TPCS', 'DG5_TPVLCS', 'DG5_CDMY' } )

// Caso esteja integrando com o Datasul, torna o campo obrigatório
If DPRIntegra() == 1
	oModel:GetModel( 'DG9DETAIL' ):GetStruct():SetProperty( 'DG9_CDCETR',  MODEL_FIELD_OBRIGAT,  .T. )
Else
	oModel:GetModel( 'DG0MASTER' ):GetStruct():SetProperty( 'DG0_CDES'  ,  MODEL_FIELD_OBRIGAT,  .T. )
	oModel:GetModel( 'DG9DETAIL' ):GetStruct():SetProperty( 'DG9_CDMQ'  ,  MODEL_FIELD_OBRIGAT,  .F. )
EndIf

Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel     := FWLoadModel( 'DPRC321' )
// Cria a estrutura a ser usada na View
Local oStructDG0 := FWFormStruct( 2, 'DG0' )
Local oStructDG1 := FWFormStruct( 2, 'DG1' )
Local oStructDG9 := FWFormStruct( 2, 'DG9' )
Local oStructDG6 := FWFormStruct( 2, 'DG6' )
Local oStructDGJ := FWFormStruct( 2, 'DGJ' )
Local oStructDGM := FWFormStruct( 2, 'DGM' )
Local oStructDGG := FWFormStruct( 2, 'DGG' )
Local oStructDG5 := FWFormStruct( 2, 'DG5' )

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

// Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_DG0', oStructDG0, 'DG0MASTER' )

// Adiciona no nosso View um controle do tipo FormGrid (antiga newgetdados)
oView:AddGrid(  'VIEW_DG1', oStructDG1, 'DG1DETAIL' )
oView:AddGrid(  'VIEW_DG9', oStructDG9, 'DG9DETAIL' )
oView:AddGrid(  'VIEW_DG6', oStructDG6, 'DG6DETAIL' )
oView:AddGrid(  'VIEW_DGJ', oStructDGJ, 'DGJDETAIL' )
If DPRIntegra() == 2
	oView:AddGrid(  'VIEW_DGM', oStructDGM, 'DGMDETAIL' )
EndIf
oView:AddGrid(  'VIEW_DGG', oStructDGG, 'DGGDETAIL' )
oView:AddGrid(  'VIEW_DG5', oStructDG5, 'DG5DETAIL' )

// Cria um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 60 )
oView:CreateHorizontalBox( 'INFERIOR', 40 )

// Cria Folder na view
oView:CreateFolder( 'FOLDER', 'INFERIOR' )

// Cria pastas nas folders
oView:AddSheet( 'FOLDER', 'TAB01', STR0013 )   // 'Estrutura'
oView:AddSheet( 'FOLDER', 'TAB02', STR0014 )   // 'Operação'
oView:AddSheet( 'FOLDER', 'TAB03', STR0015 )   // 'Tutorial'
oView:AddSheet( 'FOLDER', 'TAB04', STR0016 )   // 'Critério'
If DPRIntegra() == 2
	oView:AddSheet( 'FOLDER', 'TAB05', STR0017 )   // 'Desenho'
EndIf
oView:AddSheet( 'FOLDER', 'TAB06', STR0018 )   // 'Atributo'
oView:AddSheet( 'FOLDER', 'TAB07', STR0019 )   // 'Custos'

// Cria um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'DG1', 100, , ,'FOLDER', 'TAB01' )
oView:CreateHorizontalBox( 'DG9', 100, , ,'FOLDER', 'TAB02' )
oView:CreateHorizontalBox( 'DG6', 100, , ,'FOLDER', 'TAB03' )
oView:CreateHorizontalBox( 'DGJ', 100, , ,'FOLDER', 'TAB04' )
If DPRIntegra() == 2
	oView:CreateHorizontalBox( 'DGM', 100, , ,'FOLDER', 'TAB05' )
EndIf
oView:CreateHorizontalBox( 'DGG', 100, , ,'FOLDER', 'TAB06' )
oView:CreateHorizontalBox( 'DG5', 100, , ,'FOLDER', 'TAB07' )

// Relaciona o ID da View com o 'box' para exibicao
oView:SetOwnerView( 'VIEW_DG0', 'SUPERIOR' )
oView:SetOwnerView( 'VIEW_DG1', 'DG1' )
oView:SetOwnerView( 'VIEW_DG9', 'DG9' )
oView:SetOwnerView( 'VIEW_DG6', 'DG6' )
oView:SetOwnerView( 'VIEW_DGJ', 'DGJ' )
If DPRIntegra() == 2
	oView:SetOwnerView( 'VIEW_DGM', 'DGM' )
EndIf
oView:SetOwnerView( 'VIEW_DGG', 'DGG' )
oView:SetOwnerView( 'VIEW_DG5', 'DG5' )

// Remove os campos repetidos da tela
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
	oStructDG0:RemoveField( 'DG0_DSPJ'   )
	oStructDG0:RemoveField( 'DG0_CDEDT'  )
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
oStructDG1:SetProperty( 'DG1_NRSQ'  , MVC_VIEW_CANCHANGE, .F. )
oStructDG1:SetProperty( 'DG1_QTUT'  , MVC_VIEW_CANCHANGE, .F. )
oStructDG9:SetProperty( 'DG9_CDAT'  , MVC_VIEW_CANCHANGE, .F. )
oStructDG0:SetProperty( 'DG0_VLPJDV', MVC_VIEW_CANCHANGE, .F. )

Return oView

//-------------------------------------------------------------------
// DPRC321PAR - Parametros para calculo de ROI
//-------------------------------------------------------------------
Function DPRC321PAR()
Local lRet := .T.

if Pergunte('DPRC321A')
	oBrowse:SetFilterDefault( "DG0_CDACDV >= '" + MV_PAR01 + "' .AND. DG0_CDACDV <= '" + MV_PAR03 +;
	                  "' .AND. DG0_NRVRAC >= '" + MV_PAR02 + "' .AND. DG0_NRVRAC <= '" + MV_PAR04 + "'" )

	DPRC321OK()
	lRet := .T.
Else
	lRet := .F.
Endif

Return lRet

//-------------------------------------------------------------------
// DPRC321OK - Realiza o calculo
//-------------------------------------------------------------------
Function DPRC321OK()
Local lRet       := .T.
Local nResProj   := 0
Local nResInv    := 0
Local cLogUpdate := ''
Local nI         := 0
Local cArquiv	 := ''
Local aAux       := {}
Local aArea, aAreaSX3
Local oTabBrw
Private aCampos  := {}
Private aTabela
Private cTabBrw  := ''
Private aCabExcel := {}

AADD(aCabExcel, {STR0052, "C", TamSx3('DG0_CDACDV')[1], 0}) // PRODUTO DESENVOLVIDO
AADD(aCabExcel, {STR0053, "C", TamSx3('DG0_NRVRAC')[1], 0}) // VERSÃO
AADD(aCabExcel, {STR0054, "C", TamSx3('DG0_DSFOUT')[1], 0}) // FÓRMULA INVESTIMENTO
AADD(aCabExcel, {STR0055, "C", TamSx3('DG0_DSFOPJ')[1], 0}) // FÓRMULA PROJETO
AADD(aCabExcel, {STR0069, "C", TamSx3('DG0_DSFOCS')[1], 0}) // FÓRMULA custo diverso

aAux := TamSx3('DG0_VLTXUT')
AADD(aCabExcel, {STR0068, "N", aAux[1], aAux[2]}) // roi

aAux := TamSx3('DG0_VLCSPO')
AADD(aCabExcel, {STR0056, "N", aAux[1], aAux[2]}) // $ CUSTO FABRICAÇÃO

aAux := TamSx3('DG0_VLCS')
AADD(aCabExcel, {STR0057, "N", aAux[1], aAux[2]}) // $ CUSTOS DIVERSOS

aAux := TamSx3('DG0_VLUT')
AADD(aCabExcel, {STR0058, "N", aAux[1], aAux[2]}) // $ INVESTIMENTO

aAux := TamSx3('DG0_VLPR')
AADD(aCabExcel, {STR0059, "N", aAux[1], aAux[2]}) // $ PREÇO-TETO

aAux := TamSx3('DG0_VLPJ')
AADD(aCabExcel, {STR0060, "N", aAux[1], aAux[2]}) // $ PROJETO

aAux := TamSx3('DG0_VLPJDV')
AADD(aCabExcel, {STR0061, "N", aAux[1], aAux[2]}) // $ PROJETO DESENVOLVIMENTO

aAux := TamSx3('DG0_VLRS')
AADD(aCabExcel, {STR0062, "N", aAux[1], aAux[2]}) // $ RETORNO ESPERADO

AADD(aCabExcel, {STR0063, "C", 250, 4}) // OBSERVAÇÃO
AADD(aCabExcel, {""     , "N",  14, 4})

aTabela := DPRC321TAB(aCabExcel)
oTabBrw := SFCCriFWTa(aTabela)
cTabBrw := oTabBrw:GetAlias()

dbSelectArea( 'DG0' )
DG0->(dbSetOrder(1))
DG0->(dbGoTop())
While DG0->(!EOF())

	if DG0->DG0_CDACDV >= MV_PAR01 .AND. DG0->DG0_CDACDV <= MV_PAR03 .AND.;
	   DG0->DG0_NRVRAC >= MV_PAR02 .AND. DG0->DG0_NRVRAC <= MV_PAR04

		cLogUpdate := ''

		if Empty(DG0->DG0_DSFOPJ)
			cLogUpdate += STR0036 + " - " // Fórmula Projeto está vazia
		Endif

		if DG0->DG0_VLCSPO <= 0
			cLogUpdate += STR0037 + " - " // Custo Fabricação Inválido
		Endif

		if Empty(DG0->DG0_DSFOUT)
			cLogUpdate += STR0038 + " - " // Não existe fórmula de investimento.
		Endif

		if DG0->DG0_VLRS == 0
			cLogUpdate += STR0039 + " - " // Não existe retorno esperado informado
		Endif

		aCampos := DPRXARRDG0(.F.)

		// Projeto
		nResProj := DPRC321PRO(DG0->DG0_DSFOPJ, DG0->DG0_VLPJDV)

		// Investimento
		nResInv  := DPRC321INV(DG0->DG0_DSFOUT, DG0->DG0_VLUT)

		// ------------- ROI ----------------
		aArea    := GetArea()

		cROI := Alltrim(GetSx3Cache('DG0_VLTXUT','X3_INIBRW'))

		RestArea(aArea)
		// ----------------------------------

		RecLock(cTabBrw, .T.)
		(cTabBrw)->PRODUTO := DG0->DG0_CDACDV
		(cTabBrw)->VERSAO  := DG0->DG0_NRVRAC
		(cTabBrw)->FORMPRO := DG0->DG0_DSFOPJ
		(cTabBrw)->FORMINV := DG0->DG0_DSFOUT
		(cTabBrw)->FORMCUS := DG0->DG0_DSFOCS
		(cTabBrw)->ROI     := &cROI
		(cTabBrw)->INVEST  := nResInv
		(cTabBrw)->PROJDES := nResProj

		For nI := 1 to Len(aCampos)
			Do Case
				Case aCampos[nI][2] == '[DG0_VLCSPO]'
					(cTabBrw)->FABRIC  := aCampos[nI][3]
				Case aCampos[nI][2] == '[DG0_VLCS]'
					(cTabBrw)->DIVER   := aCampos[nI][3]
				Case aCampos[nI][2] == '[DG0_VLPR]'
					(cTabBrw)->TETO    := aCampos[nI][3]
				Case aCampos[nI][2] == '[DG0_VLPJ]'
					(cTabBrw)->PROJETO := aCampos[nI][3]
				Case aCampos[nI][2] == '[DG0_VLRS]'
					(cTabBrw)->ESPER   := aCampos[nI][3]
			End Case
		Next

		cLogUpdate += STR0040 // CALCULADO COM SUCESSO

		(cTabBrw)->OBS := cLogUpdate

		MsUnlock()

		RecLock('DG0', .F.)
		DG0->DG0_VLPJDV := nResProj // Valor Projeto
		DG0->DG0_VLUT   := nResInv  // Valor Investimento
		MsUnLock()
	Endif

	DG0->(dbSkip())
End

DG0->(dbGoTop())

DPRC321EXL()

oTabBrw:Delete()

Return lRet

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} DPRXARRDG0
Função que cria um array com os campos da tabela DG0

@author Samantha Preima
@since 23/01/2013
@version 1.0
/*///------------------------------------------------------------------------------------------------
Function DPRXARRDG0(lRecebe, nValor)
Local aArray := { }
Local nI     := 0

aAdd( aArray, { ALLTRIM(GetSx3Cache('DG0_VLPJDV','X3_DESCRIC')), "[DG0_VLPJDV]" } )
aAdd( aArray, { ALLTRIM(GetSx3Cache('DG0_VLCSPO','X3_DESCRIC')), "[DG0_VLCSPO]" } )
aAdd( aArray, { ALLTRIM(GetSx3Cache('DG0_VLCS'  ,'X3_DESCRIC')), "[DG0_VLCS]" } )
aAdd( aArray, { ALLTRIM(GetSx3Cache('DG0_VLRS'  ,'X3_DESCRIC')), "[DG0_VLRS]" } )
aAdd( aArray, { ALLTRIM(GetSx3Cache('DG0_VLPR'  ,'X3_DESCRIC')), "[DG0_VLPR]" } )
aAdd( aArray, { ALLTRIM(GetSx3Cache('DG0_VLUT'  ,'X3_DESCRIC')), "[DG0_VLUT]" } )
aAdd( aArray, { ALLTRIM(GetSx3Cache('DG0_VLPJ'  ,'X3_DESCRIC')), "[DG0_VLPJ]" } )

For nI := 1 to Len(aArray)
	if lRecebe .AND. aArray[nI][2] == '[DG0_VLPJ]'
		AADD(aArray[nI], nValor)
	Else
		AADD(aArray[nI], &("DG0->" + Substr(aArray[nI][2],2,Len(aArray[nI][2]) - 2)))
	Endif
Next

Return aArray

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRXTraduc
Realiza a tradução de um texto, trocando os código pelos valores
correspondentes.

@param cMensagem 	Mensagem a ser traduzida
@param aCampos  	Array com os códigos e suas traduções

@return cMensagem	Mensagem traduzida

@author Samantha Preima
@since 23/01/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function DPRXTraduc(cMensagem, aCampos)
Local nI 	 := 0
Local cValor := ''

For nI := 1 to Len(aCampos)
	cValor := STR(aCampos[nI][3])

	cMensagem := STRTRAN(cMensagem,aCampos[nI][2],ALLTRIM(cValor))
Next

Return cMensagem

//-------------------------------------------------------------------
// Calcula projeto
//-------------------------------------------------------------------
Function DPRC321PRO(cFormula, nValor)
Local nProj  := 0
Local cResult := ''

cResult  := DPRXTraduc(cFormula, aCampos)
if Empty(cResult)
	nProj := nValor
Else
	nProj := &cResult
Endif

Return nProj

//-------------------------------------------------------------------
// Calcula Investimento
//-------------------------------------------------------------------
Function DPRC321INV(cFormula, nInvest)
Local nValor  := 0
Local cResult := ''

cResult  := DPRXTraduc(cFormula, aCampos)
if Empty(cResult)
	nValor := nInvest
Else
	nValor := &cResult
Endif

Return nValor

//-------------------------------------------------------------------
// Calcula Custos Diversos
//-------------------------------------------------------------------
Function DPRC321DIV(cFormula, nDiv)
Local nValor  := 0
Local cResult := ''

cResult  := DPRXTraduc(cFormula, aCampos)
if Empty(cResult)
	nValor := nDiv
Else
	nValor := &cResult
Endif

Return nValor

//-------------------------------------------------------------------
// DPRC323TAB - Define a tabela a ser utilizada no browsw
//-------------------------------------------------------------------
Static Function DPRC321TAB(aCabExcel)
Local aDBF := {}
Local nI   := 0

aDBF := { { "PRODUTO", "", 0, 0, STR0041, .T., "@!" } , ; // Produto Desenvolvido
		  { "VERSAO" , "", 0, 0, STR0042, .T., x3picture('DG0_NRVRAC') } , ; // Versão
		  { "FORMINV", "", 0, 0, STR0051, .T., x3picture('DG0_DSFOUT') } , ; // Fórmula Investimento
  		  { "FORMPRO", "", 0, 0, STR0050, .T., x3picture('DG0_DSFOPJ') } , ; // Fórmula Projeto
  		  { "FORMCUS", "", 0, 0, STR0069, .T., x3picture('DG0_DSFOCS') } , ; // custos diversos
  		  { "ROI"    , "", 0, 0, STR0068, .T., x3picture('DG0_VLTXUT') } , ; // roi
		  { "FABRIC" , "", 0, 0, STR0043, .T., x3picture('DG0_VLCSPO') } , ; // Valor Custo Fabricação
		  { "DIVER"  , "", 0, 0, STR0044, .T., x3picture('DG0_VLCS') }   , ; // Valor Custos Diversos
		  { "INVEST" , "", 0, 0, STR0045, .T., x3picture('DG0_VLUT') }   , ; // Valor Investimento
		  { "TETO"   , "", 0, 0, STR0046, .T., x3picture('DG0_VLPR') }   , ; // Valor Preço-Teto
		  { "PROJETO", "", 0, 0, STR0047, .T., x3picture('DG0_VLPJ') }   , ; // Valor Projeto
		  { "PROJDES", "", 0, 0, STR0048, .T., x3picture('DG0_VLPJDV') } , ; // Valor Projeto Desenvolvimento
		  { "ESPER"  , "", 0, 0, STR0049, .T., x3picture('DG0_VLRS') } ,   ; // Valor Retorno Esperado
		  { "OBS"    , "", 0, 0, STR0052, .T., "@!" } } // Observação

For nI := 1 to Len(aCabExcel) - 1
	aDBF[nI][2] := aCabExcel[nI][2]
	aDBF[nI][3] := aCabExcel[nI][3]
	aDBF[nI][4] := aCabExcel[nI][4]
Next

Return { aDBF , {"PRODUTO", "VERSAO"} }

//-------------------------------------------------------------------
// DPRC323EXL - Gera Excel
//-------------------------------------------------------------------
Static Function DPRC321EXL()
Local aItensExcel := {}
Local aItem       := {}
Local aCols       := {}
Local lExcel      := ApOleClient("MsExcel")
Local cLog        := ''
Local aAux        := ''

if !lExcel
	cLog := STR0052 + ';' + ; // PRODUTO DESENVOLVIDO
	        STR0053 + ';' + ; // VERSÃO
	        STR0054 + ';' + ; // FÓRMULA INVESTIMENTO
	        STR0055 + ';' + ; // FÓRMULA PROJETO
	        STR0069 + ';' + ; // formula diversos
	        STR0068 + ';' + ; // roi
	        STR0056 + ';' + ; // $ CUSTO FABRICAÇÃO
	        STR0057 + ';' + ; // $ CUSTOS DIVERSOS
	        STR0058 + ';' + ; // $ INVESTIMENTO
	        STR0059 + ';' + ; // $ PREÇO-TETO
	        STR0060 + ';' + ; // $ PROJETO
	        STR0061 + ';' + ; // $ PROJETO DESENVOLVIMENTO
	        STR0062 + ';' + ; // $ RETORNO ESPERADO
	        STR0063 + PULALINHA // OBSERVAÇÃO
Endif

dbSelectArea(cTabBrw)
(cTabBrw)->(dbGoTop())
While (cTabBrw)->(!EOF())

	if lExcel
		aItem := Array(Len(aCabExcel))

		aItem[1]  := (cTabBrw)->PRODUTO
		aItem[2]  := (cTabBrw)->VERSAO
		aItem[3]  := (cTabBrw)->FORMINV
		aItem[4]  := (cTabBrw)->FORMPRO
		aItem[5]  := (cTabBrw)->FORMCUS
		aItem[6]  := (cTabBrw)->ROI
		aItem[7]  := (cTabBrw)->FABRIC
		aItem[8]  := (cTabBrw)->DIVER
		aItem[9]  := (cTabBrw)->INVEST
		aItem[10] := (cTabBrw)->TETO
		aItem[11] := (cTabBrw)->PROJETO
		aItem[12] := (cTabBrw)->PROJDES
		aItem[13] := (cTabBrw)->ESPER
		aItem[14] := (cTabBrw)->OBS

		AADD(aCols,aItem)
		aItem := {}
	Else
		cLog += ALLTRIM((cTabBrw)->PRODUTO)      + ';' + ;
				ALLTRIM((cTabBrw)->VERSAO)       + ';' + ;
				ALLTRIM((cTabBrw)->FORMINV)      + ';' + ;
				ALLTRIM((cTabBrw)->FORMPRO)      + ';' + ;
				Alltrim((cTabBrw)->FORMCUS)      + ';' + ;
	   			AllTrim((cTabBrw)->ROI)    		 + ';' + ;
				ALLTRIM(STR((cTabBrw)->FABRIC))  + ';' + ;
				ALLTRIM(STR((cTabBrw)->DIVER))   + ';' + ;
				ALLTRIM(STR((cTabBrw)->INVEST))  + ';' + ;
				ALLTRIM(STR((cTabBrw)->TETO))    + ';' + ;
				ALLTRIM(STR((cTabBrw)->PROJETO)) + ';' + ;
				ALLTRIM(STR((cTabBrw)->PROJDES)) + ';' + ;
				ALLTRIM(STR((cTabBrw)->ESPER))   + ';' + ;
				ALLTRIM((cTabBrw)->OBS)          + ';' + ;
				PULALINHA
	Endif

	(cTabBrw)->(dbSkip())
End

if lExcel
	MsgRun(STR0064, STR0065,{||DlgToExcel({{"GETDADOS",STR0066,aCabExcel,aCols}})}) // Favor Aguardar.. ## Exportando os Registros para o Arquivo ## Detalhe Retorno Sobre Investimento
Else
	MemoWrite('c:\ROI.CSV', cLog)
	DPRXError('DPRC321',STR0067 + 'c:\ROI.CSV',2)
Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} DPRC321POS
Realiza a pos-validacao dos dados da tela
/*/
//-------------------------------------------------------------------
Function DPRC321POS( oModel )
Local lRet := .T.

Return lRet