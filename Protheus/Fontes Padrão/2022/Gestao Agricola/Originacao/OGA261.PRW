#INCLUDE "OGA261.ch"
#include "protheus.ch"
#include "fwmbrowse.ch"
#include "fwmvcdef.ch"

/** {Protheus.doc} OGA261
Rotina para apresentação de serviços de armazenagem
***
@param: 	Nil
@author: 	Bruna Fagundes Rocio
@since: 	28/11/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function OGA261()
Local oMBrowse := Nil

oMBrowse := FWMBrowse():New()
oMBrowse:SetAlias( "NKG" )
oMBrowse:SetDescription( STR0001 ) //"Movimentos Serviços do Contrato"
oMBrowse:AddLegend( "NKG_STATUS='0'", "RED"	 , STR0016   ) //"Pendente"
oMBrowse:AddLegend( "NKG_STATUS='1'", "YELLOW" , STR0017 ) //"Atualizado"
oMBrowse:AddLegend( "NKG_STATUS='2'", "GREEN"	 , STR0018  ) //"Confirmado"
oMBrowse:AddLegend( "NKG_STATUS='3'", "BLUE"	 , STR0019  ) //"Bonificado"
oMBrowse:AddLegend( "NKG_STATUS='4'", "PINK"	 , STR0021  ) //"Negoc.Pend."
oMBrowse:AddLegend( "NKG_STATUS='9'", "GRAY"	 , STR0020  ) //"Simulado"
oMBrowse:DisableDetails()
oMBrowse:Activate()

Return()

/** {Protheus.doc} MenuDef
Função que retorna os itens para construção do menu da rotina
****
@param: 	Nil
@return:	aRotina - Array com os itens do menu
@author: 	Bruna Fagundes Rocio
@since: 	28/11/2014
@Uso: 		OGA261 - Movimentos Serviços do Contrato
*/

Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0003, 'OGA261Visual()', 0, 2, 0, Nil } ) //'Visualizar'
aAdd( aRotina, { STR0004, 'OGA261A(NKG->NKG_CODDEV,NKG->NKG_LOJDEV)', 0, 7, 0, Nil } ) //'Acerto '
aAdd( aRotina, { STR0011, 'OGA261E(NKG->NKG_CODCTR,NKG->NKG_ITEMOV)', 0, 8, 0, Nil } ) //'Excluir'

Return aRotina

/** {Protheus.doc} ModelDef
Função que retorna o modelo padrao para a rotina

@param: 	Nil
@return:	oModel - Modelo de dados
@author: 	Bruna Fagundes Rocio
@since: 	28/11/2014
@Uso: 		OGA261 - Movimentos Serviços do Contrato
*/
Static Function ModelDef()
Local oStruNKG := FWFormStruct( 1, "NKG" )
Local oModel   := MPFormModel():New( "OGA261" )

oModel:AddFields( 'NKGUNICO', Nil, oStruNKG )
oModel:SetDescription( STR0009 ) //"Movimentos Serviços do Contrato"
oModel:GetModel( 'NKGUNICO' ):SetDescription( STR0010 ) //'Dados Movimentos Serviços do Contrato'

Return oModel

/** {Protheus.doc} ViewDef
Função que retorna a view para o modelo padrao da rotina

@param: 	Nil
@return:	oView - View do modelo de dados
@author: 	Bruna Fagundes Rocio
@since: 	01/12/2014
@Uso: 		OGA261 - Movimentos Serviços do Contrato
*/
Static Function ViewDef()
Local oStruNKG := FWFormStruct( 2, 'NKG' )
Local oModel   := FWLoadModel( 'OGA261' )
Local oView    := FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_NKG', oStruNKG, 'NKGUNICO' )
oView:CreateHorizontalBox( 'UM'  , 100 )
oView:SetOwnerView( 'VIEW_NKG', 'UM'   )

oView:SetCloseOnOk( {||.t.} )

Return oView


/** {Protheus.doc} OGA261Visual
Função que retorna o modelo padrao para a rotina

@param: 	Nil
@return:	oModel - Modelo de dados
@author: 	Bruna Fagundes Rocio
@since: 	01/12/2014
@Uso: 		OGA261 - Movimentos Serviços do Contrato
*/
Function OGA261Visual()

Local xRet 

xRet := FWExecView( '','OGA261', MODEL_OPERATION_VIEW )

Return xRet

/** {Protheus.doc} OGA261E
Função que exclui o calculo de serviços

@param: 	Nil
@return:	oModel - Modelo de dados
@author: 	Bruna Fagundes Rocio
@since: 	08/12/2014
@Uso: 		OGA261 - Movimentos Serviços do Contrato
*/

Function OGA261E( cContrato, cITEMOV, lPergunta)
	Local lRetorno := .T.
	Default lPergunta := .T.
	
	If lPergunta
		If .Not. MsgYesNo(STR0015, STR0014) //"Tem certeza que deseja excluir o cálculo de serviço selecionado?"###"Exclusão de Cálculo de Serviço"
			Return( lRetorno )
		EndIf
	EndIf

	dbSelectArea('NKG')
	dbSetOrder(1)
	If( dbSeek( xFilial('NKG') + cContrato + cITEMOV) )
		
		If Empty(NKG->NKG_FECSER) .Or. NKG->NKG_FECSER == '0'
			RecLock('NKG',.f.)
			NKG->(dbDelete())
			MsUnLock('NKG')
		Else
			Help(, , STR0012, , STR0013, 1, 0 ) //"Ajuda"###"Cálculo de Serviço não pode ser excluído pois já existe fechamento relacionado."
			lRetorno := .f.
		Endif
	Endif
	
Return lRetorno




