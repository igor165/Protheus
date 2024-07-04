#INCLUDE "AGRA670.ch"
#INCLUDE "PROTHEUS.ch"
#INCLUDE "FWMVCDEF.ch"

// -----------------------------------------------------------
/*/{Protheus.doc} AGRA670
Cadastro SAI(Sistema Abrapa de Identificacao)

@param: Nil
@author: Aecio Ferreira Gomes
@since: 11/09/2012
@Uso: Generico
/*/
// -----------------------------------------------------------
Function AGRA670()   
Local aArea 	:= GetArea()
Local oBrowse 	:= Nil           

//Instancia o objeto Browse
oBrowse := FWMBrowse():New()
oBrowse:SetAlias('DX4')
oBrowse:SetDescription( STR0001  ) //"Cadastro do Sistema Abrapa de Identificação"

//Ativa o Browse
oBrowse:Activate()

RestArea(aArea) 
Return()          

// -----------------------------------------------------------
/*/{Protheus.doc} AGRA670
Retorna o modelo de dados da rotina de cadastro do S.A.I

@param: Nil
@author: Aecio Ferreira Gomes
@since: 11/09/2012
@Uso: AGRA670
/*/
// -----------------------------------------------------------
Static Function ModelDef()
Local oModel   	:= Nil
Local oStruDX4 	:= FwFormStruct( 1, "DX4" )//cadastro do S.A.I

// Instancia o modelo de dados
oModel := MpFormModel():New( 'AGRA670',/*bPre*/,/*{ |oModel|  }*/, , /*bCancel*/ )
oModel:SetDescription( STR0002)  //"Modelo de Dados do Sistema Abrapa de Identificação"

// Adiciona a estrutura de campos  do modelo de dados
oModel:AddFields( 'DX4MASTER', /*cOwner*/, oStruDX4 )
oModel:GetModel( 'DX4MASTER' ):SetDescription( STR0003)  //"Dados do  S.A.I"

// Seta chave primaria
oModel:SetPrimaryKey( {"DX4_FILIAL","DX4_EAN128","DX4_DIGEXT","DX4_PREFIX","DX4_PRENSA"} )

Return oModel

// -----------------------------------------------------------
/*/{Protheus.doc} ViewDef
Retorna a View (tela) da rotina Cadastro SAI

@param: Nil
@author: Aecio Ferreira Gomes
@since: 11/09/2012
@Uso: AGRA670
/*/
// -----------------------------------------------------------
Static Function ViewDef()
Local oView		:= Nil
Local oModel	:= FwLoadModel( "AGRA670" )
Local oStruDX4 	:= FwFormStruct( 2, "DX4" )//Cadastro SAI

//Instancia a View
oView := FwFormView():New()

// Seta o Model
oView:SetModel( oModel )

// Monta estrutura de visualização
oView:AddField( 'VIEW_DX4', oStruDX4, 'DX4MASTER' )

// Cria o Box para apresentação 
oView:CreateHorizontalBox( 'TOTAL', 100 )

// Seta Owner de visualização
oView:SetOwnerView( 'VIEW_DX4', 'TOTAL' )

Return oView

// -----------------------------------------------------------
/*/{Protheus.doc} ViewDef
Retorna o Menu da rotina de Cadastro SAI

@param: Nil
@author: Aecio Ferreira Gomes
@since: 11/09/2012
@Uso: AGRA670
/*/
// -----------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina Title OemToAnsi(STR0004)	Action 'VIEWDEF.AGRA670' OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina Title OemToAnsi(STR0005)	Action 'VIEWDEF.AGRA670' OPERATION 3 ACCESS 0 //"Incluir"
ADD OPTION aRotina Title OemToAnsi(STR0006)	Action 'VIEWDEF.AGRA670' OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina Title OemToAnsi(STR0007)	Action 'VIEWDEF.AGRA670' OPERATION 5 ACCESS 0 //"Excluir"
ADD OPTION aRotina Title OemToAnsi(STR0008)	Action 'VIEWDEF.AGRA670' OPERATION 8 ACCESS 0 //"Imprimir"

Return aRotina