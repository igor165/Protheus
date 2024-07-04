#INCLUDE "PLSPRO03.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSPRO03   ºAutor  ³Microsiga           º Data ³  09/18/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cadastro das Interações Medicamentosas                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SEGMENTO SAUDE VERSAO 11.5                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PLSPRO03()
Local oBrowse

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'BON' )
oBrowse:SetDescription( STR0001 ) //'Interações Medicamentosas'
oBrowse:Activate()

Return( NIL )


//-------------------------------------------------------------------
Static Function MenuDef()
Private aRotina := {}

aAdd( aRotina, { 'Pesquisar' , 				'PesqBrw'         , 0, 1, 0, .T. } )
aAdd( aRotina, { STR0002, 				'VIEWDEF.PLSPRO03', 0, 2, 0, NIL } ) //'Visualizar'
aAdd( aRotina, { STR0003   , 				'VIEWDEF.PLSPRO03', 0, 3, 0, NIL } ) //'Incluir'
aAdd( aRotina, { STR0004   , 				'VIEWDEF.PLSPRO03', 0, 4, 0, NIL } ) //'Alterar'
aAdd( aRotina, { STR0005   , 				'VIEWDEF.PLSPRO03', 0, 5, 0, NIL } ) //'Excluir'
aAdd( aRotina, { STR0006  , 				'VIEWDEF.PLSPRO03', 0, 8, 0, NIL } ) //'Imprimir'
aAdd( aRotina, { STR0007    , 				'VIEWDEF.PLSPRO03', 0, 9, 0, NIL } ) //'Copiar'

Return aRotina


//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados

Local oStruBON := FWFormStruct( 1, 'BON', , )
Local oStruBOO := FWFormStruct( 1, 'BOO', , )

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( STR0001, /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ ) //'Interações Medicamentosas'

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'BONMASTER', NIL, oStruBON )

// Adiciona ao modelo uma estrutura de formulário de edição por grid
oModel:AddGrid( 'BOODETAIL', 'BONMASTER', oStruBOO, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

// Faz relaciomaneto entre os compomentes do model
oModel:SetRelation( 'BOODETAIL', { { 'BOO_FILIAL', 'xFilial( "BOO" ) ' } , { 'BOO_CODIGO', 'BON_CODIGO' } } ,  BOO->( IndexKey( 1 ) ) )

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'BONMASTER' ):SetDescription( STR0001 ) //'Interações Medicamentosas'

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0001 ) //'Interações Medicamentosas'

//Valida se existem codigos duplicados no aCols
oModel:GetModel('BOODETAIL'):SetUniqueLine({'BOO_CODINT'})

Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()  

// Cria a estrutura a ser usada na View
Local oStruBOO := FWFormStruct( 2, 'BOO' )

// Cria a estrutura a ser usada na View
Local oModel   := FWLoadModel( 'PLSPRO03' )
Local oStruBON := FWFormStruct( 2, 'BON' ) 
Local oView    := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_BON' , oStruBON, 'BONMASTER'   )     

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid(  'VIEW_BOO' , oStruBOO, 'BOODETAIL'   )

// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'GERAL', 50 )
oView:CreateHorizontalBox( 'GRID', 50 )

// Cria Folder na view
//oView:CreateFolder( 'PASTA', 'GRID' )

//oView:AddSheet( 'PASTA', "ABABOO", 'Interação Negativa'  )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_BON' , 'GERAL'  )
oView:SetOwnerView( 'VIEW_BOO' , 'GRID'  )

oView:EnableTitleView( 'VIEW_BOO' )

// Define campos que terao Auto Incremento
oView:AddIncrementField( 'VIEW_BOO', 'BOO_ITEM' )   

Return oView  