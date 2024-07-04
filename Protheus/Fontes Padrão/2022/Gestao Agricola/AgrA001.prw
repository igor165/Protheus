#INCLUDE "AGRA001.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} AGRA001
Cadastro de Safras
@param: Nil
@author: Cleber Maldonado
@since: 11/09/2012
@Uso: SIGAAGR
/*/
// -------------------------------------------------------------------------------------
Function AGRA001()
Local oBrowse := Nil   
Local aDados := {}

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('NN1')
oBrowse:SetDescription( STR0001 )

// Adiciona legendas
oBrowse:AddLegend( "NN1_FECHAD=='N'", "GREEN", STR0008 )
oBrowse:AddLegend( "NN1_FECHAD=='S'", "RED", STR0009 )

oBrowse:Activate()

Return

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Padrao da Rotina

@param: Nil
@author: Cleber Maldonado
@since: 31/10/2012
@Uso: AGRA001
/*/
// -------------------------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}    

ADD OPTION aRotina Title STR0003	Action 'VIEWDEF.AGRA001' 	OPERATION 2 ACCESS 0
ADD OPTION aRotina Title STR0004	Action 'VIEWDEF.AGRA001' 	OPERATION 3 ACCESS 0
ADD OPTION aRotina Title STR0005	Action 'VIEWDEF.AGRA001'	OPERATION 4 ACCESS 0
ADD OPTION aRotina Title STR0006	Action 'VIEWDEF.AGRA001'	OPERATION 5 ACCESS 0

Return aRotina

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de Dados da Rotina

@param: Nil
@author: Cleber Maldonado
@since: 31/10/2012
@Uso: AGRA001
/*/
// -------------------------------------------------------------------------------------
Static Function ModelDef()

Local oModel   	:= Nil
Local oStruNN1 	:= FwFormStruct( 1, "NN1" )//Instrução de Embarque

// Instancia o modelo de dados
oModel := MpFormModel():New( 'AGRA001',/*bPre*/,/*bPos*/,/*bCommit*/,/*bCancel*/ )
oModel:SetDescription( STR0010 )

// Adiciona estrutura do cabecallho no modelo de dados 
oModel:AddFields( 'CABEC', /*cOwner*/, oStruNN1 ,  , )
oModel:GetModel( "CABEC" ):SetDescription( 'Dados da Safra' )

// Seta Chave Primaria 
oModel:SetPrimaryKey( {} )

Return oModel

// -------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Interface da rotina

@param: Nil
@author: Cleber Maldonado
@since: 31/10/2012
@Uso: AGRA001
/*/
// -------------------------------------------------------------------------------------
Static Function ViewDef()
Local oView		:= Nil
Local oModel	:= FwLoadModel( "AGRA001" )
Local oStruNN1 	:= FwFormStruct( 2, "NN1" ) // Safras

// Instancia a View
oView := FwFormView():New()

// Seta o model
oView:SetModel( oModel )

// Adiciona os campos na estrutura da View
oView:AddField( 'VIEW_NN1', oStruNN1, 'CABEC' )

// Cria o Box
oView:CreateHorizontalBox( 'SUP', 100 )

// Seta Owner
oView:SetOwnerView( 'VIEW_NN1', 'SUP' )

Return oView
