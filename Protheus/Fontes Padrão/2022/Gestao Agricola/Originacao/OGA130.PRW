#INCLUDE "OGA130.ch"
#include "protheus.ch"
#include "fwmvcdef.ch"


/** {Protheus.doc} OGA130
Rotina para cadastro de espécies de variedades de grãos

@param: 	Nil
@author: 	Bruna Rocio
@since: 	08/06/2010
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function OGA130()
Local oMBrowse	:= Nil

oMBrowse := FWMBrowse():New()
oMBrowse:SetAlias( "NJT" )
oMBrowse:SetDescription( STR0001 ) //"Tipos de Despesas"
oMBrowse:DisableDetails()
oMBrowse:Activate()

Return( Nil )


/** {Protheus.doc} MenuDef
Função que retorna os itens para construção do menu da rotina

@param: 	Nil
@return:	aRotina - Array com os itens do menu
@author: 	Bruna Rocio
@since: 	08/06/2010
@Uso: 		OGA130 - Espécies
*/
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0002 , "PesqBrw"        , 0, 1, 0, .T. } ) //"Pesquisar"
aAdd( aRotina, { STR0003, "ViewDef.OGA130", 0, 2, 0, Nil } ) //"Visualizar"
aAdd( aRotina, { STR0004   , "ViewDef.OGA130", 0, 3, 0, Nil } ) //"Incluir"
aAdd( aRotina, { STR0005   , "ViewDef.OGA130", 0, 4, 0, Nil } ) //"Alterar"
aAdd( aRotina, { STR0006   , "ViewDef.OGA130", 0, 5, 0, Nil } ) //"Excluir"
aAdd( aRotina, { STR0007  , "ViewDef.OGA130", 0, 8, 0, Nil } ) //"Imprimir"
aAdd( aRotina, { STR0008    , "ViewDef.OGA130", 0, 9, 0, Nil } ) //"Copiar"

Return( aRotina )


/** {Protheus.doc} ModelDef
Função que retorna o modelo padrao para a rotina

@param: 	Nil
@return:	oModel - Modelo de dados
@author: 	Bruna Rocio
@since: 	08/06/2010
@Uso: 		OGA130 - Espécies
*/
Static Function ModelDef()
Local oStruNJT := FWFormStruct( 1, "NJT" )
Local oModel := MPFormModel():New( "OGA130", , )

oModel:AddFields( "NJTUNICO", Nil, oStruNJT )
oModel:SetDescription( STR0009 ) //"Tipo da Despesa"
oModel:GetModel( "NJTUNICO" ):SetDescription( STR0010 ) //"Dados do Tipo da Despesa"

Return( oModel )


/** {Protheus.doc} ViewDef
Função que retorna a view para o modelo padrao da rotina

@param: 	Nil
@return:	oView - View do modelo de dados
@author: 	Bruna Rocio
@since: 	08/06/2010
@Uso: 		OGA130 - Espécies
*/
Static Function ViewDef()
Local oStruNJT := FWFormStruct( 2, "NJT" )
Local oModel   := FWLoadModel( "OGA130" )
Local oView    := FWFormView():New()

oView:SetModel( oModel )
oView:AddField( "VIEW_NJT", oStruNJT, "NJTUNICO" )
oView:CreateHorizontalBox( "UM"  , 100 )
oView:SetOwnerView( "VIEW_NJT", "UM"   )

oView:SetCloseOnOk( {||.t.} )

Return( oView )