#include 'protheus.ch'
#include 'parmtype.ch'
#include "fwmvcdef.ch"
#include "OGA050.ch"

/*{Protheus.doc} OGA050
Programa de Manutenção de Descontos de Ágio e Deságio
@author jean.schulze
@since 30/05/2017
@version undefined
@type function
*/

Function OGA050()
	Local oMBrowse := Nil

	//-- Proteção de Código
	If .Not. TableInDic('N7K')
		MsgNextRel() //-- É necessário a atualização do sistema para a expedição mais recente
		Return()
	Endif

	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias( "N7K" )
	oMBrowse:SetDescription( STR0001 ) //Descontos de Ágio Deságio
	oMBrowse:DisableDetails()
	oMBrowse:Activate()

Return( )

/** {Protheus.doc} MenuDef
Função que retorna os itens para construção do menu da rotina

@param: 	Nil
@return:	aRotina - Array com os itens do menu
@author: 	jean.schulze
@since:     30/05/2017
@Uso: 		OGA050 - Tipos de Reserva
*/
Static Function MenuDef()
	Local aRotina := {}

	aAdd( aRotina, { STR0002, "PesqBrw"       , 0, 1, 0, .T. } ) //"Pesquisar"
	aAdd( aRotina, { STR0003, "ViewDef.OGA050", 0, 2, 0, Nil } ) //"Visualizar"
	aAdd( aRotina, { STR0004, "ViewDef.OGA050", 0, 3, 0, Nil } ) //"Incluir"
	aAdd( aRotina, { STR0005, "ViewDef.OGA050", 0, 4, 0, Nil } ) //"Alterar"
	aAdd( aRotina, { STR0006, "ViewDef.OGA050", 0, 5, 0, Nil } ) //"Excluir"
	aAdd( aRotina, { STR0007, "ViewDef.OGA050", 0, 8, 0, Nil } ) //"Imprimir"
	aAdd( aRotina, { STR0008, "ViewDef.OGA050", 0, 9, 0, Nil } ) //"Copiar"

Return( aRotina )

/** {Protheus.doc} ModelDef
Função que retorna o modelo padrao para a rotina

@param: 	Nil
@return:	oModel - Modelo de dados
@author: 	jean.schulze
@since:     30/05/2017
@Uso: 		OGA050 - Tipos de Reserva
*/
Static Function ModelDef()
	Local oStruN7K := FWFormStruct( 1, "N7K" )
	Local oModel := MPFormModel():New( "OGA050" )

	oModel:AddFields("N7KUNICO", Nil, oStruN7K )
	oModel:SetDescription( STR0009) //"Desconto Ágio Deságio"
	oModel:GetModel( "N7KUNICO" ):SetDescription( STR0009) //"Desconto Ágio Deságio"

Return( oModel )

/** {Protheus.doc} ViewDef
Função que retorna a view para o modelo padrao da rotina

@param: 	Nil
@return:	oView - View do modelo de dados
@author: 	jean.schulze
@since:     30/05/2017
@Uso: 		OGA050 - Tipos de Reserva
*/
Static Function ViewDef()
	Local oStruN7K := FWFormStruct( 2, "N7K" )
	Local oModel   := FWLoadModel( "OGA050" )
	Local oView    := FWFormView():New()

	oView:SetModel( oModel )
	oView:AddField( "VIEW_N7K", oStruN7K, "N7KUNICO" )
	oView:CreateHorizontalBox( "MASTER"  , 100 )
	oView:SetOwnerView( "VIEW_N7K", "MASTER"   )

	oView:SetCloseOnOk( {||.t.} )

Return( oView )