#INCLUDE 'JURA115.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'FWMVCDEF.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA115
Regras de Preenchimento

@author Ernani Forastieri
@since 01/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA115()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0009 )
oBrowse:SetAlias( 'NTZ' )
//oBrowse:AddLegend( 'NTZ_PROPRI=="S"', 'RED'   , STR0001 ) // "Não Permite Alteração"
//oBrowse:AddLegend( 'NTZ_PROPRI<>"S"', 'GREEN' , STR0002 ) // "Permite Alteração"
oBrowse:SetLocate()
JurSetLeg( oBrowse, 'NTZ' )
JurSetBSize( oBrowse )
oBrowse:Activate()

Return NIL


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura
[n,1] Nome a aparecer no cabecalho
[n,2] Nome da Rotina associada
[n,3] Reservado
[n,4] Tipo de Transação a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Alteração sem inclusão de registros
7 - Cópia
8 - Imprimir
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author Ernani Forastieri
@since 01/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0003, 'PesqBrw'        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0004, 'VIEWDEF.JURA115', 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0005, 'VIEWDEF.JURA115', 0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { STR0006, 'VIEWDEF.JURA115', 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0007, 'VIEWDEF.JURA115', 0, 5, 0, NIL } ) // "Excluir"
aAdd( aRotina, { STR0008, 'VIEWDEF.JURA115', 0, 8, 0, NIL } ) // "Imprimir"

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
Local oModel  := FWLoadModel( 'JURA115' )
Local oStruct := FWFormStruct( 2, 'NTZ' )

JurSetAgrp( 'NTZ',, oStruct )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( 'JURA115_VIEW', oStruct, 'NTZMASTER'  )
oView:CreateHorizontalBox( 'FORMFIELD', 100 )
oView:SetOwnerView( 'JURA115_VIEW', 'FORMFIELD' )
oView:SetDescription( STR0009 ) // "Regras de Preenchimento"
oView:EnableControlBar( .T. )

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Regras de Preenchimento

@author Ernani Forastieri
@since 01/05/09
@version 1.0

@obs NTZMASTER - Dados do Regras de Preenchimento
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStructNTZ := FWFormStruct( 1, 'NTZ' )

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( 'JURA115',, { |oModel| JURA115TOK( oModel ) })
oModel:AddFields( 'NTZMASTER', NIL, oStructNTZ, , )
oModel:SetDescription( STR0010 ) // "Modelo de Dados de Regras de Preenchimento"
oModel:SetVldActivate( { |oModel| JURA115CAN( oModel ) } )
oModel:GetModel( 'NTZMASTER' ):SetDescription( STR0011 ) // "Dados de Regras de Preenchimento"
JurSetRules( oModel, 'NTZMASTER',, 'NTZ')

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} JURA115TOK
Validação Pos-Model

@author Ernani Forastieri
@since 01/05/09
@version 1.0

/*/
//-------------------------------------------------------------------
Static function JURA115TOK( oModel )
Local lRet       := .T.
Local aArea      := GetArea()
Local nOpc       := oModel:GetOperation()

If nOpc == MODEL_OPERATION_INSERT .OR. nOpc == MODEL_OPERATION_UPDATE
	//
	// Verifica chave unica da tabela
	//	
	If !JurChkPK( 'NTZ', oModel, IIf( nOpc == MODEL_OPERATION_INSERT, NIL, NTZ->( RECNO() ) ) )
		HELP( " ",1,"JAGRAVADO" )
		lRet := .F.
	EndIf
	
	
	//
	// Para gravar a informação da tabela do campo
	//	
	oModel:SetValue( 'NTZMASTER', 'NTZ_TABORI', JurPrefTab( Alltrim( oModel:GetValue( 'NTZMASTER', 'NTZ_ORIGEM' ) ) ) )
	oModel:SetValue( 'NTZMASTER', 'NTZ_TABDES', JurPrefTab( Alltrim( oModel:GetValue( 'NTZMASTER', 'NTZ_DESTIN' ) ) ) )
EndIf

RestArea( aArea )
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} JURA115CAN
Validação das Operacoes

@author Ernani Forastieri
@since 01/05/09
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function JURA115CAN( oModel )
Local nOpc := oModel:GetOperation()
Local lRet := .T.

If !( lRet := !( ( nOpc == 4 .OR. nOpc == 5 ) .AND. NTZ->NTZ_PROPRI == 'S' ) )
	JurMsgErro( STR0013 ) // "Operação não permitida."
EndIf

Return lRet
