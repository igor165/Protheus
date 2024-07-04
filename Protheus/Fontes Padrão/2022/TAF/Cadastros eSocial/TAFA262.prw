#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TAFA262.CH'
                           
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA262
Cadastro de Médicos

@author Leandro Prado
@since 05/09/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA262()

Local	oBrw	:= FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //Cadastro de Médicos
oBrw:SetAlias( 'CM7')
oBrw:SetMenuDef( 'TAFA262' )
oBrw:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao generica MVC com as opcoes de menu

@author Leandro Prado
@since 05/09/2013
@version 1.0

/*/
//-------------------------------------------------------------------                                                                                            
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA262" )                                                                          

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Funcao generica MVC do model

@author Leandro Prado
@since 05/09/2013
@version 1.0

/*/
//-------------------------------------------------------------------     
Static Function ModelDef()	
Local oStruCM7 := FWFormStruct( 1, 'CM7' )// Cria a estrutura a ser usada no Modelo de Dados
Local oModel := MPFormModel():New('TAFA262' )

// Adiciona ao modelo um componente de formulário
oModel:AddFields( 'MODEL_CM7', /*cOwner*/, oStruCM7)
oModel:GetModel( 'MODEL_CM7' ):SetPrimaryKey( { 'CM7_FILIAL' , 'CM7_ID'} )

Return oModel             


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@author Leandro Prado
@since 05/09/2013
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel		:= FWLoadModel( 'TAFA262' )// objeto de Modelo de dados baseado no ModelDef() do fonte informado
Local oStruCM7		:= FWFormStruct( 2, 'CM7' )// Cria a estrutura a ser usada na View
Local oView		:= FWFormView():New()

oView:SetModel( oModel )

oView:AddField( 'VIEW_CM7', oStruCM7, 'MODEL_CM7' )

oView:EnableTitleView( 'VIEW_CM7',  STR0001 ) //Cadastro de Médicos

oView:CreateHorizontalBox( 'FIELDSCM7', 100 )

oView:SetOwnerView( 'VIEW_CM7', 'FIELDSCM7' )


Return oView