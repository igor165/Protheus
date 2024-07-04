#include 'protheus.ch'
#include 'parmtype.ch'
#include "fwmvcdef.ch"
#include "OGA715.ch"

/*{Protheus.doc} OGA715
Programa de Manuten��o de Motivos de Rolagem da Instru��o de Embarque
@author marcos.wagner
@since 05/09/2017
@version undefined
@type function
*/

Function OGA715()
	Local oMBrowse := Nil
	
	//-- Prote��o de C�digo
	If .Not. TableInDic('N85')
		MsgNextRel() //-- � necess�rio a atualiza��o do sistema para a expedi��o mais recente
		Return()
	Endif	
	
	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias( "N85" )
	oMBrowse:SetDescription( STR0001 ) //"Motivos de Rolagem"
	oMBrowse:DisableDetails()
	oMBrowse:Activate()

Return( )

/** {Protheus.doc} MenuDef
Fun��o que retorna os itens para constru��o do menu da rotina

@param: 	Nil
@return:	aRotina - Array com os itens do menu
@author: 	Equipe Agroindustria
@since:     05/09/2017
@Uso: 		OGA715 - Motivos de Rolagem
*/
Static Function MenuDef()
	Local aRotina := {}
	
	aAdd( aRotina, { STR0002, "PesqBrw"       , 0, 1, 0, .T. } ) //"Pesquisar"
	aAdd( aRotina, { STR0003, "ViewDef.OGA715", 0, 2, 0, Nil } ) //"Visualizar"
	aAdd( aRotina, { STR0004, "ViewDef.OGA715", 0, 3, 0, Nil } ) //"Incluir"
	aAdd( aRotina, { STR0005, "ViewDef.OGA715", 0, 4, 0, Nil } ) //"Alterar"
	aAdd( aRotina, { STR0006, "ViewDef.OGA715", 0, 5, 0, Nil } ) //"Excluir"
	aAdd( aRotina, { STR0007, "ViewDef.OGA715", 0, 8, 0, Nil } ) //"Imprimir"
	aAdd( aRotina, { STR0008, "ViewDef.OGA715", 0, 9, 0, Nil } ) //"Copiar"

Return( aRotina )

/** {Protheus.doc} ModelDef
Fun��o que retorna o modelo padrao para a rotina

@param: 	Nil
@return:	oModel - Modelo de dados
@author: 	Equipe Agroindustria
@since:     05/09/2017
@Uso: 		OGA715 - Motivos de Rolagem
*/
Static Function ModelDef()
	Local oStruN85 := FWFormStruct( 1, "N85" )
	Local oModel := MPFormModel():New( "OGA715" )
	
	oModel:AddFields("N85UNICO", Nil, oStruN85 )
	oModel:SetDescription( STR0001) //"Motivos de Rolagem"
	oModel:GetModel( "N85UNICO" ):SetDescription( STR0001) //"Motivos de Rolagem"

Return( oModel )

/** {Protheus.doc} ViewDef
Fun��o que retorna a view para o modelo padrao da rotina

@param: 	Nil
@return:	oView - View do modelo de dados
@author: 	Equipe Agroindustria
@since:     05/09/2017
@Uso: 		OGA715 - Motivos de Rolagem
*/
Static Function ViewDef()
	Local oStruN85 := FWFormStruct( 2, "N85" )
	Local oModel   := FWLoadModel( "OGA715" )
	Local oView    := FWFormView():New()
	
	oView:SetModel( oModel )
	oView:AddField( "VIEW_N85", oStruN85, "N85UNICO" )
	oView:CreateHorizontalBox( "MASTER"  , 100 )
	oView:SetOwnerView( "VIEW_N85", "MASTER"   )
	
	oView:SetCloseOnOk( {||.t.} )

Return( oView )