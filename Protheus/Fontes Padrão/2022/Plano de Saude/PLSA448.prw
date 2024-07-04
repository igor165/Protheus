#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH' //Necessita desse include quando usar MVC.
#include "dbtree.ch"
#include "plsa448.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณ PLSA448  บ Autor ณEverton M. Fernandesบ Data ณ  03/05/2013 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricaoณ Fun็ใo voltada para Cadastro de Campos Adicionais TISS     ณฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ PLSA448                                                    ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PLSA448()
Local oBrowse

Private cChv444 := ""

If !FWAliasInDic("BTP", .F.)
	MsgAlert(STR0005) //"Para esta funcionalidade ้ necessแrio executar os procedimentos referente ao chamado: THQGIW"
	Return()
EndIf

// Instanciamento da Classe de Browse
oBrowse := FWMBrowse():New()

// Defini็ใo da tabela do Browse
oBrowse:SetAlias('BTP')

// Titulo da Browse
oBrowse:SetDescription(STR0001)

// Ativa็ใo da Classe
oBrowse:Activate()

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณ ModelDef บ Autor ณEverton M. Fernandesบ Data ณ  03/05/2013 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricaoณ Define o modelo de dados da aplica็ใo                      ณฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ PLSA448                                                    ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ModelDef()
// Cria as estruturas a serem usadas no Modelo de Dados
Local oStruBTP := FWFormStruct( 1, 'BTP' )
Local oStruBTQ := FWFormStruct( 1, 'BTQ' )

Local oModel // Modelo de dados construํdo

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'PLSA448' )

// Adiciona ao modelo um componente de formulแrio
oModel:AddFields( 'BTPMASTER', /*cOwner*/, oStruBTP )

// Adiciona ao modelo uma componente de grid

oStruBTQ:SetProperty('BTQ_CODTAB',MODEL_FIELD_INIT, {|| BTP_CODTAB})
oModel:AddGrid( 'BTQDETAIL', 'BTPMASTER', oStruBTQ)
oModel:GetModel('BTQDETAIL'):SetUniqueLine( { "BTQ_FILIAL", "BTQ_CODTAB", "BTQ_CDTERM", "BTQ_VIGDE" } )




// Faz relacionamento entre os componentes do model
oModel:SetRelation( 'BTQDETAIL', { { 'BTQ_FILIAL', 'xFilial( "BTQ" )'},;
       									{ 'BTQ_CODTAB', 'BTP_CODTAB' } }, BTQ->( IndexKey( 1 ) ) )

// Adiciona a descri็ใo dos Componentes do Modelo de Dados
oModel:GetModel( 'BTPMASTER' ):SetDescription( STR0003 )
oModel:GetModel( 'BTQDETAIL' ):SetDescription( STR0004 )

//Permite gravar apenas a tabela BTP
oModel:GetModel('BTQDETAIL'):SetOptional(.T.)

//Permite gravar apenas a tabela BTP
oModel:GetModel('BTPMASTER'):SetOnlyView(.T.)

// Retorna o Modelo de dados
Return oModel

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบ Programa ณ ViewDef  บ Autor ณEverton M. Fernandesบ Data ณ  03/05/2013 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบ Descricaoณ Define o modelo de dados da aplica็ใo                      ณฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ PLSA448                                                    ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ViewDef()
// Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado
Local oModel := FWLoadModel( 'PLSA448' )

// Cria as estruturas a serem usadas na View
Local oStruBTP := FWFormStruct( 2, 'BTP' )
Local oStruBTQ := FWFormStruct( 2, 'BTQ' )

// Interface de visualiza็ใo construํda
Local oView

//Retira o campo c๓digo da tela
oStruBTQ:RemoveField('BTQ_CODTAB')

// Cria o objeto de View
oView := FWFormView():New()

// Define qual Modelo de dados serแ utilizado
oView:SetModel( oModel )

// Adiciona no nosso View um controle do tipo formulแrio (antiga Enchoice)
oView:AddField( 'VIEW_BTP', oStruBTP, 'BTPMASTER' )

//Adiciona no nosso View um controle do tipo Grid (antiga Getdados)
oView:AddGrid( 'VIEW_BTQ', oStruBTQ, 'BTQDETAIL' )

// Cria um "box" horizontal para receber cada elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 20 )
oView:CreateHorizontalBox( 'INFERIOR', 80 )

// Relaciona o identificador (ID) da View com o "box" para exibi็ใo
oView:SetOwnerView( 'VIEW_BTP', 'SUPERIOR' )
oView:SetOwnerView( 'VIEW_BTQ', 'INFERIOR' )

// Criar novo botao na barra de botoes
oView:AddUserButton( 'Manuten็ใo (BTQ)', 'BMPGROUP',  { |oView| PLSITBTQ() } ) 

// Retorna o objeto de View criado
Return oView
