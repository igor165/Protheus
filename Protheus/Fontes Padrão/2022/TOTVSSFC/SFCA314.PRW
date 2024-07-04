#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWADAPTEREAI.CH'
#INCLUDE 'SFCA314.CH'

#DEFINE NEWLINE CHR(13)+CHR(10)
#DEFINE 314NE_a "CYV_QTTERP/CYV_QTTEEX/CYV_QTTEOE/CYV_LGRPPO/CYV_LGLBCQ/CYV_LGRP/CYV_LGEDRP/CYV_CDFEPO/" // Campos que n„o ser„o exibidos
#DEFINE 314NE_b "CYW_QTTEUT/CYW_QTTEEX/CYW_QTTEOE/" // Campos que n„o ser„o exibidos

//-------------------------------------------------------------------
/*/{Protheus.doc} SFCA314
Tela de cadastro de Apontamento de ProduÁ„o


@author Samantha Preima
@since 08/09/2010
@version P11
@obs Atualizado no Portal com o chamado TFDILE no dia 06/06/2012
/*/
//-------------------------------------------------------------------
Function SFCA314()
Return NIL

//-------------------------------------------------------------------
// Menu para tela de Apontamento de ProduÁ„o
//-------------------------------------------------------------------
Static Function MenuDef()
Private aRotina := {}

ADD OPTION aRotina TITLE STR0049 ACTION 'VIEWDEF.SFCA314' OPERATION 3 ACCESS 0    // 'Incluir Apontamento'
ADD OPTION aRotina TITLE STR0050 ACTION 'SFCA318ATV()'    OPERATION 3 ACCESS 0 DISABLE MENU   // 'Dispatch List'
ADD OPTION aRotina TITLE STR0051 ACTION 'SFCA313E()'      OPERATION 4 ACCESS 0 DISABLE MENU   // 'Estornar Apontamento'
ADD OPTION aRotina TITLE STR0052 ACTION 'SFCA310VIS()'    OPERATION 2 ACCESS 0 DISABLE MENU   // 'Visualizar'
ADD OPTION aRotina TITLE STR0053 ACTION 'VIEWDEF.SFCA311' OPERATION 3 ACCESS 0    // 'Apontamento de Parada'
ADD OPTION aRotina TITLE STR0054 ACTION 'VIEWDEF.SFCA312' OPERATION 3 ACCESS 0    // 'Apontamento Item Controle'
ADD OPTION aRotina TITLE STR0095 ACTION 'SFCA314LEG'      OPERATION 3 ACCESS 0 DISABLE MENU   // 'Legenda'
ADD OPTION aRotina TITLE STR0098 ACTION 'SFCA319INI()'    OPERATION 3 ACCESS 0    // 'Iniciar Apontamento'
ADD OPTION aRotina TITLE STR0099 ACTION 'SFCA310FIM()'    OPERATION 4 ACCESS 0 DISABLE MENU   // 'Finalizar Apontamento'
ADD OPTION aRotina TITLE STR0107 ACTION 'SFCA310ABA()'    OPERATION 4 ACCESS 0 DISABLE MENU   // 'Abandonar Apontamento'

//Ponto de entrada utilizado para inserir novas opcoes no array aRotina  ≥
If ExistBlock("SCA314MNU")
	ExecBlock("SCA314MNU",.F.,.F.)
EndIf

Return aRotina

//-------------------------------------------------------------------
// Model para Apontamento de ProduÁ„o
//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruCYV := FWFormStruct( 1, 'CYV', /*bAvalCampo*/,/*lViewUsado*/ ) // Apontamento
Local oStruCZP := FWFormStruct( 1, 'CZP', /*bAvalCampo*/,/*lViewUsado*/ ) // Componente
Local oStruCYW := FWFormStruct( 1, 'CYW', /*bAvalCampo*/,/*lViewUsado*/ ) // Recurso
Local oStruCY0 := FWFormStruct( 1, 'CY0', /*bAvalCampo*/,/*lViewUsado*/ ) // Refugo
Local oStruCZ0 := FWFormStruct( 1, 'CZ0', /*bAvalCampo*/,/*lViewUsado*/ ) // Ferramenta
Local oStruCZW := FWFormStruct( 1, 'CZW', /*bAvalCampo*/,/*lViewUsado*/ ) // GGF
Local oModel

oStruCYV:AddField( ;
	'Gera Parada'				,;	// 	[01]  C   Titulo do campo
	'Gera Parada'				,;	// 	[02]  C   ToolTip do campo
	"GER_PARADA"				,;	// 	[03]  C   Id do Field
	"C"							,;	// 	[04]  C   Tipo do campo
	255							,;	// 	[05]  N   Tamanho do campo
	0							,;	// 	[06]  N   Decimal do campo
	NIL							,;	// 	[07]  B   Code-block de validaÁ„o do campo
	NIL							,;	// 	[08]  B   Code-block de validaÁ„o When do campo
	{}							,;	//	[09]  A   Lista de valores permitido do campo
	.F.							,;	//	[10]  L   Indica se o campo tem preenchimento obrigatÛrio
	Nil						,;	//	[11]  B   Code-block de inicializacao do campo
	NIL							,;	//	[12]  L   Indica se trata-se de um campo chave
	NIL							,;	//	[13]  L   Indica se o campo pode receber valor em uma operaÁ„o de update.
	.T.							;	// 	[14]  L   Indica se o campo È virtual
)

oStruCYV:AddField( ;
	'Gera Par. Ant.'			,;	// 	[01]  C   Titulo do campo
	'Gera Par. Ant.'			,;	// 	[02]  C   ToolTip do campo
	"GER_PARANT"				,;	// 	[03]  C   Id do Field
	"C"							,;	// 	[04]  C   Tipo do campo
	255							,;	// 	[05]  N   Tamanho do campo
	0							,;	// 	[06]  N   Decimal do campo
	NIL							,;	// 	[07]  B   Code-block de validaÁ„o do campo
	NIL							,;	// 	[08]  B   Code-block de validaÁ„o When do campo
	{}							,;	//	[09]  A   Lista de valores permitido do campo
	.F.							,;	//	[10]  L   Indica se o campo tem preenchimento obrigatÛrio
	Nil						,;	//	[11]  B   Code-block de inicializacao do campo
	NIL							,;	//	[12]  L   Indica se trata-se de um campo chave
	NIL							,;	//	[13]  L   Indica se o campo pode receber valor em uma operaÁ„o de update.
	.T.							;	// 	[14]  L   Indica se o campo È virtual
)

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'SFCA314', /*Pre*/, { | oMdl | SFCA314POS( oMdl,1 ) }, { | oMdl | If(SFCA314CMM( oMdl ), SFCA310F12(), .F. ) } , { | oMdl | SFCA310F12() } )

// Adiciona ao modelo uma estrutura de formul·rio de ediÁ„o por campo
oModel:AddFields( 'CYVMASTER', /*cOwner*/, oStruCYV )

// Adiciona ao modelo uma estrutura de formul·rio de ediÁ„o por grid
oModel:AddGrid( 'CY0DETAIL', 'CYVMASTER', oStruCY0, { | oMdlG | SFCA314aPR ( oMdlG ) }, { | oMdlG | SFCA314aLP ( oMdlG ) }, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
oModel:AddGrid( 'CYWDETAIL', 'CYVMASTER', oStruCYW, /*bLinePre*/, { | oMdlG | SFCA314cLP ( oMdlG ) }, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
oModel:AddGrid( 'CZPDETAIL', 'CYVMASTER', oStruCZP, /*bLinePre*/, { | oMdlG | SFCA314eLP ( oMdlG ) }, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
oModel:AddGrid( 'CZ0DETAIL', 'CYVMASTER', oStruCZ0, { | oMdlG | SFCA314bPR ( oMdlG ) }, { | oMdlG | SFCA314bLP ( oMdlG ) }, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
oModel:AddGrid( 'CZWDETAIL', 'CYVMASTER', oStruCZW, /*bLinePre*/, /*bLinePos*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

// Faz relaciomaneto entre os compomentes do model
oModel:SetRelation( 'CY0DETAIL', { { 'CY0_FILIAL', 'xFilial( "CY0" )' } , { 'CY0_NRSQRP', 'CYV_NRSQRP' } } , CY0->( IndexKey(1)) )
oModel:SetRelation( 'CYWDETAIL', { { 'CYW_FILIAL', 'xFilial( "CYW" )' } , { 'CYW_NRSQRP', 'CYV_NRSQRP' } } , CYW->( IndexKey(1)) )
oModel:SetRelation( 'CZPDETAIL', { { 'CZP_FILIAL', 'xFilial( "CZP" )' } , { 'CZP_NRSQRP', 'CYV_NRSQRP' } } , CZP->( IndexKey(1)) )
oModel:SetRelation( 'CZ0DETAIL', { { 'CZ0_FILIAL', 'xFilial( "CZ0" )' } , { 'CZ0_NRSQRP', 'CYV_NRSQRP' } } , CZ0->( IndexKey(1)) )
oModel:SetRelation( 'CZWDETAIL', { { 'CZW_FILIAL', 'xFilial( "CZW" )' } , { 'CZW_NRSQRP', 'CYV_NRSQRP' } } , CZW->( IndexKey(1)) )

// Liga o controle de nao repeticao de linha
oModel:GetModel( 'CY0DETAIL' ):SetUniqueLine( { 'CY0_CDRF' } )
oModel:GetModel( 'CYWDETAIL' ):SetUniqueLine( { 'CYW_CDOE', 'CYW_CDGROE' } )
oModel:GetModel( 'CZ0DETAIL' ):SetUniqueLine( { 'CZ0_CDFE' } )
oModel:GetModel( 'CZWDETAIL' ):SetUniqueLine( { 'CZW_CDCETR' } )

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'CY0DETAIL' ):SetDescription( STR0001 ) //'Apontamento de Refugo'
oModel:GetModel( 'CYWDETAIL' ):SetDescription( STR0002 ) //'Apontamento de Recurso'
oModel:GetModel( 'CZPDETAIL' ):SetDescription( STR0003 ) //'Componentes'
oModel:GetModel( 'CZ0DETAIL' ):SetDescription( STR0004 ) //'Ferramentas'
oModel:GetModel( 'CZWDETAIL' ):SetDescription( STR0012 ) //'GGF'

// Indica que È opcional ter dados informados na Grid
oModel:GetModel( 'CY0DETAIL' ):SetOptional(.T.)
oModel:GetModel( 'CYWDETAIL' ):SetOptional(.T.)
oModel:GetModel( 'CZPDETAIL' ):SetOptional(.T.)
oModel:GetModel( 'CZ0DETAIL' ):SetOptional(.T.)
oModel:GetModel( 'CZWDETAIL' ):SetOptional(.T.)

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0005 ) //'Apontamento de ProduÁ„o'

oModel:SetVldActivate( { |oModel| SFCA314VPR( oModel ) } )
oModel:SetActivate( { |oModel| SFCA314PRE( oModel,1 ) } )

oStruCZP:SetProperty('CZP_TPST'  ,MODEL_FIELD_INIT, { || POSICIONE('CYP',1,XFILIAL('CYP')+CZP->CZP_NRORPO+CZP->CZP_IDMTOR,"CYP_TPST") } )
oStruCZP:SetProperty('CZP_NRORRE',MODEL_FIELD_INIT, { || POSICIONE('CYP',1,XFILIAL('CYP')+CZP->CZP_NRORPO+CZP->CZP_IDMTOR,'CYP_NRORRE') } )
oStruCZP:SetProperty('CZP_QTRP'  ,MODEL_FIELD_INIT, { || POSICIONE('CYP',1,XFILIAL('CYP')+CZP->CZP_NRORPO+CZP->CZP_IDMTOR,'CYP_QTRP') } )
oStruCZP:SetProperty('CZP_CDTBMT',MODEL_FIELD_INIT, { || POSICIONE('CYP',1,XFILIAL('CYP')+CZP->CZP_NRORPO+CZP->CZP_IDMTOR,'CYP_CDTBMT') } )

oStruCYV:SetProperty( 'CYV_CDMQ'  , MODEL_FIELD_WHEN, {|oModel| IF(oModel:GetOperation() == 3,.T.,IF(CYV->CYV_TPSTRP=='1', .F.,.T.))} )
oStruCYV:SetProperty( 'CYV_NRBG'  , MODEL_FIELD_WHEN, {|oModel| IF(oModel:GetOperation() == 3,.T.,IF(CYV->CYV_TPSTRP=='1', .F.,.T.))} )
oStruCYV:SetProperty( 'CYV_DTRPBG', MODEL_FIELD_WHEN, {|oModel| IF(oModel:GetOperation() == 3,.T.,IF(CYV->CYV_TPSTRP=='1', .F.,.T.))} )
oStruCYV:SetProperty( 'CYV_HRRPBG', MODEL_FIELD_WHEN, {|oModel| IF(oModel:GetOperation() == 3,.T.,IF(CYV->CYV_TPSTRP=='1', .F.,.T.))} )
oStruCYV:SetProperty( 'CYV_HCRPBG', MODEL_FIELD_WHEN, {|oModel| IF(oModel:GetOperation() == 3,.T.,IF(CYV->CYV_TPSTRP=='1', .F.,.T.))} )

Return oModel

//-------------------------------------------------------------------
// View para Apontamento de ProduÁ„o
//-------------------------------------------------------------------
Static Function ViewDef()
Local oStruCYV := FWFormStruct( 2, 'CYV', { |cCampo| !AllTrim( cCampo ) + '/' $ 314NE_a } )
Local oStruCY0 := FWFormStruct( 2, 'CY0' )
Local oStruCYW := FWFormStruct( 2, 'CYW', { |cCampo| !AllTrim( cCampo ) + '/' $ 314NE_b } )
Local oStruCZP := FWFormStruct( 2, 'CZP' )
Local oStruCZ0 := FWFormStruct( 2, 'CZ0' )
Local oStruCZW := FWFormStruct( 2, 'CZW' )
Local oModel   := FWLoadModel( 'SFCA314' )
Local oView

// CriaÁ„o de divisores
oStruCYV:AddGroup( 'Grupo01', STR0005, '', 2 ) //'Apontamento de ProduÁ„o'
oStruCYV:AddGroup( 'Grupo02', STR0006, '', 2 ) //'PreparaÁ„o'
oStruCYV:AddGroup( 'Grupo03', STR0007, '', 2 ) //'Detalhes'
oStruCYV:AddGroup( 'Grupo04', STR0008, '', 2 ) //'Consumo'
oStruCYV:AddGroup( 'Grupo05', STR0009, '', 2 ) //'Acabado'

oStruCYV:SetProperty( 'CYV_CDMQ'  , MVC_VIEW_GROUP_NUMBER, 'Grupo01' )
oStruCYV:SetProperty( 'CYV_DSMQ'  , MVC_VIEW_GROUP_NUMBER, 'Grupo01' )
oStruCYV:SetProperty( 'CYV_NRORPO', MVC_VIEW_GROUP_NUMBER, 'Grupo01' )
oStruCYV:SetProperty( 'CYV_IDAT'  , MVC_VIEW_GROUP_NUMBER, 'Grupo01' )
oStruCYV:SetProperty( 'CYV_IDATQO', MVC_VIEW_GROUP_NUMBER, 'Grupo01' )
oStruCYV:SetProperty( 'CYV_CDAT'  , MVC_VIEW_GROUP_NUMBER, 'Grupo01' )
oStruCYV:SetProperty( 'CYV_DSAT'  , MVC_VIEW_GROUP_NUMBER, 'Grupo01' )
oStruCYV:SetProperty( 'CYV_CDACRP', MVC_VIEW_GROUP_NUMBER, 'Grupo01' )
oStruCYV:SetProperty( 'CYV_DSAC'  , MVC_VIEW_GROUP_NUMBER, 'Grupo01' )
oStruCYV:SetProperty( 'CYV_NRRPET', MVC_VIEW_GROUP_NUMBER, 'Grupo01' )

// PreparaÁ„o
oStruCYV:SetProperty( 'CYV_DTBGSU', MVC_VIEW_GROUP_NUMBER, 'Grupo02' )
oStruCYV:SetProperty( 'CYV_HRBGSU', MVC_VIEW_GROUP_NUMBER, 'Grupo02' )
oStruCYV:SetProperty( 'CYV_HCBGSU', MVC_VIEW_GROUP_NUMBER, 'Grupo02' )
oStruCYV:SetProperty( 'CYV_DTEDSU', MVC_VIEW_GROUP_NUMBER, 'Grupo02' )
oStruCYV:SetProperty( 'CYV_HREDSU', MVC_VIEW_GROUP_NUMBER, 'Grupo02' )
oStruCYV:SetProperty( 'CYV_HCEDSU', MVC_VIEW_GROUP_NUMBER, 'Grupo02' )
oStruCYV:SetProperty( 'CYV_CDSU'  , MVC_VIEW_GROUP_NUMBER, 'Grupo02' )
oStruCYV:SetProperty( 'CYV_DSSU'  , MVC_VIEW_GROUP_NUMBER, 'Grupo02' )

// Detalhes
oStruCYV:SetProperty( 'CYV_NRBG'  , MVC_VIEW_GROUP_NUMBER, 'Grupo03' )
oStruCYV:SetProperty( 'CYV_NRED'  , MVC_VIEW_GROUP_NUMBER, 'Grupo03' )
oStruCYV:SetProperty( 'CYV_QTATRP', MVC_VIEW_GROUP_NUMBER, 'Grupo03' )
oStruCYV:SetProperty( 'CYV_VLPNRY', MVC_VIEW_GROUP_NUMBER, 'Grupo03' )
oStruCYV:SetProperty( 'CYV_QTATRF', MVC_VIEW_GROUP_NUMBER, 'Grupo03' )
oStruCYV:SetProperty( 'CYV_QTATRT', MVC_VIEW_GROUP_NUMBER, 'Grupo03' )
oStruCYV:SetProperty( 'CYV_QTATAP', MVC_VIEW_GROUP_NUMBER, 'Grupo03' )
oStruCYV:SetProperty( 'CYV_DTRPBG', MVC_VIEW_GROUP_NUMBER, 'Grupo03' )
oStruCYV:SetProperty( 'CYV_HRRPBG', MVC_VIEW_GROUP_NUMBER, 'Grupo03' )
oStruCYV:SetProperty( 'CYV_HCRPBG', MVC_VIEW_GROUP_NUMBER, 'Grupo03' )
oStruCYV:SetProperty( 'CYV_DTRPED', MVC_VIEW_GROUP_NUMBER, 'Grupo03' )
oStruCYV:SetProperty( 'CYV_HRRPED', MVC_VIEW_GROUP_NUMBER, 'Grupo03' )
oStruCYV:SetProperty( 'CYV_HCRPED', MVC_VIEW_GROUP_NUMBER, 'Grupo03' )
oStruCYV:SetProperty( 'CYV_HRTERP', MVC_VIEW_GROUP_NUMBER, 'Grupo03' )
oStruCYV:SetProperty( 'CYV_CDTN'  , MVC_VIEW_GROUP_NUMBER, 'Grupo03' )
oStruCYV:SetProperty( 'CYV_DSTN'  , MVC_VIEW_GROUP_NUMBER, 'Grupo03' )
oStruCYV:SetProperty( 'CYV_NRTN'  , MVC_VIEW_GROUP_NUMBER, 'Grupo03' )
oStruCYV:SetProperty( 'CYV_DTRP'  , MVC_VIEW_GROUP_NUMBER, 'Grupo03' )
oStruCYV:SetProperty( 'CYV_HRRP'  , MVC_VIEW_GROUP_NUMBER, 'Grupo03' )
oStruCYV:SetProperty( 'CYV_HCRP'  , MVC_VIEW_GROUP_NUMBER, 'Grupo03' )
oStruCYV:SetProperty( 'CYV_NRDO'  , MVC_VIEW_GROUP_NUMBER, 'Grupo03' )
oStruCYV:SetProperty( 'CYV_NRSR'  , MVC_VIEW_GROUP_NUMBER, 'Grupo03' )
oStruCYV:SetProperty( 'CYV_NRSQRP', MVC_VIEW_GROUP_NUMBER, 'Grupo03' )

// Consumo
oStruCYV:SetProperty( 'CYV_LGLCOT', MVC_VIEW_GROUP_NUMBER, 'Grupo04' )
oStruCYV:SetProperty( 'CYV_CDDPOT', MVC_VIEW_GROUP_NUMBER, 'Grupo04' )
oStruCYV:SetProperty( 'CYV_CDLCOT', MVC_VIEW_GROUP_NUMBER, 'Grupo04' )

// Acabado
oStruCYV:SetProperty( 'CYV_CDDP'  , MVC_VIEW_GROUP_NUMBER, 'Grupo05' )
oStruCYV:SetProperty( 'CYV_CDLC'  , MVC_VIEW_GROUP_NUMBER, 'Grupo05' )
oStruCYV:SetProperty( 'CYV_CDLOSR', MVC_VIEW_GROUP_NUMBER, 'Grupo05' )
oStruCYV:SetProperty( 'CYV_DTVDLO', MVC_VIEW_GROUP_NUMBER, 'Grupo05' )
oStruCYV:SetProperty( 'CYV_CDRE'  , MVC_VIEW_GROUP_NUMBER, 'Grupo05' )

oStruCYV:SetProperty( "CYV_NRRPET", MVC_VIEW_CANCHANGE ,.F.)
oStruCYV:SetProperty( "CYV_CDACRP", MVC_VIEW_CANCHANGE ,.F.)
oStruCYV:SetProperty( "CYV_NRORPO", MVC_VIEW_CANCHANGE ,.F.)
oStruCYV:SetProperty( "CYV_IDAT"  , MVC_VIEW_CANCHANGE ,.F.)
oStruCYV:SetProperty( "CYV_CDAT"  , MVC_VIEW_CANCHANGE ,.F.)
oStruCYV:SetProperty( "CYV_IDATQO", MVC_VIEW_CANCHANGE ,.F.)

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados ser· utilizado
oView:SetModel( oModel )

// Para nao reabrir a tela, apÛs salvar registro
oView:SetCloseOnOk({||.T.})

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_CYV', oStruCYV, 'CYVMASTER' )

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid( 'VIEW_CY0' , oStruCY0, 'CY0DETAIL' )
oView:AddGrid( 'VIEW_CYW' , oStruCYW, 'CYWDETAIL' )
oView:AddGrid( 'VIEW_CZP' , oStruCZP, 'CZPDETAIL' )
oView:AddGrid( 'VIEW_CZ0' , oStruCZ0, 'CZ0DETAIL' )
oView:AddGrid( 'VIEW_CZW' , oStruCZW, 'CZWDETAIL' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'APONT'   , 60 )
oView:CreateHorizontalBox( 'INFERIOR', 40 )

// Cria Folder na view
oView:CreateFolder( 'PASTAS', 'INFERIOR' )

// Cria pastas nas folders
oView:AddSheet( 'PASTAS', 'ABA01', STR0003) //'Componentes'
oView:AddSheet( 'PASTAS', 'ABA02', STR0011) //'Refugos'
oView:AddSheet( 'PASTAS', 'ABA03', STR0010) //'Recursos'
oView:AddSheet( 'PASTAS', 'ABA04', STR0004) //'Ferramentas'
oView:AddSheet( 'PASTAS', 'ABA05', STR0012) //'GGF'

// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'COMPO'  , 100,,, 'PASTAS', 'ABA01' )
oView:CreateHorizontalBox( 'REFUG'  , 100,,, 'PASTAS', 'ABA02' )
oView:CreateHorizontalBox( 'RECUR'  , 100,,, 'PASTAS', 'ABA03' )
oView:CreateHorizontalBox( 'FERRA'  , 100,,, 'PASTAS', 'ABA04' )
oView:CreateHorizontalBox( 'GGF'    , 100,,, 'PASTAS', 'ABA05' )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_CYV' , 'APONT' )
oView:SetOwnerView( 'VIEW_CZP' , 'COMPO' )
oView:SetOwnerView( 'VIEW_CYW' , 'RECUR' )
oView:SetOwnerView( 'VIEW_CY0' , 'REFUG' )
oView:SetOwnerView( 'VIEW_CZ0' , 'FERRA' )
oView:SetOwnerView( 'VIEW_CZW' , 'GGF'   )

//Remove o campo repetido em tela
oStruCY0:RemoveField("CY0_NRSQRP")
oStruCYW:RemoveField("CYW_NRSQRP")
oStruCYW:RemoveField("CYW_IDOE")
oStruCYW:RemoveField("CYW_IDGROE")
oStruCZ0:RemoveField("CZ0_NRSQRP")
oStruCZ0:RemoveField("CZ0_IDFE")
oStruCZP:RemoveField("CZP_NRORPO")
oStruCZP:RemoveField("CZP_IDMTOR")
oStruCZP:RemoveField("CZP_NRSQRP")
oStruCZW:RemoveField("CZW_NRSQRP")
oStruCZW:RemoveField("CZW_QTTEGF")
oStruCZW:RemoveField("CYV_CDDPOT")

If GetMv("MV_SFCTPRE") == '2'
	oStruCYV:RemoveField('CYV_HRBGSU')
	oStruCYV:RemoveField('CYV_HREDSU')
	oStruCYV:RemoveField('CYV_HRRPBG')
	oStruCYV:RemoveField('CYV_HRRPED')
	oStruCYV:RemoveField('CYV_HRRP')
	oStruCYW:RemoveField('CYW_HRBGRP')
	oStruCYW:RemoveField('CYW_HREDRP')
Else
	oStruCYV:RemoveField('CYV_HCBGSU')
	oStruCYV:RemoveField('CYV_HCEDSU')
	oStruCYV:RemoveField('CYV_HCRPBG')
	oStruCYV:RemoveField('CYV_HCRPED')
	oStruCYV:RemoveField('CYV_HCRP')
	oStruCYW:RemoveField('CYW_HCBGRP')
	oStruCYW:RemoveField('CYW_HCEDRP')
EndIf

IF SFCIntegra() == 1
	oStruCYV:RemoveField('CYV_CDDPRF')
	oStruCYV:RemoveField('CYV_CDLC')
	oStruCYV:RemoveField('CYV_CDLCOT')
	oStruCYV:RemoveField('CYV_CDLCRF')
	oStruCYV:RemoveField('CYV_CDRE')
	oStruCYV:RemoveField('CYV_LGLBCQ')
	oStruCYV:RemoveField('CYV_LGLCOT')
	oStruCYV:RemoveField('CYV_NRRPET')
	oStruCYV:RemoveField('CYV_CDDPOT')

	oStruCZP:RemoveField("CZP_CDES")
	//oStruCZP:RemoveField("CZP_CDLC")
	//oStruCZP:RemoveField("CZP_CDLO")
	oStruCZP:RemoveField("CZP_CDRE")
	oStruCZP:RemoveField("CZP_CDTBMT")
Endif



oView:GetViewStruct('VIEW_CZ0'):SetProperty('CZ0_CDFE', MVC_VIEW_ORDEM , '01'  )

Return oView

//*******************************************************************************************************/
// filtros
//*******************************************************************************************************/
Function SFCA314FOP (cTipo) // Filtro Operador
Local lRet      := .T.
Local oModel    := FWMODELACTIVE()
Local oModelCYW := oModel:GetModel( 'CYWDETAIL' )

if CYC->CYC_CDMQ == M->CYV_CDMQ .AND. CYC->CYC_TPRC == cTipo .AND.;
   ( (CYC->CYC_DTBGVD <= oModelCYW:GetValue('CYW_DTBGRP') .AND. CYC->CYC_DTEDVD > oModelCYW:GetValue('CYW_DTEDRP')) .Or. ;
   	 (Empty(oModelCYW:GetValue('CYW_DTBGRP')) .AND. Empty(oModelCYW:GetValue('CYW_DTEDRP'))) )
	lRet := .T.
Else
	lRet := .F.
Endif

Return lRet

//*******************************************************************************************************/
// when
//*******************************************************************************************************/
Function SFCA314WAC(cCampo)
Local lRet      := .T.
/*Local oModel    := FWMODELACTIVE()
Local oModelCYV := oModel:GetModel( 'CYVMASTER' )
Local cNRORPO   := oModelCYV:GetValue('CYV_NRORPO')
Local cIDAT     := oModelCYV:GetValue('CYV_IDAT')
Local cCDAC     := oModelCYV:GetValue('CYV_CDACRP')
Local cTPVFIV   := ''*/
Local nInteg    := SFCIntegra()

if nInteg == 1
	lRet := .T.
/* IntegraÁ„o com datasul, n„o tem previs„o de sair.
ElseIf nInteg == 2

	dbSelectArea('CY9')
	CY9->(dbSetOrder(1))
	IF CY9->(dbSeek(xFilial('CY9')+cNRORPO+cIDAT)) .AND. CY9->CY9_NRORPO == cNRORPO .AND. CY9->CY9_IDAT == cIDAT
		IF CY9->CY9_LGATED
			lRet := .T.
		Else
			lRet := .F.
		Endif
	Endif

	if lRet
		dbSelectArea('CZ3')
		CZ3->(dbSetOrder(1))
		IF CZ3->(dbSeek(xFilial('CZ3')+cCDAC)) .AND. CZ3->CZ3_CDAC == cCDAC
			cTPVFIV := CZ3->CZ3_TPVFIV
		Endif

		Do Case // verificar
			Case cCampo == 'CDRE'
				dbSelectArea('CYQ')
				CYQ->(dbSetOrder(1))
				IF CYQ->(dbSeek(xFilial('CYQ')+cNRORPO)) .AND. CYQ->CYQ_NRORPO == cNRORPO
					if cTPVFIV == '4'
						lRet := .T.
						dbSelectArea('CYQ')
						CYQ->(dbSetOrder(1))
						IF CYQ->(dbSeek(xFilial('CYQ')+cNRORPO)) .AND. CYQ->CYQ_NRORPO == cNRORPO
							oModelCYV:SetValue('CYV_CDRE',CYQ->CYQ_CDRE)
						Endif
					Else
						lRet := .F.
					Endif
				Endif
			Case cCampo == 'CDDP'
				IF cTPVFIV == '4'
					lRet := .F.
				Else
					lRet := .T.
				Endif
			Case cCampo == 'CDLOSR'
				IF cTPVFIV == '4'
					lRet := .F.
				Else
					lRet := .T.
				Endif
			Case cCampo == 'DTVDLO'
				IF cTPVFIV == '1'
					lRet := .F.
				Else
					lRet := .T.
				Endif
			Case cCampo == 'CDLC'
				IF cTPVFIV == '4'
					lRet := .F.
				Else
					lRet := .T.
				Endif
		EndCase
	Endif*/
Endif

Return lRet

//*******************************************************************************************************/
//
//  InÌcio ValidaÁıes
//
//*******************************************************************************************************/
//-------------------------------------------------------------------
// Valida se o programa pode ser iniciado
//-------------------------------------------------------------------
Function SFCA314VPR (oModel)
Local lRet      := .T.
Local cMaquina  := ''
Local aArea     := GetArea()

If SFCA314IF(oModel, 2) .Or.  SFCA314IF(oModel, 3)
	Return lRet
EndIf

IF oModel:GetOperation() != 1

	If IsInCallStack("GeraApoOrd")
		_MaqSFC310 := _MaqSFC314
	Else

		Pergunte( 'SFCA310', .F. )
		_MaqSFC310 := MV_PAR01

	EndIf

	cMaquina := IF(Empty(CYY->CYY_CDMQ),_MaqSFC310,CYY->CYY_CDMQ)

	if !IsInCallStack('SFCA310FIM') //valida chamada pelo api de apont. fim.

		// Verifica se a ordem pode receber apontamento
		If lRet
			lRet := ValidOrdem(CYY->CYY_NRORPO)
		EndIf

		// Verifica se existe apontamento de parada em aberto
		If lRet
			lRet := SFCParAber(cMaquina, .T.)
		EndIf

		// Verifica se existe apontamento de produÁ„o em aberto para m·quina
		If lRet
			lRet := SFCApAbeMq(cMaquina)
		EndIf

		// Verifica se existe apontamento de produÁ„o em aberto para split
		If lRet
			lRet := SFCApAbeSp(CYY->CYY_NRORPO, CYY->CYY_IDAT, CYY->CYY_IDATQO)
		Endif

		If lRet
			If CYQ->CYQ_TPRPOR == "1" .And. CYY->CYY_LGCERP == .F. .And. !IsInCallStack("GeraApoOrd")
				lRet := .F.
				Help( ,, 'SFCA100', , STR0121, 1, 0)//"Este split n„o È reportado."
			EndIf
		EndIf

	Endif

	If IsInCallStack("GeraApoOrd")
		Pergunte( 'SFCA310', .F. )
		_MaqSFC310 := MV_PAR01
	EndIf

Endif

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
// ValidaÁıes do browse de refugos/retrabalhos
// Input: Model do browse
// Retorno: Se a operaÁ„o foi v·lida
//-------------------------------------------------------------------
Function SFCA314aLP(oModelGrid)
Local lRet := SFCA314CQR(oModelGrid,1)

Return lRet

//-------------------------------------------------------------------
// PreLine do browse de Refugos
// Input: Model do Grid
// Retorno: Se a operaÁ„o foi v·lida
//-------------------------------------------------------------------
Function SFCA314aPR (oModelGrid)
Local lRet := .T.
Local oModel
Default lAutomacao := .F.

If !lAutomacao
	oModel := oModelGrid:GetModel('CYVMASTER')
EndIf

IF IsInCallStack('DELETELINE') == .T. // Eliminou
	oModel:LoadValue('CYVMASTER','CYV_QTATRF',oModel:GetValue('CYVMASTER','CYV_QTATRF') - oModelGrid:GetValue('CY0_QTRF'))
	oModel:LoadValue('CYVMASTER','CYV_QTATRT',oModel:GetValue('CYVMASTER','CYV_QTATRT') - oModelGrid:GetValue('CY0_QTRT'))
Endif

if IsInCallStack('UNDELETELINE') == .T. // DesEliminou
	oModel:LoadValue('CYVMASTER','CYV_QTATRF',oModel:GetValue('CYVMASTER','CYV_QTATRF') + oModelGrid:GetValue('CY0_QTRF'))
	oModel:LoadValue('CYVMASTER','CYV_QTATRT',oModel:GetValue('CYVMASTER','CYV_QTATRT') + oModelGrid:GetValue('CY0_QTRT'))
Endif

If !lAutomacao
	oModel:LoadValue('CYVMASTER','CYV_QTATAP', MAX(oModel:GetValue('CYVMASTER','CYV_QTATRP') - oModel:GetValue('CYVMASTER','CYV_QTATRF'),0))
EndIf

Return lRet

//-------------------------------------------------------------------
// ValidaÁıes do browse de ferramentas
// Input: Model do browse
// Retorno: Se a operaÁ„o foi v·lida
//-------------------------------------------------------------------
Function SFCA314bLP( oModelGrid )
Local lRet      := .T.
Local aArea     := GetArea()
Local aAreaCYC  := CYC->( GetArea() )
Local aAreaCYH  := CYH->( GetArea() )
Local aAreaCY9  := CY9->( GetArea() )
Local oModelCYV := oModelGrid:GetModel('CYVMASTER')
Local cNRORPO   := oModelCYV:GetValue('CYVMASTER','CYV_NRORPO')
Local cIDAT     := oModelCYV:GetValue('CYVMASTER','CYV_IDAT')
Local cIDATQO   := oModelCYV:GetValue('CYVMASTER','CYV_IDATQO')
Local dIni      := oModelCYV:GetValue('CYVMASTER','CYV_DTRPBG')
Local dFim      := oModelCYV:GetValue('CYVMASTER','CYV_DTRPED')
Local cMaquina  := ''
Default lAutomacao := .F.

if IsInCallStack('SFCA318ATV')
	cMaquina := oModelGrid:GetModel('MAQMASTER'):GetValue('MAQMASTER','CYV_CDMQ')
Else
	If !lAutomacao
		cMaquina := oModelCYV:GetValue('CYVMASTER','CYV_CDMQ')
	EndIf
Endif

if !IsInCallStack('SFCA318LD')

	dbSelectArea('CYH')
	CYH->(dbSetOrder(1))
	CYH->(dbGoTop())
	If !lAutomacao
		if CYH->(dbSeek(xFilial('CYH')+'2'+oModelGrid:GetValue('CZ0_CDFE')))
			dbSelectArea('CYC')
			CYC->(dbSetOrder(1))
			CYC->(dbGoTop())
			if !CYC->(dbSeek(xFilial('CYC')+cMaquina+'2'+oModelGrid:GetValue('CZ0_CDFE')))
				SFCMsgErro(STR0015 + NEWLINE +; //"Ferramenta n„o est· relacionada ‡ m·quina informada"
						   STR0017 + cNRORPO + NEWLINE + ; //" Ordem: "
						   STR0018 + cIDAT + NEWLINE +  ; //" OperaÁ„o: "
						   STR0041 + cIDATQO, "SFCA314") // " Split: "
				lRet := .F.
			Else
				if !Empty(CYC->CYC_DTBGVD) .AND. !Empty(CYC->CYC_DTEDVD) .AND.;
			   		(CYC->CYC_DTBGVD > dIni .OR.;
			    	CYC->CYC_DTEDVD < dFim)
					SFCMsgErro(STR0016 + NEWLINE +; //"Recurso inv·lido no perÌodo informado."
							   STR0017 + cNRORPO + NEWLINE +; //" Ordem: "
						       STR0018 + cIDAT + NEWLINE + ; //" OperaÁ„o: "
						   	   STR0041 + cIDATQO, "SFCA314") // " Split: "
					lRet := .F.
				Endif
			Endif
        	RestArea(aAreaCYC)
		Endif
	EndIf
Endif

RestArea(aAreaCYC)
RestArea(aAreaCYH)
RestArea(aAreaCY9)
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
// PreLine do browse de Ferramentas
// Input: Model do Grid
// Retorno: Se a operaÁ„o foi v·lida
//-------------------------------------------------------------------
Function SFCA314bPR (oModelGrid)
Local lRet      := .T.
Local cMaquina  := ''
Local oModel    
Local aRows     := FwSaveRows()
Default lAutomacao := .F.

If !lAutomacao
	oModel    := oModelGrid:GetModel('CYVMASTER')	
EndIf

IF IsInCallStack('UNDELETELINE') .OR. IsInCallStack('DELETELINE')
	if IsInCallStack('SFCA318ATV')
		cMaquina := oModel:GetValue('MAQMASTER','CYV_CDMQ')
	Else
		cMaquina := oModel:GetValue('CYVMASTER','CYV_CDMQ')
	Endif

	IF IsInCallStack('DELETELINE')
		oModelGrid:LoadValue('CZ0_QTTEUN',0)
	Else
		dbSelectArea('CYC')
		CYC->(dbSetOrder(1))
		if CYC->(dbSeek(xFilial('CYC')+cMaquina+'2'+oModelGrid:GetValue('CZ0_CDFE')))

			dbSelectArea('CYH')
			CYH->(dbSetOrder(1))
			CYH->(dbSeek(xFilial('CYH')+'2'+oModelGrid:GetValue('CZ0_CDFE')))

			Do Case
				Case CYC->CYC_TPUNTE == '1'
					nCicloSeg := CYC->CYC_QTCI / 3600
				Case CYC->CYC_TPUNTE == '2'
					nCicloSeg := CYC->CYC_QTCI / 60
				Case CYC->CYC_TPUNTE == '3'
					nCicloSeg := CYC->CYC_QTCI
				Case CYC->CYC_TPUNTE == '4'
					nCicloSeg := CYC->CYC_QTCI / 86400
			End Case

			oModelGrid:LoadValue('CZ0_QTTEUN',INT(oModel:GetValue('CYVMASTER','CYV_QTATRP') / (CYH->CYH_QTUNCI * nCicloSeg)))
		Endif
	Endif

	// SÛ recalcula data final se for dependente de ferramenta
	dbSelectArea('CY9')
	CY9->(dbSetOrder(1))
	CY9->(dbSeek(xFilial('CY9')+CYY->CYY_NRORPO+CYY->CYY_IDAT))
	IF CY9->CY9_TPTE == '4'
		// Recalcula data final
		SFCA314DRB()
	Endif
Endif

FwRestRows(aRows)

Return lRet

//-------------------------------------------------------------------
// ValidaÁıes do browse de recursos
// Input: Model do browse
// Retorno: Se a operaÁ„o foi v·lida
//-------------------------------------------------------------------
Function SFCA314cLP( oModelGrid )
Local lRet      := .T.
Local aRetorno  := {}
Local aArea     := GetArea()
Local aAreaCYI  := CYI->( GetArea() )
Local aAreaCYB  := CYB->( GetArea() )
Local aAreaCYC  := CYC->( GetArea() )
Local aAreaCYH  := CYH->( GetArea() )
Local cMaquina  := ''
Local cNRORPO    
Local cIDAT     
Local cIDATQO   
Local lUpdLine  := .F.
Default lAutomacao := .F.

If !lAutomacao
	cNRORPO   := oModelGrid:GetModel('CYVMASTER'):GetValue('CYVMASTER','CYV_NRORPO')
	cIDAT     := oModelGrid:GetModel('CYVMASTER'):GetValue('CYVMASTER','CYV_IDAT')
	cIDATQO   := oModelGrid:GetModel('CYVMASTER'):GetValue('CYVMASTER','CYV_IDATQO')
EndIf

if IsInCallStack('SFCA318ATV')
	cMaquina := oModelGrid:GetModel('MAQMASTER'):GetValue('MAQMASTER','CYV_CDMQ')
Else
	If !lAutomacao
		cMaquina := oModelGrid:GetModel('CYVMASTER'):GetValue('CYVMASTER','CYV_CDMQ')
	EndIf
Endif

If !lAutomacao
	if !IsInCallStack('SFCA318LD') .AND. oModelGrid:IsUpdated()

		dbSelectArea('CYH')
		CYH->(dbSetOrder(2))
		if CYH->(dbSeek(xFilial('CYH')+oModelGrid:GetValue('CYW_IDOE')))
			dbSelectArea('CYC')
			CYC->(dbSetOrder(2))
			CYC->(dbGoTop())
			IF !(CYC->(dbSeek(xFilial('CYC')+cMaquina+oModelGrid:GetValue('CYW_IDOE'))))
				SFCMsgErro(STR0020 + ALLTRIM(cMaquina) + NEWLINE +; //"Recurso n„o est· relacionado ‡ m·quina "
						   STR0017 + cNRORPO + NEWLINE +; //" Ordem: "
						   STR0018 + cIDAT + NEWLINE +  ; //" OperaÁ„o: "
						   STR0041 + cIDATQO + NEWLINE +; // " Split: "
						   STR0085 + CYC->CYC_CDRC, "SFCA314") // " Recurso: "
				lRet := .F.
			Else
				if !Empty(CYC->CYC_DTBGVD) .AND. !Empty(CYC->CYC_DTEDVD) .AND.;
			   	   !(CYC->CYC_DTBGVD <= oModelGrid:GetValue('CYW_DTBGRP') .AND.;
				    CYC->CYC_DTEDVD >  oModelGrid:GetValue('CYW_DTEDRP'))
					SFCMsgErro(STR0021 + NEWLINE +; //"Recurso inv·lido no perÌodo informado. Verifique as datas de validade do Recurso no cadastro de M·quina."
						   	   STR0017 + cNRORPO + NEWLINE +; // " Ordem: "
						       STR0018 + cIDAT + NEWLINE +  ; // " OperaÁ„o: "
						       STR0041 + cIDATQO + NEWLINE +; // " Split: "
						       STR0085 + CYC->CYC_CDRC, "SFCA314") // " Recurso: "
					lRet := .F.
				Endif
			Endif

			dbSelectArea('CYB')
			CYB->(dbSetOrder(1))
			CYB->(dbGoTop())
			CYB->(dbSeek(xFilial('CYB')+cMaquina))

			if !Empty(CYH->CYH_CDARPO)
				dbSelectArea('CYI')
				CYI->(dbSetOrder(1))
				CYI->(dbGoTop())
				CYI->(dbSeek(xFilial('CYI')+CYB->CYB_CDCETR))

				if CYI->CYI_CDCETR == CYB->CYB_CDCETR .AND. CYI->CYI_CDARPO != CYH->CYH_CDARPO
					Do Case
						Case CYI->CYI_TPMOD == '2'
							SFCMsgErro(STR0022 + NEWLINE +;  //"¡rea de ProduÁ„o do operador È diferente da ¡rea de ProduÁ„o da M·quina que est· sendo reportada"
									   STR0017 + cNRORPO + NEWLINE +; // " Ordem: "
								       STR0018 + cIDAT + NEWLINE +  ; // " OperaÁ„o: "
								       STR0041 + cIDATQO + NEWLINE +; // " Split: "
							    	   STR0085 + CYC->CYC_CDRC, "SFCA314") // " Recurso: "
							lRet := .F.
						Case CYI->CYI_TPMOD == '3'
							SFCMsgErro(STR0023 + NEWLINE +;  //"¡rea de ProduÁ„o da equipe È diferente da ¡rea de ProduÁ„o da M·quina que est· sendo reportada"
									   STR0017 + cNRORPO + NEWLINE +; // " Ordem: "
								       STR0018 + cIDAT + NEWLINE +  ; // " OperaÁ„o: "
								       STR0041 + cIDATQO + NEWLINE +; // " Split: "
						    		   STR0085 + CYC->CYC_CDRC, "SFCA314") // " Recurso: "
							lRet := .F.
					Endcase
				Endif
			Endif
		Endif

		if lRet
			lUpdLine := oModelGrid:lUpdateLine
			oModelGrid:SetNoUpdateLine(.F.)

			aRetorno := SFCXTEMPOS('','',3,cMaquina,oModelGrid:GetValue('CYW_DTBGRP'),oModelGrid:GetValue('CYW_DTEDRP'),oModelGrid:GetValue('CYW_HRBGRP'),oModelGrid:GetValue('CYW_HREDRP'),.F.,'SFCA314')
			oModelGrid:LoadValue('CYW_QTTEEX', aRetorno[4])
			oModelGrid:LoadValue('CYW_QTTEUT', aRetorno[3])
			oModelGrid:LoadValue('CYW_QTTEOE', aRetorno[4] + aRetorno[3])

			oModelGrid:SetNoUpdateLine( !lUpdLine )
		Endif
	Endif
EndIf

RestArea(aArea)
RestArea(aAreaCYI)
RestArea(aAreaCYB)
RestArea(aAreaCYC)
RestArea(aAreaCYH)

Return lRet

//-------------------------------------------------------------------
// ValidaÁıes do browse de componentes
// Input: Model do browse
// Retorno: Se a operaÁ„o foi v·lida
//-------------------------------------------------------------------
Function SFCA314eLP( oModelGrid )
Local lRet     := .T.
Local aArea    := GetArea()
Local aAreaCYP := CYP->( GetArea() )
Local cNRORPO  := FwFldGet('CYV_NRORPO')
Local cIDAT    := FwFldGet('CYV_IDAT')
Local cIDATQO  := FwFldGet('CYV_IDATQO')
Default lAutomacao := .F.

If !lAutomacao
	if !IsInCallStack('SFCA318LD') .AND. oModelGrid:IsUpdated()
		dbSelectArea('CYP')
		CYP->(dbSetOrder(1))
		CYP->(dbGoTop())
		if CYP->(dbSeek(xFilial('CYQ')+FwFldGet('CYV_NRORPO')+oModelGrid:GetValue('CZP_IDMTOR')))

			IF oModelGrid:GetValue('CZP_CDMT') != CYP->CYP_CDMT
				SFCMsgErro(STR0025 + CYP->CYP_CDMT + NEWLINE +; //"Para itens da reserva, o cÛdigo do item n„o deve ser alterado. Valor Original: "
						   STR0017 + cNRORPO + NEWLINE +; // " Ordem: "
						   STR0018 + cIDAT + NEWLINE +  ; // " OperaÁ„o: "
						   STR0041 + cIDATQO, "SFCA314") // " Split: "
				lRet := .F.
			Endif

			if oModelGrid:GetValue('CZP_CDACPI') != CYP->CYP_CDACPI
				SFCMsgErro(STR0026 + CYP->CYP_CDACPI + NEWLINE +; //"Para itens da reserva, o cÛdigo do item pai n„o deve ser alterado. Valor Original: "
						   STR0017 + cNRORPO + NEWLINE +; // " Ordem: "
						   STR0018 + cIDAT + NEWLINE +  ; // " OperaÁ„o: "
						   STR0041 + cIDATQO, "SFCA314") // " Split: "
				lRet := .F.
			Endif
		Endif

		RestArea(aAreaCYP)
	Endif
EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
// ValidaÁ„o CYV_QTATAP
//-------------------------------------------------------------------
Function SFCA314VQU (nQuantidade)
Local lRet      := .T.
Local lDispatch := IsInCallStack('SFCA318ATV')

if nQuantidade < 0
	SFCMsgErro(STR0027,"SFCA314",1) //"Quantidade deve ser maior que zero"
	lRet := .F.
Elseif !IsInCallStack('RUNTRIGGER')
	Pergunte('SFCA310A',.F.)

	if !lDispatch .AND. MV_PAR01 == 2 .AND. M->CYV_NRBG != M->CYV_NRED
		SFCMsgErro(STR0123,"SFCA314",1) // 'Quando apontamento por mediÁ„o, n„o È possÌvel alterar quantidade'
		lRet := .F.
	Endif
Endif

Return lRet

//-------------------------------------------------------------------
// GeraApoOrd - Gera apontamento autom·tico quando por ordem
//-------------------------------------------------------------------
Static Function GeraApoOrd(cNRORPO,cIDAT,dDTRPBG,cHRRPBG,dDTRPED,cHRRPED,nQTATRP,cNRSQRP,lFinaliza)
	Local cCDATPv,cIDATPv,cCDCETRPv
	Local nI
	Local oModelProd
	Local lRet           := .F.
	Local aArea          := {CYD->( GetArea() ),CY9->( GetArea() ),CYI->( GetArea() ),CYB->( GetArea() ),CYY->( GetArea() )}
	Local oModelCYV
	Private lPermOper    := .F.
	Private lCalcTempo   := .F.
	Private _MaqSFC314
	Private _lFinaliza   := lFinaliza

	dbSelectArea("CYD") //Pert das Operacoes da Ordem
	CYD->(dbSetOrder(2))
	If CYD->(dbSeek(xFilial("CYD")+cNRORPO+cIDAT))

		dbSelectArea("CY9") //Operacao da Ordem
		CY9->(dbSetOrder(1))
		If CY9->(dbSeek(xFilial("CY9")+cNRORPO+CYD->CYD_IDATPV))

			cCDATPv   := CY9->CY9_CDAT
			cIDATPv   := CY9->CY9_IDAT
			cCDCETRPv := CY9->CY9_CDCETR

			dbSelectArea("CYY")
			CYY->(dbSetOrder(1))
			CYY->(dbGoTop())
			CYY->(dbSeek(xFilial('CYY')+cNRORPO+cIDATPv))

			dbSelectArea("CYB")
			CYB->(dbSetOrder(2))
			If CYB->(dbSeek(xFilial("CYB")+cCDCETRPv)) //Verificar isso
				_MaqSFC314 := CYB->CYB_CDMQ
			EndIf

			If !CY9->CY9_LGCERP

				//Model Apontamento ProduÁ„o  - CYV
				oModelProd	:= FwLoadModel( 'SFCA314' )
				oModelProd:SetOperation( 3 )

				If oModelProd:Activate()

					oModelCYV := oModelProd:GetModel('CYVMASTER')

					oModelCYV:SetValue('CYV_NRORPO',cNRORPO)

					lPermOper := .T.
					lCalcTempo := .T.
					oModelCYV:SetValue('CYV_CDAT',cCDATPv)
					lCalcTempo := .F.
					lPermOper := .F.

					If Empty(oModelCYV:GetValue("CYV_IDATQO"))

						dbSelectArea("CYY")
						CYY->(dbSetOrder(1))
						If CYY->(dbSeek(xFilial("CYY")+cNRORPO+cIDATPv))
							oModelCYV:SetValue("CYV_IDATQO", CYY->CYY_IDATQO)
						EndIf

					EndIf

					dbSelectArea("CYB")
					CYB->(dbSetOrder(2))
					If CYB->(dbSeek(xFilial("CYB")+cCDCETRPv)) //Verificar isso
						oModelCYV:LoadValue("CYV_CDMQ", CYB->CYB_CDMQ)
						SFCA314CRE(cNRORPO,oModelCYV:GetValue('CYV_IDAT'),oModelProd:GetModel('CZPDETAIL'),nQTATRP,CYY->CYY_QTAT)
					EndIf

					oModelCYV:SetValue('CYV_DTRPBG',dDTRPBG)
					oModelCYV:SetValue('CYV_HRRPBG',cHRRPBG)

					oModelCYV:SetValue('CYV_QTATRP',nQTATRP)
					oModelCYV:SetValue('CYV_NRRPOG',cNRSQRP)

					//If oModelCYV:GetValue('CYV_DTRPED') > dDTRPED .Or. (oModelCYV:GetValue('CYV_DTRPED') == dDTRPED .And. oModelCYV:GetValue('CYV_HRRPED') > cHRRPED)
						oModelCYV:SetValue('CYV_DTRPED',dDTRPED)
						oModelCYV:SetValue('CYV_HRRPED',cHRRPED)
					//EndIf

					dbSelectArea("CYY")
					CYY->(dbSetOrder(1))
					CYY->(dbSeek(xFilial("CYY")+cNRORPO+cIDAT))

					If oModelProd:VldData() .And. oModelProd:CommitData()
						lRet := .T.
					Else
						aDAPErrors := oModelProd:GetErrorMessage()

						lRet := .F.
					EndIf

					oModelProd:DeActivate()

				Else
					aDAPErrors := oModelProd:GetErrorMessage()
					lRet := .F.
				EndIf

			Else
				lRet := .T. //Se a operaÁ„o for reportada, para e retorna True
			EndIf

		Else
			lRet := .F.
		EndIf

	Else
		lRet := .T.
	EndIf

	For nI := 1 To Len(aArea)
		RestArea(aArea[nI])
	Next
Return lRet

//-------------------------------------------------------------------
// ValidaÁıes do Apontamento de ProduÁ„o
// Input: Model, Tipo de ValidaÁ„o (1-Apontamento, 2-Dispatch List)
// Retorno: Se a operaÁ„o foi v·lida
//-------------------------------------------------------------------
Function SFCA314POS(oModel, nTipo)
Local lRet           := .T.
Local nQtdPreenchido := 0
Local nQtdParada     := 0
Local nI             := 0
Local nFerr          := 0
Local aRetorno  := {}
Local aArea     := GetArea()
Local aAreaCYB  := CYB->( GetArea() )
Local aAreaCYD  := CYD->( GetArea() )
Local aAreaCYQ  := CYQ->( GetArea() )
Local aAreaCYZ  := CYZ->( GetArea() )
Local aAreaCYY  := CYY->( GetArea() )
Local cCDCL     := ''
Local oModelCYV, oModelCYW, oModelCZP, oModelCZ0, oModelCZW
Local dData
Local cNRORPO,cIDAT,cIDATQO,dDTRPBG,cHRRPBG,dDTRPED,cHRRPED,nQTATRP,nQTATAP,nQTATRF,nQTATRT,nNRBG,nNRED,cNRSQRP
Local cMaquina    := ''
Local nOper       := 0
Local cMens       := ''
Local lFerrSetup  := .F.
Local lDispatch   := IsInCallStack('SFCA318ATV')
Local cParadaPK
Local cPkPenult   := ''
Local lPrimeiro   := .F.
Local lUpdLine    := .T.
Local lExibeMsg   := .T.

if lDispatch
	cMaquina := oModel:GetModel('MAQMASTER'):GetValue('MAQMASTER','CYV_CDMQ')
Else
	cMaquina := oModel:GetValue('CYVMASTER','CYV_CDMQ')
Endif

// Inclus„o de Apontamento
if !IsInCallStack('SFCA318LD')

	if nTipo == 1
		oModelCYV := oModel:GetModel( 'CYVMASTER' )
		oModelCYW := oModel:GetModel( 'CYWDETAIL' )
		oModelCZP := oModel:GetModel( 'CZPDETAIL' )
		oModelCZ0 := oModel:GetModel( 'CZ0DETAIL' )
		oModelCZW := oModel:GetModel( 'CZWDETAIL' )
	Else
		oModelCYV := oModel
		oModelCYW := oModel:GetModel( 'CYWDETAIL' ):GetModel( 'CYWDETAIL' )
		oModelCZP := oModel:GetModel( 'CZPDETAIL' ):GetModel( 'CZPDETAIL' )
		oModelCZ0 := oModel:GetModel( 'CZ0DETAIL' ):GetModel( 'CZ0DETAIL' )
		oModelCZW := oModel:GetModel( 'CZWDETAIL' ):GetModel( 'CZWDETAIL' )
	Endif

	cNRORPO := oModelCYV:GetValue('CYV_NRORPO')
	cIDAT   := oModelCYV:GetValue('CYV_IDAT')
	cIDATQO := oModelCYV:GetValue('CYV_IDATQO')
	dDTRPBG := oModelCYV:GetValue('CYV_DTRPBG')
	cHRRPBG := oModelCYV:GetValue('CYV_HRRPBG')
	dDTRPED := oModelCYV:GetValue('CYV_DTRPED')
	cHRRPED := oModelCYV:GetValue('CYV_HRRPED')
	dDTBGSU := oModelCYV:GetValue('CYV_DTBGSU')
	cHRBGSU := oModelCYV:GetValue('CYV_HRBGSU')
	dDTEDSU := oModelCYV:GetValue('CYV_DTEDSU')
	cHREDSU := oModelCYV:GetValue('CYV_HREDSU')
	nQTATRP := oModelCYV:GetValue('CYV_QTATRP')
	nQTATAP := oModelCYV:GetValue('CYV_QTATAP')
	nQTATRF := oModelCYV:GetValue('CYV_QTATRF')
	nQTATRT := oModelCYV:GetValue('CYV_QTATRT')
	nNRBG   := oModelCYV:GetValue('CYV_NRBG')
	nNRED   := oModelCYV:GetValue('CYV_NRED')
	cNRSQRP := oModelCYV:GetValue('CYV_NRSQRP')
	
	If SFCA314IF(oModel, 3)
		Return lRet
	EndIf

	//VAlida se foram gerados os Empenhos da OP - mesma validaÁ„o realizada no MATA681
	If Type("_IsPost314") != "L" 
	    _IsPost314 := .F.
    EndIf

    IF _IsPost314 .Or. IsTelNet() 
	   lExibeMsg := .F.
	EndIf

	If !A650OpBatch(PadR(cNRORPO,TamSX3("D4_OP")[1]), lExibeMsg,.F.,oModelCYV)	    
		SFCMsgErro(STR0128, "SFCA314",1) //'N„o foram gerados os empenhos da ordem de produÁ„o. Para realizar o apontamento È preciso primeiramente gerar os empenhos.'
	    lRet := .F.
	EndIf

	dbSelectArea('CYB')
	CYB->(dbSetOrder(1))
	CYB->(dbGoTop())
	CYB->(dbSeek(xFilial('CYB')+cMaquina))
	
	If !SFCA314IF(oModel, 4)
		// Verifica se existe apontamento de produÁ„o em aberto para split
		If lRet
			lRet := SFCApAbeSp(cNRORPO, cIDAT, cIDATQO, cNRSQRP)
		EndIf

		// Verifica se existe apontamento de produÁ„o em aberto para maquina
		If lRet
			lRet := SFCApAbeMq(cMaquina, cNRSQRP)
		EndIf
	EndIf

	// Define o Split como finalizado
	oModelCYV:SetValue('CYV_TPSTRP','2')

	// Valida uso de mediÁ„o para m·quina
	Pergunte( 'SFCA310A', .F. )

	If lRet
		IF CYB->CYB_LGMED // Realiza apontamento por mediÁ„o
			if MV_PAR01 == 2 // Par‚metro apontamento por mediÁ„o SIM
				if nNRBG == nNRED
					SFCMsgErro(STR0108, 'SFCA314_MEINV1', 1, STR0109) // 'M·quina realiza apontamento por mediÁ„o e n„o foram informados valores v·lidos nos contadores' ## Informe valores nos contadores ou desative a funÁ„o
					lRet := .F.
				ElseIf nNRBG > nNRED
					SFCMsgErro(STR0110, 'SFCA314_MEINV2', 1, STR0111) // 'Contador inicial deve ser menor que o contador final' ## Verifique os valores informados nos contadores
					lRet := .F.
				Endif
			Elseif nNRBG != nNRED
				SFCMsgErro(STR0112, 'SFCA314_NAOMED', 1, STR0113) // A funÁ„o de apontamento por mediÁ„o n„o est· ligada ## Ative alterando para sim o par‚metro atravÈs do bot„o F12
				lRet := .F.
			Endif
		Else
			IF nNRBG != nNRED
				SFCMsgErro(STR0114,'SFCA314_MAQMED', 1, STR0115) // M·quina n„o realiza apontamento por mediÁ„o
				lRet := .F.
			Endif
		Endif
	EndIf

	// Verifica se m·quina est· v·lida
	if lRet .And. (CYB->CYB_DTBGVD > dDTRPBG .OR.;
	   CYB->CYB_DTEDVD < dDTRPED)
		SFCMsgErro(STR0086 + NEWLINE +; //"M·quina inv·lida para o perÌodo de apontamento de produÁ„o informado."
		           STR0017 + cNRORPO + NEWLINE +; // " Ordem: "
		           STR0018 + cIDAT + NEWLINE +  ; // " OperaÁ„o: "
		           STR0041 + cIDATQO , "SFCA314") // " Split: "
		lRet := .F.
	Endif

	If lRet
		dbSelectArea('CYI')
		CYI->(dbSetOrder(1))
		CYI->(dbGoTop())
		if CYI->(dbSeek(xFilial('CYI')+CYB->CYB_CDCETR)) .AND. CYI->CYI_CDCETR == CYB->CYB_CDCETR
			IF Empty(CYI->CYI_CDARPO)
				SFCMsgErro(STR0074 + CYI->CYI_CDCETR, "SFCA314") //'Centro de Trabalho relacionado ‡ Maquina informada n„o possui ¡rea de ProduÁ„o. Corrija no cadastro do Centro de Trabalho '
				lRet := .F.
			Endif
		Else
			SFCMsgErro(STR0075, "SFCA314") //'Centro de Trabalho relacionado ‡ Maquina È inv·lido. Corrija no cadastro de M·quina.'
			lRet := .F.
		Endif
	EndIf

	If lRet // Valida saldo da operaÁ„o
		Pergunte('MTA680',.F.)

		IF MV_PAR07 != 3 // quando 3, n„o vai validar o saldo da operaÁ„o

			cValorApont := SFCA314QRP(cNRORPO,cIDAT, cIDATQO, 0, .T., 1, dDTRPBG, cHRRPBG, .T., If(lDispatch,oModelCYV,nil), dDTRPED, cHRRPED, @lPrimeiro)

			if !lPrimeiro .And. (cValorApont <= 0 .OR. cValorApont < nQTATRP)
		 	   	SFCMsgErro(STR0076,"SFCA314",1) // Necess·rio realizar apontamento da operaÁ„o anterior
		 		lRet := .F.
		 	EndIf
		 Endif
 	EndIf

	dbSelectArea('CYY')
	CYY->(dbSetOrder(1))
	CYY->(dbGoTop())
	CYY->(dbSeek(xFilial('CYY')+cNRORPO+cIDAT+cIDATQO))

	cCDCL := SFCCalendario(cMaquina)

	if lRet .And. CYY->CYY_CDCETR != CYB->CYB_CDCETR

		cMens := STR0043 + NEWLINE +; //"M·quina informada deve possuir mesmo centro de trabalho do split"
		         STR0017 + cNRORPO + NEWLINE +; // " Ordem: "
				 STR0018 + cIDAT + NEWLINE +  ; // " OperaÁ„o: "
				 STR0041 + cIDATQO     // " Split: "

		If (IsInCallStack('CARGADTS_SFC') .Or. IsInCallStack('INTEGPASTA') .Or. IsInCallStack('U_INTEGPASTA'))
			oModel:SetErrorMessage('CYVMASTER', 'CYY_CDCETR',,,, cMens )
		Else
			SFCMsgErro(cMens, "SFCA314")
		EndIf

		lRet := .F.
	Endif

	// Calcula a quantidade de ferramentas informadas
	For nI := 1 To oModelCZ0:Length()
		oModelCZ0:GoLine( nI )
		If !oModelCZ0:IsDeleted() .AND. !Empty(oModelCZ0:GetValue('CZ0_CDFE'))
			nFerr++
		EndIf
	Next

 	// Quando operaÁ„o for Dep Ferramenta, dever· possuir ao menos uma ferramenta informada
 	If lRet
	 	dbSelectArea('CY9')
		CY9->(dbSetOrder(1))
		CY9->(dbGoTop())
		if CY9->(dbSeek(xFilial('CY9')+cNRORPO+cIDAT)) .AND. CY9->CY9_NRORPO == cNRORPO .AND. CY9->CY9_IDAT == cIDAT .AND. CY9->CY9_TPTE == '4'
		 	if nFerr == 0
	 			SFCMsgErro(STR0077 + NEWLINE +; //'Quando a operaÁ„o È Dep Ferramenta, dever· ser informado um Recurso do tipo Ferramenta'
	 					   STR0017 + cNRORPO + NEWLINE +; // " Ordem: "
						   STR0018 + cIDAT + NEWLINE +  ; // " OperaÁ„o: "
						   STR0041 + cIDATQO , "SFCA314") // " Split: "
	 			lRet := .F.
	 		Endif
		Endif
	EndIf

	If lRet
		if CYB->CYB_LGSU
			if CYY->CYY_TPSTAT < '4'
				if dDTEDSU > dDTRPBG .OR.;
				  (dDTEDSU == dDTRPBG .AND. cHREDSU > cHRRPBG)

				  	cMens := STR0028 + NEWLINE +; //"InÌcio do Reporte deve ser maior ou igual ao Fim da PreparaÁ„o."
				  			 STR0017 + cNRORPO + NEWLINE +; // " Ordem: "
						     STR0018 + cIDAT + NEWLINE +  ; // " OperaÁ„o: "
						     STR0041 + cIDATQO     // " Split: "

					If (IsInCallStack('CARGADTS_SFC') .Or. IsInCallStack('INTEGPASTA') .Or. IsInCallStack('U_INTEGPASTA'))
						oModel:SetErrorMessage('CYVMASTER', 'CYV_DTEDSU',,,,cMens )
					Else
						SFCMsgErro(cMens, "SFCA314")
					EndIf

					lRet := .F.
				Endif

				if lRet
					// Verifica se existe apontamento de preparaÁ„o em aberto
					if !SFCSetupIn(cMaquina) .AND.;
						SFCA314VPA(cMaquina,oModelCYV:GetValue('CYV_DTBGSU'),oModelCYV:GetValue('CYV_DTEDSU'),oModelCYV:GetValue('CYV_HRBGSU'),oModelCYV:GetValue('CYV_HREDSU')) > 0

						cMens := STR0029 + NEWLINE +; //"J· existe um apontamento de parada realizado durante o perÌodo de PreparaÁ„o informado"
						         STR0017 + cNRORPO + NEWLINE +; // " Ordem: "
						     	 STR0018 + cIDAT + NEWLINE +  ; // " OperaÁ„o: "
						     	 STR0041 + cIDATQO     // " Split: "

						If (IsInCallStack('CARGADTS_SFC') .Or. IsInCallStack('INTEGPASTA') .Or. IsInCallStack('U_INTEGPASTA'))
							oModel:SetErrorMessage('CYVMASTER', 'CYV_DTBGSU',,,,cMens )
						Else
							SFCMsgErro(cMens, "SFCA314")
						EndIf

						lRet := .F.
					Endif

					IF Empty(oModelCYV:GetValue('CYV_CDSU'))

						cMens := STR0030 + ALLTRIM(cMaquina) + STR0031 + NEWLINE +; //"A M·quina "###" possui tempo de preparaÁ„o e n„o foi selecionada uma parada"
								 STR0017 + cNRORPO + NEWLINE +; // " Ordem: "
						     	 STR0018 + cIDAT + NEWLINE +  ; // " OperaÁ„o: "
						     	 STR0041 + cIDATQO     // " Split: "

						If (IsInCallStack('CARGADTS_SFC') .Or. IsInCallStack('INTEGPASTA') .Or. IsInCallStack('U_INTEGPASTA'))
							oModel:SetErrorMessage('CYVMASTER', 'CYV_DTBGSU',,,,cMens )
						Else
							SFCMsgErro(cMens, "SFCA314")
						EndIf

						lRet := .F.
					Endif
				Endif

				lFerrSetup := CYB->CYB_LGFESU // Obriga a m·quina a informar ferramenta na preparaÁ„o

				if lRet .AND. lFerrSetup
					if nFerr < 1
						SFCMsgErro(STR0032 + NEWLINE +; //"Esta m·quina possui tempo de preparaÁ„o e ao menos uma ferramenta dever· ser informada"
								   STR0017 + cNRORPO + NEWLINE +; // " Ordem: "
						           STR0018 + cIDAT + NEWLINE +  ; // " OperaÁ„o: "
						     	   STR0041 + cIDATQO , "SFCA314") // " Split: "
						lRet := .F.
					Endif
				Endif
			Endif
		Else
			oModelCYV:ClearField('CYV_DTBGSU')
			oModelCYV:ClearField('CYV_DTEDSU')
			oModelCYV:ClearField('CYV_HRBGSU')
			oModelCYV:ClearField('CYV_HREDSU')
		Endif

	EndIf

	if lRet
		//Verifica se existe tempo de preparaÁ„o para GGF
		For nI := 1 To oModelCZW:Length()
			oModelCZW:GoLine( nI )

			if !oModelCZW:IsDeleted() .AND. oModelCZW:IsUpdated()
				if Empty(oModelCZW:GetValue('CZW_HRTEGF'))
					SFCMsgErro(STR0024 + NEWLINE +; //"Deve ser informado tempo para GGF"
							   STR0017 + cNRORPO + NEWLINE +; // " Ordem: "
					     	   STR0018 + cIDAT + NEWLINE +  ; // " OperaÁ„o: "
					     	   STR0041 + cIDATQO , "SFCA314") // " Split: "
					lRet := .F.
					Exit
				Endif
			Endif
		Next

		IF nQTATRT > nQTATAP
			If !IsInCallStack("SFCA311DAP")
				SFCMsgErro(STR0091 + NEWLINE +; // 'Quantidade Retrabalhada deve ser menor ou igual ‡ quantidade aprovada.'
			    	       STR0017 + cNRORPO + NEWLINE +; // " Ordem: "
			    	       STR0018 + cIDAT + NEWLINE +  ; // " OperaÁ„o: "
			     	   		STR0041 + cIDATQO, "SFCA314")  // " Split: "
				lRet := .F.
			EndIf
		Elseif !IsInCallStack("SFCA311DAP") .And. nQTATRP != (oModelCYV:GetValue('CYV_QTATAP') + oModelCYV:GetValue('CYV_QTATRF'))
			cMens := STR0034 + NEWLINE +; //"Soma das quantidades aprovadas e refugadas n„o È igual ‡ quantidade reportada"
					 STR0017 + cNRORPO + NEWLINE +; // " Ordem: "
			     	 STR0018 + cIDAT + NEWLINE +  ; // " OperaÁ„o: "
			     	 STR0041 + cIDATQO     // " Split: "

			If (IsInCallStack('CARGADTS_SFC') .Or. IsInCallStack('INTEGPASTA') .Or. IsInCallStack('U_INTEGPASTA'))
				oModel:SetErrorMessage('CYVMASTER', 'CYV_QTATAP',,,,cMens)
			Else
				SFCMsgErro(cMens, "SFCA314")
			EndIf

			lRet := .F.
		Endif

		if lRet
			if !Empty(oModelCYV:GetValue('CYV_DTBGSU'))
				For dData := oModelCYV:GetValue('CYV_DTBGSU') To oModelCYV:GetValue('CYV_DTEDSU')
					CYZ->(dbSetOrder(1))
					CYZ->(dbGoTop())
					IF !CYZ->(DbSeek(xFilial('CYZ')+cCDCL+DTOS(dData)))
						SFCMsgErro(STR0035 + DTOC(dData) + NEWLINE +; //"PerÌodo informado para PreparaÁ„o È Inv·lido. N„o existe calend·rio para a data "
								   STR0017 + cNRORPO + NEWLINE +; // " Ordem: "
			     	 			   STR0018 + cIDAT + NEWLINE +  ; // " OperaÁ„o: "
						     	   STR0041 + cIDATQO , "SFCA314") // " Split: "
						lRet := .F.
					Endif

					if dData == oModelCYV:GetValue('CYV_DTBGSU')
						if CYZ->CYZ_TPDY != '1'
							SFCMsgErro(STR0066 + DTOC(dData) + NEWLINE +; //"PerÌodo informado para PreparaÁ„o È Inv·lido. Data Inicial deve ser dia ˙til. "
									   STR0017 + cNRORPO + NEWLINE +; // " Ordem: "
							     	   STR0018 + cIDAT + NEWLINE +  ; // " OperaÁ„o: "
									   STR0041 + cIDATQO , "SFCA314") // " Split: "
							lRet := .F.
						Else
							// Verificar se existe turno para este dia
							aRetorno := SFCA314GTU(,,cMaquina,oModelCYV:GetValue('CYV_DTBGSU'))

							IF Empty(aRetorno[1])
								SFCMsgErro(STR0068 + NEWLINE +; //'N„o encontrado Modelo Turno para a M·quina informada'
										   STR0017 + cNRORPO + NEWLINE +; // " Ordem: "
			     	 					   STR0018 + cIDAT + NEWLINE +  ; // " OperaÁ„o: "
			     	 					   STR0041 + cIDATQO , "SFCA314") // " Split: "
								lRet := .F.
							Else
								dbSelectArea("CYR") // Turno Dia
								dbSetOrder(2)
								If !CYR->(dbSeek(xFilial("CYR")+aRetorno[1]+ALLTRIM(STR(DOW(oModelCYV:GetValue('CYV_DTBGSU'))))))
									SFCMsgErro(STR0069 + STR0083 + NEWLINE +; //'N„o encontrado N˙mero de Turno para a M·quina informada " "para o InÌcio da PreparaÁ„o'
											   STR0017 + cNRORPO + NEWLINE +; // " Ordem: "
			     	 						   STR0018 + cIDAT + NEWLINE +  ; // " OperaÁ„o: "
			     	 						   STR0041 + cIDATQO , "SFCA314") // " Split: "
									lRet := .F.
								Endif
							Endif
						Endif
				   	EndIf
				Next
			Endif

			For dData := dDTRPBG To dDTRPED
				CYZ->(dbSetOrder(1))
				CYZ->(dbGoTop())
				IF !CYZ->(DbSeek(xFilial('CYZ')+cCDCL+DTOS(dData)))
					SFCMsgErro(STR0036 + DTOC(dData) + NEWLINE +; //"PerÌodo informado para ProduÁ„o È Inv·lido. N„o existe calend·rio para a data "
							   STR0017 + cNRORPO + NEWLINE +; // " Ordem: "
			     	 		   STR0018 + cIDAT + NEWLINE +  ; // " OperaÁ„o: "
			     	 		   STR0041 + cIDATQO , "SFCA314") // " Split: "
					lRet := .F.
				Endif

				if dData == dDTRPBG
					if CYZ->CYZ_TPDY != '1'
						SFCMsgErro(STR0067 + DTOC(dData) + NEWLINE +; //"PerÌodo informado para ProduÁ„o È Inv·lido. Data Inicial de apontamento deve ser dia ˙til. "
								   STR0017 + cNRORPO + NEWLINE +; // " Ordem: "
			     	 			   STR0018 + cIDAT + NEWLINE +  ; // " OperaÁ„o: "
			     	 			   STR0041 + cIDATQO , "SFCA314") // " Split: "
						lRet := .F.
					Else
						// Verificar se existe turno para este dia
						aRetorno := SFCA314GTU(,,cMaquina,dDTRPBG)

						IF Empty(aRetorno[1])
							SFCMsgErro(STR0068 + NEWLINE +; //'N„o encontrado Modelo Turno para a M·quina informada'
									   STR0017 + cNRORPO + NEWLINE +; // " Ordem: "
			     	 				   STR0018 + cIDAT + NEWLINE +  ; // " OperaÁ„o: "
			     	 				   STR0041 + cIDATQO , "SFCA314") // " Split: "
							lRet := .F.
						Else
							dbSelectArea("CYR") // Turno Dia
							dbSetOrder(2)
							If !CYR->(dbSeek(xFilial("CYR")+aRetorno[1]+ALLTRIM(STR(DOW(dDTRPBG)))))
								SFCMsgErro(STR0069 + STR0084 + NEWLINE +; //'N„o encontrado N˙mero de Turno para a M·quina informada ' "para inÌcio do apontamento de produÁ„o."
										   STR0017 + cNRORPO + NEWLINE +; // " Ordem: "
			     	 					   STR0018 + cIDAT + NEWLINE +  ; // " OperaÁ„o: "
			     	 					   STR0041 + cIDATQO , "SFCA314") // " Split: "
								lRet := .F.
							Endif
						Endif
					Endif
			   	EndIf
			Next
		Endif

		if !SFCSetupIn(cMaquina) .AND. (nQtdParada := SFCA314VPA(cMaquina,dDTRPBG,dDTRPED,cHRRPBG,cHRRPED,@nQtdPreenchido,@cParadaPK, @cPkPenult))  > 0
			If !CYB->CYB_LGQBRP .Or. nQtdParada > nQtdPreenchido
				SFCMsgErro(STR0037 + NEWLINE +; //"J· existe um apontamento de parada realizado durante o perÌodo de apontamento de produÁ„o informado"
						   STR0017 + cNRORPO + NEWLINE +; // " Ordem: "
				     	   STR0018 + cIDAT + NEWLINE +  ; // " OperaÁ„o: "
				     	   STR0041 + cIDATQO , "SFCA314") // " Split: "
				lRet := .F.
			Else
				oModelCYV:SetValue("GER_PARADA",cParadaPK)

				IF !Empty(cPkPenult)
					oModelCYV:SetValue("GER_PARANT", cPkPenult)
				EndIf

			EndIf
		EndIf

		dbSelectArea('CYQ')
		CYQ->(dbSetOrder(1))
		CYQ->(dbSeek(xFilial('CYQ')+cNRORPO))

		If lRet .And. CYI->CYI_TPPC == '1' .AND. !CYB->CYB_LGOVRP .And. (CYQ->CYQ_TPRPOR == "2" .OR. (CYQ->CYQ_TPRPOR == "1" .AND. CYY->CYY_LGCERP))
			if Len(SFCA314VAP(cMaquina,dDTRPBG,dDTRPED,cHRRPBG,cHRRPED)) > 0
				SFCMsgErro(STR0038 + NEWLINE +; //"J· existe um apontamento de produÁ„o realizado durante o perÌodo informado"
						   STR0017 + cNRORPO + NEWLINE +; // " Ordem: "
			    	 	   STR0018 + cIDAT + NEWLINE +  ; // " OperaÁ„o: "
			    	 	   STR0041 + cIDATQO , "SFCA314") // " Split: "
				lRet := .F.
			Endif
		Endif
	Endif

	if lRet
		dbSelectArea('CYQ')
		CYQ->(dbSetOrder(1))
		CYQ->(dbGoTop())
		CYQ->(dbSeek(xFilial('CYQ')+cNRORPO))

		If CYQ->CYQ_TPMOD == '1' // Real
			For nI := 1 To oModelCYW:Length()
				oModelCYW:GoLine( nI )

				if !oModelCYW:IsDeleted()

					IF !(Empty(oModelCYW:GetValue('CYW_CDGROE')) .AND. Empty(oModelCYW:GetValue('CYW_CDOE')))
						if CYI->CYI_TPMOD == '2' .AND.; // Operador
						   !Empty(oModelCYW:GetValue('CYW_CDGROE'))
							SFCMsgErro(STR0078 + ALLTRIM(CYI->CYI_CDCETR) + NEWLINE +; // 'Este Centro de Trabalho sÛ permite que operadores sejam informados na aba Recursos. Verifique o Reporte MOB do Centro de Trabalho '
									   STR0017 + cNRORPO + NEWLINE +; // " Ordem: "
			     	 				   STR0018 + cIDAT + NEWLINE +  ; // " OperaÁ„o: "
			     	 				   STR0041 + cIDATQO , "SFCA314") // " Split: "
							lRet := .F.
							Exit
						Endif

						if CYI->CYI_TPMOD == '3' .AND.; // Equipe
						   !Empty(oModelCYW:GetValue('CYW_CDOE'))
							SFCMsgErro(STR0079 + ALLTRIM(CYI->CYI_CDCETR) + NEWLINE +; // 'Este Centro de Trabalho sÛ permite que equipes sejam informados na aba Recursos. Verifique o Reporte MOB do Centro de Trabalho '
									   STR0017 + cNRORPO + NEWLINE +; // " Ordem: "
							     	   STR0018 + cIDAT + NEWLINE +  ; // " OperaÁ„o: "
			     	 				   STR0041 + cIDATQO , "SFCA314") // " Split: "
							lRet := .F.
							Exit
						Endif

						nOper++

						lUpdLine := oModelCYW:lUpdateLine
						oModelCYW:SetNoUpdateLine(.F.)

						oModelCYW:SetValue( 'CYW_CDTN'  , oModelCYV:GetValue('CYV_CDTN') )
						oModelCYW:SetValue( 'CYW_NRTN'  , oModelCYV:GetValue('CYV_NRTN') )

						aRetorno := SFCXTEMPOS('', '', 3, cMaquina, oModelCYW:GetValue('CYW_DTBGRP'), oModelCYW:GetValue('CYW_DTEDRP'), oModelCYW:GetValue('CYW_HRBGRP'), oModelCYW:GetValue('CYW_HREDRP'),.F.,'SFCA314')

						oModelCYW:SetValue( 'CYW_QTTEUT', aRetorno[3])
						oModelCYW:SetValue( 'CYW_QTTEEX', aRetorno[4])
						oModelCYW:SetValue( 'CYW_QTTEOE', aRetorno[3] + aRetorno[4])

						oModelCYW:SetNoUpdateLine( !lUpdLine )
					Endif
				Endif
		 	Next

		 	IF lRet .And. !IsInCallStack("SFCA311DAP")
			 	if CYI->CYI_TPMOD == '2' .AND. nOper == 0
					SFCMsgErro(STR0088 + NEWLINE +; // Deve ser informado ao menos um operador
							   STR0017 + cNRORPO + NEWLINE +; // " Ordem: "
				     	 	   STR0018 + cIDAT + NEWLINE +  ; // " OperaÁ„o: "
			    	 	 	   STR0041 + cIDATQO , "SFCA314") // " Split: "
					lRet := .F.
				ElseIf CYI->CYI_TPMOD == '3' .AND. nOper == 0
					SFCMsgErro(STR0089 + NEWLINE +; // Deve ser informado ao menos uma equipe
							   STR0017 + cNRORPO + NEWLINE +; // " Ordem: "
			    	 		   STR0018 + cIDAT + NEWLINE +  ; // " OperaÁ„o: "
			     		 	   STR0041 + cIDATQO , "SFCA314") // " Split: "
					lRet := .F.
				Endif
			Endif
		EndIf

		if lRet .AND. nOper > CYB->CYB_QTOEMQ
			SFCMsgErro(STR0080 + STR(CYB->CYB_QTOEMQ) + NEWLINE +; // 'N˙mero de operadores informados na Aba Recursos excede a quantidade m·xima permitida na M·quina. M·ximo: '
					   STR0017 + cNRORPO + NEWLINE +; // " Ordem: "
			     	   STR0018 + cIDAT + NEWLINE +  ; // " OperaÁ„o: "
			     	   STR0041 + cIDATQO , "SFCA314") // " Split: "
			lRet := .F.
		Endif
	Endif

	if Empty(oModelCYV:GetValue('CYV_CDDP'))
		oModelCYV:SetValue('CYV_CDDP', POSICIONE('CYQ',1,xFilial('CYQ')+cNRORPO,'CYQ_CDDP'))
		oModelCYV:SetValue('CYV_NRDO', cNRORPO)
	Endif

	RestArea(aAreaCYY)
	RestArea(aAreaCYQ)
	RestArea(aAreaCYZ)
	RestArea(aAreaCYB)
	RestArea(aAreaCYD)
	RestArea(aArea)
Endif

if IsInCallStack("SFCA310")
	oMarkCYY:GoTop()
Endif

return lRet

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
Static Function PrivNRSQRP(cNRSQRP)
	Local cRet := ""

    If type("pcNRSQRP") == "U"
    	cRet := cNRSQRP
    Else
    	cRet := pcNRSQRP
    EndIf

Return cRet

//-------------------------------------------------------------------
// ValApontAnt - Valida Apontamento Anterior
//-------------------------------------------------------------------
Static Function ValAponAnt(oModelCYV,lFinaliza)
	Local lRet			:= .T.
	Local nQTATRP		:= oModelCYV:GetValue('CYV_QTATRP')
	Local cNRORPO		:= oModelCYV:GetValue('CYV_NRORPO')
	Local cIDAT		:= oModelCYV:GetValue('CYV_IDAT')
	Local dDTRPBG		:= oModelCYV:GetValue('CYV_DTRPBG')
	Local cHRRPBG		:= oModelCYV:GetValue('CYV_HRRPBG')
	Local dDTRPED		:= oModelCYV:GetValue('CYV_DTRPED')
	Local cHRRPED		:= oModelCYV:GetValue('CYV_HRRPED')
	Local cNRSQRPloc := PrivNRSQRP( oModelCYV:GetValue('CYV_NRSQRP') )
	Private pcNRSQRP := cNRSQRPloc

	If Posicione("CYQ",1,xFilial("CYQ")+cNRORPO,"CYQ_TPRPOR") == "1" .And. !GeraApoOrd(cNRORPO,cIDAT,dDTRPBG,cHRRPBG,dDTRPED,cHRRPED,nQTATRP,pcNRSQRP,lFinaliza)
		lRet := .F.
	EndIf

Return lRet

//-------------------------------------------------------------------
// Commit Apontamento de ProduÁ„o
// Input: Model
// Retorno: Se a operaÁ„o foi v·lida
//-------------------------------------------------------------------
Function SFCA314CMM(oModel)
	Local cProduc := oModel:GetValue("CYVMASTER","CYV_NRSQRP")
	Local cParada := oModel:GetValue("CYVMASTER","GER_PARADA")
	Local lRet := .T.
	Private aDAPErrors

	Begin Transaction

		If SFCA314SAL(oModel:GetModel('CYVMASTER'))
			FWFormCommit( oModel ) // Salva os campos padrıes do model

			IF FindFunction("fGravaSMO") //MATA250
				fGravaSMO(CYV->CYV_NRSQRP, '4')	
			EndIf

			If !Empty(cParada)
				dbSelectArea("CYX")
				dbSetOrder(1)
				dbSeek(cParada)
				If !SFCA311DAP(cProduc,CYX->CYX_DTBGSP,CYX->CYX_DTEDSP,CYX->CYX_HRBGSP,CYX->CYX_HREDSP,oModel)
					DisarmTransaction()
					lRet := .F.
				EndIf
			EndIf

		Else
			DisarmTransaction()

			lRet := .F.

			If ValType(aDAPErrors) == "A" .And. !Empty(aDAPErrors[6])
				ShowHelpDlg( STR0117, { aDAPErrors[6] }, , { STR0118 } )//"Apontamento n„o Reportado" - "Este È um apontamento n„o reportado, portanto, faÁa as devidas correÁıes na m·quina ou centro de trabalho."
				lRet := .T.
			EndIf

		Endif

	End Transaction

	SFCA310F12()

Return lRet

//-------------------------------------------------------------------
// ValidaÁ„o CYV_CDMQ
//-------------------------------------------------------------------
Function SFCA314VMQ()
Local lRet      := .T.
Local aArea     := GetArea()
Local aAreaCYB  := CYB->(GetArea())
Local aAreaCYY  := CYY->(GetArea())
Local oModel    := FWMODELACTIVE()
Local oModelCYV := oModel:GetModel( 'CYVMASTER' )
Local cMaquina  := ''
Local cMens     := ''
Local cNRORPO   := oModelCYV:GetValue('CYV_NRORPO')
Local cIDAT     := oModelCYV:GetValue('CYV_IDAT')
Local cIDATQO   := oModelCYV:GetValue('CYV_IDATQO')

If !IsInCallStack("GeraApoOrd") //Se a funÁ„o for executado por model que esta sendo gerado automaticamente, n„o fazer esta validaÁ„o

	if IsInCallStack('SFCA318ATV')
		cMaquina := oModel:GetValue('MAQMASTER','CYV_CDMQ')
	Else
		cMaquina := oModelCYV:GetValue('CYV_CDMQ')
	Endif

	dbSelectArea('CYB')
	CYB->(dbSetOrder(1))
	CYB->(dbGoTop())
	if CYB->(dbSeek(xFilial('CYB')+cMaquina))

		dbSelectArea('CYY')
		CYY->(dbSetOrder(1))
		CYY->(dbGoTop())
		if CYY->(dbSeek(xFilial('CYY')+cNRORPO+cIDAT+cIDATQO))
			if !Empty(CYY->CYY_CDMQ)
				if CYY->CYY_TPSTAT == '4' .AND. CYY->CYY_CDMQ != cMaquina
					SFCMsgErro(STR0092,"SFCA314") // 'Split j· foi apontado em outra m·quina'
					lRet := .F.
				Endif
			Endif

			if lRet
				IF CYY->CYY_CDCETR != CYB->CYB_CDCETR

					cMens := STR0043 + NEWLINE +; //"M·quina informada deve possuir mesmo centro de trabalho do split"
							 STR0017 + cNRORPO + NEWLINE +; // " Ordem: "
					     	 STR0018 + cIDAT + NEWLINE +  ; // " OperaÁ„o: "
					     	 STR0041 + cIDATQO     // " Split: "

					If (IsInCallStack('CARGADTS_SFC') .Or. IsInCallStack('INTEGPASTA') .Or. IsInCallStack('U_INTEGPASTA'))
						oModel:SetErrorMessage('CYVMASTER', 'CYY_CDCETR',,,,cMens )
						lRet := .F.
					Else
						SFCMsgErro(cMens,"SFCA314")
					EndIf

					lRet := .F.
				Endif
			Endif
		Endif

		// Verifica se vai usar mediÁ„o, se usar e usar funÁ„o, funÁ„o deve existir
		if CYB->CYB_LGMED
			Pergunte('SFCA310A',.F.)

			IF MV_PAR01 == 2
				if !Empty(CYB->CYB_DSFUEY) .AND. !ExistBlock(CYB->CYB_DSFUEY)
					SFCMsgErro(STR0116,"SFCA314") // 'M·quina utiliza funÁ„o para c·lculo de mediÁ„o, mas funÁ„o n„o existe'
					lRet := .F.
				Else
					 oModelCYV:SetValue('CYV_QTATRP',SFCA314CON(oModelCYV:GetValue('CYV_NRBG'),oModelCYV:GetValue('CYV_NRED')))
				Endif
			Endif
		Endif
	Else
		lRet := .F.
	Endif
Endif

RestArea(aAreaCYB)
RestArea(aAreaCYY)
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
// ValidOrdem - Valida o valor informado no campo Ordem de ProduÁ„o
//-------------------------------------------------------------------
Static Function ValidOrdem(cNRORPO)

	Local cAliasCYY := ''

	If Empty(cNRORPO)
		Return .T.
	EndIf

	//Valida se a ordem possui alguma split com parametro Reportado ativo
	dbSelectArea("CYQ")
	CYQ->(dbSetOrder(1))

	If CYQ->(dbSeek(xFilial("CYQ")+cNRORPO))
		If CYQ->CYQ_TPRPOR == '1'

			cAliasCYY := GetNextAlias()

			BeginSql Alias cAliasCYY

				SELECT CYY.CYY_LGCERP
				FROM %Table:CYY% CYY
				  INNER JOIN %Table:CY9% CY9 ON CY9.CY9_NRORPO = CYY.CYY_NRORPO AND CY9.CY9_IDAT = CYY.CYY_IDAT
				WHERE CY9.CY9_NRORPO = %Exp:cNRORPO%
				  AND CY9.CY9_LGATED = 'T'
				  AND CY9.%NotDel%
				  AND CYY.%NotDel%

			EndSql

			If (cAliasCYY)->CYY_LGCERP == 'T'
				(cAliasCYY)->(dbCloseArea())
				Return .T.
			EndIf

			(cAliasCYY)->(dbCloseArea())

		Else
			Return .T.
		EndIf
	EndIf

Return .F.

//-------------------------------------------------------------------
// ValidOper - Valida o valor informado no campo OperaÁ„o
//-------------------------------------------------------------------
Static Function ValidOper(cNRORPO,cCDAT)

	If Empty(cCDAT)
		Return .T.
	EndIf

	//Valida se a ordem possui alguma split com parametro Reportado ativo
	dbSelectArea("CYQ")
	CYQ->(dbSetOrder(1))

	If CYQ->(dbSeek(xFilial("CYQ")+cNRORPO))
		If CYQ->CYQ_TPRPOR == '1'

			//Valida se o centro de trabalho da operaÁ„o possui parametro Reportado ativo
			dbSelectArea("CY9")
			CY9->(dbSetOrder(5))

			If CY9->(dbSeek(xFilial("CY9")+cNRORPO+cCDAT))

				If CY9->CY9_LGCERP .Or. (Type("lPermOper") != "U" .And. lPermOper)
					Return .T.
				EndIf

			EndIf
		Else
			Return .T.
		EndIf
	EndIf

Return .F.

//-------------------------------------------------------------------
// ValidaÁ„o Split - CYV_NRORPO, CYV_IDAT, CYV_IDATQO
//-------------------------------------------------------------------
Function SFCA314VSP(nTipo)
Local lRet      := .T.
Local aArea     := GetArea()
Local aAreaCYY  := CYY->(GetArea())
Local aAreaCYB  := CYB->(GetArea())
Local oModel    := FWMODELACTIVE()
Local oModelCYV := oModel:GetModel( 'CYVMASTER' )
Local oModelLIST := oModel:GetModel('CYVLIST')
Local cNRORPO   := oModelCYV:GetValue('CYV_NRORPO')
Local cIDAT     := oModelCYV:GetValue('CYV_IDAT')
Local cIDATQO   := oModelCYV:GetValue('CYV_IDATQO')
Local cCDAT     := oModelCYV:GetValue('CYV_CDAT')
Local cMaquina  := ''
Local nI        := 0
Local cAliasCYV := ''
Local cAliasCYY := ''
Local lExist    := .F.
Local lInicia   := IsInCallStack('SFCA319INI') .Or. SFCA314IF(oModel, 1)
Local lModelo2  := IsInCallStack('SFCA316') .Or. IsInCallStack("MATI681")
Local lImport   := IsInCallStack('SFCA320')

if lModelo2 .OR. lInicia .OR. lImport

	if IsInCallStack('SFCA318ATV') // Dispatch List
		cMaquina := oModel:GetValue('MAQMASTER','CYV_CDMQ')
	Else
		cMaquina := oModelCYV:GetValue('CYV_CDMQ')
	Endif

	oModelCYV:ClearField('CYV_CDMQ')

	if nTipo == 1 // Ordem

		lRet := Vazio() .OR. ExistCpo('CYQ',cNRORPO)

		If lRet

			lRet := ValidOrdem(cNRORPO)

			If !lRet
				Help( ,, 'SFCA314', , STR0119, 1, 0) //"A ˙ltima operaÁ„o da OP deve possuir um centro de trabalho reportado."
			EndIf

		EndIf

		oModelCYV:ClearField('CYV_IDAT')
		oModelCYV:ClearField('CYV_CDAT')
		oModelCYV:ClearField('CYV_IDATQO')
	ElseIf nTipo == 2 // OperaÁ„o
		lRet := NaoVazio() .OR. ExistCpo('CY9',cNRORPO+cIDAT)
		oModelCYV:ClearField('CYV_IDATQO')

		cAliasCYY := GetNextAlias()

		BeginSql Alias cAliasCYY

			SELECT COUNT(*) AS QTD FROM %Table:CYY% CYY
				WHERE CYY.CYY_FILIAL=%xFilial:CYY% AND
					  CYY.CYY_NRORPO=%Exp:cNRORPO% AND
					  CYY.CYY_IDAT=%Exp:cIDAT% AND
					  CYY.%NotDel%

		EndSql

		IF (cAliasCYY)->QTD == 1
			cIDATQO := POSICIONE('CYY',1,xFilial('CYY')+cNRORPO+cIDAT,'CYY_IDATQO')

			oModelCYV:LoadValue('CYV_IDATQO',cIDATQO)
		Endif

		(cAliasCYY)->(dbCloseArea())
	ElseIf nTipo == 3 // Split
		dbSelectArea('CYY')
		CYY->(dbSetOrder(1))
		CYY->(dbGoTop())
		IF !CYY->(dbSeek(xFilial('CYY')+cNRORPO+cIDAT+cIDATQO))
			if !Empty(cIDATQO)
				SFCMsgErro(STR0071,"SFCA314",2) //"Split inexistente"
			Endif

			oModelCYV:ClearField('CYV_IDATQO')
			cIDATQO := ''
		Else
			// Verificar estado do Split
			if CYY->CYY_TPSTAT == '5' // Encerrado
				SFCMsgErro(STR0097,"SFCA314",2) //'Split j· foi finalizado e n„o pode ser apontado'
				oModelCYV:ClearField('CYV_IDATQO')
				cIDATQO := ''
			Endif
		Endif
	Else // CÛdigo OperaÁ„o
		oModelCYV:ClearField('CYV_IDATQO')
		cIDATQO := ''

		lRet := ExistCpo('CY9',cNRORPO+cCDAT,5)

		if lRet

			lRet := ValidOper(cNRORPO,cCDAT)

			if !lRet
				Help( ,, 'SFCA314', , STR0120, 1, 0)//"Esta operaÁ„o n„o precisa ser reportada."
			Else

				dbSelectArea('CY9')
				CY9->(dbSetOrder(5))
				CY9->(dbGoTop())
				IF CY9->(dbSeek(xFilial('CY9')+cNRORPO+cCDAT))
					cIDAT := CY9->CY9_IDAT
					oModelCYV:LoadValue('CYV_IDAT',cIDAT)

					cAliasCYY := GetNextAlias()

					BeginSql Alias cAliasCYY

						SELECT COUNT(*) AS QTD FROM %Table:CYY% CYY
							WHERE CYY.CYY_FILIAL=%xFilial:CYY% AND
								  CYY.CYY_NRORPO=%Exp:cNRORPO% AND
								  CYY.CYY_IDAT=%Exp:cIDAT% AND
								  CYY.%NotDel%
					EndSql

					IF (cAliasCYY)->QTD == 1
						cIDATQO := POSICIONE('CYY',1,xFilial('CYY')+cNRORPO+cIDAT,'CYY_IDATQO')

						oModelCYV:LoadValue('CYV_IDATQO',cIDATQO)
					Endif

					(cAliasCYY)->(dbCloseArea())
				Endif
			Endif
		Endif
	Endif

	if !lInicia .And. ValType(oModelLIST) != "U"
		oModelLIST:SetNoInsertLine(.F.)
		oModelLIST:SetNoDeleteLine(.F.)
		oModelLIST:SetNoUpdateLine(.F.)

		For nI := 1 to oModelLIST:GetQtdLine()
			oModelLIST:GoLine(nI)

			oModelLIST:ClearField('NRSQRP')
			oModelLIST:ClearField('QTATRP')
			oModelLIST:ClearField('QTATAP')
			oModelLIST:ClearField('QTATRF')
			oModelLIST:ClearField('QTATRT')
			oModelLIST:ClearField('CDMQ'  )
			oModelLIST:ClearField('IDATQO')
			oModelLIST:ClearField('DTRPBG')
			oModelLIST:ClearField('HRRPBG')
			oModelLIST:ClearField('DTRPED')
			oModelLIST:ClearField('HRRPED')
			oModelLIST:SetValue('LGRPEO', .F.)

			oModelLIST:DeleteLine()
		Next

		nI := 1

		IF nTipo != 1 .AND. lModelo2 // Apontamento modelo 2
			SFCA314PRE(oModel,1)

			cAliasCYV := GetNextAlias()

			BeginSql Alias cAliasCYV

				SELECT * FROM %Table:CYV% CYV
					WHERE CYV.CYV_FILIAL=%xFilial:CYV% AND
						  CYV.CYV_NRORPO=%Exp:cNRORPO% AND
						  CYV.CYV_IDAT=%Exp:cIDAT% AND
						  CYV.%NotDel%

			EndSql

			(cAliasCYV)->(dbGoTop())

			While (cAliasCYV)->(!EOF())

				lExist := .T.

				if nI > oModelLIST:GetQtdLine()
					oModelList:AddLine()
				Else
					oModelLIST:GoLine(nI)

					if oModelLIST:IsDeleted()
						oModelLIST:UnDeleteLine()
					Endif
				Endif

				nI++

				oModelLIST:SetValue('NRSQRP', (cAliasCYV)->CYV_NRSQRP)
				oModelLIST:SetValue('QTATRP', (cAliasCYV)->CYV_QTATRP)
				oModelLIST:SetValue('QTATAP', (cAliasCYV)->CYV_QTATAP)
				oModelLIST:SetValue('QTATRF', (cAliasCYV)->CYV_QTATRF)
				oModelLIST:SetValue('QTATRT', (cAliasCYV)->CYV_QTATRT)
				oModelLIST:SetValue('CDMQ'  , (cAliasCYV)->CYV_CDMQ)
				oModelLIST:SetValue('IDATQO', (cAliasCYV)->CYV_IDATQO)
				oModelLIST:SetValue('DTRPBG', STOD((cAliasCYV)->CYV_DTRPBG))
				oModelLIST:SetValue('HRRPBG', (cAliasCYV)->CYV_HRRPBG)
				oModelLIST:SetValue('DTRPED', STOD((cAliasCYV)->CYV_DTRPED))
				oModelLIST:SetValue('HRRPED', (cAliasCYV)->CYV_HRRPED)
				oModelLIST:SetValue('LGRPEO', IF((cAliasCYV)->CYV_LGRPEO == 'T', .T., .F.))

				(cAliasCYV)->(dbSkip())
			End

			(cAliasCYV)->(dbCloseArea())

			oModelLIST:SetNoInsertLine(.T.)
			oModelLIST:SetNoDeleteLine(.T.)
			oModelLIST:SetNoUpdateLine(.T.)

			oModelLIST:GoLine(1)
		Endif
	Else // Se inicia apontamento
		IF !Empty(cIDATQO)

			// Verificar se existe apontamento de produÁ„o em aberto para split
			lRet := SFCApAbeSp(cNRORPO, cIDAT, cIDATQO)

			if lRet

				dbSelectArea('CYY')
				CYY->(dbSetOrder(1))
				CYY->(dbGoTop())
				if CYY->(dbSeek(xFilial('CYY')+cNRORPO+cIDAT+cIDATQO))
					if Empty(CYY->CYY_CDMQ)
						if !IsInCallStack('SFCA314MAQ')
							oModelCYV:ClearField('CYV_CDMQ')
						Endif
					Else
						if !oModelCYV:SetValue('CYV_CDMQ',CYY->CYY_CDMQ)
							lRet := .F.
						Endif
					Endif
				Else
					oModelCYV:ClearField('CYV_CDMQ')
				Endif
			Endif
		Endif
	Endif
Endif

// Quando for preenchida ordem de produÁ„o, preencher depÛsito e documento
If nTipo == 1 .AND. !lInicia
	oModelCYV:SetValue('CYV_CDDP', POSICIONE('CYQ',1,xFilial('CYQ')+cNRORPO,'CYQ_CDDP'))
	oModelCYV:SetValue('CYV_NRDO', cNRORPO)
Endif

RestArea(aAreaCYB)
RestArea(aAreaCYY)
RestArea(aArea)

Return lRet

//*******************************************************************************************************/
//
//  Fim ValidaÁıes
//
//*******************************************************************************************************/

//*******************************************************************************************************
//
//  InÌcio Gatilhos de Campos
//
//*******************************************************************************************************

//-------------------------------------------------------------------
// Gatilho para calculo de quantidade reportada a partir dos contatores
//-------------------------------------------------------------------
Function SFCA314CON(nIni, nFim)
Local nQuant  := M->CYV_QTATRP
Local lInicia := IsInCallStack('SFCA319INI')

IF !lInicia

	Pergunte('SFCA310A',.F.)

	dbSelectArea('CYB')
	CYB->(dbSetOrder(1))
	CYB->(dbSeek(xFilial('CYB')+M->CYV_CDMQ))

	IF CYB->CYB_LGMED .AND. MV_PAR01 == 2 /*Sim*/ .AND. nIni <= nFim
		if Empty(CYB->CYB_DSFUEY)
			nQuant := nFim - nIni
		Elseif ExistBlock(CYB->CYB_DSFUEY)
			nQuant := ExecBlock(CYB->CYB_DSFUEY,.F.,.F., {nIni, nFim})
		Endif
	Endif
Endif

Return nQuant

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
Function SFCA314FER ()
Local oModel    := FWMODELACTIVE()
Local oModelCZ0 := oModel:GetModel( 'CZ0DETAIL' )
Local nI		:= 0
Local nCicloSeg := 0
Local cMaquina  := ''

if IsInCallStack('SFCA318ATV')
	cMaquina := oModel:GetValue('MAQMASTER','CYV_CDMQ')
Else
	cMaquina := oModel:GetValue('CYVMASTER','CYV_CDMQ')
Endif

For nI := 1 To oModelCZ0:Length()
	oModelCZ0:GoLine( nI )

	If !oModelCZ0:IsDeleted()
		dbSelectArea('CYC')
		CYC->(dbSetOrder(1))
		if CYC->(dbSeek(xFilial('CYC')+cMaquina+'2'+oModelCZ0:GetValue('CZ0_CDFE')))

			dbSelectArea('CYH')
			CYH->(dbSetOrder(1))
			CYH->(dbSeek(xFilial('CYH')+'2'+oModelCZ0:GetValue('CZ0_CDFE')))

			Do Case
				Case CYC->CYC_TPUNTE == '1'
					nCicloSeg := CYC->CYC_QTCI / 3600
				Case CYC->CYC_TPUNTE == '2'
					nCicloSeg := CYC->CYC_QTCI / 60
				Case CYC->CYC_TPUNTE == '3'
					nCicloSeg := CYC->CYC_QTCI
				Case CYC->CYC_TPUNTE == '4'
					nCicloSeg := CYC->CYC_QTCI / 86400
			End Case

			oModelCZ0:SetValue('CZ0_QTTEUN',INT(oModel:GetValue('CYVMASTER','CYV_QTATRP') / (CYH->CYH_QTUNCI * nCicloSeg)))
		Endif
	Endif
Next

Return lRet
//-------------------------------------------------------------------
// Gatilho CZ0_CDFE
// Input: Ferramenta
// Retorno:
//-------------------------------------------------------------------
Function SFCA314CFE( cFerram )

// SÛ recalcula data final se for dependente de ferramenta
dbSelectArea('CY9')
CY9->(dbSetOrder(1))
CY9->(dbSeek(xFilial('CY9')+CYY->CYY_NRORPO+CYY->CYY_IDAT))
IF CY9->CY9_TPTE == '4'
	// Recalcula os tempos das ferramentas
	SFCA314FER()

	// Recalcula data final
	SFCA314DRB()
Endif

Return cFerram

//-------------------------------------------------------------------
// Gatilho CY0_QTRF, CY0_QTRT
// Input: Model do browse
// Retorno:
//-------------------------------------------------------------------
Function SFCA314QRR( nQtd )
Local nI 		:= 0
Local nTotalRet := 0
Local nTotalRef := 0
Local oModel    := FWMODELACTIVE()
Local oModelCY0 := oModel:GetModel( 'CY0DETAIL' )
Local aArea     := GetArea()
Local aAreaCYO  := CYO->( GetArea() )

SFCA314CQR(oModelCY0,2)

For nI := 1 To oModelCY0:Length()

	oModelCY0:GoLine( nI )

	dbSelectArea('CYO')
    CYO->(dbSetOrder(1))
    CYO->(dbGoTop())
    if CYO->(dbSeek(xFilial('CYO')+oModelCY0:GetValue('CY0_CDRF')))

     	If !oModelCY0:IsDeleted()
     		nTotalRet += oModelCY0:GetValue("CY0_QTRT")
	     	nTotalRef += oModelCY0:GetValue("CY0_QTRF")
     	EndIf
	Endif
next

oModel:LoadValue('CYVMASTER','CYV_QTATRF', nTotalRef)
oModel:LoadValue('CYVMASTER','CYV_QTATRT', nTotalRet)

oModel:LoadValue('CYVMASTER','CYV_QTATAP', MAX(oModel:GetValue('CYVMASTER','CYV_QTATRP') - oModel:GetValue('CYVMASTER','CYV_QTATRF'),0))

RestArea( aAreaCYO )
RestArea( aArea )

Return nQtd

//-------------------------------------------------------------------
// Gatilho CYV_CDMQ
// Carregar turno a partir da maquina informada
//
// Input: M·quina, Data Inicial, Data Final
//-------------------------------------------------------------------
Function SFCA314Maq ()
Local oModel    := FWMODELACTIVE()
Local oModelCYV := oModel:GetModel( 'CYVMASTER' )
Local cMaquina  := ''
Local cAliasCYY
Local cNRORPO   := oModelCYV:GetValue('CYV_NRORPO')
Local cIDAT     := oModelCYV:GetValue('CYV_IDAT')
Local lPre      := .T.
Local lInicia   := IsInCallStack('SFCA319INI') .Or. SFCA314IF(oModel, 1)
Local aRetorno  := {}

if IsInCallStack('SFCA318ATV')
	cMaquina := oModel:GetValue('MAQMASTER','CYV_CDMQ')
Else
	cMaquina := oModelCYV:GetValue('CYV_CDMQ')
Endif

IF !Empty(cMaquina)

	if Empty(oModelCYV:GetValue('CYV_IDATQO'))
		cAliasCYY := GetNextAlias()

		BeginSql Alias cAliasCYY

			SELECT COUNT(*) AS QTD FROM %Table:CYY% CYY
				WHERE CYY.CYY_FILIAL=%xFilial:CYY% AND
					  CYY.CYY_NRORPO=%Exp:cNRORPO% AND
					  CYY.CYY_IDAT=%Exp:cIDAT% AND
					  CYY.CYY_CDMQ=%Exp:cMaquina% AND
					  CYY.%NotDel%

		EndSql

		IF (cAliasCYY)->QTD == 1
			oModelCYV:SetValue('CYV_IDATQO',POSICIONE('CYY',7,xFilial('CYY')+cNRORPO+cIDAT+cMaquina,'CYY_IDATQO'))
			lPre := .F.
		Endif

		(cAliasCYY)->(dbCloseArea())
	Endif

	IF lInicia
		aRetorno := SFCA314ULT(cNRORPO, cIDAT, oModelCYV:GetValue('CYV_IDATQO'), cMaquina)

		oModelCYV:SetValue('CYV_DTRPBG', aRetorno[1])
		oModelCYV:SetValue('CYV_HRRPBG', SFCXSegToHour(aRetorno[2]))
	ElseIf (lPre .And. !IsInCallStack('SFCA314PRE') .And. !IsInCallStack('SFCA314VSP')) .Or. (Type("lCalcTempo") != "U" .And. lCalcTempo)
		SFCA314PRE(oModel, 1)
	Endif
Endif

return cMaquina

//-------------------------------------------------------------------
// Gatilho CYV_DTRPBG,CYV_HRRPBG - Data inicial do reporte
//-------------------------------------------------------------------
Function SFCA314DRB()
Local oModel    := FWMODELACTIVE()
Local oModelCYV := oModel:GetModel( 'CYVMASTER' )
Local dIni      := oModelCYV:GetValue('CYV_DTRPBG')
Local cIni      := oModelCYV:GetValue('CYV_HRRPBG')
Local cNRORPO   := oModelCYV:GetValue('CYV_NRORPO')
Local cIDAT     := oModelCYV:GetValue('CYV_IDAT')
Local dFim
Local cFim
Local aRetorno  := {}
Local a2Retorno := {}
Local cMaquina  := ''
Local nLinha    := 0
Local IsSFCA318 := IsInCallStack('SFCA318ATV')
Local lInicia   := IsInCallStack('SFCA319INI') .Or. SFCA314IF(oModel, 1)

if !Empty(dIni) .AND. !lInicia

	if IsSFCA318
		cMaquina := oModel:GetValue('MAQMASTER','CYV_CDMQ')
		nLinha   := oModelCYV:GetLine()
	Else
		cMaquina := oModelCYV:GetValue('CYV_CDMQ')
	Endif

	If GetMv("MV_SFCTPRE") == '2'
		cIni := SFCXCENTOHR(oModelCYV:GetValue('CYV_HCRPBG'))
		oModelCYV:LoadValue('CYV_HRRPBG',cIni)
	Endif

	dbSelectArea('CYB')
	CYB->(dbSetOrder(1))
	CYB->(dbSeek(xFilial('CYB')+cMaquina))

	aRetorno := SFCA314OPER(CYB->CYB_CDCETR,cNRORPO,cIDAT,oModelCYV:GetValue('CYV_QTATRP'),1)

	//Calcula tempos
	//Retorna: 1-ct,2-calend,3-data fim,4-hora fim,5-data ini,6-hora ini,7-tempo,8-turno,9-num turno,10-extra
	a2Retorno := SFCA314TPM(CYB->CYB_CDCETR,cMaquina,'',CTOD('01/01/0001'),0,dIni,SFCXHourToSeg(cIni),aRetorno[1] / 3600)

	dIni := a2Retorno[5]
	cIni := SFCXSegToHour(a2Retorno[6])
	dFim := a2Retorno[3]
	cFim := SFCXSegToHour(a2Retorno[4])

	oModelCYV:LoadValue('CYV_DTRPBG',dIni)
	oModelCYV:LoadValue('CYV_HRRPBG',cIni)
	oModelCYV:LoadValue('CYV_DTRPED',dFim)
	oModelCYV:LoadValue('CYV_HRRPED',cFim)
	oModelCYV:LoadValue('CYV_HRTERP',ROUND(a2Retorno[7],4))
	oModelCYV:LoadValue('CYV_QTTERP',a2Retorno[7] * 3600)
	oModelCYV:LoadValue('CYV_QTTEEX',a2Retorno[10])

	If GetMv("MV_SFCTPRE") == '2'
		oModelCYV:LoadValue('CYV_HCRPBG',SFCXSegtoCent(a2Retorno[6]))
		oModelCYV:LoadValue('CYV_HCRPED',SFCXSegtoCent(a2Retorno[4]))
	Endif

	IF !Empty(a2Retorno[9])
		oModelCYV:SetValue('CYV_CDTN',a2Retorno[8])
		oModelCYV:SetValue('CYV_NRTN',STRZERO(VAL(a2Retorno[9]), 5))
	Endif

	SFCA314MOD(dIni,cIni,dFim,cFim,cMaquina)
	SFCA314GGF(ROUND(a2Retorno[7],4),cMaquina)

	if IsSFCA318 .AND. !IsInCallStack('SFCA314REC')
		SFCA314REC(oModelCYV:GetLine(),dFim,cFim)
	Endif

	if IsSFCA318
		oModelCYV:GoLine(nLinha)
	Endif
Endif

Return dIni

//-------------------------------------------------------------------
// Gatilho CYV_DTRPED,CYV_HRRPED - Data final do reporte
//-------------------------------------------------------------------
Function SFCA314DRE()
Local oModel    := FWMODELACTIVE()
Local oView     := FwViewActive()
Local aAreaCYX  := CYX->(GetArea())
Local aAreaCYY  := CYY->(GetArea())
Local aRetorno  := {}
Local oModelCYV := oModel:GetModel( 'CYVMASTER' )
Local cFim      := oModelCYV:GetValue('CYV_HRRPED')
Local cIDAT     := oModelCYV:GetValue('CYV_IDAT')
Local cIni      := oModelCYV:GetValue('CYV_HRRPBG')
Local cMaquina  := ''
Local cNRORPO   := oModelCYV:GetValue('CYV_NRORPO')
Local dFim      := oModelCYV:GetValue('CYV_DTRPED')
Local dIni      := oModelCYV:GetValue('CYV_DTRPBG')
Local IsSFCA318 := IsInCallStack('SFCA318ATV')
Local nLinha    := 0

If !EMPTY(oModelCYV:GetValue('GER_PARANT'))
	dbSelectArea("CYX")
	CYX->(dbSetOrder(1))
	If CYX->(dbSeek(oModelCYV:GetValue('GER_PARANT')))
		dIni := CYX->CYX_DTEDSP
		cIni := CYX->CYX_HREDSP
	EndIf
	CYX->(dbCloseArea())
EndIf
RestArea(aAreaCYX)

if !Empty(dFim)
	if IsSFCA318
		cMaquina := oModel:GetValue('MAQMASTER','CYV_CDMQ')
		nLinha   := oModelCYV:GetLine()
	Else
		cMaquina := oModelCYV:GetValue('CYV_CDMQ')
	Endif

	If GetMv("MV_SFCTPRE") == '2'
		cFim := SFCXCENTOHR(oModelCYV:GetValue('CYV_HCRPED'))
		oModelCYV:LoadValue('CYV_HRRPED',cFim)
	Endif

	// Verifica se colocou uma data/hora final menor que a inicial
	If dFim == dIni .AND. cFim <= cIni .OR.;
	   dFim < dIni

		if !IsInCallStack('SFCA320') .And. !IsInCallStack('SFCA311DAP') .And. !IsInCallStack('GeraApoOrd')
			MsgAlert(STR0081, 'SFCA314') // 'Data e Hora final devem ser maiores que Data e Hora inicial'
		Endif

		if dFim < dIni
			dFim := dIni
		Endif
	Else
		aRetorno := SFCA314ABG(cMaquina,cNRORPO,cIDAT,oModelCYV:GetValue('CYV_IDATQO'),dFim,cFim,oModelCYV:GetValue('CYV_QTATRP'),dIni,cIni,oModelCYV:GetValue('CYV_QTTERP') / 3600)

		dIni := aRetorno[1]
		cIni := aRetorno[2]
		dFim := aRetorno[3]
		cFim := aRetorno[4]

		oModelCYV:LoadValue('CYV_DTRPBG',dIni)
		oModelCYV:LoadValue('CYV_HRRPBG',cIni)
		oModelCYV:LoadValue('CYV_DTRPED',dFim)
		oModelCYV:LoadValue('CYV_HRRPED',cFim)
		oModelCYV:LoadValue('CYV_HRTERP',ROUND(aRetorno[5] + aRetorno[8],4))
		oModelCYV:LoadValue('CYV_QTTERP',(aRetorno[5] + aRetorno[8]) * 3600)
		oModelCYV:LoadValue('CYV_QTTEEX',aRetorno[8] * 3600)

		If GetMv("MV_SFCTPRE") == '2'
			oModelCYV:LoadValue('CYV_HCRPBG',SFCXHRTOCEN(cIni))
			oModelCYV:LoadValue('CYV_HCRPED',SFCXHRTOCEN(cFim))
		Endif

		oModelCYV:SetValue('CYV_CDTN',aRetorno[6])
		oModelCYV:SetValue('CYV_NRTN',aRetorno[7])

		if IsSFCA318.AND. !IsInCallStack('SFCA314REC')
			SFCA314REC(oModelCYV:GetLine(),dFim,cFim)
		Endif

		if IsSFCA318
			oView:Refresh()

			oModelCYV:GoLine(nLinha)
		Endif

		SFCA314GGF(oModelCYV:GetValue('CYV_HRTERP'),cMaquina)
		SFCA314MOD(dIni,cIni,dFim,cFim,cMaquina)
	Endif
Endif

RestArea(aAreaCYY)

Return dFim

//-------------------------------------------------------------------
// Gatilho CYV_DTBGSU/CYV_HRBGSU - Data/Hora InÌcio
//-------------------------------------------------------------------
Function SFCA314DIS()
Local aArea     := GetArea()
Local aAreaCYY  := CYY->(GetArea())
Local aRetorno  := {}
Local oModel    := FWMODELACTIVE()
Local oModelCYV := oModel:GetModel( 'CYVMASTER' )
Local cMaquina  := ''
Local nLinha    := 0
Local IsSFCA318 := IsInCallStack('SFCA318ATV')

if IsSFCA318
	cMaquina := oModel:GetValue('MAQMASTER','CYV_CDMQ')
	nLinha   := oModelCYV:GetLine()
Else
	cMaquina := oModelCYV:GetValue('CYV_CDMQ')
Endif

If GetMv("MV_SFCTPRE") == '2'
	oModelCYV:LoadValue('CYV_HRBGSU',SFCXCENTOHR(oModelCYV:GetValue('CYV_HCBGSU')))
Endif

dbSelectArea('CYY')
CYY->(dbSetOrder(1))
CYY->(dbSeek(xFilial('CYY')+oModelCYV:GetValue('CYV_NRORPO')+oModelCYV:GetValue('CYV_IDAT')+oModelCYV:GetValue('CYV_IDATQO')))

// Ajusta data fim de setup
// Retorna: data fim setup, hora fim setup, data inicio reporte, hora inicio reporte,data fim reporte, hora fim reporte,turno
aRetorno := SFCA314AFS(cMaquina,oModelCYV:GetValue('CYV_DTBGSU'),oModelCYV:GetValue('CYV_HRBGSU'),oModelCYV:GetValue('CYV_HRTERP'),CYY->CYY_QTPASU)

oModelCYV:LoadValue('CYV_DTEDSU', aRetorno[1])
oModelCYV:LoadValue('CYV_HREDSU', aRetorno[2])
oModelCYV:SetValue('CYV_DTRPBG', aRetorno[3])
oModelCYV:SetValue('CYV_HRRPBG', aRetorno[4])

If GetMv("MV_SFCTPRE") == '2'
	oModelCYV:LoadValue('CYV_HCEDSU',SFCXHRTOCEN(aRetorno[2]))
	oModelCYV:SetValue('CYV_HCRPBG',SFCXHRTOCEN(aRetorno[4]))
Endif

if !Empty(aRetorno[7])
	oModelCYV:SetValue('CYV_CDTN', aRetorno[7])
	oModelCYV:SetValue('CYV_NRTN', STRZERO(VAL(aRetorno[8]), 5))
Endif

if IsSFCA318
	SFCA314REC(oModelCYV:GetLine(),oModelCYV:GetValue('CYV_DTRPED'),oModelCYV:GetValue('CYV_HRRPED'))

	oModelCYV:GoLine(nLinha)
Endif

RestArea(aAreaCYY)
RestArea(aArea)

Return oModelCYV:GetValue('CYV_DTBGSU')

//-------------------------------------------------------------------
// Gatilho CYV_DTEDSU/CYV_HREDSU - Data/Hora Fim Setup
//-------------------------------------------------------------------
Function SFCA314DFS()
Local aArea     := GetArea()
Local oModel    := FWMODELACTIVE()
Local oModelCYV := oModel:GetModel('CYVMASTER')
Local nLinha    := 0
Local IsSFCA318 := IsInCallStack('SFCA318ATV')

if IsSFCA318
	nLinha := oModelCYV:GetLine()
Endif

oModelCYV:SetValue('CYV_DTRPBG', oModelCYV:GetValue('CYV_DTEDSU'))
oModelCYV:SetValue('CYV_HRRPBG', oModelCYV:GetValue('CYV_HREDSU'))

dFim := oModelCYV:GetValue('CYV_DTEDSU')

If GetMv("MV_SFCTPRE") == '2'
	oModelCYV:SetValue('CYV_HCRPBG', oModelCYV:GetValue('CYV_HCEDSU'))
	oModelCYV:LoadValue('CYV_HREDSU',SFCXCENTOHR(oModelCYV:GetValue('CYV_HCEDSU')))
Endif

if IsSFCA318
	SFCA314REC(oModelCYV:GetLine(),oModelCYV:GetValue('CYV_DTRPED'),oModelCYV:GetValue('CYV_HRRPED'))

	oModelCYV:GoLine(nLinha)
Endif

RestArea(aArea)

Return dFim

//-------------------------------------------------------------------
// Gatilho CYV_QTATRP - Quantidade Reportada
//-------------------------------------------------------------------
Function SFCA314QTR ()
Local aArea     := GetArea()
Local aAreaCYY  := CYY->(GetArea())
Local aAreaCYB  := CYB->(GetArea())
Local aAreaCYI  := CYI->(GetArea())
Local aRetorno  := {}
Local nOper     := 0
Local oView     := FWViewActive()
Local oModel    := FWMODELACTIVE()
Local oModelCYV := oModel:GetModel( 'CYVMASTER' )
Local oModelCZP := oModel:GetModel( 'CZPDETAIL' )
Local cNRORPO   := oModelCYV:GetValue('CYV_NRORPO')
Local cIDAT     := oModelCYV:GetValue('CYV_IDAT')
Local cIDATQO   := oModelCYV:GetValue('CYV_IDATQO')
Local dDTRPBG   := oModelCYV:GetValue('CYV_DTRPBG')
Local cHRRPBG   := oModelCYV:GetValue('CYV_HRRPBG')
Local dDTRPED   := oModelCYV:GetValue('CYV_DTRPED')
Local cHRRPED   := oModelCYV:GetValue('CYV_HRRPED')
Local nQTATRP   := oModelCYV:GetValue('CYV_QTATRP')
Local nQTATAP   := 0
Local cMaquina  := ''
Local IsSFCA318 := IsInCallStack('SFCA318ATV')

if IsSFCA318
	cMaquina := oModel:GetValue('MAQMASTER','CYV_CDMQ')
Else
	cMaquina := oModelCYV:GetValue('CYV_CDMQ')
Endif

dbSelectArea('CYB')
CYB->(dbSetOrder(1))
CYB->(dbGoTop())
if CYB->(dbSeek(xFilial('CYB')+cMaquina))

	dbSelectArea('CYY')
	CYY->(dbSetOrder(1))
	CYY->(dbSeek(xFilial('CYY')+cNRORPO+cIDAT+cIDATQO))

	if IsSFCA318
		oModelCYV:GoLine(oView:GetLine('CYVMASTER'))
	Endif

	nQTATAP := MAX(nQTATRP - oModelCYV:GetValue('CYV_QTATRF'),0)
	oModelCYV:LoadValue('CYV_QTATAP', nQTATAP)

	SFCA314FER() // Recalcula os tempos de ferramentas

	dbSelectArea('CYI')
	CYI->(dbSetOrder(1))
	CYI->(dbGoTop())
	IF CYI->(dbSeek(xFilial('CYI')+CYB->CYB_CDCETR))
		// Calcula tempo de operaÁ„o - Retorna: 1-nTempoOper,2-nTempoHomem,3-nCargaPad
		// pi-calcula-tempo-qtd - sfapi009.p
		aRetorno := SFCA314OPER(CYI->CYI_CDCETR,cNRORPO,cIDAT,nQTATRP,1)
		nOper    := aRetorno[1] / 3600

		//Calcula tempos
		//Retorna: 1-ct,2-calend,3-data fim,4-hora fim,5-data ini,6-hora ini,7-tempo,8-turno,9-num turno,10-extra
		aRetorno := SFCA314TPM(CYB->CYB_CDCETR,cMaquina,'',CTOD('01/01/0001'),0,dDTRPBG,SFCXHourToSeg(cHRRPBG),nOper)

		dDTRPED := aRetorno[3]
		cHRRPED := SFCXSegToHour(aRetorno[4])
		nOper   := aRetorno[7]

		oModelCYV:LoadValue('CYV_DTRPED', dDTRPED)
		oModelCYV:LoadValue('CYV_HRRPED', cHRRPED)
		oModelCYV:LoadValue('CYV_HRTERP', nOper)
		oModelCYV:LoadValue('CYV_QTTERP', nOper * 3600)
		oModelCYV:LoadValue('CYV_QTTEEX', aRetorno[10] * 3600)

		If GetMv("MV_SFCTPRE") == '2'
			oModelCYV:LoadValue('CYV_HCRPED',SFCXHRTOCEN(cHRRPED))
		Endif

		if !Empty(aRetorno[9])
			oModelCYV:SetValue('CYV_CDTN', aRetorno[8])
			oModelCYV:SetValue('CYV_NRTN', STRZERO(VAL(aRetorno[9]), 5))
		Endif
	Endif

	SFCA314CRE(cNRORPO,cIDAT,oModelCZP,nQTATRP,CYY->CYY_QTAT) // Recalcula quantidade das reservas
	SFCA314GGF(nOper,cMaquina) // Recalcula GGF
	SFCA314MOD(dDTRPBG,cHRRPBG,dDTRPED,cHRRPED,cMaquina) // Recalcula M„o-de-Obra

	// Atualiza percentual de avanÁo
	oModelCYV:SetValue('CYV_VLPNRY', SFCA314AVA(cNRORPO, cIDAT, cIDATQO, nQTATRP, nQTATAP))

	if IsSFCA318 // Para dispatch list, recalcula apontamentos seguintes
		SFCA314REC(oModelCYV:GetLine(),dDTRPED,cHRRPED)
	Endif
Endif

RestArea(aAreaCYY)
RestArea(aAreaCYB)
RestArea(aAreaCYI)
RestArea(aArea)

Return nQTATRP

//-------------------------------------------------------------------
// Gatilho cÛdigo centro de trabalho
//-------------------------------------------------------------------
Function SFCA314CCT()
Local oModel    := FWMODELACTIVE()
Local oModelCYV := oModel:GetModel( 'CYVMASTER' )
Local oModelCZW := oModel:GetModel( 'CZWDETAIL' )
Local cNRORPO   := oModelCYV:GetValue('CYV_NRORPO')
Local cIDAT     := oModelCYV:GetValue('CYV_IDAT')
Local nTempo    := 0

dbSelectArea('CYQ')
CYQ->(dbSetOrder(1))
CYQ->(dbGoTop())
IF CYQ->(dbSeek(xFilial('CYQ')+cNRORPO)) .AND. CYQ->CYQ_NRORPO == cNRORPO

	if CYQ->CYQ_TPGGF == '2' // Padr„o
		dbSelectArea('CY9')
		CY9->(dbSetOrder(1))
		CY9->(dbGoTop())
		IF CY9->(dbSeek(xFilial('CY9')+cNRORPO+cIDAT)) .AND. CY9->CY9_NRORPO == cNRORPO .AND. CY9->CY9_IDAT == cIDAT
			nTempo := CY9->CY9_QTTEMQ
		Endif
	Endif
Endif

oModelCZW:LoadValue('CZW_HRTEGF',nTempo)

Return M->CZW_CDCETR

//*******************************************************************************************************
//
//  Fim Gatilhos de Campos
//
//*******************************************************************************************************

//*******************************************************************************************************
//
//  InÌcio FunÁıes de NegÛcio
//
//*******************************************************************************************************
//-----------------------------------------------------------------
// Validar quantidades retrabalhadas e refugadas
// Retorno:
//-----------------------------------------------------------------
Function SFCA314CQR (oModelCY0,nMens)
Local lRet      := .T.
Local aArea     := GetArea()
Local aAreaCYO  := CYO->( GetArea() )
Local oModelCYV 
Local cNRORPO   
Local cIDAT     
Local cIDATQO   
Default lAutomacao := .F.

If !lAutomacao
	oModelCYV := oModelCY0:GetModel('CYVMASTER')
	cNRORPO   := oModelCYV:GetValue('CYVMASTER','CYV_NRORPO')
	cIDAT     := oModelCYV:GetValue('CYVMASTER','CYV_IDAT')
	cIDATQO   := oModelCYV:GetValue('CYVMASTER','CYV_IDATQO')
EndIf

dbSelectArea('CYO')
CYO->(dbSetOrder(1))
CYO->(dbGoTop())

If !lAutomacao
	If CYO->(dbSeek(xFilial('CYO')+oModelCY0:GetValue('CY0_CDRF')))
		if !CYO->CYO_LGRT
			If !Empty(oModelCY0:GetValue("CY0_QTRT"))
				SFCMsgErro(STR0055 + oModelCY0:GetValue('CY0_CDRF') + NEWLINE +; // "Quantidade retrabalhada n„o deve ser informada para "
        				   STR0017 + cNRORPO + NEWLINE +; // " Ordem: "
				     	   STR0018 + cIDAT + NEWLINE +  ; // " OperaÁ„o: "
			    	 	   STR0041 + cIDATQO , "SFCA314", nMens) // " Split: "
				lRet := .F.
			Endif
		Endif

		if !CYO->CYO_LGRFMP
			If !Empty(oModelCY0:GetValue("CY0_QTRF"))
				SFCMsgErro(STR0056 + oModelCY0:GetValue('CY0_CDRF') + NEWLINE +; // "Quantidade refugada n„o deve ser informada para "
        				   STR0017 + cNRORPO + NEWLINE +; // " Ordem: "
			    	 	   STR0018 + cIDAT + NEWLINE +  ; // " OperaÁ„o: "
			     		   STR0041 + cIDATQO , "SFCA314", nMens) // " Split: "
				lRet := .F.
			Endif
		Endif
	EndIf
EndIf

if lRet
	If !lAutomacao
		if oModelCY0:IsUpdated() .AND. Empty(oModelCY0:GetValue("CY0_QTRT")) .AND. Empty(oModelCY0:GetValue("CY0_QTRF"))
			SFCMsgErro(STR0057 + NEWLINE +;  // "Nenhuma quantidade foi informada para refugo ou retrabalho"
				       STR0017 + cNRORPO + NEWLINE +; // " Ordem: "
				       STR0018 + cIDAT + NEWLINE +  ; // " OperaÁ„o: "
				       STR0041 + cIDATQO , "SFCA314", nMens) // " Split: "
			lRet := .F.
		Endif
	EndIf
Endif

RestArea(aArea)
RestArea(aAreaCYO)

Return lRet

//-----------------------------------------------------------------
// Calcula tempo de operaÁ„o
//
// Input: M·quina
//-----------------------------------------------------------------
Function SFCA314OPER ( cCDCETR, cNRORPO, cIDAT, nQtd, nTipo, cCDFE) // CalcularTempoPadraoO - boin535.i21
Local nCargaPad   := 0
Local nCargaBatch := 0
Local nLote       := 0
Local nLoteOrig   := 0
Local nI		  := 0
Local nTempoOper  := 0
Local nTempoHomem := 0
Local nFator	  := 0
Local aRetorno    := {}
Local oModel, oModelCZ0
Local aArea       := GetArea()
Local aAreaCYC    := CYC->( GetArea() )
Local aAreaCY9    := CY9->( GetArea() )
Local aAreaCYI    := CYI->( GetArea() )
Local aAreaCYH    := CYH->( GetArea() )
Local aRows

if nTipo == 1
	aRows     := FwSaveRows()
	oModel    := FWMODELACTIVE()
	oModelCZ0 := oModel:GetModel( 'CZ0DETAIL' )
Endif

if !Empty(cCDCETR)

	dbSelectArea('CYI')
	CYI->(dbSetOrder(1))
	if CYI->(dbSeek(xFilial('CYI')+cCDCETR))

		dbSelectArea('CY9')
		CY9->(dbSetOrder(1))
		if CY9->(dbSeek(xFilial('CY9')+cNRORPO+cIDAT))

			Do case // 1-hora,2-minutos,3-segundos,4-dias
				case CY9->CY9_TPUNTE == '1'
					nfator := 3600
				case CY9->CY9_TPUNTE == '2'
		            nfator := 60
				case CY9->CY9_TPUNTE == '3'
		            nfator := 1
				case CY9->CY9_TPUNTE == '4'
		            nfator := 86400
		    endcase

		    if CY9->CY9_QTAT != 0
		    	nCargaPad := CY9->CY9_QTVM * nQtd / CY9->CY9_QTAT
		    Endif

		    nCargaBatch := CY9->CY9_QTCG

			Do Case
				Case CY9->CY9_TPTE == '1' // proporcional
					nTempoOper  := if(CY9->CY9_QTAT == 0,0,CY9->CY9_QTTEMQ * nfator * nQtd / CY9->CY9_QTAT)
					nTempoHomem := if(CY9->CY9_QTAT == 0,0,CY9->CY9_QTTERC * nfator * nQtd / CY9->CY9_QTAT)
				Case CY9->CY9_TPTE == '2' // fixo
					nTempoOper  := CY9->CY9_QTTEMQ * nfator
					nTempoHomem := CY9->CY9_QTTERC * nfator
				Case CY9->CY9_TPTE == '3' // lote

					nCargaBatch := CYI->CYI_QTCG

					if nCargaBatch == 0
						nCargaBatch := nCargaPad
					Endif

					nLote := nCargaPad / nCargaBatch
					nLote := if(round(nLote,0) < (nLote * 0.995),round(nLote,0) + 1,round(nLote,0))

					if CY9->CY9_QTVM / CY9->CY9_QTCG != 1
						nLoteOrig := CY9->CY9_QTVM / CY9->CY9_QTCG
						nLoteOrig := if(round(nLoteOrig,0) < (nLoteOrig * 0.995),round(nLoteOrig,0) + 1,round(nLoteOrig,0))
					Else
						nLoteOrig := 1
					Endif

					nTempoOper  := CY9->CY9_QTTEMQ * nFator / nLoteOrig * nLote
					nTempoHomem := CY9->CY9_QTTERC * nFator / nLoteOrig * nLote

				Case CY9->CY9_TPTE == '4' // dep ferramenta
					if nTipo == 1
				    	For nI := 1 To oModelCZ0:Length()
							oModelCZ0:GoLine( nI )

							If (!oModelCZ0:IsDeleted() .OR. IsInCallStack('UNDELETELINE')) .AND. oModelCZ0:IsUpdated() .AND. nTempoOper < oModelCZ0:GetValue('CZ0_QTTEUN')
								nTempoOper  := oModelCZ0:GetValue('CZ0_QTTEUN')
								nTempoHomem := nTempoOper
							Endif
				 		Next
				 	Else
				 		dbSelectArea('CYH')
						CYH->(dbSetOrder(1))
						if CYH->(dbSeek(xFilial('CYH')+'2'+cCDFE))

							dbSelectArea('CYC')
							CYC->(dbSetOrder(1))
							if CYC->(dbSeek(xFilial('CYC')+'2'+cCDFE))
								Do Case
							   		Case CYC->CYC_TPUNTE == '1'
							   			nCicloSeg := CYC->CYC_QTCI / 3600
						        	Case CYC->CYC_TPUNTE == '2'
						               	nCicloSeg := CYC->CYC_QTCI / 60
						            Case CYC->CYC_TPUNTE == '3'
						               	nCicloSeg := CYC->CYC_QTCI
						            Case CYC->CYC_TPUNTE == '4'
						               	nCicloSeg := CYC->CYC_QTCI / 86400
								End Case
							Endif

							nTempoOper := nQtd / (CYH->CYH_QTUNCI * nCicloSeg)
						Endif
					Endif
			Endcase
		Endif

		nTempoOper := IF(CYI->CYI_TPPC != '4',nTempoOper,nTempoHomem)
	Endif
Endif

RestArea( aAreaCYI )
RestArea( aAreaCY9 )
RestArea( aAreaCYH )
RestArea( aAreaCYC )
RestArea( aArea )

AADD(aRetorno,nTempoOper)
AADD(aRetorno,nCargaPad)

Return aRetorno

//-------------------------------------------------------------------
// Verificar se apontamento de produÁ„o existe no perÌodo informado
//
// Input: m·quina, data inicial, data final, hora inicial, hora final
//-------------------------------------------------------------------
Function SFCA314VAP ( cMaq, dIni, dFim, cHoraIni, cHoraFim )
	Local aArea  := GetArea()
	Local cIni   := dToS(dIni)
	Local cFim   := dToS(dFim)
	Local cTmp   := GetNextAlias()
	Local aRet   := {}
	Local cQuery := ""

	cQuery := " SELECT CYV.CYV_NRSQRP, CYV.CYV_DTRPBG, CYV.CYV_HRRPBG, CYV.CYV_DTRPED, CYV.CYV_HRRPED, "
	cQuery +=   " ( "
	cQuery +=     " SELECT COUNT(*) "
	cQuery +=       " FROM " + RetSqlName("CYY") + " CYY "
	cQuery +=      " WHERE CYY_TPSTAT = '5' "
	cQuery +=        " AND CYY.D_E_L_E_T_ = ' ' "
	If "MSSQL" $ AllTrim(Upper(TCGETDB()))
		cQuery +=    " AND CYY.CYY_FILIAL+CYY.CYY_NRORPO+CYY.CYY_IDAT+CYY.CYY_IDATQO = CYV.CYV_FILIAL+CYV.CYV_NRORPO+CYV.CYV_IDAT+CYV.CYV_IDATQO "
	Else
		cQuery +=    " AND CYY.CYY_FILIAL||CYY.CYY_NRORPO||CYY.CYY_IDAT||CYY.CYY_IDATQO = CYV.CYV_FILIAL||CYV.CYV_NRORPO||CYV.CYV_IDAT||CYV.CYV_IDATQO "
	EndIf
	cQuery +=   " ) AS SPTFIN "
	cQuery +=   " FROM " + RetSqlName("CYV") + " CYV "
	cQuery +=  " WHERE CYV_FILIAL     = '" + xFilial("CYV") + "' "
	cQuery +=    " AND CYV_CDMQ       = '" + cMaq + "' "
	cQuery +=    " AND CYV.D_E_L_E_T_ = ' ' "
	cQuery +=    " AND CYV_LGRPEO     = 'F' "
	cQuery +=    " AND CYV_TPSTRP     <> '1' "
	cQuery +=    " AND ( "
	cQuery +=      " ( "
	cQuery +=        " ( "
	cQuery +=          " CYV_DTRPBG < '" + cIni + "' OR "
	cQuery +=          " CYV_DTRPBG = '" + cIni + "' AND CYV_HRRPBG <= '" + cHoraIni + "' "
	cQuery +=        " ) AND ( "
	cQuery +=          " CYV_DTRPED > '" + cIni + "' OR "
	cQuery +=          " CYV_DTRPED = '" + cIni + "' AND CYV_HRRPED > '" + cHoraIni + "' "
	cQuery +=        " ) "
	cQuery +=      " ) OR ( "
	cQuery +=        " ( "
	cQuery +=          " CYV_DTRPBG < '" + cFim + "' OR "
	cQuery +=          " CYV_DTRPBG = '" + cFim + "' AND CYV_HRRPBG < '" + cHoraFim + "' "
	cQuery +=        " ) AND ( "
	cQuery +=          " CYV_DTRPED > '" + cFim + "' OR "
	cQuery +=          " CYV_DTRPED = '" + cFim + "' AND CYV_HRRPED >= '" + cHoraFim + "' "
	cQuery +=        " ) "
	cQuery +=      " ) OR ( "
	cQuery +=        " ( "
	cQuery +=          " CYV_DTRPBG > '" + cIni + "' OR "
	cQuery +=          " CYV_DTRPBG = '" + cIni + "' AND CYV_HRRPBG >= '" + cHoraIni + "' "
	cQuery +=        " ) AND ( "
	cQuery +=          " CYV_DTRPED < '" + cFim + "' OR "
	cQuery +=          " CYV_DTRPED = '" + cFim + "' AND CYV_HRRPED < '" + cHoraFim + "' "
	cQuery +=        " ) "
	cQuery +=      " ) "
	cQuery +=    " ) "

	cQuery := ChangeQuery(cQuery)

	dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cTmp, .T., .F. )

	While !(cTmp)->(Eof())
		aAdd(aRet, {(cTmp)->CYV_NRSQRP, (cTmp)->SPTFIN, (cTmp)->CYV_DTRPBG, (cTmp)->CYV_HRRPBG, (cTmp)->CYV_DTRPED, (cTmp)->CYV_HRRPED} )
		(cTmp)->(dbSkip())
	End

	(cTmp)->(dbCloseArea())

	RestArea(aArea)

Return aRet

//-------------------------------------------------------------------
// Verificar se apontamento de parada existe no perÌodo informado
//
// Input: data inicial, data final, hora inicial, hora final
//-------------------------------------------------------------------
Function SFCA314VPA( cMaq, dIni, dFim, cHoraIni, cHoraFim, nQtdPreenchido, nPK, cPkPenult )
	Local aArea     := GetArea()
	Local cAliasQry := GetNextAlias()
	local cBanco    := AllTrim(Upper(TCGETDB()))
	Local cFim      := dToS(dFim)
	Local cIni      := dToS(dIni)
	Local cQuery    := ""
	Local cTmp      := GetNextAlias()
	Local nQtd      := 0
	Default nQtdPreenchido := 0

	cQuery := " SELECT "
	cQuery +=	 " COUNT(*) AS QTD, "
	cQuery +=	 " COUNT( "
	cQuery +=	   " CASE WHEN ( "
	cQuery +=	     " ( "
	cQuery +=	       " CYX_DTBGSP > '"+cIni+"'  OR "
	cQuery +=	       " CYX_DTBGSP = '"+cIni+"' AND CYX_HRBGSP > '"+cHoraIni+"' "
	cQuery +=	     " ) AND ( "
	cQuery +=	       " CYX_DTEDSP < '"+cFim+"' OR "
	cQuery +=	       " CYX_DTEDSP = '"+cFim+"' AND CYX_HREDSP < '"+cHoraFim+"' "
	cQuery +=	     " ) "
	cQuery +=	   " ) THEN 1 ELSE NULL END "
	cQuery +=	 " ) AS PREENCHIDO, "
	If "MSSQL" $ cBanco
		cQuery += " MAX(CYX_FILIAL+CYX_CDMQ+CYX_DTBGSP+CYX_HRBGSP) AS PK "
	Else
		cQuery += " MAX(CYX_FILIAL||CYX_CDMQ||CYX_DTBGSP||CYX_HRBGSP) AS PK "
	EndIf
	cQuery +=   " FROM "+RetSqlName("CYX")+" CYX "
	cQuery +=  " WHERE CYX_FILIAL     = '"+xFilial("CYX")+"' "
	cQuery +=	 " AND CYX_CDMQ       = '"+cMaq+"' "
	cQuery +=	 " AND CYX.D_E_L_E_T_ = ' ' "
	cQuery +=	 " AND ( "
	cQuery +=	   " ( "
	cQuery +=	     " ( "
	cQuery +=	      " CYX_DTBGSP < '"+cIni+"' OR "
	cQuery +=	      " CYX_DTBGSP = '"+cIni+"' AND CYX_HRBGSP <= '"+cHoraIni+"' "
	cQuery +=	     " ) AND ( "
	cQuery +=	      " CYX_DTEDSP > '"+cIni+"' OR "
	cQuery +=	      " CYX_DTEDSP = '"+cIni+"' AND CYX_HREDSP > '"+cHoraIni+"' "
	cQuery +=	     " ) "
	cQuery +=	   " ) OR ( "
	cQuery +=	     " ( "
	cQuery +=	       " CYX_DTBGSP < '"+cFim+"' OR "
	cQuery +=	       " CYX_DTBGSP = '"+cFim+"' AND CYX_HRBGSP < '"+cHoraFim+"' "
	cQuery +=	     " ) AND ( "
	cQuery +=	       " CYX_DTEDSP > '"+cFim+"' OR "
	cQuery +=	       " CYX_DTEDSP = '"+cFim+"' AND CYX_HREDSP >= '"+cHoraFim+"' "
	cQuery +=	     " ) "
	cQuery +=	   " ) OR ( "
	cQuery +=	     " ( "
	cQuery +=	       " CYX_DTBGSP > '"+cIni+"' OR "
	cQuery +=	       " CYX_DTBGSP = '"+cIni+"' AND CYX_HRBGSP >= '"+cHoraIni+"' "
	cQuery +=	     " ) AND ( "
	cQuery +=	       " CYX_DTEDSP < '"+cFim+"' OR "
	cQuery +=	       " CYX_DTEDSP = '"+cFim+"' AND CYX_HREDSP <= '"+cHoraFim+"' "
	cQuery +=	     " ) "
	cQuery +=	   " ) "
	cQuery +=	 " ) "

	cQuery := ChangeQuery(cQuery)

	dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cTmp, .T., .F. )

	nQtd := (cTmp)->QTD
	nQtdPreenchido := (cTmp)->PREENCHIDO
	nPK := (cTmp)->PK

	(cTmp)->(dbCloseArea())

	If nQtd > 1
		If "MSSQL" $ cBanco
			cQuery := " SELECT MAX(CYX_FILIAL+CYX_CDMQ+CYX_DTBGSP+CYX_HRBGSP) AS PKANT "
		Else
			cQuery := " SELECT MAX(CYX_FILIAL||CYX_CDMQ||CYX_DTBGSP||CYX_HRBGSP) AS PKANT "
		EndIf
		cQuery += "       FROM "+RetSqlName("CYX")+" CYX "
		cQuery += "      WHERE CYX_FILIAL = '"+xFilial("CYX")+"' "
		If "MSSQL" $ cBanco
			cQuery += "    AND CYX_FILIAL+CYX_CDMQ+CYX_DTBGSP+CYX_HRBGSP < '"+nPK+"' "
		Else
			cQuery += "    AND CYX_FILIAL||CYX_CDMQ||CYX_DTBGSP||CYX_HRBGSP < '"+nPK+"' "
		EndIf
		cQuery += "        AND CYX.D_E_L_E_T_ = ' ' "
		
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuery), cAliasQry, .T., .F. )

		If (cAliasQry)->(!EOF())
			cPkPenult := (cAliasQry)->PKANT
		ENDIF

		(cAliasQry)->(dbCloseArea())
	
	EndIf

	RestArea(aArea)

Return nQtd

//-------------------------------------------------------------------
// AlteraÁ„o de data/hora final
//
// Input: data inicial, hora inicial, tempo operaÁ„o
//-------------------------------------------------------------------
Static Function SFCA314ABG(cCDMQ,cNRORPO,cIDAT,cIDATQO,dFim,cHrFim,nQtTotal,dIni,cHrIni,nOper) // ajustaDataInicRep - sfapi009
Local aArea     := GetArea()
Local aAreaCYI  := CYI->( GetArea() )
Local aAreaCYB  := CYB->( GetArea() )
Local aAreaCYY  := CYY->( GetArea() )
Local nIniSec   := 0
Local nFimSec   := 0
Local aRetorno  := {}
Local a2Retorno := {}

dbSelectArea('CYB')
CYB->(dbSetOrder(1))
CYB->(dbSeek(xFilial('CYB')+cCDMQ))

if Empty(dFim)
	dFim := CTOD('01/01/0001')
Endif

if dFim != CTOD('01/01/0001') .AND.;
   dIni != CTOD('01/01/0001')

	if dFim < dIni .OR.;
	  (dFim == dIni .AND.;
	   cHrFim <= cHrIni)

		dFim    := dIni
		cHrFim  := cHrIni
		nOper   := 0
		nIniSec := SFCXSegtoHour(cHrIni)

		AADD(a2Retorno,dIni)
		AADD(a2Retorno,cHrIni)
		AADD(a2Retorno,dFim)
		AADD(a2Retorno,cHrFim)
		AADD(a2Retorno,nOper)
	Else

		nFimSec := SFCXHourToSeg(cHrFim)
		nIniSec := SFCXHourToSeg(cHrIni)

		//Calcula tempo m·quina
		//Retorna: 1-centro,2-calendario,3-data fim,4-seg fim,5-data ini,6-seg fim,7-tempo,8-turno,9-numero turno,10-tempo extra
		aRetorno := SFCA314TPM(CYB->CYB_CDCETR,cCDMQ,,dFim,nFimSec,dIni,nIniSec,nOper)

		AADD(a2Retorno,aRetorno[5])                         // 1- data inicio
		AADD(a2Retorno,ALLTRIM(SFCXSegtoHour(aRetorno[6]))) // 2- segundos inicio
		AADD(a2Retorno,aRetorno[3])                         // 3- data fim
		AADD(a2Retorno,ALLTRIM(SFCXSegtoHour(aRetorno[4]))) // 4- segundos fim
		AADD(a2Retorno,aRetorno[7])                         // 5- tempo
		AADD(a2Retorno,aRetorno[8])                         // 6- turno
		AADD(a2Retorno,aRetorno[9])                         // 7- numero turno
		AADD(a2Retorno,aRetorno[10])                        // 8- tempo extra
	Endif
Endif

if dIni == CTOD('01/01/0001') .AND.;
   dFim <> CTOD('01/01/0001')

	dbSelectArea('CYY')
	CYY->(dbSetOrder(1))
	CYY->(dbSeek(xFilial('CYY')+cNRORPO+cIDAT+cIDATQO))

	nFimSec := SFCXHourToSeg(cHrFim)
	nOper   := CYY->CYY_QTTEAT

	dbSelectArea('CYI')
	CYI->(dbSetOrder(1))
	if CYI->(dbSeek(xFilial('CYI')+CYB->CYB_CDCETR)) .AND.;
	   CYI_TPTEAT == '1'

		nOper := nOper * (nQtTotal / CYY->CYY_QTAT)
	Endif

	nOper := nOper / 3600

	//Calcula tempo m·quina
	//Retorna: 1-centro,2-calendario,3-data fim,4-seg fim,5-data ini,6-seg fim,7-tempo,8-turno,9-numero turno,10-tempo extra
	aRetorno := SFCA314TPM (CYB->CYB_CDCETR,cCDMQ,,dFim,nFimSec,dIni,nIniSec,CYY->CYY_QTPAAT)

	AADD(a2Retorno,aRetorno[5])                         // 1- data inicio
	AADD(a2Retorno,ALLTRIM(SFCXSegtoHour(aRetorno[6]))) // 2- segundos inicio
	AADD(a2Retorno,aRetorno[3])                         // 3- data fim
	AADD(a2Retorno,ALLTRIM(SFCXSegtoHour(aRetorno[4]))) // 4- segundos fim
	AADD(a2Retorno,aRetorno[7])                         // 5- tempo
	AADD(a2Retorno,aRetorno[8])                         // 6- turno
	AADD(a2Retorno,aRetorno[9])                         // 7- numero turno
	AADD(a2Retorno,aRetorno[10])                        // 8- tempo extra
Endif

RestArea( aAreaCYI )
RestArea( aAreaCYY )
RestArea( aAreaCYB )
RestArea( aArea )

Return a2Retorno

//-------------------------------------------------------------------
// Calcular tempos da maquina
// SFCA314TMP(cCentro,cCDMQ,cCalen,dFim,nSegFim,dIni,nSegIni,nOper,turno)
//
// Input: data inicial, hora inicial, tempo operaÁ„o
//-------------------------------------------------------------------
Function SFCA314TPM (cCDCETR,cCDMQ,cCalen,dFim,nSegFim,dIni,nSegIni,nOper,cCDTN) // CalcularTemposCtrabExtra - boin469b
Local aRetorno  := {}
Local a2Retorno := {}
Local nTempo    := 0
Local nTempoEx  := 0
Local cNRTN     := ''

if Empty(cCalen)
	if !Empty(cCDMQ)
		cCalen := SFCCalendario(cCDMQ,cCDCETR)
	Else
		if !Empty(cCDCETR)
			cCalen := SFCCalendario(,cCDCETR)
		Endif
	Endif
Endif

if dIni != CTOD('01/01/0001') .AND.;
   dFim == CTOD('01/01/0001')
    // Calcula data final com base nas datas iniciais e tempo de operaÁ„o
	aRetorno := SFCA314EDE(cCDCETR,cCDMQ,cCalen,dIni,nSegIni,nOper,cCDTN)
	dFim     := aRetorno[1]
	nSegFim  := aRetorno[2]
	nTempo   := nOper
	cCDTN    :=	aRetorno[3]
	cNRTN    := aRetorno[4]
	nTempoEx := aRetorno[5]
Else
	// Calcula tempos com base nas datas iniciais e finais
	aRetorno := SFCXTEMPOS('', '', 3, cCDMQ, dIni, dFim, SFCXSegtoHour(nSegIni), SFCXSegtoHour(nSegFim),.F.,'SFCA314')
	nTempo   := aRetorno[3] / 3600
	nTempoEx := aRetorno[4] / 3600
	cCDTN    := aRetorno[1]
	cNRTN    := aRetorno[2]
Endif

AADD(a2Retorno,cCDCETR)
AADD(a2Retorno,cCalen)
AADD(a2Retorno,dFim)
AADD(a2Retorno,nSegFim)
AADD(a2Retorno,dIni)
AADD(a2Retorno,nSegIni)
AADD(a2Retorno,nTempo)
AADD(a2Retorno,cCDTN)
AADD(a2Retorno,STRZERO(VAL(cNRTN), 5))
AADD(a2Retorno,nTempoEx)

Return a2Retorno

//-------------------------------------------------------------------
// Calcular fim do evento (hora e segundos)
// 		old=pi-determina-fim-evento - boin469b.i3
//
// SFCA314FimEvent(cCentro,cCDMQ,cCalen,dIni,nSegIni,nOper)
//
// Input: area, centro, maquina, calendario, data inicial,
//		  segundos inicio, tempo operaÁ„o
// Retorno: a2Retorno (data final, segundos final, turno)
//-------------------------------------------------------------------
Function SFCA314EDE (cCDCETR,cCDMQ,cCDCL,dIni,nSegIni,nTempoUtil,cCDTN)
Local nAuxSegIniTurno := 0
Local dDataAux        := CTOD('01/01/0001')
Local dCalc           := dIni
Local cNRTN           := ''
Local lOk             := .F.
Local lFora           := .F.
Local cDiaSemana      := ''
Local aArea           := GetArea()
Local aAreaCYR        := CYR->( GetArea() )
Local aAreaCYZ        := CYZ->( GetArea() )
Local aRetorno		  := {}
Local a2Retorno	      := {}
Local dIniVal
Local dFimVal         := CTOD('01/01/0001')
Local dFinal          := CTOD('01/01/0001')
Local nSegFinal       := 0
Local nTempoParada    := 0
Local nTempoExtra     := 0
Local cReferIni       := ''
Local cReferFim       := ''
Local nPosReg		  := 0
Local nAnt            := 0

if nTempoUtil <= 0
	dFinal     := dIni
	nSegFinal  := nSegIni
	lOk		   := .T.
Endif

nAuxSegIniTurno := nSegIni
nTempoUtil      := nTempoUtil * 3600

// busca o turno da m·quina de acordo com a data
if dFimVal <= dCalc .AND. Empty(cCDTN)
	aRetorno := SFCA314GTU(,cCDCETR,cCDMQ,dCalc)
	cCDTN    := aRetorno[1]
	dIniVal  := aRetorno[2]
	dFimVal  := aRetorno[3]
Endif

if Empty(cCDTN)
	lOk := .T.
Endif

While !lOk
	cDiaSemana := ALLTRIM(STR(DOW(dCalc)))

	// para calculo no inicio da validade do turno
	if dCalc == dIniVal
		aRetorno := SFCA314GTU(,cCDCETR,cCDMQ,dCalc - 1)
		cCDTN    := aRetorno[1]
		dIniVal  := aRetorno[2]
		dFimVal  := aRetorno[3]

		dbSelectArea('CYR')
		CYR->(dbSetOrder(2))
		if !(CYR->(dbSeek(xFilial('CYR')+cCDTN+cDiaSemana)))
			if !(dCalc == dIni .AND.;
	        	 86400 < nSegIni)

	        	dDataAux := dCalc

        		if !(dDataAux >= dCalc .OR.;
        		     dDataAux >= dFimVal .OR.;
        	   	     dDataAux < dIniVal)

					dbSelectArea('CYZ')
					CYZ->(dbSetOrder(1))
					if (CYZ->(dbSeek(xFilial('CYZ')+cCDCL+DTOS(dDataAux))) .AND. CYZ->CYZ_TPDY == '1') .OR.;
						!CYZ->(dbSeek(xFilial('CYZ')+cCDCL+DTOS(dDataAux)))

						if dCalc == dIni
							nAuxSegIniTurno := MAX(0,nSegIni)
						else
							nAuxSegIniTurno := 0
			   			Endif

						nTempoUtil -= 86400 - nAuxSegIniTurno

						if nTempoUtil <= 0
							dFinal    := dCalc
							nSegFinal := 86400 - ABS(nTempoUtil)

							lOk := .T.
							Exit
						Endif
					Endif
				Endif
			Endif
		Else
			dbSelectArea('CYZ')
			CYZ->(dbSetOrder(1))
			if (CYZ->(dbSeek(xFilial('CYZ')+cCDCL+DTOS(dDataAux))) .AND. CYZ->CYZ_TPDY == '1') .OR.;
				!CYZ->(dbSeek(xFilial('CYZ')+cCDCL+DTOS(dDataAux)))

				While CYR->(!EOF() .AND. CYR->CYR_CDTN == cCDTN .AND. CYR->CYR_NRDYWK == cDiaSemana)

					if !(dCalc == dIni .AND. SFCXHourToSeg(CYR->CYR_HRED) < nSegIni) .AND. SFCXHourToSeg(CYR->CYR_HRBG) >= nAnt

		        		if !(dCalc >= dFimVal .OR.;
		        	   	     dCalc < dIniVal)

							if dCalc == dIni
								nAuxSegIniTurno := MAX(SFCXHourToSeg(CYR->CYR_HRBG),nSegIni)
							else
								nAuxSegIniTurno := SFCXHourToSeg(CYR->CYR_HRBG)
				   			Endif

				   			// Verificar se o turno encontrado, n„o possui uma parada dentro
							nPosReg := CYR->(Recno())

							cReferIni := CYR->CYR_HRBG
							cReferFim := CYR->CYR_HRED

							nTempoParada := 0

							dbSelectArea('CYR')
							CYR->(dbSetOrder(2))
							if CYR->(dbSeek(xFilial('CYR')+cCDTN+cDiaSemana))
								While CYR->(!EOF()) .AND. CYR->CYR_CDTN == cCDTN .AND. CYR->CYR_NRDYWK == cDiaSemana

									if nPosReg != CYR->(Recno()) .AND.; // Para n„o pegar o mesmo registro que estava posicionado anteriormente
									   CYR->CYR_TPTE == '2' .AND.; // tipo parada
									   CYR->CYR_HRBG > cReferIni .AND. CYR->CYR_HRED < cReferFim // dentro do perÌodo de referÍncia

		 								// Se a operaÁ„o n„o chegar atÈ o inÌcio da parada, daÌ n„o conta no c·lculo
										if SFCXHourToSeg(CYR->CYR_HRBG) > nAuxSegIniTurno .AND. SFCXHourToSeg(CYR->CYR_HRBG) < nAuxSegIniTurno + nTempoUtil .AND.;
										   nAuxSegIniTurno + nTempoUtil > SFCXHourToSeg(CYR->CYR_HRBG)
											nTempoParada += CYR->CYR_QTTE
										Endif

										// Caso inicie dentro do turno de parada, tem q calular o tempo extra
										IF dCalc == dIni .AND. nAuxSegIniTurno == nSegIni .AND.;
										   SFCXHourToSeg(CYR->CYR_HRBG) <= nAuxSegIniTurno .AND. SFCXHourToSeg(CYR->CYR_HRED) > nAuxSegIniTurno
											nTempoExtra := if(nAuxSegIniTurno + nTempoUtil <= SFCXHourToSeg(CYR->CYR_HRED), nTempoUtil, SFCXHourToSeg(CYR->CYR_HRED) - nAuxSegIniTurno)
										Endif
									Endif

									CYR->(dbSkip())
								End
							Endif

							CYR->(dbGoTo(nPosReg))
							// Fim

							nTempoUtil -= SFCXHourToSeg(CYR->CYR_HRED) - nAuxSegIniTurno - nTempoParada

							if nTempoUtil <= 0
								dFinal    := dCalc
								nSegFinal := SFCXHourToSeg(CYR->CYR_HRED) - ABS(nTempoUtil)

								lOk := .T.
							Else
								nAuxSegIniTurno := SFCXHourToSeg(CYR->CYR_HRED)
							Endif

							if Empty(cNRTN)
								cNRTN := CYR->CYR_NRTN
							Else
								if cNRTN != CYR->CYR_NRTN
									cNRTN := '00000'
								Endif
							Endif

							if lOk
								Exit
							Endif
						Endif
					Endif

					nAnt := SFCXHourToSeg(CYR->CYR_HRED) // para sempre buscar o proximo turno que inicie depois que este termina

					CYR->(dbSkip())
				End

				nAnt := 0
			Endif
		Endif
	Endif

	if lOk
		Exit
	Endif

	if dFimVal <= dCalc
	   	aRetorno := SFCA314GTU(,cCDCETR,cCDMQ,dCalc)
	   	cCDTN    := aRetorno[1]
		dIniVal  := aRetorno[2]
		dFimVal  := aRetorno[3]
	Endif

	dbSelectArea('CYR')
	CYR->(dbSetOrder(2))
	if !(CYR->(dbSeek(xFilial('CYR')+cCDTN+cDiaSemana)))

		if !(dCalc == dIni .AND.;
			86400 < nSegIni)

			dDataAux := dCalc

			if !(dDataAux >= dFimVal .OR.;
	             dDataAux < dIniVal)

				dbSelectArea('CYZ')
				CYZ->(dbSetOrder(1))
				if (CYZ->(dbSeek(xFilial('CYZ')+cCDCL+DTOS(dDataAux))) .AND. CYZ->CYZ_TPDY == '1') .OR.;
					!CYZ->(dbSeek(xFilial('CYZ')+cCDCL+DTOS(dDataAux)))

					if dCalc == dIni
						nAuxSegIniTurno := MAX(0,nSegIni)
					else
						nAuxSegIniTurno := 0
					Endif

					nTempoUtil -= 86400 - nAuxSegIniTurno

					if nTempoUtil <= 0
						dFinal    := dCalc
						nSegFinal := 86400 - ABS(nTempoUtil)
						lOk       := .T.
						Exit
					Endif
				Endif
			Endif
		Endif
	Else
		dbSelectArea('CYZ')
		CYZ->(dbSetOrder(1))
		if (CYZ->(dbSeek(xFilial('CYZ')+cCDCL+DTOS(dCalc))) .AND. CYZ->CYZ_TPDY == '1') .OR.;
			!CYZ->(dbSeek(xFilial('CYZ')+cCDCL+DTOS(dCalc)))

			While CYR->(!EOF() .AND. CYR->CYR_CDTN == cCDTN .AND. CYR->CYR_NRDYWK == cDiaSemana)

				if (dCalc != dIni .OR. (dCalc == dIni .AND. SFCXHourToSeg(CYR->CYR_HRED) > nSegIni)) .AND.;
				   (dCalc >= dIniVal .AND. dCalc < dFimVal) .AND. SFCXHourToSeg(CYR->CYR_HRBG) >= nAnt

					if dCalc == dIni // quer dizer que vamos tratar o primeiro dia do apontamento

						if nAuxSegIniTurno == nSegIni .AND. nSegIni < SFCXHourToSeg(CYR->CYR_HRBG) // Se comeÁou antes de um turno

							nTempoExtra := if(nSegIni + nTempoUtil > SFCXHourToSeg(CYR->CYR_HRBG),SFCXHourToSeg(CYR->CYR_HRBG) - nSegIni,nTempoUtil)
							nTempoUtil  -= SFCXHourToSeg(CYR->CYR_HRBG) - nSegIni

							if nTempoUtil <= 0
								dFinal      := dCalc
								nSegFinal   := SFCXHourToSeg(CYR->CYR_HRBG) - ABS(nTempoUtil)
								lOk         := .T.

								if Empty(cNRTN)
									cNRTN := CYR->CYR_NRTN
								Else
									if cNRTN != CYR->CYR_NRTN
										cNRTN := '00000'
									Endif
								Endif

								Exit
							Endif

							nAuxSegIniTurno := SFCXHourToSeg(CYR->CYR_HRBG)
						Else // Se comeÁou dentro do turno
							nAuxSegIniTurno := MAX(SFCXHourToSeg(CYR->CYR_HRBG),nSegIni)

							if Empty(cNRTN)
								cNRTN := CYR->CYR_NRTN
							Else
								if cNRTN != CYR->CYR_NRTN
									cNRTN := '00000'
								Endif
							Endif
						Endif
					else
						if lFora
							// se comeÁou fora, tem q continuar fora, no inicio do dia
							nTempoExtra += if(nTempoUtil > SFCXHourToSeg(CYR->CYR_HRBG),SFCXHourToSeg(CYR->CYR_HRBG),nTempoUtil)
							nTempoUtil  -= SFCXHourToSeg(CYR->CYR_HRBG)

							if nTempoUtil <= 0
								dFinal      := dCalc
								nSegFinal   := SFCXHourToSeg(CYR->CYR_HRBG) - ABS(nTempoUtil)
								lOk         := .T.
							Else
								nAuxSegIniTurno := SFCXHourToSeg(CYR->CYR_HRBG)
							Endif

							if Empty(cNRTN)
								cNRTN := CYR->CYR_NRTN
							Else
								if cNRTN != CYR->CYR_NRTN
									cNRTN := '00000'
								Endif
							Endif

							if lOk
								Exit
							Endif
						Endif

						nAuxSegIniTurno := SFCXHourToSeg(CYR->CYR_HRBG)
					Endif

					// Verificar se o turno encontrado, n„o possui uma parada dentro
					nPosReg := CYR->(Recno())

					cReferIni := CYR->CYR_HRBG
					cReferFim := CYR->CYR_HRED

					nTempoParada := 0

					dbSelectArea('CYR')
					CYR->(dbSetOrder(2))
					if CYR->(dbSeek(xFilial('CYR')+cCDTN+cDiaSemana))
						While CYR->(!EOF()) .AND. CYR->CYR_CDTN == cCDTN .AND. CYR->CYR_NRDYWK == cDiaSemana

							if nPosReg != CYR->(Recno()) .AND.; // Para n„o pegar o mesmo registro que estava posicionado anteriormente
							   CYR->CYR_TPTE == '2' .AND.; // tipo parada
							   CYR->CYR_HRBG > cReferIni .AND. CYR->CYR_HRED < cReferFim // dentro do perÌodo de referÍncia

 								// Se a operaÁ„o n„o chegar atÈ o inÌcio da parada, daÌ n„o conta no c·lculo
								if SFCXHourToSeg(CYR->CYR_HRBG) > nAuxSegIniTurno .AND. SFCXHourToSeg(CYR->CYR_HRBG) < nAuxSegIniTurno + nTempoUtil .AND.;
								   nAuxSegIniTurno + nTempoUtil > SFCXHourToSeg(CYR->CYR_HRBG)
									nTempoParada += CYR->CYR_QTTE
								Endif

								// Caso inicie dentro do turno de parada, tem q calular o tempo extra
								IF dCalc == dIni .AND. nAuxSegIniTurno == nSegIni .AND.;
								   SFCXHourToSeg(CYR->CYR_HRBG) <= nAuxSegIniTurno .AND. SFCXHourToSeg(CYR->CYR_HRED) > nAuxSegIniTurno
									nTempoExtra := if(nAuxSegIniTurno + nTempoUtil <= SFCXHourToSeg(CYR->CYR_HRED), nTempoUtil, SFCXHourToSeg(CYR->CYR_HRED) - nAuxSegIniTurno)
								Endif
							Endif

							CYR->(dbSkip())
						End
					Endif

					CYR->(dbGoTo(nPosReg))
					// Fim

					nTempoUtil -= SFCXHourToSeg(CYR->CYR_HRED) - nAuxSegIniTurno - nTempoParada

					if nTempoUtil <= 0
						dFinal    := dCalc
						nSegFinal := SFCXHourToSeg(CYR->CYR_HRED) - ABS(nTempoUtil)
						lOk       := .T.
					Else
						nAuxSegIniTurno := SFCXHourToSeg(CYR->CYR_HRED)
					Endif

					if Empty(cNRTN)
						cNRTN := CYR->CYR_NRTN
					Else
						if cNRTN != CYR->CYR_NRTN
							cNRTN := '00000'
						Endif
					Endif

					if lOk
						Exit
					Endif
				Endif

				nAnt := SFCXHourToSeg(CYR->CYR_HRED) // para sempre buscar o proximo turno que inicie depois que este termina

				CYR->(dbSkip())
			End

			nAnt := 0
		Endif
	Endif

	if lOk
		Exit
	Endif

	if (dCalc + 1) == dFimVal

		aRetorno := SFCA314GTU(,cCDCETR,cCDMQ,dCalc + 1)
		cCDTN    := aRetorno[1]
		dIniVal  := aRetorno[2]
		dFimVal  := aRetorno[3]

		dbSelectArea('CYR')
		CYR->(dbSetOrder(2))
		if !(CYR->(dbSeek(xFilial('CYR')+cCDTN+STR(DOW(dCalc)))))

			if !(dCalc == dIni .AND.;
				86400 < nSegIni)

				dDataAux := dCalc

				if !(dDataAux <= dCalc .OR.;
		             dDataAux >= dFimVal .OR.;
		             dDataAux <  dIniVal)

					dbSelectArea('CYZ')
					CYZ->(dbSetOrder(1))
					if (CYZ->(dbSeek(xFilial('CYZ')+cCDCL+DTOS(dDataAux))) .AND. CYZ->CYZ_TPDY == '1') .OR.;
						!CYZ->(dbSeek(xFilial('CYZ')+cCDCL+DTOS(dDataAux)))

						if dCalc == dIni
							nAuxSegIniTurno := MAX(0,nSegIni)
						else
							nAuxSegIniTurno := 0
						Endif

						nTempoUtil -= (86400 * 3600) - nAuxSegIniTurno

						if nTempoUtil <= 0
							dFinal     := dCalc
							nSegFinal  := 86400 - ABS(nTempoUtil)
							lOk        := .T.
							Exit
						Endif
					Endif
				Endif
			Endif
		Else
			dbSelectArea('CYZ')
			CYZ->(dbSetOrder(1))
			if (CYZ->(dbSeek(xFilial('CYZ')+cCDCL+DTOS(dDataAux))) .AND. CYZ->CYZ_TPDY == '1') .OR.;
				!CYZ->(dbSeek(xFilial('CYZ')+cCDCL+DTOS(dDataAux)))

				While CYR->(!EOF()) .AND. CYR->CYR_CDTN == cCDTN .AND. CYR->CYR_NRDYWK == STR(DOW(dCalc))

					if !(dCalc == dIni .AND. SFCXHourToSeg(CYR->CYR_HRED) < nSegIni) .AND. SFCXHourToSeg(CYR->CYR_HRBG) >= nAnt

						if !(dCalc >= dFimVal .OR. dCalc <  dIniVal)

							if dCalc == dIni
								nAuxSegIniTurno := MAX(SFCXHourToSeg(CYR->CYR_HRBG),nSegIni)
							else
								nAuxSegIniTurno := SFCXHourToSeg(CYR->CYR_HRBG)
							Endif

							// Verificar se o turno encontrado, n„o possui uma parada dentro
							nPosReg := CYR->(Recno())

							cReferIni := CYR->CYR_HRBG
							cReferFim := CYR->CYR_HRED

							nTempoParada := 0

							dbSelectArea('CYR')
							CYR->(dbSetOrder(2))
							if CYR->(dbSeek(xFilial('CYR')+cCDTN+cDiaSemana))
								While CYR->(!EOF()) .AND. CYR->CYR_CDTN == cCDTN .AND. CYR->CYR_NRDYWK == cDiaSemana

									if nPosReg != CYR->(Recno()) .AND.; // Para n„o pegar o mesmo registro que estava posicionado anteriormente
									   CYR->CYR_TPTE == '2' .AND.; // tipo parada
									   CYR->CYR_HRBG > cReferIni .AND. CYR->CYR_HRED < cReferFim // dentro do perÌodo de referÍncia

		 								// Se a operaÁ„o n„o chegar atÈ o inÌcio da parada, daÌ n„o conta no c·lculo
										if SFCXHourToSeg(CYR->CYR_HRBG) > nAuxSegIniTurno .AND. SFCXHourToSeg(CYR->CYR_HRBG) < nAuxSegIniTurno + nTempoUtil .AND.;
										   nAuxSegIniTurno + nTempoUtil > SFCXHourToSeg(CYR->CYR_HRBG)
											nTempoParada += CYR->CYR_QTTE
										Endif

										// Caso inicie dentro do turno de parada, tem q calular o tempo extra
										IF dCalc == dIni .AND. nAuxSegIniTurno == nSegIni .AND.;
										   SFCXHourToSeg(CYR->CYR_HRBG) <= nAuxSegIniTurno .AND. SFCXHourToSeg(CYR->CYR_HRED) > nAuxSegIniTurno
											nTempoExtra := if(nAuxSegIniTurno + nTempoUtil <= SFCXHourToSeg(CYR->CYR_HRED), nTempoUtil, SFCXHourToSeg(CYR->CYR_HRED) - nAuxSegIniTurno)
										Endif
									Endif

									CYR->(dbSkip())
								End
							Endif

							CYR->(dbGoTo(nPosReg))
							// Fim

							nTempoUtil -= SFCXHourToSeg(CYR->CYR_HRED) - nAuxSegIniTurno - nTempoParada

							if nTempoUtil <= 0
								dFinal     := dCalc
								nSegFinal  := SFCXHourToSeg(CYR->CYR_HRED) - ABS(nTempoUtil)
								lOk        := .T.
							Else
								nAuxSegIniTurno := SFCXHourToSeg(CYR->CYR_HRED)
							Endif

							if Empty(cNRTN)
								cNRTN := CYR->CYR_NRTN
							Else
								if cNRTN != CYR->CYR_NRTN
									cNRTN := '00000'
								Endif
							Endif

							if lOk
								Exit
							Endif
						Endif
					Endif

					nAnt := SFCXHourToSeg(CYR->CYR_HRED) // para sempre buscar o proximo turno que inicie depois que este termina

					CYR->(dbSkip())
				End

				nAnt := 0
			Endif
		Endif
  	Endif

  	if lOk
		Exit
	Endif

	// Caso n„o tenho encontrado um turno, quer dizer que comeÁou fora de um
	if dFinal == CTOD('01/01/0001') .AND. nAuxSegIniTurno == nSegIni
		nTempoExtra := if(nSegIni + nTempoUtil > 86400,86400 - nSegIni,nTempoUtil)
		nTempoUtil  -= 86400 - nAuxSegIniTurno
		lFora       := .T.

		if nTempoUtil <= 0
			dFinal     := dIni
			nSegFinal  := 86400 - ABS(nTempoUtil)
			lOk        := .T.

			if Empty(cNRTN)
				cNRTN := CYR->CYR_NRTN
			Else
				if cNRTN != CYR->CYR_NRTN
					cNRTN := '00000'
				Endif
			Endif

			Exit
		Endif
	Else
		lFora := .F.
	Endif

	dCalc += 1

	if dCalc > (dIni + 1000)
		lOk := .T.
		Exit
	Endif
End

if nSegFinal == 86400
	dFinal++
	nSegFinal := 0
Else
	nSegFinal := round(nSegFinal,0)
Endif

RestArea( aAreaCYZ )
RestArea( aAreaCYR )
RestArea( aArea )

AADD(a2Retorno,dFinal)
AADD(a2Retorno,nSegFinal)
AADD(a2Retorno,cCDTN)
AADD(a2Retorno,cNRTN)
AADD(a2Retorno,nTempoExtra)

Return a2Retorno

//-------------------------------------------------------------------
// Buscar o turno, com data inicio e fim de validade
// SFCA314GTU(cArea.cCentro,cCDMQ,dRefer)
//
// Input: area, centro, maquina, data referencia
// Retorno: cCDTN, dIniVal, dFimVal
//-------------------------------------------------------------------
Function SFCA314GTU(cArea,cCDCETR,cCDMQ,dRefer) // PI-GERA-TT-TURNO - boin469b.i1
Local aRetorno := {}
Local aArea    := GetArea()
Local cCDTN    := ''
Local dIniVal  := CTOD('01/01/0001')
Local dFimVal  := CTOD('31/12/9999')

if !Empty(cCDMQ)
	cCDTN := SFCTurnoMaq(cCDMQ,dRefer)
Else
	if !Empty(cCDCETR)
		dbSelectArea('CYB')
		CYB->(dbSetOrder(2))
		if CYB->(dbSeek(xFilial('CYB')+cCDCETR))
			cCDMQ := CYB->CYB_CDMQ
			cCDTN := SFCTurnoMaq(CYB->CYB_CDMQ,dRefer)
		Endif
	Endif
Endif

dbSelectArea('CYL')
CYL->(dbSetOrder(1))
if CYL->(dbSeek(xFilial('CYL')+cCDMQ+cCDTN))
	dIniVal := CYL->CYL_DTVDBG
	dFimVal := CYL->CYL_DTVDED
Endif

AADD(aRetorno,cCDTN)
AADD(aRetorno,dIniVal)
AADD(aRetorno,dFimVal)

RestArea( aArea )

Return aRetorno

//-------------------------------------------------------------------
// Retorna Modo EdiÁ„o (WHEN) de setup: CYY_DTBGSU/CYY_HRBGSU/CYY_DTEDSU/CYY_HREDSU
// Caso possa editar, retornar True, ao contrario retorna False
//-------------------------------------------------------------------
Function SFCA314EST(cCampo)
Local lRet      := .T.
Local oView     := FWViewActive()
Local oModelCYV := FWModelActive()
Local nI 	    := 0
Local aArea     := GetArea()
Local aAreaCYB  := CYB->(GetArea())
Local aAreaCYY  := CYY->(GetArea())
Local IsSFCA318 := IsInCallStack('SFCA318ATV')
Local cMaquina  := oModelCYV:GetValue(IF(IsSFCA318,'MAQMASTER','CYVMASTER'),'CYV_CDMQ')
Local lFinaliza := IsInCallStack('SFCA310FIM') .Or. SFCA314IF(oModelCYV, 2)

oModelCYV := oModelCYV:GetModel('CYVMASTER')

if IsSFCA318
	nI := oView:GetLine('CYVMASTER')
	oModelCYV:GoLine(nI)
Endif

dbSelectArea('CYB')
CYB->(dbSetOrder(1))
CYB->(dbSeek(xFilial('CYB')+cMaquina))

if CYB->CYB_LGSU
	dbSelectArea('CYY')
	CYY->(dbSetOrder(1))
	CYY->(dbSeek(xFilial('CYY')+oModelCYV:GetValue('CYV_NRORPO')+oModelCYV:GetValue('CYV_IDAT')+oModelCYV:GetValue('CYV_IDATQO')))

	if cCampo == 'CDSU'
		lRet := IF(Empty(CYY->CYY_DTBGSU) .AND. CYY->CYY_TPSTAT == '3',.T.,.F.)
	Else
		lRet := IF(Empty(CYY->CYY_DTBGSU) .AND. CYY->CYY_TPSTAT == '3',if(lFinaliza,.F.,.T.),.F.)
	Endif
Else
	lRet := .F.

	oModelCYV:ClearField('CYV_DTBGSU')
	oModelCYV:ClearField('CYV_HRBGSU')
	oModelCYV:ClearField('CYV_DTEDSU')
	oModelCYV:ClearField('CYV_HREDSU')
Endif

RestArea(aAreaCYY)
RestArea(aAreaCYB)
RestArea(aArea)

Return lRet

//----------------------------------------------
Static Function PrintVar(xVar,nNivel)
	/*
	Local nI
	Default nNivel := 0

	If nNivel == 0
		conout(" ")
		conout("[PrintVar]")
	EndIf

	If ValType(xVar) == "A"
		conout(Space(nNivel*2)+"array(")
		For nI := 1 To Len(xVar)
			PrintVar(xVar[nI],nNivel+1)
		Next
		conout(Space(nNivel*2)+")")
	Else
		If ValType(xVar) == "N"
			xVar := AllTrim(Str(xVar))
			conout(Space(nNivel*2)+xVar)
		Else
			conout(Space(nNivel*2)+"'"+xVar+"'")
		EndIf
	EndIf
	*/
Return .T.

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
Static Function PrimApont(cNRORPO,cIDAT,cIDATQO,lValidaData,dReporte,cHrReporte,cAliasCYY)
	Local nQtProd	:= 0
	Local nValMax	:= 0
	Local cAliasCYV	:= GetNextAlias()
	Local lSFCQTS	:= SuperGetMV('MV_SFCQTS',.F.,.T.)  // Considera quantidade do split
	Local lPERDINF	:= SuperGetMV('MV_PERDINF',.F.,.T.) // Considera como saldo a quantidade aprovada?

	// Se valida data, verificar todos os apontamentos realizados atÈ o inÌcio do apontamento
	if lValidaData
		BeginSql Alias cAliasCYV

			SELECT * FROM %Table:CYV% CYV
			WHERE CYV.CYV_FILIAL=%xFilial:CYV% AND
				  CYV.CYV_NRORPO=%Exp:cNRORPO% AND
				  CYV.CYV_IDAT  =%Exp:cIDAT% AND
				  CYV.CYV_LGRPEO='F' AND
				 (CYV.CYV_DTRPED<%Exp:DTOS(dReporte)% OR
				 (CYV.CYV_DTRPED=%Exp:DTOS(dReporte)% AND CYV.CYV_HRRPED <= %Exp:cHrReporte%)) AND
				  CYV.%NotDel%
		EndSql

		While (cAliasCYV)->(!EOF())
			IF !lSFCQTS .OR. (lSFCQTS .AND. (cAliasCYV)->CYV_IDATQO == cIDATQO)
				nQtProd += if(lPERDINF,(cAliasCYV)->CYV_QTATAP,(cAliasCYV)->CYV_QTATRP)
			Endif

			(cAliasCYV)->(dbSkip())
		End

		(cAliasCYV)->(dbCloseArea())

		nValMax := if(lSFCQTS,(cAliasCYY)->CYY_QTAT, CY9->CY9_QTAT) - nQtProd
	Else // Se n„o valida data, pega os valores do split/operaÁ„o
		If lSFCQTS // Quantidade do Split
			nValMax := (cAliasCYY)->CYY_QTAT - if(lPERDINF,(cAliasCYY)->CYY_QTATAP,(cAliasCYY)->CYY_QTATRP)
		Else // Quantidade da OperaÁ„o
			nValMax := CY9->CY9_QTAT - if(lPERDINF,CY9->CY9_QTAP,CY9->CY9_QTRP)
		EndIf
	Endif

Return nValMax
//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
Static Function PosApont(cNRORPO,cIDAT,cAliasCYY,lValidaData,oModel,dReporte,cHrReporte,cHrRepFim,dRepFim)
	Local nI
	Local nValMax		:= 0
	Local nQtProd		:= 0
	Local nLinhaOrig	:= 0
	Local cAliasCYV		:= GetNextAlias()
	Local nPosReg		:= CY9->( Recno() )
	Local lDispatch		:= IsInCallStack('SFCA318ATV')
	Local lSFCQTS		:= SuperGetMV('MV_SFCQTS',.F.,.T.)  // Considera quantidade do split
	Local lPERDINF		:= SuperGetMV('MV_PERDINF',.F.,.T.) // Considera como saldo a quantidade aprovada?

	dbSelectArea('CYD')
	CYD->(dbSetOrder(2))
	CYD->(dbGoTop())
	if CYD->(dbSeek(xFilial('CYD')+cNRORPO+cIDAT))

		DbSelectArea('CY9')
		CY9->(DbSetOrder(1))
		CY9->(DbGoTop())

		If CY9->(DbSeek(xFilial('CY9')+cNRORPO+CYD->CYD_IDATPV))

			// Se valida data, verificar apontamentos realizados
			if lValidaData

				// Se dispatch, verificar se existem operaÁıes anteriores junto e somar as quantidades
				IF lDispatch .AND. oModel != NIL
					nLinhaOrig := oModel:GetLine()

					For nI := 1 to oModel:GetQtdLine()
						oModel:GoLine(nI)

						if !oModel:IsDeleted()
							if oModel:GetValue('CYV_NRORPO') == cNRORPO .AND.;
							   oModel:GetValue('CYV_IDAT')   == CYD->CYD_IDATPV .AND.;
							   (oModel:GetValue('CYV_DTRPED') < dReporte .OR.;
							    oModel:GetValue('CYV_DTRPED') == dReporte .AND. oModel:GetValue('CYV_HRRPED') <= cHrReporte)
								nQtProd += if(lPERDINF,oModel:GetValue('CYV_QTATAP'),oModel:GetValue('CYV_QTATRP'))
							Endif
						Endif
					Next

					oModel:GoLine(nLinhaOrig)
				Endif

				// Verificar Overlap
				If CYD->CYD_VLPNOV == 0

					BeginSql Alias cAliasCYV

						SELECT * FROM %Table:CYV% CYV
						WHERE CYV.CYV_FILIAL = %xFilial:CYV%
						  AND CYV.CYV_NRORPO = %Exp:cNRORPO%
						  AND CYV.CYV_IDAT   = %Exp:CYD->CYD_IDATPV%
						  AND CYV.CYV_LGRPEO = 'F'
						  AND (
						  	CYV.CYV_DTRPED < %Exp:DTOS(dReporte)%
						  	OR
						  	(CYV.CYV_DTRPED = %Exp:DTOS(dReporte)% AND CYV.CYV_HRRPED <= %Exp:cHrReporte%)
						  )
						  AND CYV.%NotDel%

					EndSql
				Else

					BeginSql Alias cAliasCYV

						SELECT * FROM %Table:CYV% CYV
						WHERE CYV.CYV_FILIAL	= %xFilial:CYV%
						  AND CYV.CYV_NRORPO	= %Exp:cNRORPO%
						  AND CYV.CYV_IDAT		= %Exp:CYD->CYD_IDATPV%
						  AND CYV.CYV_LGRPEO	= 'F'
						  AND CYV.%NotDel%
						  AND (
							(
								CYV.CYV_DTRPED  < %Exp:DTOS(dReporte)% //INICIAL
								OR
								(CYV.CYV_DTRPED = %Exp:DTOS(dReporte)% AND CYV.CYV_HRRPED <= %Exp:cHrReporte%) //INICIAL
							)
							OR (
								(
									CYV.CYV_DTRPBG  < %Exp:DTOS(dReporte)% //INICIAL
									OR
									(CYV.CYV_DTRPBG = %Exp:DTOS(dReporte)%  AND CYV.CYV_HRRPBG <= %Exp:cHrReporte%) //INICIAL
								)
								AND (
									CYV.CYV_DTRPED  < %Exp:DTOS(dRepFim)% //FINAL
									OR
									(CYV.CYV_DTRPED = %Exp:DTOS(dRepFim)% AND CYV.CYV_HRRPED <= %Exp:cHrRepFim%) //FINAL
								)
							)
						  )
					EndSql
				EndIf

				While (cAliasCYV)->(!EOF())
					nQtProd += if(lPERDINF,(cAliasCYV)->CYV_QTATAP,(cAliasCYV)->CYV_QTATRP)

					(cAliasCYV)->(dbSkip())
				End

				(cAliasCYV)->(dbCloseArea())
			Else // Se n„o valida data, verificar informaÁıes da operaÁ„o
				nQtProd := if(lPERDINF,CY9->CY9_QTAP,CY9->CY9_QTPO)
			Endif

			CY9->(dbGoTo(nPosReg))

			IF lSFCQTS // Quantidade do Split
				nValMax := nQtProd - if(lPERDINF,(cAliasCYY)->CYY_QTATAP,(cAliasCYY)->CYY_QTATRP)
			Else // Quantidade da OperaÁ„o
				nValMax := nQtProd - if(lPERDINF,CY9->CY9_QTAP,CY9->CY9_QTPO)
			Endif
		Endif
	Endif

Return nValMax

//-------------------------------------------------------------------
// Calcula quantidade a reportar
// Input: Ordem de ProduÁ„o - character;
//		  OperaÁ„o SFC      - character;
//        Split             - character;
//		  NÌvel 			- numÈrico;
//		  Sugere 			- lÛgico;
//		  Unidade 			- numÈrico;
//		  Data Reporte 		- data;
//		  Valida Data 		- lÛgico;
//		  Tipo	 			- numÈrico - 1=Apontamento,2=Dispatch List
// Output: Quantidade - numÈrico
// EMS:pi-sfc-valid-qtd-reptda-pert-aux/pi-sfc-valid-qtd-reptda-pert - sf9003.i
//-------------------------------------------------------------------
Function SFCA314QRP(cNRORPO, cIDAT, cIDATQO, nNivel, lSug, nUnid, dReporte, cHrReporte, lValidaData, oModel, dRepFim, cHrRepFim,lPrimeiro)
	Local aArea			:= GetArea()
	Local aAreaCY9		:= CY9->( GetArea() )
	Local aAreaCYD		:= CYD->( GetArea() )
	Local aAreaCYQ		:= CYQ->( GetArea() )
	Local aAreaCYI		:= CYI->( GetArea() )
	Local aAreaCZ3		:= CZ3->( GetArea() )
	Local nValMax		:= 0
	Local cAliasCYY		:= GetNextAlias()
	Local cIDATCYD		:= cIDAT
	Local lLGCERP		:= .F.
	Local lFirst		:= .F.
	Default dRepFim		:= dReporte
	Default cHrRepFim	:= cHrReporte
	Default lPrimeiro   := .F.

	// Verifica saldo a ser reportado com base no Split
	BeginSql Alias cAliasCYY

		SELECT * FROM %Table:CYY% CYY
		WHERE CYY.CYY_FILIAL = %xFilial:CYY%
		  AND CYY.CYY_NRORPO = %Exp:cNRORPO%
		  AND CYY.CYY_IDAT   = %Exp:cIDAT%
		  AND CYY.CYY_IDATQO = %Exp:cIDATQO%
		  AND CYY.%NotDel%

	EndSql

	dbSelectArea('CY9')
	CY9->(dbSetOrder(1))
	if CY9->(dbSeek(xFilial('CY9')+cNRORPO+cIDAT))

		// Primeira operaÁ„o, n„o tem necessidade de verificar apontamento das operaÁıes anteriores
		if CY9->CY9_LGATBG

			nValMax := PrimApont(cNRORPO,cIDAT,cIDATQO,lValidaData,dReporte,cHrReporte,cAliasCYY)
			lPrimeiro := .T.

		Else // OperaÁıes posteriores

			dbSelectArea('CYQ')
			CYQ->(dbSetOrder(1))
			CYQ->(dbSeek(xFilial('CYQ')+cNRORPO))

			//Se a ordem produÁ„o estiver marcada com tipo de apontamento por ordem
			If CYQ->CYQ_TPRPOR == '1'
				nPosRegCYY := CYY->( Recno() )
				CYY->(dbSetOrder(1))
				CYD->(dbSetOrder(2))
				CYD->(dbGoTop())


				While !lFirst .And. !lLGCERP

					if CYD->(dbSeek(xFilial('CYD')+cNRORPO+cIDATCYD))

						If CYY->(dbSeek(xFilial('CYY')+cNRORPO+CYD->CYD_IDATPV))

							lLGCERP := CYY->CYY_LGCERP

							If !lLGCERP
								cIDATCYD := CYD->CYD_IDATPV
							EndIf

						Else
							lFirst := .T.
						EndIf

					Else
						lFirst := .T.
					EndIf
				End

				CYY->(dbGoTo(nPosRegCYY))

				If lFirst
					nValMax := PrimApont(cNRORPO,cIDAT,cIDATQO,lValidaData,dReporte,cHrReporte,cAliasCYY)
					lPrimeiro := .T.
				Else
					nValMax := PosApont(cNRORPO,cIDATCYD,cAliasCYY,lValidaData,oModel,dReporte,cHrReporte,cHrRepFim,dRepFim)
				EndIf

			Else
				nValMax := PosApont(cNRORPO,cIDATCYD,cAliasCYY,lValidaData,oModel,dReporte,cHrReporte,cHrRepFim,dRepFim)
			EndIf

		Endif

		// Verificar se produto permite valor decimal
		dbSelectArea('CZ3')
		CZ3->(dbSetOrder(1))
		CZ3->(dbGoTop())
		IF CZ3->(dbSeek(xFilial('CZ3')+CYQ->CYQ_CDAC)) .AND. CZ3->CZ3_LGFC .AND. INT(nValMax) != nValMax
			nValMax := NOROUND(nValMax,0) + 1
		Endif
	EndIf

	(cAliasCYY)->(dbCloseArea())

	IF nValMax < 0
		nValMax := 0
	Endif

	RestArea(aAreaCY9)
	RestArea(aAreaCYD)
	RestArea(aAreaCYQ)
	RestArea(aAreaCYI)
	RestArea(aAreaCZ3)
	RestArea(aArea)

Return nValMax

//-------------------------------------------------------------------
// Carrega reservas
//-------------------------------------------------------------------
Static Function SFCA314CRE (cNRORPO, cIDAT, oModelCZP, nQtdReportar, nQtdOriginal)
Local nPropProd    := 0
Local nQtdAtendida := 0
Local nQtdReserva  := 0
Local lUltOp       := .F.
Local nI           := 0
Local nI2          := 0
Local cCDAT        := ''
Local cCDAC        := ''
Local aArea        := GetArea()
Local aAreaCY9     := CY9->( GetArea() )
Local aAreaCYQ     := CYQ->( GetArea() )
Local aAreaCYP     := CYP->( GetArea() )
Local nRecNumb     := 0
Local lExiste      := .F.
Local aCYPArea
Local iTam         := 0
Default lAutomacao := .F.
Default cProgMtSFC := ''

If cProgMtSFC == 'APIREST-SFCA314'
	oModelCZP:SetNoInsertLine(.F.)
	oModelCZP:SetNoUpdateLine(.F.)
	Return .T.
EndIf 

dbSelectArea('CY9')
CY9->(dbSetOrder(1))
CY9->(dbGoTop())
CY9->(dbSeek(xFilial('CY9')+cNRORPO+cIDAT))

if CY9->CY9_LGATED
	lUltOp := .T.
Endif

dbSelectArea('CYQ')
CYQ->(dbSetOrder(1))
CYQ->(dbGoTop())
CYQ->(dbSeek(xFilial('CYQ')+cNRORPO))

cCDAT := CY9->CY9_CDAT
cCDAC := CYQ->CYQ_CDAC

If !lAutomacao
	oModelCZP:DeActivate(.T.)
	oModelCZP:Activate()
	oModelCZP:SetNoInsertLine(.F.)
	oModelCZP:SetNoUpdateLine(.F.)
EndIf

if IsInCallStack('SFCA314QTR') .And. !IsInCallStack("MATI681") // AlteraÁ„o de quantidade

	For nI := 1 To oModelCZP:Length()
		oModelCZP:GoLine( nI )

		if !oModelCZP:IsDeleted()

			nQtdReserva  := oModelCZP:GetValue('CZP_QTMT')
			nQtdAtendida := oModelCZP:GetValue('CZP_QTRP')

			nPropProd := nQtdReserva / CYQ->CYQ_QTOR  // qtd reserva / qtd ordem

			oModelCZP:SetValue( 'CZP_QTRPPO', IF(nQtdAtendida < nQtdReserva,nQtdReportar * nPropProd,0))//qtd utilizada
			oModelCZP:SetValue( 'CZP_QTMT'  , nQtdReserva) //qtd reserva
			oModelCZP:SetValue( 'CZP_QTRP'  , nQtdAtendida ) // qtd atendida
		Endif
	Next
Else
	if !IsInCallStack('SFCA314PRE')
		If !lAutomacao
			For nI := 1 to oModelCZP:GetQtdLine()
				oModelCZP:GoLine(nI)

				oModelCZP:ClearField('CZP_CDMT'  )
				oModelCZP:ClearField('CZP_DSMT'  )
				oModelCZP:ClearField('CZP_QTRPPO')
				oModelCZP:ClearField('CZP_QTRP'  )
				oModelCZP:ClearField('CZP_CDUN'  )
				oModelCZP:ClearField('CZP_CDACPI')
				oModelCZP:ClearField('CZP_DSACPI')
				oModelCZP:ClearField('CZP_DTMT'  )
				oModelCZP:ClearField('CZP_QTMT'  )
				oModelCZP:ClearField('CZP_CDLO'  )
				oModelCZP:ClearField('CZP_CDAT'  )
				oModelCZP:ClearField('CZP_CDDP'  )
				oModelCZP:ClearField('CZP_TPST'  )
				oModelCZP:ClearField('CZP_CDRT'  )
				oModelCZP:ClearField('CZP_CDRE'  )
				oModelCZP:ClearField('CZP_NRORRE')
				oModelCZP:ClearField('CZP_CDLC'  )
				oModelCZP:ClearField('CZP_CDTBMT')

				oModelCZP:DeleteLine()
			Next
		EndIf
	Endif

	If !lAutomacao
		SFCA314CLG(oModelCZP)
	EndIf

	nI := 1

	dbSelectArea('CYP')
	CYP->(dbSetOrder(2))
	if CYP->(dbSeek(xFilial('CYP')+cNRORPO+cCDAT+cCDAC))

		While CYP->(!EOF()) .AND. CYP->CYP_NRORPO == cNRORPO .AND.;
								  CYP->CYP_CDAT   == cCDAT .AND.;
								  CYP->CYP_CDACPI == cCDAC

			lExiste := .F.
			For nI2 := 1 to oModelCZP:GetQtdLine()
				oModelCZP:GoLine(nI2)

				if !oModelCZP:IsDeleted()
					if oModelCZP:GetValue('CZP_CDMT') == CYP->CYP_CDMT  .And. ;
						oModelCZP:GetValue('CZP_CDLO') == CYP->CYP_CDLO .And. ;
						oModelCZP:GetValue('CZP_CDDP') == CYP->CYP_CDDP .And. ;
						oModelCZP:GetValue('CZP_CDRT') == CYP->CYP_CDRT .And. ;
						oModelCZP:GetValue('CZP_CDRE') == CYP->CYP_CDRE .And. ;
						oModelCZP:GetValue('CZP_CDLC') == CYP->CYP_CDLC

						nQtdReserva  := oModelCZP:GetValue('CZP_QTMT')
						nQtdReserva  := nQtdReserva + CYP->CYP_QTMT

						nQtdAtendida := oModelCZP:GetValue('CZP_QTRP')
						nQtdAtendida := nQtdAtendida + CYP_QTRP

						nPropProd := nQtdReserva / CYQ->CYQ_QTOR  // qtd reserva / qtd ordem

						oModelCZP:SetValue( 'CZP_QTRPPO', IF(nQtdAtendida < nQtdReserva,nQtdReportar * nPropProd,0))//qtd utilizada
						oModelCZP:SetValue( 'CZP_QTMT'  , nQtdReserva) //qtd reserva
						oModelCZP:SetValue( 'CZP_QTRP'  , nQtdAtendida ) // qtd atendida

						lExiste := .T.
						exit
					Endif
				Endif
			Next

			if !lExiste
				nPropProd := CYP->CYP_QTMT / CYQ->CYQ_QTOR
				nRecNumb := CYP->(RecNo())

				if nI > oModelCZP:GetQtdLine()
					aCYPArea := CYP->(getArea())
					oModelCZP:AddLine()
					CYP->( RestArea(aCYPArea) )
				Else
					oModelCZP:GoLine(nI)

					if oModelCZP:IsDeleted()
						oModelCZP:UnDeleteLine()
					Endif
				Endif

				CYP->(dbGoTo(nRecNumb))

				nI++

				oModelCZP:SetNoUpdateLine(.F.)

				oModelCZP:SetValue( 'CZP_NRORPO', cNRORPO ) //ordem
				oModelCZP:SetValue( 'CZP_IDMTOR', CYP->CYP_IDMTOR ) //id
				oModelCZP:SetValue( 'CZP_QTRPPO', IF(CYP->CYP_QTRP < CYP->CYP_QTMT,nQtdReportar * nPropProd,0)) //qtd utilizada
				oModelCZP:SetValue( 'CZP_CDMT'  , CYP->CYP_CDMT )   //componente
				oModelCZP:SetValue( 'CZP_CDACPI', cCDAC )  //item pai
				oModelCZP:SetValue( 'CZP_CDES'  , Posicione("CYQ", 1, xFilial("CYQ")+cNRORPO, "CYQ_CDES") ) //estab
				oModelCZP:SetValue( 'CZP_DTMT'  , CYP->CYP_DTMT ) //data reserva
				oModelCZP:SetValue( 'CZP_QTMT'  , CYP->CYP_QTMT ) //qtd reserva
				oModelCZP:SetValue( 'CZP_QTRP'  , CYP->CYP_QTRP ) // qtd atendida
				oModelCZP:SetValue( 'CZP_CDLO'  , CYP->CYP_CDLO ) // lote
				oModelCZP:SetValue( 'CZP_CDAT'  , cCDAT ) //operaÁ„o
				oModelCZP:SetValue( 'CZP_CDDP'  , CYP->CYP_CDDP )   //deposito
				oModelCZP:SetValue( 'CZP_TPST'  , CYP->CYP_TPST ) //estado
				oModelCZP:SetValue( 'CZP_CDRT'  , CYP->CYP_CDRT ) // roteiro
				oModelCZP:SetValue( 'CZP_CDRE'  , CYP->CYP_CDRE ) // referencia
				oModelCZP:SetValue( 'CZP_NRORRE', CYP->CYP_NRORRE ) // ordem refer
				oModelCZP:SetValue( 'CZP_CDLC'  , CYP->CYP_CDLC ) //localizaÁ„o
				oModelCZP:SetValue( 'CZP_CDTBMT', CYP->CYP_CDTBMT ) //processo ordem
			EndIf

			CYP->(dbSkip())
		End
	Endif

	if lUltOp

		dbSelectArea('CYP')
		CYP->(dbSetOrder(1))
		CYP->(dbGoTop())
		CYP->(dbSeek(xFilial('CYP')+cNRORPO))

		While CYP->(!EOF()) .AND. CYP->CYP_NRORPO == cNRORPO

			if Empty(CYP->CYP_CDAT)
				lExiste := .F.
				For nI2 := 1 to oModelCZP:GetQtdLine()
					oModelCZP:GoLine(nI2)
					if !oModelCZP:IsDeleted()
						if oModelCZP:GetValue('CZP_CDMT') == CYP->CYP_CDMT  .And. ;
							oModelCZP:GetValue('CZP_CDLO') == CYP->CYP_CDLO .And. ;
							oModelCZP:GetValue('CZP_CDDP') == CYP->CYP_CDDP .And. ;
							oModelCZP:GetValue('CZP_CDRT') == CYP->CYP_CDRT .And. ;
							oModelCZP:GetValue('CZP_CDRE') == CYP->CYP_CDRE .And. ;
							oModelCZP:GetValue('CZP_CDLC') == CYP->CYP_CDLC

							nQtdReserva  := oModelCZP:GetValue('CZP_QTMT')
							nQtdReserva  := nQtdReserva + CYP->CYP_QTMT

							nQtdAtendida := oModelCZP:GetValue('CZP_QTRP')
							nQtdAtendida := nQtdAtendida + CYP_QTRP

							nPropProd := nQtdReserva / CYQ->CYQ_QTOR  // qtd reserva / qtd ordem

							oModelCZP:SetValue( 'CZP_QTRPPO', IF(nQtdAtendida < nQtdReserva,nQtdReportar * nPropProd,0))//qtd utilizada

							oModelCZP:SetValue( 'CZP_QTMT'  , nQtdReserva) //qtd reserva
							oModelCZP:SetValue( 'CZP_QTRP'  , nQtdAtendida ) // qtd atendida
							lExiste := .T.
							Exit
						Endif
					Endif
				Next

				If !lExiste
					if nI > oModelCZP:GetQtdLine()
						aCYPArea := CYP->(getArea())
						oModelCZP:AddLine()
						CYP->( RestArea(aCYPArea) )
					Else
						oModelCZP:GoLine(nI)

						if oModelCZP:IsDeleted()
							oModelCZP:UnDeleteLine()
						Endif
					Endif

					nI++

					oModelCZP:SetNoUpdateLine(.F.)

					nPropProd := CYP->CYP_QTMT / CYQ->CYQ_QTOR

					oModelCZP:SetValue( 'CZP_NRSQRP', M->CYV_NRSQRP )
					oModelCZP:SetValue( 'CZP_NRORPO', M->CYV_NRORPO )
					oModelCZP:SetValue( 'CZP_IDMTOR', CYP->CYP_IDMTOR )
					oModelCZP:SetValue( 'CZP_QTRPPO', IF(CYP->CYP_QTRP < CYP->CYP_QTMT,nQtdReportar * nPropProd,0))
					oModelCZP:SetValue( 'CZP_CDMT'  , CYP->CYP_CDMT )
					oModelCZP:SetValue( 'CZP_DTMT'  , CYP->CYP_DTMT )
					oModelCZP:SetValue( 'CZP_QTMT'  , CYP->CYP_QTMT )
					oModelCZP:SetValue( 'CZP_CDUN'  , CYP->CYP_CDUN )
					oModelCZP:SetValue( 'CZP_QTRP'  , CYP->CYP_QTRP )
					oModelCZP:SetValue( 'CZP_CDLO'  , CYP->CYP_CDLO )
					oModelCZP:SetValue( 'CZP_CDAT'  , CYP->CYP_CDAT )
					oModelCZP:SetValue( 'CZP_CDDP'  , CYP->CYP_CDDP )
					oModelCZP:SetValue( 'CZP_TPST'  , CYP->CYP_TPST )
					oModelCZP:SetValue( 'CZP_CDACPI', CYP->CYP_CDACPI )
					oModelCZP:SetValue( 'CZP_CDRT'  , CYP->CYP_CDRT )
					oModelCZP:SetValue( 'CZP_CDRE'  , CYP->CYP_CDRE )
					oModelCZP:SetValue( 'CZP_NRORRE', CYP->CYP_NRORRE )
					oModelCZP:SetValue( 'CZP_CDLC'  , CYP->CYP_CDLC )
					oModelCZP:SetValue( 'CZP_CDTBMT', CYP->CYP_CDTBMT )
				Endif
			Endif

			CYP->(dbSkip())
		End
	Endif
Endif

if nI > 1
	iTam := LEN(oModelCZP:ADATAMODEL)
	oModelCZP:AddLine()
	ASIZE(oModelCZP:aDataModel, iTam)
Endif

IF SFCIntegra() == 1
	if GetMV("MV_REQAUT") == 'D'
		oModelCZP:SetNoInsertLine(.F.)
		oModelCZP:SetNoUpdateLine(.F.)
	Else
		oModelCZP:SetNoInsertLine(.T.)
		oModelCZP:SetNoUpdateLine(.T.)
	Endif
/* integraÁ„o com datasul n„o tem previs„o de sair
Elseif SFCIntegra() == 2
	oModelCZP:SetNoInsertLine(.F.)
	oModelCZP:SetNoUpdateLine(.F.)*/
Endif

If !lAutomacao
	oModelCZP:GoLine(1)
EndIf

RestArea(aAreaCY9)
RestArea(aAreaCYQ)
RestArea(aAreaCYP)
RestArea(aArea)

Return .T.

//-------------------------------------------------------------------
// Limpa o grid sem reiniciar o Model.
Static Function SFCA314CLG(oModel)

	Local nI         := 0
	Local nTamHeader := 0

	nTamHeader	:= LEN(oModel:aHeader)

	oModel:GoLine(1)

	ASIZE(oModel:aDataModel, 1)
	ASIZE(oModel:aCols, 1)

	For nI := 1 To nTamHeader
		oModel:ClearField(oModel:aHeader[nI][2])
	Next nI

	//AddLine forÁa um refresh no grid, os aSizes removem a nova linha em branco.
	oModel:AddLine()
	ASIZE(oModel:aDataModel, 1)
	ASIZE(oModel:aCols, 1)

Return Nil


//-------------------------------------------------------------------
// Carrega MOD
//-------------------------------------------------------------------
Static Function SFCA314MOD (dIni,cHoraIni,dFim,cHoraFim,cMaquina)
Local oModel     := FwModelActive()
Local oModelCYV  :=	oModel:GetModel( 'CYVMASTER' )
Local oModelCYW  :=	oModel:GetModel( 'CYWDETAIL' )
Local aArea      := GetArea()
Local aAreaCYQ   := CYQ->( GetArea() )
Local aAreaCY9   := CY9->( GetArea() )
Local aRetorno	 := {}
Local nI		 := 0
Local nI2		 := 0
Local cNRORPO    := oModelCYV:GetValue('CYV_NRORPO')
Local dDTRPBG    := oModelCYV:GetValue('CYV_DTRPBG')
Local dDTRPED    := oModelCYV:GetValue('CYV_DTRPED')
Local cHRRPBG    := oModelCYV:GetValue('CYV_HRRPBG')
Local cHRRPED    := oModelCYV:GetValue('CYV_HRRPED')
Local lMOB		 := .F.
Local lSFCInt    := SFCIntegra()
Local cCDCETR    := Posicione("CYB",1,xFilial("CYB")+cMaquina,"CYB_CDCETR")
Local cSFCTPRE   := GetMv("MV_SFCTPRE")

oModelCYW:SetNoInsertLine(.F.)
oModelCYW:SetNoUpdateLine(.F.)

if Posicione("CYI",1,xFilial("CYI")+cCDCETR,"CYI_TPMOD") == '1'
	oModelCYW:SetNoInsertLine(.T.)
	oModelCYW:SetNoUpdateLine(.T.)
Else
	dbSelectArea('CYQ')
	CYQ->(dbSetOrder(1))
	if CYQ->(dbSeek(xFilial('CYQ')+cNRORPO)) .AND. CYQ->CYQ_NRORPO == cNRORPO .AND. CYQ->CYQ_TPMOD == '1' // Real

		dbSelectArea('CY9')
		CY9->(dbSetOrder(1))
		if CY9->(dbSeek(xFilial('CY9')+cNRORPO+oModelCYV:GetValue('CYV_IDAT')))

			if lSFCInt == 1
				lMOB := .T.
			/* integraÁ„o com datasul n„o tem previs„o de sair
			ElseIf lSFCInt == 2

				dbSelectArea('CYC')
				CYC->(dbSetOrder(1))
				if CYC->(dbSeek(xFilial('CYC')+cMaquina+'1'))
					While CYC->(!EOF()) .AND. CYC->CYC_CDMQ == cMaquina .AND. CYC->CYC_TPRC == '1'

						dbSelectArea('CYH')
						CYH->(dbSetOrder(2))
						if CYH->(dbSeek(xFilial('CYH')+CYC->CYC_IDRC))
							if !Empty(CYH->CYH_CDMOD)
								nI2++
							Endif
						Endif

						CYC->(dbSkip())
					End
				Endif

				dbSelectArea('CYC')
				CYC->(dbSetOrder(1))
				if CYC->(dbSeek(xFilial('CYC')+cMaquina+'3'))
					While CYC->(!EOF()) .AND. CYC->CYC_CDMQ == cMaquina .AND. CYC->CYC_TPRC == '3'

						dbSelectArea('CZ1')
						CZ1->(dbSetOrder(1))
						if CZ1->(dbSeek(xFilial('CZ1')+CYC->CYC_IDRC))
							While CZ1->(!EOF()) .AND. CZ1->CZ1_IDRCGR == CYC->CYC_IDRC

								dbSelectArea('CYH')
								CYH->(dbSetOrder(2))
								if CYH->(dbSeek(xFilial('CYH')+CZ1->CZ1_IDRCOE))
									if !Empty(CYH->CYH_CDMOD)
										nI2++
									Endif
								Endif

								CZ1->(dbSkip())
							End
						Endif

						CZ1->(dbSkip())
					End
				Endif

				if nI2 > 0 .OR. !Empty(CY9->CY9_CDMOD)
				    lMOB := .T.
				Endif*/
			Endif

			if lMOB
				if oModelCYW:Length() > 1
					For nI := 1 To oModelCYW:Length()
						oModelCYW:GoLine( nI )

						oModelCYW:SetValue( 'CYW_DTBGRP', dDTRPBG )
						oModelCYW:SetValue( 'CYW_DTEDRP', dDTRPED )
						oModelCYW:SetValue( 'CYW_CDTN'  , oModelCYV:GetValue('CYV_CDTN') )
						oModelCYW:SetValue( 'CYW_NRTN'  , oModelCYV:GetValue('CYV_NRTN') )

						If cSFCTPRE == '2'
							oModelCYW:SetValue( 'CYW_HCBGRP', oModelCYV:GetValue('CYV_HCRPBG') )
							oModelCYW:SetValue( 'CYW_HCEDRP', oModelCYV:GetValue('CYV_HCRPED') )
						Endif

						oModelCYW:SetValue( 'CYW_HRBGRP', cHRRPBG )
						oModelCYW:SetValue( 'CYW_HREDRP', cHRRPED )

						aRetorno := SFCXTEMPOS('', '', 3, cMaquina, dDTRPBG, dDTRPED, cHRRPBG, cHRRPED,.F.,'SFCA314')

						oModelCYW:SetValue ( 'CYW_QTTEUT', aRetorno[3])
						oModelCYW:SetValue ( 'CYW_QTTEEX', aRetorno[4])
						oModelCYW:SetValue ( 'CYW_QTTEOE', aRetorno[3] + aRetorno[4])
				 	Next
				Else
					oModelCYW:SetValue ( 'CYW_DTBGRP', dDTRPBG )
					oModelCYW:SetValue ( 'CYW_DTEDRP', dDTRPED )
					oModelCYW:SetValue ( 'CYW_CDTN'  , oModelCYV:GetValue('CYV_CDTN') )
					oModelCYW:SetValue ( 'CYW_NRTN'  , oModelCYV:GetValue('CYV_NRTN') )

					If cSFCTPRE == '2'
						oModelCYW:SetValue( 'CYW_HCBGRP', oModelCYV:GetValue('CYV_HCRPBG') )
						oModelCYW:SetValue( 'CYW_HCEDRP', oModelCYV:GetValue('CYV_HCRPED') )
					Endif

					oModelCYW:SetValue( 'CYW_HRBGRP', cHRRPBG )
					oModelCYW:SetValue( 'CYW_HREDRP', cHRRPED )

					aRetorno := SFCXTEMPOS('', '', 3, cMaquina, dDTRPBG, dDTRPED, cHRRPBG, cHRRPED,.F.,'SFCA314')

					oModelCYW:SetValue ( 'CYW_QTTEUT', aRetorno[3])
					oModelCYW:SetValue ( 'CYW_QTTEEX', aRetorno[4])
					oModelCYW:SetValue ( 'CYW_QTTEOE', aRetorno[3] + aRetorno[4])

					if nI2 == 1
						oModelCYW:SetValue ( 'CYW_QTTEEX', aRetorno[4])
					Endif
				Endif
			Else
				oModelCYW:SetNoInsertLine(.T.)
				oModelCYW:SetNoUpdateLine(.T.)
			Endif
		Endif
	Else
		oModelCYW:SetNoInsertLine(.T.)
		oModelCYW:SetNoUpdateLine(.T.)
	Endif
Endif

RestArea(aAreaCY9)
RestArea(aAreaCYQ)
RestArea(aArea)

Return .T.

//-------------------------------------------------------------------
// Carrega GGF
//-------------------------------------------------------------------
Static Function SFCA314GGF (nTempo, cMaquina)
Local oModel     := FwModelActive()
Local oModelCZW  :=	oModel:GetModel( 'CZWDETAIL' )
Local oModelCYV  :=	oModel:GetModel( 'CYVMASTER' )
Local aArea      := GetArea()
Local aAreaCYQ   := CYQ->( GetArea() )
Local aAreaCYB   := CYB->( GetArea() )
Local nI		 := 0
Local cNRORPO    := oModelCYV:GetValue('CYV_NRORPO')

dbSelectArea('CYQ')
CYQ->(dbSetOrder(1))
CYQ->(dbGoTop())
IF CYQ->(dbSeek(xFilial('CYQ')+cNRORPO)) .AND. CYQ->CYQ_NRORPO == cNRORPO

	dbSelectArea('CYB')
	CYB->(dbSetOrder(1))
	CYB->(dbGoTop())
	CYB->(dbSeek(xFilial('CYB')+cMaquina))

	oModel:GetModel('CZWDETAIL'):SetNoInsertLine(.F.)
	oModel:GetModel('CZWDETAIL'):SetNoUpdateLine(.F.)

	if oModelCZW:Length() > 1
		For nI := 1 To oModelCZW:Length()
			oModelCZW:GoLine( nI )

			if oModelCZW:GetValue( 'CZW_CDCETR') == CYB->CYB_CDCETR
				oModelCZW:SetValue( 'CZW_HRTEGF', nTempo )
				Exit
			Endif
	 	Next
	Else
		oModelCZW:SetValue( 'CZW_CDCETR', CYB->CYB_CDCETR )
		oModelCZW:SetValue( 'CZW_HRTEGF', nTempo )
	Endif

	if CYQ->CYQ_TPGGF == '2' /* Padr„o */
		oModel:GetModel('CZWDETAIL'):SetNoInsertLine(.T.)
		oModel:GetModel('CZWDETAIL'):SetNoUpdateLine(.T.)
	Endif
Endif

RestArea(aAreaCYB)
RestArea(aAreaCYQ)
RestArea(aArea)

Return .T.

//-------------------------------------------------------------------
// Ajusta data fim de setup - ajustaDataFimSetup - sfapi009
// Entra: data inicio setup, hora inicio setup ,tempo de operaÁ„o
// Retorna: data fim setup, hora fim setup, data inicio reporte, hora inicio reporte,
//			data fim reporte, hora fim reporte
//-------------------------------------------------------------------
Function SFCA314AFS (cCDMQ, dIniSetup, cHoraIniSetup, nTempoOper, nTempoSetup)
Local aRetorno  := {}
Local a2Retorno := {}
Local a3Retorno := {}
Local aArea      := GetArea()
Local aAreaCYB   := CYB->( GetArea() )

dbSelectArea('CYB')
CYB->(dbSetOrder(1))
CYB->(dbGoTop())
CYB->(dbSeek(xFilial('CYB')+cCDMQ))

//Calcula tempos para Setup
//Retorna: 1-ct,2-calend,3-data fim,4-hora fim,5-data ini,6-hora ini,7-tempo,8-turno,9-num turno,10-extra
aRetorno := SFCA314TPM (CYB->CYB_CDCETR,cCDMQ,'',CTOD('01/01/0001'),0,dIniSetup,SFCXHourToSeg(cHoraIniSetup),nTempoSetup / 3600)

//Calcula tempos para operaÁ„o
//Retorna: 1-ct,2-calend,3-data fim,4-hora fim,5-data ini,6-hora ini,7-tempo,8-turno,9-num turno,10-extra
a2Retorno := SFCA314TPM(CYB->CYB_CDCETR,cCDMQ,'',CTOD('01/01/0001'),0,aRetorno[3],aRetorno[4],nTempoOper)

AADD(a3Retorno,aRetorno[3])                 // Data Fim Setup
AADD(a3Retorno,SFCXSegToHour(aRetorno[4]))  // Hora Fim Setup
AADD(a3Retorno,aRetorno[3])                 // Data InÌcio Reporte
AADD(a3Retorno,SFCXSegToHour(aRetorno[4]))  // Hora InÌcio Reporte
AADD(a3Retorno,a2Retorno[3])                // Data Fim Report
AADD(a3Retorno,SFCXSegToHour(a2Retorno[4])) // Hora Fim Reporte
AADD(a3Retorno,a2Retorno[8])                // Turno
AADD(a3Retorno,a2Retorno[9])                // N˙mero turno
AADD(a3Retorno,a2Retorno[10])               // Tempo Extra

RestArea(aArea)
RestArea(aAreaCYB)

Return a3Retorno

//-------------------------------------------------------------------
// Recalcula datas para quanto utilizado dispatch list
//-------------------------------------------------------------------
Function SFCA314REC(nI,dInicial,cInicial)
Local lRet 		:= .T.
Local nI2  		:= 0
Local oModel    := FWMODELACTIVE()
Local oView     := FwViewActive()
Local oModelCYV := oModel:GetModel( 'CYVMASTER' )
Local cNRORPO   := oModelCYV:GetValue('CYV_NRORPO')
Local cIDAT     := oModelCYV:GetValue('CYV_IDAT')
Local aAreaCYB  := CYB->(GetArea())
Local aAreaCYY  := CYY->(GetArea())
Local aArea     := GetArea()
Local aRetorno	:= {}
Local cMaquina  := ''
Local cSFCTPRE  := GetMv("MV_SFCTPRE")
Default lAutomacao := .F.

if IsInCallStack('SFCA318ATV')
	cMaquina := oModel:GetValue('MAQMASTER','CYV_CDMQ')
Else
	cMaquina := oModelCYV:GetValue('CYV_CDMQ')
Endif

dbSelectArea('CYB')
CYB->(dbSetOrder(1))
CYB->(dbGoTop())
if CYB->(dbSeek(xFilial('CYB')+cMaquina)) .AND. CYB->CYB_CDMQ == cMaquina

	if nI != oModelCYV:Length()

		For nI2 := (nI + 1) to oModelCYV:Length()
			oModelCYV:GoLine(nI2)

			if !CYB->CYB_LGSU
				oModelCYV:LoadValue('CYV_DTRPBG',dInicial)
				oModelCYV:LoadValue('CYV_HRRPBG',cInicial)

				If cSFCTPRE == '2'
					oModelCYV:LoadValue('CYV_HCRPBG',SFCXHRTOCEN(cInicial))
				EndIf
			Else
				dbSelectArea('CYY')
				CYY->(dbSetOrder(1))
				CYY->(dbGoTop())
				CYY->(dbSeek(xFilial('CYY')+cNRORPO+cIDAT+oModelCYV:GetValue('CYV_IDATQO')))
				if Empty(CYY->CYY_DTBGSU)
					oModelCYV:LoadValue('CYV_DTBGSU',dInicial)
					oModelCYV:LoadValue('CYV_HRBGSU',cInicial)

					If cSFCTPRE == '2'
						oModelCYV:LoadValue('CYV_HCBGSU',SFCXHRTOCEN(cInicial))
					EndIf

					aRetorno := SFCA314AFS(cMaquina,dInicial,cInicial,oModelCYV:GetValue('CYV_QTTERP') / 3600,CYY->CYY_QTPASU)

					oModelCYV:LoadValue('CYV_DTEDSU', aRetorno[1])
					oModelCYV:LoadValue('CYV_HREDSU', aRetorno[2])
					oModelCYV:LoadValue('CYV_DTRPBG', aRetorno[3])
					oModelCYV:LoadValue('CYV_HRRPBG', aRetorno[4])

					If cSFCTPRE == '2'
						oModelCYV:LoadValue('CYV_HCEDSU',SFCXHRTOCEN(aRetorno[2]))
						oModelCYV:LoadValue('CYV_HCRPBG',SFCXHRTOCEN(aRetorno[4]))
					EndIf

					if !Empty(aRetorno[7])
						oModelCYV:LoadValue('CYV_CDTN', aRetorno[7])
						oModelCYV:LoadValue('CYV_NRTN', STRZERO(VAL(aRetorno[8]), 5))
					Endif

					dInicial := aRetorno[3]
					cInicial := aRetorno[4]
				Else
					oModelCYV:LoadValue('CYV_DTRPBG',dInicial)
					oModelCYV:LoadValue('CYV_HRRPBG',cInicial)

					If cSFCTPRE == '2'
						oModelCYV:LoadValue('CYV_HCRPBG',SFCXHRTOCEN(cInicial))
					EndIf
				Endif
			Endif

			//Calcula tempos
			//Retorna: 1-ct,2-calend,3-data fim,4-hora fim,5-data ini,6-hora ini,7-tempo,8-turno,9-num turno,10-extra
			aRetorno := SFCA314TPM(CYB->CYB_CDCETR,cMaquina,'',CTOD('01/01/0001'),0,dInicial,SFCXHourToSeg(cInicial),oModelCYV:GetValue('CYV_QTTERP') / 3600)

			oModelCYV:LoadValue('CYV_DTRPED',aRetorno[3])
			oModelCYV:LoadValue('CYV_HRRPED',SFCXSegToHour(aRetorno[4]))

			If cSFCTPRE == '2'
				oModelCYV:LoadValue('CYV_HCRPED',SFCXSegtoCent(aRetorno[4]))
			EndIf

			if !Empty(aRetorno[9])
				oModelCYV:SetValue('CYV_CDTN',aRetorno[8])
				oModelCYV:SetValue('CYV_NRTN',STRZERO(VAL(aRetorno[9]), 5))
			Endif

			SFCA314MOD(dInicial,cInicial,aRetorno[3],SFCXSegToHour(aRetorno[4]),cMaquina)

			dInicial := oModelCYV:GetValue('CYV_DTRPED')
			cInicial := oModelCYV:GetValue('CYV_HRRPED')
		Next
	Endif
Endif

RestArea(aAreaCYB)
RestArea(aAreaCYY)
RestArea(aArea)

If !lAutomacao
	oView:Refresh()
EndIf

Return lRet

//-------------------------------------------------------------------
// Carrega informaÁıes iniciais no programa
//-------------------------------------------------------------------
Function SFCA314PRE (oModel, nTipo, dUltDL,nUltDL)
Local oModelCYV     := oModel:GetModel( 'CYVMASTER' )
Local oModelCZP     := oModel:GetModel( 'CZPDETAIL' )
Local oModelCZ0     := oModel:GetModel( 'CZ0DETAIL' )
Local aRetorno      := {}
Local nQtdReportar  := 0
Local nTempoOper    := 0
Local aArea    	    := GetArea()
Local aAreaCYB      := CYB->( GetArea() )
Local aAreaCYQ      := CYQ->( GetArea() )
Local aAreaCY9      := CY9->( GetArea() )
Local lRet 		    := .T.
Local lSetup        := .F. // Define se o setup j· foi iniciado ou n„o
Local nOpc 		    := oModel:GetOperation()
Local cNRORPO       := ''
Local cIDAT         := ''
Local cIDATQO       := ''
Local nSegUltEvent  := 0
Local cMaquina      := ''
Local dUltEvent     := CTOD('01/01/0001')
Local a3Retorno		:= {}
Local cCDTN			:= ''
Local lFinaliza     := nOpc == 4 .AND. IsInCallStack('SFCA310FIM') .Or. SFCA314IF(oModel, 2)
Local lInicia       := nOpc == 3 .AND. IsInCallStack('SFCA319INI') .Or. SFCA314IF(oModel, 1)
Local lDispatch     := nTipo == 2
Local lValidOper   := .T.
Local cSFCTPRE     := GetMv("MV_SFCTPRE")

if lInicia
	Return .T.
Endif

If SFCA314IF(oModel, 3)
	Return .T.
EndIf

Pergunte('MTA680',.F.)

if MV_PAR07 == 3
	lValidOper := .F.
Endif

if nOpc == 3 .OR. nOpc == 4

	If !IsInCallStack('SFCA311DAP')
		if lDispatch .OR. lFinaliza .OR. IsInCallStack('SFCA316') .OR. IsInCallStack('SFCA320') .Or. IsInCallStack('ACDV314')
			cNRORPO  := oModelCYV:GetValue('CYV_NRORPO')
			cIDAT    := oModelCYV:GetValue('CYV_IDAT')
			cIDATQO  := oModelCYV:GetValue('CYV_IDATQO')
		ElseIf IsInCallStack('SFCA310')
			cNRORPO := CYY->CYY_NRORPO
			cIDAT   := CYY->CYY_IDAT
			cIDATQO := CYY->CYY_IDATQO

			oModelCYV:SetValue('CYV_NRORPO',cNRORPO)
			oModelCYV:SetValue('CYV_IDAT'  ,cIDAT)
			oModelCYV:SetValue('CYV_IDATQO',cIDATQO)
		Endif
	EndIf

	if lDispatch
		cMaquina := oModel:GetValue('MAQMASTER','CYV_CDMQ')
	Else
		cMaquina := oModelCYV:GetValue('CYV_CDMQ')

		if Empty(cMaquina)
			if !Empty(cNRORPO) .AND. !Empty(cIDAT) .AND. !Empty(cIDATQO)
				dbSelectArea('CYY')
				CYY->(dbSetOrder(1))
				CYY->(dbGoTop())
				CYY->(dbSeek(xFilial('CYY')+cNRORPO+cIDAT+cIDATQO))

				if Empty(CYY->CYY_CDMQ)
					if IsInCallStack('SFCA310')
						oModelCYV:SetValue('CYV_CDMQ', _MaqSFC310)
						cMaquina := _MaqSFC310
					Endif
				Else
					oModelCYV:SetValue('CYV_CDMQ',CYY->CYY_CDMQ)
					cMaquina := CYY->CYY_CDMQ
				Endif
			Endif
		Endif
	Endif
Endif

// Somente executar este processo se todos os campos estiverem preenchidos:
// cNRORPO, cIDAT, cIDATQO, cMaquina
if (nOpc == 3 .OR. nOpc == 4) .AND.	!Empty(cNRORPO) .AND. !Empty(cIDAT) .AND. !Empty(cIDATQO) .AND. !Empty(cMaquina)

	dbSelectArea('CYB')
	CYB->(dbSetOrder(1))
	CYB->(dbSeek(xFilial('CYB')+cMaquina))

	dbSelectArea('CYQ')
	CYQ->(dbSetOrder(1))
	CYQ->(dbSeek(xFilial('CYQ')+cNRORPO))

	dbSelectArea('CYY')
	CYY->(dbSetOrder(1))
	CYY->(dbSeek(xFilial('CYY')+cNRORPO+cIDAT+cIDATQO))

	// Quando finalizando, n„o deve repreencher os campos de data e hora iniciais
	if lFinaliza
		dUltEvent    := oModelCYV:GetValue('CYV_DTRPBG')
		nSegUltEvent := SFCXHourToSeg(oModelCYV:GetValue('CYV_HRRPBG'))
	Else

		// Verifica se tem uma parada em aberto para esta m·quina
		if SFCSetupIn(cMaquina)
			lSetup       := .T.
			dUltEvent    := date()
			nSegUltEvent := SFCXHourToSeg(time())
		Else
			IF !lDispatch .OR. (lDispatch .AND. Empty(dUltDL))
				// Busca ultimo evento do centro de trabalho
				a3Retorno := SFCA314ULT(cNRORPO, cIDAT, cIDATQO, cMaquina)

				dUltEvent    := a3Retorno[1]
				nSegUltEvent := a3Retorno[2]
				cCDTN        := a3Retorno[3]

			Else
				dUltEvent    := dUltDL
				nSegUltEvent := nUltDL
			Endif
		Endif
	Endif

	if lValidOper

		nQtdReportar := SFCA314QRP(cNRORPO, cIDAT, cIDATQO, 0, .T., 1, dUltEvent, SFCXSegToHour(nSegUltEvent), .T., if(lDispatch,oModelCYV,nil),dUltDL, nUltDL)

		oModelCYV:LoadValue('CYV_QTATAP', nQtdReportar)
		oModelCYV:LoadValue('CYV_QTATRP', nQtdReportar)

		// AvanÁo
		oModelCYV:SetValue('CYV_VLPNRY', SFCA314AVA(cNRORPO, cIDAT, cIDATQO, nQtdReportar, nQtdReportar))

		//Retorna tempo de operaÁ„o
		//Retorna: 1-nTempoOper,2-nTempoHomem,3-nCargaPad
		aRetorno := SFCA314OPER(CYB->CYB_CDCETR,cNRORPO,cIDAT,nQtdReportar, 1)

		nTempoOper := aRetorno[1]
		oModelCYV:LoadValue('CYV_HRTERP', ROUND(nTempoOper / 3600,4))
		oModelCYV:LoadValue('CYV_QTTERP', nTempoOper)
	Else
		nQtdReportar := 0
	Endif

	if !CYB->CYB_LGSU // Se n„o tem setup

		IF lValidOper
			//Calcula tempos
			//Retorna: 1-ct,2-calend,3-data fim,4-hora fim,5-data ini,6-hora ini,7-tempo,8-turno,9-num turno,10-extra
			aRetorno := SFCA314TPM(CYB->CYB_CDCETR,cMaquina,'',CTOD('01/01/0001'),0,dUltEvent,nSegUltEvent,ROUND(nTempoOper / 3600,2),cCDTN)

			oModelCYV:ClearField('CYV_DTBGSU')
			oModelCYV:ClearField('CYV_HRBGSU')
			oModelCYV:ClearField('CYV_DTEDSU')
			oModelCYV:ClearField('CYV_HREDSU')

			oModelCYV:LoadValue('CYV_DTRPBG',aRetorno[5])
			oModelCYV:LoadValue('CYV_HRRPBG',SFCXSegToHour(aRetorno[6]))
			oModelCYV:LoadValue('CYV_DTRPED',aRetorno[3])
			oModelCYV:LoadValue('CYV_HRRPED',SFCXSegToHour(aRetorno[4]))
			oModelCYV:LoadValue('CYV_HRTERP',ROUND(aRetorno[7],4))
			oModelCYV:LoadValue('CYV_QTTERP',aRetorno[7] * 3600)
		Else
			oModelCYV:LoadValue('CYV_DTRPBG',dUltEvent)
			oModelCYV:LoadValue('CYV_HRRPBG',SFCXSegToHour(nSegUltEvent))
			oModelCYV:LoadValue('CYV_DTRPED',dUltEvent)
			oModelCYV:LoadValue('CYV_HRRPED',SFCXSegToHour(nSegUltEvent))

			aRetorno := {,,dUltEvent,nSegUltEvent,dUltEvent,nSegUltEvent,0,cCDTN,''}
		Endif
	Else // se tem setup

		if CYY->CYY_TPSTAT == '4' // se split j· foi iniciado
			oModelCYV:LoadValue('CYV_DTBGSU',CYY->CYY_DTBGSU)
			oModelCYV:LoadValue('CYV_HRBGSU',CYY->CYY_HRBGSU)
			oModelCYV:LoadValue('CYV_DTEDSU',CYY->CYY_DTEDSU)
			oModelCYV:LoadValue('CYV_HREDSU',CYY->CYY_HREDSU)

			IF lValidOper

				//Calcula tempos
				//Retorna: 1-ct,2-calend,3-data fim,4-hora fim,5-data ini,6-hora ini,7-tempo,8-turno,9-num turno,10-extra
				aRetorno := SFCA314TPM(CYB->CYB_CDCETR,cMaquina,'',CTOD('01/01/0001'),0,dUltEvent,nSegUltEvent,ROUND(nTempoOper / 3600,2),cCDTN)
			Else
				aRetorno := {,,dUltEvent,nSegUltEvent,dUltEvent,nSegUltEvent,0,cCDTN,''}
			Endif
		Else
			if lSetup // se j· foi iniciado setup e tem parada aberta

				IF lValidOper
					oModelCYV:LoadValue('CYV_DTBGSU',CYX->CYX_DTBGSP)
					oModelCYV:LoadValue('CYV_HRBGSU',CYX->CYX_HRBGSP)
					oModelCYV:LoadValue('CYV_DTEDSU',dUltEvent)
					oModelCYV:LoadValue('CYV_HREDSU',SFCXSegToHour(nSegUltEvent))
					oModelCYV:SetValue ('CYV_CDSU'  ,CYX->CYX_CDSP)

					//Calcula tempos
					//Retorna: 1-ct,2-calend,3-data fim,4-hora fim,5-data ini,6-hora ini,7-tempo,8-turno,9-num turno,10-extra
					aRetorno := SFCA314TPM(CYB->CYB_CDCETR,cMaquina,'',CTOD('01/01/0001'),0,dUltEvent,nSegUltEvent,ROUND(nTempoOper / 3600,2),cCDTN)
				Else
					aRetorno := {,,dUltEvent,nSegUltEvent,dUltEvent,nSegUltEvent,0,cCDTN,''}
				Endif
			Else // se n„o tem parada ainda

				if lFinaliza
					// N„o È possÌvel iniciar apontamento quando possui split, mas caso for alterada a m·quina para fazer preparaÁ„o,
					// ent„o colocamos data de inÌcio e fim de preparaÁ„o igual ‡ data e hora de inÌcio do apontamento
					oModelCYV:LoadValue('CYV_DTBGSU',dUltEvent)
					oModelCYV:LoadValue('CYV_HRBGSU',SFCXSegToHour(nSegUltEvent))
					oModelCYV:LoadValue('CYV_DTEDSU',dUltEvent)
					oModelCYV:LoadValue('CYV_HREDSU',SFCXSegToHour(nSegUltEvent))

					aRetorno := SFCA314TPM(CYB->CYB_CDCETR,cMaquina,'',CTOD('01/01/0001'),0,dUltEvent,nSegUltEvent,ROUND(nTempoOper / 3600,2),cCDTN)
				Else

					//Calcula tempos setup
					//Retorna: 1-ct,2-calend,3-data fim,4-hora fim,5-data ini,6-hora ini,7-tempo,8-turno,9-num turno,10-extra
					aRetorno := SFCA314TPM(CYB->CYB_CDCETR,cMaquina,'',CTOD('01/01/0001'),0,dUltEvent,nSegUltEvent,ROUND(CYY->CYY_QTPASU / 3600,2),cCDTN)

					oModelCYV:LoadValue('CYV_DTBGSU',aRetorno[5])
					oModelCYV:LoadValue('CYV_HRBGSU',SFCXSegToHour(aRetorno[6]))
					oModelCYV:LoadValue('CYV_DTEDSU',aRetorno[3])
					oModelCYV:LoadValue('CYV_HREDSU',SFCXSegToHour(aRetorno[4]))

					if lValidOper
						//Calcula tempos operaÁ„o
						//Retorna: 1-ct,2-calend,3-data fim,4-hora fim,5-data ini,6-hora ini,7-tempo,8-turno,9-num turno,10-extra
						aRetorno := SFCA314TPM(CYB->CYB_CDCETR,cMaquina,'',CTOD('01/01/0001'),0,aRetorno[3],aRetorno[4],ROUND(nTempoOper / 3600,2),cCDTN)
					Else
						aRetorno := {,,aRetorno[3],aRetorno[4],aRetorno[3],aRetorno[4],0,cCDTN, ''}
					Endif
				Endif
			Endif
		Endif

		oModelCYV:LoadValue('CYV_DTRPBG',aRetorno[5])
		oModelCYV:LoadValue('CYV_HRRPBG',SFCXSegToHour(aRetorno[6]))
		oModelCYV:LoadValue('CYV_DTRPED',aRetorno[3])
		oModelCYV:LoadValue('CYV_HRRPED',SFCXSegToHour(aRetorno[4]))
		oModelCYV:LoadValue('CYV_HRTERP',ROUND(aRetorno[7],4))
		oModelCYV:LoadValue('CYV_QTTERP',aRetorno[7] * 3600)
	Endif

	SFCA314CRE (cNRORPO,oModelCYV:GetValue('CYV_IDAT'),oModelCZP,nQtdReportar,CYY->CYY_QTAT)

	if CYB->CYB_LGSU
		If cSFCTPRE == '2'
			oModelCYV:LoadValue('CYV_HCBGSU', SFCXHRTOCEN(oModelCYV:GetValue('CYV_HRBGSU')))
			oModelCYV:LoadValue('CYV_HCEDSU', SFCXHRTOCEN(oModelCYV:GetValue('CYV_HREDSU')))
		Endif
	Endif

	If cSFCTPRE == '2'
		oModelCYV:LoadValue('CYV_HCRPBG', SFCXHRTOCEN(oModelCYV:GetValue('CYV_HRRPBG')))
		oModelCYV:LoadValue('CYV_HCRPED', SFCXHRTOCEN(oModelCYV:GetValue('CYV_HRRPED')))
	Endif

	SFCA314GGF(ROUND(nTempoOper / 3600,4),cMaquina)
	SFCA314MOD(aRetorno[5],SFCXSegToHour(aRetorno[6]),aRetorno[3],SFCXSegToHour(aRetorno[4]),cMaquina)

	oModelCYV:SetValue('CYV_CDTN', aRetorno[8])
	oModelCYV:SetValue('CYV_NRTN', STRZERO(VAL(aRetorno[9]), 5))

	If CYB->CYB_LGSU == .F.
		if Posicione("CY9",1,xFilial("CY9")+cNRORPO+cIDAT,"CY9_TPTE") == '4'
			oModelCZ0:SetNoInsertLine(.F.)
			oModelCZ0:SetNoUpdateLine(.F.)
		Else
			oModelCZ0:SetNoInsertLine(.T.)
			oModelCZ0:SetNoUpdateLine(.T.)
		Endif
	Else
		oModelCZ0:SetNoInsertLine(.F.)
		oModelCZ0:SetNoUpdateLine(.F.)
	EndIf
ElseIf nOpc == 2
	if !IsInCallStack('SFCA316DET')
		oModelCYV:LoadValue('CYV_DSSU', Posicione('CYN',1,xFilial('CYN')+oModelCYV:GetValue('CYV_CDSU'),'CYN_DSSP'))
	Endif
Endif

SFCA314KEY()

RestArea(aAreaCYQ)
RestArea(aAreaCY9)
RestArea(aAreaCYB)
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
// Busca ˙ltimo evento para m·quina
//-------------------------------------------------------------------
Static Function SFCA314ULT(cNRORPO, cIDAT, cIDATQO, cMaquina)
Local dUltEvent    := CTOD('01/01/2000')
Local nSegUltEvent := 0
Local cAliasCYV    := 0
Local aArea        := GetArea()
Local aAreaCYR     := CYR->(GetArea())
Local aAreaCY9     := CY9->(GetArea())
Local aAreaCYD     := CYD->(GetArea())
Local aAreaCYY     := CYY->(GetArea())
Local cCalend      := ''
Local aRetorno     := {}
Local cCDTN        := ''
Local lOk          := .T.
Local dUltEventOLD := CTOD('01/01/2000')
Local lValidOper   := .T.

Pergunte('MTA680',.F.)

lValidOper := MV_PAR07 == 3

dbSelectArea('CYY')
CYY->(dbSetOrder(1))
CYY->(dbSeek(xFilial('CYY')+cNRORPO+cIDAT+cIDATQO))

IF CYY->CYY_LGCGMQ // Split alocado pelo carga m·quina

	dUltEvent    := CYY->CYY_DTIMC
	nSegUltEvent := SFCXHourToSeg(CYY->CYY_HRIMC)
	cCDTN        := SFCA314GTU(,'',cMaquina,CYY->CYY_DTIMC)[1]

Else

	If lValidOper

		// Busca evento da operaÁ„o anterior ao que se deseja reportar
		dbSelectArea('CYD')
		CYD->(dbSetOrder(2))
		CYD->(dbGoTop())
		CYD->(dbSeek(xFilial('CYD')+cNRORPO+cIDAT))

		While CYD->(!EOF()) .AND. CYD->CYD_NRORPO == cNRORPO .AND. CYD->CYD_IDATNX == cIDAT

			DbSelectArea('CY9')
			CY9->(DbSetOrder(1))
			CY9->(DbGoTop())
			If CY9->(DbSeek(xFilial('CY9')+cNRORPO+CYD->CYD_IDATPV))
				cAliasCYV := GetNextAlias()

				BeginSql Alias cAliasCYV

					SELECT * FROM %Table:CYV% CYV
						WHERE CYV.CYV_FILIAL=%xFilial:CYV% AND
							  CYV.CYV_NRORPO=%Exp:cNRORPO% AND
							  CYV.CYV_IDAT=%Exp:CYD->CYD_IDATPV% AND
							  CYV.CYV_LGRPEO='F' AND
							  CYV.%NotDel%
							  ORDER BY CYV.CYV_DTRPBG DESC, CYV.CYV_HRRPBG DESC

				EndSql

				dUltEvent    := STOD((cAliasCYV)->CYV_DTRPED)
				nSegUltEvent := SFCXHourToSeg((cAliasCYV)->CYV_HRRPED)

				(cAliasCYV)->(dbCloseArea())

			Endif

			CYD->(dbSkip())
		End

		RestArea(aAreaCYD)
		RestArea(aAreaCY9)
	Endif

	// Busca ultimo apontamento realizado para a m·quina
	cAliasCYV := GetNextAlias()

	BeginSql Alias cAliasCYV

		SELECT * FROM %Table:CYV% CYV
			WHERE CYV.CYV_FILIAL=%xFilial:CYV% AND
				  CYV.CYV_CDMQ=%Exp:cMaquina% AND
				  CYV.CYV_LGRPEO='F' AND
				  CYV.%NotDel%
				  ORDER BY CYV.CYV_DTRPBG DESC, CYV.CYV_HRRPBG DESC

	EndSql

	if Empty((cAliasCYV)->CYV_DTRPED)
		if Empty(CYY->CYY_DTEDAT)
			if dUltEvent <= CYY->CYY_DTIMC
				if dUltEvent < CYY->CYY_DTIMC
					dUltEvent    := CYY->CYY_DTIMC
					nSegUltEvent := SFCXHourToSeg(CYY->CYY_HRIMC)
				Else
					if nSegUltEvent < SFCXHourToSeg(CYY->CYY_HRIMC)
						nSegUltEvent := SFCXHourToSeg(CYY->CYY_HRIMC)
					Endif
				Endif
			Endif
		Else
			if dUltEvent <= CYY->CYY_DTEDAT
				if dUltEvent < CYY->CYY_DTEDAT
					dUltEvent    := CYY->CYY_DTEDAT
					nSegUltEvent := SFCXHourToSeg(CYY->CYY_HREDAT)
				Else
					if nSegUltEvent < SFCXHourToSeg(CYY->CYY_HREDAT)
						nSegUltEvent := SFCXHourToSeg(CYY->CYY_HREDAT)
					Endif
				Endif
			Endif
		Endif

		RestArea(aAreaCYY)
	Else
		if dUltEvent <= STOD((cAliasCYV)->CYV_DTRPED)
			if dUltEvent < STOD((cAliasCYV)->CYV_DTRPED)
				dUltEvent    := STOD((cAliasCYV)->CYV_DTRPED)
				nSegUltEvent := SFCXHourToSeg((cAliasCYV)->CYV_HRRPED)
			Else
				if nSegUltEvent < SFCXHourToSeg((cAliasCYV)->CYV_HRRPED)
					nSegUltEvent := SFCXHourToSeg((cAliasCYV)->CYV_HRRPED)
				Endif
			Endif
		Endif
	Endif
	(cAliasCYV)->(dbCloseArea())
	// Fim

	// verifica se existe apontamento de parada para ultimo evento encontrado
	cAliasCYX := GetNextAlias()

	BeginSql Alias cAliasCYX

		SELECT * FROM %Table:CYX% CYX
			WHERE CYX.CYX_FILIAL=%xFilial:CYX% AND
				  CYX.CYX_CDMQ=%Exp:cMaquina% AND
			     (CYX.CYX_DTBGSP>%Exp:DTOS(dUltEvent)% OR
			     (CYX.CYX_DTBGSP=%Exp:DTOS(dUltEvent)% AND
			      CYX.CYX_HRBGSP>=%Exp:SFCXSegToHour(nSegUltEvent)%)) AND
				  CYX.%NotDel%
				  ORDER BY CYX.CYX_DTEDSP DESC, CYX.CYX_HREDSP DESC

	EndSql

	IF dUltEvent <= STOD((cAliasCYX)->CYX_DTEDSP)
		if dUltEvent < STOD((cAliasCYX)->CYX_DTEDSP)
			dUltEvent    := STOD((cAliasCYX)->CYX_DTEDSP)
			nSegUltEvent := SFCXHourToSeg((cAliasCYX)->CYX_HREDSP)
		Else
			if nSegUltEvent < SFCXHourToSeg((cAliasCYX)->CYX_HREDSP)
				nSegUltEvent := SFCXHourToSeg((cAliasCYX)->CYX_HREDSP)
			Endif
		Endif
	Endif

	(cAliasCYX)->(dbCloseArea())
	// Fim

	cCalend := SFCCalendario(cMaquina,'')

	// Busca se tem calend·rio
	dbSelectArea('CYZ')
	CYZ->(dbSetOrder(1))
	CYZ->(dbGoTop())
	if !CYZ->(dbSeek(xFilial('CYZ')+cCalend+DTOS(dUltEvent)))
		dUltEvent := date()
	Endif

	aRetorno := SFCA314GTU(,'',cMaquina,dUltEvent)
	cCDTN    := aRetorno[1]

	dbSelectArea('CYR')
	CYR->(dbSetOrder(2))
	CYR->(dbGoTop())

	dUltEventOLD := dUltEvent

	// Procura primeiro turno v·lido a partir da data de ˙ltimo evento
	While lOk

		if CYR->(dbSeek(xFilial('CYR')+cCDTN+ALLTRIM(STR(DOW(dUltEvent)))))
			While CYR->(!EOF()) .AND. CYR->CYR_CDTN == cCDTN .AND. CYR->CYR_NRDYWK == ALLTRIM(STR(DOW(dUltEvent)))
				if CYR->CYR_TPTE == '1'
					if nSegUltEvent < SFCXHourToSeg(CYR->CYR_HRBG)
						nSegUltEvent := SFCXHourToSeg(CYR->CYR_HRBG)
						lOk := .F.
						Exit
					Endif

					IF nSegUltEvent >= SFCXHourToSeg(CYR->CYR_HRBG) .AND. nSegUltEvent < SFCXHourToSeg(CYR->CYR_HRED)
						aRetorno := SFCA311VTP(cCDTN, ALLTRIM(STR(DOW(dUltEvent))), CYR->CYR_HRBG, CYR->CYR_HRED, 0, 0)

						if nSegUltEvent >= SFCXHourToSeg(aRetorno[3]) .AND. nSegUltEvent <= SFCXHourToSeg(aRetorno[4])
							nSegUltEvent := SFCXHourToSeg(aRetorno[4])
						Endif

						lOk := .F.
						Exit
					Endif
				Endif
				CYR->(dbSkip())
			End

			if !lOk
				Exit
			Endif

			dUltEvent += 1
			nSegUltEvent := 0
		Else
			dUltEvent += 1
			nSegUltEvent := 0
		Endif

		if dUltEventOLD + 100 < dUltEvent
			dUltEvent := dUltEventOLD
			Exit
		Endif
	End
	// Fim
Endif

RestArea ( aAreaCYR )
RestArea ( aArea )

Return {dUltEvent, nSegUltEvent, cCDTN}

//-------------------------------------------------------------------
// Salva informaÁıes nas outras tabelas (CYQ, CY9, CYP, CYY, CYX)
// Input: Model, M·quina
// Retorno: Se foi possÌvel
//-------------------------------------------------------------------
Function SFCA314SAL (oModelCYV, cMaquina)
Local aArea     := GetArea()
Local aAreaCYB  := CYB->(GetArea())
Local aAreaCZ1  := CZ1->(GetArea())
Local aAreaCYY  := CYY->(GetArea())
Local aAreaCYQ  := CYQ->(GetArea())
Local aAreaCYC  := CYC->(GetArea())
Local nOpc      := oModelCYV:GetOperation()
Local oModel    := oModelCYV:GetModel()
Local oModelCYW := oModel:GetModel('CYWDETAIL')
Local oModelCZP := oModel:GetModel('CZPDETAIL')
Local cNRORPO   := oModelCYV:GetValue('CYV_NRORPO')
Local cIDAT     := oModelCYV:GetValue('CYV_IDAT')
Local cIDATQO   := oModelCYV:GetValue('CYV_IDATQO')
Local dDTRPBG   := oModelCYV:GetValue('CYV_DTRPBG')
Local dDTRPED   := oModelCYV:GetValue('CYV_DTRPED')
Local cHRRPBG   := oModelCYV:GetValue('CYV_HRRPBG')
Local cHRRPED   := oModelCYV:GetValue('CYV_HRRPED')
Local dDTBGSU   := oModelCYV:GetValue('CYV_DTBGSU')
Local dDTEDSU   := oModelCYV:GetValue('CYV_DTEDSU')
Local cHRBGSU   := oModelCYV:GetValue('CYV_HRBGSU')
Local cHREDSU   := oModelCYV:GetValue('CYV_HREDSU')
Local nQTATRP   := oModelCYV:GetValue('CYV_QTATRP')
Local nQTATRT   := oModelCYV:GetValue('CYV_QTATRT')
Local nQTATRF   := oModelCYV:GetValue('CYV_QTATRF')
Local nQTATAP   := oModelCYV:GetValue('CYV_QTATAP')
Local nQTTERP   := oModelCYV:GetValue('CYV_QTTERP')
Local lRet      := .T.
Local lSetup    := .F. // Define se o setup j· foi iniciado ou n„o
Local lOk       := .T.
Local nI   	  := 0
Local nI2       := 0
Local nQtdMOD	  := 0
Local aEquipe   := {}
Local aOperEqui := {}
Local cOperador := ''
Local aErro     := {}
Local oModelCYX, oModelCYQ, oModelCYY, oModelCYYaux
Local lParada   := .F.
Local lFimSplit := .F.
Local lFimOper  := .F.
Local lOrdem    := .F.
Local nOperEqui := 0
Local nQTAT     := 0
Local nQTOR     := 0
Local lPERDINF  := SuperGetMV("MV_PERDINF",.F.,.F.)
Local lSFCQTS   := SuperGetMV("MV_SFCQTS",.F.,.F.)
Local lSFCInt   := SFCIntegra()
Local lMostrou  := .F.
Local cAliasCYY := GetNextAlias()
Local lImporta  := IsInCallStack('SFCA320')
Local lFinaliza := .T.
Local cSFCTPRE  := GetMv("MV_SFCTPRE")
Local aAreaCYV  := {}
Local aAreaCYY1 := {}
Default cMaquina  := ''
Default lAutomacao := .F.

If Type("_lFinaliza") != "U"
	lFinaliza := _lFinaliza
EndIf

If Type("_IsPost314") != "L" 
	_IsPost314 := .F.
EndIf

Begin Transaction

	if cMaquina == ''
		if IsInCallStack('SFCA318ATV')
			cMaquina := oModel:GetModel('MAQMASTER'):GetValue('MAQMASTER','CYV_CDMQ')
		Else
			cMaquina := oModelCYV:GetValue('CYV_CDMQ')
		Endif
	Endif

	Pergunte('SFCA310A',.F.)
	oModelCYV:SetValue("CYV_TPMOD",AllTrim(Str(MV_PAR02)))
	oModelCYV:SetValue("CYV_TPGGF",AllTrim(Str(MV_PAR03)))
	oModelCYV:SetValue("CYV_TPRF" ,AllTrim(Str(MV_PAR04)))

	dbSelectArea('CYB')
	CYB->(dbSetOrder(1))
	CYB->(dbGoTop())
	CYB->(dbSeek(xFilial('CYB')+cMaquina))

	dbSelectArea('CYQ')
	CYQ->(dbSetOrder(1))
	CYQ->(dbGoTop())
	CYQ->(dbSeek(xFilial('CYQ')+cNRORPO))

	dbSelectArea('CYY')
	CYY->(dbSetOrder(1))
	CYY->(dbGoTop())
	CYY->(dbSeek(xFilial('CYY')+cNRORPO+cIDAT+cIDATQO))

	if CYB->CYB_LGSU .AND. CYY->CYY_TPSTAT == '3'
		dbSelectArea('CYX')
		CYX->(dbSetOrder(2))
		IF CYX->(dbSeek(xFilial('CYX')+cMaquina+'99991231'))
			dbSelectArea('CYN')
			CYN->(dbSetOrder(1))
			IF CYN->(dbSeek(xFilial('CYN')+CYX->CYX_CDSP))
				lSetup := .T.
			Endif
		Endif

		oModelCYX := FWLoadModel('SFCA311')
		if !lSetup
			oModelCYX:SetOperation(3)
		Else
			oModelCYX:SetOperation(4)
		Endif
		oModelCYX:Activate()

		oModelCYX:SetValue('CYXMASTER','CYX_CDMQ'  ,CYB->CYB_CDMQ)
		oModelCYX:SetValue('CYXMASTER','CYX_CDSP'  ,oModelCYV:GetValue('CYV_CDSU'))
		oModelCYX:SetValue('CYXMASTER','CYX_DTBGSP',dDTBGSU)
		oModelCYX:SetValue('CYXMASTER','CYX_DTEDSP',dDTEDSU)

		if cSFCTPRE == '2'
			oModelCYX:SetValue('CYXMASTER','CYX_HCBGSP',oModelCYV:GetValue('CYV_HCBGSU'))
			oModelCYX:SetValue('CYXMASTER','CYX_HCEDSP',oModelCYV:GetValue('CYV_HCEDSU'))
		Else
			oModelCYX:SetValue('CYXMASTER','CYX_HRBGSP',cHRBGSU)
			oModelCYX:SetValue('CYXMASTER','CYX_HREDSP',cHREDSU)
		Endif

		//oModelCYX:SetValue('CYXMASTER','CYX_CDFEPO',oModelCYV:GetValue('CYV_CDFEPO'))
		oModelCYX:SetValue('CYXMASTER','CYX_TPSP'  ,'1')
		oModelCYX:SetValue('CYXMASTER','CYX_NRSQRP',oModelCYV:GetValue('CYV_NRSQRP'))

		lParada := .T.
	Endif

	if lRet
		For nI := 1 To oModelCYW:Length()
			oModelCYW:GoLine( nI )

		   	If !oModelCYW:IsDeleted()
		   		if !Empty(oModelCYW:GetValue('CYW_IDOE'))
		   			dbSelectArea('CYH')
					CYH->(dbSetOrder(2))
					CYH->(dbGoTop())
					if CYH->(dbSeek(xFilial('CYH')+CZ1->CZ1_IDRCOE))
						/*integraÁ„o com datasul n„o tem previs„o de sair
						if lSFCInt == 2 .AND. Empty(CYH->CYH_CDMOD)
							oModelCYW:DeleteLine()
						Else*/
							cOperador += oModelCYW:GetValue('CYW_IDOE') + '/'
						//Endif
					Endif
			   	Endif

		   		if !Empty(oModelCYW:GetValue('CYW_IDGROE'))
			   		aadd(aEquipe,{oModelCYW:GetValue('CYW_IDGROE'),;
								  oModelCYW:GetValue('CYW_CDGROE'),;
								  oModelCYW:GetValue('CYW_DTBGRP'),;
								  oModelCYW:GetValue('CYW_HRBGRP'),;
								  oModelCYW:GetValue('CYW_DTEDRP'),;
								  oModelCYW:GetValue('CYW_HREDRP'),;
								  oModelCYW:GetValue('CYW_CDTN'),;
								  oModelCYW:GetValue('CYW_NRTN'),;
								  oModelCYW:GetValue('CYW_QTTEOE')})
			   		oModelCYW:DeleteLine()
			   	Endif
		   	EndIf
		Next

		// Quando informada equipe, deve substituir pelos operadores
		aOperEqui := {}
		For nI := 1 To Len(aEquipe)
			CZ1->(dbSetOrder(1))
			CZ1->(dbGoTop())
			if CZ1->(dbSeek(xFilial('CZ1')+aEquipe[nI][1]))

				nCt := oModelCYW:Length()

				While !CZ1->(EOF()) .AND. CZ1->CZ1_IDRCGR == aEquipe[nI][1]

					If LEN(aOperEqui) > 0
						nOperEqui := aScan(aOperEqui,{|x| x[1] == CZ1->CZ1_CDOE})
						If nOperEqui > 0
							cMsg := STR0130 + ALLTRIM(CZ1->CZ1_CDOE) + STR0131  + ALLTRIM(aOperEqui[nOperEqui][2]) + STR0132 + ALLTRIM(aEquipe[nI][2]) + STR0133
							//'Operador: ' //' cadastrado em mais de uma Equipe: ' // ' e ' //'.'
							SFCMsgErro(cMsg ,'SFCA314') // Os Operadores relacionados a Equipe devem estar cadastrados para a M·quina no SFCA002 - M·quina. 
							lRet := .F. 
							Exit
						EndIf 
					EndIf

					oModelCYW:GoLine(nCt)

					if !(CZ1->CZ1_IDRCOE $ cOperador)
						nCT++

						If nCt > 1

							CYC->( GetArea() )
							
							dbSelectArea('CYC')
							CYC->(dbSetOrder(1))
							If !CYC->(dbSeek(xFilial('CYC')+cMaquina+'1'+CZ1->CZ1_CDOE))
								SFCMsgErro(STR0129 ,'SFCA312') // Os Operadores relacionados a Equipe devem estar cadastrados para a M·quina no SFCA002 - M·quina. 
								lRet := .F. 
								Exit
							EndIf

							RestArea(aAreaCYC)

							lOk := ( oModelCYW:AddLine() == nCT )

							If !lOk
								oModelCYW:SetNoUpdateLine(.T.)
								SFCMsgErro( STR0059,'SFCA312') // 'Erro'
								Exit
							Endif
						Endif

						aadd(aOperEqui,{CZ1->CZ1_CDOE, aEquipe[nI][2]})
								
						oModelCYW:SetValue('CYW_CDOE'  ,Alltrim(CZ1->CZ1_CDOE))
						oModelCYW:SetValue('CYW_CDGROE',aEquipe[nI][2])
						oModelCYW:SetValue('CYW_DTBGRP',aEquipe[nI][3])
						oModelCYW:SetValue('CYW_HRBGRP',aEquipe[nI][4])
						oModelCYW:SetValue('CYW_DTEDRP',aEquipe[nI][5])
						oModelCYW:SetValue('CYW_HREDRP',aEquipe[nI][6])						
						oModelCYW:SetValue('CYW_CDTN'  ,aEquipe[nI][7])
						oModelCYW:SetValue('CYW_NRTN'  ,aEquipe[nI][8])
						oModelCYW:SetValue('CYW_QTTEOE',aEquipe[nI][9])

						If cSFCTPRE == '2'
							oModelCYW:SetValue('CYW_HCBGRP', SFCXHRTOCEN(aEquipe[nI][4]) )
							oModelCYW:SetValue('CYW_HCEDRP', SFCXHRTOCEN(aEquipe[nI][6]) )
						Endif
					Else
						oModelCYW:SetValue('CYW_CDGROE', aEquipe[nI][2])
					Endif

					CZ1->(dbSkip())
				End

				If lOk .and. lRet
					oModelCYW:GoLine(1)
				EndIf
			Endif
		Next
		If lRet 
			For nI := 1 To oModelCYW:Length()
				oModelCYW:GoLine(nI)

				If !oModelCYW:IsDeleted()
					nQtdMOD += oModelCYW:GetValue('CYW_QTTEOE')
				EndIf
			Next

			oModelCYV:LoadValue('CYV_QTTEOE', nQtdMOD)

			For nI := 1 To oModelCZP:Length()
				oModelCZP:GoLine( nI )

				If !oModelCZP:IsDeleted() .AND. oModelCZP:GetValue('CZP_QTRPPO') == 0
					oModelCZP:DeActivate(.T.)
					oModelCZP:Activate()
					oModelCZP:GoLine( nI )
					oModelCZP:DeleteLine()
				EndIf
			Next

			if nOpc == 3
				oModelCYV:LoadValue('CYV_DTRP',dDataBase)
				oModelCYV:LoadValue('CYV_HRRP',TIME())
			Endif

			oModelCYY := FWLoadModel( 'SFCA315' )
			oModelCYY:SetOperation( 4 )
			oModelCYY:Activate()

			if oModelCYY:GetValue('CYYMASTER','CYY_TPSTAT') == '3'
				IF lParada
					oModelCYY:SetValue('CYYMASTER','CYY_DTBGSU',dDTBGSU)
					oModelCYY:SetValue('CYYMASTER','CYY_HRBGSU',cHRBGSU)
					oModelCYY:SetValue('CYYMASTER','CYY_DTEDSU',dDTEDSU)
					oModelCYY:SetValue('CYYMASTER','CYY_HREDSU',cHREDSU)

					IF dDTBGSU == dDTEDSU
						oModelCYY:SetValue('CYYMASTER','CYY_QTTESU',SFCXHourToSeg(ELAPTIME(cHRBGSU,cHREDSU)))
					Endif
				Endif
			Endif

			if Empty(oModelCYY:GetValue('CYYMASTER','CYY_DTBGAT')) .OR.;
			(dDTRPBG < oModelCYY:GetValue('CYYMASTER','CYY_DTBGAT') .OR.;
			(dDTRPBG == oModelCYY:GetValue('CYYMASTER','CYY_DTBGAT') .AND.;
			cHRRPBG < oModelCYY:GetValue('CYYMASTER','CYY_HRBGAT')))
				oModelCYY:SetValue('CYYMASTER','CYY_DTBGAT',dDTRPBG)
				oModelCYY:SetValue('CYYMASTER','CYY_HRBGAT',cHRRPBG)
			Endif

			oModelCYY:SetValue('CYYMASTER','CYY_QTATAP',oModelCYY:GetValue('CYYMASTER','CYY_QTATAP') + nQTATAP)
			oModelCYY:SetValue('CYYMASTER','CYY_QTATRT',oModelCYY:GetValue('CYYMASTER','CYY_QTATRT') + nQTATRT)
			oModelCYY:SetValue('CYYMASTER','CYY_QTATRF',oModelCYY:GetValue('CYYMASTER','CYY_QTATRF') + nQTATRF)
			oModelCYY:SetValue('CYYMASTER','CYY_QTATRP',oModelCYY:GetValue('CYYMASTER','CYY_QTATRP') + nQTATRP)
			oModelCYY:SetValue('CYYMASTER','CYY_DTEDAT',dDTRPED)
			oModelCYY:SetValue('CYYMASTER','CYY_HREDAT',cHRRPED)
			oModelCYY:SetValue('CYYMASTER','CYY_DTDI'  ,dDTRPED)
			oModelCYY:SetValue('CYYMASTER','CYY_HRDI'  ,cHRRPED)
			oModelCYY:SetValue('CYYMASTER','CYY_QTTEAT',oModelCYY:GetValue('CYYMASTER','CYY_QTTEAT') + nQTTERP)
			oModelCYY:SetValue('CYYMASTER','CYY_QTTEOE',oModelCYY:GetValue('CYYMASTER','CYY_QTTEOE') + nQTTERP)
			oModelCYY:SetValue('CYYMASTER','CYY_QTTEMQ',oModelCYY:GetValue('CYYMASTER','CYY_QTTEMQ') + nQTTERP)
			oModelCYY:SetValue('CYYMASTER','CYY_TPSTAT','4')

			oModelCYQ := FWLoadModel( 'SFCA100' )
			oModelCYQ:SetOperation( 4 )
			oModelCYQ:Activate()

			For nI := 1 To oModelCYQ:GetModel('CY9DETAIL'):Length()
				oModelCYQ:GetModel('CY9DETAIL'):GoLine(nI)

				if oModelCYQ:GetValue('CY9DETAIL','CY9_NRORPO') == cNRORPO .AND.;
				oModelCYQ:GetValue('CY9DETAIL','CY9_IDAT')   == cIDAT

					oModelCYQ:SetValue('CY9DETAIL','CY9_QTPO',nQTATRP + oModelCYQ:GetValue('CY9DETAIL','CY9_QTPO'))
					oModelCYQ:SetValue('CY9DETAIL','CY9_QTRF',nQTATRF + oModelCYQ:GetValue('CY9DETAIL','CY9_QTRF'))
					oModelCYQ:SetValue('CY9DETAIL','CY9_QTRP',nQTATRP + oModelCYQ:GetValue('CY9DETAIL','CY9_QTRP'))
					oModelCYQ:SetValue('CY9DETAIL','CY9_QTRT',nQTATRT + oModelCYQ:GetValue('CY9DETAIL','CY9_QTRT'))
					oModelCYQ:SetValue('CY9DETAIL','CY9_QTAP',nQTATAP + oModelCYQ:GetValue('CY9DETAIL','CY9_QTAP'))

					IF Empty(oModelCYQ:GetValue('CY9DETAIL','CY9_DTBGRY'))
						oModelCYQ:SetValue('CY9DETAIL','CY9_DTBGRY',dDTRPBG)
						oModelCYQ:SetValue('CY9DETAIL','CY9_HRBGRY',cHRRPBG)
						oModelCYQ:SetValue('CY9DETAIL','CY9_DTEDRY',dDTRPED)
						oModelCYQ:SetValue('CY9DETAIL','CY9_HREDRY',cHRRPED)
					Else
						if oModelCYQ:GetValue('CY9DETAIL','CY9_DTBGRY') > dDTRPBG .OR.;
						(oModelCYQ:GetValue('CY9DETAIL','CY9_DTBGRY') == dDTRPBG .AND.;
						oModelCYQ:GetValue('CY9DETAIL','CY9_HRBGRY') > cHRRPBG)
							oModelCYQ:SetValue('CY9DETAIL','CY9_DTBGRY',dDTRPBG)
							oModelCYQ:SetValue('CY9DETAIL','CY9_HRBGRY',cHRRPBG)
						Endif

						if oModelCYQ:GetValue('CY9DETAIL','CY9_DTEDRY') < dDTRPED .OR.;
						(oModelCYQ:GetValue('CY9DETAIL','CY9_DTEDRY') == dDTRPED .AND.;
						oModelCYQ:GetValue('CY9DETAIL','CY9_HREDRY') < cHRRPED)
							oModelCYQ:SetValue('CY9DETAIL','CY9_DTEDRY',dDTRPED)
							oModelCYQ:SetValue('CY9DETAIL','CY9_HREDRY',cHRRPED)
						Endif
					Endif

					oModelCYQ:SetValue('CY9DETAIL','CY9_TPST','2')

					If oModelCYQ:GetValue('CYQMASTER','CYQ_TPRPOR') == '2'
						oModelCYQ:SetValue('CYQMASTER','CYQ_TPST','3')
						oModelCYQ:SetValue('CYQMASTER','CYQ_TPSTOR','6')
					EndIf

					nQTAT := oModelCYQ:GetValue('CY9DETAIL','CY9_QTAT')

					// Se a operaÁ„o que est· sendo reportada for a ˙ltima, atualizar as quantidades da ordem de produÁ„o
					if oModelCYQ:GetValue('CY9DETAIL','CY9_LGATED')
						nQTOR := oModelCYQ:GetValue('CYQMASTER','CYQ_QTOR')

						oModelCYQ:SetValue('CYQMASTER','CYQ_QTORAP',oModelCYQ:GetValue('CY9DETAIL','CY9_QTAP') / nQTAT * nQTOR)
						oModelCYQ:SetValue('CYQMASTER','CYQ_QTORRF',oModelCYQ:GetValue('CY9DETAIL','CY9_QTRF') / nQTAT * nQTOR)
						oModelCYQ:SetValue('CYQMASTER','CYQ_QTORRP',oModelCYQ:GetValue('CY9DETAIL','CY9_QTRP') / nQTAT * nQTOR)
						oModelCYQ:SetValue('CYQMASTER','CYQ_QTORRT',oModelCYQ:GetValue('CY9DETAIL','CY9_QTRT') / nQTAT * nQTOR)
					Endif

					Exit
				Endif
			Next

			For nI := 1 To oModelCZP:Length()
				oModelCZP:GoLine(nI)

				if !oModelCZP:IsDeleted() .AND. !Empty(oModelCZP:GetValue('CZP_IDMTOR'))

					For nI2 := 1 To oModelCYQ:GetModel('CYPDETAIL'):Length()
						oModelCYQ:GetModel('CYPDETAIL'):GoLine( nI2 )

						if oModelCYQ:GetValue('CYPDETAIL','CYP_NRORPO') == cNRORPO .AND.;
						oModelCYQ:GetValue('CYPDETAIL','CYP_IDMTOR') == oModelCZP:GetValue('CZP_IDMTOR')

							oModelCYQ:SetValue('CYPDETAIL','CYP_QTRP', oModelCZP:GetValue('CZP_QTRPPO') + oModelCYQ:GetValue('CYPDETAIL','CYP_QTRP'))
							Exit
						Endif
					Next
				EndIf
			Next

			// Para encerrar os splits e a operaÁ„o, dever· realizar as validaÁıes abaixo
			if lSFCQTS // Saldo do Split
				if lPERDINF
					if oModelCYY:GetValue('CYYMASTER','CYY_QTATAP') >= oModelCYY:GetValue('CYYMASTER','CYY_QTAT')
						// Quando quantidade aprovada for maior ou igual a prevista do split, encerra apenas o split em quest„o
						lFimSplit := .T.
					Endif

					if oModelCYQ:GetValue('CY9DETAIL','CY9_QTAP') >= nQTAT
						lFimOper := .T.
					Endif
				ElseIf !lPERDINF
					if oModelCYY:GetValue('CYYMASTER','CYY_QTATRP') >= oModelCYY:GetValue('CYYMASTER','CYY_QTAT')
						// Quando quantidade reportada for maior ou igual a prevista do split, encerra apenas o split em quest„o
						lFimSplit := .T.
					Endif

					if oModelCYQ:GetValue('CY9DETAIL','CY9_QTRP') >= nQTAT
						lFimOper := .T.
					Endif
				Endif

				// Atualiza percentual de avanÁo no split
				oModelCYY:SetValue('CYYMASTER','CYY_VLPNRY', oModelCYV:GetValue('CYV_VLPNRY'))

			Else // Saldo da operaÁ„o
				if (lPERDINF .AND. oModelCYQ:GetValue('CY9DETAIL','CY9_QTAP') >= nQTAT) .OR.; // Quando a quantidade aprovada for maior ou igual a prevista da operaÁ„o, encerra os splits e a operaÁ„o
				(!lPERDINF .AND. oModelCYQ:GetValue('CY9DETAIL','CY9_QTRP') >= nQTAT) // Quando a quantidade reportada for maior ou igual a prevista operaÁ„o, encerra os splits e a operaÁ„o
					lFimOper  := .T.
				Endif

				// Atualiza percentual de avanÁo na operaÁ„o
				oModelCYQ:SetValue('CY9DETAIL','CY9_VLPNRY',oModelCYV:GetValue('CYV_VLPNRY'))
			Endif
		EndIf

		If lRet

			// Verifica se deve finaliza o split
			if lFimSplit .AND. !lFimOper
				IF lImporta
					if SuperGetMV("MV_SFCEDRP",.F.,.F.) == .T.
						lFinaliza := .T.
					Else
						lFinaliza := .F.
					Endif
				Else
					If IsInCallStack("SFCA311DAP") .And. Type("lSpltEnc") != "U"
						If lSpltEnc
							lFinaliza := .T.
						Else
							lFinaliza := .F.
						EndIf
					ElseIf !IsInCallStack('GERAAPOORD')
						If IsInCallStack('MATI681')
							lFinaliza := oModelCYV:GetValue("CYV_LGEDRP")
						Else
							if SuperGetMV("MV_SFCEDRP",.F.,.F.) == .T. .Or. !Empty(oModelCYV:GetValue("GER_PARADA")) .Or. ; // Finaliza automaticamente ou pergunta
								(!_IsPost314 .And. ;
								MsgNoYes(STR0087 + NEWLINE +;                     // 'Deseja finalizar o split? '
										 STR0017 + ALLTRIM(cNRORPO) + NEWLINE +;  // ' Ordem: '
										 STR0018 + ALLTRIM(cIDAT) + NEWLINE +;    // ' OperaÁ„o: '
										 STR0041 + ALLTRIM(cIDATQO)))             // ' Split: '
								lFinaliza := .T.
							Else
								lFinaliza := .F.
							Endif
						EndIf
					Endif
				Endif
			Endif

			// Verifica se deve finalizar a operaÁ„o
			if lFimOper
				IF lImporta
					if SuperGetMV("MV_SFCEDRP",.F.,.F.) == .T.
						lFinaliza := .T.
					Else
						lFinaliza := .F.
					Endif
				Else
					If IsInCallStack("SFCA311DAP") .And. Type("lSpltEnc") != "U"
						If lSpltEnc
							lFinaliza := .T.
						Else
							lFinaliza := .F.
						EndIf
					ElseIf !IsInCallStack('GERAAPOORD')
						If IsInCallStack("MATI681")
							lFinaliza := oModelCYV:GetValue("CYV_LGEDRP")
						Else
							If !lAutomacao
								if SuperGetMV("MV_SFCEDRP",.F.,.F.) == .T. .Or. !Empty(oModelCYV:GetValue("GER_PARADA")) .Or. ; // Finaliza automaticamente ou pergunta
									(!_IsPost314 .And. ;
									MsgNoYes(STR0060 + NEWLINE +;                    // 'Deseja finalizar o operaÁ„o? '
											 STR0017 + ALLTRIM(cNRORPO) + NEWLINE +;  // ' Ordem: '
											 STR0018 + ALLTRIM(cIDAT) + NEWLINE +;    // ' OperaÁ„o: '
											 STR0041 + ALLTRIM(cIDATQO)))             // ' Split: '
									lFinaliza := .T.
								Else
									lFinaliza := .F.
								Endif
							EndIf
						EndIf
					Endif
				Endif
			Endif

			//Primeira verificar apontamentos anteriores
			If lRet
				lRet := ValAponAnt(oModelCYV,lFinaliza)
			EndIf

			//Depois aplica as alteraÁıes
			if lFimSplit .AND. !lFimOper .AND. lFinaliza
				oModelCYY:SetValue('CYYMASTER','CYY_LGQOED',.T.)
				oModelCYY:SetValue('CYYMASTER','CYY_TPSTAT','5')
			Endif

			if lFimOper .AND. lFinaliza

				oModelCYY:SetValue('CYYMASTER','CYY_LGQOED',.T.)
				oModelCYY:SetValue('CYYMASTER','CYY_TPSTAT','5')
				oModelCYQ:SetValue('CY9DETAIL','CY9_TPST','3')
				oModelCYV:SetValue('CYV_LGEDRP',.T.)

				Pergunte('MTA680',.F.)

				if MV_PAR07 != 3 // N„o valida rede-pert e entao a finalizaÁ„o da ordem deve ser feita via SFCA100

					if oModelCYQ:GetValue('CY9DETAIL','CY9_LGATED')
						if SuperGetMV("MV_SFCEDRP",.F.,.F.) == .T. .Or. !Empty(oModelCYV:GetValue("GER_PARADA")) .OR.;
							(IsInCallStack("MATI681") .And. oModelCYV:GetValue("CYV_LGEDRP")) .Or. ;
							(!_IsPost314 .And. ;
							MsgNoYes( STR0061 + ALLTRIM(cNRORPO) + NEWLINE +;   													// 'Deseja finalizar a ordem de produÁ„o '
										 STR0062 + ALLTRIM(STR(oModelCYQ:GetValue('CY9DETAIL','CY9_QTAP'))) + NEWLINE +;   // '? Aprovadas: '
										 STR0063 + ALLTRIM(STR(oModelCYQ:GetValue('CY9DETAIL','CY9_QTRF'))) + NEWLINE +;   // ' Refugadas: '
										 STR0064 + ALLTRIM(STR(oModelCYQ:GetValue('CY9DETAIL','CY9_QTRT'))) + NEWLINE +;   // ' Retrabalhadas: '
										 STR0065 + ALLTRIM(STR(oModelCYQ:GetValue('CY9DETAIL','CY9_QTAT')))))     // ' Previstas: '

							lOrdem := .T.
							oModelCYQ:SetValue('CYQMASTER', 'CYQ_TPST', '5')
							oModelCYQ:SetValue('CYQMASTER', 'CYQ_TPSTOR', '7')

							For nI := 1 To oModelCYQ:GetModel('CY9DETAIL'):Length()
								oModelCYQ:GetModel('CY9DETAIL'):GoLine(nI)

								if oModelCYQ:GetValue('CY9DETAIL','CY9_NRORPO') == cNRORPO
									oModelCYQ:SetValue('CY9DETAIL','CY9_TPST','3')
								Endif
							Next
						Endif
					Endif
				Endif
			Endif

			IF Empty(oModelCYY:GetValue('CYYMASTER','CYY_CDMQ'))
				oModelCYY:SetValue('CYYMASTER','CYY_CDMQ', cMaquina)
			Endif

			RestArea(aAreaCZ1)
			RestArea(aAreaCYY)
			RestArea(aAreaCYB)
			RestArea(aAreaCYQ)
			RestArea(aArea)

			nQtdHrPrep := 0
			If lParada
				nQtdHrPrep := oModelCYX:GetValue("CYXMASTER","CYX_HRTEUT") + oModelCYX:GetValue("CYXMASTER","CYX_HRTEEX")
			EndIf

			if lRet .AND. lSFCInt == 1
				lRet := AUTO681(oModel, lOrdem, nQtdHrPrep, lParada )
			Endif

			// Salvar registros nas tabelas
			if lRet

				// Se houver parada, valida parada
				if lParada
					if !oModelCYX:VldData()
						aErro := oModelCYX:GetErrorMessage()
						SFCMsgErro(aErro[6], "SFCA314")
				  		lRet := .F.
					Endif
				Endif

				// Valida Ordem
				if !oModelCYQ:VldData()
					aErro := oModelCYQ:GetErrorMessage()
					SFCMsgErro(aErro[6], "SFCA314")
					lRet := .F.
				Endif

				// Valida Split
				if !oModelCYY:VldData()
					aErro := oModelCYY:GetErrorMessage()
					SFCMsgErro(aErro[6], "SFCA314")
					lRet := .F.
				Endif

				if lRet
					// Salva parada
					if lParada
						oModelCYX:CommitData()
						oModelCYX:DeActivate()
					Endif

					// Salva Ordem
					oModelCYQ:CommitData()
					oModelCYQ:DeActivate()

					// Salva Split
					oModelCYY:CommitData()
					oModelCYY:DeActivate()

					// Se vai finalizar a operaÁ„o, todos os Splits dever„o ser finalizados
					IF lFimOper .And. lFinaliza

						BeginSql Alias cAliasCYY

							SELECT * FROM %Table:CYY% CYY
								WHERE CYY.CYY_FILIAL=%xFilial:CYY% AND
									  CYY.CYY_NRORPO=%Exp:cNRORPO% AND
									  CYY.CYY_IDAT  =%Exp:cIDAT% AND
									  CYY.%NotDel%
						EndSql

						aAreaCYV  := CYV->(GetArea())
						aAreaCYY1 := CYY->(GetArea())

						While (cAliasCYY)->(!EOF())

							if (cAliasCYY)->CYY_IDATQO != oModelCYV:GetValue('CYV_IDATQO') .AND. (cAliasCYY)->CYY_LGQOED == 'F'
								DbSelectArea("CYV")
								CYV->(DbSetOrder(2))
								CYV->(DbSeek(xFilial("CYV")+cNRORPO+cIDAT+(cAliasCYY)->CYY_IDATQO))

								DbSelectArea("CYY")
								CYY->(DbSetOrder(1))
								CYY->(DbSeek(xFilial("CYY")+cNRORPO+cIDAT+(cAliasCYY)->CYY_IDATQO))
								
								oModelCYYaux := FWLoadModel( 'SFCA315' )
								oModelCYYaux:SetOperation( 4 )
								oModelCYYaux:Activate()

								oModelCYYaux:SetValue('CYYMASTER', 'CYY_TPSTAT', '5')
								oModelCYYaux:SetValue('CYYMASTER', 'CYY_LGQOED', .T.)
						
								if oModelCYYaux:VldData()
									oModelCYYaux:CommitData()
								Else
									aErro := oModelCYYaux:GetErrorMessage()
									SFCMsgErro(aErro[6], "SFCA314")
									lRet := .F.
								Endif
								oModelCYYaux:DeActivate()
							Endif

							(cAliasCYY)->(dbSkip())
						End
						
						CYV->(RestArea(aAreaCYV))
						CYY->(RestArea(aAreaCYY1))

						(cAliasCYY)->(dbCloseArea())
					Endif
				Endif
			Endif
		Endif
	Endif

	if !lRet
		DisarmTransaction()
	Endif

End Transaction

FwModelActive( oModel, .T. )

If !lRet .And. !oModel:HasErrorMessage()
	//Se lRet È falso e n„o tem nenhuma mensagem de erro no modelo, adiciona mensagem padr„o para que n„o seja exibido nenhum help em branco na tela.
	oModel:SetErrorMessage("SFCA314", Nil, Nil, Nil, "ERROAPON", STR0125, "", "", "") //"Apontamento de produÁ„o n„o realizado."
EndIf

Return lRet

//-------------------------------------------------------------------
// Legenda
//-------------------------------------------------------------------
Function SFCA314LEG()

// Cria a legenda que identifica a estrutura
oLegend := FWLegend():New()

// Adiciona descriÁ„o para cada legenda
oLegend:Add( { || }, "GREEN" , STR0104 ) // "Reportado"
oLegend:Add( { || }, "YELLOW", STR0105 ) // "Iniciado
oLegend:Add( { || }, "RED"   , STR0106 ) // "Estornado"

// Ativa a Legenda
oLegend:Activate()

// Exibe a Tela de Legendas
oLegend:View()

SFCA310F12()

Return Nil

//-------------------------------------------------------------------
// Calcular o percentual de avanÁo
//-------------------------------------------------------------------
Static Function SFCA314AVA(cNRORPO, cIDAT, cIDATQO, nQtdReport, nQtdAprov)
Local lAprov   := SuperGetMV('MV_PERDINF',.F.,.T.) // Considera como saldo a quantidade aprovada?
Local lSplit   := SuperGetMV('MV_SFCQTS',.F.,.T.)  // Considera quantidade do split
Local nAvanco  := 0

if lSplit
	dbSelectArea('CYY')
	CYY->(dbSetOrder(1))
	CYY->(dbSeek(xFilial('CYY')+cNRORPO+cIDAT+cIDATQO))

	IF lAprov
		nAvanco := NOROUND((nQtdAprov + CYY->CYY_QTATAP) / CYY->CYY_QTAT * 100)
	Else
		nAvanco := NOROUND((nQtdReport + CYY->CYY_QTATRP) / CYY->CYY_QTAT * 100)
	Endif
Else
	dbSelectArea('CY9')
	CY9->(dbSetOrder(1))
	CY9->(dbSeek(xFilial('CY9')+cNRORPO+cIDAT))

	if lAprov
		nAvanco := NOROUND((nQtdAprov + CY9->CY9_QTAP) / CY9->CY9_QTAT * 100)
	Else
		nAvanco := NOROUND((nQtdReport + CY9->CY9_QTRP) / CY9->CY9_QTAT * 100)
	Endif
Endif

if nAvanco > 100
	nAvanco := 100
Endif

Return nAvanco

//-------------------------------------------------------------------
/*CustoPrep - Calcula o custo da preparaÁ„o*/
//-------------------------------------------------------------------
Static Function CustoPrep(cOP,cCod,nQtdHrPrep,dEmissao)
	Local lRet	:= .T.
	Local aCab	:= {;
		{"D3_DOC"    , Substr(cOP,1,6), NIL},;
		{"D3_TM"     , GetMV("MV_SFRQMB"), NIL},;
		{"D3_EMISSAO", dEmissao, Nil};
	}
	Local aItens := {;
		{;
			{"D3_COD"  , cCod  , nil},;
			{"D3_QUANT", nQtdHrPrep, nil},;
			{"D3_LOCAL", RetFldProd(cCod,"B1_LOCPAD")  , nil},;
			{"D3_OP"   , cOP, nil};
		};
	}
	Default lAutomacao := .F.

	If VerUlFchto()
		MsExecAuto({|x,y|MATA241(x,y)},aCab,aItens)

		If !lAutomacao
			If lMSErroAuto
				If _IsPost314
					cLogErro := ErroPost()
					//Seta a mensagem de erro no modelo, para recuperar posteriormente na api.
					oModelCYV:SetErrorMessage('CYVMASTER',,,,, cLogErro )
				Else
					If !IsTelNet()
						MostraErro()
					Else
						ErroTelnet()
					EndIf
				EndIf
				lRet := .F.
			EndIf
		EndIf
	Else
		lRet := .F.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AUTO681
Rotina para IntegraÁ„o com o Protheus - MATA681

@param   oModel      Modelo de Dados

@author Bruno Candido Volpato da Cunha
@since 01/03/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AUTO681(oModelCYV, lOrdem, nQtdHrPrep, lParada)
Local aArea     := GetArea()
Local aAreaCY9  := CY9->(GetArea())
Local aAreaCYB  := CYB->(GetArea())
Local aAreaCYQ  := CYQ->(GetArea())
Local aCab      := {}
Local aItens    := {} //array que vai receber todos os itens requisitados
Local aMata681  := {}
Local aRefugos  := {}
Local cCod      := ''
Local cHora     := ''
Local cLogErro  := ""
Local cMaquina  := ''
Local cParData  := GetMV("MV_DTAPT")
Local cReqAut   := GetMV("MV_REQAUT")
Local cSFRQMB   := GetMV("MV_SFRQMB")
Local cTipoHr   := ''
Local cTpMovto  := ""
Local dtApt
Local lBaixa    := .F.
Local lCoProduto:= .F.
Local lGeraACA  := .F.
Local lPPIAtivo := Type("lRunPPI") == "L" .And. lRunPPI
Local lRet      := .T.
Local lUsaSerie := .F.
Local nI        := 0
Local oModelCY0 := oModelCYV:GetModel('CY0DETAIL')
Local oModelCZP := oModelCYV:GetModel('CZPDETAIL')
Local oModelCZW := oModelCYV:GetModel('CZWDETAIL')

Default lAutomacao := .F.

//Private lMsHelpAuto    := .F. // Grava help no log
Private lMSErroAuto    := .F.
//Private lAutoErrNoFile := .F. //Habilita a gravacao de erro da rotina automatica

If Type("_IsPost314") != "L" 
	_IsPost314 := .F.
EndIf


If IsTelNet() 
	lAutoErrNoFile := .T.
	lMsHelpAuto    := .T.
EndIf

Do Case
	Case cParData == 1
		dtApt := Date()
	Case cParData == 2
		dtApt := dDataBase
	Case cParData == 3
		dtApt := oModelCYV:GetValue('CYVMASTER','CYV_DTRPBG')
	Case cParData == 4
		dtApt := oModelCYV:GetValue('CYVMASTER','CYV_DTRPED')
	OtherWise
		dtApt := dDataBase
EndCase

Pergunte("MTA680",.F.)
nTipoHr := MV_PAR03 //-- 1-Normal ; 2-Centesimal

IF !IsInCallStack('SFCA318ATV')
	If !lAutomacao
		cMaquina := oModelCYV:GetValue('CYVMASTER','CYV_CDMQ')
	EndIf

	IF nTipoHr != 1 .AND. nTipoHr != 2
		SFCMsgErro(STR0048, "SFCA314") //"Hora centesimal est· com valor inv·lido"
		lRet := .F.
	Endif

	if Empty(cSFRQMB)
		SFCMsgErro(STR0070, "SFCA314") //"Tipo de Movimento para RequisiÁ„o e M„o-de-Obra deve ser preenchido (MV_SFRQMB)"
		lRet := .F.
	Endif
Else
	If !lAutomacao
		cMaquina := oModelCYV:GetValue('MAQMASTER','CYV_CDMQ')
	EndIf
Endif

dbSelectArea('CYB')
CYB->(dbSetOrder(1))
CYB->(dbGoTop())
CYB->(dbSeek(xFilial('CYB')+cMaquina))
cCod := PadR(APrModRec(cMaquina),TamSX3("B1_COD")[1])

If IsInCallStack("MATI681")
   SOE->(dbSeek(xFilial("SOE")+"SC2"))
   If AllTrim(SOE->OE_VAR1) == "2" .OR. AllTrim(SOE->OE_VAR1) == "3"
      lBaixa := .T.
   EndIf
EndIf
if lRet

	// Realiza as requisiÁıes
	if cReqAut == 'D' .Or. lBaixa
		For nI := 1 To oModelCZP:Length()
			oModelCZP:GoLine(nI)

			If !oModelCZP:IsDeleted() .AND. Empty(oModelCZP:GetValue('CZP_IDMTOR'))
				If Empty(oModelCZP:GetValue('CZP_NRORPO'))
					oModelCZP:SetValue('CZP_NRORPO', oModelCYV:GetValue('CYVMASTER','CYV_NRORPO') )
				EndIf

				If Empty(oModelCZP:GetValue('CZP_CDACPI'))
					oModelCZP:SetValue('CZP_CDACPI', oModelCYV:GetValue('CYVMASTER','CYV_CDACRP') )
				EndIf
			EndIf
		Next

		For nI := 1 To oModelCZP:Length()
			oModelCZP:GoLine( nI )

			if !oModelCZP:IsDeleted() .AND. oModelCZP:IsUpdated()

				//Verifica se È apropriaÁ„o indireta e se o SF5->F5_APROPR est· como S
				//Se sim, n„o dever· passar para o execauto, pois o PCP j· est· movimentando
				//Ao movimentar a produÁ„o.
				dbSelectArea("SB1")
				dbSetorder(1)
				dbSeek(xFilial('SB1')+oModelCZP:GetValue('CZP_CDMT'))
	 			If (cReqAut == "D" .And. !(SB1->B1_APROPRI == 'I')) .Or. (cReqAut != "D" .And. IsInCallStack("MATI681"))
					If oModelCZP:GetValue('CZP_QTRPPO') < 0
						lCoProduto := .T.
						Loop
					EndIf
					If Empty(aCab)
						aCab := {{"D3_DOC"    , Substr(oModelCYV:GetValue('CYVMASTER','CYV_NRORPO'),1,6), NIL},;
								 {"D3_TM"     , cSFRQMB, NIL},;
							     {"D3_EMISSAO", dtApt, Nil}}
					Endif

					aAdd(aItens,{{"D3_COD"  , oModelCZP:GetValue('CZP_CDMT')  , nil},;
					             {"D3_QUANT", oModelCZP:GetValue('CZP_QTRPPO'), nil},;
					             {"D3_LOCAL", oModelCZP:GetValue('CZP_CDDP')  , nil},;
										{"D3_OP"   , oModelCYV:GetValue('CYVMASTER','CYV_NRORPO'), nil}})
					If lPPIAtivo
						aAdd(aItens[Len(aItens)],{"D3_OBSERVA","TOTVSMES",Nil})
					EndIf
					If /*IsInCallStack("MATI681") .And.*/ Localiza(oModelCZP:GetValue('CZP_CDMT'))
						DbSelectArea("SBF")
						SBF->(DbSetOrder(4))//BF_FILIAL+BF_PRODUTO+BF_NUMSERI                                                                                                                                 
						SBF->(DbSeek(xFilial('SBF')+oModelCZP:GetValue('CZP_CDMT')))
						//EndereÁo + Serie
						While  SBF->(!EOF()) .AND. SBF->BF_PRODUTO == oModelCZP:GetValue('CZP_CDMT') 
							If SBF->BF_QUANT > 0 .AND. Alltrim(SBF->BF_NUMSERI) <> ''
								aAdd(aItens[Len(aItens)],{"D3_NUMSERI",oModelCZP:GetValue('CZP_CDLO'),Nil})
								aAdd(aItens[Len(aItens)],{"D3_LOCALIZ",oModelCZP:GetValue('CZP_CDLC'),Nil})
								lUsaSerie := .T.
								Exit							
							EndIf
							SBF->(dbSkip())
						End
						//EndereÁo + Lote
						If !lUsaSerie .AND. Rastro(oModelCZP:GetValue('CZP_CDMT'))
							aAdd(aItens[Len(aItens)],{"D3_LOTECTL",oModelCZP:GetValue('CZP_CDLO'),Nil})
							aAdd(aItens[Len(aItens)],{"D3_LOCALIZ",oModelCZP:GetValue('CZP_CDLC'),Nil})
						//EndereÁo
						ElseIf !lUsaSerie 
							aAdd(aItens[Len(aItens)],{"D3_LOCALIZ",oModelCZP:GetValue('CZP_CDLC'),Nil})
						EndIf
					Else
						aAdd(aItens[Len(aItens)],{"D3_LOTECTL",oModelCZP:GetValue('CZP_CDLO'),Nil})
					EndIf
				EndIf
			Endif
		Next

		if !Empty(aItens)
			If VerUlFchto()
				MSEXECAUTO({|x,y|MATA241(x,y)},aCab,aItens)

				If lMSErroAuto
					If _IsPost314
						cLogErro := ErroPost()
						//Seta a mensagem de erro no modelo, para recuperar posteriormente na api.
						oModelCYV:SetErrorMessage('CYVMASTER',,,,, cLogErro )
					Else
						If !IsTelNet()
							MostraErro()
						Else
							ErroTelnet()
						EndIf
					EndIf
					lRet := .F.
				EndIf
			Else
				lRet := .F.
			EndIf
		Endif
		//Faz entrada do Co-Produto (Componente com quantidade negativa)
		If lRet .And. lCoProduto .And. lPPIAtivo
			aCab := {}
			aItens := {}
			cTpMovto := ""
			dbSelectArea("SOE")
			If SOE->(dbSeek(xFilial("SOE")+"SF5"))
				cTpMovto := SOE->OE_VAR3
			EndIf
			For nI := 1 To oModelCZP:Length()
				oModelCZP:GoLine( nI )
				If !oModelCZP:IsDeleted() .And. oModelCZP:IsUpdated() .And. oModelCZP:GetValue('CZP_QTRPPO') < 0
					IF Empty(aCab)
						aCab := {{"D3_DOC"    , Substr(oModelCYV:GetValue('CYVMASTER','CYV_NRORPO'),1,6), NIL},;
								 {"D3_TM"     , cTpMovto, NIL},;
								 {"D3_EMISSAO", dtApt, Nil}}
					Endif
					aAdd(aItens,{{"D3_COD"  , oModelCZP:GetValue('CZP_CDMT')  , nil},;
										{"D3_QUANT", oModelCZP:GetValue('CZP_QTRPPO') * (-1), nil},;
										{"D3_LOCAL", oModelCZP:GetValue('CZP_CDDP')  , nil},;
										{"D3_OP"   , oModelCYV:GetValue('CYVMASTER','CYV_NRORPO'), nil}})
					aAdd(aItens[Len(aItens)],{"D3_OBSERVA","TOTVSMES",Nil})
					If /*IsInCallStack("MATI681") .And.*/ Localiza(oModelCZP:GetValue('CZP_CDMT'))
						aAdd(aItens[Len(aItens)],{"D3_NUMSERI",oModelCZP:GetValue('CZP_CDLO'),Nil})
						aAdd(aItens[Len(aItens)],{"D3_LOCALIZ",oModelCZP:GetValue('CZP_CDLC'),Nil})
					Else
						aAdd(aItens[Len(aItens)],{"D3_LOTECTL",oModelCZP:GetValue('CZP_CDLO'),Nil})
					EndIf
				EndIf
			Next nI
			if Len(aItens) > 0
				If VerUlFchto()
					MSEXECAUTO({|x,y|MATA241(x,y)},aCab,aItens)
					If lMSErroAuto
						If _IsPost314
							cLogErro := ErroPost()
							//Seta a mensagem de erro no modelo, para recuperar posteriormente na api.
							oModelCYV:SetErrorMessage('CYVMASTER',,,,, cLogErro )
						Else
							If !IsTelNet()
								MostraErro()
							Else
								ErroTelnet()
							EndIf
						EndIf
						lRet := .F.
					EndIf
				Else
					lRet := .F.
				EndIf
			EndIf
		Endif
	Endif

	//preparaÁ„o
	if lRet .And. CYB->CYB_LGSU .And. lParada
		lRet := CustoPrep(oModelCYV:GetValue('CYVMASTER','CYV_NRORPO'),cCod,nQtdHrPrep,dtApt)
	EndIf

	aCab   := {}
	aItens := {}

	// mao de obra
	dbSelectArea('CYQ')
	CYQ->(dbSetOrder(1))
	CYQ->(dbGoTop())
	if lRet .And. CYQ->(dbSeek(xFilial('CYQ')+oModelCYV:GetValue('CYVMASTER','CYV_NRORPO'))) .AND. CYQ->CYQ_TPGGF == '1'
		For nI := 1 To oModelCZW:Length()
			oModelCZW:GoLine( nI )

			if !oModelCZW:IsDeleted() .AND. oModelCZW:IsUpdated() .AND. oModelCZW:GetValue('CZW_CDCETR') == CYB->CYB_CDCETR

				if Empty(aCab)
					aCab := {{"D3_DOC"    , Substr(oModelCYV:GetValue('CYVMASTER','CYV_NRORPO'),1,6), NIL},;
					         {"D3_TM"     , cSFRQMB, NIL},;
			        		 {"D3_EMISSAO", dtApt, Nil}}
				Endif

				aAdd(aItens,{{"D3_COD"  , cCod								, nil},;
		    		         {"D3_QUANT", oModelCZW:GetValue('CZW_HRTEGF')	, nil},;
		            		 {"D3_LOCAL", RetFldProd(cCod,"B1_LOCPAD")		, nil},;
		            		 {"D3_OP"   , oModelCYV:GetValue('CYVMASTER','CYV_NRORPO'), nil}})
				If lPPIAtivo
					aAdd(aItens[Len(aItens)],{"D3_OBSERVA","TOTVSMES",Nil})
				EndIf
			Endif
		Next

		if !Empty(aItens)
			If VerUlFchto()
				MSEXECAUTO({|x,y|MATA241(x,y)},aCab,aItens)

				If lMSErroAuto
					If _IsPost314
						cLogErro := ErroPost()
						//Seta a mensagem de erro no modelo, para recuperar posteriormente na api.
						oModelCYV:SetErrorMessage('CYVMASTER',,,,, cLogErro )
					Else
						If !IsTelNet()
							MostraErro()
						Else
							ErroTelnet()
						EndIf
					EndIf
					lRet := .F.
				EndIf
			Else
				lRet := .F.
			EndIf
		Endif
	Endif

	if lRet

	    //-------------------AtualizaÁ„o do apontamento de produÁ„o-------------------
		//-- Conversao da hora:
		//-- Normal para centesimal: (normal * 100) / 60
		//-- Centesimal para normal: (centesimal * 60) / 100

		//-- Numero da ordem de producao:
		aAdd(aMata681,{"H6_OP"     , oModelCYV:GetValue('CYVMASTER','CYV_NRORPO'), NIL})

		//-- Codigo do produto produzido:
		aAdd(aMata681,{"H6_PRODUTO", oModelCYV:GetValue('CYVMASTER','CYV_CDACRP'), NIL})

		aAdd(aMata681,{"H6_LOCAL"  , oModelCYV:GetValue('CYVMASTER','CYV_CDDP')  , NIL})
		aAdd(aMata681,{"H6_LOTECTL", oModelCYV:GetValue('CYVMASTER','CYV_CDLOSR'), NIL})
		aAdd(aMata681,{"H6_DTVALID", oModelCYV:GetValue('CYVMASTER','CYV_DTVDLO'), NIL})
		aAdd(aMata681,{"H6_LOCAL"  , oModelCYV:GetValue('CYVMASTER','CYV_CDDP')  , NIL})

		//-- Codigo da operacao apontada:
		aAdd(aMata681,{"H6_OPERAC" , oModelCYV:GetValue('CYVMASTER','CYV_CDAT'), NIL})

		//-- Codigo do recurso utilizado:
		aAdd(aMata681,{"H6_RECURSO", cMaquina, NIL})

		//-- Data de inicio do apontamento:
		aAdd(aMata681,{"H6_DATAINI", oModelCYV:GetValue('CYVMASTER','CYV_DTRPBG'), NIL})

		//-- Hora inicio do apontamento:
		//-- Respeitar o tipo de hora parametrizado na rotina
		if nTipoHr==1
			cHora := Substr(oModelCYV:GetValue('CYVMASTER','CYV_HRRPBG'),1,5)
		Else
			cHora := fConvHr(Val(Substr(oModelCYV:GetValue('CYVMASTER','CYV_HRRPBG'),1,2)+'.'+;
					 Substr(oModelCYV:GetValue('CYVMASTER','CYV_HRRPBG'),4,2)),'D')
			cHora := StrTran(Val2Hora(cHora,':'),'.',':')
		Endif

		aAdd(aMata681,{"H6_HORAINI",cHora,NIL})

		//-- Data de termino do apontamento
		aAdd(aMata681,{"H6_DATAFIN",oModelCYV:GetValue('CYVMASTER','CYV_DTRPED'),NIL})

		//-- Hora de termino do apontamento
		//-- Respeitar o tipo de hora parametrizado na rotina
		if nTipoHr==1
			cHora := Substr(oModelCYV:GetValue('CYVMASTER','CYV_HRRPED'),1,5)
		Else
			cHora := fConvHr(Val(Substr(oModelCYV:GetValue('CYVMASTER','CYV_HRRPED'),1,2)+'.'+;
					 Substr(oModelCYV:GetValue('CYVMASTER','CYV_HRRPED'),4,2)),'D')
			cHora := StrTran(Val2Hora(cHora,':'),'.',':')
		Endif

		aAdd(aMata681,{"H6_HORAFIN",cHora,NIL})

		//-- Data de inclusao do apontamento:
		//-- Sugestao: manter data base
		aAdd(aMata681,{"H6_DTAPONT",oModelCYV:GetValue('CYVMASTER','CYV_DTRP')	,NIL})

		//-- Quantidade produzida:
		aAdd(aMata681,{"H6_QTDPROD",oModelCYV:GetValue('CYVMASTER','CYV_QTATAP'),NIL})

		//-- Quantidade perdida:
		aAdd(aMata681,{"H6_QTDPERD",oModelCYV:GetValue('CYVMASTER','CYV_QTATRF'),NIL})

		//-- Codigo do recurso utilizado:
		aAdd(aMata681,{"H6_FERRAM" ,oModelCYV:GetValue('CYVMASTER','CYV_CDFEPO'),NIL})

		//-- Flag de apontamento parcial (P) ou total (T)
		//-- Este campo nao e obrigatorio pois o sistema o preenche conforme
		//-- saldo da ordem e quantidade apontada.
		aAdd(aMata681,{"H6_PT",IF(lOrdem,"T","P"),NIL})

		//IntegraÁ„o TOTVS MES - Deve gravar o campo H6_OBSERVA como TOTVSMES para n„o enviar novamente os saldos.
		If lPPIAtivo
			aAdd(aMata681,{"H6_OBSERVA","TOTVSMES",NIL})
		EndIf
		dbSelectArea("CY9")
		CY9->(dbSetOrder(1))
		CY9->(dbSeek(xFilial("CY9")+oModelCYV:GetValue('CYVMASTER','CYV_NRORPO')+oModelCYV:GetValue('CYVMASTER','CYV_IDAT')))

		if !GetMV("MV_VLDOPER") == "S" // Quando desativado, ent„o pergunta ao usu·rio quando gerar acabado
			if MsgYesNo(STR0124) // 'O sistema n„o est· validando as operaÁıes conforme selecionado atravÈs do par‚metro MV_VLDOPER. … preciso informar qual ser· o ˙ltimo apontamento. Confirma como ˙ltimo apontamento?'
				lGeraACA := .T.
			Else
				lGeraACA := .F.
			Endif
		Else
			If CY9->CY9_LGATED
				lGeraACA := .T.
			Else
				lGeraACA := .F.
			EndIf
		Endif

		IF lGeraACA
			oModelCYV:SetValue('CYVMASTER','CYV_LGGAAC',.T.)
		Endif

		aAdd(aMata681,{"AUTASKULT" ,lGeraACA,NIL})

		//Verifica se est· executando pela integraÁ„o com o TOTVS MES. Se estiver,
		If IsInCallStack("MATI681")
			SOE->(dbSeek(xFilial("SOE")+"SC2"))
			If AllTrim(SOE->OE_VAR1) == "2" .OR. AllTrim(SOE->OE_VAR1) == "3"
				//Se estiver parametrizado para consumo real, envia par‚metro para n„o consumir no PCP.
				//Consumo j· realizado atravÈs do mata241
				aAdd(aMata681, {"AUTCONSUMO", {{"AUTITEMS",{},Nil}}, Nil})
			EndIf
		EndIf
		If IsInCallStack("MATI681")
			For nI := 1 To oModelCY0:Length()
				oModelCY0:GoLine( nI )
				If !oModelCY0:IsDeleted()
					aAdd(aRefugos, {{"BC_PRODUTO",oModelCYV:GetValue('CYVMASTER','CYV_CDACRP'), Nil},;
											{"BC_LOCORIG",oModelCYV:GetValue('CYVMASTER','CYV_CDDP'), Nil},;
											{"BC_TIPO"   ,"R", Nil},;
											{"BC_MOTIVO" ,oModelCY0:GetValue("CY0_CDRF"), Nil},;
											{"BC_QUANT"  ,oModelCY0:GetValue("CY0_QTRF"), Nil}})
				EndIf
			Next nI
			If Len(aRefugos) > 0
				aAdd(aMata681, {"AUTREFUGO", aRefugos, Nil})
			EndIf
		EndIf

		If VerUlFchto()
			msExecAuto({|x,y| MATA681(x,y)},aMata681,3)
		Else
			lRet := .F.
		EndIf

		If lMSErroAuto //-- Tratativa de erro
			If IsInCallStack("A314Auto") .Or. _IsPost314
				//Recupera o erro completo.
				If !IsTelNet()
					cLogErro := ErroPost()
					//Seta a mensagem de erro no modelo, para recuperar posteriormente na api.
					oModelCYV:SetErrorMessage('CYVMASTER',,,,, cLogErro )
				Else
					ErroTelnet()
				EndIf
			Else
				If !IsTelNet()
					MostraErro()
				Else
					ErroTelnet()
				EndIf
			EndIf
			lRet = .F.
		Endif

		If lRet
			oModelCYV:LoadValue('CYVMASTER','CYV_NRRPET',SH6->H6_IDENT)

			If ExistBlock("SF314Ex681")
				lRet := ExecBlock("SF314Ex681",.F.,.F.,{oModelCYV})
			EndIf
		Endif
	Endif
Endif

RestArea(aAreaCYB)
RestArea(aAreaCYQ)
CY9->(RestArea(aAreaCY9))
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
Static Function IntegDef( cXML, nTypeTrans, cTypeMessage )
/*Local lRet     := .T.
Local lAssign     := .T.
Local cXMLRet  := ""
Local oModel
Local oModelCY0, oModelCYW, oModelCZP, oModelCZ0, oModelCZW
Local oBusinessContent
Local aWasteAppointment := {}
Local aResourceAppointment := {}
Local aSupplyOrder := {}
Local aReportToolActivities := {}
Local aReportOverhead := {}
Local nI
Local aArea    := GetArea()
Local aAreaCYV := CYV->(GetArea())

If nTypeTrans == TRANS_SEND .And. (IsInCallStack('CARGADTS_SFC') .Or. IsInCallStack('INTEGPASTA') .Or. IsInCallStack('U_INTEGPASTA'))
	Return { .T., 'Envio ignorado.' }
EndIf

// Se mensagem for de Recebimento
If nTypeTrans == TRANS_RECEIVE

	  //  Se mensagem for de NegÛcio
      If cTypeMessage == EAI_MESSAGE_BUSINESS
            //conout( '+ IntegDef SFCA314 Recebendo Mensagem Business' )

			cError := ''
			cWarning := ''

			// Cria um objeto XML a partir da estutura dos dados do Model
			oXML := XmlParser(FwNoAccent(cXML), "_", @cError, @cWarning)

			lValid := .F.

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
            	Return { lValid, 'Nao foi enviada uma mensagem valida' }
            EndIf

			// Instancia o modelo
			oModel := FWLoadModel( 'SFCA314' )
			oModelCY0 := oModel:GetModel('CY0DETAIL')
			oModelCYW := oModel:GetModel('CYWDETAIL')
			oModelCZP := oModel:GetModel('CZPDETAIL')
			oModelCZ0 := oModel:GetModel('CZ0DETAIL')
			oModelCZW := oModel:GetModel('CZWDETAIL')

			// Verifica se a chave primaria que veio pelo XML ja existe na Base de Dados
			dbSelectArea('CYV')
			CYV->(dbSetOrder(1))
			lFound := CYV->(dbSeek(xFilial('CYV')+ PadR(oBusinessContent:_ReportSequence:TEXT, Len(CYV->CYV_NRSQRP))))

			// Verifica se a mensagem È de Inclus„o/AlteraÁ„o
			If UPPER(oBusinessEvent) == EAI_EVENT_UPSERT
				// Se foi encontrado, envia como AlteraÁ„o
				If lFound
					nOpc := 4
				Else
					// Caso n„o esteja cadastrado na Base de Dados, trata como Inclus„o
					nOpc := 3
				EndIf
			Else
				// Apaga o registro
				nOpc := 5
			EndIf

			// Set a operaÁ„o e Ativa o Model
			oModel:SetOperation(nOpc)
			oModel:Activate()


            // Se operaÁ„o for diferente de exclus„o
			If nOpc # 5
				// Adiciona a chave apenas se for inclus„o
				If nOpc == 3
					lAssign := oModel:SetValue('CYVMASTER', 'CYV_NRSQRP', oBusinessContent:_ReportSequence:TEXT	)
					//If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModel:SetValue('CYVMASTER', 'CYV_CDMQ', 	SFCXXtoS(oBusinessContent:_MachineCode:TEXT		) )
					If !lAssign; Return SFCXMKERR(oModel); EndIf
				EndIf


				lAssign := oModel:SetValue('CYVMASTER', 'CYV_DSMQ', 	SFCXXtoS(oBusinessContent:_MachineDescription:TEXT	) )  ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYVMASTER', 'CYV_NRORPO', 	SFCXXtoS(oBusinessContent:_ProductionOrderNumber:TEXT	) )  ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYVMASTER', 'CYV_IDAT', 	SFCXXtoS(oBusinessContent:_ActivityID:TEXT	) )  ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYVMASTER', 'CYV_IDATQO', 	SFCXXtoS(oBusinessContent:_Split:TEXT	) )   ;If !lAssign; Return SFCXMKERR(oModel); EndIf

				If XmlChildEx(oBusinessContent, '_ACTIVITYCODE') != NIL
					lAssign := oModel:SetValue('CYVMASTER', 'CYV_CDAT', 	SFCXXtoS(oBusinessContent:_ActivityCode:TEXT	) );If !lAssign; Return SFCXMKERR(oModel); EndIf
				EndIf

				lAssign := oModel:SetValue('CYVMASTER', 'CYV_CDACRP', 	SFCXXtoS(oBusinessContent:_ItemCode:TEXT	) ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYVMASTER', 'CYV_QTATRP', 	SFCXXtoS(oBusinessContent:_ReportQuantity:TEXT	) )  ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYVMASTER', 'CYV_QTATAP', 	SFCXXtoS(oBusinessContent:_ApprovedQuantity:TEXT	) ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYVMASTER', 'CYV_QTATRF', 	SFCXXtoS(oBusinessContent:_ScrapQuantity:TEXT	) )  ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYVMASTER', 'CYV_QTATRT', 	SFCXXtoS(oBusinessContent:_ReworkQuantity:TEXT	) );If !lAssign; Return SFCXMKERR(oModel); EndIf

				If XmlChildEx(oBusinessContent, '_STARTCENTSETUPTIME') != NIL
					lAssign := oModel:SetValue('CYVMASTER', 'CYV_HCBGSU', 	SFCXXtoS(oBusinessContent:_StartCentSetupTime:TEXT	) ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModel:SetValue('CYVMASTER', 'CYV_HCEDSU', 	SFCXXtoS(oBusinessContent:_EndCentSetupTime:TEXT	) ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				EndIf

				If XmlChildEx(oBusinessContent, '_STARTCENTREPORTTIME') != NIL
					lAssign := oModel:SetValue('CYVMASTER', 'CYV_HCRPBG', 	SFCXXtoS(oBusinessContent:_StartCentReportTime:TEXT	) ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModel:SetValue('CYVMASTER', 'CYV_HCRPED', 	SFCXXtoS(oBusinessContent:_EndCentReportTime:TEXT	) ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				EndIf

				If XmlChildEx(oBusinessContent, '_OPTIMEDEC') != NIL
					lAssign := oModel:SetValue('CYVMASTER', 'CYV_HRTERP', 	SFCXXtoS(oBusinessContent:_OpTimeDec:TEXT	) ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				EndIf

				If XmlChildEx(oBusinessContent, '_OPTIMEINT') != NIL
					lAssign := oModel:SetValue('CYVMASTER', 'CYV_QTTERP', 	SFCXXtoS(oBusinessContent:_OpTimeInt:TEXT	) ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				EndIf

				If XmlChildEx(oBusinessContent, '_EXTRATIME') != NIL
					lAssign := oModel:SetValue('CYVMASTER', 'CYV_QTTEEX', 	SFCXXtoS(oBusinessContent:_ExtraTime:TEXT	) ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				EndIf

				If XmlChildEx(oBusinessContent, '_STOPTIME') != NIL
					lAssign := oModel:SetValue('CYVMASTER', 'CYV_QTTESP', 	SFCXXtoS(oBusinessContent:_StopTime:TEXT	) )  ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				EndIf

				If XmlChildEx(oBusinessContent, '_MODTIME') != NIL
					lAssign := oModel:SetValue('CYVMASTER', 'CYV_QTTEOE', 	SFCXXtoS(oBusinessContent:_MODTime:TEXT	) ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				EndIf

				lAssign := oModel:SetValue('CYVMASTER', 'CYV_LGRPPO', 	SFCXXtoS(oBusinessContent:_IsProductionControlReport:TEXT	) )  ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYVMASTER', 'CYV_LGLBCQ', 	SFCXXtoS(oBusinessContent:_CQLiberated:TEXT	) ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYVMASTER', 'CYV_LGRPEO', 	SFCXXtoS(oBusinessContent:_ReversedReport:TEXT	) ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf

				If XmlChildEx(oBusinessContent, '_REVERSALDATE') != NIL
					lAssign := oModel:SetValue('CYVMASTER', 'CYV_DTEO', 	SFCXXtoS(oBusinessContent:_ReversalDate:TEXT	) ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				EndIf

				If XmlChildEx(oBusinessContent, '_UPDATEREPORT') != NIL
					lAssign := oModel:SetValue('CYVMASTER', 'CYV_LGRP', 	SFCXXtoS(oBusinessContent:_UpdateReport:TEXT	) ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				EndIf

				If XmlChildEx(oBusinessContent, '_PRODUCTIONSHIFTCODE') != NIL
					lAssign := oModel:SetValue('CYVMASTER', 'CYV_CDTN', 	SFCXXtoS(oBusinessContent:_ProductionShiftCode:TEXT	) )  ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModel:SetValue('CYVMASTER', 'CYV_DSTN', 	SFCXXtoS(oBusinessContent:_ProductionShiftDescription:TEXT	) ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				EndIf

				If XmlChildEx(oBusinessContent, '_PRODUCTIONSHIFTNUMBER') != NIL
					lAssign := oModel:SetValue('CYVMASTER', 'CYV_NRTN', 	SFCXXtoS(oBusinessContent:_ProductionShitNumber:TEXT	) ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				EndIf

				If XmlChildEx(oBusinessContent, '_REPORTCENT1TIME') != NIL
					lAssign := oModel:SetValue('CYVMASTER', 'CYV_HCRP', 	SFCXXtoS(oBusinessContent:_ReportCentlTime:TEXT	) ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				EndIf

				lAssign := oModel:SetValue('CYVMASTER', 'CYV_NRDO', 	SFCXXtoS(oBusinessContent:_DocumentCode:TEXT	) ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYVMASTER', 'CYV_NRSR', 	SFCXXtoS(oBusinessContent:_DocumentSeries:TEXT	) ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYVMASTER', 'CYV_CDDP', 	SFCXXtoS(oBusinessContent:_WarehouseCode:TEXT	) ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYVMASTER', 'CYV_CDLOSR', 	SFCXXtoS(oBusinessContent:_LotCode:TEXT	) ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf

				If XmlChildEx(oBusinessContent, '_LOTDUEDATE') != NIL
					lAssign := oModel:SetValue('CYVMASTER', 'CYV_DTVDLO', 	SFCXXtoS(oBusinessContent:_LotDueDate:TEXT	) ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				EndIf

				lAssign := oModel:SetValue('CYVMASTER', 'CYV_CDRE', 	SFCXXtoS(oBusinessContent:_ReferenceCode:TEXT	) ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYVMASTER', 'CYV_CDLC', 	SFCXXtoS(oBusinessContent:_LocationCode:TEXT	) ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYVMASTER', 'CYV_LGLCOT', 	SFCXXtoS(oBusinessContent:_SingleOutflowLocation:TEXT	) ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf

				If XmlChildEx(oBusinessContent, '_OUTFLOWLOCATIONCODE') != NIL
					lAssign := oModel:SetValue('CYVMASTER', 'CYV_CDLCOT', 	SFCXXtoS(oBusinessContent:_OutflowLocationCode:TEXT	) ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModel:SetValue('CYVMASTER', 'CYV_CDDPOT', 	SFCXXtoS(oBusinessContent:_OutflowWarehouse:TEXT	) ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				EndIf

				If XmlChildEx(oBusinessContent, '_INTEGRATIONREPORT') != NIL
					lAssign := oModel:SetValue('CYVMASTER', 'CYV_NRRPET', 	SFCXXtoS(oBusinessContent:_IntegrationReport:TEXT	) ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				EndIf

				If XmlChildEx(oBusinessContent, '_TOOLCODE') != NIL
					lAssign := oModel:SetValue('CYVMASTER', 'CYV_CDFEPO', 	SFCXXtoS(oBusinessContent:_ToolCode:TEXT	) ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModel:SetValue('CYVMASTER', 'CYV_DSFEPO', 	SFCXXtoS(oBusinessContent:_ToolDescription:TEXT	) )  ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				EndIf

				If XmlChildEx(oBusinessContent, '_SETUPCODE') != NIL
					oModel:SetValue('CYVMASTER', 'CYV_CDSU', 	SFCXXtoS(oBusinessContent:_SetupCode:TEXT	) )  ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					oModel:SetValue('CYVMASTER', 'CYV_DSSU', 	SFCXXtoS(oBusinessContent:_SetupDescription:TEXT	) ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				EndIf

				lAssign := oModel:SetValue('CYVMASTER', 'CYV_NRBG', 	SFCXXtoS(oBusinessContent:_CounterStart:TEXT	) ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				lAssign := oModel:SetValue('CYVMASTER', 'CYV_NRED', 	SFCXXtoS(oBusinessContent:_FinalAccountant:TEXT	) ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf

				If XmlChildEx(oBusinessContent, '_CLOSEOPERATION') != NIL
					lAssign := oModel:SetValue('CYVMASTER', 'CYV_LGEDRP', 	SFCXXtoS(oBusinessContent:_CloseOperation:TEXT	) ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
                EndIf


        		oModelCY0:SetNoInsertLine(.F.)
        		oModelCY0:SetNoUpdateLine(.F.)
				For nI := 1 To oModelCY0:Length()
					oModelCY0:GoLine( nI )
					If !oModelCY0:IsDeleted()
				       	oModelCY0:DeleteLine()
					Endif
				Next


				If XmlChildEx(oBusinessContent, "_LISTOFWASTEAPPOINTMENTS") != NIL .AND. XmlChildCount(oBusinessContent:_ListOfWasteAppointments) > 0
					aWasteAppointment := oBusinessContent:_ListOfWasteAppointments:_WasteAppointment
					If valType(aWasteAppointment) == 'O'
						aWasteAppointment := { aWasteAppointment }
					EndIf
				EndIf

        		For nI := 1 To Len(aWasteAppointment)
					oModelCY0:AddLine()
				    oWasteAppointmentContent := aWasteAppointment[nI]

				    lAssign := oModelCY0:SetValue('CY0_CDRF'	, SFCXXtoS(oWasteAppointmentContent:_WasteCode:TEXT)     				 ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCY0:SetValue('CY0_DSRF'  	, SFCXXtoS(oWasteAppointmentContent:_WasteDescription:TEXT)            					 ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCY0:SetValue('CY0_QTRF'	, SFCXStoX(oWasteAppointmentContent:_ScrapQuantity:TEXT, 'N')      					 ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
					lAssign := oModelCY0:SetValue('CY0_QTRT'  	, SFCXStoX(oWasteAppointmentContent:_ReworkQuantity:TEXT, 'N')        					 ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				Next




				For nI := 1 To oModelCYW:Length()
					oModelCYW:GoLine( nI )
					If !oModelCYW:IsDeleted()
				       	oModelCYW:DeleteLine()
					Endif
				Next


				If XmlChildEx(oBusinessContent, "_LISTOFRESOURCEAPPOINTMENTS") != NIL .AND. XmlChildCount(oBusinessContent:_ListOfResourceAppointments) > 0
					aResourceAppointment := oBusinessContent:_ListOfResourceAppointments:_ResourceAppointment
					If ValType(aResourceAppointment) == 'O'
						aResourceAppointment := { aResourceAppointment }
					EndIf
				EndIf

        		For nI := 1 To Len(aResourceAppointment)
					oModelCYW:AddLine()
				    oResourceAppointmentContent := aResourceAppointment[nI]

				    lAssign := oModelCYW:SetValue('CYW_IDOE', SFCXXtoS(oResourceAppointmentContent:_OperatorID:TEXT)     				 ) 	;If !lAssign; Return SFCXMKERR(oModel); EndIf
				    lAssign := oModelCYW:SetValue('CYW_CDOE', SFCXXtoS(oResourceAppointmentContent:_OperatorCode:TEXT)     				 ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				    lAssign := oModelCYW:SetValue('CYW_NMOE', SFCXXtoS(oResourceAppointmentContent:_OperatorName:TEXT)     				 ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				    lAssign := oModelCYW:SetValue('CYW_CDGROE', SFCXXtoS(oResourceAppointmentContent:_ProductionTeamCode:TEXT)     				 ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				    lAssign := oModelCYW:SetValue('CYW_HCBGRP', SFCXStoX(oResourceAppointmentContent:_StartCentTime:TEXT, 'N')     				 ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				    lAssign := oModelCYW:SetValue('CYW_HCEDRP', SFCXStoX(oResourceAppointmentContent:_EndCentTime:TEXT, 'N')     				 ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				    lAssign := oModelCYW:SetValue('CYW_QTTEOE', SFCXStoX(oResourceAppointmentContent:_MOBTime:TEXT, 'N')     				 ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				    lAssign := oModelCYW:SetValue('CYW_QTTEEX', SFCXStoX(oResourceAppointmentContent:_ExtraTime:TEXT, 'N')     				 ) 	;If !lAssign; Return SFCXMKERR(oModel); EndIf
				    lAssign := oModelCYW:SetValue('CYW_QTTEUT', SFCXStoX(oResourceAppointmentContent:_UtilTime:TEXT, 'N')     				 ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				    lAssign := oModelCYW:SetValue('CYW_CDTN', SFCXXtoS(oResourceAppointmentContent:_ProductionShiftCode:TEXT)     				 ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				    lAssign := oModelCYW:SetValue('CYW_NRTN', SFCXXtoS(oResourceAppointmentContent:_ProductionShiftNumber:TEXT)     				 ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf

				Next


				For nI := 1 To oModelCZP:Length()
					oModelCZP:GoLine( nI )
					If !oModelCZP:IsDeleted()
				       	oModelCZP:DeleteLine()
					Endif
				Next


				If XmlChildEx(oBusinessContent, "_LISTOFSUPPLYORDERS") != NIL .AND. XmlChildCount(oBusinessContent:_ListOfSupplyOrders) > 0
					aSupplyOrder := oBusinessContent:_ListOfSupplyOrders:_SupplyOrder
					If valType(aSupplyOrder) == 'O'
						aSupplyOrder := { aSupplyOrder }
					EndIf
				EndIf

        		For nI := 1 To Len(aSupplyOrder)
					oModelCZP:AddLine()
				    oSupplyOrderContent := aSupplyOrder[nI]

				    lAssign := oModelCZP:SetValue('CZP_NRORPO', oSupplyOrderContent:_ProductionOrderNumber:TEXT     				 ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				    lAssign := oModelCZP:SetValue('CZP_CDMT', oSupplyOrderContent:_MaterialCode:TEXT     				 ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf
				    lAssign := oModelCZP:SetValue('CZP_DSMT', oSupplyOrderContent:_MaterialDescription:TEXT     				 ) 	;If !lAssign; Return SFCXMKERR(oModel); EndIf
				    lAssign := oModelCZP:SetValue('CZP_CDRE', oSupplyOrderContent:_ReferenceCode:TEXT     				 ) 	;If !lAssign; Return SFCXMKERR(oModel); EndIf
				    lAssign := oModelCZP:SetValue('CZP_QTRPPO', oSupplyOrderContent:_UsedQuantity:TEXT     				 ) 	;If !lAssign; Return SFCXMKERR(oModel); EndIf
				    lAssign := oModelCZP:SetValue('CZP_QTRP', oSupplyOrderContent:_ApprovedQuantity:TEXT     				 ) 	;If !lAssign; Return SFCXMKERR(oModel); EndIf
				    lAssign := oModelCZP:SetValue('CZP_CDUN', oSupplyOrderContent:_UnitOfMeasureCode:TEXT     				 ) 	;If !lAssign; Return SFCXMKERR(oModel); EndIf
				    lAssign := oModelCZP:SetValue('CZP_CDACPI', oSupplyOrderContent:_FatherItemCode:TEXT     				 ) 	;If !lAssign; Return SFCXMKERR(oModel); EndIf
				    //lAssign := oModelCZP:SetValue('CZP_DSACPI', oSupplyOrderContent:_FatherItemDescription:TEXT     				 ) 	;If !lAssign; Return SFCXMKERR(oModel); EndIf
				    lAssign := oModelCZP:SetValue('CZP_CDDP', oSupplyOrderContent:_WarehouseCode:TEXT     				 ) 	;If !lAssign; Return SFCXMKERR(oModel); EndIf
				    lAssign := oModelCZP:SetValue('CZP_CDLC', oSupplyOrderContent:_LocationCode:TEXT     				 ) 	;If !lAssign; Return SFCXMKERR(oModel); EndIf
				    lAssign := oModelCZP:SetValue('CZP_CDLO', oSupplyOrderContent:_LotCode:TEXT     				 ) 	;If !lAssign; Return SFCXMKERR(oModel); EndIf
				    lAssign := oModelCZP:SetValue('CZP_CDAT', oSupplyOrderContent:_ActivityCode:TEXT     				 ) 	;If !lAssign; Return SFCXMKERR(oModel); EndIf
				    lAssign := oModelCZP:SetValue('CZP_CDRT', oSupplyOrderContent:_ScriptCode:TEXT     				 ) 	;If !lAssign; Return SFCXMKERR(oModel); EndIf
				    lAssign := oModelCZP:SetValue('CZP_CDES', oSupplyOrderContent:_SiteCode:TEXT     				 ) 	;If !lAssign; Return SFCXMKERR(oModel); EndIf
				    lAssign := oModelCZP:SetValue('CZP_DTMT', oSupplyOrderContent:_MaterialDate:TEXT     				 ) 	;If !lAssign; Return SFCXMKERR(oModel); EndIf
				    lAssign := oModelCZP:SetValue('CZP_QTMT', oSupplyOrderContent:_MaterialQuantity:TEXT     				 ) 	;If !lAssign; Return SFCXMKERR(oModel); EndIf
				    lAssign := oModelCZP:SetValue('CZP_TPST', oSupplyOrderContent:_StatusType:TEXT     				 ) 	;If !lAssign; Return SFCXMKERR(oModel); EndIf
				    lAssign := oModelCZP:SetValue('CZP_CDTBMT', oSupplyOrderContent:_OrderProcess:TEXT     				 ) 	;If !lAssign; Return SFCXMKERR(oModel); EndIf
				    lAssign := oModelCZP:SetValue('CZP_NRORRE', oSupplyOrderContent:_ReferenceOrderNumber:TEXT     				 ) 	;If !lAssign; Return SFCXMKERR(oModel); EndIf
				    lAssign := oModelCZP:SetValue('CZP_IDMTOR', oSupplyOrderContent:_MaterialID:TEXT     				 ) 	;If !lAssign; Return SFCXMKERR(oModel); EndIf

				Next


				For nI := 1 To oModelCZ0:Length()
					oModelCZ0:GoLine( nI )
					If !oModelCZ0:IsDeleted()
				       	oModelCZ0:DeleteLine()
					Endif
				Next


				If XmlChildEx(oBusinessContent, "_LISTOFREPORTTOOLACTIVITIES") != NIL .AND. XmlChildCount(oBusinessContent:_ListOfReportToolActivities) > 0
					aReportToolActivities := oBusinessContent:_ListOfReportToolActivities:_ReportToolActivity
					If valType(aReportToolActivities) == 'O'
						aReportToolActivities := { aReportToolActivities }
					EndIf
				EndIf

        		oModelCZ0:SetNoInsertLine(.F.)
        		oModelCZ0:SetNoUpdateLine(.F.)
        		For nI := 1 To Len(aReportToolActivities)
					oModelCZ0:AddLine()
				    oReportToolActivitiesContent := aReportToolActivities[nI]

				    lAssign := oModelCZ0:SetValue('CZ0_CDFE', oReportToolActivitiesContent:_ToolCode:TEXT     				 ) 	;If !lAssign; Return SFCXMKERR(oModel); EndIf
				    lAssign := oModelCZ0:SetValue('CZ0_DSFE', oReportToolActivitiesContent:_ToolDescription:TEXT     				 ) ;If !lAssign; Return SFCXMKERR(oModel); EndIf

				    If XmlChildEx(oReportToolActivitiesContent, '_OPERATIONUNITTIME') != NIL
					    oModelCZ0:SetValue('CZ0_QTTEUN', oReportToolActivitiesContent:_OperationUnitTime:TEXT     				 ) 	;If !lAssign; Return SFCXMKERR(oModel); EndIf
    				EndIf

				Next


				For nI := 1 To oModelCZW:Length()
					oModelCZW:GoLine( nI )
					If !oModelCZW:IsDeleted()
				       	oModelCZW:DeleteLine()
					Endif
				Next


				If XmlChildEx(oBusinessContent, "_LISTOFREPORTOVERHEAD") != NIL .AND. XmlChildCount(oBusinessContent:_ListOfReportOverhead) > 0
					aReportOverhead := oBusinessContent:_ListOfReportOverhead:_ReportOverhead
					If valType(aReportOverhead) == 'O'
						aReportOverhead := { aReportOverhead }
					EndIf
				EndIf

        		For nI := 1 To Len(aReportOverhead)
					oModelCZW:AddLine()
				    oReportOverheadContent := aReportOverhead[nI]

				    lAssign := oModelCZW:SetValue('CZW_CDCETR', oReportOverheadContent:_WorkCenterCode:TEXT     				 ) 	;If !lAssign; Return SFCXMKERR(oModel); EndIf
				    lAssign := oModelCZW:SetValue('CZW_DSCETR', oReportOverheadContent:_WorkCenterDescription:TEXT     				 ) 	;If !lAssign; Return SFCXMKERR(oModel); EndIf
				    lAssign := oModelCZW:SetValue('CZW_QTTEGF', oReportOverheadContent:_GGFTimeInt:TEXT     				 ) 	;If !lAssign; Return SFCXMKERR(oModel); EndIf
				    lAssign := oModelCZW:SetValue('CZW_HRTEGF', oReportOverheadContent:_GGFTimeDec:TEXT     				 ) 	;If !lAssign; Return SFCXMKERR(oModel); EndIf


				Next

             EndIf

            // ValidaÁ„o no Model
			if oModel:VldData()
				// Caso nao ocorra erros, efetiva os dados no banco
				oModel:CommitData()

				// Retorna OK
				cXMLRet := 'Mensagem de ' + IF(nOpc == 3,'Criacao', IF(nOpc == 4, 'Alteracao', 'Delecao')) + ' recebida com sucesso.'
			Else
				// Cria TAG com o Erro ocorrido para retornar ao EAI
				aErro := oModel:GetErrorMessage()
				cXMLRet := SFCXXtoS(aErro[6]) + ' (' + SFCXXtoS(aErro[4]) + ' = "' + SFCXXtoS(aErro[9]) + '")'

				lRet := .F.
			EndIf

			// Desativa o Model
			oModel:DeActivate()

	  // Mensagem È de Response
      ElseIf   cTypeMessage == EAI_MESSAGE_RESPONSE
            //conout( '+ IntegDef SFCA315 Recebendo Mensagem Response' )
            cXMLRet := 'Resposta recebida com sucesso.'
      // Mensagem È de Whois
      ElseIf   cTypeMessage == EAI_MESSAGE_WHOIS
            //conout( '+ IntegDef SFCA315 Recebendo Mensagem WHOIS' )
            Return {.T., '1.000'}
      EndIf
// Chamada È para envio, solicitada pelo MODEL
ElseIf nTypeTrans == TRANS_SEND
      //conout( '+ IntegDef SFCA314 Enviando Mensagem' )

      // Busca o Model que est· Ativo no momento da chamada
      oModel := FwModelActive()
	  oModelCY0 := oModel:GetModel('CY0DETAIL')
	  oModelCYW := oModel:GetModel('CYWDETAIL')
	  oModelCZP := oModel:GetModel('CZPDETAIL')
	  oModelCZ0 := oModel:GetModel('CZ0DETAIL')
	  oModelCZW := oModel:GetModel('CZWDETAIL')

	  // Cria a estrutura de TAGs BusinessEvent, j· identificando se È "Upsert" ou "Delete", e colocando as "Identifications"
      cXMLRet :=  FWEAIBusEvent( "ProductionAppointment", oModel:GetOperation(), { { "ReportSequence", oModel:GetValue("CYVMASTER", 'CYV_NRSQRP') } } )

      // Deve ser criado, manualmente, o BusinessContent a ser enviado para o EAI
      cXMLRet += '<BusinessContent>'


		cXMLRet += '<ReportSequence>'  			 	+ oModel:GetValue("CYVMASTER", 'CYV_NRSQRP')  			+ '</ReportSequence>'

		// Se a operaÁ„o for diferente de 5 (Exclus„o), manda as informaÁıes que n„o s„o relacionadas a chave
		If oModel:GetOperation() # 5

			cXMLRet += '<MachineCode>' 	 				+ oModel:GetValue("CYVMASTER", 'CYV_CDMQ')  		   		+ '</MachineCode>'
			cXMLRet += '<MachineDescription>'  			+ oModel:GetValue("CYVMASTER", 'CYV_DSMQ')  		   		+ '</MachineDescription>'
			cXMLRet += '<ProductionOrderNumber>' 		+ oModel:GetValue("CYVMASTER", 'CYV_NRORPO')  		 		+ '</ProductionOrderNumber>'
			cXMLRet += '<ActivityID>' 				    + oModel:GetValue("CYVMASTER", 'CYV_IDAT')		  			+ '</ActivityID>'
	   		cXMLRet += '<Split>'   						+ oModel:GetValue("CYVMASTER", 'CYV_IDATQO')	  			+ '</Split>'
			cXMLRet += '<ActivityCode>'			    	+ oModel:GetValue("CYVMASTER", 'CYV_CDAT')  		   	    + '</ActivityCode>'
			cXMLRet += '<ItemCode>'   					+ oModel:GetValue("CYVMASTER", 'CYV_CDACRP')  		   		+ '</ItemCode>'
			cXMLRet += '<ItemDescription>'   			+ oModel:GetValue("CYVMASTER", 'CYV_DSAC')  		   		+ '</ItemDescription>'
			cXMLRet += '<ReportQuantity>'	  		 	+ SFCXXtoS(oModel:GetValue("CYVMASTER", 'CYV_QTATRP'))		+ '</ReportQuantity>'
			cXMLRet += '<ApprovedQuantity>'  		 	+ SFCXXtoS(oModel:GetValue("CYVMASTER", 'CYV_QTATAP'))		+ '</ApprovedQuantity>'
			cXMLRet += '<ScrapQuantity>'  		  		+ SFCXXtoS(oModel:GetValue("CYVMASTER", 'CYV_QTATRF'))		+ '</ScrapQuantity>'
			cXMLRet += '<ReworkQuantity>'  		  		+ SFCXXtoS(oModel:GetValue("CYVMASTER", 'CYV_QTATRT'))		+ '</ReworkQuantity>'
			cXMLRet += '<StartCentSetupTime>'  		 	+ SFCXXtoS(oModel:GetValue("CYVMASTER", 'CYV_HCBGSU'))		+ '</StartCentSetupTime>'
			cXMLRet += '<EndCentSetupTime>'  		 	+ SFCXXtoS(oModel:GetValue("CYVMASTER", 'CYV_HCEDSU'))		+ '</EndCentSetupTime>'
			cXMLRet += '<StartCentReportTime>'  		+ SFCXXtoS(oModel:GetValue("CYVMASTER", 'CYV_HCRPBG'))		+ '</StartCentReportTime>'
			cXMLRet += '<EndCentReportTime>'  		 	+ SFCXXtoS(oModel:GetValue("CYVMASTER", 'CYV_HCRPED'))		+ '</EndCentReportTime>'
			cXMLRet += '<OpTimeDec>'  		 			+ SFCXXtoS(oModel:GetValue("CYVMASTER", 'CYV_HRTERP'))		+ '</OpTimeDec>'
			cXMLRet += '<OpTimeInt>'  		 			+ SFCXXtoS(oModel:GetValue("CYVMASTER", 'CYV_QTTERP'))		+ '</OpTimeInt>'
			cXMLRet += '<ExtraTime>'  		 			+ SFCXXtoS(oModel:GetValue("CYVMASTER", 'CYV_QTTEEX'))		+ '</ExtraTime>'
			cXMLRet += '<StopTime>'  		 			+ SFCXXtoS(oModel:GetValue("CYVMASTER", 'CYV_QTTESP'))		+ '</StopTime>'
			cXMLRet += '<MODTime>'  		 			+ SFCXXtoS(oModel:GetValue("CYVMASTER", 'CYV_QTTEOE'))		+ '</MODTime>'
			cXMLRet += '<IsProductionControlReport>'	+ SFCXXtoS(oModel:GetValue("CYVMASTER", 'CYV_LGRPPO'))		+ '</IsProductionControlReport>'
			cXMLRet += '<CQLiberated>'  		 		+ SFCXXtoS(oModel:GetValue("CYVMASTER", 'CYV_LGLBCQ'))		+ '</CQLiberated>'
			cXMLRet += '<ReversedReport>'  		 		+ SFCXXtoS(oModel:GetValue("CYVMASTER", 'CYV_LGRPEO'))		+ '</ReversedReport>'
			cXMLRet += '<ReversalDate>'  		 		+ SFCXXtoS(oModel:GetValue("CYVMASTER", 'CYV_DTEO'))		+ '</ReversalDate>'
			cXMLRet += '<UpdateReport>'  		 		+ SFCXXtoS(oModel:GetValue("CYVMASTER", 'CYV_LGRP'))		+ '</UpdateReport>'
			cXMLRet += '<ProductionShiftCode>'   	  	+ oModel:GetValue("CYVMASTER", 'CYV_CDTN')		  			+ '</ProductionShiftCode>'
			cXMLRet += '<ProductionShiftDescription>'	+ oModel:GetValue("CYVMASTER", 'CYV_DSTN')		  			+ '</ProductionShiftDescription>'
			cXMLRet += '<ProductionShitNumber>'   		+ oModel:GetValue("CYVMASTER", 'CYV_NRTN')  				+ '</ProductionShitNumber>'
			cXMLRet += '<ReportCentlTime>'   		 	+ SFCXXtoS(oModel:GetValue("CYVMASTER", 'CYV_HCRP'))		+ '</ReportCentlTime>'
			cXMLRet += '<DocumentCode>'   				+ oModel:GetValue("CYVMASTER", 'CYV_NRDO')   				+ '</DocumentCode>'
			cXMLRet += '<DocumentSeries>'  				+ oModel:GetValue("CYVMASTER", 'CYV_NRSR')  				+ '</DocumentSeries>'
			cXMLRet += '<WarehouseCode>'   				+ oModel:GetValue("CYVMASTER", 'CYV_CDDP') 		 			+ '</WarehouseCode>'
			cXMLRet += '<LotCode>'   					+ oModel:GetValue("CYVMASTER", 'CYV_CDLOSR') 	 			+ '</LotCode>'
			cXMLRet += '<LotDueDate>'  		 			+ SFCXXtoS(oModel:GetValue("CYVMASTER", 'CYV_DTVDLO'))		+ '</LotDueDate>'
			cXMLRet += '<ReferenceCode>'				+ oModel:GetValue("CYVMASTER", 'CYV_CDRE')		  			+ '</ReferenceCode>'
			cXMLRet += '<LocationCode>'					+ oModel:GetValue("CYVMASTER", 'CYV_CDLC')		  			+ '</LocationCode>'
			cXMLRet += '<SingleOutflowLocation>'	 	+ SFCXXtoS(oModel:GetValue("CYVMASTER", 'CYV_LGLCOT'))		+ '</SingleOutflowLocation>'
			cXMLRet += '<OutflowLocationCode>' 		    + oModel:GetValue("CYVMASTER", 'CYV_CDLCOT')	  			+ '</OutflowLocationCode>'
			cXMLRet += '<OutflowWarehouse>'   			+ oModel:GetValue("CYVMASTER", 'CYV_CDDPOT')  				+ '</OutflowWarehouse>'
			cXMLRet += '<IntegrationReport>'   			+ oModel:GetValue("CYVMASTER", 'CYV_NRRPET')  				+ '</IntegrationReport>'
			cXMLRet += '<ToolCode>'   					+ oModel:GetValue("CYVMASTER", 'CYV_CDFEPO')  				+ '</ToolCode>'
			cXMLRet += '<ToolDescription>'   			+ oModel:GetValue("CYVMASTER", 'CYV_DSFEPO')  				+ '</ToolDescription>'
			cXMLRet += '<SetupCode>'   		   			+ oModel:GetValue("CYVMASTER", 'CYV_CDSU')  				+ '</SetupCode>'
			cXMLRet += '<SetupDescription>' 		  	+ oModel:GetValue("CYVMASTER", 'CYV_DSSU')	  				+ '</SetupDescription>'
			cXMLRet += '<CounterStart>'  		 		+ SFCXXtoS(oModel:GetValue("CYVMASTER", 'CYV_NRBG'))		+ '</CounterStart>'
			cXMLRet += '<FinalAccountant>'  		 	+ SFCXXtoS(oModel:GetValue("CYVMASTER", 'CYV_NRED'))		+ '</FinalAccountant>'
			cXMLRet += '<CloseOperation>'  		   		+ SFCXXtoS(oModel:GetValue("CYVMASTER", 'CYV_LGEDRP'))		+ '</CloseOperation>'

		 // DateTime - Verificar
		 //	cXMLRet += '<StartSetupDateTime>'  	  		+ SFCXXtoS(oModel:GetValue("CYVMASTER", 'CYV_DTBGSU'))		+ '</StartSetupDateTime>'
		 //	cXMLRet += '<StartSetupDateTime>'   		+ oModel:GetValue("CYVMASTER", 'CYV_HRBGSU')  				+ '</StartSetupDateTime>'
		 //	cXMLRet += '<EndSetupDateTime>'  		 	+ SFCXXtoS(oModel:GetValue("CYVMASTER", 'CYV_DTEDSU'))		+ '</EndSetupDateTime>'
		 //	cXMLRet += '<EndSetupDateTime>'  			+ oModel:GetValue("CYVMASTER", 'CYV_HREDSU')	  			+ '</EndSetupDateTime>'
		 // cXMLRet += '<StartReportDateTime>'  	 	+ SFCXXtoS(oModel:GetValue("CYVMASTER", 'CYV_DTRPBG'))		+ '</StartReportDateTime>'
		 // cXMLRet += '<StartReportDateTime>'   		+ oModel:GetValue("CYVMASTER", 'CYV_HRRPBG')	  			+ '</StartReportDateTime>'
		 // cXMLRet += '<EndReportDateTime>'  			+ SFCXXtoS(oModel:GetValue("CYVMASTER", 'CYV_DTRPED'))		+ '</EndReportDateTime>'
		 //	cXMLRet += '<EndReportDateTime>'   			+ oModel:GetValue("CYVMASTER", 'CYV_HRRPED'	)	  			+ '</EndReportDateTime>'
		 //	cXMLRet += '<ReportDateTime>'  				+ SFCXXtoS(oModel:GetValue("CYVMASTER", 'CYV_DTRP'))		+ '</ReportDateTime>'
		 //	cXMLRet += '<ReportDateTime>'				+ oModel:GetValue("CYVMASTER", 'CYV_HRRP')		  			+ '</ReportDateTime>'

			// Refugo
			cXMLRet += '<ListOfWasteAppointments>'
				For nI := 1 To oModelCY0:Length()
					oModelCY0:GoLine( nI )

				   	If !oModelCY0:IsDeleted()
				   		cXMLRet += '<WasteAppointment>'
				   			cXMLRet += '<ReportSequence>'		+ oModel:GetValue("CYVMASTER", 'CYV_NRSQRP') 		+ '</ReportSequence>'
							cXMLRet += '<WasteCode>'			+ oModelCY0:GetValue('CY0_CDRF') 					+ '</WasteCode>'
							cXMLRet += '<WasteDescription>'		+ oModelCY0:GetValue('CY0_DSRF') 					+ '</WasteDescription>'
							cXMLRet += '<ScrapQuantity>'		+ SFCXXtoS(oModelCY0:GetValue('CY0_QTRF'))			+ '</ScrapQuantity>'
							cXMLRet += '<ReworkQuantity>' 		+ SFCXXtoS(oModelCY0:GetValue('CY0_QTRT'))			+ '</ReworkQuantity>'
				   		cXMLRet += '</WasteAppointment>'
				   	EndIf
				Next
			cXMLRet += '</ListOfWasteAppointments>'

			// Recurso
			cXMLRet += '<ListOfResourceAppointments>'
				For nI := 1 To oModelCYW:Length()
					oModelCYW:GoLine( nI )

				   	If !oModelCYW:IsDeleted()
				   		cXMLRet += '<ResourceAppointment>'
							cXMLRet += '<ReportSequence>'		+ oModel:GetValue("CYVMASTER", 'CYV_NRSQRP')   		+ '</ReportSequence>'
							cXMLRet += '<OperatorID>'			+ oModelCYW:GetValue('CYW_IDOE') 			   		+ '</OperatorID>'
							cXMLRet += '<OperatorCode>'			+ oModelCYW:GetValue('CYW_CDOE') 			   		+ '</OperatorCode>'
							cXMLRet += '<OperatorName>'			+ oModelCYW:GetValue('CYW_NMOE') 			   		+ '</OperatorName>'
							cXMLRet += '<ProductionTeamCode>'	+ oModelCYW:GetValue('CYW_CDGROE') 			   		+ '</ProductionTeamCode>'
							cXMLRet += '<StartCentTime>'   		+ SFCXXtoS(oModelCYW:GetValue('CYW_HCBGRP'))   		+ '</StartCentTime>'
							cXMLRet += '<EndCentTime>' 			+ SFCXXtoS(oModelCYW:GetValue('CYW_HCEDRP'))   		+ '</EndCentesimalTime>'
							cXMLRet += '<MOBTime>'	  			+ SFCXXtoS(oModelCYW:GetValue('CYW_QTTEOE'))		+ '</MOBTime>'
							cXMLRet += '<ExtraTime>'	  		+ SFCXXtoS(oModelCYW:GetValue('CYW_QTTEEX'))		+ '</ExtraTime>'
							cXMLRet += '<UtilTime>'	  	   		+ SFCXXtoS(oModelCYW:GetValue('CYW_QTTEUT'))		+ '</UtilTime>'
							cXMLRet += '<ProductionShiftCode>'	+ oModelCYW:GetValue('CYW_CDTN') 					+ '</ProductionShiftCode>'
							cXMLRet += '<ProductionShiftNumber>'+ oModelCYW:GetValue('CYW_NRTN') 					+ '</ProductionShiftNumber>'

				         // DateTime - Verificar
				         // cXMLRet += '<StartDateTime>'	 	+ SFCXXtoS(oModelCYW:GetValue('CYW_DTBGRP'))   		+ '</StartDateTime>'
				         // cXMLRet += '<StartDateTime>'		+ oModelCYW:GetValue('CYW_HRBGRP') 			   		+ '</StartDateTime>'
				         // cXMLRet += '<EndDateTime>'	  		+ SFCXXtoS(oModelCYW:GetValue('CYW_DTEDRP'))   		+ '</EndDateTime>'
 					     // cXMLRet += '<EndDateTime>'			+ oModelCYW:GetValue('CYW_HREDRP') 			   		+ '</EndDateTime>'
				   		cXMLRet += '</ResourceAppointment>'
				   	EndIf
				Next
			cXMLRet += '</ListOfResourceAppointments>'

			// Reserva da Ordem
			cXMLRet += '<ListOfSupplyOrders>'
				For nI := 1 To oModelCZP:Length()
					oModelCZP:GoLine( nI )

				   	If !oModelCZP:IsDeleted()
				   		cXMLRet += '<SupplyOrder>'
							cXMLRet += '<ReportSequence>'			+ oModel:GetValue("CYVMASTER", 'CYV_NRSQRP') 	+ '</ReportSequence>'
							cXMLRet += '<ProductionOrderNumber>' 	+ oModelCZP:GetValue('CZP_NRORPO') 				+ '</ProductionOrderNumber>'
							cXMLRet += '<MaterialCode>' 			+ oModelCZP:GetValue('CZP_CDMT') 				+ '</MaterialCode>'
							cXMLRet += '<MaterialDescription>'		+ oModelCZP:GetValue('CZP_DSMT') 				+ '</MaterialDescription>'
							cXMLRet += '<ReferenceCode>'   			+ oModelCZP:GetValue('CZP_CDRE') 				+ '</ReferenceCode>'
							cXMLRet += '<UsedQuantity>'				+ SFCXXtoS(oModelCZP:GetValue('CZP_QTRPPO'))	+ '</UsedQuantity>'
							cXMLRet += '<ApprovedQuantity>'			+ SFCXXtoS(oModelCZP:GetValue('CZP_QTRP'))		+ '</ApprovedQuantity>'
							cXMLRet += '<UnitOfMeasureCode>'		+ oModelCZP:GetValue('CZP_CDUN') 				+ '</UnitOfMeasureCode>'
							cXMLRet += '<FatherItemCode>'			+ oModelCZP:GetValue('CZP_CDACPI') 				+ '</FatherItemCode>'
							cXMLRet += '<FatherItemDescription>'	+ oModelCZP:GetValue('CZP_DSACPI') 				+ '</FatherItemDescription>'
							cXMLRet += '<WarehouseCode>'			+ oModelCZP:GetValue('CZP_CDDP') 				+ '</WarehouseCode>'
							cXMLRet += '<LocationCode>'				+ oModelCZP:GetValue('CZP_CDLC') 				+ '</LocationCode>'
							cXMLRet += '<LotCode>'			   		+ oModelCZP:GetValue('CZP_CDLO') 				+ '</LotCode>'
							cXMLRet += '<ActivityCode>'		   		+ oModelCZP:GetValue('CZP_CDAT') 				+ '</ActivityCode>'
							cXMLRet += '<ScriptCode>'				+ oModelCZP:GetValue('CZP_CDRT') 				+ '</ScriptCode>'
							cXMLRet += '<SiteCode>'					+ oModelCZP:GetValue('CZP_CDES') 				+ '</SiteCode>'
							cXMLRet += '<MaterialDate>'				+ SFCXXtoS(oModelCZP:GetValue('CZP_DTMT'))		+ '</MaterialDate>'
							cXMLRet += '<MaterialQuantity>'			+ SFCXXtoS(oModelCZP:GetValue('CZP_QTMT'))		+ '</MaterialQuantity>'
							cXMLRet += '<StatusType>'				+ oModelCZP:GetValue('CZP_TPST') 				+ '</StatusType>'
							cXMLRet += '<OrderProcess>'				+ oModelCZP:GetValue('CZP_CDTBMT') 				+ '</OrderProcess>'
							cXMLRet += '<ReferenceOrderNumber>'		+ oModelCZP:GetValue('CZP_NRORRE') 				+ '</ReferenceOrderNumber>'
							cXMLRet += '<MaterialID>'				+ oModelCZP:GetValue('CZP_IDMTOR') 				+ '</MaterialID>'
				   		cXMLRet += '</SupplyOrder>'
				   	EndIf
				Next
			cXMLRet += '</ListOfSupplyOrders>'

			// Apontamento Ferramenta
			cXMLRet += '<ListOfReportToolActivities>'
				For nI := 1 To oModelCZ0:Length()
					oModelCZ0:GoLine( nI )

				   	If !oModelCZ0:IsDeleted()
				   		cXMLRet += '<ReportToolActivity>'
							cXMLRet += '<ReportSequence>'			+ oModel:GetValue("CYVMASTER", 'CYV_NRSQRP') 	+ '</ReportSequence>'
			   				cXMLRet += '<ToolCode>' 				+ oModelCZ0:GetValue('CZ0_CDFE') 				+ '</ToolCode>'
			   				cXMLRet += '<ToolDescription>' 			+ oModelCZ0:GetValue('CZ0_DSFE') 				+ '</ToolDescription>'
							cXMLRet += '<OperationUnitTime>'		+ SFCXXtoS(oModelCZ0:GetValue('CZ0_QTTEUN'))	+ '</OperationUnitTime>'
				   		cXMLRet += '</ReportToolActivity>'
				   	EndIf
				Next
			cXMLRet += '</ListOfReportToolActivities>'

			// Apontamento GGF
			cXMLRet += '<ListOfReportOverheads>'
				For nI := 1 To oModelCZW:Length()
					oModelCZW:GoLine( nI )

				   	If !oModelCZW:IsDeleted()
				   		cXMLRet += '<ReportOverhead>'
							cXMLRet += '<ReportSequence>'			+ oModel:GetValue("CYVMASTER", 'CYV_NRSQRP') 	+ '</ReportSequence>'
				   			cXMLRet += '<WorkCenterCode>' 			+ oModelCZW:GetValue('CZW_CDCETR') 				+ '</WorkCenterCode>'
				  			cXMLRet += '<WorkCenterDescription>' 	+ oModelCZW:GetValue('CZW_DSCETR') 				+ '</WorkCenterDescription>'
							cXMLRet += '<GGFTimeInt>'	 	  		+ SFCXXtoS(oModelCZW:GetValue('CZW_QTTEGF'))	+ '</GGFTimeInt>'
							cXMLRet += '<GGFTimeDec>'	  	  		+ SFCXXtoS(oModelCZW:GetValue('CZW_HRTEGF'))	+ '</GGFTimeDec>'
				   		cXMLRet += '</ReportOverhead>'
				   	EndIf
				Next
			cXMLRet += '</ListOfReportOverheads>'

        EndIf

      cXMLRet += '</BusinessContent>'

EndIf

RestArea(aAreaCYV)
RestArea(aArea) */

Return { lRet, cXMLRet }

Function INTDF_A314( cXML, nTypeTrans, cTypeMessage )
Return INTEGDEF(cXml, nTypeTrans, cTypeMessage)




/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥ ShowF4   ≥ Autor ≥ Michelle Ramos ≥ Data ≥ 13/03/2018     ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Chamada da funcao F4                                       ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ Nenhum/nao utilizados									  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno   ≥ Retorna o lote selecionado                                 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ SFCA314F4                                                  ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Static Function SFCA314F4(a,b,c)
Local aArea		:=GetArea()
local oModel
local cCampo 	:= ""
local cLocal	:= ""

oModel := FWModelActive()
oModelCZP := oModel:GetModel("CZPDETAIL")
cProduto  := oModelCZP:GetValue("CZP_CDMT")
cLocal    := oModelCZP:GetValue("CZP_CDDP")

dbSelectArea("SB1")
DbSetOrder(1)
DbSeek( xFilial("SB1") + cProduto )

If ("CZP_CDLC" $ ReadVar())
	F4Localiz(,,,'A314', cProduto,cLocal,, ReadVar())
Else
	F4Lote(,,,'SFCA310',cProduto,SB1->B1_LOCPAD,NIL,NIL,2,,,.F.,@cCampo)
	FwFldPut( "CZP_CDLO" , cCampo,,,,.T. )
EndIf

M->CZP_CDLO:=cCampo

dbCloseArea("SB1")
RestArea(aArea)

Return NIL


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥ ShowF4   ≥ Autor ≥ Michelle Ramos ≥ Data ≥ 13/03/2018     ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Chamada da funcao F8                                       ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ Nenhum/nao utilizados									  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno   ≥ Abrir a tela de consulta de saldo do produto               ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ SFCA314F4                                                  ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Static Function SFCA314F8()
Local aArea:=GetArea()
local oModel
local cCampo:= ""
local acurpos

oModel := FWModelActive()
oModelCZP := oModel:GetModel("CZPDETAIL")
cProduto  := oModelCZP:GetValue("CZP_CDMT")

MaViewSB2(cProduto)


Return NIL

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥ ErroTelnet ≥ Autor ≥ Marcos Wagner Jr ≥ Data ≥ 20/03/2020  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Apresenta na Telnet o erro encontrado no MostraErro()      ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ Nenhum/nao utilizados									  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno   ≥ Abrir a tela de consulta de saldo do produto               ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ SFCA314F4                                                  ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Function ErroTelnet()
Local cLog  := ''
Local nI    := 1
Local aErro := {}
Local aShow := {}
Default lAutomacao := .F.

aErro := GetAutoGRLog()

For nI := 1 To Len( aErro )-3 //Para n„o sobrar o 'lixo' do final da mensagem
	
	If (Len(cLog) + Len(AllTrim(aErro[nI]) + CRLF)) > 120
		AADD(aShow,cLog)
		cLog := ' '
	EndIf

	cLog += AllTrim(aErro[nI]) + CRLF

Next nI

AADD(aShow,cLog)

For nI := 1 to Len(aShow)
	If !lAutomacao
		VTAlert(aShow[nI],,.t.)
	EndIf
Next
//conout("conout"+cLog)

Return .t.

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥ VerUlFchto ≥ Autor ≥ Marcos Wagner Jr ≥ Data ≥ 08/05/2020  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Apresenta na Telnet o erro encontrado no MostraErro()      ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ Nenhum/nao utilizados									  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ SFCA314F4                                                  ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Function VerUlFchto()
Local lRet      := .T.
Local dDataFec  := MVUlmes()

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Verificar data do ultimo fechamento em SX6.                  ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
If dDataFec >= dDataBase
	If !IsTelNet()
		Help ( " ", 1, "FECHTO" )
	Else
		cMsg := STR0126 //"Nao pode ser digitado movimento com data anterior a ultima data de fechamento (virada de saldos)."
		VTAlert(cMsg,,.t.)
		cMsg := STR0127 //"Utilizar data posterior ao ultimo fechamento de estoque (MV_ULMES) / posterior a data do bloqueio de movimentos (MV_DBLQMOV)."
		VTAlert(cMsg,,.t.)
	EndIf
	lRet := .F.
EndIf

Return lRet

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÖo    ≥ ErroTelnet ≥ Autor ≥ Marcos Wagner Jr ≥ Data ≥ 20/03/2020  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥ Apresenta na Telnet o erro encontrado no MostraErro()      ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ Nenhum/nao utilizados									  ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Retorno   ≥ Abrir a tela de consulta de saldo do produto               ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso      ≥ SFCA314F4                                                  ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Function ErroPost()
Local nCount    := 0
Local aErroAuto := {}
Local cLogErro  := ""

aErroAuto := GetAutoGRLog()
For nCount := 1 To Len(aErroAuto)
	//Retorna somente a mensagem de erro (Help) e o valor que est· inv·lido, sem quebras de linha e sem tags '<>'
	cLogErro += StrTran( StrTran( StrTran( StrTran( StrTran( aErroAuto[nCount], "/", "" ), "<", "" ), ">", "" ), CHR(10), " "), CHR(13), "") + ("|")
Next nCount

Return cLogErro

Static Function SFCA314IF(oModel, nInd)
	//nInd - indicador
	//1 - apontamento de inicio via REST/EXECAUTO
	//2 - apontamento fim via REST/EXECAUTO
	//3 - apontamento abandonar via REST/EXECAUTO
	//4 - apontamento fim via REST/EXECAUTO -- consistencia de informaÁıes especÌficas 
	
	Local lRet := .F.
	Local lExecut := .F.

	If ( Type( 'lExAutSFC' ) == 'L' )
		lExecut := lExAutSFC
	EndIf
	
	If !IsInCallStack('POST_SFCA314') .And. !lExecut
		Return lRet
	Else
		lExecut := .T.
	EndIf

	If !( Type( 'cTipApon' ) == 'C' )
		Return lRet
	EndIf

	If nInd == 1
		If lExecut .And. oModel:GetOperation() == 3 .And. cTipApon == 'I'
			lRet := .T.
		EndIf
	EndIf

	If nInd == 2
		If lExecut .And. oModel:GetOperation() == 4 .And. cTipApon == 'F'
			lRet := .T.
		EndIf
	EndIf

	If nInd == 3
		If lExecut .And. oModel:GetOperation() == 4 .And. cTipApon == 'A'
			lRet := .T.
		EndIf
	EndIf

	If nInd == 4
		If lExecut .And. oModel:GetOperation() == 4 .And. cTipApon == 'F'
			lRet := .T.
		EndIf
	EndIf

Return lRet

Static Function Val2Hora(nValor, cSepar)
	Local cHora := ""
	Local cMinutos := ""
	Default cSepar := ":"
	Default nValor := -1
	
	//Se for valores negativos, retorna a hora atual
	If nValor < 0
		cHora := SubStr(Time(), 1, 5)
		cHora := StrTran(cHora, ':', cSepar)
		
	//Sen„o, transforma o valor numÈrico
	Else
		cHora := Alltrim(Transform(nValor, "@E 99.99"))
		
		//Se o tamanho da hora for menor que 5, adiciona zeros a esquerda
		If Len(cHora) < 5
			cHora := Replicate('0', 5-Len(cHora)) + cHora
		EndIf
		
		//Fazendo tratamento para minutos
		cMinutos := SubStr(cHora, At(',', cHora)+1, 2)
		cMinutos := StrZero((Val(cMinutos)*60)/100, 2)
		
		//Atualiza a hora com os novos minutos
		cHora := SubStr(cHora, 1, At(',', cHora))+cMinutos
		
		//Atualizando o separador
		cHora := StrTran(cHora, ',', cSepar)
	EndIf
	
Return cHora

/*/{Protheus.doc} SFCA314KEY
	Seta valores nas keys
	@type  Function
	@author mauricio.joao
	@since 20/06/2022
	@version 12.1.33
	/*/
Function SFCA314KEY()

	SetKey(VK_F4, {|| SFCA314F4()})
	SetKey(VK_F8, {|| SFCA314F8()})
	
Return .T.


