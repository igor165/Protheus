#include 'protheus.ch'
#include 'parmtype.ch'
#include "fwmvcdef.ch"
#include "OGA050.ch"

/*{Protheus.doc} OGA050
Programa de Manuten��o de Descontos de �gio e Des�gio
@author jean.schulze
@since 30/05/2017
@version undefined
@type function
*/

Function OGA050()
	Local oMBrowse := Nil

	//-- Prote��o de C�digo
	If .Not. TableInDic('N7K')
		MsgNextRel() //-- � necess�rio a atualiza��o do sistema para a expedi��o mais recente
		Return()
	Endif

	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias( "N7K" )
	oMBrowse:SetDescription( STR0001 ) //Descontos de �gio Des�gio
	oMBrowse:DisableDetails()
	oMBrowse:Activate()

Return( )

/** {Protheus.doc} MenuDef
Fun��o que retorna os itens para constru��o do menu da rotina

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
Fun��o que retorna o modelo padrao para a rotina

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
	oModel:SetDescription( STR0009) //"Desconto �gio Des�gio"
	oModel:GetModel( "N7KUNICO" ):SetDescription( STR0009) //"Desconto �gio Des�gio"

Return( oModel )

/** {Protheus.doc} ViewDef
Fun��o que retorna a view para o modelo padrao da rotina

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