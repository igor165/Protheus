#INCLUDE "JURA035.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA035
Conf. Usuario Envio de Email

@author Felipe Bonvicini Conti
@since 28/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA035()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 )
oBrowse:SetAlias( "NR7" )
oBrowse:SetLocate()
//oBrowse:DisableDetails()
JurSetLeg( oBrowse, "NR7" )
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

@author Felipe Bonvicini Conti
@since 28/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA035", 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA035", 0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA035", 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA035", 0, 5, 0, NIL } ) // "Excluir"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA035", 0, 8, 0, NIL } ) // "Imprimir"

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Conf. Usuario Envio de Email

@author Felipe Bonvicini Conti
@since 28/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel := FwLoadModel( "JURA035" )
Local oStructNR7
Local oStructNR8
Local oView

//--------------------------------------------------------------
//Montagem da interface via dicionario de dados
//--------------------------------------------------------------
oStructNR7 := FWFormStruct( 2, "NR7" )
oStructNR8 := FWFormStruct( 2, "NR8" )
oStructNR8:RemoveField( "NR8_CSERVI" )
//oStructNR7:RemoveField( "NR7_DESTAB" )

//--------------------------------------------------------------
//Montagem do View normal se Container
//--------------------------------------------------------------
JurSetAgrp( 'NR7',, oStructNR7 )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA035_VIEW", oStructNR7, "NR7MASTER" )
oView:AddGrid(  "JURA035_GRID", oStructNR8 , "NR8DETAIL"  )
oView:AddIncrementField( "JURA035_GRID", "NR8_COD"  )
oView:CreateHorizontalBox( "FORMFIELD", 20 )
oView:CreateHorizontalBox( "GRID"     , 80 )
oView:SetOwnerView( "JURA035_VIEW", "FORMFIELD" )
oView:SetOwnerView( "JURA035_GRID", "GRID"      )
oView:SetUseCursor( .T. )
oView:SetDescription( STR0007 ) // "Conf. Usuario Envio de Email"
oView:EnableControlBar( .T. )
Return oView
	

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Conf. Usuario Envio de Email

@author Felipe Bonvicini Conti
@since 28/04/09
@version 1.0

@obs NR8MASTER - Cabecalho Conf. Usuario Envio de Email / NR7DETAIL - Itens Conf. Usuario Envio de Email
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStructNR8 := NIL
Local oStructNR7 := NIL
Local oModel     := NIL

//-----------------------------------------
//Monta a estrutura do formulário com base no dicionário de dados
//-----------------------------------------
oStructNR7 := FWFormStruct(1,"NR7")
oStructNR8 := FWFormStruct(1,"NR8")
//oStructNR7:RemoveField( "NR7_COD" )
oStructNR8:RemoveField( "NR8_CSERVI" )
//oStructNR7:RemoveField( "NR7_DESC" )

oStructNR8:SetProperty( "NR8_SENHA" , MODEL_FIELD_VALID , {|a,b,c,d,e,f| J035Cripty(a,b,c,d,e,f)} )

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MpFormModel():New( "JURA035", /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:AddFields( "NR7MASTER", /*cOwner*/, oStructNR7, /*Pre-Validacao*/,/*Pos-Validacao*/)
oModel:SetDescription( STR0007 ) // "Modelo de Dados da Conf. Usuario Envio de Email"
oModel:GetModel( "NR7MASTER" ):SetDescription( STR0008 ) // "Cabecalho Conf. Usuario Envio de Email"
oModel:AddGrid( "NR8DETAIL", "NR7MASTER" /*cOwner*/, oStructNR8, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )
oModel:GetModel( "NR8DETAIL" ):SetUniqueLine( { "NR8_COD" } )
oModel:SetRelation( "NR8DETAIL", { { "NR8_FILIAL", "XFILIAL('NR8')" }, { "NR8_CSERVI", "NR7_COD" } }, NR8->( IndexKey( 1 ) ) )
oModel:GetModel( "NR8DETAIL" ):SetDescription( STR0009 ) // "Itens Conf. Usuario Envio de Email"


JurSetRules( oModel, 'NR7MASTER',, 'NR7' )
JurSetRules( oModel, 'NR8DETAIL',, 'NR8' )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} J035Cripty
Encripta senha do e-mail 

@param   oModelNR8, objeto  , Estrutura do modelo de dados do grid
@param   cField   , caracter, Nome do campo
@param   cNewValue, caracter, Novo valor digitado no campo
@param   nLine    , numerico, Número da linha no grid
@param   cOldValue, caracter, Valor antigo do campo

@author  Jonatas Martins
@since   05/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J035Cripty( oModelNR8 , cField , cNewValue , nLine , cOldValue )
	Local cCriptyPass := ""
	
	If cNewValue <> cOldValue
		cCriptyPass := Embaralha( Encode64( AllTrim( cNewValue ) ) , 0 )
		oModelNR8:LoadValue( cField , cCriptyPass )
	EndIf
Return ( AllWaysTrue() )