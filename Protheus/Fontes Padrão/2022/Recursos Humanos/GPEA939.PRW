#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GPEA939.CH'
                           
//-------------------------------------------------------------------
/*/{Protheus.doc} GPEA939
Cadastro de Identificadores de Rubrica

@author Allyson L Mesashi
@since 01/10/2019
@version 1.0

/*/
//-------------------------------------------------------------------
Function GPEA939()
Local	oBrw	:= FWmBrowse():New()

If !ChkFile("RJF")
    Help( " ", 1, OemToAnsi(STR0007),, OemToAnsi(STR0007), 1, 0 )//"Tabela RJF não encontrada. Execute o UPDDISTR - atualizador de dicionário e base de dados."
    Return 	
EndIf	

oBrw:SetDescription( STR0001 ) //"Cadastro de Identificadores de Rubrica"
oBrw:SetAlias( 'RJF' )
oBrw:SetMenuDef( 'GPEA939' )
oBrw:Activate()

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao generica MVC com as opcoes de menu

@author Allyson L Mesashi
@since 01/10/2019
@version 1.0

/*/
//-------------------------------------------------------------------                                                                                            
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina Title OemToAnsi(STR0002)  Action 'PesqBrw'			OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina Title OemToAnsi(STR0003)  Action 'VIEWDEF.GPEA939'	OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina Title OemToAnsi(STR0004)  Action 'VIEWDEF.GPEA939'	OPERATION 3 ACCESS 0 //"Incluir"
ADD OPTION aRotina Title OemToAnsi(STR0005)  Action 'VIEWDEF.GPEA939'	OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina Title OemToAnsi(STR0006)  Action 'VIEWDEF.GPEA939'	OPERATION 5 ACCESS 0 //"Excluir"

Return aRotina                                                                         

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Funcao generica MVC do model

@author Allyson L Mesashi
@since 01/10/2019
@version 1.0

/*/
//-------------------------------------------------------------------     
Static Function ModelDef()	
Local oStruRJF := FWFormStruct( 1, 'RJF' )// Cria a estrutura a ser usada no Modelo de Dados
Local oModel := MPFormModel():New("GPEA939")

// Adiciona ao modelo um componente de formulário
oModel:AddFields( 'MODEL_RJF', /*cOwner*/, oStruRJF)
oModel:GetModel( 'MODEL_RJF' ):SetPrimaryKey( { 'RJF_FILIAL' , 'RJF_ID'} )

Return oModel             


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View   

@return oView - Objeto da View MVC

@author Allyson L Mesashi
@since 01/10/2019
@version 1.0                  

/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel	:= FWLoadModel( 'GPEA939' ) // objeto de Modelo de dados baseado no ModelDef() do fonte informado
Local oStruRJF	:= FWFormStruct( 2, 'RJF' ) // Cria a estrutura a ser usada na View
Local oView		:= FWFormView():New()

oView:SetModel( oModel )

oView:AddField( 'VIEW_RJF', oStruRJF, 'MODEL_RJF' )

oView:EnableTitleView( 'VIEW_RJF',  STR0001 ) //Cadastro de Identificadores de Rubrica

oView:CreateHorizontalBox( 'FIELDSRJF', 100 )

oView:SetOwnerView( 'VIEW_RJF', 'FIELDSRJF' )

Return oView
