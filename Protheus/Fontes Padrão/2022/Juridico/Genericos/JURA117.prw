#INCLUDE 'JURA117.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'

#DEFINE CAMPOSCAB 'NTY_TABELA|NTY_DESC|NTY_FUNCAO|'

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA117
Legendas de Rotinas

@author Ernani Forastieri
@since 01/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA117()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0009 )
oBrowse:SetAlias( 'NTY' )
//oBrowse:AddLegend( 'NTY_PROPRI == "S"', 'RED'   , STR0001 ) //"Não Permite Alteração"
//oBrowse:AddLegend( 'NTY_PROPRI <> "S"', 'GREEN' , STR0002 ) //"Permite Alteração"
oBrowse:SetLocate()
JurSetLeg( oBrowse, 'NTY' )
JurSetBSize( oBrowse )
oBrowse:Activate()

Return NIL


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@Return aRotina - Estrutura
[n, 1] Nome a aparecer no cabecalho
[n, 2] Nome da Rotina associada
[n, 3] Reservado
[n, 4] Tipo de Transação a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Alteração sem inclusão de registros
7 - Cópia
8 - Imprimir
[n, 5] Nivel de acesso
[n, 6] Habilita Menu Funcional

@author Ernani Forastieri
@since 01/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0003, 'PesqBrw'        , 0, 1, 0, .T. } ) //"Pesquisar"
aAdd( aRotina, { STR0004, 'VIEWDEF.JURA117', 0, 2, 0, NIL } ) //"Visualizar"
aAdd( aRotina, { STR0005, 'VIEWDEF.JURA117', 0, 3, 0, NIL } ) //"Incluir"
aAdd( aRotina, { STR0006, 'VIEWDEF.JURA117', 0, 4, 0, NIL } ) //"Alterar"
aAdd( aRotina, { STR0007, 'VIEWDEF.JURA117', 0, 5, 0, NIL } ) //"Excluir"
aAdd( aRotina, { STR0008, 'VIEWDEF.JURA117', 0, 8, 0, NIL } ) //"Imprimir"

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Natureza Juridica

@author Ernani Forastieri
@since 01/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel     := FWLoadModel( 'JURA117' )
Local oStructCab := FWFormStruct( 2, 'NTY', { | cCampo |  AllTrim( cCampo ) + '|' $ CAMPOSCAB } )
Local oStructNTY := FWFormStruct( 2, 'NTY', { | cCampo | !AllTrim( cCampo ) + '|' $ CAMPOSCAB } )

//JurSetAgrp( 'NTY' ,, oStructNTY )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( 'JURA117_CAB' , oStructCab, 'NTYMASTER'  )
oView:AddGrid(  'JURA117_ITEM', oStructNTY, 'NTYDETAIL'  )
oView:AddIncrementField( 'JURA117_ITEM', 'NTY_SEQ'  )

oView:CreateHorizontalBox( 'MASTER', 15 )
oView:CreateHorizontalBox( 'DETAIL', 85 )

oView:SetOwnerView( 'JURA117_CAB' , 'MASTER' )
oView:SetOwnerView( 'JURA117_ITEM', 'DETAIL' )

oView:SetDescription( STR0009 ) //"Legendas de Rotinas"


Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Legendas de Rotinas

@author Ernani Forastieri
@since 01/05/09
@version 1.0

@obs NTYMASTER - Dados do Legendas de Rotinas
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStructNTY := NIL

oStructCab := FWFormStruct( 1, 'NTY', { | cCampo |  AllTrim( cCampo ) + '|' $ CAMPOSCAB } )
oStructNTY := FWFormStruct( 1, 'NTY', { | cCampo | !AllTrim( cCampo ) + '|' $ CAMPOSCAB } )

oModel := MPFormModel():New( 'JURA117',, )

oModel:AddFields( 'NTYMASTER', NIL, oStructCab,, )
oModel:AddGrid( 'NTYDETAIL', 'NTYMASTER' /*cOwner*/, oStructNTY, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/ )

oModel:SetDescription( STR0010 ) //"Modelo de Dados de Legendas de Rotinas"

oModel:GetModel( 'NTYMASTER' ):SetDescription( STR0011 ) //'Cabecalho Dados de Legendas de Rotinas'
oModel:GetModel( 'NTYDETAIL' ):SetDescription( STR0012 ) //"Itens os de Legendas de Rotinas"
oModel:GetModel( 'NTYDETAIL' ):SetUniqueLine( { 'NTY_SEQ' } )

oModel:SetRelation( 'NTYDETAIL', { { 'NTY_FILIAL', "xFilial( 'NTY' )" } , { 'NTY_TABELA', 'NTY_TABELA' } } , NTY->( IndexKey( 1 ) ) )

//oModel:SetVldActivate( { | oModel | JURA117CAN( oModel ) } )

oModel:SetPrimaryKey( { 'NTY_FUNCAO', 'NTY_TABELA' } )
JurSetRules( oModel, 'NTYMASTER',, 'NTY' )

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} JURA117CAN
Validação das Operacoes

@author Ernani Forastieri
@since 01/05/09
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function JURA117CAN( oModel )
Local nOpc := oModel:GetOperation()

If !( lRet := !( ( nOpc == 4 .OR. nOpc == 5 ) .AND. NTY->NTY_PROPRI == 'S' ) )
	JurMsgErro( STR0013 ) //"Operação não permitida."
EndIf

Return lRet

