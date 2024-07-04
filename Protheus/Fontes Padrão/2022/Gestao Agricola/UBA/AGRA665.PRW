#INCLUDE "AGRA665.ch"
#include "protheus.ch"
#include "fwmvcdef.ch"


/** {Protheus.doc} AGRA665
Rotina para cadastro de espécies de variedades de grãos

@param: 	Nil
@author: 	Bruna Fagundes Rocio
@since: 	18/06/2015
@Uso: 		SIGAARM - Originação de Grãos
*/
Function AGRA665()
	Local oMBrowse := Nil

	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias( "NKF" )
	oMBrowse:SetDescription( STR0001 ) //"Usuário X Unidade de Beneficiamento"
	oMBrowse:DisableDetails()
	oMBrowse:Activate()

Return( )


/** {Protheus.doc} MenuDef
Função que retorna os itens para construção do menu da rotina

@param: 	Nil
@return:	aRotina - Array com os itens do menu
@author: 	Bruna Fagundes Rocio
@since: 	18/06/2015
@Uso: 		AGRA665 - Tipos de Reserva
*/
Static Function MenuDef()
	Local aRotina := {}

	aAdd( aRotina, { STR0002 , "PesqBrw"        , 0, 1, 0, .T. } ) //"Pesquisar"
	aAdd( aRotina, { STR0003, "ViewDef.AGRA665", 0, 2, 0, Nil } ) //"Visualizar"
	aAdd( aRotina, { STR0004   , "ViewDef.AGRA665", 0, 3, 0, Nil } ) //"Incluir"
	aAdd( aRotina, { STR0005   , "ViewDef.AGRA665", 0, 4, 0, Nil } ) //"Alterar"
	aAdd( aRotina, { STR0006   , "ViewDef.AGRA665", 0, 5, 0, Nil } ) //"Excluir"
	aAdd( aRotina, { STR0007  , "ViewDef.AGRA665", 0, 8, 0, Nil } ) //"Imprimir"
	aAdd( aRotina, { STR0008    , "ViewDef.AGRA665", 0, 9, 0, Nil } ) //"Copiar"

Return( aRotina )


/** {Protheus.doc} ModelDef
Função que retorna o modelo padrao para a rotina

@param: 	Nil
@return:	oModel - Modelo de dados
@author: 	Bruna Fagundes Rocio
@since: 	18/06/2015
@Uso: 		AGRA665 - Tipos de Reserva
*/
Static Function ModelDef()
	Local oStruNKF := FWFormStruct( 1, "NKF" )
	Local oModel := MPFormModel():New( "AGRA665" )

	oModel:AddFields( "NKFUNICO", Nil, oStruNKF )
	oModel:SetDescription( STR0001 ) //"Usuário X Unidade de Beneficiamento"
	oModel:GetModel( "NKFUNICO" ):SetDescription( STR0009 ) //"Dados de Usuário X Unidade de Beneficiamento"

Return( oModel )


/** {Protheus.doc} ViewDef
Função que retorna a view para o modelo padrao da rotina

@param: 	Nil
@return:	oView - View do modelo de dados
@author: 	Bruna Fagundes Rocio
@since: 	18/06/2015
@Uso: 		AGRA665 - Tipos de Reserva
*/
Static Function ViewDef()
	Local oStruNKF := FWFormStruct( 2, "NKF" )
	Local oModel   := FWLoadModel( "AGRA665" )
	Local oView    := FWFormView():New()

	oView:SetModel( oModel )
	oView:AddField( "VIEW_NKF", oStruNKF, "NKFUNICO" )
	oView:CreateHorizontalBox( "UM"  , 100 )
	oView:SetOwnerView( "VIEW_NKF", "UM"   )

	oView:SetCloseOnOk( {||.t.} )

Return( oView )

Function A665VALID(cUnB )
	Local lRetorno := .F.
	Local cUser    := RetCodUsr()
	Local cUnB := if (cUnB = nil,"", cUnB)
	 
	dbSelectArea('NKF')
	dbSetOrder(1)
	If dbSeek( xFilial('NKF') + cUser )
		if !Empty(cUnB)
			if NKF->NKF_CODUNB = cUnB
				lRetorno := .T.
			else
				lRetorno := .F.
				Help("",1,STR0010,,STR0012,1)
			endif
		else
			lRetorno := .T.
		endif
	Else
		lRetorno := .F.
		Help("",1,STR0010,,STR0011,1)
	Endif
Return( lRetorno )

Function A655GETUNB( )
	Local cUN := ""
	Local cUser    := RetCodUsr()
	
	dbSelectArea('NKF')
	dbSetOrder(1)
	If dbSeek( xFilial('NKF') + cUser )
		cUN := NKF->NKF_CODUNB
	Endif
	
Return( cUN )