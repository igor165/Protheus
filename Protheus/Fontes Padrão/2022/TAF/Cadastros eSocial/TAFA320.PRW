#INCLUDE 'PROTHEUS.CH' 
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TAFA320.CH'
                           
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA320
Cadastro MVC Cor do Veiculo Montadora

@author Evandro dos Santos Oliveira
@since 24/03/2014
@version 1.0   

@Return - Nil

/*/
//-------------------------------------------------------------------
Function TAFA320()
Local	oBrw	:= FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //Cadastro de Cor do Veículo - Código Montadora
oBrw:SetAlias( 'CEL')
oBrw:SetMenuDef( 'TAFA320' )
oBrw:Activate()

Return Nil 

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao generica MVC com as opcoes de menu

@author Evandro dos Santos Oliveira
@since 24/03/2014
@version 1.0

@Return 
XFUNMnuTAF - Funcão com Menu Padrão para o módulo TAF
/*/
//-------------------------------------------------------------------                                                                                            
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA320" )                                                                          

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Funcao generica MVC do model

@author Evandro dos Santos Oliveira
@since 24/03/2014
@version 1.0

@Return 
oModel - Model da tabela/programa
/*/
//-------------------------------------------------------------------     
Static Function ModelDef()	
Local oStruCEL := FWFormStruct( 1, 'CEL' )// Cria a estrutura a ser usada no Modelo de Dados
Local oModel := MPFormModel():New('TAFA320' )

// Adiciona ao modelo um componente de formulário
oModel:AddFields( 'MODEL_CEL', /*cOwner*/, oStruCEL)
oModel:GetModel( 'MODEL_CEL' ):SetPrimaryKey( { 'CEL_FILIAL' , 'CEL_ID' } )

Return (oModel)            


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@author Evandro dos Santos Oliveira
@since 24/03/2014
@version 1.0
 
@Return 
oView -  View da Tabela/Programa
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel		:= FWLoadModel( 'TAFA320' )// objeto de Modelo de dados baseado no ModelDef() do fonte informado
Local oStruCEL		:= FWFormStruct( 2, 'CEL' )// Cria a estrutura a ser usada na View
Local oView			:= FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_CEL', oStruCEL, 'MODEL_CEL' )
oView:EnableTitleView( 'VIEW_CEL',  STR0001 ) //Cadastro de Cor do Veículo - Código Montadora
oView:CreateHorizontalBox( 'FIELDSCEL', 100 )
oView:SetOwnerView( 'VIEW_CEL', 'FIELDSCEL' )

Return (oView) 