#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TAFA251.CH'
                           
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA251
Cadastro de Varas

@author Leandro Prado
@since 22/08/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA251()
Local	oBrw	:= FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //Cadastro de Varas
oBrw:SetAlias( 'C9A')
oBrw:SetMenuDef( 'TAFA251' )
oBrw:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao generica MVC com as opcoes de menu

@author Leandro Prado
@since 22/08/2013
@version 1.0

/*/
//-------------------------------------------------------------------                                                                                            
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA251" )                                                                          

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Funcao generica MVC do model

@author Leandro Prado
@since 22/08/2013
@version 1.0

/*/
//-------------------------------------------------------------------     
Static Function ModelDef()	
Local oStruC9A := FWFormStruct( 1, 'C9A' )// Cria a estrutura a ser usada no Modelo de Dados
Local oModel := MPFormModel():New('TAFA251' )

// Adiciona ao modelo um componente de formulário
oModel:AddFields( 'MODEL_C9A', /*cOwner*/, oStruC9A)
oModel:GetModel( 'MODEL_C9A' ):SetPrimaryKey( { 'C9A_FILIAL' , 'C9A_ID' } )

Return oModel             


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@author Leandro Prado
@since 22/08/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel		:= FWLoadModel( 'TAFA251' )// objeto de Modelo de dados baseado no ModelDef() do fonte informado
Local oStruC9A		:= FWFormStruct( 2, 'C9A' )// Cria a estrutura a ser usada na View
Local oView		:= FWFormView():New()

oView:SetModel( oModel )

oView:AddField( 'VIEW_C9A', oStruC9A, 'MODEL_C9A' )

oView:EnableTitleView( 'VIEW_C9A',  STR0001 ) //Cadastro de Varas

oView:CreateHorizontalBox( 'FIELDSC9A', 100 )

oView:SetOwnerView( 'VIEW_C9A', 'FIELDSC9A' )

Return oView