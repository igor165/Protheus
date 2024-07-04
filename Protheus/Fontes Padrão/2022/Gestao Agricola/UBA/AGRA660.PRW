#INCLUDE "AGRA660.ch"
#INCLUDE "PROTHEUS.ch"
#INCLUDE "FWMVCDEF.ch"

//--------------------------------------------------------------
/*/{Protheus.doc} AGRA660
Cadastro de Unidade de Beneficiamento

@author Aecio Ferreira Gomes
@since 08/10/2012
**/
//--------------------------------------------------------------
Function AGRA660()   
Local aArea 	:= GetArea()
Local oBrowse 	:= Nil           

//Instancia o objeto Browse
oBrowse := FWMBrowse():New()
oBrowse:SetAlias('DX3')
oBrowse:SetDescription( STR0001 ) //"Cadastro de Unidade de Beneficiamento"

//Ativa o Browse
oBrowse:Activate()

RestArea(aArea) 
Return()          

//--------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Retorna o Modelo de dados da rotina de Cadastro de Unidade de Beneficiamento

@author Aecio Ferreira Gomes
@since 08/10/2012
**/
//--------------------------------------------------------------------------
Static Function ModelDef()
Local oModel   	:= Nil
Local oStruDX3 	:= FwFormStruct( 1, "DX3" )//Cadastro de Unidade de Beneficiamento

// Instancia o modelo de dados
oModel := MpFormModel():New( 'AGRA660',/*bPre*/,/*{ |oModel| }*/, , /*bCancel*/ )
oModel:SetDescription( STR0002 ) //"Modelo de dados de Unidade de Beneficiamento"

// Adiciona estrutura de campos no modelo de dados
oModel:AddFields( 'DX3MASTER', /*cOwner*/, oStruDX3 )
oModel:SetDescription( STR0003 ) //"Dados da Unidade de Beneficiamento"

// Seta chave primaria
oModel:SetPrimaryKey( {"DX3_FILIAL","DX3_CODIGO"} )

Return oModel

//-----------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Retorna a View (tela) da rotina de Cadastro de Unidade de Beneficiamento

@author Aecio Ferreira Gomes
@since 08/10/2012
**/
//-----------------------------------------------------------------------
Static Function ViewDef()
Local oView		:= Nil
Local oModel	:= FwLoadModel( "AGRA660" )
Local oStruDX3 	:= FwFormStruct( 2, "DX3" )//Cadastro de Unidade de Beneficiamento

// Instancia modelo de visualização
oView := FwFormView():New()

// Seta o modelo de dados
oView:SetModel( oModel )

// Adciona os campos na estrutura do modelo de dados
oView:AddField( 'VIEW_DX3', oStruDX3, 'DX3MASTER' )

// Cria o box
oView:CreateHorizontalBox( 'TOTAL', 100 )

// Seta o owner
oView:SetOwnerView( 'VIEW_DX3', 'TOTAL' )

Return oView


//----------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Retorna o Menu da rotina de Cadastro de Unidade de Beneficiamento

@author Aecio Ferreira Gomes
@since 08/10/2012
**/
//----------------------------------------------------------------

Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina Title OemToAnsi(STR0004)	Action 'VIEWDEF.AGRA660' OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina Title OemToAnsi(STR0005)	Action 'VIEWDEF.AGRA660' OPERATION 3 ACCESS 0 //"Incluir"
ADD OPTION aRotina Title OemToAnsi(STR0006)	Action 'VIEWDEF.AGRA660' OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina Title OemToAnsi(STR0007)	Action 'VIEWDEF.AGRA660' OPERATION 5 ACCESS 0 //"Excluir"
ADD OPTION aRotina Title OemToAnsi(STR0008)	Action 'VIEWDEF.AGRA660' OPERATION 8 ACCESS 0 //"Imprimir"

Return aRotina
