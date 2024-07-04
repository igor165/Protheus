#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWEditPanel.CH"
#INCLUDE "VEIA240.CH" // mesmo CH do VEIA240

Function VEIA241()

Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription(STR0001) // Pacote de Configuração
oBrowse:SetAlias('VN0')
oBrowse:AddLegend( 'VN0_STATUS=="0"' , 'BR_BRANCO'   , STR0002 ) // Pendente
oBrowse:AddLegend( 'VN0_STATUS=="1"' , 'BR_VERDE'    , STR0003 ) // Ativado
oBrowse:AddLegend( 'VN0_STATUS=="2"' , 'BR_VERMELHO' , STR0004 ) // Desativado
oBrowse:Activate()

Return

Static Function MenuDef()

Local aRotina := {}

aRotina := FWMVCMenu('VEIA241')

ADD OPTION aRotina TITLE STR0008 ACTION 'VEIA244()' OPERATION 4 ACCESS 0 // Replicar Custo/Frete
ADD OPTION aRotina TITLE STR0009 ACTION 'VEIA250( VN0->VN0_CODMAR , VN0->VN0_MODVEI , VN0->VN0_SEGMOD )' OPERATION 4 ACCESS 0 // Cadastro de Markup/Desconto
ADD OPTION aRotina TITLE STR0010 ACTION 'VA2400171_EnviarEmail(.t.,.t.)' OPERATION 9 ACCESS 0 // Enviar e-mail de alteração na Lista de Preços dos Pacotes

Return aRotina

Static Function ModelDef()
Local oModel
Local oStrVN0 := FWFormStruct(1, "VN0")
Local oStrVN1 := FWFormStruct(1, "VN1")
Local oStrVN2 := FWFormStruct(1, "VN2")

oModel := MPFormModel():New('VEIA241',;
/*Pré-Validacao*/,;
/*Pós-Validacao*/,;
/*Confirmacao da Gravação*/,;
/*Cancelamento da Operação*/)

oModel:AddFields('VN0MASTER',/*cOwner*/ 	, oStrVN0)
oModel:AddGrid('VN1DETAIL'	,'VN0MASTER'	, oStrVN1, /* <bLinePre > */ , /* <bLinePost > */ , /* <bPre > */ , /* <bLinePos > */ , /* <bLoad> */ )
oModel:AddGrid('VN2DETAIL'	,'VN0MASTER'	, oStrVN2, /* <bLinePre > */ , /* <bLinePost > */ , /* <bPre > */ , /* <bLinePos > */ , /* <bLoad> */ )

oModel:GetModel("VN2DETAIL"):SetNoDeleteLine( .T. )

oModel:SetRelation( 'VN1DETAIL', { { 'VN1_FILIAL', 'xFilial( "VN1" )' }, { 'VN1_CODVN0', 'VN0_CODIGO' } }, VN1->( IndexKey( 1 ) ) )
oModel:SetRelation( 'VN2DETAIL', { { 'VN2_FILIAL', 'xFilial( "VN2" )' }, { 'VN2_CODVN0', 'VN0_CODIGO' } }, VN2->( IndexKey( 1 ) ) )

oModel:SetPrimaryKey( { "VN0_FILIAL", "VN0_CODIGO" } )
oModel:SetDescription(STR0001) // Pacote de Configuração
oModel:GetModel('VN0MASTER'):SetDescription(STR0033) // Informações do Pacote de Configuração
oModel:GetModel('VN1DETAIL'):SetDescription(STR0034) // Itens do Pacote de Configuração
oModel:GetModel('VN2DETAIL'):SetDescription(STR0035) // Custo do Pacote de Configuração

//oModel:InstallEvent("VEIA241LOG", /*cOwner*/, MVCLOGEV():New("VEIA241") ) // CONSOLE.LOG para verificar as chamadas dos eventos
oModel:InstallEvent("VEIA241EVDEF", /*cOwner*/, VEIA241EVDEF():New("VEIA241") )

Return oModel

Static Function ViewDef()

	Local oView
	Local oModel := ModelDef()
	Local oStrVN0:= FWFormStruct(2, "VN0")
	Local oStrVN1:= FWFormStruct(2, "VN1")
	Local oStrVN2:= FWFormStruct(2, "VN2")

	oStrVN0:RemoveField('VN0_DATINC')
	oStrVN0:RemoveField('VN0_DATALT')
	oStrVN0:RemoveField('VN0_CHVOPC')

	oStrVN1:RemoveField('VN1_CODIGO')
	oStrVN1:RemoveField('VN1_CODVN0')
	oStrVN1:RemoveField('VN1_CODVQC')
	oStrVN1:RemoveField('VN1_CODVQD')
	oStrVN1:RemoveField('VN1_DATINC')
	oStrVN1:RemoveField('VN1_DATALT')

	oStrVN2:RemoveField('VN2_CODIGO')
	oStrVN2:RemoveField('VN2_CODVN0')
	oStrVN2:RemoveField('VN2_DATINC')
	oStrVN2:RemoveField('VN2_DATALT')

	oView := FWFormView():New()

	oView:SetModel(oModel)

	oView:CreateHorizontalBox( 'BOXVN0', 45)
	oView:AddField('VIEW_VN0', oStrVN0, 'VN0MASTER')
	oView:EnableTitleView('VIEW_VN0', STR0036 ) // Dados do Pacote de Configuração
	oView:SetOwnerView('VIEW_VN0','BOXVN0')

	oView:CreateHorizontalBox( 'VN1VN2', 55)

	oView:CreateFolder( 'ABAS', 'VN1VN2' )

	oView:AddSheet( 'ABAS', 'ABA_VN1', STR0034 ) // Itens do Pacote de Configuração
	oView:CreateHorizontalBox( 'BOX_VN1' , 100,,, 'ABAS', 'ABA_VN1' )
	oView:AddGrid("VIEW_VN1",oStrVN1, 'VN1DETAIL')
	oView:SetOwnerView('VIEW_VN1','BOX_VN1')

	oView:AddSheet( 'ABAS', 'ABA_VN2', STR0035 ) // Custo do Pacote de Configuração
	oView:CreateHorizontalBox( 'BOX_VN2' , 100,,, 'ABAS', 'ABA_VN2' )
	oView:AddGrid("VIEW_VN2",oStrVN2, 'VN2DETAIL')
	oView:SetOwnerView('VIEW_VN2','BOX_VN2')

Return oView