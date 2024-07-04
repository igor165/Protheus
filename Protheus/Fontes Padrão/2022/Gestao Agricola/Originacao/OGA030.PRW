#INCLUDE "OGA030.ch"
#include "protheus.ch"
#include "fwmbrowse.ch"
#include "fwmvcdef.ch"

/** {Protheus.doc} OGA030
Rotina para cadastro de indices de mercado

@param: 	Nil
@author: 	Bruna Fagundes Rocio
@since: 	11/10/2013
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function OGA030()
Local oMBrowse

oMBrowse := FWMBrowse():New()
oMBrowse:SetAlias( "NJV" )
oMBrowse:SetDescription( STR0001 ) //"Produto Adicional"
oMBrowse:Activate()

Return()

/** {Protheus.doc} MenuDef
Função que retorna os itens para construção do menu da rotina

@param: 	Nil
@return:	aRotina - Array com os itens do menu
@author: 	Bruna Fagundes Rocio
@since: 	11/10/2013
@Uso: 		OGA030 - Produtos Adicionais
*/

Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0002 , 'PesqBrw'        , 0, 1, 0, .T. } ) //'Pesquisar'
aAdd( aRotina, { STR0003, 'ViewDef.OGA030', 0, 2, 0, Nil } ) //'Visualizar'
aAdd( aRotina, { STR0004   , 'ViewDef.OGA030', 0, 3, 0, Nil } ) //'Incluir'
aAdd( aRotina, { STR0005   , 'ViewDef.OGA030', 0, 4, 0, Nil } ) //'Alterar'
aAdd( aRotina, { STR0006   , 'ViewDef.OGA030', 0, 5, 0, Nil } ) //'Excluir'
aAdd( aRotina, { STR0007  , 'ViewDef.OGA030', 0, 8, 0, Nil } ) //'Imprimir'
aAdd( aRotina, { STR0008    , 'ViewDef.OGA030', 0, 9, 0, Nil } ) //'Copiar'

Return aRotina

/** {Protheus.doc} ModelDef
Função que retorna o modelo padrao para a rotina

@param: 	Nil
@return:	oModel - Modelo de dados
@author: 	Bruna Fagundes Rocio
@since: 	11/10/2013
@Uso: 		OGA030 - Produtos Adicionais
*/
Static Function ModelDef()
Local oStruNJV := FWFormStruct( 1, "NJV" )
Local oModel := MPFormModel():New( "OGA030M" )

oModel:AddFields( 'NJVUNICO', Nil, oStruNJV )
oModel:SetDescription( STR0009 ) //'Produtos Adicionais'
oModel:GetModel( 'NJVUNICO' ):SetDescription( STR0010 ) //'Dados dos Produtos Adicionais'

Return oModel


/** {Protheus.doc} ViewDef
Função que retorna a view para o modelo padrao da rotina

@param: 	Nil
@return:	oView - View do modelo de dados
@author: 	Bruna Fagundes Rocio
@since: 	11/10/2013
@Uso: 		OGA030 - Produtos Adicionais
*/
Static Function ViewDef()
Local oStruNJV := FWFormStruct( 2, 'NJV' )
Local oModel   := FWLoadModel( 'OGA030' )
Local oView    := FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_NJV', oStruNJV, 'NJVUNICO' )
oView:CreateHorizontalBox( 'UM'  , 100 )
oView:SetOwnerView( 'VIEW_NJV', 'UM'   )

Return oView