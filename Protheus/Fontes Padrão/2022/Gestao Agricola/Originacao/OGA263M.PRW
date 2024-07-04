#include "OGA261.ch"
#include "protheus.ch"
#include "fwmbrowse.ch"
#include "fwmvcdef.ch"

/** {Protheus.doc} OGA263M
Rotina para apresentação de serviços de armazenagem
***
@param: 	Nil
@author: 	Bruna Fagundes Rocio
@since: 	13/01/2015
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function OGA263M( cFecSer )

	Local aAreaAtu	
	Local oMBrowse	:= Nil
	
	Private cCod := cFecSer 
	
	dbSelectArea("NKS")
	aAreaAtu	:= GetArea()	
	
	dbSelectArea( "NKS" )
	dbSetOrder( 1 )
	dbSeek( xFilial( "NKS" ) + cCod)
	
	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias( "NKG" )
	oMBrowse:SetMenuDef( "OGA263M" )
	oMBrowse:SetDescription( STR0001 ) //"Movimentos Serviços do Contrato"
	oMBrowse:AddLegend( "NKG_STATUS='0'", "RED"	 , STR0016   ) //"Pendente"
	oMBrowse:AddLegend( "NKG_STATUS='1'", "YELLOW" , STR0017 ) //"Atualizado"
	oMBrowse:AddLegend( "NKG_STATUS='2'", "GREEN"	 , STR0018  ) //"Confirmado"
	oMBrowse:AddLegend( "NKG_STATUS='3'", "BLUE"	 , STR0019  ) //"Bonificado"
	oMBrowse:AddLegend( "NKG_STATUS='9'", "GRAY"	 , STR0020  ) //"Simulado"
	oMBrowse:DisableDetails()
	oMBrowse:SetFilterDefault( "NKG_FILIAL == '" + FWxFilial( "NKG" ) + "'" + " .And. NKG_FECSER == '" + cCod + "'" )
	oMBrowse:Activate()

Return()

/** {Protheus.doc} MenuDef
Função que retorna os itens para construção do menu da rotina
****
@param: 	Nil
@return:	aRotina - Array com os itens do menu
@author: 	Bruna Fagundes Rocio
@since: 	13/01/2015
@Uso: 		OGA263M - Movimentos Serviços do Contrato
*/

Static Function MenuDef()

	Local aRotina := {}
	
	aAdd( aRotina, { "Pesquisar", "PesqBrw"    , 0, 1, 0, .T. } ) //"Pesquisar"
	aAdd( aRotina, { STR0003, 'OGA263MVisual()', 0, 2, 0, Nil } ) //'Visualizar'
	aAdd( aRotina, { "Imprimir" , "ViewDef.OGA263M"	, 0, 8, 0, Nil } ) //"Imprimir"

Return aRotina

/** {Protheus.doc} ModelDef
Função que retorna o modelo padrao para a rotina

@param: 	Nil
@return:	oModel - Modelo de dados
@author: 	Bruna Fagundes Rocio
@since: 	13/01/2015
@Uso: 		OGA263M - Movimentos Serviços do Contrato
*/
Static Function ModelDef()

	Local oStruNKG := FWFormStruct( 1, "NKG" )
	Local oModel   := MPFormModel():New( "OGA263M" )
	
	oModel:AddFields( 'NKGUNICO', Nil, oStruNKG )
	oModel:SetDescription( STR0009 ) //"Movimentos Serviços do Contrato"
	oModel:GetModel( 'NKGUNICO' ):SetDescription( STR0010 ) //'Dados Movimentos Serviços do Contrato'

Return oModel

/** {Protheus.doc} ViewDef
Função que retorna a view para o modelo padrao da rotina

@param: 	Nil
@return:	oView - View do modelo de dados
@author: 	Bruna Fagundes Rocio
@since: 	13/01/2015
@Uso: 		OGA263M - Movimentos Serviços do Contrato
*/
Static Function ViewDef()

	Local oStruNKG := FWFormStruct( 2, 'NKG' )
	Local oModel   := FWLoadModel( 'OGA263M' )
	Local oView    := FWFormView():New()
	
	oView:SetModel( oModel )
	oView:AddField( 'VIEW_NKG', oStruNKG, 'NKGUNICO' )
	oView:CreateHorizontalBox( 'UM'  , 100 )
	oView:SetOwnerView( 'VIEW_NKG', 'UM'   )
	
	oView:SetCloseOnOk( {||.t.} )

Return oView

/** {Protheus.doc} OGA263MVisual
Função que retorna o modelo padrao para a rotina

@param: 	Nil
@return:	oModel - Modelo de dados
@author: 	Bruna Fagundes Rocio
@since: 	13/01/2015
@Uso: 		OGA263M - Movimentos Serviços do Contrato
*/

Function OGA263MVisual()

	Local xRet 
	
	xRet := FWExecView( '','OGA263M', MODEL_OPERATION_VIEW )

Return xRet

