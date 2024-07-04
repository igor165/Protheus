#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TAFA406.CH'
                           
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA406
Cadastro de Identificadores de Rubrica

@author Anderson Costa
@since 12/11/2015
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA406()

Local	oBrw	:= FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //Cadastro de Identificadores de Rubrica
oBrw:SetAlias( 'T3M' )
oBrw:SetMenuDef( 'TAFA406' )
oBrw:Activate()

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao generica MVC com as opcoes de menu

@author Anderson Costa
@since 12/11/2015
@version 1.0

/*/
//-------------------------------------------------------------------                                                                                            
Static Function MenuDef()
Return XFUNMnuTAF( "TAFA406" )                                                                          

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Funcao generica MVC do model

@author Anderson Costa
@since 12/11/2015
@version 1.0

/*/
//-------------------------------------------------------------------     
Static Function ModelDef()	
Local oStruT3M := FWFormStruct( 1, 'T3M' )// Cria a estrutura a ser usada no Modelo de Dados
Local oModel := MPFormModel():New("TAFA406")

lVldModel := Iif( Type( "lVldModel" ) == "U", .F., lVldModel )

If lVldModel
	oStruT3M:SetProperty( "*", MODEL_FIELD_VALID, {|| lVldModel })
EndIf

// Adiciona ao modelo um componente de formulário
oModel:AddFields( 'MODEL_T3M', /*cOwner*/, oStruT3M)
oModel:GetModel( 'MODEL_T3M' ):SetPrimaryKey( { 'T3M_FILIAL' , 'T3M_ID'} )

Return oModel             


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View   

@return oView - Objeto da View MVC

@author Anderson Costa
@since 12/11/2015
@version 1.0                  

/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel	:= FWLoadModel( 'TAFA406' ) // objeto de Modelo de dados baseado no ModelDef() do fonte informado
Local oStruT3M	:= FWFormStruct( 2, 'T3M' ) // Cria a estrutura a ser usada na View
Local oView		:= FWFormView():New()

oView:SetModel( oModel )

oView:AddField( 'VIEW_T3M', oStruT3M, 'MODEL_T3M' )

oView:EnableTitleView( 'VIEW_T3M',  STR0001 ) //Cadastro de Identificadores de Rubrica

oView:CreateHorizontalBox( 'FIELDST3M', 100 )

oView:SetOwnerView( 'VIEW_T3M', 'FIELDST3M' )

oStruT3M:RemoveField( "T3M_VERSAO" )

Return oView
