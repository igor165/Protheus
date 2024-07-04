#INCLUDE "JURA185.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA185
Cadastro de equipe Jurídico

@author Wellington Coelho
@since 13/04/15
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA185()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0006 )//"Cadastro de equipes juridico"
oBrowse:SetAlias( "NZ8" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "NZ8" )
JurSetBSize( oBrowse )

oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@author Wellington Coelho
@since 13/04/15
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA185", 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA185", 0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA185", 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA185", 0, 5, 0, NIL } ) // "Excluir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Cadastro de equipes juridico

@author Wellington Coelho
@since 13/04/15
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := FWLoadModel( "JURA185" )
Local oStructNZ8 := FWFormStruct( 2, "NZ8" )
Local oStructNZ9 := FWFormStruct( 2, "NZ9" )

oStructNZ8:RemoveField( "NZ8_CPARTL" )
oStructNZ9:RemoveField( "NZ9_CPART" )
oStructNZ9:RemoveField( "NZ9_CEQUIP" )

JurSetAgrp( 'NZ8',, oStructNZ8 )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:SetDescription( STR0006 )//"Cadastro de equipes juridico"

oView:AddField( "JURA185_VIEW", oStructNZ8 , "NZ8MASTER" )
oView:AddGrid( "JURA185_DETAIL", oStructNZ9 , "NZ9DETAIL" )

oView:CreateHorizontalBox( "FORMEQUIPE", 30 )
oView:CreateHorizontalBox( "FORMPART", 70 )

oView:SetOwnerView( "NZ8MASTER", "FORMEQUIPE" )
oView:SetOwnerView( "NZ9DETAIL", "FORMPART" )

oView:SetUseCursor( .T. )
oView:EnableControlBar( .T. )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Cadastro de equipes juridico

@author Wellington Coelho
@since 13/04/15
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStructNZ8 := FWFormStruct( 1, "NZ8" )
Local oStructNZ9 := FWFormStruct( 1, "NZ9" )

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oStructNZ9:RemoveField( "NZ9_CEQUIP" )

oModel:= MPFormModel():New( "JURA185", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:SetDescription( STR0007 )//"Modelo de Dados cadastro de equipe juridico"

oModel:AddFields( "NZ8MASTER", NIL /*cOwner*/, oStructNZ8, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:GetModel( "NZ8MASTER" ):SetDescription( STR0007 )//"Modelo de Dados cadastro de equipe juridico"

oModel:AddGrid( "NZ9DETAIL", "NZ8MASTER" /*cOwner*/, oStructNZ9, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )
oModel:GetModel( "NZ9DETAIL" ):SetDescription( STR0008 )//"Participantes"

oModel:GetModel( "NZ9DETAIL" ):SetUniqueLine( { "NZ9_CPART" } )

oModel:SetRelation( "NZ9DETAIL", { { "NZ9_FILIAL", "XFILIAL('NZ8')" }, { "NZ9_CEQUIP", "NZ8_COD" } }, NZ9->( IndexKey( 1 ) ) )

oModel:SetOptional( "NZ9DETAIL" , .F. )

JurSetRules( oModel, 'NZ8MASTER',, 'NZ8' )
JurSetRules( oModel, 'NZ9DETAIL',, 'NZ9' )

Return oModel

