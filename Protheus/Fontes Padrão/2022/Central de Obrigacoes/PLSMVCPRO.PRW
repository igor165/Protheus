#include 'PROTHEUS.CH'
#include 'FWMVCDEF.CH'
#include 'PLSMVCPRO.CH'


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSMVCPRO

Manutencao de Produtos no nucleo de informacoes e obrigacoes

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLSMVCPRO(lAuto)
	Local oBrowse	:= Nil
	Default lAuto 	:= .F.

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias('B3J')
	oBrowse:SetMenuDef( 'PLSMVCPRO' )
	oBrowse:SetDescription(STR0001) //Produtos
	oBrowse:AddLegend( "B3J_STATUS=='1'", "YELLOW",	"Validacao Pendente" )
	oBrowse:AddLegend( "B3J_STATUS=='2'", "GREEN",	"Valido" )
	oBrowse:AddLegend( "B3J_STATUS=='3'", "RED",	"Invalido" )
	If !lAuto
		oBrowse:Activate()
	EndIf

Return oBrowse
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Defininao das opcoes do menu

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function MenuDef()

	Private aRotina	:= {}

	aAdd( aRotina, { STR0002	, 'PesqBrw'				, 0 , 1 , 0 , .T. } ) //Pesquisar
	aAdd( aRotina, { STR0003	, 'VIEWDEF.PLSMVCPRO'	, 0 , 2 , 0 , NIL } ) //Visualizar
	aAdd( aRotina, { STR0006	, 'VIEWDEF.PLSMVCPRO'	, 0 , 5 , 0 , NIL } ) //Excluir
	aAdd( aRotina, { STR0007	, 'VIEWDEF.PLSMVCPRO'	, 0 , 8 , 0 , NIL } ) //Imprimir
	aAdd( aRotina, { STR0008	, 'PLSCARPRO'			, 0 , 3 , 0 , NIL } ) //Imp. Produtos / Planos
	aAdd( aRotina, { STR0009	, 'PLSPROVAL' 			, 0 , 4 , 0 , NIL } )
	aAdd( aRotina, { "Cad. Segmentação"	, 'PLSMVCSEG(.F.)'	, 0 , 2 , 0 , NIL } ) //Val. Produtos / Planos
	aAdd( aRotina, { "Cad. Abrangência"	, 'PLSMVCABR(.F.)'	, 0 , 2 , 0 , NIL } ) //Val. Produtos / Planos

Return aRotina

Function PLSPROVAL()

	Local lVlSemCom := .T. // Permite validar sem compromisso posicionado.

	AVISO('A validação será executada via JOB','Dentro de instantes o Status dos produtos serão atualizados',{'OK'})
	PLSSIPVAL(,B3J->B3J_CODOPE,"1",,B3J->B3J_CODIGO, lVlSemCom)

Return
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Defininao das opcoes do menu

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ModelDef()
	Local oStruB3J := FWFormStruct( 1, 'B3J', , )
	Local oStruB3F := FWFormStruct( 1, 'B3F', , )
	Local oModel

	oModel := MPFormModel():New( STR0001, /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

	oModel:AddFields( 'B3JMASTER', NIL, oStruB3J )
	oModel:GetModel( 'B3JMASTER' ):SetDescription( STR0001 )
	oModel:SetDescription( STR0001 )

	oModel:AddGrid( 'B3FDETAIL', 'B3JMASTER', oStruB3F )
	// oModel:SetRelation( 'B3FDETAIL', {;
	// 		{'B3F_FILIAL','xFilial("B3F")'},;
	// 		{'B3F_ORICRI','"B3J"'},;
	// 		{'B3F_CHVORI','B3J->(Recno())'};
	// }, B3F->(IndexKey(1)) )
	oModel:SetRelation( 'B3FDETAIL', {;
		{'B3F_FILIAL','xFilial("B3F")'},;
		{'B3F_ORICRI','"B3J"'},;
		{'B3F_CODOPE','B3J_CODOPE'},;
		{'B3F_IDEORI','B3J_CODIGO'};
		}, B3F->(IndexKey(1)) )

	oModel:GetModel( 'B3JMASTER' ):SetDescription( STR0001 )
	oModel:GetModel( 'B3FDETAIL' ):SetDescription( "Críticas" )
	oModel:GetModel( 'B3FDETAIL' ):SetOnlyView(.T.)
	oModel:GetModel( 'B3FDETAIL' ):SetOptional(.T.)

Return oModel
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Definicao da visao MVC para a tabela B3J

@return oView	objeto view criado

@author timoteo.bega
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ViewDef()
	Local oModel   := FWLoadModel( 'PLSMVCPRO' )
	Local oStruB3J := FWFormStruct( 2, 'B3J' )
	Local oStruB3F := FWFormStruct( 2, 'B3F' )
	Local oView    := FWFormView():New()

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_B3J' , oStruB3J, 'B3JMASTER' )
	oView:AddGrid( 'VIEW_B3F' , oStruB3F, 'B3FDETAIL' )
	oStruB3F:RemoveField('B3F_CODOPE')
	oStruB3F:RemoveField('B3F_CDOBRI')
	oStruB3F:RemoveField('B3F_ANO')
	oStruB3F:RemoveField('B3F_CDCOMP')
	oView:CreateHorizontalBox( 'SUPERIOR', 60 )
	oView:CreateHorizontalBox( 'INFERIOR', 40 )
	oView:SetOwnerView( 'VIEW_B3J', 'SUPERIOR' )
	oView:SetOwnerView( 'VIEW_B3F', 'INFERIOR' )
	oView:EnableTitleView( 'VIEW_B3J', STR0001 )
	oView:EnableTitleView( 'VIEW_B3F', 'Criticas' )

Return oView