#INCLUDE "OGA441.CH"
#include "protheus.ch"
#include "fwmvcdef.ch"

/** {Protheus.doc} OGA440
Cadastro de Tipos de Movimentações de Contrato

@param: 	Nil
@author: 	Marlon Richard Trettin
@since: 	10/06/2015
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function OGA441()
	Local oMBrowse := Nil
	
	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias( "NKL" )
	oMBrowse:SetDescription( STR0001 ) //"Tipos de Movimentações"
//	oMBrowse:AddLegend( "NKL_PROPRI<>'S'"	, "GREEN"	, X3CboxDesc( "NKL_PROPRI", "U" ) ) //"Usuário"
//	oMBrowse:AddLegend( "NKL_PROPRI=='S'"	, "RED"	, X3CboxDesc( "NKL_PROPRI", "S" ) ) //"Sistema"
	oMBrowse:DisableDetails()
	oMBrowse:Activate()
	
Return( NIL )

/** {Protheus.doc} MenuDef
Função que retorna os itens para construção do menu da rotina

@param: 	Nil
@return:	aRotina - Array com os itens do menu
@author: 	Marlon Richard Trettin
@since: 	10/06/15
@Uso: 		OGA441
*/
Static Function MenuDef()
	Local aRotina := {}
	
	aAdd( aRotina, { STR0002, "PesqBrw"       , 0, 1, 0, .T. } ) //"Pesquisar"
	aAdd( aRotina, { STR0003, "ViewDef.OGA441", 0, 2, 0, Nil } ) //"Visualizar"
	aAdd( aRotina, { STR0004, "ViewDef.OGA441", 0, 3, 0, Nil } ) //"Incluir"
	aAdd( aRotina, { STR0005, "ViewDef.OGA441", 0, 4, 0, Nil } ) //"Alterar"
	aAdd( aRotina, { STR0006, "ViewDef.OGA441", 0, 5, 0, Nil } ) //"Excluir"
	aAdd( aRotina, { STR0007, "ViewDef.OGA441", 0, 8, 0, Nil } ) //"Imprimir"
	
Return( aRotina )

/** {Protheus.doc} ModelDef
Função que retorna o modelo padrao para a rotina

@param: 	Nil
@return:	oModel - Modelo de dados
@author: 	Marlon Richard Trettin
@since: 	10/06/15
@Uso: 		OGA441
*/
Static Function ModelDef()
	Local oStruNKL	:= FWFormStruct( 1, "NKL" )
	Local oModel
	
	//oStruNKL:SetProperty( "NKL_PROPRI" , MODEL_FIELD_INIT 	, { | | "U" } ) // U=Usuário
	
	oModel	:= MPFormModel():New( "OGA441" )
	oModel:SetVldActivate( { |oMod| OGA441VLD( oMod ) } )
	oModel:SetDescription( STR0001 ) //"Tipos de Movimentações"
	
	oModel:AddFields( "NKLUNICO", /*cOwner*/, oStruNKL, , /*bPost*/, /*bLoad */ )
	oModel:SetPrimaryKey( { "NKL_FILIAL", "NKL_TIPOMV" } )
	oModel:GetModel( "NKLUNICO" ):SetDescription( STR0001 ) //"Tipos de Movimentações"
	
Return( oModel )

/** {Protheus.doc} ViewDef
Função que retorna a view para o modelo padrao da rotina

@param: 	Nil
@return:	oView - View do modelo de dados
@author: 	Marlon Richard Trettin
@since: 	10/06/15
@Uso: 		OGA441
*/
Static Function ViewDef()
	Local oStruNKL := FWFormStruct( 2, "NKL" )
	Local oModel   := FWLoadModel( "OGA441" )
	Local oView    := FWFormView():New()

//	oStruNKL:SetProperty( "NKL_PROPRI" , MVC_VIEW_CANCHANGE, .F. )
	
	oView:SetModel( oModel )
	oView:AddField( "VIEW_NKL", oStruNKL, "NKLUNICO" )
	oView:CreateHorizontalBox( "TELA" , 100 )
	oView:SetOwnerView( "VIEW_NKL", "TELA" )
	oView:EnableTitleView( "VIEW_NKL" )
	oView:SetCloseOnOk( {||.t.} )
	
Return( oView )

/** {Protheus.doc} OGA441VLD
Função que valida a execução de operações de Alteração ou Exclusão.

@param: 	oModel
@return:	.T. ou .F.
@author: 	Marlon Richard Trettin
@since: 	10/06/15
@Uso: 		OGA441
*/
Function OGA441VLD( oModel )
	Local nOpc := oModel:GetOperation()
	Local cAliasQry
	
	/* --- Exclusão --- */
	If nOpc == MODEL_OPERATION_DELETE 
		
/*		If NKL->( NKL_PROPRI ) == "S" // S=Sistema
			Help( ,, STR0008,, STR0009, 1, 0,) //"Ajuda"##"Operacao nao permitida para Tipos de Movimentacoes padroes do Sistema."
			Return( .F. )
		EndIf
*/		
		
		// Verifica Tipo de Movimentação foi utilizado em alguma movimentação
		cAliasQry := GetNextAlias()
		BeginSql Alias cAliasQry
			Select	NKM.*
			  From %Table:NKM% NKM
			 Where	NKM.%NotDel% 
			   And NKM.NKM_FILIAL = %XFilial:NKM%
			   And	NKM.NKM_TIPOMV = %exp:NKL->( NKL_TIPOMV )%
		EndSql
		
		DbselectArea( cAliasQry )
		( cAliasQry )->( DbGoTop() )
		If .Not. ( cAliasQry )->( Eof() )
			Help( ,, STR0008,, STR0010, 1, 0,) //"Ajuda"##"Nao e permitido excluir Tipos de Movimentacoes que ja tenham sido utilizados em alguma Movimentacao. Caso nao queira mais utilizar este Tipo, voce deve coloca-lo como INATIVO."
			( cAliasQry )->( dbCloseArea() )
			Return( .F. )
		EndIf 
		( cAliasQry )->( dbCloseArea() )
		
	/* --- Alteração --- */
	ElseIf nOpc == MODEL_OPERATION_UPDATE 
		
/*		If NKL->( NKL_PROPRI ) == "S" // S=Sistema
			Help( ,, STR0008,, STR0009, 1, 0,) //"Ajuda"##"Operacao nao permitida para Tipos de Movimentacoes padroes do Sistema."
			Return( .F. )
		EndIf
*/		
		
	EndIf
	
Return( .T. )
