#INCLUDE "OGA400.ch"
#include "protheus.ch"
#include "fwmvcdef.ch"


/** {Protheus.doc} OGA400 
Rotina para cadastro de Modalidades de variedades de grãos

@param: 	Nil
@author: 	Bruna Rocio
@since: 	02/10/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function OGA400()
Local oMBrowse	:= Nil

oMBrowse := FWMBrowse():New()
oMBrowse:SetAlias( "NK5" )
oMBrowse:SetDescription( STR0001 ) 
oMBrowse:DisableDetails()
oMBrowse:Activate()

Return( Nil )


/** {Protheus.doc} MenuDef
Função que retorna os itens para construção do menu da rotina

@param: 	Nil
@return:	aRotina - Array com os itens do menu
@author: 	Bruna Rocio
@since: 	02/10/2014
@Uso: 		OGA400 - Modalidades
*/
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0002 , "PesqBrw"        , 0, 1, 0, .T. } ) //"Pesquisar"
aAdd( aRotina, { STR0003 , "ViewDef.OGA400", 0, 2, 0, Nil } ) //"Visualizar"
aAdd( aRotina, { STR0004 , "ViewDef.OGA400", 0, 3, 0, Nil } ) //"Incluir"
aAdd( aRotina, { STR0005 , "ViewDef.OGA400", 0, 4, 0, Nil } ) //"Alterar"
aAdd( aRotina, { STR0006 , "ViewDef.OGA400", 0, 5, 0, Nil } ) //"Excluir"
aAdd( aRotina, { STR0007 , "ViewDef.OGA400", 0, 8, 0, Nil } ) //"Imprimir"
aAdd( aRotina, { STR0008 , "ViewDef.OGA400", 0, 9, 0, Nil } ) //"Copiar"

Return( aRotina )


/** {Protheus.doc} ModelDef
Função que retorna o modelo padrao para a rotina

@param: 	Nil
@return:	oModel - Modelo de dados
@author: 	Bruna Rocio
@since: 	02/10/2014
@Uso: 		OGA400 - Modalidades
*/
Static Function ModelDef()
Local oStruNK5 := FWFormStruct( 1, "NK5" )
Local oModel := MPFormModel():New( "OGA400" )

oModel:AddFields( "NK5UNICO", Nil, oStruNK5 )
oModel:SetDescription( STR0009 ) //"Modalidade"
oModel:GetModel( "NK5UNICO" ):SetDescription( STR0009 ) //"Modalidade"

Return( oModel )


/** {Protheus.doc} ViewDef
Função que retorna a view para o modelo padrao da rotina

@param: 	Nil
@return:	oView - View do modelo de dados
@author: 	Bruna Rocio
@since: 	02/10/2014
@Uso: 		OGA400 - Modalidades
*/
Static Function ViewDef()
Local oStruNK5 := FWFormStruct( 2, "NK5" )
Local oModel   := FWLoadModel( "OGA400" )
Local oView    := FWFormView():New()

oView:SetModel( oModel )
oView:AddField( "VIEW_NK5", oStruNK5, "NK5UNICO" )
oView:CreateHorizontalBox( "UM"  , 100 )
oView:SetOwnerView( "VIEW_NK5", "UM"   )

oView:SetCloseOnOk( {||.t.} )

Return( oView )
