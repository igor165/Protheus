#INCLUDE "OGA140.ch"
#include "protheus.ch"
#include "fwmvcdef.ch"


/** {Protheus.doc} OGA140
Rotina para cadastro de motivos alteração quantidade em contrato

@param: 	Nil
@author: 	Bruna Rocio
@since: 	08/06/2010
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function OGA140()
Local oMBrowse	:= Nil

oMBrowse := FWMBrowse():New()
oMBrowse:SetAlias( "NNQ" )
oMBrowse:SetDescription( STR0001 ) //"Motivos Alteração Quantidade em Contrato"
oMBrowse:DisableDetails()
oMBrowse:Activate()

Return( Nil )


/** {Protheus.doc} MenuDef
Função que retorna os itens para construção do menu da rotina

@param: 	Nil
@return:	aRotina - Array com os itens do menu
@author: 	Equipe Agroindústria
@since: 	07/07/2015
@Uso: 		OGA140 - Motivos Alteração Quantidade em Contrato
*/
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0002 , "PesqBrw"        , 0, 1, 0, .T. } ) //"Pesquisar"
aAdd( aRotina, { STR0003, "ViewDef.OGA140", 0, 2, 0, Nil } ) //"Visualizar"
aAdd( aRotina, { STR0004   , "ViewDef.OGA140", 0, 3, 0, Nil } ) //"Incluir"
aAdd( aRotina, { STR0005   , "ViewDef.OGA140", 0, 4, 0, Nil } ) //"Alterar"
aAdd( aRotina, { STR0006   , "ViewDef.OGA140", 0, 5, 0, Nil } ) //"Excluir"
aAdd( aRotina, { STR0007  , "ViewDef.OGA140", 0, 8, 0, Nil } ) //"Imprimir"
aAdd( aRotina, { STR0008    , "ViewDef.OGA140", 0, 9, 0, Nil } ) //"Copiar"

Return( aRotina )


/** {Protheus.doc} ModelDef
Função que retorna o modelo padrao para a rotina

@param: 	Nil
@return:	oModel - Modelo de dados
@author: 	Equipe Agroindústria
@since: 	07/07/2015
@Uso: 		OGA140 - Motivos Alteração Quantidade em Contrato
*/

Static Function ModelDef()
Local oStruNNQ := FWFormStruct( 1, "NNQ" )
Local oModel := MPFormModel():New( "OGA140" )

oModel:AddFields( "NNQUNICO", Nil, oStruNNQ )
oModel:SetDescription( STR0009  ) //"Motivo Alteração Contrato"
oModel:GetModel( "NNQUNICO" ):SetDescription( STR0010  ) //"Dados do Motivo Alteração"

Return( oModel )


/** {Protheus.doc} ViewDef
Função que retorna a view para o modelo padrao da rotina

@param: 	Nil
@return:	oView - View do modelo de dados
@author: 	Equipe Agroindústria
@since: 	07/07/2015
@Uso: 		OGA140 - Motivos Alteração Quantidade em Contrato
*/
Static Function ViewDef()
Local oStruNNQ := FWFormStruct( 2, "NNQ" )
Local oModel   := FWLoadModel( "OGA140" )
Local oView    := FWFormView():New()

oView:SetModel( oModel )
oView:AddField( "VIEW_NNQ", oStruNNQ, "NNQUNICO" )
oView:CreateHorizontalBox( "UM"  , 100 )
oView:SetOwnerView( "VIEW_NNQ", "UM"   )

oView:SetCloseOnOk( {||.t.} )

Return( oView )
