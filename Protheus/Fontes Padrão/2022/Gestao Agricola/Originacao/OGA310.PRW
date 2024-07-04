#INCLUDE "OGA310.ch"
#include "protheus.ch"
#include "fwmvcdef.ch"


/** {Protheus.doc} OGA310


@param: 	Nil
@author: 	Equipe Agroindustria
@since: 	08/06/2010
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function OGA310()
Local oMBrowse := Nil

oMBrowse := FWMBrowse():New()
oMBrowse:SetAlias( "NNO" )
oMBrowse:SetDescription( STR0001 ) //"Operações"
oMBrowse:Activate()

Return( )


/** {Protheus.doc} MenuDef
Função que retorna os itens para construção do menu da rotina

@param: 	Nil
@return:	aRotina - Array com os itens do menu
@author: 	Equipe Agroindustria
@since: 	08/06/2010
@Uso: 		OGA010 - Entidades
*/
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0002 	, "PesqBrw"     	, 0, 1, 0, .T. } ) //"Pesquisar"
aAdd( aRotina, { STR0003		, "ViewDef.OGA310", 0, 2, 0, Nil } ) //"Visualizar"
aAdd( aRotina, { STR0004   	, "ViewDef.OGA310", 0, 3, 0, Nil } ) //"Incluir"
aAdd( aRotina, { STR0005  	, "ViewDef.OGA310", 0, 4, 0, Nil } ) //"Alterar"
aAdd( aRotina, { STR0006  	, "ViewDef.OGA310", 0, 5, 0, Nil } ) //"Excluir"
aAdd( aRotina, { STR0007  	, "ViewDef.OGA310", 0, 8, 0, Nil } ) //"Imprimir"
aAdd( aRotina, { STR0008  	, "ViewDef.OGA310", 0, 9, 0, Nil } ) //"Copiar"
//aAdd( aRotina, { STR0009  	, "OGC060"			, 0, 2, 0, Nil } ) //"Consulta"

Return( aRotina )


/** {Protheus.doc} ModelDef
Função que retorna o modelo padrao para a rotina

@param: 	Nil
@return:	oModel - Modelo de dados
@author: 	Equipe Agroindustria
@since: 	08/06/2010
@Uso: 		OGA010 - Entidades
*/
Static Function ModelDef()
Local oStruNNO := FWFormStruct( 1, "NNO" )
Local oModel := MPFormModel():New( "OGA310", , { | oModel | PosModelo( oModel ) } )

oModel:AddFields( "NNOUNICO", Nil, oStruNNO )
oModel:SetDescription( STR0001 ) //"Operações"
oModel:GetModel( "NNOUNICO" ):SetDescription( STR0010   ) //"Dados da Operação"

Return( oModel )


/** {Protheus.doc} ViewDef
Função que retorna a view para o modelo padrao da rotina

@param: 	Nil
@return:	oView - View do modelo de dados
@author: 	Equipe Agroindustria
@since: 	08/06/2010
@Uso: 		OGA010 - Entidades
*/
Static Function ViewDef()
Local oStruNNO := FWFormStruct( 2, "NNO" )
Local oModel   := FWLoadModel( "OGA310" )
Local oView    := FWFormView():New()

oView:SetModel( oModel )
oView:AddField( "VIEW_NNO", oStruNNO, "NNOUNICO" )
oView:CreateHorizontalBox( "UM"  , 100 )
oView:SetOwnerView( "VIEW_NNO", "UM"   )
oView:SetCloseOnOk( { | | .t. } )

Return( oView )


/** {Protheus.doc} PosModelo
Função que valida o modelo de dados após a confirmação

@param: 	oModel - Modelo de dados
@return:	lRetorno - verdadeiro ou falso
@author: 	Equipe Agroindustria
@since: 	08/06/2010
@Uso: 		OGA010 - Entidades
*/
Static Function PosModelo( oModel )
Local lRetorno		:= .t.
Local aAreaAtu		:= GetArea()
Local nOperation	:= oModel:GetOperation()
Local cCodOpe		:= oModel:GetValue( "NNOUNICO", "NNO_CODIGO" )

If nOperation == MODEL_OPERATION_DELETE

	BeginSql Alias 'QryNJR'
		Select Count( * ) As Total 
		From %table:NJR% NJR
		Where NJR.NJR_CODOPE = %exp:cCodOpe% And NJR.%NotDel%
	EndSql
	If QryNJR->( Total ) > 0
		lRetorno := .f.
	EndIf
	QryNJR->( dbCloseArea( ) )

EndIf

RestArea( aAreaAtu )
Return( lRetorno )
